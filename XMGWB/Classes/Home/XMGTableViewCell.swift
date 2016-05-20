//
//  XMGTableViewCell.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/12.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
import SDWebImage
import KILabel

// Swift中的枚举比OC强大很多, 可以赋值任意类型的数据, 以及可以定义方法
enum XMGTableViewCellIdentifier: String
{
    case NormalCellIdentifier = "originalCell"
    case ForwardCellIdentifier = "forwardCell"
    
    /// 根据模型获取cell的重用标识
    static func identifierWithViewModel(viewModel: StatusViewModel) -> String
    {
        // rawValue 代表获取枚举的原始值
        return (viewModel.status.retweeted_status != nil) ? ForwardCellIdentifier.rawValue : NormalCellIdentifier.rawValue
    }
}

class XMGTableViewCell: UITableViewCell {
    
    /// 模型对象
    var viewModel: StatusViewModel?
        {
        didSet{
            // 1.设置头像
            iconImageView.sd_setImageWithURL(viewModel?.avatarURL)
            
            // 2.认证图标
            verifiedImageView.image = viewModel?.verifiedImage
            
            // 3.昵称
            nameLabel.text = viewModel?.status.user?.screen_name ?? ""
            
            // 4.会员图标
            vipImageView.image = viewModel?.mbrankImage
            
            // 5.时间
            timeLabel.text = viewModel?.createdText ?? ""
            
            // 6.来源
            sourceLabel.text  = viewModel?.sourceText ?? ""
            
            // 5.正文
            // contentLabel.text = viewModel?.status.text ?? ""
            contentLabel.attributedText = XMGKeyboardPackage.createMutableAttrString(viewModel?.status.text ?? "", font: contentLabel.font)
            
            // 6.转发正文
            if let temp = viewModel?.status.retweeted_status?.text
            {
                forwardLabelWidthCons.constant = UIScreen.mainScreen().bounds.width - 20
                // forwardLabel.text = temp
                forwardLabel.attributedText = XMGKeyboardPackage.createMutableAttrString(temp, font: forwardLabel.font)
            }
            
            // 7.配图
            pictureCollectionView.viewModel = viewModel
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 1.动态设置正文宽度约束
        contentLabelWidthCons.constant = UIScreen.mainScreen().bounds.width - 20
        
        // 监听@了谁
        contentLabel.userHandleLinkTapHandler = { label, handle, range in
            print("\(handle) \(range)")
        }
        
        // 监听话题的点击
        contentLabel.hashtagLinkTapHandler = { label, hashtag, range in
            print("\(hashtag) \(range)")
        }
        
        // 监听连接的点击
        contentLabel.urlLinkTapHandler = { label, url, range in
            print("\(url) \(range)")
        }
    }
    
    // MARK: - 外部控制方法
    /// 计算当前行的高度
    func caculateRowHeight(viewModel: StatusViewModel) -> CGFloat
    {
        // 1.将数据赋值给当前cell
        self.viewModel = viewModel
        
        // 2.更新UI
        layoutIfNeeded()
        
        // 3.返回行高
        return CGRectGetMaxY(footerView.frame)
    }
    
    /// 用户头像
    @IBOutlet weak var iconImageView: UIImageView!
    /// 会员图标
    @IBOutlet weak var vipImageView: UIImageView!
    /// 昵称
    @IBOutlet weak var nameLabel: UILabel!
    /// 正文
    @IBOutlet weak var contentLabel: KILabel!
    /// 正文宽度约束
    @IBOutlet weak var contentLabelWidthCons: NSLayoutConstraint!
    /// 来源
    @IBOutlet weak var sourceLabel: UILabel!
    /// 时间
    @IBOutlet weak var timeLabel: UILabel!
    /// 认证图标
    @IBOutlet weak var verifiedImageView: UIImageView!
    /// 配图容器
    @IBOutlet weak var pictureCollectionView: XMGCollectionView!
    /// 底部视图
    @IBOutlet weak var footerView: UIView!
    /// 转发正文
    @IBOutlet weak var forwardLabel: KILabel!
    /// 转发正文宽度约束
    @IBOutlet weak var forwardLabelWidthCons: NSLayoutConstraint!
    
}
