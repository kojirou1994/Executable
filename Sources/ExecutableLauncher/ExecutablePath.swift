import Foundation

public struct ExecutablePath {
  
  private static var PATHs = ProcessInfo.processInfo.environment["PATH", default: ""].split(separator: ":")
  
  public static func set(path: String) {
    ExecutablePath.PATHs = path.split(separator: ":")
  }
  
  public static func add(_ path: String, toHead: Bool = true) {
    let paths = path.split(separator: ":")
    if toHead {
      Self.PATHs.insert(contentsOf: paths, at: 0)
    } else {
      Self.PATHs.append(contentsOf: paths)
    }
  }
  
  public typealias LookupMethod = (String) throws -> String?
  
  private static var customLookup: LookupMethod?

  public static func set(lookupMethod: LookupMethod?) {
    Self.customLookup = lookupMethod
  }

  public static func lookup<E: Executable>(_ executable: E, overridePath: String? = nil) throws -> String {
    if let result = try? lookup(executable.executableName, overridePath: overridePath) {
      return result
    }
    for executableName in E.alternativeExecutableNames {
      if let result = try? lookup(executableName, overridePath: overridePath) {
        return result
      }
    }
    throw ExecutableError.executableNotFound(executable.executableName)
  }

  @discardableResult
  public static func lookup(_ executableName: String, overridePath: String? = nil) throws -> String {
    precondition(!executableName.isEmpty, "executableName is empty!")
    if let customLookup = Self.customLookup {
      if let result = try customLookup(executableName) {
        return result
      }
    }

    let searchPATHs: [Substring]
    if let path = overridePath {
      searchPATHs = path.split(separator: ":")
    } else {
      searchPATHs = PATHs
    }

    for path in searchPATHs {
      let tmp = "\(path)/\(executableName)"
      if FileManager.default.isExecutableFile(atPath: tmp) {
        return tmp
      }
    }

    throw ExecutableError.executableNotFound(executableName)
  }
}
