-- Created By Liuluyang 2015年05月19日
HeroNode = class("HeroNode", function(params)
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
-- PS: 当创建的是英雄头像时，传入的advance字段没有使用。
function HeroNode:ctor(params)
	-- 创建默认参数
	local defaultParams = {
		heroid = 1,
		-- 英雄id
		advance = nil,
		--[[ 品质 ]]
		star = nil,
		-- 星级  -1不显示星级
		level = nil,
		-- 等级  -1不显示等级
		isHero = true,
		-- 英雄还是怪物
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
		-- 点击区域，如果没有传值，则默认点击区域为getBoundingBox()噶
		x = 0,
		-- x
		y = 0,
		-- y
		needHp = false,
		-- 是否需要显示血条
		curNum = nil,
		-- 当前血量
		maxNum = nil,
		-- 满血血量 不一定要传 不传就自动去表里取
		percent = nil,
		-- 血量百分比 若有百分比则忽略之前传的cur和max 最好用cur创建
		deadNeedCall = false,
		deadCallback = nil,
		isShowType = false,  --是否显示属性标识
	}

	if params == nil then params = { } end
	for k, v in pairs(defaultParams) do
		if params[k] == nil then
			params[k] = v
		end
	end

	self._params = params
	self.isScrollView = params.isScrollView
	local targetData = nil
	if (params.needHp == true and not params.maxNum and not params.resourceId) or not params.advance or not params.star or not params.level then
		if params.isHero == true then
			targetData = gameData.getDataFromDynamicDB(gameUser.getUserId(), "hero", { heroid = params.heroid })
		else
		end
	end
	if not params.maxNum and params.needHp == true then
		params.maxNum = targetData.hp
	end

	local hero_img = cc.Sprite:create()
	if params.heroid then
		hero_img = cc.Sprite:create(XTHD.resource.getHeroAvatorImgById(params.resourceId or params.heroid))
	end
	if params.isHero == true then
		local data = gameData.getDataFromCSV("GeneralInfoList")
        local _staticData = {}
        for k,v in pairs(data) do
            _staticData[v.heroid] = v
        end
		_staticData = _staticData[tonumber(params.heroid)] or { }
		params.advance = _staticData.rank or 1
	end
	if params.advance == nil then
		params.advance = targetData.advance or targetData.rank or 0
	end
	local item_border = cc.Sprite:create(XTHD.resource.getQualityHeroBgPath(params.advance))
	self:setContentSize(item_border:getBoundingBox())
	self:setCascadeOpacityEnabled(true)

	self:setTouchSize(cc.size(self:getBoundingBox().width, self:getBoundingBox().height))
	item_border:setAnchorPoint(0.5, 1)
	hero_img:setPosition(cc.p(item_border:getBoundingBox().width / 2, item_border:getBoundingBox().height / 2))
	hero_img:setName("hero_img")
	item_border:setPosition(cc.p(self:getBoundingBox().width / 2, self:getBoundingBox().height))
	item_border:addChild(hero_img)
	item_border:setName("item_border")
	self:addChild(item_border)

	if params.isHero == true and params.isShowType then
		local heroData = gameData.getDataFromCSV("GeneralInfoList", { heroid = params.heroid })
		local type_bg = cc.Sprite:create("res/image/plugin/hero/hero_type_" .. (heroData.type or 1) .. ".png")
	    self:addChild(type_bg,10)
	    type_bg:setPosition(self:getContentSize().width - 15,self:getContentSize().height - 15)
	    self.typePic = type_bg
	end

	if params.star == nil then
		params.star = targetData.star or 0
	end

	if params.level == nil then
		params.level = targetData.level or 0
	end

	if params.star > 0 then
		local maxStar = XTHD.getHeroMaxStar(params.heroid)
		local ILevel = params.star
		local starnum = 0
		if ILevel ~= 0 then
			starnum = ILevel % maxStar == 0 and maxStar or ILevel % maxStar
		end
		if starnum <= 5 then
			for i = 1, starnum do
				local star = cc.Sprite:create("res/image/common/star_icon.png")
				star:setName("star_sp" .. i)
				local lenth = -5
				local bgwidth = self:getBoundingBox().width
				local minbg =(bgwidth -(math.min(starnum, 5) * star:getBoundingBox().width) -(math.min(starnum, 5) * lenth)) / 2
				if i <= 5 then
					local x
					if starnum == 1 then
						x = minbg + 12 +((i - 1) *(lenth + star:getBoundingBox().width - 10)) + star:getBoundingBox().width / 2 - star:getBoundingBox().width * 0.5
					elseif starnum == 2 then
						x = minbg + 20 +((i - 1) *(lenth + star:getBoundingBox().width - 10)) + star:getBoundingBox().width / 2 - star:getBoundingBox().width * 0.25 - 5
					elseif starnum == 3 then
						x = minbg + 20 +((i - 1) *(lenth + star:getBoundingBox().width - 10)) + star:getBoundingBox().width / 2 - star:getBoundingBox().width * 0.25
					else
						x = minbg + 20 +((i - 1) *(lenth + star:getBoundingBox().width - 10)) + star:getBoundingBox().width / 2 - 3
					end
					star:setPosition(x, self:getBoundingBox().height * 0.15)
					item_border:addChild(star)
					star:setScale(0.6)
				else
					star:setPosition(minbg + 15 +((i - 6) *(lenth + star:getBoundingBox().width - 10)) + star:getBoundingBox().width / 2, self:getBoundingBox().height * 0.32)
					item_border:addChild(star)
					star:setScale(0.6)
				end
			end
		else
			local moonC = math.floor(starnum / 6)
			local starC = starnum % 6
			for i = 1, moonC do
				local star = cc.Sprite:create("res/image/common/moon_icon.png")
				star:setName("star_sp" .. i)
				local lenth = -5
				local bgwidth = self:getBoundingBox().width
				local minbg =(bgwidth -(math.min(starnum, 5) * star:getBoundingBox().width) -(math.min(starnum, 5) * lenth)) / 2
				if i <= 5 then
					star:setPosition(minbg + 20 +((i - 1) *(lenth + star:getBoundingBox().width - 10)) + star:getBoundingBox().width / 2, self:getBoundingBox().height * 0.15)
					item_border:addChild(star)
					star:setScale(0.6)
				else
					star:setPosition(minbg + 20 +((i - 6) *(lenth + star:getBoundingBox().width - 10)) + star:getBoundingBox().width / 2, self:getBoundingBox().height * 0.32)
					item_border:addChild(star)
					star:setScale(0.6)
				end
			end
			for i = moonC + 1, moonC + starC do
				local star = cc.Sprite:create("res/image/common/star_icon.png")
				star:setName("star_sp" .. i)
				local lenth = -5
				local bgwidth = self:getBoundingBox().width
				local minbg =(bgwidth -(math.min(starnum, 5) * star:getBoundingBox().width) -(math.min(starnum, 5) * lenth)) / 2
				if i <= 5 then
					star:setPosition(minbg + 20 +((i - 1) *(lenth + star:getBoundingBox().width - 10)) + star:getBoundingBox().width / 2, self:getBoundingBox().height * 0.15)
					item_border:addChild(star)
					star:setScale(0.6)
				else
					star:setPosition(minbg + 20 +((i - 6) *(lenth + star:getBoundingBox().width - 10)) + star:getBoundingBox().width / 2, self:getBoundingBox().height * 0.32)
					item_border:addChild(star)
					star:setScale(0.6)
				end
			end
		end

	end

	if params.needHp == true then

		self.progressBarBg = cc.Sprite:create("res/image/common/hp_progressbar_bg.png")
		self.progressBarBg:setAnchorPoint(0.5, 1)
		self.progressBarBg:setPosition(self:getBoundingBox().width / 2, 0)
		self:addChild(self.progressBarBg)

		self.progressBar = cc.ProgressTimer:create(cc.Sprite:create("res/image/common/hp_progressbar.png"))
		self.progressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
		self.progressBar:setBarChangeRate(cc.p(1, 0))
		self.progressBar:setMidpoint(cc.p(0, 0.5))
		self.progressBar:setPosition(self.progressBarBg:getBoundingBox().width / 2, self.progressBarBg:getBoundingBox().height / 2)
		self.progressBarBg:addChild(self.progressBar)

		self.deadLabel = XTHDLabel:createWithParams( {
			text = LANGUAGE_KEY_DEFEATED,
			fontSize = 20,
			color = XTHD.resource.color.red_desc
		} )
		self.deadLabel:setAnchorPoint(0.5, 1)
		self.deadLabel:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))
		self.deadLabel:setPosition(self.progressBarBg:getPositionX(), self.progressBarBg:getPositionY())
		self:addChild(self.deadLabel)

		if params.curNum then
			if not params.percent then
				params.percent =(params.curNum / params.maxNum) * 100
			end
			self.progressBar:setPercentage(params.percent)
		else
			self.progressBar:setPercentage(100)
		end
		self:refreshHpStatus()
	end



	if tonumber(params.level) > 0 then
		local level_bg = cc.Sprite:create("res/image/common/common_herolevelBg.png")
		level_bg:setTag(1)
		level_bg:setName("level_bg")
		level_bg:setAnchorPoint(0, 0)
		if params.star <= 30 then
			level_bg:setPosition(6, 20)
		else
			level_bg:setPosition(6, 40)
		end
		hero_img:addChild(level_bg)

		local label_level = XTHDLabel:create(params.level, 20)
		label_level:setColor(cc.c3b(255, 255, 255))
		label_level:enableShadow(cc.c4b(255, 255, 255, 255), cc.size(0.4, -0.4), 0.4)
		label_level:setName("label_level")
		label_level:setCascadeColorEnabled(true)
		label_level:setPosition(level_bg:getContentSize().width / 2, level_bg:getContentSize().height / 2)
		level_bg:addChild(label_level)
	end

	self:setSwallowTouches(params.needSwallow)
	self:setClickable(params.clickable)

	self:setTouchBeganCallback(params.beganCallback)
	self:setTouchEndedCallback(params.endCallback)
	self:setTouchDeadEndedCallback(params.deadCallback)

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

	end , cc.Handler.EVENT_TOUCH_MOVED)

	local callback = function(touch, event)
		if (math.abs(self._disPos.x) > 15 or math.abs(self._disPos.y) > 15) then
			return
		end
		local isVisible = self:isAllParentsVisible(self);
		local isContain = self:isContainTouch(self, touch);
		if isVisible and isContain and self:isClickable() then
			if params.needHp == true then
				if self:getHp() <= 0 and params.deadNeedCall == true then
					if self:getTouchDeadEndedCallback() then
						self:getTouchDeadEndedCallback()()
					else
						print("无死亡回调")
					end
					return
				end
			end
			if self:getTouchEndedCallback() then
				self:getTouchEndedCallback()()
			end
		end
	end
	listener:registerScriptHandler(callback, cc.Handler.EVENT_TOUCH_ENDED)

	listener:registerScriptHandler(callback, cc.Handler.EVENT_TOUCH_CANCELLED)



	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	-- 给精灵添加点击事件
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

	self._listener = listener
