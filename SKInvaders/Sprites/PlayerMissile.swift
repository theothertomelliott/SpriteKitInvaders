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
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let texture = SKTexture(imageNamed: "PlayerMissile")
        
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.zPosition = 2
        
        let scale = CGFloat(0.6)

        self.physicsBody = SKPhysicsBody(rectangleOfSize: texture.size())
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = ColliderType.PlayerMissile.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = ColliderType.PlayArea.rawValue | ColliderType.Invader.rawValue | ColliderType.InvaderMissile.rawValue
        setScale(scale)
        
        let moveUp = SKAction.moveBy(CGVectorMake(0,60), duration:0.1);
        runAction(SKAction.repeatActionForever(moveUp));
    }
    
    func hitInvader(){
        let disappear = SKAction.removeFromParent()
        runAction(disappear)
    }
    
}
