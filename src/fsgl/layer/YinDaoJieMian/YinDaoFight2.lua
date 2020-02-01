
local YinDaoFight2 = class("YinDaoFight2", function(scene)
    return XTHDDialog:create(255)
end)

function YinDaoFight2:onCleanup()
	if self._picTb then
		local textureCache = cc.Director:getInstance():getTextureCache()
	 	for k,v in pairs(self._picTb) do
			textureCache:removeTextureForKey("res/image/story/" .. tostring(v.pic) .. ".jpg")
	 	end
	end

    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
	musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_main,true)
	XTHD.dispatchEvent({name = "EVENT_LEVEUP"}) 
end

function YinDaoFight2:ctor(scene, params)
	self._scene = scene 
	local _params = params or {}
	self._rightData = _params.rightData
	local _playerData
	if _params.id == gf1_data_rhino.heroid then
		_playerData = gf1_data_rhino
	elseif _params.id == gf1_data_mechanicalPig.heroid then
		_playerData = gf1_data_mechanicalPig
	else
		_playerData = gf1_data_chameleon
		--_playerData = guide_data_pangolin
	end
	self._playerData = _playerData

	local btn_battle
    btn_battle = XTHD.createCommonButton({
		text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_28,
		isScrollView = false,
        pos = cc.p(winWidth - 60, winHeight - 30),
        endCallback = function() 
            btn_battle:setClickable(false)
            -- cc.Director:getInstance():popScene()
            self:pause()
            self:doFightEnd()
        end
	})
	btn_battle:setScale(0.7)
    scene:addChild(btn_battle, 10)

    self:goStep1()
end


