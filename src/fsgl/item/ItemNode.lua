--[[
	80x80
	(其中边框80x80，道具图片由100x100压缩到68x68)	
]]
ItemNode = class("ItemNode", function(params)
	local obj = cc.Sprite:create()
	-- 如果传入的时字符串就代表是文件名
	if type(params) == "string" then
		local _tmp = cc.Sprite:create(params)
		if _tmp then
			obj = _tmp
		end
	end
	return XTHDTouchExtend.extend(obj)
end )

function ItemNode:ctor(params)

	-- 创建默认参数
	local defaultParams = {
		_type_ = 1,
		--[[ 类型,1:元宝；2.银两；3.翡翠；4.道具 ]]
		itemId = 1,
		dbId = nil,
		quality = 1,
		--[[ 品质 ]]
		-- 元宝 5，；绿魂石 2，蓝魂石3，紫魂石4，橙魂石5，其它的4
		count = nil,
		--[[ 个数 ]]
		isShowCount = nil,
		-- 是否强制显示个数 默认false
		phaseLevel = 0,
		-- 进阶等级
		isShowPhaseLevel = true,
		-- 是否显示进阶等级
		touchShowTip = true,
		--[[ 是否触摸显示tip ]]
		anchor = cc.p(0.5,0.5),
		-- 锚点
		needSwallow = false,
		-- 是否需要吞噬事件
		clickable = true,
		-- 是否可以点击
		beganCallback = nil,
		-- 点击事件的按下回调
		endCallback = nil,
		-- 点击事件的抬起回调
		touchSize = cc.size(0,0),
		-- 点击区域，如果没有传值，则默认点击区域为getBoundingBox()
		x = 0,
		-- x
		y = 0,
		-- y
		clickScale = 1,
		fnt_type = 1,
		-- 1为白色 2为红色（通常用于XX不够的情况）
		tipDelay = 0,
		-- 按多久出tips
		consumeNeed = nil,
		-- 如果需要显示成xx/xx这种形式，就直接传入字符串。如果有consumeNeed则会忽略count
		isGrey = false,
		-- 是否需要置灰
		isLightAct = false,-- 光效
		isShowDrop = true,--是否显示道具详细信息和获取途径
	}
	self.posCallback = nil
	-- 设置tip位置
	self._itemQuality = 0
	------当前物品的品质

	self._params = params
	if params == nil then params = { } end
	for k, v in pairs(defaultParams) do
		if params[k] == nil then
			params[k] = v
		end
	end
	self.isScrollView = params.isScrollView
	self.isShowDrop = params.isShowDrop
	self.count = params.count
	-- tonumber(params.count)
	local itemId = params.itemId
	self.dbId = params.dbId
	local stardata = 0
	self._type_ = params._type_
	local quality = params.quality

	local function getGrey(filePath)
		if not cc.Director:getInstance():getTextureCache():addImage(filePath) then
			filePath = "res/image/item/props10000.png"
		end
		local _grayNode = cc.Sprite:create(filePath)
		if params.isGrey == true then
			XTHD.setGray(_grayNode, true)
			return _grayNode
		else
			return _grayNode
		end
	end

	local imgPath = nil
	--[[ 如果是元宝 ]]
	local item_img = nil
	self._Name = XTHD.resource.name[self._type_] or ""
	print("ItemNode=>" .. self._Name .. "#" .. self._type_)
	if self._type_ == XTHD.resource.type.ingot then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_INGOT)
		quality = 5
		--[[ 如果是银两 ]]
	elseif self._type_ == XTHD.resource.type.gold then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_GOLD)
		quality = 4
		--[[ 如果是翡翠 ]]
	elseif self._type_ == XTHD.resource.type.feicui then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_FEICUI)
		quality = 4
		--[[ 如果是道具 ]]
	elseif self._type_ == XTHD.resource.type.item then
		if self.dbId and params.isShowPhaseLevel then
			if itemId < 2 or tonumber(params.phaseLevel) < 1 then
				local UserData = DBTableItem.getData(gameUser.getUserId(), { dbid = self.dbId })
				self._params.itemId = UserData.itemid
				itemId = UserData.itemid
				if not UserData.itemid then
					UserData = DBTableEquipment.getData(gameUser.getUserId(), { dbid = self.dbId })
					self._params.itemId = UserData.itemid
					itemId = UserData.itemid
				end
				stardata = tonumber(UserData.phaseLevel or 0)
			else
				stardata = tonumber(params.phaseLevel or 0)
			end
		elseif self.dbId and itemId < 2 then
			local UserData = DBTableItem.getData(gameUser.getUserId(), { dbid = self.dbId })
			self._params.itemId = UserData.itemid
			itemId = UserData.itemid
			if not UserData.itemid then
				UserData = DBTableEquipment.getData(gameUser.getUserId(), { dbid = self.dbId })
				self._params.itemId = UserData.itemid
				itemId = UserData.itemid
			end
		end
		self._static_data = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = itemId })
		self._Name = self._static_data.name
		self.itemId = itemId
		quality = self._static_data.rank
		if self._static_data.type ~= 2 then
			item_img = getGrey(XTHD.resource.getItemImgById(self._static_data.resourceid))
		else
			-- 该道具是英雄魂石
			item_img = getGrey(XTHD.resource.getItemImgById(self._static_data.resourceid))
			-- item_img:setScale(70/item_img:getBoundingBox().width,70/item_img:getBoundingBox().height)
		end
		--[[ 如果是体力 ]]
	elseif self._type_ == XTHD.resource.type.tili then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_TILI)
		quality = 4
		--[[ 如果是经验 ]]
	elseif self._type_ == XTHD.resource.type.exp then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_EXP)
		quality = 4
	elseif self._type_ == XTHD.resource.type.honor then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_HONOR)
		quality = 5
	elseif self._type_ == XTHD.resource.type.azure then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_CERULEANDRAGON)
		quality = 5
	elseif self._type_ == XTHD.resource.type.white then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_WHITETIGER)
		quality = 5
	elseif self._type_ == XTHD.resource.type.vermilion then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_VINACEOUSROSEFINCH)
		quality = 5
	elseif self._type_ == XTHD.resource.type.black then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_DRAGONTORTOISE)
		quality = 5
	elseif self._type_ == XTHD.resource.type.stone then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_SAINTSTONE)
		quality = 4
	elseif self._type_ == XTHD.resource.type.servant then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_SERVANTSTONE)
		quality = 4
	elseif self._type_ == XTHD.resource.type.reward then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_AWARD)
		quality = 5
	elseif self._type_ == XTHD.resource.type.prestige then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_PRESTIGE)
		quality = 4
	elseif self._type_ == XTHD.resource.type.smeltPoint then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_SMELTPOINT)
		quality = 4
	elseif self._type_ == XTHD.resource.type.hero then
		item_img = getGrey(XTHD.resource.getHeroAvatorImgById(tonumber(self._params.itemId)))
		self._Name = gameData.getDataFromCSV("GeneralInfoList", { heroid = tonumber(self._params.itemId) }).name
		-- item_img:setScale(0.95)
		quality = gameData.getDataFromCSV("GeneralInfoList", { heroid = tonumber(self._params.itemId) }).rank or 1
	elseif self._type_ == XTHD.resource.type.bounty then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_BOUNTY)
		quality = 4
	elseif self._type_ == XTHD.resource.type.reputation then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_PRESTIGE)
		quality = 4
	elseif self._type_ == XTHD.resource.type.heroexp then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_HEROEXP)
		quality = 4
	elseif self._type_ == XTHD.resource.type.asura_blood then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_BLOOD)
		quality = 4
	elseif self._type_ == XTHD.resource.type.guild_contri then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_CONTRI)
		quality = 4
	elseif self._type_ == XTHD.resource.type.flower then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_FLOWER)
		quality = 4
	elseif self._type_ == XTHD.resource.type.soul then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_SOUL)
		quality = 4
	elseif self._type_ == XTHD.resource.type.luckyCoin then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_LOCKYCOIN)
		quality = 4
	elseif self._type_ == XTHD.resource.type.cityExp then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_CITYEXP)
		quality = 4
	elseif self._type_ == XTHD.resource.type.zhenQi then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_ZHENQI)
		quality = 4
	elseif self._type_ == XTHD.resource.type.soul_green then
		item_img = getGrey(IMAGE_KEY_HEADER_SOULG)
		quality = 4
	elseif self._type_ == XTHD.resource.type.soul_blue then
		item_img = getGrey(IMAGE_KEY_HEADER_SOULB)
		quality = 4
	elseif self._type_ == XTHD.resource.type.soul_purple then
		item_img = getGrey(IMAGE_KEY_HEADER_SOULP)
		quality = 4
	elseif self._type_ == XTHD.resource.type.soul_red then
		item_img = getGrey(IMAGE_KEY_HEADER_SOULR)
		quality = 4
	elseif self._type_ == XTHD.resource.type.servant_qly then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_QLY)
		quality = 4
	elseif self._type_ == XTHD.resource.type.servant_qcj then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_QCJ)
		quality = 4
	elseif self._type_ == XTHD.resource.type.servant_yly then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_YLY)
		quality = 4
	elseif self._type_ == XTHD.resource.type.servant_msy then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_MSY)
		quality = 4
	elseif self._type_ == XTHD.resource.type.servant_qzl then
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_QZL)
		quality = 4
	else
		item_img = getGrey(IMAGE_KEY_COMMON_ITEM_EXP)
		quality = 4
	end
	--[[
        如果再加东西 quality按照这个来
        1 经验----紫色
        2 银两----紫色
        3 元宝----橙色
        4 道具----紫色
        5 体力----紫色
        6 翡翠----紫色
        7 威望----紫色
        8 血玉----紫色
        9 荣誉----橙色
        10 神石----紫色
        11 帮派贡献----紫色
        12 奖牌----橙色
        21 绿魂石----绿色
        22 蓝魂石----蓝色
        23 紫魂石----紫色
        24 赤魂石----橙色
        30----橙色
        31----橙色
        32----橙色
        33----橙色
        100--紫色
        101--蓝色
        102--紫色
        103--橙色
        104--蓝色
        105--紫色
        106--橙色
        200 赏金----紫色
        201 声望--紫色
        202 修罗血--紫色
    ]]
	self._itemQuality = quality
	local isHero = false
	if self._type_ == XTHD.resource.type.hero then
		isHero = true
	end
	local _path = XTHD.resource.getQualityItemBgPath(quality, isHero)
	if self._static_data and self._static_data.type == 2 then
		_path = "res/image/quality/chip_" ..(self._static_data.rank or 1) .. ".png"
	end
	-- local item_border = XTHD.createSprite(_path)
	-- 框
	local item_border = ccui.Scale9Sprite:create(_path)
	self._item_border = item_border
	-- item_border:setContentSize(cc.size(80,85))
	if params.isGrey == true then
		XTHD.setGray(item_border, true)
		-- textureCache:addImage(XTHD.resource.getQualityItemBgPath(quality))
	end
	self:setContentSize(item_border:getContentSize())
	self:setCascadeOpacityEnabled(true)

	-- self:setTouchSize(cc.size(self:getBoundingBox().width+10,self:getBoundingBox().height+10))
	-- 头像
	item_img:setPosition(cc.p(self:getBoundingBox().width / 2, self:getBoundingBox().height / 2))
	item_border:setPosition(cc.p(self:getBoundingBox().width / 2, self:getBoundingBox().height / 2))
	self.item_img = item_img

	self:addChild(item_img)
	self:addChild(item_border)

    --玄符
	if self._static_data and self._static_data.type == 5 then
		_path = "res/image/quality/rank_" ..(self._static_data.rank or 1) .. ".png"
		local _sp = XTHD.createSprite(_path)
		if params.isGrey == true then
			XTHD.setGray(_sp, true)
		end
		_sp:setAnchorPoint(1, 1)
		_sp:setPosition(item_border:getContentSize().width + 2, item_border:getContentSize().height + 2)
		self:addChild(_sp)

		local _lb = XTHDLabel:createWithParams( {
			text = self._static_data.level,
			fontSize = 20,
			color = cc.c3b(255,255,255),
		} )
		_lb:setPosition(item_border:getContentSize().width - _sp:getContentSize().width * 0.5 + 2, item_border:getContentSize().height - _sp:getContentSize().height * 0.5 + 4)
		self:addChild(_lb)
	end

    --vip卡
	if self._static_data and self._static_data.resourceid == 44440 then
		_path = "res/image/quality/rank_" ..(self._static_data.rank or 1) .. ".png"
		local _sp = XTHD.createSprite(_path)
		if params.isGrey == true then
			XTHD.setGray(_sp, true)
		end
		_sp:setAnchorPoint(1, 1)
		_sp:setPosition(item_border:getContentSize().width + 2, item_border:getContentSize().height + 2)
		self:addChild(_sp)

		local _lb = XTHDLabel:createWithParams( {
			text = self._static_data.effectvalue,
			fontSize = 20,
			color = cc.c3b(255,255,255),
		} )
		_lb:setPosition(item_border:getContentSize().width - _sp:getContentSize().width * 0.5 + 2, item_border:getContentSize().height - _sp:getContentSize().height * 0.5 + 4)
		self:addChild(_lb)
	end

	if self._static_data and self._static_data.type == 3 and tonumber(self._static_data.rank) > 3 then
		XTHD.addEffectToEquipment(self, self._static_data.rank)
	elseif params.isLightAct == true then
		XTHD.addEffectToEquipment(self, 5)
	end

	if stardata > 0 then
		local starnum = stardata
		local _starPos = SortPos:sortFromMiddle(cc.p(self:getContentSize().width / 2, 5), starnum, 13)
		for i = 1, starnum do
			local _starSpr = cc.Sprite:create("res/image/common/star_light.png")
			_starSpr:setScale(0.6)
			_starSpr:setAnchorPoint(cc.p(0.5, 0))
			_starSpr:setPosition(cc.p(_starPos[i].x, _starPos[i].y))
			self:addChild(_starSpr)
		end
	end
	if not self.count then
		self.count = 0
	end
	-- self.count = self.count > 0 and self.count or 0
	local _num_label = nil
	if tonumber(self.count) then
		self.count = getHugeNumberWithLongNumber(self.count, 100000)
	end
	if params.fnt_type == 1 then
		_num_label = getCommonWhiteBMFontLabel(self.count)
	elseif params.fnt_type == 2 then
		_num_label = getCommonRedBMFontLabel(self.count)
	end
	-- _num_label:setFontSize(24)
	-- local _num_label = cc.Label:create()
	-- _num_label:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(2,-2))
	_num_label:setName("_num_label")
	_num_label:setAnchorPoint(1, 0)
	-- _num_label:setSystemFontSize(18)
	-- _num_label:setString(self.count and self.count > 0 and self.count or 0)
	_num_label:setPosition(self:getContentSize().width - 3 - 3, -2)

	if self.count and tonumber(self.count) and tonumber(self.count) < 1 then
		_num_label:setVisible(false)
	elseif not self.count then
		_num_label:setVisible(false)
	end
	self.isShowCount = params.isShowCount or nil
	if self.isShowCount == false then
		_num_label:setVisible(false)
	elseif self.isShowCount == true then
		_num_label:setVisible(true)
	end
	self:addChild(_num_label)

	if params.consumeNeed then
		_num_label:setString(params.consumeNeed)
	end

	self:setSwallowTouches(params.needSwallow)
	self:setClickable(params.clickable)

	self:setTouchBeganCallback(params.beganCallback)
	self:setTouchEndedCallback(params.endCallback)

	if params.x ~= nil then
		self:setPositionX(params.x)
	end
	if params.y ~= nil then
		self:setPositionY(params.y)
	end

	if params.pos ~= nil then
		self:setPosition(params.pos)
	end

	if params.anchor ~= nil then
		self:setAnchorPoint(params.anchor)
	end

	self:setTouchShowTip(params.touchShowTip)

	-- 开始注册点击事件
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(self._needSwallow)

	self._disPos = cc.p(0, 0)
	listener:registerScriptHandler( function(touch, event)
		self._disPos.x = 0
		self._disPos.y = 0
		local isVisible = self:isAllParentsVisible(self, touch);
		local isContain = self:isContainTouch(self, touch);
		if isVisible and isContain and self:isClickable() then
			self.originalScale = self:getScale()
			self:setScale(params.clickScale * self:getScale())
			if self:getTouchBeganCallback() then
				self:getTouchBeganCallback()()
			end
			return true
		end
		return false
	end , cc.Handler.EVENT_TOUCH_BEGAN)

	listener:registerScriptHandler( function(touch, event)
		local touchLocation = touch:getLocation()
		-- yanyuling
		local prevLocation = touch:getPreviousLocation()
		-- yanyuling
		self._disPos.x = self._disPos.x + math.abs(cc.pSub(touchLocation, prevLocation).x)
		-- yanyuling
		self._disPos.y = self._disPos.y + math.abs(cc.pSub(touchLocation, prevLocation).y)
		-- yanyuling
		if self._disPos.x > 15 or self._disPos.y > 15 then
			self.isMoveOrEnd = true
			if self.TipsBg and self:isTouchShowTip() then
				self.TipsBg:removeFromParent()
				self.TipsBg = nil
			end
		end 
		
		
	end , cc.Handler.EVENT_TOUCH_MOVED)

	local callback = function(touch, event)
		self:setScale(self.originalScale)
		self.isMoveOrEnd = true
		if self.TipsBg and self:isTouchShowTip() then
			self.TipsBg:removeFromParent()
			self.TipsBg = nil
		end
		if (math.abs(self._disPos.x) > 15 or math.abs(self._disPos.y) > 15) then
			return
		end
		local isVisible = self:isAllParentsVisible(self);
		local isContain = self:isContainTouch(self, touch);
		if isVisible and isContain and self:isClickable() then
			if self:getTouchEndedCallback() then
				self:getTouchEndedCallback()()
			end
		end
		self:setScale(self.originalScale)
		if self.TipsBg and self:isTouchShowTip() then
			self.TipsBg:removeFromParent()
			self.TipsBg = nil
		end
		if self._type_ == 4 then
			self:ShowDorp(params.itemId)
		end
	end
	listener:registerScriptHandler(callback, cc.Handler.EVENT_TOUCH_ENDED)

	listener:registerScriptHandler(callback, cc.Handler.EVENT_TOUCH_CANCELLED)



	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	-- 给精灵添加点击事件
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

	self._listener = listener



