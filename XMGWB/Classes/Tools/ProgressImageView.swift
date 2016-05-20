//
//  ProgressImageView.swift
//  01-进度条View
//
//  Created by xiaomage on 15/11/16.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit

class ProgressImageView: UIImageView {
    /// 进度 0~1
    var progregss: CGFloat = 0.0
        {
        didSet{
            progressView.progregss = progregss
        }
    }

    init() {
        super.init(frame: CGRectZero)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    
    private func setupUI()
    {
        // 1.清空进度背景
        progressView.backgroundColor = UIColor.clearColor()
        
        // 2.添加进度视图
        addSubview(progressView)
        
        //3.添加约束
        progressView.translatesAutoresizingMaskIntoConstraints = false
        var cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[progressView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["progressView": progressView])
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[progressView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["progressView": progressView])
        addConstraints(cons)

    }
    // MAKR: - 懒加载
    private lazy var progressView: ProgressView = ProgressView()

}
