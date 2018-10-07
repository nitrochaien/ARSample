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
import ARCL

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    var randomLocations = [CLLocationCoordinate2D]()
    var zoomLevel: Float = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        addButtonShowARHunt()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    private func addButtonShowARHunt() {
        let item = UIBarButtonItem(title: "Go Hunt", style: .plain, target: self, action: #selector(goHunt))
        navigationItem.rightBarButtonItem = item
    }
    
    @objc private func goHunt() {
        if let storyboard = storyboard {
            if let controller = storyboard.instantiateViewController(withIdentifier: "ARViewController") as? ARViewController {
                controller.setData(locations: randomLocations)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    private func setupLocations(_ location: CLLocation) {
        mapView.clear()
        
        randomLocations = MapKitUtils.sharedInstance.randomCoordinatesAroundCurrentLocation(currentLocation: location)
        
        randomLocations.forEach {
            let marker = GMSMarker()
            marker.position = $0
            marker.title = "dragon"
            marker.snippet = "fire dragon"
            marker.map = mapView
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        manager.stopUpdatingLocation()
        manager.delegate = nil
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        mapView.camera = camera
        setupLocations(location)
    }
}
