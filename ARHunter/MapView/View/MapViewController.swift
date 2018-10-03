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
    var currentLocation: CLLocation?
    var zoomLevel: Float = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
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
                guard let userLocation = currentLocation else { return }
                controller.target = ARItem(itemDescription: "dragon", location: CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), itemNode: nil)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    private func setupLocations() {
        mapView.clear()
        
        if let userLocation = currentLocation {
            let locations = MapKitUtils.sharedInstance.randomCoordinatesAroundCurrentLocation(currentLocation: userLocation)
            
            for location in locations {
                let target = ARItem(itemDescription: "dragon", location: CLLocation(latitude: location.latitude, longitude: location.longitude), itemNode: nil)
                
                let marker = ARMarker()
                marker.target = target
                marker.position = location
                marker.title = "dragon"
                marker.snippet = "fire dragon"
                marker.map = mapView
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        guard let location: CLLocation = locations.first else { return }
        currentLocation = location
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        mapView.camera = camera
        setupLocations()
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
