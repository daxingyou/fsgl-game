--普通切换类型
local BgNormal = class("BgNormal", function ( params )
	local _bg = BattleBackground:_create(params)
	return _bg
end)

function BgNormal:ctor()
	self._bgSp = nil
end

function BgNormal:doCurStep( sParams )
	if self._bgSp then
		self._bgSp:removeFromParent()
		self._bgSp = nil
	end
	local _file = self._bgList[self._curStep]
	if _file then
		self._bgSp = XTHD.createSprite(_file)
		self._bgSp:setContentSize(cc.Director:getInstance():getWinSize())
	else
		self._bgSp = XTHD.createSprite()
		self._bgSp:setContentSize(cc.Director:getInstance():getWinSize())
	end
	self._moveNode:addChild(self._bgSp)

	self:_checkBgEffect(_file)
end


function BgNormal:startGuide( battleLayer, _endCall )
	if self:isGuide() == 1001 then
		self:_doGuideStart1001(battleLayer, _endCall)
	elseif self:isGuide() == 1002 then
		self:_doGuideStart1002(battleLayer, _endCall)
	elseif self:isGuide() == 1004 then
		self:_doGuideStart1004(battleLayer, _endCall)
	elseif self:isGuide() == 1 then
		self:_doGuideStart1(battleLayer, _endCall)
	elseif self:isGuide() == 4 then
		self:_doGuideStart4(battleLayer, _endCall)
	elseif self:isGuide() == 5 then
		self:_doGuideStart5(battleLayer, _endCall)
	elseif self:isGuide() == 10 then
		self:_doGuideStart10(battleLayer, _endCall)
	else --没有引导的时候，步骤一二三顺着来就行
		self:_doEndCall(_endCall)	
	end
end

