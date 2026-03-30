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
}
