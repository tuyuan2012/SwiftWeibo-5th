//
//  StatusViewModel.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/12.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit

/*
Swift中一个类可以有父类也可以没有父类
如果一个类没有父类, 那么这个类更加轻量级, 那么他们性能会更优于有父类的

有父类和没有父类有什么区别?
1.如果想使用KVC, 那么必须继承于NSObject
2.如果想实现description属性, 那么如果没有父类必须遵守CustomStringConvertible, 如果有父类可以直接重写属性即可
*/
//class StatusViewModel: NSObject {
class StatusViewModel {

    /// 模型对象
    var status: Status
    
    init(status: Status)
    {
        self.status = status
        
        /*
        想要性能比较好, 就将固定不变的数据放在init方法中处理, 如果代码较多, 那么就为每个逻辑创建一个方法, 将对应的代码放到方法中去
        如果不在乎性能, 可以直接通过get方法处理数据
        */
        
        // 2.处理图片
        guard let urls = (status.retweeted_status != nil) ? status.retweeted_status?.pic_urls : status.pic_urls else
        {
            return
        }
        
        thumbnail_pics = [NSURL]()
        bmiddle_pics = [NSURL]()
        for dict in urls
        {
            // 1.处理缩略图
            var urlStr = dict["thumbnail_pic"] as? String
            let url = NSURL(string: urlStr ?? "")!
            thumbnail_pics?.append(url)
            
            // 2.处理大图
            guard let temp = urlStr where temp != ""  else
            {
                return
            }
            urlStr = temp.stringByReplacingOccurrencesOfString("thumbnail", withString: "bmiddle")
            let url2 = NSURL(string: urlStr!)!
            bmiddle_pics?.append(url2)

        }
    }
    
    // MARK: - 数据处理
    
    /// 来源字符串
    var sourceText: String
        {
            // 1.处理来源
            // 1.1.安全校验
            guard let temp = status.source where temp != "" else
            {
                return ""
            }
            // 1.2.找到开始的位置
            let startIndex = (temp as NSString).rangeOfString(">").location + 1
            
            // 1.3.找到需要截取的字符串的长度
            let length = (temp as NSString).rangeOfString("<", options: NSStringCompareOptions.BackwardsSearch).location - startIndex
            
            // 1.4.截取字符串
            let res = (temp as NSString).substringWithRange(NSMakeRange(startIndex, length))
             return "来自 " + res
    }
    
    /**
     刚刚(一分钟内)
     X分钟前(一小时内)
     X小时前(当天)
     
     昨天 HH:mm(昨天)
     
     MM-dd HH:mm(一年内)
     yyyy-MM-dd HH:mm(更早期)
     */
    var createdText: String{
        
        // 0.安全校验
        // 先检查created_at是否有值, 如果没有就进入else
        // 并且temp 不能是 "", 如果是""就进入else
        guard let temp = status.created_at where temp != "" else
        {
            return ""
        }
        
        // 1.将发布微博的时间字符串转换为NSDate
        guard let createDate = NSDate.dataWithString(temp) else
        {
            return ""
        }
        
        // 2.利用微博发布的时间和当前本机的时间进行比较
        return createDate.desc
        
    }
    
    /// 存储所有配图URL
    var thumbnail_pics: [NSURL]?
    
    /// 存储所有配图大图URL
    var bmiddle_pics: [NSURL]?
    
    /// 用户头像URL
    var avatarURL: NSURL
        {
            // 3.处理头像
           return NSURL(string: status.user?.profile_image_url ?? "")!
    }
    
    /// 认证图片
    var verifiedImage: UIImage?
        {
            //  4.处理认证图片
            switch status.user?.verified_type ?? -1
            {
            case 0:
                // 个人认证
                return UIImage(named: "avatar_vip")
            case 2, 3, 5:
                // 企业认证
                return UIImage(named: "avatar_enterprise_vip")
            case 220:
                // 微博达人
                return UIImage(named: "avatar_grassroot")
            default:
                // 没有认证
                return nil
            }
    }
    
    /// 会员图片
    var mbrankImage: UIImage?
        {
            // 5.处理会员图标
            if status.user?.mbrank >= 1 && status.user?.mbrank <= 6
            {
                return  UIImage(named: "common_icon_membership_level\(status.user!.mbrank)")
            }
            return nil
    }
}
