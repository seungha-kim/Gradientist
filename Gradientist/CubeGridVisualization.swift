//
//  CubeGridVisualization.swift
//  Gradientist
//
//  Created by Kim Seungha on 2020/07/09.
//  Copyright © 2020 Kim Seungha. All rights reserved.
//

import Foundation
import simd

enum CubeGridVisualization: CaseIterable {
    case redToBlack
    case greenToBlack
    case blueToBlack
    case whiteToBlack
    case cyanToRed
    case magentaToGreen
    case yellowToBlue
    case onion
    case sliceThroughBlackAndWhite
    case sphere
    
    func getPredicate(currentValue: Float, gridLength: Float) -> (Float, Float, Float) -> Bool {
        switch self {
        case .redToBlack:
            let value = currentValue * gridLength
            return { r, g, b in r > value }
        case .blueToBlack:
            let value = currentValue * gridLength
            return { r, g, b in b > value }
        case .greenToBlack:
            let value = currentValue * gridLength
            return { r, g, b in g > value }
        case .whiteToBlack:
            let value = currentValue * gridLength * 3.0
            return { r, g, b in r + g + b > value }
        case .cyanToRed:
            let value = currentValue * gridLength * 3.0 - gridLength
            return { r, g, b in -r + g + b > value }
        case .magentaToGreen:
            let value = currentValue * gridLength * 3.0 - gridLength
            return { r, g, b in r - g + b > value }
        case .yellowToBlue:
            let value = currentValue * gridLength * 3.0 - gridLength
            return { r, g, b in r + g - b > value }
        case .onion:
            let half = gridLength / 2.0
            let value = currentValue * half
            return { r, g, b in
                let peeledByR = abs(Float(r) - half) > value
                let peeledByG = abs(Float(g) - half) > value
                let peeledByB = abs(Float(b) - half) > value
                return peeledByR || peeledByG || peeledByB
            }
        case .sliceThroughBlackAndWhite:
            let (nx, ny, nz) = rotatedNormalOfSliceThroughBlackAndWhite(currentValue)
            return { r, g, b in
                let v = nx * r + ny * g + nz * b
                return v > 0.0
            }
        case .sphere:
            let half = gridLength / 2.0
            let sphereRadius = currentValue * sqrt(3 * pow(gridLength, 2.0)) / 2
            return { r, g, b in
                let distance = sqrt(pow(r - half, 2.0) + pow(g - half, 2.0) + pow(b - half, 2.0))
                return distance > sphereRadius
            }
        }
    }
}

func rotatedNormalOfSliceThroughBlackAndWhite(_ value: Float) -> (Float, Float, Float) {
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
