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
        
        self.navigationController?.isNavigationBarHidden = true

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
            scene.scaleMode = .fill
            
            skView.presentScene(scene)
        }
        
        let radius: CGFloat = 10.0
        backBtn.layer.cornerRadius = radius
        uploadBtn.layer.cornerRadius = radius
        playBtn.layer.cornerRadius = radius
        
    }
    
    func setMazeFile(_ filePath: String, image: UIImage, position: CGRect, viewController: GameListViewController) {
        mazeFilePath = filePath
        previewImage = image
        previewImagePosition = position
        gameListVC = viewController
    }
    
    @IBAction func playTapped(_ sender: UIButton) {
        playBtn.isEnabled = false
        playBtn.layer.opacity = 0.3
        isPlaying = true
        gameScene.gameStart()
    }
    
    @IBAction func uploadTapped(_ sender: UIButton) {
        uploadBtn.isEnabled = false
        MazeFileManager.sharedManager.uploadFile(filePath: URL(fileURLWithPath: mazeFilePath), uploadSuccess: { 
            showCenterToast("迷宫上传成功")
            self.uploadBtn.isEnabled = true
        }) {
            showCenterToast("迷宫上传失败")
            self.uploadBtn.isEnabled = true
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        if isPlaying {
            gameScene.gamePause()
            let alert = UIAlertController(title: nil, message: "确定退出游戏吗？", preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "确定", style: .default, handler: { (_) in
                self.backTappedGo(false)
            })
            let cancelBtn = UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
                self.gameScene.gameStart()
            })
            alert.addAction(okBtn)
            alert.addAction(cancelBtn)
            self.present(alert, animated: true, completion: nil)
        } else {
            backTappedGo(false)
        }
    }
    
    func backTappedGo(_ gamePassed: Bool) {
        let imageView = UIImageView(image: imageFromSKNode(gameScene))
        imageView.frame = CGRect(x: 0, y: 64, width: 1024, height: 704)
        let topPanel = UIImageView(image: UIImage(named: "top_panel"))
        topPanel.frame = CGRect(x: 0, y: 0, width: 1024, height: 64)
        self.view.addSubview(topPanel)
        self.view.addSubview(imageView)
        _ = self.navigationController?.popViewController(animated: false)
        gameListVC.view.addSubview(topPanel)
        gameListVC.view.addSubview(imageView)
        UIApplication.shared.beginIgnoringInteractionEvents()
        if gamePassed {
            topPanel.alpha = 0
            UIView.animate(withDuration: 1.0, animations: {
                imageView.alpha = 0
                imageView.frame = self.previewImagePosition
            }, completion: { (res) in
                UIApplication.shared.endIgnoringInteractionEvents()
                topPanel.removeFromSuperview()
                imageView.removeFromSuperview()
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                topPanel.frame = self.previewImagePosition
                topPanel.alpha = 0
                imageView.frame = self.previewImagePosition
            }, completion: { (res) in
                UIApplication.shared.endIgnoringInteractionEvents()
                topPanel.removeFromSuperview()
                imageView.removeFromSuperview()
            }) 
        }
    }
    
    func gamePassedGo() {
        backTappedGo(true)
    }
    
    func imageFromSKNode(_ node: SKNode) -> UIImage {
        let view = node.scene?.view
        let scale = UIScreen.main.scale
        let nodeFrame = node.calculateAccumulatedFrame()
        
        UIGraphicsBeginImageContextWithOptions(view!.bounds.size, true, 0)
        view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        let sceneSnapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let originY = (sceneSnapshot?.size.height)!*scale - nodeFrame.origin.y*scale - nodeFrame.size.height*scale
        let cropRect = CGRect(x: node.frame.origin.x * scale,
                              y: originY,
                              width: node.frame.size.width * scale,
                              height: node.frame.size.height * scale)
        let croppedSnapshot = sceneSnapshot?.cgImage?.cropping(to: cropRect)
        let nodeSnapshot = UIImage(cgImage: croppedSnapshot!)
        
        //retain屏幕的rect
        let resRect = CGRect(x: 0, y: 128, width: 2048, height: 1408)
        let resCGSnapshot = nodeSnapshot.cgImage?.cropping(to: resRect)
        let resSnapshot = UIImage(cgImage: resCGSnapshot!)
        
        return resSnapshot
    }
    
    func gamePassed() {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = UIColor.black
        view.layer.opacity = 0.0
        self.view.addSubview(view)
        
        self.view.bringSubview(toFront: passLabel)
        passLabel.layer.opacity = 0.0
        passLabel.isHidden = false
        
        UIView.animate(withDuration: 1.5, animations: { 
            self.passLabel.layer.opacity = 1.0
            view.layer.opacity = 0.7
        }) 
        
        self.perform(#selector(gamePassedGo), with: nil, afterDelay: 2)
    }
    
    func delayPop() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
