//
// Created by luowei on 15/9/14.
// Copyright (c) 2015 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AspectInfo;


@interface LWHookConfig : NSObject
+ (NSDictionary *)hookEventDict;
@end

//dictionary key
#define Hook_TrackedEvents @"TrackedEvents"     //勾子事件项列表
#define Hook_Option @"HookOption"               //勾子执行时机
#define Hook_EventName @"EventName"             //勾子事件名称
#define Hook_EventSelectorName @"EventSelectorName" //勾子事件的selector名称
#define Hook_EventHandlerBlock @"EventHandlerBlock" //勾子事件处理相对应的block

typedef void (^HookHandlerBlock)(id <AspectInfo>);  //勾子事件处理相对应的block的类型声明

@interface UIResponder(Hook)

@end
