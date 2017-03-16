//
//  GamePlay.swift
//  BeerStrip
//
//  Created by NKT on 3/15/17.
//  Copyright © 2017 NKT. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GamePlay: SKScene,SKPhysicsContactDelegate {
    
    var cateBeer: SKSpriteNode?
    var beer: SKSpriteNode?
    var lose: SKSpriteNode?
    var life: SKSpriteNode?
    var imggirl: SKSpriteNode?
    
    let x = arc4random_uniform(2) + 1
    var velocityY: Int = -200
    var beerRate: TimeInterval = 1
    var timeSinceBeer: TimeInterval = 0
    var lastTime: TimeInterval = 0
    let noCategory: UInt32 = 0
    
    let beerCategory: UInt32 = 0b1 // 1
    let cateBeerCategory: UInt32 = 0b1 << 1 // 2
    let loseCategory: UInt32 = 0b1 << 2 // 4
    
    var score: Int = 0
    var scoreToLose: Int = 3
    var scoreLabel: SKLabelNode?
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        cateBeer = (self.childNode(withName: "catebeer") as? SKSpriteNode)!
        scoreLabel = self.childNode(withName: "score") as? SKLabelNode
        lose = self.childNode(withName: "lose") as? SKSpriteNode
        life = self.childNode(withName: "life") as? SKSpriteNode
        imggirl = self.childNode(withName: "imggirl") as? SKSpriteNode
        imggirl?.texture = SKTexture(imageNamed: "girl\(x)-1")
        
        cateBeer?.physicsBody?.categoryBitMask = cateBeerCategory
        cateBeer?.physicsBody?.collisionBitMask = noCategory
        cateBeer?.physicsBody?.contactTestBitMask = beerCategory
        
        lose?.physicsBody?.categoryBitMask = loseCategory
        lose?.physicsBody?.collisionBitMask = noCategory
        lose?.physicsBody?.contactTestBitMask = beerCategory
        
        do {
            let sounds: [String] = ["level","hit","hellno","ohyeah"]
            for sound in sounds {
                let path: String = Bundle.main.path(forResource: sound, ofType: "mp3")!
                let url: URL = URL(fileURLWithPath: path)
                let player: AVAudioPlayer = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
            }
        }
        catch {
            
        }
        
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
            return
        }

        let cA: UInt32 = contact.bodyA.categoryBitMask
        let cB: UInt32 = contact.bodyB.categoryBitMask
        if cA == beerCategory {
            if cB == cateBeerCategory{
                contact.bodyA.node?.removeFromParent()
                score += 1
                scoreLabel?.text = "Score: \(score)"
                self.run(SKAction.playSoundFileNamed("hit", waitForCompletion: false))
            } else if cB == loseCategory {
                self.run(SKAction.playSoundFileNamed("hellno", waitForCompletion: false))
                scoreToLose -= 1
                contact.bodyA.node?.removeFromParent()
            }
            
        } else if cB == beerCategory {
            if cA == cateBeerCategory{
                contact.bodyB.node?.removeFromParent()
                score += 1
                scoreLabel?.text = "Score: \(score)"
                self.run(SKAction.playSoundFileNamed("hit", waitForCompletion: false))
            } else if cA == loseCategory {
                self.run(SKAction.playSoundFileNamed("hellno", waitForCompletion: false))
                scoreToLose -= 1
                contact.bodyB.node?.removeFromParent()
            }
        }
        
        
        
        if score == 10 {
            self.run(SKAction.playSoundFileNamed("ohyeah", waitForCompletion: false))
            imggirl?.texture = SKTexture(imageNamed: "girl\(x)-2")
            velocityY = -250
            beerRate = 0.8
        } else if score == 20 {
            self.run(SKAction.playSoundFileNamed("ohyeah", waitForCompletion: false))
            imggirl?.texture = SKTexture(imageNamed: "girl\(x)-3")
            velocityY = -300
            beerRate = 0.6
        } else if score == 40 {
            self.run(SKAction.playSoundFileNamed("ohyeah", waitForCompletion: false))
            imggirl?.texture = SKTexture(imageNamed: "girl\(x)-4")
            velocityY = -400
            beerRate = 0.5
        } else if score == 80 {
            self.run(SKAction.playSoundFileNamed("ohyeah", waitForCompletion: false))
            imggirl?.texture = SKTexture(imageNamed: "girl\(x)-5")
            velocityY = -600
            beerRate = 0.5
        }
        
        
        
        
        if scoreToLose == 2 {
            life?.texture = SKTexture(imageNamed: "life2")
            life?.size.height = 100
        } else if scoreToLose == 1 {
            life?.texture = SKTexture(imageNamed: "life1")
            life?.size.height = 44
        } else if scoreToLose == 0 {
            restartGame()
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if ( pos.x >= -255 && pos.x <= 155 ) {
        cateBeer?.position.x = pos.x
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    override func update(_ currentTime: TimeInterval) {
        checkBeer(currentTime - lastTime)
        lastTime = currentTime
        
    
    }
    func checkBeer(_ frameRate: TimeInterval) {
        timeSinceBeer += frameRate
        if timeSinceBeer < beerRate {
            return
        }
        spawnBeer()
        timeSinceBeer = 0
    }
    func unsafeRandomIntFrom(start: Int, to end: Int) -> Int {
        return Int(arc4random_uniform(UInt32(end - start + 1))) + start
    }
    func spawnBeer() {
        let x = unsafeRandomIntFrom(start: -150, to: 70)
        let scene: SKScene = SKScene(fileNamed: "Beer")!
        let beer: SKSpriteNode  = scene.childNode(withName: "beer") as! SKSpriteNode
        beer.position = CGPoint(x: Int(x), y: 300)
        beer.physicsBody?.velocity = CGVector(dx: 0, dy: velocityY)
        beer.physicsBody?.categoryBitMask = beerCategory
        beer.physicsBody?.collisionBitMask = noCategory
        beer.physicsBody?.contactTestBitMask = cateBeerCategory | loseCategory
        beer.move(toParent: self)
        
        let waitAction = SKAction.wait(forDuration: 5.0)
        let removeAction = SKAction.removeFromParent()
        beer.run(SKAction.sequence([waitAction,removeAction]))
        
        
    }
    
    func restartGame() {
        if let scene = MainMenu(fileNamed: "MainMenuScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .fill
            
            // Present the scene
            view?.presentScene(scene)
        }
    }
    
}
