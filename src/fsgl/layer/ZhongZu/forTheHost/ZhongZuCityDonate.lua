--[[
种族建筑捐献
]]

local ZhongZuCityDonate = class("ZhongZuCityDonate",function( )
	return XTHD.createBasePageLayer()
end)

function ZhongZuCityDonate:ctor(cityID,parent,serverData)
	self._serverData = serverData
	self._cityID = cityID
	self._parent = parent

	self._cityLevelLabel = nil ----当前建筑的等级
	self._contentBg = nil 
	self._lookRangeBtn = nil ----查看捐献排行按钮

	self._donateTimes = 1 -----捐献次数

	self._cityName = nil ----当前城市的名字
	self._levelUpBar = nil ----城市升级进度条
	self._progressWord = nil -------进度条上的字
	self._restOfDonTimes = nil ----当前剩余的捐献次数

	self._propContainer = nil ---- 当前建筑的属性容器
	self._rankContainer = nil -----当前建筑捐献的前三名排行

	self._donateCost = {} -----各种捐献的消耗 1元宝 2翡翠 3银两

	local _level = serverData.level or 1
	self._cityLevel = _level
end

function ZhongZuCityDonate:create(cityID,parent)
	XTHDHttp:requestAsyncInGameWithParams({
        modules = "cityDetail?",
        params = {cityId = cityID},
        successCallback = function(data)
            if tonumber(data.result) == 0 then
            	local layer = ZhongZuCityDonate.new(cityID,parent,data)
				if layer then 
					layer:init()
				end 
				LayerManager.addLayout(layer)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingParent = parent,
        loadingType = HTTP_LOADING_TYPE.CIRCLE--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ZhongZuCityDonate:init( )
	------背景
	local bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
	self:addChild(bg)
	self._bg = bg
	bg:setPosition(self:getContentSize().width / 2,(self:getContentSize().height - self.topBarHeight) / 2)

	local title = "res/image/public/cityjuanxian_title.png"
	XTHD.createNodeDecoration(self._bg,title)

	-----第二层背景
	local _secondBg = ccui.Scale9Sprite:create()	
	_secondBg:setContentSize(cc.size(self._bg:getContentSize().width - 8,bg:getContentSize().height - 105))
	self._bg:addChild(_secondBg)
    _secondBg:setAnchorPoint(0.5,0)
	_secondBg:setPosition(self._bg:getContentSize().width / 2,10)
	self._contentBg = _secondBg
	------主标题
	local _title = cc.Sprite:create("res/image/camp/camp_label10.png")
	bg:addChild(_title)
	_title:setPosition(bg:getContentSize().width / 2,bg:getContentSize().height - _title:getContentSize().height-16)
	-------当前城市的名字了
	local _cityName = cc.Sprite:create("res/image/camp/map/camp_cityName_yellow"..self._cityID..".png")
	bg:addChild(_cityName)
	_cityName:setAnchorPoint(0,0.5)
	self._cityName = _cityName
	----等级
	local _levelD = self._serverData.level or 1
	local _level = XTHDLabel:create("LV:".._levelD,24,"res/fonts/def.ttf")
	_level:setColor(cc.c3b(205,101,8))
	_level:enableShadow(cc.c4b(205,101,8,0xff),cc.size(1,0))
	_level:setAnchorPoint(0,0.5)
	bg:addChild(_level)
	self._cityLevelLabel = _level
	----进度条
	local _barBg = cc.Sprite:create("res/image/camp/common_progressBg_2.png")
	bg:addChild(_barBg)
	_barBg:setAnchorPoint(0,0.5)
	-----
	local _bar = ccui.LoadingBar:create("res/image/camp/common_progress_2.png",100)
	_barBg:addChild(_bar)
	_bar:setPosition(_barBg:getContentSize().width / 2,_barBg:getContentSize().height / 2)
	self._levelUpBar = _bar
	-----进度字
	local _progressWord = XTHDLabel:create("100/100",18,"res/fonts/def.ttf")
	_progressWord:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,-1))
	_barBg:addChild(_progressWord)
	_progressWord:setPosition(_barBg:getContentSize().width / 2,_barBg:getContentSize().height / 2)
	self._progressWord = _progressWord

	local x = (_cityName:getContentSize().width + _level:getContentSize().width + _barBg:getContentSize().width)
	x = (bg:getContentSize().width - x) / 2
	_cityName:setPosition(x,_title:getPositionY() - _title:getContentSize().height)
	_level:setPosition(x + _cityName:getContentSize().width,_cityName:getPositionY())
	_barBg:setPosition(_level:getPositionX() + _level:getContentSize().width,_cityName:getPositionY())
	-------
	self:initLeftContent()
	self:initRightContent()

	self:refreshBuildDynamicData()
