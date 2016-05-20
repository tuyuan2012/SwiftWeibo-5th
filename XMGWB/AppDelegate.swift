//
//  AppDelegate.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/6.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
import AFNetworking

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // 1.设置全局外观
        UITabBar.appearance().tintColor = UIColor.orangeColor()
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
        
        // 2.注册通知, 监听根控制器的改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("switchRootViewController:"), name: XMGRootViewControllerChnage, object: nil)
        
        // 3.创建keywindow
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor  = UIColor.whiteColor()
        window?.rootViewController = defaultViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

/// 切换根控制器的代码
extension AppDelegate
{
    /// 切换根控制器器
    @objc private func switchRootViewController(notify: NSNotification)
    {
        guard let _ = notify.userInfo else
        {
            // 切换到首页
            window?.rootViewController = createViewController("Main")
            return
        }
        // 切换到欢迎界面
        window?.rootViewController = createViewController("WelcomeViewController")
        
    }
    
    /// 返回默认控制器
    private func defaultViewController() -> UIViewController
    {
        if let _ = UserAccount.loadUserAccount()
        {
            return isNewVersion() ? createViewController("NewfeatureViewController") : createViewController("WelcomeViewController")
        }
        return createViewController("Main")
    }
    
    /// 根据一个SB的名称创建一个控制器
    private func createViewController(viewControllerName: String) -> UIViewController
    {
        let sb = UIStoryboard(name: viewControllerName, bundle: nil)
        return sb.instantiateInitialViewController()!
    }
    
    /// 判断是否有新版本
    private func isNewVersion() -> Bool
    {
        // 1.从info.plist中获取当前软件的版本号
        let currentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        
        // 2.从沙盒中获取以前的软件版本号
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let sanboxVersion = (userDefaults.objectForKey("CFBundleShortVersionString") as? String) ?? "0.0"
        
        // 3.利用"当前的"和"沙盒的"进行比较
        // 如果当前的 > 沙盒的, 有新版本
        // 1.0 0.0
        if currentVersion.compare(sanboxVersion) == NSComparisonResult.OrderedDescending
        {
            // 有新版本
            // 4.存储当前的软件版本号到沙盒中
            userDefaults.setObject(currentVersion, forKey: "CFBundleShortVersionString")
            userDefaults.synchronize() // iOS7以前需要这样做, iOS7以后不需要了
            return true
        }
        
        // 5.返回结果
        return false
        
    }

}

/*
自定义LOG的目的:
在开发阶段自动显示LOG
在发布阶段自动屏蔽LOG
*/
//func NJLog<T>(message: T, method: String = __FUNCTION__, line: Int = __LINE__)
//{
//    #if DEBUG
//    print("\(method)[\(line)]: \(message)")
//    #endif
//}

