import struct Foundation.URL

public struct AnyExecutable: Executable {
  public static var executableName: String {
    assertionFailure("Should not be used.")
    fatalError()
  }

  public init(executableName: String, arguments: [String]) {
    self.executableName = executableName
    self.arguments = arguments
  }

  public init(executableURL: URL, arguments: [String]) {
    self.executableName = executableURL.lastPathComponent
    self.arguments = arguments
    self.executableURL = executableURL
  }

  public let executableName: String

  public var executableURL: URL? {
    get {
      executablePath.map(URL.init(fileURLWithPath:))
    }
    set {
      executablePath = newValue?.path
    }
  }

  public var executablePath: String?

  public var environment: [String : String]?

  public var currentDirectoryURL: URL?

  public var arguments: [String]

  public var alternativeExecutableNames: [String] = .init()

}
