//
//  FirstViewController.swift
//  MovingImageTest
//
//  Created by Daniel_Nagy on 20/04/16.
//  Copyright © 2016 NDani. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBAction func topToBottomPressed(_: UIButton) {
        let nextViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("hejj") as! ViewController
        nextViewController.animationType = .TopToBottom
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func zoomInPressed(_: UIButton) {
        let nextViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("hejj") as! ViewController
        nextViewController.animationType = .ZoomIn
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}
