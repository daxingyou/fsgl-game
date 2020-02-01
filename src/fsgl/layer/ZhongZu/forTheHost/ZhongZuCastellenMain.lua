--[[
种族城主争霸主界面 
]]

local ZhongZuCastellenMain = class("ZhongZuCastellenMain",function( )
	return XTHDDialog:create()		
end)

function ZhongZuCastellenMain:ctor(cityID,perPage,data)
	self._cityID = cityID
	self._prePage = perPage
	self._selectedCityID = cityID
	self._preSelectedCityID = cityID --------前一次选择的城主ID

	self._maxChalTimes = data.maxChallengeCount
	self._usedChalTimes = data.curChallengeCount
	self._serverData = {}
	self._cityBtns = {} --------城市按钮们
	for k,v in pairs(data.list) do 
		self._serverData[v.cityId] = v
	end 	

	self._selectedCityIndex = 1
	self._selectedCity = nil 
	self._rightBg = nil
	self._spineNode = nil
	self._castellenName = nil 
	self._isSelfHost = false -------自己是否是城主

	self.Tag = {	
		ktag_spineContainer = 100,
	}
	------
    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_CASTELLEN_AFTER_BATTLE,callback = function( event ) ----有新玩家加入 
    	self:refreshCastellenAfterBattle()
    end})
end

function ZhongZuCastellenMain:create(cityID,perPage)
	XTHDHttp:requestAsyncInGameWithParams({
        modules = "cityMasterList?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
				local layer = ZhongZuCastellenMain.new(cityID,perPage,data)
				if layer then 
					layer:init()
				end
				LayerManager.addLayout(layer)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingParent = perPage,
        loadingType = HTTP_LOADING_TYPE.CIRCLE--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ZhongZuCastellenMain:onCleanup( )	
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_CASTELLEN_AFTER_BATTLE)
end

function ZhongZuCastellenMain:init( )
	local _bg = cc.Sprite:create("res/image/camp/camp_bg1.png")
	self:addChild(_bg)
	self._bg = _bg
	_bg:setContentSize(cc.Director:getInstance():getWinSize())
	_bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	------上边框
	local _borderU = cc.Sprite:create("res/image/camp/camp_border.png")
	self:addChild(_borderU)
	_borderU:setAnchorPoint(0.5,1)
	_borderU:setOpacity(0)
	_borderU:setPosition(self:getContentSize().width / 2,self:getContentSize().height)
	-----关闭按钮
	local button = XTHD.createPushButtonWithSound({
		normalFile = "res/image/common/btn/btn_back_normal.png",
		selectedFile = "res/image/common/btn/btn_back_selected.png",
	},3)
	button:setTouchEndedCallback(function( )
		if self._prePage then 
			self._prePage:refreshCastellen()
		end 
		LayerManager.removeLayout()
	end)
	button:setAnchorPoint(1,1)
	self:addChild(button)
	button:setPosition(self:getContentSize().width,self:getContentSize().height)
	------下边框
	local _borderD = cc.Sprite:createWithTexture(_borderU:getTexture())	
	self:addChild(_borderD)
	_borderD:setOpacity(0)
	_borderD:setFlippedY(true)
	_borderD:setFlippedX(true)
	_borderD:setAnchorPoint(0.5,0)
	_borderD:setPosition(self:getContentSize().width / 2,0)
	--竞争城主之位背景
	local jz_bg = ccui.Scale9Sprite:create("res/image/camp/camp_label16_bg.png")
	jz_bg:setAnchorPoint(0.5,0)
	jz_bg:setScale(0.8)
	jz_bg:setPosition(self:getContentSize().width / 2,_borderU:getPositionY() - _borderU:getContentSize().height - jz_bg:getContentSize().height +35)
	self._bg:addChild(jz_bg)

	------竞争城主之位
	local _label = cc.Sprite:create("res/image/camp/camp_label16.png")
	jz_bg:addChild(_label)
	_label:setAnchorPoint(0.5,0.5)
	_label:setScale(0.8)
	_label:setPosition(jz_bg:getContentSize().width / 2,jz_bg:getContentSize().height*0.5 + 10)
	-----小提示	
	local _tips = cc.Sprite:create("res/image/camp/camp_label13.png")
	jz_bg:addChild(_tips)
	_tips:setAnchorPoint(0.5,0)
	_tips:setPosition(jz_bg:getContentSize().width*0.5,_label:getPositionY() -_label:getContentSize().height * 0.5 - _tips:getContentSize().height*0.5- 40 )
	------城主
	local _tempData = self._serverData[self._selectedCityID]
	local _castellen = cc.Sprite:create("res/image/camp/camp_castellen_name.png")
	self._bg:addChild(_castellen)
	_castellen:setPosition(self._bg:getContentSize().width * 0.5,self._bg:getContentSize().height*0.75 )
	-----详细信息
	-- button = XTHD.createPushButtonWithSound({
	-- 	normalFile = "res/image/common/btn/btn_green_up.png",
	-- 	selectedFile = "res/image/common/btn/btn_green_down.png",
	-- },3)
	button = XTHD.createCommonButton({
		btnColor = "write_1",
		isScrollView = false,
		text = LANGUAGE_TIPS_FRIENDINFO_CHAKAN,
		fontSize = 28,
	})
	button:setScale(0.7)
	button:setTouchEndedCallback(function( )
		if self._serverData[self._selectedCityID].masterType ~= 0 then 
			
			HaoYouPublic.httpLookFriendInfo(self,self._serverData[self._selectedCityID].baseId,function( sData )
				
				LayerManager.addShieldLayout()
				
				local _infolayer = requires("src/fsgl/layer/HaoYou/ChaKanOtherPlayerInfoLayer.lua"):create(sData)
			
				LayerManager.addLayout(_infolayer)
			end)
		else -----代理城主  
			XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS53)
		end 
	end)
	self._bg:addChild(button)
	button:setPosition(self:getContentSize().width / 2,self._bg:getContentSize().height*0.5 - 180)
	-- local _word = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_FRIENDINFO_CHAKAN,XTHD.SystemFont,18)
	-- _word:setColor(cc.c3b(59,115,0))
	-- _word:enableShadow(cc.c4b(59,115,0,0xff),cc.size(0.5,-0.5))
	-- button:addChild(_word)
	-- _word:setPosition(button:getContentSize().width / 2,button:getContentSize().height / 2)	
	------玩家名字加等级 
	local _name = XTHDLabel:createWithSystemFont(_tempData.heroName,XTHD.SystemFont,24)
	_name:setColor(cc.c3b(0xff,240,0))
	_name:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,0))
	self:addChild(_name)
	_name:setAnchorPoint(0.5,0.5)
	_name:setPosition(_castellen:getPositionX() - 5,_castellen:getPositionY() - _castellen:getContentSize().height / 2 - 18)
	self._castellenName = _name
	-----a英雄Spine
    local _path = "res/spine/"..string.format("%03d",_tempData.heroId)
    local _spine = sp.SkeletonAnimation:createWithBinaryFile(_path..".skel",_path..".atlas",1.0)
    self._spineNode = cc.Node:create()
    _spine:setAnimation(0,"idle",true)
    self._spineNode:addChild(_spine)
    self._bg:addChild(self._spineNode,0,self.Tag.ktag_spineContainer)
    self._spineNode:setPosition(self._bg:getContentSize().width / 2,self._bg:getContentSize().height * 0.5 - 125)
	self._spineNode:setScale(0.8)
    self._isSelfHost = (_tempData.baseId == gameUser:getUserId())
	------右边的半月背景
	-- local _bg = cc.Sprite:create("res/image/camp/regist/camp_right_b.png")
	-- self:addChild(_bg)
	-- _bg:setAnchorPoint(0,0.5)
	-- _bg:setPosition(self:getContentSize().width - _bg:getContentSize().width - 40,self:getContentSize().height / 2)
	-- self._rightBg = _bg

	self:initLeftCities()
	self:initRightCities()
