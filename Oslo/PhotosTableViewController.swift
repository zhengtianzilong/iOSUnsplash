//
//  PhotosTableViewController.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/6.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import UIKit



class PhotosTableViewController: UITableViewController {

    @IBOutlet weak var userBarButton: UIBarButtonItem!
    fileprivate var photos = [Photo]()
    fileprivate var personalPhotos = [UIImage?]()
    fileprivate var profileImages = [UIImage?]()
    fileprivate var photoCache = NSCache<NSString, UIImage>()
    lazy var feedRefreshControl: UIRefreshControl = {
        let feedRefreshControl = UIRefreshControl()
        feedRefreshControl.addTarget(self, action: #selector(load(with:)), for: UIControlEvents.valueChanged)
        
        self.loadingView = LoadingView()
        self.loadingView.frame.size.height = feedRefreshControl.frame.size.height
        
        feedRefreshControl.addSubview(self.loadingView)
        
        return feedRefreshControl
    }()
    
    fileprivate var currentPage = 1
    fileprivate var isPullUp:Bool = false
    fileprivate var loadingView:LoadingView!{
        
        didSet{
            loadingView.frame.origin = self.view.frame.origin
            loadingView.frame.size.width = self.view.frame.size.width
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if Token.getToken() != nil {
            
            userBarButton.tintColor = UIColor.red
        }else {
            userBarButton.tintColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
        }

        
    }
    
    @IBAction func userBarButtonDidPressed(_ sender: Any) {
        
        if Token.getToken() == nil {
            let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            present(loginViewController, animated: true, completion: nil)
            
        }else{
            let meViewController = storyboard?.instantiateViewController(withIdentifier: "MeViewController") as! MeViewController
            show(meViewController, sender: sender)
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        navigationItem.title = localize(with: "Feature")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        currentPage = 1
        
        // 判断是哪个平台
        if #available(iOS 10.0, *) {
            
            tableView.refreshControl = feedRefreshControl
            
        }else{
            tableView.addSubview(feedRefreshControl)
        }
        
        load()

    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return photos.count;
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width * 0.7;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photo = photos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Photo",for: indexPath ) as! PhotoTableViewCell;
        cell.delegate = self
        cell.photoImageView.image = nil
        cell.userImageView.image = nil
        
        if let photoImageURL = photo.imageURL,let photoURL = URL(string:photoImageURL) {
            
            if let cachedImage = self.photoCache.object(forKey: photoImageURL as NSString) {
                
                cell.photoImageView.image = cachedImage
                
            }else{
                
                NetworkService.image(with: photoURL, completion: { (image) in
                    self.photoCache.setObject(image, forKey: photoImageURL as NSString)
                    self.personalPhotos[indexPath.row] = image
                    if let updateCell = tableView.cellForRow(at: indexPath) as? PhotoTableViewCell {
//                        updateCell.photoImageView.alpha = 0
//                        UIView.animate(withDuration: 0.3, animations: { 
//                            updateCell.photoImageView.alpha = 1
//                            updateCell.photoImageView.image = image;
//                        })
                        
                        
                        updateCell.photoImageView.alpha = 1
                        updateCell.photoImageView.image = image;
                    }
                })
            }
        }

        if let profileImageURL = photo.profileImageURL, let userImageURL = URL(string:profileImageURL) {
            
            if let cachedImage = self.photoCache.object(forKey: profileImageURL as NSString) {
                
                cell.userImageView.image = cachedImage;
                
            }else{
                NetworkService.image(with: userImageURL, completion: { (image) in
                    self.photoCache.setObject(image, forKey: profileImageURL as NSString)
                    
                    self.profileImages[indexPath.row] = image
                    
                    if let updateCell = tableView.cellForRow(at: indexPath) as? PhotoTableViewCell {
                        updateCell.userImageView.image = image;
                        
                    }
                })
            }
        }
        cell.userLabel.text = photo.userName;
        cell.isLike = photo.isLike
        cell.heartCountLabel.text = "\(photo.heartCount)";
        cell.photoID = photo.id
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 && !isPullUp {
            isPullUp = true
            currentPage += 1
            load(with: currentPage)
            
        }
        
    }
    
    
    func load(with page:Int = 1) {
        
        var pageIndex = page

        feedRefreshControl.beginRefreshing()
        
        if !isPullUp{
            
            pageIndex = 1
            currentPage = 1
        }
        
        let url = URL(string: Constants.Base.UnsplashAPI + Constants.Base.Curated)
        
        NetworkService.request(url: url!, method: .GET, parameters:  [(Constants.Parameters.ClientID as Dictionary<String,AnyObject>),["page":pageIndex as AnyObject]], headers: nil) { (jsondata) -> (Void) in
           
            if(pageIndex == 1){
                 self.photos.removeAll()
                self.personalPhotos.removeAll()
                self.profileImages.removeAll()
            }
            
           
            OperationService.parseJsonWithPhotoData(jsondata as! [Dictionary<String, AnyObject>], completion: { (photo) in
                
                self.photos.append(photo)
                self.personalPhotos.append(nil)
                self.profileImages.append(nil)
                OperationQueue.main.addOperation {
                    self.feedRefreshControl.endRefreshing()
                    self.tableView.reloadData()
                    
                    self.isPullUp = false
                }
            })
        }
        
        
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        tableView .deselectRow(at: indexPath, animated: true);
        
    }
    
    func getCurrentCellRow(sender:Any?) -> Int? {
        
        if let sourceSender = sender as? UITapGestureRecognizer,
            let cellView = sourceSender.view?.superview?.superview
        {
            let selectedIndexPath = tableView.indexPath(for: cellView as! PhotoTableViewCell)?.row
            return selectedIndexPath
        }else{
            return nil
        }
        
    }
    
    
    
}



// MARK: - PhotoTableViewCellDelegate
extension PhotosTableViewController:PhotoTableViewCellDelegate{
    
    func tapToPerformSegue(_ sender: Any) {
        if let tag = (sender as AnyObject).view?.tag {
            
            switch tag {
            case 0:
                performSegue(withIdentifier: "PhotoSegue", sender: sender)
            case 1:
                performSegue(withIdentifier: "ProfileSegue", sender: sender)
            default:
                break
            }
            
        }
    }
    
    func heartButtonDidPressed(sender: Any, isLike: Bool, heartCount: Int) {
        
        if Token.getToken() != nil {
            if let selectedIndexPath = getCurrentCellRow(sender: sender) {
                photos[selectedIndexPath].isLike = isLike
                photos[selectedIndexPath].heartCount = heartCount
            }
        } else {
            let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            present(loginViewController, animated: true)
        }
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let selectedIndexPathRow = getCurrentCellRow(sender: sender) else { return  }
        
        if segue.identifier == "ProfileSegue" {
            
            if let destinationViewController = segue.destination as? ProfileViewController {
                destinationViewController.photo = self.photos[selectedIndexPathRow]
                destinationViewController.profileImage = self.profileImages[selectedIndexPathRow]
            }
            
        }else if segue.identifier == "PhotoSegue"{
            if let destinationViewController = segue.destination as? PersonalPhotoViewController {
                destinationViewController.photo = self.photos[selectedIndexPathRow]
                destinationViewController.personalPhoto = personalPhotos[selectedIndexPathRow]
            }
        }
    }
}

extension PhotosTableViewController:PersonalPhotoViewControllerDelegate{
    
    func heartButtonDidPressed(with photoID: String, isLike: Bool, heartCount: Int) {
        
        if let indexPathRow = photos.index(where: {$0.id == photoID}){
            photos[indexPathRow].isLike = isLike
            photos[indexPathRow].heartCount = heartCount
            
            let indexPath = IndexPath(row: indexPathRow, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
    
    
}

















