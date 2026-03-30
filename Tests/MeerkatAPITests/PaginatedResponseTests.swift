//
//  PaginatedResponseTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Test func testDecodeActivitiesResponse() throws {
    let json = """
    {
        "activities": [
            {
                "ID": 1,
                "CreatedAt": "2026-03-28T23:12:22.0Z",
                "UpdatedAt": "2026-03-28T23:20:45.0Z",
                "DeletedAt": null,
                "title": "Fighting Daleks",
                "description": "Exterminate!!!",
                "location": "Skaro",
                "date": "2072-03-29T00:00:00Z"
            }
        ],
        "limit": 25,
        "page": 1,
        "total": 1
    }
    """
    
    let jsonData = Data(json.utf8)
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let response = try decoder.decode(PaginatedResponse<Activity>.self, from: jsonData)
    
    let firstActivity = response.results.first
    
    #expect(firstActivity?.id == 1)
    #expect(firstActivity?.createdAt.timeIntervalSince1970 == 1774739542)
    #expect(firstActivity?.updatedAt?.timeIntervalSince1970 == 1774740045)
    #expect(firstActivity?.deletedAt == nil)
    #expect(firstActivity?.title == "Fighting Daleks")
    #expect(firstActivity?.description == "Exterminate!!!")
    #expect(firstActivity?.location == "Skaro")
    #expect(firstActivity?.date == Date(timeIntervalSince1970: 3226435200))
    
    #expect(response.limit == 25)
    #expect(response.page == 1)
    #expect(response.total == 1)
    #expect(response.totalPages == nil)
}

@Test func testDecodeBirthdays() throws {
    let json = """
    {
        "birthdays": [
            {
                "type": "contact",
                "name": "Matt Smith",
                "birthday": "1982-10-28",
                "contact_id": 1
            }
        ]
    }
    """
    
    let jsonData = Data(json.utf8)
    
    let response = try JSONDecoder().decode(PaginatedResponse<Birthday>.self, from: jsonData)
    
    let firstBirthday = response.results.first
    
    #expect(firstBirthday?.type == .contact)
    #expect(firstBirthday?.name == "Matt Smith")
    #expect(firstBirthday?.birthday == "1982-10-28")
    #expect(firstBirthday?.contactId == 1)
    
    #expect(response.limit == nil)
    #expect(response.page == nil)
    #expect(response.total == nil)
    #expect(response.totalPages == nil)
}

@Test func testDecodeContactsResponse() throws {
    let json = """
        {
            "contacts": [
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
            ],
            "limit": 25,
            "page": 1,
            "total": 1
        }
        """
    
    let jsonData = Data(json.utf8)
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let response = try decoder.decode(PaginatedResponse<Contact>.self, from: jsonData)
    
    let firstContact = response.results.first
    
    #expect(firstContact?.id == 1)
    #expect(firstContact?.createdAt == Date(timeIntervalSince1970: 0))
    #expect(firstContact?.updatedAt == Date(timeIntervalSince1970: 1))
    #expect(firstContact?.deletedAt == nil)
    #expect(firstContact?.firstname == "Matt")
    #expect(firstContact?.lastname == "Smith")
    #expect(firstContact?.nickname == "Matty")
    #expect(firstContact?.gender == .male)
    #expect(firstContact?.email == "matt.smith@example.com")
    #expect(firstContact?.phone == "(555) 1234 567890")
    #expect(firstContact?.birthday == "1982-10-28")
    #expect(firstContact?.photo == "437f3e01-7e7d-4e8a-a3c9-212b33b4229e_photo.jpg")
    #expect(firstContact?.relationships == nil)
    #expect(firstContact?.address == "1 Tardis Way")
    #expect(firstContact?.howWeMet == "Watching a TV show")
    #expect(firstContact?.foodPreference == "Vegetarian")
    #expect(firstContact?.workInformation == "Actor")
    #expect(firstContact?.contactInformation == "Somewhere, sometime")
    #expect(firstContact?.circles == ["Doctor Who"])
    #expect(firstContact?.customFields == ["Doctor #": "11th Doctor"])
    #expect(firstContact?.archived == false)
    #expect(firstContact?.photoThumbnail == "")
    
    #expect(response.limit == 25)
    #expect(response.page == 1)
    #expect(response.total == 1)
    #expect(response.totalPages == nil)
}

