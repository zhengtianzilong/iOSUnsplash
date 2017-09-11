//
//  MeViewController.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/9.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import UIKit

protocol  PassDateDelegate:class {
    func pass(userName:String,photosCount:Int)
    
    func pass(width:CGFloat)
    
}

class MeViewController: UIViewController {

    fileprivate var userName = ""
    fileprivate var publishedTotalCount: Int = 0
    fileprivate var likedTotalCount: Int = 0
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
   
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var likedPhotoContainerView: UIView!
    
    @IBOutlet weak var publishedPhotoContainerView: UIView!
    
    
    weak var publishedPhotosdelegate:PassDateDelegate?
    
    weak var likedPhotosdelegate:PassDateDelegate?
    
    
    /// 点击segment时候触发的方法
    @IBAction func segmentedControlDidChange(_ sender: Any) {
        
        for subview in segmentedControl.subviews {
            if let bottomBorderLayer = subview.layer.sublayers?.filter({$0.name == "bottomBorder"}) {
                
                for layer in bottomBorderLayer {
                    layer.removeFromSuperlayer()
                }
                
            }
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
            generateSelectedBorder(under: segmentedControl.subviews[0])
            publishedPhotoContainerView.isHidden = false
            likedPhotoContainerView.isHidden = true
        }else{
            generateSelectedBorder(under: segmentedControl.subviews[1])
            publishedPhotoContainerView.isHidden = true
            likedPhotoContainerView.isHidden = false
            
        }
    }
    
    
    /// 点击退出登录按钮
    @IBAction func logoutButtonDidPressed(_ sender: Any) {
        
        let alertViewController = UIAlertController(title: localize(with: "Logout"), message: localize(with: "Logout intro"), preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: localize(with: "Logout action title"), style: .default) { (action) in
            
            Token.removeToken()
            
            self.navigationController?.popToRootViewController(animated: true)
            
        }
        
        let cancel = UIAlertAction(title: localize(with: "Logout cancel title"), style: .cancel, handler: nil)
        
        alertViewController.addAction(confirm)
        alertViewController.addAction(cancel)
        
        present(alertViewController, animated: true, completion: nil)

    }
    
    /// 跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PublishedPhotosSegue" {
            
            if let destinationViewController = segue.destination as? PublishedPhotosCollectionViewController  {
                
                publishedPhotosdelegate = destinationViewController
                
            }
            
        }else if segue.identifier == "LikedPhotosSegue"{
            if let destinationViewController = segue.destination as? LikedPhotosCollectionViewController {
                likedPhotosdelegate = destinationViewController
            }
        
    }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        likedPhotosdelegate?.pass(width: self.view.frame.width * 0.56)
        publishedPhotosdelegate?.pass(width: self.view.frame.width * 0.56)
        
        segmentedControl.setDividerImage(generateSegmentedControlImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        segmentedControl.setBackgroundImage(generateSegmentedControlImage(), for: .normal, barMetrics: .default)
        
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.red], for: .normal)
        
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blue], for: .selected)
        generateSelectedBorder(under: segmentedControl.subviews[0])
        
        likedPhotoContainerView.isHidden = true
        
        let url = URL(string: Constants.Base.UnsplashAPI + Constants.Base.Me)!
        
        NetworkService.request(url: url, method: .GET, parameters: nil, headers: ["Authorization": "Bearer " + Token.getToken()!]) { (jsonData) -> (Void) in
            if let profileImage = jsonData["profile_image"] as? [String: AnyObject],
                let largeProfileImage = profileImage["large"] as? String {
                let largeProfileImageURL = URL(string: largeProfileImage)!
                NetworkService.image(with: largeProfileImageURL) { image in
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
            
            if let name = jsonData["name"] as? String {
                DispatchQueue.main.async {
                    self.nameLabel.text = name
                }
            }
            
            if let bio = jsonData["bio"] as? String {
                DispatchQueue.main.async {
                    self.bioLabel.text = bio
                }
            }
            
            if let publishedPhotosCount = jsonData["total_photos"] as? Int {
                self.publishedTotalCount = publishedPhotosCount
                
                DispatchQueue.main.async {
                    self.segmentedControl.setTitle(localizedFormat(with: "Published count", and: "\(publishedPhotosCount)"), forSegmentAt: 0)
                }
            }
            
            if let likededPhotosCount = jsonData["total_likes"] as? Int {
                self.likedTotalCount = likededPhotosCount
                
                DispatchQueue.main.async {
                    self.segmentedControl.setTitle(localizedFormat(with: "Liked count", and: "\(likededPhotosCount)"), forSegmentAt: 1)
                }
            }
            
            if let userName = jsonData["username"] as? String {
                self.title = userName
                self.userName = userName
                
                self.publishedPhotosdelegate?.pass(userName: userName, photosCount: self.publishedTotalCount)
                self.likedPhotosdelegate?.pass(userName: userName, photosCount: self.likedTotalCount)
            }
            
            
        }
        
        
        
    }

    
    /// 生成一个宽度为1 高度为SegmentedControl的白色图片
    private func generateSegmentedControlImage() ->UIImage{
        let rectangle = CGRect(x: 0, y: 0, width: 1, height: segmentedControl.frame.height)
        UIGraphicsBeginImageContext(rectangle.size)
        
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.addRect(rectangle)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    /// 生成一个横条
    ///
    /// - Parameter view: <#view description#>
    private func generateSelectedBorder(under view:UIView){
        if segmentedControl.selectedSegmentIndex == 0 {
            
            let bottomBorder = CALayer()
            bottomBorder.name = "bottomBorder"
            bottomBorder.frame = CGRect(x: -view.center.x / 2.5, y: view.frame.size.height + 2, width: 13, height: 1)
            bottomBorder.backgroundColor = UIColor.black.cgColor
            view.layer.addSublayer(bottomBorder)
        }else{
            
            let bottomBorder = CALayer()
            bottomBorder.name = "bottomBorder"
            bottomBorder.frame = CGRect(x: view.center.x * 3, y: view.frame.size.height + 2, width: 13, height: 1)
            bottomBorder.backgroundColor = UIColor.black.cgColor
            view.layer.addSublayer(bottomBorder)
            
        }
        
        
        
    }

    
}
