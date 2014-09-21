//
//  ShieldDamageSprite.swift
//  SKInvaders
//
//  Created by Tom Elliott on 21/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class ShieldDamageSprite : SKSpriteNode {
    
    override convenience init(){
        self.init(coder: nil)
    }
    
    required init(coder: NSCoder!) {
        let texture = SKTexture(imageNamed: "ShieldDamage")
        
        super.init(texture: texture, color: NSColor.clearColor(), size: texture.size())

        let scale = CGFloat(1)
        let size = CGSizeMake((texture.size().width*scale)/2.5, texture.size().height*scale)
        
        self.zPosition = 1
        self.hidden = true
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = ColliderType.Shield.toRaw()
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = ColliderType.PlayerMissile.toRaw() | ColliderType.InvaderMissile.toRaw()
        
        setScale(scale)
    }
    
    func shot(){
        self.hidden = false
        self.physicsBody = nil
    }
    
}