//
//  LoginResponseTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct LoginResponseTests {
    @Test func testDecodeLoginResponse() throws {
        let json = """
    {
        "date_format": "eu",
        "language": "en"
    }
    """
        
        let jsonData = Data(json.utf8)
        
        let response = try JSONDecoder().decode(LoginResponse.self, from: jsonData)
        
        #expect(response.date_format == "eu")
        #expect(response.language == .en)
    }
}
