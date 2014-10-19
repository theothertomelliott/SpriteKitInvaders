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
    
    init(imageNames: [NSString], scale: CGFloat) {
        
        NSLog("Create Invader")
        
        textures = []
        alive = true;
        
        for imageN in imageNames {
            let texture = SKTexture(imageNamed: imageN)
            textures += [texture]
        }
        
        super.init(texture: textures[0], color: NSColor.clearColor(), size: textures[0].size())
        
        // Set up animation
        let walk = SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(0.5))
        runAction(SKAction.repeatActionForever(walk), withKey: "walk")
        
        // Configure physics body sized to texture
        self.physicsBody = SKPhysicsBody(rectangleOfSize: textures[0].size())
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = ColliderType.Invader.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = ColliderType.PlayArea.rawValue
        
        setScale(scale)
        
    }
    
    convenience required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func didBeginContact(body: SKPhysicsBody, contact: SKPhysicsContact!) {
    }
    
    
    func didEndContact(body: SKPhysicsBody, contact: SKPhysicsContact!) {
    }
    
    func outOfBounds(){
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
                self.position.y - self.size.height + pos.y
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