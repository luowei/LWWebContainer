#
# Be sure to run `pod lib lint LWWebContainer-Swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWWebContainer_swift'
  s.version          = '1.0.0'
  s.summary          = 'Swift版本的LWWebContainer - 基于WKWebView的Web容器组件'

  s.description      = <<-DESC
LWWebContainer_swift 是 LWWebContainer 的 Swift 版本实现。
提供了 UIKit (LWWebContainerViewController) 和 SwiftUI (LWWebContainerView) 两种接口，
用于嵌入 Web 内容，支持导航、Cookie 管理和 JavaScript 桥接。
主要特性:
- 类原生的导航手势支持（前进/后退）
- 下拉刷新支持
- 进度指示器
- Cookie 同步
- JavaScript 消息处理
- SwiftUI 和 UIKit 兼容
                       DESC

  s.homepage         = 'https://github.com/luowei/LWWebContainer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWWebContainer.git', :tag => "swift-#{s.version}" }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'LWWebContainer_swift/**/*.{swift,h}'

  s.resource_bundles = {
    'LWWebContainer' => ['LWWebContainer/Assets/**/*']
  }

  s.frameworks = 'UIKit', 'WebKit'

  # If you want to support both Swift and ObjC in the same pod, uncomment:
  # s.dependency 'LWWebContainer', '~> 1.0'
end
