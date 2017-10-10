//
//  WhatNumberKeyboard.m
//  WhatKeyboardDemo
//
//  Created by apple on 2017/9/30.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "WhatNumberKeyboard.h"
#import "WhatKeyboardConfiguration.h"
#import "UIImage+ColorExtension.h"
#import "WhatButton.h"
#import <AVFoundation/AVFoundation.h>
#import "NSObject+YYAdd.h"
#import "WhatToolbar.h"

@interface WhatNumberKeyboard()
@property (weak, nonatomic) IBOutlet WhatButton *deleteB;
@property (weak, nonatomic) IBOutlet WhatButton *confirmB;
@property(nonatomic, weak)id container;
@property (strong, nonatomic) IBOutletCollection(WhatButton) NSArray *numbersB;
@property (weak, nonatomic) IBOutlet WhatButton *decimelB;
@property(nonatomic, assign)BOOL isClear;
@property (nonatomic, assign) SystemSoundID soundID;
@property(nonatomic, strong)WhatButton *selectButton;
@property(nonatomic, strong)NSTimer *timer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *decimalWidth;

/**
 默认数组标题
 */
@property(nonatomic, strong)NSArray *defaultArray;
/**
 配置
 */
@property(nonatomic, strong)WhatNumberKeyboardConfiguration *config;
@end

@implementation WhatNumberKeyboard
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@释放了", self.class);
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)numberKeyboardWithConfiguration:(WhatNumberKeyboardConfiguration *)config {
    WhatNumberKeyboard *keyboard =  [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
    keyboard.config = config;
    return keyboard;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
    
    //UIKeyInput
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginEditing:) name:UIKeyInputWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndEditing:) name:UIKeyInputWillHideNotification object:nil];
    
    //旋转
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didChanged:(NSNotification *)notification {
    self.decimalWidth.constant = (_config.decimalPointEnable ? 0 : -[UIScreen mainScreen].bounds.size.width * 0.75);
}

- (void)didBeginEditing:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[UITextView class]]) {
        UITextView *textV = (UITextView *)notification.object;
        if (textV.inputView == self) {
            self.container = textV;
            self.isClear = textV.secureTextEntry && _config.cleanEnable;
            [self resetDefault];
        }
    }else if ([notification.object isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)notification.object;
        if (textField.inputView == self) {
            self.container = textField;
            self.isClear = textField.secureTextEntry && _config.cleanEnable;
            [self resetDefault];
        }
    } else if ([notification.object conformsToProtocol:NSProtocolFromString(@"UIKeyInput")]) {
        UIResponder *object = notification.object;
        UIView *inputView = notification.userInfo[@"InputView"];
        if (inputView == self) {
            self.container = object;
            self.isClear = [object performSelector:@selector(isSecureTextEntry)] && _config.cleanEnable;
            [self resetDefault];
        }
    }
}
- (void)didEndEditing:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[UITextView class]]) {
        UITextView *textV = (UITextView *)notification.object;
        if (textV.inputView == self) {
            self.container = nil;
        }
    }else if ([notification.object isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)notification.object;
        if (textField.inputView == self) {
            self.container = nil;
        }
    }else if ([notification.object conformsToProtocol:NSProtocolFromString(@"UIKeyInput")]) {
        UIResponder *object = notification.object;
        if ([object respondsToSelector:@selector(inputView)]) {
            UIView *inputView = notification.userInfo[@"InputView"];
            if (inputView == self) {
                self.container = nil;
            }
        }
    }
}

- (void)resetDefault {
    [self randomKeyboard];

    if ([self.container isKindOfClass:[UITextView class]]) {
        UITextView *view = (UITextView *)self.container;
        if (self.config.toolbarEnable && !view.inputAccessoryView) {
            view.inputAccessoryView = self.toolbar;
        }
    }else if ([self.container isKindOfClass:[UITextField class]]) {
        UITextField *view = (UITextField *)self.container;
        if (self.config.toolbarEnable && !view.inputAccessoryView) {
            view.inputAccessoryView = self.toolbar;
        }
    }else if ([self.container conformsToProtocol:NSProtocolFromString(@"UIKeyInput")]) {
        UIResponder *object = self.container;
        if (self.config.toolbarEnable && !object.inputAccessoryView) {
            
        }
    }
    
}