@Test func testDecodeNotes() throws {
    let json = """
    {
        "limit": 25,
        "notes": [
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
        ],
        "page": 1,
        "total": 1
    }
    """
    
    let jsonData = Data(json.utf8)
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let response = try decoder.decode(PaginatedResponse<Note>.self, from: jsonData)
    
    let firstNote = response.results.first
    
    #expect(firstNote?.id == 1)
    #expect(firstNote?.createdAt.timeIntervalSince1970 == 1774740142)
    #expect(firstNote?.updatedAt?.timeIntervalSince1970 == 1774740142)
    #expect(firstNote?.deletedAt == nil)
    #expect(firstNote?.content == "Some Note")
    #expect(firstNote?.date?.timeIntervalSince1970 == 1774656000)
    #expect(firstNote?.contactId == nil)
    
    #expect(response.limit == 25)
    #expect(response.page == 1)
    #expect(response.total == 1)
    #expect(response.totalPages == nil)
}

@Test func testDecodeRelationships() throws {
    let json = """
    {
        "relationships": [
            {
                "ID": 1,
                "CreatedAt": "2026-03-28T23:00:13.0Z",
                "UpdatedAt": "2026-03-28T23:00:13.0Z",
                "DeletedAt": null,
                "name": "David Smith",
                "type": "Father",
                "gender": "",
                "birthday": "",
                "contact_id": 2,
                "related_contact_id": 1,
                "related_contact": {
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
        ]
    }
    """
    
    let jsonData = Data(json.utf8)
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let response = try decoder.decode(PaginatedResponse<Relationship>.self, from: jsonData)
    
    let firstRelationship = response.results.first
    
    #expect(firstRelationship?.id == 1)
    #expect(firstRelationship?.createdAt.timeIntervalSince1970 == 1774738813)
    #expect(firstRelationship?.updatedAt?.timeIntervalSince1970 == 1774738813)
    #expect(firstRelationship?.deletedAt == nil)
    #expect(firstRelationship?.name == "David Smith")
    #expect(firstRelationship?.type == "Father")
    #expect(firstRelationship?.gender == .unknown)
    #expect(firstRelationship?.birthday == "")
    #expect(firstRelationship?.contactId == 2)
    #expect(firstRelationship?.relatedContactId == 1)
    
    let contact = firstRelationship?.relatedContact
    
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
    #expect(contact?.birthday == "1982-10-28")
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
    
    #expect(response.limit == nil)
    #expect(response.page == nil)
    #expect(response.total == nil)
    #expect(response.totalPages == nil)
}

@Test func testDecodeUsers() throws {
    let json = """
    {
        "users": [
            {
                "id": 1,
                "username": "leo",
                "email": "leo@example.com",
                "language": "en",
                "date_format": "eu",
                "is_admin": true,
                "created_at": "2026-03-28T22:52:48.0Z",
                "updated_at": "2026-03-28T23:23:05.0Z"
            }
        ],
        "total": 1,
        "page": 1,
        "limit": 25,
        "total_pages": 1
    }
    """
    
    let jsonData = Data(json.utf8)
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let response = try decoder.decode(PaginatedResponse<User>.self, from: jsonData)
    
    let firstUser = response.results.first
    
    #expect(firstUser?.id == 1)
    #expect(firstUser?.username == "leo")
    #expect(firstUser?.email == "leo@example.com")
    #expect(firstUser?.language == "en")
    #expect(firstUser?.date_format == "eu")
    #expect(firstUser?.is_admin == true)
    #expect(firstUser?.created_at.timeIntervalSince1970 == 1774738368)
    #expect(firstUser?.updated_at?.timeIntervalSince1970 == 1774740185)
    
    #expect(response.limit == 25)
    #expect(response.page == 1)
    #expect(response.total == 1)
    #expect(response.totalPages == 1)
}
