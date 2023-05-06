//
//  WKWebview+dl.swift
//  DLCommon
//
//  Created by morgan on 12/04/2023.
//

import Foundation
import WebKit

private var kCustomCookieKey: String = "kCustomCookieKey"
extension WKWebView {
    public static func swizzle() {
        // 交换系统的 load方法 处理请求头中的cookie
        if self != WKWebView.self {
            return
        }
        
        let _:() = {
            let originalSelector = #selector(WKWebView.load(_:))
            let swizzledSelector = #selector(WKWebView.swizzleLoad(_:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }()
    }
    
    /// 拦截 系统的 loadRequest方法，插入我们自定义的cookie到请求头中
    @objc dynamic func swizzleLoad(_ request: URLRequest) -> WKNavigation? {
        var mutRequest = request
        
        if let customCookieDic = self.customCookieKeyValue {
            var cookie = ""
            for (key, value) in customCookieDic {
                let keyValue = "\(key)=\(value);"
                cookie += keyValue
            }
            mutRequest.setValue(cookie, forHTTPHeaderField: "Cookie")
        }
        
        return swizzleLoad(mutRequest)
    }
    
    public var customCookieKeyValue: [String: String]? {
        get {
            return objc_getAssociatedObject(self, &kCustomCookieKey) as? [String: String]
        }
        set {
            objc_setAssociatedObject(self, &kCustomCookieKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

private let kMWCookieJSCodeTag = "// 这是一个代码片段标示，用于删除某个WKUserScript代码片段的标记"
extension WKWebView {
    public func startCustomCookie() {
        addAppJsCode()
        reloadCookie()
    }
    
    /**
     刷新设置cookie
     */
    public func reloadCookie() {
        // 删除所有自定义cookie
        removeAllTagCookie()
        
        //重新添加cookie
        if let customCookieDic = self.customCookieKeyValue {
            for (key, value) in customCookieDic {
                addCookie(with: key, value: value)
            }
        }
    }
    
    /**
     设置 App 基本支持的JS代码
     */
    fileprivate func addAppJsCode() {
        guard let filePath = Bundle.load(from: "DLCommon")?.path(forResource: "MWWMCookie", ofType: "js") else {
            print("js file not found")
            return
        }
        do {
            let jsCode = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            let cookieInScript = WKUserScript(source: jsCode, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(cookieInScript)
        } catch {
            print(error)
        }
    }
    
    /**
     添加某个cookie
     */
    public func addCookie(with key: String, value: String) {
        // 防止直接调用此方法设置后，reload时不能添加的问题
        if customCookieKeyValue?[key] == nil {
            customCookieKeyValue?[key] = value
        }
        
        let jsCode = "app_setCookie('\(key)','\(value)')"
        evaluateJavaScript(jsCode, completionHandler: nil)
        
        // 代码片段标签
        let tag = customJsCodeTag(with: key)
        // 先删除原来的代码片段
        deleteUserScript(with: tag)
        // 再添加新的
        addUserScript(with: jsCode, tag: tag)
    }
    
    /**
     删除某个cookie
     */
    public func removeCookie(with key: String) {
        customCookieKeyValue?[key] = nil
        
        // 删除浏览器的某个cookie
        let jsCode = "app_deleteCookie('\(key)')"
        evaluateJavaScript(jsCode, completionHandler: nil)

        // 删除添加cookie的脚本代码
        deleteUserScript(with: customJsCodeTag(with: key))
    }
    
    /**
     删除所有的标签（app自定义）cookie
     */
    public func removeAllTagCookie() {
        if let customCookieDic = self.customCookieKeyValue {
            for (key, _) in customCookieDic {
                let jsCode = "app_deleteCookie('\(key)')"
                evaluateJavaScript(jsCode, completionHandler: nil)
            }
        }
        // 删除所有的本地自定义js 设置cookie的脚本
        deleteUserScript(with: customJsCodeTag(with: ""))
        
        self.customCookieKeyValue = nil
    }
    
    /**
     添加某个代码片段
     
     @param jsCode 插入的js代码
     @param tag tag 片段标示
     */
    fileprivate func addUserScript(with jsCode: String, tag: String) {
        let cookieInScript = WKUserScript(source: "\(jsCode) \ntag", injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(cookieInScript)
    }
    
    /**
     删除某个代码片段
     
     @param tag 片段标示, （敲黑板）注意：当 tag == 宏定义 kJhuCookieJsCodeTag时，将删除所有的自定义cookie
     */
    fileprivate func deleteUserScript(with tag: String) {
        var scriptList = configuration.userContentController.userScripts
        let newList = scriptList.filter { !$0.source.contains(tag) }
        if scriptList != newList {
            configuration.userContentController.removeAllUserScripts()
            newList.forEach({
                configuration.userContentController.addUserScript($0)
            })
        }
    }
    
    /**
     自定义js脚本片段的一个标示，用于删除某段代码片段
     
     @param key cookie name
     @return 拼接后的代码片段标示
     */
    fileprivate func customJsCodeTag(with key: String) -> String {
        return kCustomCookieKey + key
    }
}
