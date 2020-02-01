--[[
authored by LITao version.1 当前版本的引导设计分为两类来完成。
引导一：通过当前类里的triggerGuide()函数来触发的引导。该类型的引导是功能性的，模块性的，引导组与组之间是独立的。引导数据在GuideStep.lua数据文件里。
引导二：是通过程序硬写的。因为其主要作用是实现在第一章的时候始终引导玩家从主城的历练——》副本的地图关卡——》开战——》【可能要引导新人上阵】选人界面里开战——》战斗结束点返回。中途还有
	关卡里的开宝箱引导。
有一重点是要处理以上两类引导之间的重复显示
]]
-- requires("src/fsgl/staticdata/OperationGuide.lua")

YinDaoMarg = class("YinDaoMarg")

function YinDaoMarg:ctor()
    self._guideLayer = nil
    self._guideList = { }
    self._isGuiding = false
    self._id = 0
    self._index = 0
    self._group = 0
    self._preIndex = 0
    self._preGroup = 0
    self._serverExtraCondition = nil
    ------附属条件 hasSweep 是否征战过
    self._battlePVEFailTimes = 0
    -------普通副本失败的次数
    self._chapter1Guides = { }
    ----第一章特殊引导的(用于处理同时出现两种引导时)

    self._localData = { }
    -----本地的引导表
    self._triggers = { [0] = { }, [1] = { }, [2] = { } }
    ----按触发类型、条件组织的数据 (0 按钮触发，1 等级类型，2 关卡类型)
    local _allData = gameData.getDataFromCSV("GuideStep")
    local _group = 0
    for k, v in pairs(_allData) do
        if not self._localData[v.group] then
            self._localData[v.group] = { }
        end
        self._localData[v.group][v.steps] = v
        if _group ~= v.group then
            _group = v.group
            self._triggers[v.trigger][v.condition] = _group
        end
    end

    local datas = { }
    for k, i in pairs(self._triggers[0]) do
        local msg = { chatType = LiaoTianDatas.__chatType.TYPE_HELPER, message = self._localData[i][1].info1, group = k }
        table.insert(datas, #datas + 1, msg)
    end
    LiaoTianDatas.insertHelperData(datas)

    self._skipGuide = false
    ----是否要跳过引导功能

    self.Tag = {
        ktag_Cover = 1024,
    }

    local _temp = gameUser.getGuideID()
    if _temp and type(_temp) == "table" then
        self._id = _temp.id
    end
end 

function YinDaoMarg:getInstance()
    if not self._instance then
        self._instance = YinDaoMarg.new()
        -- self._instance = null
    end
    return self._instance
end

function YinDaoMarg:getACover(parent)
    if not parent then
        parent = cc.Director:getInstance():getRunningScene()
    end
    if parent then
        local cover = YinDao:create()
        parent:addChild(cover, 128, self.Tag.ktag_Cover)
        return cover
    else
        return nil
    end
end

function YinDaoMarg:removeCover(target)
    if not target then
        target = cc.Director:getInstance():getRunningScene()
    end
    if target then
        target:removeChildByTag(self.Tag.ktag_Cover)
    end
end
-- params {
-- 	parent,该指引应该加到哪个父节点
-- 	target,指引的是哪个功能按钮（如果是对话框，该值为nil）
-- 	targPos,
-- 	targSize,
--     targetBeganFunc = nil,
-- 	targCallback,点击引导之后需要响应的回调,
-- 	index = 1,当前加入的引导是该组引导里的第几个
-- 	needNext = true,当该引导是该组引导的最后一步时，是否继续下一步引导,
-- 	updateServer = true,是否需要特殊地更新服务器存储引导步骤,
-- 	extraCallback = nil,是否有额外的处理逻辑
-- 	selfClose = true,是否自己清除,
-- 	offset = cc.p(0,0)手指的偏移量
-- 	delayHand = true,延迟显示手,
-- 	needHandleMove = true,是否处理点击移动,
-- 	isButton = true,当前引导的对象是否为button
-- 	delayRemoveTouch = 0,是否延迟移除当前的遮罩层
-- 	notList = true,当前指引的对象是否为列表对象
-- 	addToRunning = false,
-- 	direction = 2,
-- 	needHideNode = nil 显示隐藏的节点
--     needCloser = false,---是否要求箭头与光圈相邻
--     noLock = true  ,是否锁屏
--     holdMode = false,延迟解屏
--     nextSkip2 = nil,在当前引导完了之后下步要到哪里（如果不传，则默认是紧接着的引导）
--     displayDelay = 1.2 是否延迟显示（visible）
--     visible = fales 是否显示
--     isMode = 1 是否是强引导
-- autoBackMainCity = true 是否自动根据引导表里配置的参数来决定返回到主城
-- }
-- -steps:{group,index}型的数组
function YinDaoMarg:addGuide(params, steps)
    if not params.index then
        params.index = 1
    end
    params.needNext = params.needNext == nil and true or params.needNext
    params.autoBackMainCity = params.autoBackMainCity == nil and true or params.autoBackMainCity
    params.isMode = params.isMode == nil and 1 or params.isMode

    if type(steps) == "table" then
        ------同时加多个
        for k, v in pairs(steps) do
            params.index = v[2]
            if not self._guideList[v[1]] then
                self._guideList[v[1]] = { }
            end
            self._guideList[v[1]][v[2]] = params
        end
    else
        ----一次加一个
        if not self._guideList[steps] then
            self._guideList[steps] = { }
        end
        self._guideList[steps][params.index] = params
    end
    -- print("添加引导后的参数为：")
    -- print_r(self._guideList)
end

function YinDaoMarg:removeGuide(data)
    self._guideList[data.group][data.step] = nil
end

function YinDaoMarg:doNextGuide()
    print("当前的引导组数据： group,index is", self._group, self._index, self._isGuiding)
    if self._group ~= 0 and self._index ~= 0 and not self._isGuiding then
        if self._preIndex == self._index and self._preGroup == self._group and(self._guideLayer ~= nil or self._storyLayer ~= nil) then
            --- 如果当前指定正在显示，则不再重复显示
            return
        else
            self._preIndex = self._index
            self._preGroup = self._group
        end
        -----当引导关卡的时候隐藏关卡本来的箭头
        local guideData, localData = self._guideList[self._group], self._localData[self._group]
        guideData = guideData and guideData[self._index] or nil
        localData = localData and localData[self._index] or nil
        print("***************当前加入的引导数据为：")
        print_r(guideData)
        print_r(localData)
        -- 	dump(localData,"引导 localData")
        if not guideData then
            if localData and localData.parameter then
                local _guideData = self._guideList[self._group]
                guideData = _guideData[localData.parameter]
                if guideData then
                    self._index = localData.parameter
                    self._preIndex = self._index
                else
                    print("the guideData is null")
                    self:releaseGuideLayer()
                    return
                end
            else
                print("the guideData and localData is null")
                self:releaseGuideLayer()
                return
            end
        elseif guideData.needHideNode and type(guideData.needHideNode) == "function" then
            local _arr = guideData.needHideNode()
            if _arr then
                _arr:setVisible(false)
            end
        end
        self._isGuiding = true
        ------------------------------------------------------------------------------------------------------------------------------------------------	
        if guideData.nextSkip2 then
            -----有特中转
            self._group, self._index = guideData.nextSkip2[1], guideData.nextSkip2[2]
        else
            self._index = self._index + 1
        end
        local layer, callback
        if localData.final == 0 or guideData.updateServer then
            --- 该组引导完成	
            self:updateServer( { group = self._group, index = self._index })
            callback = function()
                self._isGuiding = false
                if guideData.extraCallback then
                    guideData.extraCallback()
                end
                self:updateServer( { group = self._group, index = self._index })
                if guideData.needNext == true then
                    self:doNextGuide()
                end
                self._storyLayer = nil
                if guideData.autoBackMainCity and localData.func == 1 then
                    gotoMaincity()
                end
            end
        else
            callback = function()
                self._isGuiding = false
                if guideData.extraCallback then
                    guideData.extraCallback()
                end
                if guideData.needNext == true then
                    self:doNextGuide()
                end
                self._storyLayer = nil
                if guideData.autoBackMainCity and localData.func == 1 then
                    gotoMaincity()
                end
            end
        end
        self:releaseGuideLayer()
        ------------------------------------------------------------------------------------------------------------------------------
        if guideData.addToRunning then
            guideData.parent = cc.Director:getInstance():getRunningScene()
        end
        ------------------------------------------------------------------------------------------------------------------------------		
        if localData.stroyid > 0 then
            --- 是对话框引导
            layer = StoryLayer:createWithParams( { storyId = localData.stroyid, callback = callback, auto = false, opacity = 120 })
            self._storyLayer = layer
        else
            ----功能引导
            for k, v in pairs(self._chapter1Guides) do
                -----除去第一章里的特殊引导层
                if v._blockGuideLayer then
                    v._blockGuideLayer:removeFromParent()
                    v._blockGuideLayer = nil
                end
            end
            layer = YinDao:create( {
                target = guideData.target,
                clickedCallBack = callback,
                needSelfClose = guideData.selfClose,
                isMode = guideData.isMode,
                offset = guideData.offset,
                delayHand = guideData.delayHand,
                needHandleMove = guideData.needHandleMove,
                isButton = guideData.isButton,
                delayRemoveTouch = guideData.delayRemoveTouch,
                notList = guideData.notList,
                targetBox = guideData.targetBox,
                direction = localData.touch,
                needCloser = guideData.needCloser,
                targetBeganFunc = guideData.targetBeganFunc,
                originCallback = guideData.targCallback,
                wordTips = localData.characters,
                -- pos 				= cc.p(localData.x,localData.y),
                action = localData.emo,
            } )
            self._guideLayer = layer
        end
        layer:setName("_guideLayer")
        layer._id = self._id
        guideData.parent:addChild(layer, 128)
        -- 	layer:setVisible((guideData.visible == nil) and true or guideData.visible)
        --------------------------------------------------------------------------------------------------------------------------------------------
        ------在引导层显示特殊需要显示的物品
        local _item = self:getAnItemIcon(localData.icon)
        if _item then
            layer:addChild(_item)
            _item:setPosition(layer:getContentSize().width / 2, layer:getContentSize().height / 2)
        end
        --------------------------------------------------------------------------------------------------------------------------------------------
        if guideData.displayDelay then
            layer:setVisible(false)
            performWithDelay(layer, function()
                layer:setVisible(true)
            end , guideData.displayDelay)
        end
    end
end

function YinDaoMarg:onlyCapter1Guide(params)
    ------第一章的特殊引导
    local parent, target = params.parent, params.target
    if not parent or not target then
        return
    end

    local _block = gameUser.getInstancingId()
    local _guideLayer, _storyLayer = YinDaoMarg:getInstance():getCurrentGuideLayer()
    if _block < 9 and not _guideLayer and not _storyLayer then
        ----关卡小于第一章，并且当前没有其它的引导
        if params.needHideNode then
            params.needHideNode:setVisible(false)
        end
        if not parent._blockGuideLayer then
            parent._blockGuideLayer = YinDao:create( {
                target = target,
                isMode = 1,
                direction = 1,
                isButton = (params.isButton == nil and true or params.isButton),
                extraCall = function()
                    parent._blockGuideLayer:removeFromParent()
                    parent._blockGuideLayer = nil
                    self._chapter1Guides[parent] = nil
                    if params.extraCall and type(params.extraCall) == "function" then
                        params.extraCall()
                    end
                end
            } )
            self._chapter1Guides[parent] = parent
            parent:addChild(parent._blockGuideLayer, 512)
        end
    else
        print("----------------------------the guide layer is not null", _block)
    end
end

function YinDaoMarg:getCurrentGuideLayer()
    return self._guideLayer, self._storyLayer
end

------移除index之后的该组引导，包括index
function YinDaoMarg:releaseGroupGuideFrom(group, index)
    if self._guideList then
        for i = index, #self._guideList[group] do
            self._guideList[group][i] = nil
        end
    end
end

function YinDaoMarg:setCurrentGuideVisibleStatu(statu)
    if self._storyLayer then
        self._storyLayer:setVisible(statu)
    end
    if self._guideLayer then
        self._guideLayer:setVisible(statu)
    end
end

function YinDaoMarg:updateServer(data)
    if not GAME_API then
        print("=======================")
        return
    end
    if data then
        data.version = 1
        ------第几版引导，（主要用于兼容老用户）
    end
    local d = json.encode(data)
    print("=========上传引导状态到服务器保存：")
    print_r(data)
    gameUser.setGuideID(data)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "updateGuide?",
        params = { guides = d },
        successCallback = function(data)
            -- self._isGuiding = false
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            -----"网络请求失败")
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.NONE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function YinDaoMarg:getGuideSteps()
    return self._group, self._index