end

function ZhongZuCityDonate:initLeftContent( )
	-- local _bg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277,34))
	local _bg = cc.Sprite:create("res/image/camp/dqcsxg.png")
	self._contentBg:addChild(_bg)
	_bg:setPosition(self._bg:getContentSize().width * 1/4 - 55,self._contentBg:getContentSize().height - _bg:getContentSize().height / 2 - 5)
	--背景框
	local bg_kuang1 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
	bg_kuang1:setContentSize(350,180)
	bg_kuang1:setAnchorPoint(0.5,1)
	bg_kuang1:setPosition(self._bg:getContentSize().width * 1/4 - 55+10,self._contentBg:getContentSize().height - _bg:getContentSize().height / 2 - 5)
	self._contentBg:addChild(bg_kuang1,-1)
	--=-----升级城市效果变化
	local _word = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS40,XTHD.SystemFont,18) -----升级城市效果变化
	_word:setColor(XTHD.resource.color.gray_desc)
	-- _bg:addChild(_word)
	_word:setPosition(_bg:getContentSize().width / 2,_bg:getContentSize().height / 2)
	----------属性
	local container = ccui.Layout:create()
	container:setContentSize(cc.size(355,150))
	self._contentBg:addChild(container)
	container:setAnchorPoint(0.5,1)
	container:setPosition(_bg:getPositionX() + 10,_bg:getPositionY() - _bg:getContentSize().height / 2 - 5)
	self._propContainer = container

	self:createCityProperty()
	------分隔线
	local _line = cc.Sprite:create("res/image/common/line.png")
	self._contentBg:addChild(_line)
	_line:setOpacity(0)
	_line:setScaleY(300 / _line:getContentSize().width)
	_line:setPosition(_bg:getPositionX(),container:getPositionY() - container:getContentSize().height - 10)
	------捐献次数排行
	local _bg2 = cc.Sprite:create("res/image/camp/jxcsph.png")
	self._contentBg:addChild(_bg2)
	_bg2:setAnchorPoint(0.5,1)
	_bg2:setPosition(_bg:getPositionX(),_line:getPositionY() - _line:getContentSize().height - 5)
	--背景框
	local bg_kuang2 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
	bg_kuang2:setContentSize(350,170)
	bg_kuang2:setAnchorPoint(0.5,1)
	bg_kuang2:setPosition(_bg:getPositionX()+10,_line:getPositionY() - _line:getContentSize().height - 5-15)
	self._contentBg:addChild(bg_kuang2,-1)
	-------字
	_word = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS41,XTHD.SystemFont,18) -----升级城市效果变化
	_word:setColor(cc.c3b(104, 33, 11))
	-- _bg2:addChild(_word)
	_word:setPosition(_bg2:getContentSize().width / 2,_bg2:getContentSize().height / 2)
	-----捐献次数排行榜
	local container = ccui.Layout:create()
	container:setContentSize(cc.size(300,95))
	self._contentBg:addChild(container)
	container:setAnchorPoint(0.5,1)
	container:setPosition(_bg2:getPositionX(),_bg2:getPositionY() - _bg2:getContentSize().height)
	self._rankContainer = container
	---------查看排行按钮
	local _button = XTHD.createPushButtonWithSound({
		normalFile = "res/image/common/btn/btn_write_up.png",
		selectedFile = "res/image/common/btn/btn_write_down.png"
	},3)
	_button:setTouchEndedCallback(function( )
		local layer = requires("src/fsgl/layer/ZhongZu/ZhongZuRangeLayer.lua"):create(self._serverData.list,"donate")
		self:addChild(layer,2)
		layer:show()
	end)
	_button:setScale(0.8)
	local _btnWord = XTHDLabel:create(LANGUAGE_KEY_SEARCHRANGE,20,"res/fonts/def.ttf")
	_btnWord:setColor(cc.c3b(255,255,255))
	_btnWord:enableOutline(cc.c4b(84,3,3,255),2)
	_button:addChild(_btnWord)
	_button:setAnchorPoint(0.5,1)
	_btnWord:setPosition(_button:getContentSize().width / 2,_button:getContentSize().height / 2)
	self._contentBg:addChild(_button)
	_button:setPosition(_bg2:getPositionX(),container:getPositionY() - container:getContentSize().height)
	self._lookRangeBtn = _button
	----------与左边的分隔
	local _line = cc.Sprite:create("res/image/common/common_split_line.png")
	self._contentBg:addChild(_line)
	_line:setOpacity(0)
	_line:setScaleX(350 / _line:getContentSize().width)
	_line:setScaleY(2 / _line:getContentSize().height)
	_line:setRotation(90)
	_line:setPosition(self._contentBg:getContentSize().width / 2 - 80,self._contentBg:getContentSize().height / 2)
	local _rightSplit = cc.Sprite:create("res/image/ranklistreward/splitY.png")
	_rightSplit:setScaleY(self._contentBg:getContentSize().height / _rightSplit:getContentSize().height)
	self._contentBg:addChild(_rightSplit)
	_rightSplit:setAnchorPoint(1,0.5)
	_rightSplit:setPosition(_line:getPositionX(),_line:getPositionY())

	self:createFront3Range()
