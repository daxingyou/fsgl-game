
--[[
authored by LITAO
--种族里调整防守布阵面板
]]
local ZhongZuAdjustEmbattle = class("ZhongZuAdjustEmbattle",function( )
	return XTHDDialog:create()
end)

function ZhongZuAdjustEmbattle:ctor(cityID,parent)
	self.__cityID = cityID
	self.__parent = parent

	self._pressCounter = 0----按下的时间（秒）
	self._defendTeamsNode = {} ----当前防守队伍
	self._defendUpNode = {}
	self._preIndex = 0
	self._backBoard = nil

	self.Tag = {
		ktag_action1 = 1024,
		ktag_nodeMoveButton = 2048,
	}

	self.color = {
		yellow = cc.c3b(247,157,66),
		brown = cc.c3b(64,30,6),
		darkBrown = cc.c3b(66,28,7),
		darkRed = cc.c3b(255,90,0)
	}

	----注册在防守队伍调整之后刷新该UI
	XTHD.addEventListener({name = EVENT_NAME_REFRESH_CAMPTEAMADJUSTED,callback = function( event)
		self:refreshAfterAdjust()
	end})
	---注册在种族战开始的时候关闭该UI
	XTHD.addEventListener({name = EVENT_NAME_CAMPADJUSTLAYEREXIT ,callback = function(event)
		self:removeFromParent()
	end})
end

function ZhongZuAdjustEmbattle:create(cityID,parent)
	local layer = ZhongZuAdjustEmbattle.new(cityID,parent)
	if layer then 
		layer:init()
	end	 
	return layer
end 

function ZhongZuAdjustEmbattle:onCleanup()
	XTHD.removeEventListener(EVENT_NAME_REFRESH_CAMPTEAMADJUSTED)
	XTHD.removeEventListener(EVENT_NAME_CAMPADJUSTLAYEREXIT)
end

function ZhongZuAdjustEmbattle:init( )
	local bg = cc.Sprite:create("res/image/camp/camp_bg2.png")
	self:addChild(bg)
	bg:setContentSize(cc.Director:getInstance():getWinSize())
	bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	----返回按钮
	local _backBtn = XTHD.createNewBackBtn(function( )
		self:removeFromParent()
	end)	
	self:addChild(_backBtn)	
	_backBtn:setPosition(self:getContentSize().width,self:getContentSize().height)
	------注意事项 
	local _attention = cc.Sprite:create("res/image/camp/map/camp_label8.png")
	self:addChild(_attention)
	_attention:setPosition(self:getContentSize().width / 2,_attention:getContentSize().height-5)
	
	self:updateUI()
end

function ZhongZuAdjustEmbattle:initListView(targ,posy)
	posy = posy - 10
	for i = 1,3 do 		
		local data = ZhongZuDatas._serverSelfDefendTeam.teams[i]
		local node = self:createListCell(i,data)
		targ:addChild(node)
		node:setAnchorPoint(0.5,1)
		node:setPosition(targ:getContentSize().width / 2,posy)
		posy = posy - node:getContentSize().height - 15
	end 
end 

