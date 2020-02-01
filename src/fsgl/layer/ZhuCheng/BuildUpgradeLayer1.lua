--[[
点击钱庄升级面板

┏━━━┛┻━━━┛┻━━┓
┃｜｜｜｜｜｜｜┃
┃　　　━　　　 ┃
┃　┳┛ 　┗┳  　┃
┃　　　　　　　┃
┃　　　┻　　 　┃
┃　　　　　　　┃
┗━━┓　　　┏━┛
　　┃　史　┃　　
　　┃　诗　┃　　
　　┃　之　┃　　
　　┃　宠　┃
　　┃　　　┗━━━┓
　　┃ 		　┣┓
　　┃　　　  　┃
　　┗┓┓ ┏━┳┓ ┏┛
　　　┃┫┫　┃┫┫
　　　┗┻┛　┗┻┛
神兽镇楼，代码永无bug
]]
local BuildUpgradeLayer1 = class("BuildUpgradeLayer1", function()
	return XTHD.createBasePageLayer()
end)

function BuildUpgradeLayer1:ctor(params)
	self._id = params.id or 1
	self._build = params.build
	self._afterLevelupCall = params.levelupCallback------点击升级之后的回调
	self._afterImmidLevelupCall = params.immidCallback -----立刻完成之后的回调
	self._levelupVIP = params.needVip ------立刻完成需要的VIP等级

	self._leftBtmContainer = nil ------左边图标下的容器
	self._countDown = nil -----升级倒计时

	self._currentLevelData = nil -----当前等级建筑的数据
	self._nextLevelData = nil -----升到下级建筑的数据

	self._bottomInfoNode = nil----底部信息条容器

	self._levelupBtnWord = nil ----升级按钮上的字

	self._upgradeCountDown = 0 ----当前建筑正在升级的倒计时
	self._maxLevel = 10 -----当前建筑的最大等级
	self._produceBoxBg = nil ---建筑资源产出数据信息背景
	self._statu = 1 ---------当前的状态 1，升级 2 立刻完成 

	if self._build then 
		self._upgradeCountDown = self._build:getLevelUpState()
		self:getDatas()
	end 
	----------获取建筑可升级的最大等级
	local data = gameData.getDataFromCSV("LayoutOfBuilding",{buildingid = self._id})
	if data and self._build then 
		table.sort(data,function(a,b)
			return a.level > b.level
		end)
		self._maxLevel = data[1].level
	end 

	self.Tag = {
		ktag_countDown = 100,
	}

    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_BUILDINFO_AFTERLEVELUP,callback = function( event )-----
    	self:refreshCountDown()
    	self:refreshDataAfterLevelup()
    end})

    self:initUI()
    self:refreshCountDown()
    self:refreshDataAfterLevelup()
end

