import XCTest
import Executable

final class ExecutableTests: XCTestCase {
  func testError() throws {
    do {
      let none = AnyExecutable(executableName: "abcdefg", arguments: [])
      try none.launch(use: SwiftToolsSupportExecutableLauncher(outputRedirection: .none))
    } catch let error as ExecutableError {
      switch error {
      case .executableNotFound(_): break
      case .nonZeroExit(_): break
      case .pathNull: break
      }
    }
  }

  func testCheckValid() throws {
    let valid = AnyExecutable(executableName: "bash", arguments: [])
    XCTAssertNoThrow(try valid.checkValid())
    let invalid = AnyExecutable(executableName: "hsab", arguments: [])
    XCTAssertThrowsError(try invalid.checkValid())
    try ExecutablePath.lookup("ffmpeg")
  }

  func testFoundationLauncher() throws {
    let curl = AnyExecutable(executableName: "curl", arguments: ["--version"])

    try curl.launch(use: FoundationExecutableLauncher())

    try curl.launch(use: FoundationExecutableLauncher(standardInput: nil, standardOutput: .fileHandle(.nullDevice), standardError: .fileHandle(.nullDevice)))
  }
}
