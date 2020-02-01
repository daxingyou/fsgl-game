--修罗炼狱界面

local XiuLuoLianYuLayer = class("XiuLuoLianYuLayer",function ()
	return XTHD.createBasePageLayer({
        bg = "res/image/daily_task/arena/bg_xl.png",
        isOnlyBack = true,
    })
end)

function XiuLuoLianYuLayer:ctor(data)
	IS_HAVE_ARENASELECT_LAYER = false
	self:initUI(data)
	--匹配成功
	XTHD.addEventListenerWithNode({
		node = self,
        name = CUSTOM_EVENT.MATCHINGRIVAL,
        callback = function (event)
	        if self._matchingBg then
			    self._matchingBg:removeFromParent()
			    self._matchingBg = nil
			end
        	self:refreshTime(event.data.time)
        	if IS_HAVE_ARENASELECT_LAYER then
        		return
        	end
        	LayerManager.addShieldLayout()
            local XiuLuoLianYuSelectHeroLayer = requires("src/fsgl/layer/XiuLuoLianYu/XiuLuoLianYuSelectHeroLayer.lua"):create(event.data)
		    LayerManager.addLayout(XiuLuoLianYuSelectHeroLayer, {par = self})
		    IS_HAVE_ARENASELECT_LAYER = true
        end
    })
	--可以开始匹配
    XTHD.addEventListenerWithNode({
		node = self,
    	name = CUSTOM_EVENT.ENTER_RIVAL,
        callback = function (event)
			self:startMatch()	
		end
	})
	--可以退出匹配
	XTHD.addEventListenerWithNode({
		node = self,
    	name = CUSTOM_EVENT.KICK_OUT_ARENA,
        callback = function (event)
			if self._matchingBg then
			    self._matchingBg:removeFromParent()
			    self._matchingBg = nil
			end	
		end
	})
	--可以刷新胜点
    XTHD.addEventListenerWithNode({
        name = CUSTOM_EVENT.REFRESH_WIN_POINT,
        callback = function (event)
        	self._leftWin:setString(event.data.Gmg)
			self._rightWin:setString(event.data.Ayl)
        end
    })
    --刷新剩余次数
    XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_LEFT_TIME,
        callback = function (event)
        	self:refreshTime(event.data)
        end
    })
end

function XiuLuoLianYuLayer:onCleanup()
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_LEFT_TIME)
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_WIN_POINT)
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
	local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey("res/image/daily_task/arena/bg2.jpg")
	textureCache:removeTextureForKey("res/image/daily_task/arena/faction_bg.png")
	textureCache:removeTextureForKey("res/image/daily_task/arena/select_bg.png")
end

