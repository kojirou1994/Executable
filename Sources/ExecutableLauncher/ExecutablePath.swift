import Algorithms
import SystemPackage
import SystemUp

public enum ExecutablePath {

  public typealias LookupMethod = (String) -> String?

  public static var customLookup: LookupMethod?

  @inlinable
  public static func lookup<E: Executable>(_ executable: E? = nil, type: E.Type = E.self, forcePATH: String? = nil) -> Result<String, ExecutableError> {
    if let executablePath = (executable?.executablePath ?? executable?.executableURL?.path) {
      if FileSyscalls.check(.absolute(FilePath(executablePath)), accessibility: .execute) {
        return .success(executablePath)
      } else {
        return .failure(.invalidProvidedExecutablePath)
      }
    }
    if let instance = executable {
      return lookup(instance.executableName, alternativeExecutableNames: instance.alternativeExecutableNames, forcePATH: forcePATH)
    } else {
      return lookup(E.executableName, alternativeExecutableNames: E.alternativeExecutableNames, forcePATH: forcePATH)
    }
  }

  public static func lookup(_ executableName: String, alternativeExecutableNames: [String], forcePATH: String? = nil) -> Result<String, ExecutableError> {

    let executableNames = chain(CollectionOfOne(executableName), alternativeExecutableNames)

    for name in executableNames {
      assert(!name.isEmpty, "this executableName is empty!")
      assert(!name.contains("/" as Character))
      if let result = customLookup?(name) {
        return .success(result)
      }
    }

    guard let path = (forcePATH ?? PosixEnvironment.get(key: "PATH")) else {
      return .failure(.executableNotFound)
    }

    let searchPATHs = path.lazy.split(separator: ":").map { FilePath(String($0)) }

    for (name, path) in product(executableNames, searchPATHs) {
      let testPath = path.appending(name)
      if FileSyscalls.check(.absolute(testPath), accessibility: .execute) {
        return .success(testPath.string)
      }
    }

    return .failure(.executableNotFound)
  }
}
