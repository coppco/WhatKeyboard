//
//  WhatAllKeyboard.m
//  WhatKeyboardDemo
//
//  Created by apple on 2017/9/29.
//  Copyright © 2017年 mine. All rights reserved.
//

#import "WhatAllKeyboard.h"
#import "WhatButton.h"
#import "WhatPopView.h"
#import <AVFoundation/AVFoundation.h>
#import "WhatKeyboardConfiguration.h"
#import "UIImage+ColorExtension.h"
#import "NSObject+YYAdd.h"

@interface WhatAllKeyboard()
/**
 配置
 */
@property(nonatomic, strong)WhatAllKeyboardConfiguration *config;
/*字母按钮数组*/
@property (strong, nonatomic) IBOutletCollection(WhatButton) NSMutableArray *letterButtons;
/*约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showNumberConstraint;
/*额外的按钮*/
@property (weak, nonatomic) IBOutlet WhatButton *otherButton;
/*切换大小写*/
@property (weak, nonatomic) IBOutlet WhatButton *switchCapitalButton;
/*切换数字*/
@property (weak, nonatomic) IBOutlet WhatButton *switchNumberButton;
/*删除按钮*/
@property (weak, nonatomic) IBOutlet WhatButton *deleteButton;
/*确定按钮*/
@property (weak, nonatomic) IBOutlet WhatButton *confirmButton;
/*空格*/
@property (weak, nonatomic) IBOutlet WhatButton *spaceButton;
/*数字数组*/
@property(nonatomic, strong)NSMutableArray *numbers;
/*符号数组*/
@property(nonatomic, strong)NSMutableArray *characters;
/*大写字符*/
@property(nonatomic, strong)NSMutableArray *capitalLetters;
/*小写字符*/
@property(nonatomic, strong)NSMutableArray *smallLetters;
/*当前字符数组*/
@property(nonatomic, strong)NSMutableArray *currents;
/*弹出框*/
@property(nonatomic, strong)WhatPopView *popView;
/*当前选中按钮*/
@property(nonatomic, strong)WhatButton *selectButton;
/*定时器*/
@property(nonatomic, strong)NSTimer *timer;
/*是否选择*/
@property(nonatomic, assign)BOOL capitalSelected;
@property(nonatomic, assign)BOOL numberSelected;
/*清空*/
@property(nonatomic, assign)BOOL isClear;
@property (nonatomic, assign) SystemSoundID soundID;
/*输入框*/
@property(nonatomic, weak)id container;
@end

