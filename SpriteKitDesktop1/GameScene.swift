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
    case LeftEdge = 64
    case RightEdge = 128
    case BottomEdge = 256
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var shipSprite: PlayerSprite!
    var invaders : InvaderSheet!
    var leftBorder : SKNode!
    var rightBorder : SKNode!
    var bottomBorder : SKNode!
    
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
        rightBorder = addBorder(CGPointMake(size.width-20,0), to: CGPointMake(size.width-20,size.height))
        bottomBorder = addBorder(CGPointMake(0,shipSprite.position.y+shipSprite.size.height/2), to: CGPointMake(size.width,shipSprite.position.y+shipSprite.size.height/2), category: ColliderType.BottomEdge.toRaw())
        invadersOnEdge = false
    }
    
    func addBorder(from: CGPoint, to: CGPoint, category: UInt32) -> SKNode {
        
        // Show the border
        drawLine(from, to: to)
        
        var border = SKNode()
        border.physicsBody = SKPhysicsBody(edgeFromPoint: from, toPoint: to)
        border.physicsBody.usesPreciseCollisionDetection = true
        border.physicsBody.categoryBitMask = category
        border.physicsBody.collisionBitMask = 0
        border.physicsBody.contactTestBitMask = ColliderType.Player.toRaw() | ColliderType.InvaderSheet.toRaw()
        self.addChild(border)
        return border
    }

    
    func addBorder(from: CGPoint, to: CGPoint) -> SKNode {
        return addBorder(from, to: to, category: ColliderType.Edge.toRaw())
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
    
    /**
     * Handle collision between an invader missile and the player
     */
    private func missileCollision(invadermissile: InvaderMissile, player: PlayerSprite){
        invadermissile.hitPlayer()
        player.hitByMissile()
    }

    /**
    * Handle collision between a player missile and an invader
    */
    private func missileCollision(playermissile: PlayerMissile, invader: InvaderSprite){
        playermissile.hitInvader()
        invaders.invaderHit(invader)
     }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        
        /** Player missile collisions **/
        if(ColliderType.PlayerMissile.toRaw() == contact.bodyA.categoryBitMask){
            missileCollision(contact.bodyA.node as PlayerMissile, invader: contact.bodyB.node as InvaderSprite)
        }
        
        if(ColliderType.PlayerMissile.toRaw() == contact.bodyB.categoryBitMask){
            missileCollision(contact.bodyB.node as PlayerMissile, invader: contact.bodyA.node as InvaderSprite)
        }
        
        /** Invader missile collisions **/
        if(ColliderType.InvaderMissile.toRaw() == contact.bodyA.categoryBitMask){
            missileCollision(contact.bodyA.node as InvaderMissile, player: contact.bodyB.node as PlayerSprite)
        }
        if(ColliderType.InvaderMissile.toRaw() == contact.bodyB.categoryBitMask){
            missileCollision(contact.bodyB.node as InvaderMissile, player: contact.bodyA.node as PlayerSprite)
        }
        
        /** Edge collisions **/
        if(ColliderType.Player.toRaw() == contact.bodyB.categoryBitMask){
            if(ColliderType.Edge.toRaw() == contact.bodyA.categoryBitMask){
                shipSprite.didBeginContact(contact)
            }
        }
        
        if(ColliderType.InvaderSheet.toRaw() == contact.bodyB.categoryBitMask){
            
            if(ColliderType.Edge.toRaw() == contact.bodyA.categoryBitMask){
                if(!invadersOnEdge){
                    invadersOnEdge = true
                    invaders.edgeCollision()
                }
            }
            
            
            if(ColliderType.BottomEdge.toRaw() == contact.bodyA.categoryBitMask){
                shipSprite.hitByMissile()
                invaders.pause()
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
