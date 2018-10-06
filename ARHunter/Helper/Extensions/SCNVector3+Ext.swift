//
//  SCNVector3+Ext.swift
//  ARHunter
//
//  Created by Nam Vu on 10/7/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//

import SceneKit

extension SCNVector3 {
    ///Calculates distance between vectors
    ///Doesn't include the y axis, matches functionality of CLLocation 'distance' function.
    func distance(to anotherVector: SCNVector3) -> Float {
        return sqrt(pow(anotherVector.x - x, 2) + pow(anotherVector.z - z, 2))
    }
}
