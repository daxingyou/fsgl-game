--[[*******************************************
                Http网络请求基类
**********************************************]]
XTHDHttp = class("XTHDHttp");

HTTP_OPEN_ENCRYPT = true
HTTP_VALID = "1"

-- 加载中显示图标
HTTP_LOADING_TYPE = {
    CIRCLE = 0,
    HEAD = 1,
    NONE = 2,
	ANIM = 3,   -- 战斗动画加载
}

-- 请求的方式，默认GET
HTTP_REQUEST_TYPE = {
    GET = 0,
    POST = 1
}

-- 加密方式
HTTP_ENCRYPT_TYPE = {
    AES = "aes",
    NONE = "none"
}

-- 创建http
function XTHDHttp:create()
    local http = XTHDHttp.new()
    return http;
end

function XTHDHttp:requestAsyncWithParams(params)
    local http = XTHDHttp:create();
    params.encrypt = params.encrypt == nil and HTTP_ENCRYPT_TYPE.NONE or params.encrypt
    http:_requestAsyncWithParams(params,false);
end

function XTHDHttp:_requestAsyncWithParams(params,isGame)
    --[[ 请求的网络地址(完整地址) ]]
    local url = params.url
    local index=string.find(url,"http")
    if index~=1 then
        url="http://"..url
    end

    --[[ 请求的方式 ]]
    local method = HTTP_REQUEST_TYPE.GET--params.method
    --[[ 开始请求时的回调函数 ]]
    local startCallback = params.startCallback
    --[[ 请求成功的回调函数 ]]
    local successCallback = params.successCallback
    --[[ 请求失败的回调函数(此处的失败一般是指网络超时或者服务器返回的数据无法解析成json) ]]
    local failedCallback = params.failedCallback
    --[[ 请求时需要被retain的对象 ]]
    local targetNeedsToRetain = params.targetNeedsToRetain
    --[[ post请求时需要的数据 ]]
    local postData = params.postData
    local loadingType = params.loadingType
    local loadingNode = params.loadingNode
    local loadingParent = params.loadingParent
    local reconnectTimes = params.reconnectTimes
    --[[ 如果网络失败，重新连接的次数(0或nil代表不需要重试) ]]
    local timeoutForRead = params.timeoutForRead
    local timeoutForConnect = params.timeoutForConnect
    self.encrypt = params.encrypt

    if not loadingType then loadingType = HTTP_LOADING_TYPE.CIRCLE end
    if not method then method = HTTP_REQUEST_TYPE.GET end
    if not reconnectTimes then reconnectTimes = 0 end
    if not timeoutForRead then timeoutForRead = 10 end
    if not timeoutForConnect then timeoutForConnect = 10 end
    if not self.encrypt then self.encrypt = HTTP_ENCRYPT_TYPE.AES end

    local _loadingNode = loadingNode
    -- 加载loading层
    if _loadingNode == nil then
        if loadingType == HTTP_LOADING_TYPE.CIRCLE then
            _loadingNode = DengLuCircleLayer:create(0)
        elseif loadingType == HTTP_LOADING_TYPE.HEAD then
            _loadingNode = DengLuCircleLayer:create(0)
        elseif loadingType == HTTP_LOADING_TYPE.NONE then
            _loadingNode = nil
        end
    end
    if _loadingNode ~= nil then
        local _loadingParent = loadingParent
        if _loadingParent == nil then
            _loadingParent = cc.Director:getInstance():getRunningScene()
        end
        _loadingParent:addChild(_loadingNode, 10000)
    end

    local request = cc.XMLHttpRequest:new();
    -- response回调函数
    local function responseCallBack()
        if _loadingNode and _loadingNode:getParent() then
            _loadingNode:removeFromParent()
        end
        if request.readyState == 4 and(request.status >= 200 and request.status <= 300) then
            if successCallback and request.response then
                local str = request.response;
                if not string.find(str, "{") then
                    str = iBaseCrypto:decodeBase64Lua(str);
                end
                cclog(url .. " data[" .. str .. "]");
                local data = json.decode(str);
                successCallback(data);
				 if tonumber(data.result) == 1009 then ----如果掉线，重新登录
                   print("*****CTX_log:掉线，重新登录*****")
                   showBadWebDialog()
			    end 
            end
        else           
            if failedCallback then
                failedCallback();
            end
        end
    end
    -- 设置返回值类型及回调函数
    request.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING;
    request:registerScriptHandler(responseCallBack);
	print("请求的连接为："..url)
    request.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING;
    request:registerScriptHandler(responseCallBack);
    if method == HTTP_REQUEST_TYPE.GET then
        request:open("GET", url);
        request:send();
    elseif method == HTTP_REQUEST_TYPE.POST then
        request:open("POST", url);
        request:send(postData);
    end
