import Foundation
import ExecutableDescription

public final class ContiguousPipeline {

  public private(set) var processes: [Process]
  public private(set) var lastPipe: Pipe

  public init<E: Executable>(_ executable: E, standardInput: ExecutableStandardStream? = nil, standardError: ExecutableStandardStream? = nil) throws {
    lastPipe = .init()
    let launcher = FPExecutableLauncher(standardInput: nil, standardOutput: .pipe(lastPipe), standardError: standardError)
    processes = try [launcher.generateProcess(for: executable)]
  }

  @discardableResult
  public func append<E: Executable>(
    _ newExecutable: E,
    standardError: ExecutableStandardStream? = nil) throws -> Self {
    let newPipe = Pipe()
    let launcher = FPExecutableLauncher(standardInput: .pipe(lastPipe), standardOutput: .pipe(newPipe), standardError: standardError)
    let newProcess = try launcher.generateProcess(for: newExecutable)
    processes.append(newProcess)
    lastPipe = newPipe
    return self
  }

  public func run() throws {
    try processes.forEach { process in
      try process.run()
    }
  }

  public func waitUntilExit() {
    processes.forEach { process in
      process.waitUntilExit()
    }
  }
}
