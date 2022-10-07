import Foundation

struct CoreDataModel {
    let type: String
    let documentVersion: String
    let entities: [Entity]
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
}
