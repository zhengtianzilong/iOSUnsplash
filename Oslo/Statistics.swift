//
//  Statistics.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/9.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import Foundation
struct Statistics {
    let downloads: Int
    let views: Int
    let likes: Int
    
    init(downloads: Int, views: Int, likes: Int) {
        self.downloads = downloads
        self.views = views
        self.likes = likes
    }
}
