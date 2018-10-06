//
//  SceneLocationView.swift
//  ARHunter
//
//  Created by Nam Vu on 10/6/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation

protocol SceneLocationViewDelegate: AnyObject {
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation)
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation)
    
    ///After a node's location is initially set based on current location,
    ///it is later confirmed once the user moves far enough away from it.
    ///This update uses location data collected since the node was placed to give a more accurate location.
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode)
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode)
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode)
}

///Different methods which can be used when determining locations (such as the user's location).
enum LocationEstimateMethod {
    ///Only uses core location data.
    ///Not suitable for adding nodes using current position, which requires more precision.
    case coreLocationDataOnly
    
    ///Combines knowledge about movement through the AR world with
    ///the most relevant Core Location estimate (based on accuracy and time).
    case mostRelevantEstimate
}

class SceneLocationView: ARSCNView {
    ///The limit to the scene, in terms of what data is considered reasonably accurate.
    ///Measured in meters.
    private static let sceneLimit = 100.0
    ///When set to true, displays an axes node at the start of the scene
    private var showAxesNode = false
    private var sceneLocationEstimates = [SceneLocationEstimate]()
    private var updateEstimateTimer: Timer?
    private var didFetchInitialLocation = false
    
    weak var locationDelegate: SceneLocationViewDelegate?
    
    ///The method to use for determining locations.
    ///Not advisable to change this as the scene is ongoing.
    public var locationEstimateMethod: LocationEstimateMethod = .mostRelevantEstimate
    
    let locationManager = LocationManager()
    private(set) var locationNodes = [LocationNode]()
    private(set) var sceneNode: SCNNode? {
        didSet {
            if let sceneNode = sceneNode {
                for node in locationNodes {
                    sceneNode.addChildNode(node)
                }
                
                locationDelegate?.sceneLocationViewDidSetupSceneNode(sceneLocationView: self, sceneNode: sceneNode)
            }
        }
    }
    ///Whether debugging feature points should be displayed.
    ///Defaults to false
    public var showFeaturePoints = false
    
    convenience init() {
        self.init(frame: CGRect.zero, options: nil)
    }
    
    override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        locationManager.delegate = self
        delegate = self
        showsStatistics = false
        
