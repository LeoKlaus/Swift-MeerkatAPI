//
//  Reminder.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 31.03.26.
//

import Foundation

public struct ReminderCompletion: Codable, Identifiable, Hashable, TimelineEntry {
    public let id: Int
    public let createdAt: Date?
    public let updatedAt: Date?
    public let deletedAt: Date?
    public let reminderId: Int
    public let contactId: Int
    public let message: String
    public let completedAt: Date
    
    public let uuid = UUID()
    public var time: Date? {
        self.completedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case deletedAt = "DeletedAt"
        case reminderId = "reminder_id"
        case contactId = "contact_id"
        case message
        case completedAt = "completed_at"
    }
    
    public init(
        id: Int,
        createdAt: Date?,
        updatedAt: Date?,
        deletedAt: Date?,
        reminderId: Int,
        contactId: Int,
        message: String,
        completedAt: Date
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.reminderId = reminderId
        self.contactId = contactId
        self.message = message
        self.completedAt = completedAt
    }
}

public struct Reminder: Codable, Identifiable, Hashable {
    public let id: Int
    public let createdAt: Date
    public let updatedAt: Date?
    public let deletedAt: Date?
    public var message: String
    public var byMail: Bool
    public var remindAt: Date
    public var recurrence: ReminderRecurrence
    public var reoccurFromCompletion: Bool
    public var completed: Bool
    public var emailSent: Bool
    public var lastSent: Date?
    public var contactId: Int
    public var contact: Contact?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case deletedAt = "DeletedAt"
        case message = "message"
        case byMail = "by_mail"
        case remindAt = "remind_at"
        case recurrence = "recurrence"
        case reoccurFromCompletion = "reoccur_from_completion"
        case completed = "completed"
        case emailSent = "email_sent"
        case lastSent = "last_sent"
        case contactId = "contact_id"
        case contact = "contact"
    }
    
    enum EncodingKeys: String, CodingKey {
        case message = "message"
        case byMail = "by_mail"
        case remindAt = "remind_at"
        case recurrence = "recurrence"
        case reoccurFromCompletion = "reoccur_from_completion"
        case contactId = "contact_id"
    }
    
    public init(
        id: Int,
        createdAt: Date,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil,
        message: String,
        byMail: Bool,
        remindAt: Date,
        recurrence: ReminderRecurrence,
        reoccurFromCompletion: Bool,
        completed: Bool,
        emailSent: Bool,
        lastSent: Date? = nil,
        contactId: Int,
        contact: Contact? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.message = message
        self.byMail = byMail
        self.remindAt = remindAt
        self.recurrence = recurrence
        self.reoccurFromCompletion = reoccurFromCompletion
        self.completed = completed
        self.emailSent = emailSent
        self.lastSent = lastSent
        self.contactId = contactId
        self.contact = contact
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(self.message, forKey: .message)
        try container.encode(self.byMail, forKey: .byMail)
        try container.encode(self.remindAt, forKey: .remindAt)
        try container.encode(self.recurrence, forKey: .recurrence)
        try container.encode(self.reoccurFromCompletion, forKey: .reoccurFromCompletion)
        try container.encode(self.contactId, forKey: .contactId)
    }
}
