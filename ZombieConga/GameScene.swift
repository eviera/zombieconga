//
//  GameScene.swift
//  ZombieConga
//
//  Created by Emiliano on 1/6/15.
//  Copyright (c) 2015 eviera.net. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    let zombie = SKSpriteNode(imageNamed: "zombie1")
    
    override func didMoveToView(view: SKView) {
        backgroundColor  = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
        
        zombie.position = CGPoint(x: 400, y: 400)
        addChild(zombie)
        

    }
    
}
