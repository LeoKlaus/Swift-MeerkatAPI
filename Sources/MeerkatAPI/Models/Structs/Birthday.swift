//
//  Birthday.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Foundation

public enum BirthdayType: String, Codable {
    case contact
    case relationship
    case none = ""
}

public struct Birthday: Codable, Hashable {
    public let type: BirthdayType
    public let name: String
    public let birthday: String
    public let contactId: Int?
    
    enum CodingKeys: String, CodingKey {
        case type
        case name
        case birthday
        case contactId = "contact_id"
    }
    
    public init(type: BirthdayType, name: String, birthday: String, contactId: Int?) {
        self.type = type
        self.name = name
        self.birthday = birthday
        self.contactId = contactId
    }
}
