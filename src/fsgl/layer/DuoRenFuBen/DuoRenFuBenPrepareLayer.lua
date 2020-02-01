--[[
--------玩家创建了队伍之后的准备页面,当前已在队伍里的玩家进来，始终显示在第2个台子上
]]
IS_MULTICOPYPREPARELAYER_EXIT = false

local DuoRenFuBenPrepareLayer = class("DuoRenFuBenPrepareLayer",function( )
	return XTHDDialog:create()
end)
---_type == 1 玩家创建队伍进来的，否则是加入队伍进来的
function DuoRenFuBenPrepareLayer:ctor(params)
	isInTeam = true
    IS_MULTICOPYPREPARELAYER_EXIT = true
	self._selfRoleID = params.id
	self._parent = params.parent
    self._createType = params._type -----1 是队长创建进来的,否则是加入进来的
    self._copyFrontID = params.fristID --------当前进入的副本ID，副本配置表里的第一列ID
    self._preTeamData = params.previouseTeam ----当前队伍里原来的其它成员
    self._didPrepared = false -----玩家是否准备了

    self._localData = gameData.getDataFromCSV("TeamCopyList",{id = self._copyFrontID})
    self._isBeginFight = false ------是否开战

    self._changeHeroStage = nil ----更换英雄时点击的台子
    self._inviteBtn = nil -----世界邀请按钮
    self._prepareBtn = nil ------准备按钮

    self._worldInviteCD = 0 -------世界邀请的CD

    self._memberData = {} ----其它成员数据 
    self._isCaptain = false -----是否是队长
    --[[
        ///_stage 放英雄的台子 ，它有属性
        {   hasHero             = 是否有玩家加入,
            hasPortrait         = 是否有英雄头像
            heroName            = 当前玩家的名字
            available           = 是否可用（跟该副本允许上多少英雄有关）,
            fightVIMIcon        = 战斗力的图标,
            fightVIMVal         = 战斗力的值,
            button              = 台子下面的按钮（调整、踢人）
            btnWord             = button按钮上面的字,
            prepareBg           = 当前玩家准备好的背景
            captainIcon         = 队长图标
            roleID              = 当前这个台子上放的玩家ID}            
    ]]
    self._heroStage = {} -----英雄的平台 

    self.Tag = {
        ktag_heroPlaceHolder = 100,
        ktag_speekOutWordBg = 101,
        ktag_actionSchedule = 102,
    }
    if self._createType == 1 then -----如果是队长直接创建的
        self._isCaptain = true
    end 
    --开始注册点击事件
    local function touchBegan( touch,event )
        return true
    end
    self._listener = cc.EventListenerTouchOneByOne:create()
    self._listener:setSwallowTouches(true)
    self._listener:registerScriptHandler(touchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._listener, self)
    -------------------------------------------------------------------------------------------
    self:registerNotification()
end

function DuoRenFuBenPrepareLayer:create(params)
	local layer = DuoRenFuBenPrepareLayer.new(params)
	if layer then 
		layer:init()
	end 
	return layer
end

function DuoRenFuBenPrepareLayer:onCleanup( )	
    IS_MULTICOPYPREPARELAYER_EXIT = false
    LayerManager.removeChatRoom(LiaoTianRoomLayer.Functions.MultiplyCopy)    
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_MULTICOPY_PREPAREHERO) 
    XTHD.removeEventListener(CUSTOM_EVENT.ADDNEWMEMBERTOTEAM)
    XTHD.removeEventListener(CUSTOM_EVENT.SOMEONEHASLEFT)
    XTHD.removeEventListener(CUSTOM_EVENT.SWITCHCMULTICAPTAIN)
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESHPREPARESTATUS)    
    XTHD.removeEventListener(CUSTOM_EVENT.BATTLECANGETIN)  
    XTHD.removeEventListener(CUSTOM_EVENT.DISPLAY_PLAYER_SPEEK)      
    XTHD.removeEventListener(CUSTOM_EVENT.SHOW_CHAT_REDDOT_AT_MULTICOPYT)

    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/multiCopy/copy_prepare_bg.png")
    textureCache:removeTextureForKey("res/image/multiCopy/copy_speekword_bg.png")
    textureCache:removeTextureForKey("res/image/multiCopy/copy_stone_stage.png")
    textureCache:removeTextureForKey("res/image/multiCopy/copy_bubble1.png")
    textureCache:removeTextureForKey("res/image/multiCopy/copy_bubble2.png")
    textureCache:removeTextureForKey("res/image/multiCopy/copy_unkown_bg2.png")
end

