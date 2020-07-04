import Foundation
import TSCBasic

public enum ExecutableProcess {
  case foundation(Foundation.Process)
  case tsc(TSCBasic.Process)
}

extension ExecutableProcess {
  public func terminate() {
    switch self {
    case .foundation(let p):
      p.terminate()
    case .tsc(let p):
      p.signal(SIGTERM)
    }
  }
}

extension Executable {
  
  public func generateProcess() throws -> ExecutableProcess {
    switch launchMode {
    case .foundation:
      return try .foundation(generateFoundationProcess())
    case .tsc:
      return try .tsc(generateTSCProcess(outputRedirection: .collect, startNewProcessGroup: false))
    }
  }
}
