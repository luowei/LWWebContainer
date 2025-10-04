# Migration Guide: Objective-C to Swift

This guide helps you migrate from the Objective-C version of LWWebContainer to the Swift version.

## Installation Changes

### Objective-C Version (CocoaPods)

```ruby
pod 'LWWebContainer', '~> 1.0'
```

### Swift Version (CocoaPods)

```ruby
pod 'LWWebContainer-Swift', '~> 1.0'
```

Or use Swift Package Manager (new option):

```swift
dependencies: [
    .package(url: "https://github.com/luowei/LWWebContainer.git", from: "1.0.0")
]
```

## Code Migration Examples

### Example 1: Creating a Web Container

**Objective-C:**
```objc
#import "LWWebContainerVC.h"

LWWebContainerVC *webVC = [LWWebContainerVC webViewControllerWithURLString:@"https://www.example.com"];
```

**Swift:**
```swift
import LWWebContainer

let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")
```

### Example 2: Pushing to Navigation Controller

**Objective-C:**
```objc
LWWebContainerVC *webVC = [LWWebContainerVC webViewControllerWithURLString:@"https://www.example.com"];
webVC.isPushed = YES;
webVC.hidesBottomBarWhenPushed = YES;
[self.navigationController pushViewController:webVC animated:YES];
```

**Swift:**
```swift
let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")
webVC.isPushed = true
webVC.hidesBottomBarWhenPushed = true
navigationController?.pushViewController(webVC, animated: true)
```

### Example 3: Loading a URL

**Objective-C:**
```objc
NSURL *url = [NSURL URLWithString:@"https://www.apple.com"];
[webVC loadURL:url];
```

**Swift:**
```swift
if let url = URL(string: "https://www.apple.com") {
    webVC.loadURL(url)
}
```

### Example 4: Loading URL in New Tab

**Objective-C:**
```objc
NSURL *url = [NSURL URLWithString:@"https://www.apple.com"];
[webVC loadURLInNewTab:url];
```

**Swift:**
```swift
if let url = URL(string: "https://www.apple.com") {
    webVC.loadURLInNewTab(url)
}
```

### Example 5: Reloading

**Objective-C:**
```objc
[webVC reload];
```

**Swift:**
```swift
webVC.reload()
```

### Example 6: Accessing WKWebView

**Objective-C:**
```objc
[webVC.wkWebView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError *error) {
    if (!error) {
        NSString *title = result;
        NSLog(@"Title: %@", title);
    }
}];
```

**Swift:**
```swift
webVC.wkWebView.evaluateJavaScript("document.title") { result, error in
    if let title = result as? String {
        print("Title: \(title)")
    }
}
```

## Property Name Changes

All properties remain the same, only the syntax changes:

| Objective-C | Swift |
|-------------|-------|
| `@property(nonatomic) BOOL needNewTab;` | `var needNewTab: Bool` |
| `@property(nonatomic, strong) WKWebView *wkWebView;` | `var wkWebView: WKWebView!` |
| `@property(nonatomic, copy) NSString *urlstring;` | `var urlString: String?` |
| `@property(nonatomic) BOOL isPushed;` | `var isPushed: Bool` |
| `@property(nonatomic) BOOL originNavigationBarHidden;` | `var originNavigationBarHidden: Bool` |

## New Features in Swift Version

### 1. SwiftUI Support

The Swift version includes native SwiftUI views:

```swift
import SwiftUI
import LWWebContainer

struct ContentView: View {
    @State private var showWeb = false

    var body: some View {
        Button("Open Web") {
            showWeb = true
        }
        .lwWebContainer(url: URL(string: "https://www.example.com"), isPresented: $showWeb)
    }
}
```

### 2. Cookie Manager

New utility class for cookie management:

```swift
LWCookieManager.shared.syncCookies(to: webVC.wkWebView) {
    print("Cookies synced")
}

LWCookieManager.shared.getAllCookies(from: webVC.wkWebView) { cookies in
    print("Cookies: \(cookies)")
}
```

### 3. Extension Methods

New convenience extensions:

```swift
// WKWebView extensions
webVC.wkWebView.load(urlString: "https://www.example.com")
webVC.wkWebView.injectCSS("body { background: #f0f0f0; }")
webVC.wkWebView.injectJavaScript("console.log('Hello');")

// URL extensions
if url.isHTTPScheme {
    print("HTTP/HTTPS URL")
}

// String extensions
if urlString.isHTTPURLString {
    let url = urlString.asURL
}

// Bundle extensions
let image = Bundle.lwWebContainerImage(named: "backItem")
```

### 4. Configuration (Future Enhancement)

