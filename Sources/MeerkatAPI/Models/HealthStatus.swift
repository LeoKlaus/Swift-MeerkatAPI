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
    
    public init(status: String, timestamp: Date, database: DatabaseHealthStatus, version: String) {
        self.status = status
        self.timestamp = timestamp
        self.database = database
        self.version = version
    }
}

public struct DatabaseHealthStatus: Codable {
    public let status: String
    public let responseTimeMs: Int
    
    enum CodingKeys: String, CodingKey {
        case status
        case responseTimeMs = "response_time_ms"
    }
    
    public init(status: String, responseTimeMs: Int) {
        self.status = status
        self.responseTimeMs = responseTimeMs
    }
}
