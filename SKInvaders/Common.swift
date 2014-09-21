//
//  Common.swift
//  SKInvaders
//
//  Created by Tom Elliott on 21/09/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

import Foundation

enum ColliderType: UInt32 {
    case Player = 1
    case PlayerMissile = 2
    case Invader = 4
    case InvaderMissile = 8
    case PlayArea = 16
    case BottomEdge = 32
    case Shield = 64
}