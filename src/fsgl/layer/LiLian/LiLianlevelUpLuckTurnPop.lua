--[[
	FileName: LiLianlevelUpLuckTurnPop.lua
	Author: andong
	Date: 2016.2.26
	Purpose: xx界面
]]
local LiLianlevelUpLuckTurnPop = class( "LiLianlevelUpLuckTurnPop", function ()
    return XTHDPopLayer:create({isRemoveLayout = true, opacityValue = 250*0.8})
end)
function LiLianlevelUpLuckTurnPop:ctor(params)
	self._parent = params.parent
	-- dump(params)
	self:initData(params)
	self:initUI()
	self:show()
end
function LiLianlevelUpLuckTurnPop:initData(params)
	self._pos = {
		[1] = cc.p(300, 361),
		[2] = cc.p(378, 273),
		[3] = cc.p(378, 190),
		[4] = cc.p(300, 120),

		[5] = cc.p(216, 120),
		[6] = cc.p(146, 194),
		[7] = cc.p(146, 273),
		[8] = cc.p(216, 361),
	}
	self._params = params.data
	self._callback = params._callback


end
function LiLianlevelUpLuckTurnPop:initUI()

	-- local turn_word = cc.Sprite:create("res/image/plugin/stageChapter/turn_word.png")

	local popSize = cc.size(500, 300)
	-- local popNode = ccui.Scale9Sprite:create(cc.rect(45,45,1,1), "res/image/common/scale9_bg_34.png")
	
	local popNode = XTHD.createSprite("res/image/plugin/stageChapter/turn_bg.png")
	-- popNode:setContentSize(popSize)
	popNode:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
	self:addContent(popNode)
	self._popNode = popNode
	local close = XTHD.createBtnClose(function()
		self:hide()
	end)
	-- close:setPosition(cc.p(popNode:getContentSize().width-30, popNode:getContentSize().height-30))
	close:setPosition(cc.p(518-80, 502 - 80))
	popNode:addChild(close)

	self._surplusLab = XTHDLabel:createWithParams({
		text = LANGUAGE_TIPS_CHOUJIANGCOUNT..": " .. self._params.point,
		fontSize = 20,
		color = XTHD.resource.color.brown_desc,
		anchor = cc.p(0.5, 1),
		pos = cc.p(popNode:getContentSize().width/2 -10, popNode:getContentSize().height-38),
	})
	popNode:addChild(self._surplusLab)
	
	if gameUser.getLevel() < 40 then --(小于40级每升5级增加一个次数)
		local turn_word = cc.Sprite:create("res/image/plugin/stageChapter/turn_word.png")
		turn_word:setAnchorPoint(0.5, 0)
		turn_word:setPosition(cc.p(popNode:getContentSize().width/2, 16))
		popNode:addChild(turn_word,1)

		local _level1 = 5 - math.fmod(gameUser.getLevel(), 5)
		local myLab = XTHDLabel:createWithParams({
			text = _level1,
			fontSize = 22,
			color = cc.c3b(13, 255, 1),
			anchor = cc.p(0.5, 0.5),
			pos = cc.p(50, turn_word:getContentSize().height/2+1),
		})
		myLab:enableShadow(cc.c4b(13, 255, 1, 255), cc.size(0.4, -0.4))
		turn_word:addChild(myLab)
	end

	--转盘按钮
    local turn_btn = XTHD.createButton({
        normalFile           = "res/image/plugin/stageChapter/turn_up.png",
        selectedFile         = "res/image/plugin/stageChapter/turn_down.png",
        needSwallow          = false,
        anchor               = cc.p(0.5, 0.5),
        -- pos                  = cc.p(popNode:getContentSize().width/2, popNode:getContentSize().height/2),
        pos                  = cc.p(260, 234),
        endCallback = function()
        	-- self:turn()
        	self:getReard()
        end,
    })
	popNode:addChild(turn_btn,1)
	self._turnplateBtn = turn_btn

	--spine
   	local eff = sp.SkeletonAnimation:create("res/image/activities/newyear/luckyDraw/circle/cjzg.json", "res/image/activities/newyear/luckyDraw/circle/cjzg.atlas", 1.0)
    eff:setPosition(turn_btn:getContentSize().width/2, turn_btn:getContentSize().height/2)
   	turn_btn:addChild(eff)
	eff:setAnimation(0, "animation", true)
	self._eff = eff
	print("point --> ", self._params.point)
	if tonumber(self._params.point) == 0 then
		self._eff:setVisible(false)
	end


	local arrow_sp = cc.Sprite:create()
	arrow_sp:setContentSize(cc.size(40, 63+55))
	arrow_sp:setAnchorPoint(0.5, 0)
	arrow_sp:setPosition(260, 234)
	popNode:addChild(arrow_sp, 10)

	local arrow = cc.Sprite:create("res/image/plugin/stageChapter/turn_arrow.png")
	arrow:setAnchorPoint(0.5, 0)
	arrow:setPosition(arrow_sp:getContentSize().width/2, 51)
	arrow_sp:addChild(arrow)


	self._arrow = arrow_sp

	-- performWithDelay(self,function()
	-- 	arrow_sp:runAction(cc.Sequence:create(cc.EaseInOut:create(cc.RotateBy:create(1, 720 ), 1)))
	-- end,2)
	self._lastTar = 0
	math.randomseed(os.time())

	self._select = cc.Sprite:create("res/image/common/common_selectHeroSp.png")
	self._select:setAnchorPoint(0.5, 0.5)
	self._select:setPosition(self._pos[1])
	self._select:setScale(0.75)
	self._popNode:addChild(self._select, 1)
	self._select:setVisible(false)

	self:refreshItem()
