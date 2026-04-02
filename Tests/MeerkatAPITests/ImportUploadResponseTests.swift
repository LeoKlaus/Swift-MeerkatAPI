//
//  ImportUploadResponseTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct ImportUploadResponseTests {
    @Test func testDecodeUploadResponse() async throws {
        let json = """
        {
            "session_id": "d15ae90023b9a2cd26192fb299f30506",
            "headers": [
                "firstname",
                "lastname",
                "phone"
            ],
            "suggested_mappings": [
                {
                    "csv_column": "Firstname",
                    "contact_field": "firstname"
                },
                {
                    "csv_column": "Lastname",
                    "contact_field": "lastname"
                },
                {
                    "csv_column": "Phone",
                    "contact_field": "phone"
                }
            ],
            "row_count": 1,
            "sample_data": [
                [
                    "Matt",
                    "Smith",
                    "0123 789123"
                ]
            ]
        }
        """
        
        let jsonData = Data(json.utf8)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let response = try decoder.decode(ImportUploadResponse.self, from: jsonData)
        
        #expect(response.sessionID == "d15ae90023b9a2cd26192fb299f30506")
        #expect(response.headers == ["firstname", "lastname", "phone"])
        
        #expect(response.suggestedMappings.count == 3)
        
        let firstMapping = response.suggestedMappings[0]
        let secondMapping = response.suggestedMappings[1]
        let thirdMapping = response.suggestedMappings[2]
        
        #expect(firstMapping.csvColumn == "Firstname")
        #expect(firstMapping.contactField == "firstname")
        
        #expect(secondMapping.csvColumn == "Lastname")
        #expect(secondMapping.contactField == "lastname")
        
        #expect(thirdMapping.csvColumn == "Phone")
        #expect(thirdMapping.contactField == "phone")
        
        #expect(response.rowCount == 1)
        
        #expect(response.sampleData == [
            [
                "Matt",
                "Smith",
                "0123 789123"
            ]
        ])
    }
}