function BuildUpgradeLayer1:initUI()
	--背景
	self._bg = cc.Sprite:create("res/image/building/building_bg.png")
	self._bg:setPosition(self:getContentSize().width/2,(self:getContentSize().height - self.topBarHeight) / 2)
	self:addChild(self._bg)
	
	local title = "res/image/public/qianzhuang_title.png"
	XTHD.createNodeDecoration(self._bg,title)

	if not self._currentLevelData then 
		return 
	end 
	-----建筑图标
	local _icon = cc.Sprite:create("res/image/building/building_info_icon3.png")
	self._bg:addChild(_icon)
	_icon:setAnchorPoint(0,0.5)
	_icon:setPosition(_icon:getContentSize().width*0.25- 10,self._bg:getContentSize().height*0.5 + 47)
	_icon:setScale(0.7)
	

	--名字
	local buildname = cc.Sprite:create("res/image/building/buildname.png")
	buildname:setPosition(-10,_icon:getContentSize().height)
	_icon:addChild(buildname)
	------------
	local _layout = ccui.Layout:create()
	_layout:setContentSize(cc.size(425,119))
	self._bg:addChild(_layout)
	_layout:setAnchorPoint(0.5,1)
	_layout:setPosition(_icon:getPositionX() + _icon:getContentSize().width / 2,_icon:getPositionY() - _icon:getContentSize().height / 2 + 5)
	self._leftBtmContainer = _layout
	-----升级时不产出资源
	-- local _label = XTHDLabel:createWithSystemFont(LANGUAGE_MAINCITY_TIPS5,XTHD.SystemFont,18)
	local _label = XTHDLabel:create(LANGUAGE_MAINCITY_TIPS5,18,"res/fonts/def.ttf")
	_label:setColor(cc.c3b(0,0,0))
	_label:setAnchorPoint(1,1)
	_layout:addChild(_label)
	_label:setPosition(_layout:getContentSize().width / 2 +40,_layout:getContentSize().height)
	------升级所需时间 
	local _bg = ccui.Scale9Sprite:create("res/image/building/sjk.png")
	_bg:setContentSize(cc.size(336,65))
	_bg:setAnchorPoint(0.5,1)
	_layout:addChild(_bg)
	_bg:setPosition(_label:getPositionX()-70,_label:getPositionY() - _label:getContentSize().height - 3)
	_bg:setOpacity(100)
	-------升级倒计时
	-- _label = XTHDLabel:createWithSystemFont(LANGUAGE_MAINCITY_TIPS8,XTHD.SystemFont,22)
	_label = XTHDLabel:create(LANGUAGE_MAINCITY_TIPS8,20,"res/fonts/def.ttf")
	_label:setColor(cc.c3b(106,36,13))
	--_label:enableOutline(cc.c4b(45,13,103,255),2)
	_label:setAnchorPoint(0.5,0)
	_bg:addChild(_label)
	-----时间 
	local _time = XTHDLabel:createWithSystemFont("00:00:00",XTHD.SystemFont,20)
	_time:setColor(cc.c3b(106,36,13))
	_time:setAnchorPoint(0.5,0)
	_bg:addChild(_time)
	self._countDown = _time

    --银两，翡翠产出进度条
    -- local luckyBarBg = cc.Sprite:create("res/image/common/sq_common_progressBg_2.png")
    -- luckyBarBg:setAnchorPoint(0.5,0)
    -- luckyBarBg:setPosition(_layout:getContentSize().width/2-50,_time:getPositionY() - 35)
    -- _layout:addChild(luckyBarBg)
    -- self._luckyBarBg = luckyBarBg
    -- self._luckyBarBg:setScale(0.8)

    -- self._luckBar = cc.ProgressTimer:create(cc.Sprite:create("res/image/common/sq_common_progress_2.png"))
    -- self._luckBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    -- self._luckBar:setBarChangeRate(cc.p(1,0))
    -- self._luckBar:setMidpoint(cc.p(0,0.5))
    -- self._luckBar:setPosition(luckyBarBg:getContentSize().width/2,luckyBarBg:getContentSize().height/2+1)
    -- luckyBarBg:addChild(self._luckBar)
    -- self._luckBar:setPercentage(50)

    -- --收获按钮
    -- self._disboard = XTHD.createCommonButton({
    --     btnColor = "write",
    --     text = "收 获",
    --     fontSize = 26,
    -- })
    -- self._disboard:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
    -- self._disboard:setPosition(luckyBarBg:getPositionX() + 230,luckyBarBg:getPositionY()+15)
    -- _layout:addChild(self._disboard)
    -- self._disboard:setScale(0.7)
    -- self._disboard:setTouchEndedCallback(function()

    --     end)
    -- print("钱庄当前等级数据为：")
    -- print_r(self._currentLevelData)
    -- print("钱庄下一等级数据为：")
    -- print_r(self._nextLevelData)

	local y = _label:getContentSize().height + _time:getContentSize().height
	y = (_bg:getContentSize().height - y) / 2
	_time:setPosition(_bg:getContentSize().width / 2,y - 3 )
	_label:setPosition(_time:getPositionX(),y + _time:getContentSize().height - 2)

	--kuang1
	local kuang1 = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
	kuang1:setContentSize(cc.size(self._bg:getContentSize().width / 2 + 10,95))
	kuang1:setAnchorPoint(0.5,0.5)
	kuang1:setPosition(self._bg:getContentSize().width - kuang1:getContentSize().width * 0.5 - 20, self._bg:getContentSize().height - 90)
	self._bg:addChild(kuang1)

	-------右边 建筑信息
	local titleBg = cc.Sprite:create("res/image/building/jzxx.png")
	kuang1:addChild(titleBg)
	titleBg:setPosition(kuang1:getContentSize().width *0.5,kuang1:getContentSize().height)
	------
	_label = XTHDLabel:createWithSystemFont(LANGUAGE_MAINCITY_TIPS9,XTHD.SystemFont,18)
	_label:setColor(XTHD.resource.color.gray_desc)
	-- titleBg:addChild(_label)
	_label:setPosition(kuang1:getContentSize().width / 2,kuang1:getContentSize().height / 2)
	---------信息内容
	local str = self._currentLevelData.description
	str = string.gsub(str,"*","")
	_label = XTHDLabel:createWithSystemFont(str,XTHD.SystemFont,18)
	_label:setColor(cc.c3b(54,55,112))
	_label:setWidth(self._bg:getContentSize().width / 2 -10)
	kuang1:addChild(_label)
	_label:setAnchorPoint(0.5,1)
	_label:setPosition(kuang1:getContentSize().width * 0.5,kuang1:getContentSize().height - 20)
	-------分隔线
	local _line = cc.Sprite:create("res/image/common/exchange_line.png")
	self._bg:addChild(_line)
	_line:setPosition(self._bg:getContentSize().width,self._bg:getContentSize().height * 0.7 + 30)
	_line:setOpacity(0)
	
	
	---------升级信息box
	local _boxBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
	_boxBg:setContentSize(cc.size(self._bg:getContentSize().width / 2 + 10,255))
	self._bg:addChild(_boxBg)
	_boxBg:setAnchorPoint(0.5,1)
	_boxBg:setPosition(self._bg:getContentSize().width - _boxBg:getContentSize().width * 0.5 - 20,_line:getPositionY() - 30)
	self._produceBoxBg = _boxBg

	--------建筑升级
	local titleBg2 = cc.Sprite:create("res/image/building/jzsj.png")
	titleBg2:setAnchorPoint(0.5,0.5)
	titleBg2:setPosition(_boxBg:getPositionX(),_line:getPositionY() - 30)
	self._bg:addChild(titleBg2,10)
	---------
	_label = XTHDLabel:createWithSystemFont(LANGUAGE_MAINCITY_TIPS10,XTHD.SystemFont,18)
	_label:setColor(XTHD.resource.color.gray_desc)
	-- titleBg2:addChild(_label)
	_label:setPosition(titleBg2:getContentSize().width / 2,titleBg2:getContentSize().height / 2)
	------	
	self:initLevelInfo(_boxBg)
	-----底部升级消耗信息
	local node = cc.Node:create()
	self._bg:addChild(node)
	node:setContentSize(self._bg:getContentSize().width / 2 + 10,90)
	node:setAnchorPoint(0.5,1)
	node:setPosition(_boxBg:getPositionX(),_boxBg:getPositionY() - _boxBg:getContentSize().height - 10)
	self._bottomInfoNode = node
	self:initBottomInfo()
