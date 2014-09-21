//
//  InGameController.swift
//  SKInvaders
//
//  Created by Tom Elliott on 20/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation
import SpriteKit

class GameSubController : NSObject {

    private(set) var _scoring : ScoreController
    private(set) var _scene : SKScene
    private(set) var _playArea : SKNode
    
    init(scene: SKScene, scoring: ScoreController, playArea: SKNode){
        _scene = scene
        _scoring = scoring
        _playArea = playArea
    }
    
    func addToScene(){
        
    }
    
    func start(){
        
    }
    
    func pause(){
        
    }
    
    
}