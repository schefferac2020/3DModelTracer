//
//  ViewController.swift
//  ARRuler
//
//  Created by Drew Scheffer on 6/5/21.
//

import UIKit
import SceneKit
import ARKit
import Foundation
import Vision

enum DrawingState {
    case NOT_SET, PLACING_NODES, EXTENDING
}

class MainViewController: UIViewController, ARSCNViewDelegate {

    
    let orange_clickable = UIColor(red: 251/255, green: 147/255, blue: 0/255, alpha: 1.0)
    let orange_disabled = UIColor(red: 251/255, green: 147/255, blue: 0/255, alpha: 0.5)
    
    let red_enabled = UIColor(red: 245/255, green: 71/255, blue: 72/255, alpha: 1.0)
    let red_disabled = UIColor(red: 245/255, green: 71/255, blue: 72/255, alpha: 0.5)
    
    //@IBOutlet var sceneView: ARSCNView!
    var drawing_state = DrawingState.NOT_SET
    
    var linesGroup: LineGroup?
    var topLinesGroup: LineGroup?
    var allLineGroups: [LineGroup] = []
    var connectors: [SCNNode] = []
    
    let path = UIBezierPath()
    
    private let sceneView: ARSCNView =  ARSCNView(frame: UIScreen.main.bounds)
    private let indicator = UIImageView()
    private let resultLabel = UILabel()
    
    @IBOutlet weak var addPointButton: RoundedButton!
    @IBOutlet weak var completedButton: RoundedButton!
    @IBOutlet weak var moreButton: RoundedButton!
    @IBOutlet weak var horizStack: UIStackView!
    @IBOutlet weak var shareButton: RoundedButton!
    @IBOutlet weak var redoButton: RoundedButton!
    @IBOutlet weak var vertStack: UIStackView!
    
    var screenCenter: CGPoint?
    var focusSquare: FocusSquare?
    
    var moreToggled: Bool = false
    