/**随机键盘*/
- (void)randomKeyboard {
    if (_config.randomEnable) {
        NSArray *array = [self.defaultArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return (arc4random() % 3) - 1;
        }];
        
        for (int i = 0; i < MIN(array.count, self.numbersB.count); i++) {
            [self.numbersB[i] setTitle:array[i] forState:(UIControlStateNormal)];
        }
    } else {
        for (int i = 0; i < MIN(self.defaultArray.count, self.numbersB.count); i++) {
            [self.numbersB[i] setTitle:self.defaultArray[i] forState:(UIControlStateNormal)];
        }
    }
}

#pragma - mark IBAction
- (IBAction)deleteAction:(id)sender {
    [self playSound];
    [self cleanText];
    if ([self.container isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)self.container;
        [textView deleteBackward];
    }else if ([self.container isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)self.container;
        [textField deleteBackward];
    }else if ([self.container conformsToProtocol:NSProtocolFromString(@"UIKeyInput")]) {
        UIResponder *object = self.container;
        if ([object respondsToSelector:@selector(deleteBackward)]) {
            [object performSelector:@selector(deleteBackward)];
        }
    }

}

- (IBAction)confirmAction:(id)sender {
    [self playSound];
    
    if (_config.didConfirmed) {
        _config.didConfirmed(self.confirmB);
    } else {
        if ([self.container isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)self.container;
            [textView resignFirstResponder];
        }else if  ([self.container isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)self.container;
            [textField resignFirstResponder];
        }else if ([self.container conformsToProtocol:NSProtocolFromString(@"UIKeyInput")]) {
            UIResponder *object = self.container;
            if ([object respondsToSelector:@selector(resignFirstResponder)]) {
                [object performSelector:@selector(resignFirstResponder)];
            }
        }
    }
}