end

function ItemNode:setCountNumber(_num)
	if self:getChildByName("_num_label") then
		local _num_label = self:getChildByName("_num_label")
		if _num and type(_num) == "number" and _num > 1 then
			_num_label:setVisible(true)
		elseif not _num or(type(_num) == "number" and _num <= 1) then
			_num_label:setVisible(false)
		end
		if self.isShowCount == true then
			_num_label:setVisible(true)
		end
		if tonumber(_num) then
			_num = getHugeNumberWithLongNumber(_num, 1000000)
		end
		self:getChildByName("_num_label"):setString(_num)
	end
end

function ItemNode:getCountNumber()
	if self:getChildByName("_num_label") then
		self:getChildByName("_num_label"):getString()
	end
end

function ItemNode:getNumberLabel()
	return self:getChildByName("_num_label") or nil
end

function ItemNode:setTouchShowTip(flag)
	if self._touchShowTip ~= flag then
		self._touchShowTip = flag
		if self._type_ == 4 then
			self._touchShowTip = false
		else
			self._touchShowTip = true
			self.isShowDrop = false
		end
		if self._touchShowTip == true and not self.isShowDrop then
			self:setTouchBeganCallback( function()
				musicManager.playEffect("res/sound/sound_effect_tips.wav", false)
				self.isMoveOrEnd = false
				self:runAction(cc.Sequence:create(cc.DelayTime:create(self._params.tipDelay), cc.CallFunc:create( function()
					if self.isMoveOrEnd == false then
						self:showTip()
					end
				end )))
			end )
		else
			self:setTouchBeganCallback(nil)
		end
	end
