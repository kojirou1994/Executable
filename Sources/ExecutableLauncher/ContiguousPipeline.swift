import Foundation
import ExecutableDescription

public final class ContiguousPipeline {

  public private(set) var processes: [Process]
  private var lastPipe: Pipe?

  public init<E: Executable>(
    _ executable: E,
    standardInput: ExecutableStandardStream? = nil,
    standardError: ExecutableStandardStream? = nil,
    qualityOfService: QualityOfService? = nil) throws {
    let lastPipe = Pipe()
    let launcher = FPExecutableLauncher(standardInput: standardInput, standardOutput: .pipe(lastPipe), standardError: standardError)
    self.lastPipe = lastPipe
    self.processes = try [launcher.generateProcess(for: executable)]
  }

  @discardableResult
  public func append<E: Executable>(
    _ newExecutable: E,
    isLast: Bool = false,
    standardOutput: ExecutableStandardStream? = nil,
    standardError: ExecutableStandardStream? = nil,
    qualityOfService: QualityOfService? = nil) throws -> Self {
    precondition(lastPipe != nil, "Last executable has already been set!")

    let usedStandardOutput: ExecutableStandardStream?
    let newPipe: Pipe?
    if isLast || standardOutput != nil {
      newPipe = nil
      usedStandardOutput = standardOutput
    } else {
      newPipe = Pipe()
      usedStandardOutput = .pipe(newPipe.unsafelyUnwrapped)
    }

    let launcher = FPExecutableLauncher(standardInput: .pipe(lastPipe.unsafelyUnwrapped), standardOutput: usedStandardOutput, standardError: standardError)
    let newProcess = try launcher.generateProcess(for: newExecutable)
    processes.append(newProcess)
    lastPipe = newPipe
    return self
  }

  public func run() throws {
    assert(lastPipe == nil, "Last executable not set")
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
