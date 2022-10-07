import Foundation

struct Attribute {
    let name: String
    let isOptional: Bool
    let type: AttributeType
    let usesScalarValue: Bool?
    let defaultValue: String?
    let transformerName: String?
    let customClassName: String?
    
    var swiftType: String {
        let usesScalarValue = self.usesScalarValue ?? false

        switch type {
        case .date: return "Date"
        case .int16: return usesScalarValue ? "Int16" : "NSNumber"
        case .int32: return usesScalarValue ? "Int32" : "NSNumber"
        case .int64: return usesScalarValue ? "Int64" : "NSNumber"
        case .double: return usesScalarValue ? "Double" : "NSNumber"
        case .string: return "String"
        case .bool: return usesScalarValue ? "Bool" : "NSNumber"
        case .uri: return "URL"
        case .transformable: return customClassName ?? "InvalidAttributeDeclaration"
        }
    }
}

extension Attribute: Codable {
    enum DecodingKeys: String, CodingKey {
        case name
        case isOptional = "optional"
        case type = "attributeType"
        case usesScalarValue = "usesScalarValueType"
        case defaultValue = "defaultValueString"
        case transformerName = "valueTransformerName"
        case customClassName
    }
    
    enum EncodingKeys: CodingKey {
        case name
        case isOptional
        case type
        case usesScalarValue
        case defaultValue
        case transformerName
        case customClassName
        case swiftType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        isOptional = (try container.decodeIfPresent(BoolString.self, forKey: .isOptional))?.boolValue ?? false
        type = try container.decode(AttributeType.self, forKey: .type)
        usesScalarValue = (try container.decodeIfPresent(BoolString.self, forKey: .usesScalarValue))?.boolValue
        defaultValue = try container.decodeIfPresent(String.self, forKey: .defaultValue)
        transformerName = try container.decodeIfPresent(String.self, forKey: .transformerName)
        customClassName = try container.decodeIfPresent(String.self, forKey: .customClassName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.isOptional, forKey: .isOptional)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.swiftType, forKey: .swiftType)
        try container.encodeIfPresent(self.usesScalarValue, forKey: .usesScalarValue)
        try container.encodeIfPresent(self.defaultValue, forKey: .defaultValue)
        try container.encodeIfPresent(self.transformerName, forKey: .transformerName)
        try container.encodeIfPresent(self.customClassName, forKey: .customClassName)
    }
}
