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
    }
    
    var delegate : ScoreUpdateDelegate!
    private var score : Int {
        didSet {
            delegate?.scoreUpdated(self)
        }
    }
    
    // TODO: Implement this using the var structure
    func getScore() -> Int {
        return score
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