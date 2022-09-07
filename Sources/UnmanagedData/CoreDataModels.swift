import Foundation
import CoreData

struct CoreData {
    struct Model: Codable {
        enum CodingKeys: String, CodingKey {
            case type
            case documentVersion
            case entities = "entity"
        }
        
        let type: String
        let documentVersion: String
        let entities: [Entity]
    }
    
    struct Entity: Codable {
        enum CodingKeys: String, CodingKey {
            case name
            case parentEntity
            case representedClassName
            case codeGenerationType
            case attributes = "attribute"
            case relationships = "relationship"
            case fetchedProperties = "fetchedProperty"
        }
        
        let name: String
        let parentEntity: String?
        let representedClassName: String
        let codeGenerationType: CodeGenerationType?
        let attributes: [Attribute]
        let relationships: [Relationship]
        let fetchedProperties: [FetchedProperty]
    }
    
    struct Attribute: Codable {
        let name: String
        let optional: Bool
        let attributeType: AttributeType
        let usesScalarValueType: Bool?
        let defaultValueString: String?
        let valueTransformerName: String?
        let customClassName: String?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            name = try container.decode(String.self, forKey: .name)
            optional = (try container.decodeIfPresent(BoolString.self, forKey: .optional))?.boolValue ?? false
            attributeType = try container.decode(AttributeType.self, forKey: .attributeType)
            usesScalarValueType = (try container.decodeIfPresent(BoolString.self, forKey: .usesScalarValueType))?.boolValue
            defaultValueString = try container.decodeIfPresent(String.self, forKey: .defaultValueString)
            valueTransformerName = try container.decodeIfPresent(String.self, forKey: .valueTransformerName)
            customClassName = try container.decodeIfPresent(String.self, forKey: .customClassName)
        }
    }
    
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
    
    struct FetchedProperty: Codable {
        let name: String
        let optional: Bool
        let fetchRequest: FetchRequest
    }
    
    struct FetchRequest: Codable {
        let name: String
        let entity: String
    }
    
    // MARK: -
    
    enum CodeGenerationType: String, Codable  {
        case `class` = "class"
    }
    
    enum BoolString: String, Codable {
        case yes = "YES"
        case no = "NO"
        
        var boolValue: Bool {
            switch self {
            case .yes:  return true
            case .no:  return false
            }
        }
    }
    
    enum AttributeType: String, Codable {
        case date = "Date"
        case int16 = "Integer 16"
        case int32 = "Integer 32"
        case int64 = "Integer 64"
        case double = "Double"
        case string = "String"
        case bool = "Boolean"
        case uri = "URI"
        case transformable = "Transformable"
    }
    
    enum DeletionRule: String, Codable {
        case nullify = "Nullify"
        case cascade = "Cascade"
    }
}
