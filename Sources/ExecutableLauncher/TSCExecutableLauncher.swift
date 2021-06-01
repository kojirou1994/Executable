import TSCBasic

@available(macOS 10.15, *)
public struct TSCExecutableLauncher: ExecutableLauncher {

  public let outputRedirection: Process.OutputRedirection
  public let startNewProcessGroup: Bool

  public init(outputRedirection: Process.OutputRedirection = .collect, startNewProcessGroup: Bool = false) {
    self.outputRedirection = outputRedirection
    self.startNewProcessGroup = startNewProcessGroup
  }

  public func generateProcess<T>(for executable: T) throws -> Process where T : Executable {
    let launchPath = try executable.executableURL?.path ?? ExecutablePath.lookup(executable)
    let arguments = CollectionOfOne(launchPath) + executable.arguments
    let environment = executable.environment ?? ProcessEnv.vars
    
    if let workingDirectory = executable.currentDirectoryURL?.path {
      return .init(arguments: arguments,
                   environment: environment,
                   workingDirectory: AbsolutePath(workingDirectory),
                   outputRedirection: outputRedirection,
                   verbose: false, startNewProcessGroup: startNewProcessGroup)
    } else {
      return .init(arguments: arguments,
                   environment: environment,
                   outputRedirection: outputRedirection,
                   verbose: false, startNewProcessGroup: startNewProcessGroup)
    }
  }

  public func launch<T>(executable: T, options: ExecutableLaunchOptions) throws -> ProcessResult where T : Executable {
    let process = try generateProcess(for: executable)
    try process.launch()
    let result = try process.waitUntilExit()
    if options.checkNonZeroExitCode, result.exitStatus != .terminated(code: 0) {
      throw ExecutableError.nonZeroExit(result.exitStatus)
    }
    return result
  }

  public typealias Process = TSCBasic.Process

  public typealias LaunchResult = ProcessResult

}
public typealias TSCExitStatus = ProcessResult.ExitStatus
