//
//  DateComponentsTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 05.04.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct DateComponentsTests {
    @Test func testDecodeDateWithYear() throws {
        let dateStr = "2003-01-16"
        
        let components = try DateComponents(dateStr)
        
        #expect(components.year == 2003)
        #expect(components.month == 01)
        #expect(components.day == 16)
        
        let date = components.date
        
        #expect(date?.timeIntervalSince1970 == 1042671600)
    }
    
    @Test func testDecodeDateWithoutYear() throws {
        let dateStr = "--01-16"
        
        let components = try DateComponents(dateStr)
        
        #expect(components.month == 01)
        #expect(components.day == 16)
        
        let date = components.date
        
        #expect(date?.timeIntervalSince1970 == -62134476808)
    }
}
