//
//  Node.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 01.04.26.
//

import Foundation

public struct Node: Codable {
    public let id: String
    public let type: NodeType
    public let label: String
    public let photoThumbnail: String?
    public let circles: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case label
        case photoThumbnail = "photo_thumbnail"
        case circles
    }
    
    public init(
        id: String,
        type: NodeType,
        label: String,
        photoThumbnail: String? = nil,
        circles: [String]? = nil
    ) {
        self.id = id
        self.type = type
        self.label = label
        self.photoThumbnail = photoThumbnail
        self.circles = circles
    }
}
