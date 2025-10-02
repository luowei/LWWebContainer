# LWWebContainer

[![CI Status](https://img.shields.io/travis/luowei/LWWebContainer.svg?style=flat)](https://travis-ci.org/luowei/LWWebContainer)
[![Version](https://img.shields.io/cocoapods/v/LWWebContainer.svg?style=flat)](https://cocoapods.org/pods/LWWebContainer)
[![License](https://img.shields.io/cocoapods/l/LWWebContainer.svg?style=flat)](https://cocoapods.org/pods/LWWebContainer)
[![Platform](https://img.shields.io/cocoapods/p/LWWebContainer.svg?style=flat)](https://cocoapods.org/pods/LWWebContainer)

[English](./README.md) | [中文版](./README_ZH.md)

A powerful and flexible WKWebView container for iOS that provides seamless web content integration with native iOS applications. Built on top of WKWebView, LWWebContainer offers advanced features including tab management, JavaScript bridge communication, and comprehensive navigation controls.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [JavaScript Bridge API](#javascript-bridge)
- [Cookie Management](#cookie-management)
- [Architecture Overview](#architecture-overview)
- [Advanced Usage](#advanced-usage-examples)
- [API Reference](#quick-reference)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Example Project](#example-project)
- [Contributing](#contributing)
- [FAQ](#faq)
- [License](#license)

## Features

### WKWebView Container
- **Modern WebKit Integration**: Built with WKWebView for optimal performance and compatibility
- **Process Pool Management**: Shared WKProcessPool for efficient memory usage across multiple web views
- **Cookie Synchronization**: Automatic cookie management and synchronization between web and native contexts
- **Progress Tracking**: Visual progress indicator with smooth animations
- **Pull-to-Refresh**: Built-in refresh control for easy content reloading
- **Custom Navigation**: Customizable back button with support for navigation bar show/hide
- **Gesture Support**: Back/forward swipe gestures enabled by default

### Tab Support
- **Multiple Tab Management**: Support for opening URLs in new tabs or existing containers
- **Smart Tab Switching**: Intelligent tab switching logic for TabBar-based applications
- **Tab Isolation**: Each tab maintains its own web context while sharing process pool
- **Dynamic URL Loading**: Load different URLs based on tab selection
- **Navigation Stack**: Full navigation controller integration with push/pop support

### JavaScript Bridge
The container provides a comprehensive JavaScript bridge for bidirectional communication between web content and native code:

#### Native-to-Web Communication
- Load and reload web content programmatically
- Inject JavaScript code and receive results
- Navigate web history (back/forward)

#### Web-to-Native Communication
JavaScript can call native functions using `window.webkit.messageHandlers`:

**Navigation Control:**
```javascript
// Navigate back in web history
window.webkit.messageHandlers.webViewBack.postMessage(null);

// Navigate forward in web history
window.webkit.messageHandlers.webViewForward.postMessage(null);

// Reload current page
window.webkit.messageHandlers.webViewReload.postMessage(null);

// Open URL in current container
window.webkit.messageHandlers.webViewOpenURL.postMessage("https://example.com");

// Navigate back in native navigation stack
window.webkit.messageHandlers.nativeBack.postMessage(null);

// Open URL in new tab/container
window.webkit.messageHandlers.nativeOpenURL.postMessage("https://example.com");
```

**UI Control:**
```javascript
// Hide navigation bar
window.webkit.messageHandlers.nativeHideNavBar.postMessage(null);

// Show navigation bar
window.webkit.messageHandlers.nativeShowNavBar.postMessage(null);
```

**Deep Linking:**
The container automatically handles non-HTTP URLs and can open them in their respective apps (e.g., `tel:`, `mailto:`, custom URL schemes).

### Cookie Management

LWWebContainer provides comprehensive cookie management to ensure seamless data synchronization between native and web contexts:

**Automatic Cookie Synchronization:**
```objective-c
// On initialization, cookies from NSHTTPCookieStorage are automatically synced
// This happens in viewDidLoad - no manual intervention needed

// The container uses WKHTTPCookieStore (iOS 11+) for modern cookie handling
if (@available(iOS 11.0, *)) {
    // Add cookie observer for real-time updates
    [self.configuration.websiteDataStore.httpCookieStore addObserver:self];

    // Sync existing cookies
    for (NSHTTPCookie *cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies) {
        [self.configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:nil];
    }
}
```

**Shared Process Pool:**
```objective-c
// All web containers share the same WKProcessPool
// This ensures cookies and other data are shared across instances
self.configuration.processPool = [LWWebContainerVC pool];
```

**Cookie Observer:**
The container implements `WKHTTPCookieStoreObserver` to automatically detect and propagate cookie changes:
```objective-c
- (void)cookiesDidChangeInCookieStore:(WKHTTPCookieStore *)cookieStore {
    // Automatically updates all cookies when changes are detected
    [self.configuration.websiteDataStore.httpCookieStore getAllCookies:^(NSArray *cookies) {
        for (NSHTTPCookie *cookie in cookies) {
            [self.configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:nil];
        }
    }];
}
```

**Manual Cookie Management:**
```objective-c
// Access the cookie store directly if needed
if (@available(iOS 11.0, *)) {
    WKHTTPCookieStore *cookieStore = webVC.wkWebView.configuration.websiteDataStore.httpCookieStore;

    // Set a cookie
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{
        NSHTTPCookieName: @"session_id",
        NSHTTPCookieValue: @"abc123",
        NSHTTPCookieDomain: @".example.com",
        NSHTTPCookiePath: @"/"
    }];
    [cookieStore setCookie:cookie completionHandler:^{
        NSLog(@"Cookie set successfully");
    }];

    // Get all cookies
    [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
        for (NSHTTPCookie *cookie in cookies) {
            NSLog(@"Cookie: %@ = %@", cookie.name, cookie.value);
        }
    }];
}
```

## Requirements

- iOS 9.0+
- Xcode 11.0+
- CocoaPods 1.0+ or Carthage

## Installation

LWWebContainer is available through [CocoaPods](https://cocoapods.org) and Carthage.

### CocoaPods

Add the following line to your `Podfile`:

```ruby
pod 'LWWebContainer'
```

Then run:

```bash
pod install
```

### Carthage

Add the following line to your `Cartfile`:

```ruby
github "luowei/LWWebContainer"
```

Then run:

```bash
carthage update
```

## Quick Start

### Creating a Web Container

**Simple initialization:**
```objective-c
// Initialize with URL string
LWWebContainerVC *webVC = [LWWebContainerVC webViewControllerWithURLString:@"https://example.com"];

// Push to navigation controller
[self.navigationController pushViewController:webVC animated:YES];
```

### Loading URLs

```objective-c
// Load URL in current container
NSURL *url = [NSURL URLWithString:@"https://example.com"];
[webVC loadURL:url];

// Load URL in new tab/container
[webVC loadURLInNewTab:url];

// Reload current page
[webVC reload];
```

## Usage

### Basic Implementation

See [Quick Start](#quick-start) for basic usage.

### Tab Bar Integration

Integrate web containers with UITabBarController for a multi-tab web application:

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

    // Load different URLs based on tab selection
    NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"config"];

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
    }
}

@end
```

### Customization

**Accessing the WKWebView:**
```objective-c
// Direct access to underlying WKWebView
WKWebView *webView = webVC.wkWebView;

// Inject JavaScript
[webView evaluateJavaScript:@"document.title"
          completionHandler:^(id result, NSError *error) {
    NSLog(@"Page title: %@", result);
}];
```

**Navigation Bar Control:**
```objective-c
// Control whether navigation bar should be hidden
webVC.originNavigationBarHidden = YES;
```

**Push Behavior:**
```objective-c
// Control whether links should open in new containers
webVC.isPushed = YES;
webVC.hidesBottomBarWhenPushed = YES;
```

### Advanced Usage Examples

#### JavaScript Evaluation and Injection

**Execute JavaScript and Get Results:**
```objective-c
// Get page title
[webVC.wkWebView evaluateJavaScript:@"document.title"
                  completionHandler:^(id result, NSError *error) {
    if (error) {
        NSLog(@"Error: %@", error);
    } else {
        NSLog(@"Page title: %@", result);
    }
}];

// Get page content
[webVC.wkWebView evaluateJavaScript:@"document.body.innerHTML"
                  completionHandler:^(id result, NSError *error) {
    NSLog(@"HTML content: %@", result);
}];

// Inject custom JavaScript
NSString *js = @"var meta = document.createElement('meta'); "
               @"meta.name = 'viewport'; "
               @"meta.content = 'width=device-width, initial-scale=1.0'; "
               @"document.head.appendChild(meta);";
[webVC.wkWebView evaluateJavaScript:js completionHandler:nil];
```

**User Script Injection:**
```objective-c
// Inject JavaScript that runs automatically on every page
WKUserScript *script = [[WKUserScript alloc]
    initWithSource:@"console.log('Page loaded via LWWebContainer');"
     injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
  forMainFrameOnly:YES];

[webVC.wkWebView.configuration.userContentController addUserScript:script];
```

#### Complete HTML Page Example

**Create an HTML page that demonstrates all JavaScript bridge features:**
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LWWebContainer Demo</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            padding: 20px;
            max-width: 600px;
            margin: 0 auto;
        }
        button {
            display: block;
            width: 100%;
            padding: 15px;
            margin: 10px 0;
            font-size: 16px;
            background: #007AFF;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
        }
        button:active {
            background: #0051D5;
        }
        .section {
            margin: 30px 0;
            padding: 20px;
            background: #f5f5f5;
            border-radius: 8px;
        }
        h2 {
            color: #333;
            border-bottom: 2px solid #007AFF;
            padding-bottom: 10px;
        }
    </style>
</head>
<body>
    <h1>LWWebContainer Features</h1>

    <div class="section">
        <h2>Navigation Control</h2>
        <button onclick="webViewBack()">WebView Back</button>
        <button onclick="webViewForward()">WebView Forward</button>
        <button onclick="webViewReload()">Reload Page</button>
        <button onclick="openInCurrentContainer()">Open URL in Current</button>
    </div>

    <div class="section">
        <h2>Native Navigation</h2>
        <button onclick="nativeBack()">Native Back (Pop)</button>
        <button onclick="openInNewTab()">Open in New Tab</button>
        <button onclick="openExternalApp()">Call Phone</button>
    </div>

    <div class="section">
        <h2>UI Control</h2>
        <button onclick="hideNavigationBar()">Hide Navigation Bar</button>
        <button onclick="showNavigationBar()">Show Navigation Bar</button>
    </div>

    <script>
        // WebView Navigation
        function webViewBack() {
            window.webkit.messageHandlers.webViewBack.postMessage(null);
        }

        function webViewForward() {
            window.webkit.messageHandlers.webViewForward.postMessage(null);
        }

        function webViewReload() {
            window.webkit.messageHandlers.webViewReload.postMessage(null);
        }

        function openInCurrentContainer() {
            window.webkit.messageHandlers.webViewOpenURL.postMessage("https://github.com/luowei/LWWebContainer");
        }

        // Native Navigation
        function nativeBack() {
            window.webkit.messageHandlers.nativeBack.postMessage(null);
        }

        function openInNewTab() {
            window.webkit.messageHandlers.nativeOpenURL.postMessage("https://www.apple.com");
        }

        function openExternalApp() {
            // Opens Phone app
            window.webkit.messageHandlers.nativeOpenURL.postMessage("tel:10086");
        }

        // UI Control
        function hideNavigationBar() {
            window.webkit.messageHandlers.nativeHideNavBar.postMessage(null);
        }

        function showNavigationBar() {
            window.webkit.messageHandlers.nativeShowNavBar.postMessage(null);
        }

        // Check if running in LWWebContainer
        function isInWebContainer() {
            return window.webkit &&
                   window.webkit.messageHandlers &&
                   window.webkit.messageHandlers.webViewReload;
        }

        if (isInWebContainer()) {
            console.log("Running in LWWebContainer");
        }
    </script>
</body>
</html>
```

#### Deep Linking and URL Scheme Handling

**Handle various URL schemes:**
```objective-c
// The container automatically detects and handles non-HTTP URLs
// Examples of supported URL schemes:

// Phone calls
// JavaScript: window.webkit.messageHandlers.nativeOpenURL.postMessage("tel:1234567890");

// Email
// JavaScript: window.webkit.messageHandlers.nativeOpenURL.postMessage("mailto:example@email.com");

// SMS
// JavaScript: window.webkit.messageHandlers.nativeOpenURL.postMessage("sms:1234567890");

// Maps
// JavaScript: window.webkit.messageHandlers.nativeOpenURL.postMessage("maps://");

// Custom app schemes
// JavaScript: window.webkit.messageHandlers.nativeOpenURL.postMessage("yourapp://action");
```

**Implement custom URL scheme handling in your app:**
```objective-c
// In your Info.plist, register URL schemes
// Then handle incoming URLs in AppDelegate

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    // Parse the URL and take appropriate action
    if ([url.scheme isEqualToString:@"yourapp"]) {
        NSString *action = url.host;

        if ([action isEqualToString:@"openpage"]) {
            NSURLComponents *components = [NSURLComponents componentsWithURL:url
                                                      resolvingAgainstBaseURL:NO];
            NSString *pageURL = [self valueForKey:@"url" fromQueryItems:components.queryItems];

            // Open in web container
            LWWebContainerVC *webVC = [LWWebContainerVC webViewControllerWithURLString:pageURL];
            // Navigate to webVC
        }
        return YES;
    }
    return NO;
}
```

#### Navigation Policy Customization

**Understanding the navigation decision logic:**
```objective-c
// The container implements smart navigation behavior:
// 1. First page load: Opens in current container
// 2. User clicks link: Opens in new container (needNewTab = YES)
// 3. Reload/Back/Forward: Stays in current container
// 4. Form submission: Stays in current container
// 5. Non-HTTP URLs: Opens in external app

// You can customize this behavior by subclassing:

@interface MyCustomWebContainer : LWWebContainerVC
@end

@implementation MyCustomWebContainer

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSURL *url = navigationAction.request.URL;

    // Custom logic: always open PDFs in new container
    if ([url.pathExtension isEqualToString:@"pdf"]) {
        LWWebContainerVC *pdfVC = [LWWebContainerVC webViewControllerWithURLString:url.absoluteString];
        pdfVC.isPushed = YES;
        [self.navigationController pushViewController:pdfVC animated:YES];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    // Custom logic: block certain domains
    if ([url.host containsString:@"blocked-domain.com"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    // Use default behavior
    [super webView:webView
      decidePolicyForNavigationAction:navigationAction
      decisionHandler:decisionHandler];
}

@end
```

#### Custom User Agent

**Set custom user agent:**
```objective-c
// Set a custom user agent for your web container
webVC.wkWebView.customUserAgent = @"MyApp/1.0 (iOS; LWWebContainer)";

// Or append to the default user agent
NSString *defaultAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)";
NSString *customAgent = [NSString stringWithFormat:@"%@ MyApp/1.0", defaultAgent];
webVC.wkWebView.customUserAgent = customAgent;
```

#### Progress Monitoring

**Custom progress handling:**
```objective-c
// The container already observes estimatedProgress
// You can add additional observers or override the handler:

@interface MyWebContainer : LWWebContainerVC
@end

@implementation MyWebContainer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float progress = self.wkWebView.estimatedProgress;

        // Custom progress handling
        NSLog(@"Loading progress: %.0f%%", progress * 100);

        // Update your custom UI
        [self updateCustomProgressBar:progress];
    }

    // Call super to maintain default behavior
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}

- (void)updateCustomProgressBar:(float)progress {
    // Your custom progress UI logic
}

@end
```

#### Error Handling

**Handle web view errors:**
```objective-c
@interface MyWebContainer : LWWebContainerVC <WKNavigationDelegate>
@end

@implementation MyWebContainer

- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {

    NSLog(@"Navigation failed: %@", error.localizedDescription);

    // Show error page
    [self showErrorPage:error];
}

- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {

    if (error.code == NSURLErrorNotConnectedToInternet) {
        [self showNoInternetPage];
    } else {
        [self showErrorPage:error];
    }
}

- (void)showErrorPage:(NSError *)error {
    NSString *html = [NSString stringWithFormat:
        @"<html><body style='font-family: -apple-system; text-align: center; padding: 50px;'>"
        @"<h1>Oops!</h1>"
        @"<p>%@</p>"
        @"<button onclick='location.reload()'>Retry</button>"
        @"</body></html>",
        error.localizedDescription];

    [webView loadHTMLString:html baseURL:nil];
}

- (void)showNoInternetPage {
    NSString *html =
        @"<html><body style='font-family: -apple-system; text-align: center; padding: 50px;'>"
        @"<h1>No Internet Connection</h1>"
        @"<p>Please check your connection and try again.</p>"
        @"<button onclick='location.reload()'>Retry</button>"
        @"</body></html>";

    [self.wkWebView loadHTMLString:html baseURL:nil];
}

@end
```

## Architecture Overview

### WKWebView Container Design

LWWebContainer is built on a robust architecture that leverages modern WebKit features:

```
┌─────────────────────────────────────────────────────────┐
│                  LWWebContainerVC                       │
│  ┌───────────────────────────────────────────────────┐  │
│  │              WKWebView                            │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │     WKWebViewConfiguration                  │ │  │
│  │  │  ┌────────────────────────────────────────┐ │ │  │
│  │  │  │  WKUserContentController               │ │ │  │
│  │  │  │  - Script Message Handlers             │ │ │  │
│  │  │  │  - User Scripts                        │ │ │  │
│  │  │  └────────────────────────────────────────┘ │ │  │
│  │  │  ┌────────────────────────────────────────┐ │ │  │
│  │  │  │  WKProcessPool (Shared Singleton)      │ │ │  │
│  │  │  │  - Memory Efficiency                   │ │ │  │
│  │  │  │  - Cookie Sharing                      │ │ │  │
│  │  │  └────────────────────────────────────────┘ │ │  │
│  │  │  ┌────────────────────────────────────────┐ │ │  │
│  │  │  │  WKWebsiteDataStore                    │ │ │  │
│  │  │  │  - WKHTTPCookieStore                   │ │ │  │
│  │  │  │  - Cookie Observer                     │ │ │  │
│  │  │  └────────────────────────────────────────┘ │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │          UIProgressView (Progress Bar)            │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │       UIRefreshControl (Pull-to-Refresh)          │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Key Components

1. **WKProcessPool Singleton**: Shared across all web container instances for efficient memory usage and data sharing
2. **WKUserContentController**: Manages JavaScript message handlers and user script injection
3. **WKHTTPCookieStore**: Handles cookie synchronization with automatic observer pattern (iOS 11+)
4. **Navigation Delegates**: Smart navigation policy that opens links in new containers (tab-like behavior)
5. **Progress Tracking**: KVO-based progress monitoring with visual feedback
6. **Auto Layout**: Constraint-based layout for adaptive UI across different screen sizes

## Quick Reference

### JavaScript Bridge API

| Message Handler | Parameter | Description |
|----------------|-----------|-------------|
| `webViewBack` | `null` | Navigate back in web history |
| `webViewForward` | `null` | Navigate forward in web history |
| `webViewReload` | `null` | Reload current page |
| `webViewOpenURL` | `string` | Open URL in current container |
| `nativeBack` | `null` | Pop to previous native view controller |
| `nativeOpenURL` | `string` | Open URL in new container or external app |
| `nativeHideNavBar` | `null` | Hide navigation bar |
| `nativeShowNavBar` | `null` | Show navigation bar |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `wkWebView` | `WKWebView*` | The underlying WKWebView instance |
| `urlstring` | `NSString*` | URL string to load |
| `needNewTab` | `BOOL` | Whether to open links in new containers |
| `isPushed` | `BOOL` | Whether this container was pushed onto navigation stack |
| `originNavigationBarHidden` | `BOOL` | Original navigation bar hidden state |

### Methods

| Method | Description |
|--------|-------------|
| `+ webViewControllerWithURLString:` | Create new container with URL |
| `- loadURL:` | Load URL in current container |
| `- loadURLInNewTab:` | Load URL in new container |
| `- reload` | Reload current page |

### Delegates Implemented

- **WKNavigationDelegate**: Navigation and policy decisions
- **WKUIDelegate**: UI interactions
- **WKHTTPCookieStoreObserver**: Cookie change notifications (iOS 11+)
- **WKScriptMessageHandler**: JavaScript message handling

## Example Project

To run the example project:

1. Clone the repository
   ```bash
   git clone https://github.com/luowei/LWWebContainer.git
   cd LWWebContainer/Example
   ```

2. Install dependencies
   ```bash
   pod install
   ```

3. Open the workspace
   ```bash
   open LWWebContainer.xcworkspace
   ```

The example project demonstrates:
- TabBar integration with multiple web containers
- Dynamic URL loading based on tab selection
- Custom configuration management
- JavaScript bridge communication
- Cookie persistence across sessions

## Best Practices

### Performance Optimization

1. **Reuse Web Containers**: Instead of creating new instances, reuse existing containers when possible
2. **Shared Process Pool**: The singleton process pool is automatically used - don't create custom pools
3. **Lazy Loading**: Web views are initialized in `viewDidLoad` for optimal startup performance
4. **Memory Management**: Properly remove observers and message handlers in `dealloc`

### Security Considerations

1. **Content Security**: Always validate URLs before loading
2. **Cookie Scope**: Be mindful of cookie domains and paths for security
3. **HTTPS**: Prefer HTTPS URLs for secure communication
4. **URL Scheme Validation**: Validate non-HTTP URLs before opening external apps

```objective-c
// Example: Validate URLs before loading
- (BOOL)isValidURL:(NSURL *)url {
    if (!url) return NO;

    // Only allow HTTPS
    if (![url.scheme isEqualToString:@"https"]) {
        return NO;
    }

    // Whitelist allowed domains
    NSArray *allowedDomains = @[@"example.com", @"trusted-site.com"];
    for (NSString *domain in allowedDomains) {
        if ([url.host hasSuffix:domain]) {
            return YES;
        }
    }

    return NO;
}
```

### Common Pitfalls to Avoid

1. **Don't forget to remove observers**: Always clean up KVO observers in `dealloc`
2. **Cookie timing**: Wait for cookie synchronization to complete before loading pages
3. **Navigation state**: Track `isPushed` correctly for proper link opening behavior
4. **Memory leaks**: Avoid strong reference cycles in closures/blocks
5. **Thread safety**: WKWebView operations should be performed on the main thread

### Testing

```objective-c
// Example: Unit test for web container initialization
- (void)testWebContainerInitialization {
    LWWebContainerVC *webVC = [LWWebContainerVC webViewControllerWithURLString:@"https://example.com"];

    XCTAssertNotNil(webVC);
    XCTAssertNotNil(webVC.wkWebView);
    XCTAssertEqualObjects(webVC.urlstring, @"https://example.com");
}

// Example: Test JavaScript bridge
- (void)testJavaScriptBridge {
    LWWebContainerVC *webVC = [LWWebContainerVC new];
    [webVC viewDidLoad];

    XCTestExpectation *expectation = [self expectationWithDescription:@"JavaScript execution"];

    [webVC.wkWebView evaluateJavaScript:@"2 + 2"
                      completionHandler:^(id result, NSError *error) {
        XCTAssertNil(error);
        XCTAssertEqualObjects(result, @4);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}
```

## Troubleshooting

### Common Issues

**Problem**: Cookies not persisting across app restarts

**Solution**: Ensure you're properly synchronizing cookies and using persistent cookie storage:
```objective-c
// Force cookie persistence
[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
```

**Problem**: JavaScript bridge not working

**Solution**: Verify that:
1. Message handlers are registered before loading the page
2. JavaScript is using the correct handler names
3. The page is loaded via HTTPS (some features require secure context)

**Problem**: Links not opening in new containers

**Solution**: Check the `isPushed` and `needNewTab` flags:
```objective-c
webVC.isPushed = YES;  // Enable new container behavior
```

**Problem**: Progress bar not showing

**Solution**: Ensure the progress view is added to the view hierarchy and constraints are properly set.

### Debug Logging

Enable debug logging to troubleshoot issues:
```objective-c
// The WCLog macro automatically logs in DEBUG builds
// Check the console for navigation events, URL changes, etc.

// You can also add custom logging:
#ifdef DEBUG
    NSLog(@"WebView URL: %@", webVC.wkWebView.URL);
    NSLog(@"Navigation state: %@", webVC.isPushed ? @"Pushed" : @"Root");
#endif
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

See [Example Project](#example-project) section for instructions on setting up the development environment.

## FAQ

**Q: Can I use LWWebContainer with SwiftUI?**

A: Yes! You can wrap LWWebContainerVC in a UIViewControllerRepresentable:
```swift
struct WebContainerView: UIViewControllerRepresentable {
    let urlString: String

    func makeUIViewController(context: Context) -> LWWebContainerVC {
        return LWWebContainerVC.webViewController(withURLString: urlString)
    }

    func updateUIViewController(_ uiViewController: LWWebContainerVC, context: Context) {
        // Update if needed
    }
}
```

**Q: How do I handle file downloads?**

A: Implement WKNavigationDelegate's download methods or use WKDownloadDelegate (iOS 14.5+).

**Q: Can I customize the progress bar appearance?**

A: Yes, access `webProgress` property and customize its appearance:
```objective-c
webVC.webProgress.progressTintColor = [UIColor redColor];
webVC.webProgress.trackTintColor = [UIColor lightGrayColor];
```

**Q: Does it support Dark Mode?**

A: Yes, the container respects system appearance. Web content should implement their own dark mode support via CSS media queries.

**Q: How do I clear web view cache?**

A:
```objective-c
NSSet *dataTypes = [NSSet setWithArray:@[
    WKWebsiteDataTypeDiskCache,
    WKWebsiteDataTypeMemoryCache
]];

NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
[[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:dataTypes
                                           modifiedSince:dateFrom
                                       completionHandler:^{
    NSLog(@"Cache cleared");
}];
```

## Resources

### Related Projects

- [WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge) - Alternative JavaScript bridge approach
- [WKWebView Documentation](https://developer.apple.com/documentation/webkit/wkwebview) - Official Apple documentation

### Links

- [GitHub Repository](https://github.com/luowei/LWWebContainer)
- [CocoaPods Page](https://cocoapods.org/pods/LWWebContainer)
- [Issue Tracker](https://github.com/luowei/LWWebContainer/issues)

## Author

**luowei** - luowei@wodedata.com

If you have questions or suggestions, feel free to open an issue on GitHub.

## License

LWWebContainer is available under the MIT license. See the [LICENSE](LICENSE) file for more information.

---

**Note**: This project is actively maintained. If you find it helpful, please consider giving it a star on GitHub!
