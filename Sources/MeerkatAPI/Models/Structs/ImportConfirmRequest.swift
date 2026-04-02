//
//  ImportConfirmRequest.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Foundation

public struct ImportConfirmRequest: Codable {
    public let sessionID: String
    public let actions: [RowImportAction]
    
    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case actions
    }
    
    public init(sessionID: String, actions: [RowImportAction]) {
        self.sessionID = sessionID
        self.actions = actions
    }
}
