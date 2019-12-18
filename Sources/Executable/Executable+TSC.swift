import TSCBasic

public typealias TSCProcessOutputRedirection = Process.OutputRedirection
public typealias TSCExitStatus = ProcessResult.ExitStatus
public typealias TSCResult = ProcessResult

extension Executable {

    public func generateTSCProcess(outputRedirection: TSCProcessOutputRedirection, startNewProcessGroup: Bool) throws -> Process {
        let launchPath = try executableURL?.path ?? ExecutablePath.lookup(executableName)

        let process = Process(arguments: CollectionOfOne(launchPath) + arguments,
                              environment: self.environment ?? ProcessEnv.vars,
                              outputRedirection: outputRedirection,
                              verbose: false, startNewProcessGroup: startNewProcessGroup)
        return process
    }

    public func runTSC(outputRedirection: TSCProcessOutputRedirection = .collect,
                       checkNonZeroExitCode: Bool = true,
                       startNewProcessGroup: Bool = false) throws -> TSCResult {
        let process = try generateTSCProcess(outputRedirection: outputRedirection, startNewProcessGroup: false)
        try process.launch()
        let result = try process.waitUntilExit()
        if checkNonZeroExitCode, result.exitStatus != .terminated(code: 0) {
            throw ExecutableError.tscNonZeroExit(result.exitStatus)
        }
        return result
    }
}
