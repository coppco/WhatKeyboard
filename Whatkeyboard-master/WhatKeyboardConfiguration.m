//
//  WhatKeyboardConfiguration.m
//  WhatKeyboardDemo
//
//  Created by apple on 2017/9/27.
//  Copyright © 2017年 mine. All rights reserved.
//

#import "WhatKeyboardConfiguration.h"


NSString *const UIKeyInputWillShowNotification = @"UIKeyInputWillShowNotification";
NSString *const UIKeyInputWillHideNotification = @"UIKeyInputWillHideNotification";


@implementation WhatKeyboardConfiguration

@end

#pragma - mark 全键盘密码键盘

@implementation WhatAllKeyboardConfiguration

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@释放了", self.class);
#endif
}

+ (WhatAllKeyboardConfiguration *)sharedManager {
    WhatAllKeyboardConfiguration *configuration = [[self alloc] init];
    [configuration initization];
    return configuration;
}
- (void)initization {
    /*********公共属性*********/
    //音效
    self.soundEffectEnable = true;
    //自定义音效文件
    self.soundResource = nil;
    //长按删除
    self.longPressDeleteEnable = true;
    //安全模式时清空输入框
    self.cleanEnable = true;
    //确定按钮执行的block
    self.didConfirmed = nil;
    //删除按钮正常状态图片
    self.deleteNormalImage = nil;
    //删除按钮高亮状态图片
    self.deleteHighlightImage = nil;
    //确定按钮的标题
    self.confirmName = @"确定";
    //确定按钮的文字颜色
    self.confirmTextColor = [UIColor whiteColor];
    //确定按钮的正常状态背景颜色
    self.confirmNormalBackgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.7];
    //确定按钮的高亮状态背景颜色
    self.confirmHighlightBackgroundColor = [UIColor orangeColor];

     /*********当前属性*********/
    //空格能否使用
    self.spaceEnable = false;
    //空格按钮标题
    self.spaceName = @"space";
    //空格按钮正常背景图片
    self.spaceBackgroundImageNormal = nil;
    //空格按钮高亮背景图片
    self.spaceBackgroundImageHighlight = nil;
    //按键弹出框
    self.popViewEnable = true;
    //按键弹出框背景图片
    self.popImage = nil;
    //切换大写按钮图片
    self.capitalImageName = nil;
    //切换小写按钮图片
    self.smallImageName = nil;
}
@end

#pragma - mark 纯数字密码键盘

@implementation WhatNumberKeyboardConfiguration
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@释放了", self.class);
#endif
}
+ (WhatNumberKeyboardConfiguration *)sharedManager {
    WhatNumberKeyboardConfiguration *configuration = [[self alloc] init];
    [configuration initization];
    return configuration;
}
- (void)initization {
    /*********公共属性*********/
    //音效
    self.soundEffectEnable = true;
    //自定义音效文件
    self.soundResource = nil;
    //长按删除
    self.longPressDeleteEnable = true;
    //安全模式时清空输入框
    self.cleanEnable = true;
    //确定按钮执行的block
    self.didConfirmed = nil;
    //删除按钮正常状态图片
    self.deleteNormalImage = nil;
    //删除按钮高亮状态图片
    self.deleteHighlightImage = nil;
    //确定按钮的标题
    self.confirmName = @"确定";
    //确定按钮的文字颜色
    self.confirmTextColor = [UIColor whiteColor];
    //确定按钮的正常状态背景颜色
    self.confirmNormalBackgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.7];
    //确定按钮的高亮状态背景颜色
    self.confirmHighlightBackgroundColor = [UIColor orangeColor];
    
    /*********特有属性*********/
    //随机键盘
    self.randomEnable = true;
    //小数点
    self.decimalPointEnable = true;
    //是否需要toolbar
    self.toolbarEnable = true;
    //toolbar的logo
    self.securityImage = @"WhatKeyboard.bundle/keyboard_safe";
    //toolbar标题
    self.middleTitle = @"安全键盘";
    //随机键盘按钮
    self.randomButtonEnable = true;
    //随机按钮
    self.randomNormalImage = @"WhatKeyboard.bundle/see_normal";
    self.randomSelectedImage = @"WhatKeyboard.bundle/peep_normal";
    self.randomHighlightImage = nil;
    self.randomNormalTitle = nil;
    self.randomHighlightTitle = nil;
    self.randomSelectedTitle = nil;
}
@end
