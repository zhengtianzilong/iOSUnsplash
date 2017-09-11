//
//  PersonalPhotoViewController.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/6.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import UIKit

protocol PersonalPhotoViewControllerDelegate :class {
    
    func heartButtonDidPressed(with photoID:String,isLike:Bool,heartCount:Int)
    
}

class PersonalPhotoViewController: UIViewController {
    
    private let emoji: Array = ["🗾", "🎑", "🏞", "🌅", "🌄", "🌠", "🎇", "🎆", "🌇", "🌆", "🏙", "🌃", "🌌", "🌉", "🌁"]
    
    @IBOutlet weak var personalPhotoImageView: UIImageView!
    
    @IBOutlet weak var heartButton: UIButton!
    
    @IBOutlet weak var heartCountLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var statisticsButton: UIButton!
    
    @IBOutlet weak var exifButton: UIButton!
    
    
    @IBOutlet weak var savePhotoLabel: UILabel!
    
    
    
    weak var delegate:PersonalPhotoViewControllerDelegate?
    var exifView:ExifView?
    var statisticsView:StatisticsView?
    var personalPhoto:UIImage?
    var photo:Photo!
    
    fileprivate var exifInfo:Exif?
    fileprivate var statisticsInfo:Statistics?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let downloadedImage = personalPhoto {
            personalPhotoImageView.image = downloadedImage
        }else{
            personalPhotoImageView.image = nil
        
            let imageUrl = URL(string: photo.imageURL!)
            NetworkService.image(with: imageUrl, completion: { (image) in
                
                self.personalPhoto = image
                self.personalPhotoImageView.image = image
                
            })
            
        }
        