```swift
var config = LWWebContainerConfiguration()
config.enableDebugLogging = true
config.defaultURL = "https://myapp.com"
config.progressBarColor = .systemBlue
```

## Key Differences

### 1. Nullability

**Objective-C** uses nullable/nonnull annotations:
```objc
- (nullable instancetype)initWithURL:(NSURL * _Nullable)url;
```

**Swift** uses optionals:
```swift
init(url: URL?)
```

### 2. Method Names

**Objective-C:**
```objc
+ (instancetype)webViewControllerWithURLString:(NSString *)urlstring;
```

**Swift:**
```swift
static func webViewController(with urlString: String) -> LWWebContainerViewController
```

### 3. Blocks vs Closures

**Objective-C:**
```objc
[webView evaluateJavaScript:@"script" completionHandler:^(id result, NSError *error) {
    // Handle result
}];
```

**Swift:**
```swift
webView.evaluateJavaScript("script") { result, error in
    // Handle result
}
```

### 4. Type Safety

Swift provides better type safety:

```swift
// Swift enforces optional unwrapping
if let url = URL(string: urlString) {
    webVC.loadURL(url)
}

// Swift enum for navigation types
switch navigationAction.navigationType {
case .reload, .backForward:
    // Handle
default:
    break
}
```

## JavaScript Bridge - No Changes

The JavaScript bridge API remains exactly the same:

```javascript
// These work identically in both versions
window.webkit.messageHandlers.nativeBack.postMessage(null);
window.webkit.messageHandlers.nativeOpenURL.postMessage('https://example.com');
window.webkit.messageHandlers.webViewReload.postMessage(null);
```

## Testing Your Migration

### Step-by-step Testing

1. **Install Swift version**
   ```ruby
   pod 'LWWebContainer-Swift', '~> 1.0'
   ```

2. **Replace imports**
   ```swift
   // Remove: #import "LWWebContainerVC.h"
   // Add: import LWWebContainer
   ```

3. **Update class name**
   ```swift
   // Old: LWWebContainerVC
   // New: LWWebContainerViewController
   ```

4. **Update method calls**
   - Replace `[obj method:param]` with `obj.method(param)`
   - Replace `@"string"` with `"string"`
   - Replace `BOOL` with `Bool`
   - Replace `YES/NO` with `true/false`

5. **Test navigation**
   - Verify links open in new containers
   - Test back/forward gestures
   - Test JavaScript bridge

6. **Test edge cases**
   - Custom schemes (tel:, mailto:)
   - Cookie persistence
   - Pull to refresh
   - Progress indicator

## Common Issues and Solutions

### Issue 1: Module Not Found

**Error:** `No such module 'LWWebContainer'`

**Solution:** Ensure you've run `pod install` and you're opening the `.xcworkspace` file, not `.xcodeproj`

### Issue 2: Type Inference

**Error:** Type mismatch errors

**Solution:** Be explicit with types:
```swift
let urlString: String = "https://example.com"
let webVC: LWWebContainerViewController = .webViewController(with: urlString)
```

### Issue 3: Optional Unwrapping

**Error:** Value of optional type 'Type?' must be unwrapped

**Solution:** Use optional binding:
```swift
if let navigationController = navigationController {
    navigationController.pushViewController(webVC, animated: true)
}
// Or use optional chaining:
navigationController?.pushViewController(webVC, animated: true)
```

## Benefits of Migration

1. **Type Safety**: Swift's strong typing catches errors at compile time
2. **Modern Syntax**: Cleaner, more readable code
3. **SwiftUI Support**: Use in modern SwiftUI apps
4. **Better Tooling**: Improved autocomplete and documentation
5. **Future-Proof**: Swift is the future of iOS development
6. **New Features**: Access to Swift-only features and extensions

## Gradual Migration

You can use both versions in the same project during migration:

```ruby
# Podfile
pod 'LWWebContainer', '~> 1.0'           # Objective-C version
pod 'LWWebContainer-Swift', '~> 1.0'     # Swift version
```

Then migrate file by file, testing thoroughly after each change.

## Support

If you encounter issues during migration:

1. Check the [SWIFT_USAGE.md](SWIFT_USAGE.md) documentation
2. Review [LWWebContainerUsageExamples.swift](LWWebContainer/Swift/LWWebContainerUsageExamples.swift)
3. Open an issue on GitHub with:
   - Original Objective-C code
   - Your Swift translation attempt
   - Error messages
   - iOS version and Xcode version

## Conclusion

The migration from Objective-C to Swift is straightforward. The API structure remains the same, with only syntax changes. The Swift version adds new features while maintaining full compatibility with the original functionality.
