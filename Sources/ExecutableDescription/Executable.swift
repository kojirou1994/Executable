import Foundation

public protocol Executable: CustomStringConvertible {

  /// Executable name, like curl, wget
  static var executableName: String { get }

  /// Alternative executable names, eg. ["gtar"]
  static var alternativeExecutableNames: [String] { get }

  /// executable arguments, not including executableName
  var arguments: [String] { get }

  var environment: [String: String]? { get }

  /// Working Directory
  var currentDirectoryURL: URL? { get }

  /// Override static executableName
  var executableName: String { get }

  /// Overwride static alternativeExecutableNames
  var alternativeExecutableNames: [String] { get }

  /// Specify the executable file's URL
  @available(*, deprecated)
  var executableURL: URL? { get }

  var executablePath: String? { get }
}

extension Executable {

  public var executableName: String { Self.executableName }

  public var executableURL: URL? { nil }

  public var executablePath: String? { nil }

  public var environment: [String : String]? { nil }

  public var currentDirectoryURL: URL? { nil }

  public var description: String {
    "Executable: \(executableName) \(arguments.joined(separator: " "))"
  }

}

extension Executable {

  public func eraseToAnyExecutable() -> AnyExecutable {
    var e = AnyExecutable(executableName: executableName, arguments: arguments)
    e.executableURL = executableURL
    if let executablePath = self.executablePath {
      e.executablePath = executablePath
    }
    e.environment = environment
    e.currentDirectoryURL = currentDirectoryURL
    e.alternativeExecutableNames = alternativeExecutableNames
    return e
  }

}

public extension Executable {
  static var alternativeExecutableNames: [String] { [] }

  var alternativeExecutableNames: [String] { Self.alternativeExecutableNames }
}
