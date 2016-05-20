//
//  HomeTableViewController.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/6.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

class HomeTableViewController: BaseTableViewController {

    /// 保存所有微博数据
    var statuses: [StatusViewModel]?
        {
        return modelList.statuses
    }
    
    /// 负责加载数据模型
    var modelList: StatusViewModelList = StatusViewModelList()
    
    /// 缓存行高 key微博的ID, value对应的行高
    var rowHeightCache = [String: CGFloat]()
    
    /// 记录是否是上拉加载更多
    var pullupFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1.判断是否登录
        if !login{
            
            visitorView?.setupVisitorInfo(nil, title: "")
            return
        }
        
        // 2.初始化导航条
        setupNav()
        
        // 3.添加下拉刷新
        refreshControl = XMGRefreshControl()
        refreshControl?.addTarget(self, action: Selector("loadData"), forControlEvents: UIControlEvents.ValueChanged)
        // 注意点:beginRefreshing并不会触发loadData
        refreshControl?.beginRefreshing()
        
        // 4.添加提示视图
        tipLabel.frame = CGRect(x: 0, y: -44 * 2, width: UIScreen.mainScreen().bounds.width, height: 44)
        navigationController?.navigationBar.insertSubview(tipLabel, atIndex: 0)
        
        // 5.获取微博数据
        loadData()
        tableView.estimatedRowHeight = 100
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showPhotobrowser:"), name: XMGPhotoBrowserShow, object: nil)
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - 内部控制方法
    
    func showPhotobrowser(notify: NSNotification)
    {
        // 0.进行安全校验
        // 一般情况下但凡是通知/网络获取的数据, 都需要校验
        guard let urls = notify.userInfo!["urls"] as? [NSURL] else
        {
            return
        }
        
        guard let path = notify.userInfo!["indexPath"] as? NSIndexPath else
        {
            return
        }
        
        // 1.创建图片浏览器
        let browserVC = PhotoBrowserViewController(urls: urls, path: path)
        
        // 2.弹出图片浏览器
        presentViewController(browserVC, animated: true, completion: nil)
    }
    
