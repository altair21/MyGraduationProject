//
//  GameScene.swift
//  GraduationProject
//
//  Created by altair21 on 16/4/19.
//  Copyright (c) 2016年 altair21. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        background.zPosition = -1
        addChild(background)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
   
    override func update(currentTime: CFTimeInterval) {
    }
}
