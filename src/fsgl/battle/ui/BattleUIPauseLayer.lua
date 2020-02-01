
BattleUIPauseLayer = class("BattleUIPauseLayer", function(tab)
    return XTHD.createDialog()
end)

function BattleUIPauseLayer:setExitEndedCall( callFunc )
	self._btnExitBattle:setTouchEndedCallback(function()
		cc.Director:getInstance():resume()
		if callFunc then
			callFunc()
		else
			local _url = "exitEctype?"
			if self._battleType == BattleType.DIFFCULTY_COPY then
				_url = "exitDiffcultyEctype?"
			end
			XTHDHttp:requestAsyncInGameWithParams({
	            modules = _url,
	            successCallback = function(data)
	            	if tonumber(data.result) == 0 then
						self:removeFromParent()
						cc.Director:getInstance():getScheduler():setTimeScale(1.0)
						cc.Director:getInstance():popScene() 
	                else
	                   XTHDTOAST(data.msg)
	                end
	            end,--成功回调
	            failedCallback = function()
	                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
	            end,--失败回调
	            targetNeedsToRetain = self,--需要保存引用的目标
	            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	        })
		end
	end)
end

function BattleUIPauseLayer:ctor( battleType, endCall)
	self._battleType = battleType
	self:setOpacity(70)
	local winWidth  = self:getContentSize().width
	local height  	= self:getContentSize().height

	
	local btnExitBattle = XTHDPushButton:createWithParams({
			normalNode = cc.Sprite:create("res/image/tmpbattle/back2mapbtn.png"),
			selectedNode = cc.Sprite:create("res/image/tmpbattle/back2mapbtn.png"),
			needSwallow = true,
			enable = true,
			});
	self._btnExitBattle = btnExitBattle
	self:setExitEndedCall(endCall)
	btnExitBattle:setPosition(cc.p(winWidth*0.2, winHeight*0.5));
	self:addChild(btnExitBattle);
	self._btnExitBattle:setScale(0.7)

	--退出战斗
	-- local labExitBattle = XTHDLabel:createWithParams({
	-- 		text = LANGUAGE_TIPS_BATTLE_EXIT,
	-- 		size = 24
	-- 	})
	local labExitBattle = XTHD.createSprite("res/image/tmpbattle/tczd.png")
	labExitBattle:setPosition(cc.p(winWidth*0.2, winHeight*0.3));
	self:addChild(labExitBattle);
	
	--音效
	local btnSound_effect = XTHDPushButton:createWithParams({
			normalNode = cc.Sprite:create("res/image/tmpbattle/sound_on.png"),
			selectedNode = cc.Sprite:create("res/image/tmpbattle/sound_on.png"),
			needSwallow = true,
			enable = true,
			});

	btnSound_effect:setPosition(cc.p(winWidth*0.4, winHeight*0.5));
	self:addChild(btnSound_effect);
	btnSound_effect:setScale(0.7)
	
	--音效
	-- local labSound_effect = XTHDLabel:createWithParams({
	-- 		text = LANGUAGE_TIPS_BATTLE_SOUNDON,
	-- 		size = 24
	-- 	})
	local labSound_effect = XTHD.createSprite("res/image/tmpbattle/kq.png")
	labSound_effect:setPosition(cc.p(winWidth*0.4+35, winHeight*0.3));
	self:addChild(labSound_effect)
	local YX = XTHD.createSprite("res/image/tmpbattle/yx.png")
	YX:setAnchorPoint(1,0.5)
	YX:setPosition(cc.p(winWidth*0.4-10, winHeight*0.3));
	self:addChild(YX)

	local effect_off=cc.Sprite:create("res/image/tmpbattle/music_off.png")
	effect_off:setPosition(btnSound_effect:getContentSize().width/2,btnSound_effect:getContentSize().height/2)
	effect_off:setVisible(false)
	if musicManager.isEffectEnable() == false then
		effect_off:setVisible(true)
		labSound_effect:setTexture("res/image/tmpbattle/gb.png")
	end
	btnSound_effect:addChild(effect_off)

	btnSound_effect:setTouchEndedCallback(function()
	    if musicManager.isEffectEnable() == true then
            musicManager.setEffectEnable(false)
            effect_off:setVisible(true)
            labSound_effect:setTexture("res/image/tmpbattle/gb.png")
        elseif musicManager.isEffectEnable() == false then
            musicManager.setEffectEnable(true)
            effect_off:setVisible(false)
            labSound_effect:setTexture("res/image/tmpbattle/kq.png")
        end	
		end)
	--音乐
	local btnSound = XTHDPushButton:createWithParams({
			normalNode = cc.Sprite:create("res/image/tmpbattle/music.png"),
			selectedNode = cc.Sprite:create("res/image/tmpbattle/music.png"),
			needSwallow = true,
			enable = true,
			})

	btnSound:setPosition(cc.p(winWidth*0.6, winHeight*0.5));
	self:addChild(btnSound);
	btnSound:setScale(0.7)
	-- local labSound = XTHDLabel:createWithParams({
	-- 		text = LANGUAGE_TIPS_BATTLE_MUSICON,
	-- 		size = 24
	-- 	})
	--音乐
	local YY = XTHD.createSprite("res/image/tmpbattle/yy.png")
	YY:setAnchorPoint(1,0.5)
	YY:setPosition(cc.p(winWidth*0.6-10, winHeight*0.3));
	self:addChild(YY)
	local labSound = XTHD.createSprite("res/image/tmpbattle/kq.png")
	labSound:setPosition(cc.p(winWidth*0.6+35, winHeight*0.3));
	self:addChild(labSound);
	local music_off=cc.Sprite:create("res/image/tmpbattle/music_off.png")
	music_off:setPosition(btnSound:getContentSize().width/2,btnSound:getContentSize().height/2)
	music_off:setVisible(false)
	if musicManager.isMusicEnable() == false then
		music_off:setVisible(true)
		labSound:setTexture("res/image/tmpbattle/gb.png")
	end
	btnSound:addChild(music_off)

	btnSound:setTouchEndedCallback(function()
        if musicManager.isMusicEnable() == true then
            musicManager.setMusicEnable(false)
            music_off:setVisible(true)
            labSound:setTexture("res/image/tmpbattle/gb.png")
        elseif musicManager.isMusicEnable() == false then
            musicManager.setMusicEnable(true,XTHD.resource.music.music_bgm_battle)
            XTHD.dispatchEvent({name = EVENT_NAME_BATTLE_MUSIC_PLAY})
            music_off:setVisible(false)
            labSound:setTexture("res/image/tmpbattle/kq.png")
        end
		end)

	local btnResume = XTHDPushButton:createWithParams({
			normalNode = cc.Sprite:create("res/image/tmpbattle/startbtn.png"),
			selectedNode = cc.Sprite:create("res/image/tmpbattle/startbtn.png"),
			needSwallow = true,
			enable = true,
			});
			btnResume:setScale(0.7)
	btnResume:setTouchEndedCallback(function()
		self:removeFromParent()

		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_RESUME,
		})
	end)
	btnResume:setPosition(cc.p(winWidth*0.8, winHeight*0.5));
	self:addChild(btnResume);
	--继续战斗
	local labResume = XTHD.createSprite("res/image/tmpbattle/jxzd.png")
	labResume:setPosition(cc.p(winWidth*0.8, winHeight*0.3));
	self:addChild(labResume);

end

function BattleUIPauseLayer:create( battleType, endCall )
    return BattleUIPauseLayer.new(battleType, endCall)
end