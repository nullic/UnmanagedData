import Foundation

struct Relationship: Codable {    
    let name: String
    let optional: Bool
    let maxCount: UInt
    let toMany: Bool
    let deletionRule: DeletionRule
    let ordered: Bool
    let destinationEntity: String
    let inverseName: String?
    let inverseEntity: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        optional = (try container.decodeIfPresent(BoolString.self, forKey: .optional))?.boolValue ?? false
        maxCount = try container.decodeIfPresent(UInt.self, forKey: .maxCount) ?? .max
        toMany = (try container.decodeIfPresent(BoolString.self, forKey: .toMany))?.boolValue ?? false
        deletionRule = try container.decode(DeletionRule.self, forKey: .deletionRule)
        ordered = (try container.decodeIfPresent(BoolString.self, forKey: .ordered))?.boolValue ?? false
        destinationEntity = try container.decode(String.self, forKey: .destinationEntity)
        inverseName = try container.decodeIfPresent(String.self, forKey: .inverseName)
        inverseEntity = try container.decodeIfPresent(String.self, forKey: .inverseEntity)
    }
}
