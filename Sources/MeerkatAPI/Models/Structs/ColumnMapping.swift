//
//  ColumnMapping.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Foundation

public struct ColumnMapping: Codable {
    public let csvColumn: String
    public let contactField: String
    
    enum CodingKeys: String, CodingKey {
        case csvColumn = "csv_column"
        case contactField = "contact_field"
    }
    
    public init(csvColumn: String, contactField: String) {
        self.csvColumn = csvColumn
        self.contactField = contactField
    }
}
