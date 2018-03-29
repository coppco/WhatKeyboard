Pod::Spec.new do |s|
    s.name                = 'WhatKeyboard'
    s.version             = '1.1.4'
    s.summary          = '自定义密码输入键盘'
    s.homepage         = 'https://github.com/coppco/WhatKeyboard'
    s.license              = 'MIT'
    s.author               = { 'coppco' => 'coppco@qq.com' }
    s.platform           = :ios, '7.0'
    s.source               = { :git => 'https://github.com/coppco/WhatKeyboard.git', :tag => s.version}
    s.default_subspec = 'Core'

    s.subspec 'Core' do |ss|
        ss.source_files = 'WhatKeyboard-master/*.{h,m}'
    end
    s.resources           = 'WhatKeyboard-master/*.{xib,storyboard,nib,bundle}'
    s.requires_arc      = true
end