function BgNormal:_doGuideStart1001( battleLayer, _endCall )	
	cc.Director:getInstance():getScheduler():setTimeScale(1.25)
	local _children = battleLayer._controlLayer:getChildren()
    for k,node in pairs(_children) do
    	if node.isAvatarButton then
	        node:setVisible(false)
	    end
    end
	local winWidth = self._bgWidth
	local winHeight = self._bgHeight

	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _leftAnimals = data.team or {}
	local data = {side = BATTLE_SIDE.RIGHT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _rightAnimals = data.team or {}


	local _moveTime = 2.5
	local _player, _elephant, _hippo, _monkey, _raccoon, _pigHeader, _crocodileHeader
	local _wolf1 = {}
	local _wolf2 = {}
	local _crocodile = {}
	local _scale1 = 0.76
	local _scale2 = 1.33
	battleLayer:setScale(_scale2)

	local function _freshPos( _animal, _lineNum, _posX )
		_animal:setPosition(_posX, battleLayer:_getPosY(_lineNum))
		_animal:setDefualtRootY(battleLayer:_getPosY(_lineNum))
		_animal:setLineNum(_lineNum)
		_animal:setLocalZOrder(10 - _lineNum)
	end

	for k,v in pairs(_rightAnimals) do
		if v:getHeroId() == 320 then
			_pigHeader = v
			_freshPos(v, 5, winWidth*0.5 + 150 + winWidth)
			v:setScale(v:getScaleY()*_scale1)
			v:setFaceDirection(BATTLE_DIRECTION.LEFT)
			v:changeToIdel()
		elseif v:getHeroId () == 305 then
			_wolf1[#_wolf1 + 1] = v
			local _lineNum = #_wolf1 == 1 and 10 or 1
			_freshPos(v, _lineNum, winWidth*0.5 + 250 + winWidth)	
			v:changeToMove()
		elseif v:getHeroId () == 311 then
			_wolf2[#_wolf2 + 1] = v
			local _lineNum = 11 - (#_wolf2 - 1)*4
			_freshPos(v, _lineNum, winWidth*0.5 + 350 + winWidth)	
			v:changeToMove()
		elseif v:getHeroId () == 302 then
			_crocodile[#_crocodile + 1] = v
			local _lineNum = 10 - (#_crocodile - 1)*4
			_freshPos(v, _lineNum, winWidth*0.5 - 240 - (#_crocodile - 1)*40 - winWidth)	
			v:setFaceDirection(BATTLE_DIRECTION.RIGHT)
			v:changeToMove()
		elseif v:getHeroId () == 317 then
			_crocodileHeader = v
			_freshPos(v, 1, winWidth*0.5 - 150 - winWidth)
			v:setFaceDirection(BATTLE_DIRECTION.RIGHT)
			v:changeToMove()
		end
	end

	for k,v in pairs(_leftAnimals) do
		v:setScale(0.52)
		if v:getHeroId() == 3 then
			_monkey = v
			_monkey:setScale(_monkey:getScaleY()*_scale1)
			_freshPos(v, 3, -2000)
		elseif v:getHeroId() == 5 then
			_raccoon = v
			_raccoon:setScale(_raccoon:getScaleY()*_scale1)
			_freshPos(v, 7, -2000)
		elseif v:getHeroId() == 31 then
			_elephant = v
			_elephant:setScale(_elephant:getScaleY()*_scale1)
			_freshPos(v, 5, winWidth*0.5 - 200)
		elseif v:getHeroId() == 40 then
			_hippo = v
			_hippo:setScale(_hippo:getScaleY()*_scale1)
			_freshPos(v, 1, winWidth*0.5 - 350)
		else
			_player = v
			_player:setScale(_player:getScaleY()*_scale1)
			_freshPos(v, 10, winWidth*0.5 - 270)
		end
		v:changeToMove()
	end

	battleLayer:_freshSideZorder(BATTLE_SIDE.RIGHT)
	battleLayer:_freshSideZorder(BATTLE_SIDE.LEFT)

	

	local function _showStory( id, call, _par )
		_par = _par or battleLayer
		battleLayer:pauseBattle()
		_par:addChild(YinDaoScriptLayer:createWithParams({storyId = id, playerId = _player:getHeroId(),callback = function()
			battleLayer:resumeBattle()
			if call then
				call()
			end
		end}), 1)
	end
	local function _doAtkAction( _animal, _action, _targets)
		if _targets then
			_animal:setSelectedTargets({name = _action, targets = _targets})
		end
		_animal:playAnimation(_action)
	end

	local function _startPart3()
		_moveTime = _moveTime
		local _width = winWidth*0.5
		self._moveNode:runAction(cc.Sequence:create(
			cc.MoveBy:create(_moveTime, cc.p(-_width, 0)),
			cc.CallFunc:create(function()
				performWithDelay(_raccoon, function()
					_showStory(30009, function()
						_doAtkAction(_raccoon, BATTLE_ANIMATION_ACTION.ATK1, {_pigHeader})
						performWithDelay(_raccoon, function()
							self:_doEndCall(_endCall)
						end, 1.2)
					end)
				end, 0.5)
			end)
		))
		for k,v in pairs(_crocodile) do
			v:runAction(cc.MoveBy:create(_moveTime, cc.p(-_width, 0)))
		end
		for k,v in pairs(_wolf2) do
			v:runAction(cc.Sequence:create(
				cc.MoveBy:create(_moveTime, cc.p(-_width, 0))
			))
		end
		_pigHeader:runAction(cc.Sequence:create(
			cc.MoveBy:create(_moveTime, cc.p(-_width, 0))
		))

		_monkey:setFaceDirection(BATTLE_DIRECTION.RIGHT)
		_monkey:changeToMove()
		_monkey:runAction(cc.Sequence:create(
			cc.MoveTo:create(_moveTime, cc.p(_hippo:getPositionX() - _width + 120, _monkey:getPositionY())),
			cc.CallFunc:create(function()
				_monkey:changeToIdel()
			end)
		))

		_raccoon:setFaceDirection(BATTLE_DIRECTION.RIGHT)
		_raccoon:changeToMove()
		_raccoon:runAction(cc.Sequence:create(
			cc.MoveTo:create(_moveTime, cc.p(_hippo:getPositionX() - _width + 60, _raccoon:getPositionY())),
			cc.CallFunc:create(function()
				_raccoon:changeToIdel()
			end)
		))

		_elephant:setFaceDirection(BATTLE_DIRECTION.RIGHT)
		_elephant:runAction(cc.MoveBy:create(_moveTime, cc.p(-_width, 0)))
		_player:setFaceDirection(BATTLE_DIRECTION.RIGHT)
		_player:runAction(cc.MoveBy:create(_moveTime, cc.p(-_width, 0)))
		_hippo:setFaceDirection(BATTLE_DIRECTION.RIGHT)
		_hippo:runAction(cc.MoveBy:create(_moveTime, cc.p(-_width, 0)))
	end

	local function _startPart2()
		_moveTime = _moveTime*0.7
		local _width = winWidth*0.5
		self._moveNode:runAction(cc.Sequence:create(
			cc.MoveBy:create(_moveTime, cc.p(_width, 0)),
			cc.DelayTime:create(0.5),
			cc.CallFunc:create(function()
				_showStory(30006, function()
					_crocodileHeader:setTimeScale(0.8)
					_doAtkAction(_crocodileHeader, BATTLE_ANIMATION_ACTION.ATK1, {_hippo})
					_monkey:setTimeScale(1.5)
					_monkey:runAction(cc.Sequence:create(
						cc.DelayTime:create(1.5),
						cc.CallFunc:create(function()
							local _posY = _monkey:getPositionY()
							_monkey:setFaceDirection(BATTLE_DIRECTION.LEFT)
							_monkey:setPosition(_hippo:getPositionX() - 100, _posY + 800)
							for k,v in pairs(_crocodile) do
								v:setTargetable(false)
								v:setHurtable(false)
							end
							_doAtkAction(_monkey, BATTLE_ANIMATION_ACTION.SUPER, {_crocodileHeader})
						end),
						cc.MoveBy:create(0.5666, cc.p(0, -800)),
						cc.DelayTime:create(3.5),
						cc.CallFunc:create(function()
							_monkey:setTimeScale(1.0)
							_elephant:setFaceDirection(BATTLE_DIRECTION.LEFT)
							_player:setFaceDirection(BATTLE_DIRECTION.LEFT)
							_hippo:setFaceDirection(BATTLE_DIRECTION.LEFT)
							_monkey:setFaceDirection(BATTLE_DIRECTION.RIGHT)
							local function _do4()
								for k,v in pairs(_crocodile) do
									v:setTargetable(true)
									v:setHurtable(true)
								end
								_doAtkAction(_raccoon, BATTLE_ANIMATION_ACTION.SUPER, _crocodile)
								performWithDelay(_raccoon, function()
									_showStory(30008, function()
										_startPart3()
									end)
								end, 5)
							end
							local function _do3()
								local _di1 = XTHD.createSprite("res/image/tmpbattle/shadow.png")
								_di1:setPosition(-200, _crocodile[1]:getPositionY())
								XTHD.dispatchEvent({
									name = EVENT_NAME_BATTLE_PLAY_EFFECT,
									data = {node = _di1, zorder = -1 },
								})
								_di1:runAction(cc.Sequence:create(
									cc.MoveTo:create(0.8, cc.p(_crocodile[1]:getPositionX() + 100, _crocodile[1]:getPositionY())),
									cc.RemoveSelf:create(true)
								))
								XTHD.dispatchEvent({
									name = EVENT_NAME_SHAKE_SCREEN,
									data = {delta = 20, time = 0.3},
								})
								local _sp1 = SpineAnimal:createWithParams({resourceId = 311})
								XTHD.dispatchEvent({
									name = EVENT_NAME_BATTLE_PLAY_EFFECT,
									data = {node = _sp1, zorder = -1 },
								})

								_sp1:setScale(0.52)
								_sp1:playAnimation("juqing1", true)
								_sp1:setPosition(-200, winHeight)
								_sp1:runAction(cc.Sequence:create(
									cc.MoveTo:create(0.8, cc.p(_crocodile[1]:getPositionX() + 100, _crocodile[1]:getPositionY())),
									cc.CallFunc:create(function()
										_sp1:playAnimation("juqing2", false)
									end),
									cc.DelayTime:create(0.3),
									cc.CallFunc:create(function()
										_monkey:setFaceDirection(BATTLE_DIRECTION.LEFT)
										for k,v in pairs(_crocodile) do
											v:setFaceDirection(BATTLE_DIRECTION.LEFT)
											performWithDelay(v, function() 
												local _node = XTHD.createSprite("res/fonts/buffWord/silence.png")
												v:addNodeForSlot({node = _node, slotName = "hpBarPoint", zorder = 10})
												performWithDelay(_node, function() 
													_node:removeFromParent()
												end, 1)
											end, 0.3)
										end
									end),
									cc.DelayTime:create(1),
									cc.RemoveSelf:create(true)
								))

								local _di2 = XTHD.createSprite("res/image/tmpbattle/shadow.png")
								_di2:setPosition(-200, _crocodile[2]:getPositionY())
								XTHD.dispatchEvent({
									name = EVENT_NAME_BATTLE_PLAY_EFFECT,
									data = {node = _di2, zorder = -1 },
								})
								_di2:runAction(cc.Sequence:create(
									cc.DelayTime:create(2.5),
									cc.MoveTo:create(1, cc.p(_crocodile[2]:getPositionX() - 50, _crocodile[2]:getPositionY())),
									cc.RemoveSelf:create(true)
								))
								local _sp2 = SpineAnimal:createWithParams({resourceId = 305})
								XTHD.dispatchEvent({
									name = EVENT_NAME_BATTLE_PLAY_EFFECT,
									data = {node = _sp2, zorder = -1 },
								})
								_sp2:setScale(0.52)
								_sp2:playAnimation("juqin1", true)
								_sp2:setPosition(-200, winHeight*0.5)
								_sp2:runAction(cc.Sequence:create(
									cc.DelayTime:create(2.5),
									cc.CallFunc:create(function()
										XTHD.dispatchEvent({
											name = EVENT_NAME_SHAKE_SCREEN,
											data = {delta = 20, time = 0.3},
										})
									end),
									cc.MoveTo:create(1, cc.p(_crocodile[2]:getPositionX() - 50, _crocodile[2]:getPositionY())),
									cc.CallFunc:create(function()
										_sp2:playAnimation("jiqin2", false)

										for k,v in pairs(_crocodile) do
											v:runAction(cc.Spawn:create(
												cc.Sequence:create(
													cc.MoveBy:create(0.1, cc.p(0, 50)),
													cc.MoveBy:create(0.1, cc.p(0, -50))
												),
												cc.MoveBy:create(0.2, cc.p(100, 0))
											))
										end
									end),
									cc.DelayTime:create(0.3),
									cc.CallFunc:create(function()
										_raccoon:playAnimation(BATTLE_ANIMATION_ACTION.WALK, true)
										_raccoon:setPositionX(-200)
										_raccoon:runAction(cc.Sequence:create(
											cc.MoveBy:create(1.5, cc.p(300, 0)),
											cc.CallFunc:create(function()
												_raccoon:changeToIdel()
											end),
											cc.DelayTime:create(0.5),
											cc.CallFunc:create(_do4)
										))
									end),
									cc.DelayTime:create(1),
									cc.RemoveSelf:create(true)
								))
								
							end
							_showStory(30007, _do3)
						end)
					))
				end)
			end)
		))
		for k,v in pairs(_leftAnimals) do
			v:runAction(cc.Sequence:create(
				cc.MoveBy:create(_moveTime, cc.p(_width, 0))
			))
		end
		for k,v in pairs(_wolf1) do
			v:runAction(cc.Sequence:create(
				cc.MoveBy:create(_moveTime, cc.p(_width, 0))
			))
		end
		for k,v in pairs(_wolf2) do
			v:runAction(cc.Sequence:create(
				cc.MoveBy:create(_moveTime, cc.p(_width, 0))
			))
		end
		_pigHeader:runAction(cc.Sequence:create(
			cc.MoveBy:create(_moveTime, cc.p(_width, 0))
		))
		for k,v in pairs(_crocodile) do
			v:changeToMove()
			v:runAction(cc.Sequence:create(
				cc.MoveBy:create(_moveTime, cc.p(winWidth, 0)),
				cc.CallFunc:create(function()
					v:changeToIdel()
				end)
			))
		end
		_crocodileHeader:changeToMove()
		_crocodileHeader:runAction(cc.Sequence:create(
			cc.MoveBy:create(_moveTime, cc.p(winWidth, 0)),
			cc.CallFunc:create(function()
					_crocodileHeader:changeToIdel()
				end)
		))
	end

	local function _startPart1()
		_elephant:changeToMove()
		_elephant:runAction(cc.Sequence:create(
			cc.MoveBy:create(0.5, cc.p(100, 0)),
			cc.DelayTime:create(0.2),
			cc.CallFunc:create(function()
				_doAtkAction(_elephant, BATTLE_ANIMATION_ACTION.SUPER, {_pigHeader})
				performWithDelay(_elephant, function() 
					_pigHeader:removeBuffEffect()
					local function _do()
						performWithDelay(_elephant, function()
							_doAtkAction(_pigHeader, BATTLE_ANIMATION_ACTION.ATTACK)	
						end, 0.5)
						performWithDelay(_elephant, function()
							_doAtkAction(_elephant, BATTLE_ANIMATION_ACTION.ATTACK)
							performWithDelay(_pigHeader, function()
								_pigHeader:playAnimation(BATTLE_ANIMATION_ACTION.DEFENSE)
								_pigHeader:runAction(cc.MoveBy:create(0.1, cc.p(175, 0)))
							end, 0.7)	
						end, 0.8)
						for k,v in pairs(_wolf2) do
							_doAtkAction(v, BATTLE_ANIMATION_ACTION.ATTACK, {_elephant})
						end
						_wolf1[1]:runAction(cc.Sequence:create(
							cc.CallFunc:create(function()
								_doAtkAction(_wolf1[1], BATTLE_ANIMATION_ACTION.ATK1, {_wolf1[1]})
							end),
							cc.DelayTime:create(1.5),
							cc.CallFunc:create(function()
								_wolf1[1]:changeToMove()
							end),
							cc.MoveBy:create(1, cc.p(-200, 0)),
							cc.CallFunc:create(function()
								_doAtkAction(_wolf1[1], BATTLE_ANIMATION_ACTION.ATTACK, {_player})
							end),
							cc.DelayTime:create(1.5),
							cc.CallFunc:create(function()
								_doAtkAction(_wolf1[1], BATTLE_ANIMATION_ACTION.ATTACK, {_player})
							end)
							))
						_wolf1[2]:runAction(cc.Sequence:create(
							cc.CallFunc:create(function()
								_wolf1[2]:changeToMove()
							end),
							cc.MoveBy:create(2, cc.p(-400, 0)),
							cc.CallFunc:create(function()
								_wolf1[2]:changeToIdel()
							end)
							))

						performWithDelay(self, function()
							local function _do2()
								_doAtkAction(_hippo, BATTLE_ANIMATION_ACTION.ATK2, {_wolf1[2]})
								performWithDelay(_hippo, function()
									_doAtkAction(_hippo, BATTLE_ANIMATION_ACTION.ATK3, _leftAnimals)
								end, 2)
								performWithDelay(self, function()
									for k,v in pairs(_wolf2) do
										_doAtkAction(v, BATTLE_ANIMATION_ACTION.ATTACK, {_elephant})
									end
								end, 1.5)
								performWithDelay(self, function()
									_doAtkAction(_elephant, BATTLE_ANIMATION_ACTION.ATK1, {_elephant})
								end, 2.0)
								local _actions
								if _player:getHeroId() == 8 then
									_actions = {
										BATTLE_ANIMATION_ACTION.ATK1,
										BATTLE_ANIMATION_ACTION.ATTACK,
										BATTLE_ANIMATION_ACTION.ATK2
									}
								elseif _player:getHeroId() == 17 then
									_actions = {
										BATTLE_ANIMATION_ACTION.ATK1,
										BATTLE_ANIMATION_ACTION.ATTACK,
										BATTLE_ANIMATION_ACTION.ATK2
									}
								else
									_actions = {
										BATTLE_ANIMATION_ACTION.ATTACK,
										BATTLE_ANIMATION_ACTION.ATTACK,
										BATTLE_ANIMATION_ACTION.ATK1
									}
								end
								_player:changeToMove()
								_player:runAction(cc.Sequence:create(
									cc.MoveBy:create(2, cc.p(200, 0)),
									cc.CallFunc:create(function()
										_player:setTimeScale(2.0)
										_doAtkAction(_player, _actions[1], {_wolf1[1]})
									end),
									cc.DelayTime:create(1.0),
									cc.CallFunc:create(function()
										_doAtkAction(_player, _actions[2], {_wolf1[1]})
									end),
									cc.DelayTime:create(1.0),
									cc.CallFunc:create(function()
										_doAtkAction(_player, _actions[3], {_wolf1[1]})
									end),
									cc.DelayTime:create(1.0),
									cc.CallFunc:create(function()
										_player:setTimeScale(1.0)
									end),
									cc.DelayTime:create(1.0),
									cc.CallFunc:create(function()
										_startPart2()
									end)
								))
							end
							-- _showStory(30005, _do2)
							_do2()
						end, 0.5)
					end
					_showStory(30004, _do)
				end, 1.8666)
			end)
		))
		_pigHeader:changeToMove()
		_pigHeader:runAction(cc.Sequence:create(
			cc.MoveBy:create(0.5, cc.p(-100, 0)),
			cc.CallFunc:create(function()
				_doAtkAction(_pigHeader, BATTLE_ANIMATION_ACTION.ATTACK, {_elephant})
			end)
		))
	end

	local _file = self._bgList[self._curStep + 1]
	local _sp = XTHD.createSprite(_file)
	_sp:setContentSize(cc.Director:getInstance():getWinSize())
	_sp:setPosition(_sp:getContentSize().width, 0)
	self._moveNode:addChild(_sp)

	if _player:getHeroId() == 17 then
		_player:setTimeScale(1.5)
	elseif _player:getHeroId() == 8 then
		_player:setTimeScale(1.55)
	end
	_hippo:setTimeScale(1.55)
	_elephant:setTimeScale(1.4)
	self._moveNode:runAction(cc.Sequence:create(
		cc.MoveBy:create(_moveTime*1.5, cc.p(-winWidth, 0)),
		cc.CallFunc:create(function()
			_player:setTimeScale(1)
			_hippo:setTimeScale(1)
			_elephant:setTimeScale(1)
			for k,v in pairs(_leftAnimals) do
				v:changeToIdel()
			end
			performWithDelay(self, function()
				local function _do()
					local _scaleTime = 1.0
					battleLayer:runAction(cc.ScaleTo:create(_scaleTime, 1.0))
					for k,v in pairs(_leftAnimals) do
						v:runAction(cc.ScaleTo:create(_scaleTime, v:getScaleY()/_scale1))
					end
					_pigHeader:runAction(cc.ScaleTo:create(_scaleTime, _pigHeader:getScaleX()/_scale1, _pigHeader:getScaleY()/_scale1))
					for k,v in pairs(_wolf1) do
						v:runAction(cc.Sequence:create(
							cc.MoveBy:create(_moveTime, cc.p(-winWidth, 0)),
							cc.CallFunc:create(function()
								v:changeToIdel()
							end)
						))
					end
					for k,v in pairs(_wolf2) do
						v:runAction(cc.Sequence:create(
							cc.MoveBy:create(_moveTime, cc.p(-winWidth, 0)),
							cc.CallFunc:create(function()
								v:changeToIdel()
							end)
						))
					end
					performWithDelay(battleLayer, function()
						_showStory(30003, _startPart1)
					end, _moveTime + 0.5)
				end
				_showStory(30002, _do, battleLayer:getParent())
			end, 0.5)
		end)
	))
	_pigHeader:runAction(cc.MoveBy:create(_moveTime*1.5, cc.p(-winWidth, 0)))
	performWithDelay(self, function()
		_showStory(30001, nil, battleLayer:getParent())
	end, _moveTime*0.75)
end

function BgNormal:_doGuideStart1002( battleLayer, _endCall )	
	cc.Director:getInstance():getScheduler():setTimeScale(1)
	local winWidth = self._bgWidth
	local winHeight = self._bgHeight

	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _leftAnimals = data.team or {}
	local data = {side = BATTLE_SIDE.RIGHT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _rightAnimals = data.team or {}

	local _player, _elephant, _hippo, _monkey, _raccoon, _peacock, _horse
	local _pigs1 = {}
	local _peacocks = {}

	local function _freshPos( _animal, _lineNum, _posX )
		_animal:setPosition(_posX, battleLayer:_getPosY(_lineNum))
		_animal:setDefualtRootY(battleLayer:_getPosY(_lineNum))
		_animal:setLineNum(_lineNum)
		_animal:setLocalZOrder(10 - _lineNum)
	end

	for k,v in pairs(_rightAnimals) do
		if v._initYD_Cache then
			v:_initYD_Cache()
		end
		v:changeToIdel()
		v:setScale(0.52)
		v:setFaceDirection(BATTLE_DIRECTION.LEFT)
		if v:getHeroId() == 4 then
			_peacock = v
			_freshPos(v, 5, winWidth*0.5 + 300 + winWidth*0.5)
		elseif v:getHeroId() == 310 then
			_pigs1[#_pigs1 + 1] = v
			local _pN = math.modf((#_pigs1 - 1)/2)
			local _lineNum = _pN == 0 and 1 or 10
			local _px = (#_pigs1-1)%2 == 0 and 120 or 220
			_freshPos(v, _lineNum, winWidth*0.5 + _px + winWidth + (_lineNum < 5 and 50 or 0))
		end
	end

	for k,v in pairs(_leftAnimals) do
		if v._initYD_Cache then
			v:_initYD_Cache()
		end
		v:changeToIdel()
		v:setScale(0.52)
		if v:getHeroId() == 3 then
			_monkey = v
			_freshPos(v, 3, winWidth*0.5 - 150)
		elseif v:getHeroId() == 5 then
			_raccoon = v
			_freshPos(v, 6, winWidth*0.5 - 300)
		elseif v:getHeroId() == 31 then
			_elephant = v
			_freshPos(v, 7, winWidth*0.5 - 100)
		elseif v:getHeroId() == 40 then
			_hippo = v
			_freshPos(v, 1, winWidth*0.5 - 250)
		else
			_player = v
			_freshPos(v, 10, winWidth*0.5 - 200)
		end
	end

	battleLayer:_freshSideZorder(BATTLE_SIDE.RIGHT)
	battleLayer:_freshSideZorder(BATTLE_SIDE.LEFT)
	

	local function _showStory( id, call, _par )
		_par = _par or battleLayer
		battleLayer:pauseBattle()
		_par:addChild(YinDaoScriptLayer:createWithParams({storyId = id, playerId = _player:getHeroId(),callback = function()
			battleLayer:resumeBattle()
			if call then
				call()
			end
		end}), 1)
	end
	local function _doAtkAction( _animal, _action, _targets)
		if _targets then
			_animal:setSelectedTargets({name = _action, targets = _targets})
		end
		_animal:playAnimation(_action)
	end

	do --预先初始化马和其它小孔雀
		for i=1,6 do
			local _tmp = Character:createWithParams({id = gf1_data_peacock.heroid ,_type = ANIMAL_TYPE.MONSTER, monster = clone(gf1_data_peacock)})
			_peacock:getParent():addChild(_tmp)
			_peacocks[#_peacocks + 1] = _tmp
			_rightAnimals[#_rightAnimals + 1] = _tmp
			_tmp:setVisible(false)
		end
	end

	local _file = self._bgList[self._curStep + 1]
	local _sp = XTHD.createSprite(_file)
	_sp:setContentSize(cc.Director:getInstance():getWinSize())
	_sp:setPosition(_sp:getContentSize().width, 0)
	self._moveNode:addChild(_sp)
	 _file = self._bgList[self._curStep + 2]
	local _sp2 = XTHD.createSprite(_file)
	_sp2:setContentSize(cc.Director:getInstance():getWinSize())
	_sp2:setPosition(-_sp2:getContentSize().width, 0)
	self._moveNode:addChild(_sp2)

	local function _setTargetInOut( _effNode, isShow, call )
		local _eff = _effNode:getEffectSpineFromCache("res/spine/effect/004/bian/fs")
		local _pos = _effNode:getSlotPositionInWorld("root")
		_eff:setTimeScale(_effNode:getTimeScale())
		local _dir = _effNode:getFaceDirection() == BATTLE_DIRECTION.RIGHT and 1 or -1
		_eff:setScaleX(_dir*_eff:getScaleX())
		_eff:setPosition(_pos)
		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = _eff, zorder = _effNode:getLocalZOrder()},
		})
		
		_eff:registerSpineEventHandler( function ( event )
			local name = event.eventData.name
			if name == "chuxian" then
				_effNode:setVisible(true)
				if call then
					call()
				end
			elseif name == "xiaoshi" then
				_effNode:setVisible(false)
				if call then
					call()
				end
			end
		end, sp.EventType.ANIMATION_EVENT)
		local _time
		if isShow then
			_effNode:setVisible(false)
			_eff:setAnimation(0, "chuxian", false)
			_time = 0.6666
		else
			_effNode:setVisible(true)
			_eff:setAnimation(0, "xiaoshi", false)
			_time = 0.8333
		end
		performWithDelay(_eff, function()
			_eff:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
			_eff:removeFromParent()
		end, _time)
	end

	local function _pauseAll( animal )
		battleLayer._bg:setAllColor(BATTLE_DIM_COLOR)
        battleLayer:pauseBattle(true)
		for k,v in pairs(_rightAnimals) do
			if v ~= animal then
		        doFuncForAllChild(v, function(child)
					if child.isAnimal then
						child:showDim(true)
						child:setDimCount(child:getDimCount() + 1)
						child:pauseSelf()
					else
						child:pause()
					end
				end)
		    end
	    end
		for k,v in pairs(_leftAnimals) do
			if v ~= animal then
				doFuncForAllChild(v, function(child)
					if child.isAnimal then
						child:showDim(true)
						child:setDimCount(child:getDimCount() + 1)
						child:pauseSelf()
					else
						child:pause()
					end
				end)
			end
		end
	end

	local function _doBianScale( animal, call, needPause)
		animal:setStatus(BATTLE_STATUS.IDLE)
		battleLayer._controlLayer:setVisible(false)
		_pauseAll(animal)
		local _needPause = needPause == nil and false or true
		local _pScale = 1.5
		local _moveTime = 0.2
		local _movePos = cc.p((winWidth*0.5 - animal:getPositionX())*_pScale, -(winHeight*0.5 - animal:getPositionY())*_pScale)
		if animal:getHeroId() == 3 then
			_movePos.y = -1 * _movePos.y
		end
		battleLayer:runAction(cc.Sequence:create(
			cc.Spawn:create(
				cc.ScaleTo:create(_moveTime, _pScale),
				cc.MoveBy:create(_moveTime, _movePos)
			),
			cc.DelayTime:create(0.5),
			cc.CallFunc:create(function()
				_doAtkAction(animal, BATTLE_ANIMATION_ACTION.BIAN)
				animal:setDoOtherAnimationEventCheckFunction(function(event)
					local name = event.eventData.name
					if name == "zhen" then
						battleLayer:resume()
						XTHD.dispatchEvent({
							name = EVENT_NAME_SHAKE_SCREEN,
							data = {delta = 25, time = 1, speed = 0.03},
						})
						performWithDelay(battleLayer, function()
							XTHD.dispatchEvent({
								name = EVENT_NAME_SHAKE_SCREEN,
								data = {delta = 60, time = 0.4, speed = 0.02},
							})
						end, 1.0*10*0.03*2)
					elseif name == "zhenping2" then
						battleLayer:resume()
						XTHD.dispatchEvent({
							name = EVENT_NAME_SHAKE_SCREEN,
							data = {delta = 20, time = 1.5},
						})
					elseif name == "onAtk0Done4" then
						battleLayer:resume()
						XTHD.dispatchEvent({
							name = EVENT_NAME_SHAKE_SCREEN,
							data = {delta = 10, time = 0.8},
						})
					elseif name == "onAtk0Done5" then
						battleLayer:resume()
						XTHD.dispatchEvent({
							name = EVENT_NAME_SHAKE_SCREEN,
							data = {delta = 20, time = 1.4},
						})
					end
				end)
				animal:setDoOtherAnimationCompleteCheckFunction(function(event)
					if event.animation == BATTLE_ANIMATION_ACTION.BIAN then
						animal:setYD_Bian(true)
						battleLayer:runAction(cc.Sequence:create(
							cc.DelayTime:create(0.5),
							cc.Spawn:create(
								cc.ScaleTo:create(_moveTime, 1.0),
								cc.MoveBy:create(_moveTime, cc.pMul(_movePos, -1))
							),
							cc.DelayTime:create(0.5),
							cc.CallFunc:create(function() 
								battleLayer._controlLayer:setVisible(true)
								if call then
									call()
								end
							end)
						))
						if _needPause == true then
							return true
						end
					end
					return false
				end)
			end)
		))	
	end

	local function _startPart5()
		for k,v in pairs(_pigs1) do
			v:setVisible(true)
			v:resumeSelf()
			v:changeToMove()
			v:setTimeScale(2.0)
			v:runAction(cc.Sequence:create(
				cc.MoveBy:create(1.5, cc.p(-winWidth, 0)),
				cc.CallFunc:create(function ()
					v:changeToIdel()
					v:setTimeScale(1.0)
				end)
			))
		end
		_peacock:playAnimation(BATTLE_ANIMATION_ACTION.BIAN_RUN, true)
		_peacock:runAction(cc.Sequence:create(
			cc.MoveBy:create(2, cc.p(-300, 0)),
			cc.CallFunc:create(function ()
				_peacock:changeToIdel()
				for k,v in pairs(_pigs1) do
					v:setPosition(v:getPositionX(), v:getPositionY())
				end
			end),
			cc.DelayTime:create(0.5),
			cc.CallFunc:create(function()
				_horse = Character:createWithParams({id = gf1_data_horse.heroid ,_type = ANIMAL_TYPE.PLAYER, helps = clone(gf1_data_horse)})
				_peacock:getParent():addChild(_horse)
				_freshPos(_horse, 3, -200)
				_leftAnimals[#_leftAnimals + 1] = _horse
				_showStory(30113, function()
					_horse:setTimeScale(3.0)
					_doAtkAction(_horse, BATTLE_ANIMATION_ACTION.SUPER, {_peacock})
					performWithDelay(_horse, function() 
						_showStory(30114, function() 
							if battleLayer._battleEndCallback then
								battleLayer._battleEndCallback()
							end
						end)
					end, 3)
				end)
			end)
		))
	end

	local function _startPart4()
		for i=1, #_peacocks do
			local v = _peacocks[i]
			v:setHpTotal(1500)
			v:setHpNow(1500)
			v:changeToIdel()
			v:setFaceDirection(BATTLE_DIRECTION.LEFT)
			local _x = math.modf((i-1)/3)
			local _y = (i-1)%3
			local _pox = cc.p(_peacock:getPositionX() - 120 - _x*100, _peacock:getPositionY() + 100 - _y*100)
			v:setPosition(_pox)
			if _y ~= 1 then
				v:setPositionX(v:getPositionX() + 40)
			end
			v:setDefualtRootY(_pox.y)
			if _y == 0 then
				v:setLocalZOrder(10 - 8)
			elseif _y == 1 then
				v:setLocalZOrder(10 - 5)
			elseif _y == 2 then
				v:setLocalZOrder(10 - 2)
			end
			_setTargetInOut(v, true)
		end
		_peacock:setHurtable(false)

		performWithDelay(_peacock, function()
			for k,v in pairs(_peacocks) do
				v:setTimeScale(0.7)
				v:setDoOtherAnimationStartCheckFunction(function(event)
					if event.animation == BATTLE_ANIMATION_ACTION.SUPER then
						return true
					elseif event.animation == BATTLE_ANIMATION_ACTION.DEATH then
						v:setTimeScale(1.0)
					end
					return false 
				end)
				_doAtkAction(v, BATTLE_ANIMATION_ACTION.SUPER)
				
			end
			performWithDelay(_peacock, function()
				_showStory(30110, function()

					local function _doNex()
						_monkey:setMp(_monkey:getMpMax())
						XTHD.dispatchEvent({
							name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(_monkey:getHeroId()),
							data = {mpadd = _monkey:getMpMax(), standId = _monkey:getStandId()},
						})
						battleLayer:pauseBattle()
						local data = {standId = _monkey:getStandId()}
						XTHD.dispatchEvent({
							name = EVENT_NAME_BATTLE_AVATAR_BUTTON(_monkey:getHeroId()),
							data = data,
						})
						local button = data.button
			            local _buildPointer = nil
			            _buildPointer = YinDao:create({
			                target 			= button,
			                direction 		= 1,
			                action 			= 1,
			                isButton 		= false,
							isMode 			= 1,
			                hasMask 		= true,
			                wordTips 		= LANGUAGE_KEY_GUIDE_SCENE_TEXT_18,
			                extraCall 		= function ()
				                battleLayer:resumeBattle()
			                	_buildPointer:removeFromParent()
			                	button:setTouchEndedCallback(nil)
								_doAtkAction(_monkey, BATTLE_ANIMATION_ACTION.BIAN_SUPER, _peacocks)
								_monkey:setDoOtherAnimationCompleteCheckFunction(function(event)
									if event.animation == BATTLE_ANIMATION_ACTION.BIAN_SUPER then
										_monkey:changeToIdel()
									end
								end)
								_monkey:setMp(0)
								XTHD.dispatchEvent({
									name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(_monkey:getHeroId()),
									data = {mpadd = -_monkey:getMpMax(), standId = _monkey:getStandId()},
								})
								performWithDelay(self, function()
									_showStory(30111, function()
										_peacock:setHurtable(true)
										_doAtkAction(_peacock, BATTLE_ANIMATION_ACTION.BIAN_SUPER, _leftAnimals)
										_peacock:setDoOtherAnimationCompleteCheckFunction(function(event)
											if event.animation == BATTLE_ANIMATION_ACTION.BIAN_SUPER then
												_peacock:changeToIdel()
											end
										end)
										performWithDelay(_peacock, function()
											_showStory(30112, function()
												_hippo:setTimeScale(2.5)
												_hippo:setMp(_hippo:getMpMax())
												XTHD.dispatchEvent({
													name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(_hippo:getHeroId()),
													data = {mpadd = _hippo:getMpMax(), standId = _hippo:getStandId()},
												})
												battleLayer:pauseBattle()
												local data = {standId = _hippo:getStandId()}
												XTHD.dispatchEvent({
													name = EVENT_NAME_BATTLE_AVATAR_BUTTON(_hippo:getHeroId()),
													data = data,
												})
												local button = data.button
									            local _buildPointer = nil
									            _buildPointer = YinDao:create({
									                target 			= button,
									                direction 		= 1,
									                action 			= 1,
									                isButton 		= false,
													isMode 			= 1,
									                hasMask 		= true,
									                wordTips 		= LANGUAGE_KEY_GUIDE_SCENE_TEXT_18,
									                extraCall 		= function ()
										                battleLayer:resumeBattle()
									                	_buildPointer:removeFromParent()
														_doAtkAction(_hippo, BATTLE_ANIMATION_ACTION.SUPER, _leftAnimals)
														_peacock:showDim(false)
														_peacock:setDimCount(0)
														_peacock:resumeSelf()
														_hippo:setMp(0)
														XTHD.dispatchEvent({
															name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(_hippo:getHeroId()),
															data = {mpadd = -_hippo:getMpMax(), standId = _hippo:getStandId()},
														})
														_player:registerSpineEventHandler( function ( event )
															if event.animation == BATTLE_ANIMATION_ACTION.DEFENSE then 
																_player:playAnimation(BATTLE_ANIMATION_ACTION.DIZZ, true)
															end
														end, sp.EventType.ANIMATION_COMPLETE)
														performWithDelay(self, _startPart5, 4)
									                end,
									                pos = cc.p(50,100)
									            })
												battleLayer:addChild(_buildPointer)
											end)
										end, 0.7)
									end)
								end, 5.0)
			                end,
			                pos = cc.p(50,100)
			            })
						battleLayer:addChild(_buildPointer)
					end
					_doBianScale(_monkey, function()
						_monkey:setDoOtherAnimationCompleteCheckFunction(nil)
						_doNex()
					end)
				end)
			end, 0.5)
		end, 1.0)	
	end

	local function _startPart3()
		_setTargetInOut(_peacock, true)
		performWithDelay(_peacock, function()
			for k,v in pairs(_leftAnimals) do
				v:removeBuffEffect()
				v:changeToIdel()
				v:setFaceDirection(BATTLE_DIRECTION.RIGHT)
			end
		end, 1)
		performWithDelay(_peacock, function()
			_showStory(30107, function()
				_peacock:setDoOtherAnimationStartCheckFunction(function(event)
					if event.animation == BATTLE_ANIMATION_ACTION.SUPER then
						return true
					end
					return false 
				end)
				_peacock:setTimeScale(0.5)
				_doAtkAction(_peacock, BATTLE_ANIMATION_ACTION.SUPER)
				performWithDelay(_peacock, function()
					_showStory(30108, function()
						
						local function _doNex()
							_elephant:setDoOtherAnimationCompleteCheckFunction(nil)
							_peacock:setTimeScale(1.0)
							_elephant:setMp(_elephant:getMpMax())
							XTHD.dispatchEvent({
								name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(_elephant:getHeroId()),
								data = {mpadd = _elephant:getMpMax(), standId = _elephant:getStandId()},
							})
							battleLayer:pauseBattle()
							local data = {standId = _elephant:getStandId()}
							XTHD.dispatchEvent({
								name = EVENT_NAME_BATTLE_AVATAR_BUTTON(_elephant:getHeroId()),
								data = data,
							})
							local button = data.button
				            local _buildPointer = nil
				            _buildPointer = YinDao:create({
				                target 			= button,
				                direction 		= 1,
				                action 			= 1,
				                isButton 		= false,
								isMode 			= 1,
				                hasMask 		= true,
				                wordTips 		= LANGUAGE_KEY_GUIDE_SCENE_TEXT_18,
				                extraCall 		= function ()
				               		_elephant:setDoOtherAnimationEventCheckFunction(function(event)
										local name = event.eventData.name
										if name == "onAtk0Done2" then
											_peacock:setTimeScale(1.0)
											performWithDelay(self, function()
												_peacock:removeBuffEffect()
											end, 3.0)
											performWithDelay(self, function()
												_showStory(30109, function()
													_doBianScale(_peacock, function()
														_peacock:setDoOtherAnimationCompleteCheckFunction(nil)
														_peacock:_removeSelfDim()
														_peacock:playAnimation("yd_fs", false)
														_peacock:setDoOtherAnimationCompleteCheckFunction(function(event)
															if event.animation == "yd_fs" then
																_peacock:changeToIdel()
																_peacock:setDoOtherAnimationCompleteCheckFunction(nil)
																_peacock:setDoOtherAnimationEventCheckFunction(nil)
															end
															return false
														end)
														_peacock:setDoOtherAnimationEventCheckFunction(function(event)
															local name = event.eventData.name
															if name == "fs" then
																_startPart4()
															end
															return false
														end)
													end)		
												end)
											end, 3.5)
										end
										return false
									end)
					                battleLayer:resumeBattle()
				                	_buildPointer:removeFromParent()
									_doAtkAction(_elephant, BATTLE_ANIMATION_ACTION.BIAN_SUPER, {_peacock})
									_elephant:setDoOtherAnimationCompleteCheckFunction(function(event)
										if event.animation == BATTLE_ANIMATION_ACTION.BIAN_SUPER then
											_elephant:changeToIdel()
										end
									end)
									_elephant:setFaceDirection(BATTLE_DIRECTION.RIGHT)
									_elephant:setMp(0)
									XTHD.dispatchEvent({
										name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(_elephant:getHeroId()),
										data = {mpadd = -_elephant:getMpMax(), standId = _elephant:getStandId()},
									})
				                end,
				                pos = cc.p(50,100)
				            })
							battleLayer:addChild(_buildPointer)
						end
						_doBianScale(_elephant, _doNex, true)			
					end)
				end, 0.5)
			end)
		end, 1.2)
	end

	local function _startPart2()
		local _peacock1 = _peacocks[1]
		_peacock1:setLocalZOrder(10 - _raccoon:getLineNum())
		_peacock1:setFaceDirection(BATTLE_DIRECTION.RIGHT)
		_peacock1:setVisible(false)
		
		local _peacock2 = _peacocks[2]
		_peacock2:setLocalZOrder(10 - _hippo:getLineNum())
		_peacock2:setFaceDirection(BATTLE_DIRECTION.LEFT)
		_peacock2:setVisible(false)
		local _moveTime1 = 0.3
		local _length1 = winWidth*0.2
		for k,v in pairs(_leftAnimals) do
			v:runAction(cc.MoveBy:create(_moveTime1, cc.p(_length1, 0)))
		end
		
		self._moveNode:runAction(cc.MoveBy:create(_moveTime1, cc.p(_length1, 0)))

		performWithDelay(_peacock1, function()
			_peacock1:setPosition(_raccoon:getPositionX() - 150, _raccoon:getPositionY())
			_setTargetInOut(_peacock1, true, function()
				_doAtkAction(_peacock1, BATTLE_ANIMATION_ACTION.ATK1, {_raccoon})
				performWithDelay(_peacock1, function()
					_raccoon:playAnimation(BATTLE_ANIMATION_ACTION.DIZZ, true)
				end, 0.8333)
				performWithDelay(_peacock1, function()
					_raccoon:removeBuffEffect()
					_setTargetInOut(_peacock1, false)
				end, 1.5)
			end)
			performWithDelay(_hippo, function()
				_hippo:setFaceDirection(BATTLE_DIRECTION.LEFT)
				local _silenceNode = XTHD.createSprite("res/fonts/buffWord/silence.png")
				_hippo:addNodeForSlot({node = _silenceNode, slotName = "hpBarPoint", zorder = 10})
				performWithDelay(_hippo, function()
					_hippo:setTimeScale(0.5)
					_doAtkAction(_hippo, BATTLE_ANIMATION_ACTION.ATK2, {_peacock1})
					_peacock2:setPosition(_hippo:getPositionX() + 150, _hippo:getPositionY())
					_peacock2:setTimeScale(2.0)
					_setTargetInOut(_peacock2, true, function()
						_doAtkAction(_peacock2, BATTLE_ANIMATION_ACTION.ATK1, {_hippo})
						performWithDelay(_peacock2, function()
							_silenceNode:removeFromParent()
							_hippo:setTimeScale(1.0)
						end, 0.4)
						performWithDelay(_peacock2, function()
							_peacock2:setTimeScale(1.0)
							_setTargetInOut(_peacock2, false, function()
								_hippo:setFaceDirection(BATTLE_DIRECTION.RIGHT)
								_hippo:removeBuffEffect()
								_monkey:setFaceDirection(BATTLE_DIRECTION.LEFT)
								_player:setFaceDirection(BATTLE_DIRECTION.LEFT)
								_elephant:setFaceDirection(BATTLE_DIRECTION.LEFT)
								performWithDelay(self, function()
									self._moveNode:runAction(cc.Sequence:create(
										cc.DelayTime:create(0.5),
										cc.CallFunc:create(function()
											for k,v in pairs(_leftAnimals) do
												v:runAction(cc.MoveBy:create(_moveTime1, cc.p(-_length1, 0)))
											end
										end),
										cc.MoveBy:create(_moveTime1, cc.p(-_length1, 0)),
										cc.DelayTime:create(0.5),
										cc.CallFunc:create(_startPart3)
									))
								end, 0.3)
							end)
						end, 1)
						
					end)
				end, 0.3)
			end, 1.3)
		end, _moveTime1 + 0.5)
	end

	local function _startPart1()
		local _moveTime1 = 1
		local _delayTime1 = 0.5
		local _moveTime2 = 3
		local _length1 = winWidth*0.5
		_peacock:runAction(cc.MoveBy:create(_moveTime1, cc.p(-_length1, 0)))
		self._moveNode:runAction(cc.Sequence:create(
			cc.MoveBy:create(_moveTime1, cc.p(-_length1, 0)),
			cc.DelayTime:create(_delayTime1),
			cc.CallFunc:create(function()
				_peacock:playAnimation(BATTLE_ANIMATION_ACTION.WALK, true)
			end),
			cc.MoveBy:create(_moveTime2, cc.p(_length1, 0)),
			cc.CallFunc:create(function()
				_peacock:playAnimation(BATTLE_ANIMATION_ACTION.IDLE, true)
				performWithDelay(self, function()
					_showStory(30102, function()
						local _moveStandTime = 0.8
						for k,v in pairs(_leftAnimals) do
							v:changeToMove()
							if v:getHeroId() == 3 then
								v:setFaceDirection(BATTLE_DIRECTION.LEFT)
								v:runAction(cc.Sequence:create(
									cc.MoveTo:create(_moveStandTime, cc.p(winWidth*0.5 - 190, v:getDefualtRootY())),
									cc.CallFunc:create(function() 
										v:setFaceDirection(BATTLE_DIRECTION.RIGHT)
										v:changeToIdel()
									end)
								))
							elseif v:getHeroId() == 5 then
								v:setFaceDirection(BATTLE_DIRECTION.LEFT)
								v:runAction(cc.Sequence:create(
									cc.MoveTo:create(_moveStandTime, cc.p(winWidth*0.5 - 400, v:getDefualtRootY())),
									cc.CallFunc:create(function() 
										v:setFaceDirection(BATTLE_DIRECTION.RIGHT)
										v:changeToIdel()
									end)
								))
							elseif v:getHeroId() == 31 then
								v:runAction(cc.Sequence:create(
									cc.MoveTo:create(_moveStandTime, cc.p(winWidth*0.5 - 50, v:getDefualtRootY())),
									cc.CallFunc:create(function() 
										v:setFaceDirection(BATTLE_DIRECTION.RIGHT)
										v:changeToIdel()
									end)
								))
							elseif v:getHeroId() == 40 then
								v:setFaceDirection(BATTLE_DIRECTION.LEFT)
								v:runAction(cc.Sequence:create(
									cc.MoveTo:create(_moveStandTime, cc.p(winWidth*0.5 - 310, v:getDefualtRootY())),
									cc.CallFunc:create(function() 
										v:setFaceDirection(BATTLE_DIRECTION.RIGHT)
										v:changeToIdel()
									end)
								))
							else
								v:setFaceDirection(BATTLE_DIRECTION.LEFT)
								v:runAction(cc.Sequence:create(
									cc.MoveTo:create(_moveStandTime, cc.p(winWidth*0.5 - 270, v:getDefualtRootY())),
									cc.CallFunc:create(function() 
										v:setFaceDirection(BATTLE_DIRECTION.RIGHT)
										v:changeToIdel()
									end)
								))
							end
						end
						performWithDelay(self, function()
							_showStory(30103, function()
								_raccoon:playAnimation("atk0_1", true)
								performWithDelay(self, function()
									_showStory(30104, function()
										_elephant:changeToMove()
										_elephant:runAction(cc.Spawn:create(
											cc.MoveBy:create(0.6, cc.p(140, 0)),
											cc.Sequence:create(
												cc.DelayTime:create(0.4),
												cc.CallFunc:create(function()
													_doAtkAction(_elephant, BATTLE_ANIMATION_ACTION.ATK1, {_elephant})
												end)
											)
										))


										local function _doHuoQiu()
											local _bullet = XTHD.createSprite("res/spine/effect/004/atk2_paodan.png")
											_bullet:setScale(_peacock:getScaleY())
											--起始位置
											local _targetSlot= _peacock:getSlotPositionInWorld("firePoint")
											--目标位置
											local endPos = _monkey:getSlotPositionInWorld("root")
											endPos.y = endPos.y + 60

											local pos_delta = cc.pGetDistance(endPos, _targetSlot)

											local bezier = nil
											if pos_delta < 300 then
												bezier  = {
											        cc.p((endPos.x-_targetSlot.x)/4*1+_targetSlot.x, (endPos.y-_targetSlot.y)/2+_targetSlot.y+100),
													cc.p((endPos.x-_targetSlot.x)/2*1+_targetSlot.x, (endPos.y-_targetSlot.y)/2+_targetSlot.y+50),
													cc.p(endPos.x, endPos.y + 30)
										    	}
											else
												bezier  = {
											        cc.p((endPos.x-_targetSlot.x)/4*1+_targetSlot.x, (endPos.y-_targetSlot.y)/2+_targetSlot.y+100 + 50),
													cc.p((endPos.x-_targetSlot.x)/2*1+_targetSlot.x, (endPos.y-_targetSlot.y)/2+_targetSlot.y+50 + 50),
													cc.p(endPos.x, endPos.y + 30)
										    	}
											end
											_bullet:setPosition(_targetSlot)

											local dt = getDynamicTime(pos_delta, 2000)*1.25;

											local actionBezier = cc.BezierTo:create(dt, bezier)
											XTHD.dispatchEvent({
												name = EVENT_NAME_BATTLE_PLAY_EFFECT,
												data = {node = _bullet,zorder = _peacock:getLocalZOrder()},
											})
											_bullet:runAction(cc.Sequence:create(actionBezier, cc.CallFunc:create(function() 
												local _data = {
													file = "res/spine/effect/004/bz", 
													name = "bz_0", 
													startIndex = 1,
													endIndex = 8,
													perUnit = 0.05,
													isCircle = false
												 }
												local _node = XTHD.createSpriteFrameSp(_data)
												_node:setScale(2)
												_node:setPosition(_bullet:getPositionX() - 10, _bullet:getPositionY())
												XTHD.dispatchEvent({
													name = EVENT_NAME_BATTLE_PLAY_EFFECT,
													data = {node = _node, zorder = _monkey:getLocalZOrder()},
												})	
												_bullet:removeFromParent()
												_monkey:stopAllActions()
												local _py = _monkey:getDefualtRootY() - _monkey:getPositionY()
												_monkey:playAnimation(BATTLE_ANIMATION_ACTION.DEFENSE, false)
												_monkey:setDoOtherAnimationCompleteCheckFunction(function( event )
								                	if event.animation == BATTLE_ANIMATION_ACTION.DEFENSE then
								                		_monkey:playAnimation(BATTLE_ANIMATION_ACTION.DIZZ, true)
								                		performWithDelay(_monkey, function()
								                			_monkey:changeToIdel()
								                		end, 2)
								                		_monkey:setDoOtherAnimationCompleteCheckFunction(nil)
								                		return true
								                	end
								                	return false
								                end)
												_monkey:runAction(cc.MoveBy:create(0.2, cc.p(-250, _py)))
												_monkey:setTimeScale(1.0)
												_peacock:setTimeScale(1.0)
												performWithDelay(self, function()
													_showStory(30106, function()
														performWithDelay(self, function()
															local data = {standId = _raccoon:getStandId()}
															XTHD.dispatchEvent({
																name = EVENT_NAME_BATTLE_AVATAR_BUTTON(_raccoon:getHeroId()),
																data = data,
															})
															local button = data.button
															battleLayer:pauseBattle()
												            local _buildPointer = nil
												            _buildPointer = YinDao:create({
												                target 			= button,
												                direction 		= 1,
												                action 			= 1,
												                isButton 		= false,
        														isMode = 1,
												                hasMask 		= true,
												                wordTips 		= LANGUAGE_KEY_GUIDE_SCENE_TEXT_18,
												                extraCall 		= function ()
												                	_buildPointer:removeFromParent()
												                	battleLayer:resumeBattle()
													                _peacock:setTargetable(false)
													                _peacock:setHurtable(false)												                	_raccoon:setTimeScale(1.8)
												                	_raccoon:setDoOtherAnimationCompleteCheckFunction(function(event)
												                		if event.animation == "atk0_2" then
												                			_raccoon:changeToIdel()
																		end
																		return false
												                	end)
																	_doAtkAction(_raccoon, "atk0_2")
																	_raccoon:setMp(0)
																	_raccoon:setFaceDirection(BATTLE_DIRECTION.RIGHT)
																	button:setTouchEndedCallback(nil)
																	XTHD.dispatchEvent({
																		name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(_raccoon:getHeroId()),
																		data = {mpadd = -_raccoon:getMpMax(), standId = _raccoon:getStandId()},
																	})
																	performWithDelay(_peacock, function()
																		_setTargetInOut(_peacock, false)
																	end, 0.5)
																	
																	performWithDelay(_raccoon, function()
														                _peacock:setTargetable(true)
														                _peacock:setHurtable(true)
													                	_raccoon:setTimeScale(1.0)
																		_startPart2()
																	end, 3.0)
												                end,
												                pos = cc.p(50,100)
												            })
        													battleLayer:addChild(_buildPointer)
															_raccoon:setMp(_raccoon:getMpMax())
															XTHD.dispatchEvent({
																name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(_raccoon:getHeroId()),
																data = {mpadd = _raccoon:getMpMax(), standId = _raccoon:getStandId()},
															})
														end, 0.1)
													end)
												end, 1.0)
											end)))
										end
										
										performWithDelay(self, function()
											_showStory(30105, function()
												_doAtkAction(_peacock, BATTLE_ANIMATION_ACTION.ATK1, {_elephant})
												performWithDelay(_peacock, function()
													local _eff = _peacock:getEffectSpineFromCache("res/spine/effect/004/atk1", 1.0)
													_eff:setAnimation(0, "animation", false)
													_eff:setPosition(_elephant:getSlotPositionInWorld("midPoint"))
													_eff:setScaleX(-1*_eff:getScaleX())
													XTHD.dispatchEvent({
														name = EVENT_NAME_BATTLE_PLAY_EFFECT,
														data = {node = _eff, zorder = _elephant:getLocalZOrder()},
													})	
													performWithDelay(_eff, function()
														_eff:removeFromParent()
													end, 0.4)
													_elephant:playAnimation(BATTLE_ANIMATION_ACTION.DEFENSE, false)
													_elephant:runAction(cc.MoveBy:create(0.2, cc.p(-240, 0)))
									                _elephant:removeBuffEffect()
									                _elephant:setDoOtherAnimationCompleteCheckFunction(function( event )
									                	if event.animation == BATTLE_ANIMATION_ACTION.DEFENSE then
									                		_elephant:playAnimation(BATTLE_ANIMATION_ACTION.DIZZ, true)
									                		performWithDelay(_elephant, function()
									                			_elephant:changeToIdel()
									                		end, 2)
									                		_elephant:setDoOtherAnimationCompleteCheckFunction(nil)
									                		return true
									                	end
									                	return false
									                end)
												end, 1.1)
												_monkey:changeToMove()
												_monkey:runAction(cc.Sequence:create(
													cc.MoveBy:create(0.6, cc.p(120, 0)),
													cc.Spawn:create(
														cc.MoveBy:create(1.2, cc.p(250, 0)),
														cc.Sequence:create(
															cc.EaseOut:create(cc.MoveBy:create(1.2, cc.p(0, 20)), 3),
															cc.MoveBy:create(1.2, cc.p(0, -20))
														),
														cc.Sequence:create(
															cc.DelayTime:create(0.5),
															cc.CallFunc:create(function()
																_monkey:setTimeScale(0.6)
																_doAtkAction(_monkey, BATTLE_ANIMATION_ACTION.ATK2)
															end)
														)
													)
												))
												performWithDelay(_peacock, function()
													_peacock:setTimeScale(3.0)
													_doAtkAction(_peacock, BATTLE_ANIMATION_ACTION.ATK2)
													performWithDelay(self, function()
														_doHuoQiu()
													end, 1.7*0.3333)
												end, 1.3666)
											end)
										end, 0.1)												
									end)
								end, _moveStandTime)
							end)
						end, _moveStandTime + 0.2)
					end)
				end, 0.2)
			end)
		))
		for k,v in pairs(_leftAnimals) do
			v:runAction(cc.Sequence:create(
				cc.MoveBy:create(_moveTime1, cc.p(-_length1, 0)),
				cc.DelayTime:create(_delayTime1),
				cc.MoveBy:create(_moveTime2, cc.p(_length1, 0))
			))
		end
	end
	
	performWithDelay(self, function()
		_showStory(30101, _startPart1)			
	end, 1.0)
end

function BgNormal:_doGuideStart1004( battleLayer, _endCall )
	cc.Director:getInstance():getScheduler():setTimeScale(1)
	local _children = battleLayer._controlLayer:getChildren()
    for k,node in pairs(_children) do
    	if node.isAvatarButton then
	        node:setVisible(false)
	    end
    end
	local winWidth = self._bgWidth
	local winHeight = self._bgHeight

	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _leftAnimals = data.team or {}
	local data = {side = BATTLE_SIDE.RIGHT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _rightAnimals = data.team or {}

	local _player, _fox, _horse, _butterfly, _snake, _peacock
	local _pigs1 = {}
	local _peacocks = {}

	local function _freshPos( _animal, _lineNum, _posX )
		_animal:setPosition(_posX, battleLayer:_getPosY(_lineNum))
		_animal:setDefualtRootY(battleLayer:_getPosY(_lineNum))
		_animal:setLineNum(_lineNum)
		_animal:setLocalZOrder(10 - _lineNum)
	end

	for k,v in pairs(_rightAnimals) do
		if v._initYD_Cache then
			v:_initYD_Cache()
		end
		v:changeToIdel()
		v:setScale(0.52)
		v:setFaceDirection(BATTLE_DIRECTION.LEFT)
		if v:getHeroId() == 4 then
			_peacock = v
			_freshPos(v, 5, winWidth*0.5 + 150)
		elseif v:getHeroId() == 310 then
			_pigs1[#_pigs1 + 1] = v
			local _pN = math.modf((#_pigs1 - 1)/2)
			local _lineNum = _pN == 0 and 1 or 10
			local _px = (#_pigs1-1)%2 == 0 and 270 or 370
			_freshPos(v, _lineNum, winWidth*0.5 + _px + (_lineNum < 5 and 50 or 0))
		end
	end

	for k,v in pairs(_leftAnimals) do
		if v._initYD_Cache then
			v:_initYD_Cache()
		end
		v:changeToIdel()
		v:setScale(0.52)
		v:setVisible(false)
		if v:getHeroId() == 12 then
			_fox = v
			_freshPos(v, 6, winWidth*0.5)
		elseif v:getHeroId() == 27 then
			_butterfly = v
			_freshPos(v, 1, winWidth*0.5 - 300)
		elseif v:getHeroId() == 32 then
			_horse = v
			_freshPos(v, 6, winWidth*0.5 - 400)
		elseif v:getHeroId() == 39 then
			_snake = v
			_freshPos(v, 4, winWidth*0.5 - 220)
		else
			_player = v
			_freshPos(v, 10, winWidth*0.5 - 200)
			_player:playAnimation(BATTLE_ANIMATION_ACTION.DIZZ, true)
			_player:setVisible(true)
		end
	end

	battleLayer:_freshSideZorder(BATTLE_SIDE.RIGHT)
	battleLayer:_freshSideZorder(BATTLE_SIDE.LEFT)
	

	local function _showStory( id, call, _par )
		_par = _par or battleLayer
		battleLayer:pauseBattle()
		_par:addChild(YinDaoScriptLayer:createWithParams({storyId = id, playerId = _player:getHeroId(),callback = function()
			battleLayer:resumeBattle()
			if call then
				call()
			end
		end}), 1)
	end
	local function _doAtkAction( _animal, _action, _targets)
		if _targets then
			_animal:setSelectedTargets({name = _action, targets = _targets})
		end
		_animal:playAnimation(_action)
	end

	local function _startPart3()
		_doAtkAction(_peacock, "yd_tan")
		_peacock:setDoOtherAnimationCompleteCheckFunction(function(event)
			if event.animation == "yd_tan" then
				_peacock:changeToIdel()
			end
			return false
		end)
		_peacock:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.4),
			cc.CallFunc:create(function()
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 30, time = 0.3},
				})
				for k,v in pairs(_leftAnimals) do
					if v == _snake then
						v:runAction(cc.MoveBy:create(0.05, cc.p(80, 0)))
						v:playAnimation(BATTLE_ANIMATION_ACTION.DEFENSE)
					else
						v:runAction(cc.MoveBy:create(0.05, cc.p(-80, 0)))
						v:playAnimation(BATTLE_ANIMATION_ACTION.DEFENSE)
					end
				end
			end),
			cc.DelayTime:create(1),
			cc.CallFunc:create(function()
				_showStory(30210, function()
					for k,v in pairs(_leftAnimals) do
						if v ~= _player then
							v:setTimeScale(0.3)
							v:changeToMove()
							local _pos = cc.p(_peacock:getPositionX() - v:getPositionX(), _peacock:getPositionY() - v:getPositionY())
							v:runAction(cc.MoveBy:create(10, _pos))
						else
							v:setTimeScale(0.5)
							v:setFaceDirection(BATTLE_DIRECTION.LEFT)
							v:changeToMove()
							v:runAction(cc.MoveBy:create(4, cc.p(-winWidth*0.5, 0)))
						end
					end
					performWithDelay(self, function()
						_showStory(30211, function()
							_peacock:setTimeScale(0.4)
							_doAtkAction(_peacock, "yd_atk")
							performWithDelay(self, function()
					            if battleLayer._battleEndCallback then
									battleLayer._battleEndCallback()
								end
						    end, 0.3)
						end)
					end, 1)
				end)
			end)
		))
	end

	local function _setTargetInOut( _effNode, isShow, call )
		_effNode:setVisible(false)
		local _eff = _effNode:getEffectSpineFromCache("res/spine/effect/012/yan")
		local _pos = _effNode:getSlotPositionInWorld("root")
		_eff:setTimeScale(_effNode:getTimeScale())
		local _dir = _effNode:getFaceDirection() == BATTLE_DIRECTION.RIGHT and 1 or -1
		_eff:setScaleX(_dir*_eff:getScaleX())
		_eff:setPosition(_pos)
		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = _eff, zorder = _effNode:getLocalZOrder()},
		})
		_eff:setAnimation(0, "animation", false)
		_eff:registerSpineEventHandler( function ( event )
			local name = event.eventData.name
			if name == "chuxian" then
				if isShow then
					_effNode:setVisible(true)
				end
				if call then
					call()
				end
			end
		end, sp.EventType.ANIMATION_EVENT)

		performWithDelay(_eff, function()
			_eff:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
			_eff:removeFromParent()
		end, 0.8)
	end

	local function _startPart2()
		local function _doNext()
			_showStory(30206, function()
				_peacock:setDoOtherAnimationCompleteCheckFunction(function( event )
					if event.animation == BATTLE_ANIMATION_ACTION.BIAN_DEFENSE then
						_peacock:playAnimation(BATTLE_ANIMATION_ACTION.BIAN_DIZZ, true)
						return true
					end
					return false
				end)
				_fox:setTimeScale(0.6)
				_doAtkAction(_fox, BATTLE_ANIMATION_ACTION.SUPER, {_peacock})
				_doAtkAction(_horse, BATTLE_ANIMATION_ACTION.ATK1, {_peacock})
				performWithDelay(_horse, function()
					_doAtkAction(_horse, BATTLE_ANIMATION_ACTION.ATK2, {_peacock})
				end, 1.6)
				_doAtkAction(_butterfly, BATTLE_ANIMATION_ACTION.ATK1, {_peacock})
				performWithDelay(_butterfly, function()
					_doAtkAction(_butterfly, BATTLE_ANIMATION_ACTION.ATTACK, {_peacock})
				end, 1.8666)
				_snake:changeToMove()
				doFuncForAllChild(_snake, function(child)
					child:setOpacity(255*0.5)
				end)
				_snake:setTimeScale(2.0)
				_snake:runAction(cc.Spawn:create(
					cc.Sequence:create(
						cc.MoveBy:create(1, cc.p(_peacock:getPositionX() + 200 - _snake:getPositionX(), 0)),
						cc.CallFunc:create(function()
							doFuncForAllChild(_snake, function(child)
								child:setOpacity(255)
							end)
							_snake:setFaceDirection(BATTLE_DIRECTION.LEFT)
							_doAtkAction(_snake, BATTLE_ANIMATION_ACTION.ATTACK, {_peacock})
						end),
						cc.DelayTime:create(1),
						cc.CallFunc:create(function()
							_doAtkAction(_snake, "atk4", {_peacock})
						end),
						cc.DelayTime:create(1),
						cc.CallFunc:create(function()
							_snake:setTimeScale(1.0)
							_peacock:runAction(cc.MoveBy:create(0.5, cc.p(0, 120)))
						end),
						cc.DelayTime:create(0.5),
						cc.CallFunc:create(function()
							_fox:setTimeScale(1.0)
							_showStory(30207, function()
								performWithDelay(_peacock, function()
									_peacock:changeToIdel()
									_peacock:runAction(cc.Sequence:create(
										cc.EaseExponentialIn:create(cc.MoveBy:create(0.5,cc.p(0,-120))),
										cc.CallFunc:create(function()
											_showStory(30208, function()
												_horse:changeToMove()
												_horse:runAction(cc.Sequence:create(
													cc.MoveBy:create(0.5, cc.p(200, 0)),
													cc.CallFunc:create(function()
														_horse:changeToIdel()
													end)
												))
												_butterfly:changeToMove()
												_butterfly:runAction(cc.Sequence:create(
													cc.MoveBy:create(0.5, cc.p(200, 0)),
													cc.CallFunc:create(function()
														_butterfly:changeToIdel()
													end)
												))
												performWithDelay(self, function()
													_peacock:setDoOtherAnimationCompleteCheckFunction(nil)
													_showStory(30209, _startPart3)
												end, 0.6)
											end)
										end)
									))
								end, 4)
							end)
						end)
					),
					cc.Sequence:create(
						cc.DelayTime:create(0.5),
						cc.CallFunc:create(function()
							local _snake1 = Character:createWithParams({id = gf1_data_snake.heroid ,_type = ANIMAL_TYPE.PLAYER, helps = clone(gf1_data_snake)})
							_snake:getParent():addChild(_snake1)
							doFuncForAllChild(_snake1, function(child)
								child:setOpacity(255*0.7)
							end)
							_snake1:setTimeScale(2)
							_snake1:setFaceDirection(BATTLE_DIRECTION.RIGHT)
							_freshPos(_snake1, 4, _peacock:getPositionX() - 100)
							_doAtkAction(_snake1, BATTLE_ANIMATION_ACTION.ATK2, {_peacock})
							performWithDelay(_snake1, function()
								_snake1:setVisible(false)
							end, 1)
							performWithDelay(_snake1, function()
								_snake1:removeFromParent()
							end, 10)
						end)
					)
				))
			end)
		end
		_freshPos(_fox, 6, _peacock:getPositionX() - 100)
		_fox:setTimeScale(2)
		_setTargetInOut(_fox, true, function()
			_doAtkAction(_fox, BATTLE_ANIMATION_ACTION.ATTACK, {_peacock})
			_fox:runAction(cc.Sequence:create(
				cc.DelayTime:create(1.2333*0.5),
				cc.MoveBy:create(0.08, cc.p(-80, 0)),
				cc.CallFunc:create(function()
					_doAtkAction(_fox, BATTLE_ANIMATION_ACTION.ATK1, {_peacock})
				end),
				cc.DelayTime:create(3*0.5),
				cc.CallFunc:create(function()
					_setTargetInOut(_fox, false, function()
						performWithDelay(_fox, function()
							_fox:setTimeScale(1.0)
							_fox:setPositionX(winWidth*0.5 - 100)
							_setTargetInOut(_fox, true, function()
								performWithDelay(_fox, _doNext, 0.5)
							end)
						end, 1)
					end)
				end)
			))
		end)

		local function _createOneFox()
			local _fox1 = Character:createWithParams({id = gf1_data_fox.heroid ,_type = ANIMAL_TYPE.PLAYER, helps = clone(gf1_data_fox)})
			_fox:getParent():addChild(_fox1)
			_fox1:changeToIdel()
			_fox1:setFaceDirection(BATTLE_DIRECTION.LEFT)
			_fox1:setTimeScale(2)
			_freshPos(_fox1, 4, _peacock:getPositionX() + 150)

			_setTargetInOut(_fox1, true, function()
				_doAtkAction(_fox1, BATTLE_ANIMATION_ACTION.ATTACK, {_peacock})
				_fox1:runAction(cc.Sequence:create(
					cc.DelayTime:create(1.2333*0.5),
					cc.MoveBy:create(0.08, cc.p(80, 0)),
					cc.CallFunc:create(function()
						_doAtkAction(_fox1, BATTLE_ANIMATION_ACTION.ATK1, {_peacock})
					end),
					cc.DelayTime:create(3*0.25),
					cc.CallFunc:create(function()
						_peacock:playAnimation(BATTLE_ANIMATION_ACTION.BIAN_DIZZ, true)
					end),
					cc.DelayTime:create(3*0.25),
					cc.CallFunc:create(function()
						_setTargetInOut(_fox1, false, function()
							_fox1:removeFromParent()
						end)
					end)
				))
			end)
		end

		performWithDelay(self, _createOneFox, 0.8)
	end

	local function _startPart1()
		_doAtkAction(_horse, BATTLE_ANIMATION_ACTION.SUPER)
		performWithDelay(_horse, function()
			_horse:pauseSelf()
			_horse:changeToIdel()
		end, 1.15)
		_peacock:setDoOtherAnimationCompleteCheckFunction(function( event )
			if event.animation == "yd_tan" or event.animation == "yd_atk" then
				_peacock:changeToIdel()
			end
			return false
		end)
		performWithDelay(_peacock, function()
			_doAtkAction(_peacock, "yd_atk")
			_peacock:_doStart_Atk2(50)
			_peacock:_doStart_Atk2(0)
			_peacock:_doStart_Atk2(-50)
			local _paodans = {}
			performWithDelay(_peacock, function()
				local _skillData = _peacock:getSkillByAction(_peacock:getNowAniName())
				_paodans[#_paodans + 1] = _peacock:_doEvent_Atk2(_skillData, {_horse}, 50)
				_paodans[#_paodans + 1] = _peacock:_doEvent_Atk2(_skillData, {_horse}, 0)
				_paodans[#_paodans + 1] = _peacock:_doEvent_Atk2(_skillData, {_horse}, -50)
			end, 1.7)

			performWithDelay(_snake, function()
				_snake:setVisible(true)
				local _pos = cc.p(winWidth*0.5, -winHeight*0.25)
				_snake:setTimeScale(2.5)
				_snake:setPosition(_snake:getPositionX() - _pos.x, _snake:getPositionY() - _pos.y)
				_doAtkAction(_snake, BATTLE_ANIMATION_ACTION.SUPER)
				_snake:runAction(cc.Sequence:create(
					cc.MoveBy:create(0.5, _pos),
					cc.DelayTime:create(0.3),
					cc.CallFunc:create(function()
						XTHD.dispatchEvent({
							name = EVENT_NAME_SHAKE_SCREEN,
							data = {delta = 30, time = 0.3},
						})
						_snake:setTimeScale(1.0)
						for k,v in pairs(_paodans) do
							XTHD.setGray(v, true)
							v:stopAllActions()
							v:runAction(cc.Sequence:create(
								cc.DelayTime:create(1),
								cc.MoveBy:create(0.05, cc.p(0, -100)),
								cc.FadeOut:create(0.1),
								cc.RemoveSelf:create(true)
							))
						end
					end),
					cc.DelayTime:create(1.0),
					cc.CallFunc:create(function()
						_butterfly:setVisible(true)
						_pos = cc.p(0, -winHeight)
						
						_butterfly:setPositionY(_butterfly:getPositionY() - _pos.y)
						_doAtkAction(_butterfly, BATTLE_ANIMATION_ACTION.ATK2, _rightAnimals)
						_butterfly:setDoOtherAnimationCompleteCheckFunction(function(event)
							if event.animation == BATTLE_ANIMATION_ACTION.ATK2 then
								_butterfly:playAnimation("fei", true)
								local _sp = XTHD.createSprite("res/spine/effect/027/bg.png")
								_sp:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
								_sp:setScale(2)
								_sp:setPosition(_butterfly:getPositionX(), _butterfly:getPositionY() + _pos.y)
								battleLayer._animalLayer:addChild(_sp, -1)
								_sp:setOpacity(0)

								local _sp2 = XTHD.createSprite("res/spine/effect/027/hg.png")
								_sp2:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
								_sp2:setPosition(_butterfly:getPositionX(), _butterfly:getPositionY() + _pos.y)
								battleLayer._animalLayer:addChild(_sp2, _butterfly:getLocalZOrder())
								_sp2:setScale(2)
								_sp2:setOpacity(0)
								_sp:runAction(cc.FadeTo:create(0.3, 255))
								_sp2:runAction(cc.FadeTo:create(0.3, 255))
								_butterfly:runAction(cc.Sequence:create(
									cc.MoveBy:create(2.5, _pos),
									cc.DelayTime:create(0.5),
									cc.CallFunc:create(function()	
										_butterfly:setDoOtherAnimationCompleteCheckFunction(nil)
										_butterfly:changeToIdel()

										_sp:runAction(cc.Sequence:create(
											cc.FadeTo:create(0.3, 0),
											cc.RemoveSelf:create(true)
										))
										_sp2:runAction(cc.Sequence:create(
											cc.FadeTo:create(0.3, 0),
											cc.RemoveSelf:create(true)
										))
									end),
									cc.DelayTime:create(0.5),
									cc.CallFunc:create(function()	
										_showStory(30204, function()
											_peacock:setTimeScale(2.0)
											_doAtkAction(_peacock, "yd_tan")
											_peacock:setDoOtherAnimationEventCheckFunction(function(event)
												local name = event.eventData.name
												if name == "tan" then
													_peacock:setImmuneControl(true)
													_peacock:setTimeScale(1.0)
													local _effs = _peacock:getBuffNodesById(95)
													if _effs and _effs[1] then
														_effs[1]:removeAllChildren()
														_effs[1]:runAction(cc.Sequence:create(
															cc.Spawn:create(
																cc.FadeOut:create(0.5),
																cc.ScaleTo:create(0.5, 3)
															),
															cc.CallFunc:create(function()
																_peacock:removeBuffEffect()
															end)
														))
													end
													XTHD.dispatchEvent({
														name = EVENT_NAME_SHAKE_SCREEN,
														data = {delta = 20, time = 0.2},
													})
												end
												return false
											end)
											performWithDelay(_peacock, function()
												_showStory(30205, _startPart2)
											end, 1.5)
										end)
									end)
								))
								return true
							end
							return false
						end)
					end)
				))
			end, 1.3)
		end, 0.3)
	end

	_peacock:setYD_Bian(true)
	_peacock:changeToIdel()
	_peacock:showWolrdEff()
	_horse:setVisible(true)
	_horse:setPositionX(_horse:getPositionX() - winWidth*0.25)
	_horse:changeToMove()
	_horse:runAction(cc.Sequence:create(
		cc.MoveBy:create(1.0, cc.p(winWidth*0.25, 0)),
		cc.CallFunc:create(function()
			_horse:playAnimation(BATTLE_ANIMATION_ACTION.WIN, true)
		end),
		cc.DelayTime:create(1.5),
		cc.CallFunc:create(function()
			_showStory(30201, function()
				for k,v in pairs(_pigs1) do
					v:changeToMove()
					v:runAction(cc.MoveBy:create(0.5, cc.p(-80, 0)))
				end
				performWithDelay(_peacock, function()
					_showStory(30202, function()
						for k,v in pairs(_pigs1) do
							v:runAction(cc.Sequence:create(
								cc.MoveBy:create(0.25, cc.p(80, 0)),
								cc.CallFunc:create(function()
									v:changeToIdel()
								end)
							))
						end
						performWithDelay(_peacock, function()
							_showStory(30203, _startPart1)
						end, 0.6)
					end)
				end, 0.5)
			end)
		end)
	))

end

function BgNormal:_doGuideStart1( battleLayer, _endCall )

	local winWidth = self._bgWidth
	local winHeight = self._bgHeight

	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _leftAnimals = data.team or {}
	local data = {side = BATTLE_SIDE.RIGHT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _rightAnimals = data.team or {}

	local _file = self._bgList[self._curStep + 1] or self._bgList[self._curStep]
	local _bg = XTHD.createSprite(_file)
	local _moveWidth = _bg:getContentSize().width
	_bg:setContentSize(cc.Director:getInstance():getWinSize())
	_bg:setPositionX(_moveWidth)
	self._moveNode:addChild(_bg)

	local _moveTime = 2.5
	for k,v in pairs(_leftAnimals) do
		v:changeToMove()
		v:runAction(cc.Sequence:create(
			cc.MoveBy:create(_moveTime, cc.p(winWidth*0.5 + 50, 0)),
			cc.CallFunc:create(function()
				v:changeToIdel()
			end)
		))
	end

	performWithDelay(self, function()
		battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20010, callback = function() 
			_moveTime = 3.5
	    	for k,v in pairs(_leftAnimals) do
				v:changeToMove()
				performWithDelay(self, function()
					v:changeToIdel()
				end, _moveTime)
			end
			local _count = 1
			local function _createSpeak( animal )
				local pointNode = animal:getNodeForSlot( "hpBarPoint" )
				local dialog, dialogLabel = XTHD.createDialogPopGuide(LANGUAGE_KEY_GUIDE_SCENE_TEXT_20[_count])
		    	_count = _count + 1
		    	_count = _count > #LANGUAGE_KEY_GUIDE_SCENE_TEXT_20 and 1 or _count
		    	dialogLabel:setScaleX(-math.abs(dialogLabel:getScaleX()))
				pointNode:addChild(dialog,1)
			    performWithDelay(dialog, function()
			    	dialog:removeFromParent()
			    end, 1)
			end

			for k,v in pairs(_rightAnimals) do
				v:playAnimation(BATTLE_ANIMATION_ACTION.WIN, true)
				v:setPositionX(v:getPositionX() - winWidth*0.5 - 50 + _moveWidth)
				local _time = math.random(1, 10)/10
				performWithDelay(v, function()
			    	_createSpeak(v)
			    end, _moveTime + _time)
			    v:runAction(cc.MoveBy:create(_moveTime, cc.p(-_moveWidth, 0)))
			end
			self._moveNode:runAction(cc.Sequence:create(
				cc.MoveBy:create(_moveTime, cc.p(-_moveWidth, 0)),
				cc.DelayTime:create(1),
				cc.CallFunc:create(function()
					battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20011, callback = function() 
				    	
				    	local _huli, _panda
				    	for k,v in pairs(_leftAnimals) do
							if v:getHeroId() == 12 then
								_huli = v 
							elseif v:getHeroId() == 1 then
								_panda = v
							end
						end
						if not _huli or not _panda then
							self:_doEndCall(_endCall)
							return
						end
						_panda:playAnimation(BATTLE_ANIMATION_ACTION.WIN)
						_huli:setSelectedTargets({name = BATTLE_ANIMATION_ACTION.ATK1 , targets = _rightAnimals})
						_huli:playAnimation(BATTLE_ANIMATION_ACTION.ATK1)
						performWithDelay(self, function()
							battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20012, callback = function() 
								self:_doEndCall(_endCall)
							end}) , 1)
						end,3.0)
					end}) , 1)
				end)
			))
		end}) , 1)
	end, _moveTime + 1)
end

function BgNormal:_doGuideStart4( battleLayer, _endCall )

	local winWidth = self._bgWidth
	local winHeight = self._bgHeight

	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _leftAnimals = data.team or {}
	local data = {side = BATTLE_SIDE.RIGHT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _rightAnimals = data.team or {}

	local _moveTime = 2.5
	for k,v in pairs(_leftAnimals) do
		v:changeToMove()
		v:runAction(cc.Sequence:create(
			cc.MoveBy:create(_moveTime, cc.p(winWidth*0.5 + 50, 0)),
			cc.CallFunc:create(function()
				v:changeToIdel()
			end)
		))
	end

	for k,v in pairs(_rightAnimals) do
		v:playAnimation(BATTLE_ANIMATION_ACTION.WIN, true)
		v:setPositionX(v:getPositionX() - winWidth*0.5 - 50)
	end

	performWithDelay(self, function()
		battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20040, callback = function() 
			local _huli, _eyu
	    	for k,v in pairs(_leftAnimals) do
				if v:getHeroId() == 12 then
					_huli = v
					break
				end
			end
			for k,v in pairs(_rightAnimals) do
				if v:getHeroId() == 317 then
					_eyu = v
					table.remove(_rightAnimals, k)
					break
				end
			end
			if not _huli or not _eyu then
				self:_doEndCall(_endCall)
				return
			end

			_huli:setSelectedTargets({name = BATTLE_ANIMATION_ACTION.ATK1 , targets = _rightAnimals})
			_huli:playAnimation(BATTLE_ANIMATION_ACTION.ATK1)
			performWithDelay(self, function()
				_eyu:playAnimation("idle2", true)
				battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20041, callback = function() 
					_eyu:playAnimation("run2", true)
					_eyu:setFaceDirection(BATTLE_DIRECTION.RIGHT)
					_eyu:runAction(cc.Sequence:create(
						cc.MoveBy:create(2.5, cc.p(winWidth, 0))
					))
					self:_doEndCall(_endCall)
				end}) , 1)
			end,3.0)
		end}) , 1)
	end, _moveTime + 1)
