--[[
查看某个城市的防守队伍
]]
local ZhongZuCityTeamLayer = class("ZhongZuCityTeamLayer",function( )
	return XTHDPopLayer:create()
end)

function ZhongZuCityTeamLayer:ctor(brother,data,_type,cityID)
	self._cityID = cityID
	self.__brother = brother
	self._teamData = data
	self._createType = _type ----创建的类型（1，查看 ，2 挑战 ）
	self._selectedIndex = 1 -----在挑战状态下，选中的队伍索引 
	self._checkBoxObj = nil -------
	self._selectedTeamData = nil -----被选中的队伍数据 

	self.Tag = {
		ktag_titleBg = 100,
	}
end

function ZhongZuCityTeamLayer:create(brother,data,_type,cityID)
	local team = ZhongZuCityTeamLayer.new(brother,data,_type,cityID)
	if team then 
		team:init()
	end 
	return team 	
end

function ZhongZuCityTeamLayer:init( )
	local teams = #self._teamData.team
	local height = 110 + 80 * teams
	if self._createType == 2 then 
		height = 210 + 80 * teams
	end 
	----背景
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	bg:setContentSize(cc.size(560,height+70))
	
	local bg2 = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	bg2:setContentSize(cc.size(560,height+70))
	local _mode = XTHDPushButton:createWithParams({
		normalNode = bg,				
		selectedNode = bg2,
		needSwallow = true,
	})
	self:addContent(_mode)
	_mode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	-- kuang
	local kuang = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	kuang:setContentSize(cc.size(520,height+10))
	kuang:setPosition(_mode:getContentSize().width/2,_mode:getContentSize().height/2 + 10)
	_mode:addChild(kuang)
	
	if self._createType == 2 then ----挑战 
		------标题上黄的背景
		local _titleBg = cc.Sprite:create("res/image/camp/camp_reward_bg2.png")
		_mode:addChild(_titleBg,0,self.Tag.ktag_titleBg)
		_titleBg:setOpacity(0)
		_titleBg:setScaleX(_mode:getContentSize().width / _titleBg:getContentSize().width)
		_titleBg:setAnchorPoint(0.5,1)
		_titleBg:setPosition(_mode:getContentSize().width / 2,_mode:getContentSize().height - 3)
		-----上面的字
		local _wordPic = cc.Sprite:create("res/image/camp/camp_label18.png")
		_mode:addChild(_wordPic)
		_wordPic:setPosition(_mode:getContentSize().width / 2,_mode:getContentSize().height - _titleBg:getContentSize().height / 2-20)
	end 
	-------关闭按钮
	local _close = XTHD.createBtnClose(function()
        self:hide()
    end)
	_mode:addChild(_close)
	_close:setPosition(_mode:getContentSize().width - 10,_mode:getContentSize().height - 10)

	self:initTeams(_mode)
end

function ZhongZuCityTeamLayer:onEnter( )
end

function ZhongZuCityTeamLayer:onExit( )
end

