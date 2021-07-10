//
//  CircleView.swift
//  ARRuler
//
//  Created by Drew Scheffer on 7/10/21.
//

import Foundation
import UIKit

class CircleView : UIView {
    var outGoingLine : CAShapeLayer?
    var inComingLine : CAShapeLayer?
    var inComingCircle : CircleView?
    var outGoingCircle : CircleView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = self.frame.size.width / 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not Implimented")
    }
    
    deinit {
        inComingLine = nil
        outGoingLine = nil
    }

    func lineTo(circle: CircleView) -> CAShapeLayer {
        let path = UIBezierPath()
        path.move(to: self.center)
        path.addLine(to: circle.center)

        let line = CAShapeLayer()
        line.path = path.cgPath
        line.lineWidth = 5
        line.strokeColor = UIColor.red.cgColor
        circle.inComingLine = line
        outGoingLine = line
        outGoingCircle = circle
        circle.inComingCircle = self
        return line
    }
}
