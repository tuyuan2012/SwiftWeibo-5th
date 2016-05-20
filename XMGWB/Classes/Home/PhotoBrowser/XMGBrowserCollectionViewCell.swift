//
//  XMGBrowserCollectionViewCell.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/13.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit

// Swift中定义代理协议需要继承于NSObjectProtocol
// 并且默认情况下所有的代理方法都是必须实现的

protocol XMGBrowserCollectionViewCellDelegate: NSObjectProtocol
{
    func browserCollectionViewCellDidClick(cell: XMGBrowserCollectionViewCell)
}

class XMGBrowserCollectionViewCell: UICollectionViewCell {
  
    /// 代理
    // 注意: 代理属性前面一定要写weak
    weak var delegate: XMGBrowserCollectionViewCellDelegate?
    
    var url: NSURL?
        {
        didSet{
            
            // 1.重置
            reset()
            
            // 2.显示提醒视图
            activityIndicatorView.startAnimating()
            
            // 3.设置图片
            iconImageView.sd_setImageWithURL(url) { (image, error, _, _) -> Void in
                
                // 0.隐藏提醒视图
                self.activityIndicatorView.stopAnimating()
                
                // 屏幕宽高
                let screenWidth = UIScreen.mainScreen().bounds.width
                let screenHeight = UIScreen.mainScreen().bounds.height
                
                // 1.按照宽高比缩放图片
                let scale = image.size.height / image.size.width
                let height = scale * screenWidth
                self.iconImageView.frame = CGRect(origin: CGPointZero, size: CGSize(width: screenWidth, height: height))
                


                // 2.判断是长图还是短图
                if height < screenHeight
                {
                    // 短图, 需要居中
                    //1.1计算偏移位
                    let offsetY = (screenHeight - height) * 0.5
                    
                    // 1.2设置偏移位
                    self.scrollview.contentInset = UIEdgeInsets(top: offsetY, left: 0, bottom: offsetY, right: 0)
                }else
                {
                    // 长图, 不需要居中
                    self.scrollview.contentSize = self.iconImageView.frame.size
                }
                
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 1.添加子控件
        contentView.addSubview(scrollview)
        scrollview.addSubview(iconImageView)
        contentView.addSubview(activityIndicatorView)
        
        // 2.布局子控件
        scrollview.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(contentView)
        }
        activityIndicatorView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(contentView)
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 重置所有属性
    private func reset()
    {
        scrollview.contentSize = CGSizeZero
        scrollview.contentOffset = CGPointZero
        scrollview.contentInset = UIEdgeInsetsZero
        iconImageView.transform = CGAffineTransformIdentity
    }
    
    @objc private func imageClick()
    {
        // 通知代理关闭图片浏览器
        // 和OC中不太一样, Swift中调用代理方法不用先判断
        delegate?.browserCollectionViewCellDidClick(self)
    }
    
    // MARK: - 懒加载
    private lazy var scrollview: UIScrollView = {
       let sl = UIScrollView()
        
        // 和缩放相关的设置
        sl.minimumZoomScale = 0.5
        sl.maximumZoomScale = 3.0
        sl.delegate = self

        return sl
    }()
    lazy var iconImageView: UIImageView =  {
       let iv = UIImageView()
        iv.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: Selector("imageClick"))
        iv.addGestureRecognizer(tap)
        return iv
    }()
    
    private lazy var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
}

extension XMGBrowserCollectionViewCell: UIScrollViewDelegate
{
    // 告诉系统需要缩放谁
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return iconImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // 调整图片的位置, 让图片居中
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        
        // scrollView被缩放的view, 它的frame和bounds是有一定的区别的
        // bounds是的值是固定的, 而frame的值是变化的
        // 所以被缩放的控件的frame就是scrollView的contentSize
        // 也就是说frame的值和contentSize一样的
        
        var offsetY = (screenHeight - iconImageView.frame.height) * 0.5
        // 注意: 当偏移位小于0时会导致图片无法拖拽查看完整图片, 所以当偏移位小于0时需要复位为0
        offsetY = (offsetY < 0) ? 0 : offsetY
        var offsetX = (screenWidth - iconImageView.frame.width) * 0.5
        offsetX = (offsetX < 0) ? 0 : offsetX
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}
