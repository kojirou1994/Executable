import TSCBasic
@_exported import ExecutableLauncher

@available(macOS 10.15, *)
public struct TSCExecutableLauncher: ExecutableLauncher {

  public let outputRedirection: Process.OutputRedirection
  public let startNewProcessGroup: Bool

  public init(outputRedirection: Process.OutputRedirection = .collect, startNewProcessGroup: Bool = false) {
    self.outputRedirection = outputRedirection
    self.startNewProcessGroup = startNewProcessGroup
  }

  public func generateProcess<T>(for executable: T) throws -> Process where T : Executable {
    let launchPath = try ExecutablePath.lookup(executable).get()
    let arguments = CollectionOfOne(launchPath) + executable.arguments
    let environment = executable.environment ?? ProcessEnv.vars
    
    if let workingDirectory = executable.currentDirectoryURL?.path {
      return .init(arguments: arguments,
                   environment: environment,
                   workingDirectory: AbsolutePath(workingDirectory),
                   outputRedirection: outputRedirection,
                   startNewProcessGroup: startNewProcessGroup)
    } else {
      return .init(arguments: arguments,
                   environment: environment,
                   outputRedirection: outputRedirection,
                   startNewProcessGroup: startNewProcessGroup)
    }
  }

  public func launch<T>(executable: T, options: ExecutableLaunchOptions) throws -> ProcessResult where T : Executable {
    let process = try generateProcess(for: executable)
    try process.launch()
    let result = try process.waitUntilExit()
    if options.checkNonZeroExitCode, result.exitStatus != .terminated(code: 0) {
      throw ExecutableError.nonZeroExit
    }
    return result
  }

  public typealias Process = TSCBasic.Process

  public typealias LaunchResult = ProcessResult

}

@available(macOS 10.15, *)
public extension ExecutableLauncher where Self == TSCExecutableLauncher {

  @inlinable
  static var tsc: Self {
    .init(outputRedirection: .none, startNewProcessGroup: false)
  }

  @inlinable
  static func tsc(outputRedirection: TSCExecutableLauncher.Process.OutputRedirection, startNewProcessGroup: Bool = false) -> Self {
    .init(outputRedirection: outputRedirection, startNewProcessGroup: startNewProcessGroup)
  }

}
