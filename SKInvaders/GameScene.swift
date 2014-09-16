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
    case LeftEdge = 64
    case RightEdge = 128
    case BottomEdge = 256
    case TopEdge = 512
}

class GameScene: SKScene, SKPhysicsContactDelegate, ScoreUpdateDelegate, InvaderDelegate {
    
    var shipSprite: PlayerSprite!
    
    var invaderSheet : InvaderSheetController!
    
    var scoreCtl : ScoreController!
    
    var livesSprites : [SKSpriteNode] = []
    var livesCountLabel : SKLabelNode!
    
    var gameOverLabel : SKLabelNode!
    
    var p1ScoreLabel : SKLabelNode!
    var leftBorder : SKNode!
    var rightBorder : SKNode!
    var bottomBorder : SKNode!
    var topBorder : SKNode!
    
    var playArea : SKShapeNode!
    
    var sheetNumber = 0
    
    func scoreUpdated(sender: ScoreController){
        let score = sender.score
        p1ScoreLabel?.text = NSString(format:"%04d", score)
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
    
    override func didMoveToView(view: SKView) {
        
        // Set up the score controller
        scoreCtl = ScoreController()
        scoreCtl.delegate = self
        
        // Configure collisions
        self.physicsWorld.contactDelegate = self;
        
        // Add green line above lives and credit count
        drawLine(CGPointMake(0,CGFloat(playAreaBottom)),to: CGPointMake(size.width, CGFloat(playAreaBottom)), color: SKColor.greenColor())
        
        // Show the current number of lives
        livesCountLabel = SKLabelNode(fontNamed: "Space Invaders")
        livesCountLabel.position = CGPointMake(CGFloat(playAreaBottom/2),CGFloat(playAreaBottom/4))
        self.addChild(livesCountLabel)

        // Obtain the bounds of the game area
        playArea = self.childNodeWithName("PlayArea") as SKShapeNode
        playArea.hidden = true
        
        // Show the current score
        p1ScoreLabel = self.childNodeWithName("p1ScoreLabel") as SKLabelNode
        
        // Create the game over label
        gameOverLabel = self.childNodeWithName("GameOverLabel") as SKLabelNode
        gameOverLabel.hidden = true
        
        // Initial count of lives
        lives = 3
        
        // Create the player
        newPlayer()
        
        let bottomLeft = CGPointMake(playArea.position.x - playArea.frame.width/2, playArea.position.y - playArea.frame.height / 2)
        let bottomRight = CGPointMake(playArea.position.x + playArea.frame.width/2, playArea.position.y - playArea.frame.height / 2)
        let topRight = CGPointMake(playArea.position.x + playArea.frame.width/2, playArea.position.y + playArea.frame.height / 2)
        let topLeft = CGPointMake(playArea.position.x - playArea.frame.width/2, playArea.position.y + playArea.frame.height / 2)
        
        // Set playing area boundaries
        leftBorder = addBorder(bottomLeft, to: topLeft, category: ColliderType.LeftEdge.toRaw())
        rightBorder = addBorder(bottomRight, to: topRight, category: ColliderType.RightEdge.toRaw())
        bottomBorder = addBorder(bottomLeft, to: bottomRight, category: ColliderType.BottomEdge.toRaw())
        topBorder = addBorder(topLeft, to: topRight, category: ColliderType.TopEdge.toRaw())
        
        addInvaderSheet()
    }
    
    func addInvaderSheet(){
        sheetNumber++
        
        invaderSheet = InvaderSheetController(scene: self, scoring: scoreCtl)
        invaderSheet.delegate = self
        let startPos = CGPointMake(playArea.position.x - playArea.frame.width/2, playArea.position.y)
        invaderSheet.addToScene(startPos)
        
        // Calculate the current speed
        invaderSheet.cycleInterval = NSTimeInterval(0.5 - (sheetNumber * 0.01))
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
        shipSprite.position = CGPointMake(playArea.position.x - playArea.frame.width/2,playArea.position.y - playArea.frame.height/2)
        self.addChild(shipSprite)
    }
    
    /**
    * Add a border with a given collision category to the play area
    */
    func addBorder(from: CGPoint, to: CGPoint, category: UInt32) -> SKNode {
        
        // Show the border
        //drawLine(from, to: to, color: SKColor.redColor())
        
        var border = SKNode()
        border.physicsBody = SKPhysicsBody(edgeFromPoint: from, toPoint: to)
        border.physicsBody?.usesPreciseCollisionDetection = true
        border.physicsBody?.categoryBitMask = category
        border.physicsBody?.collisionBitMask = 0
        border.physicsBody?.contactTestBitMask = ColliderType.Player.toRaw() | ColliderType.PlayerMissile.toRaw() | ColliderType.Invader.toRaw()
        self.addChild(border)
        return border
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
        if(lives > 0){
            lives = 0
            shipSprite.hitByMissile()
        }
        invaderSheet.pause()
        
        gameOverLabel.text = ""
        gameOverLabel.hidden = false
        
        let pause = SKAction.waitForDuration(0.25)
        let drawLetter = SKAction.runBlock({
            let current = countElements(self.gameOverLabel.text)
            self.gameOverLabel.text = "GAME OVER".substringToIndex(current+1)
        })
        
        let drawSequence = SKAction.sequence([drawLetter, pause]);
        let drawFullText = SKAction.repeatAction(drawSequence, count: countElements("GAME OVER"))
        
        let loadMenu = SKAction.runBlock({
            if let scene = MenuScene.unarchiveFromFile("GameScene") as? MenuScene {
                /* Set the scale mode to scale to fit the window */
                scene.scaleMode = .AspectFill
                
                self.view!.presentScene(scene)
            }
        })
        
        let fullSeq = SKAction.sequence([drawFullText, SKAction.waitForDuration(2), loadMenu])
        
        self.runAction(fullSeq)
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
        
        
        /** Collision between invader missile and player **/
        if(ColliderType.InvaderMissile.toRaw() == contact.bodyA.categoryBitMask &&
        ColliderType.Player.toRaw() == contact.bodyB.categoryBitMask)
        {
            missileCollision(contact.bodyA.node as InvaderMissile, player: contact.bodyB.node as PlayerSprite)
        }
        if(ColliderType.InvaderMissile.toRaw() == contact.bodyB.categoryBitMask &&
            ColliderType.Player.toRaw() == contact.bodyA.categoryBitMask)
        {
            missileCollision(contact.bodyB.node as InvaderMissile, player: contact.bodyA.node as PlayerSprite)
        }
        
        /** Edge collisions **/
        if(ColliderType.Player.toRaw() == contact.bodyB.categoryBitMask){
            if(ColliderType.LeftEdge.toRaw() == contact.bodyA.categoryBitMask || ColliderType.RightEdge.toRaw() == contact.bodyA.categoryBitMask){
                shipSprite.didBeginContact(contact)
            }
        }
        
    }
    
    func landed(){
        gameOver()
    }
    
    func SheetCompleted() {
        
        // Wait for a couple of seconds, then create a new sheet
        let wait = SKAction.waitForDuration(2)
        let nextSheet = SKAction.runBlock({
            self.addInvaderSheet()
        })
        self.runAction(SKAction.sequence([wait, nextSheet]))
    }
    
    func didEndContact(contact: SKPhysicsContact!) {
        
        if(ColliderType.Invader.toRaw() == contact.bodyA.categoryBitMask
            || ColliderType.Invader.toRaw() == contact.bodyB.categoryBitMask){
                invaderSheet.didEndContact(contact)
        }
        
        if(ColliderType.Player.toRaw() == contact.bodyB.categoryBitMask){
            shipSprite.didEndContact(contact)
        }
    }
    
    override func keyDown(theEvent: NSEvent){
        shipSprite.interpretKeyEvents([theEvent])
    }
    
}
