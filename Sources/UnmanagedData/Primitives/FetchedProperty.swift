import Foundation

final class FetchedProperty {
    var name: String
    var isOptional: Bool
    var fetchRequest: FetchRequest
    
    init(name: String, optional: Bool, fetchRequest: FetchRequest) {
        self.name = name
        self.isOptional = optional
        self.fetchRequest = fetchRequest
    }
}

extension FetchedProperty: Codable {
    enum DecodingKeys: CodingKey {
        case name
        case optional
        case fetchRequest
    }
    
    enum EncodingKeys: CodingKey {
        case name
        case isOptional
        case fetchRequest
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let isOptional = try container.decode(Bool.self, forKey: .optional)
        let fetchRequest = try container.decode(FetchRequest.self, forKey: .fetchRequest)
        
        self.init(name: name, optional: isOptional, fetchRequest: fetchRequest)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.isOptional, forKey: .isOptional)
        try container.encode(self.fetchRequest, forKey: .fetchRequest)
    }
}

final class FetchRequest: Codable {
    var name: String
    var entity: String
    var className: String?
    var predicateString: String?
    
    init(name: String, entity: String, className: String? = nil, predicateString: String?) {
        self.name = name
        self.entity = entity
        self.className = className
        self.predicateString = predicateString
    }
}
