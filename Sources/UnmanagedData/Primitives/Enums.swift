import Foundation

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
    case decimal = "Decimal"
    case float = "Float"
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
