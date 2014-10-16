//
//  InvaderMissile.swift
//  SpriteKitDesktop1
//
//  Created by Tom Elliott on 30/08/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class InvaderMissile : SKSpriteNode {
    
    override convenience init(){
        self.init(coder: nil)
    }
    
    func setMovement(){
        let moveDown = SKAction.moveBy(CGVectorMake(0,-20), duration:0.1);
        runAction(SKAction.repeatActionForever(moveDown));
    }
    
    required init(coder: NSCoder!) {
        let texture = SKTexture(imageNamed: "InvaderMissile")
        
        super.init(texture: texture, color: NSColor.clearColor(), size: texture.size())
        
        self.zPosition = 2
        
        let scale = CGFloat(0.6)
        let size = CGSizeMake(texture.size().width*scale, texture.size().height*scale)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = ColliderType.InvaderMissile.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = ColliderType.Player.rawValue | ColliderType.PlayerMissile.rawValue | ColliderType.PlayArea.rawValue
        setScale(scale)
        
        setMovement()
    }
    
    func hitPlayer(){
        let disappear = SKAction.removeFromParent()
        runAction(disappear)
    }
    
}
