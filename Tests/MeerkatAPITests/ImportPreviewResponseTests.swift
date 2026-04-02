//
//  ImportPreviewResponseTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct ImportPreviewResponseTests {
    @Test func testDecodeImportPreviewResponse() async throws {
        let json = """
        {
            "session_id": "d15ae90023b9a2cd26192fb299f30506",
            "rows": [
                {
                    "row_index": 0,
                    "parsed_contact": {
                        "firstname": "Matt",
                        "lastname": "Smith",
                        "phone": "0123 789123"
                    },
                    "validation_errors": [],
                    "duplicate_match": {
                        "existing_contact_id": 1,
                        "existing_firstname": "Matt",
                        "existing_lastname": "Smith",
                        "existing_email": "mattsmith@example.com",
                        "existing_phone": "0123 789123",
                        "match_reason": "name"
                    },
                    "suggested_action": "update"
                },
                {
                    "row_index": 1,
                    "parsed_contact": {
                        "firstname": "David",
                        "lastname": "Smith",
                        "phone": "0123 123456"
                    },
                    "validation_errors": [],
                    "duplicate_match": null,
                    "suggested_action": "add"
                }
            ],
            "total_rows": 2,
            "valid_rows": 2,
            "duplicate_count": 1,
            "error_count": 0
        }
        """

        let jsonData = Data(json.utf8)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let response = try decoder.decode(ImportPreviewResponse.self, from: jsonData)
        #expect(response .sessionID == "d15ae90023b9a2cd26192fb299f30506")
        #expect(response.rows.count == 2)
        #expect(response.totalRows == 2)
        #expect(response.validRows == 2)
        #expect(response.duplicateCount == 1)
        #expect(response.errorCount == 0)
        
        let firstRow = response.rows[0]
        let secondRow = response.rows[1]
        
        
        #expect(firstRow.rowIndex == 0)
        #expect(firstRow.parsedContact == [
            "firstname": "Matt",
            "lastname": "Smith",
            "phone": "0123 789123"
        ])
        #expect(firstRow.validationErrors == [])
        #expect(firstRow.rowIndex == 0)
        #expect(
            firstRow.duplicateMatch == DuplicateMatch(
                existingContactID: 1,
                existingFirstname: "Matt",
                existingLastname: "Smith",
                existingEmail: "mattsmith@example.com",
                existingPhone: "0123 789123",
                matchReason: .name
            )
        )
        #expect(firstRow.suggestedAction == .update)
        
        #expect(secondRow.rowIndex == 1)
        #expect(secondRow.parsedContact == [
            "firstname": "David",
            "lastname": "Smith",
            "phone": "0123 123456"
        ])
        #expect(secondRow.validationErrors == [])
        #expect(secondRow.duplicateMatch == nil)
        #expect(secondRow.suggestedAction == .add)
    }
}