function YinDaoFight2:goStep1()
	local winWidth  = self:getContentSize().width
	local winHeight = self:getContentSize().height

	local battleLayer = requires("src/battle/BattleLayer.lua"):create()
	self._scene:addChild(battleLayer)

	local winWidth  = self:getContentSize().width
	local winHeight = self:getContentSize().height
	
	local teamListLeft = {}
	local teamListRight = {}
	
	local _playerData = self._playerData
	local animal = {id = _playerData.heroid, isGuidingHero = true, _type = ANIMAL_TYPE.PLAYER, helps = _playerData}
	teamListLeft[#teamListLeft + 1] = animal

	local _data = {
		guide_data_crane,
		guide_data_pangolin,
		guide_data_koala,
	}

	for k,v in pairs(_data) do
		local animal = {id = v.heroid ,_type = ANIMAL_TYPE.PLAYER, helps = v}
		teamListLeft[#teamListLeft + 1] = animal
	end
	table.sort(teamListLeft, function(a, b) 
		local n1 = tonumber(a.helps.attackrange) or 0
		local n2 = tonumber(b.helps.attackrange) or 0
		return n1 < n2
	end)

	local rightData = {}
	local team = {}
	for i=1,3 do
		local animal = {id = guide_data_monster1.monsterid ,_type = ANIMAL_TYPE.MONSTER ,monster = guide_data_monster1 }
	    team[#team + 1] = animal
	end
	rightData.team = team
    teamListRight[#teamListRight + 1] = rightData

	battleLayer:initWithParams({
		bgList 			= {},
		battleTime 		= 3*60,
		isFirstFight    = false,
		showSpeed 		= false,
		bgm				= "res/sound/bgm_02_battle_01.mp3",
		bgType          = BATTLE_GUIDEBG_TYPE.TYPE_SHIP,
		isGuide         = 0,
		teamListLeft	={teamListLeft},
		teamListRight	=teamListRight,
		battleEndCallback 	= function(params) 
			battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 10003 , callback = function() 
				local spineID = 320
				local animal  = SpineAnimal:createWithParams({resourceId = spineID})
				animal:setPosition(cc.p(winWidth  + 100,260))
				battleLayer:addChild(animal,1)
				
				animal:setScale(0.7)
				animal:setScaleX(-0.7)
				
				local pointNode = animal:getNodeForSlot( "hpBarPoint" )
				local dialog = cc.Sprite:create("res/image/daily_task/escort_task/dialog_bg.png")
				pointNode:addChild(dialog,1)
			    local dialogLabel = XTHDLabel:createWithParams({
			        text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_17,
			        fontSize = 18,
			        color = XTHD.resource.color.gray_desc
			    })
			    dialog:addChild(dialogLabel)
			    
			    dialog:setScale(1.4)
			    -- dialogLabel:setAnchorPoint(0,1)
			    dialogLabel:setDimensions(dialog:getBoundingBox().width,dialog:getBoundingBox().height)
			    dialogLabel:setPosition(dialog:getBoundingBox().width / 2 - 30, dialog:getBoundingBox().height / 2)
				dialogLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
				dialogLabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)

			    -- dialogLabel:setScale(1.0)
			    dialogLabel:setScaleX(-math.abs(dialogLabel:getScaleX()))


				animal:playAnimation("run",true)
				animal:runAction(cc.Sequence:create( cc.MoveTo:create(1.0,cc.p(winWidth / 2 + 250,260)) , cc.CallFunc:create(function() 
					
					animal:playAnimation("idle",true)
					--[[--出现敌人boss，引诱我们追击]]
					battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 10004 , callback = function() 
						animal:setScaleX(0.7)
						dialog:setVisible(false)
						animal:playAnimation("run",true)
						animal:runAction(cc.Sequence:create( cc.MoveTo:create(2.0,cc.p(winWidth  + 250,260)) , cc.CallFunc:create(function() 
							local left_animals = battleLayer:getAliveTeam(BATTLE_SIDE.LEFT)
							for k,v in pairs(left_animals) do
								if v:isAlive() == true then
									local pointNode = v:getNodeForSlot( "hpBarPoint" )
									local dialog = cc.Sprite:create("res/image/daily_task/escort_task/dialog_bg.png")
									pointNode:addChild(dialog,1)
								    local dialogLabel = XTHDLabel:createWithParams({
								        text = "!!!...",
								        fontSize = 22,
								        color = XTHD.resource.color.gray_desc
								    })
								    dialog:setScale(1.4)
								    dialog:addChild(dialogLabel)
								    dialogLabel:setWidth(dialog:getBoundingBox().width - 20)
			    					dialogLabel:setPosition(dialog:getBoundingBox().width / 2 - 30, dialog:getBoundingBox().height / 2)
									dialogLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
								end
							end

							battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 10005 , callback = function() 
								local left_animals = battleLayer:getAliveTeam(BATTLE_SIDE.LEFT)
								for k,v in pairs(left_animals) do
									if v:isAlive() == true then
										v:playAnimation("run",true)
										v:runAction(cc.MoveBy:create(3.0,cc.p(winWidth,0)))
										local pointNode = v:getNodeForSlot( "hpBarPoint" )
										pointNode:removeAllChildren()
									end
								end

								battleLayer:runAction(cc.Sequence:create( cc.DelayTime:create(3.1) , cc.CallFunc:create(function()
									battleLayer:removeFromParent()
									self:goStep2()
								end)))
							end}) , 1)
						end) ))
					end}) , 1)

				end) ))
			end}) , 1)
		end
	})
	battleLayer:start()
end

