//
//  ARViewController.swift
//  ARHunter
//
//  Created by Nam Vu on 10/1/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//
//  https://www.raywenderlich.com/764-augmented-reality-ios-tutorial-location-based

import UIKit
import SceneKit
import AVFoundation
import CoreLocation

class ARViewController: UIViewController {
    @IBOutlet weak var sceneView: SCNView!

    /**
     *       Defines in how many vertical levels can annotations be stacked. Default value is 5.
     *       Annotations are initially vertically arranged by distance from user, but if two annotations visibly collide with each other,
     *       then farther annotation is put higher, meaning it is moved onto next vertical level. If annotation is moved onto level higher
     *       than this value, it will not be visible.
     *       NOTE: This property greatly impacts performance because collision detection is heavy operation, use it in range 1-10.
     *       Max value is 10.
     */
    var maxVerticalLevel = 0 {
        didSet {
            if maxVerticalLevel > MAX_VERTICAL_LEVELS {
                maxVerticalLevel = MAX_VERTICAL_LEVELS
            }
        }
    }
    
    /// Total maximum number of visible annotation views. Default value is 100. Max value is 500
    var maxVisibleAnnotations = 0 {
        didSet {
            if maxVisibleAnnotations > MAX_VISIBLE_ANNOTATIONS {
                maxVisibleAnnotations = MAX_VISIBLE_ANNOTATIONS
            }
        }
    }
    
    /**
     *       Maximum distance(in meters) for annotation to be shown.
     *       If the distance from annotation to user's location is greater than this value, than that annotation will not be shown.
     *       Also, this property, in conjunction with maxVerticalLevel, defines how are annotations aligned vertically. Meaning
     *       annotation that are closer to this value will be higher.
     *       Default value is 0 meters, which means that distances of annotations don't affect their visiblity.
     */
    var maxDistance: Double = 0
    
    /**
     Smoothing factor for heading in range 0-1. It affects horizontal movement of annotaion views. The lower the value the bigger the smoothing.
     Value of 1 means no smoothing, should be greater than 0.
     */
    open var headingSmoothingFactor: Double = 1
    
    /// Class for managing geographical calculations. Use it to set properties like reloadDistanceFilter, userDistanceFilter and altitudeSensitive
    fileprivate(set) open var trackingManager: ARTrackingManager = ARTrackingManager()
    
    //Private variables
    fileprivate var annotations = [ARAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setAnnotations(_ annotations: [ARAnnotation]) {
        var validAnnotations: [ARAnnotation] = []
        // Don't use annotations without valid location
        for annotation in annotations
        {
            if annotation.location != nil && CLLocationCoordinate2DIsValid(annotation.location!.coordinate)
            {
                validAnnotations.append(annotation)
            }
        }
        self.annotations = validAnnotations
        self.reloadAnnotations()
    }
    
    func getAnnotations() -> [ARAnnotation] {
        return self.annotations
    }
    
    private func reloadAnnotations() {
        if self.trackingManager.userLocation != nil && self.isViewLoaded
        {
            self.shouldReloadAnnotations = false
            self.reload(calculateDistanceAndAzimuth: true, calculateVerticalLevels: true, createAnnotationViews: true)
        }
        else
        {
            self.shouldReloadAnnotations = true
        }
    }
}
