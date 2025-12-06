import SystemUp

public enum ExecutableError: Error {
  case executableNotFound
  case nonZeroExit
  case invalidProvidedExecutablePath
  case exec(Errno)
}
