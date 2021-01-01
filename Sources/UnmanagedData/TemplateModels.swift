import Foundation

struct Template {
    struct Utils: Codable {
        let accessModifier: String
        let nonClassAccessModifier: String
        
        var dictionary: [String: Any] {
            let result: [String: Any] = ["accessModifier": accessModifier, "nonClassAccessModifier": nonClassAccessModifier]
            return result
        }
    }
    
    struct Model: Codable {
        let accessModifier: String
        let nonClassAccessModifier: String
        let entity: Entity
        let importModule: String?
        
        var dictionary: [String: Any] {
            var result: [String: Any] = ["accessModifier": accessModifier, "nonClassAccessModifier": nonClassAccessModifier, "entity": entity]
            result["import"] = importModule
            return result
        }
    }
    
    struct Entity: Codable {
        let name: String
        let parentName: String?
        let managedName: String
        let attributes: [Attribute]
        let relationships: [Relationship]
        let fetchedProperties: [Relationship]
    }
    
    struct Attribute: Codable {
        let name: String
        let type: String
        let unwrapTransform: String?
        
        let isOptional: Bool
    }
    
    struct Relationship: Codable {
        let name: String
        let type: String
        let unwrapTransform: String?
        
        let instanceType: String
        let isArray: Bool
        let isOptional: Bool
    }
}
