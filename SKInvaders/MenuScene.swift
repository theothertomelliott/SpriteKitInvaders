//
//  MenuScene.swift
//  SKInvaders
//
//  Created by Tom Elliott on 15/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

// Scene for the pre-game menu
class MenuScene : SKScene {
    
    /**
        Called when this scene is launched. Initializes the scene.
        - parameter view: View containing this scene
    */
    override func didMoveToView(view: SKView) {
        self.childNodeWithName("GameOverLabel")?.hidden = true
        self.childNodeWithName("PlayArea")?.hidden = true
        self.childNodeWithName("LivesCountLabel")?.hidden = true
        
        // Set up the score controller
        let scoreCtl = ScoreController()
        // Show the current score
        let HighScoreLabel : SKLabelNode = self.childNodeWithName("HighScoreLabel") as! SKLabelNode
        HighScoreLabel.text = NSString(format:"%04d",scoreCtl.highScore) as String
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action:"tapped:")
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)];
        self.view?.addGestureRecognizer(tapRecognizer)
        
    }
    
    func tapped(sender: AnyObject?){
        if let scene = GameScene(fileNamed: "GameScene") {
            // Configure the view.
            if let skView = self.view {
                skView.showsFPS = true
                skView.showsNodeCount = true
                
                /* Sprite Kit applies additional optimizations to improve rendering performance */
                skView.ignoresSiblingOrder = true
                
                /* Set the scale mode to scale to fit the window */
                scene.scaleMode = .AspectFit
                
                skView.presentScene(scene)
            }
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
}