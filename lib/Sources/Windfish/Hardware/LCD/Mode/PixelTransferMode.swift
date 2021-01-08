import Foundation

extension UnsafeMutableRawBufferPointer {
  fileprivate subscript(index: LR35902.Address) -> UInt8 {
    get { return self[Int16(bitPattern: index)] }
    set { self[Int16(bitPattern: index)] = newValue }
  }
  fileprivate subscript(index: Int16) -> UInt8 {
    get { return self[Int(truncatingIfNeeded: index)] }
    set { self[Int(truncatingIfNeeded: index)] = newValue }
  }
}

extension PPU {
  private static let TilesPerRow: UInt16 = 32
  private static let PixelsPerTile: UInt16 = 8
  private static let BytesPerTile: Int16 = 16
  private static let BytesPerLine: Int16 = 2

  final class PixelTransferMode: PPUMode {
    init(registers: LCDRegisters, lineCycleDriver: LineCycleDriver) {
      self.registers = registers
      self.lineCycleDriver = lineCycleDriver
      self.fifo = Fifo()
      self.fetcher = Fetcher(registers: registers, fifo: fifo)
    }

    private let registers: LCDRegisters
    private let lineCycleDriver: LineCycleDriver

    var intersectedOAMs: [OAM.Sprite] = []

    struct Pixel: Equatable {
      let colorIndex: UInt8
      let palette: Palette
      let spritePriority: UInt8
      let bgPriority: UInt8
    }
    final class Fifo {
      var pixels: [Pixel] = []

      func dequeuePixel() -> UInt8 {
        let pixel = pixels.removeFirst()
        return pixel.palette[Int(truncatingIfNeeded: pixel.colorIndex)]
      }
    }
    final class Fetcher {
      init(registers: LCDRegisters, fifo: Fifo) {
        self.registers = registers
        self.fifo = fifo
      }

      private let registers: LCDRegisters
      private let fifo: Fifo

      private(set) var tileMapAddress: LR35902.Address = 0
      private(set) var tileDataAddress: TileDataAddress = .x8000
      private(set) var tileMapAddressOffset: UInt16 = 0
      private(set) var tilePixelY: Int16 = 0
      private(set) var tickAlternator = false
      enum State {
        case readTileNumber
        case readData0
        case readData1
        case pushToFifo
      }
      private(set) var state: State = .readTileNumber
      private(set) var tileIndex: UInt8 = 0
      private(set) var data0: UInt8 = 0
      private(set) var data1: UInt8 = 0

      /** Prepares the fetcher to start fetching a new line of pixels. */
      func start(tileMapAddress: TileMapAddress, tileDataAddress: TileDataAddress, x: UInt8, y: UInt8) {
        let wideX = UInt16(truncatingIfNeeded: x)
        let wideY = UInt16(truncatingIfNeeded: y)

        tickAlternator = false
        state = .readTileNumber
        self.tileMapAddress = tileMapAddress.address + (wideY / PPU.PixelsPerTile) * PPU.TilesPerRow
        self.tileDataAddress = tileDataAddress
        tileMapAddressOffset = wideX / PPU.PixelsPerTile
        tilePixelY = Int16(bitPattern: wideY % PPU.PixelsPerTile)
        fifo.pixels.removeAll()
      }

      func tick() {
        // Fetcher operates on a 2 t-cycle clock speed.
        // - "The Ultimate Game Boy Talk (33c3)": https://youtu.be/HyzD8pNlpwI?t=3054
        tickAlternator = !tickAlternator
        if tickAlternator {
          return
        }

        switch state {
        case .readTileNumber:
          tileIndex = registers.tileMap[tileMapAddress + tileMapAddressOffset - PPU.tileMapRegion.lowerBound]
          state = .readData0

        case .readData0:
          data0 = getBackgroundTileData(tileIndex: tileIndex, byte: 0)
          state = .readData1

        case .readData1:
          data1 = getBackgroundTileData(tileIndex: tileIndex, byte: 1)
          state = .pushToFifo

        case .pushToFifo:
          if fifo.pixels.count > 8 {
            // Fetcher stalls when the fifo doesn't have enough space to push a new block of 8 pixels.
            // - "The Ultimate Game Boy Talk (33c3)": https://youtu.be/HyzD8pNlpwI?t=3074
            break
          }
          for i: UInt8 in stride(from: 7, through: 0, by: -1) {
            let bitMask: UInt8 = 1 << i
            let lsb: UInt8 = ((data0 & bitMask) > 0) ? 0b01 : 0
            let msb: UInt8 = ((data1 & bitMask) > 0) ? 0b10 : 0
            fifo.pixels.append(.init(colorIndex: msb | lsb, palette: registers.backgroundPalette,
                                     spritePriority: 0, bgPriority: 0))
          }
          tileMapAddressOffset = (tileMapAddressOffset + 1) % PPU.TilesPerRow

          // The existence of a distinct pushToFifo state is somewhat ambiguous, as both of the canonical references on
          // PPU timing seem to imply that there are only 6 t-cycles for a given block of 8 pixels.
          // - http://blog.kevtris.org/blogfiles/Nitty%20Gritty%20Gameboy%20VRAM%20Timing.txt
          // - https://youtu.be/HyzD8pNlpwI?t=3087
          // It's unclear when the fifo is updated, but keeping it as a separate state causes the baseline t-cycle for a
          // line to be 175 rather than 173. So to avoid the extra two t-cycles we skip directly to the readData0 state
          // and read the tile index here. There might be a more accurate way to represent this.
          tileIndex = registers.tileMap[tileMapAddress + tileMapAddressOffset - PPU.tileMapRegion.lowerBound]
          state = .readData0
        }
      }

