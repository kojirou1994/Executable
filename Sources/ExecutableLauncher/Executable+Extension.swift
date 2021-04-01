@_exported import ExecutableDescription
import Foundation

public extension Executable {
  func checkValid() throws {
    if let fileURL = executableURL {
      if !FileManager.default.isExecutableFile(atPath: fileURL.path) {
        throw ExecutableError.invalidExecutableURL(fileURL)
      }
    } else {
      _ = try ExecutablePath.lookup(self)
    }
  }

  static func checkValid() throws {
    _ = try ExecutablePath.lookup(self)
  }
  
  var commandLineArguments: [String] {
    var result = [executableName.spm_shellEscaped()]
    let cachedArgs = arguments
    result.reserveCapacity(cachedArgs.count)
    cachedArgs.forEach { result.append($0.spm_shellEscaped()) }
    return result
  }

  var shellCommand: String {
    commandLineArguments.joined(separator: " ")
  }
}