end

function BuildUpgradeLayer1:initLevelInfo(parent)
	self:getDatas()
	--箭头
	local jiantou = cc.Sprite:create("res/image/goldcopy/arrow.png")
	jiantou:setPosition(parent:getContentSize().width/2,parent:getContentSize().height/2)
	parent:addChild(jiantou)
	local x = 10
	for i = 1,2 do 
		local _box = ccui.Scale9Sprite:create()
		_box:setContentSize(cc.size(parent:getContentSize().width / 2 - 7.5,parent:getContentSize().height - 10))
		parent:addChild(_box)
		_box:setAnchorPoint(0,0.5)
		_box:setPosition(x,parent:getContentSize().height / 2)
		

		local what = i
		target = _box
		local data = (what == 1) and self._currentLevelData or self._nextLevelData
		local color = (what == 1) and cc.c3b(54,55,112) or cc.c3b(54,55,112)
		local level = (what == 1) and self._build:getCurLevel() or (self._build:getCurLevel() + 1)
		local space = target:getContentSize().height / 5
		local y = target:getContentSize().height - space / 2
		if target and data then 
			-----当前等级
			local _label = XTHDLabel:createWithSystemFont(LANGUAGE_MAINCITY_TIPS11,XTHD.SystemFont,18)
			if what == 2 then 
				_label = XTHDLabel:createWithSystemFont(LANGUAGE_MAINCITY_TIPS12,XTHD.SystemFont,18)
			end 
			_label:setColor(cc.c3b(54,55,112))
			parent:addChild(_label)
			_label:setAnchorPoint(0,0.5)
			_label:setPosition(x,y)
			------值
			local _val = XTHDLabel:createWithSystemFont(level,XTHD.SystemFont,20)
			_val:setColor(color)
			parent:addChild(_val)
			_val:setAnchorPoint(0,0.5)
			_val:setPosition(_label:getPositionX() + _label:getContentSize().width,_label:getPositionY())
			if what == 2 then 
				-- _val:enableShadow(cc.c4b(104,157,0,255),cc.size(1,0))
			end 
			-----线
			local _line = cc.Sprite:create("res/image/common/exchange_line.png")
			_line:setScaleX(target:getContentSize().width / _line:getContentSize().width)
			parent:addChild(_line)
			_line:setOpacity(0)
			_line:setPosition(target:getContentSize().width / 2,y - space / 2)
			y = y - space
			------银两产量
			_label = XTHDLabel:createWithSystemFont(LANGUAGE_MAINCITY_BUILDPRODUCE[1],XTHD.SystemFont,18)
			_label:setColor(cc.c3b(54,55,112))
			parent:addChild(_label)
			_label:setAnchorPoint(0,0.5)
			_label:setPosition(x,y)
			----值
			_val = XTHDLabel:createWithSystemFont((data.producegold1h..LANGUAGE_UNKNOWN.perHour),XTHD.SystemFont,20)
			_val:setColor(color)
			parent:addChild(_val)
			_val:setAnchorPoint(0,0.5)
			_val:setPosition(_label:getPositionX() + _label:getContentSize().width,_label:getPositionY())
			if what == 2 then 
				-- _val:enableShadow(cc.c4b(104,157,0,255),cc.size(1,0))
			end 
			-----线
			_line = cc.Sprite:create("res/image/common/exchange_line.png")
			_line:setScaleX(target:getContentSize().width / _line:getContentSize().width)
			_line:setOpacity(0)
			target:addChild(_line)
			_line:setPosition(target:getContentSize().width / 2,y - space / 2)
			y = y - space
			------银两存储上限
			_label = XTHDLabel:createWithSystemFont(LANGUAGE_MAINCITY_BUILDPRODUCE[3],XTHD.SystemFont,18)
			_label:setColor(cc.c3b(54,55,112))
			parent:addChild(_label)
			_label:setAnchorPoint(0,0.5)
			_label:setPosition(x,y)
			----值
			_val = XTHDLabel:createWithSystemFont(data.goldstoremax,XTHD.SystemFont,20)
			_val:setColor(color)
			parent:addChild(_val)
			_val:setAnchorPoint(0,0.5)
			_val:setPosition(_label:getPositionX() + _label:getContentSize().width,_label:getPositionY())
			if what == 2 then 
				-- _val:enableShadow(cc.c4b(104,157,0,255),cc.size(1,0))
			end 
			-----线
			_line = cc.Sprite:create("res/image/common/exchange_line.png")
			_line:setScaleX(target:getContentSize().width / _line:getContentSize().width)
			_line:setOpacity(0)
			target:addChild(_line)
			_line:setPosition(target:getContentSize().width / 2,y - space / 2)
			y = y - space
			------翡翠产量
			_label = XTHDLabel:createWithSystemFont(LANGUAGE_MAINCITY_BUILDPRODUCE[2],XTHD.SystemFont,18)
			_label:setColor(cc.c3b(54,55,112))
			parent:addChild(_label)
			_label:setAnchorPoint(0,0.5)
			_label:setPosition(x,y)
			----值
			_val = XTHDLabel:createWithSystemFont((data.produceemerald1h..LANGUAGE_UNKNOWN.perHour),XTHD.SystemFont,20)
			_val:setColor(color)
			parent:addChild(_val)
			_val:setAnchorPoint(0,0.5)
			_val:setPosition(_label:getPositionX() + _label:getContentSize().width,_label:getPositionY())
			if what == 2 then 
				-- _val:enableShadow(cc.c4b(104,157,0,255),cc.size(1,0))
			end 
			-----线
			_line = cc.Sprite:create("res/image/common/exchange_line.png")
			_line:setScaleX(target:getContentSize().width / _line:getContentSize().width)
			_line:setOpacity(0)
			target:addChild(_line)
			_line:setPosition(target:getContentSize().width / 2,y - space / 2)
			y = y - space
			------翡翠存储产量
			_label = XTHDLabel:createWithSystemFont(LANGUAGE_MAINCITY_BUILDPRODUCE[3],XTHD.SystemFont,18)
			_label:setColor(cc.c3b(54,55,112))
			parent:addChild(_label)
			_label:setAnchorPoint(0,0.5)
			_label:setPosition(x,y)
			----值
			_val = XTHDLabel:createWithSystemFont(data.emeraldstoremax,XTHD.SystemFont,20)
			_val:setColor(color)
			parent:addChild(_val)
			_val:setAnchorPoint(0,0.5)
			_val:setPosition(_label:getPositionX() + _label:getContentSize().width,_label:getPositionY())
			if what == 2 then 
				-- _val:enableShadow(cc.c4b(104,157,0,255),cc.size(1,0))
			end 
		elseif what == 2 and not data then 
			local _label = XTHDLabel:createWithSystemFont(LANGUAGE_MAINCITY_TIPS13,XTHD.SystemFont,18)
			_label:setColor(cc.c3b(54,55,112))
			parent:addChild(_label)
			_label:setPosition(25+ _box:getContentSize().width/2 + 223,target:getContentSize().height / 2)
		end 
		x = x + _box:getContentSize().width + 30
	end 
