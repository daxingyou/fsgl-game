-- FileName: HaoYouPublic.lua
-- Author: wangming
-- Date: 2015-09-11
-- Purpose: 好友工具封装
--[[TODO List]]

HaoYouPublic = {}

-- type : 1 好友请求， 2 好友送花， 3 好友切磋, 4 镖车被截, 5 多人副本邀请
FriendMsgType = {
    ADD_FRIEND = 1,
    SEND_FLOWER = 2,
    FIGHT_FRIEND = 3,
    ESCORT_FIGHT = 4,
    MULTIPLE_INVITE = 5,
    CASTELLANFIGHT = 6,
}

local _friendData
local _data
local _friendMsgs
local _talkMsgs
local _talkNewsFlag
local _haveNews = false
local _haveMsgs = false
local _idCount = 1

function HaoYouPublic.cleanData( ... )
    _friendData = nil
	_data = nil
    _friendMsgs = nil
    _talkMsgs = nil
    _talkNewsFlag = nil
    _haveNews = false
    _haveMsgs = false
    _idCount = 1
end

function HaoYouPublic.dataSort( d1, d2 )
    if d1.onLine ~= d2.onLine then
        return d1.onLine
    end
    if d1.level ~= d2.level then
        return d1.level > d2.level
    end
    if d1.charId ~= d2.charId then
        return d1.charId < d2.charId
    end
end

function HaoYouPublic.freshData( sData )
	_friendData = sData or {}
    _data = _friendData.list or {}
    _friendData.raceCount = _friendData.raceCount or 0

    table.sort(_data, HaoYouPublic.dataSort)
end

function HaoYouPublic.getFriendData( ... )
    return _friendData
end

function HaoYouPublic.getRaceTime( ... )
    if not _friendData then
        _friendData = {}
    end
    return _friendData.raceCount or 0
end

function HaoYouPublic.setRaceTime( num )
    if not _friendData then
        _friendData = {}
    end
    _friendData.raceCount = num
end

function HaoYouPublic.updateFlowersById( sCharId, num )
    for k,v in pairs(HaoYouPublic.getData()) do
        if v.charId == sCharId then
            v.flower = num
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FRIEND_LIST, data = {charTag = tonumber(k)}})
            break
        end
    end
end

function HaoYouPublic.getData( )
    if not _data then
        _data = {}
    end
	return _data
end

function HaoYouPublic.getDataByCharId( charId )
    for k,v in pairs(HaoYouPublic.getData()) do
        if v.charId == charId then
            return v
        end
    end
end

function HaoYouPublic.addData( sData )
    HaoYouPublic.getData()
    HaoYouPublic.removeData(sData, true) 
	table.insert(_data, sData)
    table.sort(_data, HaoYouPublic.dataSort)
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FRIEND_LIST})
end

function HaoYouPublic.removeDataById( id, notSend )
    local isHave = nil
    for k,v in pairs(HaoYouPublic.getData()) do
        if v.charId == id then
            isHave = k
            break
        end
    end
    if isHave then
        table.remove(_data, isHave)
        table.sort(_data, HaoYouPublic.dataSort)
        if not notSend then
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FRIEND_LIST})
        end
    end
end

function HaoYouPublic.removeData( sData, notSend )
	HaoYouPublic.removeDataById(sData.charId, notSend)
end

function HaoYouPublic.freshFriendOnline( charId, isOnLine )
    for k,v in pairs(HaoYouPublic.getData()) do
        if v.charId == charId then
            v.onLine = isOnLine
            table.sort(_data, HaoYouPublic.dataSort)
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FRIEND_LIST})
            break
        end
    end
end

