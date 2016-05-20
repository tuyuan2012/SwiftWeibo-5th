//
//  XMGKeyboardPackage.swift
//  表情键盘
//
//  Created by xiaomage on 15/12/9.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit
/**
 说明：
 1. Emoticons.bundle 的根目录下存放的 emoticons.plist 保存了 packages 表情包信息
     >packages 是一个数组, 数组中存放的是字典
     >字典中的属性 id 对应的分组路径的名称
 2. 在 id 对应的目录下，各自都保存有 info.plist
     >group_name_cn   保存的是分组名称
     >emoticons       保存的是表情信息数组
     >code            UNICODE 编码字符串
     >chs             表情文字，发送给新浪微博服务器的文本内容
     >png             表情图片，在 App 中进行图文混排使用的图片
 */
class XMGKeyboardPackage: NSObject {
    /// 当前组的名称
    var group_name_cn: String?
    /// 当前组对应的文件夹名称
    var id: String?
    /// 当前组所有的表情
    var emoticons: [XMGKeyboardEmoticon]?
    
    init(id: String) {
        self.id = id
    }
    
    /// 加载所有组数据
    class func loadEmotionPackages() -> [XMGKeyboardPackage] {
        
        var models = [XMGKeyboardPackage]()
        // 0.手动添加最近组
        let package = XMGKeyboardPackage(id: "")
        package.appendEmptyEmoticons()
        models.append(package)
        
        // 1.加载emoticons.plist文件
        // 1.1获取emoticons.plist文件路径
        let path = NSBundle.mainBundle().pathForResource("emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        // 1.2加载emoticons.plist
        let dict = NSDictionary(contentsOfFile: path)!
        let array = dict["packages"] as! [[String: AnyObject]]
        // 2.取出所有组表情
        
        for packageDict in array
        {
            // 2.1创建当前组模型
            let package = XMGKeyboardPackage(id: packageDict["id"] as! String)
            // 2.2加载当前组所有的表情数据
            package.loadEmoticons()
            // 2.3补全一组数据, 保证当前组能被21整除
            package.appendEmptyEmoticons()
            // 2.4将当前组模型添加到数组中
            models.append(package)
        }
        return models
    }
    
    /// 加载当前组所有表情
    private func loadEmoticons()
    {
        // 1.拼接当前组info.plist路径
        let path = NSBundle.mainBundle().pathForResource(self.id, ofType: nil, inDirectory: "Emoticons.bundle")!
        let filePath = (path as NSString).stringByAppendingPathComponent("info.plist")
        // 2.根据路径加载info.plist文件
        let dict = NSDictionary(contentsOfFile: filePath)!
        // 3.从加载进来的字典中取出当前组数据
        // 3.1取出当前组名称
        group_name_cn = dict["group_name_cn"] as? String
        // 3.2取出当前组所有表情
        let array = dict["emoticons"] as! [[String: AnyObject]]
        // 3.3遍历数组, 取出每一个表情
        var models = [XMGKeyboardEmoticon]()
        
        var index = 0
        for emoticonDict in array
        {
            if index == 20
            {
               let emoticon = XMGKeyboardEmoticon(isRemoveButton: true)
                models.append(emoticon)
                index = 0
                continue
            }
            
            let emoticon = XMGKeyboardEmoticon(dict: emoticonDict, id: self.id!)
            models.append(emoticon)
            index++
        }
        emoticons = models
    }
    
    /// 补全一组数据, 保证当前组能被21整除
    private func appendEmptyEmoticons()
    {
        // 0.判断是否是最近组
        if emoticons == nil
        {
            emoticons = [XMGKeyboardEmoticon]()
        }
        
        // 1.取出不能被21整除剩余的个数
        let number = emoticons!.count % 21
//        print(emoticons!.count)
//        print(number)
        // 2.补全
        for _ in number..<20
        {
            let emoticon = XMGKeyboardEmoticon(isRemoveButton: false)
            emoticons?.append(emoticon)
        }
//        print(emoticons!.count)
        // 3.补全删除按钮
        let emoticon = XMGKeyboardEmoticon(isRemoveButton: true)
        emoticons?.append(emoticon)
    }
    
