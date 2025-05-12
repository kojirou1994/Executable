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

public extension ExecutableLauncher where Self == PosixExecutableLauncher {

  @inlinable
  static var posix: Self {
    .init()
  }

  @inlinable
  static func posix(stdin: Command.ChildIO = .inherit, stdout: Command.ChildIO = .inherit, stderr: Command.ChildIO = .inherit) -> Self {
    .init(stdin: stdin, stdout: stdout, stderr: stderr)
  }

}


extension CommandChain {

  public mutating func append<E: Executable>(_ newExecutable: E) throws {
    append(try Command(executable: newExecutable))
  }

}
