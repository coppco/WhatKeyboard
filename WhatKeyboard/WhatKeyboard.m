//
//  WhatKeyboard.m
//  SecurityKeyboard
//
//  Created by apple on 2017/8/25.
//  Copyright © 2017年 my. All rights reserved.
//

#import "WhatKeyboard.h"
#import "WhatButton.h"
#import "UIImage+ColorExtension.h"
#import "WhatPopView.h"
#import <AVFoundation/AVFoundation.h>

@implementation NSObject (YYAdd)

- (id)performSelectorWithArgs:(SEL)sel, ...{
    NSMethodSignature * sig = [self methodSignatureForSelector:sel];
    if (!sig) { [self doesNotRecognizeSelector:sel]; return nil; }
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    if (!inv) { [self doesNotRecognizeSelector:sel]; return nil; }
    [inv setTarget:self];
    [inv setSelector:sel];
    va_list args;
    va_start(args, sel);
    [NSObject setInv:inv withSig:sig andArgs:args];
    va_end(args);
    [inv invoke];
    return [NSObject getReturnFromInv:inv withSig:sig];
}


+ (void)setInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig andArgs:(va_list)args {
    NSUInteger count = [sig numberOfArguments];
    for (int index = 2; index < count; index++) {
        char *type = (char *)[sig getArgumentTypeAtIndex:index];
        while (*type == 'r' || // const
               *type == 'n' || // in
               *type == 'N' || // inout
               *type == 'o' || // out
               *type == 'O' || // bycopy
               *type == 'R' || // byref
               *type == 'V') { // oneway
            type++; // cutoff useless prefix
        }
        
        BOOL unsupportedType = NO;
        switch (*type) {
                case 'v': // 1: void
                case 'B': // 1: bool
                case 'c': // 1: char / BOOL
                case 'C': // 1: unsigned char
                case 's': // 2: short
                case 'S': // 2: unsigned short
                case 'i': // 4: int / NSInteger(32bit)
                case 'I': // 4: unsigned int / NSUInteger(32bit)
                case 'l': // 4: long(32bit)
                case 'L': // 4: unsigned long(32bit)
            { // 'char' and 'short' will be promoted to 'int'.
                int arg = va_arg(args, int);
                [inv setArgument:&arg atIndex:index];
            } break;
                
                case 'q': // 8: long long / long(64bit) / NSInteger(64bit)
                case 'Q': // 8: unsigned long long / unsigned long(64bit) / NSUInteger(64bit)
            {
                long long arg = va_arg(args, long long);
                [inv setArgument:&arg atIndex:index];
            } break;
                
                case 'f': // 4: float / CGFloat(32bit)
            { // 'float' will be promoted to 'double'.
                double arg = va_arg(args, double);
                float argf = arg;
                [inv setArgument:&argf atIndex:index];
            } break;
                
                case 'd': // 8: double / CGFloat(64bit)
            {
                double arg = va_arg(args, double);
                [inv setArgument:&arg atIndex:index];
            } break;
                
                case 'D': // 16: long double
            {
                long double arg = va_arg(args, long double);
                [inv setArgument:&arg atIndex:index];
            } break;
                
                case '*': // char *
                case '^': // pointer
            {
                void *arg = va_arg(args, void *);
                [inv setArgument:&arg atIndex:index];
            } break;
                
                case ':': // SEL
            {
                SEL arg = va_arg(args, SEL);
                [inv setArgument:&arg atIndex:index];
            } break;
                
                case '#': // Class
            {
                Class arg = va_arg(args, Class);
                [inv setArgument:&arg atIndex:index];
            } break;
                
                case '@': // id
            {
                id arg = va_arg(args, id);
                [inv setArgument:&arg atIndex:index];
            } break;
                
                case '{': // struct
            {
                if (strcmp(type, @encode(CGPoint)) == 0) {
                    CGPoint arg = va_arg(args, CGPoint);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGSize)) == 0) {
                    CGSize arg = va_arg(args, CGSize);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGRect)) == 0) {
                    CGRect arg = va_arg(args, CGRect);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGVector)) == 0) {
                    CGVector arg = va_arg(args, CGVector);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                    CGAffineTransform arg = va_arg(args, CGAffineTransform);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                    CATransform3D arg = va_arg(args, CATransform3D);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(NSRange)) == 0) {
                    NSRange arg = va_arg(args, NSRange);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIOffset)) == 0) {
                    UIOffset arg = va_arg(args, UIOffset);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                    UIEdgeInsets arg = va_arg(args, UIEdgeInsets);
                    [inv setArgument:&arg atIndex:index];
                } else {
                    unsupportedType = YES;
                }
            } break;
                
                case '(': // union
            {
                unsupportedType = YES;
            } break;
                
                case '[': // array
            {
                unsupportedType = YES;
            } break;
                
            default: // what?!
            {
                unsupportedType = YES;
            } break;
        }
        
        if (unsupportedType) {
            // Try with some dummy type...
            
            NSUInteger size = 0;
            NSGetSizeAndAlignment(type, &size, NULL);
            
#define case_size(_size_) \
else if (size <= 4 * _size_ ) { \
struct dummy { char tmp[4 * _size_]; }; \
struct dummy arg = va_arg(args, struct dummy); \
[inv setArgument:&arg atIndex:index]; \
}
            if (size == 0) { }
            case_size( 1) case_size( 2) case_size( 3) case_size( 4)
            case_size( 5) case_size( 6) case_size( 7) case_size( 8)
            case_size( 9) case_size(10) case_size(11) case_size(12)
            case_size(13) case_size(14) case_size(15) case_size(16)
            case_size(17) case_size(18) case_size(19) case_size(20)
            case_size(21) case_size(22) case_size(23) case_size(24)
            case_size(25) case_size(26) case_size(27) case_size(28)
            case_size(29) case_size(30) case_size(31) case_size(32)
            case_size(33) case_size(34) case_size(35) case_size(36)
            case_size(37) case_size(38) case_size(39) case_size(40)
            case_size(41) case_size(42) case_size(43) case_size(44)
            case_size(45) case_size(46) case_size(47) case_size(48)
            case_size(49) case_size(50) case_size(51) case_size(52)
            case_size(53) case_size(54) case_size(55) case_size(56)
            case_size(57) case_size(58) case_size(59) case_size(60)
            case_size(61) case_size(62) case_size(63) case_size(64)
            else {
                /*
                 Larger than 256 byte?! I don't want to deal with this stuff up...
                 Ignore this argument.
                 */
                struct dummy {char tmp;};
                for (int i = 0; i < size; i++) va_arg(args, struct dummy);
                NSLog(@"YYKit performSelectorWithArgs unsupported type:%s (%lu bytes)",
                      [sig getArgumentTypeAtIndex:index],(unsigned long)size);
            }
#undef case_size
            
        }
    }
}


