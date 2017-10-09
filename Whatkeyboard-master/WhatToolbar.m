//
//  WhatToolbar.m
//  WhatKeyboardDemo
//
//  Created by apple on 2017/9/26.
//  Copyright © 2017年 mine. All rights reserved.
//

#import "WhatToolbar.h"
#import "WhatKeyboardConfiguration.h"
#import "WhatNumberKeyboard.h"
NSString *const WhatToolbarDidChangeSecurityNotification = @"WhatNumberKeyboardDidChangeStatue";

@interface WhatToolbar()
@property (weak, nonatomic) IBOutlet UIButton *randomB;
/*是否防偷窥*/
@property(nonatomic, assign)BOOL isSafe;
@end

@implementation WhatToolbar
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@释放了", self.class);
#endif
}
+ (instancetype)toolbar {
    return [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}
- (IBAction)randomAction:(UIButton *)sender {
    if (_config.didRandom) {
        _config.didRandom(sender);
    } else {
        sender.selected = !sender.selected;
        _config.randomEnable = !_config.randomEnable;
        [self.keyboard randomKeyboard];
    }
}

@end
