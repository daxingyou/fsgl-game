XTHDADHttp = {}

ZCAD_SEND_TYPE = {
	ACTIVE = 1,
	REG = 2,
	START = 3,
	LEVEL = 4,
	SEND = 5,
}

--[[ http://ad.ucapi.zhanchenggame.com/index.php?c=iostrack&data={
		"product": "bdwsw",
		"mac":"80:E6:50:08:1B:42",
		"idfa":"",
		"appid":"916435158",
		"device_name":"iphone",
		"os_name":"iOS",
		"os_version":"7.1.3",
		"jailbreak":"0",
		"ssid":"ZCAP",
		"sign":"e80b7cfea433d6b22d569c16d94976f5"}

]]
local function sendHttp( sTitle, sKey, sTb )
    local _TARGET_PLATFORM = cc.Application:getInstance():getTargetPlatform()
    local _device_name = _TARGET_PLATFORM == cc.PLATFORM_OS_IPAD and "iPad" or "iPhone"

	local _url = sTitle .. "&data={"
	local _signValue = ""
	for i=1, #sTb do
		local _data = sTb[i]
		_url = _url .. "\"" .. _data[1] .. "\":" .. "\"" .. _data[2] .. "\","
		_signValue = _signValue .. _data[2]
	end  
	_signValue = _signValue .. sKey
	-- print("wm----signValue : " .. _signValue)
	local _sign = iBaseCrypto:MD5Lua(_signValue, false)
	-- print("wm----sign : " .. _sign)
	_url = _url .. "\"sign\":\"" .. _sign .. "\"}"
	-- print("wm----url : " .. _url)

	local _tb = {
        url = _url,
        encrypt = HTTP_ENCRYPT_TYPE.NONE,
        successCallback = function(data)
	        -- dump(data, "wm----back")
        end,--成功回调
        failedCallback = function()
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
    }

	local http = XTHDHttp:createWithParams(_tb)
    return http:_requestAsyncWithParams(_tb)
end


function XTHDADHttp.SendByType( sType )
	-- print("wm----GAME_CHANNEL : " .. tostring(GAME_CHANNEL) .. " , " .. CHANNEL_CODE_APPSTORE)
	if GAME_CHANNEL ~= CHANNEL_CODE_APPSTORE then
		return 
	end
	
	local _TARGET_PLATFORM = cc.Application:getInstance():getTargetPlatform()
	local _device_name = "android"
	local _os_name = "android"
	if _TARGET_PLATFORM == cc.PLATFORM_OS_IPAD then
		_device_name = "iPad"
		_os_name = "iOS"
	elseif _TARGET_PLATFORM == cc.PLATFORM_OS_IPHONE then
		_device_name = "iPhone"
		_os_name = "iOS"
	end

	local _title, _appKey, _defTb
	if GAME_CHANNEL == CHANNEL_CODE_APPSTORE then
		_appKey = "b807ad0bd3d348e2912108286cded3b7"
	    _defTb = {
			{"appid", "1040035662"},
			{"channel", tostring(GAME_CHANNEL)},
			{"device_name", _device_name},
			{"idfa", tostring(GAME_IDFA)},
			{"jailbreak", "0"},
			{"mac", tostring(GAME_MAC)},
			{"os_name", _os_name},
			{"os_version", tostring(GAME_OS_VERSION)},
			{"product", "xmgl"},
			{"ssid", ""},
		}
	else
		_appKey = "9a46527196dfd7345d57e4e6779785cc"
		_defTb = {
			{"android_id", tostring(GAME_ANDROIDID)},
			{"appid", "xmgl.android.iosjb"},
			{"channel", tostring(GAME_CHANNEL)},
			{"device_name", _device_name},
			{"idfa", tostring(GAME_IDFA)},
			{"jailbreak", "1"},
			{"mac", tostring(GAME_MAC)},
			{"os_name", _os_name},
			{"os_version", tostring(GAME_OS_VERSION)},
			{"product", "xmgl"},
			{"ssid", ""},
		}
	end
	if sType == ZCAD_SEND_TYPE.ACTIVE then
		if GAME_CHANNEL == CHANNEL_CODE_APPSTORE then
			_title = "http://ad.ucapi.zhanchenggame.com/index.php?c=iostrack"
		else
			_title = "http://ad.ucapi.zhanchenggame.com/index.php?c=android_track&m=active"
		end

	elseif sType == ZCAD_SEND_TYPE.REG then
		if GAME_CHANNEL == CHANNEL_CODE_APPSTORE then
			_title = "http://ad.ucapi.zhanchenggame.com/index.php?c=iostrack&m=reg"
		else
			_title = "http://ad.ucapi.zhanchenggame.com/index.php?c=android_track&m=reg"
		end
	elseif sType == ZCAD_SEND_TYPE.START then
		if GAME_CHANNEL == CHANNEL_CODE_APPSTORE then
			_title = "http://ad.ucapi.zhanchenggame.com/index.php?c=iostrack&m=start"
		else
			_title = "http://ad.ucapi.zhanchenggame.com/index.php?c=android_track&m=start"
		end
	elseif sType == ZCAD_SEND_TYPE.LEVEL then
		if GAME_CHANNEL == CHANNEL_CODE_APPSTORE then
			_title = "http://ad.ucapi.zhanchenggame.com/index.php?c=iostrack&m=level"
		else
			_title = "http://ad.ucapi.zhanchenggame.com/index.php?c=android_track&m=level"
		end
	elseif sType == ZCAD_SEND_TYPE.SEND then
		if GAME_CHANNEL == CHANNEL_CODE_APPSTORE then
			_title = "http://ad.ucapi.zhanchenggame.com/index.php?c=iostrack&m=pay"
		else
			_title = "http://ad.ucapi.zhanchenggame.com/index.php?c=android_track&m=pay"
		end
	end

	sendHttp(_title, _appKey, _defTb)
end


function XTHDADHttp.SendActive( )
	xpcall(function()
		XTHDADHttp.SendByType(ZCAD_SEND_TYPE.ACTIVE)
	end, function()

	end)
end
