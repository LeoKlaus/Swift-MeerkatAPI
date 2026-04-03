//
//  TokenResponseTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 03.04.26.
//

import Foundation
import Testing
@testable import MeerkatAPI

@Test func testDecodeTokenResponse() throws {
    let json = """
    {
        "id": 1,
        "name": "Test",
        "created_at": "2026-04-03T20:07:51.770066687Z",
        "last_used_at": null,
        "revoked_at": null,
        "token": "meerkat_dSsE8otSoGAXM"
    }
    """
    
    let jsonData = Data(json.utf8)
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let response = try decoder.decode(TokenResponse.self, from: jsonData)
    
    #expect(response.id == 1)
    #expect(response.name == "Test")
    #expect(response.createdAt.timeIntervalSince1970 == 1775246871.7700667)
    #expect(response.lastUsedAt == nil)
    #expect(response.revokedAt == nil)
    #expect(response.token == "meerkat_dSsE8otSoGAXM")
}
