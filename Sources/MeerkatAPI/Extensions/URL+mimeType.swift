//
//  URL+mimeType.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 31.03.26.
//

import Foundation
import UniformTypeIdentifiers

public extension URL {
    /// Returns the uniform type identity for the given file
    var mimeType: String {
        return UTType(filenameExtension: pathExtension)?.preferredMIMEType ?? "application/jpeg"
    }
}
