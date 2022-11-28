import Foundation
import XMLCoder
import ArgumentParser
import Stencil
import PathKit
import MoreCodable
import StencilSwiftKit
import Yams

struct RunnableConfig: Decodable {
    var xcdatamodel: Path
    var output: Path
    var templates: [Path]

    var modelXMLURL: URL { xcdatamodel.url.appendingPathComponent("contents") }
    private lazy var resultContentPerFile: [URL: String] = [:]
}

extension RunnableConfig {
    init(file: Path, env: [String: String] = ProcessInfo.processInfo.environment) throws {
        let basePath: Path = Path(components: file.components.dropLast())
        let content = try file.read()
        
        var config = try YAMLDecoder().decode(RunnableConfig.self, from: content)
        config.xcdatamodel = config.xcdatamodel.isRelative ? basePath + config.xcdatamodel : config.xcdatamodel
        config.output = config.output.isRelative ? basePath + config.output : config.output
        config.templates = config.templates.map { $0.isRelative ? basePath + $0 : $0 }
        
        self = try RunnableConfig(xcdatamodel: config.xcdatamodel, output: config.output, templates: config.templates)
    }
    
    init(xcdatamodel: Path, output: Path, templates: [Path]) throws {
        self.xcdatamodel = xcdatamodel
        self.output = output
        
        var allPaths: [Path] = []
        for path in templates {
            if path.isFile {
                allPaths.append(path)
            } else {
                let subpaths = try path.recursiveChildren()
                for path in subpaths {
                    if path.isFile, path.extension?.lowercased() == "stencil" {
                        allPaths.append(path)
                    }
                }
            }
        }
        
        self.templates = allPaths
    }
}


// MARK: - Config Run

extension RunnableConfig {    
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
    
    // MARK: - Run
    
    mutating func run() throws {
        print("UnmanagedData: Start parsing data")
        
        let data = try loadModelData()
        let model = try XMLDecoder().decode(CoreDataModel.self, from: data)
        model.populateMissingData()
        
        let dictionary = try DictionaryEncoder().encode(model)
        let regexp = try NSRegularExpression(pattern: "^\\/\\/\\s?unmanageddata:file:(?<filename>.+?)$(?<content>.+?)^\\/\\/\\s?unmanageddata:file:end$", options: [.dotMatchesLineSeparators, .anchorsMatchLines])
        
        for templatePath in templates {
            print("UnmanagedData: Parse template at \(templatePath)")
            
            let template = try loadTemplate(at: templatePath.url)
            let result = try template.render(dictionary)
            guard !result.isEmpty else { return }
            
            let canonicalName: String
            if templatePath.extension?.isEmpty != false {
                canonicalName = "\(templatePath.lastComponent).generated.swift"
            } else {
                canonicalName = "\(templatePath.lastComponentWithoutExtension).generated.swift"
            }
            let canonicalOutput = output.extension == "swift" ? output.url : output.url.appendingPathComponent(canonicalName)
            
            let matches = regexp.matches(in: result, range: NSRange(location: 0, length: result.count))
            
            if matches.isEmpty {
                append(content: result, toFileAt: canonicalOutput)
            } else {
                let mutableString = NSMutableString(string: result)
                for match in matches.reversed() {
                    let filename = mutableString.substring(with: match.range(withName: "filename"))
                    let content = mutableString.substring(with: match.range(withName: "content"))
                    
                    let fileURL = output.url.appendingPathComponent(filename)
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
            print("UnmanagedData: Write result to \(url.path)")
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
