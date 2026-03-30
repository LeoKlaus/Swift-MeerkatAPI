//
//  PasswordStrengthResponse.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Foundation

public struct PasswordStrengthResponse: Codable {
    public let isValid: Bool
    public let entropy: Double
    public let score: Int
    public let feedback: String?
    public let minEntropy: Int
    public let charSetSize: Int
    public let length: Int
    
    enum CodingKeys: String, CodingKey {
        case isValid = "is_valid"
        case entropy = "entropy"
        case score = "score"
        case feedback = "feedback"
        case minEntropy = "min_entropy"
        case charSetSize = "char_set_size"
        case length = "length"
    }
}
