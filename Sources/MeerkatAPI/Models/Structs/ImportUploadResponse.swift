//
//  ImportUploadResponse.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Foundation

public struct ImportUploadResponse: Codable {
    public let sessionID: String
    public let headers: [String]
    public let suggestedMappings: [ColumnMapping]
    public let rowCount: Int
    public let sampleData: [[String]]
    
    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case headers
        case suggestedMappings = "suggested_mappings"
        case rowCount = "row_count"
        case sampleData = "sample_data"
    }
}
