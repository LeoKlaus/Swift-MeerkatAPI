//
//  RowImportAction.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Foundation

public struct RowImportAction: Codable {
    public let rowIndex: Int
    public let action: ImportSuggestedAction
    
    enum CodingKeys: String, CodingKey {
        case rowIndex = "row_index"
        case action = "action"
    }
}