end

function ZhongZuCityDonate:initRightContent( )
	------四个 边角
	-- for i = 1,4 do 
	-- 	local _icon = cc.Sprite:create("res/image/common/common_cloud.png")
	-- 	self._contentBg:addChild(_icon)
	-- 	if i == 1 then 
	-- 		_icon:setFlippedX(true)
	-- 		_icon:setAnchorPoint(0,1)
	-- 		_icon:setPosition(self._contentBg:getContentSize().width / 2 - 80,self._contentBg:getContentSize().height)
	-- 	elseif i == 2 then 
	-- 		_icon:setAnchorPoint(1,1)
	-- 		_icon:setPosition(self._contentBg:getContentSize().width,self._contentBg:getContentSize().height)
	-- 	elseif i == 3 then 
	-- 		_icon:setFlippedY(true)
	-- 		_icon:setAnchorPoint(1,0)
	-- 		_icon:setPosition(self._contentBg:getContentSize().width,0)
	-- 	elseif i == 4 then 
	-- 		_icon:setFlippedX(true)
	-- 		_icon:setFlippedY(true)
	-- 		_icon:setAnchorPoint(0,0)
	-- 		_icon:setPosition(self._contentBg:getContentSize().width / 2 - 80,0)
	-- 	end 
	-- end 
	
	-------每次捐献奖励
	local _bg = cc.Sprite:create("res/image/camp/mcjxjl.png")
	self._contentBg:addChild(_bg)
	_bg:setPosition(self._contentBg:getContentSize().width * 2/3 + 35,self._contentBg:getContentSize().height - _bg:getContentSize().height + 5)
	--背景框
	local bg_kuang = ccui.Scale9Sprite:create("res/image/camp/bg_kuang.png")
	bg_kuang:setContentSize(500,365)
	bg_kuang:setAnchorPoint(0.5,1)
	bg_kuang:setPosition(self._contentBg:getContentSize().width * 2/3 + 35,self._contentBg:getContentSize().height - _bg:getContentSize().height + 5)
	self._contentBg:addChild(bg_kuang,-1)
	--=-----升级城市效果变化
	local _word = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS42,XTHD.SystemFont,18) -----每次捐献奖励
	_word:setColor(XTHD.resource.color.gray_desc)
	-- _bg:addChild(_word)
	_word:setPosition(_bg:getContentSize().width / 2,_bg:getContentSize().height / 2)
	-------奖励
	local _reward1 = ItemNode:createWithParams({
		_type_ = XTHD.resource.type.honor	
	})
	_reward1:setAnchorPoint(1,1)
	self._contentBg:addChild(_reward1)
	_reward1:setPosition(_bg:getPositionX() - 30,_bg:getPositionY() - _bg:getContentSize().height)
	-----名字
	local _name = XTHDLabel:create(_reward1:getName(),22,"res/fonts/def.ttf")
	_name:setColor(cc.c3b(252,231,204))
	_name:enableOutline(cc.c4b(0,0,0,255),1)
	self._contentBg:addChild(_name)
	_name:setPosition(_reward1:getPositionX() - _reward1:getContentSize().width / 2,self._contentBg:getContentSize().height / 2 + 25)

	local _reward2 = ItemNode:createWithParams({
		_type_ = XTHD.resource.type.cityExp
	})
	_reward2:setAnchorPoint(0,1)
	self._contentBg:addChild(_reward2)
	_reward2:setPosition(_bg:getPositionX() + 30,_reward1:getPositionY())
	-----名字
	_name = XTHDLabel:create(_reward2:getName(),22,"res/fonts/def.ttf")
	_name:setColor(cc.c3b(252,231,204))
	_name:enableOutline(cc.c4b(0,0,0,255),1)
	self._contentBg:addChild(_name)
	_name:setPosition(_reward2:getPositionX() + _reward2:getContentSize().width / 2,self._contentBg:getContentSize().height / 2 + 25)
	------今日剩余捐献次数
	local _word = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS43,XTHD.SystemFont,18) -----今日剩余捐献次数 
	_word:setColor(XTHD.resource.color.gray_desc)
	self._contentBg:addChild(_word)
	_word:setPosition(_bg:getPositionX(),self._contentBg:getContentSize().height / 2 - 50)
	-----次数
	local _val = XTHDLabel:createWithSystemFont(5,XTHD.SystemFont,20) -----今日剩余捐献次数 
	_val:setColor(XTHD.resource.color.gray_desc)
	_val:setAnchorPoint(0,0.5)
	self._contentBg:addChild(_val)
	_val:setPosition(_word:getPositionX() + _word:getContentSize().width / 2,_word:getPositionY())
	self._restOfDonTimes = _val
	------捐献按钮
	local x,y = self._bg:getContentSize().width / 2 - 30-10,_word:getPositionY() - _word:getContentSize().height - 30
	local iconPath = {"header_ingot","header_feicui","header_gold"}
	local _cost = {10,20000,20000}
	for i = 1,3 do 
		local _button = XTHD.createCommonButton({
			btnColor = "write_1",
			btnSize = cc.size(130,46),
			isScrollView = false,
			text = LANGUAGE_CAMP_DONATETYPE[i],
			fontSize = 22,
			fontColor = cc.c3b(255,255,255),
		})
		_button:setScale(0.8)
		_button:setTouchEndedCallback(function( )
			self:doDonate(_button)
		end)
		_button:setTag(i)
		_button:setAnchorPoint(0,0.5)
		self._contentBg:addChild(_button)
		_button:setPosition(x,y)
		x = x + _button:getContentSize().width + 5
		------
		----消耗
		-- local cost = XTHDLabel:createWithSystemFont(LANGUAGE_VERBS.cost1..":",XTHD.SystemFont,20) -----
		-- cost:setColor(XTHD.resource.color.gray_desc)
		-- cost:setAnchorPoint(0,0.5)
		-- self._contentBg:addChild(cost)
		-- cost:setPosition(_button:getPositionX() + 5,_button:getPositionY() - _button:getContentSize().height)
		----图标 
		local _icon = cc.Sprite:create("res/image/common/"..iconPath[i]..".png")		
		--self._contentBg:addChild(_icon)
		_icon:setAnchorPoint(0,0.5)
		-- _icon:setPosition(cost:getPositionX() + cost:getContentSize().width,cost:getPositionY())
		--_icon:setPosition(_button:getPositionX() + _button:getContentSize().width*0.25,_button:getPositionY() - _button:getContentSize().height)
		----值 
		local _val = XTHDLabel:create(_cost[i]*self._donateTimes,20,"res/fonts/def.ttf") -----
		_val:setColor(cc.c3b(252,231,204))
		_val:enableOutline(cc.c4b(0,0,0,255),1)
		_val:setAnchorPoint(0,0.5)
		--self._contentBg:addChild(_val)
		--_val:setPosition(_icon:getPositionX() + _icon:getContentSize().width,_icon:getPositionY())

        local node = cc.Node:create()
        node:setAnchorPoint(0.5,0.5)
        node:setContentSize(_icon:getContentSize().width + _val:getContentSize().width + 10,_val:getContentSize().height)
        self._contentBg:addChild(node)
        node:setPosition(_button:getPositionX() + _button:getContentSize().width*0.5 - 15,_button:getPositionY() - _button:getContentSize().height + 15)

        node:addChild(_icon)
        _icon:setPosition(_icon:getContentSize().width*0.5- 15,node:getContentSize().height * 0.5)

        node:addChild(_val)
        _val:setPosition(_icon:getPositionX() + _icon:getContentSize().width + 5,node:getContentSize().height * 0.5)

		self._donateCost[i] = _val
	end 
