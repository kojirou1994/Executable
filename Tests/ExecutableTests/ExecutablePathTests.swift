import XCTest
import ExecutableDescription
import ExecutableLauncher

final class ExecutablePathTests: XCTestCase {

  func testLookup() throws {
    XCTAssertNoThrow(try ExecutablePath.lookup("bash", alternativeExecutableNames: []).get())
  }

  func testValidate() throws {
    let valid = AnyExecutable(executableName: "bash", arguments: [])
    XCTAssertNoThrow(try valid.validate())
    let invalid = AnyExecutable(executableName: "hsab", arguments: [])
    XCTAssertThrowsError(try invalid.validate())
  }

}
