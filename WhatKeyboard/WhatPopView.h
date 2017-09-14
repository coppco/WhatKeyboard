//
//  WhatPopView.h
//  SecurityKeyboard
//
//  Created by apple on 2017/8/25.
//  Copyright © 2017年 my. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WhatPopView : UIView

+ (instancetype)popView;
/*
 * 显示标题
 */
- (void)showFromButton:(UIButton *)button;
@end
