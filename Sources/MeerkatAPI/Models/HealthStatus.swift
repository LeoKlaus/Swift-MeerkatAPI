//
//  HealthStatus.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 29.03.26.
//

import Foundation

public struct HealthStatus: Codable {
    public let status: String
    public let timestamp: Date
    public let database: DatabaseHealthStatus
    public let version: String
}

public struct DatabaseHealthStatus: Codable {
    public let status: String
    public let responseTimeMs: Int
    
    enum CodingKeys: String, CodingKey {
        case status
        case responseTimeMs = "response_time_ms"
    }
}
