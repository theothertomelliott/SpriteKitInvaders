//
//  InvaderSheetController.swift
//  SKInvaders
//
//  Created by Tom Elliott on 13/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class InvaderSheetController {
    
    var _scene : SKScene
    var _invaders : [InvaderSprite]
    var _deadSprites : [InvaderSprite]
    
    let columns = 11
    
    init(scene: SKScene){
        _scene = scene;
        
        // Create invaders
        _invaders = []
        _deadSprites = []
        
        // Type A
        for i in 1...2 {
            for i in 1...columns{
                _invaders.append(InvaderASprite())
            }
        }
        
        // Type B
        for i in 1...2 {
            for i in 1...columns {
                _invaders.append(InvaderBSprite())
            }
        }
        
        // Type C
        for i in 1...1 {
            for i in 1...columns {
                _invaders.append(InvaderCSprite())
            }
        }
    }
    
    var workingSprite = 0
    var goingRight = true
    var goingDown = false
    
    var spritesAtLeft = 0
    var spritesAtRight = 0
    
    func invaderHit(invader: InvaderSprite){
        invader.hitByMissile()
        _deadSprites.append(invader)
    }
    
    /**
    * Handle collision between a player missile and an invader
    */
    private func missileCollision(playermissile: PlayerMissile, invader: InvaderSprite){
        // Destroy the invader and missile
        playermissile.hitInvader()
        self.invaderHit(invader)
        // TODO: Add the score for destroying this invader
        //score += invader.score()
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        
        // Identify the non-invader body in the collision
        var otherBody = contact.bodyA
        var invaderHit = contact.bodyB
        if ColliderType.Invader.toRaw() == contact.bodyA.categoryBitMask {
            otherBody = contact.bodyB
            invaderHit = contact.bodyA
        }
        
        /** Player missile collisions **/
        if(ColliderType.PlayerMissile.toRaw() == otherBody.categoryBitMask){
                missileCollision(otherBody.node as PlayerMissile, invader: invaderHit.node as InvaderSprite)
        }

        /** Edge collisions **/
        if(ColliderType.LeftEdge.toRaw() == otherBody.categoryBitMask){
                spritesAtLeft++
        }
        if(ColliderType.RightEdge.toRaw() == otherBody.categoryBitMask){
                spritesAtRight++
        }
    }
    
    func didEndContact(contact: SKPhysicsContact!) {
        
        // Identify the non-invader body in the collision
        var otherBody = contact.bodyA
        if ColliderType.Invader.toRaw() == contact.bodyA.categoryBitMask {
            otherBody = contact.bodyB
        }
        
        
        
        
        if(ColliderType.LeftEdge.toRaw() == otherBody.categoryBitMask){
            NSLog("didEndContactLeft")
            spritesAtLeft--
            NSLog("now %d at left", spritesAtLeft)
        }
        if(ColliderType.RightEdge.toRaw() == otherBody.categoryBitMask){
            NSLog("didEndContactRight")
            spritesAtRight--
            NSLog("now %d at right", spritesAtRight)
        }

    }
    
    /**
     * Advance workingSprite to the next live invader
     */
    func getNextSprite(){
        // Move on to the next non-dead sprite
        var done = false
        workingSprite++
        while !done && workingSprite < _invaders.count {
            done = true
            
            // Skip over dead sprites
            for dead : InvaderSprite in _deadSprites {
                if dead == _invaders[workingSprite] {
                    done = false
                    workingSprite++
                    break
                }
            }
        }
    }
    
    func moveWorking(){
        if(workingSprite < self._invaders.count){
            let sprite : InvaderSprite = self._invaders[workingSprite]
            let moveRight = SKAction.moveBy(CGVectorMake(30,0), duration:0.0);
            let moveLeft = SKAction.moveBy(CGVectorMake(-30,0), duration:0.0);
            if(goingRight){
                sprite.runAction(moveRight)
            } else {
                sprite.runAction(moveLeft)
            }
            
            if goingDown {
                let moveDown = SKAction.moveBy(CGVectorMake(0,-30), duration:0.0);
                sprite.runAction(moveDown)
            }
            
            getNextSprite()
        } else {
            workingSprite = 0
            
            NSLog("Sprites at edge left = %d, right = %d", spritesAtLeft, spritesAtRight)
            
            if(spritesAtRight > 0 || spritesAtLeft > 0){
                goingDown = true
            } else {
                goingDown = false
            }
            
            // Change direction (need to move down too)
            if(spritesAtRight > 0){
                goingRight = false
            }
            if(spritesAtLeft > 0){
                goingRight = true
            }
        }
    }
    
    func start(){
        
        var moveSprite = SKAction.runBlock({
            self.moveWorking()
        })
        
        let delay = 0.5 / _invaders.count
        
        var waitAction = SKAction.waitForDuration(NSTimeInterval(delay))
        
        var seq = SKAction.sequence([waitAction,moveSprite])
        
        _scene.runAction(SKAction.repeatActionForever(seq))
        
    }
    
    func addToScene(startPos: CGPoint){
        
        var xPos = 0
        var yPos = 0
        
        let xSeparation = 60
        let ySeparation = 60
        
        for invader : InvaderSprite in _invaders {
            invader.position = CGPointMake(CGFloat(startPos.x + CGFloat(xPos)), CGFloat(startPos.y + CGFloat(yPos)))
            _scene.addChild(invader)
            
            xPos += xSeparation
            if(xPos/xSeparation >= (columns)){
                xPos = 0
                yPos += ySeparation
            }
        }
        
    }
    
}