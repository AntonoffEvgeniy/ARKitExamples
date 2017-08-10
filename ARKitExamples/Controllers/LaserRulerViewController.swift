//
//  LaserRulerViewController.swift
//  ARKitExamples
//
//  Created by Evgeniy Antonov on 7/17/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import UIKit
import ARKit

let kTimerDuration: TimeInterval = 0.05

class LaserRulerViewController: BaseViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var cursorImageView: UIImageView!
    @IBOutlet weak var searchingPlaneLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var planes = [UUID: Plane]()
    var timer: Timer?
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - setup
    func setupScene() {
        let scene = SCNScene()
        sceneView.delegate = self
        sceneView.scene = scene
    }
    
    func setupConfiguration() {
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    // MARK: - private
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: kTimerDuration, target: self, selector: #selector(LaserRulerViewController.timerHandler), userInfo: nil, repeats: true)
    }
    
    @objc func timerHandler() {
        let hitResult = sceneView.hitTest(cursorImageView.center, types: .existingPlaneUsingExtent).first
        let distanceSubstring = String(format: "%.2f", hitResult?.distance ?? 0)
        distanceLabel.text = "\(distanceSubstring) m"
        distanceLabel.isHidden = hitResult == nil
        cursorImageView.isHidden = hitResult == nil
        searchingPlaneLabel.isHidden = hitResult != nil
    }
}

internal extension LaserRulerViewController {
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            return
        }
        
        if planes.count == 0 {
            DispatchQueue.main.async {
                self.searchingPlaneLabel.isHidden = true
                self.runTimer()
            }
        }
        
        let plane = Plane(anchor: anchor as! ARPlaneAnchor)
        planes[anchor.identifier] = plane
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let plane = planes[anchor.identifier] {
            plane.update(anchor: anchor as! ARPlaneAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }
}
