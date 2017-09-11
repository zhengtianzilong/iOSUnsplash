//
//  PhotoTableViewCell.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/6.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import UIKit
protocol PhotoTableViewCellDelegate:class{
    
    func tapToPerformSegue(_ sender:Any)
    
    func heartButtonDidPressed(sender:Any,isLike:Bool,heartCount:Int)
    
}
class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!{
        didSet{
            if photoImageView.gestureRecognizers == nil {
                
                photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
                
            }
        }
    }

    @IBOutlet weak var userImageView: UIImageView!{
        didSet{
            if userImageView.gestureRecognizers == nil {
                
                userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
                
            }
        }
    }

    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var heartImageView: UIButton!
    
    @IBOutlet weak var heartCountLabel: UILabel!
    
    var isLike:Bool = false{
        
        didSet{
            
            isLike ? heartImageView.setBackgroundImage(UIImage(named:"heart-liked"), for: .normal) : heartImageView.setBackgroundImage(UIImage(named:"heart-outline"), for: .normal)
        }
        
    }
    
    var photoID:String = ""
    
    weak var delegate:PhotoTableViewCellDelegate?
    
    
    func tapped(_ sender:Any){
        
        if let tag = (sender as AnyObject).view?.tag {
            
            switch tag {
            case 0:
                delegate?.tapToPerformSegue(sender)
            case 1:
                delegate?.tapToPerformSegue(sender)
                
            default:break
            }
            
            
        }
    }
    
    @IBAction func heartButtonDidPressed(_ sender: Any) {
        if let token = Token.getToken() {
            let url = URL(string:Constants.Base.UnsplashAPI + "/photos/" + photoID + "/like")!
            
            if !isLike {
                
                isLike = !isLike
                heartCountLabel.text = "\(Int(heartCountLabel.text!)! + 1)"
                
                delegate?.heartButtonDidPressed(sender: sender, isLike: isLike, heartCount:  Int(heartCountLabel.text!)!)
                
                NetworkService.request(url: url, method:.POST, headers: ["Authorization": "Bearer " + token])
            }
        }else{
            delegate?.heartButtonDidPressed(sender: sender, isLike: isLike, heartCount: Int(heartCountLabel.text!)!)

        }
        
        
        
        
        
        
    }
    
}
