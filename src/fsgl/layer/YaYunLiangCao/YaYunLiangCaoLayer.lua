-- 运镖界面
--赌五毛到时候也得改
local YaYunLiangCaoLayer = class("YaYunLiangCaoLayer",function ()
	return XTHD.createBasePageLayer()
end)

function YaYunLiangCaoLayer:ctor(data)
    self:createNewBg()
	self:initUI(data)
    self:refreshBtn(data)
    self:refreshCar(data)
    XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_ESCORT_LAYER,
        callback = function (event)
            ClientHttp:requestAsyncInGameWithParams({
                modules = "getDartList?",
                params = {},
                successCallback = function(sdata)
                    if data.result==0 then
                        self:refreshBtn(sdata)
                        self:refreshCar(sdata)
                      else
                        XTHDTOAST(data.msg)
                    end
                end,
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
        end
    })
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_ESCORT_TIME)
    XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_ESCORT_TIME,
        callback = function (event)
            self:refreshChallengeTime(event.data)
        end
    })
end

function YaYunLiangCaoLayer:onEnter()
    self:addGuide()
end

function YaYunLiangCaoLayer:onExit()
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_ESCORT_LAYER)
end

function YaYunLiangCaoLayer:onCleanup()
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/background/bg_2.jpg")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/bottom_shadow.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/challenge_left.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/change_btn_selected.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/change_btn.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/desc_str.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/escort_left.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/top_shadow.png")
    for i=0, 3 do
        if i ~= 0 then
            textureCache:removeTextureForKey("res/image/daily_task/escort_task/team_flag_" .. i .. "_selected.png")
            textureCache:removeTextureForKey("res/image/daily_task/escort_task/team_flag_" .. i .. ".png")
        end
        textureCache:removeTextureForKey("res/image/daily_task/escort_task/team_mode_" .. i .. "_selected.png")
        textureCache:removeTextureForKey("res/image/daily_task/escort_task/team_mode_" .. i .. ".png")
    end
end

function YaYunLiangCaoLayer:refreshChallengeTime(num)
    if self.challengeTime and self.challengeTime.setString then
        self.challengeTime:setString(num)
    end
end

function YaYunLiangCaoLayer:refreshLayer(carRefresh)
    carRefresh = carRefresh or 0
    ClientHttp:requestAsyncInGameWithParams({
        modules = "getDartList?",
        params = {},
        successCallback = function(data)
            if data.result==0 then
                self:refreshBtn(data)
                if carRefresh == 0 then
                    self:refreshCar(data)
                end
            else
                XTHDTOAST(data.msg)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function YaYunLiangCaoLayer:createNewBg()
    local bg = cc.Sprite:create("res/image/daily_task/escort_task/beijing.jpg")
    bg:setAnchorPoint(0,0.5)
    bg:setPosition(0,self:getBoundingBox().height/2)
    self:addChild(bg)
	bg:setContentSize(self:getContentSize())

    local bg2 = cc.Sprite:create("res/image/daily_task/escort_task/beijing.jpg")
    bg2:setAnchorPoint(0,0.5)
    bg2:setPosition(bg:getBoundingBox().width,bg:getBoundingBox().height/2)
    bg:addChild(bg2)
	bg2:setContentSize(self:getContentSize())

	local _scaleX = cc.Director:getInstance():getWinSize().width / 1024
	local _scaleY = cc.Director:getInstance():getWinSize().height / 615
	
--	bg:setScaleX(_scaleX)
--	bg:setScaleY(_scaleY)
	
    bg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(20,cc.p(-bg:getBoundingBox().width,0)),cc.CallFunc:create(function ()
        bg:setPosition(0,self:getBoundingBox().height/2)
    end))))
    self.bg = bg
end