    /// 添加最近表情
    func addFavoriteEmoticon(emoticon: XMGKeyboardEmoticon)
    {
         emoticons?.removeLast()
        
        // 1.判断当前表情是否已经添加过了
        if !emoticons!.contains(emoticon)
        {
            // 2.添加当前点击的表情到最近
            emoticons?.removeLast()
            emoticons?.append(emoticon)
        }

        // 3.对表情进行排序
        let array =  emoticons?.sort({ (e1, e2) -> Bool in
            return e1.count > e2.count
        })
        emoticons = array
        
        // 4.添加一个删除按钮
        emoticons?.append(XMGKeyboardEmoticon(isRemoveButton: true))
        
    }
}

extension XMGKeyboardPackage
{
    class func createMutableAttrString(str : String, font : UIFont) -> NSMutableAttributedString {
        // 1.1.表情的规则
        let pattern = "\\[.*?\\]"
        
        // 2.利用规则创建一个正则表达式对象
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
        
        // 3.匹配结果
        let results = regex.matchesInString(str, options: NSMatchingOptions(rawValue: 0), range: NSRange(location: 0, length: str.characters.count))
        
        // 4.创建一个属性字符串
        let attrMStr = NSMutableAttributedString(string: str)
        // for result in results {
        for var i = results.count - 1; i >= 0; i-- {
            // 4.1.取出匹配结果的chs
            let result = results[i]
            let chs = (str as NSString).substringWithRange(result.range)
            
            // 4.2.查找chs对应的pngPath
            let pngPath = findPngPath(chs)
            
            // 4.3.根据路径创建属性字符串
            guard let tempPngPath = pngPath else {
                continue
            }
            let attachment = NSTextAttachment()
            attachment.image = UIImage(contentsOfFile: tempPngPath)
            attachment.bounds = CGRect(x: 0, y: -4, width: font.lineHeight, height: font.lineHeight)
            let emoAttrStr = NSAttributedString(attachment: attachment)
            
            // 4.4.将之前字符串中chs替换成表情
            attrMStr.replaceCharactersInRange(result.range, withAttributedString: emoAttrStr)
        }
        
        return attrMStr
    }
    
    class func findPngPath(chs : String) -> String? {
        // 1.加载所有的表情
        let packages = XMGKeyboardPackage.loadEmotionPackages()
        
        // 2.遍历所有的表情包,拿到chs对应的pngPath
        for package in packages {
            // 2.1.如果表情包没有值,则该表情包不需要再进行遍历
            guard let emoticons = package.emoticons else {
                print("该表情包没有值")
                continue
            }
            
            // 2.2.定义表情pngPath
            var pngPath : String?
            
            // 2.3.遍历每一个表情包中的表情
            for emoticon in emoticons {
                // 2.3.1.如果该表情的chs属性为空,则遍历下一个表情
                guard let emoticonChs = emoticon.chs else {
                    continue
                }
                
                // 2.3.2.如果chs不为空,则判断表情的chs是否和传入的chs相等
                // 如果相同:则将pngPath取出
                if emoticonChs == chs {
                    pngPath = emoticon.pngPath
                    break
                }
            }
            
            // 2.4.如果遍历了一个表情包种已经取出了pngPath,则不需要再遍历下一个表情包
            if pngPath != nil {
                return pngPath
            }
        }
        
        // 3.如果遍历了所以的表情包依然没有值,则直接返回nil
        return nil
    }
}

class XMGKeyboardEmoticon: NSObject {
    
    /// 当前组对应的文件夹名称
    var id: String?
    
    /// 当前表情对应的字符串
    var chs: String?
    
    /// 当前表情对应的图片
    var png: String?
        {
        didSet
        {
            let path = NSBundle.mainBundle().pathForResource(id, ofType: nil, inDirectory: "Emoticons.bundle")!
            pngPath = (path as NSString).stringByAppendingPathComponent(png ?? "")
        }
    }
    
    /// 当前表情图片的绝对路径
    var pngPath: String?
    
    /// Emoji表情对应的字符串
    var code: String?
        {
        didSet
        {
            // 1.创建一个扫描器
            let scanner = NSScanner(string: code ?? "")
            // 2.从字符串中扫描出对应的16进制数
            var result: UInt32 = 0
            scanner.scanHexInt(&result)
            // 3.根据扫描出的16进制创建一个字符串
            emoticonStr = "\(Character(UnicodeScalar(result)))"
        }
    }
    /// 转换之后的emoji表情字符串
    var emoticonStr: String?
    
    /// 记录当前表情是否是删除按钮
    var isRemoveButton: Bool = false
    
    /// 记录当前表情的使用次数
    var count: Int = 0
    
    init(dict: [String: AnyObject], id: String)
    {
        self.id = id
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    init(isRemoveButton: Bool)
    {
        self.isRemoveButton = isRemoveButton
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
}
