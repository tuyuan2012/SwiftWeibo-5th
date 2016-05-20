//
//  NewfeatureViewController.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/10.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
import SnapKit

class NewfeatureViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    /// 新特性界面总数
    let maxImageCount = 4
    
    // MARK: - UICollectionViewDataSource
    // 告诉系统当前组有多少行
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maxImageCount
    }
    
    // 告诉系统当前行显示什么内容
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // 1.取出cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("newfeatureCell", forIndexPath: indexPath) as! XMGCollectionViewCell
        
        // 2.设置数据
        cell.index = indexPath.item
        // 以下代码, 主要为了避免重用问题
        cell.startButton.hidden = true
        
        // 3.返回cell
        return cell
    }
    
    // MAKR: - UICollectionViewDelegate
    // 注意: 该方法传递给我们的是上一页的索引
    // 当一个cell完全显示之后就会调用
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        // 1.获取当前展现在眼前的cell对应的索引
       let path = collectionView.indexPathsForVisibleItems().last!
        
        // 2.根据索引获取当前展现在眼前cell
        let cell = collectionView.cellForItemAtIndexPath(path) as! XMGCollectionViewCell
        
        // 3.判断是否是最后一页
        if path.item == maxImageCount - 1
        {
            cell.startButton.hidden = false
            // 禁用按钮交互
            // usingSpringWithDamping 的范围为 0.0f 到 1.0f ，数值越小「弹簧」的振动效果越明显。
            // initialSpringVelocity 则表示初始的速度，数值越大一开始移动越快, 值得注意的是，初始速度取值较高而时间较短时，也会出现反弹情况。
            cell.startButton.userInteractionEnabled = false
            cell.startButton.transform = CGAffineTransformMakeScale(0.0, 0.0)
            
            UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10.0, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                    cell.startButton.transform = CGAffineTransformIdentity
                }, completion: { (_) -> Void in
                    cell.startButton.userInteractionEnabled = true
            })
        }
    }
    
}

class XMGCollectionViewCell: UICollectionViewCell {
    
    /// 保存图片索引
    var index: Int = 0
        {
        didSet{
            iconView.image = UIImage(named: "new_feature_\(index + 1)")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 初始化UI
        setupUI()
    }
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // 初始化UI
        setupUI()
    }
    
    // MARK: - 内部控制方法
    private func setupUI()
    {
        // 添加子控件
        contentView.addSubview(iconView)
        contentView.addSubview(startButton)
        
        // 布局子控件
        iconView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(0)
        }
        startButton.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(contentView.snp_bottom).offset(-160)
        }
    }
    
    @objc private func startBtnClick()
    {
        // 发送通知, 通知AppDelegate切换根控制器
        NSNotificationCenter.defaultCenter().postNotificationName(XMGRootViewControllerChnage, object: self, userInfo: nil)
    }

  
    // MARK: - 懒加载
    /// 大图容器
    private lazy var iconView = UIImageView()
    /// 开始按钮
    private lazy var startButton: UIButton = {
       let btn = UIButton(backgroundImage: "new_feature_button")
        btn.addTarget(self, action: Selector("startBtnClick"), forControlEvents: UIControlEvents.TouchUpInside)
        btn.sizeToFit()
        return btn
    }()
}

// 注意: Swift中一个文件中是可以定义多个类
class XMGFlowLayout: UICollectionViewFlowLayout {
    // 准备布局
    override func prepareLayout() {
        super.prepareLayout()
        itemSize = collectionView!.bounds.size
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.pagingEnabled = true
        
    }
}
