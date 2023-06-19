# US3 SDK for iOS

## 概要

![](https://camo.githubusercontent.com/86885d3ee622f43456c8b890b56c3f05d6ec2c5e/687474703a2f2f636c692d75636c6f75642d6c6f676f2e73672e7566696c656f732e636f6d2f75636c6f75642e706e67)

本文档主要是`US3 (原名UFile) SDK for iOS`的使用说明文档，下面我们从以下几个方面做介绍： 

* 目录结构
* 环境要求
* 安装使用
* 功能说明
* 常见问题
* 联系我们

## 目录结构

该仓库主要包括`SDK`的源码以及示例项目，示例项目包含`Objective-C`和`Swift`两个版本。 

目录  | 说明
------------- | -------------
`SDK/UFileSDK` | SDK源码
`SDK/UFileSDK/UFileSDKTests` | SDK各个功能的单元测试
`SDK/documents/devDocuments.zip` | SDK开发文档(解压后可用浏览器查看)
`SDK/Demos/OC/UFileSDKDemo` | Demo程序(`Objective-c`版本)
`SDK/Demos/Swift/UFileSDKDemo-swift` | Demo程序(`Swift`版本)

## 环境要求

* iOS系统版本>=9.0
* 必须是`UCloud`的用户，并开通了`US3`服务。

## 安装使用

### cocoapods方式

在你项目的`Podfile`中加入以下依赖：

```
pod 'UFileSDK'
```

### 使用方法

在工程中引入头文件:

```
#import <UFileSDK/UFileSDK.h>
```

注意，引入Framework后，需要在工程`Build Settings`的`Other Linker Flags`中加入`-lc++` 。如下图所示

![](https://raw.githubusercontent.com/ucloud/ufile-sdk-ios/master/documents/resources/readme_01.png)

## 功能说明

### 文件操作功能

 * 文件上传(以路径方式；以NSData方式；分片上传)
 * 文件下载(下载指定范围文件数据；下载整个文件；下载文件到路径)
 * 查询文件
 * 删除文件
 * 获取`bucket`下的文件列表(全部文件列表；指定前缀等条件的文件列表)
 * 获取`bucket`下文件的下载地址(公有`bucket`空间下文件下载地址；私有`bucket`空间下文件下载地址)
 * 获取文件的headfile信息(包括文件的mimetype,etag等)
 * 获取文件的`Etag`
 * 对比本地与远程文件的`Etag`

其操作类是`UFFileClient.h`,以上各个功能详细使用方法请查看[SDK单元测试](https://github.com/ucloud/ufile-sdk-ios/blob/master/UFileSDK/UFileSDKTests/UFFileClientTests.m)或者我们提供的[Demo](https://github.com/ucloud/ufile-sdk-ios/tree/master/Demos)

### 代码示例

#### 文件管理

假设此时，US3的控制台上你已经创建好了`Bucket`。下面我们介绍一下如何进行文件操作。

首先创建一个文件操作类,需要传入配置信息(主要是`bucket`配置信息)：

```
#import <UFileSDK/UFileSDK.h>

 // 使用本地签名，不推荐使用这种方式
UFConfig *ufConfig = [UFConfig instanceConfigWithPrivateToken:@"bucket私钥" publicToken:@"bucket公钥" bucket:@"bucket名称" fileOperateEncryptServer:nil fileAddressEncryptServer:nil proxySuffix:@"域名后缀"];
    
 // 使用服务器签名，推荐使用
UFConfig *ufConfig = [UFConfig instanceConfigWithPrivateToken:nil publicToken:@"bucket公钥" bucket:@"bucket名称" fileOperateEncryptServer:@"文件操作签名服务器" fileAddressEncryptServer:@"获取文件URL的签名服务器" proxySuffix:@"域名后缀"];
UFFileClient *fileClient =  [UFFileClient instanceFileClientWithConfig:ufConfig];

```

文件管理操作时，你所操作的`bucket`空间就是你在创建`UFFileClient`时所配置的`bucket`。下面我们示例一个简单的文件上传：

```
// 上传文件(以路径方式)
NSString*  fileName = @"initscreen.jpg";
NSString* strPath = [[NSBundle mainBundle] pathForResource:@"initscreen" ofType:@"jpg"];
    
[_fileClient uploadWithKeyName:fileName filePath:strPath mimeType:@"image/jpeg" progress:^(NSProgress * _Nonnull progress) {
        
    } uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
    if(!ufError){
    	// 你的上传成功逻辑
	   return;
    }
    // 根据ufError处理失败信息
    }];
```

### 服务器签名

此处特别强调：我们推荐使用服务端签名。 服务端签名示例代码地址 [ufile-sdk-auth-server](https://github.com/ucloud/ufile-sdk-auth-server) ,你可以直接把它部署到你的服务器上配置好参数后在移动端使用。

### Demo程序

我们在demo程序中，演示了文件操作的所有功能，你可以在本工程中查看其具体流程。另外，为了能更好的理解并使用`UFile SDK`，我们在此还提供了[UFileSDKDemo说明文档](https://github.com/ucloud/ufile-sdk-ios/blob/master/documents/DemoIntroduction.md)


## 常见问题

* `iOS 9+`强制使用`HTTPS`,使用`XCode`创建的项目默认不只支持`HTTP`，所以需要在`project build info` 添加`NSAppTransportSecurity`,在`NSAppTransportSecurity`下添加`NSAllowsArbitraryLoads`值设为`YES`,如下图。 
	![](https://raw.githubusercontent.com/ucloud/ufile-sdk-ios/master/documents/resources/readme_02.png)
	
## 版本记录

[UFileSDK release history](https://github.com/ucloud/ufile-sdk-ios/blob/master/documents/update.md)

## 联系我们

* [UCloud官方网站: https://www.ucloud.cn/](https://www.ucloud.cn/)
*  如有任何问题，欢迎提交[issue](https://github.com/ucloud/ufile-sdk-ios/issues)或联系我们的技术支持，我们会第一时间解决问题。

## 许可证
[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0.html)      
