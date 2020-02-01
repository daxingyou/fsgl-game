
local Bingfenfuli = class("Bingfenfuli", function(tab)
    return XTHD.createPopLayer()
end)

function Bingfenfuli:ctor()
	self._openState = {}
    self._inited = false
    self._tableView = nil
    self.selectedIndex = 0
    self.selectedTab = nil
    self.redDotTable = {}
	self._btnTable = {}
	self:getOpenActivity()
	self._exist = true
    self:switchTab(1)
	

	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_ACTIVITY_BFYL,callback = function()
		if self._exist then
        	self:freshRedDot()
        end
    end})
end

function Bingfenfuli:onEnter()

end

function Bingfenfuli:onExit()
	self._exist = false
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_ACTIVITY_BFYL)
end

function Bingfenfuli:onCleanup()

end

function Bingfenfuli:initWithData()
    --[[左边的tab]]

    local _contentBg = cc.Sprite:create("res/image/activities/Bingfenfuli/bg.png")
    self._contentBg = _contentBg
	_contentBg:setAnchorPoint(cc.p(0.5,0.5))
    _contentBg:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
    self:addContent(_contentBg)
	self._activityBg = _contentBg
	
	local btn_close = XTHDPushButton:createWithFile({
		normalFile = "res/image/activities/Bingfenfuli/bingfen_close_up.png",
		selectedFile = "res/image/activities/Bingfenfuli/bingfen_close_down.png",
		musicFile = XTHD.resource.music.effect_btn_commonclose,
		endCallback  = function()
           self:hide()
		end,
	})
	self._activityBg:addChild(btn_close)
	btn_close:setPosition(self._activityBg:getContentSize().width - btn_close:getContentSize().width - 10,self._activityBg:getContentSize().height - btn_close:getContentSize().height + 10)
	
    --bg2
    local bg2 = ccui.Scale9Sprite:create("res/image/activities/Bingfenfuli/btn_bg.png")
	bg2:setAnchorPoint(0,0.5)
    bg2:setPosition(bg2:getContentSize().width*0.5 - 30,_contentBg:getContentSize().height/2-35)
    _contentBg:addChild(bg2)

    local btn_listView = ccui.ListView:create()
    btn_listView:setContentSize(bg2:getContentSize().width - 5,bg2:getContentSize().height - 4)
    btn_listView:setDirection(ccui.ScrollViewDir.vertical)
    btn_listView:setBounceEnabled(true)
	btn_listView:setScrollBarEnabled(false)
	btn_listView:setSwallowTouches(true)
    bg2:addChild(btn_listView,2)
    btn_listView:setPosition(cc.p(0,2))
    self._btn_listView = btn_listView

	for i = 1, self._tabNumber do
		local layout = ccui.Layout:create()
		layout:setContentSize(btn_listView:getContentSize().width + 5,65)
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/activities/Bingfenfuli/btn_" .. self._activityOpen[i].pictureid .. "_up.png",
			selectedFile = "res/image/activities/Bingfenfuli/btn_" .. self._activityOpen[i].pictureid .. "_down.png",
			isScrollView = true,
			needEnableWhenMoving = true,
			endCallback  = function()
				 self:switchTab(i)
			end,
		})
		self._btnTable[#self._btnTable + 1] = btn
		btn:setSwallowTouches(false)
		layout:addChild(btn)
		btn:setPosition(layout:getContentSize().width * 0.5,layout:getContentSize().height * 0.5)
		self._btn_listView:pushBackCustomItem(layout)
		self:addTabRedPoint(btn,i - 1)
	end
	self:freshRedDot()
end


function Bingfenfuli:getOpenActivity()

    local activityStatic = {
        --成长基金
		[1] = {
            url = "growthFundList?",
            file = "ChengZhangJiJin",
            -- title = LANGUAGE_KEY_ACTIVITYTAB[13],
            priority = 750,
            isOpen = 1,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 0,                   -- 活动开启id，后端控制
            pictureid = 1,
			redPointId = 19,
        },
		--首充团购
		[2] = {
            url = "fristGroupList?",
            file = "Shouchongtuangou.lua",
            -- title = LANGUAGE_KEY_ACTIVITYTAB[13],
            priority = 800,
            isOpen = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 48,                   -- 活动开启id，后端控制
            pictureid = 2,
			redPointId = 20,
        },
		--限时抢购
        [3] = {
            url = "openServerDiscountShopList?",
            file = "Xianshiqianggou.lua",
            -- title = LANGUAGE_KEY_ACTIVITYTAB[13],
            priority = 850,
            isOpen = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 49,                   -- 活动开启id，后端控制
            pictureid = 3,
			redPointId = 21,
        },
        --单笔充值
        [4] = {
            url = "singlePayRewardList?",
            file = "NewDanBiChongZhiLayer.lua", 
            -- title = LANGUAGE_KEY_ACTIVITYTAB[13],
            priority = 900,
            isOpen = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 4,                   -- 活动开启id，后端控制
            pictureid = 4,
        },
	}
	local _openState = gameUser.getActivityOpenStatus() or {}
	self._activityOpen = {}
	for i=1,#activityStatic do
		if tonumber(activityStatic[i].isOpen) == 1  then
			if gameUser.getGrowthFund() == 1 then
				self._activityOpen[#self._activityOpen + 1] = activityStatic[i]
			end
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

function Bingfenfuli:switchTab(tab)
    local tabIdx = tonumber(tab or 1)
	
	if self._inited == false then
            self:initWithData()
            self._inited = true
    end
	
    local turnToOtherActFunc = function(data)
        if self._activityBg:getChildByName("activityTabLayer") then
            self._activityBg:removeChildByName("activityTabLayer")
        end
		if self._activityOpen[tabIdx].file then
        local layer = requires("src/fsgl/layer/HuoDong/" .. self._activityOpen[tabIdx].file):create(self,data)
			layer:setName("activityTabLayer")
			layer:setAnchorPoint(cc.p(0.5,0.5))
			layer:setPosition(cc.p(self._activityBg:getContentSize().width/2 + 83,self._activityBg:getContentSize().height/2 - 34))
			self._activityBg:addChild(layer)
		end	
    end


    if  self._activityOpen[tabIdx] ==nil then
        return
    end
   
    if not self._activityOpen[tabIdx].url then
        turnToOtherActFunc()
    else
    	performWithDelay(self, function()
	        self:newHttpActivity(tab,turnToOtherActFunc)
	    end, 0.1)
    end
end

function Bingfenfuli:newHttpActivity(_index,callback)
	ClientHttp:requestAsyncInGameWithParams({
        modules = self._activityOpen[_index].url,
        successCallback = function( data )
			if data.result == 0 then
				self.selectedIndex = _index
				for i = 1, #self._btnTable do
					self._btnTable[i]:setSelected(false)
				end	
				self._btnTable[self.selectedIndex]:setSelected(true)
				callback(data)
			else
				--self._btnTable[self.selectedIndex]:setSelected(false)
				XTHDTOAST(data.msg)
			end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

function Bingfenfuli:addTabRedPoint(_target,_idx)
	print("===================>>",_idx)
    if _target==nil or _idx == nil then
        return 
    end
    if _target:getChildByName("redPoint") then
        _target:removeChildByName("redPoint")
    end
	if self._activityOpen[_idx+1] ~= nil then
		-- local _redPointId = self._activityOpen[_idx+1].redPointid or 0
		-- if _redPointState[_redPointId]~=nil and tonumber(_redPointState[_redPointId])==1 then
			local _redPointSp = cc.Sprite:create("res/image/common/heroList_redPoint.png")
			_redPointSp:setName("redPoint")
			_redPointSp:setScale(0.5)
			_redPointSp:setAnchorPoint(cc.p(1,1))
			_redPointSp:setPosition(cc.p(_target:getContentSize().width,_target:getContentSize().height))
			_target:addChild(_redPointSp,1)
			_redPointSp:setVisible(false)
		-- end
		self.redDotTable[_idx + 1] = _redPointSp
	end
end

--刷新小红点
function Bingfenfuli:freshRedDot(tabIdx)
	for i = 1,#self._activityOpen do
		local isHave = false
		if self._activityOpen[i].isOpenid == 48 then
			isHave = RedPointState.GetStateByID(self._activityOpen[i].redPointId) == 1
		elseif self._activityOpen[i].isOpenid == 49 then
			isHave = RedPointState.GetStateByID(self._activityOpen[i].redPointId) == 1
		elseif self._activityOpen[i].isOpenid == 4 then
			isHave = gameUser.getSingleRechargeDot() == 1
		end

		if self._activityOpen[i].isOpen == 1 and gameUser.getFirstLayerState() then
			isHave = RedPointState.GetStateByID(self._activityOpen[i].redPointId) == 1
		end 
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "bfyl"}})
		self.redDotTable[i]:setVisible(isHave)
	end
end

function Bingfenfuli:create()
   return Bingfenfuli.new()
end

return Bingfenfuli