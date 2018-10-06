//
//  LocationNode.swift
//  ARHunter
//
//  Created by Nam Vu on 10/6/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//

import UIKit
import SceneKit
import CoreLocation

class LocationNode: SCNNode {
    //location of the node
    var location: CLLocation?
    
    //tag to find nodes already added to SceneLocationView
    var tag: String?
    
    ///Whether the location of the node has been confirmed.
    ///This is automatically set to true when you create a node using a location.
    ///Otherwise, this is false, and becomes true once the user moves 100m away from the node,
    ///except when the locationEstimateMethod is set to use Core Location data only,
    ///as then it becomes true immediately.
    public var locationConfirmed = false
    
    ///Whether a node's position should be adjusted on an ongoing basis
    ///based on its' given location.
    ///This only occurs when a node's location is within 100m of the user.
    ///Adjustment doesn't apply to nodes without a confirmed location.
    ///When this is set to false, the result is a smoother appearance.
    ///When this is set to true, this means a node may appear to jump around
    ///as the user's location estimates update,
    ///but the position is generally more accurate.
    ///Defaults to true.
    public var continuallyAdjustNodePositionWhenWithinRange = true
    
    ///Whether a node's position and scale should be updated automatically on a continual basis.
    ///This should only be set to false if you plan to manually update position and scale
    ///at regular intervals. You can do this with `SceneLocationView`'s `updatePositionOfLocationNode`.
    public var continuallyUpdatePositionAndScale = true
    
    init(location: CLLocation?) {
        self.location = location
        self.locationConfirmed = location != nil
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class LocationAnnotationNode: LocationNode {
    ///An image to use for the annotation
    ///When viewed from a distance, the annotation will be seen at the size provided
    ///e.g. if the size is 100x100px, the annotation will take up approx 100x100 points on screen.
    let image: UIImage
    
    ///Subnodes and adjustments should be applied to this subnode
    ///Required to allow scaling at the same time as having a 2D 'billboard' appearance
    let annotationNode: SCNNode
    
    ///Whether the node should be scaled relative to its distance from the camera
    ///Default value (false) scales it to visually appear at the same size no matter the distance
    ///Setting to true causes annotation nodes to scale like a regular node
    ///Scaling relative to distance may be useful with local navigation-based uses
    ///For landmarks in the distance, the default is correct
    var scaleRelativeToDistance = false
    
    init(location: CLLocation?, image: UIImage) {
        self.image = image
        
        let size = image.size
        let plane = SCNPlane(width: size.width, height: size.height)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel = .physicallyBased
        
        annotationNode = SCNNode()
        annotationNode.geometry = plane
        
        super.init(location: location)
        
        let constraint = SCNBillboardConstraint()
        constraint.freeAxes = SCNBillboardAxis.Y
        constraints = [constraint]
        
        addChildNode(annotationNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
