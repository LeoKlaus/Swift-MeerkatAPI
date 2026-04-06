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
    public let title: String
    public let description: String?
    public let location: String?
    public let date: Date
    public let contacts: [Contact]?
    
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
}
