import Foundation
/*
@dynamicMemberLookup
public struct Shell {
    
    public typealias ProcessPreparation = (Process) -> Void
    
    public var beforeRun: ProcessPreparation?
    
    let background: Bool
    
    let customPaths: [Substring]?
    
    public init(background: Bool = false, customPath: String? = nil, beforeRun: ProcessPreparation? = nil) {
        self.beforeRun = beforeRun
        self.customPaths = customPath?.split(separator: ":")
        self.background = background
    }
    
    public subscript(dynamicMember key: String) -> ShellProcess {
        get {
            return ShellProcess.init(executablePath: .init(catching: { try ExecutablePath.lookup(key, customPaths: customPaths)}), beforeRun: beforeRun, background: background)
        }
    }
    
    @dynamicCallable
//    @dynamicMemberLookup
    public struct ShellProcess {
        let executablePath: Result<String, Error>
        
        let beforeRun: ProcessPreparation?
        
        let background: Bool
        
        fileprivate init(executablePath: Result<String, Error>, beforeRun: ProcessPreparation?, background: Bool) {
            self.executablePath = executablePath
            self.beforeRun = beforeRun
            self.background = background
        }
        
//        public subscript(dynamicMember key: String) -> ShellProcess {
//            return .init(executablePath: executablePath + "-" + key, preparation: preparation, background: background)
//        }
        
//        @discardableResult
        public func dynamicallyCall(withArguments arguments: [String]) throws -> LaunchResult {
            let executablePath = try self.executablePath.get()
            let process = Process.init()
            #if os(macOS)
            if #available(OSX 10.13, *) {
                process.executableURL = URL.init(fileURLWithPath: executablePath)
            } else {
                process.launchPath = executablePath
            }
            #else
            process.executableURL = URL.init(fileURLWithPath: executablePath)
            #endif
            process.arguments = arguments
            beforeRun?(process)
            
            return try process.catchResult()
        }
        
    }
    
}

internal extension Process {
    
    func catchResult() throws -> LaunchResult {
        #if os(macOS)
        let copyQueue = DispatchQueue.init(label: UUID().uuidString)
        let stderr = Pipe()
        let stdout = Pipe()
        self.standardError = stderr
        self.standardOutput = stdout
        
        var stdoutData = Data()
        var stderrData  = Data()
        stderr.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            copyQueue.sync {
                stderrData.append(data)
            }
        }
        
        stdout.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            copyQueue.sync {
                stdoutData.append(data)
            }
        }
        try self.run(waitUntilExit: true)
        stdout.fileHandleForReading.readabilityHandler = nil
        stderr.fileHandleForReading.readabilityHandler = nil
        return copyQueue.sync {
            return LaunchResult.init(process: self, stdout: stdoutData, stderr: stderrData)
        }
        #else
        let stderr = URL.init(fileURLWithPath: "\(NSTemporaryDirectory())/\(UUID().uuidString)")
        let stdout = URL.init(fileURLWithPath: "\(NSTemporaryDirectory())/\(UUID().uuidString)")
        #if DEBUG
        print("stderr redirect: \(stderr)")
        print("stdout redirect: \(stdout)")
        #endif
        FileManager.default.createFile(atPath: stderr.path, contents: nil, attributes: nil)
        FileManager.default.createFile(atPath: stdout.path, contents: nil, attributes: nil)
        let stderrF = try FileHandle.init(forUpdating: stderr)
        let stdoutF = try FileHandle.init(forUpdating: stdout)
        standardError = stderrF
        standardOutput = stdoutF
        try self.kwiftRun(waitUntilExit: true)
        stderrF.seek(toFileOffset: 0)
        stdoutF.seek(toFileOffset: 0)
        defer {
            stderrF.closeFile()
            stdoutF.closeFile()
        }
        return LaunchResult.init(process: self, stdout: stdoutF.availableData, stderr: stderrF.availableData)
        #endif
    }
}

public struct LaunchResult {
    public let process: Process
    public let stdout: Data
    public let stderr: Data
    
    public var terminationStatus: Int32 {
        return process.terminationStatus
    }
}
*/
