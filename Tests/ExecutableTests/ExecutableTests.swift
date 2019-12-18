import XCTest
@testable import Executable

final class ExecutableTests: XCTestCase {
    func testCombine() {

    }

    func testCheckValid() {
        let valid = AnyExecutable(executableName: "bash", arguments: [])
        XCTAssertNoThrow(try valid.checkValid())
        let invalid = AnyExecutable(executableName: "hsab", arguments: [])
        XCTAssertThrowsError(try invalid.checkValid())
    }

    static var allTests = [
        ("testCombine", testCombine),
    ]
}
