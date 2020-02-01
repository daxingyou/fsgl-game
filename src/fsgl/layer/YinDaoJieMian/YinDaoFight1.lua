
local GuideFight1 = class("GuideFight1", function(params)
    return XTHDDialog:create()
end)

function GuideFight1:onCleanup()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
	musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_main,true)
	XTHD.dispatchEvent({name = "EVENT_LEVEUP"}) 
end

function GuideFight1:ctor(params, scene)
	local _params = params or {}

	local winWidth  = self:getContentSize().width
	local winHeight = self:getContentSize().height
	

	local _playerData
	self._rightData = _params.rightData
	if _params.id == gf1_data_rhino.heroid then
		_playerData = gf1_data_rhino
	elseif _params.id == gf1_data_mechanicalPig.heroid then
		_playerData = gf1_data_mechanicalPig
	else
		_playerData = gf1_data_chameleon
		--_playerData = guide_data_pangolin
	end
	self._playerData = _playerData

	local battleLayer = requires("src/battle/BattleLayer.lua"):create()
	scene:addChild(battleLayer)
	
	if _params.ectypeId == 1001 then
		self:initFight1(battleLayer)
	elseif _params.ectypeId == 1002 then
		self:initFight2(battleLayer)
	elseif _params.ectypeId == 1004 then
		self:initFight3(battleLayer)
	end
	battleLayer:start()

	local btn_battle
    btn_battle = XTHD.createCommonButton({
		text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_28,
		isScrollView = false,
        pos = cc.p(winWidth - 60, winHeight - 30),
        endCallback = function() 
            btn_battle:setClickable(false)
            self:doFightEnd(_params.ectypeId%1000)
        end
	})
	btn_battle:setScale(0.7)
    scene:addChild(btn_battle, 10)
end

