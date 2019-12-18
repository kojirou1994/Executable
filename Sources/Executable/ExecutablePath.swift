import Foundation

public struct ExecutablePath {

    private static var PATHs = ProcessInfo.processInfo.environment["PATH", default: ""].split(separator: ":")

    public static func set(_ path: String) {
        ExecutablePath.PATHs = path.split(separator: ":")
    }

    private static var customLookup: ((String) throws -> String?)?

    public static func set(_ lookupMethod: ((String) throws -> String?)?) {
        Self.customLookup = lookupMethod
    }

    internal static func lookup(_ executable: String, customPaths: [Substring]? = nil) throws -> String {
        assert(!executable.isEmpty)
        if let customLookup = Self.customLookup {
            if let result = try customLookup(executable) {
                return result
            } else {
//                throw ExecutableError.executableNotFound(executable)
            }
        }
        let paths: [Substring]
        if let customPaths = customPaths, !customPaths.isEmpty {
            paths = customPaths
        } else if !ExecutablePath.PATHs.isEmpty {
            paths = ExecutablePath.PATHs
        } else {
            throw ExecutableError.pathNull
        }

        for path in paths {
            let tmp = "\(path)/\(executable)"
            if FileManager.default.isExecutableFile(atPath: tmp) {
                return tmp
            }
        }
        throw ExecutableError.executableNotFound(executable)
    }
}