end

function ItemNode:setShowDrop(flag)
	self.isShowDrop = flag
end

function ItemNode:ShowDorp(itemId)
	if self.isShowDrop then
		if self._type_ == XTHD.resource.type.ingot then
			local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id= 1})
			cc.Director:getInstance():getRunningScene():addChild(StoredValue, 3)
		elseif self._type_ == XTHD.resource.type.gold then
			local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id= 3})
			cc.Director:getInstance():getRunningScene():addChild(StoredValue, 3)
		elseif self._type_ == XTHD.resource.type.feicui then
			local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id= 4})
			cc.Director:getInstance():getRunningScene():addChild(StoredValue, 4) 
		elseif self._type_ == XTHD.resource.type.tili then
			local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id= 2})
			cc.Director:getInstance():getRunningScene():addChild(StoredValue, 2) 
		elseif self._type_ == XTHD.resource.type.luckyCoin then
			local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id= 6})
			cc.Director:getInstance():getRunningScene():addChild(StoredValue, 2) 
		else
			local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")	
			popLayer= popLayer:create( tonumber( itemId ) )
			cc.Director:getInstance():getRunningScene():addChild( popLayer, 3 )
		end
	end
end

function ItemNode:onCleanup()
	if self.TipsBg then
		self.TipsBg:removeFromParent()
		self.TipsBg = nil
	end
