//
//  ObjectFileFactory.swift
//  ARRuler
//
//  Created by Drew Scheffer on 7/7/21.
//
import UIKit
import SceneKit
import ARKit
import Foundation
import Vision


class ObjectFactory{
    static var object_string : String?
    
    static var height: Float?
    static var object_bottom_positions: [SCNVector3] = []
    static var fake_object_bottom_positions: [SCNVector3] = [SCNVector3(0.5, 0, 0), SCNVector3(0, 0, 1), SCNVector3(1, 0, 1)]
    
    static func generate_points(allLineGroups: [LineGroup]) -> Void {
        object_bottom_positions = []
        let bottom : LineGroup = allLineGroups[0]
        let top : LineGroup = allLineGroups[1]
        let start_point = top.finalLine!.startNode.position
        
        for line in top.lines {
            let current_pos = line.startNode.position
            object_bottom_positions.append(current_pos - start_point) // makes it relative to first point
        }
        object_bottom_positions.append(top.finalLine!.endNode.position - start_point)
        
        height = top.finalLine!.startNode.position.y - bottom.finalLine!.startNode.position.y
    }
    
    static func createObjectFormattedString() { // MUST call this after generating the points
        let num_verts = object_bottom_positions.count * 2
        var object_string = "#\(num_verts) verticies\n"
        
        //Add the vertexes
        object_string += "v \(object_bottom_positions[0].x) \(object_bottom_positions[0].y + height!) \(object_bottom_positions[0].z)\n"
        object_string += "v \(object_bottom_positions[0].x) \(object_bottom_positions[0].y) \(object_bottom_positions[0].z)\n"
        
        for i in 1..<object_bottom_positions.count{
            object_string += "v \(object_bottom_positions[i].x) \(object_bottom_positions[i].y) \(object_bottom_positions[i].z)\n"
            object_string += "v \(object_bottom_positions[i].x) \(object_bottom_positions[i].y + height!) \(object_bottom_positions[i].z)\n"
        }
        
        //Additional Settings
        object_string += "\n\ng all\ns 1\n"
        
        //Add the faces
        object_string += "f 1 2 3 4\n"
        object_string += "f 4 3 2 1\n"
        var curr_ind = 4
        
        
        while (curr_ind < num_verts){
            object_string += "f \(curr_ind) \(curr_ind-1) \(curr_ind + 1) \(curr_ind+2)\n"
            object_string += "f \(curr_ind+2) \(curr_ind+1) \(curr_ind-1) \(curr_ind)\n"
            curr_ind += 2
        }
        
        object_string += "f 1 2 \(num_verts - 1) \(num_verts)\n"
        object_string += "f \(num_verts) \(num_verts - 1) 2 1\n"
        
        
        var last_face = "2 "
        var last_face_revd = "2"
        curr_ind = 3
        
        while (curr_ind < num_verts){
            last_face += "\(curr_ind) "
            last_face_revd = "\(curr_ind) " + last_face_revd
            curr_ind += 2
        }
        
        object_string += "f \(last_face)\n"
        object_string += "f \(last_face_revd)\n"
        
        self.object_string = object_string
        
    }
}
