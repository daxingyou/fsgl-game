--船类型
local BgShip = class("BgShip", function ( params )
	local _bg = BattleBackground:_create(params)
	return _bg
end)

function BgShip:ctor()
	local winWidth = self._bgWidth
	local winHeight = self._bgHeight
	local _effPar = self._effPar

	local _resPath = "res/spine/guide/battle/ship/"
	self._resPath = _resPath
	local _circleTime = 2
	if self:isGuide() == 0 then
		_circleTime = 1
	end
	self._circleTime = _circleTime

	local _first = 1
	if _circleTime%2 ~= 1 then
		_first = -1
	end
	local _bg1
	for i=1, _circleTime do
		_bg1 = XTHD.createSprite(_resPath .. "bg_1.jpg")
		_bg1:setContentSize(cc.Director:getInstance():getWinSize())
		_bg1:setPosition(_bg1:getContentSize().width*(i-1), 0)
		_bg1:setScaleX(_first) 
		_first = -1 * _first
		self._moveNode:addChild(_bg1)
	end

	if self._11 then
	end

	local _bg2 = XTHD.createSprite(_resPath .. "bg_2.jpg")
	_bg2:setContentSize(cc.Director:getInstance():getWinSize())
	_bg2:setPosition(_bg1:getPositionX() + (_bg1:getContentSize().width + _bg2:getContentSize().width)*0.5, 0)
	self._moveNode:addChild(_bg2)

	local _bg3 = XTHD.createSprite(_resPath .. "bg_3.jpg")
	_bg3:setContentSize(cc.Director:getInstance():getWinSize())
	_bg3:setPosition(_bg2:getPositionX() + (_bg2:getContentSize().width + _bg3:getContentSize().width)*0.5, 0)
	self._moveNode:addChild(_bg3)

	local _shui = sp.SkeletonAnimation:create(_resPath .. "shui2.json", _resPath .. "shui2.atlas", 1.0)			
	_shui:setPosition(_bg3:getContentSize().width*0.5, _bg3:getContentSize().height*0.5)
	_bg3:addChild(_shui)
	_shui:setAnimation(0, "animation", true)


	local _width = _bg1:getContentSize().width*_circleTime + _bg2:getContentSize().width*2 + _bg3:getContentSize().width
	local _pWidth = 100
	local function _moveAction( _chuan, _dir )
		local _moveX = 0
		local _restartX = 0
		local _endX = 0
		if _dir == 1 then
			_moveX = -(_chuan:getPositionX() + _pWidth) - winWidth*0.5
			_restartX = _width + _pWidth - winWidth*0.5
			_endX = -_pWidth - winWidth*0.5
			_chuan:setScaleX(-1)
		elseif _dir == 2 then
			_moveX = _width + _pWidth - _chuan:getPositionX() - winWidth*0.5
			_restartX = - _pWidth - winWidth*0.5
			_endX = _width + _pWidth - winWidth*0.5
		end
		local _speed = math.random(35,60)
		local _time = math.abs(_moveX)/_speed
		local _timeTotle = (_width + _pWidth*2)/_speed 

		_chuan:runAction(cc.Sequence:create(
			cc.MoveBy:create(_time, cc.p(_moveX, 0)),
			cc.RepeatForever:create(cc.Sequence:create(
				cc.CallFunc:create(function()
					_chuan:setPositionX(_restartX)
				end),
				cc.MoveBy:create(_timeTotle, cc.p(_endX-_restartX, 0))
			))
		))
	end

	local _chuans = {}
	for i=1, 5 do
		local _idx = i%2 == 0 and 1 or 2
		local _chuan = sp.SkeletonAnimation:create(_resPath .. "chuan" .. _idx .. ".json", _resPath .. "chuan" .. _idx .. ".atlas", 1.0)			
		_chuan:setAnimation(0, "animation", true)
		self._moveNode:addChild(_chuan)
		local _y = math.random(winHeight*0.3, winHeight*0.375) 
		local _x = _width/5*i - winWidth*0.5
		local _dir = math.random(1, 2)
		_chuan:setPosition(_x, _y)
		_chuans[#_chuans + 1] = _chuan
		_moveAction(_chuan, _dir)
	end
	table.sort(_chuans, function( a, b )
		return a:getPositionY() > b:getPositionY()
	end)
	for i=1, #_chuans do
        self._moveNode:reorderChild(_chuans[i], _chuans[i]:getLocalZOrder())
	end

	self._movePart1 = cc.p(-((260 - _bg1:getContentSize().width + winWidth)*0.5 + _bg1:getContentSize().width*_circleTime) , 0)
	self._movePart2 = cc.p(-_bg2:getContentSize().width + 260, 0)

	
	local moveDi = XTHD.createSprite(_resPath .. "chuan.png")	
	moveDi:setScaleX(winWidth/1024)
	moveDi:setAnchorPoint(0, 0.5)	
	moveDi:setPosition(0, winHeight*0.5 - 45.62)
	_effPar:addChild(moveDi, -1)
	self._moveDi = moveDi

	local moveUp = sp.SkeletonAnimation:create(_resPath .. "shui.json", _resPath .. "shui.atlas", 1.0)			
	moveUp:setPosition(0, winHeight*0.5)
	_effPar:addChild(moveUp, 20)
	self._moveUp = moveUp
end

function BgShip:doCurStep( sParams )
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
		local _time = 0.5
		for i = 1, #_leftAnimals do
			local spine = _leftAnimals[i]
			spine:changeToIdel()
			spine:setPositionX(spine:getPositionX() + winWidth*0.5 + 50)
			spine:setVisible(false)
			spine:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.05 * i), 
				cc.CallFunc:create(function ()
					local spSmoke = sp.SkeletonAnimation:create("res/spine/effect/line_up/yxsz.json","res/spine/effect/line_up/yxsz.atlas")
					spSmoke:setAnchorPoint(cc.p(0.5, 0))
					spSmoke:setPosition(spine:getPosition())
					spSmoke:setScale(2)
					spSmoke:setAnimation(0,"animation",false)
					XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = spSmoke, zorder = -1},
					})
					performWithDelay(spSmoke,function()
						spSmoke:removeFromParent()
					end, 2)
					local _scale = spine:getScale()
					spine:setOpacity(60)
					spine:runAction(cc.Sequence:create(
						cc.DelayTime:create(0.04), 
						cc.CallFunc:create(function()
							spine:setVisible(true)
						end), 
						cc.FadeTo:create(0.14,255)
					))
				end)
			))
		end
		performWithDelay(self, function()
			self:_doEndCall(_endCall)
		end, _time)
	elseif self._curStep == 2 then
		local _time = 3.5*self._circleTime
		self._moveUp:setAnimation(0, "idle", true)
		self._moveNode:runAction(cc.Sequence:create(
			cc.Spawn:create(
				cc.MoveBy:create(_time, self._movePart1),
				cc.Sequence:create(
					cc.DelayTime:create(_time - 1),
					cc.CallFunc:create(function()
						self._moveUp:setAnimation(0, "atk", false)
						performWithDelay(self._moveUp, function()
							XTHD.dispatchEvent({
								name = EVENT_NAME_SHAKE_SCREEN,
								data = {delta = 10, time = 0.4},
							})
						end, 0.9)
					end)
				)
			),
			cc.CallFunc:create(function()
				performWithDelay(self, function()
					self:_doEndCall(_endCall)
				end, 1)
			end)
		))
	elseif self._curStep == 3 then
		local _time = 2.5
		for k,v in pairs(_leftAnimals) do
			v:changeToMove(true)
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
	end
