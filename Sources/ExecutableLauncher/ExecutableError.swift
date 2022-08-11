import struct Foundation.URL

public enum ExecutableError: Error {
  case executableNotFound
  case nonZeroExit
  case invalidProvidedExecutablePath
}

public extension ExecutableError {
  @available(*, deprecated, renamed: "invalidExecutablePath")
  static var invalidExecutableURL: Self {
    .invalidProvidedExecutablePath
  }
}
