//
//  ImportPreviewResponse.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Foundation

public struct ImportPreviewResponse: Codable {
    public let sessionID: String
    public let rows: [ImportRowPreview]
    public let totalRows: Int
    public let validRows: Int
    public let duplicateCount: Int
    public let errorCount: Int
    
    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case rows = "rows"
        case totalRows = "total_rows"
        case validRows = "valid_rows"
        case duplicateCount = "duplicate_count"
        case errorCount = "error_count"
    }
}
