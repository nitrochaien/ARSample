//
//  MapKitUtils.swift
//  AR_Hunt
//
//  Created by Nam Vu on 10/1/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import MapKit

class MapKitUtils: NSObject {
  static let sharedInstance = MapKitUtils()
  
  func randomCoordinatesAroundCurrentLocation(currentLocation: CLLocation, min: UInt32 = 10, max: UInt32 = 150) -> [CLLocationCoordinate2D] {
    return (0...10).enumerated().map { _ in
      return randomCoordinateAroundCurrentLocation(currentLoc: currentLocation, min: min, max: max)
    }
  }
  
  func randomCoordinateAroundCurrentLocation(currentLoc: CLLocation, min: UInt32, max: UInt32) -> CLLocationCoordinate2D {
    //Get the Current Location's longitude and latitude
    let currentLong = currentLoc.coordinate.longitude
    let currentLat = currentLoc.coordinate.latitude
    
    //1 KiloMeter = 0.00900900900901° So, 1 Meter = 0.00900900900901 / 1000
    let meterCord = 0.00900900900901 / 1000
    
    //Generate random Meters between the maximum and minimum Meters
    let randomMeters = UInt(arc4random_uniform(max) + min)
    
    //then Generating Random numbers for different Methods
    let randomPM = arc4random_uniform(6)
    
    //Then we convert the distance in meters to coordinates by Multiplying number of meters with 1 Meter Coordinate
    let metersCordN = meterCord * Double(randomMeters)
    
    //here we generate the last Coordinates
    if randomPM == 0 {
      return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong + metersCordN)
    } else if randomPM == 1 {
      return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong - metersCordN)
    } else if randomPM == 2 {
      return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong - metersCordN)
    } else if randomPM == 3 {
      return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong + metersCordN)
    } else if randomPM == 4 {
      return CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong - metersCordN)
    } else {
      return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong)
    }
  }
  
  func randomCoordinateOnAllOfEarth() -> CLLocationCoordinate2D {
    let lat = CLLocationDegrees(randomBetweenNumbers(first: -90, second: 90))
    let long = CLLocationDegrees(randomBetweenNumbers(first: -180, second: 180))
    return CLLocationCoordinate2D(latitude: lat, longitude: long)
  }
  
  func randomBetweenNumbers(first: CGFloat, second: CGFloat) -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(first - second) + min(first, second)
  }
}