      private func getBackgroundTileData(tileIndex: UInt8, byte: Int16) -> UInt8 {
        // For simplicity's sake, we always treat the tile index as a signed 16 bit value. We can do this because the
        // tile index can never, by definition, be greater than 255, so there's no risk of the unsigned tile index
        // becoming negative.
        let dataIndex: Int16
        switch tileDataAddress {
        // Converting from UInt8 to Int16 requires a bit of a dance depending on the intended representation of the
        // UInt8's value. When it's actually a signed value, we need to be careful that extending the size of the byte
        // also extends the sign bit. Doing so requires that we bit-pattern cast to an Int8 and then extend the size to
        // an Int16.
        case .x8800: dataIndex = Int16(truncatingIfNeeded: Int8(bitPattern: tileIndex))
        // Extending an unsigned byte is a bit more straightforward, as we can directly extend the type to a UInt16.
        case .x8000: dataIndex = Int16(bitPattern: UInt16(truncatingIfNeeded: tileIndex))
        }
        // Each Tile occupies 16 bytes, where each 2 bytes represent a line:
        // Byte 0-1  First Line (Upper 8 pixels)
        // Byte 2-3  Next Line
        // etc.
        // - https://gbdev.io/pandocs/#video-display
        // tilePixelY determines which byte pair we want to read, and is doubled to account for the two-byte size of a
        // single line.
        let tileOffset = dataIndex &* PPU.BytesPerTile
        let tileLineOffset = tilePixelY &* PPU.BytesPerLine
        let address = tileDataAddress.baseAddress &+ UInt16(bitPattern: tileOffset + tileLineOffset + byte)
        return registers.tileData[Int(truncatingIfNeeded: address - PPU.tileDataRegion.lowerBound)]
      }
    }
    private let fetcher: Fetcher
    private var fifo: Fifo
    private var droppedPixels: UInt8 = 0
    private var screenPlotAnchor: Int = 0
    private var screenPlotOffset: Int = 0
    private var oamIterator: IndexingIterator<[OAM.Sprite]>?
    private var tcycle: Int = 0

    private var scanlineX: UInt8 = 0
    private var scanlineScrollX: UInt8 = 0
    private var windowYPlot: UInt8 = 0
    private var bgYPlot: UInt8 = 0
    private var lastBackgroundPixel: UInt8 = 0

    /** Starts the mode. */
    func start() {
      // Note that we don't reset lineCycleDriver.cycles here because we're continuing to cycle through this ly.

      // TODO: Check registers.backgroundEnable and registers.windowEnable
      precondition(registers.backgroundEnable)  // Disabled behavior not currently implemented.
      precondition(!registers.windowEnable)  // Window not currently implemented.

      // FIFO+Fetcher logic
      fetcher.start(tileMapAddress: registers.backgroundTileMapAddress,
                    tileDataAddress: registers.tileDataAddress,
                    x: registers.scx,
                    y: lineCycleDriver.scanline &+ registers.scy)
      droppedPixels = 0
      screenPlotAnchor = Int(truncatingIfNeeded: lineCycleDriver.scanline) * PPU.screenSize.width
      screenPlotOffset = 0
      oamIterator = intersectedOAMs.makeIterator()
      tcycle = 0

      // Old logic
      windowYPlot = lineCycleDriver.scanline &- registers.windowY
      bgYPlot = lineCycleDriver.scanline &+ registers.scy
      scanlineX = 0
      scanlineScrollX = registers.scx
    }

