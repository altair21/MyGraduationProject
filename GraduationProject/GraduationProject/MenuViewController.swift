//
//  MenuViewController.swift
//  GraduationProject
//
//  Created by altair21 on 16/5/11.
//  Copyright © 2016年 altair21. All rights reserved.
//

import UIKit

let vMenuBtnCornerRadius: CGFloat = 25.0
class MenuViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var makeMapBtn: UIButton!
    @IBOutlet weak var aboutBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = true
        titleLabel.font = UIFont(name: "GoodDog Cool", size: 100.0)
        startBtn.layer.cornerRadius = vMenuBtnCornerRadius
        makeMapBtn.layer.cornerRadius = vMenuBtnCornerRadius
        aboutBtn.layer.cornerRadius = vMenuBtnCornerRadius
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
