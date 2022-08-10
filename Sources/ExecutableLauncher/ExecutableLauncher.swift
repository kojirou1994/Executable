public protocol ExecutableLauncher {
  associatedtype Process
  associatedtype LaunchResult

  func generateProcess<T>(for executable: T) throws -> Process where T: Executable
  func launch<T>(executable: T, options: ExecutableLaunchOptions) throws -> LaunchResult where T: Executable
}

public struct ExecutableLaunchOptions {
  public let checkNonZeroExitCode: Bool

  public init(checkNonZeroExitCode: Bool = true) {
    self.checkNonZeroExitCode = checkNonZeroExitCode
  }

}

extension Executable {
  @inlinable
  @discardableResult
  public func launch<T: ExecutableLauncher>(use launcher: T, options: ExecutableLaunchOptions = .init()) throws -> T.LaunchResult {
    try launcher.launch(executable: self, options: options)
  }

  @inlinable
  public func generateProcess<T: ExecutableLauncher>(use launcher: T) throws -> T.Process {
    try launcher.generateProcess(for: self)
  }

  @inlinable
  @discardableResult
  @available(macOS 10.15, *)
  public func result<T: ExecutableLauncher>(use launcher: T,  options: ExecutableLaunchOptions = .init()) async throws -> T.LaunchResult {
    try launcher.launch(executable: self, options: options)
  }
}
