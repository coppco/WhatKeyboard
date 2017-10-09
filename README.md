## WhatKeyboard


WhatKeyboard是一个自定义的密码输入框键盘

![预览](http://oak4eha4y.bkt.clouddn.com/WhatKeyboard.png)        
 
## 近期更新（2017-10-09)

#### 2017-10-09
1. 新增九宫格数字键盘
2. 重构键盘, 完全配置

#### 2017-09-22
1. 适配Xcode9

#### 2017-09-18
1. 增加按键音效

#### 2017-09-15
使用自定义密码键盘时, 系统通知是有的, 但是对应的输入框代理方法不会走, 所以需要手动处理.
1. 新增对UITextView和UITextField, 他们下面两个代理方法的判断能否输入

```
## UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

## UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField; 

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string; 
```

#### 2017-09-13

1. 支持UITextView和UITextField
2. 支持自动操作, 不用设置代理
3. 支持设置代理自定义操作
4. 支持Cocoapods导入
5. 支持密码输入时, 再次输入清空密码
6. 支持点击放大显示, 滑动显示

#### 计划中

1. 代码优化
2. 支持其他输入框
             

## 怎么导入

* 手动方式
把`WhatKeyboard-master`整个文件夹拖入你的工程

* 使用Cocoapods导入
使用`Cocoapods`, `pod 'WhatKeyboard'`

## 怎么使用

* 首先导入头文件`#import "WhatKeyboardManager.h"`
* 快速使用

```
WhatAllKeyboard *keyboard = [WhatAllKeyboard allKeyboardWithConfiguration:([WhatAllKeyboardConfiguration sharedManager])];
textField.inputView = keyboard;

WhatNumberKeyboard *keyboardNumber = [WhatNumberKeyboard numberKeyboardWithConfiguration:([WhatNumberKeyboardConfiguration sharedManager])];
textView.inputView = keyboardNumber;
```
* 自定义使用, 以下是默认值, 根据实际需要修改相关属性即可

```
WhatNumberKeyboardConfiguration *config = [WhatNumberKeyboardConfiguration sharedManager];

/*********公共属性*********/
//音效
config.soundEffectEnable = true;
//自定义音效文件
config.soundResource = nil;
//长按删除
config.longPressDeleteEnable = true;
//安全模式时清空输入框
config.cleanEnable = true;
//确定按钮执行的block
config.didConfirmed = nil;
//删除按钮正常状态图片
config.deleteNormalImage = nil;
//删除按钮高亮状态图片
config.deleteHighlightImage = nil;
//确定按钮的标题
config.confirmName = @"确定";
//确定按钮的文字颜色
config.confirmTextColor = [UIColor whiteColor];
//确定按钮的正常状态背景颜色
config.confirmNormalBackgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.7];
//确定按钮的高亮状态背景颜色
config.confirmHighlightBackgroundColor = [UIColor orangeColor];
    
/*********特有属性*********/
//随机键盘
config.randomEnable = true;
//小数点
config.decimalPointEnable = true;
//是否需要toolbar
config.toolbarEnable = true;
//toolbar的logo
config.securityImage = nil;
//toolbar标题
config.middleTitle = @"安全键盘";
//随机键盘按钮
config.randomButtonEnable = true;
//随机按钮
config.randomNormalImage = @"WhatKeyboard.bundle/see_normal";
config.randomSelectedImage = @"WhatKeyboard.bundle/peep_normal";
config.randomHighlightImage = nil;
config.randomNormalTitle = nil;
config.randomHighlightTitle = nil;
config.randomSelectedTitle = nil;

WhatNumberKeyboard *keyboardNumber = [WhatNumberKeyboard numberKeyboardWithConfiguration:config];
textView.inputView = keyboardNumber;
```

