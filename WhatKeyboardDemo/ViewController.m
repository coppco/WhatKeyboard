//
//  ViewController.m
//  WhatKeyboardDemo
//
//  Created by apple on 2017/9/13.
//  Copyright © 2017年 mine. All rights reserved.
//

#import "ViewController.h"
#import "WhatKeyboardManager.h"
@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property (weak, nonatomic) IBOutlet UITextField *autoTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;

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

}

- (void)viewDidLoad {
    [super viewDidLoad];
    WhatAllKeyboard *keyboard = [WhatAllKeyboard allKeyboardWithConfiguration:([WhatAllKeyboardConfiguration sharedManager])];
    self.myTextField.inputView = keyboard;
    self.myTextField.delegate = self;
    
    self.myTextField.secureTextEntry = true;
    
    WhatNumberKeyboard *keyboardNumber = [WhatNumberKeyboard numberKeyboardWithConfiguration:([WhatNumberKeyboardConfiguration sharedManager])];
    self.numberTextField.inputView = keyboardNumber;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.myTextField) {
        if (string.length == 0) {
            return true;
        }
        NSString *pattern = @"^[\\s\\S]{5}$";
        NSError *error = nil;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:(NSRegularExpressionCaseInsensitive) error:&error];
        if (error) {
            return true;
        }
        NSLog(@"%@", ([regex matchesInString:textField.text options:(NSMatchingReportProgress) range:NSMakeRange(0, textField.text.length)].count == 0) ? @"可以输入": @"不能输入");
        return [regex matchesInString:textField.text options:(NSMatchingReportProgress) range:NSMakeRange(0, textField.text.length)].count == 0;
    }
    return true;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

@end
