//
//  GameListTableViewCell.swift
//  GraduationProject
//
//  Created by altair21 on 16/5/12.
//  Copyright © 2016年 altair21. All rights reserved.
//

import UIKit

class GameListTableViewCell: UITableViewCell {
    @IBOutlet weak var BGView: UIView!
    var previewZone: UIView!
    var _filePath: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(filePath: String) {
        if _filePath != nil && filePath == _filePath {
            return
        } else {
            _filePath = filePath
        }
        self.previewZone = UIView(frame: CGRect(x: 40, y: 0, width: 640, height: 440))
        self.previewZone.alpha = 0
//            previewZone.layer.shadowColor = UIColor.blackColor().CGColor
//            previewZone.layer.shadowOffset = CGSize(width: 4, height: 4)
//            previewZone.layer.shadowOpacity = 0.8
        let previewZoneBG = UIImageView(image: UIImage(named: "background"))
        previewZoneBG.frame = CGRect(x: 0, y: 0, width: 640, height: 440)
        dispatch_async(dispatch_get_main_queue()) {
            for view in self.BGView.subviews {
                view.removeFromSuperview()
            }
            self.BGView.addSubview(self.previewZone)
            self.previewZone.addSubview(previewZoneBG)
        }
        self.loadLevel(filePath) {
        }
    }
    
    func loadLevel(filePath: String, completion: () -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            if let levelString = try? String(contentsOfFile: filePath, usedEncoding: nil) {
                let lines = levelString.componentsSeparatedByString("\n")
                
                for (row, line) in lines.reverse().enumerate() {
                    for (column, letter) in line.characters.enumerate() {
                        let position = CGPoint(x: vPreviewTextureLength * column,
                                               y: vPreviewTextureLength * (21 - row))
                        
                        let texture = UIImageView()
                        texture.frame = CGRect(x: position.x,
                                               y: position.y,
                                               width: CGFloat(vPreviewTextureLength),
                                               height: CGFloat(vPreviewTextureLength))
                        switch letter {
                        case "1":
                            texture.image = UIImage(named: "spring_node_1")
                        case "2":
                            texture.image = UIImage(named: "spring_node_2")
                        case "3":
                            texture.image = UIImage(named: "spring_node_3")
                        case "4":
                            texture.image = UIImage(named: "spring_node_4")
                        case "x":
                            texture.image = UIImage(named: "block")
                        case "v":
                            texture.image = UIImage(named: "vortex")
                        case "s":
                            texture.image = UIImage(named: "star")
                        case "f":
                            texture.image = UIImage(named: "finish")
                        case "p":
                            texture.image = UIImage(named: "player")
                        default: break
                            
                        }
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.previewZone.addSubview(texture)
                        })
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            UIView.setAnimationsEnabled(true)
            completion()
        }
    }
    
}
