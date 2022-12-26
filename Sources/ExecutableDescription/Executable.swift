import Escape

public protocol Executable: CustomStringConvertible {

  /// Executable name, like curl, wget
  static var executableName: String { get }

  /// Alternative executable names, eg. ["gtar"]
  static var alternativeExecutableNames: [String] { get }

  /// executable arguments, not including executableName
  var arguments: [String] { get }

  var environment: [String: String]? { get }

  /// Working Directory
  var changeWorkingDirectory: String? { get }

  /// Override static executableName
  var executableName: String { get }

  /// Overwride static alternativeExecutableNames
  var alternativeExecutableNames: [String] { get }

  /// Specify the executable file's path
  var executablePath: String? { get }
}

extension Executable {

  public var executableName: String { Self.executableName }

  public var executablePath: String? { nil }

  public var environment: [String : String]? { nil }

  public var changeWorkingDirectory: String? { nil }

  public var description: String {
    var result = (executablePath ?? executableName).simpleShellEscaped()
    for arg in arguments {
      result += " "
      result += arg.simpleShellEscaped()
    }
    return result
  }

}

extension Executable {

  public func eraseToAnyExecutable() -> AnyExecutable {
    var e = AnyExecutable(executableName: executableName, arguments: arguments)
    if let executablePath = self.executablePath {
      e.executablePath = executablePath
    }
    e.environment = environment
    e.changeWorkingDirectory = changeWorkingDirectory
    e.alternativeExecutableNames = alternativeExecutableNames
    return e
  }

}

public extension Executable {
  static var alternativeExecutableNames: [String] { [] }

  var alternativeExecutableNames: [String] { Self.alternativeExecutableNames }
}