end

--[[
    以下三个方法：setHp、getMaxHp、getHp，只能在通过cur形式创建的时候才能调用
]]
function HeroNode:setHp(Hp, duration, isDuration)
	-- 变动后血量 血条滚动时间(默认0.2) 是否需要滚动(默认true)
	if not duration then
		duration = 0.2
	end

	if isDuration == nil then
		isDuration = true
	end

	if self.progressBar and self._params.maxNum then
		self._params.curNum = Hp
		if isDuration == true then
			self.progressBar:runAction(cc.ProgressTo:create(duration,(self._params.curNum / self._params.maxNum) * 100))
		else
			self.progressBar:setPercentage((self._params.curNum / self._params.maxNum) * 100)
		end
		self:refreshHpStatus()
	end
end

function XTHDTouchExtend:setTouchDeadEndedCallback(callback)
	self._deadEndCallback = callback
end
function XTHDTouchExtend:getTouchDeadEndedCallback()
	return self._deadEndCallback
end

function HeroNode:getMaxHp()
	if self._params.maxNum then
		return tonumber(self._params.maxNum)
	end
end

function HeroNode:getHp()
	return tonumber(self._params.curNum) or self:getMaxHp()
end

function HeroNode:refreshHpStatus()
	if self.progressBar:getPercentage() == 0 then
		if self._params.heroid then
			XTHD.setGray(self:getChildByName("item_border"):getChildByName("hero_img"), true)
		end
		self.progressBarBg:setVisible(false)
		self.deadLabel:setVisible(true)
	else
		if self._params.heroid then
			XTHD.setGray(self:getChildByName("item_border"):getChildByName("hero_img"), false)
		end
		self.progressBarBg:setVisible(true)
		self.deadLabel:setVisible(false)
	end
end

function HeroNode:setHpByPercent(percent, duration)
	if not duration then
		duration = 0.2
	end
	if self.progressBar then
		self.progressBar:runAction(cc.ProgressTo:create(duration, percent))
	end
end

function HeroNode:getHpByPercent()
	if self.progressBar then
		return self.progressBar:getPercentage()
	end
end

function HeroNode:setEnableWhenMoving()

end

function HeroNode:createWithParams(params)
	return HeroNode.new(params)
end