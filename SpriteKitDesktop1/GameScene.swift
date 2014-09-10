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
    case TopEdge = 512
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var shipSprite: PlayerSprite!
    var invaders : InvaderSheet!
    var livesSprites : [SKSpriteNode] = []
    var livesCountLabel : SKLabelNode!
    var scoreLabel : SKLabelNode!
    var leftBorder : SKNode!
    var rightBorder : SKNode!
    var bottomBorder : SKNode!
    var topBorder : SKNode!
    
    var score : Int = 0 {
        didSet {
            if(scoreLabel != nil){
                scoreLabel.text = "\(score)"
            }
        }
    }
    
    // Number of lives in "reserve", not counting the life in play
    var lives : Int = 3 {
        didSet {
            // Render new lives count
            if(livesSprites.count == 0){
                let texture = SKTexture(imageNamed: "Spaceship")
                var xPos : CGFloat = CGFloat(playAreaBottom/2+40)
                for(var i = 0; i < (lives-1); i++){
                    let life = SKSpriteNode(texture: texture, color: NSColor.clearColor(), size: texture.size())
                    life.setScale(0.5)
                    life.position = CGPointMake(xPos, CGFloat(playAreaBottom/2))
                    livesSprites.append(life)
                    self.addChild(life)
                    xPos += life.size.width + 10
                }
            }
            
            var i = 0
            for life : SKSpriteNode in livesSprites {
                life.removeFromParent()
                if(i < (lives-1)){
                    addChild(life)
                }
            }
            livesCountLabel.text = "\(lives+1)"
        }
    }
    
    let playAreaBottom = 50
    
    // Is the invader sheet currently collided with an edge?
    var invadersOnEdge : Bool!
    
    override func didMoveToView(view: SKView) {
        
        // Configure gravity
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self;
        
        // Set background
        self.backgroundColor = SKColor.blackColor();
        
        // Add green line above lives and credit count
        drawLine(CGPointMake(0,CGFloat(playAreaBottom)),to: CGPointMake(size.width, CGFloat(playAreaBottom)), color: SKColor.greenColor())

        // Show the current number of lives
        livesCountLabel = SKLabelNode(fontNamed: "Space Invaders")
        livesCountLabel.position = CGPointMake(CGFloat(playAreaBottom/2),CGFloat(playAreaBottom/4))
        self.addChild(livesCountLabel)
        
        // Show the current score
        let scoreHeadingLabel = SKLabelNode(fontNamed: "Space Invaders")
        scoreHeadingLabel.text = "Score <1>"
        scoreHeadingLabel.position = CGPointMake(150, self.size.height - 30)
        self.addChild(scoreHeadingLabel)
        scoreLabel = SKLabelNode(fontNamed: "Space Invaders")
        scoreLabel.position = CGPointMake(150,self.size.height - 30 - 50)
        self.addChild(scoreLabel)
        
        // Initial score
        score = 0
        
        // Initial count of lives
        lives = 3

        // Create the player
        newPlayer()

        // Initialize invader sheet
        invaders = InvaderSheet()
        invaders.position = CGPointMake(size.width/2,(size.height/2)+150)
        self.addChild(invaders)

        // Set playing area boundaries
        leftBorder = addBorder(CGPointMake(20,0), to: CGPointMake(20,size.height))
        rightBorder = addBorder(CGPointMake(size.width-20,0), to: CGPointMake(size.width-20,size.height))
        bottomBorder = addBorder(CGPointMake(0,shipSprite.position.y+shipSprite.size.height/2), to: CGPointMake(size.width,shipSprite.position.y+shipSprite.size.height/2), category: ColliderType.BottomEdge.toRaw())
        topBorder = addBorder(CGPointMake(0,size.height - 50), to: CGPointMake(size.width, size.height-50), category: ColliderType.TopEdge.toRaw())
        invadersOnEdge = false
        
    }
    
    /**
    * Bring a life out of reserve and into play
    */
    func newPlayer(){
        // Reduce lives count
        lives = lives - 1
        
        // Put ship in play
        shipSprite = PlayerSprite()
        shipSprite.position = CGPointMake(50,CGFloat(playAreaBottom + 50))
        self.addChild(shipSprite)
    }
    
    /**
     * Add a border with a given collision category to the play area
     */
    func addBorder(from: CGPoint, to: CGPoint, category: UInt32) -> SKNode {
        
        // Show the border
        drawLine(from, to: to, color: SKColor.redColor())
        
        var border = SKNode()
        border.physicsBody = SKPhysicsBody(edgeFromPoint: from, toPoint: to)
        border.physicsBody?.usesPreciseCollisionDetection = true
        border.physicsBody?.categoryBitMask = category
        border.physicsBody?.collisionBitMask = 0
        border.physicsBody?.contactTestBitMask = ColliderType.Player.toRaw() | ColliderType.InvaderSheet.toRaw() | ColliderType.PlayerMissile.toRaw()
        self.addChild(border)
        return border
    }

    /**
     * Add a generic edge border to the play area
     */
    func addBorder(from: CGPoint, to: CGPoint) -> SKNode {
        return addBorder(from, to: to, category: ColliderType.Edge.toRaw())
    }
    
    func drawLine(from: CGPoint, to: CGPoint, color: SKColor){
        let pathToDraw = CGPathCreateMutable()
        CGPathMoveToPoint(pathToDraw, nil, from.x,from.y)
        CGPathAddLineToPoint(pathToDraw, nil, to.x, to.y)
        let yourLine : SKShapeNode = SKShapeNode()
        yourLine.path = pathToDraw
        yourLine.strokeColor = color
        self.addChild(yourLine)
    }

    /**
     * End the game, player loses
     */
    private func gameOver(){
        livesCountLabel.text = "\(lives)"
        // TODO: Go to game over screen
        invaders.pause()
    }
    
    /**
     * Handle collision between an invader missile and the player
     */
    private func missileCollision(invadermissile: InvaderMissile, player: PlayerSprite){
        invadermissile.hitPlayer()
        player.hitByMissile()
        if(lives > 0){
            // Create new ship
            let wait5 = SKAction.waitForDuration(1)
            let createNewPlayer = SKAction.runBlock({
                self.newPlayer()
            })
            self.runAction(SKAction.sequence([wait5, createNewPlayer]))
        } else {
            lives = 0
            gameOver()
        }
    }

    /**
    * Handle collision between a player missile and an invader
    */
    private func missileCollision(playermissile: PlayerMissile, invader: InvaderSprite){
        // Destroy the invader and missile
        playermissile.hitInvader()
        invaders.invaderHit(invader)
        // Add the score for destroying this invader
        score += invader.score()
     }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        
        /** Player missile collisions **/
        if(ColliderType.PlayerMissile.toRaw() == contact.bodyA.categoryBitMask){
            if(ColliderType.Invader.toRaw() == contact.bodyB.categoryBitMask){
                missileCollision(contact.bodyA.node as PlayerMissile, invader: contact.bodyB.node as InvaderSprite)
            } else if(ColliderType.TopEdge.toRaw() == contact.bodyB.categoryBitMask){
                let playerMissile : PlayerMissile = contact.bodyA.node as PlayerMissile
                playerMissile.hitInvader()
            }
        }
        
        if(ColliderType.PlayerMissile.toRaw() == contact.bodyB.categoryBitMask){
            if(ColliderType.Invader.toRaw() == contact.bodyA.categoryBitMask){
                missileCollision(contact.bodyB.node as PlayerMissile, invader: contact.bodyA.node as InvaderSprite)
            } else if(ColliderType.TopEdge.toRaw() == contact.bodyA.categoryBitMask){
                let playerMissile : PlayerMissile = contact.bodyB.node as PlayerMissile
                playerMissile.hitInvader()
            }
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
                gameOver()
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact!) {
        
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
    
}
