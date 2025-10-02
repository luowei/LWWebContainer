# LWWebContainer

[![CI Status](https://img.shields.io/travis/luowei/LWWebContainer.svg?style=flat)](https://travis-ci.org/luowei/LWWebContainer)
[![Version](https://img.shields.io/cocoapods/v/LWWebContainer.svg?style=flat)](https://cocoapods.org/pods/LWWebContainer)
[![License](https://img.shields.io/cocoapods/l/LWWebContainer.svg?style=flat)](https://cocoapods.org/pods/LWWebContainer)
[![Platform](https://img.shields.io/cocoapods/p/LWWebContainer.svg?style=flat)](https://cocoapods.org/pods/LWWebContainer)

## 简介

LWWebContainer 是一个基于 WKWebView 的 iOS Web 容器组件，提供类似原生浏览器的交互体验，支持在新容器中打开 Web 页面。该组件封装了 WKWebView 的常用功能，简化了 Web 容器的开发流程，适用于需要内嵌 Web 页面的 iOS 应用。

## 主要特性

- **基于 WKWebView**：采用 iOS 系统推荐的 WKWebView，性能优异
- **新标签页支持**：支持在新容器中打开链接，仿浏览器多标签页体验
- **进度指示**：内置加载进度条，提供更好的用户反馈
- **导航控制**：完善的前进、后退、刷新等导航功能
- **Cookie 管理**：自动同步和管理 HTTP Cookie
- **JavaScript 交互**：内置多种 JavaScript 与原生交互的接口
- **手势支持**：支持左右滑动手势进行前进/后退导航
- **下拉刷新**：集成下拉刷新功能
- **自定义导航栏**：支持动态显示/隐藏导航栏

## 系统要求

- iOS 8.0 或更高版本
- Xcode 9.0 或更高版本

## 安装方式

### CocoaPods

在您的 `Podfile` 中添加以下内容：

```ruby
pod 'LWWebContainer'
```

然后执行：

```bash
pod install
```

### Carthage

在您的 `Cartfile` 中添加：

```ruby
github "luowei/LWWebContainer"
```

然后执行：

```bash
carthage update
```

## 使用方法

### 基本使用

#### 1. 导入头文件

```objective-c
#import <LWWebContainer/LWWebContainerVC.h>
```

#### 2. 创建 Web 容器

```objective-c
// 通过 URL 字符串创建
LWWebContainerVC *webVC = [LWWebContainerVC webViewControllerWithURLString:@"https://www.example.com"];

// 或者直接创建实例
LWWebContainerVC *webVC = [[LWWebContainerVC alloc] init];
webVC.urlstring = @"https://www.example.com";
```

#### 3. 加载网页

```objective-c
// 在当前容器中加载 URL
NSURL *url = [NSURL URLWithString:@"https://www.example.com"];
[webVC loadURL:url];

// 在新容器中加载 URL（会创建新的页面实例）
[webVC loadURLInNewTab:url];
```

#### 4. 刷新页面

```objective-c
[webVC reload];
```

### 高级使用

#### 在 TabBar 应用中使用

```objective-c
@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.delegate = self;
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSUInteger selectedIdx = self.selectedIndex;
    UINavigationController *navVC = self.viewControllers[selectedIdx];
    LWWebContainerVC *webVC = navVC.viewControllers.firstObject;

    // 根据不同的 Tab 加载不同的 URL
    NSDictionary *config = @{
        @"home": @"https://www.example.com/home",
        @"mall": @"https://www.example.com/mall",
        @"me": @"https://www.example.com/me"
    };

    switch (selectedIdx) {
        case 0: {
            NSURL *url = [NSURL URLWithString:config[@"home"]];
            [webVC loadURL:url];
            break;
        }
        case 1: {
            NSURL *url = [NSURL URLWithString:config[@"mall"]];
            [webVC loadURL:url];
            break;
        }
        case 2: {
            NSURL *url = [NSURL URLWithString:config[@"me"]];
            [webVC loadURL:url];
            break;
        }
        default:
            break;
    }
}

@end
```

#### 推送到新页面

```objective-c
LWWebContainerVC *webVC = [LWWebContainerVC webViewControllerWithURLString:@"https://www.example.com"];
webVC.isPushed = YES;
webVC.hidesBottomBarWhenPushed = YES;
[self.navigationController pushViewController:webVC animated:YES];
```

## API 文档

### 属性

#### needNewTab
```objective-c
@property(nonatomic) BOOL needNewTab;
```
是否需要在新标签页中打开链接。设置为 `YES` 时，点击链接会在新的容器中打开。

#### wkWebView
```objective-c
@property(nonatomic, strong) WKWebView *wkWebView;
```
内部使用的 WKWebView 实例，可以直接访问进行高级配置。

#### urlstring
```objective-c
@property(nonatomic, copy) NSString *urlstring;
```
要加载的 URL 字符串。

#### isPushed
```objective-c
@property(nonatomic) BOOL isPushed;
```
标记当前页面是否是通过 push 方式进入的，用于控制链接打开行为。

#### originNavigationBarHidden
```objective-c
@property(nonatomic) BOOL originNavigationBarHidden;
```
记录导航栏的原始隐藏状态，用于恢复导航栏显示状态。

### 方法

#### webViewControllerWithURLString:
```objective-c
+ (instancetype)webViewControllerWithURLString:(NSString *)urlstring;
```
通过 URL 字符串创建 Web 容器实例的便捷方法。

**参数：**
- `urlstring`：要加载的 URL 字符串

**返回值：**
- 返回一个配置好的 LWWebContainerVC 实例

#### loadURL:
```objective-c
- (void)loadURL:(NSURL *)url;
```
在当前容器中加载指定的 URL。

**参数：**
- `url`：要加载的 NSURL 对象

#### loadURLInNewTab:
```objective-c
- (void)loadURLInNewTab:(NSURL *)url;
```
在新容器中加载指定的 URL，会创建新的页面实例。

**参数：**
- `url`：要加载的 NSURL 对象

#### reload
```objective-c
- (void)reload;
```
重新加载当前页面。

## JavaScript 交互

LWWebContainer 提供了丰富的 JavaScript 与原生交互接口，通过 `window.webkit.messageHandlers` 调用。

### 可用的消息处理器

#### 1. webViewReload
刷新当前页面

```javascript
window.webkit.messageHandlers.webViewReload.postMessage(null);
```

#### 2. webViewBack
返回上一页

```javascript
window.webkit.messageHandlers.webViewBack.postMessage(null);
```

#### 3. webViewForward
前进到下一页

```javascript
window.webkit.messageHandlers.webViewForward.postMessage(null);
```

#### 4. webViewOpenURL
在当前容器中打开指定 URL

```javascript
window.webkit.messageHandlers.webViewOpenURL.postMessage("https://www.example.com");
```

#### 5. nativeHideNavBar
隐藏导航栏

```javascript
window.webkit.messageHandlers.nativeHideNavBar.postMessage(null);
```

#### 6. nativeShowNavBar
显示导航栏

```javascript
window.webkit.messageHandlers.nativeShowNavBar.postMessage(null);
```

#### 7. nativeBack
返回到原生上一个页面（调用 popViewController）

```javascript
window.webkit.messageHandlers.nativeBack.postMessage(null);
```

#### 8. nativeOpenURL
在新容器中打开指定 URL，或打开其他应用的 URL Scheme

```javascript
// 在新容器中打开网页
window.webkit.messageHandlers.nativeOpenURL.postMessage("https://www.example.com");

// 打开其他应用
window.webkit.messageHandlers.nativeOpenURL.postMessage("tel://10086");
```

### JavaScript 调用示例

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>LWWebContainer 示例</title>
</head>
<body>
    <button onclick="refreshPage()">刷新页面</button>
    <button onclick="goBack()">返回</button>
    <button onclick="openNewPage()">打开新页面</button>
    <button onclick="hideNavBar()">隐藏导航栏</button>
    <button onclick="showNavBar()">显示导航栏</button>

    <script>
        function refreshPage() {
            window.webkit.messageHandlers.webViewReload.postMessage(null);
        }

        function goBack() {
            window.webkit.messageHandlers.webViewBack.postMessage(null);
        }

        function openNewPage() {
            window.webkit.messageHandlers.nativeOpenURL.postMessage("https://www.example.com");
        }

        function hideNavBar() {
            window.webkit.messageHandlers.nativeHideNavBar.postMessage(null);
        }

        function showNavBar() {
            window.webkit.messageHandlers.nativeShowNavBar.postMessage(null);
        }
    </script>
</body>
</html>
```

## 核心功能详解

### 1. 链接打开策略

LWWebContainer 实现了智能的链接打开策略：

- **首次加载**：第一个页面在当前容器中打开
- **后续导航**：
  - 用户主动点击的链接默认在新容器中打开（类似浏览器新标签页）
  - 页面自动跳转（如重定向）在当前容器中打开
  - Reload、前进/后退操作在当前容器中进行

这种策略确保了类似原生浏览器的交互体验。

### 2. Cookie 管理

LWWebContainer 自动处理 Cookie 的同步：

- 从 `NSHTTPCookieStorage` 同步 Cookie 到 WKWebView
- 监听 Cookie 变化并自动更新
- 确保多个 WebView 实例间 Cookie 共享

### 3. 进度指示

内置的进度条提供实时加载反馈：

- 加载时显示进度条
- 进度到达 100% 后自动隐藏
- 平滑的动画效果

### 4. URL Scheme 支持

自动处理非 HTTP/HTTPS 协议：

- 检测到非 HTTP 链接时自动尝试调用系统处理
- 支持打开电话、邮件、地图等系统应用
- 支持第三方应用的 URL Scheme

### 5. 进程池管理

使用共享的 `WKProcessPool` 确保：

- 多个 WebView 实例共享资源
- 提高性能和内存效率
- Cookie 和缓存数据共享

## 自定义配置

### 自定义返回按钮

组件默认提供了返回按钮，图片资源位于 `LWWebContainer.bundle` 中。可以替换 `backItem` 图片来自定义按钮样式。

### 修改默认 URL

如果不提供 URL，默认加载 `https://luowei.github.io`。可以通过设置 `urlstring` 属性来指定其他 URL：

```objective-c
webVC.urlstring = @"https://www.yourdefault.com";
```

### 调试日志

在 Debug 模式下，使用 `WCLog` 宏可以输出调试信息。Release 模式下自动关闭。

```objective-c
#ifdef DEBUG
#define WCLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define WCLog(...)
#endif
```

## 注意事项

1. **iOS 11+ 特性**：Cookie 观察者功能需要 iOS 11.0 及以上版本
2. **内存管理**：在 dealloc 中正确移除了 KVO 观察者和消息处理器
3. **导航栏状态**：组件会记住并恢复导航栏的显示状态
4. **返回手势**：自动处理导航手势，避免与 WebView 手势冲突
5. **线程安全**：WKProcessPool 使用单例模式确保线程安全

## 示例项目

项目包含完整的示例代码，展示了如何在 TabBar 应用中集成 LWWebContainer。

运行示例项目：

```bash
cd Example
pod install
open LWWebContainer.xcworkspace
```

示例项目包含：

- TabBar 多页面切换
- 配置管理
- 自定义导航
- JavaScript 交互演示

## 常见问题

### Q: 如何禁用新标签页功能？

A: 设置 `needNewTab` 为 `NO`：

```objective-c
webVC.needNewTab = NO;
```

### Q: 如何自定义 WebView 配置？

A: 可以直接访问 `wkWebView` 属性进行配置：

```objective-c
webVC.wkWebView.allowsLinkPreview = YES;
webVC.wkWebView.customUserAgent = @"Your Custom User Agent";
```

### Q: 如何处理 JavaScript 调用失败？

A: 可以通过 WKScriptMessageHandler 的错误回调处理：

```objective-c
[webVC.wkWebView evaluateJavaScript:@"yourScript"
                  completionHandler:^(id result, NSError *error) {
    if (error) {
        NSLog(@"JavaScript error: %@", error);
    }
}];
```

### Q: 如何监听页面加载完成？

A: LWWebContainer 已经实现了 `WKNavigationDelegate`，可以继承并重写相关方法：

```objective-c
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [super webView:webView didFinishNavigation:navigation];
    // 你的自定义代码
}
```

## 技术架构

### 核心组件

```
LWWebContainerVC
├── WKWebView (主体)
├── UIProgressView (进度条)
├── WKWebViewConfiguration (配置)
│   ├── WKUserContentController (消息处理)
│   ├── WKProcessPool (进程池)
│   └── WKWebsiteDataStore (数据存储)
└── UIRefreshControl (下拉刷新)
```

### 代理实现

- `WKNavigationDelegate`：处理导航事件
- `WKUIDelegate`：处理 UI 交互
- `WKHTTPCookieStoreObserver`：监听 Cookie 变化
- `WKScriptMessageHandler`：处理 JavaScript 消息

## 性能优化

1. **共享进程池**：使用单例 WKProcessPool 减少内存占用
2. **懒加载**：WebView 在 viewDidLoad 时创建，优化启动性能
3. **约束布局**：使用 Auto Layout 适配不同屏幕尺寸
4. **手势优化**：禁用不必要的手势识别，避免冲突

## 更新日志

### Version 1.0.0
- 基于 WKWebView 的 Web 容器实现
- 支持新标签页打开链接
- 内置进度条和下拉刷新
- JavaScript 与原生交互接口
- Cookie 自动管理
- 完善的导航控制

## 作者

luowei - luowei@wodedata.com

## 许可证

LWWebContainer 基于 MIT 许可证开源。详见 [LICENSE](LICENSE) 文件。

## 贡献

欢迎提交 Issue 和 Pull Request！

如果这个项目对你有帮助，请给个 Star 支持一下！

## 相关资源

- [项目主页](https://github.com/luowei/LWWebContainer)
- [CocoaPods](https://cocoapods.org/pods/LWWebContainer)
- [WKWebView 官方文档](https://developer.apple.com/documentation/webkit/wkwebview)

---

**Note**: 本组件持续维护中，如有问题或建议，欢迎通过 GitHub Issues 反馈。
