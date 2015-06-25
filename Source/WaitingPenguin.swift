//
//  WaitingPenguin.swift
//  PeevedPenguins
//
//  Created by James Sobieski on 6/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class WaitingPenguin: CCSprite {
   
    func didLoadFromCCB() {
        let delay = CCRANDOM_0_1() * 2
        
        scheduleOnce("startBlinkAndJump", delay: CCTime(delay))
    }
    
    func startBlinkAndJump(){
        animationManager.runAnimationsForSequenceNamed("BlinkAndJump")
    }
}
