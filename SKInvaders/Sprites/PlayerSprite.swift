//
//  PlayerSprite.swift
//  SpriteKitDesktop1
//
//  Created by Tom Elliott on 21/08/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerSprite : SKSpriteNode {

    var alive : Bool
    
    override convenience init(){
        self.init(coder: nil)
    }
    
    required init(coder: NSCoder!) {
        let texture = SKTexture(imageNamed: "Spaceship")
        
        atLeftEdge = false
        atRightEdge = false
        
        alive = true
        
        super.init(texture: texture, color: NSColor.clearColor(), size: texture.size())
        
        let scale = CGFloat(1)
        let size = CGSizeMake(texture.size().width*scale, texture.size().width*scale)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.categoryBitMask = ColliderType.Player.toRaw()
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
        setScale(scale)
    }
    
    var atLeftEdge : Bool
    var atRightEdge : Bool
    
    func didBeginContact(contact: SKPhysicsContact!) {
        if(ColliderType.Edge.toRaw() == contact.bodyA.categoryBitMask){
            // Block motion to that direction
            if(contact.contactPoint.x < position.x){
                atLeftEdge = true
            }
            if(contact.contactPoint.x > position.x){
                atRightEdge = true
            }
            if(contact.contactPoint.x == position.x){
                // TODO: Figure out which is better
            }
        }
    }
    
    func hitByMissile(){
        alive = false
        
        // Disable physics
        self.physicsBody = nil
        
        let textures = [SKTexture(imageNamed: "PlayerExplosion")]
        let die = SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(0.5))
        let remove = SKAction.removeFromParent()
        let dieSequence = SKAction.sequence([die, remove])
        
        removeActionForKey("walk")
        
        runAction(dieSequence, withKey: "die")

    }
    
    func didEndContact(contact: SKPhysicsContact!) {
        if(ColliderType.Edge.toRaw() == contact.bodyA.categoryBitMask){
            // Unblock motion
            atRightEdge = false
            atLeftEdge = false
        }
    }
    
    override func insertText(insertString: AnyObject){
        if(!alive){
            return
        }
        
        if(" " == insertString as NSString){

            let missile = PlayerMissile();
            missile.position = CGPointMake(position.x, position.y+40);
            
            var hasMissile = false
            
            // Check there isn't already a missile on the parent
            if let nodeList = parent?.children {
                for node in nodeList {
                    if(node is PlayerMissile){
                        hasMissile = true
                        break
                    }
                }
            }
            if(!hasMissile){
                parent?.addChild(missile)
            }
        }
    }
    
    override func moveLeft(o: AnyObject){
        if(alive && !atLeftEdge){
            let a = SKAction.moveBy(CGVectorMake(-20,0),duration:0);
            runAction(a)
        }
    }
    
    override func moveRight(o: AnyObject){
        if(alive && !atRightEdge){
            let a = SKAction.moveBy(CGVectorMake(20,0),duration:0);
            runAction(a)
        }
    }
    
}
