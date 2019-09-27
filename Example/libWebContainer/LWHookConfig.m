//
// Created by luowei on 15/9/14.
// Copyright (c) 2015 luowei. All rights reserved.
//

#import "LWHookConfig.h"
#import "WCAppDelegate.h"
#import <Aspects/Aspects.h>
#import <libWebContainer/LWWebContainerVC.h>


@implementation LWHookConfig {

}

+ (NSDictionary *)hookEventDict {
    return @{
            @"LWWebContainerVC": @{
                    Hook_TrackedEvents: @[
//                            @{
//                                Hook_EventName: @"logo按钮点击",
//                                Hook_Option: @(AspectPositionAfter),
//                                Hook_EventSelectorName: @"logoBtnTouchUpInside:",
//                                Hook_EventHandlerBlock: ^(id <AspectInfo> aspectInfo) {
//                                    WCLog(@"========logo click hooked =======");
//                                },
//                            },
                            @{
                                Hook_EventName: @"viewDidLoad",
                                Hook_Option: @(AspectPositionBefore),
                                Hook_EventSelectorName: @"viewDidLoad",
                                Hook_EventHandlerBlock: ^(id <AspectInfo> aspectInfo) {
                                    WCLog(@"========viewDidLoad hooked =======");
                                    LWWebContainerVC *vc = (LWWebContainerVC *)aspectInfo.instance;
                                    if(vc.isPushed){
                                        return;
                                    }
                                    WCAppDelegate *appDelegate = (WCAppDelegate *)UIApplication.sharedApplication.delegate;
                                    switch(vc.tabBarController.selectedIndex){
                                        case 0:{
                                            vc.urlstring = appDelegate.config[@"home"];
                                            vc.originNavigationBarHidden = YES;
                                            break;
                                        }
                                        case 1:{
                                            vc.urlstring = appDelegate.config[@"mall"];
                                            break;
                                        }
                                        case 2:{
                                            vc.urlstring = appDelegate.config[@"me"];
                                            break;
                                        }
                                        default:{
                                            break;
                                        }
                                    }
                                },
                            },
                    ],
            },

            @"LWLogoPopView": @{
            }
    };
}

@end


@implementation UIResponder(Hook)

+ (void)load {
    [super load];

    [UIResponder setupWithConfiguration:[LWHookConfig hookEventDict]];
}

+ (void)setupWithConfiguration:(NSDictionary *)configs {
    // Hook Events
    for (NSString *className in configs) {
        Class clazz = NSClassFromString(className);
        NSDictionary *config = configs[className];
        if(clazz==nil || config==nil){
            return;
        }

        if (config[Hook_TrackedEvents]) {
            for (NSDictionary *event in config[Hook_TrackedEvents]) {
                SEL selekor = NSSelectorFromString(event[Hook_EventSelectorName]);
                HookHandlerBlock block = event[Hook_EventHandlerBlock];

                if(selekor==nil || block == nil){
                    return;
                }

                [clazz aspect_hookSelector:selekor
                               withOptions:(AspectOptions) ((NSNumber *)event[Hook_Option]).intValue
                                usingBlock:^(id<AspectInfo> aspectInfo) {
                                    block(aspectInfo);
                                } error:NULL];

            }
        }
    }
}

@end