//
//  LWWebContainerExtensions.swift
//  LWWebContainer
//
//  Created by luowei on 2025/10/04.
//  Copyright © 2025 luowei. All rights reserved.
//

import Foundation
import WebKit

// MARK: - URL Extensions

public extension URL {

    /// Check if the URL is an HTTP/HTTPS URL
    var isHTTPScheme: Bool {
        return scheme == "http" || scheme == "https"
    }

    /// Check if the URL can be opened by the system
    var canBeOpened: Bool {
        return UIApplication.shared.canOpenURL(self)
    }
}

// MARK: - String Extensions

public extension String {

    /// Convert string to URL if valid
    var asURL: URL? {
        return URL(string: self)
    }

    /// Check if string starts with HTTP/HTTPS
    var isHTTPURLString: Bool {
        return hasPrefix("http://") || hasPrefix("https://")
    }
}

// MARK: - WKWebView Extensions

public extension WKWebView {

    /// Load a URL from a string
    /// - Parameter urlString: The URL string to load
    func load(urlString: String) {
        guard let url = URL(string: urlString) else {
            WCLog("Invalid URL string: \(urlString)")
            return
        }
        load(URLRequest(url: url))
    }

    /// Execute JavaScript and get the result
    /// - Parameters:
    ///   - script: The JavaScript code to execute
    ///   - completion: Completion handler with result or error
    func evaluateJavaScript(_ script: String, completion: ((Result<Any?, Error>) -> Void)? = nil) {
        evaluateJavaScript(script) { result, error in
            if let error = error {
                completion?(.failure(error))
            } else {
                completion?(.success(result))
            }
        }
    }

    /// Inject CSS into the web page
    /// - Parameter css: The CSS code to inject
    func injectCSS(_ css: String) {
        let script = """
        var style = document.createElement('style');
        style.innerHTML = '\(css.replacingOccurrences(of: "\n", with: "\\n").replacingOccurrences(of: "'", with: "\\'"))';
        document.head.appendChild(style);
        """
        evaluateJavaScript(script)
    }

    /// Inject JavaScript into the web page
    /// - Parameter javascript: The JavaScript code to inject
    func injectJavaScript(_ javascript: String) {
        evaluateJavaScript(javascript)
    }
}

// MARK: - Bundle Extensions

public extension Bundle {

    /// Get the LWWebContainer resource bundle
    static var lwWebContainerBundle: Bundle? {
        let mainBundle = Bundle(for: LWWebContainerViewController.self)
        if let bundlePath = mainBundle.path(forResource: "LWWebContainer", ofType: "bundle"),
           let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        return Bundle.main
    }

    /// Load an image from the LWWebContainer bundle
    /// - Parameter name: The name of the image
    /// - Returns: The image if found
    static func lwWebContainerImage(named name: String) -> UIImage? {
        return UIImage(named: name, in: lwWebContainerBundle, compatibleWith: nil)
    }
}

// MARK: - Cookie Management

public class LWCookieManager {

    public static let shared = LWCookieManager()

    private init() {}

    /// Sync cookies from HTTPCookieStorage to WKWebView
    /// - Parameter completion: Completion handler
    @available(iOS 11.0, *)
    public func syncCookies(to webView: WKWebView, completion: (() -> Void)? = nil) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore

        guard let cookies = HTTPCookieStorage.shared.cookies else {
            completion?()
            return
        }

        let group = DispatchGroup()

        for cookie in cookies {
            group.enter()
            cookieStore.setCookie(cookie) {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion?()
        }
    }

    /// Get all cookies from WKWebView
    /// - Parameters:
    ///   - webView: The web view
    ///   - completion: Completion handler with cookies array
    @available(iOS 11.0, *)
    public func getAllCookies(from webView: WKWebView, completion: @escaping ([HTTPCookie]) -> Void) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            completion(cookies)
        }
    }

    /// Delete all cookies from WKWebView
    /// - Parameters:
    ///   - webView: The web view
    ///   - completion: Completion handler
    @available(iOS 11.0, *)
    public func deleteAllCookies(from webView: WKWebView, completion: (() -> Void)? = nil) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore

        cookieStore.getAllCookies { cookies in
            let group = DispatchGroup()

            for cookie in cookies {
                group.enter()
                cookieStore.delete(cookie) {
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion?()
            }
        }
    }
}

// MARK: - Script Message Models

public struct LWScriptMessage {
    public let name: String
    public let body: Any

    public var bodyAsString: String? {
        return body as? String
    }

    public var bodyAsDictionary: [String: Any]? {
        return body as? [String: Any]
    }

    public var bodyAsArray: [Any]? {
        return body as? [Any]
    }
}

// MARK: - Navigation Action Policy

public enum LWNavigationActionPolicy {
    case allow
    case cancel
    case openInNewTab

    var wkPolicy: WKNavigationActionPolicy {
        switch self {
        case .allow:
            return .allow
        case .cancel, .openInNewTab:
            return .cancel
        }
    }
}

// MARK: - Web Container Configuration

public struct LWWebContainerConfiguration {

    /// Enable debug logging
    public var enableDebugLogging: Bool = false

    /// Default URL if none provided
    public var defaultURL: String = "https://luowei.github.io"

    /// Enable pull to refresh
    public var enablePullToRefresh: Bool = true

    /// Enable back/forward gestures
    public var enableBackForwardGestures: Bool = true

    /// Progress bar color
    public var progressBarColor: UIColor = .blue

    /// Back button image name
    public var backButtonImageName: String = "backItem"

    /// Custom user agent
    public var customUserAgent: String?

    /// Additional JavaScript to inject on page load
    public var additionalJavaScript: String?

    /// Additional CSS to inject on page load
    public var additionalCSS: String?

    public init() {}
}
