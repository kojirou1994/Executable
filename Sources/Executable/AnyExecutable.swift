import struct Foundation.URL

public struct AnyExecutable: Executable {
  public static var executableName: String { fatalError("Should not be used.") }

  public init(executableName: String, arguments: [String]) {
    self.executableName = executableName
    self.arguments = arguments
  }

  public init(executableURL: URL, arguments: [String]) {
    self.executableName = executableURL.lastPathComponent
    self.executableURL = executableURL
    self.arguments = arguments
  }

  public let executableName: String

  public var executableURL: URL?

  public var environment: [String : String]?

  public var currentDirectoryURL: URL?

  public var arguments: [String]

}
