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
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let texture = SKTexture(imageNamed: "Shield")
        
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        let scale = CGFloat(1)
        let size = CGSizeMake(texture.size().width*scale, texture.size().height*scale)
        
        let sd : ShieldDamageSprite = ShieldDamageSprite()
        
        let w : CGFloat = sd.frame.width / 2.5
        let h : CGFloat = sd.frame.height
        
        for var x : CGFloat = 0; x < size.width; x+=w {
            for var y : CGFloat = 0; y < size.height+h; y+=h {
                let segment = ShieldDamageSprite()
                segment.position = CGPointMake(x-size.width/2,y-size.height/2)
                self.addChild(segment)
            }
        }
        
        setScale(scale)
    }
    
}