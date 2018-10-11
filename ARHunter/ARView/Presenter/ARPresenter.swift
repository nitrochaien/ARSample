//
//  ARPresenter.swift
//  ARHunter
//
//  Created by Nam Vu on 10/1/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//

import UIKit
import CoreLocation
import SceneKit

protocol ARPresenterDelegate: NSObjectProtocol {
    func didGenerateNodes(_ data: [LocationAnnotationNode])
}

class ARPresenter: NSObject {
    weak var delegate: ARPresenterDelegate?
    
    var locations = [CLLocationCoordinate2D]()
    var updateUserLocationTimer: Timer?
    
    func attachView(_ delegate: ARPresenterDelegate) {
        self.delegate = delegate
        updateUserLocation()
    }
    
    func detachView() {
        delegate = nil
    }
    
    private func updateUserLocation() {
        let data = generateDemoData()
        delegate?.didGenerateNodes(data)
    }
    
    func generateDemoData() -> [LocationAnnotationNode] {
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
}

// MARK: - SceneLocationViewDelegate
extension ARPresenter: SceneLocationViewDelegate {
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
