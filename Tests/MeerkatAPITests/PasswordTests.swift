//
//  PasswordTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct PasswordTests {
    @Test func testDecodePassword() throws {
        let json = """
    {
        "is_valid": false,
        "entropy": 9.965784284662087,
        "score": 0,
        "feedback": "Password must be at least 8 characters long.",
        "min_entropy": 50,
        "char_set_size": 10,
        "length": 3
    }
    """
        
        let jsonData = Data(json.utf8)
        
        let response = try JSONDecoder().decode(PasswordStrengthResponse.self, from: jsonData)
        
        #expect(response.isValid == false)
        #expect(response.entropy == 9.965784284662087)
        #expect(response.score == 0)
        #expect(response.feedback == "Password must be at least 8 characters long.")
        #expect(response.minEntropy == 50)
        #expect(response.charSetSize == 10)
        #expect(response.length == 3)
    }
}
