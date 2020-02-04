--Created By Liuluyang 2015年06月13日
local ChaozhiduihuanActivityLayer = class("ChaozhiduihuanActivityLayer",function ()
	return XTHD.createPopLayer()
end)

function ChaozhiduihuanActivityLayer:ctor(data)
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
	local _bg = cc.Sprite:create("res/image/activities/chaozhiduihuan/bg.png")
	_bg:setPosition(self:getContentSize().width *0.5,self:getContentSize().height *0.5)
	--_bg:setScale(0.9)
	self._bg = _bg
	self:addContent(self._bg)

	--剩余兑换券
	local juan = cc.Sprite:create("res/image/activities/chaozhiduihuan/duihuan.png")
	self._bg:addChild(juan)
	juan:setPosition(self._bg:getContentSize().width/2 + 230,self._bg:getContentSize().height - 92)
	self._juan = juan
	self._juanCount = XTHDLabel:create(XTHD.resource.getItemNum(2324),16,"res/fonts/def.ttf")  
	juan:addChild(self._juanCount)
	self._juanCount:setPosition(juan:getContentSize().width/2 + 10,juan:getContentSize().height/2)

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
	self._bg:addChild(rankbtn,5)
	rankbtn:setPosition(rankbtn:getContentSize().width + 50,rankbtn:getContentSize().height - 20)
	self._rankbtn = rankbtn

	local shijianbg = cc.Sprite:create("res/image/activities/chaozhiduihuan/daojishibg.png")
	self._bg:addChild(shijianbg)
	shijianbg:setPosition(self._bg:getContentSize().width*0.5 + 180 + shijianbg:getContentSize().width * 0.5, self._bg:getContentSize().height - 125)
	
	self._timeLable = XTHDLabel:create("",14,"res/fonts/def.ttf")
	self._timeLable:setAnchorPoint(0,0.5)
	--self._timeLable:setColor(XTHD.resource.textColor.green_text)
	self._timeLable:setPosition(shijianbg:getPositionX() -15,shijianbg:getPositionY())
	self._bg:addChild(self._timeLable)

	self._title = cc.Sprite:create("res/image/activities/chaozhiduihuan/title_".. self._selectedIndex ..".png")
	self._bg:addChild(self._title)
	self._title:setPosition(self._title:getContentSize().width *0.5 + 230,self._bg:getContentSize().height - self._title:getContentSize().height*0.5 - 95)

	self._ceilTitle = cc.Sprite:create("res/image/activities/chaozhiduihuan/ceilTitle_".. self._selectedIndex ..".png")
	self._bg:addChild(self._ceilTitle)
	self._ceilTitle:setPosition(self._bg:getContentSize().width *0.5,self._bg:getContentSize().height - 38)
	
	--左边按钮
	local btn_listView = ccui.ListView:create()
    btn_listView:setContentSize(cc.size(151, 402))
    btn_listView:setDirection(ccui.ScrollViewDir.vertical)
    btn_listView:setBounceEnabled(true)
	btn_listView:setScrollBarEnabled(false)
	btn_listView:setSwallowTouches(true)
    self._bg:addChild(btn_listView,2)
    btn_listView:setPosition(cc.p(65,31))
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

	local liusu = cc.Sprite:create("res/image/activities/chaozhiduihuan/liusu.png")
	self._bg:addChild(liusu,11)
	liusu:setPosition(liusu:getContentSize().width *0.5 + 20,liusu:getContentSize().height *0.5 + 25)

	local btn_close = XTHDPushButton:createWithFile({
		normalFile = "res/image/activities/chaozhiduihuan/btn_close_up.png",
		selectedFile = "res/image/activities/chaozhiduihuan/btn_close_down.png",
		musicFile = XTHD.resource.music.effect_btn_commonclose,
		endCallback  = function()
           self:hide()
		end,
	})
	self._bg:addChild(btn_close)
	btn_close:setPosition(self._bg:getContentSize().width - btn_close:getContentSize().width * 0.5 + 18,self._bg:getContentSize().height - btn_close:getContentSize().height * 0.5 - 16)
	performWithDelay(self, function()
        self:SelectedActivityLayer(self._selectedIndex)
    end, 0.2)
	--self:initTableView()
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

	self._title:setTexture("res/image/activities/chaozhiduihuan/title_".. self._selectedIndex ..".png")
	self._ceilTitle:setTexture("res/image/activities/chaozhiduihuan/ceilTitle_".. self._selectedIndex ..".png")
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
						XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "czdh"}})
						return
					else
						self._redDot:setVisible(false)
					end
				end
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "czdh"}})
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
	self:addChild(layer)
	layer:show()	
end


function ChaozhiduihuanActivityLayer:create(data)
	return ChaozhiduihuanActivityLayer.new(data)
end

return ChaozhiduihuanActivityLayer