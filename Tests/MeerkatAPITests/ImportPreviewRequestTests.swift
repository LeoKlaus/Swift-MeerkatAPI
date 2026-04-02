//
//  ImportPreviewRequestTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct ImportPreviewRequestTests {
    @Test func testEncodePreviewRequest() async throws {
        
        let previewRequest = ImportPreviewRequest(
            sessionID: "abc123",
            mappings: [
                ColumnMapping(
                    csvColumn: "Lastname",
                    contactField: "lastname"
                ),
                ColumnMapping(
                    csvColumn: "Firstname",
                    contactField: "firstname"
                ),
                ColumnMapping(
                    csvColumn: "Phone",
                    contactField: "phone"
                )
            ]
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        
        let encodedData = try encoder.encode(previewRequest)
        
        let encodedStr = String(data: encodedData, encoding: .utf8)
        
        let expectedStr = """
        {"mappings":[{"contact_field":"lastname","csv_column":"Lastname"},{"contact_field":"firstname","csv_column":"Firstname"},{"contact_field":"phone","csv_column":"Phone"}],"session_id":"abc123"}
        """
        
        #expect(encodedStr == expectedStr)
    }
}
