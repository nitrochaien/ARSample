//
//  LocationManager.swift
//  ARHunter
//
//  Created by Nam Vu on 10/6/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation)
    func locationManagerDidUpdateHeading(_ locationManager: LocationManager, heading: CLLocationDirection, accuracy: CLLocationDirection)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    weak var delegate: LocationManagerDelegate?
    var currentLocation: CLLocation?
    
    private var manager: CLLocationManager?
    private(set) var heading: CLLocationDirection?
    private(set) var headingAccuracy: CLLocationDegrees?
    
    override init() {
        super.init()
        
        manager = CLLocationManager()
        manager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager?.distanceFilter = kCLDistanceFilterNone
        manager?.headingFilter = kCLHeadingFilterNone
        manager?.pausesLocationUpdatesAutomatically = false
        manager?.delegate = self
        manager?.startUpdatingHeading()
        manager?.startUpdatingLocation()
        manager?.requestWhenInUseAuthorization()
        
        currentLocation = manager?.location
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            self.delegate?.locationManagerDidUpdateLocation(self, location: location)
        }
        
        self.currentLocation = manager.location
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy >= 0 {
            self.heading = newHeading.trueHeading
        } else {
            self.heading = newHeading.magneticHeading
        }
        
        self.headingAccuracy = newHeading.headingAccuracy
        
        self.delegate?.locationManagerDidUpdateHeading(self, heading: self.heading!, accuracy: newHeading.headingAccuracy)
    }
    
    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}
