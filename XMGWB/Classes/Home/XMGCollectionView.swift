//
//  XMGCollectionView.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/13.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
import SDWebImage

class XMGCollectionView: UICollectionView
{
    
    /// 配图容器高度约束
    @IBOutlet weak var pictureCollectionViewHeightCons: NSLayoutConstraint!
    /// 配图容器宽度约束
    @IBOutlet weak var pictureCollectionVeiwWidthCons: NSLayoutConstraint!
    
    
    /// 模型对象
    var viewModel: StatusViewModel?
        {
        didSet{
            // 6.1计算配图和配图容器的尺寸
            let (itemSize, size) = caculateSize()
            // 6.2设置配图容器的尺寸
            pictureCollectionVeiwWidthCons.constant = size.width
            pictureCollectionViewHeightCons.constant = size.height
            
            // 6.3设置配图的尺寸
            if itemSize != CGSizeZero
            {
                (collectionViewLayout as! UICollectionViewFlowLayout).itemSize = itemSize
            }
            
            // 6.4刷新表格
            reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = self
        delegate = self
    }
    
    // MARK: - 内部控制方法
    /// 计算配图的尺寸
    /// 第一个参数: imageView的尺寸
    /// 第二个参数: 配图容器的尺寸
    private func caculateSize() -> (CGSize, CGSize)
    {
        /*
        没有配图: 不显示CGSizeZero
        一张配图: 图片的尺寸就是配图和配图容器的尺寸
        四张配图: 田字格
        其他张配图: 九宫格
        */
        // 1.获取配图个数
        let count = viewModel?.thumbnail_pics?.count ?? 0
        
        // 2.判断有没有配图
        if count == 0
        {
            return (CGSizeZero, CGSizeZero)
        }
        
        // 3.判断是否是一张配图
        if count == 1
        {
            let urlStr = viewModel!.thumbnail_pics?.last!.absoluteString
            // 加载已经下载好得图片
            let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(urlStr)
            
            // 获取图片的size
            return (image.size, image.size)
        }
        
        let imageWidth:CGFloat = 90
        let imageHeight = imageWidth
        let imageMargin: CGFloat = 10
        // 4.判断是否是4张配图
        if count == 4
        {
            let col:CGFloat = 2
            // 计算宽度  宽度 = 列数 * 图片宽度+ (列数 - 1) * 间隙
            let width = col * imageWidth + (col - 1) * imageMargin
            // 计算高度
            let height = width
            return (CGSize(width: 90, height: 90), CGSize(width: width, height: height))
        }
        
        // 5.其它张配图  九宫格
        let col: CGFloat = 3
        let row  =  (count - 1) / 3 + 1
        let width = col * imageWidth + (col - 1) * imageMargin
        let height = CGFloat(row) * imageHeight + CGFloat(row - 1) * imageMargin
        return (CGSize(width: 90, height: 90), CGSize(width: width, height: height))
    }

}

/// 数据源
extension XMGCollectionView: UICollectionViewDataSource, UICollectionViewDelegate
{
    
    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.thumbnail_pics?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pictureCell", forIndexPath: indexPath) as! XMGPictureCollectionViewCell
        
        let url = viewModel!.thumbnail_pics![indexPath.item]
        cell.imageURL = url
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let url = viewModel?.bmiddle_pics![indexPath.item] else
        {
            // 没有图片
            return
        }
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! XMGPictureCollectionViewCell
        
        // 1.下载图片显示进度
        SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: { (current, total) -> Void in
//            NJLog(CGFloat(current) / CGFloat(total))
            cell.iconImageView.progregss = CGFloat(current) / CGFloat(total)
            }) { (_, error, _, _, _) -> Void in
                // 2.发送通知, 通知控制器弹出图片浏览器, 并且传递当前collectionView所有配图以及被点击的索引
                NSNotificationCenter.defaultCenter().postNotificationName(XMGPhotoBrowserShow, object: self, userInfo: ["urls": self.viewModel!.bmiddle_pics!, "indexPath": indexPath])
        }
        
    }
}

/// 配图Cell
class XMGPictureCollectionViewCell: UICollectionViewCell {
    
    /// 配图
    @IBOutlet weak var iconImageView: ProgressImageView!
    
    @IBOutlet weak var gifImageView: UIImageView!
    
    /// 配图对应的URL
    var imageURL: NSURL?
        {
        didSet{
            // 1.设置配图
            iconImageView.sd_setImageWithURL(imageURL)
            
            // 2.设置是否需要显示gif图标
            guard let urlStr = imageURL?.absoluteString else
            {
                return
            }
             gifImageView.hidden = (urlStr as NSString).pathExtension != "gif"
        }
    }
}
