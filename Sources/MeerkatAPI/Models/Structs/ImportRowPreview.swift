//
//  ImportRowPreview.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Foundation

public struct ImportRowPreview: Codable {
    public let rowIndex: Int
    public let parsedContact: [String:String]
    public let validationErrors: [String]
    public let duplicateMatch: DuplicateMatch?
    public let suggestedAction: ImportSuggestedAction
    
    enum CodingKeys: String, CodingKey {
        case rowIndex = "row_index"
        case parsedContact = "parsed_contact"
        case validationErrors = "validation_errors"
        case duplicateMatch = "duplicate_match"
        case suggestedAction = "suggested_action"
    }
}
