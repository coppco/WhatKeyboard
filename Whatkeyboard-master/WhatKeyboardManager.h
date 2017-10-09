//
//  WhatKeyboard.h
//  WhatKeyboardDemo
//
//  Created by apple on 2017/9/29.
//  Copyright © 2017年 mine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhatAllKeyboard.h"
#import "WhatNumberKeyboard.h"
#import "WhatKeyboardConfiguration.h"
@interface WhatKeyboardManager : NSObject


/**
 创建全密码键盘

 @param config 配置文件
 @return 返回全密码键盘
 */
+ (WhatAllKeyboard *)allKeyboardWithConfiguration:(WhatAllKeyboardConfiguration *)config;


/**
 创建纯数字密码键盘

 @param config 配置文件
 @return 返回数字密码键盘
 */
+ (WhatNumberKeyboard *)numberKeyboardWithConfiguration:(WhatNumberKeyboardConfiguration *)config;

@end