end
function LiLianlevelUpLuckTurnPop:refreshItem()

	if self._itemList then
		for i = 1, #self._itemList do
			if self._itemList[i] then
				self._itemList[i]:removeFromParent()
			end
		end
	end
	-- table.sort(self._params.configs, function(a, b)
	-- 	return tonumber(a.index) < tonumber(b.index)
	-- end)
	local function swap(a, b)
		if b == 0 then
			b = 1
		end
		local ta = {}
		ta = clone(self._params.configs[a])
		self._params.configs[a] = nil
		self._params.configs[a] = self._params.configs[b]
		self._params.configs[b] = ta
	end
	for i = 1, 4 do
		local id = math.random(1, 8)
		-- print("id --> ", id)
		-- print("id2--> ", 8-id)
		swap(id, 8-id)
	end
	-- dump(self._params.configs)

	self._itemList = {}
	for i = 1, #self._pos do
		local itemData = self._params.configs[i]

		local item = ItemNode:createWithParams({
			_type_ = itemData.rewardType,
			itemId = itemData.itemId,
			count = itemData.count,
		})
		self._popNode:addChild(item, 0)
		item:setScale(0.75)
		item:setPosition(self._pos[i])

		--rocord name
		self._params.configs[i].name = item._Name

		self._itemList[#self._itemList+1] = item
	end



end
function LiLianlevelUpLuckTurnPop:getReard()
	YinDaoMarg:getInstance():guideTouchEnd()

	ClientHttp:requestAsyncInGameWithParams({
	    modules = "levelZhuanPanReward?",      --接口
	    params = {}, --参数
	    successCallback = function(data)
	        if tonumber(data.result) == 0 then --请求成功	
	        	YinDaoMarg:getInstance():releaseGuideLayer()
	        	
				local _parent = cc.Director:getInstance():getRunningScene()
				self._mask = XTHDPushButton:createWithParams({
					touchSize = cc.size(1300, 1000),
					endCallback = function()
					end,
					pos = cc.p(_parent:getContentSize().width/2, _parent:getContentSize().height/2),
				})
				_parent:addChild(self._mask)
				--更新抽奖状态
	        	gameUser.setZhuanpanCount(data.point)
	        	self._preData = self._params.configs
	        	self._params.configs = data.configs
	        	self:turn(data)
	        else
				YinDaoMarg:getInstance():tryReguide()
	           XTHDTOAST(data.msg) --出错信息(后端返回)
	        end
	    end,--成功回调
	    loadingParent = self,
	    failedCallback = function()
			YinDaoMarg:getInstance():tryReguide()
	        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
	    end,--失败回调
	    targetNeedsToRetain = self,--需要保存引用的目标
	    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})

end
function LiLianlevelUpLuckTurnPop:turn(data)

	self._select:setVisible(true)
	-- local tar = math.random(1, 8)
	local tar 
	for i = 1, #self._preData do
		if tonumber(data.rewardIndex) == tonumber(self._preData[i].index) then
			tar = i
			break
		end
	end
	print("tar -----> ", tar)
	local add = 0
	if not self._first then
		add = 22.5
	end
	local needJust = self._lastTar == 0 and 0 or (9-self._lastTar)
	-- print("needJust --> ", needJust)
	self._first = true
	local rotate = 1080 + needJust * 45 + 45 * (tar - 1) + add 
	local _base = 22.5
	local _times = rotate/_base
	print("_times --> ", _times)

	local _actionArray = {}
	local _idToPos = {
		[1] = 1,
		[3] = 2,
		[5] = 3,
		[7] = 4,
		[9] = 5,
		[11] = 6,
		[13] = 7,
		[15] = 8,
	}
	local _posToId = {
		[0] = 0,
		[1] = 1,
		[2] = 3,
		[3] = 5,
		[4] = 7,
		[5] = 9,
		[6] = 11,
		[7] = 13,
		[8] = 15,
	}
	local function _setPos(_t)
		if _t%2 ~= 0 then
			local id = _idToPos[_t % 16]
			if id > 0 and id < 9 then
				self._select:setPosition(self._pos[id])
			end
		end
	end
	--一圈16次 48 ->3圈
	print("last --> ", _posToId[self._lastTar])

	local _total = _posToId[self._lastTar] + _times
	for i = 1 + _posToId[self._lastTar], _total do
		if i <= (_total-16) then 
			_actionArray[#_actionArray+1] = cc.Sequence:create(cc.RotateBy:create(0.03, _base),cc.CallFunc:create(function() _setPos(i) end))
		elseif i <= (_total-8) then
			_actionArray[#_actionArray+1] = cc.Sequence:create(cc.RotateBy:create(0.06, _base),cc.CallFunc:create(function() _setPos(i) end))
		elseif i <= (_total-4) then
			_actionArray[#_actionArray+1] = cc.Sequence:create(cc.RotateBy:create(0.12, _base),cc.CallFunc:create(function() _setPos(i) end))
		elseif i <= (_total-2) then
			_actionArray[#_actionArray+1] = cc.Sequence:create(cc.RotateBy:create(0.15, _base),cc.CallFunc:create(function() _setPos(i) end))
		elseif i <= (_total - 1) then
			_actionArray[#_actionArray+1] = cc.Sequence:create(cc.RotateBy:create(0.25, _base),cc.CallFunc:create(function() _setPos(i) end))
		elseif i <= (_total) then
			_actionArray[#_actionArray+1] = cc.Sequence:create(cc.RotateBy:create(0.5, _base),cc.CallFunc:create(function() _setPos(i) end))
		end
	end
	--结束操作
	_actionArray[#_actionArray+1] = cc.CallFunc:create(function()
		performWithDelay(self, function()
			self:endHandle(data)
			-- test
			-- self._mask:removeFromParent()
			-- self._mask = nil
		end, 0.5)
	end)
	self._arrow:runAction(cc.Sequence:create(_actionArray))

	-- self._arrow:runAction(cc.Sequence:create(
	-- 	cc.EaseIn:create(cc.RotateBy:create(1.5, rotate - 360),1.5),
	-- 	cc.EaseOut:create(cc.RotateBy:create(1, 180), 1),
	-- 	cc.EaseOut:create(cc.RotateBy:create(1, 90), 1.0),
	-- 	cc.EaseOut:create(cc.RotateBy:create(1, 45), 1.0),
	-- 	cc.EaseOut:create(cc.RotateBy:create(1, 45), 1.0),

	-- 	cc.CallFunc:create(function()
	-- 		performWithDelay(self, function()
	-- 			-- self:endHandle(data)

	-- 			-- test
	-- 			-- self._mask:removeFromParent()
	-- 			-- self._mask = nil
	-- 		end, 0.5)
	-- 	end)
	-- ))
	self._lastTar = tar
end
function LiLianlevelUpLuckTurnPop:endHandle(data)
	
	local showData = self._preData[tonumber(self._lastTar)]

	local show = {}
	show.rewardtype = showData.rewardType
	show.id = showData.itemId
	show.num = showData.count
	ShowRewardNode:create({show}, nil, function()
		self._select:setVisible(false)
		if tonumber(data.point) == 0 then
			self._eff:setVisible(false)
		end
		if data.configs and next(data.configs)then 
			self:refreshItem()
		end
	end)

	self._mask:removeFromParent()
	self._mask = nil
	XTHDTOAST(LANGUAGE_CONGRATULATIONS_ITEM(showData.name, showData.count))

    -- 更新属性
    if data.property and #data.property > 0 then
        for i=1, #data.property do
            local pro_data = string.split( data.property[i], ',' )
            --记录数据
            if XTHD.resource.propertyToType[tonumber(pro_data[1])] then
                local idx = #show + 1
                show[idx] = {}
                show[idx].rewardtype = XTHD.resource.propertyToType[tonumber(pro_data[1])]
                show[idx].num = tonumber(pro_data[2]) - tonumber(gameUser.getDataById(pro_data[1]) or 0)
            end
            --更新数据
            DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
        end
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
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

	self._surplusLab:setString(LANGUAGE_TIPS_CHOUJIANGCOUNT..": " .. data.point)
end
function LiLianlevelUpLuckTurnPop:create(params)
	return self.new(params)
end

function LiLianlevelUpLuckTurnPop:onEnter()
	YinDaoMarg:getInstance():getACover(self._parent)
    YinDaoMarg:getInstance():addGuide({ ----点击抽一次
        parent = self,
        target = self._turnplateBtn,
		offset = cc.p(5,5),
        index = 3,
        needNext = false,
        updateServer = true,
    },3)
    performWithDelay(self,function( )    	
	    YinDaoMarg:getInstance():doNextGuide()   
	    YinDaoMarg:getInstance():removeCover(self._parent)
    end,0.2)
    -------------------
end
function LiLianlevelUpLuckTurnPop:onCleanup()
	-- print("onCleanup ====")
	if self._callback and type(self._callback) == "function" then
		self._callback()
	end
end
function LiLianlevelUpLuckTurnPop:onExit()
    YinDaoMarg:getInstance():doNextGuide()   	
end

return LiLianlevelUpLuckTurnPop