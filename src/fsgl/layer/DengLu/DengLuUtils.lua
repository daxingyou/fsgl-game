--create by hezhitao 2015.06.17


DengLuUtils = {}

function DengLuUtils.doNewLogin( node,relogin,isCreateRole)
    local __node__ = node
    local function _doLogin( )
        local userDefault = cc.UserDefault:getInstance()
        local lastServer = userDefault:getStringForKey(KEY_NAME_LAST_SERVER)
        lastServer = loadstring(lastServer)
        if type(lastServer) == "function" then
            lastServer = lastServer()
        else
            lastServer = checktable(lastServer)
        end

        local serverName    = lastServer.serverName
        local serverIp      = lastServer.serverIp
        local serverPort    = lastServer.serverPort
        local openState     = lastServer.openState
        local crowdState    = lastServer.crowdState
        local newState      = lastServer.newState
        local serverId      = lastServer.serverId
        local serverIp      = lastServer.serverIp

        local loadingNode = requires("src/fsgl/layer/DengLuBeiJing/SwitchSceneLayer1.lua"):create({showLogo = true})
        node:addChild(loadingNode)
        loadingNode:setName("TEMP")
        local time = os.clock()            
        local hasPermanentCampID = false
        --[[登录游戏服务器，如果成功，就进入选种族的页面]]
        XTHDHttp:requestAsyncWithParams({
            url = serverIp..":"..serverPort.."/game/newLogin?token="..gameUser.getNewLoginToken() .. "&serverId=" .. serverId,
            startCallback = function()
            end,
            -- print("@@@@@@@:" .. serverId),
            successCallback = function(data)
                print("登录服务器返回的数据：")
                print_r(data)
                --[[重新赋值]]
                GAME_API = serverIp..":"..serverPort.."/game/"                
                local diff  = os.clock() - time
                local delay = 0
                if diff < 2 then
                   delay = 2     
                end
                if data.result == 0 or data.result == 1004 then 
                    if data.result == 0 then
                        ----------------------------------------------------------------------------------------------------------------
                        ---在这里清除游戏里需要清除的全局数据
                        LiaoTianDatas.reset()
                        gameUser.setSocketIP(0)
                        gameUser.setSocketPort(0)
                        gameUser.setRecoveryState(data["recoveryState"])
                        gameUser.setGragraduationState(data["gragraduation"])
						gameUser.setLeijidengluState(data["createLoginReward"])
						gameUser.setThreeTimePayId(data["threeTimePayId"])
						gameUser.setThreeTimePayList(data["threeTimePayList"])
						gameUser.setFirstLayerState(data["fristWindow"])
						gameUser.setFinishThreePayRewardList(data["finishThreePayRewardList"])
						gameUser.setGrowthFund(data["growthFund"])
						gameUser.setFlower(data["flower"])
						gameUser.setMonthState(data["monthWindow"])
                        gameUser.setMeiRiQianDaoState(data["dayCheckinWindow"])
						gameUser.setSex(data["sex"])
						gameUser.setCurTitle(data["curTitle"])
                        resetDBDatas()
                        ----------------------------------------------------------------------------------------------------------------
                        --[[初始化用户数据]]
                        HaoYouPublic.cleanData()
                        FunctionYinDao:reset()
                        YinDaoMarg:getInstance():reset()      
                        musicManager.reset()
                        ----------------------------------------------------------------------------------------------------------------                               
                        gameUser.initWithData(data)   
                        BATTLE_TIME_SCALE = gameUser.getBattleSpeed()
                        if GAME_CHANNEL == CHANNEL_CODE_JW or GAME_CHANNEL == CHANNEL_CODE_XT or GAME_CHANNEL == CHANNEL_CODE_SY then
                            if isCreateRole then
                                XTHD.uploadPlayerInfo(2)  --创建角色
                            end
                            XTHD.uploadPlayerInfo(1)  --进入游戏
                        end                   
                        cc.UserDefault:getInstance():setStringForKey(KEY_NAME_LAST_UUID, data["uuid"])
                        cc.UserDefault:getInstance():flush()
                        hasPermanentCampID = (data.changeCampState == 1)
                    end
                    local function callback(data)
                        if data["uuid"] ~= nil then          
                            local Url_List={
                                {method="allPet?"},
                                {method="allItem?"},
                                {method="ectypeRecord?"},
                                {method="allBuild?"},
                                {method="godBeastList?"},
                                {method="groupList?"},
								{method="servantList?"}
                                --{method="servantList?"}
                            }
                            local _zan = 0
                            local _bad = 0
                            
                            local function _get_zan()
                                local node = cc.Director:getInstance():getNotificationNode()
                                local announce = XTHDMarqueeNode:createWithParams()
                                announce:setPosition(winSize.width / 2,winSize.height * 4 / 5 + 55)
                                announce:setName("announcement")
                                node:addChild(announce)
                                if gameUser.getLevel() == 1 and not next(DBTableHero.DBData) then-------等级为1且没有英雄                                    
                                    performWithDelay(__node__,function()
                                        musicManager.setEffectVolume(0.5)
                                        musicManager.setEffectEnable(true)

                                        local scene = cc.Scene:create()
                                        cc.Director:getInstance():replaceScene(scene)
                                        local _lay
                                        if not hasPermanentCampID then --没有选种族
                                            MsgCenter:getInstance()
                                            _lay = requires("src/fsgl/layer/YinDaoJieMian/YinDaoFight0.lua"):create()
                                            print("********CTX_log:新玩家则进入引导模式*********")
                                        else
                                            MsgCenter:getInstance()
                                            _lay = XTHD.createSelectHeroLayer(scene, function()
                                                LayerManager.pushModule( nil, true, {guide = true})
                                                replaceLayer({id = 1, parent = LayerManager.getBaseLayer()})
                                            end)                                     
                                        end
                                        scene:addChild(_lay)  

                                        -- local _guideData = gameUser.getGuideID()
                                        -- local layer
                                        -- if _guideData.index == 2 then
                                        --     layer = requires("src/fsgl/layer/YinDaoJieMian/GuideSceneShipLayer.lua"):create({})
                                        -- elseif _guideData.index == 3 then
                                        --     layer = requires("src/fsgl/layer/YinDaoJieMian/GuideScene6Layer.lua"):create({})
                                        -- elseif _guideData.index == 4 then
                                        --     layer = requires("src/fsgl/layer/YinDaoJieMian/GuideSceneBridgeLayer.lua"):create({})
                                        -- elseif _guideData.index == 5 then
                                        --     layer = requires("src/fsgl/layer/YinDaoJieMian/GuideStoryHomeLayer.lua"):create({})
                                        --     local scene = cc.Scene:create()
                                        --     scene:addChild(layer)
                                        --     cc.Director:getInstance():replaceScene(scene)
                                        -- else
                                        --     -- musicManager.playBackgroundMusic("res/sound/guide/bgm2.mp3", true)
                                        --     layer = requires("src/fsgl/layer/YinDaoJieMian/GuideScene1Layer.lua"):create({})
                                        --     local scene = cc.Scene:create()
                                        --     scene:addChild(layer)
                                        --     cc.Director:getInstance():replaceScene(scene)
                                        -- end
                                        -- layer:setCascadeOpacityEnabled(true)
                                        -- layer:setOpacity(0)
                                        -- layer:runAction(cc.FadeIn:create(4.0))
                                    end,4.1)
                                    
                                    local function _func_(node) 
                                        node:runAction(cc.FadeTo:create(4,0))
                                        for k,node in pairs(node:getChildren()) do
                                            _func_(node)
                                        end
                                    end
                                    _func_(__node__)
                                    local width = cc.Director:getInstance():getWinSize().width
                                    local height = cc.Director:getInstance():getWinSize().height
                                    local  stopEffect = cc.Ripple3D:create(10*2, cc.size(32,24), cc.p(width/2,height/2), width/2 , 10, 100)
                                    __node__:getParent():runAction(stopEffect)
                                    loadingNode:setVisible(false)
                                else
                                    LayerManager.pushModule(nil, true)
                                end
                                --漏单处理 ios
                                ChargeResources:dealRestoreOrder()
                                DengLuUtils.bindBPush(data["uuid"])

                                local _param_ = {
                                    uid = tostring(gameUser.getUserId()),
                                    nickName = tostring(gameUser.getNickname()),
                                    level = tostring(gameUser.getLevel()),
                                    serverId = tostring(gameUser.getServerId()),
                                    serverName = tostring(gameUser.getServerName()),
                                    vip = tostring(gameUser.getVip()),
                                    appUId = tostring(gameUser.getPassportID()),
                                }
                                XTHD.loginSuccessCallback(_param_)
                            end

                            local function checkOver()
                                if _zan + _bad == #Url_List then 
                                    if _bad == 0 then
                                        DBUserTeamData:initPveTeamData()
                                        _get_zan()
                                    else
                                        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
                                        node:showLoginRect()
                                        node:removeChildByName("TEMP")
                                    end
                                end
                            end

                            local function Request_Net(idx)
                                ClientHttp:requestAsyncInGameWithParams({
                                    modules = Url_List[idx]["method"],
                                    successCallback = function(net_data)
                                        if tonumber(net_data.result) == 0 then
                                            if idx == 1 then
                                                DengLuUtils.UpdateHerosAndEquipmentsData(net_data["pets"])
                                                if net_data["pets"] and #net_data["pets"] > 1 then
                                                    -- MsgCenter:getInstance()
                                                end
                                            elseif idx == 2 then
                                                DengLuUtils.UpdataBagData(net_data)
                                            elseif  idx == 3 then
                                                DengLuUtils.UpdateInstancingData(net_data)
                                            elseif idx == 4 then 
                                                MsgCenter:getInstance()
                                                UserDataMgr:setMainCityData( net_data)
                                                UserDataMgr:preLoadSpine()
                                            elseif idx == 5 then
                                                DengLuUtils.initAndUpdateArtifactTable(net_data)
                                            elseif idx == 6 then
                                                DengLuUtils.updateEmbattles(net_data)
                                            elseif idx == 7 then
                                                DengLuUtils.initAndUpdatePetTable(net_data)
                                            end
                                            _zan = _zan + 1 
                                            checkOver()
                                        else
                                            _bad = _bad + 1
                                            checkOver()
                                            --此处会无限循环的
                                            -- if net_data.result ~= 1009 then 
                                            --     Request_Net(idx)
                                            -- else
                                            -- XTHDTOAST(net_data.msg or LANGUAGE_TIPS_WEBERROR)
                                            -- end
                                            -- node:showLoginRect()
                                            -- node:removeChildByName("TEMP")
                                        end
                                    end,--成功回调
                                    failedCallback = function()
                                        _bad = _bad + 1
                                        checkOver()
                                        -- XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
                                        -- node:showLoginRect()
                                        -- node:removeChildByName("TEMP")
                                    end,--失败回调
                                    targetNeedsToRetain = node,--需要保存引用的目标
                                    loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
                                })
                            end
                            -- Request_Net(_zan + 1)
                            for i=1,#Url_List do
                               Request_Net(i)
                            end
                        end
                    end
                    node:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function()
                        if tonumber(data.result) == 0 then
                            --判断技能点是否为0，即是否开启技能倒计时
                            if tonumber(data.curSkillPoint)<1 then
                                -- UpdateTimerMgr:setSkillDotStart(data.skillTime)
                                gameUser.setSkillPointTimeTable(data.skillTime,tostring(os.time()))
                            end
                            callback(data)
                            
                        elseif tonumber(data.result) == 1004 then--[[如果没有创建过角色]]
							loadingNode:setVisible(false)
							requires("src/fsgl/layer/YinDaoJieMian/YinDaoFight0.lua"):create()
							node:showLoading()
							local layer = requires("src/fsgl/layer/DengLu/PlayerNamePoplayer.lua"):create(data,node)
							cc.Director:getInstance():getRunningScene():addChild(layer)
							layer:show()
                        elseif tonumber(data.result) == 1015 then
                            gameUser.setToken(nil)
                            node:showLoginRect()
                            loadingNode:removeFromParent()
                            XTHDTOAST(data.msg)
                        else
                            loadingNode:removeFromParent()
                        end
                    end)))
                    return
                end 
                --gameUser.setToken(nil)
                node:showLoginRect()
                loadingNode:removeFromParent()
                XTHDTOAST(data.msg or LANGUAGE_KEY_ERROR_NETWORK)
            end,--成功回调
            failedCallback = function()
                --gameUser.setToken(nil)
                node:showLoginRect()
                loadingNode:removeFromParent()
                XTHDTOAST(LANGUAGE_KEY_WEIHUZHONG)
            end,--失败回调
            targetNeedsToRetain = node,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end

    checkUpdate({
        par = node,
        loadingType = HTTP_LOADING_TYPE.NONE,
        failCall = function() -----无更新
            _doLogin()
        end,
        succCall = function( sData ) ----有更新
            local UpdateLayer = requires("src/fsgl/GameLoadingLayer.lua")
            local scene = cc.Scene:create()
            scene:addChild(UpdateLayer:create({checkDatas = sData}))
            cc.Director:getInstance():replaceScene(scene) 
        end,
    })
