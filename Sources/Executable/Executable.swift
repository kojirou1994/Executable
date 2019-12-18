import Foundation

public enum ExecutableError: Error {
    case pathNull
    case executableNotFound(String)
    case foundationNonZeroExit(Int32)
    case tscNonZeroExit(TSCExitStatus)
}

public enum ExecutableLaunchMode {
    case foundation
    /// swift-tools-support-core
    case tsc
}

public enum ExecutableStandardStream {
    case fileHandle(FileHandle)
    case pipe(Pipe)

    var valueForProcess: Any {
        switch self {
        case .fileHandle(let f):
            return f as Any
        case .pipe(let p):
            return p as Any
        }
    }
}

public protocol Executable: CustomStringConvertible {
    
    static var executableName: String {get}
    
    var arguments: [String] {get}

    var environment: [String : String]? {get}

    /// only work in foundation mode
    var standardInput: ExecutableStandardStream? {get}

    /// only work in foundation mode
    var standardOutput: ExecutableStandardStream? {get}

    /// only work in foundation mode
    var standardError: ExecutableStandardStream? {get}

    var currentDirectoryURL: URL? {get}

    var executableName: String {get}

    var executableURL: URL? {get}

    var launchMode: ExecutableLaunchMode {get}
}

extension Executable {
    
    public var executableName: String { Self.executableName }

    public var executableURL: URL? {nil}

    public var environment: [String : String]? {nil}

    public var standardInput: ExecutableStandardStream? {nil}

    public var standardOutput: ExecutableStandardStream? {nil}

    public var standardError: ExecutableStandardStream? {nil}

    /// only work in foundation mode
    public var currentDirectoryURL: URL? {nil}

    public var launchMode: ExecutableLaunchMode { .tsc }
    
    public func checkValid() throws {
        if executableURL == nil {
            _ = try ExecutablePath.lookup(executableName)
        }
    }
    
    public var description: String {
        "CommandLine: \(executableName) \(arguments.joined(separator: " "))"
    }
    
    public var commandLineArguments: [String] {
        CollectionOfOne(executableName) + arguments
    }
    
}
/*
public class ProcessOperation: Operation {
    
    internal let _process: Process
    
    public init(_ process: Process) {
        _process = process
    }
    
    override public func main() {
        try! _process.kwift_run(wait: true)
    }
    
    override public func cancel() {
        #if os(macOS)
        _process.terminate()
        #else
        kill(_process.processIdentifier, SIGTERM)
        #endif
    }
}

public extension OperationQueue {
    func add(_ process: Process) {
        addOperation(ProcessOperation(process))
    }
    
    func add<E: Executable>(_ executable: E/*, preparation: (Process) -> Void*/) {
        let p = try! executable.generateProcess()
//        preparation(p)
//        addOperation(ProcessOperation(p))
    }
}
*/
