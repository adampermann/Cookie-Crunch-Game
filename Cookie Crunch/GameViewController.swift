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
    var movesLeft: Int!
    var score: Int!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    
    func beginGame() {
        movesLeft = level.maximumMoves
        score = 0
        updateLables()
        self.shuffle()
    }
    
    func shuffle() {
        let newCookies = self.level.shuffle()
        self.scene.addSpritesForCookies(newCookies)
    }
    
    // Handle swipe is called any time the GameScene
    // attemts a swap between cookies
    func handleSwipe(swap: Swap) {
        self.scene.userInteractionEnabled = false
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap, completion: handleMatches)
        }
    }
    
    // Handles the matches the player makes
    // this function is called back after animating a swap (valid or invalid)
    // 
    // This function is also recursive in that after a swap
    // if there are any cookies that are dropped which result in
    // new chains, it will continue matching until none
    // are left and control is given back to player.
    func handleMatches() {
        let chains = level.removeMatches()
        if chains.count == 0 {
            // break recursion once no more matches
            beginNextTurn()
            return
        }
        scene.animateMatchedCookies(chains) {
            for chain in chains {
                self.score! += chain.score
            }
            self.updateLables()
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns) {
                let columns = self.level.topOffCookies()
                self.scene.animateNewCookies(columns) {
                    
                    // recursion
                    self.handleMatches()
                }
            }
        }
    }
    
    func beginNextTurn() -> Void {
        level.detectPossibleSwaps()
        scene.userInteractionEnabled = true
        view.userInteractionEnabled = true
    }
    
    func updateLables() {
        targetLabel.text = String(format: "%ld", level.targetScore)
        movesLabel.text = String(format: "%ld", movesLeft)
        scoreLabel.text = String(format: "%ld", score)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
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
        
        self.level = Level(filename: "Level_3")
        scene.level = self.level
        scene.addTiles()
        
        self.beginGame()
    }
}
