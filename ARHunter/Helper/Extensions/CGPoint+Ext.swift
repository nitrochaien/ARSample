//
//  CGPoint+Ext.swift
//  ARHunter
//
//  Created by Nam Vu on 10/7/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//

import UIKit
import SceneKit

extension CGPoint {
    static func pointWithVector(vector: SCNVector3) -> CGPoint {
        return CGPoint(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
    
    func radiusContainsPoint(radius: CGFloat, point: CGPoint) -> Bool {
        let x = pow(point.x - self.x, 2)
        let y = pow(point.y - self.y, 2)
        let radiusValue = pow(radius, 2)
        
        return x + y <= radiusValue
    }
}
