//
//  UserTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Test func testDecodeUser() throws {
    let json = """
    {
        "id": 1,
        "username": "leo",
        "email": "leo@example.com",
        "language": "en",
        "date_format": "eu",
        "is_admin": true,
        "created_at": "2026-03-28T22:52:48.0Z",
        "updated_at": "2026-03-28T23:23:05.0Z"
    }
    """
    
    let jsonData = Data(json.utf8)
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let user = try decoder.decode(User.self, from: jsonData)
    
    #expect(user.id == 1)
    #expect(user.username == "leo")
    #expect(user.email == "leo@example.com")
    #expect(user.language == "en")
    #expect(user.date_format == "eu")
    #expect(user.is_admin == true)
    #expect(user.created_at.timeIntervalSince1970 == 1774738368)
    #expect(user.updated_at?.timeIntervalSince1970 == 1774740185)
}