    var areaValue: Double? {
        didSet{
            if let m = areaValue {
                DispatchQueue.main.async {
                    self.resultLabel.text = String(format: "%.1f cm^2", m)
                }
            }else{
                DispatchQueue.main.async {
                    self.resultLabel.text = String(format: "%.1f cm^2", 0.00)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout_view()
                
    }
    
    func layout_view(){
        self.screenCenter = self.sceneView.bounds.mid
        //screenCenter = self.indicator.center
        setupFocusSquare()
        
        let width = view.bounds.width
        let height = view.bounds.height
        view.backgroundColor = UIColor.black
        
        view.addSubview(sceneView)
        sceneView.frame = view.bounds
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints] //Shows the feature points
        sceneView.autoenablesDefaultLighting = true
        
        
        let resultLabelView = UIView()
        resultLabelView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        resultLabelView.layer.cornerRadius = 20
        resultLabelView.clipsToBounds = true
        resultLabelView.frame = CGRect(x: 30, y: 30, width: width - 60, height: 90)
        
        view.addSubview(resultLabelView)
        
        indicator.image = K.Image.Indicator.green
        // = orange_clickable
        
        indicator.image = indicator.image?.withRenderingMode(.alwaysTemplate)
        indicator.tintColor = orange_clickable
        
        indicator.frame = CGRect(x: (width - 60)/2, y: (height - 60)/2, width: 60, height: 60)
        view.addSubview(indicator)
        
        resultLabel.textAlignment = .center
        resultLabel.textColor = .black
        resultLabel.numberOfLines = 1
        resultLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        resultLabel.frame = resultLabelView.frame.insetBy(dx: 10, dy: 10)
        resultLabel.text = "0.0 cm^2"
        view.addSubview(resultLabel)
        
        addPointButton.defaultColor = orange_clickable
        addPointButton.highlightedColor = orange_disabled
        
        completedButton.defaultColor = orange_disabled
        completedButton.highlightedColor = orange_disabled
        
        moreButton.defaultColor = orange_clickable
        moreButton.highlightedColor = orange_disabled
        
        shareButton.defaultColor = orange_clickable
        shareButton.highlightedColor = orange_disabled
        
        redoButton.defaultColor = red_enabled
        redoButton.highlightedColor = red_disabled
        
        view.bringSubviewToFront(horizStack)
        view.bringSubviewToFront(vertStack)
        
        redoButton.isHidden = true
        shareButton.isHidden = true
    }
    
    func setupFocusSquare() {
            self.focusSquare?.isHidden = true
            self.focusSquare?.removeFromParentNode()
            self.focusSquare = FocusSquare()
            self.sceneView.scene.rootNode.addChildNode(self.focusSquare!)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.updateLine()
        self.updateFocusSquare()
        self.updateConnectors() // Has to be after update line
        
        if (drawing_state == DrawingState.EXTENDING){
            //allLineGroups[1].update_heights(newHeights: 0.0)
            
            let (cam_direction, cam_position) = self.getUserVector()
            
            
            
            let vector1 = allLineGroups[0].lines[0].endNode.position - allLineGroups[0].lines[0].startNode.position // TODO < -- make this the nodes that are farthest from the user's position
            let vector2 = allLineGroups[1].lines[0].startNode.position - allLineGroups[0].lines[0].startNode.position
            
            let plane_normal = vector1.cross(other: vector2)
            let plane_point = allLineGroups[0].lines[0].endNode.position
            
            let intersection_point = lineIntersection(planePoint: plane_point, planeNormal: plane_normal, linePoint: cam_position, lineDirection: cam_direction)
            
            if let int_pt = intersection_point {
                let height = int_pt.y
                allLineGroups[1].update_heights(newHeights: height)
            }
//            let important_node = allLineGroups[0].finalLine?.startNode
//            let imporant_node_pos = important_node!.position
//
//            let cam_to_node_ray =  SCNVector3(imporant_node_pos.x - cam_position.x, imporant_node_pos.y - cam_position.y, imporant_node_pos.z - cam_position.z)
//
//            let surface_normal = SCNVector3(0, 1, 0)
//
//            let s = cam_to_node_ray.length()
            
//            let theta1 = angle_between_vectors(vec1: cam_direction, vec2: cam_to_node_ray)
//            let theta2 = angle_between_vectors(vec1: cam_to_node_ray, vec2: surface_normal)
//
//            let theta3 = Float.pi - theta1 - theta2
//
//            let height = s * sin(theta1) / sin(theta3)
//
//
//            theta1 < 0.2 ? allLineGroups[1].update_heights(newHeights: 0.01) : allLineGroups[1].update_heights(newHeights: height)
            
        }
        
    }
    
    public func lineIntersection(planePoint: SCNVector3, planeNormal: SCNVector3, linePoint: SCNVector3, lineDirection: SCNVector3) -> SCNVector3? {
        if (planeNormal.dot(with: lineDirection.normalize()) == 0){
            return nil
        }
        
        let t = (planeNormal.dot(with: planePoint) - planeNormal.dot(with: linePoint)) / planeNormal.dot(with: lineDirection.normalize())
        return linePoint + lineDirection.normalize().scale(factor: t)
    }
    
    
    func updateFocusSquare() {
        DispatchQueue.main.async {
            
            self.focusSquare?.unhide()
            
            let (world_transform, planeAnchor, _) = self.sceneView.worldPositionFromScreenPosition(self.indicator.center, objectPos: nil)
            let worldPos = world_transform?.translation
            if let worldPos = worldPos {
                    self.focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.sceneView.session.currentFrame?.camera)
            }
        }
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // returns direction, position vectors
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    func updateLine() {
        let result = sceneView.worldPositionFromScreenPosition(self.indicator.center, objectPos: nil)
        guard let transform = result.world_transform else { return; }
        
        let position: SCNVector3? = SCNVector3.transformToPosition(result.world_transform!)
        if let p = position {
            let camera = self.sceneView.session.currentFrame?.camera
            let cameraPos = SCNVector3.transformToPosition(camera!.transform)
            //Do something with the current camera position
            print(cameraPos)
            
            guard let group = linesGroup else {
                return;
            }
            let area = group.updatePosition(pos: p, camera: camera)
            areaValue = Double(area)
            var other_pos = p
            other_pos.y += 0.02
            topLinesGroup?.updatePosition(pos: other_pos, camera: camera)
            //Do something with the area
            print(area)
        }
    }
    
    func lineBetweenNodes(node1: SCNNode, node2: SCNNode) -> SCNNode {
        let lineNode = SCNGeometry.cylinderLine(from: node1.position, to: node2.position, segments: 16)
        return lineNode
    }
    
    func updateConnectors() {
        for connector in connectors{
            connector.removeFromParentNode()
        }
        
        
        
        /*if let bot_lines = linesGroup?.lines, let top_lines = topLinesGroup?.lines {
            for i in 0..<top_lines.count {
                let top_node = top_lines[i].startNode
                let bot_node = bot_lines[i].startNode
                
                let line = lineBetweenNodes(node1: top_node, node2: bot_node)
                self.sceneView.scene.rootNode.addChildNode(line)
                connectors.append(line)
            }
        }else*/
        if allLineGroups.count >= 2{
            let bot_lines = allLineGroups[0].lines
            let top_lines = allLineGroups[1].lines
            for i in 0..<top_lines.count {
                let top_node = top_lines[i].startNode
                let bot_node = bot_lines[i].startNode
                
                let line = lineBetweenNodes(node1: top_node, node2: bot_node)
                self.sceneView.scene.rootNode.addChildNode(line)
                connectors.append(line)
            }
            let bot_node = allLineGroups[0].finalLine!.endNode
            let top_node = allLineGroups[1].finalLine!.endNode
            
            let line = lineBetweenNodes(node1: top_node, node2: bot_node)
            self.sceneView.scene.rootNode.addChildNode(line)
            connectors.append(line)
            
            
        }else{
            return
        }

    }
    
    //MARK: - IBActions
    @IBAction func moreButtonPressed(_ sender: Any) {
        let dur = 0.4
        let op = UIView.AnimationOptions.transitionCrossDissolve
        
        if (moreToggled){
            if self.shareButton.isHidden == false {
                UIView.transition(with: shareButton, duration: 1*dur,
                                  options: op,
                                  animations: {
                                    self.shareButton.isHidden = true
                              })
            }
            UIView.transition(with: redoButton, duration: 2*dur,
                              options: op,
                              animations: {
                                self.redoButton.isHidden = true
                          })
        }else{
            UIView.transition(with: redoButton, duration: 1*dur,
                              options: op,
                              animations: {
                                self.redoButton.isHidden = false
                          })
            if allLineGroups.count != 0 {
                UIView.transition(with: shareButton, duration: 3*dur,
                                  options: op,
                                  animations: {
                                    self.shareButton.isHidden = false
                              })
            }
            
            
        }
        
        
        moreToggled = !moreToggled
        moreButton.defaultColor = moreToggled ? orange_disabled : orange_clickable
        
    }
    
    
    @IBAction func placeButtonPressed(_ sender: Any) {
        self.placePoint(sender as! UIButton)
        
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        self.finishAction(sender as! UIButton)
    }
    
    @IBAction func redoButtonPressed(_ sender: Any) {
        resetEverything()
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        exportObject(sender as! UIButton)
    }
    
    
}

@objc private extension MainViewController{
    func placePoint(_ sender: UIButton){
        drawing_state = DrawingState.PLACING_NODES
        
        if linesGroup?.lines.count ?? 0 >= 1{
            completedButton.defaultColor = orange_clickable
        }else{
            completedButton.defaultColor = orange_disabled
        }
        
        
        if let group = linesGroup {
            group.add_line()
            topLinesGroup?.add_line()
        }else{
            let result = sceneView.worldPositionFromScreenPosition(self.indicator.center, objectPos: nil)
            let position: SCNVector3? = SCNVector3.transformToPosition(result.world_transform!)
            
            if let p = position {
                linesGroup = LineGroup(startPos: p, scnView: sceneView)
                var other_pos = p
                other_pos.y += 0.02
                topLinesGroup = LineGroup(startPos: other_pos, scnView: sceneView, is_top_part: true)
            }
        }
    }
    
    func finishAction(_ sender: UIButton) {
        
        if (drawing_state == DrawingState.EXTENDING){ //We have completed a 3d figure
            drawing_state = DrawingState.NOT_SET
            ObjectFactory.generate_points(allLineGroups: allLineGroups)
            
            if (moreToggled){
                UIView.transition(with: shareButton, duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.shareButton.isHidden = false
                              })
                
            }
            return
        }
        
        guard let lineGrp = linesGroup, lineGrp.lines.count >= 2 else{
            linesGroup = nil
            topLinesGroup = nil
            return
        }
        allLineGroups.append(lineGrp)
        allLineGroups.append(topLinesGroup!)
        topLinesGroup?.unhide_everything()
        linesGroup = nil
        topLinesGroup = nil
        
        drawing_state = DrawingState.EXTENDING
        
    }
    
    func exportObject(_ sender: UIButton) {
        //Write all of the feature points to a string
        resetEverything()
        performSegue(withIdentifier: K.Segues.toModify, sender: nil)
    }
    
    func resetEverything() {
        drawing_state = DrawingState.NOT_SET
        
        self.linesGroup = nil
        self.topLinesGroup = nil
        self.allLineGroups = []
        
        for connector in connectors{
            connector.removeFromParentNode()
        }
        self.connectors = []
        
        shareButton.isHidden = true
        
        areaValue = 0.00
    }
}
