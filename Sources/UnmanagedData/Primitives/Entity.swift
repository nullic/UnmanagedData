import Foundation

final class Entity {
    var name: String
    var parentName: String?
    var className: String
    var parentClassName: String?
    var children: [Entity]
    var allChildren: [Entity]
    var isAbstract: Bool
    var codeGenerationType: CodeGenerationType?
    var attributes: [Attribute]
    var relationships: [Relationship]
    var fetchedProperties: [FetchedProperty]
    var allAttributes: [Attribute] = []
    var allRelationships: [Relationship] = []
    var allFetchedProperties: [FetchedProperty] = []
    var userInfo: UserInfo?
    
    init(name: String, parentName: String?, className: String, parentClassName: String? = nil, children: [Entity] = [], allChildren: [Entity] = [], isAbstract: Bool, codeGenerationType: CodeGenerationType?, attributes: [Attribute], relationships: [Relationship], fetchedProperties: [FetchedProperty], userInfo: UserInfo?) {
        self.name = name
        self.parentName = parentName
        self.className = className
        self.parentClassName = parentClassName
        self.children = children
        self.allChildren = allChildren
        self.codeGenerationType = codeGenerationType
        self.attributes = attributes
        self.relationships = relationships
        self.fetchedProperties = fetchedProperties
        self.userInfo = userInfo
        self.isAbstract = isAbstract
    }
}

extension Entity: Codable {
    enum DecodingKeys: String, CodingKey {
        case name
        case parentName = "parentEntity"
        case className = "representedClassName"
        case isAbstract
        case codeGenerationType
        case attributes = "attribute"
        case relationships = "relationship"
        case fetchedProperties = "fetchedProperty"
        case userInfo
    }
    
    enum EncodingKeys: String, CodingKey {
        case name
        case parentName
        case className
        case parentClassName
        case children
        case allChildren
        case isAbstract
        case codeGenerationType
        case attributes
        case relationships
        case fetchedProperties
        case allAttributes
        case allRelationships
        case allFetchedProperties
        case userInfo
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let parentName = try container.decodeIfPresent(String.self, forKey: .parentName)
        let className = try container.decode(String.self, forKey: .className)
        let isAbstract = try container.decodeIfPresent(Bool.self, forKey: .isAbstract)
        let codeGenerationType = try container.decodeIfPresent(CodeGenerationType.self, forKey: .codeGenerationType)
        let attributes = try container.decode([Attribute].self, forKey: .attributes)
        let relationships = try container.decode([Relationship].self, forKey: .relationships)
        let fetchedProperties = try container.decode([FetchedProperty].self, forKey: .fetchedProperties)
        let userInfo = try container.decodeIfPresent(UserInfo.self, forKey: .userInfo)
        
        self.init(name: name, parentName: parentName, className: className, isAbstract: isAbstract ?? false, codeGenerationType: codeGenerationType, attributes: attributes, relationships: relationships, fetchedProperties: fetchedProperties, userInfo: userInfo)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.parentName, forKey: .parentName)
        try container.encode(self.className, forKey: .className)
        try container.encodeIfPresent(self.parentClassName, forKey: .parentClassName)
        try container.encode(self.children, forKey: .children)
        try container.encode(self.allChildren, forKey: .allChildren)
        try container.encode(self.isAbstract, forKey: .isAbstract)
        try container.encodeIfPresent(self.codeGenerationType, forKey: .codeGenerationType)
        try container.encode(self.attributes, forKey: .attributes)
        try container.encode(self.relationships, forKey: .relationships)
        try container.encode(self.fetchedProperties, forKey: .fetchedProperties)
        try container.encode(self.allAttributes, forKey: .allAttributes)
        try container.encode(self.allRelationships, forKey: .allRelationships)
        try container.encode(self.allFetchedProperties, forKey: .allFetchedProperties)
        try container.encodeIfPresent(self.userInfo, forKey: .userInfo)
    }
}
