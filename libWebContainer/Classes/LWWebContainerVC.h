//
//  LWWebContainerVC.h
//  mymall
//
//  Created by luowei on 2019/9/23.
//  Copyright © 2019 mymall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#ifdef DEBUG
#define WCLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define WCLog(...)
#endif

#define LWWebContainerBundle(obj)  ([NSBundle bundleWithPath:[[NSBundle bundleForClass:[obj class]] pathForResource:@"libWebContainer" ofType:@"bundle"]] ?: ([NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"libWebContainer " ofType:@"bundle"]] ?: [NSBundle mainBundle]))
#define UIImageWithName(name,obj) ([UIImage imageNamed:name inBundle:LWWebContainerBundle(obj) compatibleWithTraitCollection:nil])


@interface LWWebContainerVC : UIViewController


@property(nonatomic) BOOL needNewTab;
@property(nonatomic, strong) WKWebView *wkWebView;
@property(nonatomic, copy) NSString *urlstring;


@property(nonatomic) BOOL isPushed;

@property(nonatomic) BOOL originNavigationBarHidden;

+ (instancetype)webViewControllerWithURLString:(NSString *)urlstring;

//加载URL
- (void)loadURL:(NSURL *)url;
//在新容器中加载URL
- (void)loadURLInNewTab:(NSURL *)url;

- (void)reload;
@end

