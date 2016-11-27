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

    @IBAction func backBtnTapped(_ sender: UIButton) {
        UIView.transition(with: self.navigationController!.view, duration: 0.75, options: .transitionFlipFromLeft, animations: { 
            _ = self.navigationController?.popViewController(animated: false)
        }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
