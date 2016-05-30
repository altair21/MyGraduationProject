//
//  GameListViewController.swift
//  GraduationProject
//
//  Created by altair21 on 16/5/12.
//  Copyright © 2016年 altair21. All rights reserved.
//

import UIKit

class GameListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var mazeTitle = Array<String>()
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        
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
        vc.setMazeFile(MazeFileManager.sharedManager.getFileFullPath(self.mazeTitle[indexPath.item]))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
