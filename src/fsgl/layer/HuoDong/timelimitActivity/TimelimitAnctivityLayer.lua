--7 - 11
--限时活动
local TimelimitAnctivityLayer = class("TimelimitAnctivityLayer",function()
	return XTHD.createPopLayer()
end)

function TimelimitAnctivityLayer:ctor()
	self._btnList = {}
	self._layerNode = nil
	self._selectedIndex = 0
	local activityStatic = {
        --限时神将
		[1] = {
            url = "limitPetList?",
            file = "XianShiYingXiongLayer.lua",
            priority = 750,
            isOpen = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 11,                   -- 活动开启id，后端控制
            pictureid = 11,
            redPointid = 11,
        },
		--限时挑战
		[2] = {
            url = nil,
            file = "XianShiTiaoZhanLayer.lua",
            priority = 750,
            isOpen = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 7,                   -- 活动开启id，后端控制
            pictureid = 7,
            redPointid = 7,
        }
	}
	
	local _openState = gameUser.getActivityOpenStatus() or {}
	self._activityOpen = {}
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
		return tonumber(data1.isOpenid)<tonumber(data2.isOpenid)
	end)
	
	self._tabNumber = table.nums(self._activityOpen)	

	self:initUI()
end

function  TimelimitAnctivityLayer:create()
	return TimelimitAnctivityLayer:new()
end

function TimelimitAnctivityLayer:initUI()
	local bg = cc.Sprite:create("res/image/activities/TimelimitActivity/bg.png")
	self:addContent(bg)
	bg:setPosition(self:getContentSize().width *0.5,self:getContentSize().height *0.5)
	self._bg = bg

	self._layerNode = cc.Node:create()
	self._layerNode:setContentSize(self._bg:getContentSize())
	self._layerNode:setAnchorPoint(0.5,0.5)
	self._layerNode:setPosition(self._bg:getContentSize().width*0.5,self._bg:getContentSize().height *0.5)
	self._bg:addChild(self._layerNode)

	local btn_close = XTHDPushButton:createWithFile({
		normalFile = "res/image/activities/TimelimitActivity/btn_close_up.png",
		selectedFile = "res/image/activities/TimelimitActivity/btn_close_down.png",
		musicFile = XTHD.resource.music.effect_btn_commonclose,
		endCallback  = function()
           self:hide()
		end,
	})
	self._bg:addChild(btn_close,10)
	btn_close:setPosition(self._bg:getContentSize().width - btn_close:getContentSize().width * 0.5 + 18,self._bg:getContentSize().height - btn_close:getContentSize().height * 0.5 - 10)
	
	local title = cc.Sprite:create("res/image/activities/TimelimitActivity/title_1.png")
	self._bg:addChild(title)
	title:setPosition(self._bg:getContentSize().width *0.5 - 5,self._bg:getContentSize().height - title:getContentSize().height *0.5 - 5)

	local btn_listView = ccui.ListView:create()
    btn_listView:setContentSize(cc.size(151, 402))
    btn_listView:setDirection(ccui.ScrollViewDir.vertical)
    btn_listView:setBounceEnabled(true)
	btn_listView:setScrollBarEnabled(false)
	btn_listView:setSwallowTouches(true)
    self._bg:addChild(btn_listView,2)
    btn_listView:setPosition(cc.p(65,31))
    self._btn_listView = btn_listView 

	for i = 1, self._tabNumber do
		local layout = ccui.Layout:create()
		layout:setContentSize(151,80)
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/activities/TimelimitActivity/btn_" .. self._activityOpen[i].pictureid .. "_up.png",
			selectedFile = "res/image/activities/TimelimitActivity/btn_" .. self._activityOpen[i].pictureid .. "_down.png",
			isScrollView = true,
			needEnableWhenMoving = true,
			endCallback  = function()
				self:selectedNode(i)
			end,
		})
		btn:setSwallowTouches(false)
		layout:addChild(btn)
		btn:setPosition(layout:getContentSize().width * 0.5,layout:getContentSize().height * 0.5)
		self._btnList[#self._btnList + 1] = btn
		
		local selectedbg = cc.Sprite:create("res/image/activities/TimelimitActivity/btn_" .. self._activityOpen[i].pictureid .. "_down.png")
		btn:addChild(selectedbg)
		selectedbg:setPosition(btn:getContentSize().width *0.5,btn:getContentSize().height *0.5)
		selectedbg:setVisible(false)
		selectedbg:setName("selectedbg")

		self._btn_listView:pushBackCustomItem(layout)
	end
	self:selectedNode(1)
end

function TimelimitAnctivityLayer:selectedNode(index)
	--self._layerNode:removeAllChildren()
	if self._selectedIndex  == index then
		return
	else
		self._selectedIndex  = index
	end
	for i = 1, #self._btnList do
		self._btnList[i]:getChildByName("selectedbg"):setVisible(false)
	end
	self._btnList[index]:getChildByName("selectedbg"):setVisible(true)

	
	if self._activityOpen[index].url ~= nil then
        performWithDelay(self, function()
	        XTHD.timeHeroListCallback(self._layerNode)
	    end, 0.1)
	else
        performWithDelay(self, function()
	        requires("src/fsgl/layer/HuoDong/XianShiTiaoZhanLayer.lua"):create(self._layerNode) 
	    end, 0.1) 
	end

end

return TimelimitAnctivityLayer;