end

function ItemNode:isTouchShowTip()
	return self._touchShowTip
end

function ItemNode:showTip()

	if self.TipsBg then
		self.TipsBg:removeFromParent()
		self.TipsBg = nil
	end
	local itemId = self._params.itemId

	local tmpPos = self:convertToWorldSpace(cc.p(0.5, 0.5))

	if self._type_ == 4 then
		local dbData = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = self._params.itemId })
		if self.dbId then
			if dbData.type == 3 then
				self.TipsBg = self:_getOwnEquipTipsLayer(dbData)
				-- 拥有的装备
			else
				self.TipsBg = self:_getItemTipsLayer()
				-- 道具
			end
		else
			if dbData.type == 3 then
				self.TipsBg = self:_getEquipTipsLayer(dbData)
				-- 没有的装备
			else
				self.TipsBg = self:_getItemTipsLayer()
				-- 道具
			end
		end
	else
		if self._type_ == XTHD.resource.type.azure or self._type_ == XTHD.resource.type.white or self._type_ == XTHD.resource.type.vermilion or self._type_ == XTHD.resource.type.black or
			self._type_ == XTHD.resource.type.servant_qly or self._type_ == XTHD.resource.type.servant_qzl or self._type_ == XTHD.resource.type.servant_msy or self._type_ == XTHD.resource.type.servant_yly or self._type_ == XTHD.resource.type.servant_qcj then
			self.TipsBg = self:_getSaintTipsLayer()
			-- 神兽资源
		elseif self._type_ == XTHD.resource.type.hero then
			self.TipsBg = self:_getHeroTipsLayer()
			-- 英雄
		else
			self.TipsBg = self:_getTipsLayer()
			-- 普通资源
		end
	end

	if not self.posCallback then
		if tmpPos.x >= cc.Director:getInstance():getWinSize().width / 2 and tmpPos.y >= cc.Director:getInstance():getWinSize().height / 2 then
			-- 第一象限
			self.TipsBg:setAnchorPoint(cc.p(1, 1))
			self.TipsBg:setPosition(tmpPos.x, tmpPos.y)

		elseif tmpPos.x <= cc.Director:getInstance():getWinSize().width / 2 and tmpPos.y >= cc.Director:getInstance():getWinSize().height / 2 then
			-- 第二象限
			self.TipsBg:setAnchorPoint(cc.p(0, 1))
			self.TipsBg:setPosition(tmpPos.x + self:getBoundingBox().width, tmpPos.y)
		elseif tmpPos.x <= cc.Director:getInstance():getWinSize().width / 2 and tmpPos.y <= cc.Director:getInstance():getWinSize().height / 2 then
			-- 第三象限
			self.TipsBg:setAnchorPoint(cc.p(0, 0))
			self.TipsBg:setPosition(tmpPos.x + self:getBoundingBox().width, tmpPos.y + self:getBoundingBox().height)
		elseif tmpPos.x >= cc.Director:getInstance():getWinSize().width / 2 and tmpPos.y <= cc.Director:getInstance():getWinSize().height / 2 then
			-- 第四象限
			self.TipsBg:setAnchorPoint(cc.p(1, 0))
			self.TipsBg:setPosition(tmpPos.x, tmpPos.y + self:getBoundingBox().height)
		end

		if self.TipsBg:getAnchorPoint().y == 0 then
			if tmpPos.y + self:getBoundingBox().height + self.TipsBg:getBoundingBox().height > cc.Director:getInstance():getWinSize().height - 50 then
				self.TipsBg:setPositionY(self.TipsBg:getPositionY() -((tmpPos.y + self:getBoundingBox().height + self.TipsBg:getBoundingBox().height) -(cc.Director:getInstance():getWinSize().height - 50)))
			end
		end

		cc.Director:getInstance():getRunningScene():addChild(self.TipsBg, 5)
		self.TipsBg:setScale(0)
		self.TipsBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.05), cc.ScaleTo:create(0.01, 1)))
	else
		-- 手动设置tip位置，必须将它添加到某一节点上
		self.posCallback()
	end

end

function ItemNode:getQuality()
	return self._itemQuality
end

function ItemNode:getName()
	return self._Name
end

