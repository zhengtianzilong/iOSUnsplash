//
//  ProfileViewController.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/6.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var photo:Photo!
    var profileImage:UIImage!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    
    @IBOutlet weak var protfolioName: UIButton!{
        didSet{
            
            protfolioName.addTarget(self, action: #selector(webLoad), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var portfolioImage: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var photoURLs = [String]()
    fileprivate var photoCache = NSCache<NSString,UIImage>()
    fileprivate var personalPhotos = [Photo]()
    fileprivate var downloadedPersonalPhotos = [UIImage?]()
    fileprivate var totalPhotosCount:Int = 0
    fileprivate var currentPage = 1
    fileprivate var loadingView:LoadingView!{
        
        didSet{
            loadingView.frame = collectionView.bounds
            loadingView.frame.size.width = self.view.frame.size.width
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.image = profileImage
        userLabel.text = photo.name
        bioLabel.text = photo.bio
        
        if photo.location != "" {
            locationLabel.text = photo.location
        }else{
            locationLabel.text = "No Location"
        }
        
        if (photo.profileImageURL?.contains("instagram.com"))! {
            protfolioName.setImage(#imageLiteral(resourceName: "instagram"), for: UIControlState.normal)
            let instagramNmae = photo.portfolioURL.components(separatedBy: "/")
            protfolioName.setTitle(instagramNmae[3], for: UIControlState.normal)
            
        }else{
            protfolioName.setImage(#imageLiteral(resourceName: "portfolio"), for: UIControlState.normal)
            protfolioName.setTitle("Website", for: UIControlState.normal)
        }
        
        loadingView = LoadingView()
        collectionView.addSubview(loadingView)
        
        load()
        
    }
    
    func webLoad(){
        
        performSegue(withIdentifier: "PortolioSegue", sender: self)
        
    }
    
    func load(with page:Int = 1) {
        
        let urlString = Constants.Base.UnsplashAPI + "/users/\(photo.userName)/photos"
        
        let url = URL(string: urlString)
        
        NetworkService.request(
            url: url!,
            method: .GET,
            parameters: [Constants.Parameters.ClientID as Dictionary<String,AnyObject>,["page":page] as Dictionary<String,AnyObject>],
            headers: nil) { (jsonData) -> (Void) in
                guard let data = jsonData as? [Dictionary<String,AnyObject>] else{
                    
                    return
                }
                
                let firstData = data[0]
                if let user = firstData["user"] as? [String:AnyObject],
                let totalPhotos = user["total_photos"] as? Int{
                    
                    self.totalPhotosCount = totalPhotos
                    
                }
                
                OperationService.parseJsonWithPhotoData(jsonData as! [Dictionary<String, AnyObject>], completion: { (photo) in
                    
                    self.personalPhotos.append(photo)
                    self.downloadedPersonalPhotos.append(nil)
                    
                })
            
                OperationQueue.main.addOperation {
                    
                    self.collectionView.reloadData()
                    self.loadingView.removeFromSuperview()
                }
        }
        
        
        
    }
    
    
}


extension ProfileViewController:UICollectionViewDataSource,UICollectionViewDelegate{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return personalPhotos.count;
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonalPhoto", for: indexPath) as! ProfileCollectionViewCell;
        cell.personalPhotoImageView.image = nil
        let photo = personalPhotos[indexPath.row]
        
        
        if let photoUrl = photo.imageURL, let url = URL(string: photo.imageURL!) {
            
            if let photoImageCache = self.photoCache.object(forKey: photoUrl as NSString){
                
                cell.personalPhotoImageView.image = photoImageCache
                
            }else{
                NetworkService.image(with: url) { (image) in
                    self.photoCache.setObject(image, forKey: photoUrl as NSString)
                   
                    if let updateCell = collectionView.cellForItem(at: indexPath) as? ProfileCollectionViewCell{
                        
                        updateCell.personalPhotoImageView.image = image
                    }
                }
            }
        }
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "PhotoSegue", sender: self);
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == personalPhotos.count - 1 && indexPath.row != totalPhotosCount - 1{
            
            currentPage += 1
            
            load(with: currentPage)
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PhotoSegue" {
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?[0].row,
                let destinationViewController = segue.destination as? PersonalPhotoViewController
            {
             destinationViewController.photo = personalPhotos[selectedIndexPath]
                destinationViewController.personalPhoto = downloadedPersonalPhotos[selectedIndexPath]
                
                if let photosTableViewController = navigationController?.viewControllers[0] as? PhotosTableViewController {
                    destinationViewController.delegate = photosTableViewController
                }
 
                
            }
        }else if segue.identifier == "PortolioSegue"{
            if let destinationViewController = segue.destination as? PortfolioWebViewController {
                
                destinationViewController.navigationItem.title = "\(photo.name)'s website"
                destinationViewController.portfolioURL = photo.portfolioURL
                
            }
            
            
        }
        
    }
    
}




extension ProfileViewController:UICollectionViewDelegateFlowLayout{
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height);
        
    }
    
}