end

function BgShip:startGuide( battleLayer, _endCall )

	if self:isGuide() == 0 then
		self:_doGuideStart0(battleLayer, _endCall)
	elseif self:isGuide() == 2 then
		self:_doGuideStart2(battleLayer, _endCall)
	elseif self:isGuide() == 7 then
		self:_doGuideStart7(battleLayer, _endCall)
	else --没有引导的时候，步骤一二三顺着来就行
		self:changeToNext({endCall = function()
			self:changeToNext({endCall = function()
				self:changeToNext({endCall = function()
					self:_doEndCall(_endCall)
				end})
			end})	
		end})		
	end
end

function BgShip:_doGuideStart0( battleLayer, _endCall )
	cc.Director:getInstance():getScheduler():setTimeScale(1)
	local winWidth = self._bgWidth
	local winHeight = self._bgHeight
	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _leftAnimals = data.team or {}
	local _player
	for k,v in pairs(_leftAnimals) do
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
		_showStory(10010, function() 
	        local flash_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/zhsm.json", "res/spine/effect/exchange_effect/zhsm.atlas",1 )
	        flash_effect:setPosition(winWidth/2,winHeight/2+53)
	        battleLayer:addChild(flash_effect,20)
		    flash_effect:setAnimation(0,"mubiao2",false)
		    performWithDelay(flash_effect, function()
				flash_effect:removeFromParent()
			end,3.0)
			--开始场景的第一阶段移动流程,船移动到指定位置
			self:changeToNext({endCall = function()
				_showStory(10011, function() 
					--这中间可以点干点别的事
					-- local sParams = {
					-- 	isTurn = true,
					-- 	moveTime = 1,
					-- 	isEndToStand = true,
					-- 	sEndCall = function ( ... )
							--让英雄开始向前移动准备开始战斗
							self:changeToNext({endCall = function()
								self:_doEndCall(_endCall)
							end})
					-- 	end
					-- }
					-- battleLayer:_resetLeftStands(sParams)			
				end)
			end})
		end)
	end})
