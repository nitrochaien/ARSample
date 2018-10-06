//
//  MapViewController.swift
//  ARHunter
//
//  Created by Nam Vu on 10/1/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    var nodes = [LocationAnnotationNode]()
    var zoomLevel: Float = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        
        addButtonShowARHunt()
    }
    
    private func addButtonShowARHunt() {
        let item = UIBarButtonItem(title: "Go Hunt", style: .plain, target: self, action: #selector(goHunt))
        navigationItem.rightBarButtonItem = item
    }
    
    @objc private func goHunt() {
        if let storyboard = storyboard {
            if let controller = storyboard.instantiateViewController(withIdentifier: "ARViewController") as? ARViewController {
                controller.setData(nodes)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    private func setupLocations(_ location: CLLocation) {
        mapView.clear()
        
        let locations = MapKitUtils.sharedInstance.randomCoordinatesAroundCurrentLocation(currentLocation: location)
        
        locations.forEach {
            let lat = $0.latitude
            let long = $0.longitude
            let node = MapKitUtils.sharedInstance.buildNode(latitude: lat, longitude: long, altitude: 10, imageName: "pin")
            nodes.append(node)
            
            let marker = ARMarker()
            marker.position = $0
            marker.title = "dragon"
            marker.snippet = "fire dragon"
            marker.map = mapView
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = locations.first else { return }

        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        mapView.camera = camera
        setupLocations(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Setup Location status authorized.")
            locationManager.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
}
