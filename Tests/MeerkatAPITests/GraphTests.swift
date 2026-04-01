//
//  GraphTests.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 01.04.26.
//

import Testing
import Foundation
@testable import MeerkatAPI

@Suite struct GraphTests {
    @Test func testDecodeGraph() throws {
        let json = """
        {
            "nodes": [
                {
                    "id": "c-1",
                    "type": "contact",
                    "label": "Matt Smith",
                    "photo_thumbnail": "data:image/jpeg;base64...",
                    "circles": [
                        "Doctor Who",
                        "Matts Family"
                    ]
                },
                {
                    "id": "c-2",
                    "type": "contact",
                    "label": "David Smith",
                    "circles": [
                        "Matts Family"
                    ]
                },
                {
                    "id": "c-3",
                    "type": "contact",
                    "label": "Lynne Smith",
                    "circles": [
                        "Matts Family"
                    ]
                },
                {
                    "id": "a-1",
                    "type": "activity",
                    "label": "Walk in the Park"
                }
            ],
            "edges": [
                {
                    "id": "r-2",
                    "source": "c-1",
                    "target": "c-3",
                    "type": "relationship",
                    "label": "Mother"
                },
                {
                    "id": "r-3",
                    "source": "c-1",
                    "target": "c-2",
                    "type": "relationship",
                    "label": "Father"
                },
                {
                    "id": "ae-1-1",
                    "source": "a-1",
                    "target": "c-1",
                    "type": "activity",
                    "label": "Walk in the Park"
                },
                {
                    "id": "ae-1-2",
                    "source": "a-1",
                    "target": "c-2",
                    "type": "activity",
                    "label": "Walk in the Park"
                },
                {
                    "id": "ae-1-3",
                    "source": "a-1",
                    "target": "c-3",
                    "type": "activity",
                    "label": "Walk in the Park"
                }
            ]
        }
        """
        
        let jsonData = Data(json.utf8)
        
        let graph = try JSONDecoder().decode(Graph.self, from: jsonData)
        
        #expect(graph.nodes.count == 4)
        #expect(graph.edges.count == 5)
        
        let firstNode = graph.nodes[0]
        let secondNode = graph.nodes[1]
        let thirdNode = graph.nodes[2]
        let fourthNode = graph.nodes[3]
        
        #expect(firstNode.id == "c-1")
        #expect(firstNode.type == .contact)
        #expect(firstNode.label == "Matt Smith")
        #expect(firstNode.photoThumbnail == "data:image/jpeg;base64...")
        #expect(firstNode.circles == ["Doctor Who", "Matts Family"])
        
        #expect(secondNode.id == "c-2")
        #expect(secondNode.type == .contact)
        #expect(secondNode.label == "David Smith")
        #expect(secondNode.photoThumbnail == nil)
        #expect(secondNode.circles == ["Matts Family"])
        
        #expect(thirdNode.id == "c-3")
        #expect(thirdNode.type == .contact)
        #expect(thirdNode.label == "Lynne Smith")
        #expect(thirdNode.photoThumbnail == nil)
        #expect(thirdNode.circles == ["Matts Family"])
        
        #expect(fourthNode.id == "a-1")
        #expect(fourthNode.type == .activity)
        #expect(fourthNode.label == "Walk in the Park")
        #expect(fourthNode.photoThumbnail == nil)
        #expect(fourthNode.circles == nil)
        
        
        let firstEdge = graph.edges[0]
        let secondEdge = graph.edges[1]
        let thirdEdge = graph.edges[2]
        let fourthEdge = graph.edges[3]
        let fifthEdge = graph.edges[4]
        
        
        #expect(firstEdge.id == "r-2")
        #expect(firstEdge.source == "c-1")
        #expect(firstEdge.target == "c-3")
        #expect(firstEdge.type == .relationship)
        #expect(firstEdge.label == "Mother")
            
        #expect(secondEdge.id == "r-3")
        #expect(secondEdge.source == "c-1")
        #expect(secondEdge.target == "c-2")
        #expect(secondEdge.type == .relationship)
        #expect(secondEdge.label == "Father")
        
        #expect(thirdEdge.id == "ae-1-1")
        #expect(thirdEdge.source == "a-1")
        #expect(thirdEdge.target == "c-1")
        #expect(thirdEdge.type == .activity)
        #expect(thirdEdge.label == "Walk in the Park")
        
        #expect(fourthEdge.id == "ae-1-2")
        #expect(fourthEdge.source == "a-1")
        #expect(fourthEdge.target == "c-2")
        #expect(fourthEdge.type == .activity)
        #expect(fourthEdge.label == "Walk in the Park")
        
        #expect(fifthEdge.id == "ae-1-3")
        #expect(fifthEdge.source == "a-1")
        #expect(fifthEdge.target == "c-3")
        #expect(fifthEdge.type == .activity)
        #expect(fifthEdge.label == "Walk in the Park")
    }
}
