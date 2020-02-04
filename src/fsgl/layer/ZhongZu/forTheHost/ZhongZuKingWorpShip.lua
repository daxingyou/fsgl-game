--[[
城主膜拜界面
]]

local ZhongZuKingWorpShip = class("ZhongZuKingWorpShip",function( )
	return XTHDDialog:create()		
end)

function ZhongZuKingWorpShip:ctor(cityID,prePage,data)
	self._cityID = cityID
	self._selectedCityID = cityID

	self._maxChalTimes = data.maxChallengeCount
	self._usedChalTimes = data.curChallengeCount

	self._serverData = {}
	for k,v in pairs(data.list) do 
		self._serverData[v.cityId] = v
	end 	

    self._text1 = "每个种族的长安城城主默认为：巅峰王者，成为巅峰王者之后，会在王者雕像内展示，并享有王者特殊待遇。"
    self._text2 = "巅峰王者接受膜拜，便会获得鲜花，每被膜拜一次，便会增加10朵鲜花，鲜花可在鲜花商店内兑换稀有物品。"

	self._selectedCityIndex = 1
	self._selectedCity = nil 
	self._rightBg = nil
	self._spineNode = nil
	self._castellenName = nil  --城主名字
	self._ramainCount = nil      --剩余膜拜次数文本框
	self._isSelfHost = false -------自己是否是城主

    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_CASTELLEN_AFTER_BATTLE,callback = function( event ) ----有新玩家加入 
    	self:refreshCastellenAfterBattle()
    end})
end

function ZhongZuKingWorpShip:create(cityID,prePage)
	XTHDHttp:requestAsyncInGameWithParams({
        modules = "cityMasterList?",
        successCallback = function(data)
        -- print("城主膜拜服务器返回数据为：---------------")
        -- print_r(data)
            if tonumber(data.result) == 0 then
				local layer = ZhongZuKingWorpShip.new(cityID,prePage,data)
				if layer then 
					layer:init()
				end
				LayerManager.addLayout(layer)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingParent = prePage,
        loadingType = HTTP_LOADING_TYPE.CIRCLE--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ZhongZuKingWorpShip:onCleanup( )	
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_CASTELLEN_AFTER_BATTLE)
end

function ZhongZuKingWorpShip:init( )
	local _bg = cc.Sprite:create("res/image/camp/worpship/mobaibg1.png")
	local size = cc.Director:getInstance():getWinSize()
	_bg:setContentSize(size)
	self:addChild(_bg)
	_bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)

	-----关闭按钮
	local button = XTHD.createPushButtonWithSound({
		normalFile = "res/image/common/btn/btn_back_normal.png",
		selectedFile = "res/image/common/btn/btn_back_selected.png",
	},3)
	button:setTouchEndedCallback(function( )
		LayerManager.removeLayout()
	end)
	button:setAnchorPoint(1,1)
	self:addChild(button)
	button:setPosition(self:getContentSize().width,self:getContentSize().height)

	------巅峰王者
	local _label = cc.Sprite:create("res/image/camp/worpship/mobaiicon1.png")
	self:addChild(_label)
	_label:setAnchorPoint(0.5,0)
	_label:setScale(1)
	_label:setPosition(self:getContentSize().width / 2,self:getContentSize().height - 80)

	------城主
	local _tempData = self._serverData[self._selectedCityID]

    --剩余膜拜次数
    local _count = XTHDLabel:createWithSystemFont("剩余膜拜次数：0",XTHD.SystemFont,23)
	_count:setColor(cc.c3b(0,255,0))
	_count:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,0))
	self:addChild(_count)
	_count:setAnchorPoint(0.5,0.5)
	_count:setPosition(self:getContentSize().width/2,self:getContentSize().height/2 - 255)
	self._ramainCount = _count
    self._ramainCount:setString("剩余膜拜次数："..tostring(gameUser.getCurWorpShip()))
	-----英雄
    local _path = "res/spine/"..string.format("%03d",_tempData.heroId)
    local _spine = sp.SkeletonAnimation:createWithBinaryFile(_path..".skel",_path..".atlas",1.0)
    self._spineNode = cc.Node:create()
	self._spineNode:setAnchorPoint(0.5,0)
    _spine:setAnimation(0,"idle",true)
    self._spineNode:addChild(_spine)
    self:addChild(self._spineNode,0,100)
    self._spineNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2 - 130)
    self._isSelfHost = (_tempData.baseId == gameUser:getUserId())

	------玩家名字加等级 
	local _name = XTHDLabel:createWithSystemFont(_tempData.heroName,XTHD.SystemFont,35)
	_name:setColor(cc.c3b(0xff,240,0))
	_name:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,0))
	self:addChild(_name)
	_name:setAnchorPoint(0.5,0.5)
	_name:setPosition(self:getContentSize().width/2, self._spineNode:getPositionY() + 270)
	self._castellenName = _name

	local offsetX = GetScreenOffsetX()
