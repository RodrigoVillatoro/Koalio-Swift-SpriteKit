//
//  SKTutils.swift
//  Koalio
//
//  Created by Rodrigo Villatoro on 7/6/14.
//  Copyright (c) 2014 RVD. All rights reserved.
//

import Foundation
import SpriteKit

func CGPointMultiplyScalar(a: CGPoint, b: CGFloat) -> CGPoint {
    return CGPointMake(a.x * b, a.y * b)
}

func CGPointAdd(a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPointMake(a.x + b.x, a.y + b.y)
}

func CGPointSubtract(a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPointMake(a.x - b.x, a.y - b.y)
}

func Clamp(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    return value < min ? min : value > max ? max : value
}

