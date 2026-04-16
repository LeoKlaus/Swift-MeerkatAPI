//
//  Activity.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Foundation

public struct Activity: Codable, Hashable, Identifiable, TimelineEntry {
    public let id: Int
    public let createdAt: Date
    public let updatedAt: Date?
    public let deletedAt: Date?
    public var title: String
    public var description: String?
    public var location: String?
    public var date: Date
    public var contacts: [Contact]?
    
    public let uuid = UUID()
    public var time: Date? {
        self.date
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case deletedAt = "DeletedAt"
        case title
        case description
        case location
        case date
        case contacts
    }
    
    enum EncodingKeys: String, CodingKey {
        case title
        case description
        case location
        case date
        case contactIds = "contact_ids"
    }
    
    public init(
        id: Int,
        createdAt: Date,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil,
        title: String,
        description: String? = nil,
        location: String? = nil,
        date: Date,
        contacts: [Contact]? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.title = title
        self.description = description
        self.location = location
        self.date = date
        self.contacts = contacts
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.description, forKey: .description)
        try container.encode(self.location, forKey: .location)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.contacts?.map(\.id), forKey: .contactIds)
    }
}
