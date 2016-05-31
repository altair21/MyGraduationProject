//
//  GlobalFile.swift
//  GraduationProject
//
//  Created by altair21 on 16/5/12.
//  Copyright © 2016年 altair21. All rights reserved.
//

import Foundation
import UIKit

let serverAddress = "http://120.27.100.126:8080/"
let vTextureLength = 32
let vPreviewTextureLength = 20
let vMenuBtnCornerRadius: CGFloat = 25.0

let storyboardGameViewController = "GameViewController"

let cellGameListTableViewCell = "GameListTableViewCell"

enum TextureType: String {
    case Player = "player"
    case Wall = "wall"
    case Vortex = "vortex"
    case Star = "star"
    case Finish = "finish"
    case Spring = "spring"  //占位
}

struct PhysicsCategory {
    static let None:   UInt32 = 0
    static let Player: UInt32 = 0b1 //1
    static let Wall:   UInt32 = 0b10 //2
    static let Star:   UInt32 = 0b100 //4
    static let Vortex: UInt32 = 0b1000 //8
    static let Finish: UInt32 = 0b10000 //16
    static let Spring: UInt32 = 0b100000 //32
}

func showCenterToast(str: String) {
    UIView.currentView().makeToast(str, duration: 2.0, position: .Center)
}

