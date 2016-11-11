//
//  GameScene.swift
//  GraduationProject
//
//  Created by altair21 on 16/4/19.
//  Copyright (c) 2016年 altair21. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var motionManager: CMMotionManager!
    var scoreLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    var gameOver = false
    var isPlaying = false
    var playerPosition: CGPoint!
    var levelPath: String!
    weak var viewController: GameViewController!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        initBG()
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        loadLevel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
   
    override func update(_ currentTime: TimeInterval) {
        if !gameOver && isPlaying {
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -20, dy: accelerometerData.acceleration.x * 20)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == player {
            playerCollidedWithNode(contact.bodyB.node!)
        } else if contact.bodyB.node == player {
            playerCollidedWithNode(contact.bodyA.node!)
        }
    }
    
    func playerCollidedWithNode(_ node: SKNode) {
        if node.name == TextureType.Vortex.rawValue {
            player.physicsBody!.isDynamic = false
            gameOver = true
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            player.run(sequence, completion: { [unowned self] in
                self.createPlayer()
                self.gameOver = false
            }) 
        } else if node.name == TextureType.Star.rawValue {
            node.removeFromParent()
            score += 1
        } else if node.name == TextureType.Finish.rawValue {
            gamePassed(node)
        }
    }
    
    func gameStart() {
        isPlaying = true
        player.physicsBody!.isDynamic = true
        self.enumerateChildNodes(withName: TextureType.Vortex.rawValue) { (node, _) in
            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1.0)))
        }
    }
    
    func gamePause() {
        isPlaying = false
        player.physicsBody!.isDynamic = false
        self.enumerateChildNodes(withName: TextureType.Vortex.rawValue) { (node, _) in
            node.removeAllActions()
        }
    }
    
    func gamePassed(_ node: SKNode) {
        gameOver = true
        let scale = SKAction.scale(to: 0.0001, duration: 0.25)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([scale, remove])
        player.run(sequence)
        node.run(sequence)
        
        viewController.gamePassed()
    }
    
    func initBG() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -2
        addChild(background)
        
        let topBG = SKSpriteNode(imageNamed: "top_bg")
        topBG.position = CGPoint(x: 512, y: 736)
        topBG.blendMode = .replace
        topBG.zPosition = -1
        addChild(topBG)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 726)
        addChild(scoreLabel)
    }
    
    func initTexture(_ type: TextureType, position: CGPoint) {
        let node: SKSpriteNode
        
        switch type {
        case .Player:
            createPlayer()
        case .Wall:
            node = SKSpriteNode(imageNamed: "block")
            node.name = TextureType.Wall.rawValue
            node.position = position
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
            node.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            node.physicsBody!.isDynamic = false
            addChild(node)
        case .Vortex:
            node = SKSpriteNode(imageNamed: "vortex")
            node.name = TextureType.Vortex.rawValue
            node.position = position
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2 * 0.75)
            node.physicsBody!.isDynamic = false
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
            node.physicsBody!.isDynamic = false
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
            node.physicsBody!.isDynamic = false
            node.physicsBody!.categoryBitMask = PhysicsCategory.Finish
            node.physicsBody!.collisionBitMask = PhysicsCategory.None
            node.physicsBody!.contactTestBitMask = PhysicsCategory.Player
            addChild(node)
        }
    }
    
    func initSpring(_ type: Int, position: CGPoint) {
        var node: SKSpriteNode = SKSpriteNode(imageNamed: "spring1")
        switch type {
        case 1:
            node = SKSpriteNode(imageNamed: "spring1")
            node.name = TextureType.Spring.rawValue
            node.position = CGPoint(x: position.x - CGFloat(vTextureLength) / 4, y: position.y)
            node.size = CGSize(width: vTextureLength / 2, height: vTextureLength)
        case 2:
            node = SKSpriteNode(imageNamed: "spring2")
            node.name = TextureType.Spring.rawValue
            node.position = CGPoint(x: position.x, y: position.y + CGFloat(vTextureLength) / 4)
            node.size = CGSize(width: vTextureLength, height: vTextureLength / 2)
        case 3:
            node = SKSpriteNode(imageNamed: "spring3")
            node.name = TextureType.Spring.rawValue
            node.position = CGPoint(x: position.x + CGFloat(vTextureLength) / 4, y: position.y)
            node.size = CGSize(width: vTextureLength / 2, height: vTextureLength)
        case 4:
            node = SKSpriteNode(imageNamed: "spring4")
            node.name = TextureType.Spring.rawValue
            node.position = CGPoint(x: position.x, y: position.y - CGFloat(vTextureLength) / 4)
            node.size = CGSize(width: vTextureLength, height: vTextureLength / 2)
        default:
            break
        }
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody!.isDynamic = false
        node.physicsBody!.categoryBitMask = PhysicsCategory.Spring
        node.physicsBody!.collisionBitMask = PhysicsCategory.Player
        node.physicsBody!.contactTestBitMask = PhysicsCategory.None
        node.physicsBody!.restitution = 0.85
        addChild(node)
        initSpringBase(type, position: position)
    }
    
    func initSpringBase(_ type: Int, position: CGPoint) {
        var node = SKSpriteNode(imageNamed: "spring_base_1")
        switch type {
        case 1:
            node = SKSpriteNode(imageNamed: "spring_base_1")
            node.name = TextureType.Wall.rawValue
            node.position = CGPoint(x: position.x + CGFloat(vTextureLength) / 4, y: position.y)
            node.size = CGSize(width: vTextureLength / 2, height: vTextureLength)
        case 2:
            node = SKSpriteNode(imageNamed: "spring_base_2")
            node.name = TextureType.Wall.rawValue
            node.position = CGPoint(x: position.x, y: position.y - CGFloat(vTextureLength) / 4)
            node.size = CGSize(width: vTextureLength, height: vTextureLength / 2)
        case 3:
            node = SKSpriteNode(imageNamed: "spring_base_3")
            node.name = TextureType.Wall.rawValue
            node.position = CGPoint(x: position.x - CGFloat(vTextureLength) / 4, y: position.y)
            node.size = CGSize(width: vTextureLength / 2, height: vTextureLength)
        case 4:
            node = SKSpriteNode(imageNamed: "spring_base_4")
            node.name = TextureType.Wall.rawValue
            node.position = CGPoint(x: position.x, y: position.y + CGFloat(vTextureLength) / 4)
            node.size = CGSize(width: vTextureLength, height: vTextureLength / 2)
        default:
            break
        }
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody!.isDynamic = false
        node.physicsBody!.categoryBitMask = PhysicsCategory.Wall
        node.physicsBody!.collisionBitMask = PhysicsCategory.Player
        node.physicsBody!.contactTestBitMask = PhysicsCategory.None
        addChild(node)
    }
    
    func createPlayer() {
            player = SKSpriteNode(imageNamed: "player")
            player.name = TextureType.Player.rawValue
            player.position = playerPosition
            player.size = CGSize(width: vTextureLength, height: vTextureLength)
            player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2 * 0.65)
            player.physicsBody!.allowsRotation = true
            player.physicsBody!.linearDamping = 0.5
            player.physicsBody!.categoryBitMask = PhysicsCategory.Player
            player.physicsBody!.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Spring
            player.physicsBody!.contactTestBitMask = PhysicsCategory.Star | PhysicsCategory.Vortex | PhysicsCategory.Finish
            addChild(player)
    }
    
    func loadLevel() {
        if let levelString = try? String(contentsOfFile: levelPath) {
            let lines = levelString.components(separatedBy: "\n")
            
            for (row, line) in lines.reversed().enumerated() {
                for (column, letter) in line.characters.enumerated() {
                    let position = CGPoint(x: vTextureLength * column + vTextureLength / 2, y: vTextureLength * row + vTextureLength / 2)
                    
                    switch letter {
                    case "1":
                        initSpring(1, position: position)
                    case "2":
                        initSpring(2, position: position)
                    case "3":
                        initSpring(3, position: position)
                    case "4":
                        initSpring(4, position: position)
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
