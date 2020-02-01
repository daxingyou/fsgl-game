
--[[
authored by LITAO
--种族里调整防守布阵面板
]]
local BangPaiDuiWu = class("BangPaiDuiWu",function( )
	return XTHD.createBasePageLayer({bg="res/image/guild/guildWar/guildWar_bg.png",isOnlyBack = true})
end)

function BangPaiDuiWu:ctor(data,parent)
	----注册在防守队伍调整之后刷新该UI
	XTHD.addEventListener({name = REFRESH_GUILDBATTLEGROUP,callback = function( event)
		self:refreshAfterAdjust()
	end})
end

function BangPaiDuiWu:create(data,parent)
	self._parent = parent
	self._Data = data
	dump(data,"获取帮派战队伍")
	local layer = BangPaiDuiWu.new(data,parent)
	if layer then 
		layer:init()
	end	 
	return layer
end 

function BangPaiDuiWu:onCleanup()
	XTHD.removeEventListener(REFRESH_GUILDBATTLEGROUP)
end

function BangPaiDuiWu:init( )
	local bg = cc.Sprite:create("res/image/camp/camp_bg2.png")
	self:addChild(bg)
	bg:setContentSize(cc.Director:getInstance():getWinSize())
	bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	----返回按钮
--	local _backBtn = XTHD.createNewBackBtn(function( )
--		self:removeFromParent()
--	end)	
--	self:addChild(_backBtn)	
--	_backBtn:setPosition(self:getContentSize().width,self:getContentSize().height)
	------注意事项 
	local _attention = cc.Sprite:create("res/image/guild/GuildTishi_2.png")
	self:addChild(_attention)
	_attention:setPosition(self:getContentSize().width / 2,_attention:getContentSize().height-5)
	
	self:updateUI()
end

function BangPaiDuiWu:initListView(targ,posy)
	posy = posy - 10
	for i = 1,3 do 		
		local data = self._Data.list[i]
		local node = self:createListCell(i,data)
		targ:addChild(node)
		node:setAnchorPoint(0.5,1)
		node:setPosition(targ:getContentSize().width / 2,posy)
		posy = posy - node:getContentSize().height - 15
	end 
end 

function BangPaiDuiWu:createListCell( indx,data)
	local node = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")	
	node:setContentSize(663,130)
	node:setTag(indx)
	--防守位置背景
	local world_bg = ccui.Scale9Sprite:create("res/image/plugin/saint_beast/title_bg2.png")
	world_bg:setAnchorPoint(0,0.5)
	world_bg:setPosition(17,node:getContentSize().height - world_bg:getContentSize().height / 2 - 7)
	node:addChild(world_bg)
	----防守位置 
	local _word = cc.Sprite:create("res/image/guild/Guildtroops.png")
	node:addChild(_word)
	_word:setAnchorPoint(0,0.5)
	_word:setPosition(17,node:getContentSize().height - _word:getContentSize().height / 2 - 12)
		
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
		LayerManager.addShieldLayout()
		local _team_data = self:getTeamData(indx)
		local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua"):createWithParams({
			battle_type = BattleType.GUILDWAR_TEAM, 	--战斗类型
			team_data = _team_data, 
			teamIndex = button:getTag()	,	--目标队伍id，需要设置的防守队伍的队伍id
		})		 
		fnMyPushScene(_layer)
	end)	
	node:addChild(button)
	button:setAnchorPoint(1,0.5)	
	button:setPosition(node:getContentSize().width - 10,node:getContentSize().height * 1/3)

	-----头像们
	local x = button:getPositionX() - button:getBoundingBox().width-20
	
	local power = 0
	if data then 
		for i = 1, 5 do
			local v = DBTableHero.getHeroData(data.pets[i])
			local head = nil 
			if v then 
				head = HeroNode:createWithParams({
					heroid = v.heroid,
					star = v.star,
					level = v.level,
					needHp = true,
					curNum = v.curHp,
					advance = v.phase,
				})
				head:setScale(0.57)
				power = power + v.power
			else 
				head = cc.Sprite:create("res/image/common/no_hero.png")
				head:setScale(0.6)
			end 
			node:addChild(head)
			head:setAnchorPoint(1,0.5)
			head:setPosition(x - (i-1) *head:getContentSize().width*0.7,button:getPositionY())
		end
		--------战斗力logo
		local _icon = cc.Sprite:create("res/image/common/fightValue_Image.png")
		node:addChild(_icon)
		_icon:setAnchorPoint(0,0.5)
		 _icon:setScale(0.8)
		_icon:setPosition(20,node:getContentSize().height * 1/3)

		---值 
		local _value = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt",power)
		_value:setAdditionalKerning(-2)
		node:addChild(_value)
		_value:setAnchorPoint(0,0.5)
		--_value:setScale(0.7)
		_value:setPosition(_icon:getPositionX() + _icon:getBoundingBox().width,_icon:getPositionY() - 5)
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
	return node
end
--此处把数据组装成PVP防守队伍相同的结构，是为了在选将界面方便做统一处理
function BangPaiDuiWu:getTeamData(indx)
	local defendTeams = {}
	local i = 1
	for k,v in pairs(self._Data.list) do 
		local _data = v.pets
		defendTeams[i] = {}
		defendTeams[i].teamId = 0
		defendTeams[i].cityId = 0
		defendTeams[i].team = {}
		dump(_data)
		for j = 1,#_data do
			print("===========>>>",i) 
			defendTeams[i].team[#defendTeams[i].team + 1] = tonumber(_data[j])
		end 
		i = i + 1
	end 
	return defendTeams
end
---刷新队伍UI在调整了队伍之后
function BangPaiDuiWu:refreshAfterAdjust( )
	    XTHDHttp:requestAsyncInGameWithParams({
        modules = "myGuildBattleGroup?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
				self._Data = data
                self:updateUI()
            else
				XTHDTOAST(data.msg)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
    })
end
----更新UI
function BangPaiDuiWu:updateUI( )
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
	local titleBg = cc.Sprite:create("res/image/guild/GuildTishi_1.png")
	self._backBoard:addChild(titleBg)
	titleBg:setAnchorPoint(0.5,1)
	titleBg:setPosition(self._backBoard:getContentSize().width / 2,self._backBoard:getContentSize().height - titleBg:getContentSize().height - 18)
	
	self:initListView(self._backBoard,titleBg:getPositionY() - titleBg:getContentSize().height)
end

return BangPaiDuiWu