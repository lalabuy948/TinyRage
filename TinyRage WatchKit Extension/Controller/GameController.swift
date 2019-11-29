//
//  GameController.swift
//  TinyRage WatchKit Extension
//
//  Created by Daniil Popov on 11/9/19.
//  Copyright © 2019 Daniil Popov. All rights reserved.
//

import WatchKit
import Foundation


class GameController: WKInterfaceController, WKCrownDelegate {

    @IBOutlet weak var skInterface: WKInterfaceSKScene!
    
    private var crownSensivity:Double = 20.0
    
    var gameScene:GameScene!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // start listening to crown
        crownSequencer.delegate = self
        crownSequencer.focus()
        
        // Load the SKScene from 'GameScene.sks'
        if let scene = GameScene(fileNamed: "GameScene") {
            
            gameScene = scene
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            self.skInterface.presentScene(scene)
            
            // Use a value that will maintain a consistent frame rate
            self.skInterface.preferredFramesPerSecond = 60

        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
            
        // convert crown rotation to CGFloat
        let step   = NSNumber.init(value: rotationalDelta * crownSensivity).floatValue
        let cgStep = CGFloat(step)

        if (cgStep < -0.5 || cgStep > 0.5) {
            // WKInterfaceDevice.current().play(.notification)
            gameScene.applyBirdImpulse()
        }
    }
    
    @IBAction func swipedRight(_ sender: Any) {
        WKInterfaceController.reloadRootPageControllers(
            withNames: ["MainMenu"], contexts: [], orientation: .horizontal, pageIndex: 0
        )
        
        self.pushController(withName: "MainMenu", context: nil)
    }

}
