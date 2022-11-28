import Foundation
import ArgumentParser
import PathKit

struct Config: ParsableCommand {
    @Argument(
      help: "Path to the configuration file to use",
      completion: .file(extensions: ["yml"])
    )
    var file: Path = "umd.yml"
    
    func validateExists() throws {
        if !file.isFile {
            throw ValidationError("`\(file)` is not a config file")
        }
    }
    
    func run() throws {
        print("UnmanagedData: Will execute 'config' command")
        var config = try RunnableConfig(file: file)
        try config.run()
    }
}
