//
//  Exif.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/9.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import Foundation
struct Exif {
    let createTime: String
    let width: Int
    let height: Int
    let make: String
    let model: String
    let aperture: String
    let exposureTime: String
    let focalLength: String
    let iso: Int
    
    init(createTime: String,
         width: Int, height: Int,
         make: String,
         model: String,
         aperture: String,
         exposureTime: String,
         focalLength: String,
         iso: Int) {
        self.createTime = createTime
        self.width = width
        self.height = height
        self.make = make
        self.model = model
        self.aperture = aperture
        self.exposureTime = exposureTime
        self.focalLength = focalLength
        self.iso = iso
    }
}
