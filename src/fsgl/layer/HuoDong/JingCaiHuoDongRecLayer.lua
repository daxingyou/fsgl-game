--[=[
    FileName:JingCaiHuoDongRecLayer.lua
    Autor:赵俊路
    Date:2019.05.31
    Content:精彩活动界面
    PS:临时的活动界面
]=]
local JingCaiHuoDongRecLayer = class("JingCaiHuoDongRecLayer", function(tab)
    return XTHD.createBasePageLayer({bg ="res/image/activities/carnival_bg1.png" })
end)

function JingCaiHuoDongRecLayer:ctor(tab)
	
    self._inited = false
    self.fresh = true
	self:getChildByName("BgSprite"):setPosition(self:getContentSize().width/2,self:getContentSize().height/2 - 7)
    self._contentBg = nil
    self._tableView = nil
    self.selectedIndex = 0
    self.selectedTab = nil
    self.cellTable = {}
    XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_ACTIVITIESTAB_REDPOINT,node = self,callback = function(event)
        if self.fresh then
            print("刷新精彩活动小红点")
            self:refreshTabRedPoint()
        end  
    end})

    self:getOpenActivity()
    self:switchTab(tab)
end

function JingCaiHuoDongRecLayer:onCleanup()
    self.fresh = false
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_ACTIVITIESTAB_REDPOINT) 
    RedPointState[2].state = gameUser.getWonderfulPointDot()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "jchd"}})  
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/activities/actReContent_bg.png")
    -- for i=1, 8 do
    --     textureCache:removeTextureForKey("res/image/activities/activitiesTab_" .. i .. ".png")
    -- end
    textureCache:removeTextureForKey("res/image/activities/tabstyle_normal.png")
    textureCache:removeTextureForKey("res/image/activities/tabstyle_sel.png")
    helper.collectMemory()
end

function JingCaiHuoDongRecLayer:initWithData()
    --[[右边的tab]]
    local _topBarHeight = self.topBarHeight
    local _contentBg = cc.Sprite:create("res/image/activities/carnival_bg2.png")
	_contentBg:setScale(0.95)
    -- _contentBg:setOpacity(0)
    self._contentBg = _contentBg

    local _tableViewSize = cc.size(_contentBg:getContentSize().width - 20*6.5, 50)
    --contentBg下面需要多留10pixels
    local _contentPosY = (self:getContentSize().height - _topBarHeight)/2
    _contentBg:setAnchorPoint(cc.p(0.5,0.5))
    _contentBg:setPosition(cc.p(self:getContentSize().width/2,_contentPosY))
    self:addChild(_contentBg)

    local stone = cc.Sprite:create("res/image/activities/stone.png")
    self._contentBg:addChild(stone,10)
    stone:setPosition(self._contentBg:getContentSize().width - 80,40)

    -- local _leftSp = cc.Sprite:create("res/image/activities/actAdorn_left.png")
    -- _leftSp:setPosition(cc.p(_contentBg:getBoundingBox().x+63,_contentBg:getBoundingBox().y+35))
    -- _leftSp:setScale(0.6)
    -- self:addChild(_leftSp)
    -- local _rightSp = cc.Sprite:create("res/image/activities/actAdorn_right.png")
    -- _rightSp:setPosition(cc.p(_contentBg:getBoundingBox().x + _contentBg:getBoundingBox().width -58,_contentBg:getBoundingBox().y+15))
    -- _rightSp:setScale(0.7)
    -- self:addChild(_rightSp)

    local _tableViewCellSize = cc.size(145, _tableViewSize.height)
    self._tableView = cc.TableView:create(_tableViewSize)
    self._tableView:setTouchEnabled(true)
    -- self._tableView:setBounceable(false)
    self._tableView:setPosition((_contentBg:getContentSize().width - _tableViewSize.width) / 2 - 2,_contentBg:getContentSize().height - 112)
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) 
    self._tableView:setDelegate()
    -- self._tableView:setCascadeOpacityEnabled( false )
    _contentBg:addChild(self._tableView)

    local function numberOfCellsInTableView(table)
        return self._tabNumber
    end
	local _size = cc.size(_tableViewCellSize.width+10,_tableViewCellSize.height)
    local function cellSizeForTable(table, idx)
        return _tableViewCellSize.width+10,_tableViewCellSize.height
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if cell then
            if cell:getChildByName("cellBtn") then
                local _cellBtn = cell:getChildByName("cellBtn")
                if _cellBtn.selected and _cellBtn.selected==true then
                    _cellBtn.selected = false
                    self.selectedTab = nil
                end
            end
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
			cell:setContentSize(_tableViewCellSize.width+10,_tableViewCellSize.height)
        end
		cell:setContentSize(_size)
        self.cellTable[idx + 1] = cell
        local _cellBtn = XTHD.createButton({
            normalFile = "res/image/activities/tabstyle_normal.png",
            selectedFile = "res/image/activities/tabstyle_sel.png",
            text = self._activityOpen[idx+1].title,
            fontSize = 22,
            fontColor = cc.c3b(171, 154, 109),
            needSwallow = false,
            touchSize = cc.size(140,55),
            anchor = cc.p(0.5,0.5),
			isScrollView = true,
            pos = cc.p(_tableViewCellSize.width*0.5+10,_tableViewCellSize.height*0.5-5),
            needEnableWhenMoving = true,
        })
        _cellBtn:getLabel():setPositionX(_cellBtn:getLabel():getPositionX() + 10)
        _cellBtn:getLabel():setPositionY(_cellBtn:getLabel():getPositionY() - 2)
        _cellBtn:setScaleY(0.85)
        _cellBtn:setName("cellBtn")
        _cellBtn.selected = false
        self:addTabRedPoint(_cellBtn,idx)
        _cellBtn:setTouchEndedCallback(function()
				self.selectedIndex = idx
                _cellBtn:setSelected(true)
                _cellBtn:setLabelColor(cc.c3b(78, 67, 53))
                -- _cellBtn:getLabel():setPositionX(_cellBtn:getLabel():getPositionX()-2)
                -- _cellBtn:getLabel():setPositionY(_cellBtn:getLabel():getPositionY()+2)
                _cellBtn.selected = true
                -- if _cellBtn:getChildByName("redPoint") then
                --     _cellBtn:removeChildByName("redPoint")
                -- end
                if self.selectedTab~=nil then
                    -- self:addTabRedPoint(self.selectedTab,self.selectedIndex)
                    self.selectedTab:setSelected(false)
                    self.selectedTab:setLabelColor(cc.c3b(171, 154, 109))
                    self.selectedTab.selected = false
                    self.selectedTab = nil
                end
                self.selectedTab = _cellBtn
                self.selectedIndex = idx
                
                self:switchTab(idx+1)
            end)
        
        if self.selectedIndex == idx then
            if self.selectedTab~=nil then
                -- self:addTabRedPoint(_cellBtn,idx)
                self.selectedTab:setSelected(false)
                self.selectedTab:setLabelColor(cc.c3b(171, 154, 109))
                self.selectedTab.selected = false
                self.selectedTab = nil
            end
            self.selectedTab = _cellBtn
            _cellBtn:setSelected(true)
            _cellBtn:setLabelColor(cc.c3b(78, 67, 53))
            _cellBtn.selected = true
        else
            -- self:addTabRedPoint(_cellBtn,idx)
        end
        local _activityData = self._activityOpen[idx+1] or {}
        -- local _tabSp = cc.Sprite:create("res/image/activities/activitiesTab_" .. (_activityData.pictureid or 1) .. ".png")
        -- _tabSp:setAnchorPoint(cc.p(0.5,0))
        -- _tabSp:setPosition(cc.p(_tableViewCellSize.width/2,_cellBtn:getContentSize().height))
        -- cell:addChild(_tabSp)

        cell:addChild(_cellBtn)
        return cell
    end
    self._tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:reloadData()
