//
//  MeerkatLanguage.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

public enum InterfaceLanguage: Decodable, Equatable, Hashable {
    
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
    
    public init(rawValue: String) {
        switch rawValue {
        case "en":
            self = .en
        case "de":
            self = .de
        default:
            self = .unknown(langcode: rawValue)
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(String.self))
    }
}
