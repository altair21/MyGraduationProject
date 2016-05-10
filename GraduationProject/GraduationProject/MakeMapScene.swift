//
//  MakeMapScene.swift
//  GraduationProject
//
//  Created by altair21 on 16/5/9.
//  Copyright © 2016年 altair21. All rights reserved.
//

import SpriteKit

class MakeMapScene: SKScene {
    var mazeString: String = ""
    var player: SKSpriteNode!
    var finish: SKSpriteNode!
    var wall: SKSpriteNode!
    var vortex: SKSpriteNode!
    var star: SKSpriteNode!
    var spring1: SKSpriteNode!
    var spring2: SKSpriteNode!
    var spring3: SKSpriteNode!
    var spring4: SKSpriteNode!
    var eraser: SKSpriteNode!
    var doneButton: SKSpriteNode!
    var currentSelectNode: SKSpriteNode!
    var currentSelectNodeCharacter: Character!
    var borderView: UIView!
    
    override func didMoveToView(view: SKView) {
        initBG()
        initMaze()
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInNode(self)
            if point.y >= 704 {
                locationInScene(touch.locationInNode(self))
            } else {
                
            }
            print(touch.locationInNode(self))
        } else {
            return
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    func locationInScene(position: CGPoint) {
        if interact(position, rect: player.frame) {
            initBorderView(player.frame)
            currentSelectNode = player
            currentSelectNodeCharacter = "p"
        } else if interact(position, rect: finish.frame) {
            initBorderView(finish.frame)
            currentSelectNode = finish
            currentSelectNodeCharacter = "f"
        } else if interact(position, rect: wall.frame) {
            initBorderView(wall.frame)
            currentSelectNode = wall
            currentSelectNodeCharacter = "x"
        } else if interact(position, rect: vortex.frame) {
            initBorderViewAtVortex(vortex.frame)
            currentSelectNode = vortex
            currentSelectNodeCharacter = "v"
        } else if interact(position, rect: star.frame) {
            initBorderView(star.frame)
            currentSelectNode = star
            currentSelectNodeCharacter = "s"
        } else if interact(position, rect: spring1.frame) {
            initBorderView(spring1.frame)
            currentSelectNode = spring1
            currentSelectNodeCharacter = "1"
        } else if interact(position, rect: spring2.frame) {
            initBorderView(spring2.frame)
            currentSelectNode = spring2
            currentSelectNodeCharacter = "2"
        } else if interact(position, rect: spring3.frame) {
            initBorderView(spring3.frame)
            currentSelectNode = spring3
            currentSelectNodeCharacter = "3"
        } else if interact(position, rect: spring4.frame) {
            initBorderView(spring4.frame)
            currentSelectNode = spring4
            currentSelectNodeCharacter = "4"
        } else if interact(position, rect: eraser.frame) {
            initBorderView(eraser.frame)
            currentSelectNode = eraser
        } else if interact(position, rect: doneButton.frame) {
            
        }
    }
    
    func interact(point: CGPoint, rect: CGRect) -> Bool {
        if point.x >= CGRectGetMinX(rect) &&
            point.x <= CGRectGetMaxX(rect) &&
            point.y >= CGRectGetMinY(rect) &&
            point.y <= CGRectGetMaxY(rect) {
            return true
        } else {
            return false
        }
    }
    
    func initBorderView(frame: CGRect) {
        if let view = borderView {
            view.removeFromSuperview()
        }
        let resFrame = CGRectMake(frame.origin.x - 2.5, 0, frame.size.width + 5, frame.size.height + 5)
        borderView = UIView(frame: resFrame)
        borderView.layer.borderColor = UIColor.yellowColor().CGColor
        borderView.layer.borderWidth = 2.5
        self.view?.addSubview(borderView)
    }
    
    func initBorderViewAtVortex(frame: CGRect) {
        if let view = borderView {
            view.removeFromSuperview()
        }
        let resFrame = CGRectMake(276.5, 0, 64, 64)
        borderView = UIView(frame: resFrame)
        borderView.layer.borderColor = UIColor.yellowColor().CGColor
        borderView.layer.borderWidth = 2.5
        self.view?.addSubview(borderView)
    }
    
    func initMaze() {
        for col in 0..<32 {
            let node = SKSpriteNode(imageNamed: "block")
            node.position = CGPoint(x: vTextureLength * col + vTextureLength / 2, y: vTextureLength / 2)
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            addChild(node)
        }
        for row in 1..<22 {
            let node = SKSpriteNode(imageNamed: "block")
            node.position = CGPoint(x: vTextureLength / 2, y: vTextureLength * row + vTextureLength / 2)
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            addChild(node)
            
            let node2 = SKSpriteNode(imageNamed: "block")
            node2.position = CGPoint(x: 31 * vTextureLength + vTextureLength / 2, y: vTextureLength * row + vTextureLength / 2)
            node2.size = CGSize(width: vTextureLength, height: vTextureLength)
            addChild(node2)
        }
        for col in 0..<32 {
            let node = SKSpriteNode(imageNamed: "block")
            node.position = CGPoint(x: vTextureLength * col + vTextureLength / 2, y: vTextureLength * 21 + vTextureLength / 2)
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            addChild(node)
        }
        
        initMazeString()
    }
    
    func initMazeString() {
        for _ in 1...32 {
            mazeString.append(Character("x"))
        }
        mazeString.append(Character("\n"))
        for _ in 2..<22 {
            mazeString.append(Character("x"))
            for _ in 2..<32 {
                mazeString.append(Character(" "))
            }
            mazeString.append(Character("x"))
            mazeString.append(Character("\n"))
        }
        for _ in 1...32 {
            mazeString.append(Character("x"))
        }
    }
    
    func initBG() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        background.zPosition = -2
        addChild(background)
        
        let topBG = SKSpriteNode(imageNamed: "top_bg")
        topBG.position = CGPoint(x: 512, y: 736)
        topBG.blendMode = .Replace
        topBG.zPosition = -1
        addChild(topBG)
        
        initTopPanel()
    }
    
