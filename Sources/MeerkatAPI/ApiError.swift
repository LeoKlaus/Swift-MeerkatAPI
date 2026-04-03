//
//  ApiError.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 29.03.26.
//


import Foundation

public enum ApiError: Error, Sendable {
    case unauthorized
    case forbidden
    case notFound
    case invalidResponse(Data, URLResponse?)
    case unexpectedHTTPStatus(Data, Int)
}
