//
//  ViewController.swift
//  Gradientist
//
//  Created by Kim Seungha on 2020/07/05.
//  Copyright © 2020 Kim Seungha. All rights reserved.
//

import UIKit
import SceneKit
import simd

enum ZoomState {
    case idle
    case zooming(start: Double)
}

enum PeelVisualization {
    case redToBlack
    case blueToBlack
    case greenToBlack
    case whiteToBlack
    case cyanToRed
    case magentaToGreen
    case yellowToBlue
    case onion
    case sliceThroughBlackAndWhite
}

struct Coord: Hashable {
    let r: Int
    let g: Int
    let b: Int
}

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var picker: UIPickerView!
    
    let pickerData: [PeelVisualization] = [
        .redToBlack,
        .blueToBlack,
        .greenToBlack,
        .whiteToBlack,
        .cyanToRed,
        .magentaToGreen,
        .yellowToBlue,
        .onion,
        .sliceThroughBlackAndWhite
    ]
    
    var boxes = [Coord: SCNNode]()
    
    let geometryNode = SCNNode()
    let cameraNode = SCNNode()
    var currentAngle: Float = -.pi / 4
    var zoomState: ZoomState = .idle
    var pickedVisualization: PeelVisualization = .redToBlack
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupAction()
        
    }
    
    private func rotatedNormalOfSliceThroughBlackAndWhite(value: Float) -> (Float, Float, Float) {
        // https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
        let theta = Double(value * .pi * 2)
        let v = SIMD3(x: 1.0, y: -1.0, z: 0)
        let k = SIMD3(x: sqrt(3.0) / 3.0, y: sqrt(3.0) / 3.0, z: sqrt(3.0) / 3.0)
        let c1: SIMD3 = v * cos(theta)
        let c2: SIMD3 = cross(k, v) * sin(theta)
        let c3: SIMD3 = k * dot(k, v) * (1 - cos(theta))
        let r = c1 + c2 + c3
        return (Float(r.x), Float(r.y), Float(r.z))
    }
    
    private func setupView() {
        view.backgroundColor = .white
        sceneView.backgroundColor = .white
        slider.value = 1.0
        picker.delegate = self
    }
    
    private func setupScene() {
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
        scene.rootNode.addChildNode(geometryNode)
        sceneView.allowsCameraControl = true
        sceneView.scene = scene
        
        updateGeometryTransform(angle: currentAngle)
    }
    
    private func setupAction() {
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    private func updateGeometryTransform(angle: Float) {
        geometryNode.transform = SCNMatrix4Mult(
            SCNMatrix4MakeTranslation(-7.5, -7.5, -7.5),
            SCNMatrix4MakeRotation(angle, 0, 1, 0)
        )
    }
    
    @objc func sliderChanged() {
        update()
    }
    
    private func update() {
        let value = slider.value
        switch (pickedVisualization) {
        case .redToBlack:
            updateByRedWay(value)
        case .blueToBlack:
            updateByBlueWay(value)
        case .greenToBlack:
            updateByGreenWay(value)
        case .whiteToBlack:
            updateByDiagonalWayWhiteToBlack(value)
        case .cyanToRed:
            updateByDiagonalWayCyanToRed(value)
        case .magentaToGreen:
            updateByDiagonalWayMagentaToGreen(value)
        case .yellowToBlue:
            updateByDiagonalWayYellowToBlue(value)
        case .onion:
            updateByOnion(value)
        case .sliceThroughBlackAndWhite:
            updateBySliceThroughBlackAndWhite(value)
        }
    }
    
    private func updateByRedWay(_ value: Float) {
        let value = Int(slider.value * 16)
        for r in 0..<16 {
            for g in 0..<16 {
                for b in 0..<16 {
                    let node = boxes[Coord(r: r, g: g, b: b)]!
                    node.opacity = r > value ? 0 : 1
                }
            }
        }
    }
    
    private func updateByGreenWay(_ value: Float) {
        let value = Int(slider.value * 16)
        for r in 0..<16 {
            for g in 0..<16 {
                for b in 0..<16 {
                    let node = boxes[Coord(r: r, g: g, b: b)]!
                    node.opacity = g > value ? 0 : 1
                }
            }
        }
    }
    
    private func updateByBlueWay(_ value: Float) {
        let value = Int(slider.value * 16)
        for r in 0..<16 {
            for g in 0..<16 {
                for b in 0..<16 {
                    let node = boxes[Coord(r: r, g: g, b: b)]!
                    node.opacity = b > value ? 0 : 1
                }
            }
        }
    }
    
    private func updateByDiagonalWayWhiteToBlack(_ value: Float) {
        let value = Int(slider.value * 45)
        for r in 0..<16 {
            for g in 0..<16 {
                for b in 0..<16 {
                    let node = boxes[Coord(r: r, g: g, b: b)]!
                    node.opacity = r + g + b > value ? 0 : 1
                }
            }
        }
    }
    
    private func updateByDiagonalWayCyanToRed(_ value: Float) {
        let value = Int(slider.value * 45) - 15
        for r in 0..<16 {
            for g in 0..<16 {
                for b in 0..<16 {
                    let node = boxes[Coord(r: r, g: g, b: b)]!
                    node.opacity = -r + g + b > value ? 0 : 1
                }
            }
        }
    }
    
    private func updateByDiagonalWayMagentaToGreen(_ value: Float) {
        let value = Int(slider.value * 45) - 15
        for r in 0..<16 {
            for g in 0..<16 {
                for b in 0..<16 {
                    let node = boxes[Coord(r: r, g: g, b: b)]!
                    node.opacity = r - g + b > value ? 0 : 1
                }
            }
        }
    }
    
    private func updateByDiagonalWayYellowToBlue(_ value: Float) {
        let value = Int(slider.value * 45) - 15
        for r in 0..<16 {
            for g in 0..<16 {
                for b in 0..<16 {
                    let node = boxes[Coord(r: r, g: g, b: b)]!
                    node.opacity = r + g - b > value ? 0 : 1
                }
            }
        }
    }
    
    private func updateByOnion(_ value: Float) {
        let value = value * 7.5
        for r in 0..<16 {
            for g in 0..<16 {
                for b in 0..<16 {
                    let node = boxes[Coord(r: r, g: g, b: b)]!
                    let peeledByR = abs(Float(r) - 7.5) > value
                    let peeledByG = abs(Float(g) - 7.5) > value
                    let peeledByB = abs(Float(b) - 7.5) > value
                    let peeled = peeledByR || peeledByG || peeledByB
                    node.opacity = peeled ? 0 : 1
                }
            }
        }
    }
    
    private func updateBySliceThroughBlackAndWhite(_ value: Float) {
        let (nx, ny, nz) = rotatedNormalOfSliceThroughBlackAndWhite(value: value)
        for r in 0..<16 {
            for g in 0..<16 {
                for b in 0..<16 {
                    let node = boxes[Coord(r: r, g: g, b: b)]!
                    let rf = Float(r), gf = Float(g), bf = Float(b)
                    let peeled: Bool = nx * rf + ny * gf + nz * bf > 0
                    node.opacity = peeled ? 0 : 1
                }
            }
        }
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch (pickerData[row]) {
        case .redToBlack:
            return "Red to Black"
        case .blueToBlack:
            return "Blue to Black"
        case .greenToBlack:
            return "Green to Black"
        case .whiteToBlack:
            return "White to Black"
        case .cyanToRed:
            return "Cyan to Red"
        case .magentaToGreen:
            return "Magenta to Green"
        case .yellowToBlue:
            return "Yellow to Blue"
        case .onion:
            return "Like Onion"
        case .sliceThroughBlackAndWhite:
            return "Slice through Black and White"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickedVisualization = pickerData[picker.selectedRow(inComponent: 0)]
        update()
    }
}
