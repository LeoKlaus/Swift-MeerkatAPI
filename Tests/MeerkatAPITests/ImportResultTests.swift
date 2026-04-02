//
//  ImportResultTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct ImportResultTests {
    @Test func testDecodeImportResult() async throws {
        let json = """
        {
            "total_processed": 2,
            "created": 0,
            "updated": 0,
            "skipped": 2,
            "errors": []
        }
        """
        
        let jsonData = Data(json.utf8)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let response = try decoder.decode(ImportResult.self, from: jsonData)
        #expect(response.totalProcessed == 2)
        #expect(response.created == 0)
        #expect(response.updated == 0)
        #expect(response.skipped == 2)
        #expect(response.errors == [])
    }
}
