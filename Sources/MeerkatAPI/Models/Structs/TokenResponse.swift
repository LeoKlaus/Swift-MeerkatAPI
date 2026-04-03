//
//  TokenResponse.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 03.04.26.
//

import Foundation

public struct TokenResponse: Codable {
    public let id: Int
    public let name: String
    public let createdAt: Date
    public let lastUsedAt: Date?
    public let revokedAt: Date?
    public let token: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case createdAt = "created_at"
        case lastUsedAt = "last_used_at"
        case revokedAt = "revoked_at"
        case token = "token"
    }
}

