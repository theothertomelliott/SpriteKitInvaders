//
//  GameScene.swift
//  SpriteKitDesktop1
//
//  Created by Tom Elliott on 20/08/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import SpriteKit

enum ColliderType: UInt32 {
    case Player = 1
    case PlayerMissile = 2
    case Invader = 4
    case InvaderMissile = 8
    case Edge = 16
    case InvaderSheet = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var shipSprite: PlayerSprite!
    var invaders : InvaderSheet!
    var leftBorder : SKNode!
    var rightBorder : SKNode!
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor.blackColor();
        shipSprite = PlayerSprite()
        shipSprite.position = CGPointMake(50, 50)
        self.addChild(shipSprite)
        
        invaders = InvaderSheet()
        invaders.position = CGPointMake(size.width/2,(size.height/2)+150)
        self.addChild(invaders)
        
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self;
        
        leftBorder = addBorder(CGPointMake(20,0), to: CGPointMake(20,size.height))
        //drawLine(CGPointMake(20,0), to: CGPointMake(20,size.height))
        
        rightBorder = addBorder(CGPointMake(size.width-20,0), to: CGPointMake(size.width-20,size.height))
        //drawLine(CGPointMake(size.width-20,0), to: CGPointMake(size.width-20,size.height))
        
        invadersOnEdge = false
    }
    
    func addBorder(from: CGPoint, to: CGPoint) -> SKNode {
        var border = SKNode()
        border.physicsBody = SKPhysicsBody(edgeFromPoint: from, toPoint: to)
        border.physicsBody.usesPreciseCollisionDetection = true
        border.physicsBody.categoryBitMask = ColliderType.Edge.toRaw()
        border.physicsBody.collisionBitMask = 0
        border.physicsBody.contactTestBitMask = ColliderType.Player.toRaw() | ColliderType.InvaderSheet.toRaw()
        self.addChild(border)
        return border
    }
    
    func drawLine(from: CGPoint, to: CGPoint){
        let pathToDraw = CGPathCreateMutable()
        CGPathMoveToPoint(pathToDraw, nil, from.x,from.y)
        CGPathAddLineToPoint(pathToDraw, nil, to.x, to.y)
        let yourLine : SKShapeNode = SKShapeNode()
        yourLine.path = pathToDraw
        yourLine.strokeColor = NSColor.redColor()
        self.addChild(yourLine)
    }
    
    func drawCircle(at: CGPoint, radius: CGFloat){
        let pathToDraw = CGPathCreateMutable()
        
        CGPathMoveToPoint(pathToDraw, nil, at.x - radius,at.y - radius)
        CGPathAddLineToPoint(pathToDraw, nil, at.x + radius, at.y - radius)
        CGPathAddLineToPoint(pathToDraw, nil, at.x + radius, at.y + radius)
        CGPathAddLineToPoint(pathToDraw, nil, at.x - radius, at.y + radius)
        CGPathAddLineToPoint(pathToDraw, nil, at.x - radius, at.y - radius)
        
        let yourLine : SKShapeNode = SKShapeNode()
        yourLine.path = pathToDraw
        yourLine.strokeColor = NSColor.redColor()
        self.addChild(yourLine)

    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        //NSLog("Collision between type %d and %d", contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask)
        
        if(ColliderType.PlayerMissile.toRaw() == contact.bodyA.categoryBitMask){
            //NSLog("Player missile collision")
            let missile : PlayerMissile = contact.bodyA.node as PlayerMissile
            let invader : InvaderSprite = contact.bodyB.node as InvaderSprite
            missile.hitInvader()
            invaders.invaderHit(invader)
        }
        
        if(ColliderType.PlayerMissile.toRaw() == contact.bodyB.categoryBitMask){
            //NSLog("Player missile collision")
            let missile : PlayerMissile = contact.bodyB.node as PlayerMissile
            let invader : InvaderSprite = contact.bodyA.node as InvaderSprite
            missile.hitInvader()
            invaders.invaderHit(invader)
        }
        
        if(ColliderType.Player.toRaw() == contact.bodyB.categoryBitMask){
            shipSprite.didBeginContact(contact)
        }
        
        if(ColliderType.Edge.toRaw() == contact.bodyA.categoryBitMask){
            if(ColliderType.InvaderSheet.toRaw() == contact.bodyB.categoryBitMask){
                if(!invadersOnEdge){
                    invadersOnEdge = true
                    invaders.edgeCollision()
                }
            }
        }
    }
    
    var invadersOnEdge : Bool!
    
    func didEndContact(contact: SKPhysicsContact!) {
        //NSLog("End of collision between type %d and %d", contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask)
        
        if(ColliderType.Player.toRaw() == contact.bodyB.categoryBitMask){
            shipSprite.didEndContact(contact)
        }
        
        if(ColliderType.Edge.toRaw() == contact.bodyA.categoryBitMask){
           invadersOnEdge = false
        }
    }
    
    override func keyDown(theEvent: NSEvent){
        shipSprite.interpretKeyEvents([theEvent])
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
