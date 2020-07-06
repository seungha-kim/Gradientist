//
//  ViewController.swift
//  Gradientist
//
//  Created by Kim Seungha on 2020/07/05.
//  Copyright © 2020 Kim Seungha. All rights reserved.
//

import UIKit
import SceneKit

enum ZoomState {
    case idle
    case zooming(start: Double)
}

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: SCNView!

    let geometryNode = SCNNode()
    let cameraNode = SCNNode()
    var currentAngle: Float = -.pi / 4
    var zoomState: ZoomState = .idle
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
    }
    
    func setupView() {
        view.backgroundColor = .gray
        sceneView.backgroundColor = .gray
    }
    
    func setupScene() {
        let scene = SCNScene()
        
        // light
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = .ambient
        omniLightNode.light!.color = UIColor.black
        omniLightNode.position = SCNVector3(0, 50, 50)
        scene.rootNode.addChildNode(omniLightNode)
        
        // camera
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 30.0
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 32, 32)
        cameraNode.eulerAngles = SCNVector3(-Double.pi / 4, 0, 0)
        scene.rootNode.addChildNode(cameraNode)
        
        // box
        let protoBox = SCNBox(width: 0.8, height: 0.8, length: 0.8, chamferRadius: 0.0)
        for i in 0..<16 {
            for j in 0..<16 {
                for k in 0..<16 {
                    let i = Float(i), j = Float(j), k = Float(k)
                    let box = protoBox.copy() as! SCNBox
                    let material = SCNMaterial()
                    material.diffuse.contents = UIColor(
                        red: CGFloat(i / 16.0),
                        green: CGFloat(j / 16.0),
                        blue: CGFloat(k / 16.0),
                        alpha: 1.0
                    )
                    box.firstMaterial = material
                    let boxNode = SCNNode(geometry: box)
                    boxNode.position = SCNVector3(Float(i), Float(j), Float(k))
                    geometryNode.addChildNode(boxNode)
                }
            }
        }

        // scene
        scene.rootNode.addChildNode(geometryNode)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(sender:)))
        sceneView.addGestureRecognizer(panRecognizer)
        sceneView.addGestureRecognizer(pinchRecognizer)
        sceneView.scene = scene
        
        updateGeometryTransform(angle: currentAngle)
    }
    
    private func updateGeometryTransform(angle: Float) {
        geometryNode.transform = SCNMatrix4Mult(
            SCNMatrix4MakeTranslation(-7.5, -7.5, -7.5),
            SCNMatrix4MakeRotation(angle, 0, 1, 0)
        )
    }
    
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        var newAngle = Float(translation.x) * Float(.pi / 180.0)
        newAngle += currentAngle
        updateGeometryTransform(angle: newAngle)
        
        if (sender.state == .ended) {
            currentAngle = newAngle
        }
    }
    
    @objc func pinchGesture(sender: UIPinchGestureRecognizer) {
        let mitigation: Double = 0.8
        let compensate: Double = 1.0 - mitigation
        let scale = Double(sender.scale) * mitigation + compensate
        switch (zoomState) {
        case .idle:
            zoomState = .zooming(start: cameraNode.camera!.orthographicScale)
        case .zooming(start: let start):
            let z = max(10.0, min(50.0, start / scale))
            cameraNode.camera!.orthographicScale = z
            if (sender.state == .ended) {
                zoomState = .idle
            }
        }
    }
}
