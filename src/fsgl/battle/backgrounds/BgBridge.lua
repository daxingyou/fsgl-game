--吊桥类型
local BgBridge = class("BgBridge", function ( params )
	local _bg = BattleBackground:_create(params)
	return _bg
end)

function BgBridge:ctor()
	local winWidth = self._bgWidth
	local winHeight = self._bgHeight
	local _effPar = self._effPar

	local _resPath = "res/spine/guide/battle/bridge/"
	self._resPath = _resPath

	local _bg1 = XTHD.createSprite(_resPath .. "bg_1.jpg")
	_bg1:setContentSize(frameSize)
	self._moveNode:addChild(_bg1)

	local _bg2 = XTHD.createSprite(_resPath .. "bg_2.jpg")
	_bg2:setContentSize(frameSize)
	_bg2:setPosition(0, (_bg1:getContentSize().height + _bg2:getContentSize().height)*0.5)
	self._moveNode:addChild(_bg2)

	local _bg4 = XTHD.createSprite(_resPath .. "bg_4.jpg")
	_bg4:setContentSize(frameSize)
	self._moveNode:addChild(_bg4)

	local yanjiang = sp.SkeletonAnimation:create(_resPath .. "yanjiang3.json", _resPath .. "yanjiang3.atlas", 1.0)			
	yanjiang:setPosition(_bg4:getContentSize().width*0.5, _bg4:getContentSize().height*0.5)
	_bg4:addChild(yanjiang)
	yanjiang:setAnimation(0, "animation", true)

	local _bg3 = XTHD.createSprite(_resPath .. "bg_3.jpg")
	_bg3:setContentSize(frameSize)
	_bg3:setPosition((_bg2:getContentSize().width + _bg3:getContentSize().width)*0.5, _bg2:getPositionY())
	self._moveNode:addChild(_bg3)

	_bg4:setPosition(_bg3:getPositionX() + (_bg3:getContentSize().width + _bg4:getContentSize().width)*0.5, _bg3:getPositionY())

	if self:isGuide() == 0 then
		local _longZi = XTHD.createSprite(_resPath .. "tielong.png")
		_longZi:setAnchorPoint(0.5, 0)
		_longZi:setPosition(_bg4:getContentSize().width - 200, _bg4:getContentSize().height*0.5 - 50 + 200)
		_bg4:addChild(_longZi, 10)
		self._longZi = _longZi

		local _aniData = {id = 1 ,_type = ANIMAL_TYPE.PLAYER , helps = guide_data_panda}
		local _panda = Character:createWithParams(_aniData)	
		_panda:setPosition(_longZi:getPositionX()+20, _bg4:getContentSize().height*0.5 + 200)
		_bg4:addChild(_panda, 1)
		_panda:setAnimation(0, BATTLE_ANIMATION_ACTION.WIN, true)
		self._panda = _panda
		_panda:setColor(cc.c3b(100,100,100))
	end

	local yanjiang = sp.SkeletonAnimation:create(_resPath .. "yanjiang.json", _resPath .. "yanjiang.atlas", 1.0)			
	yanjiang:setPosition(_bg3:getContentSize().width*0.5, _bg3:getContentSize().height*0.5)
	_bg3:addChild(yanjiang)
	yanjiang:setAnimation(0, "animation", true)

	local winSize = cc.Director:getInstance():getWinSize()
	local scaleX = winSize.width / 1024
	local scaleY = winSize.height / 615

	local moveDi = sp.SkeletonAnimation:create(_resPath .. "dianti.json", _resPath .. "dianti.atlas", 1.0)			
	moveDi:setPosition(winWidth*0.5, winHeight*0.5)
	_effPar:addChild(moveDi, -1)
	self._moveDi = moveDi
	self._moveDi:setScaleX(scaleX)
	self._moveDi:setScaleY(scaleY)
	

	local moveUp = sp.SkeletonAnimation:create(_resPath .. "dianti2.json", _resPath .. "dianti2.atlas", 1.0)			
	moveUp:setPosition(winWidth*0.5, winHeight*0.5)
	_effPar:addChild(moveUp, 10)
	self._moveUp = moveUp
	self._moveUp:setScaleX(scaleX)
	self._moveUp:setScaleY(scaleY)

	self._movePart1 = cc.p(0, -(_bg1:getContentSize().height + _bg2:getContentSize().height)*0.5)
	self._movePart2 = cc.p(-(_bg2:getContentSize().width + _bg3:getContentSize().width)*0.5 , 0)
	self._movePart3 = cc.p(-(_bg3:getContentSize().width + _bg4:getContentSize().width)*0.5 , 0)
end

