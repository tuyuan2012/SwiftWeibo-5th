//
//  ComposeViewController.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/16.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
import SVProgressHUD

class ComposeViewController: UIViewController {
    
    // MARK:- 属性
    /// 工具条底部约束
    @IBOutlet weak var toolbarBottomCons: NSLayoutConstraint!
    
    // 容器视图高度约束
    @IBOutlet weak var containerViewHeightCons: NSLayoutConstraint!
    
    /// 自定义TextView
    @IBOutlet weak var statusTextView: ComposeTextView!
    
    // 提醒用户输入的数字的Label
    @IBOutlet weak var tipLabel: UILabel!
    
    // 规定用户一共可以输入多少内容
    let maxCount = 140
    
    // 照片选中控制器的属性
    var photoPickerVc : PhotoPickerViewController?
    
    // 懒加载表情键盘的控制器
    lazy var keyboardEmoticonVc : XMGKeyboardEmoticonViewController = XMGKeyboardEmoticonViewController {[unowned self] (emoticon) -> () in
        self.statusTextView.insertEmoticon(emoticon)
        
        // 当插入表情时,主动调用textView的文字发生改变的函数
        self.textViewDidChange(self.statusTextView)
    }
    
    // MARK:- 监听按钮的点击
    /// 监听图片按钮的点击
    @IBAction func pictureBtnClick(sender: AnyObject) {
        // 1.显示containnerView
        containerViewHeightCons.constant = UIScreen.mainScreen().bounds.height * 0.7
        UIView.animateWithDuration(0.4) { () -> Void in
            self.view.layoutIfNeeded()
        }
        
        // 2.退出键盘
        statusTextView.resignFirstResponder()
    }
    /// 监听表情按钮点击
    @IBAction func emoticonBtnClick(sender: AnyObject) {
        // 1.退出键盘
        self.statusTextView.resignFirstResponder()
        
        // 2.切换键盘
        if self.statusTextView.inputView == nil { // 切换成表情键盘
            self.statusTextView.inputView = keyboardEmoticonVc.view
        } else { // 切换普通键盘
            self.statusTextView.inputView = nil
        }
        
        // 3.弹出键盘
        self.statusTextView.becomeFirstResponder()
    }
    
    /// 监听取消按钮的点击
    @IBAction func cancleBtnClick(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// 监听发送按钮点击
    @IBAction func sendBtnClick(sender: AnyObject) {
        // 1.取出图片
        let image = photoPickerVc?.images.last
        
        // 2.取出发送微博的内容
        let statusText = statusTextView.emoticonStr()
        
        // 3.提醒用户正在发送微博
        SVProgressHUD.showWithStatus("正在发送微博", maskType: SVProgressHUDMaskType.Black)
        
        // 4.退出键盘
        statusTextView.resignFirstResponder()
        
        // 5.发送微博
        NetworkTools.shareInstance.sendStatus(statusText, image: image) { (dict, error) -> () in
            if error != nil {
                
                // 提醒用户发送微博失败
                SVProgressHUD.showInfoWithStatus("发送微博失败", maskType: SVProgressHUDMaskType.Black)
                
                return
            }
            
            if dict != nil {
                
                // 提醒用户发送微博成功
                SVProgressHUD.showInfoWithStatus("发送微博成功", maskType: SVProgressHUDMaskType.Black)
                
                // 退出控制器
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    
    
    // MARK:- 系统调用的方法
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.设置textView代理
        statusTextView.delegate = self
        
        // 2.监听键盘变化
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChange:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        // 3.设置容器视图的高度为0
        containerViewHeightCons.constant = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if containerViewHeightCons.constant == 0 {
            // 召唤键盘
            statusTextView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // 注销键盘
        statusTextView.resignFirstResponder()
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "phtotPicker" {
            photoPickerVc = segue.destinationViewController as? PhotoPickerViewController
        }
    }
    
    // MARK: - 内部控制方法
    @objc private func keyboardWillChange(note: NSNotification)
    {
        // 获取键盘弹出和退出的时间
        let durationTime = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        // 获取和底部的差距
        let endFrame = note.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue;
        let margin = view.frame.size.height - endFrame.origin.y
        
        // 改变约束,并且执行动画
        toolbarBottomCons.constant = margin
        UIView.animateWithDuration(durationTime) { () -> Void in
            // 如果执行多次动画,则忽略上一次已经未完成的动画,直接进入下一次
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: 7)!)
            self.view.layoutIfNeeded()
        }
    }

}


extension ComposeViewController: UITextViewDelegate
{
    func textViewDidChange(textView: UITextView) {
        // 1.发送按钮是否可以点击和占位label是否显示
        navigationItem.rightBarButtonItem?.enabled = textView.hasText()
        self.statusTextView.placeholderLabel.hidden = textView.hasText()
        
        // 2.计算用于当前还可以输入多少内容
        // 2.1.拿到用户已经输入了多少内容
        let currentCount = self.statusTextView.emoticonStr().characters.count
        
        // 2.2.计算用户还可以输入多少内容
        let leftCount = maxCount - currentCount
        
        // 3.在tipLabel中显示当前的个数
        tipLabel.text = "\(leftCount)"
        
        // 4.如果剩余的个数小于0,则让发送按钮不能点击
        navigationItem.rightBarButtonItem?.enabled = leftCount >= 0
        
        // 5.如果剩余的个数小于0,则让tipLabel显示红色的文字
        tipLabel.textColor = leftCount >= 0 ? UIColor.lightGrayColor() : UIColor.redColor()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        statusTextView.resignFirstResponder()
    }
}
