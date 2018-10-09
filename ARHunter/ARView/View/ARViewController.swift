//
//  ARViewController.swift
//  ARHunter
//
//  Created by Nam Vu on 10/1/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//
//  https://www.raywenderlich.com/764-augmented-reality-ios-tutorial-location-based

import UIKit
import ARCL
import CoreLocation

class ARViewController: UIViewController {
    private let sceneView = SceneLocationView()
    private let presenter = ARPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sceneView)
        
        sceneView.locationDelegate = presenter
        addTapGestureToRemoveSceneView()
        
        presenter.attachView(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneView.frame = view.bounds
    }

    func setData(locations: [CLLocationCoordinate2D]) {
        presenter.locations = locations
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("run")
        sceneView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("pause")
        // Pause the view's session
        sceneView.pause()
    }
    
    deinit {
        print("Deinit ARViewController")
        presenter.detachView()
    }
    
    private func addTapGestureToRemoveSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToSceneView))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func tapToSceneView(_ recognizer: UITapGestureRecognizer) {
//        let tapLocation = recognizer.location(in: sceneView)
//        let hitTestResults = sceneView.hitTest(tapLocation, options: nil)
//
//        if let node = hitTestResults.first?.node {
//
//        }
    }
}

// MARK: - ARPresenterDelegate
extension ARViewController: ARPresenterDelegate {
    func didGenerateNodes(_ data: [LocationAnnotationNode]) {
        data.forEach { sceneView.addLocationNodeWithConfirmedLocation(locationNode: $0) }
    }
}
