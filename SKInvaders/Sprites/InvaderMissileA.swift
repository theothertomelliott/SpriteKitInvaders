//
//  InvaderMissileA.swift
//  SKInvaders
//
//  Created by Tom Elliott on 17/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class InvaderMissileA : InvaderMissile {
    
    override func setMovement(){
        let moveDown = SKAction.moveBy(CGVectorMake(0,-20), duration:0.2);
        runAction(SKAction.repeatActionForever(moveDown));
    }
    
}