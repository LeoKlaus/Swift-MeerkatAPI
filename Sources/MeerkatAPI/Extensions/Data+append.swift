//
//  Data+append.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 31.03.26.
//


import Foundation

extension Data {
    /// Appends the data for the given string as UTF-8 data
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
