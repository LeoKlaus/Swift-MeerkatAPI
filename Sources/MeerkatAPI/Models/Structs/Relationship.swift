//
//  Relationship.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Foundation

public struct Relationship: Codable {
    public let id: Int
    public let createdAt: Date
    public let updatedAt: Date?
    public let deletedAt: Date?
    public let name: String
    public let type: String
    public let gender: Gender?
    public let birthday: String?
    public let contactId: Int
    public let relatedContactId: Int
    public let relatedContact: Contact
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case deletedAt = "DeletedAt"
        case name
        case type
        case gender
        case birthday
        case contactId = "contact_id"
        case relatedContactId = "related_contact_id"
        case relatedContact = "related_contact"
    }
    
    public init(
        id: Int,
        createdAt: Date,
        updatedAt: Date?,
        deletedAt: Date?,
        name: String,
        type: String,
        gender: Gender?,
        birthday: String?,
        contactId: Int,
        relatedContactId: Int,
        relatedContact: Contact
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.type = type
        self.gender = gender
        self.birthday = birthday
        self.contactId = contactId
        self.relatedContactId = relatedContactId
        self.relatedContact = relatedContact
    }
}
