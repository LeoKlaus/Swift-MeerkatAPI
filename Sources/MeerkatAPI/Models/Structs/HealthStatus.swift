//
//  HealthStatus.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 29.03.26.
//

import Foundation

public enum Healthiness: Codable, RawRepresentable {
    case healthy
    case unhealthy
    case unknown(status: String)
    
    public var rawValue: String {
        switch self {
        case .healthy:
            return "healthy"
        case .unhealthy:
            return "unhealthy"
        case .unknown(let status):
            return status
        }
    }
    
    public init(rawValue: String) {
        switch rawValue {
        case "healthy":
            self = .healthy
        case "unhealthy":
            self = .unhealthy
        default:
            self = .unknown(status: rawValue)
        }
    }
}

public struct HealthStatus: Codable {
    public let status: Healthiness
    public let timestamp: Date
    public let database: DatabaseHealthStatus
    public let version: String
    
    public init(status: Healthiness, timestamp: Date, database: DatabaseHealthStatus, version: String) {
        self.status = status
        self.timestamp = timestamp
        self.database = database
        self.version = version
    }
}

public struct DatabaseHealthStatus: Codable {
    public let status: Healthiness
    public let responseTimeMs: Int
    
    enum CodingKeys: String, CodingKey {
        case status
        case responseTimeMs = "response_time_ms"
    }
    
    public init(status: Healthiness, responseTimeMs: Int) {
        self.status = status
        self.responseTimeMs = responseTimeMs
    }
}
