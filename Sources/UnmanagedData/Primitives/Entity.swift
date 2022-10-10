import Foundation

final class Entity {
    var name: String
    var parentName: String?
    var className: String
    var codeGenerationType: CodeGenerationType?
    var attributes: [Attribute]
    var relationships: [Relationship]
    var fetchedProperties: [FetchedProperty]
    
    init(name: String, parentName: String?, className: String, codeGenerationType: CodeGenerationType?, attributes: [Attribute], relationships: [Relationship], fetchedProperties: [FetchedProperty]) {
        self.name = name
        self.parentName = parentName
        self.className = className
        self.codeGenerationType = codeGenerationType
        self.attributes = attributes
        self.relationships = relationships
        self.fetchedProperties = fetchedProperties
    }
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
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let parentName = try container.decodeIfPresent(String.self, forKey: .parentName)
        let className = try container.decode(String.self, forKey: .className)
        let codeGenerationType = try container.decodeIfPresent(CodeGenerationType.self, forKey: .codeGenerationType)
        let attributes = try container.decode([Attribute].self, forKey: .attributes)
        let relationships = try container.decode([Relationship].self, forKey: .relationships)
        let fetchedProperties = try container.decode([FetchedProperty].self, forKey: .fetchedProperties)
        
        self.init(name: name, parentName: parentName, className: className, codeGenerationType: codeGenerationType, attributes: attributes, relationships: relationships, fetchedProperties: fetchedProperties)
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