--	print("----------------------offsetx:"..offsetX)

    --第一个框
    local kuang1 = ccui.Scale9Sprite:create("res/image/camp/worpship/mobaibg2.png")
	kuang1:setPosition(210 + offsetX,self:getContentSize().height - 250)
	kuang1:setScale(0.9)
	self:addChild(kuang1)

    local text1 = XTHDLabel:createWithSystemFont("巅峰王者",XTHD.SystemFont,25)
	text1:setColor(cc.c3b(255,0,0))
	text1:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,0))
	text1:setPosition(kuang1:getContentSize().width/2 - 90,kuang1:getContentSize().height - 20)
	kuang1:addChild(text1)

	local text2 = XTHDLabel:createWithSystemFont(self._text1,XTHD.SystemFont,26)
	text2:setColor(cc.c3b(72,61,139))
	-- text2:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,0))
	text2:setPosition(kuang1:getContentSize().width/2 + 5,kuang1:getContentSize().height/2 - 30)
	text2:setDimensions(kuang1:getContentSize().width - 10,kuang1:getContentSize().height - 10)
	kuang1:addChild(text2)

    --第二个框
	local kuang2 = ccui.Scale9Sprite:create("res/image/camp/worpship/mobaibg2.png")
	kuang2:setPosition(self:getContentSize().width - 200 - offsetX,self:getContentSize().height - 250)
	kuang2:setScale(0.9)
	self:addChild(kuang2)

	local text3 = XTHDLabel:createWithSystemFont("王者待遇",XTHD.SystemFont,25)
	text3:setColor(cc.c3b(255,0,0))
	text3:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,0))
	text3:setPosition(kuang2:getContentSize().width/2 - 90,kuang2:getContentSize().height - 20)
	kuang2:addChild(text3)

	local text4 = XTHDLabel:createWithSystemFont(self._text2,XTHD.SystemFont,26)
	text4:setColor(cc.c3b(72,61,139))
	-- text4:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,0))
	text4:setPosition(kuang2:getContentSize().width/2 + 5,kuang2:getContentSize().height/2 - 30)
	text4:setDimensions(kuang2:getContentSize().width - 10,kuang2:getContentSize().height - 10)
	kuang2:addChild(text4)
 
    --夺权按钮
    local button = XTHD.createPushButtonWithSound({
		normalFile = "res/image/camp/tiaozhan.png",
		selectedFile = "res/image/camp/tiaozhan.png"
	})
	button:setScale(0.8)
	button:setPosition(cc.p(self:getContentSize().width-50 - button:getContentSize().width*0.5,self:getContentSize().height/2 - 230 + button:getContentSize().width * 0.5))
	button:setAnchorPoint(0.5,0.5)
	self:addChild(button)
	
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

	--膜拜按钮
    local button2 = XTHD.createPushButtonWithSound({
		normalFile = "res/image/camp/worpship/mobaibtn_up.png",
		selectedFile = "res/image/camp/worpship/mobaibtn_down.png"
	})
	button2:setScale(1)
	button2:setPosition(cc.p(self:getContentSize().width/2 + 80,self:getContentSize().height/2 - 230))
	button2:setAnchorPoint(1,0)
	self:addChild(button2)
	button2:setTouchEndedCallback(function( )
		self:worship()
	end)


end

function ZhongZuKingWorpShip:worship()
	ClientHttp:requestAsyncInGameWithParams({
        modules = "worship?",
        params  = {worshipType = 1},
        successCallback = function( data )
            -- print("膜拜城主服务器返回参数为：")
            -- print_r(data)
            if tonumber(data.result) == 0 then
                local show = {} --奖励展示
				--货币类型
				if data.property and #data.property > 0 then
					for i=1,#data.property do
						local pro_data = string.split( data.property[i],',')
						--如果奖励类型存在，而且不是vip升级(406)则加入奖励
						print(XTHD.resource.propertyToType[tonumber(pro_data[1])])
						if tonumber(pro_data[1]) ~= 406 and XTHD.resource.propertyToType[tonumber(pro_data[1])] then
							local getNum = tonumber(pro_data[2]) - tonumber(gameUser.getDataById(pro_data[1]))
							if getNum > 0 then
								local idx = #show + 1
								show[idx] = {}
								show[idx].rewardtype = XTHD.resource.propertyToType[tonumber(pro_data[1])]
								show[idx].num = getNum
							end
						end
						DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
					end
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 		--刷新数据信息
				end
	
				--物品类型
				if data.bagItems and #data.bagItems ~= 0 then
					for i=1,#data.bagItems do
						local item_data = data.bagItems[i]
						local showCount = item_data.count
						if item_data.count and tonumber(item_data.count) ~= 0 then
							--print("itemCount: "..DBTableItem.getCountByID(item_data.dbId))
							showCount = item_data.count - tonumber(DBTableItem.getCountByID(item_data.dbId));
							DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
						else
							DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
						end
						--如果奖励类型
						local idx = #show + 1
						show[idx] = {}
						show[idx].rewardtype = 4 -- item_data.item_type
						show[idx].id = item_data.itemId
						show[idx].num = showCount
					end
				end
				--显示领取奖励成功界面
				ShowRewardNode:create(show)
				RedPointManage:reFreshDynamicItemData() 
				local num = data.maxWorship - data.worshipSum
				gameUser.setCurWorpShip(num)
				self._ramainCount:setString("剩余膜拜次数："..num)
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

------刷新当前的城主信息
function ZhongZuKingWorpShip:refreshCastellen(data)
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
function ZhongZuKingWorpShip:refreshCastellenAfterBattle( )
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

function ZhongZuKingWorpShip:doFight( )
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

return ZhongZuKingWorpShip