function XiuLuoLianYuLayer:initUI(data)

	local reward_btn = XTHD.createButton({
        normalFile        = "res/image/worldboss/rewarld_1.png", 
        selectedFile      = "res/image/worldboss/rewarld_2.png",
        pos = cc.p(self:getContentSize().width - GetScreenOffsetX()*4,50),
        anchor = cc.p(1, 0),
        endCallback = function()
        	local _pNum = gameUser.getCampID() == 1 and tonumber(self._leftWin:getString()) or tonumber(self._rightWin:getString())
            local reward_pop=requires("src/fsgl/layer/XiuLuoLianYu/XiuLuoLianYuRewardLayer.lua"):create(_pNum)
			LayerManager.addLayout(reward_pop, {noHide = true})
        end
	})
	reward_btn:setScale(0.7)
    self:addChild(reward_btn)

	local factionBg = cc.Sprite:create("res/image/daily_task/arena/faction_bg.png")
	factionBg:setPosition(self:getBoundingBox().width*0.5,self:getBoundingBox().height*0.5)
	factionBg:setScale(0.8)
	self:addChild(factionBg)

	
	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=28});
            self:addChild(StoredValue)
        end,
	})
	self:addChild(help_btn)
	help_btn:setPosition(self:getContentSize().width - help_btn:getContentSize().width - 50,self:getContentSize().height - help_btn:getContentSize().height*0.7 + 10)

	local saintBeastChange = XTHDPushButton:createWithParams({
		normalFile = "res/image/plugin/saint_beast/change_normal.png",
		selectedFile = "res/image/plugin/saint_beast/change_selected.png",
		musicFile = XTHD.resource.music.effect_btn_common,
	})
	saintBeastChange:setAnchorPoint(0,0.5)
	saintBeastChange:setPosition(10,self:getContentSize().height - saintBeastChange:getContentSize().height *0.5)
	self:addChild(saintBeastChange)
	saintBeastChange:setTouchEndedCallback(function()
		local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("Artifact")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
	end)

	local leftFaction = cc.Sprite:create("res/image/camp/camp_icon_small1.png")
	leftFaction:setAnchorPoint(0,0.5)
	leftFaction:setPosition(100,factionBg:getContentSize().height*0.5)
	factionBg:addChild(leftFaction)

	local rightFaction = cc.Sprite:create("res/image/camp/camp_icon_small2.png")
	rightFaction:setAnchorPoint(1,0.5)
	rightFaction:setPosition(factionBg:getContentSize().width-100,factionBg:getContentSize().height*0.5)
	factionBg:addChild(rightFaction)

	local leftPoint = cc.Sprite:create("res/image/daily_task/arena/point.png")
	leftPoint:setPosition(leftFaction:getPositionX()+leftPoint:getContentSize().width+40,leftFaction:getPositionY())
	factionBg:addChild(leftPoint)

	local leftWin = XTHDLabel:createWithParams({
		text = data.winsPointsGmg,
		fontSize = 30,
		color = cc.c3b(255,255,255)
	})
	leftWin:setPosition(factionBg:getBoundingBox().width*0.5-185,factionBg:getContentSize().height*0.5)
	factionBg:addChild(leftWin)
	self._leftWin = leftWin

	local rightWin = XTHDLabel:createWithParams({
		text = data.winsPointsAyl,
		fontSize = 30,
		color = cc.c3b(255,255,255)
	})
	rightWin:setPosition(factionBg:getContentSize().width*0.5+305,factionBg:getContentSize().height*0.5)
	factionBg:addChild(rightWin)
	self._rightWin = rightWin

	local rightPoint = cc.Sprite:create("res/image/daily_task/arena/point.png")
	rightPoint:setPosition(rightFaction:getPositionX()-rightPoint:getBoundingBox().width-40,rightFaction:getPositionY())
	factionBg:addChild(rightPoint)

    local middleLogo = cc.Sprite:create("res/image/daily_task/arena/logo.png")
	middleLogo:setPosition(self:getBoundingBox().width*0.5,self:getBoundingBox().height*0.5)
	middleLogo:setScale(0.8)
	self:addChild(middleLogo)
	--修罗战场
	local xiuluo = cc.Sprite:create("res/image/daily_task/arena/xiuluo_l.png")
	xiuluo:setPosition(middleLogo:getContentSize().width/2,15)
	xiuluo:setAnchorPoint(0.5,0)
	middleLogo:addChild(xiuluo)
	--种族点达到需求后搜游参赛玩家客货得奖励
    local _rewardTip = XTHD.createSprite("res/image/daily_task/arena/rewardTip.png")
    _rewardTip:setPosition(self:getBoundingBox().width*0.5, 
		middleLogo:getPositionY()+middleLogo:getBoundingBox().height*0.5+_rewardTip:getBoundingBox().height*0.5 - 10)
		_rewardTip:setScale(0.8)
    self:addChild(_rewardTip)

	--开启时间
    local openTime = XTHDLabel:createWithParams({
    	text = LANGUAGE_KEY_TIMETO,
    	fontSize = 20,
    	color = cc.c3b(255,255,255)
	})
	openTime:setPosition(self:getBoundingBox().width*0.5,_rewardTip:getPositionY()+35)
	self:addChild(openTime)

	data.startDate = string.sub(data.startDate,1,-4)
	data.endDate = string.sub(data.endDate,1,-4)
	
	local seasonData = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt",os.date("%Y.%m.%d",data.startDate).."-"..os.date("%Y.%m.%d",data.endDate))
	seasonData:setPosition(self:getBoundingBox().width*0.5,openTime:getPositionY()+28)
	self:addChild(seasonData)

	--第几赛季背景
	local sj_bg = ccui.Scale9Sprite:create("res/image/daily_task/arena/si_bg.png")
	sj_bg:setPosition(self:getContentSize().width/2,self:getContentSize().height)
	sj_bg:setAnchorPoint(0.5,1)
	sj_bg:setScale(0.9)
	self:addChild(sj_bg)
	--第几赛季
	local seasonStr1 = cc.Sprite:create("res/image/daily_task/arena/season_str1.png")
	seasonStr1:setAnchorPoint(0,0.5)
	local seasonNum = cc.Label:createWithBMFont("res/image/tmpbattle/goldword001.fnt",data.season)
	seasonNum:setAnchorPoint(0,0.5)
	local seasonStr2 = cc.Sprite:create("res/image/daily_task/arena/season_str2.png")
	seasonStr2:setAnchorPoint(0,0.5)

	seasonStr1:setPosition(sj_bg:getContentSize().width * 0.3 - 15,sj_bg:getContentSize().height*0.5 + 5)
	sj_bg:addChild(seasonStr1)
	seasonNum:setPosition(seasonStr1:getPositionX()+seasonStr1:getBoundingBox().width,seasonStr1:getPositionY()+3)
	sj_bg:addChild(seasonNum)
	seasonStr2:setPosition(seasonNum:getPositionX()+seasonNum:getBoundingBox().width,seasonNum:getPositionY()-3)
	sj_bg:addChild(seasonStr2)
	--修罗战场需要进行
	local arenaDesc = cc.Sprite:create("res/image/daily_task/arena/arena_desc.png")
	arenaDesc:setPosition(self:getBoundingBox().width*0.5,middleLogo:getPositionY()-middleLogo:getBoundingBox().height*0.5-30)
	arenaDesc:setScale(0.7)
	self:addChild(arenaDesc)

	local challengeBtn = XTHDPushButton:createWithParams({
		normalFile = "res/image/common/btn/kstz_up.png",
		selectedFile = "res/image/common/btn/kstz_down.png",
		--disableFile = "res/image/common/btn/btn_guildWar_normal.png"
	})

	local closeBtn = XTHDPushButton:createWithParams({
		normalFile = "res/image/common/btn/btn_guildWar_normal.png",
		selectedFile = "res/image/common/btn/btn_guildWar_normal.png",
		--disableFile = "res/image/common/btn/btn_guildWar_normal.png"
	})
	closeBtn:setTouchEndedCallback(function ()
		XTHDTOAST("修罗炼狱未在开启时间内！")
	end)

	-- 未开启
	local challengeLabel = XTHDLabel:createWithParams({
		text = "未开启",
		fontSize = 24,
		color = cc.c3b(255,255,255)
	})

	-- local challengeSprite=cc.Sprite:create("res/image/common/btn/btn_guildWar_normal.png")
	closeBtn:setPosition(self:getBoundingBox().width * 0.5, arenaDesc:getPositionY() - 70)
	self:addChild(closeBtn)

	challengeLabel:setPosition(self:getBoundingBox().width * 0.5, arenaDesc:getPositionY() - 70)
	self:addChild(challengeLabel)

	challengeBtn:setPosition(self:getBoundingBox().width*0.5,arenaDesc:getPositionY()-70)
	self:addChild(challengeBtn)
	challengeBtn.isSending = false

	challengeBtn:setTouchEndedCallback(function ()
		if challengeBtn.isSending then
			return
		end
		self:sendArenaState(true)
		challengeBtn.isSending = true
		performWithDelay(challengeBtn, function()
			challengeBtn.isSending = false
		end, 1)
	end)

	-- 未开启
	if data.openState == 0 then
		challengeBtn:setVisible(false)
		challengeLabel:setVisible(true)
		closeBtn:setVisible(true)
	else
		challengeBtn:setVisible(true)
		challengeLabel:setVisible(false)
		closeBtn:setVisible(false)
	end

	local challengeTime = cc.Sprite:create("res/image/daily_task/arena/challenge_time.png")
	challengeTime:setAnchorPoint(0,0.5)
	local timeLeft = XTHDLabel:createWithParams({
		text = data.asuraTimes,
		fontSize = 24,
		color = cc.c3b(255,255,255)
	})
	timeLeft:setAnchorPoint(0,0.5)
	challengeTime:setPosition((self:getBoundingBox().width-(timeLeft:getBoundingBox().width+challengeTime:getBoundingBox().width))*0.5,challengeBtn:getPositionY()-45)
	self:addChild(challengeTime)
	timeLeft:setPosition(challengeTime:getPositionX()+challengeTime:getBoundingBox().width,challengeTime:getPositionY())
	self:addChild(timeLeft)
	self.timeLeft = timeLeft
