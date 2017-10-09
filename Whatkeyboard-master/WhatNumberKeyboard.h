//
//  WhatNumberKeyboard.h
//  WhatKeyboardDemo
//
//  Created by apple on 2017/9/30.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WhatNumberKeyboardConfiguration;

@interface WhatNumberKeyboard : UIView

/**
 创建键盘
 */
+ (instancetype)numberKeyboardWithConfiguration:(WhatNumberKeyboardConfiguration *)config;

/**
 配置
 */
@property(nonatomic, strong)WhatNumberKeyboardConfiguration *config;


- (void)randomKeyboard;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end