function DuoRenFuBenPrepareLayer:init( )
	local bg = cc.Sprite:create("res/image/plugin/weaponshop/bg.jpg")
	self:addChild(bg)
	bg:setContentSize(cc.Director:getInstance():getWinSize())
	bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	------暗色背景
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,(0xff / 2)),self:getContentSize().width,self:getContentSize().height)
    self:addChild(layer)
    -----退出按钮
    local _backBtn = XTHD.createButton({
        normalNode = "res/image/common/btn/mult_back.png",
        selectedNode = "res/image/common/btn/mult_back.png",
    })
    self:addChild(_backBtn)
    _backBtn:setScale(0.8)
    _backBtn:setPosition(self:getContentSize().width - 50,self:getContentSize().height - _backBtn:getBoundingBox().height / 2 - 10)
    _backBtn:setTouchEndedCallback(function( )
    	self:doBackBtn()
    end)
    ------聊天按钮
    LayerManager.addChatRoom({sType = LiaoTianRoomLayer.Functions.MultiplyCopy})
    -----标题条
    local _titleBg = cc.Sprite:create("res/image/multiCopy/copy_unkown_bg2.png")
    self:addChild(_titleBg)
    _titleBg:setPosition(self:getContentSize().width / 2,self:getContentSize().height - _titleBg:getContentSize().height)
    -----副本名字
    local _copyName = cc.Sprite:create("res/image/multiCopy/copy_name"..self._localData.fbtype..".png")
    _titleBg:addChild(_copyName)
    _copyName:setAnchorPoint(0,0.5)
    ----难度
    local str = string.format("(%s)",LANGUAGE_MULTICOPY_DIFFICULTY[self._localData.nandu])
    local _difficulty = XTHDLabel:createWithSystemFont(str,XTHD.SystemFont,16)
    _difficulty:setColor(cc.c3b(253,229,51))
    _titleBg:addChild(_difficulty)
    _difficulty:setAnchorPoint(0,0.5)
    ----提示语
    local tips = XTHDLabel:createWithSystemFont(self._localData.shuoming,XTHD.SystemFont,20)
    tips:setColor(cc.c3b(255,168,0))
    _titleBg:addChild(tips)
    tips:setAnchorPoint(0,0.5)
    local x = _copyName:getContentSize().width + _difficulty:getContentSize().width + tips:getContentSize().width
    x = (_titleBg:getContentSize().width - x) / 2
    _copyName:setPosition(x - 20,_titleBg:getContentSize().height / 2)
    _difficulty:setPosition(x -20 + _copyName:getContentSize().width,_copyName:getPositionY())
    tips:setPosition(_difficulty:getPositionX() + _difficulty:getContentSize().width,_difficulty:getPositionY())    
    -------开战
    local _prepareBtn = XTHD.createCommonButton({
        btnColor = "write",
        btnSize = cc.size(135, 46),
        isScrollView = false,
        text = LANGUAGE_KEY_PREPARE,
        fontSize = 26,
        fontColor = cc.c3b(255,255,255),
    })
    _prepareBtn:setScale(1)
    self:addChild(_prepareBtn)
    _prepareBtn:setTouchEndedCallback(function( )
        self:doFightOrPrepare(_prepareBtn)
    end)
    _prepareBtn:setPosition(self:getContentSize().width - _prepareBtn:getContentSize().width / 2 - 10,_prepareBtn:getContentSize().height / 2 + 10)
    _prepareBtn.btnWord = _prepareBtn:getLabel()
    _prepareBtn._type = "prepare"
    if self._isCaptain then 
        _prepareBtn._type = "fight"
        _prepareBtn.btnWord:setString(LANGUAGE_KEY_DOFIGHT)    
    end 
    self._prepareBtn = _prepareBtn
    ------世界频道邀请
    local _inviteBtn = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(90,46),
        isScrollView = false,
        text = LANGUAGE_TIPS_WORDS266,
        fontColor = cc.c3b(255,255,255),
        fontSize = 22,
    })
    _inviteBtn:setScaleY(1.0)
    _inviteBtn:setScaleX(1.0)
    self:addChild(_inviteBtn)
    _inviteBtn:setTouchEndedCallback(function( )
        self:doInviteOthersInWorld()
    end)
    _inviteBtn:setPosition(_prepareBtn:getPositionX() - _prepareBtn:getContentSize().width - 10,_prepareBtn:getPositionY())
    self._inviteBtn = _inviteBtn
    _inviteBtn:setVisible(self._isCaptain)
    -----喊话按钮
    local _chatBtn = XTHD.createPushButtonWithSound({
    	normalFile = "res/image/multiCopy/copy_bubble1.png",
    	selectedFile = "res/image/multiCopy/copy_bubble2.png",    	
    },3)
    self:addChild(_chatBtn)
    _chatBtn:setTouchEndedCallback(function( )
    	local layer = requires("src/fsgl/layer/DuoRenFuBen/DuoRenFuBenSpeekWord.lua"):create(_chatBtn,self)
    	self:addChild(layer)
    end)
    -- local _word = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_WORDS267,XTHD.SystemFont,18)
    -- _word:setColor(cc.c3b(160,76,43))
    -- _word:setWidth(40)
    -- _chatBtn:addChild(_word)
    -- _word:setPosition(_chatBtn:getContentSize().width / 2,_chatBtn:getContentSize().height / 2 + 7)
    _chatBtn:setPosition(_chatBtn:getContentSize().width / 2 + 10,_chatBtn:getContentSize().height / 2 + 10)

    self:initHeros()    
    self:createOtherHero()
    self:createSelfHero()
end