end
-----获取当前步骤的引导后面的对应关卡ID
function YinDaoMarg:getCurrentStepBlockID()
    if self._group and self._index then
        local _data = self._localData[self._group]
        _data = _data and _data[self._index] or nil
        if _data then
            return _data.stageid
        else
            return -1
        end
    else
        return -1
    end
end

function YinDaoMarg:releaseGuideLayer()
    if self._guideLayer then
        self._guideLayer:removeFromParent()
        self._guideLayer = nil
    end
end
-----通过引导ID来跳转引导 
function YinDaoMarg:skipGuideTo(group, _index)
    _index = _index or 1
    local data = { group = group, index = _index }
    gameUser.setGuideID(data)
end
-----通过引导组和引导步骤来跳转引导,needsave 是否需要服务器记住该步引导； noSetGameUser 是否需要重新设置gameUser里的引导步
function YinDaoMarg:skipGuideOnGI(group, index, needSave, noSetGameUser)
    if not group or not index or group <= 0 or index <= 0 then
        return
    end
    local _data = { group = group, index = index }
    if not noSetGameUser then
        self._group, self._index = group, index
    end
    if needSave then
        self:updateServer(_data)
    end
end
------处理特殊的引导情况(重新登录进游戏之后)
function YinDaoMarg:handleSpecial(data)
    if not data or(type(data) == "table" and data.version ~= 1) then
        ----无效的引导
        print("the guide is unavailable")
        self._group, self._index = 0, 0
        return
    end
    if data.group and data.group<0 then
        return
    end
    self._index = data.index
    local levelGroup = self._triggers[1][gameUser.getLevel()]
    -----当前等级触发的引导组
    local blockGroup = self._triggers[2][gameUser.getInstancingId()]
    -----当前关卡触发的引导组
    if type(data) == "table" then
        self._group = data.group
        if levelGroup and data.group ~= levelGroup then
            self._group = levelGroup
        elseif blockGroup and data.group ~= blockGroup then
            self._group = blockGroup
        end
    else
        if levelGroup then
            self._group = levelGroup or 0
        else
            self._group = blockGroup or 0
        end
        self._index = 1
    end
    -- --------------------本地跳转
    local jumpData = self._localData[self._group]
    jumpData = jumpData and jumpData[self._index] or nil
    if jumpData and jumpData.parameter ~= 0 then
        self._index = jumpData.parameter
    end
