#if !canImport(ObjectiveC)
import XCTest

extension VisitorTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__VisitorTests = [
        ("testInstructionWithNoOperandsIsVisitedWithNil", testInstructionWithNoOperandsIsVisitedWithNil),
        ("testInstructionWithOneOperandIsVisitedOnce", testInstructionWithOneOperandIsVisitedOnce),
        ("testInstructionWithTwoOperandsIsVisitedTwice", testInstructionWithTwoOperandsIsVisitedTwice),
        ("testNestedInstructionWithTwoOperandsIsVisitedTwice", testNestedInstructionWithTwoOperandsIsVisitedTwice),
        ("testRepresentation", testRepresentation),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(VisitorTests.__allTests__VisitorTests),
    ]
}
#endif
