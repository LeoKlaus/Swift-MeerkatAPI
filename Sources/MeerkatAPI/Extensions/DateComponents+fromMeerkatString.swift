//
//  DateComponents+fromMeerkatString.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 05.04.26.
//

import Foundation

enum MeerkatDateComponentError: Error {
    case invalidDateFormat(string: String)
}

extension DateComponents {
    
    /**
     Initialize date components from a meerkat birthday string (either `yyyy-MM-dd` or `--MM-dd`)
     - Throws: `MeerkatDateComponentError.invalidDateFormat(String)`
     */
    init(_ meerkatString: String) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: meerkatString) {
            self = Calendar.current.dateComponents([.calendar, .year, .month, .day], from: date)
        } else {
            dateFormatter.dateFormat = "--MM-dd"
            
            if let date = dateFormatter.date(from: meerkatString) {
                self = Calendar.current.dateComponents([.calendar, .month, .day], from: date)
            } else {
                throw MeerkatDateComponentError.invalidDateFormat(string: meerkatString)
            }
        }
    }
}
