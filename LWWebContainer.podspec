#
# Be sure to run `pod lib lint LWWebContainer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWWebContainer'
  s.version          = '1.0.0'
  s.summary          = '基于WKWebView的Web容器组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
LWWebContainer，基于WKWebView的Web容器组件，仿原理交互支持链接在新的容器中打开Web页。
                       DESC

  s.homepage         = 'https://github.com/luowei/LWWebContainer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWWebContainer.git'}
  # s.source           = { :git => 'https://gitlab.com/ioslibraries1/libwebcontainer.git'}
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LWWebContainer/Classes/**/*'
  
  s.resource_bundles = {
    'LWWebContainer' => ['LWWebContainer/Assets/**/*']
  }

  s.public_header_files = 'LWWebContainer/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
