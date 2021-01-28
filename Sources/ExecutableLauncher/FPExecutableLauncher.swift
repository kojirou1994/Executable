import Foundation

@available(*, deprecated, renamed: "FPExecutableLauncher")
public typealias FoundationExecutableLauncher = FPExecutableLauncher

/// This launcher use Foundation Process class.
public struct FPExecutableLauncher: ExecutableLauncher {
  public let standardInput: ExecutableStandardStream?
  public let standardOutput: ExecutableStandardStream?
  public let standardError: ExecutableStandardStream?

  public init(standardInput: ExecutableStandardStream? = nil,
              standardOutput: ExecutableStandardStream? = nil,
              standardError: ExecutableStandardStream? = nil) {
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
      switch process.terminationReason {
      case .exit:
        throw ExecutableError.nonZeroExit(.terminated(code: process.terminationStatus))
      case .uncaughtSignal:
        throw ExecutableError.nonZeroExit(.signalled(signal: process.terminationStatus))
      #if os(macOS)
      @unknown default:
        assertionFailure("Unknown terminationReason!")
        throw ExecutableError.nonZeroExit(.terminated(code: process.terminationStatus))
      #endif
      }
    }
    return .init(terminationStatus: process.terminationStatus, terminationReason: process.terminationReason)
  }

  public func generateProcess<T>(for executable: T) throws -> Process where T : Executable {
    let process = Process()
    // use provided exe url, or search in PATH
    process.executableURL = try executable.executableURL ?? URL(fileURLWithPath: ExecutablePath.lookup(executable))

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
    return process
  }

  public typealias Process = Foundation.Process

  public struct LaunchResult {
    public let terminationStatus: Int32
    public let terminationReason: Process.TerminationReason
  }

}
