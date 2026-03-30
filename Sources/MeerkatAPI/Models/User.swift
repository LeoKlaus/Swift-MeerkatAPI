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
    public let language: String?
    public let date_format: String?
    public let is_admin: Bool
    public let created_at: Date
    public let updated_at: Date?
    
    public init(id: Int, username: String, email: String, language: String?, date_format: String?, is_admin: Bool, created_at: Date, updated_at: Date?) {
        self.id = id
        self.username = username
        self.email = email
        self.language = language
        self.date_format = date_format
        self.is_admin = is_admin
        self.created_at = created_at
        self.updated_at = updated_at
    }
}
