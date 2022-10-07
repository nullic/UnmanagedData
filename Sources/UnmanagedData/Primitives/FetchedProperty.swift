import Foundation

struct FetchedProperty: Codable {
    let name: String
    let optional: Bool
    let fetchRequest: FetchRequest
}

struct FetchRequest: Codable {
    let name: String
    let entity: String
}