    func initTopPanel() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 17 + 29.5, y: 736)
        player.size = CGSize(width: 59, height: 59)
        addChild(player)
        
        finish = SKSpriteNode(imageNamed: "finish")
        finish.position = CGPoint(x: 93 + 29.5, y: 736)
        finish.size = CGSize(width: 59, height: 59)
        addChild(finish)
        
        wall = SKSpriteNode(imageNamed: "block")
        wall.position = CGPoint(x: 186 + 29.5, y: 736)
        wall.size = CGSize(width: 59, height: 59)
        addChild(wall)
        
        vortex = SKSpriteNode(imageNamed: "vortex")
        vortex.position = CGPoint(x: 279 + 29.5, y: 736)
        vortex.size = CGSize(width: 59, height: 59)
        vortex.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI), duration: 1.0)))
        addChild(vortex)
        
        star = SKSpriteNode(imageNamed: "star")
        star.position = CGPoint(x: 372 + 29.5, y: 736)
        star.size = CGSize(width: 59, height: 59)
        addChild(star)
        
        //springs
        spring1 = SKSpriteNode(imageNamed: "spring_node_1")
        spring1.position = CGPoint(x: 465 + 29.5, y: 736)
        spring1.size = CGSize(width: 59, height: 59)
        addChild(spring1)
        
        spring2 = SKSpriteNode(imageNamed: "spring_node_2")
        spring2.position = CGPoint(x: 558 + 29.5, y: 736)
        spring2.size = CGSize(width: 59, height: 59)
        addChild(spring2)
        
        spring3 = SKSpriteNode(imageNamed: "spring_node_3")
        spring3.position = CGPoint(x: 651 + 29.5, y: 736)
        spring3.size = CGSize(width: 59, height: 59)
        addChild(spring3)
        
        spring4 = SKSpriteNode(imageNamed: "spring_node_4")
        spring4.position = CGPoint(x: 744 + 29.5, y: 736)
        spring4.size = CGSize(width: 59, height: 59)
        addChild(spring4)
        
        eraser = SKSpriteNode(imageNamed: "eraser")
        eraser.position = CGPoint(x: 837 + 29.5, y: 736)
        eraser.size = CGSize(width: 59, height: 59)
        addChild(eraser)
        
        doneButton = SKSpriteNode(imageNamed: "done")
        doneButton.position = CGPoint(x: 930 + 29.5, y: 736)
        doneButton.size = CGSize(width: 59, height: 59)
        addChild(doneButton)
    }
    
    func doneTapped() {
        
    }
}
