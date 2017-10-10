//
//  WhatKeyboard.m
//  WhatKeyboardDemo
//
//  Created by apple on 2017/9/29.
//  Copyright © 2017年 mine. All rights reserved.
//

#import "WhatKeyboardManager.h"
#import "WhatKeyboardConfiguration.h"
#import "WhatAllKeyboard.h"
#import "WhatNumberKeyboard.h"

@implementation WhatKeyboardManager

+ (WhatAllKeyboard *)allKeyboardWithConfiguration:(WhatAllKeyboardConfiguration *)config {
    return [WhatAllKeyboard allKeyboardWithConfiguration:config];
}

+ (WhatNumberKeyboard *)numberKeyboardWithConfiguration:(WhatNumberKeyboardConfiguration *)config {
    return [WhatNumberKeyboard numberKeyboardWithConfiguration:config];
}

@end
