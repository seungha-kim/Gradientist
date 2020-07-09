//
//  CubeGridView.swift
//  Gradientist
//
//  Created by Kim Seungha on 2020/07/09.
//  Copyright © 2020 Kim Seungha. All rights reserved.
//

import UIKit
import SceneKit

class CubeGridView: SCNView {
    var boxes = [Coord: SCNNode]()
    let geometryNode = SCNNode()
    let cameraNode = SCNNode()
    var currentValue: Float = 1.0 {
        didSet {
            update()
        }
    }
    var pickedVisualization: CubeGridVisualization = .redToBlack {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        scene = SCNScene()
        
        // light
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = .ambient
        omniLightNode.light!.color = UIColor.black
        omniLightNode.position = SCNVector3(0, 50, 50)
        scene!.rootNode.addChildNode(omniLightNode)
        
        // camera
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 30.0
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 32, 32)
        cameraNode.eulerAngles = SCNVector3(-Double.pi / 4, 0, 0)
        scene!.rootNode.addChildNode(cameraNode)
        
        // box
        let protoBox = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        for r in 0..<16 {
            for g in 0..<16 {
                for b in 0..<16 {
                    let rf = Float(r), gf = Float(g), bf = Float(b)
                    let box = protoBox.copy() as! SCNBox
                    let material = SCNMaterial()
                    material.diffuse.contents = UIColor(
                        red: CGFloat(rf / 15.0),
                        green: CGFloat(gf / 15.0),
                        blue: CGFloat(bf / 15.0),
                        alpha: 1.0
                    )
                    box.firstMaterial = material
                    let boxNode = SCNNode(geometry: box)
                    boxNode.position = SCNVector3(gf, bf, rf)
                    geometryNode.addChildNode(boxNode)
                    boxes[Coord(r: r, g: g, b: b)] = boxNode
                }
            }
        }

        // scene
        scene!.rootNode.addChildNode(geometryNode)
        allowsCameraControl = true
    }
    
    private func update() {
        let predicate = pickedVisualization.getPredicate(currentValue: currentValue, gridLength: 15.0)
        for r in 0..<16 {
            for g in 0..<16 {
                for b in 0..<16 {
                    let node = boxes[Coord(r: r, g: g, b: b)]!
                    let rf = Float(r), gf = Float(g), bf = Float(b)
                    node.opacity = predicate(rf, gf, bf) ? 0 : 1
                }
            }
        }
    }
}