end
-----更新当前建筑的等级及调整当前建筑名字、等级、进度条的位置
function ZhongZuCityDonate:refreshBuildDynamicData()
	if self._cityName and self._cityLevelLabel and self._levelUpBar then 
		local x,y = self._cityName:getPosition()
		-----等级
		local level = self._serverData.level or 1
		self._cityLevelLabel:setString("LV:"..level)
		-----进度条
		local _current = self._serverData.curExp or 1
		local _max = self._serverData.maxExp or 1
		local percent = _current / _max * 100
		self._levelUpBar:setPercent(percent)
		----进度条上的字
		self._progressWord:setString(_current.."/".._max)
		------剩余捐献次数
		_current = self._serverData.curDonateCount or 0
		_max = self._serverData.maxDonateCount or 0
		self._restOfDonTimes:setString(_max - _current)
		-----更新捐献的消耗
		_current = _current + 1
		for i = 1,#self._donateCost do
			local _cost = 0
			if i == 1 then ----元宝消耗
				_cost = 10 * _current
			else 
				_cost = 20000 * _current
			end 
			self._donateCost[i]:setString(_cost)
		end 

		local x = (self._cityName:getContentSize().width + self._cityLevelLabel:getContentSize().width + self._levelUpBar:getParent():getContentSize().width)
		x = (self._contentBg:getContentSize().width - x) / 2
		self._cityName:setPosition(x,y)
		self._cityLevelLabel:setPosition(x + self._cityName:getContentSize().width,y)
		self._levelUpBar:getParent():setPosition(self._cityLevelLabel:getPositionX() + self._cityLevelLabel:getContentSize().width,y)
	end 