function ItemNode:_getItemTipsLayer()
	local id = self._params.itemId
	-- local bg = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/tips_bg.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
	-- bg:setContentSize(cc.size(281,115))

	bg:setContentSize(cc.size(320, 110))
	if id then
		local dbData = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = id })
		local descLabel = XTHDLabel:createWithParams( {
			text = dbData.effect,
			fontSize = 18,
			color = cc.c3b(255,255,255)
		} )
		descLabel:setWidth(253 + 19)
		bg:setContentSize(cc.size(320, 110 + descLabel:getBoundingBox().height))
	end

	local splitLine = cc.Sprite:create("res/image/common/common_split_line.png")
	splitLine:setPosition(bg:getBoundingBox().width / 2, bg:getBoundingBox().height - 85)
	splitLine:setScaleX(0.8)
	bg:addChild(splitLine)

	if id then
		local dbData = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = id })
		local descLabel = XTHDLabel:createWithParams( {
			text = dbData.effect,
			fontSize = 18,
			color = cc.c3b(77,77,125)-- 描述
		} )
		descLabel:setAnchorPoint(0, 0)
		descLabel:setWidth(253 + 19)
		descLabel:setPosition(23, 18)
		bg:addChild(descLabel)

		local item = ItemNode:createWithParams( {
			_type_ = 4,
			itemId = id,
			touchShowTip = false
		} )
		item:setScale(0.7)
		item:setPosition(20 + item:getBoundingBox().width / 2, bg:getBoundingBox().height - 20 - item:getBoundingBox().height / 2)
		bg:addChild(item)

		local nameLabel = XTHDLabel:createWithParams( {
			text = dbData.name,
			fontSize = 18,
			color = cc.c3b(20,114,145)-- 道具名
		} )
		nameLabel:setAnchorPoint(0, 1)
		nameLabel:setPosition(item:getPositionX() + item:getBoundingBox().width / 2 + 10, item:getPositionY() + item:getBoundingBox().height / 2)
		bg:addChild(nameLabel)

		local levelword = LANGUAGE_KEY_LEVEL_LIMIT .. ":"
		-- ..dbData.level

		local levelStr = XTHDLabel:createWithParams( {
			text = levelword,
			fontSize = 18,
			color = cc.c3b(7,105,4)-- 需求等級
		} )
		levelStr:setAnchorPoint(0, 1)
		levelStr:setPosition(item:getPositionX() + item:getBoundingBox().width / 2 + 10, item:getPositionY() - item:getBoundingBox().height / 2 + levelStr:getBoundingBox().height)
		bg:addChild(levelStr)

		local levelLabel = XTHDLabel:createWithParams( {
			text = dbData.level,
			fontSize = 18,
			color = cc.c3b(94,132,26)-- 等級
		} )
		levelLabel:setAnchorPoint(0, 1)
		levelLabel:setPosition(levelStr:getPositionX() + levelStr:getBoundingBox().width, levelStr:getPositionY())
		bg:addChild(levelLabel)
		if dbData.level == 0 then
			levelStr:setVisible(false)
			levelLabel:setVisible(false)
		end

		-- local ownNum = 0
		-- local ownData = DBTableItem.getData( gameUser.getUserId(), {itemid = id} )
		-- if #ownData ~= 0 and type(ownData[1]) == "table" then
		--     for i=1,#ownData do
		--         ownNum = ownNum + ownData[i].count
		--     end
		-- else
		--     ownNum = ownData.count or 0
		-- end

		-- local ownData = DBTableEquipment.getData(gameUser.getUserId(), {itemid = id} )
		-- if #ownData ~= 0 and type(ownData[1]) == "table" then
		--     for i=1,#ownData do
		--         ownNum = ownNum + 1
		--     end
		-- end

		local ownLabel3 = XTHDLabel:createWithParams( {
			text = "(" .. LANGUAGE_OTHER_TXTOWNED,
			fontSize = 18,
			color = cc.c3b(20,114,145)-- 擁有
		} )
		ownLabel3:setAnchorPoint(0, 1)
		ownLabel3:setPosition(nameLabel:getPositionX(), nameLabel:getPositionY() -20)
		bg:addChild(ownLabel3)

		local ownLabel2 = XTHDLabel:createWithParams( {
			text = XTHD.resource.getItemNum(id),
			fontSize = 18,
			color = cc.c3b(94,132,26)
		} )
		ownLabel2:setAnchorPoint(0, 1)
		ownLabel2:setPosition(ownLabel3:getPositionX() + ownLabel3:getBoundingBox().width, nameLabel:getPositionY() -20)
		bg:addChild(ownLabel2)


		local ownLabel1 = XTHDLabel:createWithParams( {
			text = LANGUAGE_OTHER_TXTJIAN .. ")",
			fontSize = 18,
			color = cc.c3b(20,114,145)
		} )
		ownLabel1:setAnchorPoint(0, 1)
		ownLabel1:setPosition(ownLabel2:getPositionX() + ownLabel2:getBoundingBox().width, nameLabel:getPositionY() -20)
		-- bg:getBoundingBox().width-20
		bg:addChild(ownLabel1)


		local priceLabel = XTHDLabel:createWithParams( {
			text = dbData.price,
			fontSize = 18,
			color = cc.c3b(94,132,26)-- 价格
		} )
		priceLabel:setAnchorPoint(1, 1)
		priceLabel:setPosition(bg:getBoundingBox().width - 20, levelLabel:getPositionY())
		bg:addChild(priceLabel)

		local priceIcon = cc.Sprite:create(IMAGE_KEY_HEADER_GOLD)
		priceIcon:setPosition(priceLabel:getPositionX() - priceLabel:getBoundingBox().width - priceIcon:getBoundingBox().width / 2, priceLabel:getPositionY() - priceLabel:getBoundingBox().height / 2)
		bg:addChild(priceIcon)

		if dbData.price == 0 then
			priceLabel:setVisible(false)
			priceIcon:setVisible(false)
		end
	end
	if self:isTouchShowTip() == false then
		local dialog = XTHDDialog:create()
		dialog:setTouchSize(cc.size(10000, 10000))
		bg:addChild(dialog)
		dialog:setTouchEndedCallback( function()
			bg:removeFromParent()
			--[[ 一定要记得加上这句 ]]
			self.TipsBg = nil
		end )
	end
	return bg
end

function ItemNode:_getEquipTipsLayer(dbData)
	local equipData = gameData.getDataFromCSV("EquipInfoList", { itemid = self._params.itemId })
	local _num = 0
	for i = 1, #XTHD.resource.AttributesNum do
		local nowData = tostring(equipData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]])
		if nowData ~= "0" then
			_num = _num + 1
		end
	end

	-- local bg = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/tips_bg.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
	bg:setContentSize(cc.size(320, 120))
	bg.scaleSize = bg:getBoundingBox().height

	local testHeight = XTHDLabel:createWithParams( {
		text = "1",
		fontSize = 18,
		color = cc.c3b(255,255,255)
	} )

	-- 获取弹窗描述
	bg.scaleSize = bg.scaleSize + _num * testHeight:getBoundingBox().height
	-- dbData.description = ""
	if dbData.effect ~= "" then
		local itemDesc = XTHDLabel:createWithParams( {
			text = dbData.effect,
			fontSize = 18,
			color = cc.c3b(77,77,125)
		} )
		itemDesc:setWidth(253 + 19)
		itemDesc:setAnchorPoint(0, 0)
		itemDesc:setPosition((bg:getBoundingBox().width - itemDesc:getBoundingBox().width) / 2, 19)

		local splitLine = cc.Sprite:create("res/image/common/common_split_line.png")
		splitLine:setPosition(bg:getBoundingBox().width / 2, itemDesc:getPositionY() + itemDesc:getBoundingBox().height + 8)
		splitLine:setScaleX(0.8)

		bg.scaleSize = bg.scaleSize + itemDesc:getBoundingBox().height + 7 + splitLine:getBoundingBox().height + 4
		bg:setContentSize(cc.size(bg:getBoundingBox().width, bg.scaleSize))

		bg:addChild(itemDesc)
		bg:addChild(splitLine)
	else
		bg:setContentSize(cc.size(bg:getBoundingBox().width, bg.scaleSize))
	end



	local item = self:createWithParams( {
		dbId = self._params.dbId,
		itemId = self._params.itemId,
		_type_ = 4
	} )
	item:setScale(0.7)
	item:setPosition(20 + item:getBoundingBox().width / 2, bg:getBoundingBox().height - 20 - item:getBoundingBox().height / 2)
	bg:addChild(item)

	local itemName = XTHDLabel:createWithParams( {
		text = dbData.name,
		----------------------------------装备名称
		fontSize = 18,
		color = cc.c3b(20,114,145)
	} )
	itemName:setAnchorPoint(0, 1)
	itemName:setPosition(item:getPositionX() + item:getBoundingBox().width / 2 + 10, item:getPositionY() + item:getBoundingBox().height / 2)
	bg:addChild(itemName)

	local itemType = XTHDLabel:createWithParams( {
		text = LANGUAGE_KEY_WEARHEROTYPE .. ":",
		----------------------------------穿戴英雄类型
		fontSize = 18,
		color = cc.c3b(20,114,145)
	} )
	itemType:setAnchorPoint(0, 0)
	itemType:setPosition(itemName:getPositionX(), item:getPositionY() - item:getBoundingBox().height / 2)
	bg:addChild(itemType)

	local _tb = string.split(equipData.herotype, "#")
	if #_tb == 3 then
		local heroType = XTHDLabel:createWithParams( {
			text = LANGUAGE_KEY_ALLHERO,
			fontSize = 18,
			color = cc.c3b(20,114,145)
		} )
		heroType:setAnchorPoint(0, 0)
		heroType:setPosition(itemType:getPositionX() + itemType:getBoundingBox().width, itemType:getPositionY())
		bg:addChild(heroType)
	else
		for i = 1, #_tb do
			-- ZCLOG(equipData)
			local heroType = cc.Sprite:create("res/image/plugin/hero/hero_type_" .. _tb[i] .. ".png")

			heroType:setScale(0.8)
			heroType:setPosition(heroType:getBoundingBox().width / 2 + itemType:getPositionX() + itemType:getBoundingBox().width +((i - 1) * heroType:getBoundingBox().width) +(i * 5), itemType:getPositionY() + itemType:getBoundingBox().height / 2)
			bg:addChild(heroType)
		end
	end

	local splitLine = cc.Sprite:create("res/image/common/common_split_line.png")
	splitLine:setPosition(bg:getBoundingBox().width / 2, item:getPositionY() - item:getBoundingBox().height / 2 - 8)
	splitLine:setScaleX(0.8)
	bg:addChild(splitLine)
	splitLine._num = 0
	for i = 1, #XTHD.resource.AttributesNum do
		local nowData = tostring(equipData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]])
		if nowData ~= "0" then
			splitLine._num = splitLine._num + 1
			local AttributesName = XTHDLabel:createWithParams( {
				text = XTHD.resource.getAttributes(tonumber(XTHD.resource.AttributesNum[i])) .. ":",
				fontSize = 18,
				color = cc.c3b(84,60,34)----------------------------加成属性
			} )
			AttributesName:setAnchorPoint(0, 0)
			AttributesName:setPosition(20, splitLine:getPositionY() -10 -(splitLine._num * AttributesName:getBoundingBox().height))
			bg:addChild(AttributesName)

			local _tb = string.split(nowData, "#")
			local MaxNum = _tb[2]
			local MinNum = _tb[1]
			if tonumber(XTHD.resource.AttributesNum[i]) >= 300 and tonumber(XTHD.resource.AttributesNum[i]) < 315 then
				MaxNum = MaxNum .. "%"
				MinNum = MinNum .. "%"
			end

			local AttributesNum = XTHDLabel:createWithParams( {
				text = " +(" .. MinNum .. " - " .. MaxNum .. ")",
				fontSize = 18,
				color = cc.c3b(77,77,125)
			} )
			AttributesNum:setAnchorPoint(0, 0)
			AttributesNum:setPosition(AttributesName:getPositionX() + AttributesName:getBoundingBox().width, AttributesName:getPositionY())
			bg:addChild(AttributesNum)
		end
	end

	if self:isTouchShowTip() == false then
		local dialog = XTHDDialog:create()
		dialog:setTouchSize(cc.size(10000, 10000))
		bg:addChild(dialog)
		dialog:setTouchEndedCallback( function()
			bg:removeFromParent()
			--[[ 一定要记得加上这句 ]]
			self.TipsBg = nil
		end )
	end

	return bg
