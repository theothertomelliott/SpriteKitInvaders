//
//  PlayerMissile.swift
//  SpriteKitDesktop1
//
//  Created by Tom Elliott on 28/08/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerMissile : SKSpriteNode {
    
    override convenience init(){
        self.init(coder: nil)
    }
    
    required init(coder: NSCoder!) {
        let texture = SKTexture(imageNamed: "PlayerMissile")
        
        super.init(texture: texture, color: NSColor.clearColor(), size: texture.size())
        
        let scale = CGFloat(0.6)
        let size = CGSizeMake(texture.size().width*scale, texture.size().width*scale)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = ColliderType.PlayerMissile.toRaw()
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = ColliderType.Invader.toRaw() | ColliderType.PlayerMissile.toRaw()
        setScale(scale)
        
        let moveUp = SKAction.moveBy(CGVectorMake(0,40), duration:0.1);
        runAction(SKAction.repeatActionForever(moveUp));
    }
    
    func hitInvader(){
        let disappear = SKAction.removeFromParent()
        runAction(disappear)
    }
    
}
