//
//  Gender.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

public enum Gender: String, Codable, Sendable {
    case male = "male"
    case female = "female"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"
    case unknown = ""
}
