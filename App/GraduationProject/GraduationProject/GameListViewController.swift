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
        remoteMazeTitle = MazeFileManager.sharedManager.getLocalFilesList(isLocalDir: false)
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
            refreshRemoteFile()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshRemoteFile() {
        MazeFileManager.sharedManager.getFileList({ (result) in
            if let JSON = result.value {
                if JSON["result"] as! String == "success" {
                    let tempArr: Array<String> = JSON["files"] as! Array
                    for title in tempArr {
                        if !self.localMazeTitle.contains(title) {
                            self.remoteMazeTitle.append(title)
                            MazeFileManager.sharedManager.download(title)
                        }
                    }
                    
                    //去重，原谅我用这么奇怪的姿势
                    let tempSet = Set(self.remoteMazeTitle)
                    self.remoteMazeTitle = Array(tempSet)
                    
                    self.tableView.reloadData()
                }
//                print("JSON: \(JSON)")
            }
        }) { (error) in
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
        refreshRemoteFile()
    }
    
    @IBAction func backBtnTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let myCell = cell as! GameListTableViewCell
        myCell.showPreviewZone()
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let myCell = cell as! GameListTableViewCell
        myCell.previewZone.alpha = 0.1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellGameListTableViewCell) as! GameListTableViewCell
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
        if switcher.currentIndex == 0 {
            cell.setupView(MazeFileManager.sharedManager.getFileFullPath(self.localMazeTitle[indexPath.item], isLocalFile: true))
        } else {
            cell.setupView(MazeFileManager.sharedManager.getFileFullPath(self.remoteMazeTitle[indexPath.item], isLocalFile: false))
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(storyboardGameViewController) as! GameViewController
        if switcher.currentIndex == 0 {
            vc.setMazeFile(MazeFileManager.sharedManager.getFileFullPath(self.localMazeTitle[indexPath.item], isLocalFile: true))
        } else {
            vc.setMazeFile(MazeFileManager.sharedManager.getFileFullPath(self.remoteMazeTitle[indexPath.item], isLocalFile: false))
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func switcher(switcher: DynamicMaskSegmentSwitch, didSelectAtIndex index: Int) {
        print(index)
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