        if showFeaturePoints {
            debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        }
    }
    
    func run() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravity
        
        session.run(configuration, options: .removeExistingAnchors)
        
        updateEstimateTimer?.invalidate()
        updateEstimateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateLocationData), userInfo: nil, repeats: true)
    }
    
    func pause() {
        session.pause()
        updateEstimateTimer?.invalidate()
        updateEstimateTimer = nil
    }
    
    @objc private func updateLocationData() {
        removeOldLocationEstimates()
        confirmLocationOfDistantLocationNodes()
        updatePositionAndScaleOfLocationNodes()
    }
    
    ///Resets the scene heading to 0
    func resetSceneHeading() {
        sceneNode?.eulerAngles.y = 0
    }
    
    // MARK: - Scene location estimates
    func currentScenePosition() -> SCNVector3? {
        guard let pointOfView = pointOfView else { return nil }
        
        return scene.rootNode.convertPosition(pointOfView.position, to: sceneNode)
    }
    
    func currentEulerAngles() -> SCNVector3? {
        return pointOfView?.eulerAngles
    }
    
    fileprivate func addSceneLocationEstimate(location: CLLocation) {
        if let position = currentScenePosition() {
            let sceneLocationEstimate = SceneLocationEstimate(location: location, position: position)
            self.sceneLocationEstimates.append(sceneLocationEstimate)
            if self.sceneLocationEstimates.count > 30 {
                self.sceneLocationEstimates.removeFirst()
            }
            
            locationDelegate?.sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: self, position: position, location: location)
        }
    }
    
    private func removeOldLocationEstimates() {
        if let currentPosition = currentScenePosition() {
            removeOldLocationEstimates(currentScenePosition: currentPosition)
        }
    }
    
    private func removeOldLocationEstimates(currentScenePosition: SCNVector3) {
        let currentPoint = CGPoint.pointWithVector(vector: currentScenePosition)
        
        sceneLocationEstimates = sceneLocationEstimates.filter {
            let point = CGPoint.pointWithVector(vector: $0.position)
            let radiusPoint = currentPoint.radiusContainsPoint(radius: CGFloat(SceneLocationView.sceneLimit), point: point)
            if !radiusPoint {
                locationDelegate?.sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: self, position: $0.position, location: $0.location)
            }
            
            return radiusPoint
        }
    }
    
    ///The best estimation of location that has been taken
    ///This takes into account horizontal accuracy, and the time at which the estimation was taken
    ///favouring the most accurate, and then the most recent result.
    ///This doesn't indicate where the user currently is.
    func bestLocationEstimate() -> SceneLocationEstimate? {
        let sortedLocationEstimates = sceneLocationEstimates.sorted(by: {
            if $0.location.horizontalAccuracy == $1.location.horizontalAccuracy {
                return $0.location.timestamp > $1.location.timestamp
            }
            
            return $0.location.horizontalAccuracy < $1.location.horizontalAccuracy
        })
        
        return sortedLocationEstimates.first
    }
    
    func currentLocation() -> CLLocation? {
        if locationEstimateMethod == .coreLocationDataOnly {
            return locationManager.currentLocation
        }
        
        guard let bestEstimate = self.bestLocationEstimate(),
            let position = currentScenePosition() else {
                return nil
        }
        
        return bestEstimate.translatedLocation(to: position)
    }
    
    // MARK: - LocationNodes
    ///upon being added, a node's location, locationConfirmed and position may be modified and should not be changed externally.
    func addLocationNodeForCurrentPosition(locationNode: LocationNode) {
        guard let currentPosition = currentScenePosition(),
            let currentLocation = currentLocation(),
            let sceneNode = self.sceneNode else {
                return
        }
        
        locationNode.location = currentLocation
        
        ///Location is not changed after being added when using core location data only for location estimates
        if locationEstimateMethod == .coreLocationDataOnly {
            locationNode.locationConfirmed = true
        } else {
            locationNode.locationConfirmed = false
        }
        
        locationNode.position = currentPosition
        
        locationNodes.append(locationNode)
        sceneNode.addChildNode(locationNode)
    }
    
    ///location not being nil, and locationConfirmed being true are required
    ///Upon being added, a node's position will be modified and should not be changed externally.
    ///location will not be modified, but taken as accurate.
    func addLocationNodeWithConfirmedLocation(locationNode: LocationNode) {
        if locationNode.location == nil || locationNode.locationConfirmed == false {
            return
        }
        
        updatePositionAndScaleOfLocationNode(locationNode: locationNode, initialSetup: true, animated: false)
        
        locationNodes.append(locationNode)
        sceneNode?.addChildNode(locationNode)
    }
    
    func removeAllNodes() {
        locationNodes.removeAll()
        guard let childNodes = sceneNode?.childNodes else { return }
        for node in childNodes {
            node.removeFromParentNode()
        }
    }
    
    /// Determine if scene contains a node with the specified tag
    ///
    /// - Parameter tag: tag text
    /// - Returns: true if a LocationNode with the tag exists; false otherwise
    func sceneContainsNodeWithTag(_ tag: String) -> Bool {
        return findNodes(tagged: tag).count > 0
    }
    
    /// Find all location nodes in the scene tagged with `tag`
    ///
    /// - Parameter tag: The tag text for which to search nodes.
    /// - Returns: A list of all matching tags
    func findNodes(tagged tag: String) -> [LocationNode] {
        guard tag.count > 0 else {
            return []
        }
        
        return locationNodes.filter { $0.tag == tag }
    }
    
    func removeLocationNode(locationNode: LocationNode) {
        if let index = locationNodes.index(of: locationNode) {
            locationNodes.remove(at: index)
        }
        
        locationNode.removeFromParentNode()
    }
    
    private func confirmLocationOfDistantLocationNodes() {
        guard let currentPosition = currentScenePosition() else {
            return
        }
        
        for locationNode in locationNodes where !locationNode.locationConfirmed {
            let currentPoint = CGPoint.pointWithVector(vector: currentPosition)
            let locationNodePoint = CGPoint.pointWithVector(vector: locationNode.position)
            
            if !currentPoint.radiusContainsPoint(radius: CGFloat(SceneLocationView.sceneLimit), point: locationNodePoint) {
                confirmLocationOfLocationNode(locationNode)
            }
        }
    }
    
    ///Gives the best estimate of the location of a node
    func locationOfLocationNode(_ locationNode: LocationNode) -> CLLocation {
        if locationNode.locationConfirmed || locationEstimateMethod == .coreLocationDataOnly {
            return locationNode.location!
        }
        
        if let bestLocationEstimate = bestLocationEstimate(),
            locationNode.location == nil ||
                bestLocationEstimate.location.horizontalAccuracy < locationNode.location!.horizontalAccuracy {
            let translatedLocation = bestLocationEstimate.translatedLocation(to: locationNode.position)
            
            return translatedLocation
        } else {
            return locationNode.location!
        }
    }
    
    private func confirmLocationOfLocationNode(_ locationNode: LocationNode) {
        locationNode.location = locationOfLocationNode(locationNode)
        
        locationNode.locationConfirmed = true
        
        locationDelegate?.sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: self, node: locationNode)
    }
    
    func updatePositionAndScaleOfLocationNodes() {
        for locationNode in locationNodes where locationNode.continuallyUpdatePositionAndScale {
            updatePositionAndScaleOfLocationNode(locationNode: locationNode, animated: true)
        }
    }
    
    public func updatePositionAndScaleOfLocationNode(locationNode: LocationNode, initialSetup: Bool = false, animated: Bool = false, duration: TimeInterval = 0.1) {
        guard let currentPosition = currentScenePosition(),
            let currentLocation = currentLocation() else {
                return
        }
        
        SCNTransaction.begin()
        
        SCNTransaction.animationDuration = animated ? duration : 0
        
        let locationNodeLocation = locationOfLocationNode(locationNode)
        
        // Position is set to a position coordinated via the current position
        let locationTranslation = currentLocation.translation(toLocation: locationNodeLocation)
        let adjustedDistance: CLLocationDistance
        let distance = locationNodeLocation.distance(from: currentLocation)
        
        if locationNode.locationConfirmed &&
            (distance > 100 || locationNode.continuallyAdjustNodePositionWhenWithinRange || initialSetup) {
            if distance > 100 {
                //If the item is too far away, bring it closer and scale it down
                let scale = 100 / Float(distance)
                
                adjustedDistance = distance * Double(scale)
                
                let adjustedTranslation = SCNVector3(
                    x: Float(locationTranslation.longitudeTranslation) * scale,
                    y: Float(locationTranslation.altitudeTranslation) * scale,
                    z: Float(locationTranslation.latitudeTranslation) * scale)
                
                let position = SCNVector3(
                    x: currentPosition.x + adjustedTranslation.x,
                    y: currentPosition.y + adjustedTranslation.y,
                    z: currentPosition.z - adjustedTranslation.z)
                
                locationNode.position = position
                
                locationNode.scale = SCNVector3(x: scale, y: scale, z: scale)
            } else {
                adjustedDistance = distance
                let position = SCNVector3(
                    x: currentPosition.x + Float(locationTranslation.longitudeTranslation),
                    y: currentPosition.y + Float(locationTranslation.altitudeTranslation),
                    z: currentPosition.z - Float(locationTranslation.latitudeTranslation))
                
                locationNode.position = position
                locationNode.scale = SCNVector3(x: 1, y: 1, z: 1)
            }
        } else {
            //Calculates distance based on the distance within the scene, as the location isn't yet confirmed
            adjustedDistance = Double(currentPosition.distance(to: locationNode.position))
            
            locationNode.scale = SCNVector3(x: 1, y: 1, z: 1)
        }
        
        if let annotationNode = locationNode as? LocationAnnotationNode {
            //The scale of a node with a billboard constraint applied is ignored
            //The annotation subnode itself, as a subnode, has the scale applied to it
            let appliedScale = locationNode.scale
            locationNode.scale = SCNVector3(x: 1, y: 1, z: 1)
            
            var scale: Float
            
            if annotationNode.scaleRelativeToDistance {
                scale = appliedScale.y
                annotationNode.annotationNode.scale = appliedScale
            } else {
                //Scale it to be an appropriate size so that it can be seen
                scale = Float(adjustedDistance) * 0.181
                
                if distance > 3000 {
                    scale = scale * 0.75
                }
                
                annotationNode.annotationNode.scale = SCNVector3(x: scale, y: scale, z: scale)
            }
            
            annotationNode.pivot = SCNMatrix4MakeTranslation(0, -1.1 * scale, 0)
        }
        
        SCNTransaction.commit()
        
        locationDelegate?.sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: self, locationNode: locationNode)
    }
}

