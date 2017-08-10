//
//  RootViewController.swift
//  ARKitExamples
//
//  Created by Evgeniy Antonov on 7/17/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import UIKit

let kButtonsCornerRadius: CGFloat = 8

class RootViewController: BaseViewController {
    @IBOutlet weak var rulerButton: UIButton!
    @IBOutlet weak var laserRulerButton: UIButton!
    @IBOutlet weak var flyingObjectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    func setupViews() {
        for button in [rulerButton, laserRulerButton, flyingObjectButton] {
            button?.layer.cornerRadius = kButtonsCornerRadius
        }
    }
}
