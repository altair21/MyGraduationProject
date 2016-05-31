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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView() {
        let previewZone = UIView(frame: CGRect(x: 40, y: 0, width: 640, height: 440))
        let previewZoneBG = UIImageView(image: UIImage(named: "background"))
        previewZoneBG.frame = previewZone.frame
        previewZone.addSubview(previewZoneBG)
        BGView.addSubview(previewZone)
    }
    
}