end

function BgNormal:_doGuideStart5( battleLayer, _endCall )

	local winWidth = self._bgWidth
	local winHeight = self._bgHeight

	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _leftAnimals = data.team or {}
	local data = {side = BATTLE_SIDE.RIGHT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _rightAnimals = data.team or {}

	local _moveTime = 2.5
	for k,v in pairs(_leftAnimals) do
		v:changeToMove()
		v:runAction(cc.Sequence:create(
			cc.MoveBy:create(_moveTime, cc.p(winWidth*0.5 + 50, 0)),
			cc.CallFunc:create(function()
				v:changeToIdel()
			end)
		))
	end

	for k,v in pairs(_rightAnimals) do
		v:playAnimation(BATTLE_ANIMATION_ACTION.WIN, true)
		v:setPositionX(v:getPositionX() - winWidth*0.5 - 50)
	end

	performWithDelay(self, function()
		battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20050, callback = function() 
	    	local _huli
	    	for k,v in pairs(_leftAnimals) do
				if v:getHeroId() == 12 then
					_huli = v
					break
				end
			end
	    	local _laoshu, _eyu
			for k,v in pairs(_rightAnimals) do
				if v:getHeroId() == 30 then
					_laoshu = v
				elseif v:getHeroId() == 317 then
					_eyu = v
				end
			end
			if not _laoshu or not _eyu or not _huli then
				self:_doEndCall(_endCall)
				return
			end
			_laoshu:setSelectedTargets({name = BATTLE_ANIMATION_ACTION.ATK2 , targets = {_huli}})
			_laoshu:playAnimation(BATTLE_ANIMATION_ACTION.ATK2)
			performWithDelay(self, function()
				battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20051, callback = function() 
					_huli:setSelectedTargets({name = BATTLE_ANIMATION_ACTION.SUPER , targets = {_laoshu}})
					_huli:playAnimation(BATTLE_ANIMATION_ACTION.SUPER)
					performWithDelay(self, function()
						for k,v in pairs(_rightAnimals) do
							if v:getHeroId() == 317 then
								table.remove(_rightAnimals, k)
								break
							end
						end
						_eyu:playAnimation("run2", true)
						_eyu:setFaceDirection(BATTLE_DIRECTION.RIGHT)
						_eyu:runAction(cc.Sequence:create(
							cc.MoveBy:create(3, cc.p(winWidth*0.6, 0)),
							cc.CallFunc:create(function()
								self:_doEndCall(_endCall)
							end)
						))
						local pointNode = _eyu:getNodeForSlot( "hpBarPoint" )
						local dialog, dialogLabel = XTHD.createDialogPopGuide(LANGUAGE_KEY_GUIDE_SCENE_TEXT_23)
						pointNode:addChild(dialog,1)
					end, 5.0)
				end}) , 1)
			end,3.0)
		end}) , 1)
	end, _moveTime + 1)
