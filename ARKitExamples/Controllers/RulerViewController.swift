//
//  RulerViewController.swift
//  ARKitExamples
//
//  Created by Evgeniy Antonov on 7/17/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import UIKit
import ARKit

let kWorldTransformPositionKey = 3
let kSphereObjectRadius: CGFloat = 0.005;
let kLabelNodeScale: Float = 0.002

class RulerViewController: BaseViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    
    var planes = [UUID: Plane]()
    var startingHitResult: ARHitTestResult?
    var endingHitResult: ARHitTestResult?
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupScene()
        setupRecognizers()
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
    
    func setupRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RulerViewController.handleDidTap(recognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - private
    @objc func handleDidTap(recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
        if let hitResult = hitResults.first {
            if startingHitResult == nil {
                startingHitResult = hitResult
                renderStartingPoint()
            } else {
                endingHitResult = hitResult
                renderEndPoint()
            }
        }
    }
    
    private func renderStartingPoint() {
        if let hitResult = startingHitResult {
            renderNode(with: hitResult)
        }
    }
    
    private func renderEndPoint() {
        if let hitResult = endingHitResult {
            renderNode(with: hitResult)
            calculateDistance()
        }
    }
    
    private func renderNode(with hitResult: ARHitTestResult) {
        let geometry = SCNSphere(radius: kSphereObjectRadius)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        geometry.materials = [material]
        
        let node = SCNNode(geometry: geometry)
        
        let x = hitResult.worldTransform[kWorldTransformPositionKey].x
        let y = hitResult.worldTransform[kWorldTransformPositionKey].y + Float(kSphereObjectRadius / 2)
        let z = hitResult.worldTransform[kWorldTransformPositionKey].z
        node.position = SCNVector3Make(x, y, z)
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    private func calculateDistance() {
        let startingHitX = startingHitResult?.worldTransform[kWorldTransformPositionKey].x ?? 0
        let endingHitX = endingHitResult?.worldTransform[kWorldTransformPositionKey].x ?? 0
        let diffX = max(startingHitX, endingHitX) - min(startingHitX, endingHitX)
        
        let startingHitZ = startingHitResult?.worldTransform[kWorldTransformPositionKey].z ?? 0
        let endingHitZ = endingHitResult?.worldTransform[kWorldTransformPositionKey].z ?? 0
        let diffZ = max(startingHitZ, endingHitZ) - min(startingHitZ, endingHitZ)
        
        let distance = sqrt(Double(diffX * diffX + diffZ * diffZ))
        let centerX = max(startingHitX, endingHitX) - diffX / 2
        let centerY = startingHitResult?.worldTransform[kWorldTransformPositionKey].y ?? 0
        let centerZ = max(startingHitZ, endingHitZ) - diffZ / 2
        let distanceLabelPosition = SCNVector3Make(centerX, centerY, centerZ)
        renderDistanceLabel(with: distanceLabelPosition, distance: distance)
        
        startingHitResult = nil
        endingHitResult = nil
    }
    
    private func renderDistanceLabel(with position: SCNVector3, distance: Double) {
        let distanceSubstring = String(format: "%.2f", distance)
        let distanceString = "\(distanceSubstring) m"
        let labelGeometry = SCNText(string: distanceString, extrusionDepth: 1)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        labelGeometry.materials = [material]
        
        let labelNode = SCNNode(geometry: labelGeometry)
        
        labelNode.position = position
        labelNode.scale = SCNVector3Make(kLabelNodeScale, kLabelNodeScale, kLabelNodeScale)
        sceneView.scene.rootNode.addChildNode(labelNode)
    }
}

internal extension RulerViewController {
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            return
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

