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
    
    var textures: [SKTexture]
    var alive : Bool
    var scaledSize : CGSize
    
    init(imageNames: [NSString]) {
        
        NSLog("Create Invader")
        
        textures = []
        alive = true;
        
        for imageN in imageNames {
            let texture  = SKTexture(imageNamed: imageN)
            textures += [texture]
        }
        
        let scale = CGFloat(0.4)
        
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
        super.init(texture: texture, color: NSColor.clearColor(), size: texture.size())
    }
    
    /**
     * Score awarded for destruction
     */
    func score() -> Int{
        return 10
    }
    
    func fireMissile(){
        let missile = InvaderMissile()
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