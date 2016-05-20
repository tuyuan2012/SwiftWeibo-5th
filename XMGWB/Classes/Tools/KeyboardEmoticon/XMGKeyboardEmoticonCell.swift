//
//  XMGKeyboardEmoticonCell.swift
//  表情键盘
//
//  Created by xiaomage on 15/12/9.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit


class XMGKeyboardEmoticonCell: UICollectionViewCell {
    
    /// 当前行对应的表情模型
    var emoticon: XMGKeyboardEmoticon?
        {
        didSet{
            // 1.显示emoji表情
            iconButton.setTitle(emoticon?.emoticonStr ?? "", forState: UIControlState.Normal)
            
            // 2.设置图片表情
             iconButton.setImage(nil, forState: UIControlState.Normal)
            if emoticon?.chs != nil
            {
                iconButton.setImage(UIImage(contentsOfFile: emoticon!.pngPath!), forState: UIControlState.Normal)
            }
            // 3.设置删除按钮
            if emoticon!.isRemoveButton
            {
                iconButton.setImage(UIImage(named: "compose_emotion_delete"), forState: UIControlState.Normal)
                iconButton.setImage(UIImage(named: "compose_emotion_delete_highlighted"), forState: UIControlState.Highlighted)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    // MARK: - 内部控制方法
    private func setupUI()
    {
        // 1.添加子控件
        contentView.addSubview(iconButton)
        iconButton.backgroundColor = UIColor.whiteColor()

        // 2.布局子控件
        iconButton.frame = CGRectInset(bounds, 4, 4)
    }
    
    // MARK: - 懒加载
    private lazy var iconButton: UIButton = {
        let btn = UIButton()
        btn.userInteractionEnabled = false
        btn.titleLabel?.font = UIFont.systemFontOfSize(30)
        return btn
    }()
}
