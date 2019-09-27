//
// Created by luowei on 2019/9/25.
// Copyright (c) 2019 mymall. All rights reserved.
//

#import "MyTabBarController.h"
#import "WCAppDelegate.h"
#import <libWebContainer/LWWebContainerVC.h>


@implementation MyTabBarController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.delegate = self;

    // Do any additional setup after loading the view.
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];

}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSUInteger selectedIdx = (self.selectedIndex+1) % 3;
    UINavigationController *navVC = self.viewControllers[selectedIdx];
    LWWebContainerVC *webVC = navVC.viewControllers.firstObject;
//    [webVC reload];

    NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:@"config"];
    if(!config){
        config = ((WCAppDelegate *)[UIApplication sharedApplication].delegate).config;
    }
    switch (selectedIdx){
        case 0:{
            NSURL *url = [NSURL URLWithString:config[@"home"]];
            [webVC loadURL:url];
            break;
        }
        case 1:{
            NSURL *url = [NSURL URLWithString:config[@"mall"]];
            [webVC loadURL:url];
            break;
        }
        case 2:{
            NSURL *url = [NSURL URLWithString:config[@"me"]];
            [webVC loadURL:url];
            break;
        }
        default:{
            NSURL *url = [NSURL URLWithString:config[@"home"]];
            [webVC loadURL:url];
        }
    }
}

@end