@implementation WhatAllKeyboard

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@释放了", self.class);
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)allKeyboardWithConfiguration:(WhatAllKeyboardConfiguration *)config {
    WhatAllKeyboard *keyboard =  [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
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


#pragma - mark IBAction
/**切换大小写*/
- (IBAction)switchCapital:(WhatButton *)sender {
    [self playSound];
    self.capitalSelected = !self.capitalSelected;
    [self changeCurrentType];
}

/**切换数字*/
- (IBAction)switchNumber:(WhatButton *)sender {
    [self playSound];
    self.numberSelected = !self.numberSelected;
    self.capitalSelected = false;
    [self changeCurrentType];
}

/**删除按钮*/
- (IBAction)delete:(WhatButton *)sender {
    [self playSound];
    [self cleanText];
    if ([self.container isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)self.container;
        if ([self shouldPerformBtn:sender]) {
            [textView deleteBackward];
        }
    }else if ([self.container isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)self.container;
        if ([self shouldPerformBtn:sender]) {
            [textField deleteBackward];
        }
    }else if ([self.container conformsToProtocol:NSProtocolFromString(@"UIKeyInput")]) {
        UIResponder *object = self.container;
        if ([object respondsToSelector:@selector(deleteBackward)]) {
            [object performSelector:@selector(deleteBackward)];
        }
    }
}

/**确认按钮*/
- (IBAction)confirm:(WhatButton *)sender {
     [self playSound];
    
    if (_config.didConfirmed) {
        _config.didConfirmed(sender);
    } else {
        if ([self.container isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)self.container;
            [textView resignFirstResponder];
        }else if ([self.container isKindOfClass:[UITextField class]]) {
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

- (IBAction)space:(WhatButton *)sender {
    [self playSound];
    [self cleanText];
    if ([self.container isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)self.container;
        if ([self shouldPerformBtn:sender]) {
            [textView insertText:@" "];
        }
    }else if ([self.container isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)self.container;
        if ([self shouldPerformBtn:sender]) {
            [textField insertText:@" "];
        }
    }else if ([self.container conformsToProtocol:NSProtocolFromString(@"UIKeyInput")]) {
        UIResponder *object = self.container;
        if ([object respondsToSelector:@selector(insertText:)]) {
            [object performSelector:@selector(insertText:) withObject:@" "];
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
        if (_config.popViewEnable) {
            [self.popView showFromButton:btn];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    
    CGPoint location = [touch locationInView:touch.view];
    WhatButton *btn = [self keyboardButtonWithLocation:location];
    
    if (btn) {
        self.selectButton = btn;
        if (_config.popViewEnable) {
            [self.popView showFromButton:btn];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.selectButton = nil;
    if (_config.popViewEnable) {
        [self.popView removeFromSuperview];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.popView removeFromSuperview];
    
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

#pragma - mark Private Method
- (WhatButton *)keyboardButtonWithLocation:(CGPoint)location {
    for (WhatButton *button in self.letterButtons) {
        if (CGRectContainsPoint(button.frame, location)) {
            return button;
        }
    }
    if (CGRectContainsPoint(self.otherButton.frame, location)) {
        return self.otherButton.hidden ? nil : self.otherButton;
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


- (void)resetDefault {
    self.numberSelected = false;
    self.capitalSelected = false;
    [self changeCurrentType];
}

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
        self.deleteButton.highlighted = true;
    } else if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateFailed || longPress.state == UIGestureRecognizerStateCancelled) {
        [self.timer invalidate];
        self.timer = nil;
        self.deleteButton.highlighted = false;
    } else if(longPress.state == UIGestureRecognizerStateChanged) {
        self.deleteButton.highlighted = true;
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

/**切换键盘内容*/
- (void)changeCurrentType {
    self.otherButton.hidden = !self.numberSelected;
    self.showNumberConstraint.constant = self.numberSelected ? - [UIScreen mainScreen].bounds.size.width / 20.0 : 0;
    
    [self.switchNumberButton setTitle:self.numberSelected ? @"ABC": @"#+123" forState:(UIControlStateNormal)];
    
    if (self.numberSelected) {
        [self.switchCapitalButton setTitle: self.capitalSelected ? @"数\n字" : @"符\n号" forState:(UIControlStateNormal)];
        [self.switchCapitalButton setImage:nil forState:(UIControlStateNormal)];
    } else {
        [self.switchCapitalButton setTitle:nil forState:(UIControlStateNormal)];
        [self.switchCapitalButton setImage:[UIImage imageNamed: self.capitalSelected ? (_config.capitalImageName.length > 0 ? _config.capitalImageName : @"WhatKeyboard.bundle/keyboard_capital") : (_config.smallImageName.length > 0 ? _config.smallImageName : @"WhatKeyboard.bundle/keyboard_small")] forState:(UIControlStateNormal)];
    }
    
    //字符
    if (self.capitalSelected && self.numberSelected) {
        self.currents = self.characters;
        [self.otherButton setTitle:@"•" forState:(UIControlStateNormal)];
        return;
    }
    //数字
    if (!self.capitalSelected && self.numberSelected) {
        self.currents = self.numbers;
        [self.otherButton setTitle:@"\"" forState:(UIControlStateNormal)];
        return;
    }
    
    //大写字母
    if (self.capitalSelected && !self.numberSelected) {
        self.currents = self.capitalLetters;
        return;
    }
    //小写
    if (!self.capitalSelected && !self.numberSelected) {
        self.currents = self.smallLetters;
        return;
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

#pragma - mark setter
- (void)setConfig:(WhatAllKeyboardConfiguration *)config {
    _config = config;
    self.switchCapitalButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.switchCapitalButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithRed:242 / 255.0  green:242 / 255.0 blue:242 / 255.0 alpha:1]] forState:(UIControlStateNormal)];
    [self.deleteButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithRed:242 / 255.0  green:242 / 255.0 blue:242 / 255.0 alpha:1]] forState:(UIControlStateNormal)];
    
    if (config.soundEffectEnable) {
        _soundID = 1104;
        if (config.soundResource.length > 0) {
            NSURL *soundURL = [[NSBundle bundleForClass:[self class]] URLForResource:config.soundResource withExtension:nil];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &_soundID);
        }
    }
    
    if (config.longPressDeleteEnable) {
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self.deleteButton addGestureRecognizer:press];
    }
    
    self.spaceButton.enabled = config.spaceEnable;
    [self.spaceButton setTitle:config.spaceName forState:(UIControlStateNormal)];
    
    if (config.spaceBackgroundImageNormal.length > 0) {
        [self.spaceButton setTitle:nil forState:(UIControlStateNormal)];
        [self.spaceButton setBackgroundImage:[UIImage imageNamed:config.spaceBackgroundImageNormal] forState:(UIControlStateNormal)];
    }
    
    if (config.spaceBackgroundImageHighlight.length > 0) {
        [self.spaceButton setTitle:nil forState:(UIControlStateNormal)];
        [self.spaceButton setBackgroundImage:[UIImage imageNamed:config.spaceBackgroundImageHighlight] forState:(UIControlStateNormal)];
    }

    if (config.popViewEnable) {
        self.popView = [WhatPopView popView];
        if (config.popImage.length > 0) {
            [self.popView setImage:[UIImage imageNamed:config.popImage]];
        }
    }
    
    [self.confirmButton setTitle:config.confirmName forState:(UIControlStateNormal)];
    [self.confirmButton setTitleColor:config.confirmTextColor forState:(UIControlStateNormal)];
    
    [self.confirmButton setBackgroundImage:[UIImage imageFromColor:config.confirmNormalBackgroundColor] forState:(UIControlStateNormal)];
    [self.confirmButton setBackgroundImage:[UIImage imageFromColor:config.confirmHighlightBackgroundColor] forState:(UIControlStateHighlighted)];
    
    if (config.deleteNormalImage.length > 0) {
        [self.deleteButton setImage:[UIImage imageNamed:config.deleteNormalImage] forState:(UIControlStateNormal)];
    } else {
        [self.deleteButton setImage:[UIImage imageNamed:@"WhatKeyboard.bundle/keyboard_delete"] forState:(UIControlStateNormal)];
    }
    
    if (config.deleteHighlightImage.length > 0) {
        [self.deleteButton setImage:[UIImage imageNamed:config.deleteHighlightImage] forState:(UIControlStateNormal)];
    } else {
        [self.deleteButton setImage:[UIImage imageNamed:@"WhatKeyboard.bundle/keyboard_delete"] forState:(UIControlStateNormal)];
    }
    
    if (config.capitalImageName.length > 0) {
        [self.switchCapitalButton setImage:[UIImage imageNamed:config.capitalImageName] forState:(UIControlStateNormal)];
    } else {
        [self.switchCapitalButton setImage:[UIImage imageNamed:@"WhatKeyboard.bundle/keyboard_small"] forState:(UIControlStateNormal)];
    }
    
}

/**设置当前键盘内容*/
- (void)setCurrents:(NSMutableArray *)currents {
    if (_currents != currents) {
        _currents = currents;
        for (int i = 0; i < self.currents.count; i++) {
            [self.letterButtons[i] setTitle:self.currents[i] forState:(UIControlStateNormal)];
        }
    }
}

/**当前选中按钮*/
- (void)setSelectButton:(WhatButton *)selectButton {
    if (_selectButton != selectButton) {
        _selectButton.highlighted = false;
        selectButton.highlighted = true;
        _selectButton = selectButton;
    }
}

#pragma - mark getter
- (NSMutableArray *)smallLetters {
    if (!_smallLetters) {
        _smallLetters = ({
            NSMutableArray *object = [[NSMutableArray alloc] initWithObjects:@"q", @"w", @"e", @"r", @"t", @"y", @"u", @"i", @"o", @"p", @"a", @"s", @"d", @"f", @"g", @"h", @"j", @"k", @"l", @"z", @"x", @"c", @"v", @"b", @"n", @"m", nil];
            object;
        });
    }
    return _smallLetters;
}
- (NSMutableArray *)capitalLetters {
    if (!_capitalLetters) {
        _capitalLetters = ({
            NSMutableArray *object = [[NSMutableArray alloc] initWithObjects:@"Q", @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P", @"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L", @"Z", @"X", @"C", @"V", @"B", @"N", @"M", nil];
            object;
        });
    }
    return _capitalLetters;
}
- (NSMutableArray *)numbers {
    if (!_numbers) {
        _numbers = ({
            NSMutableArray *object = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", @"-", @"/", @":", @";", @"(", @")", @"$", @"&", @"@", @".", @",", @"?", @"!", @"'", @"+", @"=", nil];
            //@"\""
            object;
        });
    }
    return _numbers;
}

- (NSMutableArray *)characters {
    if (!_characters) {
        _characters = ({
            NSMutableArray *object = [[NSMutableArray alloc] initWithObjects:@"[", @"]", @"{", @"}", @"#", @"%", @"^", @"*", @"_", @"\\", @"|", @"/", @"~", @"<", @">", @"`", @"¥", @"€", @"￡", @".", @",", @"?", @"!", @"'", @"+", @"=", nil];
            //@"•"
            object;
        });
    }
    return _characters;
}

@end
