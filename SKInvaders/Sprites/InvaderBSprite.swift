//
//  InvaderBSprite.swift
//  SpriteKitDesktop1
//
//  Created by Tom Elliott on 23/08/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class InvaderBSprite : InvaderSprite
{
    
    convenience init(){
        self.init(coder: nil)
    }
    
    required init(coder: NSCoder!){
        super.init(imageNames: ["InvaderBFrame1", "InvaderBFrame2"])
    }
    
    /**
    * Score awarded for destruction
    */
    override func score() -> Int{
        return 20
    }
    
}