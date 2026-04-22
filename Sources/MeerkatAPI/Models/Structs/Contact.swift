//
//  Contact.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 29.03.26.
//

import Foundation

public struct Contact: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let createdAt: Date?
    public let updatedAt: Date?
    public let deletedAt: Date?
    public var firstname: String
    public var lastname: String?
    public var nickname: String?
    public var gender: Gender?
    public var email: String?
    public var phone: String?
    public var birthday: DateComponents?
    public let photo: String?
    public var relationships: [Relationship]?
    public var address: String?
    public var howWeMet: String?
    public var foodPreference: String?
    public var workInformation: String?
    public var contactInformation: String?
    public var circles: [String]?
    public var customFields: [String:String]?
    public var archived: Bool
    public let photoThumbnail: String?
    
    public enum CodingKeys: String, CodingKey {
        case id = "ID"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case deletedAt = "DeletedAt"
        case firstname
        case lastname
        case nickname
        case gender
        case email
        case phone
        case birthday
        case photo
        case relationships
        case address
        case howWeMet = "how_we_met"
        case foodPreference = "food_preference"
        case workInformation = "work_information"
        case contactInformation = "contact_information"
        case circles
        case customFields = "custom_fields"
        case archived
        case photoThumbnail = "photo_thumbnail"
    }
    
    public enum EncodingKeys: String, CodingKey {
        case firstname
        case lastname
        case nickname
        case gender
        case email
        case phone
        case birthday
        case relationships
        case address
        case howWeMet = "how_we_met"
        case foodPreference = "food_preference"
        case workInformation = "work_information"
        case contactInformation = "contact_information"
        case circles
        case customFields = "custom_fields"
    }
    
    public init(id: Int, createdAt: Date?, updatedAt: Date?, deletedAt: Date?, firstname: String, lastname: String?, nickname: String?, gender: Gender?, email: String?, phone: String?, birthday: DateComponents?, photo: String?, relationships: [Relationship]?, address: String?, howWeMet: String?, foodPreference: String?, workInformation: String?, contactInformation: String?, circles: [String]?, customFields: [String : String]?, archived: Bool, photoThumbnail: String?) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.firstname = firstname
        self.lastname = lastname
        self.nickname = nickname
        self.gender = gender
        self.email = email
        self.phone = phone
        self.birthday = birthday
        self.photo = photo
        self.relationships = relationships
        self.address = address
        self.howWeMet = howWeMet
        self.foodPreference = foodPreference
        self.workInformation = workInformation
        self.contactInformation = contactInformation
        self.circles = circles
        self.customFields = customFields
        self.archived = archived
        self.photoThumbnail = photoThumbnail
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        self.firstname = try container.decode(String.self, forKey: .firstname)
        self.lastname = try container.decodeIfPresent(String.self, forKey: .lastname)
        self.nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        self.gender = try container.decodeIfPresent(Gender.self, forKey: .gender)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        let birthdayString = try container.decodeIfPresent(String.self, forKey: .birthday)
        if let birthdayString, !birthdayString.isEmpty {
            self.birthday = try DateComponents(birthdayString)
        } else {
            self.birthday = nil
        }
        self.photo = try container.decodeIfPresent(String.self, forKey: .photo)
        self.relationships = try container.decodeIfPresent([Relationship].self, forKey: .relationships)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.howWeMet = try container.decodeIfPresent(String.self, forKey: .howWeMet)
        self.foodPreference = try container.decodeIfPresent(String.self, forKey: .foodPreference)
        self.workInformation = try container.decodeIfPresent(String.self, forKey: .workInformation)
        self.contactInformation = try container.decodeIfPresent(String.self, forKey: .contactInformation)
        self.circles = try container.decodeIfPresent([String].self, forKey: .circles)
        self.customFields = try container.decodeIfPresent([String : String].self, forKey: .customFields)
        self.archived = try container.decode(Bool.self, forKey: .archived)
        self.photoThumbnail = try container.decodeIfPresent(String.self, forKey: .photoThumbnail)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(self.firstname, forKey: .firstname)
        try container.encodeIfPresent(self.lastname, forKey: .lastname)
        try container.encodeIfPresent(self.nickname, forKey: .nickname)
        try container.encodeIfPresent(self.gender, forKey: .gender)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.phone, forKey: .phone)
        
        let birthdayString = self.birthday?.meerkatString
        try container.encodeIfPresent(birthdayString, forKey: .birthday)
        
        try container.encodeIfPresent(self.relationships, forKey: .relationships)
        try container.encodeIfPresent(self.address, forKey: .address)
        try container.encodeIfPresent(self.howWeMet, forKey: .howWeMet)
        try container.encodeIfPresent(self.foodPreference, forKey: .foodPreference)
        try container.encodeIfPresent(self.workInformation, forKey: .workInformation)
        try container.encodeIfPresent(self.contactInformation, forKey: .contactInformation)
        try container.encodeIfPresent(self.circles, forKey: .circles)
        try container.encodeIfPresent(self.customFields, forKey: .customFields)
    }
    
    public static let defaultFields: Set<Contact.CodingKeys> = [
        .id,
        .firstname,
        .lastname,
        .nickname,
        .gender,
        .email,
        .phone,
        .birthday,
        .photo,
        .relationships,
        .address,
        .howWeMet,
        .foodPreference,
        .workInformation,
        .contactInformation,
        .circles,
        .customFields,
        .archived,
        .firstname,
        .lastname
    ]
    
    public var firstAndLastName: String {
        if let lastname, !lastname.isEmpty {
            return firstname + " " + lastname
        } else {
            return firstname
        }
    }
    
    public var displayName: String {
        if let nickname, let lastname, !nickname.isEmpty && !lastname.isEmpty {
            return firstname + " \"\(nickname)\" " + lastname
        } else if let nickname, !nickname.isEmpty {
            return firstname + " \"\(nickname)\""
        } else if let lastname, !lastname.isEmpty {
            return firstname + " " + lastname
        } else {
            return firstname
        }
    }
}
