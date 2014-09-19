//
//  InvaderSprite.swift
//  SpriteKitDesktop1
//
//  Created by Tom Elliott on 23/08/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class InvaderSprite : SKSpriteNode {
    
    private var textures: [SKTexture]
    private var alive : Bool
    private var scaledSize : CGSize
    private(set) var collidingLeft : Bool
    private(set) var collidingRight : Bool
    
    init(imageNames: [NSString], scale: CGFloat) {
        
        NSLog("Create Invader")
        
        textures = []
        alive = true;
        
        collidingLeft = false
        collidingRight = false
        
        for imageN in imageNames {
            let texture  = SKTexture(imageNamed: imageN)
            textures += [texture]
        }
        
        scaledSize = CGSizeMake(textures[0].size().width*scale, textures[0].size().height*scale)
        
        super.init(texture: textures[0], color: NSColor.clearColor(), size: textures[0].size())
        
        // Set up animation
        let walk = SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(0.5))
        runAction(SKAction.repeatActionForever(walk), withKey: "walk")
        
        // Configure physics body sized to texture
        self.physicsBody = SKPhysicsBody(rectangleOfSize: scaledSize)
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = ColliderType.Invader.toRaw()
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
        
        setScale(scale)
        
    }
    
    required init(coder: NSCoder!) {
        textures = []
        let texture  = SKTexture(imageNamed: "InvaderAFrame1")
        scaledSize = texture.size()
        alive = true
        collidingLeft = false
        collidingRight = false
        super.init(texture: texture, color: NSColor.clearColor(), size: texture.size())
    }
    
    func didBeginContact(body: SKPhysicsBody, contact: SKPhysicsContact!) {
        if body.categoryBitMask == ColliderType.LeftEdge.toRaw(){
            collidingLeft = true
        }
        if body.categoryBitMask == ColliderType.RightEdge.toRaw(){
            collidingRight = true
        }
    }
    
    
    func didEndContact(body: SKPhysicsBody, contact: SKPhysicsContact!) {
        if body.categoryBitMask == ColliderType.LeftEdge.toRaw(){
            collidingLeft = false
        }
        if body.categoryBitMask == ColliderType.RightEdge.toRaw(){
            collidingRight = false
        }
    }
    
    
    /**
     * Score awarded for destruction
     */
    func score() -> Int{
        return 10
    }
    
    func fireMissile(){
        var missile : InvaderMissile
        let num = arc4random_uniform(3)
        if(num == 0){
            missile = InvaderMissileA()
        } else if(num == 1){
            missile = InvaderMissileB()
        } else {
            missile = InvaderMissileC()
        }
        if let pos = self.parent?.position {
            missile.position = CGPointMake(
                self.position.x + pos.x,
                self.position.y - self.scaledSize.height + pos.y
            )
        }
        self.parent?.addChild(missile)
    }
    
    func isAlive() -> Bool{
        return alive
    }
    
    func isDestroyed() -> Bool {
        return parent == nil
    }
    
    func hitByMissile(){
        alive = false
        
        // Disable physics
        self.physicsBody = nil
        
        let textures = [SKTexture(imageNamed: "InvaderExplosion")]
        let die = SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(0.5))
        let remove = SKAction.removeFromParent()
        let dieSequence = SKAction.sequence([die, remove])
        
        removeActionForKey("walk")
        
        runAction(dieSequence, withKey: "die")
        
    }
    
    deinit {
        NSLog("uninit Invader")
    }
    
    func Explode(){
        // TODO: Explode this invader
    }

}