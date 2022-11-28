import Foundation
import PackagePlugin

@main
struct UnmanagedDataPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let umd = try context.tool(named: "UnmanagedData")
        
        let configuration = context.package.directory.appending("umd.yml")
        if FileManager.default.fileExists(atPath: configuration.string) {
            try umd.run(configuration)
        }

        let targets = context.package.targets.compactMap { $0 as? SourceModuleTarget }
        for target in targets {
            let configuration = target.directory.appending("umd.yml")
            if FileManager.default.fileExists(atPath: configuration.string) {
                try umd.run(configuration)
            }
        }
    }
}

private extension PluginContext.Tool {
    func run(_ configuration: Path) throws {
        Diagnostics.remark("\(name): config -- \(configuration)")
        let task = Process()
        task.executableURL = URL(fileURLWithPath: path.string)
        task.arguments = ["config", configuration.string]
        
        try task.run()
        task.waitUntilExit()
        
        if !(task.terminationReason == .exit && task.terminationStatus == 0) {
            let problem = "\(task.terminationReason):\(task.terminationStatus)"
            Diagnostics.error("\(name) invocation failed: \(problem)")
        }
    }
}
