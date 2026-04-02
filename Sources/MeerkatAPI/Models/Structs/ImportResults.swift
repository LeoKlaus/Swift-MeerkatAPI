//
//  ImportResults.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Foundation

public struct ImportResult: Codable {
    public let totalProcessed: Int
    public let created: Int
    public let updated: Int
    public let skipped: Int
    public let errors: [String]
    
    enum CodingKeys: String, CodingKey {
        case totalProcessed = "total_processed"
        case created = "created"
        case updated = "updated"
        case skipped = "skipped"
        case errors = "errors"
    }
}
