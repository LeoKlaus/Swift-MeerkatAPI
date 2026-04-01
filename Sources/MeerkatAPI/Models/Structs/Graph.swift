//
//  Graph.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 01.04.26.
//

import Foundation

public struct Graph: Codable {
    public let nodes: [Node]
    public let edges: [Edge]
}
