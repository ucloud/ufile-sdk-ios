# UFileSDKDemo使用说明

## 概要

本文档主要介绍如何使用`UFileSDKDemo`，我们通过对`UFileSDKDemo`做系统介绍将对你有如下帮助：

* 如果你是一名iOS开发者，能让你更清晰的理解`UFileSDKDemo`并能快速上手集成`UFileSDK`，从而提高效率。
* 如果你是一名技术支持人员，有些case你不用找研发人员就可以自己根据用户配置参数来快速定位问题

接下来我们从以下几个方面做介绍： 

* 安装运行
* 应用设置
* 功能介绍
* 视频相关
* 其它

## 安装运行

### 源码方式

开发者主要是使用这种方式。首先到`github`上下载`UFileSDK`源码

```
git clone https://github.com/ucloud/ufile-sdk-ios.git
```

进入到`Demos/OC/UFileSDKDemo`目录,利用`cocoapods`安装`UFileSDK`

```
pod install
```

打开`UFileSDKDemo.xcworkspace`即可运行。 

### 直接下载安装

为了快速方便排查问题，我们还发布了beta版本，可通过以下方式安装。

用苹果手机打开浏览器输入 `https://fir.im/41w8` 然后点击安装

![](https://ws3.sinaimg.cn/large/006tNbRwgy1fydblwdu3tj30u01szdwx.jpg)

点击Home键回到桌面打开`UFileSDKDemo`，提示如下：

![](https://ws1.sinaimg.cn/large/006tNbRwgy1fydbn5v4f1j30u01sznpi.jpg)

你需要进入设置页面设置信任该应用： `设置->通用-设备管理->企业级应用->信任证书`

![](https://ws1.sinaimg.cn/large/006tNbRwgy1fydbo4uqb8j30u01sztkp.jpg)

此时就可以打开app了。

## 应用设置

打开app的设置页面，如图

![](https://ws3.sinaimg.cn/large/006tNbRwgy1fydbtvdi0cj30u01sz79t.jpg)

### 概念解释

当进行文件操作操作时，需要配置`bucket`公私钥及后缀域名信息等。下面我们首先对这些参数的来源以及用处做一一解释。 

* bucket私钥：本地签名时需要用到，从控制台获取
* bucket公钥：从控制台获取
* bucket名称：所有的文件，都在一个bucket下面。
* 默认域名后缀： eg:ufile.ucloud.cn
* 文件操作签名服务： 在做文件操作时(上传、下载、删除等)可以使用服务器签名，在此处配置该签名服务器地址
* 文件地址签名服务: 只有在获取私有bucket下的文件url时，可以使用该服务器签名，在此处配置该签名服务器地址


### 参数设置

获取到设置页面上的各个参数后，可以手动输入，最后点击`应用`按钮，重启应用，下次打开生效。

你也可以通过点击右上角的`扫描`按钮，扫描配置信息的二维码对页面进行参数填充，这样可以避免手动输入大量数据。

#### 二维码内容格式

需要把你的配置参数按照按照以下格式拼凑，然后再生成二维码(可以使用[微微二维码](http://www.wwei.cn/))


以下是服务器签名所必须得配置信息(推荐使用服务器签名方式):

```
{
  "bucketPublicKey"    :  "你的bucket public key",
  "ProfixSuffix"       :  "你的域名后缀",
  "BucketName"         :  "你的bucket名称",
  "FileOperateEncryptServer"  : "你的文件操作签名服务器地址",
  "FileAddressEncryptServer"  : "你的文件下载签名服务器地址"
}
```

生成二维码后，用demo进行扫描填充最后点击`应用`按钮生效，接着就可以用你的配置信息进行文件管理操作了。如下图所示：

![](https://ws3.sinaimg.cn/large/006tNbRwgy1fydcgkr0nfj30u01sznpi.jpg)

填充后

![](https://ws4.sinaimg.cn/large/006tNbRwgy1fydchxiwj1j30u01szgup.jpg)


如果采用本地签名的方式(不安全),则配置信息是如下格式：

```
{
  "bucketPublicKey"    :  "你的bucket public key",
  "bucketPirvateKey"   :  "你的bucket private key",
  "ProfixSuffix"       :  "你的域名后缀",
  "BucketName"         :  "你的bucket名称",
}
```

## 功能介绍

app提供的具体功能有:文件普通上传、分片上传、下载、查询、删除、bucket下文件列表信息、文件的headfile信息等。此外，app还有展示错误信息页面，会将经常遇到的错误信息打印出来。

普通上传成功
![](https://ws2.sinaimg.cn/large/006tNbRwgy1fydcvegydcj30u01sztfn.jpg)

文件下载成功
![](https://ws2.sinaimg.cn/large/006tNbRwgy1fydcway4ukj30u01sz7ik.jpg)

普通上传出错
![](https://ws1.sinaimg.cn/large/006tNbRwgy1fydcwvg4dgj30u01szgsi.jpg)

## 视频相关

### 播放你存在UFile中的视频

我们的`SDK`中有能获取`bucket`空间下文件的下载URL接口。可以通过ios播放器直接播放该URL。

市场上大多数的播放使用的是`ijkplayer`，如果你用的也是，可能会有编译不过的情况。可以通过回退版本或指定编译平台的方式来解决(亲测)，具体可参考[ijkpalyer-k0.5.1-arm64](https://github.com/MaxwellQi/ijkplayer)

## 其它

* 如对demo有任何问题(bug、需求、建议)，欢迎提交[issue](https://github.com/ucloud/ufile-sdk-ios/issues)










