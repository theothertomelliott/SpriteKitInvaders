//
//  ShieldSprite.swift
//  SKInvaders
//
//  Created by Tom Elliott on 20/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class ShieldSprite : SKSpriteNode {
    
    override convenience init(){
        self.init(coder: nil)
    }
    
    required init(coder: NSCoder!) {
        let texture = SKTexture(imageNamed: "Shield")
        
        var _colliders : [SKNode] = []
        
        super.init(texture: texture, color: NSColor.clearColor(), size: texture.size())
        
        let scale = CGFloat(1)
        let size = CGSizeMake(texture.size().width*scale, texture.size().height*scale)
        
        var sd : ShieldDamageSprite = ShieldDamageSprite()
        
        let w : CGFloat = sd.frame.width / 2.5
        let h : CGFloat = sd.frame.height
        
        for var x : CGFloat = 0; x < size.width; x+=w {
            for var y : CGFloat = 0; y < size.height; y+=h {
                
                let segment = ShieldDamageSprite()
                segment.position = CGPointMake(x-size.width/2,y-size.height/2)
                self.addChild(segment)
                
                _colliders.append(segment)
                
            }
        }
        
        setScale(scale)
    }
    
}