//
//  GameScene.swift
//  Cookie Crunch
//
//  Created by Adam on 4/10/15.
//  Copyright (c) 2015 Adam Inc. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
    }
}