end

function BuildUpgradeLayer1:initBottomInfo( )
	local canUpgrade = true
	self:getDatas()
	if self._bottomInfoNode and self._currentLevelData then 
		if self._upgradeCountDown <= 0 then ------不处于升级状态
			----玩家需求等级
			local _label = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_PLAYERLIMIT.."：",XTHD.SystemFont,18)
			self._bottomInfoNode:addChild(_label)
			_label:setColor(cc.c3b(54,55,112))
			_label:setAnchorPoint(0,1)
			_label:setPosition(5,self._bottomInfoNode:getContentSize().height)
			---值
			local need = self._currentLevelData.upgradelimitlevel
			local current = gameUser.getLevel()
			local val = XTHDLabel:createWithSystemFont(need,XTHD.SystemFont,18)
			if current >= need then 
				val:setColor(cc.c3b(81,50,30))
				val:enableShadow(cc.c4b(81,50,30,255),cc.size(1,0))
			else 
				canUpgrade = false
				val:setColor(cc.c3b(81,50,30))
				val:enableShadow(cc.c4b(81,50,30,255),cc.size(1,0))
			end 
			self._bottomInfoNode:addChild(val)
			val:setAnchorPoint(0,1)
			val:setPosition(_label:getPositionX() + _label:getContentSize().width,_label:getPositionY())
			-----需要消耗
			local _label2 = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_WORDS141,XTHD.SystemFont,18)
			self._bottomInfoNode:addChild(_label2)
			_label2:setColor(cc.c3b(54,55,112))
			_label2:setAnchorPoint(0,1)
			_label2:setPosition(_label:getPositionX(),_label:getPositionY() - _label:getContentSize().height - 5)
			----银两
			local _gold = cc.Sprite:create("res/image/common/header_gold.png")
			self._bottomInfoNode:addChild(_gold)
			_gold:setAnchorPoint(0,1)
			_gold:setScale(0.9)
			_gold:setPosition(_label2:getPositionX() + _label2:getContentSize().width,_label2:getPositionY() + 5)		
			---值
			need = self._currentLevelData.upgradegoldcost
			current = gameUser.getGold()			
			val = XTHDLabel:createWithSystemFont(need,XTHD.SystemFont,18)
			if current >= need then 
				val:setColor(cc.c3b(81,50,30))
				val:enableShadow(cc.c4b(81,50,30,255),cc.size(1,0))
			else 
				canUpgrade = false
				val:setColor(cc.c3b(81,50,30))
				val:enableShadow(cc.c4b(81,50,30,255),cc.size(1,0))
			end 
			self._bottomInfoNode:addChild(val)
			val:setAnchorPoint(0,1)
			val:setPosition(_gold:getPositionX() + _gold:getContentSize().width,_label2:getPositionY())
			----翡翠
			local _jade = cc.Sprite:create("res/image/common/header_feicui.png")
			self._bottomInfoNode:addChild(_jade)
			_jade:setAnchorPoint(0,1)
			_jade:setScale(0.9)
			_jade:setPosition(val:getPositionX() + val:getContentSize().width + 5,val:getPositionY() + 5)		
			---值
			need = self._currentLevelData.upgradeemeraldcost
			current = gameUser.getFeicui()			
			val = XTHDLabel:createWithSystemFont(need,XTHD.SystemFont,18)
			if current >= need then 
				val:setColor(cc.c3b(81,50,30))
				val:enableShadow(cc.c4b(81,50,30,255),cc.size(1,0))
			else 
				canUpgrade = false
				val:setColor(cc.c3b(81,50,30))
				val:enableShadow(cc.c4b(81,50,30,255),cc.size(1,0))
			end 
			self._bottomInfoNode:addChild(val)
			val:setAnchorPoint(0,1)
			val:setPosition(_jade:getPositionX() + _jade:getContentSize().width,_label2:getPositionY())
		else ----处于升级状态 
			canUpgrade = false
			local _label = XTHDLabel:createWithSystemFont(LANGUAGE_MAINCITY_TIPS14,XTHD.SystemFont,20) -----建筑正在升级		
			self._bottomInfoNode:addChild(_label)
			_label:setColor(cc.c3b(54,55,112))
			_label:setAnchorPoint(0,0.5)
			_label:setPosition(5,self._bottomInfoNode:getContentSize().height / 2)
		end 
		----字
		local _labelText 
		if self._upgradeCountDown > 0 then 
			_labelText = LANGUAGE_MAINCITY_FUNCNAME6 -----立刻完成 
		else 
			_labelText = LANGUAGE_MAINCITY_FUNCNAME4 -----升级的
		end 
		-----按钮
		local button = XTHD.createCommonButton({
			btnColor = "write",
			isScrollView = false,
			text = _labelText,
			fontSize = 26,
			fontColor = cc.c3b(255,255,255),
		})
		self._bottomInfoNode:addChild(button)
		button:setPosition(self._bottomInfoNode:getContentSize().width - button:getContentSize().width+50,self._bottomInfoNode:getContentSize().height / 2+10)
		button:setScale(0.7)
		button:setTouchEndedCallback(function( )
			if self._statu == 1 then 
				self:doLevelUp()
			else 
				self:doLevelUpImmid()
			end 
		end)
		
		self._levelUpBtn = button
		self._levelupBtnWord = button:getLabel()
		if canUpgrade == true then 
            local rewardSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)
            button:addChild(rewardSpine)
            rewardSpine:setPosition(button:getContentSize().width / 2+5,button:getContentSize().height / 2+2)
			rewardSpine:setScaleX(1.1)
            rewardSpine:setAnimation( 0, "querenjinjie", true)
		end 
	end 
