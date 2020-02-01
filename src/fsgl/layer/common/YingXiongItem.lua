
--用来创建一个英雄头像，头像有点击事件，下面的小星星，如果你不需要小星星，可以通过设置决定是否显示
--YingXiongItem 是一个基于 XTHDPushButton 的节点
YingXiongItem = class("YingXiongItem", function (hero_data)
	local headBtnPath = XTHD.resource.getQualityHeroBgPath(hero_data["advance"])
	local _herospPath = XTHD.resource.getHeroAvatorImgById(hero_data["heroid"])
	local head_sp = cc.Sprite:create(_herospPath)
	head_sp:setName("head_sp")

	local _normalSprite = cc.Sprite:create(headBtnPath)
	local _selectedSprite = cc.Sprite:create(headBtnPath)
	local head_btn =XTHDPushButton:createWithParams({
				normalNode        = _normalSprite,--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
	            selectedNode      = _selectedSprite,
	            needSwallow       = false,--是否吞噬事件
	            needEnableWhenMoving = true 
			})
	head_btn:setScale(84/head_btn:getBoundingBox().width)
 	local level_bg = cc.Sprite:createWithTexture(nil,cc.rect(0,0,28,17))
 	level_bg:setTag(1)
 	level_bg:setColor(cc.c3b(0,0,0))
 	level_bg:setOpacity( 125.0 )
 	level_bg:setName("level_bg")
 	-- level_bg:setAnchorPoint(0,1)
 	-- level_bg:setPosition(0,head_sp:getContentSize().height)
 	level_bg:setAnchorPoint(0,0)
 	level_bg:setPosition(8,20)
 	head_sp:addChild(level_bg)
 	if tonumber(hero_data["level"]) <= 0 then
 		level_bg:setVisible(false)
 	end

 	if hero_data["star"] > 0 then
		local maxStar = XTHD.getHeroMaxStar(hero_data.heroid)
        local ILevel = hero_data.star
        local starnum = 0
        if ILevel ~= 0 then
            starnum = ILevel%maxStar == 0 and maxStar or ILevel%maxStar
        end
		local moonC = math.floor(starnum/6)
		local starC = starnum%6
		local star_pos_arr = SortPos:sortFromMiddle(cc.p(head_btn:getContentSize().width / 2,3) , moonC + starC , 15)
		if starnum <= 5 then
			for i=1,starnum do
				local star = cc.Sprite:create("res/image/common/star_icon.png")
				star:setName("star_sp" .. i)
				star:setScale(0.6)
				star:setAnchorPoint(0.5,0)
				star:setPosition( star_pos_arr[i].x, star_pos_arr[i].y )
				head_btn:addChild(star,1)
			end
		else
			for i = 1,moonC do
				local star = cc.Sprite:create("res/image/common/moon_icon.png")
				star:setName("star_sp" .. i)
				star:setScale(0.6)
				star:setAnchorPoint(0.5,0)
				star:setPosition( star_pos_arr[i].x, star_pos_arr[i].y )
				head_btn:addChild(star,1)
			end
			for i = moonC + 1,moonC + starC do
				local star = cc.Sprite:create("res/image/common/star_icon.png")
				star:setName("star_sp" .. i)
				star:setScale(0.6)
				star:setAnchorPoint(0.5,0)
				star:setPosition( star_pos_arr[i].x, star_pos_arr[i].y )
				head_btn:addChild(star,1)
			end
		end
		
--	 	local star_number = hero_data["star"]
--	 	local star_pos_arr = SortPos:sortFromMiddle(cc.p(head_btn:getContentSize().width / 2,3) , star_number , 14)
--	 	for i=0,star_number-1 do
--	 		local star_sp = cc.Sprite:create("res/image/common/item_star.png")
--	 		star_sp:setScale(0.8)
--	 		star_sp:setName("star_sp" .. tostring(i))
--	 		star_sp:setAnchorPoint(0.5,0)
--	 		star_sp:setPosition(star_pos_arr[i+1])
--	 		head_btn:addChild(star_sp,1)
--	 	end
	end
 	if tonumber(hero_data["level"]) > 0 then
	 	local label_level =getCommonWhiteBMFontLabel(hero_data["level"]) --XTHDLabel:create(hero_data["level"] , 16)
	 	-- label_level:setColor(cc.c3b(255,255,255))
	 	-- label_level:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))
	 	label_level:setName("label_level")
	 	label_level:setCascadeColorEnabled(true)
	 	label_level:setPosition(level_bg:getContentSize().width / 2 , level_bg:getContentSize().height / 2-4)
	 	level_bg:addChild(label_level)
 	end

 	head_sp:setPosition(head_btn:getContentSize().width/2, head_btn:getContentSize().height/2)
	head_btn:addChild(head_sp,-1)

	if hero_data.needHp == true then
        if not hero_data.percent then
            hero_data.percent = (hero_data.curNum / hero_data.maxNum) * 100
        end
        local progressBarBg = cc.Sprite:create("res/image/common/hp_progressbar_bg.png")
        progressBarBg:setAnchorPoint(0.5,1)
        progressBarBg:setPosition(head_sp:getBoundingBox().width/2,head_sp:getBoundingBox().height)
        head_sp:addChild(progressBarBg)

        local progressBar = cc.ProgressTimer:create(cc.Sprite:create("res/image/common/hp_progressbar.png"))
        progressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        progressBar:setBarChangeRate(cc.p(1,0))
        progressBar:setMidpoint(cc.p(0,0.5))
        progressBar:setPosition(progressBarBg:getBoundingBox().width/2,progressBarBg:getBoundingBox().height/2)
        progressBarBg:addChild(progressBar)
        progressBar:setPercentage(hero_data.percent)
    end
	 
 	return head_btn
