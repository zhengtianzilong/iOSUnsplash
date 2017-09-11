//
//  StatisticsView.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/6.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import UIKit

class StatisticsView: UIView {
    
    @IBOutlet var downloadsTitleLabel: UILabel! {
        didSet {
            downloadsTitleLabel.text = localize(with: "Downloads")
        }
    }
    @IBOutlet weak var downloadsLabel: UILabel!
    @IBOutlet var viewsTitleLabel: UILabel! {
        didSet {
            viewsTitleLabel.text = localize(with: "Views")
        }
    }
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet var likesTitleLabel: UILabel! {
        didSet {
            likesTitleLabel.text = localize(with: "Likes")
        }
    }
    @IBOutlet var likesLabel: UILabel!
}
