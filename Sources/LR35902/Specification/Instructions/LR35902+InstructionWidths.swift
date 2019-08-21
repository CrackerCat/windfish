import Foundation
import CPU

extension LR35902.Instruction {
  // MARK: - Lazily computed lookup tables for instruction widths

  static var widths: [Spec: CPUInstructionWidth<UInt16>] = {
    return CPU.widths(for: table + tableCB)
  }()
}
