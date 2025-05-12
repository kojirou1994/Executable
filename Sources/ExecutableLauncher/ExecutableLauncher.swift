@_exported import ExecutableDescription
import SystemUp

public protocol ExecutableLauncher {
  associatedtype LaunchResult

  func launch<T>(executable: T, options: ExecutableLaunchOptions) throws -> LaunchResult where T: Executable
}

public struct ExecutableLaunchOptions: Sendable {
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
  @discardableResult
  public func result<T: ExecutableLauncher & Sendable>(use launcher: T,  options: ExecutableLaunchOptions = .init()) async throws -> T.LaunchResult where Self: Sendable {
    try await withUnsafeThrowingContinuation { continuation in
      try! PosixThread.detach {
        continuation.resume(with: Result.init(catching: {
          try launcher.launch(executable: self, options: options)
        }))
      }
    }
  }
}
