# UFileSDK release history

### v-3.0.2(2018.12.21)

* 日志级别设置
* 支持本地和服务器签名
* 文件操作
	* 普通上传
	* 极速上传
	* 文件方式上传
	* 上传`buffer(NSData)`类型数据
	* 分片上传
	* 下载文件(整体，部分)
	* 下载文件到目录
	* 删除文件
	* 查询文件
* 获取`bucket`下文件列表
* 查询文件的`headFile`
* 获取`bucket`下文件的下载地址
* 比较本地文件与`bucket`中文件的etag值

### v-3.0.3(2019.01.02)

* fix issue-#1

### v-3.0.4(2019.02.19)

* fix bug: 上传文件进度无效

### v-3.0.5(2019.05.07)

* fix warning: 发布SDK到cocoapods时`MIT LICENSE`路径错误
