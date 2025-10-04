//
//  LWWebContainerViewController.swift
//  LWWebContainer
//
//  Created by luowei on 2025/10/04.
//  Copyright © 2025 luowei. All rights reserved.
//

import UIKit
import WebKit

#if DEBUG
func WCLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let output = items.map { "\($0)" }.joined(separator: separator)
    print("[\(#function)] \(output)\(terminator)")
}
#else
func WCLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {}
#endif

public class LWWebContainerViewController: UIViewController {

    // MARK: - Public Properties

    public var needNewTab: Bool = false
    public var urlString: String?
    public var isPushed: Bool = false
    public var originNavigationBarHidden: Bool = false

    public private(set) var wkWebView: WKWebView!

    // MARK: - Private Properties

    private var webProgress: UIProgressView!
    private var configuration: WKWebViewConfiguration!
    private var refreshControl: UIRefreshControl!

    private static var processPool: WKProcessPool = {
        return WKProcessPool()
    }()

    // MARK: - Initialization

    public static func webViewController(with urlString: String) -> LWWebContainerViewController {
        let vc = LWWebContainerViewController()
        vc.urlString = urlString
        return vc
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // Setup back button if not root view controller
        if navigationController?.viewControllers.first != self {
            navigationItem.leftBarButtonItem = createBackButton()
        }

        setupWebView()
        setupProgressView()
        setupRefreshControl()

        // Load initial URL
        if let urlString = urlString, !urlString.isEmpty {
            if let url = URL(string: urlString) {
                loadURL(url)
            }
        } else {
            if let url = URL(string: "https://luowei.github.io") {
                loadURL(url)
            }
        }
    }

    deinit {
        if #available(iOS 11.0, *) {
            configuration.websiteDataStore.httpCookieStore.remove(self)
        }
        wkWebView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        wkWebView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.isNavigationBarHidden = originNavigationBarHidden
    }

    // MARK: - Setup Methods

    private func setupWebView() {
        // Configure WKWebView
        configuration = WKWebViewConfiguration()
        configuration.processPool = LWWebContainerViewController.processPool

        let userContentController = WKUserContentController()

        // Add script message handlers
        let handlers = [
            "webViewReload", "webViewBack", "webViewForward", "webViewOpenURL",
            "nativeHideNavBar", "nativeShowNavBar", "nativeBack", "nativeOpenURL"
        ]

        for handler in handlers {
            userContentController.add(self, name: handler)
        }

        configuration.userContentController = userContentController

        // Sync cookies
        if #available(iOS 11.0, *) {
            configuration.websiteDataStore.httpCookieStore.add(self)
            if let cookies = HTTPCookieStorage.shared.cookies {
                for cookie in cookies {
                    configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
                }
            }
        }

        wkWebView = WKWebView(frame: view.bounds, configuration: configuration)
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self
        wkWebView.allowsBackForwardNavigationGestures = true
        wkWebView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(wkWebView)

        // Setup constraints
        NSLayoutConstraint.activate([
            wkWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wkWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wkWebView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            wkWebView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Add KVO observers
        wkWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        wkWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
    }

    private func setupProgressView() {
        webProgress = UIProgressView(progressViewStyle: .default)
        webProgress.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webProgress)

        NSLayoutConstraint.activate([
            webProgress.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webProgress.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webProgress.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webProgress.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        wkWebView.scrollView.addSubview(refreshControl)
    }

    // MARK: - Public Methods

    public func loadURL(_ url: URL) {
        needNewTab = false
        wkWebView.load(URLRequest(url: url))
    }

    public func loadURLInNewTab(_ url: URL) {
        needNewTab = true
        wkWebView.load(URLRequest(url: url))
    }

    public func reload() {
        WCLog("Reload: \(wkWebView.url?.absoluteString ?? "")")
        wkWebView.reload()
    }

    // MARK: - Private Methods

    @objc private func refreshReload() {
        reload()
        refreshControl.endRefreshing()
    }

    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }

    private func createBackButton() -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)

        if let image = loadBundleImage(named: "backItem") {
            button.setImage(image, for: .normal)
        }

        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        button.contentHorizontalAlignment = .left

        let screenWidth = UIScreen.main.bounds.width
        let inset = -1 * screenWidth / 375.0
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 0)

        return UIBarButtonItem(customView: button)
    }

    private func loadBundleImage(named name: String) -> UIImage? {
        let bundle = Bundle(for: type(of: self))
        if let bundlePath = bundle.path(forResource: "LWWebContainer", ofType: "bundle"),
           let resourceBundle = Bundle(path: bundlePath) {
            return UIImage(named: name, in: resourceBundle, compatibleWith: nil)
        }
        return UIImage(named: name, in: Bundle.main, compatibleWith: nil)
    }

    private func appOpenURLString(_ urlString: String) {
        guard let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else { return }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    // MARK: - KVO

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            let animated = wkWebView.estimatedProgress > webProgress.progress
            webProgress.setProgress(Float(wkWebView.estimatedProgress), animated: animated)

            if wkWebView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.webProgress.isHidden = true
                }, completion: { _ in
                    self.webProgress.setProgress(0.0, animated: false)
                })
            }
        } else if keyPath == #keyPath(WKWebView.title) {
            navigationItem.title = wkWebView.title
        }
    }
}