-- type : 1 好友请求， 2 好友送花， 3 好友切磋, 4 镖车被截, 5 多人副本邀请
function HaoYouPublic.addNewMsgs( tb )
    if not _friendMsgs then
        _friendMsgs = {}
    end
    -- dump(tb, "addNewMsgs")
    if tb.sMsgType == 1 then
        for k,v in pairs(_friendMsgs) do
            if v.charId == tb.charId and v.sMsgType == 1 then
                return
            end
        end
    end
    tb.sMsgId = _idCount
    _idCount = _idCount + 1
    table.insert( _friendMsgs, tb )
    HaoYouPublic.setNews(true)
end

-- type : 1 好友请求， 2 好友送花， 3 好友切磋
function HaoYouPublic.removeNewMsgs( data )
    if not _friendMsgs then
        _friendMsgs = {}
    end
    for k,v in pairs(_friendMsgs) do
        if v.sMsgId == data.sMsgId then
            table.remove(_friendMsgs, k)
            return
        end
    end
end

function HaoYouPublic.removeAllNewMsgs( )
    _friendMsgs = {}
    HaoYouPublic.setNews(false)
    _idCount = 1
end

function HaoYouPublic.getNewMsgs( )
    return _friendMsgs or {}
end

function HaoYouPublic.haveNews( )
    return _haveNews
end

function HaoYouPublic.setNews( sBool )
    _haveNews = sBool
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT, data = {name = "newsMsg", visible = _haveNews}})
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FRIEND_NEWMSG})
end

function HaoYouPublic.addTalkMsg( msg, selfTalk)
    if not _talkMsgs then
        _talkMsgs = {}
    end
    table.insert(_talkMsgs, 1, msg)
    local pId = msg.senderID
    if msg.senderID == gameUser.getUserId() then
        pId = msg.reciverID
    else
        HaoYouPublic.freshTalkNewsFlag(pId, true)
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FRIEND_TALKLIST,data = {charId = pId}})
    if not selfTalk then
        HaoYouPublic.setMsgs(true)
    end
end

function HaoYouPublic.getTalkMsgByCharId( charId )
    if not _talkMsgs then
        _talkMsgs = {}
    end
    
    local pTb = {}
    for i=1, #_talkMsgs do
        local v = _talkMsgs[i]
        if v.senderID == charId or v.reciverID == charId then
            table.insert(pTb, v)
        end
    end
    return pTb
end

function HaoYouPublic.freshTalkNewsFlag( sId, sFlag, notFreshList )
    local _id = tonumber(sId) or 0
    if not _talkNewsFlag then
        _talkNewsFlag = {}
    end
    if sFlag then
        if not _talkNewsFlag[_id] then
            _talkNewsFlag[_id] = 0
        end
        _talkNewsFlag[_id] = _talkNewsFlag[_id] + 1
    else
        _talkNewsFlag[_id] = 0
    end
    _talkNewsFlag[_id] = _talkNewsFlag[_id] > 99 and 99 or _talkNewsFlag[_id]
    if not notFreshList then
        for k,v in pairs(HaoYouPublic.getData()) do
            if v.charId == _id then
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FRIEND_LIST, data = {charTag = tonumber(k)}})
                break
            end
        end
    end
end

function HaoYouPublic.getTalkNewsFlag( sId )
    local _id = tonumber(sId) or 0
    if not _talkNewsFlag then
        _talkNewsFlag = {}
    end
    local pNum = tonumber(_talkNewsFlag[_id]) or 0
    return pNum
end

function HaoYouPublic.getTalkMsgs( ... )
    return _talkMsgs or {}
end

function HaoYouPublic.haveMsgs( ... )
    return _haveMsgs
end

function HaoYouPublic.setMsgs( sBool )
    _haveMsgs = sBool
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT, data = {name = "friend", visible = _haveMsgs}})
   
end

---------------------------function---------------


function HaoYouPublic.isFriend( charId )
	local pDatas = HaoYouPublic.getData()
	for k,v in pairs(pDatas) do
		if v.charId == charId then
			return true
		end
	end
	return false
end

