//
//  FloatingPoint+Ext.swift
//  ARHunter
//
//  Created by Nam Vu on 10/7/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//

import UIKit

extension FloatingPoint {
    public var degreesToRadians: Self { return self * .pi / 180 }
    public var radiansToDegrees: Self { return self * 180 / .pi }
}
