//
//  GameScene.swift
//  GraduationProject
//
//  Created by altair21 on 16/4/19.
//  Copyright (c) 2016年 altair21. All rights reserved.
//

import SpriteKit

enum TextureType {
    case Player
    case Wall
    case Vortex
    case Star
    case Finish
    case Spring //占位
}

struct PhysicsCategory {
    static let None:   UInt32 = 0
    static let Player: UInt32 = 0b1 //1
    static let Wall:   UInt32 = 0b10 //2
    static let Star:   UInt32 = 0b100 //4
    static let Vortex: UInt32 = 0b1000 //8
    static let Finish: UInt32 = 0b10000 //16
    static let Spring: UInt32 = 0b100000 //32
}
let vTextureLength = 32

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        background.zPosition = -2
        addChild(background)
        
        let topBG = SKSpriteNode(imageNamed: "top_bg")
        topBG.position = CGPoint(x: 512, y: 736)
        topBG.blendMode = .Replace
        topBG.zPosition = 100
        addChild(topBG)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
//        physicsWorld.contactDelegate = self
        
        
        loadLevel()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
   
    override func update(currentTime: CFTimeInterval) {
    }
    
    func initTexture(type: TextureType, position: CGPoint) {
        let node: SKSpriteNode
        
        switch type {
        case .Player:
            node = SKSpriteNode(imageNamed: "player")
            node.position = position
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody!.allowsRotation = true
            node.physicsBody!.linearDamping = 0.5
            node.physicsBody!.categoryBitMask = PhysicsCategory.Player
            node.physicsBody!.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Spring
            node.physicsBody!.contactTestBitMask = PhysicsCategory.Star | PhysicsCategory.Vortex | PhysicsCategory.Finish
            addChild(node)
        case .Wall:
            node = SKSpriteNode(imageNamed: "block")
            node.position = position
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
            node.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            node.physicsBody!.dynamic = false
            addChild(node)
        case .Vortex:
            node = SKSpriteNode(imageNamed: "vortex")
            node.position = position
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            node.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI), duration: 1.0)))
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody!.dynamic = false
            node.physicsBody!.categoryBitMask = PhysicsCategory.Vortex
            node.physicsBody!.collisionBitMask = PhysicsCategory.None
            node.physicsBody!.contactTestBitMask = PhysicsCategory.Player
            addChild(node)
        case .Star:
            node = SKSpriteNode(imageNamed: "star")
            node.position = position
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody!.categoryBitMask = PhysicsCategory.Star
            node.physicsBody!.collisionBitMask = PhysicsCategory.None
            node.physicsBody!.contactTestBitMask = PhysicsCategory.Player
            addChild(node)
        case .Spring:       //占位
            break
        case .Finish:
            node = SKSpriteNode(imageNamed: "finish")
            node.position = position
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody!.dynamic = false
            node.physicsBody!.categoryBitMask = PhysicsCategory.Finish
            node.physicsBody!.collisionBitMask = PhysicsCategory.None
            node.physicsBody!.contactTestBitMask = PhysicsCategory.Player
            addChild(node)
        }
    }
    
    func loadLevel() {
        if let levelPath = NSBundle.mainBundle().pathForResource("1", ofType: "txt") {
            if let levelString = try? String(contentsOfFile: levelPath, usedEncoding: nil) {
                let lines = levelString.componentsSeparatedByString("\n")
                
                for (row, line) in lines.reverse().enumerate() {
                    for (column, letter) in line.characters.enumerate() {
                        let position = CGPoint(x: vTextureLength * column + vTextureLength / 2, y: vTextureLength * row + vTextureLength / 2)
                        
                        switch letter {
                        case "1":
                            fallthrough
                        case "2":
                            fallthrough
                        case "3":
                            fallthrough
                        case "4":
                            fallthrough
                        case "x":
                            initTexture(.Wall, position: position)
                        case "v":
                            initTexture(.Vortex, position: position)
                        case "s":
                            initTexture(.Star, position: position)
                        case "f":
                            initTexture(.Finish, position: position)
                        case "p":
                            initTexture(.Player, position: position)
                        default: break
                            
                        }
                    }
                }
            }
        }
    }
}