end

function BgNormal:_doGuideStart10( battleLayer, _endCall )

	local winWidth = self._bgWidth
	local winHeight = self._bgHeight

	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _leftAnimals = data.team or {}
	local data = {side = BATTLE_SIDE.RIGHT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _rightAnimals = data.team or {}

	local _file = self._bgList[self._curStep + 1] or self._bgList[self._curStep]
	local _bg = XTHD.createSprite(_file)
	local _moveWidth = _bg:getContentSize().width
	_bg:setContentSize(cc.Director:getInstance():getWinSize())
	_bg:setPositionX(_moveWidth)
	self._moveNode:addChild(_bg)


	local _panda, _crane
	local _moveTime = 2.5
	for k,v in pairs(_leftAnimals) do
		v:changeToMove()
		if v:getHeroId() == 1 then
			_panda = v
		elseif v:getHeroId() == 7 then
			_crane = v
		end
		v:runAction(cc.Sequence:create(
			cc.MoveBy:create(_moveTime, cc.p(winWidth*0.5 + 50, 0)),
			cc.CallFunc:create(function()
				v:changeToIdel()
			end)
		))
	end

	local _scale = 0.56
	local _aniData = {id = 12 ,_type = ANIMAL_TYPE.PLAYER , helps = guide_data_fox}
	local _fox = sp.SkeletonAnimation:createWithBinaryFile("res/spine/012.skel", "res/spine/012.atlas", 1.0)
	_fox:setPosition(_panda:getPositionX() + 70, _crane:getPositionY())
	_panda:getParent():addChild(_fox)
	_fox:setScale(_scale)
	_fox:setAnimation(0, BATTLE_ANIMATION_ACTION.RUN, true)
	_fox:runAction(cc.Sequence:create(
		cc.MoveBy:create(_moveTime, cc.p(winWidth*0.5 + 50, 0)),
		cc.CallFunc:create(function()
			_fox:setAnimation(0, BATTLE_ANIMATION_ACTION.IDLE, true)
			_fox:setScaleX(-1*_scale)
		end)
	))

	performWithDelay(self, function()
		battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20100, callback = function() 
			_fox:setAnimation(0, BATTLE_ANIMATION_ACTION.RUN, true)
			_fox:runAction(cc.Sequence:create(
				cc.MoveBy:create(_moveTime, cc.p(-winWidth*0.5 + 50, 0)),
				cc.CallFunc:create(function()
					_fox:removeFromParent()
					_fox = nil
				end)
			))
			_panda:setFaceDirection(BATTLE_DIRECTION.LEFT)
			performWithDelay(self, function()
				battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20101, callback = function() 
					_panda:setFaceDirection(BATTLE_DIRECTION.RIGHT)
					_moveTime = 3.5
			    	for k,v in pairs(_leftAnimals) do
						v:changeToMove()
						performWithDelay(self, function()
							v:changeToIdel()
						end, _moveTime)
					end

					for k,v in pairs(_rightAnimals) do
						v:playAnimation(BATTLE_ANIMATION_ACTION.WIN, true)
						v:setPositionX(v:getPositionX() - winWidth*0.5 - 50 + _moveWidth)
					    v:runAction(cc.MoveBy:create(_moveTime, cc.p(-_moveWidth, 0)))
					end
					self._moveNode:runAction(cc.Sequence:create(
						cc.MoveBy:create(_moveTime, cc.p(-_moveWidth, 0)),
						cc.DelayTime:create(1),
						cc.CallFunc:create(function()
							self:_doEndCall(_endCall)
						end)
					))
				end}) , 1)
			end, _moveTime - 1)
		end}) , 1)
	end, _moveTime + 1)
