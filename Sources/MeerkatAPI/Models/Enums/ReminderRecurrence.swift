//
//  ReminderRecurrence.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 31.03.26.
//

public enum ReminderRecurrence: String, Codable {
    case once
    case weekly
    case monthly
    case quarterly
    case sixMonths = "six-months"
    case yearly
}
