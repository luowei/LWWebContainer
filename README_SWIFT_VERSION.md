# LWWebContainer Swift Version

## 概述

LWWebContainer_swift 是 LWWebContainer 的 Swift 版本实现，提供了现代化的 Swift API 用于创建基于 WKWebView 的 Web 容器组件。

## 安装

### CocoaPods

在您的 `Podfile` 中添加：

```ruby
pod 'LWWebContainer_swift'
```

然后运行：

```bash
pod install
```

## 使用方法

### UIKit

```swift
import LWWebContainer_swift

// 使用 LWWebContainerViewController
let webViewController = LWWebContainerViewController()
webViewController.loadURL(URL(string: "https://www.example.com")!)
navigationController?.pushViewController(webViewController, animated: true)
```

### SwiftUI

```swift
import SwiftUI
import LWWebContainer_swift

struct ContentView: View {
    var body: some View {
        LWWebContainerView(url: URL(string: "https://www.example.com")!)
            .edgesIgnoringSafeArea(.all)
    }
}
```

## 主要特性

- **类原生导航**: 支持前进/后退手势，提供类似 Safari 的浏览体验
- **下拉刷新**: 内置下拉刷新功能
- **进度指示器**: 显示页面加载进度
- **Cookie 同步**: 自动处理 Cookie 同步
- **JavaScript 桥接**: 支持 JavaScript 消息处理
- **双平台支持**: 同时支持 SwiftUI 和 UIKit

## 组件说明

- **LWWebContainerViewController**: UIKit 视图控制器，提供完整的 Web 容器功能
- **LWWebContainerView**: SwiftUI 视图组件，声明式 API
- **LWWebContainerExtensions**: 扩展功能，提供额外的工具方法

## 系统要求

- iOS 11.0+
- Swift 5.0+
- Xcode 12.0+

## 与 Objective-C 版本的关系

- **LWWebContainer**: Objective-C 版本，适用于传统的 Objective-C 项目
- **LWWebContainer_swift**: Swift 版本，提供现代化的 Swift API 和 SwiftUI 支持

您可以根据项目需要选择合适的版本。两个版本功能相同，但 Swift 版本提供了更好的类型安全性和 SwiftUI 集成。

## License

LWWebContainer_swift is available under the MIT license. See the LICENSE file for more info.