end

function BgShip:_doGuideStart2( battleLayer, _endCall )
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

	local _panda, _fox
	for k,v in pairs(_leftAnimals) do
		if v:getHeroId() == 1 then
			_panda = v
		elseif v:getHeroId() == 12 then
			_fox = v
		end
	end
	if _panda then
		performWithDelay(_panda, function()
			local pointNode = _panda:getNodeForSlot( "hpBarPoint" )
			local dialog = XTHD.createDialogPopGuide(LANGUAGE_KEY_GUIDE_SCENE_TEXT_21, 22)
			pointNode:addChild(dialog,1)
		    performWithDelay(dialog, function()
		    	dialog:removeFromParent()
		    end, 2)
		    if _fox then
		    	performWithDelay(_fox, function()
				    local pointNode = _fox:getNodeForSlot( "hpBarPoint" )
					local dialog = XTHD.createDialogPopGuide(LANGUAGE_KEY_GUIDE_SCENE_TEXT_26, 22)
					pointNode:addChild(dialog, 1)
				    performWithDelay(dialog, function()
				    	dialog:removeFromParent()
				    end, 2)
			    end, 1.5)
		    end
		end, 1.5)
	end
	

	self:changeToNext({endCall = function()
		self:changeToNext({endCall = function()
			self:changeToNext({endCall = function()
				if not _panda then
					self:_doEndCall(_endCall)
					return
				end
				local data = {standId = _panda:getStandId()}
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_AVATAR_BUTTON(_panda:getHeroId()),
					data = data,
				})
				local button = data.button
				
				_panda:setMp(_panda:getMpMax())
				XTHD.dispatchEvent({
					name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(_panda:getHeroId()),
					data = {mpadd = _panda:getMpMax(), standId = _panda:getStandId()},
				})
				button:setTouchEndedCallback(nil)
	            local _buildPointer = nil
	            _buildPointer = YinDao:create({
	                target 			= button,
	                direction 		= 1,
	                action 			= 1,
	                isButton 		= false,
					isMode 			= 1,
	                hasMask 		= false,
	                wordTips 		= LANGUAGE_KEY_GUIDE_SCENE_TEXT_22,
	                extraCall 		= function ()
		                _panda:setSelectedTargets({name = BATTLE_ANIMATION_ACTION.SUPER, targets = _rightAnimals})
	               		_panda:playAnimation(BATTLE_ANIMATION_ACTION.SUPER)
	                	_buildPointer:removeFromParent()
	                	performWithDelay(battleLayer, function()
							battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20020, callback = function()
								performWithDelay(battleLayer, function()
									self:_doEndCall(_endCall)
								end,0.5)
							end}), 2)
						end, 3)
	                end,
	                pos = cc.p(50,100)
	            })
				battleLayer:addChild(_buildPointer)
			end})
		end})	
	end})
