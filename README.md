###注意
请在真机上测试相机、定位及通讯录等功能，LJPrefs只实现了权限的判断和设置跳转，后面会对功能单独开辟Demo<br>大部分项目都会用到iOS系统自带的一些功能，类似第三方封装也有很多，但是很多只单纯实现了功能，自从iOS8开始苹果对用户隐私越发重视，用户第一次点开APP/使用系统自带隐私功能时弹出框如果点击不允许后不做权限判断会导致诸多问题，本着将这块的用户体验做好，于是心血来潮就做了LJPrefs

###使用方法（以相机为例）
#####获取当前APP是否已获取相机权限：
```OC
[PrefsCamera adjustPrivacySettingEnable:^(BOOL pFlag) {
	
}];
```
#####跳转至设置-隐私-相机：
```OC
[PrefsCamera openPrivacySetting];
```

目前提供的常用隐私设置有 : )

* PrefsLocation 定位
* PrefsAddressBook 通讯录
* PrefsPhoto 相片
* PrefsMicrophone 麦克风
* PrefsCamera 相机

===========================
后面我还会继续写推送、iOS无线数据、声音等权限，欢迎各路大神指出不足之处，小弟一定虚心接受。
###　　　　　　　　　　Author:Geniune
###　　　　　　　　E-mail:geniunee@126.com

===========================
