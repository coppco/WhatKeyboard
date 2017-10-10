#!/bin/bash

filename="WhatKeyboard.podspec"

#podspec文件路径
project_path="$(pwd)/${filename}"

echo -e "podspec文件路径为: ${project_path}\n"

echo -e "开始上传podspec\n"
#开始上传
log=$(pod trunk push ${project_path})


if [[ $log =~ "successfully" ]]
then
echo "上传成功"
else
echo -e "上传失败\n"

echo $log

fi
