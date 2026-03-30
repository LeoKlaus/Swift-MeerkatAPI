//
//  CustomFieldTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Test func testDecodeCustomFields() throws {
    let json = """
    {
        "custom_field_names": [
            "Doctor #"
        ]
    }
    """
    
    let jsonData = Data(json.utf8)
    
    let customFields = try JSONDecoder().decode(CustomFields.self, from: jsonData)
    
    #expect(customFields.customFieldNames == ["Doctor #"])
}
