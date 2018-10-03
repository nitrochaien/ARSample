//
//  ARItem.swift
//  AR_Hunt
//
//  Created by Nam Vu on 9/20/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//

import UIKit
import CoreLocation
import SceneKit

struct ARItem {
  let itemDescription: String
  let location: CLLocation
  var itemNode: SCNNode?
}
