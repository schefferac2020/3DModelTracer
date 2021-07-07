import Foundation
import UIKit
import SceneKit
import ARKit

extension SCNGeometry {
    
    class func triangleFrom(vector1: SCNVector3, vector2: SCNVector3, vector3: SCNVector3) -> SCNGeometry {

            let indices: [Int32] = [0, 1, 2]
            let source = SCNGeometrySource(vertices: [vector1, vector2, vector3])
            let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
            return SCNGeometry(sources: [source], elements: [element])
    }
    
    class func cylinderLine(from: SCNVector3, to: SCNVector3, segments: Int, color: UIColor = .white, rad: Float = 0.001) -> SCNNode {
        let radius = CGFloat(rad)
        let x1 = from.x
        let x2 = to.x
        
        let y1 = from.y
        let y2 = to.y
        
        let z1 = from.z
        let z2 = to.z

        let distance = sqrtf((x2 - x1) * (x2 - x1) +
                             (y2 - y1) * (y2 - y1) +
                             (z2 - z1) * (z2 - z1))

        let cylinder = SCNCylinder(radius: radius,
                                   height: CGFloat(distance))
        cylinder.radialSegmentCount = segments
        cylinder.firstMaterial?.diffuse.contents = color

        let lineNode = SCNNode(geometry: cylinder)
        lineNode.position = SCNVector3(((from.x + to.x)/2),
                                       ((from.y + to.y)/2),
                                       ((from.z + to.z)/2))
        lineNode.eulerAngles = SCNVector3(Float.pi/2,
                                          acos((to.z - from.z)/distance),
                                          atan2(to.y - from.y, to.x - from.x))
        return lineNode
    }
    
    class func rectLine(from: SCNVector3, to: SCNVector3, color: UIColor = .white, width: Float = 0.01) -> SCNNode {
        let wid = CGFloat(width)
        let x1 = from.x
        let x2 = to.x
        
        let y1 = from.y
        let y2 = to.y
        
        let z1 = from.z
        let z2 = to.z

        let distance = sqrtf((x2 - x1) * (x2 - x1) +
                             (y2 - y1) * (y2 - y1) +
                             (z2 - z1) * (z2 - z1))

        let rect = SCNBox(width: wid, height: CGFloat(distance), length: wid, chamferRadius: 0.0)
        //cylinder.radialSegmentCount = segments
        rect.firstMaterial?.diffuse.contents = color

        let lineNode = SCNNode(geometry: rect)
        lineNode.position = SCNVector3(((from.x + to.x)/2),
                                       ((from.y + to.y)/2),
                                       ((from.z + to.z)/2))
        lineNode.eulerAngles = SCNVector3(Float.pi/2,
                                          acos((to.z - from.z)/distance),
                                          atan2(to.y - from.y, to.x - from.x))
        return lineNode
    }
}
