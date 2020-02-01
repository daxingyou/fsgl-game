
ZC_targetPlatform = cc.Application:getInstance():getTargetPlatform()


--UC 配置
UC_CPID = "53156"     --0
UC_GAME_ID = "577727"   --535784
UC_SERVER_ID = "0"

--适配刘海屏的偏移基准像素
ScreenOffsetX = 100

--顶号flag
ISDINGHAO = false
--心跳计数器
BEATCOUNTDOWN = 0
--断线重连倒计时
CONNECTTIME = 30
--是否是第一次热更
ISFIRSTUPDATE = true
--是够有未读邮件
ISUNREADMAIL = false

--渠道 配置
--游戏名称：  援军
GAME_APPKEY    =     ""  
ISLEVELUP = 0

--渠道号
--[[--以下命名规则建议改成:CHANNEL_CODE_xxxxx
(下次提交这部分的代码的时候需要多加小心)
]]
CHANNEL_CODE_Define = "local"  --只有在未接入任何sdk的情况下，所以一般事开发环境中使用
CHANNEL_CODE_XM = "xm"   	--小米
CHANNEL_CODE_HW = "hw"      --华为
CHANNEL_CODE_360 = "360"  
CHANNEL_CODE_BD = "bd"	 	--百度
CHANNEL_CODE_XT = "xt"      --信条
CHANNEL_CODE_XG = "xg"      --溪谷
CHANNEL_CODE_JW = "jw"		--简玩
CHANNEL_CODE_FB = "fb"		--Facebook
CHANNEL_CODE_SY = "sy"      --上游

CHANNEL_CODE_APPSTORE = "appstore" 



CHANNEL = {
	Android = {
		CHANNEL_CODE_Define = "local",
		CHANNEL_CODE_XM = "xm",   	--小米
		CHANNEL_CODE_HW = "hw",     --华为
		CHANNEL_CODE_360 = "360",  
		CHANNEL_CODE_BD = "bd",	 	--百度
		CHANNEL_CODE_XT = "xt",     --信条
		CHANNEL_CODE_XG = "xg" ,    --溪谷
		CHANNEL_CODE_JW = "jw" ,    --简玩
		CHANNEL_CODE_FB = "fb" ,	--Facebook
		CHANNEL_CODE_SY = "sy" ,    --上游
	},
	IOS   = {
		CHANNEL_CODE_Define = "local",
		CHANNEL_CODE_XM = "xm",   	--小米
		CHANNEL_CODE_HW = "hw",     --华为
		CHANNEL_CODE_360 = "360",  
		CHANNEL_CODE_BD = "bd",	 	--百度
		CHANNEL_CODE_XT = "xt" ,    --信条
		CHANNEL_CODE_XG = "xg" ,    --溪谷
		CHANNEL_CODE_JW = "jw" ,    --简玩
		CHANNEL_CODE_FB = "fb",		--Facebook
		CHANNEL_CODE_SY = "sy" ,    --上游
		CHANNEL_CODE_APPSTORE = "appstore", 
	}
}

--内购商品ID对应表
AppStoreGoods = {
	[1] = "com.vZIqJYo.HrMLi_6",
	[2] = "com.vZIqJYo.HrMLi_30",
	[3] = "com.vZIqJYo.HrMLi_68",
	[4] = "com.vZIqJYo.HrMLi_198",
	[5] = "com.vZIqJYo.HrMLi_328",
	[6] = "com.vZIqJYo.HrMLi_648",
	[7] = "com.vZIqJYo.HrMLiYK_25",
	[8] = "com.vZIqJYo.HrMLiZSK_98",
	[9] = "com.vZIqJYo.HrMLiXSLB_30",
	[10] = "com.vZIqJYo.HrMLi_1598",
	[11] = "com.vZIqJYo.HrMLiCZJJ_68",
}

--游戏设备信息
GAME_CHANNEL = "local" --默认为def 测试
GAME_MAC = ""
GAME_IDFA = ""
GAME_OS_VERSION = ""
GAME_ANDROIDID = ""

lastGuideRecuritTime = 0   --上一次申请加入帮派的时间

isLoginFlag = false

isLoginUC = false

isNotShowLoginUI = false


--用于异步更新渠道判断
if (cc.PLATFORM_OS_ANDROID == ZC_targetPlatform) then
    GAME_CHANNEL = "local" --android官网
elseif (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) or (cc.PLATFORM_OS_MAC == ZC_targetPlatform) then
    GAME_CHANNEL = "local" --IOS官网
end

--用于统计手机型号，版本号等
GAME_ANDROID_MODEL = ""         --手机型号
GAME_ANDROID_VERSION_NUM = ""   --版本号

--Java中用的类
JAVA_PLATFORMSDK = "org/cocos2dx/plugin/PlatformSdk"
OBJECTC_PLATFORMSDK = "PlatformSdk"
--用于异步更新渠道判断
if (cc.PLATFORM_OS_ANDROID == ZC_targetPlatform) then
    LUA_BRIDGE_CLASS = JAVA_PLATFORMSDK
elseif (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) or (cc.PLATFORM_OS_MAC == ZC_targetPlatform) then
    LUA_BRIDGE_CLASS = OBJECTC_PLATFORMSDK
end

OC_ZCJNIHELPER = "ZCJniHelper"
