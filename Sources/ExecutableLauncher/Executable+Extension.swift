@_exported import ExecutableDescription
import Foundation

public extension Executable {
  func validate() throws {
    if let fileURL = executableURL {
      if !FileManager.default.isExecutableFile(atPath: fileURL.path) {
        throw ExecutableError.invalidExecutableURL(fileURL)
      }
    } else {
      _ = try ExecutablePath.lookup(self)
    }
  }

  static func validate() throws {
    _ = try ExecutablePath.lookup(self)
  }
}
