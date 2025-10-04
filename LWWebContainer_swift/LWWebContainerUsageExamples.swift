//
//  LWWebContainerUsageExamples.swift
//  LWWebContainer
//
//  Created by luowei on 2025/10/04.
//  Copyright © 2025 luowei. All rights reserved.
//
//  This file contains usage examples for the LWWebContainer Swift library.
//  These are example functions showing how to use the library in different scenarios.
//

import UIKit
import SwiftUI

// MARK: - UIKit Usage Examples

class ExampleViewController: UIViewController {

    // MARK: - Example 1: Basic Usage - Present Web Container

    func example_presentWebContainer() {
        let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")
        let navController = UINavigationController(rootViewController: webVC)
        present(navController, animated: true, completion: nil)
    }

    // MARK: - Example 2: Push Web Container

    func example_pushWebContainer() {
        let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")
        webVC.isPushed = true
        navigationController?.pushViewController(webVC, animated: true)
    }

    // MARK: - Example 3: Load URL in Existing Container

    func example_loadURLInContainer() {
        let webVC = LWWebContainerViewController()
        webVC.urlString = "https://www.example.com"

        // Load URL
        if let url = URL(string: "https://www.apple.com") {
            webVC.loadURL(url)
        }
    }

    // MARK: - Example 4: Load URL in New Tab

    func example_loadURLInNewTab() {
        let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")

        // This will open the URL in a new container when navigation happens
        if let url = URL(string: "https://www.apple.com") {
            webVC.loadURLInNewTab(url)
        }

        navigationController?.pushViewController(webVC, animated: true)
    }

    // MARK: - Example 5: Access WebView Directly

    func example_accessWebView() {
        let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")

        // Access the WKWebView directly after viewDidLoad
        webVC.viewDidLoad()

        // Execute JavaScript
        webVC.wkWebView.evaluateJavaScript("document.title") { result, error in
            if let title = result as? String {
                print("Page title: \(title)")
            }
        }

        // Reload
        webVC.reload()

        // Navigate
        webVC.wkWebView.goBack()
        webVC.wkWebView.goForward()
    }

    // MARK: - Example 6: Cookie Management

    func example_cookieManagement() {
        let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")
        webVC.viewDidLoad()

        if #available(iOS 11.0, *) {
            // Sync cookies
            LWCookieManager.shared.syncCookies(to: webVC.wkWebView) {
                print("Cookies synced")
            }

            // Get all cookies
            LWCookieManager.shared.getAllCookies(from: webVC.wkWebView) { cookies in
                print("Total cookies: \(cookies.count)")
            }

            // Delete all cookies
            LWCookieManager.shared.deleteAllCookies(from: webVC.wkWebView) {
                print("All cookies deleted")
            }
        }
    }
}

// MARK: - SwiftUI Usage Examples

@available(iOS 13.0, *)
struct ExampleSwiftUIView: View {

    @State private var showWebView = false
    @State private var isLoading = false
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var pageTitle = ""

    var body: some View {
        VStack {
            exampleBasicUsage
            exampleCustomWebView
            exampleWithUIKit
        }
    }

    // MARK: - Example 1: Basic SwiftUI Integration

    var exampleBasicUsage: some View {
        Button("Open Web Page") {
            showWebView = true
        }
        .lwWebContainer(url: URL(string: "https://www.example.com"), isPresented: $showWebView)
    }

    // MARK: - Example 2: Custom SwiftUI Web View

    var exampleCustomWebView: some View {
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

            HStack {
                Button("Back") {
                    // Handle back
                }
                .disabled(!canGoBack)

                Button("Forward") {
                    // Handle forward
                }
                .disabled(!canGoForward)

                Text(pageTitle)
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Example 3: UIKit ViewController in SwiftUI

    var exampleWithUIKit: some View {
        LWWebContainerRepresentable(urlString: "https://www.example.com")
    }
}

// MARK: - Advanced Examples

class AdvancedExampleViewController: UIViewController {

    // MARK: - Example 7: Inject Custom JavaScript

    func example_injectJavaScript() {
        let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")
        webVC.viewDidLoad()

        let javascript = """
        console.log('Hello from native!');
        document.body.style.backgroundColor = '#f0f0f0';
        """

        webVC.wkWebView.injectJavaScript(javascript)
    }

    // MARK: - Example 8: Inject Custom CSS

    func example_injectCSS() {
        let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")
        webVC.viewDidLoad()

        let css = """
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        a {
            color: #007AFF;
        }
        """

        webVC.wkWebView.injectCSS(css)
    }

    // MARK: - Example 9: Handle Custom Schemes

    func example_customSchemeHandling() {
        let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")

        // The web container automatically handles non-http schemes
        // by attempting to open them with UIApplication.shared.open()

        // For example, clicking a link like "tel:123-456-7890" or "mailto:email@example.com"
        // will automatically open the Phone or Mail app
    }

    // MARK: - Example 10: Communication Between Web and Native

    func example_webToNativeJavaScriptBridge() {
        // In the web page JavaScript, you can call:
        //
        // window.webkit.messageHandlers.nativeBack.postMessage(null);
        // window.webkit.messageHandlers.nativeOpenURL.postMessage('https://www.apple.com');
        // window.webkit.messageHandlers.nativeHideNavBar.postMessage(null);
        // window.webkit.messageHandlers.nativeShowNavBar.postMessage(null);
        // window.webkit.messageHandlers.webViewBack.postMessage(null);
        // window.webkit.messageHandlers.webViewForward.postMessage(null);
        // window.webkit.messageHandlers.webViewReload.postMessage(null);
        // window.webkit.messageHandlers.webViewOpenURL.postMessage('https://www.apple.com');

        let webVC = LWWebContainerViewController.webViewController(with: "https://www.example.com")
        navigationController?.pushViewController(webVC, animated: true)
    }
}

// MARK: - Configuration Examples

class ConfigurationExampleViewController: UIViewController {

    // MARK: - Example 11: Using Configuration (Future Enhancement)

    func example_usingConfiguration() {
        var config = LWWebContainerConfiguration()
        config.enableDebugLogging = true
        config.defaultURL = "https://myapp.com"
        config.enablePullToRefresh = true
        config.progressBarColor = .systemBlue
        config.customUserAgent = "MyApp/1.0"

        // Note: Configuration support would need to be added to LWWebContainerViewController
        // This is a demonstration of how it could work
    }
}

// MARK: - Helper Extensions for Examples

extension LWWebContainerViewController {

    /// Example of creating a custom web container with additional setup
    static func customWebViewController(with urlString: String, customSetup: ((LWWebContainerViewController) -> Void)? = nil) -> LWWebContainerViewController {
        let vc = webViewController(with: urlString)
        customSetup?(vc)
        return vc
    }
}
