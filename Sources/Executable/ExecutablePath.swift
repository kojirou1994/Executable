import Foundation

public struct ExecutablePath {

    private static var PATHs = ProcessInfo.processInfo.environment["PATH", default: ""].split(separator: ":")

    public static func set(_ path: String) {
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

    public static func set(_ lookupMethod: LookupMethod?) {
        Self.customLookup = lookupMethod
    }

    @discardableResult
    public static func lookup(_ executable: String, customPaths: [Substring]? = nil) throws -> String {
        assert(!executable.isEmpty)
        if let customLookup = Self.customLookup {
            if let result = try customLookup(executable) {
                return result
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
