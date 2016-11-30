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
        
        let configure = DynamicMaskSegmentSwitchConfigure(highlightedColor: .orange, normalColor: .white, items: ["本地地图","服务器地图"])
        switcher.configure = configure
        switcher.delegate = self
        
        backBtn.layer.cornerRadius = 10.0
        refreshBtn.layer.cornerRadius = 10.0
        
        tableView.transform = CGAffineTransform(rotationAngle: -CGFloat(M_PI) / CGFloat(2))
        tableView.frame = CGRect(x: 0, y: 230, width: tableView.frame.size.width, height: tableView.frame.size.height)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        localMazeTitle = MazeFileManager.sharedManager.getLocalFilesList(isLocalDir: true)
        localMazeTitle.sort()
        remoteMazeTitle = MazeFileManager.sharedManager.getLocalFilesList(isLocalDir: false)
        remoteMazeTitle.sort()
        if switcher.currentIndex == 0 {
            if localMazeTitle.count == 0 {
                localDoge.isHidden = false
            }
        } else {
            if remoteMazeTitle.count == 0 {
                remoteDoge.isHidden = false
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
    
    func refreshRemoteFile(_ forceUpdate: Bool) {
        MazeFileManager.sharedManager.getFileList({ (result) in
            print(result.value!)
            if let JSON = result.value as! Dictionary<String, Any>? {
                if (((JSON["result"] != nil) && JSON["result"] as! String == "success") || ((JSON["code"] != nil) && JSON["code"] as! Int == 200)) {
                    let tempArr: Array<String> = JSON["files"] as! Array
                    var updateFlag = false
                    for title in tempArr {
                        if !self.localMazeTitle.contains(title) {
                            self.remoteMazeTitle.append(title)
                            updateFlag = true
                        }
                    }
                    
                    if forceUpdate {
                        showCenterToast("获取文件列表成功")
                    }
                    
                    //去重，原谅我用这么奇怪的姿势
                    let tempSet = Set(self.remoteMazeTitle)
                    self.remoteMazeTitle = Array(tempSet)
                    self.remoteMazeTitle.sort()
                    if updateFlag && self.switcher.currentIndex == 1 {
                        self.tableView.reloadData()
                    }
                    
                    if self.remoteMazeTitle.count > 0 {
                        if self.remoteDoge.isHidden == false {
                            UIView.animate(withDuration: 0.4, animations: {
                                self.remoteDoge.alpha = 0.0
                            }, completion: { _ in
                                self.remoteDoge.isHidden = true
                                self.remoteDoge.alpha = 1.0
                            })
                        }
                    }
                } else {
                    if forceUpdate {
                        showCenterToast("获取文件列表失败")
                    }
                }
                print("JSON: \(JSON)")
            }
        }) { (error) in
            if forceUpdate {
                showCenterToast("获取文件列表失败")
            }
            print(error)
        }
    }
    
    func shouldUpdateFile() -> Bool {
        if let res = UserDefaults.standard.object(forKey: kRefreshValueOnDisk) as? Bool{
            refreshSwitch.setOn(res, animated: false)
            return res
        } else {
            return refreshSwitch.isOn
        }
    }
    
    @IBAction func refreshSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(refreshSwitch.isOn, forKey: kRefreshValueOnDisk)
    }
    
    @IBAction func refreshBtnTapped(_ sender: UIButton) {
        refreshRemoteFile(true)
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        UIView.transition(with: self.navigationController!.view, duration: 0.6, options: [.transitionCurlUp, .curveEaseOut], animations: {
            _ = self.navigationController?.popViewController(animated: false)
            }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if switcher.currentIndex == 0 {
            return localMazeTitle.count
        } else {
            return remoteMazeTitle.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(720)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellGameListTableViewCell) as! GameListTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.contentView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI) / 2)
        if switcher.currentIndex == 0 {
            cell.setupView(fileName: self.localMazeTitle[(indexPath as NSIndexPath).item],
                           filePath: MazeFileManager.sharedManager.getFileFullPath(self.localMazeTitle[(indexPath as NSIndexPath).item], isLocalFile: true),
                           superView: self)
        } else {
            MazeFileManager.sharedManager.download(self.remoteMazeTitle[(indexPath as NSIndexPath).item], completion:  {
                cell.setupView(fileName: self.remoteMazeTitle[(indexPath as NSIndexPath).item],
                               filePath: MazeFileManager.sharedManager.getFileFullPath(self.remoteMazeTitle[(indexPath as NSIndexPath).item], isLocalFile: false),
                               superView: self)
            }, failure: {
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .middle)
                tableView.endUpdates()
            })
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let cell = tableView.cellForRow(at: indexPath) as! GameListTableViewCell
        cell.snapshot()
        let rect = cell.previewZone.convert(cell.previewZone.bounds, to: self.view)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardGameViewController) as! GameViewController
        let image = UIImageView()
        image.frame = CGRect(x: 0, y: 64, width: 1024, height: 704)
        image.transform = CGAffineTransform(scaleX: 640 / 1024, y: 440 / 704)
        image.center = CGPoint(x: rect.midX, y: rect.midY)
        
        let topPanel = UIImageView(image: UIImage(named: "top_panel"))
        topPanel.frame = CGRect(x: 0, y: 64, width: 1024, height: 64)
        topPanel.transform = CGAffineTransform(scaleX: 640 / 1024, y: 40 / 64)
        topPanel.center = CGPoint(x: rect.midX, y: rect.origin.y + 20)
        topPanel.alpha = 0
        
        self.view.addSubview(topPanel)
        self.view.addSubview(image)
        
        if switcher.currentIndex == 0 {
            vc.setMazeFile(MazeFileManager.sharedManager.getFileFullPath(self.localMazeTitle[(indexPath as NSIndexPath).item], isLocalFile: true), image: imageDic[localMazeTitle[(indexPath as NSIndexPath).item]]!,
                           position: rect, viewController: self)
            image.image = imageDic[localMazeTitle[(indexPath as NSIndexPath).item]]
        } else {
            vc.setMazeFile(MazeFileManager.sharedManager.getFileFullPath(self.remoteMazeTitle[(indexPath as NSIndexPath).item], isLocalFile: false), image: imageDic[remoteMazeTitle[(indexPath as NSIndexPath).item]]!,
                           position: rect, viewController: self)
            image.image = imageDic[remoteMazeTitle[(indexPath as NSIndexPath).item]]
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
            image.transform = CGAffineTransform.identity
            image.center = CGPoint(x: 512, y: 416)
            topPanel.transform = CGAffineTransform.identity
            topPanel.center = CGPoint(x: 512, y: 32)
            topPanel.alpha = 1
        }, completion: { _ in
            image.removeFromSuperview()
            topPanel.removeFromSuperview()
            self.navigationController?.pushViewController(vc, animated: false)
            UIApplication.shared.endIgnoringInteractionEvents()
        })
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func switcher(_ switcher: DynamicMaskSegmentSwitch, didSelectAtIndex index: Int) {
        print(index)
        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        tableView.reloadData()
        localDoge.isHidden = true
        remoteDoge.isHidden = true
        UIView.setAnimationsEnabled(true)
        if self.switcher.currentIndex == 0 {
            refreshBtn.isEnabled = false
            if localMazeTitle.count == 0 {
                localDoge.isHidden = false
            }
        } else {
            refreshBtn.isEnabled = true
            if remoteMazeTitle.count == 0 {
                remoteDoge.isHidden = false
            }
        }
    }

}
