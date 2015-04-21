//
//  GameScene.swift
//  Cookie Crunch
//
//  Created by Adam on 4/10/15.
//  Copyright (c) 2015 Adam Inc. All rights reserved.
//

import SpriteKit

// GameScene is a view that handles
// displaying the cookie sprites and
// the tile sprites as well as the layers
// in which they are in.

// GameScene also handles swipe detection
// logic but does not actually perform a
// swap as it is a view
class GameScene: SKScene {
    
    var level: Level!
    
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    
    // swipeHandler is a CLOSURE.
    // If it recognizes that the user made a swipe, it will call the 
    // closure that’s stored in the swipe handler.
    // This is how it communicates back to the 
    // GameViewController that a swap needs to take place.
    var swipeHandler: ((Swap) -> ())?
    
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    let tilesLayer = SKNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        self.addChild(background)
        self.addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        self.cookiesLayer.position = layerPosition
        self.tilesLayer.position = layerPosition
        self.gameLayer.addChild(self.tilesLayer)
        self.gameLayer.addChild(self.cookiesLayer)
        
        self.swipeFromColumn = nil
        self.swipeFromRow = nil
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        // convert point and see if the location touched was 
        // in the cookie layer
        let (success, column, row) = convertPoint(location)
        
        if success {
            
            // if the touch was acutaly on a cookie
            if let cookie = level.cookieAtColumn(column, row: row) {
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        // swipe form column is nil if touches began 
        // happened in an invalid area (ie. not cookie layer) 
        // or the cookies have already been swaped
        if swipeFromColumn == nil { return }
        
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn! {
                // swipe left
                horzDelta = -1
            } else if column > swipeFromColumn! {
                // swipe right
                horzDelta = 1
            } else if row < swipeFromRow! {
                // swipe down
                vertDelta = -1
            } else if row > swipeFromRow! {
                // swipe up
                vertDelta = 1
            }
            
            
            if horzDelta != 0 || vertDelta != 0 {
                trySwapHorizontal(horzDelta, vertical: vertDelta)
                
                // setting this back to nil will allow game scene logic
                // to ignore the rest of the swipe motion
                swipeFromColumn = nil
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        // called when user lifts finger from screen
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        // called when iOS cancels touch / swipe for
        // something such as a phone call
        touchesEnded(touches, withEvent: event)
    }
    
    func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int) {
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        
        // don't move the cookie to an invalid row or column
        if toColumn < 0 || toColumn >= NumColumns { return }
        if toRow < 0 || toRow >= NumRows { return }
        
        if let toCookie = level.cookieAtColumn(toColumn, row: toRow) {
            if let fromCookie = level.cookieAtColumn(swipeFromColumn!, row: swipeFromRow!) {
                if let handler = swipeHandler {
                    let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
                    handler(swap)
                }
                println("****** swapping \(fromCookie) with \(toCookie)")
            }
        }
    }
    
    func animateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        spriteA.runAction(moveA, completion: completion)
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB, completion: completion)
    }
    
    func addSpritesForCookies(cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.position = pointForColumn(cookie.column, row: cookie.row)
            self.cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
        }
    }
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let tile = level.tileAtColumn(column, row: row) {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForColumn(column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    // converts a column and row to a CGPoint
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    // convets a CGPoint to a column and row if in valid bounds of the scene
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                
                // the point is in bounds
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            // Invalid location
            return (false, 0, 0)
        }
    }
}