-----初始化队友们
function DuoRenFuBenPrepareLayer:initHeros( )
	for i = 1,5 do 
		local _stage = cc.Sprite:create("res/image/multiCopy/copy_stone_stage.png")
		self:addChild(_stage)
		if i == 1 then 
			_stage:setPosition(_stage:getContentSize().width / 2 + 30,_stage:getContentSize().height + 120)
		elseif i == 2 then 
			_stage:setPosition(self:getContentSize().width / 2,_stage:getContentSize().height + 120)
		elseif i == 3 then 
			_stage:setPosition(self:getContentSize().width - _stage:getContentSize().width / 2 - 30,_stage:getContentSize().height + 120)
		elseif i == 4 then 
			_stage:setPosition(self:getContentSize().width * 1/3 - 25,self:getContentSize().height / 2 + _stage:getContentSize().height * 1/3 - 10)
		elseif i == 5 then 
			_stage:setPosition(self:getContentSize().width * 2/3 + 25,self:getContentSize().height / 2 + _stage:getContentSize().height * 1/3 - 10)
		end 
        self._heroStage[i] = _stage
        ----名字
        local _heroName = XTHDLabel:createWithSystemFont(gameUser.getNickname(),XTHD.SystemFont,16)
        _stage:addChild(_heroName,2)
        _heroName:setPosition(_stage:getContentSize().width / 2,_stage:getContentSize().height / 2 + 195)
        _stage.heroName = _heroName
        _heroName:setVisible(false)
        ------队长图标
        local _captainIcon = cc.Sprite:create("res/image/common/captain_icon.png")
        _captainIcon:setVisible(false)
        _stage:addChild(_captainIcon,2)
        _captainIcon:setAnchorPoint(1,0.5)
        _stage.captainIcon = _captainIcon
		-------没人
        local _holder = XTHDImage:create("res/image/multiCopy/copy_null_holder.png")
		_stage:addChild(_holder,1,self.Tag.ktag_heroPlaceHolder)
		_holder:setAnchorPoint(0.5,0)
		_holder:setPosition(_stage:getContentSize().width / 2+20,_stage:getContentSize().height * 2/3 - 5)
		_holder:setTouchEndedCallback(function( )
            self:doStageClicked(_holder)
            -- self:doInviteFriends(_holder)
		end)
        _holder.canInvite = true
        _holder.isInviteHost = true

        _stage.hasHero = false
        _stage.hasPortrait = false
        _stage.available = false
        ------准备背景
        local _prepareBg = cc.Sprite:create("res/image/multiCopy/copy_prepare_bg.png")
        _stage:addChild(_prepareBg,5)
        _prepareBg:setPosition(_stage:getContentSize().width / 2,_stage:getContentSize().height + _prepareBg:getContentSize().height)
        _stage.prepareBg = _prepareBg
        _prepareBg:setVisible(false)
        ----上面的字
        local _word = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_PREPARED,XTHD.SystemFont,18)
        _word:setColor(cc.c3b(255,252,0))
        _word:enableShadow(cc.c4b(255,252,0,0xff),cc.size(1,0))
        _prepareBg:addChild(_word)
        _word:setPosition(_prepareBg:getContentSize().width / 2,_prepareBg:getContentSize().height / 2)
        _prepareBg.word = _word
        if i <= self._localData.limit then  ---------英雄上限
            _stage.available = true
    		----plus 
    		local _plus = cc.Sprite:create("res/image/multiCopy/copy_yellowplus.png")
    		_holder:addChild(_plus)
    		_plus:setAnchorPoint(0.5,0)
    		------邀请好友
    		local _tips = XTHDLabel:create(LANGUAGE_TIPS_WORDS268,26,"res/fonts/def.ttf")
            _tips:setColor(cc.c3b(238,219,187))
            _tips:enableOutline(cc.c4b(0,0,0,255),2)
    		_holder:addChild(_tips)
    		_holder:setAnchorPoint(0.5,0)

    		local y = _plus:getContentSize().height + _tips:getContentSize().height
    		y = (_holder:getContentSize().height - y) / 2		
    		_tips:setPosition(_holder:getContentSize().width / 2 -30,y)
            _plus:setPosition(_tips:getPositionX(),_tips:getPositionY() + _tips:getContentSize().height)
            --战力背景
            local zl_bg = cc.Sprite:create("res/image/common/zl_bg.png")
            _stage:addChild(zl_bg)
            zl_bg:setAnchorPoint(0,0.5)
            _stage.zl_bg = zl_bg
            zl_bg:setVisible(false)
            -----战斗力
            local _icon = cc.Sprite:create("res/image/common/fightValue_Image.png")
            _icon:setAnchorPoint(0,0.5)
            _icon:setScale(0.85)
            _stage:addChild(_icon)
            _stage.fightVIMIcon = _icon
            _icon:setVisible(false)
            ----值 
            local _val = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt",10000)
            _val:setAnchorPoint(0,0.5)
            _val:setAdditionalKerning(-2)
            _val:setScale(0.65)
            _stage:addChild(_val)        
            _stage.fightVIMVal = _val
            _val:setVisible(false)
            local x = _icon:getBoundingBox().width + _val:getBoundingBox().width
            x = (_stage:getContentSize().width - x) / 2
            _icon:setPosition(x-10,_stage:getContentSize().height / 2-35)
            zl_bg:setPosition(x-20,_stage:getContentSize().height / 2-35)
            _val:setPosition(x + _icon:getBoundingBox().width+10,_icon:getPositionY() - 5)
            -------台子下面的按钮
            local _button = XTHD.createCommonButton({
                btnColor = "write_1",
                isScrollView = false,
                text = LANGUAGE_MULTICOPY_TIPS4,
                fontColor = cc.c3b(255,255,255),
                fontSize = 26,
            })
            _button:setScale(0.6)
            _button:setVisible(false)
            _button:setAnchorPoint(0.5,1)
            _stage:addChild(_button)
            -- _button:setScale(0.8)
            _button:setTouchEndedCallback(function( )
                self:doStageBelowBtn(_button)
            end)
            _button:setPosition(_stage:getContentSize().width / 2,_icon:getPositionY() - _icon:getContentSize().height / 2 + 2)
            _button._type = "kick"
            _stage.button = _button
            ------字
            _stage.btnWord = _button:getLabel()
        else
            local _cannotIcon = cc.Sprite:create("res/image/imgSelHero/battleHeroType_jin.png")
            _holder:addChild(_cannotIcon)
            _cannotIcon:setPosition(_holder:getContentSize().width / 2,_holder:getContentSize().height / 2)
            _holder.canInvite = false
        end 
	end 
