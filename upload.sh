#!/bin/bash

filename="WhatKeyboard.podspec"

#podspec文件路径
project_path="$(pwd)/${filename}"

echo "开始上传podspec"
#开始上传
pod trunk push ${filename}
