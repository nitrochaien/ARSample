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

open class ARAnnotation: NSObject {
    /// Title of annotation
    open var title: String?
    /// Location of annotation
    open var location: CLLocation?
    /// View for annotation. It is set inside ARViewController after fetching view from dataSource.
    internal(set) open var annotationView: ARAnnotationView?
    
    // Internal use only, do not set this properties
    internal(set) open var distanceFromUser: Double = 0
    internal(set) open var azimuth: Double = 0
    internal(set) open var verticalLevel: Int = 0
    internal(set) open var active: Bool = false
}