end

function BgShip:_doGuideStart7( battleLayer, _endCall )

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

	local _panda, _fox, _crane
	for k,v in pairs(_leftAnimals) do
		if v:getHeroId() == 1 then
			_panda = v
		elseif v:getHeroId() == 7 then
			_crane = v
		elseif v:getHeroId() == 12 then
			_fox = v
		end
	end
	if _crane then
		performWithDelay(_crane, function()
			local pointNode = _crane:getNodeForSlot( "hpBarPoint" )
			local dialog = XTHD.createDialogPopGuide(LANGUAGE_KEY_GUIDE_SCENE_TEXT_27)
			pointNode:addChild(dialog,1)
		    performWithDelay(dialog, function()
		    	dialog:removeFromParent()
		    end, 2)
		    if _fox then
		    	performWithDelay(_fox, function()
				    local pointNode = _fox:getNodeForSlot( "hpBarPoint" )
					local dialog = XTHD.createDialogPopGuide(LANGUAGE_KEY_GUIDE_SCENE_TEXT_26, 22)
					pointNode:addChild(dialog, 1)
				    performWithDelay(dialog, function()
				    	dialog:removeFromParent()
				    end, 2)
			    end, 1.5)
		    end
		    if _panda then
		    	performWithDelay(_panda, function()
				    local pointNode = _panda:getNodeForSlot( "hpBarPoint" )
					local dialog = XTHD.createDialogPopGuide(LANGUAGE_KEY_GUIDE_SCENE_TEXT_26, 22)
					pointNode:addChild(dialog, 1)
				    performWithDelay(dialog, function()
				    	dialog:removeFromParent()
				    end, 2)
			    end, 1.5)
		    end
		end, 1.5)
	end

	self:changeToNext({endCall = function()
		self:changeToNext({endCall = function()
			self:changeToNext({endCall = function()
				battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20070, callback = function()
					for k,v in pairs(_rightAnimals) do
						if v:getHeroId() == 317 then
							self._eyu = table.remove(_rightAnimals, k)
							break
						end
					end
					if not self._eyu then
						self:_doEndCall(_endCall)
						return
					end
					self._eyu:resumeSelf()
					self._eyu:changeToMove()
					self._eyu:setFaceDirection(BATTLE_DIRECTION.RIGHT)
					local _x = self._bgWidth - 100 - self._eyu:getPositionX()
					self._eyu:runAction(cc.Sequence:create(
						cc.MoveBy:create(2, cc.p(_x, 0)),
						cc.CallFunc:create(function()
							self._eyu:changeToIdel()
							self._eyu:setFaceDirection(BATTLE_DIRECTION.LEFT)
							performWithDelay(battleLayer, function()
								self:_doEndCall(_endCall)
							end,0.5)
						end)
					))
				end}), 2)
			end})
		end})	
	end})
end

--------------------------------结束引导------------------------------

function BgShip:startFightEnd( battleLayer, _endCall )
	if self:isGuide() == 7 then
		self:_doGuideEnd7(battleLayer, _endCall)
	else --没有引导的时候，步骤一二三顺着来就行
		self:_doEndCall(_endCall)		
	end
end

