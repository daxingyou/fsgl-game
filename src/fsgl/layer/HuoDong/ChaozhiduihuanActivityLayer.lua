--Created By Liuluyang 2015年06月13日
local ChaozhiduihuanActivityLayer = class("ChaozhiduihuanActivityLayer",function ()
	local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	node:setContentSize(830,342)
	return node
end)

function ChaozhiduihuanActivityLayer:ctor(data,parent)
	self._parent = parent
	self._data = data
	self._btnList = {}
	self._selectedIndex = 1
--	dump(self._data,"超值兑换活动")
	 local activityStatic = {
        --累计充值
		[1] = {
            url = "costRewardList?",
            file = "ChaozhiduihuanDuihuanLayer.lua",
            -- title = LANGUAGE_KEY_ACTIVITYTAB[13],
            priority = 750,
            isOpen = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 43,                   -- 活动开启id，后端控制
            pictureid = 1,
            redPointid = 0,
        },
		[2] = {
            url = "costRewardList?",
            file = "ChaozhiduihuanXiaofeiLayer.lua",
            -- title = LANGUAGE_KEY_ACTIVITYTAB[13],
            priority = 750,
            isOpen = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 43,                   -- 活动开启id，后端控制
            pictureid = 2,
            redPointid = 43,
        },
		[3] = {
            url = "discountShopList?",
            file = "ChaozhiduihuanZhekouLayer.lua",
            -- title = LANGUAGE_KEY_ACTIVITYTAB[13],
            priority = 750,
            isOpen = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 44,                   -- 活动开启id，后端控制
            pictureid = 3,
            redPointid = 0,
        },
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
--	self._activityOpen = activityStati
	
	self._tabNumber = table.nums(self._activityOpen)

	self:initUI()
	self:updateRedDot()
end

function ChaozhiduihuanActivityLayer:initUI()	
	local bg = cc.Sprite:create()
	self:addChild(bg)
	bg:setContentSize(self:getContentSize())
	bg:setPosition(self:getContentSize().width*0.5,self:getContentSize().height *0.5)
	self._bg = bg

	local listviewbg = cc.Sprite:create("res/image/activities/newhuoyueyouli/listviewbg.png")
	self._bg:addChild(listviewbg)
	listviewbg:setContentSize(listviewbg:getContentSize().width,self._bg:getContentSize().height)
	listviewbg:setPosition(listviewbg:getContentSize().width *0.5,listviewbg:getContentSize().height *0.5)
	self._listviewbg = listviewbg

	local titlebg = cc.Sprite:create("res/image/activities/newhuoyueyouli/title_chaozhiduihuan.png")
	titlebg:setScale(1.043)
	titlebg:setAnchorPoint(0,1)
	self._bg:addChild(titlebg)
	titlebg:setPosition(listviewbg:getContentSize().width,self._bg:getContentSize().height + 14)

	--剩余兑换券
	local juan = cc.Sprite:create("res/image/activities/chaozhiduihuan/duihuan.png")
	titlebg:addChild(juan)
	juan:setPosition(titlebg:getContentSize().width - juan:getContentSize().width *0.5,titlebg:getContentSize().height - juan:getContentSize().height *0.5 - 10)
	self._juan = juan
	self._juanCount = XTHDLabel:create(XTHD.resource.getItemNum(2324),16,"res/fonts/def.ttf") 
	self._juanCount:setColor(cc.c3b(100,40,0))
	juan:addChild(self._juanCount)
	self._juanCount:setPosition(juan:getContentSize().width/2 + 10,juan:getContentSize().height/2)
	

	self._timeLable = XTHDLabel:create("",14,"res/fonts/def.ttf")
	self._timeLable:setAnchorPoint(0,0.5)
	self._timeLable:setPosition(titlebg:getContentSize().width - 125,self._timeLable:getContentSize().height *0.5 + 8)
	titlebg:addChild(self._timeLable)

--	self._title = cc.Sprite:create("res/image/activities/chaozhiduihuan/title_".. self._selectedIndex ..".png")
--	self._bg:addChild(self._title)
--	self._title:setPosition(self._title:getContentSize().width *0.5 + 230,self._bg:getContentSize().height - self._title:getContentSize().height*0.5 - 95)

	local bg3 = cc.Sprite:create("res/image/activities/newhuoyueyouli/renwu.png")
	bg3:setScale(0.7)
	self._bg:addChild(bg3)
	bg3:setPosition(self._bg:getContentSize().width - bg3:getContentSize().width *0.4 + 30,self._bg:getContentSize().height - bg3:getContentSize().height *0.5)


	self._tableViewBg = cc.Sprite:create("res/image/activities/huoyueyouli/bg_2.png")
	self._tableViewBg:setAnchorPoint(0,1)
	self._bg:addChild(self._tableViewBg)
	self._tableViewBg:setContentSize(self._tableViewBg:getContentSize().width,self:getContentSize().height - titlebg:getContentSize().height *1.043 + 18)
	self._tableViewBg:setPosition(listviewbg:getContentSize().width,self._bg:getContentSize().height - titlebg:getContentSize().height * 1.043 + 15)

	--排行榜按钮
	local rankbtn = XTHDPushButton:createWithParams({
		normalFile = "res/image/activities/chaozhiduihuan/xinpaihang1.png",
		selectedFile = "res/image/activities/chaozhiduihuan/xinpaihang2.png",
		isScrollView = true,
		needEnableWhenMoving = true,
		endCallback  = function()
			self:RankJiangliPopLayer() 
		end,
	})
	--rankbtn:setScale(0.7)
	rankbtn:setSwallowTouches(false)
	listviewbg:addChild(rankbtn,5)
	rankbtn:setPosition(listviewbg:getContentSize().width *0.5,rankbtn:getContentSize().height - 45)
	self._rankbtn = rankbtn
	
	--左边按钮
	local btn_listView = ccui.ListView:create()
    btn_listView:setContentSize(listviewbg:getContentSize())
    btn_listView:setDirection(ccui.ScrollViewDir.vertical)
    btn_listView:setBounceEnabled(true)
	btn_listView:setScrollBarEnabled(false)
	btn_listView:setSwallowTouches(true)
    listviewbg:addChild(btn_listView)
    btn_listView:setPosition(cc.p(0,0))
    self._btn_listView = btn_listView	
	local isOpen = gameUser.getActivityOpenStatusById(44)

	for i = 1, self._tabNumber do
		local layout = ccui.Layout:create()
		layout:setContentSize(151,80)
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/activities/chaozhiduihuan/btn_" .. self._activityOpen[i].pictureid .. "_up.png",
			selectedFile = "res/image/activities/chaozhiduihuan/btn_" .. self._activityOpen[i].pictureid .. "_down.png",
			isScrollView = true,
			needEnableWhenMoving = true,
			endCallback  = function()
				self:SelectedActivityLayer(i)		   
			end,
		})
		btn:setSwallowTouches(false)
		layout:addChild(btn)
		btn:setPosition(layout:getContentSize().width * 0.5,layout:getContentSize().height * 0.5)
		self._btnList[#self._btnList +1] = btn
		if i == 3 then
			btn:setVisible(isOpen==1)
		end
		local selectedbg = cc.Sprite:create("res/image/activities/chaozhiduihuan/btn_" .. self._activityOpen[i].pictureid .. "_down.png")
		btn:addChild(selectedbg)
		selectedbg:setPosition(btn:getContentSize().width *0.5,btn:getContentSize().height *0.5)
		selectedbg:setVisible(false)
		selectedbg:setName("selectedbg")
	
		if self._activityOpen[i].redPointid == 43 then
			local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
			btn:addChild(redDot)
			redDot:setPosition(10, btn:getBoundingBox().height - 10)
			redDot:setScale(0.6)
			redDot:setVisible(false)	
			self._redDot = redDot
		end

		self._btn_listView:pushBackCustomItem(layout)
	end

	performWithDelay(self, function()
        self:SelectedActivityLayer(self._selectedIndex)
    end, 0.2)
end

function ChaozhiduihuanActivityLayer:SelectedActivityLayer(index)
	self._selectedIndex = index
	if self._selectedIndex ~= 1 then
		self._juan:setVisible(false)
		self._rankbtn:setVisible(false)
	else
		self._juan:setVisible(true)
		self._rankbtn:setVisible(true)
	end
	for i = 1,self._tabNumber do
		if i ~= index then
			self._btnList[i]:getChildByName("selectedbg"):setVisible(false)
		else
			self._btnList[i]:getChildByName("selectedbg"):setVisible(true)
		end
	end

	--self._title:setTexture("res/image/activities/chaozhiduihuan/title_".. self._selectedIndex ..".png")
	if self._activityOpen[index].url ~= nil then
		self:newHttpActivity(index)
	else
		local layer = requires( "src/fsgl/layer/HuoDong/" .. self._activityOpen[index].file ):create(self._bg)
		self._bg:addChild(layer,3,10)
		layer:setPosition(cc.p(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2 - 54))
	end
	self:updateRedDot()
end

function ChaozhiduihuanActivityLayer:updateTime()
	schedule(self, function(dt)
		self._data.close = self._data.close - 1
		self._timeLable:setString(LANGUAGE_KEY_CARNIVALDAY(self._data.close))
  	end,1,10)
end

function ChaozhiduihuanActivityLayer:updateRedDot()
	ClientHttp:requestAsyncInGameWithParams({
        modules = "costRewardList?",
        successCallback = function( data )
			if data.result == 0 then
				RedPointState[7].state = 0
				for i = 1,#data.list do
					if data.list[i].state == 1 then
						self._redDot:setVisible(true)
						RedPointState[7].state = 1
						self._parent:refreshRedDot()
						XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "hyyl"}})
						return
					else
						self._redDot:setVisible(false)
					end
				end
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "hyyl"}})
			end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

function ChaozhiduihuanActivityLayer:newHttpActivity(index)
	ClientHttp:requestAsyncInGameWithParams({
        modules = self._activityOpen[index].url,
        successCallback = function( data )
			if data.result == 0 then
				self._data = data
				self:stopAllActions()
				self:updateTime()
				if self._bg:getChildByTag(10) then
					self._bg:getChildByTag(10):removeFromParent()
				end
				local layer = requires( "src/fsgl/layer/HuoDong/" .. self._activityOpen[index].file ):create(self,data)
--				dump(data,"77777")
				self._bg:addChild(layer,3,10)
				layer:setPosition(cc.p(self._bg:getContentSize().width/2 + 2,self._bg:getContentSize().height/2 - 54))	
			else
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

function ChaozhiduihuanActivityLayer:RankJiangliPopLayer()
	local layer = requires( "src/fsgl/layer/HuoDong/ChaozhiduihuanJiangliPopLayer.lua"):create()
	cc.Director:getInstance():getRunningScene():addChild(layer)
	layer:show()	
end


function ChaozhiduihuanActivityLayer:create(data,parent)
	return ChaozhiduihuanActivityLayer.new(data,parent)
end

return ChaozhiduihuanActivityLayer