function GuideFight1:doFightEnd( fightIndex )
	if self._isSendEnd then
		return
	end
	local _instancingid = fightIndex
	self._isSendEnd = true
	-- do cc.Director:getInstance():popScene() return
	print("self._playerData.heroid ---------- iiiiiiiiiiiii".. tostring(self._playerData.heroid))
	print("DBTableHero.DBData count ---------- iiiiiiiiiiiii".. tostring(#DBTableHero.DBData))
	local _mHero = DBTableHero.getDataByID(self._playerData.heroid)

	if not _mHero then
		_mHero = DBTableHero.getDataByID(1)
	end
	local params = {
		battleCostTime = 170,
		battleType = 0,
		instancingid = _instancingid,
    	result = 1,
    	star = 3,
    	wave = #self._rightData,
    	left = {
	        {
	            {
	                ["heroid"]   = _mHero.heroid,
	                ["hp_begin"] = _mHero.hp,
	                ["hp_end"]   = _mHero.hp,
	                ["hurt"]     = 0,
	                ["id"]       = _mHero.heroid,
	                ["sp_begin"] = 0,
	                ["sp_end"]   = 0,
	                ["standId"]  = 1,
	                ["type"]     = "player",
	            },
	        },
	    },
	    right = {},
	}

	for index=1, #self._rightData do
		local team = {}
		local waveMonsters = self._rightData[index]
		for k, monster in pairs(waveMonsters) do
			local _tb = {}
			local monsterid = monster.monsterid
			_tb.heroid = monster.heroid
			_tb.hp_begin = monster.hp
			_tb.hp_end = 0
			_tb.hurt = 0
			_tb.id = monster.monsterid
			_tb.sp_begin = monster.beginanger
			_tb.sp_end = 0
			_tb.standId = 100 + (tonumber(k) or 0)
			_tb.type = "monster"
			team[#team + 1] = _tb
		end
		params.right[#params.right + 1] = team
	end

	local _scene = cc.Director:getInstance():getRunningScene()
	ClientHttp.http_SendFightValidation(_scene, function(data)
		local refresh_data = {}
		refresh_data["type"] = ChapterType.Normal
        refresh_data["instancingid"] = _instancingid
        refresh_data["star"] = data.star
        refresh_data["surplusCount"] = data["surplusCount"] or 0
		CopiesData.refreshDataBase(refresh_data)

		local playerProperty = data.playerProperty
		if playerProperty and #playerProperty > 0 then
	        local _current = gameUser.getIngot()
	        for i=1,#playerProperty do
	            local pro_data = string.split( playerProperty[i],',')
	            DBUpdateFunc:UpdateProperty("userdata", pro_data[1], pro_data[2], nil, true)
		    end
		    XTHD.resource.PVE11GiveIngot = gameUser.getIngot() - _current
		end
		local allPets = data.allPets
		if allPets and #allPets > 0 then
            for i=1, #allPets do
                local _key = allPets[i]
                local hero_data = data.pet[tostring(_key)]
                if hero_data and hero_data["property"] and #hero_data["property"] > 0 then
                	for j = 1, #hero_data["property"] do
			            local pro_data = string.split(hero_data["property"][j],',')
			            DBUpdateFunc:UpdateProperty("userheros", pro_data[1], pro_data[2], _key)
			        end
                end
            end
        end
        local bagItems = data.bagItems
        if bagItems and #bagItems > 0 then
	        for i=1,#bagItems do
				DBTableItem.updateCount(gameUser.getUserId(), bagItems[i], bagItems[i]["dbId"])
	        end
	    end
		cc.Director:getInstance():popScene()
    end, function()
     	createFailHttpTipToPop()
	end, params)
end

function GuideFight1:showGuochang(battleLayer, fightIndex)
	local function _func_(node) 
		node:runAction(cc.FadeTo:create(3.0,0))
        for k,node in pairs(node:getChildren()) do
            _func_(node)
        end
    end
    _func_(battleLayer)
    local _text = ""
    if fightIndex == 1 then
    	_text = "英雄们所向披靡 然而前路仍然凶险！"
	elseif fightIndex == 2 then
    	_text = "孔宣实力超群，英雄们能否化险为夷？"
	elseif fightIndex == 4 then
    	_text = "不要辜负了殷十娘的一番苦心，快去营救禅玉将军！"
	end
    battleLayer:runAction(cc.Sequence:create(
    	cc.DelayTime:create(3.0), 
    	cc.CallFunc:create(function()
			battleLayer:removeAllChildren()
			local labTxt =  XTHD.createLabel({color = cc.c3b(255,255,255) , fontSize = 30}) 
			labTxt:setDimensions(800,150)
			labTxt:setAnchorPoint(cc.p(0.5,0.5))
			labTxt:setPosition(winWidth / 2 , winHeight / 2)
			labTxt:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			labTxt:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
			labTxt:setOpacity(0)
			labTxt:setString(_text)
			battleLayer:addChild(labTxt)
			labTxt:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.FadeIn:create(3.0),cc.FadeOut:create(2.0),cc.CallFunc:create(function( ... )
				battleLayer:removeFromParent()
				self:doFightEnd(fightIndex)
			end)))
	end)))

end

function GuideFight1:initFight1(battleLayer)
	local _playerData = self._playerData
	local teamListLeft = {}
	local teamListRight = {}
	local _bgList = {"res/image/background/bg_60.jpg","res/image/background/bg_61.jpg"}
	local animal = {id = _playerData.heroid, isGuidingHero = true, _type = ANIMAL_TYPE.PLAYER, helps = clone(_playerData)}
	teamListLeft[#teamListLeft + 1] = animal

	local _data = {
		gf1_data_elephant,
		gf1_data_hippo,
		gf1_data_monkey,
		gf1_data_raccoon,
	}

	for k,v in pairs(_data) do
		local animal = {id = v.heroid ,_type = ANIMAL_TYPE.PLAYER, helps = clone(v)}
		teamListLeft[#teamListLeft + 1] = animal
	end
	table.sort(teamListLeft, function(a, b) 
		local n1 = tonumber(a.helps.attackrange) or 0
		local n2 = tonumber(b.helps.attackrange) or 0
		return n1 < n2
	end)

	_data = {
		{
			gf1_data_pigHeader,
			gf1_data_wolf1,
			gf1_data_wolf1,
			gf1_data_wolf2,
			gf1_data_wolf2,
			gf1_data_wolf2,
			gf1_data_wolf2,
			gf1_data_crocodileHeader,
			gf1_data_crocodile,
			gf1_data_crocodile,
			gf1_data_crocodile,
		}
	}
	for k,v in pairs(_data) do
		local rightData = {}
		local team = {}
		for key,val in pairs(v) do
			local animal = {id = val.heroid ,_type = ANIMAL_TYPE.MONSTER, monster = clone(val)}
			team[#team + 1] = animal
		end
		rightData.team = team
	    teamListRight[#teamListRight + 1] = rightData
	end

	battleLayer:initWithParams({
		bgList 			= _bgList,
		battleTime 		= 3*60,
		isFirstFight    = false,
		showSpeed 		= false,
		bgm				= "res/sound/bgm_02_battle_01.mp3",
		bgType          = BATTLE_GUIDEBG_TYPE.TYPE_NORMAL,
		isGuide         = 1001,
		teamListLeft	={teamListLeft},
		teamListRight	=teamListRight,
		battleEndCallback = function(params) 
			self:showGuochang(battleLayer, 1)
		end
	})
end

function GuideFight1:initFight2(battleLayer)
	local _playerData = self._playerData
	local teamListLeft = {}
	local teamListRight = {}
	local _bgList = {"res/image/background/bg_61.jpg","res/image/background/bg_62.jpg","res/image/background/bg_60.jpg"}
	local animal = {id = _playerData.heroid, isGuidingHero = true, _type = ANIMAL_TYPE.PLAYER, helps = clone(_playerData)}
	teamListLeft[#teamListLeft + 1] = animal

	local _data = {
		gf1_data_elephant,
		gf1_data_hippo,
		gf1_data_monkey,
		gf1_data_raccoon,
	}

	for k,v in pairs(_data) do
		local animal = {id = v.heroid ,_type = ANIMAL_TYPE.PLAYER, helps = clone(v)}
		teamListLeft[#teamListLeft + 1] = animal
	end
	table.sort(teamListLeft, function(a, b) 
		local n1 = tonumber(a.helps.attackrange) or 0
		local n2 = tonumber(b.helps.attackrange) or 0
		return n1 < n2
	end)

	_data = {
		{
			gf1_data_peacock,
			gf1_data_pig2,
			gf1_data_pig2,
			gf1_data_pig2,
			gf1_data_pig2,
		}
	}
	for k,v in pairs(_data) do
		local rightData = {}
		local team = {}
		for key,val in pairs(v) do
			local animal = {id = val.heroid ,_type = ANIMAL_TYPE.MONSTER, monster = clone(val)}
			team[#team + 1] = animal
		end
		rightData.team = team
	    teamListRight[#teamListRight + 1] = rightData
	end

	battleLayer:initWithParams({
		bgList 			= _bgList,
		battleTime 		= 3*60,
		isFirstFight    = false,
		showSpeed 		= false,
		bgm				= "res/sound/bgm_02_battle_01.mp3",
		bgType          = BATTLE_GUIDEBG_TYPE.TYPE_NORMAL,
		isGuide         = 1002,
		teamListLeft	={teamListLeft},
		teamListRight	=teamListRight,
		battleEndCallback = function(params) 
			self:showGuochang(battleLayer, 2)
		end
	})
end


function GuideFight1:initFight3(battleLayer)
	local _playerData = self._playerData
	local teamListLeft = {}
	local teamListRight = {}
	local _bgList = {"res/image/background/bg_61.jpg"}
	local animal = {id = _playerData.heroid, isGuidingHero = true, _type = ANIMAL_TYPE.PLAYER, helps = clone(_playerData)}
	teamListLeft[#teamListLeft + 1] = animal

	local _data = {
		gf1_data_fox,
		gf1_data_horse,
		gf1_data_snake,
		gf1_data_butterfly,
	}

	for k,v in pairs(_data) do
		local animal = {id = v.heroid ,_type = ANIMAL_TYPE.PLAYER, helps = clone(v)}
		teamListLeft[#teamListLeft + 1] = animal
	end
	table.sort(teamListLeft, function(a, b) 
		local n1 = tonumber(a.helps.attackrange) or 0
		local n2 = tonumber(b.helps.attackrange) or 0
		return n1 < n2
	end)

	_data = {
		{
			gf1_data_peacock,
			gf1_data_pig2,
			gf1_data_pig2,
			gf1_data_pig2,
			gf1_data_pig2,
		}
	}
	for k,v in pairs(_data) do
		local rightData = {}
		local team = {}
		for key,val in pairs(v) do
			local animal = {id = val.heroid ,_type = ANIMAL_TYPE.MONSTER, monster = clone(val)}
			team[#team + 1] = animal
		end
		rightData.team = team
	    teamListRight[#teamListRight + 1] = rightData
	end

	battleLayer:initWithParams({
		bgList 			= _bgList,
		battleTime 		= 3*60,
		isFirstFight    = false,
		showSpeed 		= false,
		bgm				= "res/sound/bgm_02_battle_01.mp3",
		bgType          = BATTLE_GUIDEBG_TYPE.TYPE_NORMAL,
		isGuide         = 1004,
		teamListLeft	={teamListLeft},
		teamListRight	=teamListRight,
		battleEndCallback = function(params) 
			self:showGuochang(battleLayer, 4)
		end
	})
end

function GuideFight1:create(params)
	local scene = cc.Scene:create()
	cc.Director:getInstance():pushScene(scene)
	local _lay = GuideFight1.new(params, scene)
	scene:addChild(_lay, -1)
	return _lay
end

return GuideFight1