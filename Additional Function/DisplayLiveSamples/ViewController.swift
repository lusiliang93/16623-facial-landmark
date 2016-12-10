//
//  ViewController.swift
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 15.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    let sessionHandler = SessionHandler()
    var current_time = 0.0
    @IBOutlet weak var preview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        sessionHandler.openSession()
        

        let layer = sessionHandler.layer
        layer.frame = preview.bounds
        
//        let FPSView = UITextView()
        
//        FPSView.text = ("nzhu")
//        FPSView.font = UIFont(name:"Arial",size:90.0)
//        FPSView.textColor = UIColor.purpleColor()
//        preview.addSubview(FPSView)


        
        preview.layer.addSublayer(layer)
        

//        view.layoutIfNeeded()
//        var next_time = NSTimeInterval()
//        var deltaTime = Double(next_time) - current_time
//        var currentFPS = 1 / deltaTime
//        print(currentFPS)
//    }
    
//    var lastUpdateTime: NSTimeInterval = 0
//    
//     func update(currentTime currentTime: NSTimeInterval) {
//        let deltaTime = currentTime - lastUpdateTime
//        let currentFPS = 1 / deltaTime
//        print(currentFPS)
//
//        lastUpdateTime = currentTime
    }
}

