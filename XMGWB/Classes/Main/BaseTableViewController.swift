//
//  BaseTableViewController.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/6.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    /// 记录用户是否登录
    var login: Bool = UserAccount.login()
    /// 访客视图
    var visitorView: VisitorView?
    
    override func loadView() {
        super.loadView()
        login ? super.loadView() : setupVisitorView()
    }

    // MARK : - 内部控制方法
    private func setupVisitorView()
    {
        // 1.添加访客视图
        visitorView = VisitorView.visitorView()
        view = visitorView
        
        // 2.监听按钮的点击事件
        visitorView?.registerButton.addTarget(self, action: Selector("registerBtnClick"), forControlEvents: UIControlEvents.TouchUpInside)
        visitorView?.loginButton.addTarget(self, action: Selector("loginBtnClick"), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 3.添加导航条按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("registerBtnClick"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("loginBtnClick"))
    }
    
    @objc private func registerBtnClick()
    {
    
    }
    @objc private func loginBtnClick()
    {
        // 1.创建登录界面
        let sb = UIStoryboard(name: "OAuthViewController", bundle: nil)
        let OAuthVc = sb.instantiateInitialViewController()!
        
        // 2.弹出登录界面
        presentViewController(OAuthVc, animated: true, completion: nil)
    }
}
