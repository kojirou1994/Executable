import SystemPackage
import SystemUp
@_exported import ExecutableLauncher
import Command

extension Command {
  public init(executable: some Executable) throws {
    self.init(executable: try ExecutablePath.lookup(executable).get(), arguments: executable.arguments)
    searchPATH = false
    cwd = executable.changeWorkingDirectory
    if let env = executable.environment {
      environment = .custom(.init(environment: env), mergeGlobal: false)
    }
  }
}

public struct PosixExecutableLauncher: ExecutableLauncher {
  public init(stdin: Command.ChildIO = .inherit,
              stdout: Command.ChildIO = .inherit,
              stderr: Command.ChildIO = .inherit) {
    self.stdin = stdin
    self.stdout = stdout
    self.stderr = stderr
  }

  public var stdin: Command.ChildIO
  public var stdout: Command.ChildIO
  public var stderr: Command.ChildIO

  public func generateProcess<T>(for executable: T) throws -> Command where T : Executable {
    var command = try Command(executable: executable)
    command.stdin = stdin
    command.stdout = stdout
    command.stderr = stderr

    return command
  }

  public func launch<T>(executable: T, options: ExecutableLaunchOptions) throws -> Command.Output where T : Executable {
    let command = try generateProcess(for: executable)
    let output = try command.output()
    if options.checkNonZeroExitCode {
      guard output.status.exited, output.status.exitStatus == 0 else {
        throw ExecutableError.nonZeroExit
      }
    }
    return output
  }

}

public struct PosixPipelineLauncher {
  /// first process stdin
  public var firstStandardInput: Command.ChildIO

  /// last process stdout
  public var lastStandardOutput: Command.ChildIO = .inherit

  /// every process default stderr, don't use .makePipe
  public var defaultStandardError: Command.ChildIO = .inherit

  struct PipeItem {
    /// prepared command, stdin and stdout are not set
    let command: Command
  }

  var items: [PipeItem] = []

  public init(firstStandardInput: Command.ChildIO = .inherit) {
    self.firstStandardInput = firstStandardInput
  }

  @discardableResult
  __consuming public func appending<E: Executable>(_ newExecutable: E, stderr: Command.ChildIO? = nil) throws -> Self {
    var copy = self
    let stderr = stderr ?? defaultStandardError
    switch stderr {
    case .makePipe: assertionFailure("don't use makePipe for stderr!")
    default: break
    }
    copy.items.append(.init(command: try Command(executable: newExecutable)))
    return copy
  }

  public struct LaunchedPipeline {

    var processes: [Command.ChildProcess]

    public var firstProcess: Command.ChildProcess {
      _read {
        yield processes[0]
      }
      _modify {
        yield &processes[0]
      }
    }

    /// last process's output if makePipe
    public let lastStandardOutput: FileDescriptor?

    public mutating func waitUntilExit() -> [WaitPID.ExitStatus] {
      var result = [WaitPID.ExitStatus]()
      result.reserveCapacity(processes.count)
      for index in processes.indices {
        result.append(try! processes[index].wait())
      }
      return result
    }
  }

  public func launch() throws -> LaunchedPipeline {
    precondition(items.count > 1, "no need to pipe")
    let first = items[0]
    let last = items[items.count-1]
    let mid = items.dropFirst().dropLast()

    func addNonLast(_ item: PipeItem, stdin: Command.ChildIO) throws -> (Command.ChildProcess, stdoutRead: FileDescriptor) {
      var command = item.command
      command.stdin = stdin
      command.stdout = .makePipe

      let process = try command.spawn()

      return (process, process.stdout!)
    }

    let (firstProcess, secondStdin) = try addNonLast(first, stdin: firstStandardInput)

    var processes: [Command.ChildProcess] = [firstProcess]
    // TODO: wait/kill processes if error

    var lastPipeReadEnd: FileDescriptor = secondStdin
    for item in mid {
      let (newProcess, newStdin) = try addNonLast(item, stdin: .fd(lastPipeReadEnd))
      try lastPipeReadEnd.close()
      lastPipeReadEnd = newStdin
      processes.append(newProcess)
    }

    var command = last.command

    command.stdin = .fd(lastPipeReadEnd)
    command.stdout = lastStandardOutput

    let lastProcess = try command.spawn()
    try lastPipeReadEnd.close()
    processes.append(lastProcess)

    return .init(processes: processes, lastStandardOutput: lastProcess.stdout)
  }

}

private func | (lhs: some Executable, rhs: some Executable) throws -> PosixPipelineLauncher {
  try PosixPipelineLauncher()
    .appending(lhs)
    .appending(rhs)
}

public func | (lhs: PosixPipelineLauncher, rhs: some Executable) throws -> PosixPipelineLauncher {
  try lhs.appending(rhs)
}
