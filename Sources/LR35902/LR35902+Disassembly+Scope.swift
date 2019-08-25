import Foundation

extension LR35902.Disassembly {
  func rewriteScopes(_ run: LR35902.Disassembly.Run) {
    // Compute scope and rewrite function labels if we're a function.

    for runGroup in run.runGroups() {
      // TODO: We should do this after all disassembly has been done and before writing to disk.
      for run in runGroup {
        guard let visitedRange = run.visitedRange else {
          continue
        }
        inferVariableTypes(in: visitedRange)
      }
      guard let runStartAddress = runGroup.startAddress,
        let runGroupLabel = labels[runStartAddress],
        let runGroupName = runGroupLabel.components(separatedBy: ".").first else {
        continue
      }

      // Expand scopes for the label.
      // TODO: This doesn't work well if the labels change after the scope has been defined.
      // TODO: Labels should be annotable with a name and a scope independently.
      let scope = runGroup.scope
      if scope.isEmpty {
        continue
      }
      expandScope(forLabel: runGroupName, scope: scope)

      // Define the initial contiguous scope for the rungroup's label.
      // This allows functions to rewrite local labels as relative labels.
      guard let contiguousScope = runGroup.firstContiguousScopeRange else {
        continue
      }
      addContiguousScope(range: contiguousScope)

      let labelLocations = self.labelLocations(in: contiguousScope.dropFirst())

      rewriteLoopLabels(in: contiguousScope.dropFirst())
      rewriteElseLabels(in: contiguousScope.dropFirst())
      rewriteReturnLabels(at: labelLocations)
    }
  }

  private func rewriteReturnLabels(at locations: [LR35902.CartridgeLocation]) {
    let returnLabelAddresses = locations.filter { instructionMap[$0]?.spec.category == .ret }
    for cartLocation in returnLabelAddresses {
      let addressAndBank = LR35902.addressAndBank(from: cartLocation)
      labels[cartLocation] = "return_\(addressAndBank.address.hexString)_\(addressAndBank.bank.hexString)"
    }
  }

  private func rewriteLoopLabels(in scope: Range<LR35902.CartridgeLocation>) {
    let tocs: [(destination: LR35902.CartridgeLocation, tocs: Set<TransferOfControl>)] = scope.compactMap {
      let (address, bank) = LR35902.addressAndBank(from: $0)
      if let toc = transfersOfControl(at: address, in: bank) {
        return ($0, toc)
      } else {
        return nil
      }
    }
    let backwardTocs: [(source: LR35902.CartridgeLocation, destination: LR35902.CartridgeLocation)] = tocs.reduce(into: [], { (accumulator, element) in
      let tocsInThisScope = element.tocs.filter {
        scope.contains($0.sourceLocation) && element.destination < $0.sourceLocation && labels[element.destination] != nil
      }
      for toc in tocsInThisScope {
        if case .jr(let condition, _) = instructionMap[toc.sourceLocation]?.spec,
          condition != nil {
          accumulator.append((toc.sourceLocation, element.destination))
        }
      }
    })
    if backwardTocs.isEmpty {
      return
    }
    // Loops do not include other unconditional transfers of control.
    let loops = backwardTocs.filter {
      let loopRange = ($0.destination..<$0.source)
      let tocsWithinLoop = tocs.flatMap {
        $0.tocs.filter { loopRange.contains($0.sourceLocation) }.map { $0.sourceInstructionSpec }
      }
      return !tocsWithinLoop.contains {
        switch $0 {
        case .jp(let condition, _), .ret(let condition):
          return condition == nil
        default:
          return false
        }
      }
    }
    if loops.isEmpty {
      return
    }
    let destinations = Set(loops.map { $0.destination })
    for cartLocation in destinations {
      let addressAndBank = LR35902.addressAndBank(from: cartLocation)
      labels[cartLocation] = "loop_\(addressAndBank.address.hexString)_\(addressAndBank.bank.hexString)"
    }
  }

  private func rewriteElseLabels(in scope: Range<LR35902.CartridgeLocation>) {
    let tocs: [(destination: LR35902.CartridgeLocation, tocs: Set<TransferOfControl>)] = scope.compactMap {
      let (address, bank) = LR35902.addressAndBank(from: $0)
      if let toc = transfersOfControl(at: address, in: bank) {
        return ($0, toc)
      } else {
        return nil
      }
    }
    let forwardTocs: [(source: LR35902.CartridgeLocation, destination: LR35902.CartridgeLocation)] = tocs.reduce(into: [], { (accumulator, element) in
      let tocsInThisScope = element.tocs.filter {
        scope.contains($0.sourceLocation) && element.destination > $0.sourceLocation && labels[element.destination] != nil
      }
      for toc in tocsInThisScope {
        if case .jr(let condition, _) = instructionMap[toc.sourceLocation]?.spec,
          condition != nil {
          accumulator.append((toc.sourceLocation, element.destination))
        }
      }
    })
    if forwardTocs.isEmpty {
      return
    }
    let destinations = Set(forwardTocs.map { $0.destination })
    for cartLocation in destinations {
      let addressAndBank = LR35902.addressAndBank(from: cartLocation)
      labels[cartLocation] = "else_\(addressAndBank.address.hexString)_\(addressAndBank.bank.hexString)"
    }
  }

