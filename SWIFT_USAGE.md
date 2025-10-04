# LWWebContainer - Swift/SwiftUI Usage Guide

A modern Swift/SwiftUI implementation of the LWWebContainer web component, providing both UIKit and SwiftUI interfaces for embedding web content with native-like navigation.

## Features

- **UIKit Support**: Full-featured `LWWebContainerViewController` for UIKit apps
- **SwiftUI Support**: Native `LWWebContainerView` for SwiftUI apps
- **Navigation**: Support for opening links in new containers (tab-like behavior)
- **Gestures**: Back/forward swipe gestures
- **Progress**: Loading progress indicator
- **Refresh**: Pull-to-refresh support
- **Cookies**: Automatic cookie synchronization
- **JavaScript Bridge**: Built-in message handlers for web-to-native communication
- **Custom Schemes**: Automatic handling of tel:, mailto:, and other schemes

## Installation

### CocoaPods

Add to your Podfile:

```ruby
pod 'LWWebContainer-Swift', '~> 1.0'
```

Then run:

```bash
pod install
```

### Swift Package Manager

Add the package dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/luowei/LWWebContainer.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File > Swift Packages > Add Package Dependency
2. Enter: `https://github.com/luowei/LWWebContainer.git`

## Requirements

- iOS 11.0+
- Swift 5.0+
- Xcode 12.0+

## Quick Start

### UIKit

```swift
import LWWebContainer

// Create and present web container
let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")
let navController = UINavigationController(rootViewController: webVC)
present(navController, animated: true)

// Or push to navigation stack
let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")
webVC.isPushed = true
navigationController?.pushViewController(webVC, animated: true)
```

### SwiftUI

```swift
import SwiftUI
import LWWebContainer

struct ContentView: View {
    @State private var showWeb = false

    var body: some View {
        Button("Open Web Page") {
            showWeb = true
        }
        .lwWebContainer(url: URL(string: "https://www.example.com"), isPresented: $showWeb)
    }
}
```

## Detailed Usage

### 1. UIKit - Basic Usage

```swift
// Create web container
let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")

// Present modally
let navController = UINavigationController(rootViewController: webVC)
present(navController, animated: true)

// Or push
navigationController?.pushViewController(webVC, animated: true)
```

### 2. UIKit - Advanced Features

```swift
let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")

// Access the WKWebView directly
webVC.wkWebView.evaluateJavaScript("document.title") { result, error in
    if let title = result as? String {
        print("Page title: \(title)")
    }
}

// Load a different URL
if let url = URL(string: "https://www.apple.com") {
    webVC.loadURL(url)
}

// Load URL in new tab (will open in new container on next navigation)
if let url = URL(string: "https://www.google.com") {
    webVC.loadURLInNewTab(url)
}

// Reload current page
webVC.reload()
```

### 3. SwiftUI - Custom Web View

```swift
import SwiftUI
import LWWebContainer

struct WebViewScreen: View {
    @State private var isLoading = false
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var pageTitle = ""

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            }

            LWWebContainerView(
                url: URL(string: "https://www.example.com"),
                isLoading: $isLoading,
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                title: $pageTitle
            )

            // Navigation toolbar
            HStack {
                Button(action: { /* go back */ }) {
                    Image(systemName: "chevron.left")
                }
                .disabled(!canGoBack)

                Spacer()

                Button(action: { /* go forward */ }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!canGoForward)

                Spacer()

                Text(pageTitle)
                    .lineLimit(1)
            }
            .padding()
        }
    }
}
```

### 4. SwiftUI - UIKit Integration

```swift
struct ContentView: View {
    var body: some View {
        LWWebContainerRepresentable(urlString: "https://www.example.com")
    }
}
```

### 5. Cookie Management

```swift
let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")

// Sync cookies from HTTPCookieStorage
LWCookieManager.shared.syncCookies(to: webVC.wkWebView) {
    print("Cookies synced")
}

// Get all cookies
LWCookieManager.shared.getAllCookies(from: webVC.wkWebView) { cookies in
    print("Total cookies: \(cookies.count)")
    for cookie in cookies {
        print("Cookie: \(cookie.name) = \(cookie.value)")
    }
}

// Delete all cookies
LWCookieManager.shared.deleteAllCookies(from: webVC.wkWebView) {
    print("All cookies deleted")
}
```

### 6. JavaScript Injection

```swift
let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")

// Inject JavaScript
let javascript = """
console.log('Hello from native!');
document.body.style.backgroundColor = '#f0f0f0';
"""
webVC.wkWebView.injectJavaScript(javascript)

// Inject CSS
let css = """
body {
    font-family: -apple-system, sans-serif;
}
a {
    color: #007AFF;
}
"""
webVC.wkWebView.injectCSS(css)
```

### 7. JavaScript Bridge (Web to Native Communication)

The web container provides built-in JavaScript message handlers that can be called from your web page:

#### Available Message Handlers

