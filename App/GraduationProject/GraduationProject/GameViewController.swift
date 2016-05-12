//
//  GameViewController.swift
//  GraduationProject
//
//  Created by altair21 on 16/4/19.
//  Copyright (c) 2016年 altair21. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var passLabel: UILabel!
    var gameScene: GameScene!
    var isPlaying = false
    var mazeFilePath: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true

        if let scene = GameScene(fileNamed:"GameScene") {
            gameScene = scene
            gameScene.levelPath = mazeFilePath
            gameScene.viewController = self
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
//            skView.showsPhysics = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
        
        let radius: CGFloat = 10.0
        backBtn.layer.cornerRadius = radius
        uploadBtn.layer.cornerRadius = radius
        playBtn.layer.cornerRadius = radius
        
    }
    
    func setMazeFile(filePath: String) {
        mazeFilePath = filePath
    }
    
    @IBAction func playTapped(sender: UIButton) {
        playBtn.enabled = false
        playBtn.layer.opacity = 0.3
        isPlaying = true
        gameScene.gameStart()
    }
    
    @IBAction func uploadTapped(sender: UIButton) {
        MazeFileManager.sharedManager.uploadFile(NSURL(fileURLWithPath: mazeFilePath))
    }
    
    @IBAction func backTapped(sender: UIButton) {
        if isPlaying {
            gameScene.gamePause()
            let alert = UIAlertController(title: nil, message: "确定退出游戏吗？", preferredStyle: .Alert)
            let okBtn = UIAlertAction(title: "确定", style: .Default, handler: { (_) in
                self.navigationController?.popViewControllerAnimated(true)
            })
            let cancelBtn = UIAlertAction(title: "取消", style: .Cancel, handler: { (_) in
                self.gameScene.gameStart()
            })
            alert.addAction(okBtn)
            alert.addAction(cancelBtn)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func gamePassed() {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = UIColor.blackColor()
        view.layer.opacity = 0.0
        self.view.addSubview(view)
        
        self.view.bringSubviewToFront(passLabel)
        passLabel.layer.opacity = 0.0
        passLabel.hidden = false
        
        UIView.animateWithDuration(1.5) { 
            self.passLabel.layer.opacity = 1.0
            view.layer.opacity = 0.7
        }
        
        self.performSelector(#selector(delayPop), withObject: nil, afterDelay: 3)
    }
    
    func delayPop() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
