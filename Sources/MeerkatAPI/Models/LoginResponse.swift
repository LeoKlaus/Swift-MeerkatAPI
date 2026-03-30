//
//  LoginResponse.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Foundation

public struct LoginResponse: Decodable {
    public let date_format: DateFormat
    public let language: InterfaceLanguage
}
