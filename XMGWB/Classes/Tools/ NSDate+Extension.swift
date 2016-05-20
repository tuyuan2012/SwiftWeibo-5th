//
//   NSDate+Extension.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/12.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit

extension NSDate
{
    /// 根据制定字符串转换NSDate
    class func dataWithString(str: String) -> NSDate? {
        // 1.将发布微博的时间转换为NSDate
        // 1.1创建时间格式化对象
        let formatter = NSDateFormatter()
        // 1.2初始化时间格式化对象  "Tue May 31 17:46:55 +0800 2011"
        formatter.dateFormat = "EEE MM dd HH:mm:ss Z yyyy"
        formatter.locale = NSLocale(localeIdentifier: "en")
        
        // 1.3将发布微博的时间字符串转换为NSDate
        return formatter.dateFromString(str)
    }
    
    /// 返回格式化之后的时间字符串
    var desc: String
        {
            // 1.1创建时间格式化对象
            let formatter = NSDateFormatter()
            // 1.2初始化时间格式化对象  "Tue May 31 17:46:55 +0800 2011"
            formatter.locale = NSLocale(localeIdentifier: "en")
            
            // 日历
            let calendar = NSCalendar.currentCalendar()
            
            // 发布时间: 2014-11-12 00:00:00
            // 当前时间: 2015-10-11 00:00:00
            if calendar.isDateInToday(self)
            {
                // 2.1获取当前时间和发布时间之间的时间差
                let timeInterval = Int(NSDate().timeIntervalSinceDate(self))
                
                if timeInterval < 60
                {
                    return "刚刚"
                }else if timeInterval < 60 * 60
                {
                    return "\(timeInterval / 60)分钟以前"
                }else if timeInterval < 60 * 60 * 24
                {
                    return "\(timeInterval / (60 * 60))小时前"
                }
                
            }
            
            // 昨天
            var formatterStr = "HH:mm"
            let comps = calendar.components(NSCalendarUnit.Year, fromDate: self, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))
            if calendar.isDateInYesterday(self)
            {
                formatterStr = "昨天 " + formatterStr
            }else if comps.year < 1
            {
                // 一年以内
                formatterStr = "MM-dd " + formatterStr
            }else
            {
                // 更早时间
                formatterStr = "yyyy-MM-dd " + formatterStr
            }
            
            formatter.dateFormat = formatterStr
            return formatter.stringFromDate(self)
    }
}
