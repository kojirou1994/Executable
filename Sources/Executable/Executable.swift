import Foundation

public enum ExecutableError: Error {
  case executableNotFound(String)
  case nonZeroExit(TSCExitStatus)
  case invalidExecutableURL(URL)
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

public protocol Executable: CustomStringConvertible where AlternativeExecutableNames.Element == String {

  static var executableName: String { get }

  associatedtype AlternativeExecutableNames: Sequence = EmptyCollection<String>

  static var alternativeExecutableNames: AlternativeExecutableNames { get }

  var arguments: [String] { get }

  var environment: [String : String]? { get }

  /// Working Directory
  var currentDirectoryURL: URL? { get }

  /// Override static executableName
  var executableName: String { get }

  /// Specify the executable file's URL
  var executableURL: URL? { get }
}

extension Executable {

  public var executableName: String { Self.executableName }

  public var executableURL: URL? { nil }

  public var environment: [String : String]? {nil}

  public var currentDirectoryURL: URL? {nil}

  public func checkValid() throws {
    if let fileURL = executableURL {
      if !FileManager.default.isExecutableFile(atPath: fileURL.path) {
        throw ExecutableError.invalidExecutableURL(fileURL)
      }
    } else {
      _ = try ExecutablePath.lookup(self)
    }
  }

  public static func checkValid() throws {
    _ = try ExecutablePath.lookup(executableName)
  }

  public var description: String {
    "CommandLine: \(executableName) \(arguments.joined(separator: " "))"
  }

  public var commandLineArguments: [String] {
    var result = [executableName.spm_shellEscaped()]
    let cachedArgs = arguments
    result.reserveCapacity(cachedArgs.count)
    cachedArgs.forEach { result.append($0.spm_shellEscaped()) }
    return result
  }

  public var shellCommand: String {
    commandLineArguments.joined(separator: " ")
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

public extension Executable where AlternativeExecutableNames == EmptyCollection<String> {
  static var alternativeExecutableNames: AlternativeExecutableNames { .init() }
}