    func tick(memory: AddressableMemory) -> LCDCMode? {
      tcycle += 1

      fetcher.tick()

      if registers.backgroundEnable {
        // The fifo requires at least 9 pixels in order to be able to pop a pixel off. This ensures that there are
        // always at least 8 pixels for the purposes of compositing sprites onto the background pixels.
        // Until there are at least 9 pixels, the fifo stalls.
        if fifo.pixels.count <= 8 {
          return nil
        }

        // Scrolling is implemented by dropping pixels from the fifo up until the scx.
        // - "The Ultimate Game Boy Talk (33c3)": https://youtu.be/HyzD8pNlpwI?t=3104
        //
        // "The program running on the GB CPU can still change various registers like SCX and SCY when a line is being
        // "drawn to the screen. (I.e. during mode 3.) At least one officially released game makes heavy used of that:
        // Prehistorik Man which is using it in its intro to draw text using palette changes, and probably in some
        // places in the gameplay as well. Not to mention demoscene demos, which (ab)use this a lot, for example Mental
        // Respirator and 20Y, which use this for things like wobbly image stretching and other special effects."
        // - http://forums.nesdev.com/viewtopic.php?f=20&t=10771#p122197
        // This is why we use registers.scx directly here rather than a cached value at the start of the line.
        if droppedPixels < registers.scx % UInt8(truncatingIfNeeded: PPU.PixelsPerTile) {
          fifo.pixels.removeFirst()
          droppedPixels += 1

          // Because scx can change mid-line, we can't use the simple (173 + (xscroll % 7)) formula outlined in
          // http://blog.kevtris.org/blogfiles/Nitty%20Gritty%20Gameboy%20VRAM%20Timing.txt
          // Instead, we offset the tcycle counter for each cycle spent dropping a pixel.
          tcycle -= 1
          return nil
        }

        // TODO: Check if we need to start fetching the window.
      }

      if registers.objEnable {
        // When a sprite is detected, the fetcher switches temporarily to a sprite fetch mode
        // - "The Ultimate Game Boy Talk (33c3)": https://youtu.be/HyzD8pNlpwI?t=3179
        // TODO: Implement spriting.
//        while let sprite = oamIterator?.next() {
//          if sprite.x == 0
//        }
      }

      // This is first executed on cycle 4 of the pixel transfer. It takes two machine cycles to load one tile line
      // into the fifo, and the fifo must always have at least 8 pixels in it before pixels can be dequeued, so we
      // load a second tile's line for an additional two machine cycles.
      registers.screenData[screenPlotAnchor + screenPlotOffset] = fifo.dequeuePixel()

      screenPlotOffset += 1
      if screenPlotOffset >= 160 {
        precondition(tcycle == 173)
        registers.requestHBlankInterruptIfNeeded(memory: memory)
        return .hblank
      }
      return nil
    }

    /** Executes a single machine cycle.  */
    func advance(memory: AddressableMemory) -> LCDCMode? {
      lineCycleDriver.cycles += 1

      for _ in 1...4 {
        if let nextMode = tick(memory: memory) {
          // TODO: This doesn't always consume an entire machine cycle, so may need to move to tick-based emulation
          // in order to time this correctly.
          return nextMode
        }
      }
      return nil

      var nextMode: LCDCMode? = nil

      if lineCycleDriver.cycles > PPU.searchingOAMLength + 1 && scanlineX < 160 {
        plot()
        scanlineX += 1
        plot()
        scanlineX += 1
        plot()
        scanlineX += 1
        plot()
        scanlineX += 1
      }

      if lineCycleDriver.cycles >= PPU.searchingOAMLength + 43 {
        precondition(scanlineX >= 160)
        nextMode = .hblank
        // Don't reset lcdModeCycle yet, as this mode can actually end early.

        registers.requestHBlankInterruptIfNeeded(memory: memory)
      }

      return nextMode
    }

    private func plot(x: UInt8, y: UInt8, byte: UInt8, palette: Palette) {
      let color = palette[Int(bitPattern: UInt(truncatingIfNeeded: byte))]
      registers.screenData[Int(bitPattern: UInt(truncatingIfNeeded: PPU.screenSize.width) * UInt(truncatingIfNeeded: y) + UInt(truncatingIfNeeded: x))] = color
    }

