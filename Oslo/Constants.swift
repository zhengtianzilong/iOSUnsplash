//
//  Constants.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/7.
//  Copyright © 2017年 caizilong. All rights reserved.
//

struct Constants {
    
    struct Base {
        
        static let UnsplashURL = "https://unsplash.com"
        static let UnsplashAPI = "https://api.unsplash.com"
        static let Curated = "/photos/curated"
        static let Authorize = "/oauth/authorize"
        static let Token = "/oauth/token"
        static let Me = "/me"
        
    }
    
    struct Parameters {
        static let ClientID = ["client_id": "de3e9797b860a9e33e62daa098d29f0f03c8beba93b2719466fa83b969110c31"]
        static let ClientSecret = ["client_secret": "3e01403617cccc7396ccd8d7fb98015bf37c77d67db1696f2521827eee1ce2b5"]
        static let RedirectURI = ["redirect_uri": "Oslo://photos"]
        static let GrantType = ["grant_type": "authorization_code"]
        static let ResponseType = ["response_type": "code"]
        static let Scope = ["scope": "public+read_user+write_likes"]
    }
    
    
    
}