function YinDaoFight2:goStep2()
	local winWidth  = self:getContentSize().width
	local winHeight = self:getContentSize().height
	
	local bgList = {"res/image/background/bg_10.jpg"}
	local teamListLeft = {}
	local _playerData = self._playerData
	local animal = {id = _playerData.heroid, isGuidingHero = true, _type = ANIMAL_TYPE.PLAYER, helps = _playerData}
	teamListLeft[#teamListLeft + 1] = animal

	local _data = {
		guide_data_crane,
		guide_data_pangolin,
		guide_data_koala,
	}

	for k,v in pairs(_data) do
		local animal = {id = v.heroid ,_type = ANIMAL_TYPE.PLAYER, helps = v}
		teamListLeft[#teamListLeft + 1] = animal
	end
	table.sort(teamListLeft, function(a, b) 
		local n1 = tonumber(a.helps.attackrange) or 0
		local n2 = tonumber(b.helps.attackrange) or 0
		return n1 < n2
	end)

	local teamListRight = {}
	local team = {}
	for i=1,3 do
		local animal = {id = guide_data_monster2.monsterid ,_type = ANIMAL_TYPE.MONSTER ,monster = guide_data_monster2 }
	    team[#team + 1] = animal
	end
	local animal = {id = guide_data_monsterHeader1.monsterid ,_type = ANIMAL_TYPE.MONSTER ,monster = guide_data_monsterHeader1}
	team[#team + 1] = animal
	teamListRight.team = team

	--[[--进入第二场战斗]]
	local battleLayer = requires("src/battle/BattleLayer.lua"):create()
	self._scene:addChild(battleLayer)

	battleLayer:initWithParams({
		bgList 			= bgList,
		battleTime 		= 3*60,
		isFirstFight    = false,
		showSpeed 		= false,
		isGuide 		= -1,
		bgm				= "res/sound/bgm_02_battle_02.mp3",
		teamListLeft	={teamListLeft},
		teamListRight	={teamListRight},
		battleEndCallback 	= function(params) 
			battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 10006, playerId = _playerData.heroid, callback = function() 
				local left_animals = battleLayer:getAliveTeam(BATTLE_SIDE.LEFT)
				for k,v in pairs(left_animals) do
					if v:isAlive() == true then
						v:playAnimation("run",true)
						v:runAction(cc.MoveBy:create(3.0,cc.p(winWidth,0)))
					end
				end

				local function _func_(node) 
	        		node:runAction(cc.FadeTo:create(3.0,0))
	                for k,node in pairs(node:getChildren()) do
	                    _func_(node)
	                end
	            end
	            _func_(battleLayer)
	            
				battleLayer:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),cc.CallFunc:create(function()
					battleLayer:removeAllChildren()

					local labTxt =  XTHD.createLabel({color = cc.c3b(255,255,255) , fontSize = 30}) 
					labTxt:setDimensions(800,150)
					labTxt:setAnchorPoint(cc.p(0.5,0.5))
					labTxt:setPosition(winWidth / 2 , winHeight / 2)
					labTxt:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
					labTxt:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
					labTxt:setOpacity(0)
					labTxt:setString(LANGUAGE_KEY_GUIDE_SCENE_TEXT_6)
					battleLayer:addChild( labTxt )
					labTxt:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.FadeIn:create(3.0),cc.FadeOut:create(2.0),cc.CallFunc:create(function( ... )
						battleLayer:removeFromParent()
						self:goStep3()
					end)))
				end)))
				
			end}) , 1)
		end
	})

	battleLayer:start()
end

