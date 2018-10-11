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
    
    private let presenter = MapPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.attachView(self)
        presenter.setupLocationManager()
        
        addButtonShowARHunt()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    deinit {
        print("Deinit MapViewController")
        presenter.detachView()
    }
    
    private func addButtonShowARHunt() {
        let item = UIBarButtonItem(title: "Go Hunt", style: .plain, target: self, action: #selector(goHunt))
        navigationItem.rightBarButtonItem = item
    }
    
    @objc private func goHunt() {
        if let storyboard = storyboard {
            if let controller = storyboard.instantiateViewController(withIdentifier: "ARViewController") as? ARViewController {
                controller.setData(locations: presenter.randomLocations)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    private func setupLocations(_ location: CLLocation) {
        mapView.clear()
        
        presenter.randomLocations = MapKitUtils.sharedInstance.randomCoordinatesAroundCurrentLocation(currentLocation: location)
        
        presenter.randomLocations.forEach {
            let marker = GMSMarker()
            marker.position = $0
            marker.title = "dragon"
            marker.snippet = "fire dragon"
            marker.map = mapView
        }
    }
}

extension MapViewController: MapPresenterDelegate {
    func updateMap(with location: CLLocation, and camera: GMSCameraPosition) {
        mapView.camera = camera
        setupLocations(location)
    }
}
