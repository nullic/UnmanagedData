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
                entity.parentClassName = entities.first(where: { parentName == $0.name })?.className
            }
            
            for relation in entity.relationships {
                relation.destinationClassName = entities.first(where: { relation.destinationEntity == $0.name })?.className
                if let inverseEntity = relation.inverseEntity {
                    relation.inverseClassName = entities.first(where: { inverseEntity == $0.name })?.className
                }
            }
            
            for property in entity.fetchedProperties {
                property.fetchRequest.className = entities.first(where: { property.fetchRequest.entity == $0.name })?.className
            }
        }
    }
}