// MARK: - WKNavigationDelegate

extension LWWebContainerViewController: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webProgress.isHidden = false
        webProgress.setProgress(0.0, animated: false)
        webProgress.trackTintColor = .white
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let urlString = url.absoluteString

        // Handle non-http URLs
        if !urlString.hasPrefix("http") {
            WCLog("urlString: \(urlString)")
            appOpenURLString(urlString)
            decisionHandler(.cancel)
            return
        }

        WCLog("navigationType: \(navigationAction.navigationType.rawValue)")

        // Allow certain navigation types without new tab logic
        switch navigationAction.navigationType {
        case .reload, .backForward, .formSubmitted, .formResubmitted:
            decisionHandler(.allow)
            return
        default:
            break
        }

        // Handle new tab logic when pushed
        if isPushed {
            if urlString.hasPrefix("http") && needNewTab {
                WCLog("Opening in new tab: \(urlString)")
                let vc = LWWebContainerViewController.webViewController(with: urlString)
                vc.isPushed = true
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
                decisionHandler(.cancel)
            } else {
                needNewTab = true
                decisionHandler(.allow)
            }
            return
        }

        // Handle new tab logic for root
        if urlString.hasPrefix("http") && needNewTab {
            WCLog("Opening in new tab: \(urlString)")
            let vc = LWWebContainerViewController.webViewController(with: urlString)
            vc.isPushed = true
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
            decisionHandler(.cancel)
        } else {
            needNewTab = true
            decisionHandler(.allow)
        }
    }
}

// MARK: - WKUIDelegate

extension LWWebContainerViewController: WKUIDelegate {
    // Add WKUIDelegate methods as needed
}

// MARK: - WKScriptMessageHandler

extension LWWebContainerViewController: WKScriptMessageHandler {

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        switch message.name {
        case "nativeBack":
            navigationController?.popViewController(animated: true)

        case "nativeOpenURL":
            guard let urlString = message.body as? String else { return }

            if !urlString.hasPrefix("http") {
                appOpenURLString(urlString)
                return
            }

            if urlString.hasPrefix("http") && needNewTab {
                WCLog("Opening: \(urlString)")
                let vc = LWWebContainerViewController.webViewController(with: urlString)
                vc.isPushed = true
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            } else {
                needNewTab = true
            }

        case "nativeHideNavBar":
            originNavigationBarHidden = true
            navigationController?.isNavigationBarHidden = originNavigationBarHidden

        case "nativeShowNavBar":
            originNavigationBarHidden = false
            navigationController?.isNavigationBarHidden = originNavigationBarHidden

        case "webViewBack":
            wkWebView.goBack()

        case "webViewForward":
            wkWebView.goForward()

        case "webViewReload":
            reload()

        case "webViewOpenURL":
            guard let urlString = message.body as? String,
                  let url = URL(string: urlString) else { return }
            loadURL(url)

        default:
            // TODO: Add encryption/decryption, camera/photo library access, etc.
            break
        }
    }
}

// MARK: - WKHTTPCookieStoreObserver

@available(iOS 11.0, *)
extension LWWebContainerViewController: WKHTTPCookieStoreObserver {

    public func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        cookieStore.getAllCookies { cookies in
            for cookie in cookies {
                cookieStore.setCookie(cookie)
            }
        }
    }
}
