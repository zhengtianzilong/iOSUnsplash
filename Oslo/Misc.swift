//
//  Misc.swift
//  Oslo
//
//  Created by 蔡紫龙 on 2017/9/6.
//  Copyright © 2017年 caizilong. All rights reserved.
//

import UIKit

public extension UIView{
    
    public class func load(from xib:String,with frame:CGRect) -> UIView?{
        
        guard let nibView = Bundle.main.loadNibNamed(xib, owner: self, options: nil) as? [UIView]  else { return nil }
        
        let view = nibView[0];
        view.frame = frame;
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight];
        return view;
    }
}

public func delay(_ delay:Double, completion:@escaping ()->Void){
    
    let time = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: time, execute: completion)
    
}

extension Array{
    
    func randomItem() -> Element {
        
        let index = Int(arc4random_uniform(UInt32(self.count)))
        
        return self[index]
 
    }
    
}

extension UIView{
    @IBInspectable var cornerRadius:CGFloat{
        
        get{
            return layer.cornerRadius
        }
        set{
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
        
    }
    
    @IBInspectable var borderWidth:CGFloat{
        
        set{
            layer.borderWidth = newValue
        }
        get{
            return layer.borderWidth
        }
        
    }
    
    @IBInspectable var borderColor:UIColor{
        get{
            return UIColor(cgColor: layer.borderColor!)
        }
        set{
            layer.borderColor = newValue.cgColor
        }
    }
    
    
    
}

public func localize(with key:String) ->String{
    
    return NSLocalizedString(key, comment: "")
    
}

public func localizedFormat(with key:String,and argument:String) ->String{
    return String(format: localize(with: key), argument)
}


