end
-----初始化左边的城主
function ZhongZuCastellenMain:initLeftCities( )
	local off = self:getContentSize().width / 6
	local x,y = 40,115
	for i = 1,5 do 
		local button = XTHD.createPushButtonWithSound({
			normalFile = "res/image/camp/map/camp_build_circle"..i..".png",
			selectedFile = "res/image/camp/map/camp_build_circle"..(i + 10)..".png"
		},3)
		button:setTouchEndedCallback(function( )
			self:doClickCity(button)
		end)
		self:addChild(button)
		button:setScale(0.6)
		button:setAnchorPoint(0.5,1)
		button:setPosition(off * i, y)
		-- y = y - button:getContentSize().height
		-- x = x + button:getContentSize().width-30
		-----建筑
		-- local _city = cc.Sprite:create("res/image/camp/map/camp_build_circle"..i..".png")
		-- button:addChild(_city)
		-- _city:setAnchorPoint(0,0.5)
		-- _city:setPosition(5,button:getContentSize().height / 2 + 3)
		-----镜面 
		-- local _mirror = cc.Sprite:create("res/image/camp/camp_mirror_bg.png")
		-- button:addChild(_mirror)		
		-- _mirror:setAnchorPoint(0,0.5)
		-- _mirror:setPosition(_city:getPositionX() - 2,_city:getPositionY() - 1)
		-----选中的圈
		-- local _circle = cc.Sprite:create("res/image/camp/camp_circle1.png")
		-- button:addChild(_circle)
		-- _circle:setAnchorPoint(0,0.5)
		-- _circle:setPosition(0-1,button:getContentSize().height / 2 + 1)
		-- button.selectedCircle = _circle
		button:setTag(i)
		if i == self._cityID then 
		-- 	_circle:setVisible(true)
			button:setSelected(true)
			self._selectedCity = button
		else 
		-- 	_circle:setVisible(false)			
		end 
		----名字
		-- local _cityName = cc.Sprite:create("res/image/camp/map/camp_cityName_yellow"..i..".png")
		-- button:addChild(_cityName)
		-- _cityName:setAnchorPoint(0,0.5)
		-- _cityName:setPosition(_city:getPositionX() + _city:getContentSize().width + 20,button:getContentSize().height / 2)
		----
		button.hostID = self._serverData[i].baseId
		self._cityBtns[i] = button
	end 