function HaoYouPublic.getCampStr( campID )
	local _campID = tonumber(campID) or 1
	if _campID == 1 then
		return LANGUAGE_CAMP_NAME1
	else
		return LANGUAGE_CAMP_NAME2
	end
end

function HaoYouPublic.getTimeStr( msgTime )
	local _msgTime = tostring(msgTime)
	local time = tonumber(string.sub(_msgTime, 1, #_msgTime - 3)) or 0
    local past = tonumber(os.time()) - time
    local _now = math.modf(tonumber(os.time())/(3600*24))
    _msgTime = math.modf(time/(3600*24))
    -- past = past / 3600
    if _now - _msgTime >= 7 then 
        time = LANGUAGE_CHAT_TIME7
    elseif _now - _msgTime >= 6 then
        time = LANGUAGE_CHAT_TIME6
    elseif _now - _msgTime >= 5 then
        time = LANGUAGE_CHAT_TIME5
    elseif _now - _msgTime >= 4 then
        time = LANGUAGE_CHAT_TIME4
    elseif _now - _msgTime >= 3 then
        time = LANGUAGE_CHAT_TIME3
    elseif _now - _msgTime >= 2 then
        time = LANGUAGE_CHAT_TIME2
    elseif _now - _msgTime >= 1 then
        time = LANGUAGE_CHAT_TIME1
    else
    	time = os.date("%H:%M",tonumber(time))
    end

    -- elseif past > 24 and past < 48 then --昨天
    -- 	time = LANGUAGE_CHAT_TIME1
    -- elseif past > 48 and past < 72 then --两天
    -- 	time = LANGUAGE_CHAT_TIME2
    -- elseif past > 72 and past < 96 then --三天
    -- 	time = LANGUAGE_CHAT_TIME3
    -- elseif past > 96 and past < 120 then --四天
    -- 	time = LANGUAGE_CHAT_TIME4
    -- elseif past > 120 and past < 144 then --五天
    -- 	time = LANGUAGE_CHAT_TIME5
    -- elseif past > 144 and past < 168 then --六天
    -- 	time = LANGUAGE_CHAT_TIME6
    -- elseif past > 168 then --一周前
    -- 	time = LANGUAGE_CHAT_TIME7
    -- end
    return time
end

-- 创建好友头像
--[[
    params :
    iconID 头像ID
    campID 种族ID， 无则不显示
    level 等级， 无则不显示
    callFn 点击回调 无则不可点击
]]--
local function createFriendIcon( sParams )
    local params = sParams or {}
    local iconID = params.iconID
    local campID = params.campID
    local level = params.level
    local callFn = params.callFn
    local gray = params.gray
    if not iconID or iconID == 0 then 
        iconID = 1
    end 
    local _canTouch = callFn and true or false

    local _normalNode = XTHD.createSprite(XTHD.resource.getHeroAvatorImgById(iconID))
    local _selectedNode = XTHD.createSprite(XTHD.resource.getHeroAvatorImgById(iconID))
    if gray then
        XTHD.setGray(_normalNode, true)
        XTHD.setGray(_selectedNode, true)
    end
    local icon = XTHDPushButton:createWithParams({
        normalNode = _normalNode,
        selectedNode = _selectedNode,
        musicFile = XTHD.resource.music.effect_btn_common,
        needSwallow = false,
        enable = _canTouch,
        endCallback = function ()
            if callFn then
                callFn()
            end
        end,
    })
    local iconBox = cc.Sprite:create("res/image/plugin/competitive_layer/hero_board1.png")
    if campID then
        iconBox = cc.Sprite:create("res/image/plugin/competitive_layer/hero_board" .. campID .. ".png")
    end
    if iconBox and icon then
        icon:addChild(iconBox,-1)
        iconBox:setPosition(icon:getBoundingBox().width*0.5,icon:getBoundingBox().height*0.5)
        icon:setScale(0.75)
        if gray then
            XTHD.setGray(iconBox, true)
        end
        -----level 
       

        ------camp
        if campID then
            -- local _campBox = cc.Sprite:create("res/image/homecity/city_player_levelBox.png")
            -- if _campBox then 
            --     if gray then
            --         XTHD.setGray(_campBox, true)
            --     end
            --     iconBox:addChild(_campBox)
            --     _campBox:setPosition(iconBox:getBoundingBox().width - _campBox:getContentSize().width*0.5 + 5,_campBox:getContentSize().height / 2 - 3)
            --     --camp icon 
                local campIcon = cc.Sprite:create("res/image/homecity/camp_icon"..campID..".png")
                if campIcon then 
                    if gray then
                        XTHD.setGray(campIcon, true)
                    end
                    icon:addChild(campIcon)
                    campIcon:setPosition(icon:getContentSize().width ,10)              
                end 
            -- end 
        end
        
        if level then
            local _level = getCommonWhiteBMFontLabel(level)
            if _level then 
                icon:addChild(_level)
                _level:setAnchorPoint(0,0.5)
                _level:setPosition(5, _level:getBoundingBox().height*0.5 - 10)
                if gray then
                    XTHD.setGray(_level, true)
                end
            end 
        end

       
    end
    -- local select_box = cc.Sprite:create("res/image/common/item_select_box.png")
    -- select_box:setPosition(icon:getBoundingBox().width*0.5, icon:getBoundingBox().height*0.5)
    -- select_box:setName("select_box")
    -- icon:addChild(select_box,3) 
    -- select_box:setVisible(false)
    -- icon.select_box = select_box
    return icon
end

function HaoYouPublic.getFriendIcon( sData, sParams )
	local pData = sData or {}
	local _iconData = pData.templateId or 1
	local params = sParams or {}
	local _notShowLv = params.notShowLv
	local _notShowCamp = params.notShowCamp
	local _callFn = params.callFn
    local _checkOnline = params.isCheckOnline

    local pB = false
    if _checkOnline then
        pB = not pData.onLine
    end

	local pD = {iconID = _iconData}
	pD.callFn = _callFn
    pD.gray = pB
	if not _notShowLv then
		pD.level = pData.level or 1
	end
	if not _notShowCamp then
		pD.campID = pData.campId or 1
	end
	local icon = createFriendIcon(pD)
	return icon
end

function HaoYouPublic.showFirendInfo( charId, par, sZorder )
    local string = tostring(charId)
    XTHDHttp:requestAsyncInGameWithParams({
        modules = "findPlayer?",
        params = {charName = string},
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                local sdata = data.list or {}
                local pData = sdata[1]
                if pData then
                    local _isFriend = HaoYouPublic.isFriend(pData.charId)
                    local pScene = cc.Director:getInstance():getNotificationNode()
                    requires("src/fsgl/layer/HaoYou/HaoYouInfoPop.lua"):create(pScene, {data = pData, isFriend = _isFriend, zorder = sZorder})
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
        end,--失败回调
        targetNeedsToRetain = par,--需要保存引用的目标
        loadingParent = par,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function HaoYouPublic.httpGetFriendData( parNode, callBack )
    if not parNode then
        return
    end
    XTHDHttp:requestAsyncInGameWithParams({
        modules="friendList?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                HaoYouPublic.freshData(data)
                if callBack then
                    callBack(data)
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
        end,--失败回调
        targetNeedsToRetain = parNode,--需要保存引用的目标
        loadingParent = parNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function HaoYouPublic.httpLookFriendInfo( parNode, _id, callBack )
    if not parNode then
        return
    end
    XTHDHttp:requestAsyncInGameWithParams({
        modules="lookOtherPlayer?",
         params  = {otherCharId = _id},
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                if callBack then
                    callBack(data)
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
        end,--失败回调
        targetNeedsToRetain = parNode,--需要保存引用的目标
        loadingParent = parNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end