end

-- 获取强化过后的属性
function ItemNode:getEquipAttr(baseAttr, phaseArr)
	local baseAttr = string.split(baseAttr, ",")
	local phaseArr = string.split(phaseArr, "#")
	for i = 1, #phaseArr do
		local phaseAttr = string.split(phaseArr[i], ",")
		if baseAttr[1] == phaseAttr[1] then
			return tonumber(baseAttr[2]) + tonumber(phaseAttr[2])
		end
	end
	return baseAttr[2]
end

function ItemNode:_getOwnEquipTipsLayer(dbData)
	local equipData = gameData.getDataFromCSV("EquipInfoList", { itemid = self._params.itemId })
	-- ZCLOG(self._params.itemId)
	local UserData = nil
	if self.dbId then
		UserData = DBTableItem.getData(gameUser.getUserId(), { dbid = self.dbId })
		if not UserData.dbid then
			UserData = DBTableEquipment.getData(gameUser.getUserId(), { dbid = self.dbId })
		end
	end
	-- UserData.baseProperty = "201,20"
	local AttributesArr = string.split(UserData.baseProperty, "#")

	-- local bg = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/tips_bg.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
	bg:setContentSize(cc.size(320, 120))
	bg.scaleSize = bg:getBoundingBox().height

	local testHeight = XTHDLabel:createWithParams( {
		text = "1",
		fontSize = 18,
		color = cc.c3b(95,93,131)
	} )

	bg.scaleSize = bg.scaleSize + #AttributesArr * testHeight:getBoundingBox().height
	-- dbData.description = ""
	if dbData.effect ~= "" then
		local itemDesc = XTHDLabel:createWithParams( {
			text = dbData.effect,
			fontSize = 18,
			color = cc.c3b(77,77,125)
		} )
		itemDesc:setWidth(253 + 19)
		itemDesc:setAnchorPoint(0, 0)
		itemDesc:setPosition((bg:getBoundingBox().width - itemDesc:getBoundingBox().width) / 2, 19)

		local splitLine = cc.Sprite:create("res/image/common/common_split_line.png")
		splitLine:setPosition(bg:getBoundingBox().width / 2, itemDesc:getPositionY() + itemDesc:getBoundingBox().height + 8)
		splitLine:setScaleX(0.8)

		bg.scaleSize = bg.scaleSize + itemDesc:getBoundingBox().height + 7 + splitLine:getBoundingBox().height + 4
		bg:setContentSize(cc.size(bg:getBoundingBox().width, bg.scaleSize))

		bg:addChild(itemDesc)
		bg:addChild(splitLine)
	else
		bg:setContentSize(cc.size(bg:getBoundingBox().width, bg.scaleSize))
	end



	local item = self:createWithParams( {
		dbId = self._params.dbId,
		itemId = self._params.itemId,
		_type_ = 4
	} )
	item:setScale(0.7)
	item:setPosition(20 + item:getBoundingBox().width / 2, bg:getBoundingBox().height - 20 - item:getBoundingBox().height / 2)
	bg:addChild(item)

	local itemName = XTHDLabel:createWithParams( {
		text = dbData.name,
		fontSize = 18,
		color = cc.c3b(95,93,131)
	} )
	itemName:setAnchorPoint(0, 1)
	itemName:setPosition(item:getPositionX() + item:getBoundingBox().width / 2 + 10, item:getPositionY() + item:getBoundingBox().height / 2)
	bg:addChild(itemName)

	if UserData then
		local itemLevel = XTHDLabel:createWithParams( {
			text = UserData.strengLevel > 0 and "Lv." .. UserData.strengLevel or LANGUAGE_KEY_HERO_TEXT.noneStrength,
			fontSize = 18,
			color = cc.c3b(95,93,131)
		} )
		itemLevel:setAnchorPoint(1, 1)
		itemLevel:setPosition(bg:getBoundingBox().width - 20, itemName:getPositionY())
		bg:addChild(itemLevel)
	end

	local itemType = XTHDLabel:createWithParams( {
		text = LANGUAGE_KEY_WEARHEROTYPE .. ":",
		fontSize = 18,
		color = cc.c3b(95,93,131)
	} )
	itemType:setAnchorPoint(0, 0)
	itemType:setPosition(itemName:getPositionX(), item:getPositionY() - item:getBoundingBox().height / 2)
	bg:addChild(itemType)

	local _tb = string.split(equipData.herotype, "#")
	if _tb == 3 then
		local heroType = XTHDLabel:createWithParams( {
			text = LANGUAGE_KEY_ALLHERO,
			fontSize = 18,
			color = cc.c3b(95,93,131)
		} )
		heroType:setAnchorPoint(0, 0)
		heroType:setPosition(itemType:getPositionX() + itemType:getBoundingBox().width, itemType:getPositionY())
		bg:addChild(heroType)
	else
		for i = 1, #_tb do
			local heroType = cc.Sprite:create("res/image/plugin/hero/hero_type_" .. _tb[i] .. ".png")
			heroType:setScale(0.8)
			heroType:setPosition(heroType:getBoundingBox().width / 2 + itemType:getPositionX() + itemType:getBoundingBox().width +((i - 1) * heroType:getBoundingBox().width) +(i * 5), itemType:getPositionY() + itemType:getBoundingBox().height / 2)
			bg:addChild(heroType)
		end
	end

	local splitLine = cc.Sprite:create("res/image/common/common_split_line.png")
	splitLine:setPosition(bg:getBoundingBox().width / 2, item:getPositionY() - item:getBoundingBox().height / 2 - 8)
	splitLine:setScaleX(0.8)
	bg:addChild(splitLine)

	for i = 1, #AttributesArr do
		local nowAttributes = AttributesArr[i]
		local _strings = string.split(nowAttributes, ",")
		local AttributesName = XTHDLabel:createWithParams( {
			text = XTHD.resource.getAttributes(_strings[1]) .. ":",
			fontSize = 18,
			color = cc.c3b(95,93,131)
		} )
		AttributesName:setAnchorPoint(0, 0)
		AttributesName:setPosition(20, splitLine:getPositionY() -10 -(i * AttributesName:getBoundingBox().height))
		bg:addChild(AttributesName)

		local OriginNum = self:getEquipAttr(nowAttributes, UserData.phaseProperty)
		OriginNum = math.floor(OriginNum + 0.5)
		if tonumber(_strings[1]) >= 300 and tonumber(_strings[1]) < 315 then
			OriginNum = "+" .. OriginNum .. "%"
		else
			OriginNum = "+" .. OriginNum
		end

		local AttributesNum = XTHDLabel:createWithParams( {
			text = " " .. OriginNum,
			fontSize = 18,
			color = cc.c3b(31,136,43)
		} )
		AttributesNum:setAnchorPoint(0, 0)
		AttributesNum:setPosition(AttributesName:getPositionX() + AttributesName:getBoundingBox().width, AttributesName:getPositionY())
		bg:addChild(AttributesNum)
	end

	if self:isTouchShowTip() == false then
		local dialog = XTHDDialog:create()
		dialog:setTouchSize(cc.size(10000, 10000))
		bg:addChild(dialog)
		dialog:setTouchEndedCallback( function()
			bg:removeFromParent()
			--[[ 一定要记得加上这句 ]]
			self.TipsBg = nil
		end )
	end

	return bg
