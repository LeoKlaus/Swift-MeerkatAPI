//
//  ReminderTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 31.03.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct ReminderTests {
    @Test func testDecodeReminder() throws {
        let json = """
        {
            "ID": 2,
            "CreatedAt": "2026-03-28T23:13:13.0Z",
            "UpdatedAt": "2026-03-30T11:17:55.0Z",
            "DeletedAt": null,
            "message": "Reminder",
            "by_mail": false,
            "remind_at": "2026-03-31T00:00:00Z",
            "recurrence": "once",
            "reoccur_from_completion": true,
            "completed": false,
            "email_sent": false,
            "last_sent": null,
            "contact_id": 1,
            "contact": {
                "ID": 1,
                "CreatedAt": "1970-01-01T00:00:00Z",
                "UpdatedAt": "1970-01-01T00:00:01Z",
                "DeletedAt": null,
                "firstname": "Matt",
                "lastname": "Smith",
                "nickname": "Matty",
                "gender": "male",
                "email": "matt.smith@example.com",
                "phone": "(555) 1234 567890",
                "birthday": "1982-10-28",
                "photo": "437f3e01-7e7d-4e8a-a3c9-212b33b4229e_photo.jpg",
                "relationships": null,
                "address": "1 Tardis Way",
                "how_we_met": "Watching a TV show",
                "food_preference": "Vegetarian",
                "work_information": "Actor",
                "contact_information": "Somewhere, sometime",
                "circles": [
                    "Doctor Who"
                ],
                "custom_fields": {
                    "Doctor #": "11th Doctor"
                },
                "archived": false,
                "photo_thumbnail": ""
            }
        }
        """
        
        let jsonData = Data(json.utf8)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let reminder = try decoder.decode(Reminder.self, from: jsonData)
        
        #expect(reminder.id == 2)
        #expect(reminder.createdAt.timeIntervalSince1970 == 1774739593)
        #expect(reminder.updatedAt?.timeIntervalSince1970 == 1774869475)
        #expect(reminder.deletedAt == nil)
        #expect(reminder.message == "Reminder")
        #expect(reminder.byMail == false)
        #expect(reminder.remindAt.timeIntervalSince1970 == 1774915200)
        #expect(reminder.recurrence == .once)
        #expect(reminder.reoccurFromCompletion)
        #expect(reminder.completed == false)
        #expect(reminder.emailSent == false)
        #expect(reminder.lastSent == nil)
        #expect(reminder.contactId == 1)
        
        let contact = reminder.contact
        
        #expect(contact?.id == 1)
        #expect(contact?.createdAt == Date(timeIntervalSince1970: 0))
        #expect(contact?.updatedAt == Date(timeIntervalSince1970: 1))
        #expect(contact?.deletedAt == nil)
        #expect(contact?.firstname == "Matt")
        #expect(contact?.lastname == "Smith")
        #expect(contact?.nickname == "Matty")
        #expect(contact?.gender == .male)
        #expect(contact?.email == "matt.smith@example.com")
        #expect(contact?.phone == "(555) 1234 567890")
        #expect(contact?.birthday?.year == 1982)
        #expect(contact?.birthday?.month == 10)
        #expect(contact?.birthday?.day == 28)
        #expect(contact?.photo == "437f3e01-7e7d-4e8a-a3c9-212b33b4229e_photo.jpg")
        #expect(contact?.relationships == nil)
        #expect(contact?.address == "1 Tardis Way")
        #expect(contact?.howWeMet == "Watching a TV show")
        #expect(contact?.foodPreference == "Vegetarian")
        #expect(contact?.workInformation == "Actor")
        #expect(contact?.contactInformation == "Somewhere, sometime")
        #expect(contact?.circles == ["Doctor Who"])
        #expect(contact?.customFields == ["Doctor #": "11th Doctor"])
        #expect(contact?.archived == false)
        #expect(contact?.photoThumbnail == "")
    }
}
