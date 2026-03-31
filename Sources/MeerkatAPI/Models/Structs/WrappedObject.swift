//
//  WrappedObject.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 31.03.26.
//

import Foundation

public struct WrappedObject<T: Codable>: Decodable {
    let result: T
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case message
    }
    
    struct DynamicKey: CodingKey {
        var stringValue: String
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let dynamicKeysContainer = try decoder.container(keyedBy: DynamicKey.self)
        var result: T?
        try dynamicKeysContainer.allKeys.forEach { key in
            switch key.stringValue {
            case "contact", "relationship":
                result = try dynamicKeysContainer.decode(T.self, forKey: key)
            default: break
            }
        }
        guard let result else {
            throw DecodingError.valueNotFound(T.self, .init(codingPath: [DynamicKey(stringValue: "results")], debugDescription: "Missing object in wrapped response"))
        }
        self.result = result
        
        let container: KeyedDecodingContainer<WrappedObject<T>.CodingKeys> = try decoder.container(keyedBy: WrappedObject<T>.CodingKeys.self)
        
        self.message = try container.decodeIfPresent(String.self, forKey: WrappedObject<T>.CodingKeys.message)
    }
    
    public init(result: T, message: String? = nil) {
        self.result = result
        self.message = message
    }
}
