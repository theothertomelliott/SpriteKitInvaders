//
//  MenuScene.swift
//  SKInvaders
//
//  Created by Tom Elliott on 15/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class MenuScene : SKScene {
    
    override func didMoveToView(view: SKView) {
        let gameOverLabel = self.childNodeWithName("GameOverLabel") as SKLabelNode
        gameOverLabel.hidden = true
        
        let playArea = self.childNodeWithName("PlayArea") as SKShapeNode
        playArea.hidden = true
    }
    
    override func keyDown(theEvent: NSEvent){
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill

            self.view!.presentScene(scene)
        }

    }

    
}