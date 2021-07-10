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

class LineGroup: NSObject, NSCopying {
    
    
    var lines = [LineNode]()
    var curr_line: LineNode
    var finalLine: LineNode?
    var sceneView: ARSCNView
    var is_top: Bool
    
    init(startPos: SCNVector3, scnView: ARSCNView, is_top_part: Bool = false) {
        
        self.sceneView = scnView
        self.is_top = is_top_part
        
        let first_line = LineNode(startPos: startPos, scnView: scnView)
        curr_line = first_line
        
        lines.append(curr_line)
        super.init()
        hideLineIfTop(line: curr_line)
    }
    
    init(lines: [LineNode], curr_line: LineNode, finalLine: LineNode, scnView: ARSCNView, is_top_part: Bool = false) {
        self.lines = lines
        self.sceneView = scnView
        self.curr_line = curr_line
        self.finalLine = finalLine
        self.is_top = false
        
        super.init()
    }
    
    
    func copy(with zone: NSZone? = nil) -> Any {
        super.copy()
        let current_line_node = curr_line.copy() as! LineNode
        let final_line = finalLine?.copy() as! LineNode
        var new_lines = [LineNode]()
        for line in lines{
            new_lines.append(line.copy() as! LineNode)
        }
        let new = LineGroup(lines: new_lines, curr_line: current_line_node, finalLine: final_line, scnView: sceneView)
        return new
        
    }
    

    deinit {
        //TODO
    }
    
    public func update_heights(newHeights: Float){
        for line in lines {
            line.updateHeight(newHeight: newHeights)
        }
        finalLine?.updateHeight(newHeight: newHeights)
    }
    
    public func add_line(){
        let line = LineNode(startPos: curr_line.endNode.position, scnView: sceneView)
        curr_line = line
        hideLineIfTop(line: line)
        lines.append(line)
        update_final_line()
    }
    
    public func update_final_line(){
        finalLine?.removeFromParent()
        finalLine = nil // We have to this one
        
        if (lines.count > 1){
            let temp = LineNode(startPos: lines[0].startNode.position, scnView: sceneView)
            hideLineIfTop(line: temp)
            finalLine = temp
        }
    }
    
    
    
    public func updatePosition (pos: SCNVector3, camera: ARCamera?) -> Float {
        curr_line.updatePosition(pos: pos, camera: camera, is_hidden: is_top)
        finalLine?.updatePosition(pos: pos, camera: camera, is_hidden: is_top)
        
        if finalLine != nil {
            //Do calculations to find the area
            let area = surveyors_formula()
            return area
        }
        
        return 0.0 // This is the area if the above fails
    }
    
    func hideLineIfTop(line: LineNode) -> Void {
        if is_top {
            line.startNode.isHidden = true
            line.endNode.isHidden = true
            line.lineNode?.isHidden = true
        }
    }
    
    func unhide_everything() -> Void {
        for line in lines {
            line.startNode.isHidden = false
            line.endNode.isHidden = false
            line.lineNode?.isHidden = false
        }
        finalLine?.startNode.isHidden = false
        finalLine?.endNode.isHidden = false
        finalLine?.lineNode?.isHidden = false
    }
    
    //returns in cm^2
    func surveyors_formula() -> Float {
        var coordinates = [SCNVector3]()
        for line in lines {
            let current_coord = line.endNode.position
            coordinates.append(current_coord)
        }
        coordinates.append(finalLine!.startNode.position)
        
        //Do the area calculations
        var firstsum: Float = 0.0
        var secondsum: Float = 0.0
        for i in 0..<coordinates.count-1{
            firstsum += coordinates[i].x * coordinates[i+1].z
            secondsum += coordinates[i+1].x * coordinates[i].z
        }
        firstsum += coordinates.last!.x * coordinates.first!.z
        secondsum += coordinates.first!.x * coordinates.last!.z
        
        let area = (1/2) * abs(firstsum - secondsum)
        
        return area * 10000
    }
    
    //MARK: - Private

    
    
}

 
