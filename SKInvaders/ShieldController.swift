//
//  ShieldController.swift
//  SKInvaders
//
//  Created by Tom Elliott on 20/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class ShieldController : GameSubController, SKPhysicsContactDelegate {

    var shields : [ShieldSprite]
    
    override init(scene: SKScene, scoring: ScoreController, playArea: SKNode){
        shields = [ShieldSprite(),ShieldSprite(),ShieldSprite(), ShieldSprite()]
        super.init(scene: scene, scoring: scoring, playArea: playArea)
    }
    
    override func addToScene(){
        
        var x = _playArea.position.x - _playArea.frame.width/2 + _playArea.frame.width/8
        
        for shield in shields {
            shield.position =
                CGPointMake(
                    x,
                    _playArea.position.y-_playArea.frame.height/2 + 130
            )
            _scene.addChild(shield)
            
            x += _playArea.frame.width / 4
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        
        var collidedShield : ShieldDamageSprite!
        
        if(contact.bodyA.categoryBitMask == ColliderType.Shield.toRaw()){
            collidedShield = contact.bodyA.node as ShieldDamageSprite
        }
        if(contact.bodyB.categoryBitMask == ColliderType.Shield.toRaw()){
            collidedShield = contact.bodyB.node as ShieldDamageSprite
        }
        collidedShield.shot()
        
        if(contact.bodyA.categoryBitMask == ColliderType.PlayerMissile.toRaw()){
            let missile : PlayerMissile = contact.bodyA.node as PlayerMissile
            missile.hitInvader()
        }
        if(contact.bodyB.categoryBitMask == ColliderType.PlayerMissile.toRaw()){
            let missile : PlayerMissile = contact.bodyB.node as PlayerMissile
            missile.hitInvader()
        }
        
        if(contact.bodyA.categoryBitMask == ColliderType.InvaderMissile.toRaw()){
            let missile : InvaderMissile = contact.bodyA.node as InvaderMissile
            missile.hitPlayer()
        }
        if(contact.bodyB.categoryBitMask == ColliderType.InvaderMissile.toRaw()){
            let missile : InvaderMissile = contact.bodyB.node as InvaderMissile
            missile.hitPlayer()
        }
        
        
    }
    
    func didEndContact(contact: SKPhysicsContact!) {
    
    }
    
}