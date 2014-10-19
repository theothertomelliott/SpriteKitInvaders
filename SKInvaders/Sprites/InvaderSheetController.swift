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
    private var _motherShip : MotherShipSprite!
    private var _playArea : SKNode
    private var _level : UInt
    private var _invaderSpeedX : CGFloat!
    private var _invaderSpeedY : CGFloat!
    
    var cycleInterval : NSTimeInterval
    
    var delegate : InvaderDelegate!
    
    var workingSprite = 0
    var goingRight = true
    var goingDown = false
    
    /// Number of columns of invaders in the sheet
    let columns = 11
    
    init(scene: SKScene, scoring: ScoreController, playArea: SKNode, level: UInt){
        _scene = scene
        _scoring = scoring
        _playArea = playArea
        _level = level
        
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
        
        let sw : CGFloat = startingSize().width
        let sh : CGFloat = startingSize().height
        
        _invaderSpeedX = (_playArea.frame.width - sw)/15
        _invaderSpeedY = (_playArea.frame.height - sh)/10
        
        NSLog("Play area width = %@, starting width = %@", _playArea.frame.width, sw)
        NSLog("Invader speed = %@", _invaderSpeedX)
    }
    
    private func invaderSeparation() -> CGSize {
        
        var maxW = CGFloat(0)
        var maxH = CGFloat(0)
        
        for invader : InvaderSprite in _invaders {
            
            let w = invader.size.width
            let h = invader.size.height
            
            if(w > maxW){
                maxW = w
            }
            
            if(h > maxH){
                maxH = h
            }
            
        }
        
        return CGSizeMake(maxW * 1.5,maxH * 2)
    }
    
    private func startingSize() -> CGSize {
        
        let separation = self.invaderSeparation()
        
        let w : CGFloat = separation.width * CGFloat(columns)
        let h : CGFloat = CGFloat(_invaders.count / columns) * separation.height
        
        return CGSizeMake(w,h)
        
    }

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
        _scene.removeActionForKey("mothership.spawn")
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        
        // Identify the non-invader body in the collision
        var otherBody = contact.bodyA
        var invaderHit = contact.bodyB
        if ColliderType.Invader.rawValue == contact.bodyA.categoryBitMask {
            otherBody = contact.bodyB
            invaderHit = contact.bodyA
        }
        
        if let invaderNode = invaderHit?.node as? InvaderSprite {
            invaderNode.didBeginContact(otherBody, contact: contact)
        }
        
        /** Player missile collisions **/
        if(ColliderType.PlayerMissile.rawValue == otherBody.categoryBitMask){
                missileCollision(otherBody.node as PlayerMissile, invader: invaderHit.node as InvaderSprite)
        }
        
        /** When an invader reaches the bottom of the screen **/
        if(ColliderType.BottomEdge.rawValue == otherBody.categoryBitMask){
            // TODO: Force a game over
            delegate?.landed()
        }
    }
    
    func didEndContact(contact: SKPhysicsContact!) {
        
        // Identify the non-invader body in the collision
        var otherBody = contact.bodyA
        var invaderHit = contact.bodyB
        if ColliderType.Invader.rawValue == contact.bodyA.categoryBitMask {
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
            if(sprite.isAlive()){
                if(sprite.position.x + sprite.frame.width/2 > _playArea.position.x + _playArea.frame.width/2){
                    count++
                }
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
            if(sprite.isAlive()){
                if(sprite.position.x - sprite.frame.width/2 < _playArea.position.x - _playArea.frame.width/2){
                    count++
                }
            }
        }
        return count
    }
    
    /** Move the current working invader **/
    func moveWorking(){
        if(workingSprite < self._invaders.count){
            let sprite : InvaderSprite = self._invaders[workingSprite]
            sprite.move(CGVectorMake(_invaderSpeedX,_invaderSpeedY), isMovingRight: goingRight, isMovingDown: goingDown)
            getNextSprite()
            
        } else {
            workingSprite = 0
            
            let sl = spritesAtLeft()
            let sr = spritesAtRight()
            
            if((sl > 0 || sr > 0) && !goingDown){
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
        setMothershipSequence()
        
    }
    
    /** Add the invaders to the scene **/
    func addToScene(){
        
        let sheetSize = self.startingSize()
        let startPos = CGPointMake(
            _playArea.position.x - _playArea.frame.width/2 + _invaderSpeedX*7,
            ((_playArea.position.y + _playArea.frame.height/2) - sheetSize.height/2) - _invaderSpeedY*(2+CGFloat(_level))
        )
        
        let separation = self.invaderSeparation()
        
        var xPos = CGFloat(0)
        var yPos = CGFloat(0)
        
        var column = 1
        for invader : InvaderSprite in _invaders {
            invader.position = CGPointMake(CGFloat(startPos.x + CGFloat(xPos)), CGFloat(startPos.y + CGFloat(yPos)))
            _scene.addChild(invader)
            
            xPos += separation.width
            
            column++
            if(column > (columns)){
                xPos = 0
                yPos += separation.height
                column = 1
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
    
    func setMothershipSequence(){
        let mothershipAction = [
            SKAction.waitForDuration(10),
            SKAction.runBlock {
                if (self._motherShip == nil) || self._motherShip.isDestroyed() {
                    if arc4random_uniform(5) == 1 {
                        self._motherShip = MotherShipSprite()
                    
                        let xPos = self._playArea.position.x + self._playArea.frame.width/2
                        let yPos = self._playArea.position.y + self._playArea.frame.height/2
                    
                        self._motherShip.position = CGPointMake(xPos, yPos)
                        self._scene.addChild(self._motherShip)
                    }
                }
            }
        ]
        _scene.runAction(SKAction.repeatActionForever(SKAction.sequence(mothershipAction)), withKey: "mothership.spawn")
    }

    
}