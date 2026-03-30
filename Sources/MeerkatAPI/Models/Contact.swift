//
//  Contact.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 29.03.26.
//

import Foundation

public struct Contact: Codable, Identifiable {
    public let id: Int
    public let createdAt: Date?
    public let updatedAt: Date?
    public let deletedAt: Date?
    public let firstname: String
    public let lastname: String?
    public let nickname: String?
    public let gender: Gender?
    public let email: String?
    public let phone: String?
    public let birthday: String?
    public let photo: String?
    public let relationships: String? // TODO: What is this?
    public let address: String?
    public let howWeMet: String?
    public let foodPreference: String?
    public let workInformation: String?
    public let contactInformation: String?
    public let circles: [String]?
    public let customFields: [String:String]?
    public let archived: Bool
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
    
    public init(id: Int, createdAt: Date?, updatedAt: Date?, deletedAt: Date?, firstname: String, lastname: String?, nickname: String?, gender: Gender?, email: String?, phone: String?, birthday: String?, photo: String?, relationships: String?, address: String?, howWeMet: String?, foodPreference: String?, workInformation: String?, contactInformation: String?, circles: [String]?, customFields: [String : String]?, archived: Bool, photoThumbnail: String?) {
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
    
    public static let defaultFields: [Contact.CodingKeys] = [
        .id,
        .firstname,
        .lastname,
        .nickname,
        .gender,
        .birthday,
        .phone,
        .circles,
        .archived,
        .customFields,
        .relationships,
        .photo
    ]
    
    public var fullName: String {
        if let nickname, let lastname {
            return firstname + " \"\(nickname)\" " + lastname
        } else if let nickname {
            return firstname + " \"\(nickname)\""
        } else if let lastname {
            return firstname + " " + lastname
        } else {
            return firstname
        }
    }
}
