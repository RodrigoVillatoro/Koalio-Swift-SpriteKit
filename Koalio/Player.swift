//
//  Player.swift
//  Koalio
//
//  Created by Rodrigo Villatoro on 7/6/14.
//  Copyright (c) 2014 RVD. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
 
    var velocity = CGPointMake(0, 0)
    var desiredPosition = CGPoint()
    var onGround = Bool()
    var forwardMarch = Bool()
    var mightAsWellJump = Bool()
    
    func updatePlayer(delta: CFTimeInterval) {
        
        let gravity = CGPointMake(0, -450)
        let gravityStep = CGPointMultiplyScalar(gravity, CGFloat(delta))
        
        let forwardMove = CGPointMake(800.0, 0.0)
        let forwardStep = CGPointMultiplyScalar(forwardMove, CGFloat(delta))
        
        velocity = CGPointAdd(velocity, gravityStep)
        velocity = CGPointMake(velocity.x * 0.90, velocity.y)
        
        let jumpForce = CGPointMake(0.0, 310)
        let jumpCutoff: CGFloat = 150.0
        
        if mightAsWellJump && onGround {
            velocity = CGPointAdd(velocity, jumpForce)
            self.runAction(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false))
        } else if !mightAsWellJump && velocity.y > jumpCutoff {
            velocity = CGPointMake(velocity.x, jumpCutoff)
        }
        
        if forwardMarch {
            velocity = CGPointAdd(velocity, forwardStep)
        }
        
        let minMovement = CGPointMake(0.0, -450.0)
        let maxMovement = CGPointMake(120.0, 250.0)
        velocity = CGPointMake(Clamp(velocity.x, minMovement.x, maxMovement.y), Clamp(velocity.y, minMovement.y, maxMovement.y))
        
        let velocityStep = CGPointMultiplyScalar(velocity, CGFloat(delta))
        desiredPosition = CGPointAdd(self.position, velocityStep)
        
    }
    
    func collisionBoundingBox() -> CGRect {
        let boundingBox = CGRectInset(self.frame, 2, 0)
        var diff = CGPointSubtract(desiredPosition, self.position)
        return CGRectOffset(boundingBox, diff.x, diff.y)
    }
    
}
