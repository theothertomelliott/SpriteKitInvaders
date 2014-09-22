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
    var playArea : SKNode!
    
    override convenience init(){
        self.init(coder: nil)
    }
    
    required init(coder: NSCoder!) {
        let texture = SKTexture(imageNamed: "Spaceship")
        
        atLeftEdge = false
        atRightEdge = false
        
        alive = true
        
        super.init(texture: texture, color: NSColor.clearColor(), size: texture.size())
        
        let scale = CGFloat(0.8)
        let size = CGSizeMake(texture.size().width*scale, texture.size().height*scale)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.categoryBitMask = ColliderType.Player.toRaw()
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
        setScale(scale)
    }
    
    var atLeftEdge : Bool
    var atRightEdge : Bool
    
    func didBeginContact(contact: SKPhysicsContact!) {

    }
    
    func didEndContact(contact: SKPhysicsContact!) {

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
    
    func checkEdges(){
        if let p : SKNode = playArea {
            atLeftEdge = (self.position.x - self.frame.width/2 < p.position.x - p.frame.width/2);
            atRightEdge = (self.position.x + self.frame.width/2 > p.position.x + p.frame.width/2);
        }
    }
    
    override func moveLeft(o: AnyObject){
        if(alive && !atLeftEdge){
            let a = SKAction.moveBy(CGVectorMake(-20,0),duration:0.1);
            let b = SKAction.runBlock({
                    self.checkEdges();
                })
            runAction(SKAction.sequence([a,b]))
        }
    }
    
    override func moveRight(o: AnyObject){
        if(alive && !atRightEdge){
            let a = SKAction.moveBy(CGVectorMake(20,0),duration:0.1);
            let b = SKAction.runBlock({
                self.checkEdges();
            })
            runAction(SKAction.sequence([a,b]))
        }
    }
    
}