function YaYunLiangCaoLayer:initUI(data)
 --    bg:runAction(cc.Sequence:create(cc.MoveBy:create(5,cc.p(-bg:getBoundingBox().width,0)),cc.RemoveSelf:create()))

    local tipDi = cc.Sprite:create("res/image/imgSelHero/x_40.png")
    tipDi:setContentSize(cc.Director:getInstance():getWinSize().width*1.5,50)
    tipDi:setAnchorPoint(0.5, 0.5)
    tipDi:setPosition(self:getContentSize().width*0.5-100, self:getContentSize().height - 65)
    self:addChild(tipDi,0)

    local backBtn = XTHDPushButton:createWithParams({
        normalNode = cc.Sprite:create("res/image/common/btn/btn_back_normal.png"),
        selectedNode = cc.Sprite:create("res/image/common/btn/btn_back_selected.png"),
        musicFile = XTHD.resource.music.effect_btn_commonclose,
        touchSize = cc.size(150,60),
        anchor = cc.p(1,1),
        pos = cc.p(self:getContentSize().width, self:getContentSize().height)
    })
    self:addChild(backBtn)

    backBtn:setTouchEndedCallback(function ()
        LayerManager.removeLayout(self)
    end)

    --底部背景框
    local bottomShadow = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/daily_task/escort_task/bottom_shadow.png")
    bottomShadow:setContentSize(cc.size(self:getBoundingBox().width,bottomShadow:getBoundingBox().height))
    bottomShadow:setAnchorPoint(0.5,0)
    bottomShadow:setScaleX(self:getBoundingBox().width/bottomShadow:getBoundingBox().width)
    bottomShadow:setPosition(self:getBoundingBox().width/2,0)
    self:addChild(bottomShadow)
    self.bottomShadow = bottomShadow

	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=29});
            self:addChild(StoredValue,2)
        end,
	})
	self:addChild(help_btn)
	help_btn:setPosition(help_btn:getContentSize().width/2 + 15,self.bottomShadow:getPositionY() + 35)

    --兑换按钮
    -- local normalChange = XTHDPushButton:createWithParams({
    --     normalFile = "res/image/daily_task/escort_task/change.png",
    --     selectedFile = "res/image/daily_task/escort_task/change_selected.png",
    -- })
    -- normalChange:setAnchorPoint(1,0.5)
    -- normalChange:setPosition(self:getBoundingBox().width-20,bottomShadow:getContentSize().height/2)
    -- self:addChild(normalChange)
    -- normalChange:setTouchEndedCallback(function( )
    --     local _store = requires("src/fsgl/layer/ShangCheng.lua"):create({which = 'yunBiao'})
    --     LayerManager.addLayout(_store)
    -- end)

    --剩余挑战次数
    local challengeLeft = cc.Sprite:create("res/image/daily_task/escort_task/challenge_left.png")
    challengeLeft:setAnchorPoint(1,0.5)

    self.challengeTime = getCommonWhiteBMFontLabel(data.lootTimes)
    self.challengeTime:setAnchorPoint(1,0.5)
    self.challengeTime:setFontSize(24)
    --剩余运镖次数
    local escortLeft = cc.Sprite:create("res/image/daily_task/escort_task/escort_left.png")
    escortLeft:setAnchorPoint(1,0.5)

    self.escortTime = getCommonWhiteBMFontLabel(data.dartTimes)
    self.escortTime:setAnchorPoint(1,0.5)
    self.escortTime:setFontSize(24)
    

    self.escortTime:setPosition(tipDi:getContentSize().width/2+300,tipDi:getContentSize().height/2)
    tipDi:addChild(self.escortTime)

    escortLeft:setPosition(self.escortTime:getPositionX()-self.escortTime:getBoundingBox().width,tipDi:getContentSize().height/2)
    tipDi:addChild(escortLeft)

    self.challengeTime:setPosition(escortLeft:getPositionX()-escortLeft:getBoundingBox().width-80,tipDi:getContentSize().height/2)
    tipDi:addChild(self.challengeTime)

    challengeLeft:setPosition(self.challengeTime:getPositionX()-self.challengeTime:getBoundingBox().width,tipDi:getContentSize().height/2)
    tipDi:addChild(challengeLeft)
    

    local topShadow = cc.Sprite:create("res/image/daily_task/escort_task/top_shadow.png")
    topShadow:setAnchorPoint(0.5,0.5)
    topShadow:setPosition(self:getContentSize().width/2,self:getContentSize().height-tipDi:getContentSize().height-topShadow:getContentSize().height/2-25)
    self:addChild(topShadow,1)
    topShadow:setScale(0.8)

    local descStr = cc.Sprite:create("res/image/daily_task/escort_task/desc_str.png")
    descStr:setAnchorPoint(0.5,0.5)
    descStr:setPosition(topShadow:getContentSize().width/2,topShadow:getContentSize().height/2)
    topShadow:addChild(descStr,10)
    
    --换一批按钮
    local changeBtn = XTHDPushButton:createWithParams({
        normalFile = "res/image/daily_task/escort_task/change_btn.png",
        selectedFile = "res/image/daily_task/escort_task/change_btn_selected.png",
    })
    changeBtn:setAnchorPoint(0,0.5)
    changeBtn:setPosition(self:getContentSize().width-changeBtn:getContentSize().width-10 - GetScreenOffsetX(),self:getContentSize().height/2-170)
    self:addChild(changeBtn)
    changeBtn:setScale(0.8)

    changeBtn:setTouchEndedCallback(function ()
        self:runClouds()
    end)

    --战斗记录按钮
    local replayBtn = XTHDPushButton:createWithParams({
        normalFile = "res/image/daily_task/escort_task/replay_btn.png",
        selectedFile = "res/image/daily_task/escort_task/replay_btn_selected.png",
    })
    replayBtn:setAnchorPoint(0,0.5)
    replayBtn:setPosition(changeBtn:getPositionX(),self:getContentSize().height/2-50)
    self:addChild(replayBtn)
    replayBtn:setScale(0.8)
    replayBtn:setTouchEndedCallback(function()
        self:replayBtnCallback()
    end)
