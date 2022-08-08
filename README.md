# LWWebContainer

[![CI Status](https://img.shields.io/travis/luowei/LWWebContainer.svg?style=flat)](https://travis-ci.org/luowei/LWWebContainer)
[![Version](https://img.shields.io/cocoapods/v/LWWebContainer.svg?style=flat)](https://cocoapods.org/pods/LWWebContainer)
[![License](https://img.shields.io/cocoapods/l/LWWebContainer.svg?style=flat)](https://cocoapods.org/pods/LWWebContainer)
[![Platform](https://img.shields.io/cocoapods/p/LWWebContainer.svg?style=flat)](https://cocoapods.org/pods/LWWebContainer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```Objective-C
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

```

## Requirements

## Installation

LWWebContainer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LWWebContainer'
```

**Carthage**
```ruby
github "luowei/LWWebContainer"
```

## Author

luowei, luowei@wodedata.com

## License

LWWebContainer is available under the MIT license. See the LICENSE file for more info.
