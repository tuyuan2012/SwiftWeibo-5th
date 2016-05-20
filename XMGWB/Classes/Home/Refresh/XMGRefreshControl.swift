//
//  XMGRefreshControl.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/13.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
import SnapKit

class XMGRefreshControl: UIRefreshControl {

    override init() {
        
        super.init()
        
        // 1.添加子控件
        addSubview(refreshView)
        
        // 2.布局子控件
        refreshView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.size.equalTo(CGSize(width: 150, height: 60))
        }

        // 3.注册监听, 监听frame的改变
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        removeObserver(self, forKeyPath: "frame")
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        refreshView.endAnimation()
    }
    

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // 下拉刷新控件的frame一旦改变就会调用
        
        /*
        规律: 越往下拉Y越小, 越往上推Y越大
        */
        // 1.过滤垃圾数据
        if frame.origin.y == 0 || frame.origin.y == -64
        {
            return
        }
        
        // 2.检查是否已经触发下拉刷新
        if refreshing
        {
            refreshView.startAnimation()
            return
        }
        
        // 3.控制箭头旋转
        if frame.origin.y < -50 && !refreshView.showRotationFlag
        {
            refreshView.showRotationFlag = true
            refreshView.rotationArrow()
        }else if frame.origin.y > -50 && refreshView.showRotationFlag
        {
            refreshView.showRotationFlag  = false
            refreshView.rotationArrow()
        }
    }

    // MARK: - 懒加载
    private lazy var refreshView = XMGRefreshView.refreshView()
}

class XMGRefreshView: UIView {
    
    /// 提示视图
    @IBOutlet weak var tipsView: UIView!
    /// 箭头视图
    @IBOutlet weak var arrowImageView: UIImageView!
    /// 菊花视图
    @IBOutlet weak var loadingImageVIew: UIImageView!
    
    // 记录是否需要旋转
    var showRotationFlag = false
    
    /// 快速创建提示视图
    class func refreshView() -> XMGRefreshView  {
        return NSBundle.mainBundle().loadNibNamed("XMGRefreshView", owner: nil, options: nil).last as! XMGRefreshView
    }
    
    private func rotationArrow()
    {
        /*
        规律: 1.默认是顺时针 2.就近原则
        */
        var angle = CGFloat(M_PI)
        angle = showRotationFlag ? angle - 0.01 : angle + 0.01
        UIView.animateWithDuration(0.5) { () -> Void in
            self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, angle)
        }
    }
    // MARK: - 内部控制方法
    /// 开始菊花旋转动画
    private func startAnimation()
    {
        // 0.隐藏提示视图
        tipsView.hidden = true
        
        let key = "transform.rotation"
        if let _  = loadingImageVIew.layer.animationForKey(key)
        {
            return
        }
        
        // 1.创建动画对象
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        // 2.设置动画属性
        anim.toValue = 2 * M_PI
        anim.duration = 10.0
        anim.repeatCount = MAXFLOAT
        anim.removedOnCompletion = false

        // 3.将动画添加到图层
        loadingImageVIew.layer.addAnimation(anim, forKey: key)
    }
    
    /// 停止菊花旋转动画
    private func endAnimation()
    {
        // 0.显示提示视图
        tipsView.hidden = false
        
        // 1.移除动画
        loadingImageVIew.layer.removeAllAnimations()
    }
}