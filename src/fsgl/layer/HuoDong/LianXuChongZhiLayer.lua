--[[
	FileName: LianXuChongZhiLayer.lua
	Author: andong
	Date: 2016-1-13
	Purpose: 连续充值
]]
local LianXuChongZhiLayer = class( "LianXuChongZhiLayer", function ()
    return XTHDSprite:createWithTexture(nil,cc.rect(0,0,839,420))
end)
function LianXuChongZhiLayer:ctor(parmas)
	self:setOpacity( 0 )
	self:initData(parmas.httpData)
	self:initUI()
	self:refreshButton()

	-- 添加监听事件
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG ,callback = function()
        self:request()
    end})
end

function LianXuChongZhiLayer:initData(data)
	self._data = data
	local static = gameData.getDataFromCSV("ContinuityChongzhi", {["id"]=data.configId} )
	self._static = static
	self._taday = {}
	for i = 1, 4 do
		self._taday[i] = {}
		self._taday[i].rewardtype = static["rewardtype"..i]

		local rewardTab = string.split(static["canshu"..i], "#")
		self._taday[i].num = rewardTab[2]
		if tonumber(self._taday[i].rewardtype) == 4 then
			self._taday[i].id = rewardTab[1]
		end
	end
end
function LianXuChongZhiLayer:initUI()
	self._size = self:getContentSize()

	local background = ccui.Scale9Sprite:create( "res/image/activities/activityRec_bg.png" )
	background:setContentSize(640,483)
	background:setAnchorPoint( cc.p( 1, 0.5 ) )
	background:setPosition( self._size.width + 34, self._size.height*0.5 - 18 )
	self:addChild(background)
	self._background = background

	-- 小浣熊
	local smallRaccoon = XTHD.createSprite( "res/image/activities/dailyRecharge/lianxuchongzhichatu.png" )
	smallRaccoon:setAnchorPoint(0.5,0.5)
	smallRaccoon:setPosition( 98, self:getContentSize().height/2 -18 )
	self:addChild( smallRaccoon )
	-- -- 活动规则标题
	-- local rulesTitleLabel = XTHD.createLabel({
	-- 	text      = LANGUAGE_ACTIVITY_PRIVILEGEAWARD[1],
	-- 	fontSize  = 20,
	-- 	anchor    = cc.p( 0, 1 ),
	-- 	pos       = cc.p( 7, background:getContentSize().height - 10 ),
	-- 	clickable = false,
	-- 	color     = cc.c3b(255, 255, 255)
	-- })
	-- rulesTitleLabel:enableShadow( cc.c4b(255, 255, 255, 255), cc.size( 0.4, -0.4) )
	-- background:addChild( rulesTitleLabel )
	-- -- 活动规则
	-- local rulesLabel = XTHD.createLabel({
	-- 	text      = LANGUAGE_ACTIVITY_PRIVILEGEAWARD[4],
	-- 	fontSize  = 18,
	-- 	color     = cc.c3b( 229, 183, 47 ),
	-- 	anchor    = cc.p( 0, 1 ),
	-- 	pos       = cc.p( rulesTitleLabel:getPositionX(), rulesTitleLabel:getPositionY() - 30 ),
	-- 	clickable = false,
	-- })
	-- rulesLabel:setWidth( 230 )
	-- rulesLabel:enableShadow( cc.c4b( 229, 183, 47, 255), cc.size( 0.4, -0.4 ) )
	-- background:addChild( rulesLabel )

	-- local info_title = cc.Sprite:create("res/image/activities/dailyRecharge/info_title.png")
	-- info_title:setAnchorPoint(0, 0)
	-- info_title:setPosition(2, 241)
	-- background:addChild(info_title)

	-- -- 深色背景
	-- local bg = ccui.Scale9Sprite:create("res/image/activities/dailyRecharge/bg.png")
	-- bg:setContentSize(640, 447)
	-- bg:setAnchorPoint(1, 0.5)
	-- bg:setPosition(background:getContentSize().width + 26,background:getContentSize().height-4)
	-- background:addChild(bg)

	local reward_title = cc.Sprite:create("res/image/activities/dailyRecharge/reward_title.png")
	reward_title:setAnchorPoint(0.5, 0.5)
	reward_title:setPosition(background:getContentSize().width/2, 334)
	background:addChild(reward_title)
	--num
	local myTTF = cc.Label:createWithBMFont("res/image/activities/dailyRecharge/bigword.fnt", tonumber(self._static["needcanshu"]))
	myTTF:setAnchorPoint(cc.p(0.5,0.5))
	myTTF:setPosition(cc.p(296,106))
	reward_title:addChild(myTTF)

	--reward
	local rewardimg = cc.Sprite:create("res/image/activities/dailyRecharge/rewardBg.png")
	rewardimg:setAnchorPoint(1, 0)
	rewardimg:setPosition(background:getContentSize().width- 50, 98)
	background:addChild(rewardimg)

	local pos = SortPos:sortFromMiddle(cc.p(rewardimg:getContentSize().width/2, rewardimg:getContentSize().height/2+50),#self._taday,rewardimg:getContentSize().width/(#self._taday))
	for i = 1, #self._taday do
		local bgimg = cc.Sprite:create("res/image/activities/dailyRecharge/reward_bgimg.png")
		bgimg:setAnchorPoint(0.5, 0.5)
		bgimg:setPosition(pos[i])
		rewardimg:addChild(bgimg)
		bgimg:setScale(0.7)
		local item = ItemNode:createWithParams({
			_type_ = self._taday[i].rewardtype,
			itemId = self._taday[i].id,
			count = self._taday[i].num,
		})
		item:setPosition(bgimg:getContentSize().width/2, bgimg:getContentSize().height/2+8)
		bgimg:addChild(item)
        local sp = XTHD.createSprite("res/image/vip/effect/effect1.png")
        item:addChild(sp)
        sp:setPosition(item:getContentSize().width/2-1,item:getContentSize().height/2 + 2)
        local xingxing_effect = getAnimation("res/image/vip/effect/effect",1,8,1/10) --点击
        sp:setScale(0.9)
        sp:runAction(cc.RepeatForever:create(xingxing_effect))
	end

	local changeReward = XTHD.createButton({
		normalFile = "res/image/activities/dailyRecharge/reward_normal.png",
		selectedFile = "res/image/activities/dailyRecharge/reward_selected.png",
		needSwallow = false,
		endCallback = function()
			self:rewardList()
		end,
		anchor = cc.p(1, 0),
		pos = cc.p(background:getContentSize().width-14, 17),
	})
	changeReward:setScale(0.7)
	background:addChild(changeReward)

	local tip1 = XTHDLabel:createWithParams({
		text = LANGUAGE_DAILYRECHARGE_DAYS(self._data.continuousPayDay),
		fontSize = 22,
		color = cc.c3b(245, 103, 38),
		anchor = cc.p(0, 1),
		pos = cc.p(10, self._size.height + 30),
	})
	background:addChild(tip1)
	self._days = tip1

	local tip2 = XTHDLabel:createWithParams({
		text = LANGUAGE_RECHARGED_INGOTS..": ",
		fontSize = 22,
		color = cc.c3b(245, 103, 38),
		anchor = cc.p(1, 1),
		pos = cc.p(background:getContentSize().width-100, tip1:getPositionY()),
	})
	background:addChild(tip2)
	
	local total = XTHDLabel:createWithParams({
		text = self._data.dayTotalPay,
		fontSize = 22,
		color = cc.c3b(245, 103, 38),
		anchor = cc.p(0, 1),
		pos = cc.p(tip2:getPositionX(), tip1:getPositionY()),
	})
	background:addChild(total)
	self._totalIngot = total
	
end
function LianXuChongZhiLayer:refreshButton()
	
	-- self._data.state = 1
	if self._rechargeBtn then
		self._rechargeBtn:removeFromParent()
	end
	local _normalFile 
	local _selectedFile
	local flag = 0
	if tonumber(self._data.state) == 0 then
		 _normalFile = "res/image/activities/firstrecharge/recharge_up.png"
		 _selectedFile = "res/image/activities/firstrecharge/recharge_down.png"
	elseif tonumber(self._data.state) == 1 then
		 _normalFile = "res/image/activities/firstrecharge/fetch_up.png"
		 _selectedFile = "res/image/activities/firstrecharge/fetch_down.png"
		flag = 1
	elseif tonumber(self._data.state) == 2 then
		flag = 2
	end

	-- 前去充值按钮
	if flag ~= 2 then
		self._rechargeBtn = XTHD.createButton({
			normalFile = _normalFile,
			selectedFile = _selectedFile,
			endCallback = function()
				if flag == 0 then
					XTHD.createRechargeVipLayer( self )
				elseif flag == 1 then
					self:getTadayReward()
				end
			end
		})
		self._rechargeBtn:setPosition( self._background:getContentSize().width/2, 45 )
		self._rechargeBtn:setScale(0.8)
		self._background:addChild( self._rechargeBtn )
		if flag == 1 then
			local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
			self._rechargeBtn:addChild(fetchSpine)
			fetchSpine:setScaleX(1.7)
			fetchSpine:setPosition(self._rechargeBtn:getContentSize().width*0.5 + 2, self._rechargeBtn:getContentSize().height*0.5+2)
			fetchSpine:setAnimation(0, "querenjinjie", true )
		end	
	elseif flag == 2 then
		-- 已领取
		self._rechargeBtn = XTHD.createSprite( "res/image/vip/yilingqu.png" )
		self._rechargeBtn:setPosition( self._background:getContentSize().width/2, 45 )
		self._rechargeBtn:setScale(0.8)
		self._background:addChild( self._rechargeBtn )
	end
	---
	self._days:setString(LANGUAGE_DAILYRECHARGE_DAYS(self._data.continuousPayDay))
	self._totalIngot:setString(self._data.dayTotalPay)

end

function LianXuChongZhiLayer:getTadayReward()
	ClientHttp:requestAsyncInGameWithParams({
	    modules = "receiveContinuousPayReward?",      --接口
	    successCallback = function(data)
	        if tonumber(data.result) == 0 then --请求成功
	            ShowRewardNode:create( self._taday )
            	-- 更新属性
		    	if data.property and #data.property > 0 then
	                for i=1, #data.property do
	                    local pro_data = string.split( data.property[i], ',' )
	                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
	                end
	                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
	            end
	            -- 更新背包
	            if data.bagItems and #data.bagItems ~= 0 then
	                for i=1, #data.bagItems do
	                    local item_data = data.bagItems[i]
	                    if item_data.count and tonumber( item_data.count ) ~= 0 then
	                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
	                    else
	                        DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
	                    end
	                end
	            end 
				self._data.state = 2
				self:refreshButton()
	        else
	           XTHDTOAST(data.msg) --出错信息(后端返回)
	        end
	    end,--成功回调
	    loadingParent = self,
	    failedCallback = function()
	        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
	    end,--失败回调
	    targetNeedsToRetain = self,--需要保存引用的目标
	    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})
end
function LianXuChongZhiLayer:rewardList()
    LayerManager.addShieldLayout()
    local function refreshData(id)
    	for i = 1, #self._data.list do
    		if id == self._data.list[i].configId then
    			self._data.list[i].state = 2
    			break
    		end
    	end
    end
    self._data.callback = refreshData
	local poplist = requires("src/fsgl/layer/HuoDong/LianXuChongZhiJiangLiPop.lua"):create(self._data)
	LayerManager.addLayout(poplist, {noHide = true})
end
function LianXuChongZhiLayer:create(parmas)
	return self.new(parmas)
end
function LianXuChongZhiLayer:onCleanup()
	-- print("onCleanup ... ")
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_RECHARGE_MSG)
end
function LianXuChongZhiLayer:onEnter( ... )
	-- print("onEnter ... ")
end
function LianXuChongZhiLayer:request()
	ClientHttp:requestAsyncInGameWithParams({
	    modules = "continuousPayRewardList?",      --接口
	    params = {}, --参数
	    successCallback = function(data)
	        if tonumber(data.result) == 0 then --请求成功
	        	self:initData(data)
	        	self:refreshButton()
	        else
	           XTHDTOAST(data.msg) --出错信息(后端返回)
	        end
	    end,--成功回调
	    loadingParent = self,
	    failedCallback = function()
	        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
	    end,--失败回调
	    targetNeedsToRetain = self,--需要保存引用的目标
	    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})
end
function LianXuChongZhiLayer:onExit( ... )
	-- print("onExit ... ")
end
return LianXuChongZhiLayer