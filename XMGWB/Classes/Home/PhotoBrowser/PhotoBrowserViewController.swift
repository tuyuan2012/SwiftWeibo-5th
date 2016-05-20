//
//  PhotoBrowserViewController.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/13.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
import SVProgressHUD

class PhotoBrowserViewController: UIViewController {

    /// 所有需要显示的图片
    var urls: [NSURL]
    /// 当前点击的图片索引
    var path: NSIndexPath
    
    init(urls: [NSURL], path: NSIndexPath)
    {
        self.urls = urls
        self.path = path
        
        // 自定义构造方法需要调用的是designated对应的构造方法
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.greenColor()
        
        // 1.添加子控件
        view.addSubview(collectionView)
        view.addSubview(closeButton)
        view.addSubview(saveButton)
        
        // 2.布局子控件
        closeButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(20)
            make.bottom.equalTo(view.snp_bottom).offset(-20)
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
        
        saveButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(view).offset(-20)
            make.bottom.equalTo(view.snp_bottom).offset(-20)
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
        
        collectionView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // 滚动到指定位置
        collectionView.scrollToItemAtIndexPath(path, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
    }
    
    // MARK: - 内部控制方法
    @objc private func closeBtnClick()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @objc private func saveBtnClick()
    {
        // 1.获取当前显示的索引
        let path = collectionView.indexPathsForVisibleItems().first!
        // 2.获取当前显示的cell
        let cell = collectionView.cellForItemAtIndexPath(path) as! XMGBrowserCollectionViewCell
        // 3.获取当前显示的image
        guard let image = cell.iconImageView.image else
        {
            // 没有图片
            SVProgressHUD.showErrorWithStatus("没有图片", maskType: SVProgressHUDMaskType.Black)
            return
        }
        
        // 保存图片
        /*
        第一个参数: 需要保存的图片
        第二个参数: 谁来监听是否保存成功
        第三个参数: 监听是否保存成功的方法名称
        第四个参数: 给监听方法传递的参数
        注意; 监听是否保存成功的方法必须是系统指定的方法
        - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
        */
        UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject?)
    {
        if error != nil
        {
            SVProgressHUD.showErrorWithStatus("保存图片失败", maskType: SVProgressHUDMaskType.Black)
            return
        }
        
        SVProgressHUD.showSuccessWithStatus("保存图片成功", maskType: SVProgressHUDMaskType.Black)
        
        
    }
    
    // MARK: - 懒加载
    private lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("关闭", forState: UIControlState.Normal)
        btn.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        btn.addTarget(self, action: Selector("closeBtnClick"), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    private lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("保存", forState: UIControlState.Normal)
        btn.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        btn.addTarget(self, action: Selector("saveBtnClick"), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    private lazy var layout: XMGPhotoBrowserLayout =  XMGPhotoBrowserLayout()
    
    private lazy var collectionView: UICollectionView = {
       let clv = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout)
        clv.registerClass(XMGBrowserCollectionViewCell.self, forCellWithReuseIdentifier: "browserCell")
        clv.dataSource = self
        clv.backgroundColor = UIColor.redColor()
        return clv
    }()

}

extension PhotoBrowserViewController: UICollectionViewDataSource, XMGBrowserCollectionViewCellDelegate
{
    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // 1.获取cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("browserCell", forIndexPath: indexPath) as! XMGBrowserCollectionViewCell
        
        // 2.设置图片
        cell.url = urls[indexPath.item]
        
        // 3.设置代理
        cell.delegate = self

        // 4.返回cell
        return cell
    }
    
    // MARK: - XMGBrowserCollectionViewCellDelegate
    func browserCollectionViewCellDidClick(cell: XMGBrowserCollectionViewCell) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

class XMGPhotoBrowserLayout: UICollectionViewFlowLayout {
    override func prepareLayout() {
        itemSize = UIScreen.mainScreen().bounds.size
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.pagingEnabled = true
    }
}
