//
//  ARViewController.swift
//  ARHunter
//
//  Created by Nam Vu on 10/1/18.
//  Copyright © 2018 Nam Vu. All rights reserved.
//
//  https://www.raywenderlich.com/764-augmented-reality-ios-tutorial-location-based

import UIKit
import CoreLocation
import ARKit

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
    
    @objc func tapToSceneView(tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            let hits = sceneView.hitTest(tapRecognizer.location(in: tapRecognizer.view), options: nil) as [SCNHitTestResult]
            if let node = hits.first?.node.parent as? LocationNode {
                sceneView.removeLocationNode(locationNode: node)
                for i in 0...presenter.locations.count - 1 {
                    let location = presenter.locations[i]
                    if location.latitude == node.location.coordinate.latitude {
                        presenter.locations.remove(at: i)
                        break
                    }
                }
            }
        }
    }
}

// MARK: - ARPresenterDelegate
extension ARViewController: ARPresenterDelegate {
    func didGenerateNodes(_ data: [LocationAnnotationNode]) {
        data.forEach { sceneView.addLocationNodeWithConfirmedLocation(locationNode: $0) }
    }
}
