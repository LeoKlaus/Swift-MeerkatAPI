//
//  User.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 29.03.26.
//

import Foundation

public struct User: Codable, Identifiable {
    public let id: Int
    public let username: String
    public let email: String
    public let language: InterfaceLanguage?
    public let dateFormat: DateFormat?
    public let isAdmin: Bool
    public let createdAt: Date
    public let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case language
        case dateFormat = "date_format"
        case isAdmin = "is_admin"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(
        id: Int,
        username: String,
        email: String,
        language: InterfaceLanguage?,
        dateFormat: DateFormat?,
        isAdmin: Bool,
        createdAt: Date,
        updatedAt: Date?
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.language = language
        self.dateFormat = dateFormat
        self.isAdmin = isAdmin
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