function BgBridge:doCurStep( sParams )
	local winWidth = self._bgWidth
	local winHeight = self._bgHeight

	local _endCall = sParams.endCall
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

	if self._curStep == 1 then
		local _time = 2.5
		for k,v in pairs(_leftAnimals) do
			v:changeToMove(true)
			v:runAction(cc.Sequence:create(
				cc.MoveBy:create(_time, cc.p(winWidth*0.5 + 50, 0)),
				cc.CallFunc:create(function()
					v:changeToIdel()
				end)
			))
		end
		performWithDelay(self, function()
			self:_doEndCall(_endCall)
		end, _time + 0.5)
	elseif self._curStep == 2 then
		local _time = 3*0.5
		self._moveDi:setTimeScale(2)
		self._moveDi:setAnimation(0, "animation", false)
		self._moveUp:setTimeScale(2)
		self._moveUp:setAnimation(0, "animation", false)
		XTHD.dispatchEvent({
			name = EVENT_NAME_SHAKE_SCREEN,
			data = {delta = 10, time = 0.4},
		})
		self._moveNode:runAction(cc.Sequence:create(
			cc.MoveBy:create(_time, self._movePart1),
			cc.CallFunc:create(function()
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 10, time = 0.4},
				})
				performWithDelay(self, function()
					self:_doEndCall(_endCall)
				end, 1)
			end)
		))
	elseif self._curStep == 3 then
		local _time = 3.5
		for k,v in pairs(_leftAnimals) do
			v:changeToMove(true)
			v:setMove(false)
		end	
		for k,v in pairs(_rightAnimals) do
			v:changeToIdel()
			v:setPositionX(v:getPositionX() - winWidth*0.5-50 - self._movePart2.x)
			v:runAction(cc.MoveBy:create(_time, self._movePart2))
		end
		self._moveDi:runAction(cc.MoveBy:create(_time, self._movePart2))
		self._moveUp:runAction(cc.MoveBy:create(_time, self._movePart2))
		self._moveNode:runAction(cc.MoveBy:create(_time, self._movePart2))
		performWithDelay(self, function()
			for k,v in pairs(_leftAnimals) do
				v:changeToIdel()
			end
			performWithDelay(self, function()
				self:_doEndCall(_endCall)
			end, 0.5)
		end, _time)
	elseif self._curStep == 4 then
		local _deadRight = sParams.deadRight
		local _deadLeft = sParams.deadLeft
		
		local _time = 3.5
		for k,v in pairs(_leftAnimals) do
			v:changeToMove(true)
			v:setMove(false)
		end	
		for k,v in pairs(_rightAnimals) do
			v:changeToIdel()
			v:setPositionX(v:getPositionX() - winWidth*0.6 - 50  - self._movePart3.x)
			v:runAction(cc.MoveBy:create(_time, self._movePart3))
		end
		self._moveDi:runAction(cc.MoveBy:create(_time, self._movePart3))
		self._moveUp:runAction(cc.MoveBy:create(_time, self._movePart3))
		self._moveNode:runAction(cc.Sequence:create(
			cc.MoveBy:create(_time, self._movePart3),
			cc.CallFunc:create(function()
				for k,v in pairs(_leftAnimals) do
					v:changeToIdel()
				end
				performWithDelay(self, function()
					self:_doEndCall(_endCall)
				end, 0.5)
			end)
		))
	end
end

function BgBridge:getTargets( )
	return self._panda, self._longZi
end


function BgBridge:startGuide( battleLayer, _endCall )
	if self:isGuide() ~= 0 then --没有引导的时候，步骤一二三顺着来就行
		self:changeToNext({endCall = function()
			self:changeToNext({endCall = function()
				self:changeToNext({endCall = function()
					self:_doEndCall(_endCall)
				end})
			end})	
		end})			
		return
	end
	cc.Director:getInstance():getScheduler():setTimeScale(1)
	local winWidth = self._bgWidth
	local winHeight = self._bgHeight
	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local left_animals = data.team or {}
	local _player
	for k,v in pairs(left_animals) do
		if v:getHeroId() == 7 then
		elseif v:getHeroId() == 24 then
		elseif v:getHeroId() == 25 then
		else
			_player = v
		end
	end

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

	self:changeToNext({endCall = function()
		_showStory(10020, function() 
			for k,v in pairs(left_animals) do
				if v:getHeroId() == 7 then
					v:setTimeScale(1.5)
					local pos = cc.p(v:getPosition())
					v:playAnimation("run",true)
					v:runAction(cc.Sequence:create(
						cc.MoveTo:create(3.0,cc.p(900, 700)), 
						cc.DelayTime:create(1.0), 
						cc.CallFunc:create(function()
							self:changeToNext({endCall = function()
								--开始场景的第一阶段移动流程,船移动到指定位置
								v:setFaceDirection(BATTLE_DIRECTION.LEFT)
								v:playAnimation("run",true)
								v:runAction(cc.Sequence:create(
									cc.MoveTo:create(3.0,pos), 
									cc.CallFunc:create(function()
										v:setTimeScale(1)
										v:setFaceDirection(BATTLE_DIRECTION.RIGHT)
										v:playAnimation("idle",true)
										_showStory(10030, function() 
											--这中间可以点干点别的事
											--让英雄开始向前移动准备开始战斗
											self:changeToNext({endCall = function()
												_showStory(10031, function() 
													for k,v in pairs(left_animals) do
														if v:getHeroId() == 25 then
															local data = {standId = v:getStandId()}
															XTHD.dispatchEvent({
																name = EVENT_NAME_BATTLE_AVATAR_BUTTON(v:getHeroId()),
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
												                hasMask 		= false,
												                wordTips 		= LANGUAGE_KEY_GUIDE_SCENE_TEXT_18,
												                extraCall 		= function ()
												                	_buildPointer:removeFromParent()
																	local data = {side = BATTLE_SIDE.RIGHT}
																	XTHD.dispatchEvent({
																		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
																		data = data,
																	})
																	local _rightAnimals = data.team or {}
																	for k,v in pairs(_rightAnimals) do
																		v:setTimeScale(2.0)
																	end
												                	performWithDelay(battleLayer, function()
																		battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 10032, callback = function()
																			performWithDelay(battleLayer, function()
																				self:_doEndCall(_endCall)
																			end, 1)
																		end}), 2)
																	end, 4)
												                end,
												                pos = cc.p(50,100)
												            })
        													battleLayer:addChild(_buildPointer)
															v:setMp(v:getMpMax())
															XTHD.dispatchEvent({
																name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(v:getHeroId()),
																data = {mpadd = v:getMpMax(), standId = v:getStandId()},
															})
															break
														end
													end
												end)
											end})
										end)
									end)
								))
							end})
						end) 
					))
					break
				end
			end
		end)
	end})
