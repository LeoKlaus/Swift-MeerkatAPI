//
//  Note.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Foundation

public struct Note: Codable, Identifiable, Hashable, TimelineEntry {
    public let id: Int
    public let createdAt: Date
    public let updatedAt: Date?
    public let deletedAt: Date?
    public var content: String
    public var date: Date?
    public var contactId: Int?
    public var contact: Contact?
    
    public let uuid = UUID()
    public var time: Date? {
        self.date
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case deletedAt = "DeletedAt"
        case content = "content"
        case date = "date"
        case contactId = "contact_id"
        case contact = "contact"
    }
    
    public init(id: Int, createdAt: Date, updatedAt: Date?, deletedAt: Date?, content: String, date: Date?, contactId: Int?, contact: Contact?) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.content = content
        self.date = date
        self.contactId = contactId
        self.contact = contact
    }
}
