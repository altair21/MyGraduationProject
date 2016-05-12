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
        
        MazeFileManager.sharedManager.getFileList { response in
            if let JSON = response.result.value {
                if JSON["result"] as! String == "success" {
                    self.mazeTitle = JSON["files"] as! Array
                    self.tableView.reloadData()
                }
                print("JSON: \(JSON)")
            }
        }
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
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
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
