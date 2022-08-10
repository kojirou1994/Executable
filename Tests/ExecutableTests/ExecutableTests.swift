import XCTest
import ExecutableDescription
import ExecutableLauncher
import FPExecutableLauncher
import TSCExecutableLauncher

final class ExecutableTests: XCTestCase {
  func testError() throws {
    do {
      let none = AnyExecutable(executableName: "abcdefg", arguments: [])
      try none.launch(use: TSCExecutableLauncher(outputRedirection: .none))
    } catch let error as ExecutableError {
      switch error {
      case .executableNotFound(_): break
      case .nonZeroExit: break
      case .invalidExecutableURL(_): break
      }
    }
  }

  func testCheckValid() throws {
    let valid = AnyExecutable(executableName: "bash", arguments: [])
    XCTAssertNoThrow(try valid.validate())
    let invalid = AnyExecutable(executableName: "hsab", arguments: [])
    XCTAssertThrowsError(try invalid.validate())
  }

  func testFoundationLauncher() throws {
    let curl = AnyExecutable(executableName: "curl", arguments: ["--version"])

    try curl.launch(use: FPExecutableLauncher())

    try curl.launch(use: FPExecutableLauncher(standardInput: nil, standardOutput: .fileHandle(.nullDevice), standardError: .fileHandle(.nullDevice)))
  }

  func testContiguousPipeline() throws {
    let lastOutputPipe = Pipe()
    let pipeline = try ContiguousPipeline(AnyExecutable(executableName: "ps", arguments: ["aux"]))
      .append(AnyExecutable(executableName: "grep", arguments: ["a"]),
              standardOutput: .pipe(lastOutputPipe))

    try pipeline.run()
    let output = lastOutputPipe.fileHandleForReading.readDataToEndOfFile()
    pipeline.waitUntilExit()
    XCTAssertFalse(output.isEmpty)
  }

  func testAsyncFuncs() async throws {
    let ffmpeg = AnyExecutable(executableURL: URL(fileURLWithPath: "/Users/kojirou/Executable/arm64/ffmpeg"), arguments: ["-h", "full"])
    let result = try await ffmpeg.result(use: TSCExecutableLauncher())
    print(try result.output.get().count)
  }
}
