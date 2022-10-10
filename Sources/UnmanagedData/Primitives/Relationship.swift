import Foundation

final class Relationship {
    var name: String
    var isOptional: Bool
    var maxCount: UInt
    var toMany: Bool
    var deletionRule: DeletionRule
    var isOrdered: Bool
    var destinationEntity: String
    var destinationClassName: String?
    var inverseName: String?
    var inverseEntity: String?
    var inverseClassName: String?
    
    var swiftType: String {
        let destination = destinationClassName ?? destinationEntity
        if toMany {
            return isOrdered ? "NSOrderedSet" : "NSSet"
        } else {
            return destination
        }
    }
    
    init(name: String, isOptional: Bool, maxCount: UInt, toMany: Bool, deletionRule: DeletionRule, isOrdered: Bool, destinationEntity: String, destinationClassName: String?, inverseName: String?, inverseEntity: String?, inverseClassName: String?) {
        self.name = name
        self.isOptional = isOptional
        self.maxCount = maxCount
        self.toMany = toMany
        self.deletionRule = deletionRule
        self.isOrdered = isOrdered
        self.destinationEntity = destinationEntity
        self.destinationClassName = destinationClassName
        self.inverseName = inverseName
        self.inverseEntity = inverseEntity
    }
}

extension Relationship: Codable {
    enum DecodingKeys: CodingKey {
        case name
        case optional
        case maxCount
        case toMany
        case deletionRule
        case ordered
        case destinationEntity
        case destinationClassName
        case inverseName
        case inverseEntity
    }
    
    enum EncodingKeys: CodingKey {
        case name
        case isOptional
        case maxCount
        case toMany
        case deletionRule
        case isOrdered
        case destinationEntity
        case destinationClassName
        case inverseName
        case inverseEntity
        case inverseClassName
        case swiftType
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        
        let name = try container.decode(String.self, forKey: .name)
        let optional = (try container.decodeIfPresent(BoolString.self, forKey: .optional))?.boolValue ?? false
        let maxCount = try container.decodeIfPresent(UInt.self, forKey: .maxCount) ?? .max
        let toMany = (try container.decodeIfPresent(BoolString.self, forKey: .toMany))?.boolValue ?? false
        let deletionRule = try container.decode(DeletionRule.self, forKey: .deletionRule)
        let ordered = (try container.decodeIfPresent(BoolString.self, forKey: .ordered))?.boolValue ?? false
        let destinationEntity = try container.decode(String.self, forKey: .destinationEntity)
        let inverseName = try container.decodeIfPresent(String.self, forKey: .inverseName)
        let inverseEntity = try container.decodeIfPresent(String.self, forKey: .inverseEntity)
        
        self.init(name: name, isOptional: optional, maxCount: maxCount, toMany: toMany, deletionRule: deletionRule, isOrdered: ordered, destinationEntity: destinationEntity, destinationClassName: nil, inverseName: inverseName, inverseEntity: inverseEntity, inverseClassName: nil)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.isOptional, forKey: .isOptional)
        try container.encode(self.maxCount, forKey: .maxCount)
        try container.encode(self.toMany, forKey: .toMany)
        try container.encode(self.deletionRule, forKey: .deletionRule)
        try container.encode(self.isOrdered, forKey: .isOrdered)
        try container.encode(self.destinationEntity, forKey: .destinationEntity)
        try container.encodeIfPresent(self.destinationClassName, forKey: .destinationClassName)
        try container.encodeIfPresent(self.inverseName, forKey: .inverseName)
        try container.encodeIfPresent(self.inverseEntity, forKey: .inverseEntity)
        try container.encodeIfPresent(self.inverseClassName, forKey: .inverseClassName)
        
        try container.encode(self.swiftType, forKey: .swiftType)
    }
}