end)

function YingXiongItem:getLevelLabel()
	return  self:getChildByName("head_sp"):getChildByName("level_bg"):getChildByName("label_level")
end

function YingXiongItem:refreshItemInfo(params)
	local default = {
		heroid   =1,
		star   = 1,
		level = 1,
		advance = 1,
		needHp = false,
		percent = nil,
		curNum = 100,
		maxNum = 100,
	}
	if params["heroid"] == nil and params["id"] == true then 
		params["heroid"] = params["id"]
	end
	for k,v in pairs(default) do
		if params[k] == nil then
			params[k] = v
		end
	end
	local _staticData = gameData.getDataFromCSV("GeneralInfoList")
    _staticData = _staticData[tonumber(params.heroid)] or {}
    params.advance = _staticData.rank or 1
	
	local _heroSpPath = XTHD.resource.getHeroAvatorImgById(params["heroid"])
	local _headBtnpath = XTHD.resource.getQualityHeroBgPath(params["advance"])
	self:getStateNormal():initWithFile(_headBtnpath)
	self:getStateSelected():initWithFile(_headBtnpath)
	self:getChildByName("head_sp"):initWithFile(_heroSpPath)

	local _level_bg = self:getChildByName("head_sp"):getChildByName("level_bg")
	if tonumber(params["level"]) <= 0 then
 		_level_bg:setVisible(false)
 	end

 	for i=0,5 do
 		if self:getChildByName("star_sp" .. tostring(i)) then
 			self:removeChildByName("star_sp" .. tostring(i))
 		end
 	end

 	if params["star"] > 0 then
		local maxStar = XTHD.getHeroMaxStar(params.heroid)
        local ILevel = params.star
        local starnum = 0
        if ILevel ~= 0 then
            starnum = ILevel%maxStar == 0 and maxStar or ILevel%maxStar
        end
		local moonC = math.floor(starnum/6)
		local starC = starnum%6
		local star_pos_arr = SortPos:sortFromMiddle(cc.p(head_btn:getContentSize().width / 2,3) , moonC + starC , 15)
		if starnum <= 5 then
			for i=1,starnum do
				local star = cc.Sprite:create("res/image/common/star_icon.png")
				star:setName("star_sp" .. i)
				star:setScale(0.6)
				star:setAnchorPoint(0.5,0)
				star:setPosition( star_pos_arr[i].x, star_pos_arr[i].y )
				head_btn:addChild(star,1)
			end
		else
			for i = 1,moonC do
				local star = cc.Sprite:create("res/image/common/moon_icon.png")
				star:setName("star_sp" .. i)
				star:setScale(0.6)
				star:setAnchorPoint(0.5,0)
				star:setPosition( star_pos_arr[i].x, star_pos_arr[i].y )
				head_btn:addChild(star,1)
			end
			for i = moonC + 1,moonC + starC do
				local star = cc.Sprite:create("res/image/common/star_icon.png")
				star:setName("star_sp" .. i)
				star:setScale(0.6)
				star:setAnchorPoint(0.5,0)
				star:setPosition( star_pos_arr[i].x, star_pos_arr[i].y )
				head_btn:addChild(star,1)
			end
		end
--	 	local star_number = params["star"]
--	 	local star_pos_arr = SortPos:sortFromMiddle(cc.p(self:getContentSize().width / 2,3) , star_number , 14 + 3)
--	 	for i=0,star_number-1 do
--	 		local star_sp = cc.Sprite:create("res/image/common/item_star.png")
--	 		star_sp:setName("star_sp" .. tostring(i))
--	 		star_sp:setAnchorPoint(0.5,0)
--	 		star_sp:setPosition(star_pos_arr[i+1])
--	 		self:addChild(star_sp,1)
--	 	end
	 end
 	if tonumber(params["level"]) > 0 then
 		if _level_bg:getChildByName("label_level") then
 			_level_bg:getChildByName("label_level"):setString(params["level"])
 		else
 			local label_level = XTHDLabel:create(hero_data["level"] , 16)
		 	label_level:setColor(cc.c3b(255,255,255))
		 	label_level:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))
		 	label_level:setName("label_level")
		 	label_level:setCascadeColorEnabled(true)
		 	label_level:setPosition(_level_bg:getContentSize().width / 2 , _level_bg:getContentSize().height / 2 - 4)
		 	_level_bg:addChild(label_level)
 		end
	 	
 	end
end

function YingXiongItem:ctor(params)
end

--[[
	params={
	heroid = 1, or id =1 --此处会做一个数据判断，支持传递heroid，或者 id，增加容错性
	star   = 3,
	level = 10,
	advance = 3,
	}
]]
function YingXiongItem:createWithParams(params)
	local default = {
		heroid   =1,
		star   = 1,
		level = 1,
		advance = 1,
	}
	if params["heroid"] == nil and params["id"] == true then 
		params["heroid"] = params["id"]
	end
	for k,v in pairs(default) do
		if params[k] == nil then
			params[k] = v
		end
	end
	local data = gameData.getDataFromCSV("GeneralInfoList")
	local _staticData = {}
	for k, v in pairs(data) do
		_staticData[v.heroid] = v
	end
    _staticData = _staticData[tonumber(params.heroid)] or {}
    params.advance = _staticData.rank or 1
	return self.new(params)
end