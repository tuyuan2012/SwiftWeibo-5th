//
//  swift
//  XMGWB
//
//  Created by xiaomage on 15/11/9.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit

class TitleButton: UIButton {

    /// 通过代码创建会调用
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        adjustsImageWhenHighlighted = false
        setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        setImage(UIImage(named: "navigationbar_arrow_down"), forState: UIControlState.Normal)
        setImage(UIImage(named: "navigationbar_arrow_up"), forState: UIControlState.Selected)
        sizeToFit()
    }
    
    /// 通过SB/XIB创建会调用
    required init?(coder aDecoder: NSCoder) {
        // 致命错误
        fatalError("init(coder:) has not been implemented")
//        super.init(coder: aDecoder)
        // 写自己的实现
    }
    
    
    /*
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        
    }
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        
    }
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        /*
        NJLog("")
        titleLabel?.frame.offsetInPlace(dx: -imageView!.frame.width * 0.5, dy: 0)
        imageView?.frame.offsetInPlace(dx: titleLabel!.frame.width * 0.5, dy: 0)
        */
        titleLabel?.frame.origin.x = 0
        imageView?.frame.origin.x = titleLabel!.frame.width
    }
    
}
