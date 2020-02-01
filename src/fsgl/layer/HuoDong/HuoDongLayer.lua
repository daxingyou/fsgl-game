--[=[
    FileName:HuoDongLayer.lua
    Autor:xingchen
    Date:2015.11.13
    Content:新活动界面
    PS:临时的活动界面
]=]
local HuoDongLayer = class("HuoDongLayer", function(tab)
    return XTHD.createBasePageLayer()
end)

function HuoDongLayer:ctor(tab)
    local layer = cc.LayerColor:create(cc.c4b(0,0,0, 255*0.4))
    self:addChild(layer)
    self._inited = false
    self._contentBg = nil
    self._tableView = nil
    self.selectedIndex = 0
    self.selectedTab = nil
    XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_ACTIVITIESTAB_REDPOINT,node = self,callback = function(event)
        self:refreshTabRedPoint()
    end})

    self:getOpenActivity()
	self:switchTab(tab)


end

function HuoDongLayer:onCleanup()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/activities/activitiesContent_bg.png")
    for i=1, 8 do
        textureCache:removeTextureForKey("res/image/activities/activitiesTab_" .. i .. ".png")
    end
    helper.collectMemory()
end

function HuoDongLayer:initWithData()
    --[[右边的tab]]
    local _topBarHeight = self.topBarHeight
    local size=self:getContentSize()

    local _contentBg = cc.Sprite:create("res/image/activities/activitiesContent_bg.png")
    self._contentBg = _contentBg
    local bsize=_contentBg:getContentSize()

    --contentBg下面需要多留10pixels
    local _tableViewSize = cc.size(bsize.width-120,115) 
    local _midHeight = bsize.height +_tableViewSize.height - 17
    local _contentPosY = (size.height - _topBarHeight - _midHeight)/2+ 50
    _contentBg:setAnchorPoint(cc.p(0.5,0))
    _contentBg:setPosition(cc.p(size.width/2,_contentPosY))
    self:addChild(_contentBg)

    local _tableViewCellSize = cc.size(150,_tableViewSize.height)
    self._tableView = cc.TableView:create(_tableViewSize)
	TableViewPlug.init(self._tableView)
    -- self._tableView:setBounceable(false)
    self._tableView:setPosition((size.width-_tableViewSize.width)/2 + 1,_contentBg:getPositionY()+bsize.height - 115)
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) 
    self._tableView:setDelegate()
    self:addChild(self._tableView)
	
	self._tableView.getCellNumbers =  function(table)
        return self._tabNumber
    end
    
	self._tableView.getCellSize = function(table, idx)
        return _tableViewCellSize.width, _tableViewCellSize.height
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
			cell:setContentSize(_tableViewCellSize.width, _tableViewCellSize.height)
        end
        local _cellBtn = XTHD.createButton({
            normalFile = "res/image/activities/actTab_normal.png",
            selectedFile = "res/image/activities/actTab_selected.png",
            text = self._activityOpen[idx+1].title,
            fontSize = 24,
            fontColor = cc.c3b(254,202,2),------每日活动
            needSwallow = false,
            touchSize = cc.size(137,200),
            anchor = cc.p(0.5,0),
            pos = cc.p(_tableViewCellSize.width*0.5,5),
            needEnableWhenMoving = true,
			isScrollView = true,
        })
        _cellBtn:getLabel():setPositionX(_cellBtn:getLabel():getPositionX()-2)
        _cellBtn:getLabel():setPositionY(_cellBtn:getLabel():getPositionY() - 1)
        _cellBtn:setScaleY(0.85)
        _cellBtn:setName("cellBtn")
        _cellBtn.selected = false
        self._activityOpen[idx + 1].button = _cellBtn
        _cellBtn:setTouchEndedCallback(function()
				 self.selectedIndex = idx
                _cellBtn:setSelected(true)
                _cellBtn:setLabelColor(cc.c3b(122,27,27))
                -- _cellBtn:getLabel():setPositionX(_cellBtn:getLabel():getPositionX()-2)
                -- _cellBtn:getLabel():setPositionY(_cellBtn:getLabel():getPositionY()+2)
                _cellBtn.selected = true
                if self.selectedTab~=nil then
                    self:addTabRedPoint(self.selectedTab,self.selectedIndex)
                    self.selectedTab:setSelected(false)
                    self.selectedTab:setLabelColor(cc.c3b(254,202,2))------每日活动
                    self.selectedTab.selected = false
                    self.selectedTab = nil
                end
                self.selectedTab = _cellBtn
                if _cellBtn:getChildByName("redPoint") then
                    _cellBtn:removeChildByName("redPoint")
                end
                self:switchTab(idx+1)
            end)
        
        if self.selectedIndex == idx then
            if self.selectedTab~=nil then
                self.selectedTab:setSelected(false)
                self.selectedTab:setLabelColor(cc.c3b(254,202,2))------每日活动
                self.selectedTab.selected = false
                self.selectedTab = nil
            end
            self.selectedTab = _cellBtn
            _cellBtn:setSelected(true)
            _cellBtn:setLabelColor(cc.c3b(122,27,27))
            _cellBtn.selected = true
        else
            self:addTabRedPoint(_cellBtn,idx)
        end
        local _activityData = self._activityOpen[idx+1] or {}
        
        --local _tabSp = cc.Sprite:create("res/image/activities/activitiesTab_" .. (_activityData.pictureid or 1) .. ".png")
        --_tabSp:setAnchorPoint(cc.p(0.5,0))
        -- _tabSp:setScale(0.8)
        --_tabSp:setPosition(cc.p(_tableViewCellSize.width/2,_cellBtn:getContentSize().height-10))
        --cell:addChild(_tabSp)

        cell:addChild(_cellBtn)
        return cell
    end
    self._tableView:registerScriptHandler(self._tableView.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(self._tableView.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:reloadData()
end


function HuoDongLayer:getOpenActivity(tab)

    local activityStatic = {
        --军需物资
        [1] = {
            url = "wishState?",                  --请求接口
            file = "JunXuWuZiLayer.lua",            --跳转文件
            title = LANGUAGE_KEY_ACTIVITYTAB[2], --title名
            priority = 5000,                     --优先级
            isOpen = 0,                          -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 5,                        -- 活动开启id，后端控制
            pictureid = 2,
            redPointid = 10,
        },
        --元宝转转转
        [2] = {
            url = "yaoGoldWindow?",
            file = "SlotsIngotLayer.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[3],
            priority = 6000,
            isOpen = 0,
            isOpenid = 1,
            pictureid = 3,
            redPointid = 11,
        },
        --百万富翁
        [3] = {
            url = "yaoSilverWindow?",
            file = "BaiWanFuWongLayer.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[4],
            priority = 7000,
            isOpen = 0,
            isOpenid = 2,
            pictureid = 4,
            redPointid = 12,
        },
        --每日签到
        [4] = {
            url = "getCheckInDailyList?",
            file = "MeiRiQianDaoLayer.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[5],
            priority = 2000,
            isOpen = 1,
            isOpenid = 0,
            pictureid = 5,
            redPointid = 1,
        },
        --累计登录
        [5] = {
            url = "loginRecord?",
            file = "LeiJiDengLuLayer.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[6],
            priority = 3000,
            isOpen = 1,
            isOpenid = 0,
            pictureid = 6,
            redPointid = 2,
        },
        --在线奖励
        [6] = {
            url = "timeRewardRecord?",
            file = "ZaiXianJiangLiLayer.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[7],
            priority = 4000,
            isOpen = 1,
            isOpenid = 0,
            pictureid = 7,
            redPointid = 3,
        },
        --冲级奖励
        [7] = {
            url = "levelRewardRecord?",
            file = "ChongJiJiangLiLayer.lua",
            title = LANGUAGE_KEY_ACTIVITYTAB[8],
            priority = 1000,
            isOpen = 1,
            isOpenid = 0,
            pictureid = 8,
            redPointid = 4,
        },
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
    -- local getOpen = {}
    -- --按活动优先级排序 priority大排前面
    -- for i = 1, table.nums(openParams) do
    --     if openParams[i] == 1 then
    --         getOpen[#getOpen + 1] = activityStatic[i]
    --     end
    -- end
    
    -- table.sort(getOpen, function(a,b)
    --     return a.priority > b.priority
    -- end)
    -- self._activityOpen = {}
    -- for k,v in pairs(getOpen) do
    --     self._activityOpen[#self._activityOpen + 1] = v
    -- end
end

function HuoDongLayer:switchTab(tab)
	-- dump(self._activityOpen)
    print("tab="..tab)
    local tabIdx = tonumber(tab or 1)
	if self._inited == false then
            self:initWithData()
            self._inited = true
            LayerManager.addLayout(self)
            -- XTHD.runActionPop(self._contentBg)
    end
    local turnToOtherActFunc = function(data)
		if self._contentBg ~= nil then
        if self._contentBg:getChildByName("activityTabLayer") then
            self._contentBg:removeChildByName("activityTabLayer")
        end
	end
        -- data里面保存红点位置 用来传递到子界面
        data.redPointid = self._activityOpen[tabIdx].redPointid

        layer = requires("src/fsgl/layer/HuoDong/" .. self._activityOpen[tabIdx].file):create({httpData = data,parentLayer = self})
        layer:setName("activityTabLayer")
        layer:setAnchorPoint(cc.p(0.5,0))
        layer:setScale(0.92)
        layer:setPosition(cc.p(self._contentBg:getContentSize().width/2,33))
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
    self.selectedIndex = tab - 1
    self.selectedTab:setSelected(false)
    self.selectedTab.selected = false
    self.selectedTab:setLabelColor(cc.c3b(254,202,2))
    self._activityOpen[tab].button:setSelected(true)
    self._activityOpen[tab].button.selected = true
    self._activityOpen[tab].button:setLabelColor(cc.c3b(122,27,27))
    self.selectedTab = self._activityOpen[tab].button
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

function HuoDongLayer:addTabRedPoint(_target,_idx)
    if _target==nil or _idx == nil then
        return 
    end
    if _target:getChildByName("redPoint") then
        _target:removeChildByName("redPoint")
    end
    local _redPointState = gameUser.getActivibyStatus() or {}
    local _redPointId = self._activityOpen[_idx + 1].redPointid or 0

	RedPointState[4].state = 0
    if _redPointState[_redPointId]~=nil and tonumber(_redPointState[_redPointId])==1 then
        local _redPointSp = cc.Sprite:create("res/image/common/heroList_redPoint.png")
        _redPointSp:setName("redPoint")
        _redPointSp:setAnchorPoint(cc.p(1,1))
        _redPointSp:setPosition(cc.p(_target:getContentSize().width+10,_target:getContentSize().height))
        _target:addChild(_redPointSp)
    end
	self:updateMainCityRedPoint()
end

function HuoDongLayer:updateMainCityRedPoint()
	RedPointState[4].state = 0
	for i = 1, self._tabNumber do
		local _redPointState = gameUser.getActivibyStatus() or {}
		local _redPointId = self._activityOpen[i].redPointid or 0
		if _redPointState[_redPointId]~=nil and tonumber(_redPointState[_redPointId])==1 then
			RedPointState[4].state = 1
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "activity"}})
			return
		end
	end
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "activity"}})
end

function HuoDongLayer:refreshTabRedPoint()
    self._tableView:reloadDataAndScrollToCurrentCell()
end

function HuoDongLayer:createWithTab(tab)
    return HuoDongLayer.new(tab)
end

return HuoDongLayer