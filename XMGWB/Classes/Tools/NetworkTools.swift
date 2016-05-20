//
//  NetworkTools.swift
//  XMGWB
//
//  Created by xiaomage on 15/11/10.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
import AFNetworking

class NetworkTools: AFHTTPSessionManager {
    
    /// 单例
    static let shareInstance: NetworkTools = {
        // 注意: 指定BaseURL时一定要包含/
        let url = NSURL(string: "https://api.weibo.com/")
        let instance = NetworkTools(baseURL: url, sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
        instance.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json", "text/json", "text/javascript", "text/plain") as Set<NSObject>
        return instance
    }()

    // MARK: - 外部控制方法
    // 根据RequestToken换取AccessToken
    func loadAccessToken(codeStr: String, finished: (dict: [String: AnyObject]?, error: NSError?)->())
    {
        let path = "oauth2/access_token"
        
        let parameters = ["client_id": WB_App_Key, "client_secret": WB_App_Secret, "grant_type": "authorization_code", "code": codeStr, "redirect_uri": WB_Redirect_URI]
        
        NetworkTools.shareInstance.POST(path, parameters: parameters, success: { (task, objc) -> Void in
                // 执行回调
                finished(dict: objc as? [String : AnyObject], error: nil)
            }) { (task, error) -> Void in
                // 执行回调
                finished(dict: nil, error: error)
        }
    }
    
    /// 获取用户信息
    func loadUserInfo(account: UserAccount, finished: (dict: [String: AnyObject]?, error: NSError?)->())
    {
        let path = "2/users/show.json"
        
        let parameters = ["access_token": account.access_token!, "uid": account.uid!]
        
        NetworkTools.shareInstance.GET(path, parameters: parameters, success: { (task, objc) -> Void in
            
            // 1.执行回调
            finished(dict: objc as? [String : AnyObject], error: nil)
            
            }) { (task, error) -> Void in
                // 1.执行回调
                finished(dict: nil, error: error)
        }
    }
    
    /// 获取微博数据
    func loadStatus(since_id: String,  max_id: String,finished: (dicts: [[String: AnyObject]]?, error: NSError?)->())
    {
        let path = "2/statuses/home_timeline.json"
        
        assert(UserAccount.loadUserAccount() != nil, "必须授权之后才能获取微博数据")
        
        var parameters = ["access_token": UserAccount.loadUserAccount()!.access_token!]
        if since_id != "0"
        {
            parameters["since_id"] = since_id
        }else if max_id != "0"
        {
           let temp = Int(max_id)! - 1
           parameters["max_id"] = "\(temp)"
        }
        
        NetworkTools.shareInstance.GET(path, parameters: parameters, success: { (task, objc) -> Void in
            
            // 1.从服务器返回的字典中取出字典数组
            guard let array = (objc as! [String : AnyObject])["statuses"] else
            {
                finished(dicts: nil, error: NSError(domain: "com.520it.lnj", code: 1001, userInfo: ["message": "没有找到statuses这个key"]))
                return
            }
                finished(dicts: array as? [[String : AnyObject]], error: nil)
            }) { (task, error) -> Void in
                finished(dicts: nil, error: error)
        }
    }
    
    /// 发送微博的接口
    func sendStatus(statusText : String, image : UIImage?, finished : (dict : [String : AnyObject]?, error : NSError?) -> ()) {
        // 定义路径
        var path = "/2/statuses/"
        
        // 定义参数
        let parameters = ["access_token": UserAccount.loadUserAccount()!.access_token!, "status" : statusText]
        
        if image == nil {
            // 1.获取发送微博的路径
            path += "update.json"
            
            // 2.发送微博
            POST(path, parameters: parameters, success: { (task, objc) -> Void in
                finished(dict: objc as? [String : AnyObject], error: nil)
                }, failure: { (task, error) -> Void in
                finished(dict: nil, error: error)
            })
            
        } else {
            // 1.获取发送微博的路径(带图片)
            path += "upload.json"
            
            // 2.发送微博
            POST(path, parameters: parameters, constructingBodyWithBlock: { (formData) -> Void in
                // 1.将UIImage对象转成NSData类型
                let imageData = UIImagePNGRepresentation(image!)!
                
                // 2.拼接图片内容
                formData.appendPartWithFileData(imageData, name: "pic", fileName: "123.png", mimeType: "image/png")
                }, success: { (task, objc) -> Void in
                    finished(dict: objc as? [String : AnyObject], error: nil)
                }, failure: { (task, error) -> Void in
                    finished(dict: nil, error: error)
            })
        }
    }
}