end

function ZhongZuCastellenMain:initRightCities( )
	--城主奖励框
	local kuang1 = ccui.Scale9Sprite:create("res/image/camp/kuang1.png")
	kuang1:setPosition(32,self:getContentSize().height - 50)
	kuang1:setAnchorPoint(0,1)
	self:addChild(kuang1)
	kuang1:setScale(0.8)

	------城主奖励
	local _tips = cc.Sprite:create("res/image/camp/camp_label14.png")
	kuang1:addChild(_tips)
	_tips:setAnchorPoint(0.5,0.5)
	_tips:setPosition(kuang1:getContentSize().width / 2,kuang1:getContentSize().height)
	------两行字
	local x,y = _tips:getPositionX(),_tips:getPositionY() - _tips:getContentSize().height + 5
	for i = 1,2 do 
		local _word = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_CASTELLENREWARDTIPS[i],XTHD.SystemFont,20)
		-- _word:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,0))
		_word:setColor(cc.c3b(0,0,0))
		kuang1:addChild(_word)
		_word:setWidth(150)
		_word:setAnchorPoint(0.5,1)
		_word:setPosition(x,y)
		y = y - _word:getContentSize().height - 5
	end 
	--抢夺时间框
	local kuang2 = ccui.Scale9Sprite:create("res/image/camp/kuang1.png")
	kuang2:setPosition(self:getContentSize().width-32,self:getContentSize().height - 50)
	kuang2:setAnchorPoint(1,1)
	self:addChild(kuang2)
	kuang2:setScale(0.8)
	------抢夺时间 
	_tips = cc.Sprite:create("res/image/camp/camp_label15.png")
	kuang2:addChild(_tips)
	_tips:setAnchorPoint(0.5,0.5)
	_tips:setPosition(kuang2:getContentSize().width / 2,kuang2:getContentSize().height)
	-----说明 
	local _word = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS44,XTHD.SystemFont,20)
	-- _word:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,0))
	kuang2:addChild(_word)
	_word:setColor(cc.c3b(0,0,0))
	_word:setAnchorPoint(0.5,0.5)
	_word:setWidth(150)
	-- _word:setAnchorPoint(0,1)
	_word:setPosition(kuang2:getContentSize().width / 2,kuang2:getContentSize().height/2)
	-------t挑战按钮带动作的
	-- local button = XTHD.createFightBtn({
    -- 	par = self._rightBg,
    -- 	pos = cc.p(_tips:getPositionX() + _tips:getContentSize().width - 10,_tips:getPositionY() - _tips:getContentSize().height - 150)
	-- })
	local button = XTHD.createPushButtonWithSound({
		normalFile = "res/image/camp/tiaozhan.png",
		selectedFile = "res/image/camp/tiaozhan.png"
	})
	button:setScale(0.8)
	button:setPosition(cc.p(self._bg:getContentSize().width-70,self._bg:getContentSize().height*0.5))
	button:setAnchorPoint(1,0.5)
	self._bg:addChild(button)

	button:setTouchBeganCallback(function()
		button:setScale(0.78)
	end)

	button:setTouchMovedCallback(function()
		button:setScale(0.8)
	end)

	button:setTouchEndedCallback(function( )
		button:setScale(0.8)
		self:doFight()
	end)
	--剩余挑战次数框
	local kuang3 = ccui.Scale9Sprite:create("res/image/camp/kuang2.png")
	kuang3:setPosition(32,150)
	kuang3:setAnchorPoint(0,0)
	self:addChild(kuang3)
	kuang3:setScale(0.8)

	------今日剩余挑战次数 
	local _restOfTimes = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS45..":",XTHD.SystemFont,18)----今日剩余挑战次数文字 
	kuang3:addChild(_restOfTimes)
	_restOfTimes:setAnchorPoint(0,0.5)
	_restOfTimes:setColor(cc.c3b(54,55,112))
	_restOfTimes:setPosition(10,kuang3:getContentSize().height/2)	

	--框4
	local kuang4 = ccui.Scale9Sprite:create("res/image/camp/kuang3.png")
	kuang4:setAnchorPoint(1,0.5)
	kuang4:setPosition(kuang3:getContentSize().width-15,_restOfTimes:getPositionY())
	kuang3:addChild(kuang4)

	local str = string.format("%d/%d",(self._maxChalTimes - self._usedChalTimes),self._maxChalTimes)
	-- local _times = XTHDLabel:createWithSystemFont(str,XTHD.SystemFont,18)----今日剩余挑战次数 
	local _times = XTHDLabel:create(str,18,"res/fonts/def.ttf")
	--_times:enableOutline(cc.c4b(45,13,103,255),1)
	kuang4:addChild(_times)
	_times:setAnchorPoint(0.5,0.7)
	_times:setColor(cc.c3b(255,255,255))
	_times:setPosition(kuang4:getContentSize().width / 2,kuang4:getContentSize().height/2 +4)
	self._restOfChalTimes = _times