end
-----创建其它玩家
function DuoRenFuBenPrepareLayer:createOtherHero( )
    if self._preTeamData then 
        local i = 1
        for k,v in pairs(self._preTeamData) do 
            i = (k > 1) and (k + 1) or k            
            if v.heroID > 0 then 
                self:createHeroSpine(self._heroStage[i],v.heroID,v.name,v.isCaptain,v.fightVim)
                self:displayMembersPrepare({roleID = v.roleID,prepare = (v.didPrepare == 1)},i)
            else 
                self:createANoneOtherHero({playerName = v.name,roleID = v.roleID,index = i})
            end 
            self._heroStage[i].roleID = v.roleID
            if self._isCaptain then 
                self._heroStage[i].button:setVisible(true)
                self._heroStage[i].button._type = "kick"
                self._heroStage[i].btnWord:setString(LANGUAGE_MULTICOPY_TIPS4)
            end 
        end 
    end 
end
-------创建自己
function DuoRenFuBenPrepareLayer:createSelfHero( )
    local stage = self._heroStage[2]
    if stage then 
        stage.button:setVisible(true)
        stage.button._type = "switch"
        stage.btnWord:setString(LANGUAGE_KEY_ADJUST) 
        stage.hasHero = true
        stage.roleID = gameUser.getUserId()
        if self._selfRoleID < 1 then 
            stage.heroName:setVisible(true)
            local targ = stage:getChildByTag(self.Tag.ktag_heroPlaceHolder)
            if targ then 
                targ:removeAllChildren()
                local _plus = cc.Sprite:create("res/image/multiCopy/copy_plus.png")
                targ:addChild(_plus)
                _plus:setPosition(targ:getContentSize().width / 2 -30,targ:getContentSize().height / 2 + 8)
                ----字
                local _word = XTHDLabel:create(LANGUAGE_KEY_SETHERO,26,"res/fonts/def.ttf")
                _word:enableOutline(cc.c4b(0,0,0,255),2)
                _word:setColor(cc.c3b(0,254,12))
                targ:addChild(_word)
                _word:setPosition(_plus:getPositionX(),_plus:getPositionY() - _plus:getContentSize().height + 3)
                ----动画 
                local time = 1.0
                local scale1 = cc.ScaleTo:create(time,1.1)
                local scale2 = cc.ScaleTo:create(time,1.0)
                _plus:runAction(cc.RepeatForever:create(cc.Sequence:create(scale1,scale2)))
                targ.isInviteHost = false
            end 
        else
            local _heroData = DBTableHero.getDataByID(self._selfRoleID)
            self:createHeroSpine(stage,self._selfRoleID,gameUser.getNickname(),self._isCaptain,_heroData.power)
        end 
    end 
end
------当有新成员加进来，但是还没有设置头像的时候 
function DuoRenFuBenPrepareLayer:createANoneOtherHero(data)
    local function setAPosition(target)
        if target then ----没有英雄 
            if self._isCaptain then            
                target.button:setVisible(true)
                target.button._type = "kick"
                target.btnWord:setString(LANGUAGE_MULTICOPY_TIPS4)
            end 
            target.heroName:setString(data.playerName)
            target.heroName:setVisible(true)
            target.hasHero = true
            target.roleID = data.roleID
            target = target:getChildByTag(self.Tag.ktag_heroPlaceHolder)
            if target then 
                target.canInvite = false
                target:removeAllChildren()
                local _plus = cc.Sprite:create("res/image/multiCopy/copy_plus.png")
                target:addChild(_plus)
                _plus:setPosition(target:getContentSize().width / 2 -30,target:getContentSize().height / 2 + 8)
                ----字
                local _word = XTHDLabel:create(LANGUAGE_KEY_SETHERO,26,"res/fonts/def.ttf")
                _word:enableOutline(cc.c4b(0,0,0,255),2)
                _word:setColor(cc.c3b(0,254,12))
                target:addChild(_word)
                _word:setPosition(_plus:getPositionX(),_plus:getPositionY() - _plus:getContentSize().height + 3)
                ----动画 
                local time = 1.0
                local scale1 = cc.ScaleTo:create(time,1.1)
                local scale2 = cc.ScaleTo:create(time,1.0)
                _plus:runAction(cc.RepeatForever:create(cc.Sequence:create(scale1,scale2)))
            end 
        end 
    end
    if data.index then 
        local targ = self._heroStage[data.index]
        setAPosition(targ)
    else 
        for k,v in pairs(self._heroStage) do 
            if not v.hasHero then ----没有英雄 
                setAPosition(v)
                break
            end 
        end 
    end 
