//
//  ViewController.swift
//  ARRuler
//
//  Created by Drew Scheffer on 6/5/21.
//

import UIKit
import SceneKit
import ARKit

class MainViewController: UIViewController, ARSCNViewDelegate {

    //@IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var lineNodes = [SCNNode]()
    var textNode = SCNNode()
    
    private var line: LineNode?
    private var lines: [LineNode] = []
    
    let path = UIBezierPath()
    
    private let sceneView: ARSCNView =  ARSCNView(frame: UIScreen.main.bounds)
    private let indicator = UIImageView()
    private let setPointButton = UIButton()
    private let resultLabel = UILabel()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout_view()
        
    }
    
    func layout_view(){
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
        
        
        indicator.image = K.Image.Indicator.red
        indicator.frame = CGRect(x: (width - 60)/2, y: (height - 60)/2, width: 60, height: 60)
        view.addSubview(indicator)
        
        
        
        setPointButton.contentMode = .scaleAspectFill
        setPointButton.setBackgroundImage(K.Image.place, for: .normal)
        setPointButton.frame = CGRect(x: (width - 100)/2, y: (height - 100 - 20), width: 100, height: 100)
        setPointButton.addTarget(self, action: #selector(MainViewController.placePoint(_:)), for: .touchUpInside)
        view.addSubview(setPointButton)
        
        resultLabel.textAlignment = .center
        resultLabel.textColor = .black
        resultLabel.numberOfLines = 1
        resultLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        resultLabel.frame = resultLabelView.frame.insetBy(dx: 10, dy: 10)
        resultLabel.text = "0.00 cm"
        view.addSubview(resultLabel)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.updateLine()
    }
    
    
    func removeNodes(){
        for dot in dotNodes {
            dot.removeFromParentNode()
        }
        
        for line in lineNodes {
            line.removeFromParentNode()
        }
        dotNodes = [SCNNode]()
        lineNodes = [SCNNode]()
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if (dotNodes.count >= 2){
//            removeNodes()
//        }
//    }
    
    
    
    func drawShape(){
//        path.move(to: CGPoint(x: 0.1, y: 0.5))
//        path.addLine(to: CGPoint(x: 0.1, y: 0.1))
//        path.addLine(to: CGPoint(x: 0.3, y: 0.1))
//        path.addLine(to: CGPoint(x: -0.1, y: -0.5))
//        path.addLine(to: CGPoint(x: -0.1, y: -0.1))
//        path.addLine(to: CGPoint(x: -0.3, y: -0.1))

        path.close()
        
        let shape = SCNShape(path: path, extrusionDepth: 0.04)
        let color = UIColor.yellow
        shape.firstMaterial?.diffuse.contents = color
        shape.chamferRadius = 0.05
        
        let boltNode = SCNNode(geometry: shape)
        //boltNode.position.z = -1
        
        sceneView.scene.rootNode.addChildNode(boltNode)
    }
    
    func addDot (at hitResult: ARHitTestResult){
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                     hitResult.worldTransform.columns.3.y,
                                     hitResult.worldTransform.columns.3.z)
        
        
        let x_pos = (Double)(dotNode.position.x)
        let y_pos = (Double)(dotNode.position.y)
        let z_pos = (Double)(dotNode.position.z)
        if (dotNodes.count == 0){
            path.move(to: CGPoint(x: x_pos, y: z_pos))
        }else {
            path.addLine(to: CGPoint(x: x_pos, y: z_pos))
        }

        
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        
        
//        if dotNodes.count >= 2 {
//            calculateDistance()
//            addLine(start: dotNodes[0].position, end: dotNodes[1].position)
//        }
        
    }
    
    
    
    
    func addLine( start: SCNVector3, end: SCNVector3){
        let lineNode = SCNGeometry.cylinderLine(from: start, to: end, segments: 5)
        sceneView.scene.rootNode.addChildNode(lineNode)
        lineNodes.append(lineNode)
    }
    
    func calculateDistance() {
        let start = dotNodes.first!
        let end = dotNodes.last!
        
        var distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
             pow(end.position.y - start.position.y, 2) +
             pow(end.position.z - start.position.z, 2)
        )
        
        distance *= 100
        
        let distanceFormatted = String(format: "%.2f cm", abs(distance))
        updateText(text: distanceFormatted, atPosition: start.position)
    }
    
    func updateText( text: String, atPosition: SCNVector3 ) {
         textNode.removeFromParentNode()
     
         let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
         textGeometry.firstMaterial?.diffuse.contents = UIColor.systemRed
         
         textNode = SCNNode(geometry: textGeometry)
         textNode.position = SCNVector3(
             atPosition.x,
             atPosition.y + 0.01,
             atPosition.z
         )
     
         textNode.scale = SCNVector3(0.01, 0.01, 0.01)
         sceneView.scene.rootNode.addChildNode(textNode)
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
        let position = sceneView.worldPositionFromScreenPosition(self.indicator.center, objectPos: nil)
        if let p = position.position {
            let camera = self.sceneView.session.currentFrame?.camera
            let cameraPos = SCNVector3.transformToPosition(camera!.transform)
            //Do something with the current camera position
            print(cameraPos)
            
            guard let currentLine = line else {
                return;
            }
            let length = currentLine.updatePosition(pos: p, camera: camera)
            //Do something with the length
            
        }
    }
    
}

@objc private extension MainViewController{
    func placePoint(_ sender: UIButton){
        
        
        
        //This only works for single lines currently
        if let l = line {
            lines.append(l)
            line = nil
        }else{
            lines = []
            let startPos = sceneView.worldPositionFromScreenPosition(indicator.center, objectPos: nil, infinitePlane: false)
            if let p = startPos.position {
                line = LineNode(startPos: p, scnView: sceneView) // <-- TODO
            }
        }
        
        //addDot(at: hitResult)
        
        
        if (dotNodes.count >= 3){
            print("GOT HERE")
            drawShape()
        }
    }
}