function ZhongZuAdjustEmbattle:createListCell( indx,data)
	local node = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")	
	node:setContentSize(663,130)
	node:setTag(indx)
	--防守位置背景
	local world_bg = ccui.Scale9Sprite:create("res/image/plugin/saint_beast/title_bg2.png")
	world_bg:setAnchorPoint(0,0.5)
	world_bg:setPosition(17,node:getContentSize().height - world_bg:getContentSize().height / 2 - 7)
	node:addChild(world_bg)
	----防守位置 
	local _word = cc.Sprite:create("res/image/camp/camp_adjust_word2.png")
	node:addChild(_word)
	_word:setAnchorPoint(0,0.5)
	_word:setPosition(17,node:getContentSize().height - _word:getContentSize().height / 2 - 12)
	--城池名字	
	local _name = cc.Sprite:create("res/image/camp/map/camp_label6.png")
	local _statuIcon = cc.Sprite:create("res/image/camp/map/camp_beLazy_icon.png")
	if data then 
		if data.cityId > 0 then 
			_name = cc.Sprite:create("res/image/camp/map/camp_cityName_yellow"..data.cityId..".png")
		end 
		_statuIcon = cc.Sprite:create("res/image/camp/map/camp_hardDefence_icon.png")
	end 
	node:addChild(_name)
	_name:setAnchorPoint(0,0.5)
	_name:setPosition(_word:getPositionX() + _word:getContentSize().width + 10,_word:getPositionY())
	----坚守中、偷懒中
	node:addChild(_statuIcon)
	_statuIcon:setAnchorPoint(1,0.5)
	_statuIcon:setPosition(node:getContentSize().width - 20,_word:getPositionY())
	---队数
	local _teams = cc.Sprite:create("res/image/camp/map/camp_team"..indx..".png")
	node:addChild(_teams)
	_teams:setAnchorPoint(0,1)
	_teams:setScale(0.8)
	_teams:setPosition(10,_statuIcon:getPositionY() - _statuIcon:getContentSize().height / 2 )	
	--调整按钮
	local button = XTHD.createCommonButton({
		btnColor = "write_1",
		btnSize = cc.size(131,49),
		isScrollView = false,
		musicFile = XTHD.resource.music.effect_btn_common,
		text = "调整",
		fontSize = 26,
	})
	button:setScale(0.6)
	button:setTag(indx)
	button:setTouchEndedCallback(function( )
        YinDaoMarg:getInstance():overCurrentGuide(true)
		LayerManager.addShieldLayout()
		local _team_data = self:getTeamData(indx)
		local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua"):createWithParams({
			battle_type = BattleType.CAMP_DEFENCE, 	--战斗类型
			team_data = _team_data, 			--传进来的队伍信息，如果是进攻，则不需要传此参数，因为进攻队伍信息都存在本地了，目前只有PVP和种族战用到了该参数有用来设置防守队伍
			teamIndex = button:getTag()	,	--目标队伍id，需要设置的防守队伍的队伍id
			cityId 	= self.__cityID,	--种族战cityID 
		})		 
		fnMyPushScene(_layer)
	end)	
	---按钮上的字
	-- local _word = XTHD.resource.getButtonImgTxt("tiaozheng_lan")
	-- if _word then 
	-- 	button:addChild(_word)
	-- 	_word:setPosition(button:getContentSize().width / 2,button:getContentSize().height / 2)
	-- end 
	node:addChild(button)
	button:setAnchorPoint(1,0.5)	
	button:setPosition(node:getContentSize().width - 10,node:getContentSize().height * 1/3)
	-----头像们
	local x = button:getPositionX() - button:getBoundingBox().width-20
	if data then 
		--------战斗力logo
		local _icon = cc.Sprite:create("res/image/common/fightValue_Image.png")
		node:addChild(_icon)
		_icon:setAnchorPoint(0,0.5)
		 _icon:setScale(0.8)
		_icon:setPosition(_teams:getPositionX() + _teams:getContentSize().width,node:getContentSize().height * 1/3)
		---值 
		local _value = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt",data.teams[1].power)
		_value:setAdditionalKerning(-2)
		node:addChild(_value)
		_value:setAnchorPoint(0,0.5)
		_value:setScale(0.6)
		_value:setPosition(_icon:getPositionX() + _icon:getBoundingBox().width,_icon:getPositionY() - 2)
		
		x = x - 50 * 5
		local space = 5
		for i = 1,5 do 
			local v = data.teams[1].heros[i]
			local head = nil 
			if v then 
				head = HeroNode:createWithParams({
					heroid = v.petId,
					star = v.star,
					level = v.level,
					needHp = true,
					curNum = v.curHp,
					maxNum = v.property['200'],
					advance = v.phase,
				})
				head:setScale(0.57)
			else 
				head = cc.Sprite:create("res/image/common/no_hero.png")
				head:setScale(0.6)
			end 
			node:addChild(head)
			head:setAnchorPoint(1,0.5)
			head:setPosition(x,button:getPositionY())
			x = x + head:getBoundingBox().width + space
		end 
	else 
		local _label = XTHDLabel:createWithParams({
			text = LANGUAGE_CAMP_TIPSWORDS11,
			fontSize = 18,
			color = cc.c3b(255,161,60),
		})
		node:addChild(_label)
		_label:setAnchorPoint(1,0.5)
		_label:setPosition(x - 50,button:getPositionY())
	end 
    if indx == 1 then
        self.adjustBtn = button
        self:addGuide()
    end
	return node
end
--此处把数据组装成PVP防守队伍相同的结构，是为了在选将界面方便做统一处理
function ZhongZuAdjustEmbattle:getTeamData(indx)
	local defendTeams = {}
	local i = 1
	for k,v in pairs(ZhongZuDatas._serverSelfDefendTeam.teams) do 
		defendTeams[i] = {}
		defendTeams[i].teamId = v.teams[1].teamId
		defendTeams[i].cityId = v.cityId
		defendTeams[i].team = {}
		local _data = v.teams[1].heros
		for j = 1,#_data do 
			defendTeams[i].team[#defendTeams[i].team + 1] = tonumber(_data[j].petId)
		end 
		i = i + 1
	end 
	return defendTeams
end
---刷新队伍UI在调整了队伍之后
function ZhongZuAdjustEmbattle:refreshAfterAdjust( )
	ZhongZuDatas.requestServerData({
		method = "searchMyDefendGroup?",
		success = function( )
			self:updateUI()
			ZhongZuDatas.requestServerData({
				method = "selfCampCityList?",
				success = function( )
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_CAMP_SELFCITIES})					
				end,
				target = self,
			})
		end,
		target = self,
	})	
end
----更新UI
function ZhongZuAdjustEmbattle:updateUI( )
	if self._backBoard then 
		self._backBoard:removeAllChildren()
	else
		---背景
		local back = ccui.Scale9Sprite:create()	
		back:setContentSize(1024,483)
		back:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
		self:addChild(back)
		self._backBoard = back
	end 
	-----标题条
	local titleBg = cc.Sprite:create("res/image/camp/map/camp_label4.png")
	self._backBoard:addChild(titleBg)
	titleBg:setAnchorPoint(0.5,1)
	titleBg:setPosition(self._backBoard:getContentSize().width / 2,self._backBoard:getContentSize().height - titleBg:getContentSize().height - 18)
	
	self:initListView(self._backBoard,titleBg:getPositionY() - titleBg:getContentSize().height)
end

function ZhongZuAdjustEmbattle:addGuide( )
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self.adjustBtn, -----点击调整按钮
        index = 6,
        offset = cc.p(535,415),
    },25)
    YinDaoMarg:getInstance():doNextGuide()    
end

return ZhongZuAdjustEmbattle