import Foundation

struct CoreDataModel {
    var type: String
    var documentVersion: String
    var entities: [Entity]
    var entitiesByName: [String: Entity]
}

extension CoreDataModel: Codable {
    enum DecodingKeys: String, CodingKey {
        case type
        case documentVersion
        case entities = "entity"
    }
    
    enum EnodingKeys: CodingKey {
        case type
        case documentVersion
        case entities
        case entitiesByName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        let entities = try container.decode([Entity].self, forKey: .entities)
        
        self.type = try container.decode(String.self, forKey: .type)
        self.documentVersion = try container.decode(String.self, forKey: .documentVersion)
        
        var entitiesByName: [String: Entity] = [:]
        for entity in entities {
            entitiesByName[entity.name] = entity
        }
        
        self.entities = entities
        self.entitiesByName = entitiesByName
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EnodingKeys.self)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.documentVersion, forKey: .documentVersion)
        try container.encode(self.entities, forKey: .entities)
        try container.encode(self.entitiesByName, forKey: .entitiesByName)
    }
    
    func populateMissingData() {
        for entity in entities {
            if let parentName = entity.parentName, let parent = entitiesByName[parentName] {
                entity.parentClassName = parent.className
                parent.children.append(entity)
            }
            
            for relation in entity.relationships {
                relation.destinationClassName = entitiesByName[relation.destinationEntity]?.className
                if let inverseEntity = relation.inverseEntity {
                    relation.inverseClassName = entities.first(where: { inverseEntity == $0.name })?.className
                }
            }
            
            for property in entity.fetchedProperties {
                property.fetchRequest.className = entitiesByName[property.fetchRequest.entity]?.className
            }
        }
        
        for entity in entities {
            entity.allAttributes = findAll(for: entity)
            entity.allRelationships = findAll(for: entity)
            entity.allFetchedProperties = findAll(for: entity)
            
            entity.allAttributes.forEach { entity.attributesByName[$0.name] = $0 }
            entity.allRelationships.forEach {entity.relationshipsByName[$0.name] = $0 }
            entity.allFetchedProperties.forEach { entity.fetchedPropertiesByName[$0.name] = $0 }
            
            entity.allChildren = findAllChildren(for: entity)
        }
    }
    
    private func findAllChildren(for entity: Entity) -> [Entity] {
        var result: [Entity] = entity.children
        for child in entity.children {
            result.append(contentsOf: findAllChildren(for: child))
        }
        return result
    }
    
    private func findAll(for entity: Entity) -> [Relationship] {
        var result: [Relationship] = entity.relationships
        if let parentName = entity.parentName, let parent = entitiesByName[parentName] {
            result.append(contentsOf: findAll(for: parent))
        }
        return result
    }
    
    private func findAll(for entity: Entity) -> [Attribute] {
        var result: [Attribute] = entity.attributes
        if let parentName = entity.parentName, let parent = entitiesByName[parentName] {
            result.append(contentsOf: findAll(for: parent))
        }
        return result
    }
    
    private func findAll(for entity: Entity) -> [FetchedProperty] {
        var result: [FetchedProperty] = entity.fetchedProperties
        if let parentName = entity.parentName, let parent = entitiesByName[parentName] {
            result.append(contentsOf: findAll(for: parent))
        }
        return result
    }
}
