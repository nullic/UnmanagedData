import Foundation
import PackagePlugin

@main
struct UnmanagedDataPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        // Possible paths where there may be a config file (root of package, target dir.)
        let configurations: [Path] = [context.package.directory, target.directory]
            .map { $0.appending("umd.yml") }
            .filter { FileManager.default.fileExists(atPath: $0.string) }
        
        let umd = try context.tool(named: "UnmanagedData")
        Diagnostics.remark("toolPath: \(umd.path)")
        Diagnostics.remark("context.pluginWorkDirectory: \(context.pluginWorkDirectory)")
        Diagnostics.remark("target.directory: \(target.directory)")
        
        guard !configurations.isEmpty else {
          Diagnostics.error("No UnmanagedData configurations found for target \(target.name).")
          return []
        }
        
        return configurations.map { config in
//                .buildCommand(displayName: "UnmanagedData BuildTool Plugin", executable: umd.path, arguments: ["config", "\(config)"])
                .prebuildCommand(
                    displayName: "UnmanagedData BuildTool Plugin",
                    executable: umd.path,
                    arguments: ["config", "\(config)"],
                    outputFilesDirectory: target.directory
                )
        }
    }
}
