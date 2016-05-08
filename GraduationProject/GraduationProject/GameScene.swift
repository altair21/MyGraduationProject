//
//  GameScene.swift
//  GraduationProject
//
//  Created by altair21 on 16/4/19.
//  Copyright (c) 2016年 altair21. All rights reserved.
//

import SpriteKit
import CoreMotion

enum TextureType: String {
    case Player = "player"
    case Wall = "wall"
    case Vortex = "vortex"
    case Star = "star"
    case Finish = "finish"
    case Spring = "spring"  //占位
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

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var motionManager: CMMotionManager!
    var scoreLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    var gameOver = false
    var playerPosition: CGPoint!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMoveToView(view: SKView) {
        initBG()
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        loadLevel()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        if !gameOver {
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -15, dy: accelerometerData.acceleration.x * 15)
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.node == player {
            playerCollidedWithNode(contact.bodyB.node!)
        } else if contact.bodyB.node == player {
            playerCollidedWithNode(contact.bodyA.node!)
        }
    }
    
    func playerCollidedWithNode(node: SKNode) {
        if node.name == TextureType.Vortex.rawValue {
            player.physicsBody!.dynamic = false
            gameOver = true
            score -= 10
            
            let move = SKAction.moveTo(node.position, duration: 0.25)
            let scale = SKAction.scaleTo(0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            player.runAction(sequence) { [unowned self] in
                self.createPlayer()
                self.gameOver = false
            }
        } else if node.name == TextureType.Star.rawValue {
            node.removeFromParent()
            score += 1
        } else if node.name == TextureType.Finish.rawValue {
            
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
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.position = CGPoint(x: 16, y: 726)
        addChild(scoreLabel)
    }
    
    func initTexture(type: TextureType, position: CGPoint) {
        let node: SKSpriteNode
        
        switch type {
        case .Player:
            createPlayer()
        case .Wall:
            node = SKSpriteNode(imageNamed: "block")
            node.name = TextureType.Wall.rawValue
            node.position = position
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
            node.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            node.physicsBody!.dynamic = false
            addChild(node)
        case .Vortex:
            node = SKSpriteNode(imageNamed: "vortex")
            node.name = TextureType.Vortex.rawValue
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
            node.name = TextureType.Star.rawValue
            node.position = position
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody!.dynamic = false
            node.physicsBody!.categoryBitMask = PhysicsCategory.Star
            node.physicsBody!.collisionBitMask = PhysicsCategory.None
            node.physicsBody!.contactTestBitMask = PhysicsCategory.Player
            addChild(node)
        case .Spring:       //占位
            break
        case .Finish:
            node = SKSpriteNode(imageNamed: "finish")
            node.name = TextureType.Finish.rawValue
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
    
    func createPlayer() {
            player = SKSpriteNode(imageNamed: "player")
            player.name = TextureType.Player.rawValue
            player.position = playerPosition
            player.size = CGSize(width: vTextureLength, height: vTextureLength)
            player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2 * 0.8)
            player.physicsBody!.allowsRotation = true
            player.physicsBody!.linearDamping = 0.5
            player.physicsBody!.categoryBitMask = PhysicsCategory.Player
            player.physicsBody!.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Spring
            player.physicsBody!.contactTestBitMask = PhysicsCategory.Star | PhysicsCategory.Vortex | PhysicsCategory.Finish
            addChild(player)
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
                            playerPosition = position
                            initTexture(.Player, position: position)
                        default: break
                            
                        }
                    }
                }
            }
        }
    }
}
