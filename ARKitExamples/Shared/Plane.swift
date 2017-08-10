//
//  Plane.swift
//  ARKitExamples
//
//  Created by Evgeniy Antonov on 7/17/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import UIKit
import ARKit

class Plane: SCNNode {
    var anchor: ARPlaneAnchor?
    var planeGeometry: SCNPlane?
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        self.anchor = anchor
        planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.y))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(white: 1, alpha: 0.3)
        planeGeometry?.materials = [material]
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1.0, 0.0, 0.0)
        
        setTextureScale()
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(anchor: ARPlaneAnchor) {
        planeGeometry?.width = CGFloat(anchor.extent.x)
        planeGeometry?.height = CGFloat(anchor.extent.z)
        
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        setTextureScale()
    }
    
    func setTextureScale() {
        let width = planeGeometry?.width ?? 0
        let height = planeGeometry?.height ?? 0
        
        let material = planeGeometry?.materials.first
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), 1)
        
        material?.diffuse.wrapS = .repeat
        material?.diffuse.wrapT = .repeat
    }
}