end

function YaYunLiangCaoLayer:runClouds()
    --self:refreshLayer()
    --local swallowBg = XTHDDialog:create()
    --self:addChild(swallowBg)
    local cloudLeft = cc.Sprite:create("res/image/plugin/stageChapter/yun_left.png")
    local cloudRight = cc.Sprite:create("res/image/plugin/stageChapter/yun_right.png")
    cloudLeft:setScale(self:getBoundingBox().height/cloudLeft:getBoundingBox().height)
    cloudRight:setScale(self:getBoundingBox().height/cloudRight:getBoundingBox().height)
    cloudLeft:setAnchorPoint(1,0.5)
    cloudRight:setAnchorPoint(0,0.5)
    cloudLeft:setPosition(0,self:getBoundingBox().height/2)
    cloudRight:setPosition(self:getBoundingBox().width,self:getBoundingBox().height/2)
    self:addChild(cloudLeft,3)
    self:addChild(cloudRight,3)

    cloudLeft:runAction(cc.Sequence:create(cc.MoveBy:create(0.3,cc.p(cloudLeft:getBoundingBox().width,0)),cc.CallFunc:create(function ()
        ClientHttp:requestAsyncInGameWithParams({
            modules = "getDartList?",
            params = {},
            successCallback = function(data)
                if data.result==0 then
                    self:refreshBtn(data)
                    self:refreshCar(data)
                    cloudLeft:runAction(cc.Sequence:create(cc.MoveBy:create(0.3,cc.p(-cloudLeft:getBoundingBox().width,0)),cc.RemoveSelf:create()))
                    cloudRight:runAction(cc.Sequence:create(cc.MoveBy:create(0.3,cc.p(cloudRight:getBoundingBox().width,0)),cc.RemoveSelf:create()))
                    --swallowBg:removeFromParent()
                  else
                    XTHDTOAST(data.msg)
                end
            end,
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            end,--失败回调
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end)))
    cloudRight:runAction(cc.MoveBy:create(0.3,cc.p(-cloudRight:getBoundingBox().width,0)))
end

function YaYunLiangCaoLayer:replayBtnCallback()
    ClientHttp:requestAsyncInGameWithParams({
        modules = "lootDartLog?",
        successCallback = function(data)
            if data.result==0 then
                local _popLayer = requires("src/fsgl/layer/YaYunLiangCao/YaYunLiangCaoRecordPopLayer.lua"):create(data)
                self:addChild(_popLayer,2)
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function YaYunLiangCaoLayer:refreshBtn(data)
    self.bottomShadow:removeAllChildren()
    self.challengeTime:setString(data.lootTimes)
    self.escortTime:setString(data.dartTimes)
    self.btnList = {}
    for i=1,3 do
        local nowData = data.data[i]
        local normal,selected = self:getBtnNode(i,data.data[i].flag,nowData.lockState)

        local teamFlag = XTHDPushButton:createWithParams({
            normalNode = normal,
            selectedNode = selected,
            touchSize = cc.size(185,55),
            needSwallow = true
        })
        teamFlag:setAnchorPoint(1,0.5)
        teamFlag:setPosition(350+teamFlag:getBoundingBox().width+(i-1)*200,self.bottomShadow:getBoundingBox().height/2+5)
        self.bottomShadow:addChild(teamFlag,1)

        --local modeStr = cc.Sprite:create("res/image/daily_task/escort_task/mode_str_"..i..".png")
        --modeStr:setAnchorPoint(0,0)
        --modeStr:setPosition(10,0)
        --teamFlag:addChild(modeStr)

        --if nowData.lockState == 1 then
        --    XTHD.setGray(modeStr,true)
        --end

        teamFlag:setTouchEndedCallback(function ()
            local nowCSV = gameData.getDataFromCSV("LiangcaoStore",{id = nowData.taskId})
            if nowData.flag == 0 then
                ----引导
                YinDaoMarg:getInstance():guideTouchEnd() 
                ------------------------------------------             
                ClientHttp:requestAsyncInGameWithParams({
                    modules = "openDart?",
                    params = {},
                    successCallback = function(data)
                        if data.result==0 then
                            YinDaoMarg:getInstance():releaseGuideLayer()
                            local YaYunLiangCaoTaskLayer = requires("src/fsgl/layer/YaYunLiangCao/YaYunLiangCaoTaskLayer.lua"):create(data,function ()
                                self:refreshLayer()
                            end,i)
                            LayerManager.addLayout(YaYunLiangCaoTaskLayer)
                        else
                            YinDaoMarg:getInstance():tryReguide()
                            XTHDTOAST(data.msg)
                        end
                    end,
                    failedCallback = function()
                        YinDaoMarg:getInstance():tryReguide()
                        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                    end,--失败回调
                    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                })
            elseif nowData.flag == 1 then
                local rewardList = {}
                local finishNum = 1 + #nowData.meetTerm
                local taskNum = 0
                for i=1,4 do
                    if tonumber(nowCSV["type"..i]) ~= 0 then
                        taskNum = taskNum + 1
                    end
                end
                for i=1,4 do
                    local rewardData = string.split(nowCSV["reward"..i],"#") --1类型  2装备id  3数量
                    local rewardCount = #nowData.meetTerm == taskNum and tonumber(rewardData[3])*2 or tonumber(rewardData[3])
                    if finishNum >= i then
                        rewardList[#rewardList+1] = {
                            rewardtype = tonumber(rewardData[1]),
                            id = tonumber(rewardData[2]),
                            num = rewardCount
                        }
                    end
                end
                
                local YaYunLiangCaoRewardPop = requires("src/fsgl/layer/YaYunLiangCao/YaYunLiangCaoRewardPop.lua"):create(rewardList,nowCSV.needyuanbao,function ()
                    XTHDHttp:requestAsyncInGameWithParams({
                        modules = "finishDart?",
                        params = {dartType = nowData.dartType},
                        successCallback = function(finish)
                            if tonumber(finish.result) == 0 then
                                data.data[i].flag = finish.flag
                                data.data[i].leftTime = finish.leftTime
                                XTHD.updateProperty(finish.property)
                                XTHD.saveItem({items = finish.items})
                                for i=1,#finish.petData do
                                    for j=1,#finish.petData[i].property do
                                        local petItemData = string.split( finish.petData[i].property[j],',')
                                        DBTableHero.updateDataByPropId(gameUser.getUserId(),petItemData[1],petItemData[2],finish.petData[i].baseId)
                                    end
                                end
                                local taskNum = 0
                                for i=1,4 do
                                    if tonumber(nowCSV["typeCan"..i]) ~= 0 then
                                        taskNum = taskNum + 1
                                    end
                                end
                                
                                local finishNum = 1 + #nowData.meetTerm
                                local rewardList = self:getRewardListTb(finish)
                                -- for i=1,4 do
                                --     local rewardData = string.split(nowCSV["reward"..i],"#") --1类型  2装备id  3数量
                                --     local rewardCount = #nowData.meetTerm == taskNum and tonumber(rewardData[3])*2 or tonumber(rewardData[3])
                                --     if finishNum >= i then
                                --         rewardList[#rewardList+1] = {
                                --             rewardtype = tonumber(rewardData[1]),
                                --             id = tonumber(rewardData[2]),
                                --             num = rewardCount
                                --         }
                                --     end
                                -- end
                                ShowRewardNode:create(rewardList)
                                data.data[i] = finish.data
                                self:refreshBtn(data)
                                self:refreshCar(data)
                            else
                                XTHDTOAST(finish.msg or LANGUAGE_TIPS_WEBERROR)
                            end
                        end,--成功回调
                        failedCallback = function()
                            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
                        end,--失败回调
                        targetNeedsToRetain = self,--需要保存引用的目标
                        loadingParent = self,
                        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                    })
                end)
                self:addChild(YaYunLiangCaoRewardPop,2)
                YaYunLiangCaoRewardPop:show()
            elseif nowData.flag == 2 then
                XTHDHttp:requestAsyncInGameWithParams({
                    modules = "dartReward?",
                    params = {dartType = nowData.dartType},
                    successCallback = function(reward)
                        if tonumber(reward.result) == 0 then
                            XTHD.updateProperty(reward.property)
                            XTHD.saveItem({items = reward.items})
                            for i=1,#reward.petData do
                                for j=1,#reward.petData[i].property do
                                    local petItemData = string.split( reward.petData[i].property[j],',')
                                    DBTableHero.updateDataByPropId(gameUser.getUserId(),petItemData[1],petItemData[2],reward.petData[i].baseId)
                                end
                            end
                            local taskNum = 0
                            for i=1,4 do
                                if tonumber(nowCSV["typeCan"..i]) ~= 0 then
                                    taskNum = taskNum + 1
                                end
                            end
                            
                            local finishNum = 1 + #nowData.meetTerm
                            local rewardList = self:getRewardListTb(reward)
                            -- for i=1,4 do
                            --     local rewardData = string.split(nowCSV["reward"..i],"#") --1类型  2装备id  3数量
                            --     local rewardCount = #nowData.meetTerm == taskNum and tonumber(rewardData[3])*2 or tonumber(rewardData[3])
                            --     if finishNum >= i then
                            --         rewardList[#rewardList+1] = {
                            --             rewardtype = tonumber(rewardData[1]),
                            --             id = tonumber(rewardData[2]),
                            --             num = rewardCount
                            --         }
                            --     end
                            -- end
                            ShowRewardNode:create(rewardList)
                            data.data[i] = reward.data
                            self:refreshBtn(data)
                        else
                            XTHDTOAST(reward.msg or LANGUAGE_TIPS_WEBERROR)
                        end
                    end,--成功回调
                    failedCallback = function()
                        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
                    end,--失败回调
                    targetNeedsToRetain = self,--需要保存引用的目标
                    loadingParent = self,
                    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                })
            end
        end)

        self.btnList[i] = teamFlag

        if nowData.leftTime and nowData.leftTime > 0 then
            local cdLabel = getCommonWhiteBMFontLabel(getCdStringWithNumber(nowData.leftTime,{h=":"}))
			cdLabel:setAnchorPoint(0,0.5)
            cdLabel:setPosition(70,teamFlag:getBoundingBox().height-25)
            teamFlag:addChild(cdLabel)
            cdLabel.cd = nowData.leftTime
            self:doCountDown(cdLabel)
        end
    end
end

function YaYunLiangCaoLayer:getRewardListTb( data )
    local rewardList = {}
    local _addSilver = tonumber(data.addSilver) or 0
    if _addSilver > 0 then
        rewardList[#rewardList+1] = {
            rewardtype = XTHD.resource.type.gold,
            num = _addSilver,
        }
    end
    local _addFeicui = tonumber(data.addFeicui) or 0
    if _addFeicui > 0 then
        rewardList[#rewardList+1] = {
            rewardtype = XTHD.resource.type.feicui,
            num = _addFeicui,
        }
    end
    local _addRenown = tonumber(data.addRenown) or 0
    if _addRenown > 0 then
        rewardList[#rewardList+1] = {
            rewardtype = XTHD.resource.type.reputation,
            num = _addRenown,
        }
    end
    if data.addItems and #data.addItems > 0 then
        for i=1, #data.addItems do
            local info = string.split(data.addItems[i],",")
            if tonumber(info[2]) > 0 then
                rewardList[#rewardList+1] = {
                    rewardtype = XTHD.resource.type.item,
                    id = info[1],
                    num = info[2],
                }
            end
        end
    end
    return rewardList
end

function YaYunLiangCaoLayer:doCountDown(label)
    print("doCountDown")
    label:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
        label.cd = label.cd - 1
        if label.cd > 0 then
            label:setString(getCdStringWithNumber(label.cd,{h=":"}))
        else
            label:stopAllActions()
            self:refreshLayer(1)
        end
    end))))