end

-- 
function JingCaiHuoDongRecLayer:getOpenActivity()

    local activityStatic = {
         --至尊转盘
         [1] = {
            url = "turnTableWindow?",
            file = "ZhiZunZhuanPan.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[1],
            priority = 950,
            isOpen = 0,                             -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 6,                           -- 活动开启id，后端控制
            -- gameUser.getActivityLoginRewardState(),
            -- pictureid = 1,
            redPointid = 15,
        },
        --特权奖励
        [2] = {
            url = "powerGiftList?",
            file = "TeQuanJiangLiLayer.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[10],
            priority = 900,
            isOpen = 1,
            isOpenid = 0,
            -- pictureid = 10,
            redPointid = 14,
        },
        --首充奖励
        [3] = {
            file = "ShouCiChongZhiLayer.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[11],
            priority = 700,
            isOpen = 0, -- gameUser.getFirstPayState() < 2 and 1 or 0,
            isOpenid = 0,
            -- pictureid = 11,
            redPointid = 0,
        },
        -- 连续充值
        [4] = {
            url = "continuousPayRewardList?",
            file = "LianXuChongZhiLayer.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[12],
            priority = 850,
            isOpen = 1,
            isOpenid = 0,
            -- pictureid = 12,
            redPointid = 6,
        },
        -- vip每日奖励
        [5] = {
            file = "VipGongZiLayer.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[14],
            priority = 725,
            isOpen = 1,
            isOpenid = 0,
            -- pictureid = 12,
            redPointid = 8,
        },
        -- 单笔好礼
        [6] = {
            url = "rechargeMeetRewardList?",
            file = "DanBiHaoLiLayer.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[16],
            priority = 900,
            isOpen = 0,
            isOpenid = 41,
            -- pictureid = 12,
            redPointid = 16,
        },
        --累计充值
        [7] = {
            url = "totalPayRewardList?",
            file = "TotalRechargeLayer1.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[13],
            priority = 750,
            isOpen = 0,
            isOpenid = 10,
            -- pictureid = 11,
            redPointid = 5,
        },
        --单笔充值
        -- [8] = {
        --     url = "singlePayRewardList?",
        --     file = "DanBiChongZhiLayer.lua",
        --     title = LANGUAGE_KEY_ACTIVITYTAB[9],
        --     priority = 800,
        --     isOpen = 0,
        --     isOpenid = 4,
        --     -- pictureid = 9,
        --     redPointid = 9,
        -- },
       
        -- 投资计划
--        [9] = {
--            url = "InvestPlanRecord?",
--            file = "TouZiJiHuanLayer.lua",
--            title = LANGUAGE_KEY_ACTIVITYTAB[15],
--            priority = 725,
--            isOpen = 1,
--            isOpenid = 0,
--            -- pictureid = 12,
--            redPointid = 13,
--        },
    }
    self._activityOpen = {}
    local _openState = gameUser.getActivityOpenStatus() or {}
    for i=1,#activityStatic do
        if tonumber(activityStatic[i].isOpen) == 1  then
            self._activityOpen[#self._activityOpen + 1] = activityStatic[i]
        else
            local activityState = _openState[tostring( activityStatic[i].isOpenid or 0 )] or 0
            if tonumber( activityState ) == 1 then
                self._activityOpen[#self._activityOpen + 1] = activityStatic[i]
            end
        end
    end
    table.sort(self._activityOpen,function(data1,data2)
            return tonumber(data1.priority)<tonumber(data2.priority)
        end)
    self._tabNumber = table.nums(self._activityOpen)
end

function JingCaiHuoDongRecLayer:switchTab(tab)
    print("tab="..tab)
    local tabIdx = tonumber(tab or 1)
	
	if self._inited == false then
            self:initWithData()
            self._inited = true
            LayerManager.addLayout(self)
            -- XTHD.runActionPop(self._contentBg)
     end
    local turnToOtherActFunc = function(data)
       
        if self._contentBg:getChildByName("activityTabLayer") then
            self._contentBg:removeChildByName("activityTabLayer")
        end

        -- 加载新的活动界面
        local layer = requires("src/fsgl/layer/HuoDong/" .. self._activityOpen[tabIdx].file):create({httpData = data,parentLayer = self})
        layer:setName("activityTabLayer")
        layer:setAnchorPoint(cc.p(0.5,0))
        layer:setScale(0.9)
        layer:setPosition(cc.p(self._contentBg:getContentSize().width/2 - 3, 76))
        -- layer:setCascadeOpacityEnabled( false )
        self._contentBg:addChild(layer)
    end


    if  self._activityOpen[tabIdx] ==nil then
        return
    end
    -- if self._modulesTable[tabIdx] ==nil then
    --     turnToOtherActFunc()
    --     return
    -- end
    if not self._activityOpen[tabIdx].url then
        turnToOtherActFunc()
    else
        ClientHttp:httpActivity(self._activityOpen[tabIdx].url,self,function(data)
                turnToOtherActFunc(data)
            end,{})
    end
    -- XTHDHttp:requestAsyncInGameWithParams({
    --     modules = self._activityOpen[tabIdx].url
    --     ,successCallback = function(data)
    --         if tonumber(data.result) == 0 then
    --             turnToOtherActFunc(data)
    --         else
    --             XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
    --         end
    --     end,--成功回调
    --     failedCallback = function()
    --         XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
    --     end,--失败回调
    --     targetNeedsToRetain = self,--需要保存引用的目标
    --     loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    -- })
end

function JingCaiHuoDongRecLayer:addTabRedPoint(_target,_idx)
    -- do return end
    if _target==nil or _idx == nil then
        return 
    end
    if _target:getChildByName("redPoint") then
        _target:removeChildByName("redPoint")
    end
    local _redPointState = gameUser.getActivibyStatus() or {}
    local _redPointId = self._activityOpen[_idx+1].redPointid or 0
    if _redPointState[_redPointId]~=nil and tonumber(_redPointState[_redPointId])==1 then
        local _redPointSp = cc.Sprite:create("res/image/common/heroList_redPoint.png")
        _redPointSp:setName("redPoint")
        _redPointSp:setAnchorPoint(cc.p(0,1))
        _redPointSp:setPosition(cc.p(0,_target:getContentSize().height+5))
        _target:addChild(_redPointSp)
    end
end

function JingCaiHuoDongRecLayer:refreshTabRedPoint()
    -- self._tableView:reloadDataAndScrollToCurrentCell()
    for i = 1,#self.cellTable do
        if self.cellTable[i]:getChildByName("cellBtn"):getChildByName("redPoint") then
            self.cellTable[i]:getChildByName("cellBtn"):getChildByName("redPoint"):setVisible(false)
        end
        local _redPointState = gameUser.getActivibyStatus() or {}
        local _redPointId = self._activityOpen[i].redPointid or 0
        if _redPointState[_redPointId]~=nil and tonumber(_redPointState[_redPointId])==1 then
            self.cellTable[i]:getChildByName("cellBtn"):getChildByName("redPoint"):setVisible(true)
        end
    end

end

function JingCaiHuoDongRecLayer:createWithTab(tab)
    return JingCaiHuoDongRecLayer.new(tab)
end

return JingCaiHuoDongRecLayer