end
-----创建当前等级的建筑属性
function ZhongZuCityDonate:createCityProperty( )
	if self._propContainer then 
		self._propContainer:removeAllChildren()
		local x,y = self._propContainer:getContentSize().width / 2 + 5, self._propContainer:getContentSize().height - 15
		self._cityProp = ZhongZuDatas:getCityPropByLevel(self._cityLevel,self._cityID)
		for k,v in pairs(self._cityProp) do 
			------属性名
			local _name = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_BUILDPROPERTY[v.propID]..":",XTHD.SystemFont,18)
			_name:setColor(XTHD.resource.color.gray_desc)
			_name:setAnchorPoint(1,0.5)
			self._propContainer:addChild(_name)
			_name:setPosition(x,y)
			-----原来的值
			local _val = v.propCur
			if v.propID ~= 7 and v.propID ~= 6 then 
				_val = _val.."%"
			end 
			local _preVal = XTHDLabel:createWithSystemFont(_val,XTHD.SystemFont,18)
			_preVal:setColor(XTHD.resource.color.gray_desc)
			_preVal:setAnchorPoint(0,0.5)
			self._propContainer:addChild(_preVal)
			_preVal:setPosition(_name:getPositionX() + 2,_name:getPositionY())
			if v.propNext then
				-------箭头
				local _arrow = cc.Sprite:create("res/image/plugin/hero/hero_propertyadd.png")
				self._propContainer:addChild(_arrow)
				_arrow:setRotation(90)
				_arrow:setPosition(_preVal:getPositionX() + _preVal:getContentSize().width + _arrow:getContentSize().width / 2 + 5,_preVal:getPositionY())
				-----新值
				_val = v.propNext
				if v.propID ~= 7 and v.propID ~= 6 then 
					_val = _val.."%"
				end 
				local _nowVal = XTHDLabel:createWithSystemFont(_val,XTHD.SystemFont,20)
				_nowVal:setColor(cc.c3b(104,157,0))	
				_nowVal:enableShadow(cc.c4b(104,157,0,0xff),cc.size(1,0))	
				_nowVal:setAnchorPoint(0,0.5)
				self._propContainer:addChild(_nowVal)
				_nowVal:setPosition(_arrow:getPositionX() + _arrow:getContentSize().width / 2 + 5,_name:getPositionY())
			end 
			y = y  - _name:getContentSize().height - 5		
		end 
	end 
