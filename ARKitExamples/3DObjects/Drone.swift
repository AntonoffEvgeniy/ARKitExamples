//
//  Drone.swift
//  ARKitExamples
//
//  Created by Evgeniy Antonov on 7/17/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import ARKit

class Drone: SCNNode {
    func loadModel() {
        guard let virtualObjectScene = SCNScene(named: "Drone.scn") else { return }
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        addChildNode(wrapperNode)
    }
}
