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
        var config = try RunnableConfig(xcdatamodel: modelPath, output: outputPath, templates: templatePaths, prune: prune)
        try config.run()
    }
}
