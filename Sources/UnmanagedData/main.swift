import Foundation
import XMLCoder
import ArgumentParser
import Stencil
import PathKit

private let templateExtension = ".stencil"
private let templatesURL: URL! = Bundle.module.resourceURL?.appendingPathComponent("templates")
private var templates: [String] = {
    var result: [String]?
    if let templatesURL = templatesURL {
        let paths = try? FileManager.default.contentsOfDirectory(atPath: templatesURL.path)
        result = paths?.filter { $0.hasSuffix(templateExtension) }.map { file -> String in
            var copy = file
            copy.removeLast(templateExtension.count)
            return copy
        }
    }
    return result ?? []
}()

struct UnmanagedData: ParsableCommand {
    @Argument(help: "Path to model XML or .xcdatamodel", transform: URL.init(fileURLWithPath:))
    var pathToFile: URL
    
    @Argument(help: "Generated models output folder", transform: URL.init(fileURLWithPath:))
    var outputFolder: URL
    
    @Flag(help: "Replace folder content (remove all folder content)")
    var replace = false
    
    @Option(name: .customLong("generate"), parsing: .next, help: "Generate code for \(templates.joined(separator: "|"))")
    var templateName: String = "Block"
    
    @Option(name: .customLong("prefix"), parsing: .next, help: "Generated entity name prefix")
    var namePrefix: String = ""
    
    @Option(name: .customLong("suffix"), parsing: .next, help: "Generated entity name suffix")
    var nameSuffix: String = ""
    
    @Option(name: .customLong("access"), parsing: .next, help: "Generate code access modifier public|open|internal")
    var accessModifier: String = "public"
    private var nonClassAccessModifier: String {
        if accessModifier == "open" {
           return "public"
        } else {
            return accessModifier
        }
    }
    
    @Option(name: .customLong("module"), parsing: .next, help: "Managed objects module name")
    var module: String?
    
    private var modelXMLURL: URL {
        if pathToFile.pathExtension == "xcdatamodel" {
            return pathToFile.appendingPathComponent("contents")
        } else {
            return pathToFile
        }
    }

    private func template() throws -> Stencil.Template {
        let templatesPath = Path(templatesURL.path)
        let environment = Environment(loader: FileSystemLoader(paths: [templatesPath]))
        return try environment.loadTemplate(name: templateName + ".stencil")
    }
    
    mutating func validate() throws {
        guard FileManager.default.fileExists(atPath: modelXMLURL.path) else {
            throw ValidationError("File does not exist at \(modelXMLURL.path)")
        }
        
        guard templatesURL != nil else {
            throw ValidationError("Could not find templates folder")
        }
        
        let templateName = self.templateName + templateExtension
        guard FileManager.default.fileExists(atPath: templatesURL.appendingPathComponent(templateName).path) else {
            throw ValidationError("Could not find template for '\(self.templateName)'")
        }
        
        guard ["public", "open", "internal"].contains(accessModifier) else {
            throw ValidationError("Invalid access modifier")
        }
    }

    mutating func run() throws {
        print(pathToFile.path)
        print(outputFolder.path)

        let template = try self.template()
       
        let isAcccessing = modelXMLURL.startAccessingSecurityScopedResource()
        let data = try Data(contentsOf: modelXMLURL)
        if isAcccessing { modelXMLURL.stopAccessingSecurityScopedResource() }
        
        let model = try XMLDecoder().decode(CoreData.Model.self, from: data)
        
        try createOutputFolderIfNeeded()
        if replace {
            try removeOutputFolderContent()
        }
        
        let namePrefix = self.namePrefix
        let nameSuffix = self.nameSuffix
        let mapper: StringMapper = { namePrefix + $0 + nameSuffix }
        
        let templatesData = model.templateModels(accessModifier: accessModifier, nonClassAccessModifier: nonClassAccessModifier, managedModelsModule: module, modelNameMappper: mapper)
        for context in templatesData {
            let result = try template.render(context.dictionary)
            let filePath = outputFolder.appendingPathComponent(context.entity.name).appendingPathExtension("swift").path

            do {
                print("Write model to \(filePath)")
                try result.write(toFile: filePath, atomically: true, encoding: .utf8)
            } catch {
                print("Failed to write file \(filePath) with error: \(error.localizedDescription)")
            }
        }
    }
    
    private func createOutputFolderIfNeeded() throws {
        if FileManager.default.fileExists(atPath: outputFolder.path) == false {
            print("Creating ... \(outputFolder.path)")
            try FileManager.default.createDirectory(atPath: outputFolder.path, withIntermediateDirectories: true)
        }
    }
    
    private func removeOutputFolderContent() throws {
        let paths = try FileManager.default.contentsOfDirectory(atPath: outputFolder.path)
        for path in paths {
            let itemUrl = outputFolder.appendingPathComponent(path)
            print("Removing ... \(itemUrl.path)")
            try FileManager.default.removeItem(at: itemUrl)
        }
    }
}

UnmanagedData.main()
