import Foundation

final class FetchedProperty: Codable {
    var name: String
    var optional: Bool
    var fetchRequest: FetchRequest
    
    init(name: String, optional: Bool, fetchRequest: FetchRequest) {
        self.name = name
        self.optional = optional
        self.fetchRequest = fetchRequest
    }
}

final class FetchRequest: Codable {
    var name: String
    var entity: String
    
    init(name: String, entity: String) {
        self.name = name
        self.entity = entity
    }
}
