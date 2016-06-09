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
    var previewImage: UIImage!
    var previewImagePosition: CGRect!
    weak var gameListVC: GameListViewController!

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
            scene.scaleMode = .Fill
            
            skView.presentScene(scene)
        }
        
        let radius: CGFloat = 10.0
        backBtn.layer.cornerRadius = radius
        uploadBtn.layer.cornerRadius = radius
        playBtn.layer.cornerRadius = radius
        
    }
    
    func setMazeFile(filePath: String, image: UIImage, position: CGRect, viewController: GameListViewController) {
        mazeFilePath = filePath
        previewImage = image
        previewImagePosition = position
        gameListVC = viewController
    }
    
    @IBAction func playTapped(sender: UIButton) {
        playBtn.enabled = false
        playBtn.layer.opacity = 0.3
        isPlaying = true
        gameScene.gameStart()
    }
    
    @IBAction func uploadTapped(sender: UIButton) {
        uploadBtn.enabled = false
        MazeFileManager.sharedManager.uploadFile(filePath: NSURL(fileURLWithPath: mazeFilePath), uploadSuccess: { 
            showCenterToast("迷宫上传成功")
            self.uploadBtn.enabled = true
        }) {
            showCenterToast("迷宫上传失败")
            self.uploadBtn.enabled = true
        }
    }
    
    @IBAction func backTapped(sender: UIButton) {
        if isPlaying {
            gameScene.gamePause()
            let alert = UIAlertController(title: nil, message: "确定退出游戏吗？", preferredStyle: .Alert)
            let okBtn = UIAlertAction(title: "确定", style: .Default, handler: { (_) in
                self.backTappedGo(false)
            })
            let cancelBtn = UIAlertAction(title: "取消", style: .Cancel, handler: { (_) in
                self.gameScene.gameStart()
            })
            alert.addAction(okBtn)
            alert.addAction(cancelBtn)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            backTappedGo(false)
        }
    }
    
    func backTappedGo(gamePassed: Bool) {
        let imageView = UIImageView(image: imageFromSKNode(gameScene))
        imageView.frame = CGRect(x: 0, y: 64, width: 1024, height: 704)
        let topPanel = UIImageView(image: UIImage(named: "top_panel"))
        topPanel.frame = CGRect(x: 0, y: 0, width: 1024, height: 64)
        self.view.addSubview(topPanel)
        self.view.addSubview(imageView)
        self.navigationController?.popViewControllerAnimated(false)
        gameListVC.view.addSubview(topPanel)
        gameListVC.view.addSubview(imageView)
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        if gamePassed {
            topPanel.alpha = 0
            UIView.animateWithDuration(1.0, animations: {
                imageView.alpha = 0
                imageView.frame = self.previewImagePosition
            }, completion: { (res) in
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                topPanel.removeFromSuperview()
                imageView.removeFromSuperview()
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                topPanel.frame = self.previewImagePosition
                topPanel.alpha = 0
                imageView.frame = self.previewImagePosition
            }) { (res) in
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                topPanel.removeFromSuperview()
                imageView.removeFromSuperview()
            }
        }
    }
    
    func gamePassedGo() {
        backTappedGo(true)
    }
    
    func imageFromSKNode(node: SKNode) -> UIImage {
        let view = node.scene?.view
        let scale = UIScreen.mainScreen().scale
        let nodeFrame = node.calculateAccumulatedFrame()
        
        UIGraphicsBeginImageContextWithOptions(view!.bounds.size, true, 0)
        view?.drawViewHierarchyInRect(view!.bounds, afterScreenUpdates: true)
        let sceneSnapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let originY = sceneSnapshot.size.height*scale - nodeFrame.origin.y*scale - nodeFrame.size.height*scale
        let cropRect = CGRect(x: node.frame.origin.x * scale,
                              y: originY,
                              width: node.frame.size.width * scale,
                              height: node.frame.size.height * scale)
        let croppedSnapshot = CGImageCreateWithImageInRect(sceneSnapshot.CGImage, cropRect)
        let nodeSnapshot = UIImage(CGImage: croppedSnapshot!)
        
        //retain屏幕的rect
        let resRect = CGRect(x: 0, y: 128, width: 2048, height: 1408)
        let resCGSnapshot = CGImageCreateWithImageInRect(nodeSnapshot.CGImage, resRect)
        let resSnapshot = UIImage(CGImage: resCGSnapshot!)
        
        return resSnapshot
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
        
        self.performSelector(#selector(gamePassedGo), withObject: nil, afterDelay: 2)
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
