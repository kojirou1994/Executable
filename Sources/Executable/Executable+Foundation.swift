import Foundation

public struct FoundationExecutableLauncher: ExecutableLauncher {
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
    #if os(macOS)
    if #available(OSX 10.13, *) {
      try process.run()
    } else {
      process.launch()
    }
    #else
    try process.run()
    #endif

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
    if let executableURL = executable.executableURL {
      #if os(macOS)
      if #available(OSX 10.13, *) {
        process.executableURL = executableURL
      } else {
        process.launchPath = executableURL.path
      }
      #else
      process.executableURL = executableURL
      #endif
    } else {
      // search in PATH
      let launchPath = try ExecutablePath.lookup(executable.executableName)
      let executableURL = URL(fileURLWithPath: launchPath)
      #if os(macOS)
      if #available(OSX 10.13, *) {
        process.executableURL = executableURL
      } else {
        process.launchPath = launchPath
      }
      #else
      process.executableURL = executableURL
      #endif
    }

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
      #if os(macOS)
      if #available(OSX 10.13, *) {
        process.currentDirectoryURL = currentDirectoryURL
      } else {
        process.currentDirectoryPath = currentDirectoryURL.path
      }
      #else
      process.currentDirectoryURL = currentDirectoryURL
      #endif
    }
    return process
  }

  public typealias Process = Foundation.Process

  public struct LaunchResult {
    public let terminationStatus: Int32
    public let terminationReason: Process.TerminationReason
  }

}