end

----------------------------新封装-----------------------------
function XTHDHttp:requestAsyncInGameWithParams(_params_)
    local modules = _params_.modules
    local _params = _params_.params
    _params_.method = HTTP_REQUEST_TYPE.GET
    local method = _params_.method
	_params_.loadingType = HTTP_LOADING_TYPE.ANIM
    --[[ 请求的方式 ]]

    local http = XTHDHttp:create();
    if modules == nil then
        modules = ""
    end

	print("当前请求的uuid："..gameUser.getUUID())

    -- 添加默认公共字段
    local _defultInfo = {
        mUserId = gameUser.getUserId(),
        uuid = gameUser.getUUID(),
        channel = GAME_CHANNEL,
        time = os.clock(),
        valid = tostring(HTTP_VALID),
    }
    if _params == nil or type(_params) ~= "table" then
        _params = { }
    end
    for k, v in pairs(_defultInfo) do
        if _params[k] == nil then
            _params[k] = v
        end
    end

    if method == HTTP_REQUEST_TYPE.POST then
        _params_.url = GAME_API .. modules
        _params_.postData = http:getTrueUrl(_params, _params_.encrypt)
    else
        _params_.url = GAME_API .. modules .. http:getTrueUrl(_params, _params_.encrypt)
    end

    http:_requestAsyncWithParams(_params_,true)
end

-- 根据table数组，及加密条件，获取真实发送的modules？后面的内容
function XTHDHttp:getTrueUrl(params, encrypt)
    local _encryptInfo = { }
    -- 存储整理归纳后的字段信息

    if params ~= nil and type(params) == "table" and next(params) ~= nil then
        -- 是table的整理字段信息内容
        -- 整理字段信息，有重复的就自动覆盖
        for key, value in pairs(params) do
            local _haveKey = nil
            for k, v in pairs(_encryptInfo) do
                if v[1] == key then
                    _haveKey = k
                    break
                end
            end
            if _haveKey then
                _encryptInfo[_haveKey] = { key, value }
            else
                _encryptInfo[#_encryptInfo + 1] = { key, value }
            end
        end
    else
        -- 否则直接反馈空信息
        return ""
    end
    -- value根据key排序
    table.sort(_encryptInfo, function(a, b)
        return a[1] < b[1]
    end )

    local _url = ""
    -- 存储实际有用的字段内容拼接
    for i, v in ipairs(_encryptInfo) do
        -- 拼接url里？后边的内容
        if i == 1 then
            _url = v[1] .. "=" .. v[2]
        else
            _url = _url .. "&" .. v[1] .. "=" .. v[2]
        end
    end
    if IS_NEI_TEST then
        print("wm----before_encrypt : " .. _url)
    end

    local _encrypt = encrypt == nil and HTTP_ENCRYPT_TYPE.AES or encrypt
    if HTTP_OPEN_ENCRYPT and _encrypt == HTTP_ENCRYPT_TYPE.AES then
        -- 需要加密
        -- 整合要实际发送的信息
        local _valueTable = { }
        -- 存储实value的md5加密内容
        -- 拼接url里？后边的内容
        for i, v in ipairs(_encryptInfo) do
            _valueTable[#_valueTable + 1] = v[2]
        end
        local _valueTable = table.concat(_valueTable, '|') or ""
        -- 拼接value内容
        _valueTable = iBaseCrypto:MD5Lua(_valueTable, false)
        -- md5加密value内容
        _url = iBaseCrypto:encodeBase64Lua(_url, #_url)
        -- url内容base64加密
        _url = _url .. "&isEncrypt=true&encryptTitle=" .. _valueTable
        -- 拼接？后面的发送内容
        if IS_NEI_TEST then
            print("wm----after_encrypt : " .. _url)
        end
    end
    return _url
end

function XTHDHttp:sendErrorMsg(_url,data,callback)
--	print("错误日志上报url：".._url.."uid="..data.uid.."&msg="..string.urlencode(data.msg))
    XTHDHttp:requestAsyncWithParams({
        url = _url.."uid="..data.uid.."&msg="..string.urlencode(data.msg),
        targetNeedsToRetain = nil,--需要保存引用的目标
        successCallback = function(data)
            callback()
        end,--成功回调
        failedCallback = function()
			print("错误日志上报失败！")
--            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end,--失败回调
    }) 
end

return XTHDHttp;
