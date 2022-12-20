import Foundation

struct UserInfo {
    struct Entry: Codable {
        let key: String
        let value: String
    }
    
    let entries: [Entry]
}

extension UserInfo: Codable {
    enum DecodingKeys: CodingKey {
        case entry
    }
    
    enum EncodingKeys: CodingKey {
        case record(String)
        
        init?(stringValue: String) {  self = .record(stringValue) }
        var stringValue: String {
            switch self {
            case .record(let key): return key
            }
        }
        
        var intValue: Int? { nil }
        init?(intValue: Int) { return nil }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        self.entries = try container.decode([Entry].self, forKey: .entry)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        for entry in entries {
            try container.encode(entry.value, forKey: .record(entry.key))
        }
    }
}