+ (id)getReturnFromInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig {
    NSUInteger length = [sig methodReturnLength];
    if (length == 0) return nil;
    
    char *type = (char *)[sig methodReturnType];
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type++; // cutoff useless prefix
    }
    
#define return_with_number(_type_) \
do { \
_type_ ret; \
[inv getReturnValue:&ret]; \
return @(ret); \
} while (0)
    
    switch (*type) {
            case 'v': return nil; // void
            case 'B': return_with_number(bool);
            case 'c': return_with_number(char);
            case 'C': return_with_number(unsigned char);
            case 's': return_with_number(short);
            case 'S': return_with_number(unsigned short);
            case 'i': return_with_number(int);
            case 'I': return_with_number(unsigned int);
            case 'l': return_with_number(int);
            case 'L': return_with_number(unsigned int);
            case 'q': return_with_number(long long);
            case 'Q': return_with_number(unsigned long long);
            case 'f': return_with_number(float);
            case 'd': return_with_number(double);
            case 'D': { // long double
                long double ret;
                [inv getReturnValue:&ret];
                return [NSNumber numberWithDouble:ret];
            };
            
            case '@': { // id
                void *ret;
                [inv getReturnValue:&ret];
                return (__bridge id)(ret);
            };
            
            case '#': { // Class
                Class ret = nil;
                [inv getReturnValue:&ret];
                return ret;
            };
            
        default: { // struct / union / SEL / void* / unknown
            const char *objCType = [sig methodReturnType];
            char *buf = calloc(1, length);
            if (!buf) return nil;
            [inv getReturnValue:buf];
            NSValue *value = [NSValue valueWithBytes:buf objCType:objCType];
            free(buf);
            return value;
        };
    }
#undef return_with_number
}

@end

@interface WhatKeyboard ()
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
@property(nonatomic, strong)id container;
@end