end

function ZhongZuCityDonate:createFront3Range( )
	if self._rankContainer then 
		self._rankContainer:removeAllChildren()
		if self._serverData and next(self._serverData.list) ~= nil then 
			local y = self._rankContainer:getContentSize().height - 15
			local _len = #self._serverData.list > 3 and 3 or #self._serverData.list
			for i = 1,_len do 
				local _data = self._serverData.list[i]
				------奖杯
				local _icon = cc.Sprite:create("res/image/ranklist/rank_"..i..".png")
				self._rankContainer:addChild(_icon)
				_icon:setScale(0.6)
				_icon:setPosition(_icon:getBoundingBox().width / 2 + 15,y)
				----名字
				local  _name = XTHDLabel:createWithSystemFont(_data.name,XTHD.SystemFont,18)
				_name:setColor(XTHD.resource.color.gray_desc)
				_name:setAnchorPoint(0,0.5)
				self._rankContainer:addChild(_name)
				_name:setPosition(_icon:getPositionX() + _icon:getBoundingBox().width / 2 + 15,_icon:getPositionY() - 2)
				----次数
				local _times = XTHDLabel:createWithSystemFont(_data.count,XTHD.SystemFont,18)
				_times:setColor(XTHD.resource.color.gray_desc)
				_times:setAnchorPoint(1,0.5)
				self._rankContainer:addChild(_times)
				_times:setPosition(self._rankContainer:getContentSize().width - 25,_name:getPositionY())
				y = y - _icon:getBoundingBox().height - 5
			end 
			self._lookRangeBtn:setVisible(true)
		else 
			local _str = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS27,XTHD.SystemFont,25)
			_str:setColor(cc.c3b(0,0,0))
			self._rankContainer:addChild(_str)
			_str:setPosition(self._rankContainer:getContentSize().width / 2,self._rankContainer:getContentSize().height / 2)
			self._lookRangeBtn:setVisible(false)
		end 
	end 
end

function ZhongZuCityDonate:doDonate( sender )
	local _type = sender:getTag()
	local _cost = tonumber(self._donateCost[_type]:getString())
	if _type == 1 and gameUser.getIngot() < _cost then ------元宝不足
		showIngotNotEnoughDialog( self,_cost)
	elseif _type == 2 and gameUser.getFeicui() < _cost then ------翡翠不足		
		local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=4})
	    self:addChild( layer, 3 )
	elseif _type == 3 and gameUser.getGold() < _cost then -----银两不足
		local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=3})
	    self:addChild( layer, 3 )
	else
		XTHDHttp:requestAsyncInGameWithParams({
	        modules = "cityDonate?",
	        params = {cityId = self._cityID,donateType = _type},
	        successCallback = function(data)
	            if tonumber(data.result) == 0 then
	            	self._serverData = data
	            	self:refreshBuildDynamicData()
	            	if self._cityLevel ~= data.level then 
	            		self._cityLevel = data.level
	            		self:createCityProperty()
	            	end 
	            	local _addedHonor = gameUser.getHonor()
	        	    for k,v in pairs(data.property) do 
	                    local values = string.split(v,',')	                    
	                    DBUpdateFunc:UpdateProperty("userdata",values[1],values[2])
	                    if tonumber(values[1]) == 426 then -----变化的荣誉
	                    	_addedHonor = math.abs(_addedHonor - values[2])
	                    end 
	                end
	                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
	                self:createFront3Range()
	                --------获得的奖励提示
	            	XTHDTOAST(string.format(LANGUAGE_CAMP_TIPSWORDS52,_addedHonor, 300))
	            else
	            	XTHDTOAST(data.msg)
	            end
	        end,
	        failedCallback = function()
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
	        end,--失败回调
	        loadingParent = self,
	        loadingType = HTTP_LOADING_TYPE.CIRCLE--加载图显示 circle 光圈加载 head 头像加载
	    })
	end 
end

return ZhongZuCityDonate