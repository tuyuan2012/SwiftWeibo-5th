//
//  OAuthViewController.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/9.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
import SVProgressHUD

class OAuthViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1.加载登录界面
        loadPage()
    }
    
    // MARK: - 内部控制方法
    @IBAction func leftBtnClick(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// 自定义填充账号密码
    @IBAction func rightBtnClick(sender: AnyObject) {
         let js = "document.getElementById('userId').value = '1606020376@qq.com';"  +
            "document.getElementById('passwd').value = 'haomage';"
        webView.stringByEvaluatingJavaScriptFromString(js)
    }
    
    /// 加载登录界面
    private func loadPage()
    {
        let str = "https://api.weibo.com/oauth2/authorize?client_id=\(WB_App_Key)&redirect_uri=\(WB_Redirect_URI)"
        guard let url = NSURL(string: str) else
        {
            return
        }
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }

}
extension OAuthViewController: UIWebViewDelegate
{
    func webViewDidStartLoad(webView: UIWebView) {
        // 显示提醒, 提醒用户正在加载登陆界面
        SVProgressHUD.showInfoWithStatus("正在加载...", maskType: SVProgressHUDMaskType.Black)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        // 关闭提醒
        SVProgressHUD.dismiss()
    }
    
    /// webview每次请求一个新的地址都会调用该方法, 返回true代表允许访问, 返回flase代表不允许方法
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        // 1.判断是否是授权回调地址, 如果不是就允许继续跳转
        guard let urlStr = request.URL?.absoluteString where urlStr.hasPrefix(WB_Redirect_URI)  else
        {
            // : https://api.weibo.com/
            return true
        }
        
        // 2.判断是否授权成功
        let code = "code="
        guard urlStr.containsString(code) else
        {
            // 授权失败
            return false
        }
        
        // 3.授权成功
        if let temp = request.URL?.query
        {
            // 3.1截取code=后面的字符串
            let codeStr = temp.substringFromIndex(code.endIndex)
            
            // 3.2利用RequestToken换取AccessToken
            loadAccessToken(codeStr)
        }
        
        
        return false
    }
    
    /// 根据RequestToken换取AccessToken
    private func loadAccessToken(codeStr: String)
    {
        NetworkTools.shareInstance.loadAccessToken(codeStr) { (dict, error) -> () in
            
            // 0.进行安全校验
            if let _ = error
            {
                SVProgressHUD.showErrorWithStatus("换取AccessToken错误", maskType: SVProgressHUDMaskType.Black)
                return
            }
            
            guard let res = dict else
            {
                SVProgressHUD.showErrorWithStatus("服务器返回的数据是nil", maskType: SVProgressHUDMaskType.Black)
                return
            }
            
            
            // 1.将授权信息转换为模型
            let userAccount = UserAccount(dict: res)
            
            // 2.根据授权信息获取用户信息
            self.loadUserInfo(userAccount)
            
        }
    }
    
    /// 获取用户信息
    private func loadUserInfo(account: UserAccount)
    {
        
        NetworkTools.shareInstance.loadUserInfo(account) { (dict, error) -> () in
            // 0.进行安全校验
            if let _ = error
            {
                SVProgressHUD.showErrorWithStatus("获取用户信息失败", maskType: SVProgressHUDMaskType.Black)
                return
            }
            
            guard let res = dict else
            {
                SVProgressHUD.showErrorWithStatus("服务器返回的数据是nil", maskType: SVProgressHUDMaskType.Black)
                return
            }
            
            // 1.取出获取到的用户信息
            account.screen_name = res["screen_name"] as? String
            account.avatar_large = res["avatar_large"] as? String
            
            // 2.保存授权信息
            account.saveAccount()
            
            // 3.切换到欢迎界面
            // 发送通知, 通知AppDelegate切换根控制器
            NSNotificationCenter.defaultCenter().postNotificationName(XMGRootViewControllerChnage, object: self, userInfo: ["message": true])
        }
    }

}
