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
    
    @Option(name: .customLong("template"), help: "Path to template.")
    var templatePaths: [String]

    private lazy var templateURLs: [URL] = templatePaths.map { URL(fileURLWithPath: $0) }
    
    private lazy var resultContentPerFile: [URL: String] = [:]
    
    // MARK: -
    
    private var modelXMLURL: URL {
        if modelURL.pathExtension == "xcdatamodel" {
            return modelURL.appendingPathComponent("contents")
        } else {
            return modelURL
        }
    }
    
    private func loadModelData() throws -> Data {
        let isAcccessing = modelXMLURL.startAccessingSecurityScopedResource()
        defer {
            if isAcccessing { modelXMLURL.stopAccessingSecurityScopedResource() }
        }
        return try Data(contentsOf: modelXMLURL)
    }

    private func loadTemplate(at templateURL: URL) throws -> Stencil.Template {
        let isAcccessing = templateURL.startAccessingSecurityScopedResource()
        defer {
            if isAcccessing { templateURL.stopAccessingSecurityScopedResource() }
        }

        let templatesPath = Path(templateURL.deletingLastPathComponent().path)
        return try stencilSwiftEnvironment(templatePaths: [templatesPath]).loadTemplate(name: templateURL.lastPathComponent)
    }
    
    mutating func validate() throws {
        let isAcccessing = modelXMLURL.startAccessingSecurityScopedResource()
        guard FileManager.default.fileExists(atPath: modelXMLURL.path) else {
            throw ValidationError("File does not exist at \(modelXMLURL.path)")
        }
        if isAcccessing { modelXMLURL.stopAccessingSecurityScopedResource() }
    }
    
    // MARK: - Run

    mutating func run() throws {
        let data = try loadModelData()
        let model = try XMLDecoder().decode(CoreDataModel.self, from: data)
        model.populateMissingData()
        
        let dictionary = try DictionaryEncoder().encode(model)
        let regexp = try NSRegularExpression(pattern: "^\\/\\/\\s?unmanageddata:file:(?<filename>.+?)$(?<content>.+?)^\\/\\/\\s?unmanageddata:file:end$", options: [.dotMatchesLineSeparators, .anchorsMatchLines])
        
        for templateURL in templateURLs {
            let template = try loadTemplate(at: templateURL)
            let result = try template.render(dictionary)
            guard !result.isEmpty else { return }
            
            
            let canonicalName: String
            if templateURL.pathExtension.isEmpty {
                canonicalName = "\(templateURL.lastPathComponent).generated.swift"
            } else {
                canonicalName = "\(templateURL.deletingPathExtension().lastPathComponent).generated.swift"
            }
            let canonicalOutput = outputURL.pathExtension == "swift" ? outputURL : outputURL.appendingPathComponent(canonicalName)
            
            let matches = regexp.matches(in: result, range: NSRange(location: 0, length: result.count))
            
            if matches.isEmpty {
                append(content: result, toFileAt: canonicalOutput)
            } else {
                let mutableString = NSMutableString(string: result)
                for match in matches.reversed() {
                    let filename = mutableString.substring(with: match.range(withName: "filename"))
                    let content = mutableString.substring(with: match.range(withName: "content"))
                    
                    let fileURL = outputURL.appendingPathComponent(filename)
                    append(content: content.trimmingCharacters(in: .whitespacesAndNewlines), toFileAt: fileURL)

                    mutableString.replaceCharacters(in: match.range, with: "")
                }
                
                let reminder = mutableString.trimmingCharacters(in: .whitespacesAndNewlines)
                if !reminder.isEmpty {
                    append(content: reminder, toFileAt: canonicalOutput)
                }
            }
        }
        
        try writeResult()
    }
    
    // MARK: - Write result
    
    private mutating func append(content: String, toFileAt url: URL) {
        if let currentContent = resultContentPerFile[url] {
            resultContentPerFile[url] = currentContent.appending("\n\n").appending(content)
        }
        else {
            resultContentPerFile[url] = content
        }
    }
    
    private mutating func writeResult() throws {
        for (url, content) in resultContentPerFile {
            try write(content: content, to: url)
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

// MARK: -

UnmanagedData.main()
