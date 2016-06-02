//
//  GameListViewController.swift
//  GraduationProject
//
//  Created by altair21 on 16/5/12.
//  Copyright © 2016年 altair21. All rights reserved.
//

import UIKit

class GameListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DynamicMaskSegmentSwitchDelegate {
    let kRefreshValueOnDisk = "kRefreshValueOnDisk"
    
    var mazeTitle = Array<String>()
    var localMazeTitle = Array<String>()
    var remoteMazeTitle = Array<String>()
    var imageDic: Dictionary<String, UIImage> = [:]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switcher: DynamicMaskSegmentSwitch!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var refreshSwitch: UISwitch!
    @IBOutlet weak var localDoge: UIImageView!
    @IBOutlet weak var remoteDoge: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configure = DynamicMaskSegmentSwitchConfigure(highlightedColor: .orangeColor(), normalColor: .whiteColor(), items: ["本地地图","服务器地图"])
        switcher.configure = configure
        switcher.delegate = self
        
        backBtn.layer.cornerRadius = 10.0
        refreshBtn.layer.cornerRadius = 10.0
        
        tableView.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI) / CGFloat(2))
        tableView.frame = CGRect(x: 0, y: 230, width: tableView.frame.size.width, height: tableView.frame.size.height)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        localMazeTitle = MazeFileManager.sharedManager.getLocalFilesList(isLocalDir: true)
        localMazeTitle.sortInPlace()
        remoteMazeTitle = MazeFileManager.sharedManager.getLocalFilesList(isLocalDir: false)
        remoteMazeTitle.sortInPlace()
        if switcher.currentIndex == 0 {
            if localMazeTitle.count == 0 {
                localDoge.hidden = false
            }
        } else {
            if remoteMazeTitle.count == 0 {
                remoteDoge.hidden = false
            }
        }
        
        if shouldUpdateFile() {
            refreshRemoteFile(false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshRemoteFile(forceUpdate: Bool) {
        MazeFileManager.sharedManager.getFileList({ (result) in
            if let JSON = result.value {
                if JSON["result"] as! String == "success" {
                    let tempArr: Array<String> = JSON["files"] as! Array
                    var updateFlag = false
                    for title in tempArr {
                        if !self.localMazeTitle.contains(title) {
                            self.remoteMazeTitle.append(title)
                            updateFlag = true
                            MazeFileManager.sharedManager.download(title)
                        }
                    }
                    
                    if forceUpdate {
                        showCenterToast("获取文件列表成功")
                    }
                    
                    //去重，原谅我用这么奇怪的姿势
                    let tempSet = Set(self.remoteMazeTitle)
                    self.remoteMazeTitle = Array(tempSet)
                    self.remoteMazeTitle.sortInPlace()
                    if updateFlag && self.switcher.currentIndex == 1 {
                        self.tableView.reloadData()
                    }
                } else {
                    if forceUpdate {
                        showCenterToast("获取文件列表失败")
                    }
                }
//                print("JSON: \(JSON)")
            }
        }) { (error) in
            if forceUpdate {
                showCenterToast("获取文件列表失败")
            }
            print(error)
        }
    }
    
    func shouldUpdateFile() -> Bool {
        if let res = NSUserDefaults.standardUserDefaults().objectForKey(kRefreshValueOnDisk) as? Bool{
            refreshSwitch.setOn(res, animated: false)
            return res
        } else {
            return refreshSwitch.on
        }
    }
    
    @IBAction func refreshSwitchChanged(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(refreshSwitch.on, forKey: kRefreshValueOnDisk)
    }
    
    @IBAction func refreshBtnTapped(sender: UIButton) {
        refreshRemoteFile(true)
    }
    
    @IBAction func backBtnTapped(sender: UIButton) {
        UIView.transitionWithView(self.navigationController!.view, duration: 0.75, options: .TransitionFlipFromLeft, animations: {
            self.navigationController?.popViewControllerAnimated(false)
            }, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if switcher.currentIndex == 0 {
            return localMazeTitle.count
        } else {
            return remoteMazeTitle.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(720)
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        let myCell = cell as! GameListTableViewCell
//        myCell.showPreviewZone()
//    }
    
//    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        let myCell = cell as! GameListTableViewCell
//        myCell.previewZone.alpha = 0.1
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellGameListTableViewCell) as! GameListTableViewCell
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
        if switcher.currentIndex == 0 {
            cell.setupView(fileName: self.localMazeTitle[indexPath.item],
                           filePath: MazeFileManager.sharedManager.getFileFullPath(self.localMazeTitle[indexPath.item], isLocalFile: true),
                           superView: self)
        } else {
            cell.setupView(fileName: self.remoteMazeTitle[indexPath.item],
                           filePath: MazeFileManager.sharedManager.getFileFullPath(self.remoteMazeTitle[indexPath.item], isLocalFile: false),
                           superView: self)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GameListTableViewCell
        cell.snapshot()
        let rect = cell.previewZone.convertRect(cell.previewZone.bounds, toView: self.view)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(storyboardGameViewController) as! GameViewController
        if switcher.currentIndex == 0 {
            vc.setMazeFile(MazeFileManager.sharedManager.getFileFullPath(self.localMazeTitle[indexPath.item], isLocalFile: true), image: imageDic[localMazeTitle[indexPath.item]]!,
                           position: rect, viewController: self)
        } else {
            vc.setMazeFile(MazeFileManager.sharedManager.getFileFullPath(self.remoteMazeTitle[indexPath.item], isLocalFile: false), image: imageDic[remoteMazeTitle[indexPath.item]]!,
                           position: rect, viewController: self)
        }
        let image = UIImageView()
        image.frame = rect
        if switcher.currentIndex == 0 {
            image.image = imageDic[localMazeTitle[indexPath.item]]
        } else {
            image.image = imageDic[remoteMazeTitle[indexPath.item]]
        }
        let topPanel = UIImageView(image: UIImage(named: "top_panel"))
        topPanel.frame = rect
        topPanel.alpha = 0
        self.view.addSubview(topPanel)
        self.view.addSubview(image)
        UIView.animateWithDuration(0.5, animations: {
            image.frame = CGRect(x: 0, y: 64, width: 1024, height: 704)
            topPanel.frame = CGRect(x: 0, y: 0, width: 1024, height: 64)
            topPanel.alpha = 1
        }) { (res) in
            image.removeFromSuperview()
            topPanel.removeFromSuperview()
            self.navigationController?.pushViewController(vc, animated: false)
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func switcher(switcher: DynamicMaskSegmentSwitch, didSelectAtIndex index: Int) {
        print(index)
        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        tableView.reloadData()
        localDoge.hidden = true
        remoteDoge.hidden = true
        UIView.setAnimationsEnabled(true)
        if self.switcher.currentIndex == 0 {
            refreshBtn.enabled = false
            if localMazeTitle.count == 0 {
                localDoge.hidden = false
            }
        } else {
            refreshBtn.enabled = true
            if remoteMazeTitle.count == 0 {
                remoteDoge.hidden = false
            }
        }
    }

}
