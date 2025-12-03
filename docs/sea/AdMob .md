---
title: AdMob
parent: sea
nav_order: 100
---



1. TOC
{:toc}



## 开启ump开关

欧盟弹窗的选项, 前两个选择开启, 后两个选择关闭

<img src="https://cdn.jsdelivr.net/gh/aikesi128/img_bed@master/25-11-28/ocJU4G_wew.png" alt="img" style="zoom:50%;" />



## 常见问题处理

### app-ads.txt 无法被验证

如果域名中带有www可能会被admob排除: 它默认排除“www.”和“m.”子网域 根据该规范，抓取工具将不会在“www.”和“m.”这两个子网域中查找文件, 如果有的话需要修改域名解析相关的东西, 去掉www这个子域

示例app-ads.txt(别人是怎么做的): https://translation.globatalkai.com/app-ads.txt