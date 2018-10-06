//
//  ARViewController.swift
//  ARHunter
//
//  Created by Nam Vu on 10/1/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//
//  https://www.raywenderlich.com/764-augmented-reality-ios-tutorial-location-based

import UIKit
import ARKit
import AVFoundation
import CoreLocation

class ARViewController: UIViewController {
    @IBOutlet weak var sceneView: SceneLocationView!
    
    var centerMapOnUserLocation: Bool = true
    var adjustNorthByTappingSidesOfScreen = false
    var demoData = [LocationAnnotationNode]()
    
    private var userLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        sceneView.locationDelegate = self
        addTapGestureToRemoveSceneView()
        
        updateUserLocation()
    }
    
    func setData(_ data: [LocationAnnotationNode]) {
        self.demoData = data
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("run")
        sceneView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("pause")
        // Pause the view's session
        sceneView.pause()
    }
    
    private func updateUserLocation() {
        guard let currentLocation = sceneView.currentLocation() else { return }
        
        demoData.forEach { sceneView.addLocationNodeWithConfirmedLocation(locationNode: $0) }
        
        if let bestEstimate = self.sceneView.bestLocationEstimate(),
            let position = self.sceneView.currentScenePosition() {
            print("")
            print("Fetch current location")
            print("best location estimate, position: \(bestEstimate.position), location: \(bestEstimate.location.coordinate), accuracy: \(bestEstimate.location.horizontalAccuracy), date: \(bestEstimate.location.timestamp)")
            print("current position: \(position)")
            
            let translation = bestEstimate.translatedLocation(to: position)
            
            print("translation: \(translation)")
            print("translated location: \(currentLocation)")
            print("")
        }
    }
    
    private func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        //Create a box shape. (1 float = 1 meter)
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        
        //A node represent position and coordinates of an object in 3D space
        let boxNode = SCNNode()
        //Give node a shape by setting geometry to the box
        boxNode.geometry = box
        //Give our node a position. This position is relative to the camera. Positive x is to the right. Negative x is to the left. Positive y is up. Negative y is down. Positive z is backward. Negative z is forward.
        boxNode.position = SCNVector3(x, y, z)
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(boxNode)
        sceneView.scene = scene
    }
    
    private func addTapGestureToRemoveSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToSceneView))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func tapToSceneView(_ recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, options: nil)
        
        if let node = hitTestResults.first?.node {
            print("Touch node!! Node: \(node.description)")
//            node.removeFromParentNode()
        }
    }
}

extension ARViewController: SceneLocationViewDelegate {
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        print("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        print("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
}
