//
//  URLQueryItem+page.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 31.03.26.
//

import Foundation

public extension URLQueryItem {
    init(page: Int) {
        self.init(name: "page", value: String(page))
    }
}
