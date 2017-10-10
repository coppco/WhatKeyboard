//
//  WhatKeyboardConfiguration.h
//  WhatKeyboardDemo
//
//  Created by apple on 2017/9/27.
//  Copyright © 2017年 mine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 UIKeyInput键盘将要出现
 */
UIKIT_EXTERN NSString * _Nonnull const UIKeyInputWillShowNotification;
/**
 UIKeyInput键盘将要隐藏
 */
UIKIT_EXTERN NSString * _Nonnull const UIKeyInputWillHideNotification;


NS_ASSUME_NONNULL_BEGIN

#pragma - mark  父类, 请使用子类

@interface WhatKeyboardConfiguration : NSObject

/**
 是否需要音效, 默认: true, 系统音效Sound ID为 1104 (其他还有1103、1105)
 */
@property(nonatomic, assign)BOOL soundEffectEnable;

/**
 自定义音效文件名称, 文件不能过大, 时间过长, 默认: nil */
@property(nonatomic, copy, nullable)NSString *soundResource;

/**
 是否支持长按删除, 默认: true
 */
@property(nonatomic, assign)BOOL longPressDeleteEnable;

/**
 密码安全时是否自动清空输入框, 默认: true
 */
@property(nonatomic, assign)BOOL cleanEnable;

/**
 确定按钮执行的block, 默认: 回收键盘
 */
@property(nonatomic, copy, nullable)void (^didConfirmed)(UIButton *);

/**
 自定义删除按钮图片, 默认: WhatKeyboard.bundle/keyboard_delete
 */
@property(nonatomic, copy, nullable)NSString *deleteNormalImage;

/**
 自定义删除按钮图片, 默认: nil
 */
@property(nonatomic, copy, nullable)NSString *deleteHighlightImage;

/**
 确定按钮名称, 默认: 确定
 */
@property(nonatomic, copy)NSString *confirmName;

/**
 确定按钮文字颜色, 默认: whiteColor
 */
@property(nonatomic, strong)UIColor *confirmTextColor;

/**
 确定按钮正常状态背景颜色, 默认: orangeColor alpha 0.7
 */
@property(nonatomic, strong)UIColor *confirmNormalBackgroundColor;

/**
 确定按钮高亮状态背景颜色, 默认: orangeColor
 */
@property(nonatomic, strong)UIColor *confirmHighlightBackgroundColor;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end


#pragma - mark 全键盘配置
@interface WhatAllKeyboardConfiguration: WhatKeyboardConfiguration
/**
 初始化方法
 */
+ (instancetype)sharedManager;

/**
 是否需要空格, 默认: true
 */
@property(nonatomic, assign)BOOL spaceEnable;

/**
 空格名称, 默认: space
 */
@property(nonatomic, copy, nullable)NSString *spaceName;

/**
 自定义空格背景图片, 默认: nil
 */
@property(nonatomic, copy, nullable)NSString *spaceBackgroundImageNormal;

/**
 自定义空格背景图片, 默认: nil
 */
@property(nonatomic, copy, nullable)NSString *spaceBackgroundImageHighlight;

/**
 是否需要放大的背景, 默认: true
 */
@property(nonatomic, assign)BOOL popViewEnable;

/**
 放大背景的图片, 默认: 使用WhatKeyboard.bundle/keyboard_pressview
 */
@property(nonatomic, copy, nullable)NSString *popImage;

/**
 切换大写图片, 默认: 使用WhatKeyboard.bundle/keyboard_capital
 */
@property(nonatomic, copy, nullable)NSString *capitalImageName;

/**
 切换小写图片, 默认: 使用WhatKeyboard.bundle/keyboard_small
 */
@property(nonatomic, copy, nullable)NSString *smallImageName;

/**
 Unavailable. Please use sharedManager method
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end



#pragma - mark 九宫格数字键盘配置
@interface WhatNumberKeyboardConfiguration: WhatKeyboardConfiguration
/**
 初始化方法
 */
+ (instancetype)sharedManager;
/**
 是否需要随机键盘, 默认: true
 */
@property(nonatomic, assign)BOOL randomEnable;

/**
 数字键盘是否需要点: 默认: true
 */
@property(nonatomic, assign)BOOL decimalPointEnable;

/**
 是否需要toolbar, 默认: true
 */
@property(nonatomic, assign)BOOL toolbarEnable;

/******下面的属性需要开启toolbarEnable才可以******/
/**
 自定义toolbar上面logo图片, 默认: WhatKeyboard.bundle/keyboard_safe
 */
@property(nonatomic, copy, nullable)NSString *securityImage;

/**
 toolbar上面标题, 默认: 安全键盘
 */
@property(nonatomic, copy)NSString *middleTitle;

/**
 toolbar上面随机键盘按钮, 默认是: true
 */
@property(nonatomic, assign)BOOL randomButtonEnable;

/**
 随机按钮正常状态下图片, 默认 WhatKeyboard.bundle/see_normal
 */
@property(nonatomic, copy, nullable)NSString *randomNormalImage;

/**
 随机按钮选择状态下图片,  默认: WhatKeyboard.bundle/peep_normal
 */
@property(nonatomic, copy, nullable)NSString *randomSelectedImage;

/**
 随机按钮选高亮态下图片,
 */
@property(nonatomic, copy, nullable)NSString *randomHighlightImage;

/**
 随机按钮正常状态下标题
 */
@property(nonatomic, copy, nullable)NSString *randomNormalTitle;

/**
 随机按钮选择状态下标题
 */
@property(nonatomic, copy, nullable)NSString *randomSelectedTitle;

/**
 随机按钮高亮状态下标题
 */
@property(nonatomic, copy, nullable)NSString *randomHighlightTitle;

/**
 随机按钮执行的block, 默认: 切换随机键盘
 */
@property(nonatomic, copy, nullable)void (^didRandom)(UIButton *);

/**
 Unavailable. Please use sharedManager method
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
