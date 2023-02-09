import Foundation
import XMLCoder
import ArgumentParser
import Stencil
import PathKit
import MoreCodable
import StencilSwiftKit

struct Run: ParsableCommand {
    @Argument(help: "Path to .xcdatamodel", completion: .file(extensions: ["xcdatamodel"]))
    var modelPath: Path
    
    @Option(name: .customLong("output"), help: "Generated models output folder")
    var outputPath: Path
    
    @Option(name: .customLong("template"), help: "Path to template.", completion: .file(extensions: ["stencil"]))
    var templatePaths: [Path]
    
    @Option(name: .customLong("prune"), help: "Remove old generated files")
    var prune: Bool = false
    
    @Option(help: "Additional arguments to pass to templates. Each argument can have an explicit value or will have an implicit `true` value. Arguments should be passed one by one (e.g. --arguments arg1=value --arguments arg2). Arguments are accessible in templates via `arguments.<name>`.")
    var arguments: [String] = []
    
    var modelXMLURL: URL { modelPath.url.appendingPathComponent("contents") }
    
    mutating func validate() throws {
        let isAcccessing = modelXMLURL.startAccessingSecurityScopedResource()
        guard FileManager.default.fileExists(atPath: modelXMLURL.path) else {
            throw ValidationError("File does not exist at \(modelXMLURL.path)")
        }
        if isAcccessing { modelXMLURL.stopAccessingSecurityScopedResource() }
    }
    
    // MARK: - Run
    
    mutating func run() throws {
        print("UnmanagedData: Will execute 'run' command")
        var arguments: [String: String] = [:]
        
        for arg in self.arguments {
            let comps = arg.components(separatedBy: "=")
            if comps.count == 1 {
                arguments[comps[0]] = "true"
            } else if comps.count == 2 {
                arguments[comps[0]] = comps[1]
            } else {
                throw ValidationError("Invalid argument: \(arg)")
            }
        }
        
        var config = try RunnableConfig(xcdatamodel: modelPath, output: outputPath, templates: templatePaths, prune: prune, arguments: arguments)
        try config.run()
    }
}
