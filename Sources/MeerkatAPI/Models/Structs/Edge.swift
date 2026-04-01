//
//  Edge.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 01.04.26.
//

import Foundation

public struct Edge: Codable {
    public let id: String
    public let source: String
    public let target: String
    public let type: EdgeType
    public let label: String
}
