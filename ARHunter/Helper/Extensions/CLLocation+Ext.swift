//
//  CLLocation+Ext.swift
//  ARHunter
//
//  Created by Nam Vu on 10/7/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//

import CoreLocation

let EARTH_RADIUS = 6371000.0

///Translation in meters between 2 locations
struct LocationTranslation {
    var latitudeTranslation: Double
    var longitudeTranslation: Double
    var altitudeTranslation: Double
    
    init(latitudeTranslation: Double, longitudeTranslation: Double, altitudeTranslation: Double) {
        self.latitudeTranslation = latitudeTranslation
        self.longitudeTranslation = longitudeTranslation
        self.altitudeTranslation = altitudeTranslation
    }
}

extension CLLocation {
    convenience init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance) {
        self.init(coordinate: coordinate, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
    }
    
    ///Translates distance in meters between two locations.
    ///Returns the result as the distance in latitude and distance in longitude.
    func translation(toLocation location: CLLocation) -> LocationTranslation {
        let inbetweenLocation = CLLocation(latitude: self.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let distanceLatitude = location.distance(from: inbetweenLocation)
        
        let latitudeTranslation: Double
        
        if location.coordinate.latitude > inbetweenLocation.coordinate.latitude {
            latitudeTranslation = distanceLatitude
        } else {
            latitudeTranslation = 0 - distanceLatitude
        }
        
        let distanceLongitude = self.distance(from: inbetweenLocation)
        
        let longitudeTranslation: Double
        
        if self.coordinate.longitude > inbetweenLocation.coordinate.longitude {
            longitudeTranslation = 0 - distanceLongitude
        } else {
            longitudeTranslation = distanceLongitude
        }
        
        let altitudeTranslation = location.altitude - self.altitude
        
        return LocationTranslation(
            latitudeTranslation: latitudeTranslation,
            longitudeTranslation: longitudeTranslation,
            altitudeTranslation: altitudeTranslation)
    }
    
    func translatedLocation(with translation: LocationTranslation) -> CLLocation {
        let latitudeCoordinate = self.coordinate.coordinateWithBearing(bearing: 0, distanceMeters: translation.latitudeTranslation)
        
        let longitudeCoordinate = self.coordinate.coordinateWithBearing(bearing: 90, distanceMeters: translation.longitudeTranslation)
        
        let coordinate = CLLocationCoordinate2D(
            latitude: latitudeCoordinate.latitude,
            longitude: longitudeCoordinate.longitude)
        
        let altitude = self.altitude + translation.altitudeTranslation
        
        return CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: self.horizontalAccuracy, verticalAccuracy: self.verticalAccuracy, timestamp: self.timestamp)
    }
}

extension CLLocationCoordinate2D {
    func coordinateWithBearing(bearing: Double, distanceMeters: Double) -> CLLocationCoordinate2D {
        // formula by http://www.movable-type.co.uk/scripts/latlong.html
        let lat1 = self.latitude * Double.pi / 180
        let lon1 = self.longitude * Double.pi / 180
        
        let distance = distanceMeters / EARTH_RADIUS
        let angularBearing = bearing * Double.pi / 180
        
        var lat2 = lat1 + distance * cos(angularBearing)
        let dLat = lat2 - lat1
        let dPhi = log(tan(lat2 / 2 + Double.pi/4) / tan(lat1 / 2 + Double.pi/4))
        let q = (dPhi != 0) ? dLat/dPhi : cos(lat1)  // E-W line gives dPhi=0
        let dLon = distance * sin(angularBearing) / q
        
        // check for some daft bugger going past the pole
        if fabs(lat2) > Double.pi/2 {
            lat2 = lat2 > 0 ? Double.pi - lat2 : -(Double.pi - lat2)
        }
        var lon2 = lon1 + dLon + 3 * Double.pi
        while lon2 > 2 * Double.pi {
            lon2 -= 2 * Double.pi
        }
        lon2 -= Double.pi
        
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
}
