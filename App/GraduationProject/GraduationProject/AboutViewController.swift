//
//  AboutViewController.swift
//  GraduationProject
//
//  Created by altair21 on 16/5/11.
//  Copyright © 2016年 altair21. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var backBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        backBtn.layer.cornerRadius = vMenuBtnCornerRadius
    }

    @IBAction func backBtnTapped(sender: UIButton) {
        UIView.transitionWithView(self.navigationController!.view, duration: 0.75, options: .TransitionFlipFromLeft, animations: { 
            self.navigationController?.popViewControllerAnimated(false)
        }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
