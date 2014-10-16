//
//  MotherShipSprite.swift
//  SKInvaders
//
//  Created by Tom Elliott on 19/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class MotherShipSprite : InvaderSprite {
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    required init(){
        super.init(imageNames: ["Mothership"], scale: 0.6)
        
        removeActionForKey("walk")
        let moveLeft = SKAction.moveBy(CGVector(dx: -20,dy: 0), duration: 0.1)
        self.runAction(SKAction.repeatActionForever(moveLeft), withKey: "walk")
    }
    
    /**
    * Score awarded for destruction
    */
    override func score() -> Int{
        return 50
    }
    
    override func outOfBounds(){
        // Get rid of this sprite if it ever goes out of the play area
        self.removeFromParent()
    }
    
    override func didBeginContact(body: SKPhysicsBody, contact: SKPhysicsContact!) {
    }
    
    
    override func didEndContact(body: SKPhysicsBody, contact: SKPhysicsContact!) {
    }

}