//
//  ImportPreviewRequest.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Foundation

public struct ImportPreviewRequest: Codable {
    public let sessionID: String
    public let mappings: [ColumnMapping]
    
    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case mappings
    }
    
    public init(sessionID: String, mappings: [ColumnMapping]) {
        self.sessionID = sessionID
        self.mappings = mappings
    }
}
