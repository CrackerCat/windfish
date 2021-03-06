import Foundation

// References:
// - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf

final class IORegisterMemory: AddressableMemory {
  enum IOAddresses: LR35902.Address {
    case P1   = 0xFF00
    case SB   = 0xFF01
    case SC   = 0xFF02

    case BGP  = 0xFF47
    case OBP0 = 0xFF48
    case OBP1 = 0xFF49
  }
  var values: [IOAddresses: UInt8] = [
    .P1:   0x00,
    .SB:   0x00,
    .SC:   0x00,
    .BGP:  0xFC,
    .OBP0: 0xFF,
    .OBP1: 0xFF,
  ]

  var serialDataReceived: [UInt8] = []

  func read(from address: LR35902.Address) -> UInt8 {
    guard let ioAddress = IOAddresses(rawValue: address) else {
      preconditionFailure("Invalid address")
    }
    return values[ioAddress]!
  }

  func write(_ byte: UInt8, to address: LR35902.Address) {
    guard let ioAddress = IOAddresses(rawValue: address) else {
      preconditionFailure("Invalid address")
    }
    if ioAddress == .SC && (byte & 0b1000_0000) > 0 {
      serialDataReceived.append(values[.SB]!)
    }
    precondition(values[ioAddress] != nil, "Writing to invalid register.")
    values[ioAddress] = byte
  }

  func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}
