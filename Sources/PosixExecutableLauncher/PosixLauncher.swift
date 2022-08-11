import SystemPackage
import SystemUp
@_exported import ExecutableLauncher

public struct PosixExecutableLauncher: ExecutableLauncher {
  public func generateProcess<T>(for executable: T) throws -> Process where T : ExecutableDescription.Executable {
    .init()
  }

  public func launch<T>(executable: T, options: ExecutableLaunchOptions) throws -> LaunchResult where T : ExecutableDescription.Executable {
    .init()
  }

  public struct Process {}

  public struct LaunchResult {}


}
