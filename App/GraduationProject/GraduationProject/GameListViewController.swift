//
//  GameListViewController.swift
//  GraduationProject
//
//  Created by altair21 on 16/5/12.
//  Copyright © 2016年 altair21. All rights reserved.
//

import UIKit

class GameListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DynamicMaskSegmentSwitchDelegate {
    var mazeTitle = Array<String>()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switcher: DynamicMaskSegmentSwitch!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var refreshSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configure = DynamicMaskSegmentSwitchConfigure(highlightedColor: .orangeColor(), normalColor: .whiteColor(), items: ["本地地图","服务器地图"])
        switcher.configure = configure
        switcher.delegate = self
        
        backBtn.layer.cornerRadius = 10.0
        refreshBtn.layer.cornerRadius = 10.0
        
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        mazeTitle = MazeFileManager.sharedManager.getLocalFilesList()
        MazeFileManager.sharedManager.getFileList({ (result) in
            if let JSON = result.value {
                if JSON["result"] as! String == "success" {
                    let tempArr: Array<String> = JSON["files"] as! Array
                    for title in tempArr {
                        if !self.mazeTitle.contains(title) {
                            MazeFileManager.sharedManager.download(title)
                        }
                    }
                    self.mazeTitle = self.mazeTitle + tempArr
                    
                    //去重，原谅我用这么奇怪的姿势
                    let tempSet = Set(self.mazeTitle)
                    self.mazeTitle = Array(tempSet)
                    
                    self.tableView.reloadData()
                }
//                print("JSON: \(JSON)")
            }
        }) { (error) in
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshSwitchChanged(sender: UISwitch) {
    }
    
    @IBAction func refreshBtnTapped(sender: UIButton) {
    }
    
    @IBAction func backBtnTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mazeTitle.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellGameListTableViewCell) as! GameListTableViewCell
        cell.titleLabel.text = mazeTitle[indexPath.item]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        MazeFileManager.sharedManager.getLocalFilesList()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(storyboardGameViewController) as! GameViewController
        vc.setMazeFile(MazeFileManager.sharedManager.getFileFullPath(self.mazeTitle[indexPath.item], isLocalFile: true))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func switcher(switcher: DynamicMaskSegmentSwitch, didSelectAtIndex index: Int) {
        print(index)
    }

}
