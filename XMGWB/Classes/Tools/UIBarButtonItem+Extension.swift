//
//  UIBarButtonItem+Extension.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/9.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit

extension UIBarButtonItem
{
    convenience init(imageName: String, target: AnyObject, action: Selector) {
        
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: imageName + "_highlighted"), forState: UIControlState.Highlighted)
        btn.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        btn.sizeToFit()
        
        self.init(customView: btn)
    }
}