end

function XiuLuoLianYuLayer:startMatch()
	-- XTHDTOAST("匹配中...")
	if self._matchingBg then
		self._matchingBg:removeFromParent()
		self._matchingBg = nil
	end
	self._matchingBg = XTHDDialog:create(150)
    self:addChild(self._matchingBg)

    self._matchingBg:runAction(cc.Sequence:create(cc.DelayTime:create(30),cc.CallFunc:create(function ()
    	self:sendArenaState(false)
    	XTHDTOAST(LANGUAGE_TIPS_WORDS256)
    end)))

    local backBtn = XTHD.createCommonButton({
		btnColor = "write",
		isScrollView = false,
		musicFile = XTHD.resource.music.effect_btn_commonclose,
		text = LANGUAGE_BTN_KEY.quxiaopipei,
		fontSize = 22,
		anchor = cc.p(0.5, 0.5),
		pos = cc.p(self._matchingBg:getBoundingBox().width*0.5, self._matchingBg:getBoundingBox().height*0.5 - 90),
		endCallback = function()
			self:sendArenaState(false)
		end
	})
	backBtn:setScale(0.8)
	self._matchingBg:addChild(backBtn)

    local matchingToast = cc.Sprite:create("res/image/daily_task/arena/select_bg.png")
    matchingToast:setPosition(self._matchingBg:getBoundingBox().width*0.5,self._matchingBg:getBoundingBox().height*0.5)
    self._matchingBg:addChild(matchingToast)

    local matchingStr = cc.Sprite:create("res/image/daily_task/arena/matching.png")
    matchingStr:setPosition(matchingToast:getBoundingBox().width*0.5,matchingToast:getBoundingBox().height*0.5)
    matchingToast:addChild(matchingStr)
    
    matchingToast:setCascadeOpacityEnabled(true)
    matchingToast:setOpacity(0)
    matchingToast:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1,255),cc.FadeTo:create(1,50))))
end

function XiuLuoLianYuLayer:refreshTime(data)
	self.timeLeft:setString(data)
end

function XiuLuoLianYuLayer:sendArenaState( isStart )
	local object = SocketSend:getInstance()
	if object then 
		local p
		if isStart then
			p = MsgCenter.MsgType.CLIENT_REQUEST_ARENASTART
		else
			p = MsgCenter.MsgType.CLIENT_REQUEST_ARENASTOP
		end
		object:send(p)
	end 
end

function XiuLuoLianYuLayer:create(data)
	return XiuLuoLianYuLayer.new(data)
end

function XiuLuoLianYuLayer:onEnter( )
	-----------引导
	YinDaoMarg:getInstance():addGuide({index = 4,parent = self},20)
    YinDaoMarg:getInstance():doNextGuide()
end

return XiuLuoLianYuLayer
