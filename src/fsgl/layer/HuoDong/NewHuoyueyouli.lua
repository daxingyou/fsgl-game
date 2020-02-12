--[=[
    FileName:NewHuoyueyouli.lua
    Autor:赵俊路
    Date:2019.05.31
    Content:精彩活动界面
    PS:临时的活动界面
]=]
local NewHuoyueyouli = class("NewHuoyueyouli", function(tab)
    return XTHD.createBasePageLayer({bg ="res/image/activities/carnival_bg1.png" })
end)

function NewHuoyueyouli:ctor(tab)
	self._selectIndex = 1
	self._isFirst = true
	self._layerNode = nil
	self._btnlist = {}
	self:getOpenActivity()
	self:init()
end

function NewHuoyueyouli:init()
	local _topBarHeight = self.topBarHeight

	local _contentBg = cc.Sprite:create("res/image/activities/newhuoyueyouli/bg.png")
	self:addChild(_contentBg)
	_contentBg:setPosition(self:getContentSize().width*0.5,(self:getContentSize().height - _topBarHeight)*0.5)
	self._contentBg = _contentBg
	
	local title = cc.Sprite:create("res/image/activities/newhuoyueyouli/name.png")
	self._contentBg:addChild(title)
	title:setPosition(self._contentBg:getContentSize().width *0.5,self._contentBg:getContentSize().height - title:getContentSize().height *0.5 - 10)

	local scorllRect = ccui.ListView:create()
    scorllRect:setContentSize(cc.size(self._contentBg:getContentSize().width *0.85 + 20, 50))
    scorllRect:setDirection(ccui.ScrollViewDir.horizontal)
    scorllRect:setBounceEnabled(true)
	scorllRect:setScrollBarEnabled(false)
	scorllRect:setSwallowTouches(true)
    self._contentBg:addChild(scorllRect,10)
    scorllRect:setPosition(cc.p(61, self._contentBg:getContentSize().height - 115))
    self.scorllRect = scorllRect
	
	for i = 1,self._tabNumber do
		local layout = ccui.Layout:create()
		layout:setContentSize(155,45)

		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/activities/tabstyle_normal.png",
            selectedFile = "res/image/activities/tabstyle_sel.png",
		})
		layout:addChild(btn)
		btn:setPosition(layout:getContentSize().width *0.5,layout:getContentSize().height *0.5)
		self._btnlist[#self._btnlist + 1] = btn

		local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
        btn:addChild(redDot)
        redDot:setPosition(btn:getContentSize().width - redDot:getContentSize().width *0.5 + 3, btn:getBoundingBox().height - 5)
		redDot:setScale(0.8)
		redDot:setVisible(false)	
		redDot:setName("redDot")

		local btn_lable = XTHDLabel:create(self._activityOpen[i].text,18)
		btn:addChild(btn_lable)
		btn_lable:setAnchorPoint(0,0.5)
		btn_lable:setColor(cc.c3b(255,255,255))
		btn_lable:setPosition(layout:getContentSize().width *0.3 + 5,layout:getContentSize().height *0.4)

		btn:setTouchEndedCallback(function()
			self:SwichTab(i)
		end)
		
		self.scorllRect:pushBackCustomItem(layout)
	end
	
	local Activitybg = cc.Sprite:create("res/image/common/common_bg_1.png")
	self._contentBg:addChild(Activitybg)
	Activitybg:setPosition(self._contentBg:getContentSize().width *0.5 - 1, (self._contentBg:getContentSize().height - self.scorllRect:getContentSize().height)*0.5 - 20)
	Activitybg:setContentSize(self._contentBg:getContentSize().width *0.85 + 18,self._contentBg:getContentSize().height - self.scorllRect:getContentSize().height - 100)
	dump(Activitybg:getContentSize())
	self._Activitybg = Activitybg
	self:SwichTab(self._selectIndex)
	self:refreshRedDot()
end

function NewHuoyueyouli:getOpenActivity()
	 local activityStatic = {
		--活跃有礼
         [1] = {
            url = "activeActivityList?",
            file = "HuoyueyouliActivityLayer.lua",
			text = "活跃有礼",
            isOpen = 0,                             -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 42,                           -- 活动开启id，后端控制
            redPointid = 5,
        },
		--投资计划
		[2] = {
            url = "InvestPlanRecord?",
            file = "NewTouzijihuaActivityLayer.lua",
			text = "投资计划",
            isOpen = 0,                             -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 40,                           -- 活动开启id，后端控制
            redPointid = 6,
        },
		--超值兑换
		[3] = {
            url = "costRewardList?",
            file = "ChaozhiduihuanActivityLayer.lua",
			text = "超值兑换",
            isOpen = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 43,                   -- 活动开启id，后端控制
            pictureid = 1,
            redPointid = 7,
        },
	}

	--日常活动需要特殊处理
	local dailyActivityId = {
        12,-- 充值返利
        13,-- 消费返利
        14,-- 切石返利
        15,-- 群英返利
        16,-- 神兵返利
        17,-- 神器返利
		18,-- 登录有礼
	}
	local activityOpenStatus = gameUser.getActivityOpenStatus() or { }
	for i, v in ipairs(dailyActivityId) do
		if activityOpenStatus[tostring(v)] == 1 then
			activityStatic[#activityStatic + 1] = {
				url = "totalActivateList?",
				file = "RiChangHuoDongLayer.lua",
				text = "日常活动",
				isOpen = 1,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
				isOpenid = 0,                   -- 活动开启id，后端控制
				pictureid = 1,
				redPointid = 8,
			}
			break
		end
     end

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

    self._tabNumber = table.nums(self._activityOpen)
end

function NewHuoyueyouli:SwichTab(index)
	if self._selectIndex == index and not self._isFirst then
		return
	end
	self._selectIndex = index
	self._isFirst = false

	if self._activityOpen[index].isOpenid == 40 then
		ClientHttp:requestAsyncInGameWithParams( {
			modules = "InvestPlanRecord?",
			params = { type = 1 },
			successCallback = function(data)
				self:refreshBtnstate()
				if self._layerNode then
					self._layerNode:removeFromParent()
					self._layerNode = nil
				end
				local layer = requires("src/fsgl/layer/HuoDong/"..self._activityOpen[index].file):create(data,self)
				self._Activitybg:addChild(layer)
				layer:setPosition(self._Activitybg:getContentSize().width *0.5,self._Activitybg:getContentSize().height *0.5)
				self._layerNode = layer
			end,
			failedCallback = function()
				XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
				------"网络请求失败")
			end,
			-- 失败回调
			loadingType = HTTP_LOADING_TYPE.CIRCLE,
			-- 加载图显示 circle 光圈加载 head 头像加载
			loadingParent = node,
		} )
	elseif self._activityOpen[index].isOpenid == 0 then
		self:refreshBtnstate()
		local activityDailyLayer = requires("src/fsgl/layer/HuoDong/RiChangHuoDongLayer.lua")
		local id = activityDailyLayer:firstActivityId()
		ClientHttp:requestAsyncInGameWithParams( {
			modules = "totalActivateList?",
			params = { activateId = id },
			successCallback = function(data)
				if tonumber(data.result) == 0 then
					if self._layerNode then
						self._layerNode:removeFromParent()
						self._layerNode = nil
					end
					local layer = activityDailyLayer:create(data,self)
					self._Activitybg:addChild(layer)
					layer:setPosition(self._Activitybg:getContentSize().width *0.5,self._Activitybg:getContentSize().height *0.5)
					self._layerNode = layer
				else
					XTHDTOAST(data.msg)
				end
			end,
			failedCallback = function()
				XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
			end,
			-- 失败回调
			targetNeedsToRetain = self,
			loadingType = HTTP_LOADING_TYPE.CIRCLE,
			loadingParent = self,
		} )
	else
		ClientHttp:httpActivity(self._activityOpen[index].url,self,function(data)
			self:refreshBtnstate()
			if self._layerNode then
				self._layerNode:removeFromParent()
				self._layerNode = nil
			end
			local layer = requires("src/fsgl/layer/HuoDong/"..self._activityOpen[index].file):create(data,self)
			self._Activitybg:addChild(layer)
			layer:setPosition(self._Activitybg:getContentSize().width *0.5,self._Activitybg:getContentSize().height *0.5)
			self._layerNode = layer
		end,{})
	end
end

function NewHuoyueyouli:refreshRedDot()
	for i = 1,#self._btnlist do
		local redDot = self._btnlist[i]:getChildByName("redDot")
		redDot:setVisible(RedPointState[self._activityOpen[i].redPointid].state == 1)
	end
end

function NewHuoyueyouli:refreshBtnstate()
	for i = 1,#self._btnlist do
		if self._selectIndex == i then
			self._btnlist[i]:setSelected(true)
		else
			self._btnlist[i]:setSelected(false)
		end
	end
end

function NewHuoyueyouli:create(tab)
    return NewHuoyueyouli.new(tab)
end

return NewHuoyueyouli