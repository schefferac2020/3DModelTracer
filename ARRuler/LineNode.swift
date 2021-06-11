//
//  LineNode.swift
//  ARRuler
//
//  Created by Drew Scheffer on 6/8/21.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class LineNode: NSObject {
    let startNode: SCNNode
    let endNode: SCNNode
    var lineNode: SCNNode?
    var sceneView: ARSCNView?
    private var recentFocusSquarePositions = [SCNVector3]()
    
    init(startPos: SCNVector3, scnView: ARSCNView) {
        func buildSphere(color: UIColor) -> SCNSphere {
            let dot = SCNSphere(radius: 1)
            dot.firstMaterial?.diffuse.contents = color
            dot.firstMaterial?.lightingModel = .constant
            dot.firstMaterial?.isDoubleSided = true
            return dot
        }
        
        self.sceneView = scnView
        
        startNode = SCNNode(geometry: buildSphere(color: .blue))
        startNode.scale = SCNVector3(1/400.0, 1/400.0, 1/400.0)
        startNode.position = startPos
        sceneView?.scene.rootNode.addChildNode(startNode)
        
        endNode = SCNNode(geometry: buildSphere(color: .red))
        endNode.scale = SCNVector3(1/400.0, 1/400.0, 1/400.0)
        
        lineNode = nil
        
        super.init()
    }
    
    deinit {
        removeFromParent()
    }
    
    public func updatePosition (pos: SCNVector3, camera: ARCamera?) -> Float {
        let posEnd = updateTransform(for: pos, camera: camera)
        
        if endNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(endNode)
        }
        endNode.position = posEnd
        
        //let posStart = startNode.position
        
        lineNode?.removeFromParentNode()
        lineNode = lineBetweenNodes(node1: startNode, node2: endNode)
        sceneView?.scene.rootNode.addChildNode(lineNode!)
        
        return 0.0
    }
    
    func lineBetweenNodes(node1: SCNNode, node2: SCNNode) -> SCNNode {
        let lineNode = SCNGeometry.cylinderLine(from: node1.position, to: node2.position, segments: 16)
        return lineNode
    }
    
    //MARK: - Private
    
    func removeFromParent() {
        startNode.removeFromParentNode()
        endNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
    }
    
    private func updateTransform(for position: SCNVector3, camera: ARCamera?) -> SCNVector3 {
        recentFocusSquarePositions.append(position)
        recentFocusSquarePositions.keepLast(1)
        
        if let average = recentFocusSquarePositions.first {
            return average
        }
        
        return SCNVector3Zero
    }
    
    private func normalize(_ angle: Float, forMinimalRotationTo ref: Float) -> Float {

        var normalized = angle
        while abs(normalized - ref) > Float.pi / 4 {
            if angle > ref {
                normalized -= Float.pi / 2
            } else {
                normalized += Float.pi / 2
            }
        }
        return normalized
    }
    
    
}