    @objc private func loadData()
    {
        
        // 0.准备since_id/ max_id
        var since_id = statuses?.first?.status.idstr ?? "0"
        var max_id = "0"
        if pullupFlag
        {
            max_id = statuses?.last?.status.idstr ?? "0"
            since_id = "0"
        }
        
        // 1.获取微博数据
        modelList.loadStatus(since_id, max_id: max_id) { (models, error) -> () in
            // 1.安全校验
            if error != nil
            {
                SVProgressHUD.showErrorWithStatus("获取微博数据失败", maskType: SVProgressHUDMaskType.Black)
                return
            }
            // 2.显示刷新提醒
            self.showTipView(models!.count)
            
            // 3.设置数据
            self.tableView.reloadData()
            
            // 4.关闭刷新控件
            self.refreshControl?.endRefreshing()
        }
    }
    /// 显示刷新提醒
    private func showTipView(count: Int)
    {
        
        // 0.设置提醒文字
        tipLabel.text = (count == 0) ? "没有更多微博数据" : "刷新到\(count)条微博数据"
        
        // 1.保存原来的frame
        let rect = tipLabel.frame
        
        // 2.执行动画
        UIView.animateWithDuration(2.0, animations: { () -> Void in
            self.tipLabel.frame = CGRect(origin: CGPoint(x: 0, y: 44), size: rect.size)
            }) { (_) -> Void in
                UIView.animateWithDuration(1.0, delay: 1.0, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                    self.tipLabel.frame = rect
                    }, completion: nil)
        }
    }
    /// 初始化导航条
    private func setupNav()
    {
        // 2.1添加左边和右边按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(imageName: "navigationbar_friendattention", target: self, action: Selector("friendBtnClick"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(imageName: "navigationbar_pop", target: self, action: Selector("qrcodeBtnClick"))
        
        // 2.2添加标题按钮
        navigationItem.titleView = titleButton
        
        // 3.注册监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("titleBtnChange"), name: XMGPopoverViewControllerShowClick, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("titleBtnChange"), name: XMGPopoverViewControllerDismissClick, object: nil)
    }
    
    /// 控制标题按钮箭头的方向
    @objc private func titleBtnChange()
    {
        titleButton.selected = !titleButton.selected
    }
    /// 监听标题按钮的点击
    @objc private func titleBtnClick(titleButton: UIButton)
    {
        // 1.创建菜单
        let sb = UIStoryboard(name: "PopoverController", bundle: nil)
        let popoverVC = sb.instantiateInitialViewController()!
        
        // 1.1设置转场的代理
        popoverVC.transitioningDelegate = popoverManager
        // 1.2设置转场样式
        popoverVC.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        // 2.显示菜单
        presentViewController(popoverVC, animated: true, completion: nil)
        
    }
    @objc private func friendBtnClick()
    {
        print("friendBtnClick")
    }
    @objc private func qrcodeBtnClick()
    {
        // 1.创建二维码界面
        let sb = UIStoryboard(name: "QRCodeViewController", bundle: nil)
        let QRCodeVc = sb.instantiateInitialViewController()!
        
        // 2.弹出二维码界面
        presentViewController(QRCodeVc, animated: true, completion: nil)
    }
    
    /// 内存警告
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 接收到内存警告, 将所有缓存移除
        rowHeightCache.removeAll()
    }

    // MARK: - 懒加载
    /// 标题按钮
    private lazy var titleButton: TitleButton = {
        let btn = TitleButton()
        let title = UserAccount.loadUserAccount()!.screen_name ?? "小码哥微博 "
        btn.setTitle(title + " ", forState: UIControlState.Normal)
        btn.addTarget(self, action: Selector("titleBtnClick:"), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    /// 负责自定义转场的对象
    private lazy var popoverManager: PopoverAnimationManager = {
       let manager = PopoverAnimationManager()
        manager.presentedFrame = CGRect(x: 100, y: 56, width: 200, height: 400)
        return manager
    }()
    
    /// 提醒视图
    private lazy var tipLabel: UILabel = {
        // 1.创建UILabel
       let lb = UILabel()
        lb.textAlignment =  NSTextAlignment.Center
        lb.textColor = UIColor.whiteColor()
        lb.backgroundColor = UIColor.orangeColor()
        return lb
    }()
    
}

/// 数据源代理方法
extension HomeTableViewController
{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return statuses?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 1.取出模型
        let viewModel = statuses![indexPath.row]
        
        // 2.根据模型获取cell
        let cell = tableView.dequeueReusableCellWithIdentifier(XMGTableViewCellIdentifier.identifierWithViewModel(viewModel), forIndexPath: indexPath) as! XMGTableViewCell
        
        // 3.设置数据
        cell.viewModel = viewModel
        
        
        // 4.判断是否是最后一个cell
        if indexPath.row == (statuses!.count - 1)
        {
            pullupFlag = true
            loadData()
        }
        return cell
    }
    
    // 返回当前行的行高
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // 0.取出模型
        let viewModel = statuses![indexPath.row]
        
        // 1.从缓存中获取
        if let height = rowHeightCache[viewModel.status.idstr ?? "0"]
        {
            // 有缓存直接返回
            return height
        }
        
        // 没有缓存数据
        // 1.1.拿到当前行的cell
        let cell = tableView.dequeueReusableCellWithIdentifier(XMGTableViewCellIdentifier.identifierWithViewModel(viewModel)) as! XMGTableViewCell
        
        // 1.2.计算行高
        let height = cell.caculateRowHeight(viewModel)
        
        // 1.3 将计算结果缓存起来
        rowHeightCache[viewModel.status.idstr ?? "0"] = height
        
        // 1.4返回行高
        return height
    }
}


