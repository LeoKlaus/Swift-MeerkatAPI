//
//  PasswordStrengthResponse.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Foundation

public struct PasswordStrengthResponse: Codable {
    public let is_valid: Bool
    public let entropy: Double
    public let score: Int
    public let feedback: String?
    public let min_entropy: Int
    public let char_set_size: Int
    public let length: Int
}
