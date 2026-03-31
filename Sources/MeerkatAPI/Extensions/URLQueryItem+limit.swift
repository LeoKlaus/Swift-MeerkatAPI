//
//  URLQueryItem+limit.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 31.03.26.
//

import Foundation

public extension URLQueryItem {
    init(limit: Int) {
        self.init(name: "limit", value: String(limit))
    }
}