@implementation WhatKeyboard
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@释放了", self.class);
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    AudioServicesDisposeSystemSoundID(self.soundID);
}
+ (instancetype)keyboard {
    WhatKeyboard *keyboard =  [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:keyboard selector:@selector(didBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:keyboard selector:@selector(didBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:keyboard selector:@selector(didEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:keyboard selector:@selector(didEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
    
    return keyboard;
}
- (void)resetDefault {
    self.numberSelected = false;
    self.capitalSelected = false;
    [self changeCurrentType];
}

- (WhatKeyboard *)customSpaceButtonWithImageName:(NSString *)imageNamge enable:(BOOL)enable {
    [self.spaceButton setBackgroundImage:[UIImage imageNamed:imageNamge] forState:(UIControlStateNormal)];
    [self.spaceButton setTitle:nil forState:(UIControlStateNormal)];
    self.spaceButton.enabled = enable;
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.autoOperation = true;
    self.isNeedSound = true;
    self.switchCapitalButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.deleteButton setImage:[UIImage imageNamed:@"WhatKeyboard.bundle/keyboard_delete"] forState:(UIControlStateNormal)];
    
    //特殊背景
    [self.switchCapitalButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithRed:242 / 255.0  green:242 / 255.0 blue:242 / 255.0 alpha:1]] forState:(UIControlStateNormal)];
    [self.deleteButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithRed:242 / 255.0  green:242 / 255.0 blue:242 / 255.0 alpha:1]] forState:(UIControlStateNormal)];
    
    [self.confirmButton setBackgroundImage:[UIImage imageFromColor:[[UIColor orangeColor] colorWithAlphaComponent:0.8]] forState:(UIControlStateNormal)];
    [self.confirmButton setBackgroundImage:[UIImage imageFromColor:[UIColor orangeColor]] forState:(UIControlStateHighlighted)];
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.deleteButton addGestureRecognizer:press];
}

- (void)didBeginEditing:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[UITextView class]]) {
        UITextView *textV = (UITextView *)notification.object;
        if (textV.inputView == self) {
            self.container = textV;
            self.isClear = textV.secureTextEntry;
            [self resetDefault];
        }
    }
    
    if ([notification.object isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)notification.object;
        if (textField.inputView == self) {
            self.container = textField;
            self.isClear = textField.secureTextEntry;
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
    }
    
    if ([notification.object isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)notification.object;
        if (textField.inputView == self) {
            self.container = nil;
        }
    }
}
- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(delete:) userInfo:nil repeats:true];
        self.deleteButton.highlighted = true;
    } else if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateFailed || longPress.state == UIGestureRecognizerStateCancelled) {
        [self.timer invalidate];
        self.timer = nil;
        self.deleteButton.highlighted = false;
    } else if(longPress.state == UIGestureRecognizerStateChanged) {
        self.deleteButton.highlighted = true;
    }
}

#pragma - mark Actions

- (void)playSound {
    if (self.isNeedSound) {
        AudioServicesPlaySystemSound(self.soundID);
    }
}

- (IBAction)switchCapital:(WhatButton *)sender {
    [self playSound];
    self.capitalSelected = !self.capitalSelected;
    [self changeCurrentType];
}
- (IBAction)switchNumber:(WhatButton *)sender {
     [self playSound];
    self.numberSelected = !self.numberSelected;
    self.capitalSelected = false;
    [self changeCurrentType];
}
- (void)clearText {
    if (self.isClear) {
        if (self.autoOperation) {
            if ([self.container isKindOfClass:[UITextView class]]) {
                UITextView *textView = (UITextView *)self.container;
                textView.text = nil;
            }
            if ([self.container isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)self.container;
                textField.text = nil;
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(clearText:)]) {
                [self.delegate clearText:self];
            }
        }
        self.isClear = false;
    }
}
#pragma - mark WhatKeyboardDelegate

