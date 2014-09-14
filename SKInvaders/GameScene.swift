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

class GameScene: SKScene, SKPhysicsContactDelegate, ScoreUpdateDelegate {
    
    var shipSprite: PlayerSprite!
    var invaders : InvaderSheet!
    
    var invaderSheet : InvaderSheetController!
    
    var scoreCtl : ScoreController!
    
    var livesSprites : [SKSpriteNode] = []
    var livesCountLabel : SKLabelNode!
    var scoreLabel : SKLabelNode!
    var leftBorder : SKNode!
    var rightBorder : SKNode!
    var bottomBorder : SKNode!
    var topBorder : SKNode!
    
    func scoreUpdated(sender: ScoreController){
        let score = sender.getScore()
        scoreLabel?.text = "\(score)"
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
        
        // Set up the score controller
        scoreCtl = ScoreController()
        scoreCtl.delegate = self
        
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
        
        // Initial count of lives
        lives = 3
        
        // Create the player
        newPlayer()
        
        // Set playing area boundaries
        leftBorder = addBorder(CGPointMake(20,0), to: CGPointMake(20,size.height), category: ColliderType.LeftEdge.toRaw())
        rightBorder = addBorder(CGPointMake(size.width-20,0), to: CGPointMake(size.width-20,size.height), category: ColliderType.RightEdge.toRaw())
        bottomBorder = addBorder(CGPointMake(0,shipSprite.position.y+shipSprite.size.height/2), to: CGPointMake(size.width,shipSprite.position.y+shipSprite.size.height/2), category: ColliderType.BottomEdge.toRaw())
        topBorder = addBorder(CGPointMake(0,size.height - 50), to: CGPointMake(size.width, size.height-50), category: ColliderType.TopEdge.toRaw())
        invadersOnEdge = false
        
        invaderSheet = InvaderSheetController(scene: self, scoring: scoreCtl)
        invaderSheet.addToScene(CGPointMake(size.width/2-60*7,(size.height/2)-50))
        invaderSheet.start()
        
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
        border.physicsBody?.contactTestBitMask = ColliderType.Player.toRaw() | ColliderType.InvaderSheet.toRaw() | ColliderType.PlayerMissile.toRaw() | ColliderType.Invader.toRaw()
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
    
    func didBeginContact(contact: SKPhysicsContact!) {
        
        // Pass invader collisions to the invader sheet
        if(ColliderType.Invader.toRaw() == contact.bodyA.categoryBitMask
            || ColliderType.Invader.toRaw() == contact.bodyB.categoryBitMask){
                invaderSheet.didBeginContact(contact)
        }
        
        /** Get rid of missiles that go off the screen **/
        if(ColliderType.PlayerMissile.toRaw() == contact.bodyA.categoryBitMask
            && ColliderType.TopEdge.toRaw() == contact.bodyB.categoryBitMask){
                let missile : PlayerMissile = contact.bodyA.node as PlayerMissile
                missile.hitInvader()
        }
        if(ColliderType.PlayerMissile.toRaw() == contact.bodyB.categoryBitMask
            && ColliderType.TopEdge.toRaw() == contact.bodyA.categoryBitMask){
                let missile : PlayerMissile = contact.bodyB.node as PlayerMissile
                missile.hitInvader()
        }
        
        /** Edge collisions **/
        if(ColliderType.Player.toRaw() == contact.bodyB.categoryBitMask){
            if(ColliderType.Edge.toRaw() == contact.bodyA.categoryBitMask){
                shipSprite.didBeginContact(contact)
            }
        }
        
        // TODO: Handle this collision for the new invader model
        if(ColliderType.InvaderSheet.toRaw() == contact.bodyB.categoryBitMask){
            
            if(ColliderType.BottomEdge.toRaw() == contact.bodyA.categoryBitMask){
                shipSprite.hitByMissile()
                gameOver()
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact!) {
        
        if(ColliderType.Invader.toRaw() == contact.bodyA.categoryBitMask
            || ColliderType.Invader.toRaw() == contact.bodyB.categoryBitMask){
                invaderSheet.didEndContact(contact)
        }
        
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
