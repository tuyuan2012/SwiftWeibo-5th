//
//  XMGPresentationController.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/9.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit

class XMGPresentationController: UIPresentationController {

    /// 记录菜单的尺寸
    var presentedFrame = CGRectZero
    
    /// 布局被弹出的控制器
    override func containerViewWillLayoutSubviews()
    {
        super.containerViewWillLayoutSubviews()
        // containerView 容器视图 (所有被展现的内容都再容器视图上)
        // presentedView() 被展现的视图(当前就是弹出菜单控制器的view)
        
        // 1.添加蒙版
        containerView?.insertSubview(cover, atIndex: 0)
        cover.frame = containerView!.bounds
        
        // 2.修改被展现视图尺寸
        presentedView()?.frame = presentedFrame // CGRect(x: 100, y: 56, width: 200, height: 200)
    }
    
    // MARK: - 内部控制方法
    @objc private func coverClick()
    {
        // 关闭菜单
        presentedViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - 懒加载
    private lazy var cover: UIView = {
        // 1.创建蒙版
       let otherView = UIView()
        otherView.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        // 2.添加手势识别器
        let tap = UITapGestureRecognizer(target: self, action: Selector("coverClick"))
        otherView.addGestureRecognizer(tap)
        return otherView
    }()
}