#pragma - mark Touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super  touchesBegan:touches withEvent:event];
    self.selectButton = nil;
    
    UITouch *touch = touches.anyObject;
    
    CGPoint location = [touch locationInView:touch.view];
    WhatButton *btn = [self keyboardButtonWithLocation:location];
    
    if (btn) {
        self.selectButton = btn;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    
    CGPoint location = [touch locationInView:touch.view];
    WhatButton *btn = [self keyboardButtonWithLocation:location];
    
    if (btn) {
        self.selectButton = btn;
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.selectButton = nil;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = touches.anyObject;
    CGPoint location = [touch locationInView:touch.view];
    WhatButton *btn = [self keyboardButtonWithLocation:location];
    
    if (btn) {
        [self cleanText];
        [self playSound];
        if ([self.container isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)self.container;
            if ([self shouldPerformBtn:btn]) {
                [textView insertText:btn.currentTitle];
            }
        }else if ([self.container isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)self.container;
            if ([self shouldPerformBtn:btn]) {
                [textField insertText:btn.currentTitle];
            }
        }else if ([self.container conformsToProtocol:NSProtocolFromString(@"UIKeyInput")]) {
            UIResponder *object = self.container;
            if ([object respondsToSelector:@selector(insertText:)]) {
                [object performSelector:@selector(insertText:) withObject:btn.currentTitle];
            }
        }
    } else if (self.selectButton) {
        [self playSound];
        [self cleanText];
        if ([self.container isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)self.container;
            if ([self shouldPerformBtn:self.selectButton]) {
                [textView insertText:self.selectButton.currentTitle];
            }
        }else if ([self.container isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)self.container;
            if ([self shouldPerformBtn:self.selectButton]) {
                [textField insertText:self.selectButton.currentTitle];
            }
        }else if ([self.container conformsToProtocol:NSProtocolFromString(@"UIKeyInput")]) {
            UIResponder *object = self.container;
            if ([object respondsToSelector:@selector(insertText:)]) {
                [object performSelector:@selector(insertText:) withObject:self.selectButton.currentTitle];
            }
        }
    }
    self.selectButton = nil;
}

#pragma - mark setter & getter
- (void)setConfig:(WhatNumberKeyboardConfiguration *)config {
    _config = config;
    [self.deleteB setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithRed:242 / 255.0  green:242 / 255.0 blue:242 / 255.0 alpha:1]] forState:(UIControlStateNormal)];
    
    if (config.soundEffectEnable) {
        _soundID = 1104;
        if (config.soundResource.length > 0) {
            NSURL *soundURL = [[NSBundle bundleForClass:[self class]] URLForResource:config.soundResource withExtension:nil];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &_soundID);
        }
    }
    
    if (config.longPressDeleteEnable) {
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self.deleteB addGestureRecognizer:press];
    }
    
    [self.confirmB setTitle:config.confirmName forState:(UIControlStateNormal)];
    [self.confirmB setTitleColor:config.confirmTextColor forState:(UIControlStateNormal)];
    
    [self.confirmB setBackgroundImage:[UIImage imageFromColor:config.confirmNormalBackgroundColor] forState:(UIControlStateNormal)];
    [self.confirmB setBackgroundImage:[UIImage imageFromColor:config.confirmHighlightBackgroundColor] forState:(UIControlStateHighlighted)];
    
    if (config.deleteNormalImage.length > 0) {
        [self.deleteB setImage:[UIImage imageNamed:config.deleteNormalImage] forState:(UIControlStateNormal)];
    } else {
        [self.deleteB setImage:[UIImage imageNamed:@"WhatKeyboard.bundle/keyboard_delete"] forState:(UIControlStateNormal)];
    }
    
    if (config.deleteHighlightImage.length > 0) {
        [self.deleteB setImage:[UIImage imageNamed:config.deleteHighlightImage] forState:(UIControlStateNormal)];
    } else {
        [self.deleteB setImage:[UIImage imageNamed:@"WhatKeyboard.bundle/keyboard_delete"] forState:(UIControlStateNormal)];
    }
    
    self.decimelB.hidden = !_config.decimalPointEnable;
    self.decimalWidth.constant = (_config.decimalPointEnable ? 0 : -[UIScreen mainScreen].bounds.size.width * 0.75);
    
    if (_config.toolbarEnable) {
        _toolbar = [WhatToolbar toolbar];
        self.toolbar.imageV.image = [UIImage imageNamed:(_config.securityImage.length > 0 ? _config.securityImage : @"WhatKeyboard.bundle/keyboard_safe")];
        self.toolbar.titleL.text = _config.middleTitle;
        self.toolbar.keyboard = self;
        self.toolbar.rightB.hidden = !_config.randomButtonEnable;
        self.toolbar.config = _config;
        if (_config.randomButtonEnable) {
            [self.toolbar.rightB setTitle:_config.randomNormalTitle forState:(UIControlStateNormal)];
            [self.toolbar.rightB setTitle:_config.randomHighlightTitle forState:(UIControlStateHighlighted)];
            [self.toolbar.rightB setTitle:_config.randomSelectedTitle forState:(UIControlStateSelected)];
            
            [self.toolbar.rightB setImage: [UIImage imageNamed:_config.randomNormalImage] forState:UIControlStateNormal];
            [self.toolbar.rightB setImage:[UIImage imageNamed:_config.randomHighlightImage] forState:UIControlStateHighlighted];
            [self.toolbar.rightB setImage:[UIImage imageNamed:_config.randomSelectedImage] forState:UIControlStateSelected];
            [self.toolbar.rightB setTitleColor:[UIColor colorWithRed:96 / 255.0 green:114 / 255.0 blue:129 / 255.0 alpha:1] forState:(UIControlStateNormal)];
            
            self.toolbar.rightB.selected = _config.randomEnable;
        }
    }
}