- (IBAction)delete:(WhatButton *)sender {
     [self playSound];
    [self clearText];
    if (self.autoOperation) {
        if ([self.container isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)self.container;
            [textView deleteBackward];
        }
        if ([self.container isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)self.container;
            [textField deleteBackward];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickDelete:)]) {
            [self.delegate didClickDelete:self];
        }
    }
}
- (IBAction)confirm:(WhatButton *)sender {
     [self playSound];
    if (self.autoOperation) {
        if ([self.container isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)self.container;
            [textView resignFirstResponder];
        }
        if ([self.container isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)self.container;
            [textField resignFirstResponder];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickConfirm:)]) {
            [self.delegate didClickConfirm:self];
        }
    }
}
- (IBAction)space:(WhatButton *)sender {
     [self playSound];
    [self clearText];
    if (self.autoOperation) {
        if ([self.container isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)self.container;
            if ([self shouldPerformBtn:sender]) {
                [textView insertText:@" "];
            }
        }
        if ([self.container isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)self.container;
            if ([self shouldPerformBtn:sender]) {
                [textField insertText:@" "];
            }
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSpace:)]) {
            if ([self shouldPerformBtn:sender]) {
                [self.delegate didClickSpace:self];
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
        [self.popView showFromButton:btn];
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    
    CGPoint location = [touch locationInView:touch.view];
    WhatButton *btn = [self keyboardButtonWithLocation:location];
    
    if (btn) {
        self.selectButton = btn;
        [self.popView showFromButton:btn];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.selectButton = nil;
    [self.popView removeFromSuperview];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.popView removeFromSuperview];
    
    UITouch *touch = touches.anyObject;
    CGPoint location = [touch locationInView:touch.view];
    WhatButton *btn = [self keyboardButtonWithLocation:location];
    
    if (btn) {
        [self clearText];
         [self playSound];
        if (self.autoOperation) {
            if ([self.container isKindOfClass:[UITextView class]]) {
                UITextView *textView = (UITextView *)self.container;
                if ([self shouldPerformBtn:btn]) {
                    [textView insertText:btn.currentTitle];
                }
            }
            if ([self.container isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)self.container;
                if ([self shouldPerformBtn:btn]) {
                    [textField insertText:btn.currentTitle];
                }
            }
        } else {
            if ([self shouldPerformBtn:btn]) {
                [self.delegate didClickCharacter:self withString:btn.currentTitle];
            }
        }
    } else if (self.selectButton) {
         [self playSound];
        [self clearText];
        if (self.autoOperation) {
            if ([self.container isKindOfClass:[UITextView class]]) {
                UITextView *textView = (UITextView *)self.container;
                if ([self shouldPerformBtn:self.selectButton]) {
                    [textView insertText:self.selectButton.currentTitle];
                }
            }
            if ([self.container isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)self.container;
                if ([self shouldPerformBtn:self.selectButton]) {
                    [textField insertText:self.selectButton.currentTitle];
                }
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCharacter:withString:)]) {
                if ([self shouldPerformBtn:self.selectButton]) {
                    [self.delegate didClickCharacter:self withString:self.selectButton.currentTitle];
                }
            }
        }
    }
    
    self.selectButton = nil;
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


- (void)changeCurrentType {
    self.otherButton.hidden = !self.numberSelected;
    self.showNumberConstraint.constant = self.numberSelected ? - [UIScreen mainScreen].bounds.size.width / 20.0 : 0;
    
    [self.switchNumberButton setTitle:self.numberSelected ? @"ABC": @"#+123" forState:(UIControlStateNormal)];
    
    if (self.numberSelected) {
        [self.switchCapitalButton setTitle: self.capitalSelected ? @"数\n字" : @"符\n号" forState:(UIControlStateNormal)];
        [self.switchCapitalButton setImage:nil forState:(UIControlStateNormal)];
    } else {
        [self.switchCapitalButton setTitle:nil forState:(UIControlStateNormal)];
        [self.switchCapitalButton setImage:[UIImage imageNamed: self.capitalSelected ? @"WhatKeyboard.bundle/keyboard_capital" : @"WhatKeyboard.bundle/keyboard_small"] forState:(UIControlStateNormal)];
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

- (void)setCurrents:(NSMutableArray *)currents {
    if (_currents != currents) {
        _currents = currents;
        for (int i = 0; i < self.currents.count; i++) {
            [self.letterButtons[i] setTitle:self.currents[i] forState:(UIControlStateNormal)];
        }
    }
}

#pragma mark - Private Methods

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

#pragma - mark setter
- (void)setDelegate:(id<WhatKeyboardDelegate>)delegate {
    _delegate = delegate;
    self.autoOperation = (delegate != nil);
}

- (void)setSelectButton:(WhatButton *)selectButton {
    if (_selectButton != selectButton) {
        _selectButton.highlighted = false;
        selectButton.highlighted = true;
        _selectButton = selectButton;
    }
    
}

#pragma - mark lazy load
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
- (WhatPopView *)popView {
    if (!_popView) {
        _popView = ({
            WhatPopView *object = [WhatPopView popView];
            object;
        });
    }
    return _popView;
}

- (SystemSoundID)soundID {
    if (_soundID == 0) {
        NSURL *soundURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"WhatKeyboard.bundle/keyboard-click.aiff" withExtension:nil];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &_soundID);
    }
    return _soundID;
}


@end