end
--------刷新成员里某个玩家的肖像
function DuoRenFuBenPrepareLayer:refreshOtherHeroProtrait(data)
    local targ = nil
    for k,v in pairs(self._heroStage) do 
        if v.roleID == data.roleID then 
            targ = v
            break
        end 
    end 
    if targ then 
        self:createHeroSpine(targ,data.heroID,nil,nil,data.fightVIM)
    end 
end
----退出按钮
function DuoRenFuBenPrepareLayer:doBackBtn( )
    local layer = XTHDConfirmDialog:createWithParams({
        msg = LANGUAGE_MULTICOPY_TIPS14, ----你确定离开队伍么？
        rightCallback = function( )
			isInTeam = false
            local object = SocketSend:getInstance()
            if object then 
                object:send(MsgCenter.MsgType.CLIENT_REQUEST_EXITMULTITEAM) ---退出队伍
            end 
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MULTICOPY_TEAMS}) -----刷新当前副本里的队伍
            LayerManager.removeLayout(self)
        end,
    })
    self:addChild(layer,10)
end

function DuoRenFuBenPrepareLayer:doStageClicked( sender )
    print("the sender isInviteHost is",sender.isInviteHost,sender.canInvite)
    if sender and sender.isInviteHost then -------是否是邀请
        self:doInviteFriends(sender)
    else
        if self._didPrepared then 
            XTHDTOAST(LANGUAGE_MAINCITY_TIPS15) ----准备之后就不能换人了
        else 
            local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua"):createWithParams({
                battle_type = BattleType.MULTICOPY_DEFENCE,     --战斗类型
                heroId = self._selfRoleID,
                heroQuiltyLimit = self._localData.limitRank,
                instancingid = self._copyFrontID,
            })       
            fnMyPushScene(_layer)
        end 
    end 
end

function DuoRenFuBenPrepareLayer:doFightOrPrepare(sender)
    local object = SocketSend:getInstance()
    if sender._type == "fight" and self._isBeginFight == false then
        local _heroAmount = 0
        for k,v in pairs(self._heroStage) do 
            if v.hasHero == true then 
                _heroAmount = _heroAmount + 1
            end 
        end 
        --现在改为一个人也可以开战
        -- if _heroAmount < 2 then 
        --     XTHDTOAST(LANGUAGE_MULTICOPY_TIPS17) -----一个人无法挑战 
        --     return
        -- end 
        if object then 
            object:send(MsgCenter.MsgType.CLIENT_REQUEST_DOFIGHT)
            self._isBeginFight = true
            object:addErrorFunc(6116,function(data) -----开战有人还没有准备
                self._isBeginFight = false
            end)
        end 
    elseif sender._type == "prepare" then 
        if self._heroStage[2].hasPortrait then ------自己有没有设置英雄
            if object then 
                object:writeChar(1)
                object:send(MsgCenter.MsgType.CLIENT_REQUEST_PREPARE)
            end 
            sender._type = "cancelPrepare"        
            sender.btnWord:setString(LANGUAGE_KEY_CANCELPREPARE)
        else 
            XTHDTOAST(LANGUAGE_MULTICOPY_TIPS13) ---------还没有设置英雄
        end 
        sender:setScale(1.0)
        sender:stopAllActions()
    elseif sender._type == "cancelPrepare" then 
        if object then 
            object:writeChar(0)
            object:send(MsgCenter.MsgType.CLIENT_REQUEST_PREPARE)
        end         
        sender._type = "prepare"    
        sender.btnWord:setString(LANGUAGE_KEY_PREPARE)
    end 
end

function DuoRenFuBenPrepareLayer:doInviteFriends(sender)  
    if sender.canInvite then 
        if self._isCaptain then
            requires("src/fsgl/layer/DuoRenFuBen/DuoRenFuBenInvite.lua"):create(self)
        else 
            XTHDTOAST(LANGUAGE_MULTICOPY_TIPS5)
        end 
    end 
end

function DuoRenFuBenPrepareLayer:doInviteOthersInWorld( )
    if self._worldInviteCD == 0 then 
        self._worldInviteCD = 1
        local object = SocketSend:getInstance()
        if object then 
            object:send(MsgCenter.MsgType.CLIENT_REQUEST_INVITEFROMWORLD)        
        end 
        schedule(self,function( )
            self._worldInviteCD = self._worldInviteCD + 1
            if self._worldInviteCD > 60 then 
                self:stopActionByTag(self.Tag.ktag_actionSchedule)
                self._worldInviteCD = 0
            end 
        end,1.0,self.Tag.ktag_actionSchedule)
        XTHDTOAST(LANGUAGE_MULTICOPY_TIPS12) -----邀请已经发送
    else
        XTHDTOAST(LANGUAGE_MULTICOPY_TIPS10) ------不能频繁发送
    end 
