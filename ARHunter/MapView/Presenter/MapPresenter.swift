//
//  MapPresenter.swift
//  ARHunter
//
//  Created by Nam Vu on 10/1/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//

import UIKit
import ARCL
import GoogleMaps

protocol MapPresenterDelegate: NSObjectProtocol {
    func updateMap(with location: CLLocation, and camera: GMSCameraPosition)
}

class MapPresenter: NSObject {
    weak var delegate: MapPresenterDelegate?
    
    private let locationManager = CLLocationManager()
    
    var randomLocations = [CLLocationCoordinate2D]()
    private(set) var zoomLevel: Float = 15.0
    
    func attachView(_ delegate: MapPresenterDelegate) {
        self.delegate = delegate
    }
    
    func detachView() {
        self.delegate = nil
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
}

extension MapPresenter: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        manager.stopUpdatingLocation()
        manager.delegate = nil
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        
        delegate?.updateMap(with: location, and: camera)
    }
}
