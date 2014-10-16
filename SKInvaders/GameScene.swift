//
//  GameScene.swift
//  SpriteKitDesktop1
//
//  Created by Tom Elliott on 20/08/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate, ScoreUpdateDelegate, InvaderDelegate {
    
    var shipSprite: PlayerSprite!
    
    var invaderSheet : InvaderSheetController!
    
    var shields : ShieldController!
    
    var scoreCtl : ScoreController!
    
    var livesSprites : [SKSpriteNode] = []
    var livesCountLabel : SKLabelNode!
    
    var gameOverLabel : SKLabelNode!
    
    var p1ScoreLabel : SKLabelNode!
    var HighScoreLabel : SKLabelNode!
    
    var leftBorder : SKNode!
    var rightBorder : SKNode!
    var bottomBorder : SKNode!
    var topBorder : SKNode!
    
    var playArea : SKShapeNode!
    
    var sheetNumber = 0
    
    func scoreUpdated(sender: ScoreController){
        p1ScoreLabel?.text = NSString(format:"%04d", sender.score)
        HighScoreLabel?.text = NSString(format:"%04d", sender.highScore)
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
        
        // Hide instructions
        self.childNodeWithName("PushLabel")?.hidden = true
        self.childNodeWithName("ButtonInstructionLabel")?.hidden = true
        
        // Set up the score controller
        scoreCtl = ScoreController()
        scoreCtl.delegate = self
        // Show the current score
        p1ScoreLabel = self.childNodeWithName("p1ScoreLabel") as SKLabelNode
        HighScoreLabel = self.childNodeWithName("HighScoreLabel") as SKLabelNode
        scoreUpdated(scoreCtl);
        
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
        
        // Create the game over label
        gameOverLabel = self.childNodeWithName("GameOverLabel") as SKLabelNode
        gameOverLabel.hidden = true
        
        // Initial count of lives
        lives = 3
        
        // Create the player
        newPlayer()
        
        let bottomLeft = CGPointMake(playArea.position.x - playArea.frame.width/2, playArea.position.y - playArea.frame.height / 2)
        let bottomRight = CGPointMake(playArea.position.x + playArea.frame.width/2, playArea.position.y - playArea.frame.height / 2)
        
        // Set playing area boundaries
        
        playArea.physicsBody = SKPhysicsBody(rectangleOfSize: playArea.frame.size)
        playArea.physicsBody?.categoryBitMask = ColliderType.PlayArea.rawValue
        playArea.physicsBody?.collisionBitMask = 0
        playArea.physicsBody?.contactTestBitMask = 0
        
        // TODO: Create a proper edge border from the play area object
        bottomBorder = addBorder(bottomLeft, to: bottomRight, category: ColliderType.BottomEdge.rawValue)
        
        addInvaderSheet()
        addShields()
        
        startGame()
    }
    
    func addShields(){
        shields = ShieldController(scene: self, scoring: scoreCtl, playArea: playArea)
        shields.addToScene()
    }
    
    func startGame(){
        invaderSheet.start()
    }
    
    func addInvaderSheet(){
        sheetNumber++
        
        invaderSheet = InvaderSheetController(scene: self, scoring: scoreCtl, playArea: playArea, level: UInt(sheetNumber))
        invaderSheet.delegate = self
        invaderSheet.addToScene()
    }
    
    /**
    * Bring a life out of reserve and into play
    */
    func newPlayer(){
        // Reduce lives count
        lives = lives - 1
        
        // Put ship in play
        shipSprite = PlayerSprite()
        shipSprite.playArea = playArea
        shipSprite.position = CGPointMake(playArea.position.x - playArea.frame.width/2,playArea.position.y - playArea.frame.height/2 + shipSprite.frame.height/2)
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
        border.physicsBody?.contactTestBitMask = ColliderType.Player.rawValue | ColliderType.PlayerMissile.rawValue | ColliderType.Invader.rawValue
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
    
    func isCollisionInvolving(contact: SKPhysicsContact!, type : ColliderType) -> Bool {
        
        return (type.rawValue == contact.bodyA.categoryBitMask ||
            type.rawValue == contact.bodyB.categoryBitMask )
        
    }
    
    func getColliderOfType(contact: SKPhysicsContact!, type : ColliderType) -> SKPhysicsBody? {
        if (type.rawValue == contact.bodyA.categoryBitMask){
            return contact.bodyA
        }
        if (type.rawValue == contact.bodyB.categoryBitMask){
            return contact.bodyB
        }
        return nil
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        
        /*** Shield collisions ***/
        if(isCollisionInvolving(contact, type: ColliderType.Shield)){
            shields.didBeginContact(contact)
        }
        
        // Pass invader collisions to the invader sheet
        if(isCollisionInvolving(contact, type: ColliderType.Invader)){
            invaderSheet.didBeginContact(contact)
        }
        
        /*** Handle missile to missile collisions ***/
        if(ColliderType.InvaderMissile.rawValue == contact.bodyA.categoryBitMask &&
            ColliderType.PlayerMissile.rawValue == contact.bodyB.categoryBitMask){
                let im = contact.bodyA.node as InvaderMissile
                let pm = contact.bodyB.node as PlayerMissile
                im.hitPlayer()
                pm.hitInvader()
        }

        if(ColliderType.InvaderMissile.rawValue == contact.bodyB.categoryBitMask &&
            ColliderType.PlayerMissile.rawValue == contact.bodyA.categoryBitMask){
                let im = contact.bodyB.node as InvaderMissile
                let pm = contact.bodyA.node as PlayerMissile
                im.hitPlayer()
                pm.hitInvader()
        }
        
        /** Collision between invader missile and player **/
        if(ColliderType.InvaderMissile.rawValue == contact.bodyA.categoryBitMask &&
        ColliderType.Player.rawValue == contact.bodyB.categoryBitMask)
        {
            missileCollision(contact.bodyA.node as InvaderMissile, player: contact.bodyB.node as PlayerSprite)
        }
        if(ColliderType.InvaderMissile.rawValue == contact.bodyB.categoryBitMask &&
            ColliderType.Player.rawValue == contact.bodyA.categoryBitMask)
        {
            missileCollision(contact.bodyB.node as InvaderMissile, player: contact.bodyA.node as PlayerSprite)
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
        
        /*** Shield collisions ***/
        if(isCollisionInvolving(contact, type: ColliderType.Shield)){
            shields.didEndContact(contact)
        }
        
        // Pass invader collisions to the invader sheet
        if(isCollisionInvolving(contact, type: ColliderType.Invader)){
            invaderSheet.didEndContact(contact)
        }
        
        if(ColliderType.Player.rawValue == contact.bodyB.categoryBitMask){
            shipSprite.didEndContact(contact)
        }
        
        // Someone went out of bounds!
        if(isCollisionInvolving(contact, type: ColliderType.PlayArea)){
            if let collider = getColliderOfType(contact, type: ColliderType.PlayerMissile) {
                (collider.node as PlayerMissile).hitInvader()
            }
            if let collider = getColliderOfType(contact, type: ColliderType.InvaderMissile){
                (collider.node as InvaderMissile).hitPlayer()
            }
            if let collider = getColliderOfType(contact, type: ColliderType.Invader){
                (collider.node as InvaderSprite).outOfBounds()
            }
        }
    }
    
    override func keyDown(theEvent: NSEvent){
        shipSprite.interpretKeyEvents([theEvent])
    }
    
}