end
------点击调整/踢人按钮
function DuoRenFuBenPrepareLayer:doStageBelowBtn( sender )
    self._changeHeroStage = sender:getParent()
    if sender._type == "kick" then -----踢人  
        local object = SocketSend:getInstance()
        if object then 
            object:writeInt(self._changeHeroStage.roleID)
            object:send(MsgCenter.MsgType.CLIENT_REQUEST_KICKOUTSOMEONE)
        end 
    elseif sender._type == "switch" then ---r换人，
        if self._didPrepared then 
            XTHDTOAST(LANGUAGE_MAINCITY_TIPS15) ----准备之后就不能换人了
        else 
            local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua"):createWithParams({
                battle_type = BattleType.MULTICOPY_DEFENCE,     --战斗类型
                heroId = self._selfRoleID,
                heroQuiltyLimit = self._localData.limitRank,
                instancingid = self._copyFrontID,
            })       
            fnMyPushScene(_layer)
        end 
    end 
end
---------喊话
function DuoRenFuBenPrepareLayer:setSelectedWord( id )
    local object = SocketSend:getInstance()
    if object then 
        object:writeChar(id)
        object:send(MsgCenter.MsgType.CLIENT_REQUEST_MULTISPEEKOUT)
    end 
end
------显示喊话内容
function DuoRenFuBenPrepareLayer:showSpeekOutWords(data)
    for i = 1,#self._heroStage do 
        if data.roleID == self._heroStage[i].roleID then 
            if not self._heroStage[i]:getChildByTag(self.Tag.ktag_speekOutWordBg) then 
                local background = ccui.Scale9Sprite:create(cc.rect(22,37,1,1),"res/image/chatroom/chat_msg_bg1.png")
                background:setContentSize(cc.size(150,50))
                background:setScale(0.7)
                local word = XTHDLabel:createWithSystemFont(data.wordIndex,XTHD.SystemFont,22)
                word:setColor(cc.c3b(160,76,43))
                word:enableShadow(cc.c4b(160,76,43,0xff),cc.size(1,0))
                background:addChild(word)
                background.word = word
                word:setAnchorPoint(0,0.5)
                word:setPosition(15,background:getContentSize().height / 2)        
                self._heroStage[i]:addChild(background,2,self.Tag.ktag_speekOutWordBg)
                if i == 3 then 
                    background:setAnchorPoint(0,0.5)
                    background:setFlippedX(true)
                    word:setScaleX(-1)
                    word:setAnchorPoint(1,0.5)
                    background:setPosition(0,150)
                else 
                    background:setAnchorPoint(0,0.5)
                    background:setPosition(self._heroStage[i]:getContentSize().width - 30,150)
                end
                performWithDelay(self._heroStage[i],function( )
                    self._heroStage[i]:removeChildByTag(self.Tag.ktag_speekOutWordBg)
                end,3.0)
            else 
                local target = self._heroStage[i]:getChildByTag(self.Tag.ktag_speekOutWordBg)
                if target then
                    self._heroStage[i]:stopAllActions()
                    target.word:setString(LANGUAGE_MULTICOPY_SPEEKWORDS[data.wordIndex])
                    performWithDelay(self._heroStage[i],function( )
                        self._heroStage[i]:removeChildByTag(self.Tag.ktag_speekOutWordBg)
                    end,3.0)
                end 
            end 
        end 
    end 
end
------创建指定ID的英雄spine
function DuoRenFuBenPrepareLayer:createHeroSpine(stage,id,name,isCaptain,fightVim)
    if stage and id then 
        stage:removeChildByTag(self.Tag.ktag_heroPlaceHolder)
        local _path = "res/spine/"..string.format("%03d",id)
        local _spine = sp.SkeletonAnimation:createWithBinaryFile(_path..".skel",_path..".atlas",1.0)
        local _node = cc.Node:create()
        _spine:setAnimation(0,"idle",true)
        _spine:setScale(0.8)
        _node:addChild(_spine)
        stage:addChild(_node,0,self.Tag.ktag_heroPlaceHolder)
        stage.hasHero = true
        stage.hasPortrait = true
        _node:setPosition(stage:getContentSize().width / 2,stage:getContentSize().height - 20)
        -----
        stage.fightVIMVal:setString(fightVim)
        stage.fightVIMVal:setVisible(true)
        stage.fightVIMIcon:setVisible(true)
        stage.zl_bg:setVisible(true)
        if name then 
            stage.heroName:setString(name)
        end 
        stage.heroName:setVisible(true)
        if isCaptain and not stage.captainIcon:isVisible() then --------如果是队长，则在名字旁边显示队长图标
            local x,y = stage.heroName:getPosition()
            local size = stage.captainIcon:getContentSize()
            stage.heroName:setPositionX(x + size.width / 2)
            x,y = stage.heroName:getPosition()

            stage.captainIcon:setVisible(true)
            stage.captainIcon:setPosition(x - stage.heroName:getContentSize().width / 2,y)
        end 
    end 
