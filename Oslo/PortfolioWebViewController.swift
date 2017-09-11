//
//  PortfolioWebViewController.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/9.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import UIKit

class PortfolioWebViewController: UIViewController,UIWebViewDelegate{
    
    @IBOutlet weak var portfolioWebView: UIWebView!
    
    var portfolioURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        portfolioWebView.delegate = self
        
        if let requestURL = URL(string: portfolioURL){
            let request = URLRequest(url: requestURL)
            portfolioWebView.loadRequest(request)
        }
        
      

    }
    
    
}
