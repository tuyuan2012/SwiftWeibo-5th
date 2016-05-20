//
//  ProgressView.swift
//  01-进度条View
//
//  Created by xiaomage on 15/11/16.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit


class ProgressView: UIView {

    /// 进度 0~1
    var progregss: CGFloat = 0.0
        {
        didSet{
            // 只要接收到新的数据就绘制圆形
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        // 控制下载进度, 如果完成就消失
        if progregss >= 1.0
        {
            return
        }
        
        // 画圆
//        圆心
        let center = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
//        半径
        let radius = min(bounds.width * 0.5, bounds.height * 0.5)
//        开始位置
        let start = -CGFloat(M_PI_2)
//        结束位置
        let end = CGFloat(2 * M_PI) * progregss + start
        
        // 设置圆形参数
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
        
        // 连接到圆心
        path.addLineToPoint(center)
        
        // 关闭路径
        path.closePath()
        
        UIColor(white: 0.5, alpha: 0.8).setFill()
        
        path.fill()
    }

}
