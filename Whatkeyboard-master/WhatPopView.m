//
//  WhatPopView.m
//  SecurityKeyboard
//
//  Created by apple on 2017/8/25.
//  Copyright © 2017年 my. All rights reserved.
//

#import "WhatPopView.h"

@interface WhatPopView ()
/*标题*/
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;

@end

@implementation WhatPopView
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@释放了", self.class);
#endif
}
+ (instancetype)popView {
    WhatPopView *view = [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageV.image = [UIImage imageNamed:@"WhatKeyboard.bundle/keyboard_pressview.png"];
}

- (void)setImage:(UIImage *)image{
    self.imageV.image = image;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return false;
}

- (void)showFromButton:(UIButton *)button {
    NSString * title = button.currentTitle;
    if (button == nil || !(title.length > 0)) {
        return;
    }
    
    self.titleL.text = title;
    
    CGRect btnFrame = [button convertRect:button.bounds toView:nil];

    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    
    self.center = CGPointMake(MAX(MIN(CGRectGetMidX(btnFrame), [UIScreen mainScreen].bounds.size.width - self.frame.size.width / 2), self.frame.size.width / 2), CGRectGetMinY(btnFrame) - self.frame.size.height / 2);
    [window addSubview:self];
}
@end
