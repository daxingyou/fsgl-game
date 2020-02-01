--createdBy xingchen 
--2015/10/30
--帮派战开战界面
local BangPaiZhanKaiZhan = class("BangPaiZhanKaiZhan",function()
		local layer = XTHDDialog:create()
	    return layer
	end)
function BangPaiZhanKaiZhan:ctor(data)
	self.attackBgTable = {}
	self.challengeListData = {}
	self:setChallengeListData(data)
	self:initLayer()
end

function BangPaiZhanKaiZhan:oncCleanup()
	local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey("res/image/guild/guildWar/guildWar_fightBg.png")
end

function BangPaiZhanKaiZhan:initLayer()
	local winSize = cc.Director:getInstance():getWinSize()
	local _bg = cc.Sprite:create("res/image/guild/guildWar/guildWar_fightBg.png")
	_bg:setContentSize(winSize)
    _bg:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2 ))
    self:addChild(_bg)
    -- 返回按钮
	local _btnBack = XTHD.createNewBackBtn(function()
		    LayerManager.removeLayout(self)
		end)
	_btnBack:setAnchorPoint(cc.p(1,1));
	_btnBack:setPosition(cc.p(self:getContentSize().width-4,self:getContentSize().height));
	self:addChild(_btnBack);

	local _titleBg = cc.Sprite:create("res/image/guild/guildWar/guildWar_fightTitleBg.png")
	_titleBg:setAnchorPoint(cc.p(0,1))
	_titleBg:setPosition(cc.p(0,self:getContentSize().height))
	self:addChild(_titleBg)

	local _titleSp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_adjust.png")
	_titleSp:setAnchorPoint(cc.p(0,0.5))
	_titleSp:setPosition(cc.p(12,_titleBg:getContentSize().height/2))
	_titleBg:addChild(_titleSp)
	local _desLabelSp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_dragprompt.png")
	_desLabelSp:setAnchorPoint(cc.p(0,0.5))
	_desLabelSp:setPosition(cc.p(_titleSp:getBoundingBox().x+_titleSp:getBoundingBox().width + 20,_titleSp:getPositionY()))
	_titleBg:addChild(_desLabelSp)

	local _leftSize = cc.size(424,500) -- 100*(#_leftListData)
	local _anchorLeftSub = 5-#self.challengeListData["aGroup"]
	local _leftDefenceBg = cc.Sprite:createWithTexture(nil, cc.rect(0,0,_leftSize.width,_leftSize.height))
	_leftDefenceBg:setOpacity(0)
	_leftDefenceBg:setAnchorPoint(cc.p(0,0.5+0.1*_anchorLeftSub))
	_leftDefenceBg:setPosition(cc.p(0,(self:getContentSize().height - 60)/2))
	self:addChild(_leftDefenceBg)

	local _distance = 500/10
	local _memberPos = {
		cc.p(212,_distance*9),cc.p(212,_distance*7),cc.p(212,_distance*5),cc.p(212,_distance*3),cc.p(212,_distance*1)
	}
	self.memberPos = _memberPos
	self.distance = _distance

	self.attackBgTable = {}
	local _leftListData = self.challengeListData["aGroup"] or {}
	self.adjustOrder = {}
	for i=1,#_leftListData do
		-- local _posIndex = i+5-#_rightListData
		local _posIndex = i
		self.adjustOrder[i] = i
		local _leftBg = XTHDPushButton:createWithParams({
				normalFile = "res/image/guild/guildWar/guildWar_attackBg.png",
				selectedFile = "res/image/guild/guildWar/guildWar_attackBg.png",
				needEnableWhenOut = true
			})
		_leftBg.posIndex = i
		_leftBg:setPosition(_memberPos[_posIndex])
		_leftDefenceBg:addChild(_leftBg)
		self.attackBgTable[i] = _leftBg
		local _indexKey = i
		if self.challengeListData.selfKillIndex and tonumber(self.challengeListData.selfKillIndex)==i-1 then
			_indexKey = "Over"
		end
		local _indexBtn = XTHD.createButton({
					normalFile = "res/image/guild/guildWar/guildWar_order" .. _indexKey .. ".png",
					selectedFile = "res/image/guild/guildWar/guildWar_order" .. _indexKey .. ".png",
					touchScale = 0.95,
				})
		_indexBtn.posIndex = _indexKey
		_indexBtn:setTouchEndedCallback(function()
				--设置成绝杀。
				if _indexBtn.posIndex and tostring(_indexBtn.posIndex) == "Over" then
					XTHDTOAST(LANGUAGE_KEY_GUILDWAR_TEXT.currentPosIsKillToastXc)
				else
					self:setIndexBtnCallback(tonumber(_indexBtn.posIndex))
				end
			end)
		_indexBtn:setName("indexBtn")
		_indexBtn:setPosition(cc.p(30,_leftBg:getContentSize().height/2))
		_leftBg:addChild(_indexBtn)

		local _attackPlayerSp = HaoYouPublic.getFriendIcon({templateId = _leftListData[i].templateId,level = _leftListData[i].level}, {notShowCamp = true})
		_attackPlayerSp:setScale(72/_attackPlayerSp:getContentSize().width)
		_attackPlayerSp:setAnchorPoint(cc.p(0,0.5))
		_attackPlayerSp:setPosition(cc.p(65,_leftBg:getContentSize().height/2))
		_leftBg:addChild(_attackPlayerSp)

		local _nameLabel = XTHDLabel:create(_leftListData[i].name or "",20)
		_nameLabel:setAnchorPoint(cc.p(0,1))
		_nameLabel:setPosition(cc.p(147+5,_leftBg:getContentSize().height-15))
		_leftBg:addChild(_nameLabel)

		local _powerSp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_power.png")
		_powerSp:setAnchorPoint(cc.p(0,0))
		_powerSp:setPosition(cc.p(_nameLabel:getPositionX(),18))
		_leftBg:addChild(_powerSp)

		local _powerLabel = XTHDLabel:createWithParams({fnt = "res/fonts/yellowwordforcamp.fnt" , text = _leftListData[i].power or 0 , kerning = -2})
		_powerLabel:setAnchorPoint(cc.p(0,0))
		_powerLabel:setPosition(cc.p(_powerSp:getBoundingBox().x+_powerSp:getBoundingBox().width,18-7))
		_leftBg:addChild(_powerLabel)

		_leftBg:setTouchBeganCallback(function()
	    		local _fighterIndex = _leftBg.posIndex
	    		self:doTouchBegan(_leftBg)
	    	end)
	    _leftBg:setTouchMovedCallback(function(touch)
	    		local _fighterIndex = _leftBg.posIndex
	    		self:doTouchMoved(_leftBg,touch,_fighterIndex)
	    	end)
	    _leftBg:setTouchEndedCallback(function()
	    		local _fighterIndex = _leftBg.posIndex
	    		self:doTouchEnded(_leftBg)
	    	end)
	end
	
	local _rightSize = cc.size(424,500) -- 100*(#_rightListData)
	local _anchorRightSub = 5-#self.challengeListData["bGroup"]
	local _rightAttackBg = cc.Sprite:createWithTexture(nil, cc.rect(0,0,_rightSize.width,_rightSize.height))
	_rightAttackBg:setOpacity(0)
	_rightAttackBg:setAnchorPoint(cc.p(1,0.5 + 0.1 * _anchorRightSub))
	_rightAttackBg:setPosition(cc.p(self:getContentSize().width,(self:getContentSize().height - 60)/2))
	self:addChild(_rightAttackBg)
	local _rightListData = self.challengeListData["bGroup"] or {}
	for i=1,#_rightListData do
		-- local _posIndex = i+5-#_leftListData
		local _posIndex = i
		local _rightBg = cc.Sprite:create("res/image/guild/guildWar/guildWar_defenceBg.png")
		_rightBg:setAnchorPoint(cc.p(1,0.5))
		_rightBg:setPosition(cc.p(_rightAttackBg:getContentSize().width,_memberPos[_posIndex].y))
		_rightAttackBg:addChild(_rightBg)
		local _defencePlayerSp = HaoYouPublic.getFriendIcon({templateId = _rightListData[i].templateId,level = _rightListData[i].level}, {notShowCamp = true})
		_defencePlayerSp:setScale(72/_defencePlayerSp:getContentSize().width)
		_defencePlayerSp:setAnchorPoint(cc.p(1,0.5))
		_defencePlayerSp:setPosition(cc.p(_rightBg:getContentSize().width - 10,_rightBg:getContentSize().height/2))
		_rightBg:addChild(_defencePlayerSp)
		local _nameLabel = XTHDLabel:create(_rightListData[i].name or "",18)
		_nameLabel:setAnchorPoint(cc.p(1,1))
		_nameLabel:setPosition(cc.p(_rightBg:getContentSize().width - 10-72-5-5,_rightBg:getContentSize().height - 15))
		_rightBg:addChild(_nameLabel)
	end

	--开战
	local _battleBtnPos = cc.p(self:getContentSize().width/2 + 10,self:getContentSize().height/2+20)

	local _startBattleBtn = XTHD.createButton({
			normalNode = cc.Sprite:create(),
			selectedNode = cc.Sprite:create(),
			touchSize = cc.size(235,230),
		})
	_startBattleBtn:setPosition(_battleBtnPos)
	self:addChild(_startBattleBtn)
	local _battleSpine = sp.SkeletonAnimation:create("res/image/guild/guildWarSpine/zykz.json", "res/image/guild/guildWarSpine/zykz.atlas")
	_battleSpine:setPosition(_battleBtnPos)
	_battleSpine:setAnimation(0,"idle",true)
	self:addChild(_battleSpine)
	_startBattleBtn:setTouchBeganCallback(function()
			_battleSpine:setAnimation(0,"atk",false)
			_battleSpine:addAnimation(0,"idle",true)
		end)
	_startBattleBtn:setTouchEndedCallback(function()
		self:startBattle()
	end)

end


function BangPaiZhanKaiZhan:startBattle()
	local _selfFightTable = {}
	for i=1,#self.challengeListData["aGroup"] do
		_selfFightTable[i] = self.challengeListData["aGroup"][i].charId
	end
	ClientHttp.httpGuildAdjustAttackSequence(self,function(_data)
		XTHD.dispatchEvent({name = "refreshGuildFightCount",data = {surplusTime = _data.surplusTime} })
		self:battleCallback(_data)
	end,{killIndex = self.challengeListData.selfKillIndex,list = json.encode(_selfFightTable)})
end

function BangPaiZhanKaiZhan:battleCallback( sData )
    local _battle_type = BattleType.PVP_GUILDFIGHT
	local pLay = cc.Layer:create()
	pLay._selectedHeroList = clone(self.challengeListData["aGroup"])
	pLay._enemyList = clone(self.challengeListData["bGroup"])
	pLay._fightData = sData
	LayerManager.removeLayout(self)
	LayerManager.addShieldLayout()
	local runningScene = cc.Director:getInstance():getRunningScene()
	runningScene:addChild(pLay)
	local _scene, _battleLayer, _httpTar
	local _battleLayer
	local function _getResult( )
		_httpTar = _scene or pLay
		ClientHttp.httpGuildBattleAttackLog(_httpTar, function( data )
			data._leftList = pLay._selectedHeroList
			data._rightList = pLay._enemyList
			if _battleLayer then
				print("_battleLayer is not nil")
			end

			if pLay then
				print("pLay is not nil")
        		pLay:removeFromParent()
        		pLay = nil
			end

			if not _battleLayer then
				print("_battleLayer is nil")
			end

        	data.backCallback = function() 
				cc.Director:getInstance():popScene()
			end
			if not _scene then
				_scene = cc.Scene:create()
				cc.Director:getInstance():pushScene(_scene)
			end
			_scene:addChild(requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoNVN.lua"):create(data, _battle_type))
        	--_battleLayer:addChild(requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoNVN.lua"):create(data, _battle_type))
		end, function()
			if pLay then
        		pLay:removeFromParent()
        		pLay = nil
        	end
            createFailHttpTipToPop()
		end)
	end

	local function _heroSort( a, b )
		local n1 = tonumber(a.data.attackrange) or 0
		local n2 = tonumber(b.data.attackrange) or 0
		return n1 < n2
	end

	local function go_battle( )
		if #pLay._fightData.aList == 0 or #pLay._fightData.bList == 0 then
			print("pLay._fightData.aList : ".. tostring(#pLay._fightData.aList))
			print("pLay._fightData.bList : ".. tostring(#pLay._fightData.bList))
    		_getResult()
    		return
    	end
		_httpTar = _scene or pLay
    	if _battleLayer then
    		_battleLayer:removeFromParent()
    	end
    	musicManager.stopBackgroundMusic()
    	local teamListLeft = {}
    	local teamListRight = {}
    	local bgList = {"res/image/background/bg_pvp.jpg"}


    	for i,v in ipairs(pLay._fightData.aList) do
    		local animal = {id = v.petId ,_type = ANIMAL_TYPE.PLAYER, data = v, startHp = v.curHp}
	    	teamListLeft[#teamListLeft + 1] = animal
		end
    	table.sort(teamListLeft, _heroSort)
		--[[--敌人的队伍]]
		local team = {}
		for i,v in ipairs(pLay._fightData.bList) do
			local animal = {id = v.petId ,_type = ANIMAL_TYPE.PLAYER, data = v, startHp = v.curHp}
    		team[#team + 1]=animal
		end
    	table.sort( team, _heroSort)
		teamListRight.team = team

		if not _scene then
			_scene = cc.Scene:create()
			cc.Director:getInstance():pushScene(_scene)
		end

		_battleLayer = requires("src/battle/BattleLayer.lua"):create()
		local data = {
			playerList = pLay._selectedHeroList,
			enemyList = pLay._enemyList,
			winInfo = pLay._winInfo,
			nowCount = pLay._count,
			fightData = pLay._fightData,
		}
		local uiPvpRobberyLayer = BattleUINXNLayer:create(data, _battle_type)
		_battleLayer:initWithParams({
			bgList 			= bgList,
			bgm    			= "res/sound/bgm_battle_pvp.mp3",
			battleTime      = 90,
			teamListLeft	= {teamListLeft},
			teamListRight	= {teamListRight},
			battleType 		= _battle_type,
			battleEndCallback = function(params)
				ClientHttp.http_SendFightValidation(_httpTar, function(data)
                	_battleLayer:hideWithoutBg()
            		LayerManager.addShieldLayout()
                	local function _endCall(  )
			    		pLay._fightData = data
			    		go_battle()
				    end
				    local _attackLore = 0
				    local _defendLore = 0
				    if params.result == 1 and pLay._fightData.bKillIndex == 1 then
				    	_attackLore = 1
			    	elseif params.result == 0 and pLay._fightData.aKillIndex == 1 then
			    		_defendLore = 1
				    end

				    local _leftName = ""
				    local _leftLevel = 1
				    local _leftId = 1
				    for k,v in pairs(pLay._selectedHeroList) do
				    	if v.charId == pLay._fightData.aCharId then
				    		_leftName = v.name or ""
				    		_leftId = v.templateId or 1
				    		_leftLevel = v.level or 1
				    		if params.result ~= 1 then
				    			v.result = params.result
				    		end
				    		if _attackLore == 1 then
				    			v.isLore = 1
				    		end
				    		break
				    	end
				    end
				    
				    local _rightName = ""
				    local _rightLevel = 1
				    local _rightId = 1
				    for k,v in pairs(pLay._enemyList) do
				    	if v.charId == pLay._fightData.bCharId then
				    		_rightName = v.name or ""
				    		_rightId = v.templateId or 1
				    		_rightLevel = v.level or 1
				    		if params.result ~= 0 then
				    			v.result = params.result
				    		end
				    		if _defendLore == 1 then
				    			v.isLore = 1
				    		end
				    		break
				    	end
				    end
				    local _info = {
					    result = params.result,
				    	leftId = _leftId,
				    	rightId = _rightId,
				    	leftLevel = _leftLevel,
				    	rightLevel = _rightLevel, 
				    	leftName = _leftName,
				    	rightName = _rightName,
				    	attackLore = _attackLore,
				    	defendLore = _defendLore,
						teamId = data.teamId
				    }
				    createOneFightTips(_scene, _info, _endCall)
				    musicManager.stopBackgroundMusic()
				end, function()
					createFailHttpTipToPop()
                    if pLay then
                		pLay:removeFromParent()
                		pLay = nil
                	end
				end, params )
			end,
		})
		_scene:addChild(_battleLayer)
		_battleLayer:setUILay(uiPvpRobberyLayer)
		_scene:addChild(uiPvpRobberyLayer)
		_battleLayer:start()
	end

	go_battle()
end


function  BangPaiZhanKaiZhan:setIndexBtnCallback(_idx)
	if _idx ==nil then
		return
	end
	self.challengeListData.selfKillIndex = _idx-1
	self:resetIndexBtnPos()
end

function BangPaiZhanKaiZhan:doTouchBegan(target)
	target:setLocalZOrder(3)
	target:setScale(1.08)
end
--_idx是它began的时候的位置
function BangPaiZhanKaiZhan:doTouchMoved(target,touch,_idx)
	-- local target = self.fighterBgTable[self.adjustOrder[tonumber(_idx)]]
	local x,y = target:getPosition()
	target:setScale(1.08)
	local nowPos = touch:getLocation()
	local prePos = touch:getPreviousLocation()
	local diff = cc.pSub(nowPos,prePos)		
	if not (y + diff.y > self.memberPos[1].y) and not (y + diff.y < self.memberPos[#self.challengeListData["aGroup"]].y) then -----如果移到顶部或者移到底部就不能移动
		local _newPosY = y + diff.y
		target:setPosition(x,_newPosY)	
		local _newIndex = math.floor(_newPosY/self.distance)
		local _newPos = math.ceil((10-_newIndex)/2)
		self:setAttackBgNewPos(_idx,_newPos)
	end
end

function BangPaiZhanKaiZhan:doTouchEnded(target)
	target:setLocalZOrder(0)
	target:setScale(1)
	self:resetAttackBgPos()
	self:resetIndexBtnPos()
end

--—_idx是点击之前的位置
function BangPaiZhanKaiZhan:setAttackBgNewPos(_idx,_newPos)
	if _idx == nil or _newPos == nil then
		return
	end
	local _newAdjust = {}
	local _oldPos = 0
	for i=1,#self.adjustOrder do
		_newAdjust[i] = self.adjustOrder[i]
		if tonumber(self.adjustOrder[i])==_idx then
			_oldPos = i
		end
	end
	if _oldPos == 0 or _oldPos==_newPos then
		return
	end
	local _variate = 1
	if _oldPos>_newPos then
		_variate = -1
	elseif _oldPos<_newPos then
		_variate = 1
	else
		return
	end
	for i=_oldPos,_newPos,_variate do
		if i == _newPos then
			_newAdjust[i] = _idx
		else
			local _attackBg = self.attackBgTable[tonumber(self.adjustOrder[i+_variate])]
			_attackBg.posIndex = i
			_attackBg:stopAllActions()
			-- _fightBg:setPosition(self.fighterBgPos[i])
			_attackBg:runAction(cc.MoveTo:create(0.3,cc.p(self.memberPos[i])))
			_newAdjust[i] = self.adjustOrder[i + _variate]
		end
	end
	--给予新的索引
	self.adjustOrder = {}
	self.adjustOrder = _newAdjust
end

function BangPaiZhanKaiZhan:resetAttackBgPos()
	local _newFighterBgTable = {}
	local _newFighterListData = {}
	local _newAdjust = {}
	for i=1,#self.adjustOrder do
		_newFighterBgTable[i] = self.attackBgTable[tonumber(self.adjustOrder[i])]
		_newFighterListData[i] = self.challengeListData["aGroup"][tonumber(self.adjustOrder[i])]
		_newFighterBgTable[i]:stopAllActions()
		_newFighterBgTable[i]:setPosition(self.memberPos[i])
		_newFighterBgTable[i].posIndex = i
		_newAdjust[i] = i
	end
	self.attackBgTable = {}
	self.adjustOrder = {}
	self.adjustOrder = _newAdjust
	self.attackBgTable = _newFighterBgTable
	self.challengeListData["aGroup"] = _newFighterListData
end

function BangPaiZhanKaiZhan:resetIndexBtnPos()
	-- local _isChange = false
	local _selfKillIndex = self.challengeListData.selfKillIndex
	for i=1,#self.adjustOrder do
		local _attackBg = self.attackBgTable[i]
		if _attackBg~=nil and _attackBg:getChildByName("indexBtn") then
			local _indexBtn = _attackBg:getChildByName("indexBtn")
			if _indexBtn.posIndex and tostring(_indexBtn.posIndex) == "Over" then
				if _selfKillIndex ~= i-1 then
					--创建
					_indexBtn:setStateNormal(cc.Sprite:create("res/image/guild/guildWar/guildWar_order" .. i .. ".png"))
					_indexBtn:setStateSelected(cc.Sprite:create("res/image/guild/guildWar/guildWar_order" .. i .. ".png"))
					_indexBtn.posIndex = i
				end
			elseif _selfKillIndex == i-1 and _indexBtn.posIndex and tostring(_indexBtn.posIndex) ~= "Over" then
				_indexBtn:setStateNormal(cc.Sprite:create("res/image/guild/guildWar/guildWar_orderOver.png"))
				_indexBtn:setStateSelected(cc.Sprite:create("res/image/guild/guildWar/guildWar_orderOver.png"))
				_indexBtn.posIndex = "Over"
			elseif _indexBtn.posIndex and tostring(_indexBtn.posIndex)~=tostring(i) then
				_indexBtn:setStateNormal(cc.Sprite:create("res/image/guild/guildWar/guildWar_order" .. i .. ".png"))
				_indexBtn:setStateSelected(cc.Sprite:create("res/image/guild/guildWar/guildWar_order" .. i .. ".png"))
				_indexBtn.posIndex = i
			end
		end
	end
end

function BangPaiZhanKaiZhan:setChallengeListData(data)
	self.challengeListData = {}
	self.challengeListData = data or {}
end

function BangPaiZhanKaiZhan:create(data)
	local _layer = self.new(data)
	return _layer
end

return BangPaiZhanKaiZhan