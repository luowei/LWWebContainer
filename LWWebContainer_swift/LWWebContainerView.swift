//
//  LWWebContainerView.swift
//  LWWebContainer
//
//  Created by luowei on 2025/10/04.
//  Copyright © 2025 luowei. All rights reserved.
//

import SwiftUI
import WebKit

/// A SwiftUI wrapper for WKWebView with navigation support
@available(iOS 13.0, *)
public struct LWWebContainerView: UIViewRepresentable {

    // MARK: - Properties

    public let url: URL?
    @Binding public var isLoading: Bool
    @Binding public var canGoBack: Bool
    @Binding public var canGoForward: Bool
    @Binding public var title: String

    public var onNavigationAction: ((URL) -> WKNavigationActionPolicy)?

    // MARK: - Initialization

    public init(
        url: URL?,
        isLoading: Binding<Bool> = .constant(false),
        canGoBack: Binding<Bool> = .constant(false),
        canGoForward: Binding<Bool> = .constant(false),
        title: Binding<String> = .constant(""),
        onNavigationAction: ((URL) -> WKNavigationActionPolicy)? = nil
    ) {
        self.url = url
        self._isLoading = isLoading
        self._canGoBack = canGoBack
        self._canGoForward = canGoForward
        self._title = title
        self.onNavigationAction = onNavigationAction
    }

    // MARK: - UIViewRepresentable

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = LWWebContainerViewController.getProcessPool()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        if let url = url {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        // Update bindings
        DispatchQueue.main.async {
            self.isLoading = webView.isLoading
            self.canGoBack = webView.canGoBack
            self.canGoForward = webView.canGoForward
            self.title = webView.title ?? ""
        }
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {

        var parent: LWWebContainerView

        init(_ parent: LWWebContainerView) {
            self.parent = parent
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
            parent.title = webView.title ?? ""
        }

        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            if let handler = parent.onNavigationAction {
                let policy = handler(url)
                decisionHandler(policy)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}

// MARK: - Extension for LWWebContainerViewController

extension LWWebContainerViewController {
    static func getProcessPool() -> WKProcessPool {
        return processPool
    }
}

// MARK: - SwiftUI View Modifiers

@available(iOS 13.0, *)
public extension View {

    /// Navigate to a web page using LWWebContainerView
    func lwWebContainer(url: URL?, isPresented: Binding<Bool>) -> some View {
        self.sheet(isPresented: isPresented) {
            NavigationView {
                LWWebContainerViewWrapper(url: url)
            }
        }
    }
}

// MARK: - Helper View

@available(iOS 13.0, *)
struct LWWebContainerViewWrapper: View {

    let url: URL?

    @State private var isLoading = false
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var title = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle())
            }

            LWWebContainerView(
                url: url,
                isLoading: $isLoading,
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                title: $title
            )
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    // Go back action
                }) {
                    Image(systemName: "chevron.left")
                }
                .disabled(!canGoBack)

                Spacer()

                Button(action: {
                    // Go forward action
                }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!canGoForward)

                Spacer()

                Button(action: {
                    // Reload action
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

// MARK: - Convenience View for UIKit Integration

@available(iOS 13.0, *)
public struct LWWebContainerRepresentable: UIViewControllerRepresentable {

    public let urlString: String

    public init(urlString: String) {
        self.urlString = urlString
    }

    public func makeUIViewController(context: Context) -> UINavigationController {
        let webVC = LWWebContainerViewController.webViewController(with: urlString)
        let navController = UINavigationController(rootViewController: webVC)
        return navController
    }

    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed
    }
}
