//
//  InvaderSheetController.swift
//  SKInvaders
//
//  Created by Tom Elliott on 13/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

protocol InvaderDelegate {
    
    func landed()
    func SheetCompleted()
    
}

/// A controller class for managing a full sheet of invaders
class InvaderSheetController {
    
    private var _scoring : ScoreController
    private var _scene : SKScene
    private var _invaders : [InvaderSprite]
    
    var cycleInterval : NSTimeInterval
    
    var delegate : InvaderDelegate!
    
    /// Number of columns of invaders in the sheet
    let columns = 11
    
    init(scene: SKScene, scoring: ScoreController){
        _scene = scene
        _scoring = scoring
        
        // Create invaders
        _invaders = []
        
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
        
        cycleInterval = NSTimeInterval(0.5)
    }
    
    var workingSprite = 0
    var goingRight = true
    var goingDown = false
    
    /**
    * Handle collision between a player missile and an invader
    */
    private func missileCollision(playermissile: PlayerMissile, invader: InvaderSprite){
        // Destroy the invader and missile
        playermissile.hitInvader()
        invader.hitByMissile()
        
        // Add the score for destroying this invader
        _scoring.incrementScore(invader.score())
        
        if liveInvaderCount() == 0 {
            self.pause()
            delegate?.SheetCompleted()
        }
    }
    
    
    /**
        Count the remaining live invaders
    */
    func liveInvaderCount() -> Int {
        var count = 0
        for invader in _invaders {
            if(invader.isAlive()){
                count++
            }
        }
        
        
        return count
    }
    
    /**
        Get rid of remaining invaders
    */
    func clearSheet(){
        for invader in _invaders {
            invader.removeFromParent()
        }
    }
    
    func pause(){
        _scene.removeActionForKey("invaders.move")
        _scene.removeActionForKey("invaders.fire")
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        
        // Identify the non-invader body in the collision
        var otherBody = contact.bodyA
        var invaderHit = contact.bodyB
        if ColliderType.Invader.toRaw() == contact.bodyA.categoryBitMask {
            otherBody = contact.bodyB
            invaderHit = contact.bodyA
        }
        
        if let invaderNode = invaderHit?.node as? InvaderSprite {
            invaderNode.didBeginContact(otherBody, contact: contact)
        }
        
        /** Player missile collisions **/
        if(ColliderType.PlayerMissile.toRaw() == otherBody.categoryBitMask){
                missileCollision(otherBody.node as PlayerMissile, invader: invaderHit.node as InvaderSprite)
        }
        
        /** When an invader reaches the bottom of the screen **/
        if(ColliderType.BottomEdge.toRaw() == otherBody.categoryBitMask){
            // TODO: Force a game over
            delegate?.landed()
        }
    }
    
    func didEndContact(contact: SKPhysicsContact!) {
        
        // Identify the non-invader body in the collision
        var otherBody = contact.bodyA
        var invaderHit = contact.bodyB
        if ColliderType.Invader.toRaw() == contact.bodyA.categoryBitMask {
            otherBody = contact.bodyB
            invaderHit = contact.bodyA
        }
        
        if let invaderNode = invaderHit?.node as? InvaderSprite {
            invaderNode.didEndContact(otherBody, contact: contact)
        }
        
    }
    
    /**
     * Advance workingSprite to the next live invader
     */
    func getNextSprite(){
        // Move on to the next non-dead sprite
        
        let workingStart = workingSprite
        
        var done = false
        workingSprite++
        while workingSprite < _invaders.count && _invaders[workingSprite].isDestroyed() {
            workingSprite++
        }
    }
    
    /**
    
        Obtain a count of sprites currently on the right edge
    
    */
    private func spritesAtRight() -> Int {
        var count = 0
        for sprite in _invaders {
            if(sprite.isAlive() && sprite.collidingRight){
                count++
            }
        }
        return count
    }

    
    /**
    
    Obtain a count of sprites currently on the left edge
    
    */
    private func spritesAtLeft() -> Int {
        var count = 0
        for sprite in _invaders {
            if(sprite.isAlive() && sprite.collidingLeft){
                count++
            }
        }
        return count
    }
    
    /** Move the current working invader **/
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
            
            let sl = spritesAtLeft()
            let sr = spritesAtRight()
            
            if(sl > 0 || sr > 0){
                goingDown = true
            } else {
                goingDown = false
            }
            
            // Change direction (need to move down too)
            if(sr > 0){
                goingRight = false
            }
            if(sl > 0){
                goingRight = true
            }
        }
    }
    
    func start(){
        
        setMoveSequence()
        setFiringSequence()
        
    }
    
    /** Add the invaders to the scene **/
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
    
    func fireMissile(){
        
        // Identify the invaders that don't have any invaders below them
        var frontRow : [InvaderSprite] = []
        
        for i in 0...(columns-1) {
            // For the current column, find the invader on the lowest row that is still alive
            var row = 0
            while (row*columns + i) < _invaders.count {
                if(_invaders[row*columns + i].isAlive()){
                    frontRow.append(_invaders[row*columns + i])
                    break;
                }
                row++
            }
        }
        
        // Choose a random invader in the front row to fire
        let ri = arc4random_uniform(UInt32(frontRow.count))
        frontRow[Int(ri)].fireMissile()
        
    }
    
    func setMoveSequence(){
        var moveSprite = SKAction.runBlock({
            self.moveWorking()
        })
        
        let delay = Int(cycleInterval) / _invaders.count
        
        var waitAction = SKAction.waitForDuration(NSTimeInterval(delay))
        
        var seq = SKAction.sequence([waitAction,moveSprite])
        
        _scene.runAction(SKAction.repeatActionForever(seq), withKey: "invaders.move")
    }
    
    func setFiringSequence(){
        let firingActions = [
            SKAction.waitForDuration(3),
            SKAction.runBlock {
                self.fireMissile()
            }
        ]
        _scene.runAction(SKAction.repeatActionForever(SKAction.sequence(firingActions)), withKey: "invaders.fire")
        
    }

    
}