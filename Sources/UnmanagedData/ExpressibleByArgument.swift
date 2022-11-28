import ArgumentParser
import PathKit

extension Path: ExpressibleByArgument, Decodable {
  public init?(argument: String) {
    self.init(argument)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let decodedString = try container.decode(String.self)
    self.init(decodedString)
  }
}
