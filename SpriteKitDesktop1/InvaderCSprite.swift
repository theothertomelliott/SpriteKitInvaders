//
//  InvaderCSprite.swift
//  SpriteKitDesktop1
//
//  Created by Tom Elliott on 23/08/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class InvaderCSprite : InvaderSprite
{
    
    convenience init(){
        self.init(coder: nil)
    }
    
    required init(coder: NSCoder!){
        super.init(imageNames: ["InvaderCFrame1", "InvaderCFrame2"])
    }
    
    /**
    * Score awarded for destruction
    */
    override func score() -> Int{
        return 30
    }
    
}