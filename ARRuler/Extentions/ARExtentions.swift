//
//  ARExtentions.swift
//  ARRuler
//
//  Created by Drew Scheffer on 6/8/21.
//

import Foundation
import ARKit
import SceneKit

extension SCNVector3{
    static func transformToPosition(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
}

extension ARSCNView {
    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         objectPos: SCNVector3?,
                                         infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        let sceneView = self
        
        
        let hitTestResults = sceneView.hitTest(position, types: .featurePoint)
        if let hitResult = hitTestResults.first{
            let planeHitPosition = SCNVector3.transformToPosition(hitResult.worldTransform)
            
            return (planeHitPosition, nil, false)
        }
        
        return (nil, nil, false)
    }
    
}

extension Array where Iterator.Element == SCNVector3 {
    var average: SCNVector3? {
        guard !isEmpty else {
            return nil
        }
        
        var ret = self.reduce(SCNVector3Zero) { (cur, next) -> SCNVector3 in
            var cur = cur
            cur.x += next.x
            cur.y += next.y
            cur.z += next.z
            return cur
        }
        let fcount = Float(count)
        ret.x /= fcount
        ret.y /= fcount
        ret.z /= fcount
        
        return ret
    }
}

extension RangeReplaceableCollection {
    mutating func keepLast(_ elementsToKeep: Int) {
        if count > elementsToKeep {
            self.removeFirst(count - elementsToKeep)
        }
    }
}
