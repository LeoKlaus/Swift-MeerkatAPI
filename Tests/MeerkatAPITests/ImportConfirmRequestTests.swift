//
//  ImportConfirmRequestTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 02.04.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct ImportConfirmRequestTests {
    @Test func testEncodeConfirmRequest() async throws {
        
        let previewRequest = ImportConfirmRequest(
            sessionID: "123abc",
            actions: [
                RowImportAction(rowIndex: 0, action: .add),
                RowImportAction(rowIndex: 1, action: .skip),
                RowImportAction(rowIndex: 2, action: .update)
            ]
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        
        let encodedData = try encoder.encode(previewRequest)
        
        let encodedStr = String(data: encodedData, encoding: .utf8)
        
        let expectedStr = """
        {"actions":[{"action":"add","row_index":0},{"action":"skip","row_index":1},{"action":"update","row_index":2}],"session_id":"123abc"}
        """
        
        #expect(encodedStr == expectedStr)
    }
}
