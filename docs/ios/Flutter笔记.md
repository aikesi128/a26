---
title: Flutter study note
parent: ios
nav_order: 30
---
1. TOC
{:toc}


## 安装

**Flutter 环境搭建, 跟着一步一步做即可: `https://docs.flutter.dev/get-started/quick`**



## Dart 语言

每个有状态的组件, 在创建或者添加到组件树上的时候, 都会调用initState()方法,  可以在这里进行一些初始化数据的操作, 不过第一行必须是`super.initState()`. 热重载的时候不会调用这个方法

1. 都是引用类型, 没有值类型,  所以没有struct关键字, 也没有元组类型

2. 实现多mixinxsd 的方法查找顺序, 自己本类, Flyer, Consumen, Animal

```
class Bird extends Animal with Consumer, Flyer {
```

3. A widget's main job is to implement a [`build()`](https://api.flutter.dev/flutter/widgets/StatelessWidget/build.html) function

4. 使用material主题

```
在 pubspec.yaml 添加
name: my_app
flutter:
  uses-material-design: true
```

5. 在flutter中创建用户界面,  需要重写widget的build方法, 所有的widget都必须有一个build方法, 并且**这个方法必须返回另外一个widget.** 



## 常见问题处理

### QWA

1. flutter使用到系统功能, 申请用户授权时候无法拉起授权弹窗: `参考链接: https://pub.dev/packages/permission_handler`

2. xcode设备列表无法选择模拟器的时候?

   ```
   可以在设置中->Excluded Architecture 中将所有Any iOS Simulator SDK(Debug, Profile, Release) 下的arm64 选项都删除; 
   
   但这个项目最终引起模拟器失效的是谷歌的这个库:  google_mlkit_text_recognition: ^0.14.0
   导致Generated.xcconfig中的一句代码变成这样: EXCLUDED_ARCHS[sdk=iphonesimulator*]=i386 arm64
   最终导致当前项目无法再模拟器上运行, 这句配置在Xcode中的表现就是设置中Excluded Architecture下的所有选项都增加了arm64, 导致无法再模拟器上运行, 猜测可能是这个库要求必须是真机.
   ```

   

### 打包和安装

[参考文档](https://docs.flutter.dev/deployment/ios#upload-the-app-bundle-to-app-store-connect)

```json
# 打包
// 清理旧的构建产物
flutter clean 
// 构建iOS发布包
flutter build ipa --release


断开VS后打开应用闪退, 是因为调试模式依赖开发环境, 无独立运行能力, 调试签名证书权限不足;
想要设备上的应用断开电脑后不闪退, 需要构建profile或者release模式的独立包, 而非调试模式.

# 安装profile模式, 让客户端可以再次正常冷启动
flutter clean 
flutter build ios
flutter install --profile

# 安装release模式, 让客户端可以再次正常冷启动
flutter clean 
flutter build ios
flutter install --release

```



## 参考文档:

[官方学习文档](https://docs.flutter.dev/get-started)

从Swift到dart: https://dart.dev/resources/coming-from/swift-to-dart
