import Foundation
import XMLCoder
import ArgumentParser
import Stencil
import PathKit
import MoreCodable
import StencilSwiftKit

private enum Version {
  static let unmanageddata = "2.0.0"
  static let stencil = "0.15.1"
  static let stencilSwiftKit = "2.10.1"
}

struct UnmanagedData: ParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "umd",
      abstract: "A utility for generating code.",
      version: version,
      subcommands: [
        Run.self,
        Config.self,
      ],
      defaultSubcommand: Run.self
    )
    
    private static let version = """
      UnmanagedData v\(Version.unmanageddata) (\
      Stencil v\(Version.stencil), \
      StencilSwiftKit v\(Version.stencilSwiftKit)
      """
}

// MARK: -

print("UnmanagedData: Running ...")
UnmanagedData.main()
print("UnmanagedData: Finished")