    private func plot() {
      if registers.windowEnable && (registers.windowX &- 7) <= scanlineX && registers.windowY <= lineCycleDriver.scanline {
        plot(x: scanlineX, y: lineCycleDriver.scanline,
             byte: backgroundPixel(x: scanlineX &- (registers.windowX &- 7), y: windowYPlot, window: true),
             palette: registers.backgroundPalette)
      } else if registers.backgroundEnable {
        plot(x: scanlineX, y: lineCycleDriver.scanline,
             byte: backgroundPixel(x: scanlineX &+ scanlineScrollX, y: bgYPlot, window: false),
             palette: registers.backgroundPalette)
      } else {
        lastBackgroundPixel = 0
      }

      if intersectedOAMs.isEmpty {
        return
      }

      for sprite in intersectedOAMs {
        guard sprite.x > scanlineX && sprite.x <= scanlineX + 8 else {
          continue
        }
        let wideScanlineX = Int16(truncatingIfNeeded: Int8(bitPattern: scanlineX))
        let wideScanlineY = Int16(truncatingIfNeeded: Int8(bitPattern: lineCycleDriver.scanline))
        let wideSpriteX = Int16(truncatingIfNeeded: Int8(bitPattern: sprite.x))
        let wideSpriteY = Int16(truncatingIfNeeded: Int8(bitPattern: sprite.y))
        let tileIndex: Int16
        var tileOffsetX = wideScanlineX + 8 - wideSpriteX
        var tileOffsetY = wideScanlineY + 16 - wideSpriteY

        switch registers.spriteSize {
        case .x8x16:
          let wideTile = Int16(truncatingIfNeeded: Int8(bitPattern: sprite.tile))
          if tileOffsetY > 7 && !sprite.yflip {
            tileOffsetY -= 8;
            tileIndex = wideTile | 0x01
          } else if tileOffsetY <= 7 && !sprite.yflip  {
            tileIndex = wideTile & 0xFE
          } else if tileOffsetY > 7 && sprite.yflip {
            tileOffsetY = 15 - tileOffsetY
            tileIndex = wideTile & 0xFE
          } else if tileOffsetY <= 7 && sprite.yflip {
            tileIndex = wideTile | 0x01
            tileOffsetY = 7 - tileOffsetY
          } else {
            tileIndex = 0
          }
        case .x8x8:
          tileIndex = Int16(truncatingIfNeeded: Int8(bitPattern: sprite.tile))
          if sprite.yflip {
            tileOffsetY = 7 - tileOffsetY
          }
        }
        if sprite.xflip {
          tileOffsetX = 7 - tileOffsetX
        }

        let tileData0: UInt8
        let tileData1: UInt8
        let tileDataIndex = Int(truncatingIfNeeded: (tileIndex &* 16) &+ tileOffsetY &* 2)
        tileData0 = registers.tileData[tileDataIndex]
        tileData1 = registers.tileData[tileDataIndex + 1]

        let lsb: UInt8 = (tileData0 & (0x80 >> tileOffsetX)) > 0 ? 0b01 : 0
        let msb: UInt8 = (tileData1 & (0x80 >> tileOffsetX)) > 0 ? 0b10 : 0
        let pixel = msb | lsb
        if pixel > 0 {
          let pixelBehindBg = sprite.priority && lastBackgroundPixel > 0
          if !pixelBehindBg {
            let palette: Palette
            switch sprite.palette {
            case .obj0pal:
              palette = registers.objectPallete0
            case .obj1pal:
              palette = registers.objectPallete1
            }
            plot(x: scanlineX, y: lineCycleDriver.scanline, byte: pixel, palette: palette)
          }
          break
        }
      }
    }

    private func backgroundPixel(x: UInt8, y: UInt8, window: Bool) -> UInt8 {
      let wideX = UInt16(truncatingIfNeeded: x)
      let wideY = UInt16(truncatingIfNeeded: y)
      let tileX = Int16(bitPattern: wideX / 8)
      let tileY = Int16(bitPattern: wideY / 8)
      let tileOffsetX = Int16(bitPattern: wideX % 8)
      let tileOffsetY = Int16(bitPattern: wideY % 8)

      let tileIndex: UInt8
      let tileMapIndex = Int(truncatingIfNeeded: tileX &+ tileY &* 32)
      switch window ? registers.windowTileMapAddress : registers.backgroundTileMapAddress {
      case .x9800:
        tileIndex = registers.tileMap[tileMapIndex]
      case .x9C00:
        tileIndex = registers.tileMap[0x400 + tileMapIndex]
      }

      let tileData0: UInt8
      let tileData1: UInt8
      switch registers.tileDataAddress {
      case .x8800:
        let signedTileIndex = Int8(bitPattern: tileIndex)
        let tileDataIndex = 0x1000 + Int(truncatingIfNeeded: (Int16(truncatingIfNeeded: signedTileIndex) &* 16) &+ tileOffsetY &* 2)
        tileData0 = registers.tileData[tileDataIndex]
        tileData1 = registers.tileData[tileDataIndex + 1]
      case .x8000:
        let tileDataIndex = Int(truncatingIfNeeded: Int16(bitPattern: UInt16(truncatingIfNeeded: tileIndex) &* 16) &+ tileOffsetY &* 2)
        tileData0 = registers.tileData[tileDataIndex]
        tileData1 = registers.tileData[tileDataIndex + 1]
      }

      let lsb: UInt8 = (tileData0 & (0x80 >> tileOffsetX)) > 0 ? 0b01 : 0
      let msb: UInt8 = (tileData1 & (0x80 >> tileOffsetX)) > 0 ? 0b10 : 0

      lastBackgroundPixel = msb | lsb
      return lastBackgroundPixel
    }
  }
}