function YinDaoFight2:goStep3()
	local winWidth  = self:getContentSize().width
	local winHeight = self:getContentSize().height
	
	local teamListLeft = {}
	local teamListRight = {}
	
	local _playerData = self._playerData
	local animal = {id = _playerData.heroid, isGuidingHero = true, _type = ANIMAL_TYPE.PLAYER, helps = _playerData}
	teamListLeft[#teamListLeft + 1] = animal

	local _data = {
		guide_data_crane,
		guide_data_pangolin,
		guide_data_koala,
	}

	for k,v in pairs(_data) do
		local animal = {id = v.heroid ,_type = ANIMAL_TYPE.PLAYER, helps = v}
		teamListLeft[#teamListLeft + 1] = animal
	end
	table.sort(teamListLeft, function(a, b) 
		local n1 = tonumber(a.helps.attackrange) or 0
		local n2 = tonumber(b.helps.attackrange) or 0
		return n1 < n2
	end)


	local teamListRight = {}
	do
		local rightData = {}
		local team = {}
		for i=1,3 do
			local animal = {id = guide_data_monster3.monsterid ,_type = ANIMAL_TYPE.MONSTER ,monster = guide_data_monster3 }
		    team[#team + 1] = animal
		end
    	rightData.team = team
	    teamListRight[#teamListRight + 1] = rightData
	end
	do
		local rightData = {}
		local team = {}
		for i=1,3 do
			local animal = {id = guide_data_monster4.monsterid ,_type = ANIMAL_TYPE.MONSTER ,monster = guide_data_monster4 }
		    team[#team + 1] = animal
		end
		local animal = {id = guide_data_monsterHeader2.monsterid ,_type = ANIMAL_TYPE.MONSTER ,monster = guide_data_monsterHeader2 }
	    team[#team + 1] = animal
    	rightData.team = team
	    teamListRight[#teamListRight + 1] = rightData
	end

	--[[--进入第二场战斗]]
	local battleLayer = requires("src/battle/BattleLayer.lua"):create()
	self._scene:addChild(battleLayer)

	battleLayer:initWithParams({
		bgList 			= {},
		battleTime 		= 10*60,
		isFirstFight    = false,
		showSpeed 		= false,
		bgm				= "res/sound/bgm_02_battle_03.mp3",
		bgType          = BATTLE_GUIDEBG_TYPE.TYPE_BRIDGE,
		isGuide         = 0,
		teamListLeft	={teamListLeft},
		teamListRight	=teamListRight,
		battleEndCallback 	= function(params) 
			battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 10055 , callback = function() 
				local sPanda = battleLayer._bg:getTargets()
				sPanda:setFaceDirection(BATTLE_DIRECTION.LEFT)
				sPanda:playAnimation(BATTLE_ANIMATION_ACTION.IDLE, true)		

				local flash_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/zhsm.json", "res/spine/effect/exchange_effect/zhsm.atlas",1 )
	            flash_effect:setPosition(winWidth/2,winHeight/2+53)
	            battleLayer:addChild(flash_effect,20)
	            flash_effect:setAnimation(0,"guoguan",false)
	            performWithDelay(flash_effect, function()
					flash_effect:removeFromParent()
				end,3.0)
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 3, time = 1.5},
				})
				performWithDelay(battleLayer, function()
					XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
						data = {delta = 5*2, time = 100.5},
					})
			    end, 2)
				performWithDelay(battleLayer, function()
					local left_animals = battleLayer:getAliveTeam(BATTLE_SIDE.LEFT)
					local sPanda = battleLayer._bg:getTargets()
					local _pos = sPanda:getParent():convertToWorldSpace(cc.p(sPanda:getPosition()))
					local _aniData = {id = 1 ,_type = ANIMAL_TYPE.PLAYER , helps = guide_data_panda}
					print("IIIIDDDDD:" .. _aniData.id)
					local _panda = Character:createWithParams(_aniData)	
					battleLayer._animalLayer:addChild(_panda)
					_panda:setPosition(_pos)
					_panda:setFaceDirection(BATTLE_DIRECTION.LEFT)
					sPanda:removeFromParent()
					left_animals[#left_animals + 1] = _panda
					for k,v in pairs(left_animals) do
						if v:isAlive() == true then
							v:playAnimation(BATTLE_ANIMATION_ACTION.IDLE, true)
						end
					end
			        battleLayer:addChild(YinDaoScriptLayer:createWithParams({storyId = 10056 , callback = function()
			        	
						local times = 1

						local function startMoveCircle( endCall )
							local _circleTime = 5--循环次数
							local _bgPar = battleLayer._bg

							local _time = 2.5
							
							--背景层
							local _resPath = "res/spine/guide/battle/bridge/"
							local _bg1 = XTHD.createSprite(_resPath .. "bg_4.jpg")
							_bg1:setContentSize(cc.Director:getInstance():getWinSize())
							local _sizeBg = _bg1:getContentSize()
							local yanjiang = sp.SkeletonAnimation:create(_resPath .. "yanjiang3.json", _resPath .. "yanjiang3.atlas", 1.0)			
							yanjiang:setPosition(_sizeBg.width*0.5, _sizeBg.height*0.5)
							_bg1:addChild(yanjiang)
							yanjiang:setAnimation(0, "animation", true)

							local _bg2 = XTHD.createSprite(_resPath .. "bg_4.jpg")
							_bg2:setContentSize(cc.Director:getInstance():getWinSize())
							local yanjiang = sp.SkeletonAnimation:create(_resPath .. "yanjiang3.json", _resPath .. "yanjiang3.atlas", 1.0)			
							yanjiang:setPosition(_sizeBg.width*0.5, _sizeBg.height*0.5)
							_bg2:addChild(yanjiang)
							yanjiang:setAnimation(0, "animation", true)

							_bgPar:addChild(_bg1)

							_bg2:setPosition(_sizeBg.width, _bgPar:getContentSize().height*0.5)
							_bgPar:addChild(_bg2)

							--落石
							_resPath = "res/image/story/"
							local luoshi1_2 = sp.SkeletonAnimation:create(_resPath .. "luoshi2.json", _resPath .. "luoshi2.atlas", 1.0)			
							luoshi1_2:setPosition(_sizeBg.width*0.5, _sizeBg.height*0.5)
							_bg1:addChild(luoshi1_2)
							luoshi1_2:setAnimation(0, "atk2_2", true)
							local luoshi2_2 = sp.SkeletonAnimation:create(_resPath .. "luoshi2.json", _resPath .. "luoshi2.atlas", 1.0)			
							luoshi2_2:setPosition(_sizeBg.width*0.5, _sizeBg.height*0.5)
							_bg2:addChild(luoshi2_2)
							luoshi2_2:setAnimation(0, "atk2_2", true)

							local luoshi1_1 = sp.SkeletonAnimation:create(_resPath .. "luoshi1.json", _resPath .. "luoshi1.atlas", 1.0)			
							luoshi1_1:setPosition(battleLayer:getContentSize().width*0.5, battleLayer:getContentSize().height*0.5)
							luoshi1_1:setAnimation(0, "atk2_1", true)
							XTHD.dispatchEvent({
								name = EVENT_NAME_BATTLE_PLAY_EFFECT,
								data = {node = luoshi1_1, zorder = 10},
							})
							local luoshi2_1 = sp.SkeletonAnimation:create(_resPath .. "luoshi1.json", _resPath .. "luoshi1.atlas", 1.0)			
							luoshi2_1:setPosition(battleLayer:getContentSize().width*0.5 + _sizeBg.width, battleLayer:getContentSize().height*0.5)
							luoshi2_1:setAnimation(0, "atk2_1", true)
							XTHD.dispatchEvent({
								name = EVENT_NAME_BATTLE_PLAY_EFFECT,
								data = {node = luoshi2_1, zorder = 10},
							})


							--执行滚动
							local function _func1( _node )
								_node:runAction(cc.Sequence:create(
									cc.MoveBy:create(_time, cc.p(-_sizeBg.width, 0)),
									cc.Repeat:create(cc.Sequence:create(
										cc.CallFunc:create(function()
											_node:setPositionX(_sizeBg.width)
										end),
										cc.MoveBy:create(_time*2, cc.p(-_sizeBg.width*2, 0))
									),_circleTime)
								))
							end
							_func1(luoshi1_1)
							_func1(_bg1)
							
							local function _func2( _node )
								_node:runAction(cc.Sequence:create(
									cc.Repeat:create(cc.Sequence:create(
										cc.MoveBy:create(_time*2, cc.p(-_sizeBg.width*2, 0)),
										cc.CallFunc:create(function()
											_node:setPositionX(_sizeBg.width)
										end)
									), _circleTime),
									cc.MoveBy:create(_time, cc.p(-_sizeBg.width, 0))
								))
							end
							_func2(luoshi2_1)
							_func2(_bg2)
						end

			        	local function _func_(node) 
			        		--[[--如果是人物]]
			        		if node ~= battleLayer and node.playAnimation then
        						node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1.0,0) , cc.CallFunc:create(function() 
        								if times > 2 then
        									node:removeFromParent()
        								end
        							end) , cc.DelayTime:create(1.0) , cc.FadeTo:create(1,240)  , cc.DelayTime:create(0.5*2))))
            				else
            					node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1.0,0) , cc.CallFunc:create(function() 
            						if battleLayer == node then
            							times = times + 1
            						end
    								if times > 2 then
    									battleLayer:removeAllChildren()
    									battleLayer:stopAllActions()

										local labTxt =  XTHD.createLabel({color = cc.c3b(255,255,255) , fontSize = 30}) 
										labTxt:setDimensions(winWidth - 50 ,150)
										labTxt:setAnchorPoint(cc.p(0.5,0.5))
										labTxt:setPosition(winWidth / 2 , winHeight / 2)
										labTxt:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
										labTxt:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
										labTxt:setOpacity(0)
										labTxt:setString(LANGUAGE_KEY_GUIDE_SCENE_TEXT_10)
										battleLayer:addChild( labTxt )
										labTxt:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.FadeIn:create(5.0),cc.FadeOut:create(2.0),cc.CallFunc:create(function( ... )
											battleLayer:removeFromParent()
											self:goStep4()
										end)))
										
    								end
        							end) , cc.DelayTime:create(1.5) , cc.FadeTo:create(1,200)  , cc.DelayTime:create(0.5))))
			        		end
			        		if battleLayer ~= node then
				                for k,node in pairs(node:getChildren()) do
				                    _func_(node)
				                end
				            end
			            end
						
						for k,v in pairs(left_animals) do
							if v:isAlive() == true then
								v:setTimeScale(1.2)
								v:setFaceDirection(BATTLE_DIRECTION.RIGHT)
								v:playAnimation(BATTLE_ANIMATION_ACTION.RUN, true)
							end
						end
						battleLayer._bg:setMoveNodeState(false)	
						startMoveCircle()
						battleLayer._bg:resumeAll()

						performWithDelay(battleLayer, function()
							_func_(battleLayer._bg)
							_func_(battleLayer._animalLayer)
							_func_(battleLayer)
					    end,0.5*2)
					end}),10)
			    end, 4)
			end}) , 1)
		end
	})

	battleLayer:start()