end
-----结束当前整组引导,是否需要重新引导
function YinDaoMarg:overCurrentGuide(noMode, group)
    print("wanted over guide group is", group)
    local _group, _index = nil, nil
    if group and self._group and group >= self._group then
        _group = group
        _index = 1
    elseif group == nil then
        _group, _index = self._group, self._index
    end
    print("overed current guide id", _group)
    if _group and _index then
        self._guideList[_group] = { }
        local data = self._localData[_group]
        data = data and data[#data] or nil
        if data then
            local _skip = data.jumpgroup
            data = self._localData[_skip]
            if data and data[1] and self._group and data[1].group > self._group then
                self:skipGuideTo(_skip, 1)
                self:updateServer( { group = _skip, index = 1 })
            end
        end
    end
    if noMode then
        self:releaseGuideLayer()
    end
end
-------试着再次引导上一步(能成功再次引导是有条件的，即neednext = false)
function YinDaoMarg:tryReguide()
    local _guideLayer = self:getCurrentGuideLayer()
    if _guideLayer then
        _guideLayer:resetClickCounter()
    end
end

function YinDaoMarg:guideTouchEnd()
    xpcall( function()
        print("at guide touchend call function")
        local _data = self._guideList[self._preGroup]
        _data = _data and _data[self._preIndex] or nil
        if self:getCurrentGuideLayer() and _data and _data.target then
            if _data.target == self:getCurrentGuideLayer():getCurrentElement() then
                print("the xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
                self:getCurrentGuideLayer():doTouchedTarget()
                print("release guide layer at function guide to end")
            end
        end
    end , function()
        print("the guide has occured error,the group is ,the index is", self._group, self._index)
        self._skipGuide = true
    end )
end

function YinDaoMarg:reset()
    self._guideLayer = nil
    self._guideList = { }
    self._isGuiding = false
    self._index = 1
    self._group = 0
    self._preIndex = 0
    self._preGroup = 0
    self._skipGuide = false
    self._storyLayer = nil
    self._battlePVEFailTimes = 0
    self._instance = nil
    self._chapter1Guides = { }
end

-----当前引导触发之后是否需要回到主城
function YinDaoMarg:isCurtGuideNeed2MainCity()
    if self._guideLayer then
        local _data = self._localData[self._preGroup]
        _data = _data and _data[self._preIndex] or nil
        if _data then
            return _data.func == 1
        end
    end
    return false
end
----通过ID创建一个物品的图标
function YinDaoMarg:getAnItemIcon(id)
    local _itemData = { }
    local _itemNode = nil
    if id and id ~= 0 then
        local _index = string.split(id, ",")
        local _allData = gameData.getDataFromCSV("ExploreInfoList")
        local _data = _allData[tonumber(_index[1])]
        _data = _data and _data.firstiawardid or nil
        if _data then
            _data = string.split(_data, ",")
            _data = _data[tonumber(_index[2])]
            _data = string.split(_data, "#")
            ----物品的，1 类型，2 id,3数量
            for i = 1, #_data do
                _itemData[i] = _data[i]
            end
        end
    end
    if #_itemData > 0 then
        _itemNode = ItemNode:createWithParams( {
            _type_ = tonumber(_itemData[1]),
            itemId = _itemData[2],
            count = tonumber(_itemData[3]),
            isShowCount = false,
            needSwallow = true,
        } )
    end
    if _itemNode then
        _itemNode:setScale(1.5)
        local _circle = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/teshu.json", "res/spine/effect/exchange_effect/teshu.atlas", 1)
        _circle:setPosition(_itemNode:getContentSize().width / 2, _itemNode:getContentSize().height / 2)
        _itemNode:addChild(_circle)
        _circle:setAnimation(0, "animation", true)
    end

    return _itemNode
end

function YinDaoMarg:increaseBattleTimes()
    self._battlePVEFailTimes = self._battlePVEFailTimes + 1
    return self._battlePVEFailTimes
end

-----引导触发 0助手触发，1等级触发，2 关卡触发
function YinDaoMarg:triggerGuide(_type, condition)
    local _group = self._triggers[_type][condition]
    if _group then
        local _guideData = self._localData[_group]
        _guideData = _guideData and _guideData[1] or nil
        if _type > 0 then
            if _guideData and _guideData.pic ~= 0 then
                ----开头带着新功能开启的
                self._group = _group
                self._index = 2
                if _type == 1 then
                    FunctionYinDao.isLevelUp = true
                    ----- 提示新功能开启
                elseif _type == 2 then
                    FunctionYinDao.warIsWin = true
                    ----- 提示新功能开启
                end
                FunctionYinDao:showNewFunction()
                self:updateServer( { group = self._group, index = self._index })
            elseif _guideData and _guideData.pic == 0 then
                self._group = _group
                self._index = 1
                self:updateServer( { group = self._group, index = self._index })
            end
        else
            self._group = _group
            self._index = 1
            gotoMaincity()
            self:doNextGuide()
        end
    end
end