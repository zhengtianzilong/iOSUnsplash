//
//  LikedPhotoCollectionViewCell.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/10.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import UIKit

class LikedPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var likedPhotoImageView: UIImageView!
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 3.0
        self.layer.shadowOffset = CGSize(width: 2, height: 4)
        
    }
    
    
}