end
-------某个玩家离队了,或者 被踢了
function DuoRenFuBenPrepareLayer:kickOutSomeone(id)
    if id == gameUser.getUserId() then ----如果是自己
        self:showBeKickedOutDialog()
    else 
        for k,v in pairs(self._heroStage) do 
            if v.roleID == id then 
                self:resetAStageToNone(k)
                break
            end 
        end 
    end 
end
------显示当自己被踢的时候的对话框
function DuoRenFuBenPrepareLayer:showBeKickedOutDialog( )
    local layer = XTHDConfirmDialog:createWithParams({
        msg = LANGUAGE_MULTICOPY_TIPS6, ----你被队长踢出去了
        rightCallback = function( )
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MULTICOPY_TEAMS}) -----刷新当前副本里的队伍
            LayerManager.removeLayout(self)
        end,
        leftVisible = false,
    })
    layer:getContainerLayer():setClickable(false)
    self:addChild(layer,10)
end
------队长变动
function DuoRenFuBenPrepareLayer:switchCaptain(data)
    for i = 1,#self._heroStage do 
        local targ = self._heroStage[i]
        if targ and targ.available then 
            if data.nowCaptain == targ.roleID then ----找到了新队长
                if i == 2 then 
                    self._isCaptain = true
                end 
                targ.prepareBg:setVisible(false)
                local x,y = targ.heroName:getPosition()
                local size = targ.captainIcon:getContentSize()
                targ.heroName:setPositionX(x + size.width / 2)
                x,y = targ.heroName:getPosition()

                targ.captainIcon:setVisible(true)                
                targ.captainIcon:setPosition(x - targ.heroName:getContentSize().width / 2,y)
            elseif data.preCaptain == targ.roleID then ----之前的队长位置
                self:resetAStageToNone(i)
            elseif i ~= 2 and targ.hasHero and self._isCaptain then
                targ.button._type = "kick"
                targ.button:setVisible(true)
            end 
        end 
    end 
    self._inviteBtn:setVisible(self._isCaptain)
    if self._isCaptain then 
        self._prepareBtn._type = "fight"  
        self._prepareBtn.btnWord:setString(LANGUAGE_KEY_DOFIGHT)
    end 
end
------将一个台子设置成没有英雄的时候（即初始状态 ）
function DuoRenFuBenPrepareLayer:resetAStageToNone(index)
    local target = self._heroStage[index]
    if target then 
        target:removeChildByTag(self.Tag.ktag_heroPlaceHolder)
        target.button:setVisible(false)
        target.heroName:setVisible(false)
        target.fightVIMIcon:setVisible(false)
        target.zl_bg:setVisible(false)
        target.fightVIMVal:setVisible(false)
        target.captainIcon:setVisible(false)
        target.prepareBg:setVisible(false)
        target.hasHero = false
        target.hasPortrait = false
        target.roleID = 0
        -------没人
        local _holder = XTHDImage:create("res/image/multiCopy/copy_null_holder.png")
        target:addChild(_holder,1,self.Tag.ktag_heroPlaceHolder)
        _holder:setAnchorPoint(0.5,0)
        _holder:setPosition(target:getContentSize().width / 2 ,target:getContentSize().height * 2/3 - 5)
        _holder:setTouchEndedCallback(function( )
            self:doStageClicked(_holder)
        end)
        _holder.canInvite = true
        _holder.isInviteHost = true
        ----plus 
        local _plus = cc.Sprite:create("res/image/multiCopy/copy_yellowplus.png")
        _holder:addChild(_plus)
        _plus:setAnchorPoint(0.5,0)
        ------邀请好友
        local _tips = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_WORDS268,XTHD.SystemFont,16)
        _tips:setColor(cc.c3b(254,227,0))
        _holder:addChild(_tips)
        _holder:setAnchorPoint(0.5,0)

        local y = _plus:getContentSize().height + _tips:getContentSize().height
        y = (_holder:getContentSize().height - y) / 2       
        _tips:setPosition(_holder:getContentSize().width / 2 -20,y)
        _plus:setPosition(_tips:getPositionX(),_tips:getPositionY() + _tips:getContentSize().height)
    end 
end
-------显示队友的准备状态 ,如果index 有意义。。。。
function DuoRenFuBenPrepareLayer:displayMembersPrepare(data,index)
    if not index then 
        for i = 1,#self._heroStage do 
            local targ = self._heroStage[i]
            if targ and targ.available then 
                if data.roleID == targ.roleID then ----找到了
                    targ.prepareBg:setVisible(data.prepare)
                    if data.roleID == gameUser.getUserId() then -----是自己
                        self._didPrepared = data.prepare
                    end 
                end 
            end 
        end 
    else 
        local targ = self._heroStage[index]
        if targ and targ.available then ----找到了 
            targ.prepareBg:setVisible(data.prepare)
            if data.roleID == gameUser.getUserId() then -----是自己
                self._didPrepared = data.prepare
            end 
        end 
    end 
end
------当前自己设置好英雄之后，右下角的准备按钮开始跳动
function DuoRenFuBenPrepareLayer:playPrepareBtnAction( )
    if not self._isScale and self._prepareBtn then 
        local time = 1.0
        local scale1 = cc.ScaleTo:create(time,0.9)
        local scale2 = cc.ScaleTo:create(time,0.8)
        self._prepareBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(scale1,scale2)))
        self._isScale = true
    end 
