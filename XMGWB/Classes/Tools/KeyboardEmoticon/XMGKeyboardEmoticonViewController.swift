//
//  XMGKeyboardEmoticonViewController.swift
//  表情键盘
//
//  Created by xiaomage on 15/12/9.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit

class XMGKeyboardEmoticonViewController: UIViewController {

    /// 保存所有组数据
    var packages: [XMGKeyboardPackage] = XMGKeyboardPackage.loadEmotionPackages()
    
    /// 回调的闭包属性
    var emoticonCallback : (emoticon : XMGKeyboardEmoticon)->()
    
    // 重写控制器的init方法
    init(callBack : (emoticon : XMGKeyboardEmoticon)->()) {
        self.emoticonCallback = callBack
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.redColor()
        
        // 1.添加子控件
        view.addSubview(collectionView)
        view.addSubview(toolbar)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        // 2.布局子控件
        let dict = ["collectionView": collectionView, "toolbar": toolbar]
        var cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[toolbar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-[toolbar(49)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        view.addConstraints(cons)
    }
    
    // MARK: - 内部控制方法
    @objc private func itemClick(item: UIBarButtonItem)
    {
        // 1.创建indexPath
        let indexPath = NSIndexPath(forItem: 0, inSection: item.tag)
        // 2.滚动到指定的indexPath
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
    }
    
    // MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {
       let clv = UICollectionView(frame: CGRectZero, collectionViewLayout: XMGKeyboardEmoticonLayout())
        clv.backgroundColor = UIColor.greenColor()
        clv.dataSource = self
        clv.delegate = self
        clv.registerClass(XMGKeyboardEmoticonCell.self, forCellWithReuseIdentifier: "keyboardCell")
       return clv
    }()
    
    private lazy var toolbar: UIToolbar = {
       let tb = UIToolbar()
        tb.tintColor = UIColor.lightGrayColor()
        
        var items = [UIBarButtonItem]()
        var index = 0
        for title in ["最近", "默认", "Emoji", "浪小花"]
        {
            // 1.创建item
            let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("itemClick:"))
            item.tag = index++
            items.append(item)
            // 2.创建间隙
            let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
             items.append(flexibleItem)
        }
        items.removeLast()
        // 2.将item添加到toolbar上
        tb.items = items
        return tb
    }()
}

extension XMGKeyboardEmoticonViewController: UICollectionViewDataSource
{
    // 告诉系统有多少组
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    // 告诉系统每组多少个
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packages[section].emoticons?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // 1.取出cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("keyboardCell", forIndexPath: indexPath) as! XMGKeyboardEmoticonCell
        
        cell.backgroundColor = (indexPath.item % 2 == 0) ? UIColor.redColor(): UIColor.purpleColor()
        // 2.设置数据
//        cell.emoticon = packages[indexPath.section].emoticons![indexPath.item]
        let package = packages[indexPath.section]
        cell.emoticon = package.emoticons![indexPath.item]
        
        // 3.返回cell
        return cell
    }
}

extension XMGKeyboardEmoticonViewController: UICollectionViewDelegate
{
    /// 监听表情点击
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // 1.取出点击的表情
        let package = packages[indexPath.section]
        let emoticon = package.emoticons![indexPath.item]
        
        // 2.记录点击的表情,并且放入到最近中
        // 每使用一次就+1
        emoticon.count += 1
        
        // 判断是否是删除按钮
        if !emoticon.isRemoveButton
        {
            // 将当前点击的表情添加到最近组中
            packages[0].addFavoriteEmoticon(emoticon)
        }
        
        // 3.将表情传递给外面的控制器
        emoticonCallback(emoticon: emoticon)
    }
}


class XMGKeyboardEmoticonLayout: UICollectionViewFlowLayout {
    override func prepareLayout() {
        super.prepareLayout()
        
        // 1.计算cell宽度
        let width = UIScreen.mainScreen().bounds.width / 7
        let height = collectionView!.bounds.height / 3
        itemSize = CGSize(width: width, height: height)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        // 2.设置collectionView
        collectionView?.bounces = false
        collectionView?.pagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
    }
}