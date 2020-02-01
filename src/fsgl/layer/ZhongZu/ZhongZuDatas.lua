--[[
authored by LITAO
种族的数据管理
]]
ZhongZuDatas = {}

ZhongZuDatas._localReward = nil -- 本地种族的奖励数据 
ZhongZuDatas._localWorship = nil --本地神兽祭拜数据 
ZhongZuDatas._localCity = nil --本地种族城市数据
ZhongZuDatas._localTask = nil --本地种族任务数据 
ZhongZuDatas._localTaskBarData = nil  --种族任务里的进度条数据 
ZhongZuDatas._localStore = nil --种族商店数据 
ZhongZuDatas._fightedTeamData = {} ------挑战的防守队伍数据 


ZhongZuDatas._serverBasic = nil ---服务器种族的基本数据 
ZhongZuDatas._serverSelfCity = nil ---服务器种族我方城镇的数据
ZhongZuDatas._serverEnemyCity = nil -- 服务器种族敌方城镇的数据 
ZhongZuDatas._serverSelfDefendTeam = nil --我在某个城市的所有防守队伍
ZhongZuDatas._serverExchanges = nil --种族商店里可兑换的数据
ZhongZuDatas._serverWorship = nil --种族神兽膜拜s

ZhongZuDatas._serverSelfCityDatas = nil -- 服务器自己城市的数据 
ZhongZuDatas._serverEnemyCityDatas = nil --服务器敌人城市的数据 
ZhongZuDatas._serverEnemyDatas = nil ----服务器可攻击敌人列表

ZhongZuDatas.__dayMaxForce = -1 ---种族里个人当天最大的势力点值 
ZhongZuDatas._selfTeams = {} 
ZhongZuDatas._selfTeamsAmount = 0 ----当前玩家自己的防守队伍数量

ZhongZuDatas._isCampWarStart = 0 ----种族战是否开启 0 未开启 1 已开启 -1 已结束 
ZhongZuDatas._warResult = -1 ----种族战结果，1 光明谷胜 2 暗月岭胜 0 平局 
ZhongZuDatas._ruinAmount = 0 ----种族战结束之后敌方城市被毁数量 
--------------------------------------------------------------------------------------------------------------------------------------------
----本地静态数据 
--------------------------------------------------------------------------------------------------------------------------------------------
function ZhongZuDatas.getLocalCampDatas( )
	if not ZhongZuDatas._localReward then 
		ZhongZuDatas._localReward = gameData.getDataFromCSV("RacialRewords")
	end 
	if not ZhongZuDatas._localWorship then 
		ZhongZuDatas._localWorship = gameData.getDataFromCSV("CampWorship")
	end 
	if not ZhongZuDatas._localCity then 
        ZhongZuDatas._localCity = gameData.getDataFromCSV("RacialCityList")
	end 
	if not ZhongZuDatas._localTask then 
		ZhongZuDatas._localTask = gameData.getDataFromCSV("RacialMission")
	end 
	if not ZhongZuDatas._localTaskBarData then 
		ZhongZuDatas._localTaskBarData = gameData.getDataFromCSV("RacialPointB")
	end 
	if not ZhongZuDatas._localStore then 
		ZhongZuDatas._localStore = gameData.getDataFromCSV("RaceStore")
	end 
end
---获得种族任务里的最大势力值
function ZhongZuDatas.getTaskMaxForce( )
	if ZhongZuDatas.__dayMaxForce < 0 then 
		local temp = {}
	    for i = 1,#ZhongZuDatas._localTaskBarData do 
	        temp[i] = tonumber(ZhongZuDatas._localTaskBarData[i].needPowerPoint)
	    end 
	    ZhongZuDatas.__dayMaxForce = math.max(unpack(temp))
	end 
    return ZhongZuDatas.__dayMaxForce >= 0 and ZhongZuDatas.__dayMaxForce or 0
end
--------------------------------------------------------------------------------------------------------------------------------------------
-----服务器数据 
--------------------------------------------------------------------------------------------------------------------------------------------
------设置势力点
function ZhongZuDatas.getSelfAllForce( )
    if ZhongZuDatas._serverBasic then 
        return ZhongZuDatas._serverBasic.totalForce or 0
    else 
        return 0
    end 
