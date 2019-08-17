import XCTest
@testable import LR35902

class RGBDAssembler: XCTestCase {

  func test_nop_failsWithExtraOperand() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    nop nop
""")

    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [RGBDSAssembler.Error(lineNumber: 1, error: "Invalid instruction: nop nop")])
  }

  func test_nop_failsWithExtraOperandAtCorrectLine() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """

; This is a comment-only line
    nop nop
""")

    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [RGBDSAssembler.Error(lineNumber: 3, error: "Invalid instruction: nop nop")])
  }

  func test_newline_doesNotCauseParseFailures() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    nop

    nop
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertTrue(errors.isEmpty)
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .nop),
      0x0001: LR35902.Instruction(spec: .nop)
    ])
  }

  func test_nop_1() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    nop
""")

    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertTrue(errors.isEmpty)
    XCTAssertEqual(disassembly.instructionMap, [0x0000: LR35902.Instruction(spec: .nop)])
  }

  func test_nop_2() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    nop
    nop
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertTrue(errors.isEmpty)
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .nop),
      0x0001: LR35902.Instruction(spec: .nop)
    ])
  }

  func test_ld_bc_imm16_dollarHexIsRepresentable() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld bc, $1234
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertTrue(errors.isEmpty)

    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bc, .immediate16), immediate16: 0x1234)
    ])
  }

  func test_ld_bc_imm16_0xHexIsRepresentable() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld bc, 0x1234
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertTrue(errors.isEmpty)

    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bc, .immediate16), immediate16: 0x1234)
    ])
  }

  func test_ld_bc_imm16_nop() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld bc, $1234
    nop
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertTrue(errors.isEmpty)
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bc, .immediate16), immediate16: 0x1234),
      0x0003: LR35902.Instruction(spec: .nop)
    ])
  }

  func test_ld_bc_imm16_unrepresentableNumberFails() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld bc, $12342342342
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [RGBDSAssembler.Error(lineNumber: 1, error: "Unable to represent $12342342342 as a UInt16")])
    XCTAssertEqual(disassembly.instructionMap, [:])
  }

  func test_ld_bc_imm16_emptyNumberFails() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld bc, $
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [RGBDSAssembler.Error(lineNumber: 1, error: "Unable to represent $ as a UInt16")])
    XCTAssertEqual(disassembly.instructionMap, [:])
  }

}