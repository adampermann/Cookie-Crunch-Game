//
//  GameViewController.swift
//  Cookie Crunch
//
//  Created by Adam on 4/10/15.
//  Copyright (c) 2015 Adam Inc. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!
    var level: Level!
    
    func beginGame() {
        self.shuffle()
    }
    
    func shuffle() {
        let newCookies = self.level.shuffle()
        self.scene.addSpritesForCookies(newCookies)
    }
    
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        level.performSwap(swap)
        
        // trailing closure syntax for animate swipe
        scene.animateSwap(swap) {
            self.view.userInteractionEnabled = true
        }
        
//        another way to code it would be
        
//        scene.animateSwap(swap, completion: {
//            self.view.userInteractionEnabled = true
//        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        self.scene = GameScene(size: skView.bounds.size)
        self.scene.scaleMode = .AspectFill
        
        scene.swipeHandler = handleSwipe
        // Present the scene.
        skView.presentScene(scene)
        
        self.level = Level(filename: "Level_1")
        scene.level = self.level
        scene.addTiles()
        
        self.beginGame()
    }
}