end

function YaYunLiangCaoLayer:getBtnNode(num,flag,isGray)
    print("getBtnNode")
    local sp = cc.Sprite:create()
    sp:setContentSize(cc.size(185,73))
    local btn = cc.Sprite:create("res/image/daily_task/escort_task/team_flag_"..num..".png")
    local flagBtn = cc.Sprite:create("res/image/daily_task/escort_task/team_mode_"..flag..".png")
    flagBtn:setAnchorPoint(0,0.5)
    flagBtn:setPosition(btn:getBoundingBox().width-38+10,btn:getBoundingBox().height/2-15)
    btn:addChild(flagBtn,-1)
    btn:setAnchorPoint(0,0)
    sp:addChild(btn)

    local selectSp = cc.Sprite:create()
    selectSp:setContentSize(cc.size(185,73))
    local selectedbtn = cc.Sprite:create("res/image/daily_task/escort_task/team_flag_"..num.."_selected.png")
    local selectedFlagBtn = cc.Sprite:create("res/image/daily_task/escort_task/team_mode_"..flag.."_selected.png")
    selectedFlagBtn:setAnchorPoint(0,0.5)
    selectedFlagBtn:setPosition(selectedbtn:getBoundingBox().width-38,selectedbtn:getBoundingBox().height/2-15)
    selectedbtn:addChild(selectedFlagBtn,-1)
    selectedbtn:setAnchorPoint(0,0)
    selectSp:addChild(selectedbtn)

    if isGray == 1 then
        XTHD.setGray(btn,true)
        XTHD.setGray(flagBtn,true)
        XTHD.setGray(selectedbtn,true)
        XTHD.setGray(selectedFlagBtn,true)

        local normalLock = cc.Sprite:create("res/image/daily_task/escort_task/lock.png")
        normalLock:setPosition(btn:getBoundingBox().width/2-10,btn:getBoundingBox().height/2+5)
        btn:addChild(normalLock)

        local selectLock = cc.Sprite:create("res/image/daily_task/escort_task/lock.png")
        selectLock:setPosition(selectedbtn:getBoundingBox().width/2-10,selectedbtn:getBoundingBox().height/2+5)
        selectedbtn:addChild(selectLock)
        
        XTHD.setGray(normalLock,true)
        XTHD.setGray(selectLock,true)
    end

    return sp,selectSp
