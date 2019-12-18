import Foundation

extension Executable {
    public func generateFoundationProcess() throws -> Process {
        let process = Process()
        if let executableURL = self.executableURL {
            // provied url
            #if os(macOS)
            if #available(OSX 10.13, *) {
                process.executableURL = executableURL
            } else {
                process.launchPath = executableURL.path
            }
            #else
            process.executableURL = executableURL
            #endif
        } else {
            // search in PATH
            let launchPath = try ExecutablePath.lookup(executableName)
            let executableURL = URL(fileURLWithPath: launchPath)
            #if os(macOS)
            if #available(OSX 10.13, *) {
                process.executableURL = executableURL
            } else {
                process.launchPath = launchPath
            }
            #else
            process.executableURL = executableURL
            #endif
        }

        process.arguments = arguments
        if let environment = self.environment {
            process.environment = environment
        }
        if let standardInput = self.standardInput?.valueForProcess {
            process.standardInput = standardInput
        }
        if let standardOutput = self.standardOutput?.valueForProcess {
            process.standardOutput = standardOutput
        }
        if let standardError = self.standardError?.valueForProcess {
            process.standardError = standardError
        }
        if let currentDirectoryURL = self.currentDirectoryURL {
            #if os(macOS)
            if #available(OSX 10.13, *) {
                process.currentDirectoryURL = currentDirectoryURL
            } else {
                process.currentDirectoryPath = currentDirectoryURL.path
            }
            #else
            process.currentDirectoryURL = currentDirectoryURL
            #endif
        }
        return process
    }
}
