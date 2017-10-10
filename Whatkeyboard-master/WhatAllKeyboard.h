//
//  WhatAllKeyboard.h
//  WhatKeyboardDemo
//
//  Created by apple on 2017/9/29.
//  Copyright © 2017年 mine. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WhatAllKeyboardConfiguration;

@interface WhatAllKeyboard : UIView

/**
 创建键盘
 */
+ (instancetype)allKeyboardWithConfiguration:(WhatAllKeyboardConfiguration *)config;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
@end