end

function YaYunLiangCaoLayer:refreshCar(data)
    print("refreshCar")
    if self.carLayer then
        self.carLayer:removeAllChildren()
    else
        self.carLayer = cc.Layer:create()
        self:addChild(self.carLayer)
    end

    self.bg:stopAllActions()
    for i=#data.dartList,1,-1 do
        if data.dartList[i].isSelf then
            table.remove(data.dartList,i)
        end
    end
    for i=1,#data.data do
        if data.data[i].flag == 1 then
            data.data[i].isSelf = 1
            data.dartList[#data.dartList+1] = data.data[i]
        end
    end
    if #data.dartList > 0 then
        self.bg:setPosition(0,self:getBoundingBox().height/2)
        self.bg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(20,cc.p(-self.bg:getBoundingBox().width,0)),cc.CallFunc:create(function ()
            self.bg:setPosition(0,self:getBoundingBox().height/2)
        end))))
    end
    -- math.randomseed(os.clock())
    math.newrandomseed()
    self._pigList = {}
    local function _sortList ( d1, d2 )
        if not d1.needtime then
            local nowCSV = gameData.getDataFromCSV("LiangcaoStore", {id = d1.taskId})
            d1.needtime = nowCSV.needtime
        end
         if not d2.needtime then
            local nowCSV = gameData.getDataFromCSV("LiangcaoStore", {id = d2.taskId})
            d2.needtime = nowCSV.needtime
        end
        local percent1 = 1 - (tonumber(d1.leftTime)/tonumber(d1.needtime))
        if percent1 < 0 then
            percent1 = 0
        elseif percent1 > 1 then
            percent1 = 1
        end
        local percent2 = 1 - (tonumber(d2.leftTime)/tonumber(d2.needtime))
        if percent2 < 0 then
            percent2 = 0
        elseif percent2 > 1 then
            percent2 = 1
        end
        return percent1 > percent2
    end
    table.sort(data.dartList, _sortList)
    local pYs = {360, 270, 180}
    local lastX = 0
    local lastY = 0
    local pCount = #data.dartList
    local _widthCell = 100
    if pCount >= 6 then
        _widthCell = 80
    end

    local _midX = (self:getContentSize().width - _widthCell*2)*0.5
    local _startX = _midX + pCount/2 * _widthCell
    if pCount > 0 then
        for i=1, pCount do
            local j = i --> 5 and i - 5 or i
            local nowData = data.dartList[j]
            local nowCSV = gameData.getDataFromCSV("LiangcaoStore", {id = nowData.taskId})
            -- local randomPig = math.random(0,150)
            local pType = nowData.dartType

            local carSpBtn = XTHDPushButton:createWithParams({
                anchor       = cc.p(0.5, 0.5), --已经商定好   用(0.5, 0)作为锚点，建筑成形后记得修改
                needSwallow  = false,
                needEnableWhenMoving = true,
                musicFile = XTHD.resource.music.effect_btn_common,
            })        
            local spineTargSize = cc.size(180, 120)
        
            local node = cc.Node:create()
            node:setAnchorPoint(cc.p(0.5, 0.5))
            local carSp = sp.SkeletonAnimation:create("res/spine/effect/escort_car/chuan"..pType..".json","res/spine/effect/escort_car/chuan"..pType..".atlas", 1)
            carSp:setAnimation(0, "animation", true)
            carSpBtn:setTouchSize(spineTargSize)
            node:addChild(carSp)
            node:setPositionY(carSpBtn:getContentSize().height / 2 + carSpBtn:getContentSize().height * carSpBtn:getScaleY() - 30)
            carSpBtn:addChild(node)
            -- pType = pType ~= 3 and 1 or 2
            -- local pigSp = sp.SkeletonAnimation:create("res/spine/effect/escort_car/b"..pType..".json","res/spine/effect/escort_car/b"..pType..".atlas",0.6)
           
            -- pigSp:setAnimation(0, "run",true)
            -- local percent = 1-(tonumber(nowData.leftTime)/tonumber(nowCSV.needtime))
            -- if percent < 0 then
            --     percent = 0
            -- elseif percent > 1 then
            --     percent = 1
            -- end
            -- local posRandomX = (self:getContentSize().width - carSp:getBoundingBox().width * 2)*percent
            local posRandomX = _startX - (i-1)*_widthCell*0.9

            -- local posRandomY = 80 + (pCount - i + 1)*50
            local pY = lastY
            while(pY == lastY) do
                pY = math.random(1,3)
            end
            self.carLayer:addChild(carSpBtn, pY)
            --self.carLayer:addChild(pigSp, pY)
            --pigSp.id = nowData.taskId
            --self._pigList[#self._pigList+1] = pigSp
            local posRandomY = pYs[pY]
            lastY = pY
            carSpBtn:setPosition(posRandomX,posRandomY)

            local randomPig = math.random(80,120)/100
            carSpBtn:setScale(randomPig)
            --pigSp:setTimeScale(randomPig)
            --pigSp:setPosition(posRandomX, posRandomY)
            
            -- performWithDelay(carSp, function ( ... )
            --     if posRandomX >= lastX - carSp:getBoundingBox().width*0.5 and posRandomX <= lastX + carSp:getBoundingBox().width*0.5 then
            --         if posRandomX >= lastX then
            --             posRandomX = posRandomX + carSp:getBoundingBox().width*0.5
            --         else
            --             posRandomX = posRandomX - carSp:getBoundingBox().width*0.5
            --         end
            --     end
            --     lastX = posRandomX
            --     carSp:setPosition(posRandomX, posRandomY)
            --     pigSp:setPosition(posRandomX, posRandomY)
            -- end, 0.001*pCount)

            carSpBtn:setTouchEndedCallback(function ()
                if not nowData.charId then
                    nowData.charId = gameUser.getUserId()   
                end

                ClientHttp:requestAsyncInGameWithParams({
                    modules = "getDartInfo?",
                    params = {dartType = nowData.dartType,rivalId = nowData.charId},
                    successCallback = function(Info)
                        if Info.result==0 then
                            local _popLayer = requires("src/fsgl/layer/YaYunLiangCao/YaYunLiangCaoInfoPopLayer.lua"):create(Info)
                            self:addChild(_popLayer,2)
                        else
                            XTHDTOAST(Info.msg)
                        end
                    end,
                    failedCallback = function()
                        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                    end,--失败回调
                    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                })
            end)

            if nowData.isSelf then
                -- carSp:setTouchEndedCallback(function ()
                --     print(" carSp:setTouchEndedCallback")
                --     self.btnList[nowData.dartType]:getTouchEndedCallback()()
                -- end)
            end
            self:showDialog()
        end
    else
        self:stopAction(self._dialogAction)
    end
end

function YaYunLiangCaoLayer:showDialog()
    print(" carSp:showDialog")
    self:stopAction(self._dialogAction)
    if #self._pigList > 0 then
        self._dialogAction = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function ()
            local randomPig = math.random(1, #self._pigList)
            local randomDialog = math.random(1,3)
            local dialogStr = gameData.getDataFromCSV("LiangcaoStore",{id = self._pigList[randomPig].id})["tip"..randomDialog]
            -- XTHDTOAST(dialogStr)
            self.dialog = cc.Sprite:create("res/image/daily_task/escort_task/dialog_bg.png")
            self.dialog:setPosition(self._pigList[randomPig]:getBoundingBox().width/2+40,self._pigList[randomPig]:getBoundingBox().height+25)
            self._pigList[randomPig]:addChild(self.dialog)

            local dialogLabel = XTHDLabel:createWithParams({
                text = dialogStr,
                fontSize = 16,
                color = XTHD.resource.color.gray_desc
            })
            dialogLabel:setAnchorPoint(0,1)
            dialogLabel:setPosition(10,self.dialog:getBoundingBox().height-7)
            dialogLabel:setWidth(130)
            self.dialog:addChild(dialogLabel)
        end),cc.DelayTime:create(3),cc.CallFunc:create(function ()
            if self.dialog then
                self.dialog:removeFromParent()
                self.dialog = nil
            end
        end)))
        self:runAction(self._dialogAction)
    end
end

function YaYunLiangCaoLayer:create(data)
	return YaYunLiangCaoLayer.new(data)
end

function YaYunLiangCaoLayer:addGuide()
    -- YinDaoMarg:getInstance():addGuide({index = 4,parent = self},20) ---- 
    -- if self.btnList[1] then 
    --     YinDaoMarg:getInstance():addGuide({ ------引导低级派遣队伍 
    --         parent = self,
    --         target = self.btnList[1],
    --         index = 5,
    --     },20)
    -- end 
    -- YinDaoMarg:getInstance():doNextGuide()
end

return YaYunLiangCaoLayer