//
//  NetworkService.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/7.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import UIKit

class NetworkService {
    
    enum HTTPMethod:String {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    
    /// 请求
    ///
    /// - Parameters:
    ///   - url: api
    ///   - method: 方式
    ///   - parameters: 参数
    ///   - headers: 头文件
    ///   - completion: 返回体
    class func request(url:URL,method:HTTPMethod,parameters:[[String:AnyObject]]? = nil,headers:[String:String]? = nil,completion:((AnyObject) ->(Void))? = nil) -> Void {
        // session概念在计算机领域广泛应用，可以理解为一个时间周期，也就是告诉程序我需要一个时间的空档，才开始发送网络数据
        let session = URLSession.shared
        // 建立url
        let parsedURL = parse(url, with: parameters)
        // 建立request
        var request = URLRequest(url: parsedURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        // https://unsplash.com/photos/curated?client_id=de3e9797b860a9e33e62daa098d29f0f03c8beba93b2719466fa83b969110c31
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // 进行各种错误的处理
            guard error == nil else{
                print("An error occured,\(String(describing: error))")
                return
                
            }
            
            guard let data = data else{
                print("没有数据返回")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,statusCode >= 200 && statusCode <= 299 else
            {
                print("状态码不在200---299范围内")
                
                do{
                    // 进行JSON的序列化
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                    
                   if ((result["errors"] as? Array)?[0])! ==  "OAuth error: The access token is invalid"{
                    Token.removeToken()
                    
                    }
                }catch{
                    print("不可以转换成JSON格式")
                    return
                }
                return
            }

            
            do{
                // 进行JSON的序列化
                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                completion?(result as AnyObject)
            
            }catch{
                print("不可以转换成JSON格式")
                return
            }
            
        }
        // 执行task
        task.resume()

    }
    
    // 对url进行拼接处理
    class func parse(_ url:URL,with parameters:[[String:AnyObject]]? = nil) -> URL{
        
        var components =  URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem]()
        if let params = parameters {
            for param in params {
                
                for (key,value) in param {
                    
                    let queryItem = URLQueryItem(name: key, value: "\(value)")
                    components?.queryItems?.append(queryItem)
                }
                
            }
            
        }
        
        return (components?.url)!
    }
    
    class func image(with imageUrl:URL?,completion:@escaping ((_ image:UIImage)->Void)) -> (Void){
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            if let imageURL = imageUrl{
                do{
                    let imageData = try Data(contentsOf: imageURL)
                    guard let image = UIImage(data: imageData) else{
                        return
                    }
                    
                    DispatchQueue.main.async {
                      completion(image)
                    } 
                }catch{
                    print("图片下载失败")
                }
            }
            
            
            
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
