//
//  NoteTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct NoteTests {
    @Test func testDecodeNote() throws {
        let json = """
    {
        "ID": 1,
        "CreatedAt": "2026-03-28T23:22:22.0Z",
        "UpdatedAt": "2026-03-28T23:22:22.0Z",
        "DeletedAt": null,
        "content": "Some Note",
        "date": "2026-03-28T00:00:00Z",
        "contact_id": null,
        "contact": {
            "ID": 0,
            "CreatedAt": "0001-01-01T00:00:00Z",
            "UpdatedAt": "0001-01-01T00:00:00Z",
            "DeletedAt": null,
            "firstname": "",
            "lastname": "",
            "nickname": "",
            "gender": "",
            "email": "",
            "phone": "",
            "birthday": "",
            "photo": "",
            "relationships": null,
            "address": "",
            "how_we_met": "",
            "food_preference": "",
            "work_information": "",
            "contact_information": "",
            "circles": null,
            "custom_fields": null,
            "archived": false
        }
    }
    """
        
        let jsonData = Data(json.utf8)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let note = try decoder.decode(Note.self, from: jsonData)
        
        #expect(note.id == 1)
        #expect(note.createdAt.timeIntervalSince1970 == 1774740142)
        #expect(note.updatedAt?.timeIntervalSince1970 == 1774740142)
        #expect(note.deletedAt == nil)
        #expect(note.content == "Some Note")
        #expect(note.date?.timeIntervalSince1970 == 1774656000)
        #expect(note.contactId == nil)
    }
}
