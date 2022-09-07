import Foundation

typealias StringMapper = (String) -> String

struct ConvertModelContext {
    let allEntities: [CoreData.Entity]
    let modelNameMappper: StringMapper
    let module: String?
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension CoreData.Model {
    func templateModels(accessModifier: String, nonClassAccessModifier: String, managedModelsModule module: String?, modelNameMappper: @escaping StringMapper) -> [Template.Model] {
        let context = ConvertModelContext(allEntities: entities, modelNameMappper: modelNameMappper, module: module)

        return entities.map { entity -> Template.Model in
            let entity = entity.templateEntity(context: context)
            return Template.Model(accessModifier: accessModifier, nonClassAccessModifier: nonClassAccessModifier, entity: entity, importModule: module)
        }
    }
}

extension CoreData.Entity {
    func templateEntity(context: ConvertModelContext) -> Template.Entity {
        let attributes = self.attributes.map { $0.templateAttribute(context: context) }
        let relationships = self.relationships.map { $0.templateAttribute(context: context) }
        let fetchedProperties = self.fetchedProperties.map { $0.templateAttribute(context: context) }
        let managedName = context.module != nil ? (context.module! + "." + self.representedClassName) : self.representedClassName
        
        var parentName: String?
        if let parentEntity = parentEntity, let parent = context.allEntities.first(where: { $0.name == parentEntity }) {
            parentName = context.modelNameMappper(parent.name)
        }
        
        return Template.Entity(name: context.modelNameMappper(name), parentName: parentName, managedName: managedName,
                               attributes: attributes,
                               relationships: relationships,
                               fetchedProperties: fetchedProperties)
    }
}

extension CoreData.Attribute {
    func templateAttribute(context: ConvertModelContext) -> Template.Attribute {
        let usesScalarValueType = self.usesScalarValueType ?? false
        let type = (attributeType.scalarTypeString ?? customClassName!) + (optional ? "?" : "")
        let managedType = attributeType.managedTypeString(usesScalarValueType: usesScalarValueType, isOptional: optional) ?? (customClassName! + (optional ? "?" : ""))
        let unwrapTransform = attributeType.unwrapTransform(usesScalarValueType: usesScalarValueType, isOptional: optional)
        return Template.Attribute(name: name, type: type, managedType: managedType, unwrapTransform: unwrapTransform, isOptional: optional)
    }
}

extension CoreData.Relationship {
    func templateAttribute(context: ConvertModelContext) -> Template.Relationship {
        let instanceType = context.modelNameMappper(destinationEntity)
        var objectType = context.allEntities.first(where: { $0.name == destinationEntity })!.representedClassName
        objectType = context.module != nil ? (context.module! + "." + objectType) : objectType
        
        let toOne = maxCount == 1
        let type = (toOne ? instanceType : "[\(instanceType)]") + (optional ? "?" : "")
        let managedType = (toOne ? instanceType : (ordered ? "NSOrderedSet" : "NSSet")) + (optional ? "?" : "!")
        
        let unwrapTransform: String?
        if optional && toOne {
            unwrapTransform = nil
        } else if !optional && toOne {
            unwrapTransform = "!"
        } else if optional && !toOne {
            unwrapTransform = "?.\(ordered ? "array" : "allObjects") as? [\(objectType)]"
        } else {// if !optional && !isToOne {
            unwrapTransform = "?..\(ordered ? "array" : "allObjects") as! [\(objectType)]"
        }
        
        return Template.Relationship(name: name, capitalizedName: name.capitalizingFirstLetter(), type: type, managedType: managedType, relationshipType: instanceType, unwrapTransform: unwrapTransform, instanceType: instanceType, isSet: !toOne, isOrdered: ordered, isOptional: optional)
    }
}

extension CoreData.FetchedProperty {
    func templateAttribute(context: ConvertModelContext) -> Template.Relationship {
        let instanceType = context.modelNameMappper(fetchRequest.entity)
        var objectType = context.allEntities.first(where: { $0.name == fetchRequest.entity })!.representedClassName
        objectType = context.module != nil ? (context.module! + "." + objectType) : objectType
        
        let type = "[\(instanceType)]" + (optional ? "?" : "")
        let unwrapTransform = optional ? " as? [\(objectType)]" : " as! [\(objectType)]"
        
        return Template.Relationship(name: name, capitalizedName: name.capitalizingFirstLetter(), type: type, managedType: type, relationshipType: instanceType, unwrapTransform: unwrapTransform, instanceType: instanceType, isSet: true, isOrdered: false, isOptional: optional)
    }
}

extension CoreData.AttributeType {
    var scalarTypeString: String? {
        switch self {
        case .date: return "Date"
        case .int16: return "Int16"
        case .int32: return "Int32"
        case .int64: return "Int64"
        case .double: return "Double"
        case .string: return "String"
        case .bool: return "Bool"
        case .uri: return "URL"
        case .transformable: return nil
        }
    }
    
    func managedTypeString(usesScalarValueType: Bool, isOptional: Bool) -> String? {
        if !usesScalarValueType {
            switch self {
            case .int16, .int32, .int64, .double, .bool: return "NSNumber" + (isOptional ? "?" : "!")
            default: break
            }
        }
        
        guard let unwrapedType = scalarTypeString else { return nil }
        
        switch self {
        case .int16, .int32, .int64, .double, .bool:
            return unwrapedType
        case .date, .string, .uri:
            return unwrapedType + (isOptional ? "?" : "!")
        case .transformable:
            return nil
        }
    }
    
    func unwrapTransform(usesScalarValueType: Bool, isOptional: Bool) -> String? {
        let unwrap = isOptional ? "?" : "!"
        let unwrapIfNeeded = isOptional ? nil : "!"
        
        switch self {
        case .date: return unwrapIfNeeded
        case .int16: return usesScalarValueType ? nil : "\(unwrap).int16Value"
        case .int32: return usesScalarValueType ? nil : "\(unwrap).int32Value"
        case .int64: return usesScalarValueType ? nil : "\(unwrap).int64Value"
        case .double: return usesScalarValueType ? nil : "\(unwrap).doubleValue"
        case .string: return unwrapIfNeeded
        case .bool: return usesScalarValueType ? nil : "\(unwrap).booleanValue"
        case .uri: return unwrapIfNeeded
        case .transformable: return unwrapIfNeeded
        }
    }
}
