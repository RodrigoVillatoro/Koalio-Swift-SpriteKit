//
//  GameScene.swift
//  Koalio
//
//  Created by Rodrigo Villatoro on 7/6/14.
//  Copyright (c) 2014 RVD. All rights reserved.
//  http://www.raywenderlich.com/62049/sprite-kit-tutorial-make-platform-game-like-super-mario-brothers-part-1
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    var map = JSTileMap()
    var player = Player()
    var previousUpdateTime = CFTimeInterval()
    var walls = TMXLayer()
    var hazards = TMXLayer()
    var gameIsOver = Bool()
    var backgroundMusicPlayer = AVAudioPlayer()
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor(red: 0.4, green: 0.4, blue: 0.95, alpha: 1.0)
        self.userInteractionEnabled = true
        
        playBackgroundMusic()
        
        map = JSTileMap(named: "level1.tmx")
        addChild(map)
        
        walls = map.layerNamed("walls")
        hazards = map.layerNamed("hazards")
        
        player = Player(imageNamed: "koalio_stand")
        player.position = CGPointMake(100, 50)
        player.zPosition = 15
        map.addChild(player)
        
    }
    
    func playBackgroundMusic() -> () {
        var error: NSError?
        let backgroundMusicURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("level1", ofType: "mp3"))
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusicURL, error: &error)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }
    
    func tileRectFromTileCoords(tileCoords: CGPoint) -> CGRect {
        let levelHeightInPixels = map.mapSize.height * map.tileSize.height
        let origin = CGPointMake(tileCoords.x * map.tileSize.width, levelHeightInPixels - ((tileCoords.y + 1) * map.tileSize.height))
        return CGRectMake(origin.x, origin.y, map.tileSize.width, map.tileSize.height)
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
            
            if playerCoord.y >= self.map.mapSize.height - 1 {
                gameOver(true)
                return
            }
            
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
    
    func handleHazardCollisions(player: Player){
        
        if gameIsOver {
            return
        }
        
        let indices = [7, 1, 3, 5, 0, 2, 6, 8]
        for var i = 0; i < 8; i++ {
            let tileIndex = Int(indices[i])
            
            let playerRect = player.collisionBoundingBox()
            let playerCoord = hazards.coordForPoint(player.desiredPosition)
            
            let tileColumn = tileIndex % 3
            let tileRow = tileIndex / 3
            let tileCoord = CGPointMake(playerCoord.x + CGFloat(tileColumn - 1), playerCoord.y + CGFloat(tileRow - 1))
            
            let gid = self.tileGIDAtTileCoord(tileCoord, layer: hazards)
            
            if gid != 0 {
                let tileRect = self.tileRectFromTileCoords(tileCoord)
                if CGRectIntersectsRect(playerRect, tileRect) {
                    gameOver(true)
                }
            }
        }
    }
    
    func checkForWin() {
        // 10 tiles before the map ends
        if player.position.x > ((map.mapSize.width * map.tileSize.width) - (map.tileSize.width * 10)) {
            self.gameOver(true)
        }
    }

    func gameOver(won: Bool){
        
        gameIsOver = true
        self.runAction(SKAction.playSoundFileNamed("hurt.wav", waitForCompletion: false))
        
        var gameText = ""
        
        if won {
            gameText = "You Won!"
        } else {
            gameText = "You died!!"
        }
        
        let endGameLabel = SKLabelNode(fontNamed: "Marker Felt")
        endGameLabel.text = gameText
        endGameLabel.fontSize = 40.0
        endGameLabel.position = CGPointMake(self.size.width / 2, self.size.height / 1.7)
        self.addChild(endGameLabel)
        
        let replay = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        replay.tag = 321
        let replayImage = UIImage(named: "replay")
        replay.setImage(replayImage, forState: UIControlState.Normal)
        replay.addTarget(self, action: "replayGame", forControlEvents: UIControlEvents.TouchUpInside)
        replay.frame = CGRectMake(self.size.width / 2 - replayImage.size.width / 2, self.size.height / 2 - replayImage.size.height / 2, replayImage.size.width, replayImage.size.height)
        self.view.addSubview(replay)
    }
    
    func replayGame() {
        self.view.viewWithTag(321).removeFromSuperview()
        self.view.presentScene(GameScene(size: self.scene.size))
    }
    
    func setViewpointCenter(position: CGPoint) {
        var x = returnMax(position.x, self.size.width / 2)
        var y = returnMax(position.y, self.size.height / 2)
        x = returnMin(x, (map.mapSize.width * map.tileSize.width) - self.size.width / 2)
        y = returnMin(y, (map.mapSize.height * map.tileSize.height) - self.size.height / 2)
        let actualPosition = CGPointMake(x, y)
        let centerOfView = CGPointMake(self.size.width / 2, self.size.height / 2)
        let viewPoint = CGPointSubtract(centerOfView, actualPosition)
        map.position = viewPoint
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            var touchLocation = touch.locationInNode(self)
            if touchLocation.x > self.size.width/2 {
                player.mightAsWellJump = true
            } else {
                player.forwardMarch = true
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent!) {
        for touch: AnyObject in touches {
            let halfWidth = self.size.width / 2.0
            var touchLocation = touch.locationInNode(self)
            var previousTouchLocation = touch.previousLocationInNode(self)
            if touchLocation.x > halfWidth && previousTouchLocation.x <= halfWidth {
                player.forwardMarch = false
                player.mightAsWellJump = true
            } else if previousTouchLocation.x > halfWidth && touchLocation.x <= halfWidth {
                player.forwardMarch = true
                player.mightAsWellJump = false
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent!) {
        for touch: AnyObject in touches {
            var touchLocation = touch.locationInNode(self)
            if touchLocation.x < self.size.width / 2 {
                player.forwardMarch = false
            } else {
                player.mightAsWellJump = false
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        
        if gameIsOver {
            return
        }
        
        var delta = currentTime - previousUpdateTime
        
        if delta > 0.02 {
            delta = 0.02
        }
        
        previousUpdateTime = currentTime
        player.updatePlayer(delta)
        
        checkForAndResolveCollisionForPlayer(player, layer: walls)
        handleHazardCollisions(player)
        checkForWin()
        setViewpointCenter(player.position)
        
    }
}











