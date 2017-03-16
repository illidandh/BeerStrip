//
//  MainMenu.swift
//  BeerStrip
//
//  Created by NKT on 3/15/17.
//  Copyright © 2017 NKT. All rights reserved.
//

import SpriteKit
class MainMenu: SKScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if atPoint(location).name == "Start" {
                if let scene = GamePlay(fileNamed: "GamePlayScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .fill
                    
                    // Present the scene
                    view!.presentScene(scene)
                }
                
            }
        }
    }
}
