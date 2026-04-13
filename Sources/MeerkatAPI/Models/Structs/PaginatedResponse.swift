//
//  PaginatedResponse.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 29.03.26.
//

import Foundation

public struct PaginatedResponse<T: Codable>: Decodable {
    public let results: [T]
    public let limit: Int?
    public let page: Int?
    public let total: Int?
    public let totalPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case total
        case page
        case limit
        case totalPages = "total_pages"
    }
    
    struct DynamicKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let dynamicKeysContainer = try decoder.container(keyedBy: DynamicKey.self)
        var results: [T] = []
        try dynamicKeysContainer.allKeys.forEach { key in
            switch key.stringValue {
            case "activities", "birthdays", "completions", "contacts", "notes", "relationships", "incoming_relationships", "reminders", "users", "tokens":
                results = try dynamicKeysContainer.decodeIfPresent([T].self, forKey: key) ?? []
            default: break
            }
        }
        self.results = results
        
        let container: KeyedDecodingContainer<PaginatedResponse<T>.CodingKeys> = try decoder.container(keyedBy: PaginatedResponse<T>.CodingKeys.self)
        
        self.limit = try container.decodeIfPresent(Int.self, forKey: PaginatedResponse<T>.CodingKeys.limit)
        self.page = try container.decodeIfPresent(Int.self, forKey: PaginatedResponse<T>.CodingKeys.page)
        self.total = try container.decodeIfPresent(Int.self, forKey: PaginatedResponse<T>.CodingKeys.total)
        self.totalPages = try container.decodeIfPresent(Int.self, forKey: PaginatedResponse<T>.CodingKeys.totalPages)
    }
    
    public init(results: [T], limit: Int?, page: Int?, total: Int?, totalPages: Int?) {
        self.results = results
        self.limit = limit
        self.page = page
        self.total = total
        self.totalPages = totalPages
    }
}
