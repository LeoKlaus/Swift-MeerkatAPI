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
    public var type: BirthdayType
    public var name: String
    public var birthday: DateComponents
    public var contactId: Int?
    
    enum CodingKeys: String, CodingKey {
        case type
        case name
        case birthday
        case contactId = "contact_id"
    }
    
    public init(type: BirthdayType, name: String, birthday: DateComponents, contactId: Int?) {
        self.type = type
        self.name = name
        self.birthday = birthday
        self.contactId = contactId
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(BirthdayType.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        let birtdayString = try container.decode(String.self, forKey: .birthday)
        self.birthday = try DateComponents(birtdayString)
        self.contactId = try container.decodeIfPresent(Int.self, forKey: .contactId)
    }
}
