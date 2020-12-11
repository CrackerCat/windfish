import Foundation
import Disassembler
import CPU

extension LR35902.Instruction {
  public func operandData() -> Data? {
    switch immediate {
    case let .imm8(value):
      return Data([value])
    case let .imm16(value):
      return Data([UInt8(value & 0xff), UInt8((value >> 8) & 0xff)])
    case .none:
      return nil
    }
  }
}

extension LR35902.Instruction.Spec: InstructionSpecDisassemblyInfo {
  public func asData() -> Data? {
    return Data(LR35902.InstructionSet.opcodeBytes[self]!)
  }

  public var category: InstructionCategory? {
    switch self {
    case .call: return .call
    case .ret, .reti: return .ret
    default: return nil
    }
  }
}

extension LR35902.Instruction.Numeric: InstructionOperandAssemblyRepresentable {
  public var representation: InstructionOperandAssemblyRepresentation {
    switch self {
    case .bcaddr:
      return .specific("[bc]")
    case .deaddr:
      return .specific("[de]")
    case .hladdr:
      return .specific("[hl]")
    case .imm16addr:
      return .address
    case .ffimm8addr:
      return .ffaddress
    case .sp_plus_simm8:
      return .stackPointerOffset
    case .imm8, .simm8, .imm16:
      return .numeric
    default:
      return .specific("\(self)")
    }
  }
}

extension LR35902.Instruction.RestartAddress: InstructionOperandAssemblyRepresentable {
  public var representation: InstructionOperandAssemblyRepresentation {
    return .numeric
  }
}

extension LR35902.Instruction.Bit: InstructionOperandAssemblyRepresentable {
  public var representation: InstructionOperandAssemblyRepresentation {
    return .numeric
  }
}