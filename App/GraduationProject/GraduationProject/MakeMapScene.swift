//
//  MakeMapScene.swift
//  GraduationProject
//
//  Created by altair21 on 16/5/9.
//  Copyright © 2016年 altair21. All rights reserved.
//

import SpriteKit

struct MapNode {
    var x: Int
    var y: Int
}   //为方便（其实是我懒得改了），制作迷宫时x为列数，y为行数。在bfs时，x为行数，y为列数

class MakeMapScene: SKScene {
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
    var mapPlayer: SKSpriteNode!
    var mapFinish: SKSpriteNode!
    var mapPlayerPosition: MapNode!
    var mapFinishPosition: MapNode!
    var borderView: UIView!
    let enumNodeName = "enumNodeName"
    let customQueue = DispatchQueue(label: "com.altair21.queue")
    
    weak var viewController: MakeMapViewController!
    
    var lastTouchMapNode: MapNode!
    
    override func didMove(to view: SKView) {
        initBG()
        initMaze()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            if point.y >= 704 {
                locationInScene(touch.location(in: self))
            } else {
                drawAtPoint(point)
            }
            print(touch.location(in: self))
        } else {
            return
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            if point.y < 704 {
                drawAtPoint(point)
            }
        } else {
            return
        }
    }
    
    func drawAtPoint(_ point: CGPoint) {
        if currentSelectNode == nil {
            return
        }
        
        let col: Int = Int(point.x / CGFloat(vTextureLength))
        let row: Int = Int(point.y / CGFloat(vTextureLength))
        if (col == 0 || col == 31 || row == 0 || row == 21) {
            return
        }
        
        if currentSelectNode == eraser {
            checkNodeRemove(point)
        } else {
            checkNodeRemove(point)
            let node = SKSpriteNode(texture: currentSelectNode.texture)
            node.name = enumNodeName
            node.position = CGPoint(x: vTextureLength * col + vTextureLength / 2, y: vTextureLength * row + vTextureLength / 2)
            node.size = CGSize(width: vTextureLength, height: vTextureLength)
            if currentSelectNode == vortex {
                node.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1.0)))
            } else if currentSelectNode == player {
                if let mapPlayer = mapPlayer {
                    mapPlayer.removeFromParent()
                }
                mapPlayer = node
                mapPlayerPosition = MapNode(x: col, y: row)
            } else if currentSelectNode == finish {
                if let mapFinish = mapFinish {
                    mapFinish.removeFromParent()
                }
                mapFinish = node
                mapFinishPosition = MapNode(x: col, y: row)
            }
            addChild(node)
        }
        
        lastTouchMapNode = MapNode(x: col, y: row)
    }
    
    func generateMazeString() -> String {
        var mazeString = ""
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
        
        self.enumerateChildNodes(withName: enumNodeName) { (sknode, _) in
            let node = sknode as! SKSpriteNode
            if node.size != CGSize(width: vTextureLength, height: vTextureLength) {
                return
            }
            let point = node.position
            let col: Int = Int(point.x / CGFloat(vTextureLength))
            let row: Int = Int(point.y / CGFloat(vTextureLength))
            if (col == 0 || col == 31 || row == 0 || row == 21) {
                return
            }
            
            var letter: Character!
            if node.texture == self.player.texture {
                letter = "p"
            } else if node.texture == self.finish.texture {
                letter = "f"
            } else if node.texture == self.vortex.texture {
                letter = "v"
            } else if node.texture == self.star.texture {
                letter = "s"
            } else if node.texture == self.wall.texture {
                letter = "x"
            } else if node.texture == self.spring1.texture {
                letter = "1"
            } else if node.texture == self.spring2.texture {
                letter = "2"
            } else if node.texture == self.spring3.texture {
                letter = "3"
            } else if node.texture == self.spring4.texture {
                letter = "4"
            }
            
            let offset = (21 - row) * 33 + col
            var index = mazeString.startIndex
            for _ in 0..<offset {
                index = mazeString.index(after: index)
            }
            self.customQueue.sync(execute: {
                mazeString.remove(at: index)
                mazeString.insert(letter, at: index)
            })
            
        }
        
        return mazeString
    }
    
    func checkNodeRemove(_ point: CGPoint) {
        let nodes = self.nodes(at: point)
        for node in nodes {
            if node.name == enumNodeName {
                node.removeFromParent()
            }
        }
    }
    
    func locationInScene(_ position: CGPoint) {
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
            currentSelectNodeCharacter = " "
        } else if interact(position, rect: doneButton.frame) {
            doneTapped()
        }
    }
    
    func interact(_ point: CGPoint, rect: CGRect) -> Bool {
        if point.x >= rect.minX &&
            point.x <= rect.maxX &&
            point.y >= rect.minY &&
            point.y <= rect.maxY {
            return true
        } else {
            return false
        }
    }
    
    func initBorderView(_ frame: CGRect) {
        if let view = borderView {
            view.removeFromSuperview()
        }
        let resFrame = CGRect(x: frame.origin.x - 2.5, y: 0, width: frame.size.width + 5, height: frame.size.height + 5)
        borderView = UIView(frame: resFrame)
        borderView.layer.borderColor = UIColor.yellow.cgColor
        borderView.layer.borderWidth = 2.5
        self.view?.addSubview(borderView)
    }
    
    func initBorderViewAtVortex(_ frame: CGRect) {
        if let view = borderView {
            view.removeFromSuperview()
        }
        let resFrame = CGRect(x: 276.5, y: 0, width: 64, height: 64)
        borderView = UIView(frame: resFrame)
        borderView.layer.borderColor = UIColor.yellow.cgColor
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
        vortex.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1.0)))
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
        //FIXME: this may cause cycling reference
        let alert = UIAlertController(title: nil, message: "请选择要进行的操作：", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "完成", style: .default) { (_) in
            self.checkValidity(uploadMaze: false)
        }
        let uploadBtn = UIAlertAction(title: "完成并上传", style: .default) { (_) in
            self.checkValidity(uploadMaze: true)
        }
        let discardBtn = UIAlertAction(title: "放弃并退出", style: .default) { (_) in
            self.popViewController()
        }
        let cancelBtn = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        alert.addAction(uploadBtn)
        alert.addAction(discardBtn)
        alert.addAction(cancelBtn)
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func checkValidity(uploadMaze: Bool) {
        let mazeString = generateMazeString()
        var hasPlayer = false
        var hasFinish = false
        for char in mazeString.characters {
            if char == "p" {
                hasPlayer = true
            } else if char == "f" {
                hasFinish = true
            }
        }
        if !hasPlayer {
            let alert = UIAlertController(title: nil, message: "迷宫没有放置小球", preferredStyle: .alert)
            let cancelBtn = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(cancelBtn)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            return
        } else if !hasFinish {
            let alert = UIAlertController(title: nil, message: "迷宫没有放置终点", preferredStyle: .alert)
            let cancelBtn = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(cancelBtn)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            return
        }
        print(mazeString)
        let bfs = BFSUtility.initWith(mazeString, playerPosition: mapPlayerPosition, finishPosition: mapFinishPosition)
        if !bfs.checkByBFS() {
            let alert = UIAlertController(title: nil, message: "迷宫无法走通，请重新制作", preferredStyle: .alert)
            let cancelBtn = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alert.addAction(cancelBtn)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            _ = MazeFileManager.sharedManager.writeToFile(mazeString, upload: uploadMaze, writeFileSuccess: {
                showCenterToast("迷宫制作成功")
            }, writeFileFailure: {
                showCenterToast("迷宫制作失败")
            }, uploadSuccess: { 
                showCenterToast("迷宫上传成功")
            }, uploadFailure: { 
                showCenterToast("迷宫上传失败")
            })
            popViewController()
        }
    }
    
    func popViewController() {
        UIView.transition(with: self.viewController.navigationController!.view, duration: 0.6, options: [.transitionCurlUp, .curveEaseOut], animations: {
            _ = self.viewController.navigationController?.popViewController(animated: false)
        }, completion: nil)
    }
}

