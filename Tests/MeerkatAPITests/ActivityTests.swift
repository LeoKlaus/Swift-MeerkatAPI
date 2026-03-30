//
//  ActivityTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct ActivityTests {
    
    @Test func testDecodeActivity() throws {
        let json = """
    {
        "ID": 1,
        "CreatedAt": "2026-03-28T23:12:22.0Z",
        "UpdatedAt": "2026-03-28T23:20:45.0Z",
        "DeletedAt": null,
        "title": "Fighting Daleks",
        "description": "Exterminate!!!",
        "location": "Skaro",
        "date": "2072-03-29T00:00:00Z"
    }
    """
        
        let jsonData = Data(json.utf8)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let activity = try decoder.decode(Activity.self, from: jsonData)
        
        #expect(activity.id == 1)
        #expect(activity.createdAt.timeIntervalSince1970 == 1774739542)
        #expect(activity.updatedAt?.timeIntervalSince1970 == 1774740045)
        #expect(activity.deletedAt == nil)
        #expect(activity.title == "Fighting Daleks")
        #expect(activity.description == "Exterminate!!!")
        #expect(activity.location == "Skaro")
        #expect(activity.date == Date(timeIntervalSince1970: 3226435200))
    }
}
