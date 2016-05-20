//
//  WelcomeViewController.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/10.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
import SDWebImage

class WelcomeViewController: UIViewController {

    /// 头像距离底部约束
    @IBOutlet weak var iconBottomCons: NSLayoutConstraint!
    /// 欢迎回来
    @IBOutlet weak var tipLabel: UILabel!
    /// 头像容器
    @IBOutlet weak var iconView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 断言: 断定一定有授权模型, 如果没有程序就会崩溃, 并且会输出后面message中的内容
        assert(UserAccount.loadUserAccount() != nil, "用户当前还没有授权")
        
        // 设置头像
        let url = NSURL(string: UserAccount.loadUserAccount()!.avatar_large!)
        iconView.sd_setImageWithURL(url)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // 1.计算移动的距离
        let offset = view.bounds.height - iconBottomCons.constant
        iconBottomCons.constant =  offset
        
        // 2.执行头像动画
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (_) -> Void in
               
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    self.tipLabel.alpha = 1.0
                    }, completion: { (_) -> Void in
                        // 发送通知, 通知AppDelegate切换根控制器
                        NSNotificationCenter.defaultCenter().postNotificationName(XMGRootViewControllerChnage, object: self, userInfo: nil)
                })
            }
    }

}