```javascript
// In your web page JavaScript:

// Navigate back in native navigation
window.webkit.messageHandlers.nativeBack.postMessage(null);

// Open URL in new container
window.webkit.messageHandlers.nativeOpenURL.postMessage('https://www.apple.com');

// Hide navigation bar
window.webkit.messageHandlers.nativeHideNavBar.postMessage(null);

// Show navigation bar
window.webkit.messageHandlers.nativeShowNavBar.postMessage(null);

// Navigate back in WebView history
window.webkit.messageHandlers.webViewBack.postMessage(null);

// Navigate forward in WebView history
window.webkit.messageHandlers.webViewForward.postMessage(null);

// Reload current page
window.webkit.messageHandlers.webViewReload.postMessage(null);

// Load URL in current WebView
window.webkit.messageHandlers.webViewOpenURL.postMessage('https://www.apple.com');
```

#### Example Web Page

```html
<!DOCTYPE html>
<html>
<head>
    <title>Test Page</title>
</head>
<body>
    <button onclick="goBack()">Go Back</button>
    <button onclick="openNewPage()">Open New Page</button>
    <button onclick="hideNavBar()">Hide Nav Bar</button>
    <button onclick="showNavBar()">Show Nav Bar</button>

    <script>
        function goBack() {
            window.webkit.messageHandlers.nativeBack.postMessage(null);
        }

        function openNewPage() {
            window.webkit.messageHandlers.nativeOpenURL.postMessage('https://www.apple.com');
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

### 8. Custom Scheme Handling

The web container automatically handles custom URL schemes:

```swift
// Links like these in web pages are automatically handled:
// tel:123-456-7890        -> Opens Phone app
// mailto:email@example.com -> Opens Mail app
// maps:?q=Cupertino       -> Opens Maps app
// Custom app schemes      -> Opens if registered
```

### 9. Extensions and Utilities

```swift
// URL Extensions
let url = URL(string: "https://example.com")
if url?.isHTTPScheme == true {
    print("This is an HTTP/HTTPS URL")
}

// String Extensions
let urlString = "https://example.com"
if urlString.isHTTPURLString {
    if let url = urlString.asURL {
        print("Valid URL: \(url)")
    }
}

// Bundle Extensions
if let image = Bundle.lwWebContainerImage(named: "backItem") {
    print("Loaded image from bundle")
}
```

## API Reference

### LWWebContainerViewController

#### Properties

- `urlString: String?` - The URL string to load
- `needNewTab: Bool` - Whether to open next navigation in new container
- `isPushed: Bool` - Whether this container was pushed to navigation stack
- `originNavigationBarHidden: Bool` - Original navigation bar hidden state
- `wkWebView: WKWebView!` - The underlying WKWebView

#### Methods

- `static func webViewController(with urlString: String) -> LWWebContainerViewController`
  - Create a new web container with URL string

- `func loadURL(_ url: URL)`
  - Load a URL in current container

- `func loadURLInNewTab(_ url: URL)`
  - Load a URL that will open in new container on navigation

- `func reload()`
  - Reload current page

### LWWebContainerView (SwiftUI)

#### Initializer

```swift
init(
    url: URL?,
    isLoading: Binding<Bool> = .constant(false),
    canGoBack: Binding<Bool> = .constant(false),
    canGoForward: Binding<Bool> = .constant(false),
    title: Binding<String> = .constant(""),
    onNavigationAction: ((URL) -> WKNavigationActionPolicy)? = nil
)
```

### LWCookieManager

#### Methods

- `func syncCookies(to webView: WKWebView, completion: (() -> Void)? = nil)`
  - Sync cookies from HTTPCookieStorage to WKWebView

- `func getAllCookies(from webView: WKWebView, completion: @escaping ([HTTPCookie]) -> Void)`
  - Get all cookies from WKWebView

- `func deleteAllCookies(from webView: WKWebView, completion: (() -> Void)? = nil)`
  - Delete all cookies from WKWebView

## Migration from Objective-C

If you're migrating from the Objective-C version:

### Before (Objective-C)

```objc
#import "LWWebContainerVC.h"

LWWebContainerVC *webVC = [LWWebContainerVC webViewControllerWithURLString:@"https://www.example.com"];
[self.navigationController pushViewController:webVC animated:YES];
```

### After (Swift)

```swift
import LWWebContainer

let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")
navigationController?.pushViewController(webVC, animated: true)
```

## Best Practices

1. **Memory Management**: The web container automatically manages observers and delegates. No manual cleanup needed.

2. **Cookie Sync**: Cookies are automatically synced between HTTPCookieStorage and WKWebView on iOS 11+.

3. **Navigation**: Use `isPushed = true` when pushing to navigation stack to enable proper new-tab behavior.

4. **Custom Schemes**: The container automatically opens custom schemes with UIApplication. No additional setup needed.

5. **Progress Indicator**: The built-in progress bar is automatically shown/hidden during page loads.

## Troubleshooting

### Web page not loading

- Check that the URL is valid and starts with http:// or https://
- Ensure App Transport Security settings allow the domain (Info.plist)

### JavaScript bridge not working

- Verify the message handler names are correct
- Check that JavaScript is enabled in WKWebView (enabled by default)
- Use browser console to debug JavaScript errors

### Cookies not persisting

- Ensure you're testing on iOS 11+ for automatic cookie sync
- Use LWCookieManager to manually sync if needed
- Check that cookies are not being blocked by the web server

## License

MIT License - See LICENSE file for details

## Author

luowei - luowei@wodedata.com

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
