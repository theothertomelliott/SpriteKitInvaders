//
//  ScoreController.swift
//  SKInvaders
//
//  Created by Tom Elliott on 14/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation

protocol ScoreUpdateDelegate {
    
    func scoreUpdated(sender: ScoreController)
    
}

class ScoreController {
    
    init(){
        score = 0
        let prefs : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        prefs.synchronize()
        highScore = prefs.integerForKey("highscore")
    }
    
    private(set) var highScore : Int {
        didSet {
            let prefs : NSUserDefaults = NSUserDefaults.standardUserDefaults()
            prefs.setInteger(highScore, forKey: "highscore")
            prefs.synchronize()
        }
    }
    
    var delegate : ScoreUpdateDelegate!
    private(set) var score : Int {
        didSet {
            if(score > highScore){
                highScore = score
            }
            delegate?.scoreUpdated(self)
        }
    }
    
    /**
     * Add to the current score
     * Will ignore zero and negative values
     */
    func incrementScore(value: Int){
        if(value > 0){
            score += value
        }
    }
    
}