function BgShip:_doGuideEnd7(battleLayer, _endCall)
	if not self._eyu then
		self:_doEndCall(_endCall)
		return
	end

	local winWidth = self._bgWidth
	local winHeight = self._bgHeight
	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local _leftAnimals = data.team or {}

	for k,v in pairs(_leftAnimals) do
		v:changeToIdel()
		v:setFaceDirection(BATTLE_DIRECTION.RIGHT)
	end

	local _moveTime = 2.5
	self._eyu:playAnimation("idle3", true)
	battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20071, callback = function()
		self._eyu:changeToMove()
		self._eyu:setFaceDirection(BATTLE_DIRECTION.RIGHT)
		self._eyu:runAction(cc.MoveBy:create(_moveTime, cc.p(winWidth, 0)))

		performWithDelay(self, function ()
			for k,v in pairs(_leftAnimals) do
				v:changeToMove()
				v:runAction(cc.MoveBy:create(_moveTime, cc.p(winWidth, 0)))
				local _pTime = math.random(1, 5)/10
				performWithDelay(v, function()
					local pointNode = v:getNodeForSlot( "hpBarPoint" )
					local dialog, dialogLabel = XTHD.createDialogPopGuide(LANGUAGE_KEY_GUIDE_SCENE_TEXT_24)
					pointNode:addChild(dialog, 1)
					performWithDelay(dialog, function()
						dialog:removeFromParent()
					end, 1)
				end, _pTime)
			end
		end, 0.5)


		performWithDelay(self, function ()
			self._moveNode:setVisible(false)
			local _bg = XTHD.createSprite("res/spine/guide/battle/ship/bg_2.jpg")
			_bg:setContentSize(cc.Director:getInstance():getWinSize())
			_bg:setScaleX(-1)
			self:addChild(_bg)
			local parX = (winWidth - _bg:getContentSize().width)*0.5

			_moveTime = 1.5

			self._eyu:setPositionX(-50)
			self._eyu:runAction(cc.Sequence:create(
				cc.MoveBy:create(_moveTime, cc.p(320 + parX, 0)),
				cc.CallFunc:create(function()
					self._eyu:changeToIdel()
					local pointNode = self._eyu:getNodeForSlot( "hpBarPoint" )
					local dialog, dialogLabel = XTHD.createDialogPopGuide(LANGUAGE_KEY_GUIDE_SCENE_TEXT_25)
					pointNode:addChild(dialog, 1)
					performWithDelay(dialog, function()
						dialog:removeFromParent()
					end, 1.5)
				end),
				cc.DelayTime:create(1.5),
				cc.CallFunc:create(function()
					self._eyu:playAnimation("jump", false)
				end),
				-- cc.Spawn:create(
				-- 	cc.MoveBy:create(1, cc.p(200, 0)),
				-- 	cc.Sequence:create(
				-- 		cc.MoveBy:create(0.5, cc.p(0, 100)),
				-- 		cc.MoveBy:create(0.3, cc.p(0,-100)),
				-- 		cc.Spawn:create(
				-- 			cc.MoveBy:create(0.2, cc.p(0,-50)),
				-- 			cc.FadeOut:create(0.2)
				-- 		)
				-- 	)
				-- ),
				cc.CallFunc:create(function()
					for k,v in pairs(_leftAnimals) do
						v:setPositionX(-100)
						v:runAction(cc.Sequence:create(
							cc.DelayTime:create(0.5 + 0.5*k),
							cc.MoveBy:create(_moveTime, cc.p(320 + 100 + parX - 50*k, 0)),
							cc.CallFunc:create(function()
								v:changeToIdel()
							end)
						))
					end
					performWithDelay(self, function()
						battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 20072, callback = function()
							self:_doEndCall(_endCall)	
						end}), 2)
					end, _moveTime*2)
				end)
			))
		end, _moveTime + 1) 	
	end}), 2)	
end

function BgShip:create(params)
	return BgShip.new(params)
end

return BgShip
