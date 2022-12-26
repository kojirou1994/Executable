import Foundation

public struct AnyExecutable: Executable {
  public static var executableName: String {
    assertionFailure("Should not be used.")
    fatalError()
  }

  public init(executableName: String, arguments: [String]) {
    self.executableName = executableName
    self.arguments = arguments
  }

  public init(executablePath: String, arguments: [String]) {
    self.executableName = (executablePath as NSString).lastPathComponent
    self.arguments = arguments
    self.executablePath = executablePath
  }

  public let executableName: String

  public var executablePath: String?

  public var environment: [String : String]?

  public var changeWorkingDirectory: String?

  public var arguments: [String]

  public var alternativeExecutableNames: [String] = .init()

}
