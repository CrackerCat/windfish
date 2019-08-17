import Foundation
import LR35902

let data = try Data(contentsOf: URL(fileURLWithPath: "/Users/featherless/workbench/awakenlink/rom/LinksAwakening.gb"))

let disassembly = LR35902.Disassembly(rom: data)

disassembly.setLabel(at: 0x0003, in: 0x00, named: "DEBUG_TOOL")
disassembly.setData(at: 0x0003, in: 0x00)

disassembly.setLabel(at: 0x0150, in: 0x00, named: "Main")
disassembly.setPreComment(at: 0x0156, in: 0x00, text: "Reset the palette registers to zero.")

disassembly.setPreComment(at: 0x015D, in: 0x00, text: "Clears 6144 bytes of video ram. Graphics vram location for OBJ and BG tiles start at $8000 and end at $97FF; for a total of 0x1800 bytes.")

// MARK: - Bank 0 functions
disassembly.defineFunction(startingAt: 0x07B9, in: 0x00, named: "SetBank")
disassembly.defineFunction(startingAt: 0x2881, in: 0x00, named: "LCDOff")
disassembly.defineFunction(startingAt: 0x28A8, in: 0x00, named: "FillBGWith7F")
disassembly.defineFunction(startingAt: 0x28C5, in: 0x00, named: "CopyMemoryRegion")
disassembly.defineFunction(startingAt: 0x28F2, in: 0x00, named: "CopyBackgroundData")
disassembly.defineFunction(startingAt: 0x298A, in: 0x00, named: "ClearHRAM")
disassembly.defineFunction(startingAt: 0x2999, in: 0x00, named: "ClearMemoryRegion")
disassembly.defineFunction(startingAt: 0x2B6B, in: 0x00, named: "LoadInitialTiles")

// MARK: - Bank 1 functions
disassembly.defineFunction(startingAt: 0x40CE, in: 0x01, named: "LCDOn")
disassembly.defineFunction(startingAt: 0x46DD, in: 0x01, named: "InitSave")
disassembly.defineFunction(startingAt: 0x460F, in: 0x01, named: "InitSaves")
disassembly.defineFunction(startingAt: 0x7D19, in: 0x01, named: "CopyDMATransferToHRAM")


disassembly.defineMacro(named: "callcb", instructions: [
  .any(.ld(.a, .immediate8)),
  .instruction(.init(spec: .ld(.immediate16address, .a), immediate16: 0x2100)),
  .any(.call(.immediate16))
], code: [
  .ld(.a, .macro("bank(\\1)")),
  .ld(.immediate16address, .a),
  .call(.arg(1))
], validArgumentValues: [
  1: IndexSet(integersIn: 0x4000..<0x8000)
])

//disassembly.defineMacro(named: "copyregion", instructions: [
//  .any(.ld(.hl, .immediate16)),
//  .any(.ld(.de, .immediate16)),
//  .any(.ld(.bc, .immediate16)),
//  .instruction(.init(spec: .call(.immediate16), immediate16: 0x28C5)),
//], code: [
//  .ld(.hl, .arg(1)),
//  .ld(.de, .arg(2)),
//  .ld(.bc, .arg(3)),
//  .call(.immediate16),
//], validArgumentValues: [:])

disassembly.createGlobal(at: 0xA100, named: "SAVEFILES")

try disassembly.writeTo(directory: "/Users/featherless/workbench/gbdis/disassembly")
