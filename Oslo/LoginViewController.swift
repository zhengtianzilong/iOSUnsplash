//
//  LoginViewController.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/6.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginWebView: UIWebView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBAction func backButtonDidPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil);
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let authorizationURL = NetworkService.parse(URL(string: Constants.Base.UnsplashURL + Constants.Base.Authorize)!, with: [
            Constants.Parameters.ClientID as Dictionary<String, AnyObject>,
            Constants.Parameters.ResponseType as Dictionary<String, AnyObject>,
            Constants.Parameters.RedirectURI as Dictionary<String, AnyObject>,
            Constants.Parameters.Scope as Dictionary<String, AnyObject>
            ])

        let request = URLRequest(url: authorizationURL)
        loginWebView.delegate = self
        loginWebView.loadRequest(request)
    }
    
    
}

extension LoginViewController:UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let absoluteURL = request.url?.absoluteString
        
        if (absoluteURL?.contains("oslo://photos"))! {
            
            let code = absoluteURL?.components(separatedBy: "=")[1]
            
            NetworkService.request(
                url: URL(string: Constants.Base.UnsplashURL + Constants.Base.Token)!,
                method: .POST,
                parameters: [Constants.Parameters.ClientID as Dictionary<String, AnyObject>,
                             Constants.Parameters.ClientSecret as Dictionary<String, AnyObject>,
                             Constants.Parameters.RedirectURI as Dictionary<String, AnyObject>,
                             ["code": code as AnyObject],
                             Constants.Parameters.GrantType as Dictionary<String, AnyObject>
                             ],
                headers: nil,
                completion: { (jsonData) -> (Void) in
                    let accessToken = jsonData["access_token"] as! String
                    Token.saveToken(accessToken)
                    self.dismiss(animated: true, completion: nil)
                                
            })
            
            return false
        }
        return true
        
        
    }
    
    
    
}