// MARK: - ARSCNViewDelegate
extension SceneLocationView: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if sceneNode == nil {
            sceneNode = SCNNode()
            scene.rootNode.addChildNode(sceneNode!)
            
            if showAxesNode {
                let axesNode = SCNNode.axesNode(quiverLength: 0.1, quiverThickness: 0.5)
                sceneNode?.addChildNode(axesNode)
            }
        }
        
        if !didFetchInitialLocation {
            //Current frame and current location are required for this to be successful
            if session.currentFrame != nil,
                let currentLocation = self.locationManager.currentLocation {
                didFetchInitialLocation = true
                
                self.addSceneLocationEstimate(location: currentLocation)
            }
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("session interruption ended")
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("session did fail with error: \(error)")
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .limited(.insufficientFeatures):
            print("camera did change tracking state: limited, insufficient features")
        case .limited(.excessiveMotion):
            print("camera did change tracking state: limited, excessive motion")
        case .limited(.initializing):
            print("camera did change tracking state: limited, initializing")
        case .normal:
            print("camera did change tracking state: normal")
        case .notAvailable:
            print("camera did change tracking state: not available")
        case .limited(.relocalizing):
            print("camera did change tracking state: limited, relocalizing")
        }
    }
}

// MARK: - LocationManagerDelegate
extension SceneLocationView: LocationManagerDelegate {
    func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation) {
        addSceneLocationEstimate(location: location)
    }
    
    func locationManagerDidUpdateHeading(_ locationManager: LocationManager, heading: CLLocationDirection, accuracy: CLLocationAccuracy) {
        // negative value means the heading will equal the `magneticHeading`, and we're interested in the `trueHeading`
        if accuracy < 0 {
            return
        }
        
        // heading of 0º means its pointing to the geographic North
        if heading == 0 {
            resetSceneHeading()
        }
    }
}