- (void)setSelectButton:(WhatButton *)selectButton {
    if (_selectButton != selectButton) {
        _selectButton.highlighted = false;
        selectButton.highlighted = true;
        _selectButton = selectButton;
    }
}

- (NSArray *)defaultArray {
    if (!_defaultArray) {
        _defaultArray = ({
            NSArray *object = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", nil];
            object;
        });
    }
    return _defaultArray;
}

#pragma - mark Private Method
/**播放音效*/
- (void)playSound {
    if (_config.soundEffectEnable && _soundID != 0) {
        AudioServicesPlaySystemSound(self.soundID);
    }
}

/**长按删除方法*/
- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerDelete:) userInfo:nil repeats:true];
        self.deleteB.highlighted = true;
    } else if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateFailed || longPress.state == UIGestureRecognizerStateCancelled) {
        [self.timer invalidate];
        self.timer = nil;
        self.deleteB.highlighted = false;
    } else if(longPress.state == UIGestureRecognizerStateChanged) {
        self.deleteB.highlighted = true;
    }
}

- (void)timerDelete:(NSTimer *)timer {
    [self playSound];
    [self cleanText];
    if ([self.container isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)self.container;
        [textView deleteBackward];
    }else if ([self.container isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)self.container;
        [textField deleteBackward];
    }else if ([self.container conformsToProtocol:NSProtocolFromString(@"UIKeyInput")]) {
        UIResponder *object = self.container;
        if ([object respondsToSelector:@selector(deleteBackward)]) {
            [object performSelector:@selector(deleteBackward)];
        }
    }

}

/**清空输入框*/
- (void)cleanText {
    if (self.isClear) {
        if ([self.container isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)self.container;
            textView.text = nil;
        }else if ([self.container isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)self.container;
            textField.text = nil;
        }else if ([self.container conformsToProtocol:NSProtocolFromString(@"UIKeyInput")]) {
            //            UIResponder *object = self.container;
            //            if ([object respondsToSelector:@selector(deleteBackward)]) {
            //                [object performSelector:@selector(deleteBackward)];
            //            }
        }
        self.isClear = false;
    }
}

- (WhatButton *)keyboardButtonWithLocation:(CGPoint)location {
    for (WhatButton *button in self.numbersB) {
        if (CGRectContainsPoint(button.frame, location)) {
            return button;
        }
    }
    if (_config.decimalPointEnable && CGRectContainsPoint(self.decimelB.frame, location)) {
        return self.decimelB;
    }
    return nil;
}
- (BOOL)shouldPerformBtn:(UIButton *)btn {
    BOOL result = true;
    if (self.container && ([self.container isKindOfClass:[UITextField class]] || [self.container isKindOfClass:[UITextView class]])) {
        
        if ([self.container isKindOfClass:[UITextView class]]) {
            UITextView *view = (UITextView *)self.container;
            
            if (view.delegate && [view.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
                result = (BOOL)[(NSObject *)(view.delegate) performSelector:@selector(textViewShouldBeginEditing:) withObject:view];
                if (!result) {
                    return result;
                }
            }
            
            if (view.delegate && [view.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                result = (BOOL)[(NSObject *)(view.delegate) performSelectorWithArgs: @selector(textView:shouldChangeTextInRange:replacementText:), view, NSMakeRange(0, view.text.length), btn.currentTitle];
            }
        }
        
        if ([self.container isKindOfClass:[UITextField class]]) {
            UITextField *view = (UITextField *)self.container;
            
            if (view.delegate && [view.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
                result = (BOOL)[(NSObject *)(view.delegate) performSelector:@selector(textFieldShouldBeginEditing:) withObject:view];
                if (!result) {
                    return result;
                }
            }
            
            if (view.delegate && [(NSObject *)(view.delegate) respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                result = ((NSNumber *)[(NSObject *)(view.delegate) performSelectorWithArgs: @selector(textField:shouldChangeCharactersInRange:replacementString:), view, NSMakeRange(0, view.text.length), btn.currentTitle]).boolValue;
            }
        }
    }
    return result;
}
@end