end

function YinDaoFight2:goStep4()
	local _lay = XTHDDialog:create()
	self:addChild(_lay)
	local winWidth  = self:getContentSize().width
	local winHeight = self:getContentSize().height

	local _bg_1 = XTHD.createSprite("res/image/background/bg_60.jpg")
	_bg_1:setContentSize(cc.Director:getInstance():getWinSize())
	_bg_1:setPosition(cc.p(winWidth / 2 , winHeight / 2))
	_lay:addChild(_bg_1)
	
	local shifu = SpineAnimal:createWithParams({resourceId = 15})
	shifu:setPosition(cc.p(winWidth / 2 - 250,250))
	shifu:setScale(0.7)
	shifu:playAnimation("atk3",true)
	_lay:addChild(shifu,1)
	
	local function _getPosY(idx)
		return 180 + 15*idx
	end

	local _teamInfo = {}
	_teamInfo[#_teamInfo + 1] = 1
	for k,_aniData in pairs(_teamInfo) do
		local spineID = _aniData
		local animal  = SpineAnimal:createWithParams({resourceId = spineID})

		animal:setScale(0.5)
		animal:setScaleX(-0.5)
		
		local index = k
		local x = winWidth * 1.05 + (winWidth*0.08*index) + 50
		local y = index%2 ~= 0 and _getPosY(6) or _getPosY(1)
		
		local z = 0
		z = index % 2 == 0 and 10 or 0--开启自动排位这个要屏蔽
		_lay:addChild( animal, z)
		animal:setPosition(cc.p(x, y))
		animal:playAnimation("run",true)
		animal:runAction(cc.Sequence:create(cc.MoveBy:create(3.0,cc.p(-550,0)) , cc.CallFunc:create(function( ... )
			
			if animal:isExistAnimation("idle2") == true then
				animal:playAnimation("idle2",false)
			else
				-- animal:playAnimation("atk1",false)
			end
			if k == 1 then
				_lay:addChild(YinDaoScriptLayer:createWithParams({storyId = 10060 , callback = function() 
					_lay:setCascadeOpacityEnabled(true)
					_lay:setOpacity(255)
					_lay:runAction(cc.Sequence:create(cc.FadeOut:create(4.0),cc.DelayTime:create(1.0),cc.CallFunc:create(function()
						_lay:removeFromParent()
						self:goStep5()
					end)))

				end}),20)
			end
		end)))
	end
end

function YinDaoFight2:goStep5()
	self._curIndex = 1
	self._picTb = {
		{pic = "kongque", time = 20.5, text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_7, sound = "guide_7"},
		{pic = "yindao1-2", time = 11.5, text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_8, sound = "guide_8"},
		{pic = "2", time = 14.5, text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_9, sound = "guide_9"},
		{pic = "4", time = 12.5, text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_19, sound = "guide_10"},
	}
	local winWidth  = self:getContentSize().width
	local winHeight = self:getContentSize().height

	local _fadeTime = 3.0
	local function showSelf()
		local _centerLayer = XTHDDialog:create()
		_centerLayer:setCascadeOpacityEnabled(true)
		_centerLayer:setOpacity(0)
		self:addChild(_centerLayer)
		local _file = self._picTb[self._curIndex].pic
		local _time = self._picTb[self._curIndex].time
		local _text = self._picTb[self._curIndex].text
		local _sound = self._picTb[self._curIndex].sound

		local bg = XTHD.createSprite("res/image/story/" .. tostring(_file) .. ".jpg")
		bg:setContentSize(cc.Director:getInstance():getWinSize())
		bg:setPosition(winWidth*0.5 , winHeight*0.5)
		_centerLayer:addChild(bg)

		local text_bg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
		text_bg:setContentSize(cc.size(winWidth, 150))
		_centerLayer:addChild(text_bg)

		local labTxt =  XTHD.createRichLabel({color = cc.c3b(255, 255, 255) , fontSize = 30}) 
		labTxt:setDimensions(cc.size(800, 150))
		labTxt:setAnchorPoint(cc.p(0.5, 0))
		labTxt:setPosition(winWidth*0.5 , 0)
		labTxt:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		labTxt:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		labTxt:setString(_text)
		_centerLayer:addChild( labTxt )

		local function gotoNext( ... )
			if self._soundEffId then
				musicManager.stopEffect(self._soundEffId)
				self._soundEffId = nil
			end
			self._curIndex = self._curIndex + 1
			_centerLayer:setOpacity(255)
			_centerLayer:runAction(cc.Sequence:create(
				cc.FadeOut:create(_fadeTime),
				cc.CallFunc:create(function()
					_centerLayer:removeFromParent()
					if self._curIndex <= #self._picTb then
						showSelf()
					else
						musicManager.stopAllEffects()
					    musicManager.stopMusic()
					    self:goStep6()
					end
				end)
			))
		end

		-- self._soundEffId = musicManager.playEffect("res/sound/guide/" .. _sound .. ".mp3")
		_centerLayer:runAction(cc.Sequence:create(
			cc.FadeIn:create(_fadeTime),
			cc.CallFunc:create(function()
				_centerLayer:setTouchEndedCallback(function() 
					_centerLayer:setClickable(false)
					gotoNext()
				end)
			end),
			cc.DelayTime:create(_time - _fadeTime),
			cc.CallFunc:create(function()
				gotoNext()
			end)
		))
	end
	showSelf()
end

function YinDaoFight2:goStep6()

	local winWidth  = self:getContentSize().width
	local winHeight = self:getContentSize().height

	local _bg_1 = XTHD.createSprite("res/image/background/bg_60.jpg")
	_bg_1:setContentSize(cc.Director:getInstance():getWinSize())
	_bg_1:setPosition(cc.p(winWidth / 2 , winHeight / 2))
	self:addChild(_bg_1)
	
	local shifu  = SpineAnimal:createWithParams({resourceId = 15})
	shifu:setPosition(cc.p(winWidth / 2 - 250,250))
	shifu:setScale(0.7)
	shifu:playAnimation("atk3",true)
	self:addChild(shifu,1)
	
	local function _getPosY(idx)
		return 180 + 15*idx
	end

	local _teamInfo = {}
	_teamInfo[#_teamInfo + 1] = 1

	local animals = {}
	for k,_aniData in pairs(_teamInfo) do
		local spineID = _aniData
		local animal  = SpineAnimal:createWithParams({resourceId = spineID})

		animal:setScale(0.5)
		animal:setScaleX(-0.5)
		
		local index = k
		local x = winWidth * 1.05 + (winWidth*0.08*index) + 50-550
		local y = index%2 ~= 0 and _getPosY(6) or _getPosY(1)
		
		local z = 0
		z = index % 2 == 0 and 10 or 0--开启自动排位这个要屏蔽
		self:addChild( animal, z)
		animal:setPosition(cc.p(x, y))
		animal:playAnimation("idle",true)
		animals[#animals + 1] = animal
	end--for end
	
	self:addChild(YinDaoScriptLayer:createWithParams({storyId = 10065 , callback = function() 
		for k,animal in pairs(animals) do
			animal:playAnimation("idle2",false)
			local pointNode = animal:getNodeForSlot( "hpBarPoint" )
			local dialog = cc.Sprite:create("res/image/daily_task/escort_task/dialog_bg.png")
			pointNode:addChild(dialog,1)
		    local dialogLabel = XTHDLabel:createWithParams({
		        text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_16,
		        fontSize = 18,
		        color = XTHD.resource.color.gray_desc
			})

		    dialog:addChild(dialogLabel)
			dialog:setScale(1.4) -- 1.4
		    -- dialogLabel:setAnchorPoint(0,1)
		    dialogLabel:setDimensions(dialog:getBoundingBox().width, dialog:getBoundingBox().height)
		    dialogLabel:setPosition(dialog:getBoundingBox().width / 2 - 30, dialog:getBoundingBox().height / 2)
			dialogLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			dialogLabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		    dialogLabel:setScaleX(-math.abs(dialogLabel:getScaleX())) --
		    dialog:setPositionX(50)

			performWithDelay(self, function()
				dialog:removeFromParent()

				animal:setScaleX(0.5)
				animal:playAnimation("run",true)
				animal:runAction(cc.Sequence:create(
					cc.MoveBy:create(3.0, cc.p(500, 0)),
					cc.CallFunc:create(function (  )
						--[[--开始消失]]
						self:setCascadeOpacityEnabled(true)
						self:runAction(cc.Sequence:create(
							cc.FadeOut:create(4.0),
							cc.CallFunc:create(function()
								-- cc.Director:getInstance():popScene()
								self:doFightEnd()
							end)))
					end)  
				))
			end,1.5)
		end
	end}),20)
end

function YinDaoFight2:doFightEnd()
	if self._isSendEnd then
		return
	end
	self._isSendEnd = true
	local _instancingid = 5
	-- do cc.Director:getInstance():popScene() return
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


function YinDaoFight2:create( params )
	local scene = cc.Scene:create()
	cc.Director:getInstance():pushScene(scene)
	local _lay = YinDaoFight2.new(scene, params)
	scene:addChild(_lay, -1)
	return _lay
end

return YinDaoFight2