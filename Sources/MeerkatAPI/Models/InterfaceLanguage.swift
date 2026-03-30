//
//  MeerkatLanguage.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

public enum InterfaceLanguage: Codable {
    
    case en
    case de
    case unknown(langcode: String)
    
    public var rawValue: String {
        switch self {
        case .en:
            "en"
        case .de:
            "de"
        case .unknown(let langcode):
            langcode
        }
    }
    
    public init?(rawValue: String) {
        switch rawValue {
        case "en":
            self = .en
        case "de":
            self = .de
        default:
            self = .unknown(langcode: rawValue)
        }
    }
}
