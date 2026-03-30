//
//  CustomFields.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Foundation

public struct CustomFields: Codable {
    public let customFieldNames: [String]
    
    enum CodingKeys: String, CodingKey {
        case customFieldNames = "custom_field_names"
    }
    
    enum EncodingKeys: String, CodingKey {
        case customFieldNames = "Names"
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(self.customFieldNames, forKey: .customFieldNames)
    }
}
