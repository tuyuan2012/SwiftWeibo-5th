//
//  VisitorView.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/6.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit

class VisitorView: UIView {
    
    /// 注册按钮
    @IBOutlet weak var registerButton: UIButton!
    /// 登录按钮
    @IBOutlet weak var loginButton: UIButton!
    /// 文本视图
    @IBOutlet weak var titleView: UILabel!
    /// 大图标
    @IBOutlet weak var iconView: UIImageView!
    /// 大转盘
    @IBOutlet weak var rotationView: UIImageView!
    
    // MARK: - 外部控制方法
    /**
    设置访客视图内容
    
    - parameter imageName: 图片名称
    - parameter title:     标题内容
    */
    func setupVisitorInfo(imageName: String?, title: String)
    {
        // 首页
        guard let name = imageName else
        {
            startAnimation()
            return
        }
        // 其他界面
        iconView.image = UIImage(named: name)
        titleView.text = title
        rotationView.hidden = true
    }
    
    /**
    快速创建方法
    */
    class func visitorView() -> VisitorView
    {
        return NSBundle.mainBundle().loadNibNamed("VisitorView", owner: nil, options: nil).last as! VisitorView
    }
    

    // MARK: - 内部控制方法
    private func startAnimation()
    {
        // 1.创建动画对象
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        // 2.设置动画属性
        anim.toValue = 2 * M_PI
        anim.duration = 10.0
        anim.repeatCount = MAXFLOAT
        
        // 告诉系统不要随便给我移除动画, 只有当控件销毁的时候才需要移除
        anim.removedOnCompletion = false
        // 3.将动画添加到图层
        rotationView.layer.addAnimation(anim, forKey: nil)
    }
}
