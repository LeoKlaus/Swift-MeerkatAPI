//
//  BirthdayTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Test func testDecodeBirthday() throws {
    let json = """
    {
        "type": "contact",
        "name": "Matt Smith",
        "birthday": "1982-10-28",
        "contact_id": 1
    }
    """
    
    let jsonData = Data(json.utf8)
    
    let birthday = try JSONDecoder().decode(Birthday.self, from: jsonData)
    
    #expect(birthday.type == .contact)
    #expect(birthday.name == "Matt Smith")
    #expect(birthday.birthday == "1982-10-28")
    #expect(birthday.contactId == 1)
}
