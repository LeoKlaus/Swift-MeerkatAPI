//
//  DateFormat.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Foundation


public enum DateFormat: Codable, Equatable, Hashable {
    
    case eu
    case us
    case unknown(langcode: String)
    
    public var rawValue: String {
        switch self {
        case .eu:
            "eu"
        case .us:
            "us"
        case .unknown(let langcode):
            langcode
        }
    }
    
    public init(rawValue: String) {
        switch rawValue {
        case "eu":
            self = .eu
        case "us":
            self = .us
        default:
            self = .unknown(langcode: rawValue)
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(String.self))
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

