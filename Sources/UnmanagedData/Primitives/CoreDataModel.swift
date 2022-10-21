import Foundation

struct CoreDataModel {
    var type: String
    var documentVersion: String
    var entities: [Entity]
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
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.documentVersion = try container.decode(String.self, forKey: .documentVersion)
        self.entities = try container.decode([Entity].self, forKey: .entities)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EnodingKeys.self)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.documentVersion, forKey: .documentVersion)
        try container.encode(self.entities, forKey: .entities)
    }
    
    func populateMissingData() {
        for entity in entities {
            if let parentName = entity.parentName {
                entity.parentClassName = findEntity(name: parentName)?.className
            }
            
            for relation in entity.relationships {
                relation.destinationClassName = findEntity(name: relation.destinationEntity)?.className
                if let inverseEntity = relation.inverseEntity {
                    relation.inverseClassName = entities.first(where: { inverseEntity == $0.name })?.className
                }
            }
            
            for property in entity.fetchedProperties {
                property.fetchRequest.className = findEntity(name: property.fetchRequest.entity)?.className
            }
            
            entity.allAttributes = findAll(for: entity)
            entity.allRelationships = findAll(for: entity)
            entity.allFetchedProperties = findAll(for: entity)
        }
    }
    
    private func findEntity(name: String) -> Entity? {
        entities.first(where: { name == $0.name })
    }
    
    private func findAll(for entity: Entity) -> [Relationship] {
        var result: [Relationship] = entity.relationships
        if let parentName = entity.parentName, let parent = findEntity(name: parentName) {
            result.append(contentsOf: findAll(for: parent))
        }
        return result
    }
    
    private func findAll(for entity: Entity) -> [Attribute] {
        var result: [Attribute] = entity.attributes
        if let parentName = entity.parentName, let parent = findEntity(name: parentName) {
            result.append(contentsOf: findAll(for: parent))
        }
        return result
    }
    
    private func findAll(for entity: Entity) -> [FetchedProperty] {
        var result: [FetchedProperty] = entity.fetchedProperties
        if let parentName = entity.parentName, let parent = findEntity(name: parentName) {
            result.append(contentsOf: findAll(for: parent))
        }
        return result
    }
}