end

-- 检查是否需要更新数据库，此时需要保证已经获取了uuid
function DengLuUtils._checkUpdateDB( lastuuid )
    return true
end

function DengLuUtils.UpdateHerosAndEquipmentsData(jsonData)
    --创建英雄数据库
    if jsonData == nil or next(jsonData) == nil then
        return;
    end

    local _target_tab = {}
    local _hero_id = {}
    local _target_equipments = {}
    local _target_skills = {}
    for i = 1, #jsonData do
        local _heros = {};
        _heros["heroid"] = jsonData[i]["id"] or 1;
        _heros["level"] =  jsonData[i]["level"] or 1;
        _heros["star"] =   jsonData[i]["starLevel"] or 0;
        _heros["advance"] = jsonData[i]["phaseLevel"] or 0;
        _heros["curexp"] =  jsonData[i]["curExp"] or 0;
        _heros["maxexp"] =  jsonData[i]["maxExp"] or 100;
        _heros["items"] =  jsonData[i]["items"] or {};
        _heros["skills"] =  jsonData[i]["skills"] or {};
        _heros["neigongs"] =  tostring(jsonData[i]["neigongs"] or "");
        _heros["petVeins"] =  jsonData[i]["petVeins"] or {};

        for _k, _v in pairs(jsonData[i]["property"]) do
            _heros[_k]=_v
        end
        _heros["407"]=jsonData[i]["power"]
        _target_tab[#_target_tab+1]=_heros
        -- 对辅助表hero_id进行更新，这个表中只是用来记录玩家拥有的英雄id
        _hero_id[#_hero_id+1]= _heros["heroid"]
        
        for j = 1, #_heros["items"] do
            local _equipment = {};
            _equipment["heroid"] = _heros["heroid"];
            _equipment["itemid"] = _heros["items"][j]["itemId"];
            _equipment["dbid"] = _heros["items"][j]["dbId"];
            _equipment["bagindex"] = _heros["items"][j]["position"];
            _equipment["power"] = _heros["items"][j]["power"];
            _equipment["quality"] = _heros["items"][j]["quality"];
            _equipment["baseProperty"] = _heros["items"][j]["property"]["baseProperty"];
            _equipment["strengLevel"] = _heros["items"][j]["property"]["strengLevel"];
            _equipment["phaseProperty"] = _heros["items"][j]["property"]["phaseProperty"];
            _equipment["phaseLevel"] = _heros["items"][j]["property"]["phaseLevel"];
            _equipment["plusTempProperty"] = _heros["items"][j]["property"]["plusTempProperty"];
            _target_equipments[#_target_equipments+1] = _equipment
        end
       
        local _skills = {};
        _skills["heroid"] = _heros["heroid"];
        _skills["talentlv"] = _heros["skills"][1]
        _skills["skillidlv"] = _heros["skills"][2]
        _skills["skillid0lv"] = _heros["skills"][3]
        _skills["skillid1lv"] = _heros["skills"][4]
        _skills["skillid2lv"] = _heros["skills"][5]
        _skills["skillid3lv"] = _heros["skills"][6]
        _target_skills[#_target_skills+1] = _skills
    end    
    DBTableHero.insertMultiData(gameUser.getUserId(), _target_tab)--填充英雄数据
    print("DengLuUtils.UpdateHerosAndEquipmentsData DBTableHero.insertMultiData")
    DBTableHeroSkill.insertMultiData(gameUser.getUserId(), _target_skills)--填充英雄技能数据 zhangchao
    DBTableEquipment.insertMultiData(gameUser.getUserId() , _target_equipments )        
end

function DengLuUtils.updateEmbattles( data )
    if data and data.groups then 
        for i = 1,#data.groups do 
            local params = {}
            params["teamid"] = data.groups[i].groupId
            for k,v in pairs(data.groups[i].list) do 
                params['heroid'..k] = v
            end 
            DBUserTeamData:InsertData(params)
        end 
    end 
end
--存储五物品数据
function DengLuUtils.UpdataBagData(jsonData)
    -- DBTableItem.DBData = {}
    if jsonData == nil or next(jsonData) == nil then
        return;
    end
    
    if jsonData == nil or next(jsonData) == nil then
        return;
    end
   if jsonData["items"] and next(jsonData["items"]) ~= nil then
        --批量插入数据
        --[[插入用户道具数据]]
        DBTableItem.insertMultiData(gameUser.getUserId() , jsonData["items"] )

        --在此更新背包数据后，刷新神器红点信息
        DBTableArtifact.refreshRedDot()
    end
end

function DengLuUtils.UpdateInstancingData(jsonData)
    CopiesData.UpdateInstancingData(jsonData)
end

function DengLuUtils.initAndUpdateArtifactTable(jsonData)
    for i=1,#jsonData.list do
        local pNum = tonumber(jsonData.list[i].cdTime) or 0
        jsonData.list[i].cdTime = pNum > 0 and pNum + os.time() or 0
        DBTableArtifact.analysDataAndUpdate(jsonData.list[i])
    end    
end

function DengLuUtils.initAndUpdatePetTable( jsonData )
    for i=1,#jsonData.list do
        local pNum = tonumber(jsonData.list[i].cdTime) or 0
        jsonData.list[i].cdTime = pNum > 0 and pNum + os.time() or 0
        DBPetData.analysDataAndUpdate(jsonData.list[i])
    end    
end

function DengLuUtils.bindBPush( uuid )
    local tmp_uuid = uuid ~= nil and uuid or ""    
    local tmp_user_id = string.len(cc.UserDefault:getInstance():getStringForKey(BPUSH_USER_ID)) ~= 0 and cc.UserDefault:getInstance():getStringForKey(BPUSH_USER_ID) or ""
    local tmp_platform_id = 1   --1表示ios   2表示android
    if (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) then
        tmp_platform_id = 1
    elseif cc.PLATFORM_OS_ANDROID == ZC_targetPlatform then
        tmp_platform_id = 2
    end

    ClientHttp:requestAsyncInGameWithParams({
        modules = "channelChange?",
        params = {
            platformId = tmp_platform_id,
            channelId = 0, --GAME_CHANNEL, --候大神需求必须是0
            userId=tmp_user_id
        },
        successCallback = function(data)
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_TIPS_WORDS119)-----"服务器已关闭")
        else
            if data["result"] == 0 then
            else
                print("推送向服务器绑定失败")
            end
        end

        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WORDS119)----"服务器已关闭")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
    })
end