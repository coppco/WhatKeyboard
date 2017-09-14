//
//  ViewController.m
//  WhatKeyboardDemo
//
//  Created by apple on 2017/9/13.
//  Copyright © 2017年 mine. All rights reserved.
//

#import "ViewController.h"
#import "WhatKeyboard.h"


@interface ViewController ()<WhatKeyboardDelegate>
@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property (weak, nonatomic) IBOutlet UITextField *autoTextField;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBegin:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBegin:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didBegin:(NSNotification *)notification {
    NSLog(@"开始编辑");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WhatKeyboard *keyboard = [WhatKeyboard keyboard];
    keyboard.delegate = self;
    self.myTextField.inputView = keyboard;
    [self.myTextField becomeFirstResponder];
    
    self.autoTextField.inputView = [WhatKeyboard keyboard];
}

#pragma - mark WhatKeyboardDelegate
- (void)clearText:(WhatKeyboard *)keyboard {
    self.myTextField.text = nil;
}
- (void)didClickSpace:(WhatKeyboard *)keyboard {
    [self.myTextField insertText:@" "];
}
- (void)didClickDelete:(WhatKeyboard *)keyboard {
    [self.myTextField deleteBackward];
}

- (void)didClickConfirm:(WhatKeyboard *)keyboard {
    [self.myTextField resignFirstResponder];
}

- (void)didClickCharacter:(WhatKeyboard *)keyboard withString:(NSString *)str {
    [self.myTextField insertText:str];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
