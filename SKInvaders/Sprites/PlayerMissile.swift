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

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init() {
        let texture = SKTexture(imageNamed: "PlayerMissile")
        
        super.init(texture: texture, color: NSColor.clearColor(), size: texture.size())
        
        self.zPosition = 2
        
        let scale = CGFloat(0.6)
        let size = CGSizeMake(texture.size().width*scale, texture.size().height*scale)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = ColliderType.PlayerMissile.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = ColliderType.PlayArea.rawValue | ColliderType.Invader.rawValue | ColliderType.InvaderMissile.rawValue
        setScale(scale)
        
        let moveUp = SKAction.moveBy(CGVectorMake(0,40), duration:0.1);
        runAction(SKAction.repeatActionForever(moveUp));
    }
    
    func hitInvader(){
        let disappear = SKAction.removeFromParent()
        runAction(disappear)
    }
    
}
