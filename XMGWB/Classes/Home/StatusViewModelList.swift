//
//  StatusViewModelList.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/13.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
import SDWebImage

// 专门用户获取数据
class StatusViewModelList {
    
    /// 保存所有微博数据
    var statuses: [StatusViewModel]?
    
    /// 获取微博数据
    func loadStatus(since_id: String,  max_id: String,finished: (models: [StatusViewModel]?, error: NSError?)->())
    {
        // 1.获取微博数据
        NetworkTools.shareInstance.loadStatus(since_id, max_id: max_id) { (dicts, error) -> () in
            
            // 1.安全校验
            if error != nil
            {
                finished(models: nil, error: error)
                return
            }
            
            guard let array = dicts else
            {
               finished(models: nil, error: NSError(domain: "com.520it.lnj", code: 1002, userInfo: ["message": "没有获取到微博数据"]))
                return
            }
            
            // 2.遍历字典数组, 处理微博数据
            var models = [StatusViewModel]()
            for dict in array
            {
                models.append(StatusViewModel(status:Status(dict: dict)))
            }
            
            // 3.处理下拉刷新的数据
            if since_id != "0"
            {
                // 将新的数据凭借到旧数据前面
                self.statuses = models + self.statuses!
                
            }else if max_id != "0"
            {
                // 将新的数据拼接到旧数据后面
                self.statuses = self.statuses! + models
            }else{
                self.statuses = models
            }

            // 4.缓存配图
            self.cacheImage(models, finished: finished)
        }
    }
    
    /// 缓存配图
    private func cacheImage(list: [StatusViewModel], finished: (models: [StatusViewModel]?, error: NSError?)->())
    {
        
        // 0.创建一个组
        let group = dispatch_group_create()
        
        // 1.取出所有微博模型
        for viewModel in list
        {
            // 2.安全校验
            guard let urls = viewModel.thumbnail_pics else
            {
                continue
            }
            
            // 3.从微博模型中取出所有的配图字典
            for url in urls
            {
                // 将当前操作添加到组中
                dispatch_group_enter(group)
                
                // 4.下载图片
                // 注意:downloadImageWithURL方法下载图片是在子线程下载的, 而回调是在主线程回调
                SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (_, error, _, _, _) -> Void in
                    
                    // 将当前操作从组中移除
                    dispatch_group_leave(group)
                })
            }
            
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            // 执行回调
            finished(models: list, error: nil)
        }
    }
}
