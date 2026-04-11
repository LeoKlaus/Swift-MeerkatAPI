//
//  User.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 29.03.26.
//

import Foundation

public struct User: Codable, Identifiable {
    public let id: Int
    public let createdAt: Date
    public let updatedAt: Date?
    public var username: String
    public var email: String
    public var language: InterfaceLanguage?
    public var dateFormat: DateFormat?
    public var isAdmin: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case username
        case email
        case language
        case dateFormat = "date_format"
        case isAdmin = "is_admin"
    }
    
    public init(
        id: Int,
        createdAt: Date,
        updatedAt: Date?,
        username: String,
        email: String,
        language: InterfaceLanguage?,
        dateFormat: DateFormat?,
        isAdmin: Bool
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.username = username
        self.email = email
        self.language = language
        self.dateFormat = dateFormat
        self.isAdmin = isAdmin
    }
}
