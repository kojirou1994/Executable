import SystemPackage
import SystemUp
@_exported import ExecutableLauncher
import Command

extension Command {
  mutating func setup(_ exe: some Executable) {
    searchPATH = false
    cwd = exe.changeWorkingDirectory
    if let env = exe.environment {
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
    let path = try ExecutablePath.lookup(executable).get()
    var command = Command(executable: path, arg0: executable.executableName, arguments: executable.arguments)
    command.setup(executable)
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
  public var stdInput: Command.ChildIO

  /// last process stdout
  @available(*, unavailable)
  var stdOutput: Command.ChildIO = .inherit

  /// every process default stderr, don't use .makePipe
  public var defaultStderr: Command.ChildIO = .inherit

  struct PipeItem {
    let exe: AnyExecutable
    /// cached exe path
    let path: String
    /// overwride default stderr
    let stderr: Command.ChildIO?
  }

  var items: [PipeItem] = []

  public init(stdInput: Command.ChildIO = .inherit) {
    self.stdInput = stdInput
  }

  @discardableResult
  __consuming public func appending<E: Executable>(_ newExecutable: E, stderr: Command.ChildIO? = nil) throws -> Self {
    var copy = self
    let path = try ExecutablePath.lookup(newExecutable).get()
    copy.items.append(.init(exe: newExecutable.eraseToAnyExecutable(), path: path, stderr: stderr))
    return copy
  }

  public struct PipeProcesses {

    var processes: [Command.ChildProcess]

    public var first: Command.ChildProcess {
      _read {
        yield processes[0]
      }
      _modify {
        yield &processes[0]
      }
    }

    /// last process's output
    public let stdout: FileDescriptor?

    public mutating func waitUntilExit() -> [WaitPID.ExitStatus] {
      var result = [WaitPID.ExitStatus]()
      for index in processes.indices {
        result.append(try! processes[index].wait())
      }
      return result
    }
  }

  public func launch() throws -> PipeProcesses {
    assert(items.count > 1, "no need to pipe")
    var iterator = items.makeIterator()
    guard let first = iterator.next() else {
      fatalError()
    }

    func setup(_ item: PipeItem, stdin: Command.ChildIO) throws -> (Command.ChildProcess, stdoutRead: FileDescriptor) {
      var command = Command(executable: item.path, arguments: item.exe.arguments)
      command.setup(item.exe)

      command.stdin = stdin
      let newPipe = try FileDescriptor.pipe()
      command.stdout = .fd(newPipe.writeEnd)

      let stderr = item.stderr ?? defaultStderr
      switch stderr {
      case .makePipe:
        assertionFailure("don't use makePipe!")
      default: break
      }
      command.stderr = stderr

      let process = try command.spawn()
      try newPipe.writeEnd.close()

      return (process, newPipe.readEnd)
    }

    let (firstProcess, secondStdin) = try setup(first, stdin: stdInput)

    var processes: [Command.ChildProcess] = [firstProcess]

    var lastPipeReadEnd: FileDescriptor = secondStdin
    while let item = iterator.next() {
      let (newProcess, newStdin) = try setup(item, stdin: .fd(lastPipeReadEnd))
      try lastPipeReadEnd.close()
      lastPipeReadEnd = newStdin
      processes.append(newProcess)
    }

    return .init(processes: processes, stdout: lastPipeReadEnd)
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
