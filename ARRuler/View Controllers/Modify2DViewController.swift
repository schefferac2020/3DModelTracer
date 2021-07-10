//
//  ModifyViewController.swift
//  ARRuler
//
//  Created by Drew Scheffer on 7/10/21.
//

import UIKit
import SceneKit

class Modify2DViewController: UIViewController {
    
    var points : [CGPoint] = []
    var circles: [CircleView] = []
    var sublayers: [CAShapeLayer] = []
    
    let wanted_width: CGFloat = 300.0
    let wanted_height: CGFloat = 300.0
    
    let vert_offset: Double = 200
    var horiz_offset: Double = 10
    var scale = 1.0
    
    var objectFileUrl: URL?
        
    @IBOutlet weak var makeModelButton: RoundedButton!
    
    func fixPoints() {
        var min_x: CGFloat = 1000
        var min_y: CGFloat = 1000
        for point in points{
            min_x = min(min_x, point.x)
            min_y = min(min_y, point.y)
        }
        
        for i in 0..<points.count {
            points[i] = CGPoint(x: points[i].x - min_x, y: points[i].y - min_y)
        }
    }
    
    func setupObjFile() {
        let fileName = "layoutObject"
        let DocumentDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        objectFileUrl = DocumentDirUrl.appendingPathComponent(fileName).appendingPathExtension("obj")
        
        print("File Path: \(objectFileUrl!.path)")
    }
    
    func resetPointsAndCircles() {
        for circle in circles{
            circle.removeFromSuperview()
        }
        for layer in sublayers {
            layer.removeFromSuperlayer()
        }
        
        circles = []
        sublayers = []
        points = []
        
    }
    
    func setPointsAndCircles() {
        resetPointsAndCircles()
        
        //Create vector of points
        for vector in ObjectFactory.object_bottom_positions {
            points.append(CGPoint(x: Double(vector.x), y: Double(vector.z)))
        }
        
        fixPoints()
        //Get the scale
        self.scale = getScale()
        
        //Create the circles
        for point in points{
            let newCircle = CircleView(frame: CGRect(x: horiz_offset + scale * Double(point.x), y: vert_offset + scale * Double(point.y), width: 25, height: 25))
            
            newCircle.backgroundColor = .red
            view.addSubview(newCircle)
            newCircle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(gesture:))))
            
            circles.append(newCircle)
        }
        for i in 1...circles.count{
            let added_sub_layer = circles[i-1].lineTo(circle: circles[i % circles.count])
            sublayers.append(added_sub_layer)
            view.layer.addSublayer(added_sub_layer)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupObjFile()
        horiz_offset = (Double(view.frame.width) - Double(wanted_width)) / 2
        makeModelButton.defaultColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.7)
        
        setPointsAndCircles()
        
    }
    
    func getScale() -> Double {
        var max_x: CGFloat = -1.0
        var max_y: CGFloat = -1.0
        for point in points{
            max_x = max(max_x, point.x)
            max_y = max(max_y, point.y)
        }
        
        return min(Double(wanted_width / max_x), Double(wanted_height / max_y))
    }
    
    
    @objc func didPan(gesture: UIPanGestureRecognizer) {
        guard let circle = gesture.view as? CircleView else {
            return
        }
        if (gesture.state == .began) {
            circle.center = gesture.location(in: self.view)
        }
        let newCenter: CGPoint = gesture.location(in: self.view)
        let dX = newCenter.x - circle.center.x
        let dY = newCenter.y - circle.center.y
        circle.center = CGPoint(x: circle.center.x + dX, y: circle.center.y + dY)


        if let outGoingCircle = circle.outGoingCircle, let line = circle.outGoingLine, let path = circle.outGoingLine?.path {

            let newPath = UIBezierPath(cgPath: path)
            newPath.removeAllPoints()
            newPath.move(to: circle.center)
            newPath.addLine(to: outGoingCircle.center)
            line.path = newPath.cgPath
        }

        if let inComingCircle = circle.inComingCircle, let line = circle.inComingLine, let path = circle.inComingLine?.path {

            let newPath = UIBezierPath(cgPath: path)
            newPath.removeAllPoints()
            newPath.move(to: inComingCircle.center)
            newPath.addLine(to: circle.center)
            line.path = newPath.cgPath
        }
    }
    
    func shareObject(objectString: String?){
        guard let writeString = objectString else { return; }
        
        do {
            try writeString.write(to: objectFileUrl!, atomically: true, encoding: String.Encoding.utf8)
            
        }catch let error as NSError {
            print("Failed to write the URL")
            print(error)
        }
        
        //Present and export
        let path = objectFileUrl!.path
        let activityItem:NSURL = NSURL(fileURLWithPath: path)
        let activityVC = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    
    @IBAction func backToCameraButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        setPointsAndCircles()
    }
    
    @IBAction func createObjectPressed(_ sender: Any) {
        var bottomPositions: [SCNVector3] = []
        
        for circle in circles{
            let transformed_x = (Double(circle.center.x) - horiz_offset) / scale
            let transformed_y = (Double(circle.center.y) - vert_offset) / scale
            let newPos = SCNVector3(transformed_x, 0.0, transformed_y)
            bottomPositions.append(newPos)
        }
        
        ObjectFactory.object_bottom_positions = bottomPositions
        ObjectFactory.createObjectFormattedString()
        let objectString = ObjectFactory.object_string
        shareObject(objectString: objectString)
    }
    

}
