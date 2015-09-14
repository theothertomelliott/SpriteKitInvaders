//
//  Common.swift
//  SKInvaders
//
//  Created by Tom Elliott on 21/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation

/**
    Types for physics bodies involved in collisions
    - Player: The player ship
    - PlayerMissile: Missiles fired by the player
    - Invader: Enemy sprites, invaders and mothership
    - InvaderMissile: Missiles fired by enemies
    - PlayArea: Bounds of the playing field
    - Shield: Shield contact areas
*/
enum ColliderType: UInt32 {
    case Player = 1
    case PlayerMissile = 2
    case Invader = 4
    case InvaderMissile = 8
    case PlayArea = 16
    case Shield = 32
}