end

function ZhongZuDatas.setSelfAllForce(val)
    if ZhongZuDatas._serverBasic then 
        ZhongZuDatas._serverBasic.totalForce = val
    end 
end

function ZhongZuDatas.getSelfPerDayForce( )
    if ZhongZuDatas._serverBasic then 
        return ZhongZuDatas._serverBasic.dayAddForce or 0
    else 
        return 0
    end 
end

function ZhongZuDatas.setSelfPerDayForce( val )
    if ZhongZuDatas._serverBasic then
        ZhongZuDatas._serverBasic.dayAddForce = val
    end 
end
--[[
param = {
    method = 被请求的服务器方法
    params = 被请求的URL参数
    success = 请求成功后的回调
    failure = 请求失败后的回调    
}
]]
function ZhongZuDatas.requestServerData(param)
    local _type = HTTP_LOADING_TYPE.CIRCLE
    if param.noCircle then 
        _type = HTTP_LOADING_TYPE.NONE
    end     
    XTHDHttp:requestAsyncInGameWithParams({
        modules = param.method,
        params = param.params,
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                ZhongZuDatas.analysisResponse(data,param)
            else
                if param.method ~= "rivalCampCityList?" then 
                    XTHDTOAST(data["msg"])
                end 
                if data.result == 4808 then ---种族战即将开启
                    ZhongZuDatas._isCampWarStart = 0
                end 
                if param.failure then 
                    param.failure(data)
                end 
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            if param.failure then 
                param.failure(nil)
            end 
        end,--失败回调
        loadingParent = param.target,
        loadingType = _type,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ZhongZuDatas.analysisResponse( data,customParam )
    if customParam.method == "campBase?" then 
        ZhongZuDatas._serverBasic = data
        ZhongZuDatas._aForce = data.aForce
        ZhongZuDatas._bForce = data.bForce
        ZhongZuDatas._isCampWarStart = tonumber(data.openState)
        if customParam.success then 
            customParam.success()
        end 
    elseif customParam.method == "selfCampCityList?" then 
        table.sort(data.citys,function( a,b )
            return tonumber(a.cityId) < tonumber(b.cityId)
        end)
        ZhongZuDatas._serverSelfCity = data
        if customParam.success then 
            customParam.success()
        end 
    elseif customParam.method == "rivalCampCityList?" then
        table.sort(data.citys,function( a,b )
            return tonumber(a.cityId) < tonumber(b.cityId)
        end)
        ZhongZuDatas._serverEnemyCity = data
        if customParam.success then 
            customParam.success()
        end 
    elseif customParam.method == "searchMyDefendGroup?" then        
        if data and data.teams then 
            table.sort( data.teams, function( a,b )
                if tonumber(a.cityId) == tonumber(b.cityId) then 
                    return tonumber(a.teams[1].teamId) < tonumber(b.teams[1].teamId)
                else 
                    return tonumber(a.cityId) < tonumber(b.cityId)
                end 
            end)
            -----------整合自己的防守队伍,如果cityid为0
            local i = 0
            ZhongZuDatas._selfTeams = {}            
            for k,v in pairs(data.teams) do
                i = i + 1
                local cityID = tonumber(v.cityId)
                if not ZhongZuDatas._selfTeams[cityID] then 
                    ZhongZuDatas._selfTeams[cityID] = {}
                    ZhongZuDatas._selfTeams[cityID][1] = v
                else 
                    local _len = #ZhongZuDatas._selfTeams[cityID]
                    ZhongZuDatas._selfTeams[cityID][_len + 1] = v
                end 
            end 
            ZhongZuDatas._selfTeamsAmount = i
        end 
        ZhongZuDatas._serverSelfDefendTeam = data
        if customParam.success then 
            customParam.success()
        end 
    elseif customParam.method == "campSelfCity?" then
        ZhongZuDatas._serverSelfCityDatas = data
        if customParam.success then 
            customParam.success()
        end 
    elseif customParam.method == "campRivalCity?" then
        ZhongZuDatas._serverEnemyCityDatas = data
        if customParam.success then 
            customParam.success(data)
        end 
    elseif customParam.method == "changeRival?" then
        ZhongZuDatas._serverEnemyDatas = data
        if customParam.success then 
            customParam.success()
        end 
    elseif customParam.method == "worshipList?" then
        ZhongZuDatas._serverWorship = data
        if customParam.success then 
            customParam.success()
        end 
    elseif customParam.method == "clearCampCd?" then
        if customParam.success then 
            customParam.success(data)
        end 
    elseif customParam.method == "forceWeekReward?" then
        if customParam.success then 
            customParam.success(data)
        end 
    elseif customParam.method == "forceDayReward?" then
        if customParam.success then 
            customParam.success(data)
        end 
    elseif customParam.method == "campExchangeList?" then
        ZhongZuDatas._serverExchanges = data 
        if customParam.success then 
            customParam.success()
        end 
    elseif customParam.method == "campExchange?" then
        if customParam.success then 
            customParam.success(data)
        end 
    elseif customParam.method == "worship?" then 
        if customParam.success then 
            customParam.success(data)
        end 
    elseif customParam.method == "setCampGroup?" then 
        if customParam.success then 
            customParam.success()
        end 
    elseif customParam.method == "hurtRank?" then 
        if customParam.success then 
            customParam.success(data)
        end 
    end 
end
--------------------------------------------------------------------------------------------------------------------------------------------

function ZhongZuDatas.reset( )
    ZhongZuDatas._localReward = nil -- 本地种族的奖励数据 
    ZhongZuDatas._localWorship = nil --本地神兽祭拜数据 
    ZhongZuDatas._localCity = nil --本地种族城市数据
    ZhongZuDatas._localTask = nil --本地种族任务数据 
    ZhongZuDatas._localTaskBarData = nil  --种族任务里的进度条数据 
    ZhongZuDatas._localStore = nil --种族商店数据 
    ZhongZuDatas._serverBasic = nil ---服务器种族的基本数据
    ZhongZuDatas._serverSelfCity = nil ---服务器种族我方城镇的数据
    ZhongZuDatas._serverEnemyCity = nil -- 服务器种族敌方城镇的数据 
    ZhongZuDatas._serverSelfDefendTeam = nil --我在某个城市的所有防守队伍
    ZhongZuDatas._serverExchanges = nil --种族商店里可兑换的数据
    ZhongZuDatas._serverSelfCityDatas = nil -- 服务器自己城市的数据 
    ZhongZuDatas._serverEnemyCityDatas = nil --服务器敌人城市的数据 
    ZhongZuDatas._serverEnemyDatas = nil ----服务器可攻击敌人列表
    ZhongZuDatas.__dayMaxForce = -1 ---种族里个人当天最大的势力点值 
    ZhongZuDatas._serverWorship = nil --种族神兽膜拜s
    ZhongZuDatas._selfTeamsAmount = 0 ----当前玩家自己的防守队伍数量
    ZhongZuDatas._fightedTeamData = {}
    ZhongZuDatas._selfTeams = {}
end
-----存储当前玩家挑战的防守队伍信息（）
function ZhongZuDatas:setFightTeamDatas( data )
    ZhongZuDatas._fightedTeamData = data
end
------在挑战防守队伍胜利之后，进入重新指定队伍页面
function ZhongZuDatas:enterReassignTeamLayer(parent)
    if parent then 
        local layer = requires("src/fsgl/layer/ZhongZu/forTheHost/ZhongZuReassignForHost.lua"):create(
            ZhongZuDatas._fightedTeamData.cityId,
            ZhongZuDatas._fightedTeamData.cityLevel
        )
        -- dump(ZhongZuDatas._fightedTeamData)
        parent:addChild(layer,10)
        ZhongZuDatas._fightedTeamData = {}
    end 
end
-----创建种族里独特的人物头像
function ZhongZuDatas:createCampHeroIcon( id,level,levelFactor)    
    local node = cc.Node:create()
    if id then 
        local icon = XTHD.createSprite(XTHD.resource.getHeroAvatorImgById(id))
        node:setContentSize(icon:getContentSize())
        node:addChild(icon) 
        icon:setPosition(node:getContentSize().width / 2,node:getContentSize().height / 2)

        -- local border = cc.Sprite:create("res/image/plugin/competitive_layer/hero_board.png")
        local border = XTHD.createSprite(XTHD.resource.getQualityItemBgPath(true))
        node:addChild(border)
        border:setPosition(icon:getPositionX(),icon:getPositionY())
        if level then 
            local level = cc.Label:createWithBMFont("res/fonts/pvpshuzi.fnt",level)
            local level_bg = cc.Sprite:createWithTexture(nil,cc.rect(0,0,level:getBoundingBox().width + 6,20))
            level_bg:setColor(cc.c3b(0,0,0))
            level_bg:setOpacity(0)
            level_bg:setAnchorPoint(0,0)
            level_bg:setPosition(0,10)
            if levelFactor then 
                level_bg:setScale(levelFactor)
            end 
            node:addChild(level_bg)

            level_bg:addChild(level)
            level:setAnchorPoint(0,0)
            level:setPosition(3,0 - 12)
            level:setAdditionalKerning(-2)
        end 
    end 
    return node
end

function ZhongZuDatas:isCampWarStart( ) ---是否种族战已经开始
    if ZhongZuDatas._isCampWarStart == 1 then 
        return true
    else 
        return ZhongZuDatas._isCampWarStart
    end 
end
-----种族战结束的倒计时
function ZhongZuDatas:getWarOverCountDown(target,CDTag,frameCall)
    if target and ZhongZuDatas._serverEnemyCityDatas and ZhongZuDatas._serverEnemyCityDatas.campDiffTime then 
        local _data = ZhongZuDatas._serverEnemyCityDatas.campDiffTime
        local _time = getCdStringWithNumber(_data,{m = LANGUAGE_UNKNOWN.minute,s = LANGUAGE_UNKNOWN.second,h = LANGUAGE_UNKNOWN.hour})
        target:setString(_time)
        if frameCall then 
            frameCall()
        end 
        if not target:getActionByTag(CDTag) then 
            schedule(target,function ( )
                ZhongZuDatas._serverEnemyCityDatas.campDiffTime = ZhongZuDatas._serverEnemyCityDatas.campDiffTime - 1         
                if ZhongZuDatas._serverEnemyCityDatas.campDiffTime < 1 then 
                    target:stopActionByTag(CDTag)
                else 
                    _data = ZhongZuDatas._serverEnemyCityDatas.campDiffTime
                    local str = getCdStringWithNumber(_data,{m = LANGUAGE_UNKNOWN.minute,s = LANGUAGE_UNKNOWN.second,h = LANGUAGE_UNKNOWN.hour})
                    target:setString(str)
                    if frameCall then 
                        frameCall()
                    end 
                end 
            end,1.0,CDTag)
        end 
    end 
end

function ZhongZuDatas:setCampWarLatestResult(result)
    ZhongZuDatas._warResult = result
    if result ~= gameUser._campID then ----敌方胜
        ZhongZuDatas._ruinAmount = math.random(2,4)
    elseif result == gameUser._campID then ----己方胜 
        ZhongZuDatas._ruinAmount = 5
    end 
end
------建筑当前等级的种族建筑的属性值 返回当前等级的值、下一级的值
function ZhongZuDatas:getCityPropByLevel(level,cityID)
    local result = {}
    local data = ZhongZuDatas._localCity[cityID]
    
    if data then 
        local initProp = string.split(data.starteffect,"#")
        local added = string.split(data.upadd,"#")
        local propName = string.split(data.cityeffect,"#")
        local maxLevel = data.maxlv

        -- 2019/04/13 去除第五条守军每天获得6点荣誉值
        for i = 1,4 do 
            if level < maxLevel then 
                result[i] = {
                    propID = tonumber(propName[i]),
                    propCur = tonumber(initProp[i]) + (level - 1) * tonumber(added[i]),
                    propNext = tonumber(initProp[i]) + level * tonumber(added[i]),
                }
            else 
                result[i] = {
                    propID = tonumber(propName[i]),
                    propCur = tonumber(initProp[i]) + (level - 1) * tonumber(added[i]),
                }
            end 
        end 
    end 
    return result
end