---
title: CoreDataWithCloud
---



1.TOC

{:toc}



### CoreDataWithCloud

Coredata就是一个数据库,  一套数据本地持久化的解决方案. 可以建表, 进行增删改查等操作, 但是一旦app卸载数据将无法找回.

CoreDataWithCloud相当是加强版本, 数据可以同步到云端, 在多设备之间同步, 只要登录同一个Apple账号, 就可以同步数据, 可以当做一个用户的私有服务器来使用.

### 如何配置

- 创建项目的时候不要勾选Host in CloudKit, 创建完成后在Capability中增加CloudKit的能力. 勾选Services下的CloudKit. 并创建新的container, 格式:iCloud+bundleID
- 初始化Coredata的时候将 `NSPersistentContainer` 替换为 `NSPersistentCloudKitContainer`, 这样数据就会自动同步到用户的iCloud中.
- 其他使用就和Coredata一样.

### 不同状态对数据同步整体流程的影响

在iCloud中, 不同的设置会对数据是否可以顺利同步到iCloud中是有影响的.

| iCloud | iCloud Drive | iCloud中当前app状态开关 | case名称 | CoreDataWithCloud工作状态 |
| ------ | ------------ | ----------------------- | -------- | ------------------------- |
| 登录   | 开启         | 开启                    | A1       | 正常                      |
| 登录   | 开启         | 关闭                    | A2       | 无法同步                  |
| 登录   | 关闭         | 开启                    | A3       | 正常                      |
| 登录   | 关闭         | 关闭                    | A4       | 无法同步                  |
| 未登录 | na           | na                      | A5       | 无法同步                  |



```
A1说明: 这是正常的数据配置, 一切表现正常.

A2说明:
在设置中关闭当前app的iCloud功能的时候(当前app后边的switch在关闭状态, iCloud登录正常, driver处于开启状态) 

1. 导致 CKContainer.default().accountStatus 这个函数返回: case noAccount = 3, 账户不允许
2. 间接导致在监听数据同步到通知中拿到的Event, event.type是.setup的时候, 状态是false(event:  type is 0  res is false  error is The operation couldn’t be completed. (Cocoa error 134400.)), 也就是coredata的cloud功能设置失败. 并且不会有后续的导入导出的通知事件发生. 
3. 即使本地增加一条数据, 但是也不会同步到cloudkit控制台的.
4. 数据表现: FileManager.default.ubiquityIdentityToken 获取令牌失败
5. 当前app后边的switch处于打开状态, 所有数据恢复正常

A3说明:
1. FileManager.default.ubiquityIdentityToken 令牌获取失败
2. CKContainer.default().accountStatus 账户状态正常
3. coredata icloud 工作正常

A4说明:
1. 获取令牌失败
2. 账户状态显示没有账户
3. 同步数据报错134405/134400, 无法同步数据

A5说明:
1. 获取令牌失败
2. 账户状态显示没有账户
3. 同步数据报错134400, 无法同步数据
```

**总结: **

1. 只要登录iCloud,  打开对应app状态开关, xcodeWithCloud就可以正常工作.
2. 是否可以获取token(令牌) = iCloud Drive状态是否开启, 对xcodeWithCloud没有影响
3. 即使当前App没有做登录模块, 只要设置中的开关满足, 数据也是可以同步到云端的.



### 监听数据变化

- 获取账户状态,  这个很重要, 直接影响是否可以顺利同步数据

  ```
  import CloudKit
  
  CKContainer.default().accountStatus { s, error in
      if s == CKAccountStatus.available {
          print("account is ok")
      }else {
          print(s.rawValue, error?.localizedDescription, "account not alow")
      }
  }
  ```

- 在单例中进行初始化

  ```
  private lazy var persistentContainer: NSPersistentCloudKitContainer = {
          let container = NSPersistentCloudKitContainer(name: "HCC")
          container.loadPersistentStores(completionHandler: { (storeDescription, error) in
              if let error = error as NSError? {
                  print("Unresolved error \(error), \(error.userInfo)")
              }
          })
          
          // 启用历史追踪, 用于冲突处理, 变更追溯
          container.viewContext.transactionAuthor = "appUser"
          container.viewContext.automaticallyMergesChangesFromParent = true
          container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump // 本地覆盖云端 
          return container
      }()
  ```

- 监听事件通知: NSPersistentCloudKitContainer.eventChangedNotification, .setup .import .export 等

  - userInfo中event对应的对象就是NSPersistentCloudKitContainer.Event类型的一个对象
  - 对象中包含事件类型, 是否成功, 事件信息, 错误信息等, 可以填充自己的逻辑, 比如导入事件并且成功的时候, 本地的数据量会发生变化, 这里可以刷新UI.

  ```
  NotificationCenter.default.addObserver(forName: NSPersistentCloudKitContainer.eventChangedNotification, object: nil, queue: nil) { noti in
  //            print(#function)
              if let event = noti.userInfo?["event"] as? NSPersistentCloudKitContainer.Event {
                  print("event: ", "type is \(event.type.rawValue) ", "res is \(event.succeeded) ", "error is \(event.error?.localizedDescription ?? "")")
                  if event.succeeded {
                      CCManager.manager.logCount()
                  }
              }
          }
  ```

  

### CloudKit 控制台

这是Apple提供的一个web查询数据的入口: https://icloud.developer.apple.com/dashboard

- 查看客户端同步到云端的数据
- 要查询的话要先增加recordName的索引, 否则可能会报错: Field 'recordName' is not marked queryable
- 也可以在这里进行增删改查, 与客户端在测试环境下进行联调, 数据库选择隐私数据库.
- 调试完毕之后需要将最终确定的scheme发布到生产环境.

<img src="https://aikesi128.github.io/aktools/childs/source/1.png" style="zoom:50%;" />		

<img src="https://aikesi128.github.io/aktools/childs/source/2.png" style="zoom:50%;" />