end


--------------------------------切换波次引导------------------------------


function BgNormal:startFightNext( battleLayer, _endCall )
	if self:isGuide() == 8 then
		self:_doFightNext8(battleLayer, _endCall)
	else --没有引导的时候，步骤一二三顺着来就行
		self:_doEndCall(_endCall)	
	end
end

function BgNormal:_doFightNext8( battleLayer, _endCall )
	local winWidth = self._bgWidth
	local winHeight = self._bgHeight

	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _leftAnimals = data.team or {}
	local data = {side = BATTLE_SIDE.RIGHT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _rightAnimals = data.team or {}

	local _bossAnimal
	for k,v in pairs(_rightAnimals) do
		if v then
			_bossAnimal = v
			break
		end
	end
	if not _bossAnimal then
		self:_doEndCall(_endCall)
		return
	end
	_bossAnimal:playAnimation("chuxian1", true)

	local _sayAni
	local _moveTime = 2.5
	for k,v in pairs(_leftAnimals) do
		v:runAction(cc.Sequence:create(
			cc.MoveBy:create(_moveTime, cc.p(winWidth*0.5,0)),
			cc.CallFunc:create(function()
				v:changeToIdel()
			end)
		))
		if k == 1 then
			_sayAni = v
		end
	end


	performWithDelay(_sayAni, function ()
		local _node = _sayAni:getNodeForSlot("hpBarPoint")
		local dialog = XTHD.createDialogPopGuide(LANGUAGE_BATTLE_STORY1)
		_node:addChild(dialog, 10)
		dialog:setPosition(40, 25)

		performWithDelay(dialog, function ()
			dialog:removeFromParent()
			dialog = nil
			_bossAnimal:playAnimation("chuxian2", false)

			performWithDelay(_bossAnimal, function()
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 40, time = 0.5},
				})
				for k,v in pairs(_leftAnimals) do
					v:runAction(cc.Sequence:create(
						cc.MoveBy:create(0.05,cc.p(0, 100)), 
						cc.DelayTime:create(0.2),  
						cc.MoveBy:create(0.3, cc.p(0, -100))
					))
					_sayAni:getNodeForSlot("hpBarPoint")
					local dialog2 = XTHD.createDialogPopGuide(LANGUAGE_BATTLE_STORY2)
					_node:addChild(dialog2, 10)
					dialog2:setPosition(40, 25)
					performWithDelay(dialog2, function ()
						dialog2:removeFromParent()
						dialog2 = nil
					end, 3)
				end

				performWithDelay(self, function()
					battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20080, callback = function() 
						self:_doEndCall(_endCall)
					end}), 1)	
				end, 4)

			end, 5.3666)
		end, 3)
	end, _moveTime + 0.3)
