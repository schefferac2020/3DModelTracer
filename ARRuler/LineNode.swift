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

class LineNode: NSObject, NSCopying {
    
    
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
    
    init(startNode: SCNNode, endNode: SCNNode, lineNode: SCNNode?, sceneView: ARSCNView?) {
        self.startNode = startNode
        self.endNode = endNode
        self.lineNode = lineNode
        self.sceneView = sceneView

        super.init()
    }
    
    deinit {
        removeFromParent()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let new_line_node: LineNode = LineNode(startNode: startNode.clone(), endNode: endNode.clone(), lineNode: lineNode?.clone(), sceneView: sceneView)
        return new_line_node
    }
    
    public func updateHeight(newHeight: Float){
        //lineNode?.position.y += 0.0001
        
        
        startNode.position.y = newHeight
        endNode.position.y = newHeight
        lineNode?.removeFromParentNode()
        lineNode = lineBetweenNodes(node1: startNode, node2: endNode)
        sceneView?.scene.rootNode.addChildNode(lineNode!)
        
        //lineNode?.scale = SCNVector3(1.5, 1.0, 1.0)
        
        //lineNode?.transform = SCNMatrix4MakeTranslation(1.0, Float(newHeight / 2.0), 1.0)
    }
    
    
    public func updatePosition (pos: SCNVector3, camera: ARCamera?, is_hidden: Bool = false) -> Float {
        let posEnd = updateTransform(for: pos, camera: camera)
        
        if endNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(endNode)
        }
        endNode.position = posEnd
        
        //let posStart = startNode.position
        
        lineNode?.removeFromParentNode()
        lineNode = lineBetweenNodes(node1: startNode, node2: endNode)
        lineNode?.isHidden = is_hidden
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
        //Currently does not do any updating lol
        return position
//        return SCNVector3Zero
    }
}
