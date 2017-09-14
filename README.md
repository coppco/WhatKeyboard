## WhatKeyboard


WhatKeyboard是一个自定义的密码输入框键盘

![预览](http://oak4eha4y.bkt.clouddn.com/WhatKeyboard.png)        
 
## 近期更新（2017-09-13)


#### 2017-09-13

1. 支持UITextView和UITextField
2. 支持自动操作, 不用设置代理
3. 支持设置代理自定义操作
4. 支持Cocoapods导入
5. 支持再次输入时清空上传输入的密码
6. 支持点击放大显示, 滑动显示

#### 计划中

1. 代码优化
2. 支持其他输入框
             

## 怎么导入

* 方式1
把`WhatKeyboard`整个文件夹拖入你的工程

* 方式2
使用`Cocoapods`, `pod 'WhatKeyboard'`

## 怎么使用
* 首先导入头文件`#import "WhatKeyboard.h"`
* 自动处理

```
self.textField.inputView = [WhatKeyboard keyboard];
```

* 当然你也可以使用代理, 自己处理

```
WhatKeyboard *keyboard = [WhatKeyboard keyboard];
keyboard.delegate = self;
self.textField.inputView = keyboard;

遵循代理WhatKeyboardDelegate, 实现代理方法

#pragma - mark WhatKeyboardDelegate
- (void)clearText:(WhatKeyboard *)keyboard {
    self.textField.text = nil;
}
- (void)didClickSpace:(WhatKeyboard *)keyboard {
    [self.textField insertText:@" "];
}
- (void)didClickDelete:(WhatKeyboard *)keyboard {
    [self.textField deleteBackward];
}
- (void)didClickConfirm:(WhatKeyboard *)keyboard {
    [self.textField resignFirstResponder];
}
- (void)didClickCharacter:(WhatKeyboard *)keyboard withString:(NSString *)str {
    [self.textField insertText:str];
}
```