end


--------------------------------结束引导------------------------------

function BgNormal:startFightEnd( battleLayer, _endCall )
	if self:isGuide() == 5 then
		self:_doGuideEnd5(battleLayer, _endCall)
	elseif self:isGuide() == 8 then
		self:_doGuideEnd8(battleLayer, _endCall)
	else --没有引导的时候，步骤一二三顺着来就行
		self:_doEndCall(_endCall)		
	end
end

function BgNormal:_doGuideEnd5(battleLayer, _endCall)
	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _leftAnimals = data.team or {}

	local _fox, _panda
	for k,v in pairs(_leftAnimals) do
		if v:getHeroId() == 12 then
			_fox = v
		elseif v:getHeroId() == 1 then
			_panda = v
		end
	end
	if not _fox or not _panda then
		self:_doEndCall(_endCall)
		return
	end

	_fox:playAnimation("death2", true)
	_panda:playAnimation(BATTLE_ANIMATION_ACTION.IDLE, true)
	battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20052, callback = function() 
		self:_doEndCall(_endCall)
	end}), 1)	
end

function BgNormal:_doGuideEnd8(battleLayer, _endCall)
	performWithDelay(self, function()
		battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20081, callback = function() 
			self:_doEndCall(_endCall)
		end}), 1)	
	end, 4)
end

function BgNormal:create(params)
	return BgNormal.new(params)
end

return BgNormal
