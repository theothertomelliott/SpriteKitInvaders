//
//  InvaderASprite.swift
//  SpriteKitDesktop1
//
//  Created by Tom Elliott on 23/08/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class InvaderASprite : InvaderSprite
{
 
    required init() {
        super.init(imageNames: ["InvaderAFrame1", "InvaderAFrame2"], scale: 0.3)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
}