//
//  LWWebContainerVC.m
//  mymall
//
//  Created by luowei on 2019/9/23.
//  Copyright © 2019 mymall. All rights reserved.
//


#import "LWWebContainerVC.h"


@interface LWWebContainerVC ()<WKNavigationDelegate,WKUIDelegate,WKHTTPCookieStoreObserver,WKScriptMessageHandler>
@property(nonatomic, strong) UIProgressView *webProgress;
@property(nonatomic, strong) WKWebViewConfiguration *configuration;
@end


@implementation LWWebContainerVC

+ (instancetype)webViewControllerWithURLString:(NSString *)urlstring {
    LWWebContainerVC *vc = [LWWebContainerVC new];
    vc.urlstring = urlstring;
    return vc;
}


static WKProcessPool *_pool;

+ (WKProcessPool *)pool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pool = [[WKProcessPool alloc] init];
    });
    return _pool;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.navigationController.viewControllers.firstObject != self) {
        self.navigationItem.leftBarButtonItem = [self backItemWithAction:@selector(backAction)];
    }


    self.configuration = [[WKWebViewConfiguration alloc] init];
    self.configuration.userContentController = [WKUserContentController new];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"webViewReload"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"webViewBack"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"webViewForward"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"webViewOpenURL"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"nativeHideNavBar"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"nativeShowNavBar"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"nativeBack"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"nativeOpenURL"];
    self.configuration.processPool = [LWWebContainerVC pool];
    if (@available(iOS 11.0, *)) {
        [self.configuration.websiteDataStore.httpCookieStore addObserver:self];
        for (NSHTTPCookie *cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies) {
            [self.configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:nil];
        }
    }

    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:self.configuration];
    [self.view addSubview:self.wkWebView];
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    self.wkWebView.allowsBackForwardNavigationGestures = YES;
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];

    self.wkWebView.translatesAutoresizingMaskIntoConstraints = YES;
    NSLayoutConstraint *webLeft = [NSLayoutConstraint constraintWithItem:self.wkWebView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *webRight = [NSLayoutConstraint constraintWithItem:self.wkWebView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *webTop = [NSLayoutConstraint constraintWithItem:self.wkWebView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *webBottom = [NSLayoutConstraint constraintWithItem:self.wkWebView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [NSLayoutConstraint activateConstraints:@[webLeft,webRight,webTop,webBottom]];

    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshReload:) forControlEvents:UIControlEventValueChanged];
    [self.wkWebView.scrollView addSubview:refreshControl];

    self.webProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 2)];
    [self.view addSubview:self.webProgress];

    self.webProgress.translatesAutoresizingMaskIntoConstraints = YES;
    NSLayoutConstraint *progressLeft = [NSLayoutConstraint constraintWithItem:self.webProgress attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *progressRight = [NSLayoutConstraint constraintWithItem:self.webProgress attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *progressTop = [NSLayoutConstraint constraintWithItem:self.webProgress attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *progressHeight = [NSLayoutConstraint constraintWithItem:self.webProgress attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:2];
    [NSLayoutConstraint activateConstraints:@[progressLeft,progressRight,progressTop,progressHeight]];

    if (self.urlstring.length == 0) {
        self.urlstring = @"https://luowei.github.io";
    }
    NSURL *url = [NSURL URLWithString:self.urlstring];
    if (url) {
        [self loadURL:url];
    }

}

- (void)dealloc {
    if (@available(iOS 11.0, *)) {
        [self.configuration.websiteDataStore.httpCookieStore removeObserver:self];
    }
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebView removeObserver:self forKeyPath:@"title"];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    self.navigationController.navigationBarHidden = self.originNavigationBarHidden;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


//加载URL
- (void)loadURL:(NSURL *)url {
    self.needNewTab = NO;
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:url]];
}


//在新容器中加载URL
- (void)loadURLInNewTab:(NSURL *)url {
    self.needNewTab = YES;
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:url]];
}


- (void)reload {
    WCLog(@"===========Reload: %@",self.wkWebView.URL.absoluteString);
    [self.wkWebView reload];
}


