//
//  WhatToolbar.h
//  WhatKeyboardDemo
//
//  Created by apple on 2017/9/26.
//  Copyright © 2017年 mine. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WhatNumberKeyboardConfiguration;
@class WhatNumberKeyboard;
UIKIT_EXTERN NSString *const WhatToolbarDidChangeSecurityNotification;

@interface WhatToolbar : UIView
+ (instancetype)toolbar;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UIButton *rightB;
@property(nonatomic, strong)WhatNumberKeyboardConfiguration *config;
/**
 键盘
 */
@property(nonatomic, weak)WhatNumberKeyboard *keyboard;
@end
