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
    var mapPlayer: SKSpriteNode!
    var mapFinish: SKSpriteNode!
    var mapPlayerPosition: MapNode!
    var mapFinishPosition: MapNode!
    var borderView: UIView!
    let enumNodeName = "enumNodeName"
    weak var viewController: MakeMapViewController!
    
    var lastTouchMapNode: MapNode!
    
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
                drawAtPoint(point)
            }
            print(touch.locationInNode(self))
        } else {
            return
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInNode(self)
            if point.y < 704 {
                drawAtPoint(point)
            }
        } else {
            return
        }
    }
    
    func drawAtPoint(point: CGPoint) {
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
                node.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI), duration: 1.0)))
            } else if currentSelectNode == player {
                if let mapPlayer = mapPlayer {
                    mapPlayer.removeFromParent()
                    let offset = (21 - mapPlayerPosition.y) * 33 + mapPlayerPosition.x
                    var index = mazeString.startIndex
                    for _ in 0..<offset {
                        index = index.successor()
                    }
                    mazeString.removeAtIndex(index)
                    mazeString.insert(" ", atIndex: index)
                }
                mapPlayer = node
                mapPlayerPosition = MapNode(x: col, y: row)
            } else if currentSelectNode == finish {
                if let mapFinish = mapFinish {
                    mapFinish.removeFromParent()
                    let offset = (21 - mapFinishPosition.y) * 33 + mapFinishPosition.x
                    var index = mazeString.startIndex
                    for _ in 0..<offset {
                        index = index.successor()
                    }
                    mazeString.removeAtIndex(index)
                    mazeString.insert(" ", atIndex: index)
                }
                mapFinish = node
                mapFinishPosition = MapNode(x: col, y: row)
            }
            addChild(node)
            
            let offset = (21 - row) * 33 + col
            var index = mazeString.startIndex
            for _ in 0..<offset {
                index = index.successor()
            }
            mazeString.removeAtIndex(index)
            mazeString.insert(currentSelectNodeCharacter, atIndex: index)
        }
        
        lastTouchMapNode = MapNode(x: col, y: row)
    }
    
    func checkNodeRemove(point: CGPoint) {
        if let lastTouchMapNode = lastTouchMapNode {
            if lastTouchMapNode.x == Int(point.x / CGFloat(vTextureLength)) &&
                lastTouchMapNode.y == Int(point.y / CGFloat(vTextureLength)) {
                return
            }
        }
        
        //FIXME: this may cause cycling reference
        self.enumerateChildNodesWithName(enumNodeName) { (node, _) in
            if self.interact(point, rect: node.frame) {
                node.removeFromParent()
                let col = Int(node.frame.origin.x / CGFloat(vTextureLength))
                let row = Int(node.frame.origin.y / CGFloat(vTextureLength))
                let offset = (21 - row) * 33 + col
                var index = self.mazeString.startIndex
                for _ in 0..<offset {
                    index = index.successor()
                }
                self.mazeString.removeAtIndex(index)
                self.mazeString.insert(" ", atIndex: index)
            }
        }
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
            currentSelectNodeCharacter = " "
        } else if interact(position, rect: doneButton.frame) {
            doneTapped()
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
        //FIXME: this may cause cycling reference
        let alert = UIAlertController(title: nil, message: "迷宫制作完成了吗？", preferredStyle: .Alert)
        let okBtn = UIAlertAction(title: "确定", style: .Default) { (_) in
            self.checkValidity()
        }
        let discardBtn = UIAlertAction(title: "放弃", style: .Default) { (_) in
            self.viewController.navigationController?.popViewControllerAnimated(true)
        }
        let cancelBtn = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alert.addAction(okBtn)
        alert.addAction(discardBtn)
        alert.addAction(cancelBtn)
        self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func checkValidity() {
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
            let alert = UIAlertController(title: nil, message: "迷宫没有放置小球", preferredStyle: .Alert)
            let cancelBtn = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alert.addAction(cancelBtn)
            self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        } else if !hasFinish {
            let alert = UIAlertController(title: nil, message: "迷宫没有放置终点", preferredStyle: .Alert)
            let cancelBtn = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alert.addAction(cancelBtn)
            self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
        print(mazeString)
        let bfs = BFSUtility.initWith(mazeString, playerPosition: mapPlayerPosition, finishPosition: mapFinishPosition)
        if !bfs.checkByBFS() {
            let alert = UIAlertController(title: nil, message: "迷宫无法走通，请重新制作", preferredStyle: .Alert)
            let cancelBtn = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
            alert.addAction(cancelBtn)
            self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        } else {
            if MazeFileManager.writeToFile(mazeString) {
                self.view?.makeToast("迷宫制作完成", duration: 2.0, position: ToastPosition.Center)
            }
        }
    }
}

class BFSUtility: NSObject {
    var queue = Array<MapNode>()
    var front: Int = 0, rear: Int = 1
    var map = Array<Array<Character>>()
    var vis = Array<Array<Int>>()
    var playerPosition: MapNode!
    var finishPosition: MapNode!
    var mazeString: String!
    
    
    class func initWith(mazeString: String, playerPosition: MapNode, finishPosition: MapNode) -> BFSUtility {
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
                charIndex = charIndex.successor()
            }
            if row < 21 {
                charIndex = charIndex.successor()
            }
            vis.append(visRow)
            map.append(mapRow)
        }
        
        queue.append(playerPosition)
        vis[playerPosition.x][playerPosition.y] = 1
        while front < rear {
            let tempNode = queue[front]
            front += 1
            
            let newNode1 = MapNode(x: tempNode.x + 1, y: tempNode.y)
            if canGo(newNode1) {
                if (map[newNode1.x][newNode1.y] == "f") {
                    return true
                }
                queue.append(newNode1)
                rear += 1
                vis[newNode1.x][newNode1.y] = 1
            }
            let newNode2 = MapNode(x: tempNode.x - 1, y: tempNode.y)
            if canGo(newNode2) {
                if (map[newNode2.x][newNode2.y] == "f") {
                    return true
                }
                queue.append(newNode2)
                rear += 1
                vis[newNode2.x][newNode2.y] = 1
            }
            let newNode3 = MapNode(x: tempNode.x, y: tempNode.y + 1)
            if canGo(newNode3) {
                if (map[newNode3.x][newNode3.y] == "f") {
                    return true
                }
                queue.append(newNode3)
                rear += 1
                vis[newNode3.x][newNode3.y] = 1
            }
            let newNode4 = MapNode(x: tempNode.x, y: tempNode.y - 1)
            if canGo(newNode4) {
                if (map[newNode4.x][newNode4.y] == "f") {
                    return true
                }
                queue.append(newNode4)
                rear += 1
                vis[newNode4.x][newNode4.y] = 1
            }
        }
        return false
    }
    
    func canGo(node: MapNode) -> Bool {
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
