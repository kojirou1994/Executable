import struct Foundation.URL

public enum ExecutableError: Error {
  case executableNotFound(String)
  case nonZeroExit
  case invalidExecutableURL(URL)
}
