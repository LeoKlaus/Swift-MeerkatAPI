//
//  TimelineEntry.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 05.04.26.
//

import Foundation

public protocol TimelineEntry: Identifiable {
    var uuid: UUID { get }
    var time: Date? { get }
}
