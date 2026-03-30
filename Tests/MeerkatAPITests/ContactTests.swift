//
//  ContactTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct ContactTests {
    @Test func testDecodeContact() throws {
        let json = """
    {
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
    """
        
        let jsonData = Data(json.utf8)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let contact = try decoder.decode(Contact.self, from: jsonData)
        
        #expect(contact.id == 1)
        #expect(contact.createdAt == Date(timeIntervalSince1970: 0))
        #expect(contact.updatedAt == Date(timeIntervalSince1970: 1))
        #expect(contact.deletedAt == nil)
        #expect(contact.firstname == "Matt")
        #expect(contact.lastname == "Smith")
        #expect(contact.nickname == "Matty")
        #expect(contact.gender == .male)
        #expect(contact.email == "matt.smith@example.com")
        #expect(contact.phone == "(555) 1234 567890")
        #expect(contact.birthday == "1982-10-28")
        #expect(contact.photo == "437f3e01-7e7d-4e8a-a3c9-212b33b4229e_photo.jpg")
        #expect(contact.relationships == nil)
        #expect(contact.address == "1 Tardis Way")
        #expect(contact.howWeMet == "Watching a TV show")
        #expect(contact.foodPreference == "Vegetarian")
        #expect(contact.workInformation == "Actor")
        #expect(contact.contactInformation == "Somewhere, sometime")
        #expect(contact.circles == ["Doctor Who"])
        #expect(contact.customFields == ["Doctor #": "11th Doctor"])
        #expect(contact.archived == false)
        #expect(contact.photoThumbnail == "")
    }
}
