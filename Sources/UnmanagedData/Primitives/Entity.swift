import Foundation

struct Entity {
    let name: String
    let parentName: String?
    let className: String
    let codeGenerationType: CodeGenerationType?
    let attributes: [Attribute]
    let relationships: [Relationship]
    let fetchedProperties: [FetchedProperty]
}

extension Entity: Codable {
    enum DecodingKeys: String, CodingKey {
        case name
        case parentName = "parentEntity"
        case className = "representedClassName"
        case codeGenerationType
        case attributes = "attribute"
        case relationships = "relationship"
        case fetchedProperties = "fetchedProperty"
    }
    
    enum EncodingKeys: String, CodingKey {
        case name
        case parentName
        case className
        case codeGenerationType
        case attributes
        case relationships
        case fetchedProperties
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.parentName = try container.decodeIfPresent(String.self, forKey: .parentName)
        self.className = try container.decode(String.self, forKey: .className)
        self.codeGenerationType = try container.decodeIfPresent(CodeGenerationType.self, forKey: .codeGenerationType)
        self.attributes = try container.decode([Attribute].self, forKey: .attributes)
        self.relationships = try container.decode([Relationship].self, forKey: .relationships)
        self.fetchedProperties = try container.decode([FetchedProperty].self, forKey: .fetchedProperties)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.parentName, forKey: .parentName)
        try container.encode(self.className, forKey: .className)
        try container.encodeIfPresent(self.codeGenerationType, forKey: .codeGenerationType)
        try container.encode(self.attributes, forKey: .attributes)
        try container.encode(self.relationships, forKey: .relationships)
        try container.encode(self.fetchedProperties, forKey: .fetchedProperties)
    }
}