end
------升级
function BuildUpgradeLayer1:doLevelUp( )
	------------------------------
	ClientHttp:requestAsyncInGameWithParams({
		modules = "upLevel?",
        params = { buildId=self._id },
        successCallback = function(data)
            if tonumber(data.result) == 0 then
            	--玩家减资源
				gameUser.setGold(tonumber(data.curGold))
				gameUser.setFeicui(tonumber(data.curFeicui))
				if self._afterLevelupCall then 
					self._afterLevelupCall(data.buildId,data.time)
				end 				
				self:refreshCountDown()
				self:refreshDataAfterLevelup()
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
        	elseif tonumber(data.result) == 2000 then
            	XTHD.createExchangePop(3)
            else
                XTHDTOAST(data.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调
        loadingParent = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end
------立刻完成 
function BuildUpgradeLayer1:doLevelUpImmid( )
    local cost = math.ceil(self._upgradeCountDown/60)*2
    if cost <= 0 then 
        return 
    end 
    local confirmLayer = XTHDConfirmDialog:createWithParams({
        rightCallback=function()
            local _cost = math.ceil(self._upgradeCountDown/60)*2
            if _cost <= 0 then 
                return 
            end 
            XTHDHttp:requestAsyncInGameWithParams({
                modules = "nowUpLevel?",
                params = { buildId = self._id },
                successCallback = function(data)
                    if tonumber(data.result) == 0 then
                        --玩家减资源
                        gameUser.setIngot(tonumber(data.ingot))
                        if self._afterImmidLevelupCall then 
                        	self._afterImmidLevelupCall(data)
                        end 
                        self._statu = 1
                        self:getDatas()
                        self:refreshDataAfterLevelup()
                        self:refreshCountDown()
						XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                    elseif data.result == 2004 then 
                        showIngotNotEnoughDialog(self,cost)--2004 元宝不足
                    elseif data.result == 3707 then ----vip等级不足
                        showVIPNotEnoughDialog(self,self._levelupVIP)
                    end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
                end,--失败回调
                loadingParent = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
        end,                 
        msg = LANGUAGE_FORMAT_TIPS28(cost,self._currentLevelData.buildingname), -----"确定花费%s元宝立刻升级%s?",cost,self._targetCityData.buildingname),
    })
    self:addChild(confirmLayer)  
end

function BuildUpgradeLayer1:create(params)
	local pLayer = self.new(params)
	return pLayer
end

function BuildUpgradeLayer1:onEnter( )
end

function BuildUpgradeLayer1:onExit( )	
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_BUILDINFO_AFTERLEVELUP)	
end
--------刷新倒计时
function BuildUpgradeLayer1:refreshCountDown( )
	self._upgradeCountDown = self._build:getLevelUpState() or 0
	self:stopActionByTag(self.Tag.ktag_countDown)
	if self._upgradeCountDown > 0 then ------当前建筑正在升级
        self._countDown:setString(getCdStringWithNumber(self._upgradeCountDown,{m = LANGUAGE_UNKNOWN.minute,s = LANGUAGE_UNKNOWN.second},false,true))
        if self._levelupBtnWord then 
        	self._levelupBtnWord:setString(LANGUAGE_MAINCITY_FUNCNAME6) ----立刻完成
        	self._statu = 2
        end 
		schedule(self,function(  )
			if self._countDown then 
				self._upgradeCountDown = self._upgradeCountDown - 1
				if self._upgradeCountDown > 0 then 
            		self._countDown:setString(getCdStringWithNumber(self._upgradeCountDown,{m = LANGUAGE_UNKNOWN.minute,s = LANGUAGE_UNKNOWN.second},false,true))
            	else 
            		self:stopActionByTag(self.Tag.ktag_countDown)
			        if self._levelupBtnWord then 
			        	self._levelupBtnWord:setString(LANGUAGE_MAINCITY_FUNCNAME4) ----升级
			        end 
			        self:refreshDataAfterLevelup()
        			self._statu = 1
            	end 
			end 
		end,1.0,self.Tag.ktag_countDown)
	else 
		if self._countDown then
			local time = self._currentLevelData.upgradelimittime * 60
	        self._countDown:setString(getCdStringWithNumber(time,{m = LANGUAGE_UNKNOWN.minute,s = LANGUAGE_UNKNOWN.second},false,true))
		end
	end 
end
-------当前升级完成之后刷新界面数据
function BuildUpgradeLayer1:refreshDataAfterLevelup( )	
	local isFull = self._build:getCurLevel() == self._maxLevel ------等级达到上限
	if self._leftBtmContainer then 
		self._leftBtmContainer:setVisible(not isFull)
	end 
	if self._bottomInfoNode then 
		self._bottomInfoNode:setVisible(not isFull)
		self._bottomInfoNode:removeAllChildren()
		self:initBottomInfo()
	end 
	if self._produceBoxBg then 
		self._produceBoxBg:removeAllChildren()
		self:initLevelInfo(self._produceBoxBg)
	end 
end

function BuildUpgradeLayer1:getDatas( )
	if self._build then 
		local _leve = self._build:getCurLevel()
		self._upgradeCountDown = self._build:getLevelUpState() or 0
		self._currentLevelData = gameData.getDataFromCSV("LayoutOfBuilding",{buildingid = self._id,level = _leve})
		self._currentLevelData = (next(self._currentLevelData) ~= nil) and self._currentLevelData or nil	
		self._nextLevelData = gameData.getDataFromCSV("LayoutOfBuilding",{buildingid = self._id,level = (_leve + 1)})
		self._nextLevelData = (next(self._nextLevelData) ~= nil) and self._nextLevelData or nil			
	end 
end

function BuildUpgradeLayer1:addEffectForButon( )
    local rewardSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)
    rewardSpine:setName("rewardSpine")
    self._levelUpBtn:addChild( rewardSpine )
    rewardSpine:setPosition( self._levelUpBtn:getContentSize().width*0.5+7, self._levelUpBtn:getContentSize().height/2+2 )
    rewardSpine:setAnimation( 0, "querenjinjie", true)
end

return BuildUpgradeLayer1