- (void)refreshReload:(UIRefreshControl *)refreshControl {
    [self reload];
    [refreshControl endRefreshing];
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.webProgress.hidden = NO;
    [self.webProgress setProgress:0.0 animated:NO];
    self.webProgress.trackTintColor = [UIColor whiteColor];

}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSURL *url = navigationAction.request.URL;
    NSString *urlString = (url) ? url.absoluteString : @"";
    if(![urlString hasPrefix:@"http"]){
        WCLog("======urlString:%@",urlString);
        [self appOpenURLString:urlString];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    WCLog(@"=====navigationType:%ld", (long)navigationAction.navigationType);

//    if(navigationAction.navigationType == WKNavigationTypeOther){
    if(navigationAction.navigationType == WKNavigationTypeReload ||
            navigationAction.navigationType == WKNavigationTypeBackForward ||
            navigationAction.navigationType == WKNavigationTypeFormSubmitted ||
            navigationAction.navigationType == WKNavigationTypeFormResubmitted ){
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    if (self.isPushed) {
        if ([urlString hasPrefix:@"http"] && self.needNewTab) {
            WCLog(@"===========打开:%@",urlString);
            LWWebContainerVC *vc = [LWWebContainerVC webViewControllerWithURLString:urlString];
            vc.isPushed = YES;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            decisionHandler(WKNavigationActionPolicyCancel);
        }else{
            self.needNewTab = YES;
            decisionHandler(WKNavigationActionPolicyAllow);
        }

        return;
    }

    if([urlString hasPrefix:@"http"] && self.needNewTab){
        WCLog(@"===========打开:%@",urlString);
        LWWebContainerVC *vc = [LWWebContainerVC webViewControllerWithURLString:urlString];
        vc.isPushed = YES;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        decisionHandler(WKNavigationActionPolicyCancel);
    }else{
        self.needNewTab = YES;
        decisionHandler(WKNavigationActionPolicyAllow);
    }

}

//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
//    [self.configuration.websiteDataStore.httpCookieStore getAllCookies:^(NSArray *cookies) {
//        NSHTTPCookie *cookie;
//        for (cookie in cookies) {
//            [self.configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:nil];
//        }
//    }];
//    decisionHandler(WKNavigationResponsePolicyAllow);
//}



#pragma mark - WKHTTPCookieStoreObserver

- (void)cookiesDidChangeInCookieStore:(WKHTTPCookieStore *)cookieStore API_AVAILABLE(ios(11.0)){
    [self.configuration.websiteDataStore.httpCookieStore getAllCookies:^(NSArray *cookies) {
        for (NSHTTPCookie *cookie in cookies) {
            [self.configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:nil];
        }
    }];
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if([message.name isEqualToString:@"nativeBack"]) {
        [self.navigationController popViewControllerAnimated:YES];

    }else if([message.name isEqualToString:@"nativeOpenURL"]){
        NSString *urlString = (NSString *)message.body;
        if(![urlString hasPrefix:@"http"]){
            [self appOpenURLString:urlString];
            return;
        }
        if ([urlString hasPrefix:@"http"] && self.needNewTab) {
            WCLog(@"===========打开:%@",urlString);
            LWWebContainerVC *vc = [LWWebContainerVC webViewControllerWithURLString:urlString];
            vc.isPushed = YES;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            self.needNewTab = YES;
        }

    }else if([message.name isEqualToString:@"nativeHideNavBar"]) {
        self.originNavigationBarHidden = YES;
        self.navigationController.navigationBarHidden = self.originNavigationBarHidden;

    }else if([message.name isEqualToString:@"nativeShowNavBar"]) {
        self.originNavigationBarHidden = NO;
        self.navigationController.navigationBarHidden = self.originNavigationBarHidden;

    }else if ([message.name isEqualToString:@"webViewBack"]) {
        [self.wkWebView goBack];

    }else if ([message.name isEqualToString:@"webViewForward"]) {
        [self.wkWebView goForward];

    }else if ([message.name isEqualToString:@"webViewReload"]) {
        [self reload];

    } else if ([message.name isEqualToString:@"webViewOpenURL"]) {
        NSString *urlString = (NSString *)message.body;
        [self loadURL:[NSURL URLWithString:urlString]];
//        [self.wkWebView evaluateJavaScript:@"native回传结果" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//            WCLog(@"%@----%@",result, error);
//        }];

    }else{
        //todo: 加/解密、开相机/册...
    }
}

- (void)appOpenURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if([[UIApplication sharedApplication] canOpenURL:url]){
                if(@available(iOS 10.0,*)){
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                }else{
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
}


#pragma mark - Progress Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        BOOL animated = self.wkWebView.estimatedProgress > self.webProgress.progress;
        [self.webProgress setProgress:(float) self.wkWebView.estimatedProgress animated:animated];

        if (self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.webProgress.hidden = YES;
            }                completion:^(BOOL finished) {
                [self.webProgress setProgress:0.0f animated:NO];
            }];
        }
    }
    if ([keyPath isEqualToString:@"title"]) {
//        self.title = self.wkWebView.title;
        self.navigationItem.title = self.wkWebView.title;
    }
}

- (NSString *)valueForKey:(NSString *)key
           fromQueryItems:(NSArray *)queryItems {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems
            filteredArrayUsingPredicate:predicate]
            firstObject];
    return queryItem.value;
}


- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIBarButtonItem *)backItemWithAction:(nullable SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.f, 0.f, 44.f, 44.f);
    [button setImage:UIImageWithName(@"backItem",self) forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    if(@available(iOS 9.0,*)){
        button.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, (CGFloat) (-1 * CGRectGetWidth([UIScreen mainScreen].bounds) /375.0),0,0)];
    }
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
