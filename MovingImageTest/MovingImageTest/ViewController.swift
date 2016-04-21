//
//  ViewController.swift
//  MovingImageTest
//
//  Created by Daniel_Nagy on 18/04/16.
//  Copyright © 2016 NDani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var animationType = AnimatingHeaderImageAnimationType.TopToBottom
    
    var movingImageView: AnimatingHeaderImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let images = [UIImage(named: "1")!, UIImage(named: "2")!, UIImage(named: "3")!, UIImage(named: "4")!]
        movingImageView = AnimatingHeaderImage(images: images)
        
        if let movingImageView = movingImageView {
            view.addSubview(movingImageView)
        }
        
        movingImageView?.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        movingImageView?.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        movingImageView?.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        movingImageView?.heightAnchor.constraintEqualToConstant(200).active = true
        
        movingImageView?.restartAfterFinish = true
        movingImageView?.animationTime = 5
        movingImageView?.animationType = animationType
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        movingImageView?.startImageAnimation()
    }
}