        photo.isLike ? heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-liked"), for: .normal) : heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-outline"), for: .normal)
        heartCountLabel.text = String(photo.heartCount)
        savePhotoLabel.alpha = 0

        load()
        
    }
    
    
    private func load() {
        
        let statisticsURL = URL(string: Constants.Base.UnsplashAPI + "/photos/" + photo.id + "/stats")!
        
        NetworkService.request(url: statisticsURL, method: .GET, parameters: [Constants.Parameters.ClientID as Dictionary<String, AnyObject>], headers: nil) { (jsonData) -> (Void) in
            
            OperationService.parseJsonWithStatisticsData(jsonData as! Dictionary<String, AnyObject>, completion: { (info) in
                
                self.statisticsInfo = info
                
            })
            
        }
        
        
        let exifURL = URL(string: Constants.Base.UnsplashAPI + "/photos/" + photo.id)!
        
        NetworkService.request(url: exifURL, method: NetworkService.HTTPMethod.GET,
                               parameters: [Constants.Parameters.ClientID as Dictionary<String, AnyObject>]) { jsonData in
                                OperationService.parseJsonWithExifData(jsonData as! Dictionary<String, AnyObject>) { exifInfo in
                                    self.exifInfo = exifInfo
                                }
                                
        }
        
        
    }
    
    
    /// 点击下载
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func downloadButtonPressed(_ sender: Any) {
        
        guard personalPhoto != nil else {
            
            return
            
        }
        
        UIImageWriteToSavedPhotosAlbum(personalPhoto!, self, #selector(save(_:didFinishSavingWithError:contextInfo:)), nil)
        
        
        
        
    }
    
    @objc private func save(_ image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:UnsafeRawPointer){
        
        savePhotoLabel.isHidden = false
        
        if let error = error {
            savePhotoLabel.text =  "Save photo failed"
            print(error.localizedDescription)
        } else {
             savePhotoLabel.text = "\(emoji.randomItem())"+"Photo saved"
            savePhotoLabel.transform = CGAffineTransform(translationX: -20, y: -20)
            
            UIView.animate(withDuration: 1, animations: { 
                self.savePhotoLabel.alpha = 1
                self.savePhotoLabel.transform = CGAffineTransform.identity
            }, completion: { (_) in
                
                delay(1, completion: { 
                    
                    UIView.animate(withDuration: 1, animations: { 
                        self.savePhotoLabel.alpha = 0
                        self.savePhotoLabel.transform = CGAffineTransform(translationX: 20, y: 20)
                    })
                    
                })
                
            })
            
            
           
        }
        
        delay(2.0){
            
            self.savePhotoLabel.isHidden = true
            
        }
        
        
    }
    @IBAction func shareButtonDidPressed(_ sender: Any) {
        
        let shareImage:UIImage = personalPhotoImageView.image!
        
        let activityItems = [shareImage] as [Any]
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            activityViewController.popoverPresentationController?.sourceView = self.view
            
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func statisticsButtonPressed(_ sender: Any) {
        
        if statisticsView == nil {
            if exifView != nil {
                exifButton.setBackgroundImage(#imageLiteral(resourceName: "camera"), for: UIControlState.normal)
                exifView?.removeFromSuperview()
                exifView = nil
            }
            
            statisticsButton.setBackgroundImage(#imageLiteral(resourceName: "statistics-on"), for: UIControlState.normal)
            
            if let view = UIView.load(from: "Statistics", with: personalPhotoImageView.bounds) as? StatisticsView {
                
                statisticsView = view
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                guard statisticsInfo != nil else {
                    return
                }
                statisticsView!.downloadsLabel.text = numberFormatter.string(from: statisticsInfo!.downloads as NSNumber)
                statisticsView!.viewsLabel.text = numberFormatter.string(from: statisticsInfo!.views as NSNumber)
                statisticsView!.likesLabel.text = numberFormatter.string(from: statisticsInfo!.likes as NSNumber)
                personalPhotoImageView.addSubview(statisticsView!)
            }
        }else{
            statisticsButton.setBackgroundImage(#imageLiteral(resourceName: "statistics"), for: UIControlState.normal)
            statisticsView?.removeFromSuperview()
            statisticsView = nil
        }
    }
    
    
    /// 点击照相机
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func exifButtonPressed(_ sender: Any) {
        
        if exifView == nil {
            
            if statisticsView != nil {
                statisticsView?.removeFromSuperview()
                statisticsButton.setBackgroundImage(#imageLiteral(resourceName: "statistics"), for: .normal)
                statisticsView = nil
                
            }
            exifButton.setBackgroundImage(#imageLiteral(resourceName: "camera-on"), for: .normal)
            if let view = UIView.load(from: "ExifView", with: personalPhotoImageView.bounds) as? ExifView {
                
                exifView = view;
                
                
                guard exifInfo != nil else { return }
                
                let dateTime = exifInfo!.createTime.components(separatedBy: "T")[0]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: dateTime)
                dateFormatter.dateStyle = .long
                let createDate = dateFormatter.string(from: date!)
                exifView!.createdTimeLabel.text = createDate
                
                exifView!.dimensionsLabel.text = "\(exifInfo!.width) x \(exifInfo!.height)"
                exifView!.makeLabel.text = exifInfo!.make
                exifView!.modelLabel.text = exifInfo!.model
                exifView!.apertureLabel.text = exifInfo!.aperture
                exifView!.exposureTimeLabel.text = exifInfo!.exposureTime
                exifView!.focalLengthLabel.text = exifInfo!.focalLength
                exifView!.isoLabel.text = "\(exifInfo!.iso)"
                
                personalPhotoImageView .addSubview(exifView!)
            }

        }else{
            exifButton.setBackgroundImage(#imageLiteral(resourceName: "camera"), for: UIControlState.normal)
            exifView?.removeFromSuperview()
            exifView = nil
            
            
        }
        
    }
    
    
    @IBAction func heartButtonDidPressed(_ sender: Any) {
        
        if let token = Token.getToken() {
            let url = URL(string: Constants.Base.UnsplashAPI + "/photos/" + photo.id + "/like")!
            
            if !photo.isLike {
                heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-liked"), for: .normal)
                heartCountLabel.text = "\(Int(heartCountLabel.text!)! + 1)"
                
                photo.isLike = !photo.isLike
                photo.heartCount = Int(heartCountLabel.text!)!
                
                delegate?.heartButtonDidPressed(with: photo.id, isLike: photo.isLike, heartCount: photo.heartCount)
                
                NetworkService.request(url: url, method: NetworkService.HTTPMethod.POST, headers: ["Authorization": "Bearer " + token])
            } else {
                heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-outline"), for: .normal)
                heartCountLabel.text = "\(Int(heartCountLabel.text!)! - 1)"
                
                photo.isLike = !photo.isLike
                photo.heartCount = Int(heartCountLabel.text!)!
                
                delegate?.heartButtonDidPressed(with: photo.id, isLike: photo.isLike, heartCount: photo.heartCount)
                
                NetworkService.request(url: url, method: NetworkService.HTTPMethod.DELETE, headers: ["Authorization": "Bearer " + token])
            }
        } else {
            let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            present(loginViewController, animated: true)
        }

        
        
        
        
        
    }
    
    
    // 点击蒙版
    @IBAction func closeButtonPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