class BFSUtility: NSObject {
    var queue = Array<MapNode>()
    var front: Int = 0, rear: Int = 1
    var map = Array<Array<Character>>()
    var vis = Array<Array<Int>>()
    var playerPosition: MapNode!
    var finishPosition: MapNode!
    var dir = [0, 1, 0, -1, -1, 0, 1, 0]
    var mazeString: String!
    
    
    class func initWith(_ mazeString: String, playerPosition: MapNode, finishPosition: MapNode) -> BFSUtility {
        let object = BFSUtility()
        object.mazeString = mazeString
        object.playerPosition = MapNode(x: 21 - playerPosition.y, y: playerPosition.x)
        object.finishPosition = MapNode(x: 21 - finishPosition.y, y: finishPosition.x)
        return object
    }
    
    func checkByBFS() -> Bool {
        var charIndex = mazeString.startIndex
        for row in 0..<22 {
            var mapRow = Array<Character>()
            var visRow = Array<Int>()
            for _ in 0..<32 {
                visRow.append(0)
                mapRow.append(mazeString.characters[charIndex])
                charIndex = mazeString.index(after: charIndex)
            }
            if row < 21 {
                charIndex = mazeString.index(after: charIndex)
            }
            vis.append(visRow)
            map.append(mapRow)
        }
        
        queue.append(playerPosition)
        vis[playerPosition.x][playerPosition.y] = 1
        while front < rear {
            let tempNode = queue[front]
            front += 1
            
            for i in 0..<4 {
                let newNode = MapNode(x: tempNode.x + dir[i*2], y: tempNode.y + dir[i*2+1])
                if canGo(newNode) {
                    if map[newNode.x][newNode.y] == "f" {
                        return true
                    }
                    queue.append(newNode)
                    rear += 1
                    vis[newNode.x][newNode.y] = 1
                }
            }
        }
        return false
    }
    
    func canGo(_ node: MapNode) -> Bool {
        if node.x > 0 && node.x < 21 &&
            node.y > 0 && node.y < 31 &&
            map[node.x][node.y] != "x" &&
            map[node.x][node.y] != "v" &&
            map[node.x][node.y] != "1" &&
            map[node.x][node.y] != "2" &&
            map[node.x][node.y] != "3" &&
            map[node.x][node.y] != "4" &&
            vis[node.x][node.y] == 0 {
            return true
        } else {
            return false
        }
    }
}
