import Foundation
import XMLCoder
import ArgumentParser
import Stencil
import PathKit
import MoreCodable
import StencilSwiftKit

struct UnmanagedData: ParsableCommand {
    @Argument(help: "Path to model XML or .xcdatamodel", transform: URL.init(fileURLWithPath:))
    var modelURL: URL
    
    @Option(name: .customLong("output"), help: "Generated models output folder", transform: URL.init(fileURLWithPath:))
    var outputURL: URL
    
    @Option(name: .customLong("template"), parsing: .next, help: "Path to template.", transform: URL.init(fileURLWithPath:))
    var templateURL: URL
    
    private var modelXMLURL: URL {
        if modelURL.pathExtension == "xcdatamodel" {
            return modelURL.appendingPathComponent("contents")
        } else {
            return modelURL
        }
    }

    private func loadTemplate() throws -> Stencil.Template {
        let isAcccessing = templateURL.startAccessingSecurityScopedResource()
        defer {
            if isAcccessing { templateURL.stopAccessingSecurityScopedResource() }
        }

        let templatesPath = Path(templateURL.deletingLastPathComponent().path)
        return try stencilSwiftEnvironment(templatePaths: [templatesPath]).loadTemplate(name: templateURL.lastPathComponent)
    }
    
    private var canonicalName: String {
        if modelURL.pathExtension.isEmpty {
            return "\(modelURL.lastPathComponent).generated.swift"
        } else {
            return "\(modelURL.deletingPathExtension().lastPathComponent).generated.swift"
        }
    }
    
    private var canonicalOutput: URL {
        outputURL.pathExtension == "swift" ? outputURL : outputURL.appendingPathComponent(canonicalName)
    }
    
    mutating func validate() throws {
        let isAcccessing = modelXMLURL.startAccessingSecurityScopedResource()
        guard FileManager.default.fileExists(atPath: modelXMLURL.path) else {
            throw ValidationError("File does not exist at \(modelXMLURL.path)")
        }
        if isAcccessing { modelXMLURL.stopAccessingSecurityScopedResource() }
    }

    mutating func run() throws {
        let template = try loadTemplate()
       
        let isAcccessing = modelXMLURL.startAccessingSecurityScopedResource()
        let data = try Data(contentsOf: modelXMLURL)
        if isAcccessing { modelXMLURL.stopAccessingSecurityScopedResource() }
        
        let model = try XMLDecoder().decode(CoreDataModel.self, from: data)
        let dictionary = try DictionaryEncoder().encode(model)
        
        let result = try template.render(dictionary)
        guard !result.isEmpty else { return }
        
        let regexp = try NSRegularExpression(pattern: "^\\/\\/\\s?unmanageddata:file:(?<filename>.+?)$(?<content>.+?)^\\/\\/\\s?unmanageddata:file:end$", options: [.dotMatchesLineSeparators, .anchorsMatchLines])
        let matches = regexp.matches(in: result, range: NSRange(location: 0, length: result.count))
        
        if matches.isEmpty {
            try write(content: result, to: canonicalOutput)
        } else {
            let mutableString = NSMutableString(string: result)
            for match in matches.reversed() {
                let filename = mutableString.substring(with: match.range(withName: "filename"))
                let content = mutableString.substring(with: match.range(withName: "content"))
             
                let fileURL = outputURL.appendingPathComponent(filename)
                try write(content: content.trimmingCharacters(in: .whitespacesAndNewlines), to: fileURL)
                
                mutableString.replaceCharacters(in: match.range, with: "")
            }
            
            let reminder = mutableString.trimmingCharacters(in: .whitespacesAndNewlines)
            if !reminder.isEmpty {
                try write(content: reminder, to: canonicalOutput)
            }
        }
    }
    
    private func createOutputFolderIfNeeded(folder: URL) throws {
        if FileManager.default.fileExists(atPath: folder.path) == false {
            try FileManager.default.createDirectory(atPath: folder.path, withIntermediateDirectories: true)
        }
    }
    
    private func write(content: String, to: URL) throws {
        let fullContent =
"""
// Generated using UnmagedData
// DO NOT EDIT

\(content)


"""
        try createOutputFolderIfNeeded(folder: to.deletingLastPathComponent())
        try fullContent.write(toFile: to.path, atomically: true, encoding: .utf8)
    }
}

UnmanagedData.main()
