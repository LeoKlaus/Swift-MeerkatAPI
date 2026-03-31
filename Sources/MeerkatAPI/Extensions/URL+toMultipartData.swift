//
//  URL+toMultipartData.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 31.03.26.
//

import Foundation

public extension URL {
    /**
     Generate body data for a multipart form request for uploading an image
     - Parameter Boundary: Boundary for the multipart form
     
     - Returns: Data representation of the multipart form body
     */
    func toMultipartData(with boundary: String) throws -> Data {
        var body = Data()
        
        let filename = self.lastPathComponent
        let data = try Data(contentsOf: self)
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(self.mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        return body
    }
}
