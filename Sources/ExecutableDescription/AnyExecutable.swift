public struct AnyExecutable: Executable, Sendable {
  public static var executableName: String {
    assertionFailure("Should not be used.")
    fatalError()
  }

  public init(executableName: String, arguments: [String]) {
    self.executableName = executableName
    self.arguments = arguments
  }

  public init(executablePath: String, arguments: [String]) {
    if let sepIndex = executablePath.lastIndex(of: "/") {
      executableName = String(executablePath.suffix(from: sepIndex).dropFirst())
      if executableName.isEmpty {
        fatalError("invalid executablePath: \(executablePath)")
      }
    } else {
      executableName = executablePath
    }
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