function ZhongZuCityTeamLayer:initTeams(targ)
	if not self._teamData then 
		return 
	end 
	local data = self._teamData
	---头像
	local portrait = ZhongZuDatas:createCampHeroIcon(data.templateId)
	targ:addChild(portrait)
	portrait:setScale(0.85)
	portrait:setAnchorPoint(0,1)
	if self._createType == 1 then ------查看
		portrait:setPosition(25,targ:getContentSize().height - 25)
	else  -----挑战 
		local _temp = targ:getChildByTag(self.Tag.ktag_titleBg)
		portrait:setPosition(25,_temp:getPositionY() - _temp:getBoundingBox().height - 10)
		------今日剩余挑战次数 
		local str = string.format("%d/%d",(ZhongZuDatas._serverSelfCityDatas.maxCount - ZhongZuDatas._serverSelfCityDatas.curChallengeCount),ZhongZuDatas._serverSelfCityDatas.maxCount)
		local _times = XTHDLabel:createWithSystemFont(str,XTHD.SystemFont,20)----今日剩余挑战次数 
		targ:addChild(_times)
		_times:setColor(cc.c3b(255,255,255))
		_times:setAnchorPoint(1,1)
		_times:setPosition(targ:getContentSize().width - 25,portrait:getPositionY()+ 2 )

		local _restOfTimes = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS45,XTHD.SystemFont,18)----今日剩余挑战次数文字 
		targ:addChild(_restOfTimes)
		_restOfTimes:setColor(XTHD.resource.color.gray_desc)
		_restOfTimes:setAnchorPoint(1,1)
		_restOfTimes:setPosition(_times:getPositionX() - _times:getContentSize().width - 5,_times:getPositionY() - 2)
	end 
	----名字，等级 
	local name = XTHDLabel:createWithSystemFont(data.name,XTHD.SystemFont,18)
	targ:addChild(name)
	name:setColor(XTHD.resource.color.gray_desc)
	name:setAnchorPoint(0,1)
	name:setPosition(portrait:getPositionX() + portrait:getBoundingBox().width + 10,portrait:getPositionY() - 2)
	-----
	local level = XTHDLabel:createWithParams({
		text = "LV:"..data.level,
		fontSize = 18,		
	})
	level:setColor(XTHD.resource.color.gray_desc)
	targ:addChild(level)
	level:setAnchorPoint(0,0.5)	
	level:setPosition(name:getPositionX(),portrait:getPositionY() - portrait:getBoundingBox().height + level:getContentSize().height / 2+10)
	------队伍
	local y = portrait:getPositionY() - portrait:getBoundingBox().height-5
	
	for i = 1,#data.team do 
		---第一层背景
		local _bg = ccui.Scale9Sprite:create()
		_bg:setContentSize(cc.size(500,95))
		targ:addChild(_bg)
		_bg:setPosition(targ:getContentSize().width / 2,y - _bg:getContentSize().height / 2+10)
		---第二层背景
		local normal = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
		normal:setContentSize(cc.size(500,87))
		local selected = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
		selected:setContentSize(cc.size(500,91))
		local bg = XTHD.createPushButtonWithSound({
			normalNode = normal,
			selectedNode = selected,
		},3)
		_bg:addChild(bg)
		bg.teamData = data.team[i]
		bg:setPosition(_bg:getContentSize().width / 2,_bg:getContentSize().height / 2)
		bg:setTouchEndedCallback(function( )
			self:doSelectedEnemy(bg)
		end)
		bg:setEnable(self._createType == 2)
		bg:setTag(data.team[i][1].teamId)
		-----被选中的黄框 
		local _yellowPic = ccui.Scale9Sprite:create("res/image/common/scale9_bg_13.png")
		_yellowPic:setContentSize(cc.size(515,100))
		bg:addChild(_yellowPic)
		_yellowPic:setPosition(bg:getContentSize().width / 2,bg:getContentSize().height / 2)
		bg.selectedPic = _yellowPic		
		_yellowPic:setVisible(false)
		if i == 1 and self._createType == 2 then 
			bg:setSelected(true)
			bg.selectedPic:setVisible(true)
			self._selectedIndex = bg:getTag()
			self._selectedTeamData = data.team[i]
			self._checkBoxObj = bg
			self._selectedTeamData = data.team[i]
		end 
		----战斗力
		local _zhan = cc.Sprite:create("res/image/common/fightValue_Image.png")
		_zhan:setScale(0.8)
		bg:addChild(_zhan)
		_zhan:setPosition(_zhan:getContentSize().width / 2 + 5,bg:getContentSize().height / 2)
		----值
		local _value = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt",data.team[i][1].power)
		bg:addChild(_value)
		_value:setAnchorPoint(0,0.5)
		_value:setScale(0.7)
		_value:setPosition(_zhan:getContentSize().width / 2 + _zhan:getPositionX(),_zhan:getPositionY() - 3)
		---头像们
		local x = bg:getContentSize().width - 10
		for k,v in pairs(data.team[i][1].heros) do 
			local node = HeroNode:createWithParams({
				heroid = v.petId,
				star = v.star,
				level = v.level,
				needHp = true,
				curNum = v.curHp,
				maxNum = v.property['200'],
				advance = v.phase,
			})
			bg:addChild(node)
			node:setAnchorPoint(1,0.5)
			node:setPosition(x,bg:getContentSize().height / 2+3)
			node:setScale(0.6)
			x = x - node:getBoundingBox().width - 5
		end 
		y = y - _bg:getContentSize().height - 2
	end 
	if self._createType == 2 then 
		-----挑战按钮
		local _chagBtn = XTHD.createCommonButton({
			btnColor = "write",
			text = LANGUAGE_VERBS.challenge,
			isScrollView = true,
			fontSize = 26,
			fontColor = cc.c3b(255,255,255)
		})
		_chagBtn:setScale(0.7)
		targ:addChild(_chagBtn)
		_chagBtn:setPosition(targ:getContentSize().width / 2,_chagBtn:getContentSize().height - 5)
		_chagBtn:setTouchEndedCallback(function( )
			self:doChallengBtn(_chagBtn)	
		end)
	end 
end

function ZhongZuCityTeamLayer:doChallengBtn( sender )
	if ZhongZuDatas._serverSelfCityDatas.maxCount - ZhongZuDatas._serverSelfCityDatas.curChallengeCount > 0 then 
		local challageData = {
			charId = self._teamData.charId,
			teamId = self._selectedIndex,
			cityId = self._cityID,
			name = self._teamData.name,
			teams = self._selectedTeamData,
		}
		
		ZhongZuDatas:setFightTeamDatas({cityId = self._cityID,cityLevel = ZhongZuDatas._serverSelfCityDatas.cityLevel})

		LayerManager.addShieldLayout()
	    local SelHeroLayer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua")
	    local _layerHandler = SelHeroLayer:create(BattleType.CAMP_TEAMCOMPARE, nil, challageData)
	    LayerManager.removeLayout()
	    fnMyPushScene(_layerHandler)
	else 
		XTHDTOAST(LANGUAGE_TIPS_WORDS32)
	end 
end

function ZhongZuCityTeamLayer:doSelectedEnemy( sender )
	if sender then 
		sender:setSelected(true)
		sender.selectedPic:setVisible(true)
		if self._checkBoxObj then 
			self._checkBoxObj:setSelected(false)
			self._checkBoxObj.selectedPic:setVisible(false)
			self._checkBoxObj = sender
		end 
		self._selectedIndex = sender:getTag()
		self._selectedTeamData = sender.teamData
	end 
end

return ZhongZuCityTeamLayer