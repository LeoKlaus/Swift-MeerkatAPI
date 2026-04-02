//
//  DuplicateMatch.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Foundation

public struct DuplicateMatch: Codable, Equatable {
    public let existingContactID: Int
    public let existingFirstname: String?
    public let existingLastname: String?
    public let existingEmail: String?
    public let existingPhone: String?
    public let matchReason: MatchReason
    
    enum CodingKeys: String, CodingKey {
        case existingContactID = "existing_contact_id"
        case existingFirstname = "existing_firstname"
        case existingLastname = "existing_lastname"
        case existingEmail = "existing_email"
        case existingPhone = "existing_phone"
        case matchReason = "match_reason"
    }
}