  private struct CPUState {
    enum RegisterValue<T: BinaryInteger> {
      case variable(LR35902.Address)
      case value(T)
    }
    struct RegisterState<T: BinaryInteger> {
      let value: RegisterValue<T>
      let sourceLocation: LR35902.CartridgeLocation
    }
    var a: RegisterState<UInt8>?
    var b: RegisterState<UInt8>?
    var d: RegisterState<UInt8>?
    var e: RegisterState<UInt8>?
    var bc: RegisterState<UInt16>?
    var hl: RegisterState<UInt16>?
    var sp: RegisterState<UInt16>?
    var next: [LR35902.CartridgeLocation] = []
    var ram: [LR35902.Address: RegisterState<UInt8>] = [:]

    subscript(numeric: LR35902.Instruction.Numeric) -> RegisterState<UInt8>? {
      get {
        switch numeric {
        case .a: return a
        case .b: return b
        case .d: return d
        case .e: return e
        default: return nil
        }
      }
      set {
        switch numeric {
        case .a: a = newValue
        case .b: b = newValue
        case .d: d = newValue
        case .e: e = newValue
        default:
          break
        }
      }
    }
  }

  private func inferVariableTypes(in range: Range<LR35902.CartridgeLocation>) {
    var (pc, bank) = LR35902.addressAndBank(from: range.lowerBound)
    let upperBoundPc = LR35902.addressAndBank(from: range.upperBound).address

    var state = CPUState()

    // TODO: Store this globally.
    var states: [LR35902.CartridgeLocation: CPUState] = [:]

    while pc < upperBoundPc {
      guard let instruction = self.instruction(at: pc, in: bank) else {
        pc += 1
        continue
      }

      let location = LR35902.cartAddress(for: pc, in: bank)!

      switch instruction.spec {
      case .ld(let numeric, .imm8):
        state[numeric] = .init(value: .value(instruction.imm8!), sourceLocation: location)
      case .ld(.a, .e):
        state.a = state.e
      case .ld(.a, .imm16addr):
        state.a = .init(value: .variable(instruction.imm16!), sourceLocation: location)
      case .ld(.bc, .imm16):
        state.bc = .init(value: .value(instruction.imm16!), sourceLocation: location)
      case .ld(.hl, .imm16):
        state.hl = .init(value: .value(instruction.imm16!), sourceLocation: location)
      case .ld(let numeric, .ffimm8addr):
        let address = 0xFF00 | LR35902.Address(instruction.imm8!)
        state[numeric] = .init(value: .variable(address), sourceLocation: location)
      case .ld(.ffimm8addr, let numeric):
        let address = 0xFF00 | LR35902.Address(instruction.imm8!)
        if let global = globals[address],
          let dataType = global.dataType,
          let sourceLocation = state.a?.sourceLocation {
          typeAtLocation[sourceLocation] = dataType
        }
        state.ram[address] = state[numeric]
      case .cp(_):
        if case .variable(let address) = state.a?.value,
          let global = globals[address],
          let dataType = global.dataType {
          typeAtLocation[location] = dataType
        }
      case .xor(.a):
        state.a = .init(value: .value(0), sourceLocation: location)
      case .and(let numeric):
        if case .value(let dst) = state.a?.value,
          case .value(let src) = state[numeric]?.value {
          state.a = .init(value: .value(dst & src), sourceLocation: location)
          // TODO: Compute the flag bits.
        } else {
          state.a = nil
        }
      case .ld(.sp, .imm16):
        state.sp = .init(value: .value(instruction.imm16!), sourceLocation: location)
      case .reti, .ret:
        state.a = nil
        state.bc = nil
        state.hl = nil
        state.sp = nil
        state.ram.removeAll()

      // TODO: For calls, we need to look up the affected registers and arguments.
      default:
        break
      }

      let width = LR35902.Instruction.widths[instruction.spec]!.total

      var thisState = state
      thisState.next = [location + LR35902.CartridgeLocation(width)]
      states[location] = thisState

      pc += width
    }
  }
}
