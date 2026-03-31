//
//  Data+toMultipartData.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 31.03.26.
//

import Foundation
import UniformTypeIdentifiers

public extension Data {
    /**
     Generate body data for a multipart form request for uploading an image
     - Parameter Boundary: Boundary for the multipart form
     - Parameter fileName: Filename to use for the file upload
     - Parameter mimeType: UTType of the given data
     
     - Returns: Data representation of the multipart form body
     */
    public func toMultipartData(boundary: String, fileName: String, mimeType: UTType) throws -> Data {
        var body = Data()
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(self)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        return body
    }
}
