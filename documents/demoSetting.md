# UFileSDKDemo配置说明

## 概念解释

当进行文件操作操作时，需要配置`bucket`公私钥及后缀域名信息等。下面我们首先对这些参数做一一解释。 

文件管理需要用到的配置信息：

* bucket私钥：从控制台获取
* bucket公钥：从控制台获取
* bucket名称：所有的文件，都在一个bucket下面。
* 默认域名后缀： eg:ufile.ucloud.cn


`bucket`管理所需要用到的配置信息：

* `ucloud api`私钥：从控制台获取,和bucket私钥不同。
* `ucloud api`公钥：从控制台获取,和bucket公钥不同。

## UFileDemo设置

如下图所示，是Demo的设置页面。 

![](https://raw.githubusercontent.com/ufilesdk-dev/ufile-ios-sdk/master/documents/resources/demoSetting_01.png)

你可以手动输入这些参数进行配置，你也可以点击右上角的`扫描`按钮扫描配置信息的二维码进行参数填充，这样就避免了手动输入大量数据。


### 二维码内容格式

需要把你的配置参数按照按照以下格式拼凑，然后再生成二维码(可以使用[微微二维码](http://www.wwei.cn/))。

```
{
  "ucloudApiPublicKey" :  " 你的ucloudApiPublicKey ", 
  "ucloudApiPrivateKey":  "你的ucloudApiPrivateKey",
  "bucketPublicKey"    :  "你的bucket public key",
  "bucketPirvateKey"   :  "你的bucket private key",
  "ProfixSuffix"       :  "你的域名后缀",
  "BucketName"         :  "你的bucket名称"
}

```

生成二维码后，用demo进行扫描填充最后点击`应用`按钮生效，接着就可以用你的配置信息进行文件和bucket管理操作了。如下图所示： 

![](https://raw.githubusercontent.com/ufilesdk-dev/ufile-ios-sdk/master/documents/resources/demoSetting_02.png)
![](https://raw.githubusercontent.com/ufilesdk-dev/ufile-ios-sdk/master/documents/resources/demoSetting_03.png)