end

-- 修罗
function ItemNode:_getTipsLayer()
	-- local bg = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/tips_bg.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
	itemtype = self._type_
	bg:setContentSize(cc.size(320, 110))
	if itemtype then
		local descLabel = XTHDLabel:createWithParams( {
			text = XTHD.resource.description[tonumber(itemtype)] or "",
			fontSize = 18,
			color = cc.c3b(255,255,255)
		} )
		descLabel:setWidth(253 + 19)
		bg:setContentSize(cc.size(320, 110 + descLabel:getBoundingBox().height))
	end

	local splitLine = cc.Sprite:create("res/image/common/common_split_line.png")
	splitLine:setPosition(bg:getBoundingBox().width / 2, bg:getBoundingBox().height - 85)
	splitLine:setScaleX(0.8)
	bg:addChild(splitLine)

	if itemtype then
		local descLabel = XTHDLabel:createWithParams( {
			text = XTHD.resource.description[tonumber(itemtype)] or "",
			fontSize = 18,
			color = cc.c3b(77,77,125)
		} )
		descLabel:setAnchorPoint(0, 0)
		descLabel:setWidth(253 + 19)
		descLabel:setPosition(23, 18)
		bg:addChild(descLabel)

		local item = ItemNode:createWithParams( {
			_type_ = self._type_
		} )
		item:setScale(0.7)
		item:setPosition(20 + item:getBoundingBox().width / 2, bg:getBoundingBox().height - 20 - item:getBoundingBox().height / 2 + 10)
		bg:addChild(item)

		if self:getChildByName("_num_label") and tonumber(self:getChildByName("_num_label"):getString()) and tonumber(self:getChildByName("_num_label"):getString()) > 0 then
			-- XTHDTOAST(itemtype)
			local levelLabel = XTHDLabel:createWithParams( {
				text = self:getChildByName("_num_label"):getString() .. XTHD.resource.name[tonumber(itemtype)] or "",
				fontSize = 18,
				color = cc.c3b(94,132,26)
			} )
			levelLabel:setAnchorPoint(0, 1)
			levelLabel:setPosition(item:getPositionX() + item:getBoundingBox().width / 2 + 10, item:getPositionY() - item:getBoundingBox().height / 2 + levelLabel:getBoundingBox().height + 10)
			bg:addChild(levelLabel)
		end

		local nameLabel = XTHDLabel:createWithParams( {
			text = XTHD.resource.name[tonumber(itemtype)] or "",
			fontSize = 18,
			color = cc.c3b(20,114,145)
		} )
		nameLabel:setAnchorPoint(0, 1)
		nameLabel:setPosition(item:getPositionX() + item:getBoundingBox().width / 2 + 10, item:getPositionY() + item:getBoundingBox().height / 2)
		bg:addChild(nameLabel)
	end

	if self:isTouchShowTip() == false then
		local dialog = XTHDDialog:create()
		dialog:setTouchSize(cc.size(10000, 10000))
		bg:addChild(dialog)
		dialog:setTouchEndedCallback( function()
			bg:removeFromParent()
			--[[ 一定要记得加上这句 ]]
			self.TipsBg = nil
		end )
	end

	return bg