end

function BgBridge:startFightNext( battleLayer, _rightOldAnis, _dead_left_animals_, _endCall )

	if self:isGuide() ~= 0 then --没有引导的时候，步骤一二三顺着来就行
		self:changeToNext({endCall = function()
			self:_doEndCall(_endCall)
		end})			
		return
	end
	cc.Director:getInstance():getScheduler():setTimeScale(1)
	local data = {side = BATTLE_SIDE.RIGHT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _rightAnimals = data.team or {}
	local _monsterHeader
	for k,v in pairs(_rightAnimals) do
		if v:getHeroId() == guide_data_monsterHeader2.heroid then
			_monsterHeader = v
			break
		end
	end
	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local left_animals = data.team or {}
	local _player
	for k,v in pairs(left_animals) do
		if v:getHeroId() == 7 then
		elseif v:getHeroId() == 24 then
		elseif v:getHeroId() == 25 then
		else
			_player = v
		end
	end

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
	self:changeToNext({
		deadRight = _rightOldAnis,
		deadLeft = _dead_left_animals_,
		endCall = function()
			_showStory(10040, function() 
				for k,v in pairs(left_animals) do
					if v:getHeroId() == 22 then
						v:setSelectedTargets({name = BATTLE_ANIMATION_ACTION.SUPER , targets = {_monsterHeader}})
						v:playAnimation("atk0")
						performWithDelay(self, function()
							self:_doEndCall(_endCall)
						end,2.0)
						break
					end
				end
			end)
		end

	})
end

function BgBridge:startFightEnd( battleLayer, _endCall )
	if self:isGuide() == -1 then --没有引导的时候，步骤一二三顺着来就行
		self:_doEndCall(_endCall)
		return
	end	
	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local left_animals = data.team or {}
	local _panda,_longZi = self:getTargets()
	_panda:resume()
	_longZi:resume()
	battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 10050, callback = function() 
		--笼子拉起来，回调返回熊猫对象(SkeletonAnimation）
		
		local v = nil
		for k, animal in pairs(left_animals) do
			if animal:getHeroId() == 7 then
				v = animal
				break
			end
		end
		if not v then
			self:_doEndCall(_endCall)
			return
		end
		local pos = cc.p(v:getPosition())
		v:playAnimation("run",true)
		v:runAction(cc.Sequence:create(
			cc.MoveBy:create(1.0,cc.p(0 , 250)),
			cc.DelayTime:create(0.5), 
			cc.CallFunc:create(function()
				v:playAnimation("atk1",true)
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 10}
				})
				--[[--熊猫掉下来]]
				performWithDelay(battleLayer, function()
					_panda:runAction(cc.Sequence:create(
						cc.MoveBy:create(0.5, cc.p(0, -200)),
						cc.CallFunc:create(function()
							_panda:setColor(cc.c3b(255,255,255))
							XTHD.dispatchEvent({
								name = EVENT_NAME_SHAKE_SCREEN,
								data = {delta = 10,time = 1.5}
							})
						end)
					))
					_longZi:runAction(cc.Sequence:create(
						cc.MoveBy:create(0.5, cc.p(0, -200)),
						cc.DelayTime:create(1),
						cc.MoveBy:create(3.5, cc.p(0, 600)),
						cc.CallFunc:create(function()
							_longZi:setVisible(false)
							self:_doEndCall(_endCall)
						end)
					))
					v:playAnimation("run",true)
					v:runAction(cc.Sequence:create(cc.MoveTo:create(1.0,pos) , cc.CallFunc:create(function()
						v:playAnimation("idle",true)
					end)))
				end,1.0)
			end)
		))
	end}), 1)
end

function BgBridge:create(params)
	return BgBridge.new(params)
end

return BgBridge
