import Foundation

public enum ExecutableError: Error {
  case pathNull
  case executableNotFound(String)
  case nonZeroExit(TSCExitStatus)
}

// only work for Foundation framework
public enum ExecutableStandardStream {
  case fileHandle(FileHandle)
  case pipe(Pipe)

  @inlinable
  var valueForProcess: Any {
    switch self {
    case .fileHandle(let f):
      return f as Any
    case .pipe(let p):
      return p as Any
    }
  }
}

public protocol Executable: CustomStringConvertible {

  static var executableName: String {get}

  var arguments: [String] {get}

  var environment: [String : String]? {get}

  /// Working Directory
  var currentDirectoryURL: URL? {get}

  var executableName: String {get}

  var executableURL: URL? {get}
}

extension Executable {

  public var executableName: String { Self.executableName }

  public var executableURL: URL? {nil}

  public var environment: [String : String]? {nil}

  public var currentDirectoryURL: URL? {nil}

  public func checkValid() throws {
    if executableURL == nil {
      _ = try ExecutablePath.lookup(executableName)
    }
  }

  public var description: String {
    "CommandLine: \(executableName) \(arguments.joined(separator: " "))"
  }

  public var commandLineArguments: [String] {
    CollectionOfOne(executableName) + arguments
  }

}

extension Executable {

  @inlinable
  public func eraseToAnyExecutable() -> AnyExecutable {
    var e = AnyExecutable(executableName: executableName, arguments: arguments)
    e.executableURL = executableURL
    e.environment = environment
    e.currentDirectoryURL = currentDirectoryURL
    return e
  }

}