end
function ItemNode:_getHeroTipsLayer()
	-- local bg = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/tips_bg.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
	itemtype = 50
	bg:setContentSize(cc.size(320, 110))
	if itemtype then
		local descLabel = XTHDLabel:createWithParams( {
			text = tostring(gameData.getDataFromCSV("GeneralInfoList",{ heroid = tonumber(self._params.itemId) })["description"]) or "",
			fontSize = 18,
			color = cc.c3b(255,255,255)
		} )
		descLabel:setWidth(253 + 19)
		bg:setContentSize(cc.size(320, 110 + descLabel:getBoundingBox().height))
	end

	local splitLine = cc.Sprite:create("res/image/common/common_split_line.png")
	splitLine:setPosition(bg:getBoundingBox().width / 2, bg:getBoundingBox().height - 85)
	splitLine:setScaleX(0.8)
	bg:addChild(splitLine)

	if itemtype then
		local descLabel = XTHDLabel:createWithParams( {
			text = tostring(gameData.getDataFromCSV("GeneralInfoList",{ heroid = tonumber(self._params.itemId) })["description"]) or "",
			fontSize = 18,
			color = cc.c3b(77,77,125)
		} )
		descLabel:setAnchorPoint(0, 0)
		descLabel:setWidth(253 + 19)
		descLabel:setPosition(23, 18)
		bg:addChild(descLabel)

		local item = ItemNode:createWithParams( {
			_type_ = self._type_,
			itemId = tonumber(self._params.itemId)
		} )
		item:setScale(0.7)
		item:setPosition(20 + item:getBoundingBox().width / 2, bg:getBoundingBox().height - 20 - item:getBoundingBox().height / 2)
		bg:addChild(item)

		-- if self:getChildByName("_num_label") and tonumber(self:getChildByName("_num_label"):getString()) and tonumber(self:getChildByName("_num_label"):getString()) > 0 then
		--     -- XTHDTOAST(itemtype)
		--     local levelLabel = XTHDLabel:createWithParams({
		--         text = self:getChildByName("_num_label"):getString()..XTHD.resource.name[tonumber(itemtype)] or "",
		--         fontSize = 18,
		--         color = cc.c3b(54,255,48)
		--     })
		--     levelLabel:setAnchorPoint(0,1)
		--     levelLabel:setPosition(item:getPositionX()+item:getBoundingBox().width/2+10,item:getPositionY()-item:getBoundingBox().height/2+levelLabel:getBoundingBox().height)
		--     bg:addChild(levelLabel)
		-- end

		local nameLabel = XTHDLabel:createWithParams( {
			text = tostring(gameData.getDataFromCSV("GeneralInfoList",{ heroid = tonumber(self._params.itemId) })["name"]) or "",
			fontSize = 18,
			color = cc.c3b(255,255,255)
		} )
		nameLabel:setAnchorPoint(0, 1)
		nameLabel:setPosition(item:getPositionX() + item:getBoundingBox().width / 2 + 10, item:getPositionY() + item:getBoundingBox().height / 2)
		bg:addChild(nameLabel)
	end

	if self:isTouchShowTip() == false then
		local dialog = XTHDDialog:create()
		dialog:setTouchSize(cc.size(10000, 10000))
		bg:addChild(dialog)
		dialog:setTouchEndedCallback( function()
			bg:removeFromParent()
			--[[ 一定要记得加上这句 ]]
			self.TipsBg = nil
		end )
	end

	return bg
end

function ItemNode:_getSaintTipsLayer()
	-- local bg = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/tips_bg.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
	itemtype = self._type_
	bg:setContentSize(cc.size(320, 110))
	if itemtype then
		local descTemp = XTHDLabel:createWithParams( {
			text = XTHD.resource.description[tonumber(itemtype)] or "",
			fontSize = 18,
			color = cc.c3b(255,255,255)
		} )
		descTemp:setWidth(253 + 19)
		bg:setContentSize(cc.size(320, 110 + descTemp:getBoundingBox().height))
	end

	local splitLine = cc.Sprite:create("res/image/common/common_split_line.png")
	splitLine:setPosition(bg:getBoundingBox().width / 2, bg:getBoundingBox().height - 85)
	splitLine:setScaleX(0.8)
	bg:addChild(splitLine)

	-- local shadow = cc.Sprite:create("res/image/common/tips_shadow.png")
	-- shadow:setScaleX(bg:getBoundingBox().width/shadow:getBoundingBox().width)
	-- -- shadow:setScaleY(1.1)
	-- shadow:setAnchorPoint(0.5,0)
	-- shadow:setPosition(bg:getContentSize().width/2,8)
	-- bg:addChild(shadow)

	if itemtype then
		local descLabel = XTHDLabel:createWithParams( {
			text = XTHD.resource.description[tonumber(itemtype)] or "",
			fontSize = 18,
			color = cc.c3b(77,77,125)
		} )
		descLabel:setAnchorPoint(0, 0)
		-- if descLabel:getBoundingBox().width > 252 then
		--     bg:setContentSize(cc.size(281,115+20))
		--     shadow:setScaleY(2.2)
		-- end
		-- descLabel:setDimensions(253,60)
		descLabel:setWidth(253 + 19)
		descLabel:setPosition(23, 18)
		bg:addChild(descLabel)
		-- shadow:setScaleY(descLabel:getBoundingBox().height/shadow:getBoundingBox().height)

		local item = ItemNode:createWithParams( {
			_type_ = self._type_
		} )
		item:setScale(0.7)
		item:setPosition(20 + item:getBoundingBox().width / 2, bg:getBoundingBox().height - 20 - item:getBoundingBox().height / 2)
		bg:addChild(item)

		local nameLabel = XTHDLabel:createWithParams( {
			text = XTHD.resource.name[tonumber(itemtype)] or "",
			fontSize = 18,
			color = cc.c3b(255,255,255)
		} )
		nameLabel:setAnchorPoint(0, 1)
		nameLabel:setPosition(item:getPositionX() + item:getBoundingBox().width / 2 + 10, item:getPositionY() + item:getBoundingBox().height / 2)
		bg:addChild(nameLabel)
	end

	if self:isTouchShowTip() == false then
		local dialog = XTHDDialog:create()
		dialog:setTouchSize(cc.size(10000, 10000))
		bg:addChild(dialog)
		dialog:setTouchEndedCallback( function()
			bg:removeFromParent()
			--[[ 一定要记得加上这句 ]]
			self.TipsBg = nil
		end )
	end

	return bg
end

function ItemNode:getImg()
	return self.item_img
end

function ItemNode:setPosCallback(_callback)
	self.posCallback = _callback or nil
end
function ItemNode:getTipBg()
	return self.TipsBg or nil
end


--     创建默认参数
-- local defaultParams = {
--     itemId          = 1,
--     quality         = 1,--[[品质]]
--     count           = 1,--[[个数]]
--     _type_          = 1,--[[类型,1:元宝；2.银两；3.翡翠；4.道具]]
--     touchShowTip    = true,--[[是否触摸显示tip]]
--     anchor          = cc.p(0.5,0.5),--锚点
--     needSwallow     = false,--是否需要吞噬事件
--     clickable       = true,--是否可以点击
--     beganCallback   = nil,--点击事件的按下回调
--     endCallback     = nil,--点击事件的抬起回调
--     touchSize       = cc.size(0,0),--点击区域，如果没有传值，则默认点击区域为getBoundingBox()
--     x               = 0,--x
--     y               = 0--y
-- }
function ItemNode:createWithParams(params)
	return ItemNode.new(params)
end

