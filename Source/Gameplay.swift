//
//  Gameplay.swift
//  PeevedPenguins
//
//  Created by James Sobieski on 6/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit
import Foundation

class Gameplay: CCNode, CCPhysicsCollisionDelegate {
    var grabbed:Bool = false
    
    weak var gamePhysicsNode:CCPhysicsNode!
    weak var levelNode:CCNode!
    weak var retryButton:CCNode!
    weak var contentNode:CCNode!
    weak var pullbackNode:CCNode!
    weak var mouseJointNode: CCNode!
    weak var catapaultArm: CCNode!
    var mouseJoint: CCPhysicsJoint?
    var currentPenguin: Penguin?
    var penguinCatapaultJoint: CCPhysicsJoint?
    let minSpeed = CGFloat(5)
    var actionFollow:CCActionFollow?
    
    
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
        
        println("made it in")
        
        let level = CCBReader.load("Levels/Level1")
        levelNode.addChild(level)
        
        println("made it through")
        
        pullbackNode.physicsBody.collisionMask = []
        mouseJointNode.physicsBody.collisionMask = []
        gamePhysicsNode.collisionDelegate = self
        
        
        
        
        gamePhysicsNode.debugDraw = true
        
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, seal: Seal!, wildcard: CCNode!) {
        //println("something collided with a seal")
        var energy = pair.totalKineticEnergy
        if energy > 5000 {
            gamePhysicsNode.space.addPostStepBlock({ () -> Void in self.sealRemoved(seal) }, key: seal)
            println("Seal removed")
        }
    }
    
    func sealRemoved(seal: Seal) {
        
        let sealExplosion = CCBReader.load("SealExplosion") as! CCParticleSystem
        sealExplosion.autoRemoveOnFinish = true
        sealExplosion.position = seal.position
        seal.parent.addChild(sealExplosion)
        seal.removeFromParent()
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let touchLocation = touch.locationInNode(contentNode)
        if CGRectContainsPoint(catapaultArm.boundingBox(), touchLocation){
            grabbed = true
            
            mouseJointNode.position = touchLocation
            
            mouseJoint = CCPhysicsJoint.connectedSpringJointWithBodyA(mouseJointNode.physicsBody, bodyB: catapaultArm.physicsBody, anchorA: CGPointZero, anchorB: CGPoint(x: 14, y: 150), restLength: 0, stiffness: 500, damping: 50)
            
            currentPenguin = CCBReader.load("Penguin") as! Penguin?
            if let currentPenguin = currentPenguin {
                // initially position it on the scoop. 34,138 is the position in the node space of the catapultArm
                let penguinPosition = catapaultArm.convertToWorldSpace(CGPoint(x: 34, y: 138))
                // transform the world position to the node space to which the penguin will be added (gamePhysicsNode)
                currentPenguin.position = gamePhysicsNode.convertToNodeSpace(penguinPosition)
                // add it to the physics world
                gamePhysicsNode.addChild(currentPenguin)
                // we don't want the penguin to rotate in the scoop
                currentPenguin.physicsBody.allowsRotation = false
                
                
                
//                position = CGPoint.zeroPoint
//                let actionFollow = CCActionFollow(target: currentPenguin, worldBoundary: boundingBox())
//                contentNode.runAction(actionFollow)
                
                
                
                // create a joint to keep the penguin fixed to the scoop until the catapult is released
                penguinCatapaultJoint = CCPhysicsJoint.connectedPivotJointWithBodyA(currentPenguin.physicsBody, bodyB: catapaultArm.physicsBody, anchorA: currentPenguin.anchorPointInPoints)
            }
            
            
        }
    }
    
    func nextAttempt() {
        
        //causes the screen to not always follow the penguin
        
        println("called nextAttempt()")
        currentPenguin = nil
        contentNode.stopAction(actionFollow)
        
        let actionMoveTo = CCActionMoveTo(duration: 1, position: CGPoint.zeroPoint)
        contentNode.runAction(actionMoveTo)

    }
    
    override func update(delta: CCTime) {
        if let currentPenguin = currentPenguin {
            if currentPenguin.launched {
        
                if ccpLength(currentPenguin.physicsBody.velocity) < minSpeed {
                    nextAttempt()
                    return
                }
            
                let xMin = currentPenguin.boundingBox().origin.x
                if (xMin < boundingBox().origin.x) {
                    nextAttempt()
                    return
                }
            
                let xMax = xMin + currentPenguin.boundingBox().size.width
                if xMax > (boundingBox().origin.x + boundingBox().size.width) {
                    nextAttempt()
                    return
                }
            }
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        // when touches end, meaning the user releases their finger, release the catapult
        releaseCatapault()
    }
    
    override func touchCancelled(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        // when touches are cancelled, meaning the user drags their finger off the screen or onto something else, release the catapult
        releaseCatapault()
    }
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        // whenever touches move, update the position of the mouseJointNode to the touch position
        let touchLocation = touch.locationInNode(contentNode)
        mouseJointNode.position = touchLocation
    }
    
    func launchPenguin() {
        /*let penguin = CCBReader.load("Penguin") as! Penguin
        penguin.position = ccpAdd(catapaultArm.position, CGPoint(x: 16, y: 50))
        
        gamePhysicsNode.addChild(penguin)
        
        let launchDirection = CGPoint(x: 1, y: 0)
        let force = ccpMult(launchDirection, 8000)
        penguin.physicsBody.applyForce(force)
        
        position = CGPoint.zeroPoint
        let actionFollow = CCActionFollow(target: penguin, worldBoundary: boundingBox())
        contentNode.runAction(actionFollow)
        */
        
    }
    
    func releaseCatapault() {
        
        println("catapaultRelease() called")
        //if let joint = mouseJoint {
            currentPenguin?.launched = true
            penguinCatapaultJoint?.invalidate()
            penguinCatapaultJoint = nil
            
            actionFollow = CCActionFollow(target: currentPenguin, worldBoundary: boundingBox())
            contentNode.runAction(actionFollow)
            
            //println("catapault reached")
            // releases the joint and lets the catapult snap back
            mouseJoint?.invalidate()
            mouseJoint = nil
        //}
    }
    
    func retry() {
        let gamePlayScene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(gamePlayScene)
    }
}
