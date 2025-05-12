import SystemUp
import CUtility

public struct ExecExecutableLauncher: ExecutableLauncher {

  public var resetBlockedSignals: Bool

  public init(resetBlockedSignals: Bool) {
    self.resetBlockedSignals = resetBlockedSignals
  }

  public func launch<T>(executable: T, options: ExecutableLaunchOptions) throws -> Never where T : Executable {
    let path = try ExecutablePath.lookup(executable).get()
    var args = CStringArray()
    args.append(.copy(bytes: path))
    args.append(contentsOf: executable.arguments)

    try args.withUnsafeCArrayPointer { array in
      // for compiler no warning
      Result {
        if resetBlockedSignals {
          try BlockedSignals.singleThreaded.restoreAfter {
            try SystemCall.exec(path, argv: array, searchPATH: false)
          }
        } else {
          try SystemCall.exec(path, argv: array, searchPATH: false)
        }
      }
    }.get()
  }

}

public extension ExecutableLauncher where Self == ExecExecutableLauncher {

  @inlinable
  static var exec: Self {
    .exec(resetBlockedSignals: true)
  }

  @inlinable
  static func exec(resetBlockedSignals: Bool) -> Self {
    .init(resetBlockedSignals: resetBlockedSignals)
  }

}
