//
//  InvaderSheet.swift
//  SpriteKitDesktop1
//
//  Created by Tom Elliott on 23/08/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class InvaderSheet : SKSpriteNode {

    convenience override init(){
        self.init(coder: nil)
    }
    
    deinit {
        NSLog("deinit InvaderSheet")
    }
    
    var invader : InvaderSprite
    var sequenceRight : SKAction
    var sequenceLeft : SKAction
    var sequenceDown : SKAction
    // Front line invaders, ones who can fire
    var frontLine : [String: InvaderSprite]!
    var yourLine : SKShapeNode!
    
    required init(coder: NSCoder!){
        
        let distance = 60
        
        let width = 10*distance
        let height = 4*distance
        
        let initX = 0-(width/2)
        let initY = 0-(height/2)
        
        var xPos = initX
        var yPos = initY
        
        invader = InvaderASprite()
        
        let moveRight = SKAction.moveBy(CGVectorMake(30,0), duration:0.0);
        let moveLeft = SKAction.moveBy(CGVectorMake(-30,0), duration:0.0);
        let wait = SKAction.waitForDuration(1)
        let waitHalf = SKAction.waitForDuration(0.25)
        let moveDown = SKAction.moveBy(CGVectorMake(0,-30), duration:0.0);
        sequenceRight = SKAction.sequence([wait,moveRight])
        sequenceLeft = SKAction.sequence([wait,moveLeft])
        sequenceDown = SKAction.sequence([waitHalf, moveDown])
        
        goingRight = true
        
        let texture  = SKTexture(imageNamed: "Blank")
        super.init(texture: texture, color: NSColor.clearColor(), size: texture.size())

        runAction(SKAction.repeatActionForever(sequenceRight), withKey: "move")
        
        // Type A
        for i in 1...2 {
            for i in 1...11 {
                let invader = InvaderASprite()
                invader.position = CGPointMake(CGFloat(xPos), CGFloat(yPos))
                addChild(invader)
            
                xPos += distance
            }
            xPos = initX
            yPos += distance
        }
    
        // Type B
        for i in 1...2 {
            for i in 1...11 {
                let invader = InvaderBSprite()
                invader.position = CGPointMake(CGFloat(xPos), CGFloat(yPos))
                addChild(invader)
                
                xPos += distance
            }
            xPos = initX
            yPos += distance
        }
        
        // Type C
        for i in 1...1 {
            for i in 1...11 {
                let invader = InvaderCSprite()
                invader.position = CGPointMake(CGFloat(xPos), CGFloat(yPos))
                addChild(invader)
                
                xPos += distance
            }
            yPos += distance
        }

        setPhysicsBody()
        setFiringSequence()
    }
    
    func setFiringSequence(){
        let firingActions = [
            SKAction.waitForDuration(3),
            SKAction.runBlock {
                // Randomly decide to add a missile
                let fireIndex = Int(arc4random_uniform(UInt32(self.frontLine.count)))
                var count = 0
                for (xpos, invader) in self.frontLine {
                    if(count == fireIndex){
                        invader.fireMissile()
                    }
                    count++
                }
            }
        ]
        runAction(SKAction.repeatActionForever(SKAction.sequence(firingActions)))
        
    }
    
    func setPhysicsBody() {
        var bottomCorner : CGPoint!
        var topCorner : CGPoint!
        var count = 0
        
        frontLine = Dictionary<String, InvaderSprite>()
        
        for node in children {
            if(node is InvaderSprite && (node as InvaderSprite).isAlive()){
                let invader : InvaderSprite = node as InvaderSprite
                
                // Invader Position - Lowest point
                let ipl = CGPointMake(invader.position.x - invader.size.width/2, invader.position.y - node.size.width/2)
                // Invader Position - Highest point
                let iph = CGPointMake(invader.position.x + invader.size.width/2, invader.position.y + node.size.height/2)
                
                // Find the front line of invaders
                let xpos : NSString = invader.position.x.description
                if let current = frontLine[xpos] {
                    if(current.position.y > invader.position.y){
                        frontLine[xpos] = invader
                    }
                } else {
                    frontLine[xpos] = invader
                }
                
                count++
                
                if(bottomCorner == nil){
                    bottomCorner = ipl
                } else {
                    if(invader.position.x < bottomCorner.x){
                        bottomCorner.x = ipl.x
                    }
                    if(invader.position.y < bottomCorner.y){
                        bottomCorner.y = ipl.y
                    }
                }
                
                if(topCorner == nil){
                    topCorner = iph
                } else {
                    if(iph.x > topCorner.x){
                        topCorner.x = iph.x
                    }
                    if(iph.y > topCorner.y){
                        topCorner.y = iph.y
                    }
                }
            }
        }
        NSLog("Counted %d invaders", count)
        
        if(yourLine != nil){
            yourLine.removeFromParent()
            yourLine = nil
        }
        
        if(count > 0){

            let edgeSize = CGSizeMake(topCorner.x - bottomCorner.x, topCorner.y - bottomCorner.y)
            let edgeCenter = CGPointMake(bottomCorner.x + edgeSize.width/2, bottomCorner.y + edgeSize.height/2)
        
            let pathToDraw = CGPathCreateMutable()
            CGPathMoveToPoint(pathToDraw, nil, 0-edgeSize.width/2,0-edgeSize.height/2)
            CGPathAddLineToPoint(pathToDraw, nil, 0-edgeSize.width/2, edgeSize.height/2)
            CGPathAddLineToPoint(pathToDraw, nil, edgeSize.width/2, edgeSize.height/2)
            CGPathAddLineToPoint(pathToDraw, nil, edgeSize.width/2, 0-edgeSize.height/2)
            CGPathAddLineToPoint(pathToDraw, nil, 0-edgeSize.width/2, 0-edgeSize.height/2)
        
            yourLine = SKShapeNode()
            yourLine.position = CGPointMake(position.x+edgeCenter.x,position.y+edgeCenter.y)
            yourLine.path = pathToDraw
            yourLine.physicsBody = SKPhysicsBody(rectangleOfSize: edgeSize)
            yourLine.physicsBody.usesPreciseCollisionDetection = true
            yourLine.physicsBody.categoryBitMask = ColliderType.InvaderSheet.toRaw()
            yourLine.physicsBody.collisionBitMask = 0
            yourLine.physicsBody.contactTestBitMask = 0
            yourLine.strokeColor = NSColor.redColor()
            self.addChild(yourLine)
        }
    }
    
    func invaderHit(invader: InvaderSprite){
        invader.hitByMissile()
        self.physicsBody = nil
        setPhysicsBody()
        
        // TODO: Change speed based on number of invaders
    }
    
    func pause(){
        removeActionForKey("move")
    }
    
    var goingRight : Bool
    
    func edgeCollision(){
        if(goingRight){
            removeActionForKey("move")
            runAction(SKAction.repeatActionForever(sequenceLeft), withKey: "move")
            goingRight = false
        } else {
            removeActionForKey("move")
            runAction(SKAction.repeatActionForever(sequenceRight), withKey: "move")
            goingRight = true
        }
        
        runAction(sequenceDown)
    }
    
}