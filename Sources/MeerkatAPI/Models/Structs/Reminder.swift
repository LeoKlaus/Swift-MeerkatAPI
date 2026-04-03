//
//  Reminder.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 31.03.26.
//

import Foundation

public struct Reminder: Codable, Identifiable, Hashable {
    public let id: Int
    public let createdAt: Date
    public let updatedAt: Date?
    public let deletedAt: Date?
    public let message: String
    public let byMail: Bool
    public let remindAt: Date
    public let recurrence: ReminderRecurrence
    public let reoccurFromCompletion: Bool
    public let completed: Bool
    public let emailSent: Bool
    public let lastSent: Date?
    public let contactId: Int?
    public let contact: Contact?
    
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
        contactId: Int? = nil,
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
}
