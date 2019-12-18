import Foundation

extension Process {

    public typealias LaunchedHandler = (_ processIdentifier: Int32) -> Void
    
    public func run(waitUntilExit: Bool,
                         checkNonZeroExitCode: Bool = true,
                         launchedHandler: LaunchedHandler? = nil) throws {
        #if os(macOS)
        if #available(OSX 10.13, *) {
            try run()
        } else {
            launch()
        }
        #else
        try run()
        #endif
        launchedHandler?(self.processIdentifier)
        if waitUntilExit {
            while isRunning {
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
        if checkNonZeroExitCode, terminationStatus != 0 {
            throw ExecutableError.foundationNonZeroExit(terminationStatus)
        }
    }

}