end

function DuoRenFuBenPrepareLayer:registerNotification()
    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_MULTICOPY_PREPAREHERO,callback = function( event )-----选好人了之后刷出选中的人（更换英雄 ）
        if event.data.heroId > 0 then  
            self._selfRoleID = event.data.heroId
            ------通知服务器更换英雄
            local object = SocketSend:getInstance()
            if object then 
                object:writeInt(self._selfRoleID)
                object:send(MsgCenter.MsgType.CLIENT_REQUEST_EXCHANGEROLEMULTI)
            end
            self:playPrepareBtnAction()
        end 
    end})
    XTHD.addEventListener({name = CUSTOM_EVENT.ADDNEWMEMBERTOTEAM,callback = function( event ) ----有新玩家加入 
        local _data = event.data
        if event.data.hasPortrait then ----有头像
            self:refreshOtherHeroProtrait(_data)
        else
            self:createANoneOtherHero(_data)
        end 
    end})
    XTHD.addEventListener({name = CUSTOM_EVENT.SOMEONEHASLEFT,callback = function( event ) ----踢出某个人 、或某人离队
        local roleID = event.data
        self:kickOutSomeone(roleID)
    end})
    XTHD.addEventListener({name = CUSTOM_EVENT.SWITCHCMULTICAPTAIN,callback = function( event ) ----更换队长
        local data = event.data
        self:switchCaptain(data)
    end})
    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESHPREPARESTATUS,callback = function( event ) ----刷新队友里准备、取消准备的状态 
        local data = event.data
        self:displayMembersPrepare(data)
    end})    
    XTHD.addEventListener({name = CUSTOM_EVENT.BATTLECANGETIN,callback = function( event ) ----可开战了
        self:getInBattle()
    end})    
    XTHD.addEventListener({name = CUSTOM_EVENT.DISPLAY_PLAYER_SPEEK,callback = function( event ) ----玩家喊话 
        local data = event.data
        self:showSpeekOutWords(data)
    end})
end

function DuoRenFuBenPrepareLayer:getInBattle( )
    local _battle_type = BattleType.MULTICOPY_FIGHT
    ClientHttp.http_StartChallenge(self, _battle_type, nil, function( sData)
        local teamListLeft = {}
        local teamListRight = {}
        local scene = cc.Scene:create()
        local battleLayer = requires("src/battle/BattleLayer.lua"):create()
        scene:addChild(battleLayer)

        local _instanceId = self._localData.id
        local battle_time = self._localData.time
        local sound = "res/sound/"..tostring(self._localData.bgm)..".mp3"
        local bgList = {}
        bgList[#bgList + 1] = "res/image/background/bg_"..self._localData.background..".jpg"

        for i,v in ipairs(sData.myTeam) do
            local _staticData = gameData.getDataFromCSV("GeneralInfoList", {["heroid"] = v.petId}) or {}
            v.attackrange = _staticData.attackrange 
            local animal = {id = v.petId, _type = ANIMAL_TYPE.PLAYER, data = v}
            teamListLeft[#teamListLeft + 1] = animal
        end
        table.sort(teamListLeft, function( a, b )
            local n1 = tonumber(a.data.attackrange) or 0
            local n2 = tonumber(b.data.attackrange) or 0
            return n1 < n2
        end)
        --[[--敌人的队伍]]
        local team = {}
        for i,v in ipairs(sData.monsters) do
            local animal = {id = v.monsterid, _type = ANIMAL_TYPE.MONSTER, monster = v}
            team[#team + 1] = animal
        end
        table.sort( team, function( a, b )
            local n1 = tonumber(a.monster.attackrange) or 0
            local n2 = tonumber(b.monster.attackrange) or 0
            return n1 < n2
        end)
        teamListRight.team = team


        local battleLayer = requires("src/battle/BattleLayer.lua"):create()
        local battleUILayer = BattleUIExploreLayer:create(_battle_type)
        local function endCallBack( params )
            ClientHttp.http_SendFightValidation(scene, function(data)--战报结果
                performWithDelay(battleLayer, function()
                    battleLayer:hideWithoutBg()
                    LayerManager.addShieldLayout()
                    -- 添加战斗结果界面
                    local _layer = requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoMultiCopyLayer.lua"):create(data)
                    scene:addChild(_layer)
                end, 1.5)
            end, function()
                createFailHttpTipToPop()
            end, params)
        end
        battleLayer:initWithParams({
            bgList          = bgList,
            bgm             = sound,
            instancingid    = _instanceId,
            teamListLeft    = {teamListLeft},
            teamListRight   = {teamListRight},
            battleType      = _battle_type,
            battleTime      = battle_time,
            battleEndCallback = endCallBack,
        })
        battleLayer:setUILay(battleUILayer)
        scene:addChild(battleLayer)
        scene:addChild(battleUILayer)
        LayerManager.removeLayout()
        LayerManager.removeLayout()
        cc.Director:getInstance():pushScene(scene)
        battleLayer:start()
    end)
end

return DuoRenFuBenPrepareLayer