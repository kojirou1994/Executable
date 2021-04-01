import Foundation

public protocol Executable: CustomStringConvertible {

  /// Executable name, like curl, wget
  static var executableName: String { get }

  /// Alternative executable names, eg. ["gtar"]
  static var alternativeExecutableNames: [String] { get }

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

  public var description: String {
    "Executable: \(executableName) \(arguments.joined(separator: " "))"
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

public extension Executable {
  static var alternativeExecutableNames: [String] { [] }
}
