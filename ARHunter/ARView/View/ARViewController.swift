//
//  ARViewController.swift
//  ARHunter
//
//  Created by Nam Vu on 10/1/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//
//  https://www.raywenderlich.com/764-augmented-reality-ios-tutorial-location-based

import UIKit
import ARCL
import SceneKit
import CoreLocation

class ARViewController: UIViewController {
    let sceneView = SceneLocationView()

    var locations = [CLLocationCoordinate2D]()
    
    var updateUserLocationTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sceneView)
        
        sceneView.locationDelegate = self
        
        addTapGestureToRemoveSceneView()
        
        updateUserLocationTimer?.invalidate()
        updateUserLocationTimer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(updateUserLocation),
            userInfo: nil,
            repeats: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneView.frame = view.bounds
    }

    
    func setData(locations: [CLLocationCoordinate2D]) {
        self.locations = locations
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
        updateUserLocationTimer?.invalidate()
        updateUserLocationTimer = nil
    }
    
    @objc private func updateUserLocation() {
        generateDemoData().forEach { sceneView.addLocationNodeWithConfirmedLocation(locationNode: $0) }
    }
    
    private func generateDemoData() -> [LocationAnnotationNode] {
        var nodes = [LocationAnnotationNode]()
        locations.forEach {
            let lat = $0.latitude
            let long = $0.longitude
            let node = buildNode(latitude: lat, longitude: long, altitude: 10, imageName: "pin")
            nodes.append(node)
        }
        return nodes
    }
    
    private func buildNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees, altitude: CLLocationDistance, imageName: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let image = UIImage(named: imageName)!
        return LocationAnnotationNode(location: location, image: image)
    }
    
    private func addTapGestureToRemoveSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToSceneView))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func tapToSceneView(_ recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, options: nil)
        
        if let node = hitTestResults.first?.node {
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
