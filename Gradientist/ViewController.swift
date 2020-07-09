//
//  ViewController.swift
//  Gradientist
//
//  Created by Kim Seungha on 2020/07/05.
//  Copyright © 2020 Kim Seungha. All rights reserved.
//

import UIKit
import SceneKit

struct Coord: Hashable {
    let r: Int
    let g: Int
    let b: Int
}

class ViewController: UIViewController {
    @IBOutlet weak var cubeGridView: CubeGridView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var picker: UIPickerView!
    
    let pickerData = CubeGridVisualization.allCases
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAction()
    }

    private func setupView() {
        view.backgroundColor = .white
        slider.value = 1.0
        picker.delegate = self
    }

    private func setupAction() {
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }

    @objc func sliderChanged() {
        cubeGridView.currentValue = slider.value
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
        case .sphere:
            return "Sphere"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cubeGridView.pickedVisualization = pickerData[picker.selectedRow(inComponent: 0)]
    }
}
