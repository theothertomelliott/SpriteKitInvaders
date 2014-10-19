//
//  GameScene.swift
//  SpriteKitDesktop1
//
//  Created by Tom Elliott on 20/08/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import SpriteKit

// The main scene for the game itself
class GameScene: SKScene, SKPhysicsContactDelegate, ScoreUpdateDelegate, InvaderDelegate {
    
    // Bounds of the game (doesn't include score labels and lives remaining)
    private var playArea : SKShapeNode!

    // Elements in play
    private var shipSprite: PlayerSprite!
    private var invaderSheet : InvaderSheetController!
    private var shields : ShieldController!
    
    // Labels
    private var gameOverLabel : SKLabelNode!
    private var p1ScoreLabel : SKLabelNode!
    private var HighScoreLabel : SKLabelNode!
    private var livesCountLabel : SKLabelNode!

    // Sprites indicating remaining lives
    private var livesSprites : [SKSpriteNode] = []

    // Handles scoring
    private var scoreCtl : ScoreController!

    private var sheetNumber = 0
    
    /**
        Called when this scene is launched. Initializes the scene.
        :param: view View containing this scene
    */
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
        
        // Show the current number of lives
        livesCountLabel = self.childNodeWithName("LivesCountLabel") as SKLabelNode
        
        // Obtain the bounds of the game area
        playArea = self.childNodeWithName("PlayArea") as SKShapeNode
        playArea.hidden = true
        
        // Create the game over label
        gameOverLabel = self.childNodeWithName("GameOverLabel") as SKLabelNode
        gameOverLabel.hidden = true
        
        // Create the player
        newPlayer()
        
        // Set playing area boundaries
        
        playArea.physicsBody = SKPhysicsBody(rectangleOfSize: playArea.frame.size)
        playArea.physicsBody?.categoryBitMask = ColliderType.PlayArea.rawValue
        playArea.physicsBody?.collisionBitMask = 0
        playArea.physicsBody?.contactTestBitMask = 0
        
        addInvaderSheet()
        addShields()
        
        startGame()
    }
    
    // Number of lives in "reserve", not counting the life in play
    private var lives : Int = 3 {
        didSet {
            // Render new lives count
            if(livesSprites.count == 0){
                let texture = SKTexture(imageNamed: "Spaceship")
                var xPos : CGFloat = CGFloat(livesCountLabel.position.x + 50)
                for(var i = 0; i < (lives-1); i++){
                    let life = SKSpriteNode(texture: texture, color: NSColor.clearColor(), size: texture.size())
                    life.setScale(0.6)
                    life.position = CGPointMake(xPos, livesCountLabel.position.y + life.size.height/2)
                    livesSprites.append(life)
                    self.addChild(life)
                    xPos += life.size.width + 10
                }
            }
            
            var i = 0
            for life : SKSpriteNode in livesSprites {
                if(i > (lives)){
                    life.removeFromParent()
                }
                i++
            }
            livesCountLabel.text = "\(lives)"
        }
    }
    
    /**
        Add shields to the scene
    */
    private func addShields(){
        shields = ShieldController(scene: self, scoring: scoreCtl, playArea: playArea)
        shields.addToScene()
    }
    
    /**
        Start a new game
    */
    private func startGame(){
        // Initial count of lives
        lives = 3
        invaderSheet.start()
    }
    
    /**
        Add a new sheet of invaders to the game
    */
    private func addInvaderSheet(){
        sheetNumber++
        
        invaderSheet = InvaderSheetController(scene: self, scoring: scoreCtl, playArea: playArea, level: UInt(sheetNumber))
        invaderSheet.delegate = self
        invaderSheet.addToScene()
    }
    
    /**
        Bring a life out of reserve and into play
    */
    private func newPlayer(){
        // Reduce lives count
        lives = lives - 1
        
        // Put ship in play
        shipSprite = PlayerSprite()
        shipSprite.playArea = playArea
        shipSprite.position = CGPointMake(playArea.position.x - playArea.frame.width/2,playArea.position.y - playArea.frame.height/2 + shipSprite.frame.height/2)
        self.addChild(shipSprite)
    }
    
    /**
        End the game, player loses
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
    
    override func keyDown(theEvent: NSEvent){
        shipSprite.interpretKeyEvents([theEvent])
    }
    
    // MARK: Collision helpers
    
    /**
        Handle collision between an invader missile and the player
        :param: invaderMissile The invader missile involved in the collision
        :param: player The player sprite involved in the collision
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
        Determine if a collision involves a physics body of a particular type
        :param: contact The physics contact representing this collision
        :param: type The collider type to test for
        :return: true if either of the bodies in the contact is of the specified type
    */
    private func isCollisionInvolving(contact: SKPhysicsContact!, type : ColliderType) -> Bool {
        
        return (type.rawValue == contact.bodyA.categoryBitMask ||
            type.rawValue == contact.bodyB.categoryBitMask )
        
    }
    
    /**
        Get the physics body of a particular type from a contact.
        Note that this will only return bodyA if both bodies are of the same type.
        :param: contact The physics contact to be checked
        :param: type The type of the body we want to retrieve
        :return: The first body of the specified type in this contact
    */
    private func getColliderOfType(contact: SKPhysicsContact!, type : ColliderType) -> SKPhysicsBody? {
        if (type.rawValue == contact.bodyA.categoryBitMask){
            return contact.bodyA
        }
        if (type.rawValue == contact.bodyB.categoryBitMask){
            return contact.bodyB
        }
        return nil
    }
    
    // MARK: SKPhysicsContactDelegate
    
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
        }
    }
    
    // MARK: ScoreUpdateDelegate
    
    func scoreUpdated(sender: ScoreController){
        p1ScoreLabel?.text = NSString(format:"%04d", sender.score)
        HighScoreLabel?.text = NSString(format:"%04d", sender.highScore)
    }
    
    // MARK: InvaderDelegate
    
    func landed(){
        gameOver()
    }
    
    func SheetCompleted() {
        
        // Wait for a couple of seconds, then create a new sheet
        let wait = SKAction.waitForDuration(2)
        let nextSheet = SKAction.runBlock({
            self.addInvaderSheet()
            self.invaderSheet.start();
        })
        self.runAction(SKAction.sequence([wait, nextSheet]))
    }

    
    
}
