//
//  HealthStatusTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 30.03.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct HealthStatusTests {
    @Test func testDecodeHealthStatus() async throws {
        let json = """
        {
            "status": "healthy",
            "timestamp": "2026-03-30T12:46:20Z",
            "database": {
                "status": "healthy",
                "response_time_ms": 0
            },
            "version": "0.1.0"
        }
        """
        
        let jsonData = Data(json.utf8)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let response = try decoder.decode(HealthStatus.self, from: jsonData)
        
        #expect(response.status == .healthy)
        #expect(response.timestamp.timeIntervalSince1970 == 1774874780)
        #expect(response.database.status == .healthy)
        #expect(response.database.responseTimeMs == 0)
        #expect(response.version == "0.1.0")
    }
}
