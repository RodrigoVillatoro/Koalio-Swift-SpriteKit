//
//  GameScene.swift
//  Koalio
//
//  Created by Rodrigo Villatoro on 7/6/14.
//  Copyright (c) 2014 RVD. All rights reserved.
//  http://www.raywenderlich.com/62049/sprite-kit-tutorial-make-platform-game-like-super-mario-brothers-part-1
//

import SpriteKit

class GameScene: SKScene {
    
    var map = JSTileMap()
    var player = Player()
    var previousUpdateTime = CFTimeInterval()
    var walls = TMXLayer()
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor(red: 0.4, green: 0.4, blue: 0.95, alpha: 1.0)
        self.userInteractionEnabled = true
        
        map = JSTileMap(named: "level1.tmx")
        addChild(map)
        
        walls = self.map.layerNamed("walls")
        
        player = Player(imageNamed: "koalio_stand")
        player.position = CGPointMake(100, 50)
        player.zPosition = 15
        map.addChild(player)
        
    }
    
    func tileRectFromTileCoords(tileCoords: CGPoint) -> CGRect {
        let levelHeightInPixels = self.map.mapSize.height * self.map.tileSize.height
        let origin = CGPointMake(tileCoords.x * self.map.tileSize.width, levelHeightInPixels - ((tileCoords.y + 1) * self.map.tileSize.height))
        return CGRectMake(origin.x, origin.y, self.map.tileSize.width, self.map.tileSize.height)
    }
    
    func tileGIDAtTileCoord(coord: CGPoint, layer:TMXLayer) -> NSInteger {
        let layerInfo = layer.layerInfo
        return layerInfo.tileGidAtCoord(coord)
    }
    
    func checkForAndResolveCollisionForPlayer(player: Player, layer:TMXLayer){
        let indices = [7, 1, 3, 5, 0, 2, 6, 8]
        player.onGround = false
        for var i = 0; i < 8; i++ {
            let tileIndex = Int(indices[i])
            let playerRect = player.collisionBoundingBox()
            let playerCoord = layer.coordForPoint(player.desiredPosition)
            let tileColumn = tileIndex % 3
            let tileRow = tileIndex / 3
            let tileCoord = CGPointMake(playerCoord.x + CGFloat(tileColumn - 1), playerCoord.y + CGFloat(tileRow - 1))
            let gid = self.tileGIDAtTileCoord(tileCoord, layer: layer)
            
            if gid != 0 {
                var tileRect = self.tileRectFromTileCoords(tileCoord)
                if CGRectIntersectsRect(playerRect, tileRect) {
                    var intersection = CGRectIntersection(playerRect, tileRect)
                    if tileIndex == 7 {
                        player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height)
                        player.velocity = CGPointMake(player.velocity.x, 0.0)
                        player.onGround = true
                    } else if tileIndex == 1 {
                        player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y - intersection.size.height)
                    } else if tileIndex == 3 {
                        player.desiredPosition = CGPointMake(player.desiredPosition.x + intersection.size.width, player.desiredPosition.y)
                    } else if tileIndex == 5 {
                        player.desiredPosition = CGPointMake(player.desiredPosition.x - intersection.size.width, player.desiredPosition.y)
                    } else {
                        if intersection.size.width > intersection.size.height {
                            player.velocity = CGPointMake(player.velocity.x, 0.0)
                            var intersectionHeight = Float()
                            if tileIndex > 4 {
                                intersectionHeight = intersection.size.height
                                player.onGround = true
                            } else {
                                intersectionHeight = -intersection.size.height
                            }
                            player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height)
                        } else {
                            var intersectionWidth = Float()
                            if tileIndex == 6 || tileIndex == 0 {
                                intersectionWidth = intersection.size.width
                            } else {
                                intersectionWidth = -intersection.size.width
                            }
                            player.desiredPosition = CGPointMake(player.desiredPosition.x + intersectionWidth, player.desiredPosition.y)
                        }
                    }
                }
            }
        }
        player.position = player.desiredPosition
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            var touchLocation = touch.locationInNode(self)
            if touchLocation.x > self.size.width/2 {
                self.player.mightAsWellJump = true
            } else {
                self.player.forwardMarch = true
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent!) {
        for touch: AnyObject in touches {
            let halfWidth = self.size.width / 2.0
            var touchLocation = touch.locationInNode(self)
            var previousTouchLocation = touch.previousLocationInNode(self)
            if touchLocation.x > halfWidth && previousTouchLocation.x <= halfWidth {
                self.player.forwardMarch = false
                self.player.mightAsWellJump = true
            } else if previousTouchLocation.x > halfWidth && touchLocation.x <= halfWidth {
                self.player.forwardMarch = true
                self.player.mightAsWellJump = false
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent!) {
        for touch: AnyObject in touches {
            var touchLocation = touch.locationInNode(self)
            if touchLocation.x < self.size.width / 2 {
                self.player.forwardMarch = false
            } else {
                self.player.mightAsWellJump = false
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        
        var delta = currentTime - previousUpdateTime
        
        if delta > 0.02 {
            delta = 0.02
        }
        
        previousUpdateTime = currentTime
        player.updatePlayer(delta)
        
        self.checkForAndResolveCollisionForPlayer(player, layer: walls)
        
    }
}