end

function ZhongZuCastellenMain:doClickCity( sender )
	if sender then 		
		local _id = sender:getTag()
		if _id == self._selectedCityID then 
			return 
		end 
		sender:setSelected(true)
		-- sender.selectedCircle:setVisible(true)		
		self._selectedCityIndex = sender:getTag()
		if self._selectedCity then 
			self._selectedCity:setSelected(false)
			-- self._selectedCity.selectedCircle:setVisible(false)
			self._selectedCity = sender
		end
		local _tempData = self._serverData[_id] 
		self:refreshCastellen(_tempData)
		self._preSelectedCityID = self._selectedCityID
		self._selectedCityID = _id
		if sender.hostID == gameUser.getUserId() then 
			self._isSelfHost = true 
		else 
			self._isSelfHost = false
		end 
	end 
end
------刷新当前的城主信息
function ZhongZuCastellenMain:refreshCastellen(data)
	if not data then 
		return 
	end 
	if self._castellenName then -------名字
		self._castellenName:setString(data.heroName)
	end 
	if self._restOfChalTimes then ------剩余挑战次数 
		local str = string.format("%d/%d",(self._maxChalTimes - self._usedChalTimes),self._maxChalTimes)
		self._restOfChalTimes:setString(str)
	end 
	if self._spineNode then -----城市人物
		self._spineNode:removeAllChildren()
	    local _path = "res/spine/"..string.format("%03d",data.heroId)
	    local _spine = sp.SkeletonAnimation:createWithBinaryFile(_path..".skel",_path..".atlas",1.0)
	    _spine:setAnimation(0,"idle",true)
	    self._spineNode:addChild(_spine)
	end 
	self._isSelfHost = (data.baseId == gameUser.getUserId())	
end
-----当挑战城主战斗结束之后刷新城主信息
function ZhongZuCastellenMain:refreshCastellenAfterBattle( )
	XTHDHttp:requestAsyncInGameWithParams({
        modules = "cityMasterList?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
				self._maxChalTimes = data.maxChallengeCount
				self._usedChalTimes = data.curChallengeCount
				for k,v in pairs(data.list) do ----设置数据
					self._serverData[v.cityId] = v
					if self._cityBtns[v.cityId] then 
						self._cityBtns[v.cityId].hostID = v.baseId
					end 
				end
				self:refreshCastellen(self._serverData[self._selectedCityID])
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ZhongZuCastellenMain:doFight( )
	if self._isSelfHost then 
		XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS14) ----你已是该城城主
		return
	elseif self._maxChalTimes - self._usedChalTimes < 1 then -----挑战次数已用完 
		XTHDTOAST(LANGUAGE_TIPS_WORDS32)
		return 
	end 
	if not ZhongZuDatas._localCity then 
    	ZhongZuDatas._localCity = gameData.getDataFromCSV("RacialCityList")
    end 
	local staticData = ZhongZuDatas._localCity
	local challageData = {
		cityId = self._selectedCityID,
		name = staticData[self._selectedCityID].cityName ..(LANGUAGE_CAMP_BUILDBTNWORDS[3]),
		teams = {}
	}
	LayerManager.addShieldLayout()
    local SelHeroLayer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua")
    local _layerHandler = SelHeroLayer:create(BattleType.CASTELLAN_FIGHT, nil, challageData)
    fnMyPushScene(_layerHandler)
end

return ZhongZuCastellenMain