import SystemUp
import CUtility

public struct ExecExecutableLauncher: ExecutableLauncher {

  public var resetBlockedSignals: Bool

  public init(resetBlockedSignals: Bool) {
    self.resetBlockedSignals = resetBlockedSignals
  }

  public func launch<T>(executable: T, options: ExecutableLaunchOptions) throws(ExecutableError) -> Never where T : Executable {
    let path = try ExecutablePath.lookup(executable).get()
    var args = CStringArray()
    args.append(try! .copy(bytes: path))
    args.append(contentsOf: executable.arguments)

    try args.withUnsafeCArrayPointer { array in
      // for compiler no warning
      Result<Never, Errno> { () throws(Errno) in
        if resetBlockedSignals {
          try BlockedSignals.singleThreaded.restoreAfter { () throws(Errno) in
            try SystemCall.exec(path, argv: array, searchPATH: false)
          }
        } else {
          try SystemCall.exec(path, argv: array, searchPATH: false)
        }
      }
    }.mapError { ExecutableError.exec($0) }.get()
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
