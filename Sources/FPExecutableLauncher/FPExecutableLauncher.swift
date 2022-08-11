import Foundation
@_exported import ExecutableLauncher

/// This launcher use Foundation Process class.
public struct FPExecutableLauncher: ExecutableLauncher {
  public var standardInput: ExecutableStandardStream?
  public var standardOutput: ExecutableStandardStream?
  public var standardError: ExecutableStandardStream?
  public var qualityOfService: QualityOfService?

  public init(standardInput: ExecutableStandardStream? = nil,
              standardOutput: ExecutableStandardStream? = nil,
              standardError: ExecutableStandardStream? = nil,
              qualityOfService: QualityOfService? = nil) {
    self.standardInput = standardInput
    self.standardOutput = standardOutput
    self.standardError = standardError
  }

  public func launch<T>(executable: T, options: ExecutableLaunchOptions) throws -> LaunchResult where T : Executable {
    let process = try generateProcess(for: executable)
    try process.run()

    while process.isRunning {
      Thread.sleep(forTimeInterval: 0.05)
    }

    if options.checkNonZeroExitCode, process.terminationStatus != 0 {
      throw ExecutableError.nonZeroExit
    }
    return .init(terminationStatus: process.terminationStatus, terminationReason: process.terminationReason)
  }

  public func generateProcess<T>(for executable: T) throws -> Process where T : Executable {
    let process = Process()
    // use provided exe url, or search in PATH
    process.executableURL = try URL(fileURLWithPath: ExecutablePath.lookup(executable).get())

    process.arguments = executable.arguments
    if let environment = executable.environment {
      process.environment = environment
    }
    if let standardInput = standardInput?.valueForProcess {
      process.standardInput = standardInput
    }
    if let standardOutput = standardOutput?.valueForProcess {
      process.standardOutput = standardOutput
    }
    if let standardError = standardError?.valueForProcess {
      process.standardError = standardError
    }
    if let currentDirectoryURL = executable.currentDirectoryURL {
      process.currentDirectoryURL = currentDirectoryURL
    }
    if let qos = qualityOfService {
      process.qualityOfService = qos
    }
    return process
  }

  public typealias Process = Foundation.Process

  public struct LaunchResult {
    public let terminationStatus: Int32
    public let terminationReason: Process.TerminationReason
  }

}

extension ExecutableLauncher where Self == FPExecutableLauncher {

  @inlinable
  public static var foundationProcess: Self {
    .init(standardInput: nil, standardOutput: nil, standardError: nil)
  }

  @inlinable
  public static func foundationProcess(standardInput: ExecutableStandardStream?, standardOutput: ExecutableStandardStream?, standardError: ExecutableStandardStream?) -> Self {
    .init(standardInput: standardInput, standardOutput: standardOutput, standardError: standardError)
  }

}
