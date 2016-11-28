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
    var filePath: String?
    var fileName: String?
    weak var superView: GameListViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupView(fileName: String, filePath: String, superView: GameListViewController) {
        if self.fileName != nil && fileName == self.fileName {
            return
        } else {
            self.fileName = fileName
        }
        self.superView = superView
        self.previewZone = UIView(frame: CGRect(x: 40, y: 0, width: 1024, height: 704))
        self.BGView.alpha = 0
        previewZone.layer.shadowColor = UIColor.black.cgColor
        previewZone.layer.shadowOffset = CGSize(width: 4, height: 4)
        previewZone.layer.shadowOpacity = 0.8
        let previewZoneBG = UIImageView(image: UIImage(named: "background"))
        previewZoneBG.contentMode = .scaleToFill
        previewZoneBG.frame = CGRect(x: 0, y: 0, width: 1024, height: 704)
        DispatchQueue.main.async {
            for view in self.BGView.subviews {
                view.removeFromSuperview()
            }
            self.BGView.addSubview(self.previewZone)
            self.previewZone.addSubview(previewZoneBG)
        }
        if superView.imageDic[self.fileName!] == nil {
            self.loadLevel(filePath) {
                self.snapshot()
            }
        } else {
            replaceViewWithImage()
        }
    }
    
    func replaceViewWithImage() {
        DispatchQueue.main.async {
            for view in self.BGView.subviews {
                view.removeFromSuperview()
            }
            let imageView = UIImageView(image: self.superView.imageDic[self.fileName!])
            imageView.frame = CGRect(x: 0, y: 0, width: 1024, height: 704)
            self.BGView.addSubview(self.previewZone)
            self.previewZone.addSubview(imageView)
            self.previewZone.transform = CGAffineTransform(scaleX: 640 / 1024, y: 440 / 704).concatenating(CGAffineTransform(translationX: -192, y: -132))
            UIView.setAnimationsEnabled(true)
            UIView.animate(withDuration: 0.5, animations: {
                self.BGView.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func snapshot() {
        if superView.imageDic[self.fileName!] == nil {
            DispatchQueue.global(qos: .userInitiated).async(execute: {
                UIGraphicsBeginImageContextWithOptions(self.previewZone.bounds.size, false, 0.0)
                self.previewZone.layer.render(in: UIGraphicsGetCurrentContext()!)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                self.superView.imageDic[self.fileName!] = image
                self.replaceViewWithImage()
            })
        }
    }
    
    func loadLevel(_ filePath: String, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let levelString = try? String(contentsOfFile: filePath) {
                var textures: [UIImageView] = []
                let lines = levelString.components(separatedBy: "\n")
                
                for (row, line) in lines.reversed().enumerated() {
                    for (column, letter) in line.characters.enumerated() {
                        let position = CGPoint(x: vTextureLength * column,
                                               y: vTextureLength * (21 - row))
                        
                        let texture = UIImageView()
                        texture.frame = CGRect(x: position.x,
                                               y: position.y,
                                               width: CGFloat(vTextureLength),
                                               height: CGFloat(vTextureLength))
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
                        textures.append(texture)
                    }
                }
                DispatchQueue.main.async(execute: {
                    for texture in textures {
                        self.previewZone.addSubview(texture)
                    }
                })
            }
            DispatchQueue.main.async {
                UIView.setAnimationsEnabled(true)
                completion()
            }
        }
    }
    
}
