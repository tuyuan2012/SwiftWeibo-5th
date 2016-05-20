//
//  MainViewController.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/6.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 0.添加自定义加号按钮到tabBar
        tabBar.addSubview(composeButton)
        
        // 1.计算按钮的宽度
        let width = tabBar.bounds.width / CGFloat(childViewControllers.count)
        let height = composeButton.bounds.height
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        // 2.调整加号按钮位置
        composeButton.frame = CGRectOffset(rect, 2 * width, 0)
    }
    
    // MARK: - 内部控制方法
    /// 监听加号按钮点击
    @objc private func composeBtnClick(){
        
        /*
        UITextField
        不可以换行
        不可以滚动
        可以显示占位提示文本  placeholder
        
        UITextView
        可以换行
        可以滚动
        不可以显示占位提示文本
        */
        let sb = UIStoryboard(name: "ComposeViewController", bundle: nil)
        let vc = sb.instantiateInitialViewController()!
        presentViewController(vc, animated: true, completion: nil)
        
    }
    
    // MARK: - 懒加载
    private lazy var composeButton: UIButton = {
        let btn = UIButton(imageName: "tabbar_compose_icon_add", backgroundImage: "tabbar_compose_button")
        btn.addTarget(self, action: Selector("composeBtnClick"), forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()

}
