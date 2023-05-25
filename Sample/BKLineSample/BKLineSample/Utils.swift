//
//  Codable.swift
//
//  Created by tang on 14.7.21.
//

import Foundation

// MARK: - Default Value Annotation
public protocol CodableDefaultValue {
    associatedtype Value: Codable
    static var wrappedValue: Value { get }
}

@propertyWrapper public struct CodableDefault<T: CodableDefaultValue> {
    public var wrappedValue: T.Value
    public init() {
        self.wrappedValue = T.wrappedValue
    }
}

extension CodableDefault {
    public typealias True = CodableDefault<Bool.True>
    public typealias False = CodableDefault<Bool.False>
    public typealias EmptyString = CodableDefault<String.Empty>
    public typealias ZeroString = CodableDefault<String.Zero>
    public typealias ZeroDouble = CodableDefault<Double.Zero>
    public typealias ZeroDecimal = CodableDefault<Decimal.Zero>
}

extension Bool {
    public enum False: CodableDefaultValue {
        public static let wrappedValue = false
    }
    public enum True: CodableDefaultValue {
        public static let wrappedValue = true
    }
}

extension String {
    public enum Empty: CodableDefaultValue {
        public static let wrappedValue = ""
    }
    public enum Zero: CodableDefaultValue {
        public static let wrappedValue = "0"
    }
}

extension Double {
    public enum Zero: CodableDefaultValue {
        public static let wrappedValue = 0.0
    }
}

extension Decimal {
    public enum Zero: CodableDefaultValue {
        public static let wrappedValue = 0
    }
}

extension Int {
    public enum Zero: CodableDefaultValue {
        public static let wrappedValue = 0
    }
}

extension CodableDefault: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(T.Value.self)) ?? T.wrappedValue
    }
}

extension KeyedDecodingContainer {
//    func decode<T>( _ type: CodableDefault<T>.Type, forKey key: Key) throws -> CodableDefault<T> {
//        try decodeIfPresent(type, forKey: key) ?? CodableDefault(wrappedValue: T.wrappedValue)
//    }
    
    public func decodeIfPresent(_ type: Decimal.Type, forKey key: Key) -> Decimal? {
        guard let str = try? decode(String.self, forKey: key) else {
            return nil
        }
        return Decimal(string: str)
    }
}

// MARK: - Encode
public extension Encodable {
    func toJSONData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    func toJSONString() -> String? {
        guard let bytes = toJSONData() else {
            return nil
        }
        return String(bytes: bytes, encoding: .utf8)
    }
    
    func toJSON() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap {
            $0 as? [String: Any]
        } ?? [:]
    }
    
    func toJSON(returnSelfOnFailed: Bool) -> Any {
        guard let data = try? JSONEncoder().encode(self) else {
            if returnSelfOnFailed {
                return self
            }
            return [:]
        }
        let result = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
        return result ?? (returnSelfOnFailed ? self : [:])
    }
}

public extension Array {
    func listToJson() -> String? {
        var list: [Any]?
        if self is [Codable] {
            list = (self as! [Codable]).map{ $0.toJSON(returnSelfOnFailed: true) }
        } else {
            list = self
        }
        
        guard let list = list, JSONSerialization.isValidJSONObject(list) else {
            return nil
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: list, options: [.init(rawValue: 0)]),
            let JSONString = NSString(data:data, encoding: String.Encoding.utf8.rawValue) {
            return JSONString as String
        }
        return nil
    }
}

// MARK: - Decode
public extension Decodable {
    static func fromMap(JSONData: Data) -> Self? {
        do {
            let decorder = JSONDecoder()
            decorder.dateDecodingStrategy = .millisecondsSince1970
            return try decorder.decode(Self.self, from: JSONData)
        } catch let error {
            print("\(error)")
            return nil
        }
    }
    
    static func fromMap(JSONString: String) -> Self? {
        do {
            let decorder = JSONDecoder()
            decorder.dateDecodingStrategy = .millisecondsSince1970
            return try decorder.decode(Self.self, from: Data(JSONString.utf8))
        } catch let error {
            print("\(error)")
            return nil
        }
    }
    
    static func fromMap(JSONObject: Any) -> Self? {
        guard JSONSerialization.isValidJSONObject(JSONObject) else {
            print("JSONSerialization : Invalid JSON object")
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: JSONObject, options: .fragmentsAllowed) else {
            return nil
        }
        do {
            let decorder = JSONDecoder()
            decorder.dateDecodingStrategy = .millisecondsSince1970
            return try decorder.decode(Self.self, from: data)
        } catch let error {
            print("\(error)")
            return nil
        }
    }
}
