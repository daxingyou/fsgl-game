--抢夺资源界面

local JingJiRobberyLayer = class("JingJiRobberyLayer",function ()
    return XTHD.createBasePageLayer()
end)

function JingJiRobberyLayer:ctor(data)
	self:initUI()
    self:setPlayerData(data)
    self:refreshRivals(data)
end

function JingJiRobberyLayer:initUI()
	-- local _notic_bg = self:getChildByName("_notic_bg")
	
	local bg = cc.Sprite:create("res/image/plugin/competitive_layer/player_rival_bg.png")
	bg:setAnchorPoint(0.5,0.5)
    bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height*0.5)
	bg:setContentSize(self:getContentSize().width,self:getContentSize().height - self.topBarHeight)
	
   -- bg:setScale(0.7)
    self._bg = bg
	self:addChild(bg)

	local playerBg = cc.Sprite:create("res/image/plugin/competitive_layer/player_bg.png")
	playerBg:setAnchorPoint(0,0.5)
    playerBg:setPosition(0, bg:getContentSize().height - playerBg:getContentSize().height)
    playerBg:setScale(0.7)
	bg:addChild(playerBg)
    self.playerBg = playerBg

    local playerPl = cc.Sprite:create("res/image/plugin/competitive_layer/panda_bg.png")
    playerPl:setAnchorPoint(0,0.5)
    playerPl:setPosition(10,bg:getBoundingBox().height/2)
    bg:addChild(playerPl)

    local rivalPl = cc.Sprite:create("res/image/plugin/competitive_layer/rival_pl.png")
    rivalPl:setAnchorPoint(1,1)
    rivalPl:setPosition(bg:getBoundingBox().x + bg:getBoundingBox().width, bg:getBoundingBox().height/2+70)
    bg:addChild(rivalPl)

	local robberyDown = cc.Sprite:create("res/image/plugin/competitive_layer/robbery_down.png")
	robberyDown:setAnchorPoint(0.5,0.5)
	robberyDown:setContentSize(self._bg:getContentSize().width,robberyDown:getContentSize().height*2)
	robberyDown:setPosition(self._bg:getContentSize().width * 0.5,0)
	bg:addChild(robberyDown)

    self.countDownLabel = getCommonWhiteBMFontLabel(30)
    self.countDownLabel:setAnchorPoint(0,0)
    self.countDownLabel:setPosition(20,robberyDown:getContentSize().height * 0.5)
    robberyDown:addChild(self.countDownLabel)

    local countStr = cc.Sprite:create("res/image/plugin/competitive_layer/count_down_str.png")
    countStr:setPosition(self.countDownLabel:getPositionX()+75,self.countDownLabel:getPositionY()+self.countDownLabel:getBoundingBox().height/2+7)
    robberyDown:addChild(countStr)

	local dif = (615-77)-(cc.Director:getInstance():getWinSize().height-77)
    local xdif = dif/math.tan(82.92)

    local rival_bg = cc.Sprite:create("res/image/plugin/competitive_layer/rival_bg.png")

    --地府背景位置
    self.rivalPos = cc.p(self._bg:getContentSize().width/2 + rival_bg:getContentSize().width*0.5 -5,robberyDown:getPositionY()+robberyDown:getBoundingBox().height + 13)

    -- 可抢夺次数
	local robberyTime = cc.Sprite:create("res/image/plugin/competitive_layer/robbery_time.png")
    robberyTime:setAnchorPoint(0,0.5)
	robberyTime:setPosition(self._bg:getContentSize().width - robberyTime:getContentSize().width - 180,self._bg:getContentSize().height - 100)
	robberyTime:setScale(1.5)
	self._bg:addChild(robberyTime)

	local robberyTimeBg = cc.Sprite:create("res/image/common/topbarItem_bg.png")
    robberyTimeBg:setAnchorPoint(0,0.5)
    robberyTimeBg:setPosition(robberyTime:getPositionX()+robberyTime:getBoundingBox().width+5,robberyTime:getPositionY())
    self._bg:addChild(robberyTimeBg)

    self.robberyTimeLabel = getCommonWhiteBMFontLabel("")
    -- self.robberyTimeLabel:setAnchorPoint(0,0.5)
    self.robberyTimeLabel:setPosition(robberyTimeBg:getBoundingBox().width/2-4,robberyTimeBg:getBoundingBox().height/2-7)
    robberyTimeBg:addChild(self.robberyTimeLabel)

    -- local challageBg = ccui.Scale9Sprite:create(cc.rect(18,22,1,1),"res/image/plugin/competitive_layer/btn_bg.png")
    -- challageBg:setContentSize(cc.size(225,65))
    -- challageBg:setPosition(self:getBoundingBox().width/2,robberyDown:getBoundingBox().height/2-3)
    -- self:addChild(challageBg)

    -- local challageBtn = XTHD.createCommonButton({
    --     btnColor = "green",
    --     btnSize = cc.size(212,48),
    --     musicFile = XTHD.resource.music.effect_btn_common,
    --     text = LANGUAGE_BTN_KEY.kaishitiaozhan,
    --     fontSize = 22,
    -- })
    --ly开始挑战按钮
    local challageBtn = XTHD.createButton({
        normalFile = "res/image/plugin/competitive_layer/starChalleng_up.png",
        selectedFile = "res/image/plugin/competitive_layer/starChalleng_down.png",
        })
    challageBtn:setPosition(self._bg:getContentSize().width/2,challageBtn:getContentSize().height * 0.5 -30)
    challageBtn:setScale(0.9)
    self._bg:addChild(challageBtn,6)

    challageBtn:setTouchEndedCallback(function ()
        --------
        YinDaoMarg:getInstance():guideTouchEnd()
        ------------------------------------
        LayerManager.addShieldLayout()
        local SelHeroLayer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua")
        local _layerHandler = SelHeroLayer:create(BattleType.PVP_CHALLENGE, nil, self.challageData);
        _layerHandler._challageData = self._challageData
        -- self:getParent():addChild(_layerHandler)
        LayerManager.removeLayout(self)
        fnMyPushScene(_layerHandler)
        -- self:removeFromParent()
    end)
    self._challageBtn = challageBtn

    -- local changeBg = cc.Sprite:create("res/image/plugin/competitive_layer/btn_bg.png")
    -- changeBg:setAnchorPoint(1,0.5)
    -- changeBg:setPosition(self:getBoundingBox().width-40,robberyDown:getBoundingBox().height/2-3)
    -- self:addChild(changeBg)

    local changeBtn = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(200,80),
        isScrollView = false,
        musicFile = XTHD.resource.music.effect_btn_common,
        text = "更换对手",
        fontSize = 22,
    })
	changeBtn:setScale(0.8)
    changeBtn:setPosition(self._bg:getContentSize().width *0.7 ,changeBtn:getContentSize().height * 0.5 - 20)
    self._bg:addChild(changeBtn)
    changeBtn:setTouchEndedCallback(function ()
        XTHDHttp:requestAsyncInGameWithParams({
            modules="changeStrong?",
            successCallback = function(changeStrong)
                if tonumber(changeStrong.result) == 0 then
                    XTHD.updateProperty(changeStrong.property)
                    self:refreshRivals(changeStrong)
                elseif tonumber(changeStrong.result) == 2000 then
                    XTHD.createExchangePop(3)
                else
                    XTHDTOAST(changeStrong.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
                end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end)

    --ly注视掉，效果图里面没有
    -- local goldBg = cc.Sprite:create("res/image/common/topbarItem_bg.png")
    -- goldBg:setScaleX(0.5)
    -- goldBg:setAnchorPoint(1,0.5)
    -- goldBg:setPosition(changeBtn:getPositionX()-changeBtn:getBoundingBox().width-5,changeBtn:getPositionY())
    -- self:addChild(goldBg)

    -- local consumeGold = getCommonWhiteBMFontLabel(gameUser.getLevel() * 2)
    -- consumeGold:setPosition(goldBg:getPositionX()-goldBg:getBoundingBox().width/2,goldBg:getPositionY()-7)
    -- self:addChild(consumeGold)

    -- local goldIcon = XTHD.createHeaderIcon(XTHD.resource.type.gold)
    -- goldIcon:setPosition(goldBg:getPositionX()-goldBg:getBoundingBox().width,goldBg:getPositionY()-2)
    -- self:addChild(goldIcon)

    self.rewardBg = cc.Sprite:create("res/image/plugin/competitive_layer/reward_bg.png")
    self.rewardBg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
    self:addChild(self.rewardBg)
    self.rewardBg:setScale(0.9)

    --可抢夺玩家资源文字
    local rewardTitle = cc.Sprite:create("res/image/plugin/competitive_layer/reward_title_str.png")
    rewardTitle:setAnchorPoint(0.5,1)
    rewardTitle:setPosition(self.rewardBg:getBoundingBox().width/2+10,self.rewardBg:getBoundingBox().height-10)
    self.rewardBg:addChild(rewardTitle)
end

--抢
function JingJiRobberyLayer:setPlayerData(data)

     --头像框
     local avatar_bg = cc.Sprite:create("res/image/plugin/competitive_layer/hero_board" .. gameUser.getCampID() ..".png")
    --  avatar_bg:setPosition(playerAvatar:getBoundingBox().width/2,playerAvatar:getBoundingBox().height/2)
    avatar_bg:setPosition(100,self.playerBg:getBoundingBox().height/2+20)
    self.playerBg:addChild(avatar_bg)

     --头像
    local playerAvatar = cc.Sprite:create(XTHD.resource.getHeroAvatorImgById(gameUser.getTemplateId()))
    playerAvatar:setAnchorPoint(0.5,0.5)
    -- playerAvatar:setPosition(40,self.playerBg:getBoundingBox().height/2+20)
    playerAvatar:setPosition(avatar_bg:getBoundingBox().width/2,avatar_bg:getBoundingBox().height/2-2)
    playerAvatar:setScale(1.05)
    avatar_bg:addChild(playerAvatar)

   

    local playerLevel = getCommonWhiteBMFontLabel(gameUser.getLevel())
    playerLevel:setAnchorPoint(1,0)
    playerLevel:setPosition(playerAvatar:getBoundingBox().width-5,-7)
    playerAvatar:addChild(playerLevel)

    --天庭昵称背景
    local n_bg1 = cc.Sprite:create("res/image/plugin/competitive_layer/n_bg" .. gameUser.getCampID() .. ".png")
    n_bg1:setAnchorPoint(0,1)
    n_bg1:setPosition(playerAvatar:getPositionX()+playerAvatar:getBoundingBox().width+30,playerAvatar:getPositionY()+playerAvatar:getBoundingBox().height/2+30)
    self.playerBg:addChild(n_bg1)
    --天庭昵称
    local playerName = XTHDLabel:createWithParams({
        text = gameUser.getNickname(),
        fontSize = 24,
        color = cc.c3b(155,0,0)
    })
    playerName:setAnchorPoint(0,1)
    playerName:setPosition(playerAvatar:getPositionX()+playerAvatar:getBoundingBox().width+50,playerAvatar:getPositionY()+playerAvatar:getBoundingBox().height/2+25)
    self.playerBg:addChild(playerName)

    local selfCampID = gameUser.getCampID()
    selfCampID = selfCampID == 0 and 1 or selfCampID
    local campIcon = cc.Sprite:create("res/image/common/camp_Icon_" .. selfCampID .. ".png")
    campIcon:setAnchorPoint(0,0)
    campIcon:setPosition(playerAvatar:getPositionX()+playerAvatar:getBoundingBox().width+20,playerAvatar:getPositionY()-playerAvatar:getBoundingBox().height/2-3+10)
    self.playerBg:addChild(campIcon)

    local campStr = cc.Sprite:create("res/image/plugin/competitive_layer/camp_str_"..selfCampID..".png")
    campStr:setAnchorPoint(0,0)
    campStr:setPosition(campIcon:getPositionX()+campIcon:getBoundingBox().width+20,campIcon:getPositionY()+30)
    self.playerBg:addChild(campStr)

    --ly天庭战力背景
    local zl_bg = cc.Sprite:create("res/image/common/zl_bg.png")
    zl_bg:setPosition(450,self.playerBg:getBoundingBox().height/2+3)
    self.playerBg:addChild(zl_bg)
--    --天庭战力
--    local powerSp = cc.Sprite:create("res/image/common/fightValue_Image.png")
--    powerSp:setPosition(380,self.playerBg:getBoundingBox().height/2+3)
--    self.playerBg:addChild(powerSp)

    --天庭战力值
    local powerNum = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt",data.maxPower)
    powerNum:setAnchorPoint(0,0.5)
    powerNum:setPosition(430,self.playerBg:getBoundingBox().height/2 - 3)
    self.playerBg:addChild(powerNum)

    self.robberyTimeLabel:setString(data.robberyTime)
end

function JingJiRobberyLayer:doCountDown(node)
    node:stopAllActions()
    node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function ()
        if node.cd <= 0 then
            node:stopAllActions()
            node:setString("")
            LayerManager.addShieldLayout()
            local SelHeroLayer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua")

            local _layerHandler = SelHeroLayer:create(BattleType.PVP_CHALLENGE, nil, self.challageData);
            _layerHandler._challageData = self._challageData
            -- self:getParent():addChild(_layerHandler)
            LayerManager.removeLayout(self)
            fnMyPushScene(_layerHandler)
            -- local SelHeroLayer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua")
            -- local challageData = self.challageData.rivals
            -- local _layerHandler = SelHeroLayer:create(BattleType.PVP_CHALLENGE, nil, challageData);
            -- -- self:getParent():addChild(_layerHandler)
            -- fnMyPushScene(_layerHandler)
            -- self:removeFromParent()
        end
        node:setString(getCdStringWithNumber(node.cd,{h = ":"}))
        node.cd = node.cd - 1
    end),cc.DelayTime:create(1))))
end

--被抢
function JingJiRobberyLayer:refreshRivals(data)
    self.countDownLabel:setString(getCdStringWithNumber(30,{h = ":"}))
    self.countDownLabel.cd = 30
    self:doCountDown(self.countDownLabel)
    if self.rivalBg then
        self.rivalBg:removeFromParent()
        self.rivalBg = nil
    end
    self.rivalBg = cc.Sprite:create("res/image/plugin/competitive_layer/rival_bg.png")
    self.rivalBg:setAnchorPoint(0.5,0.5)
    self.rivalBg:setScale(0.7)
    self.rivalBg:setPosition(self._bg:getContentSize().width,self.rivalPos.y)
    self._bg:addChild(self.rivalBg)

    local rivalData = data.rivals[1]
    self.challageData = rivalData
    self._challageData = data

    --地府头像框
    local avatar_bg = cc.Sprite:create("res/image/plugin/competitive_layer/hero_board" .. rivalData.campId ..".png")
    -- avatar_bg:setPosition(rivalAvatar:getBoundingBox().width/2,rivalAvatar:getBoundingBox().height/2)
    avatar_bg:setPosition(150,self.playerBg:getBoundingBox().height/2+20)
    self.rivalBg:addChild(avatar_bg)


    --地府头像
    local rivalAvatar = cc.Sprite:create(XTHD.resource.getHeroAvatorImgById(rivalData.templateId))
    rivalAvatar:setAnchorPoint(0.5,0.5)
    -- rivalAvatar:setPosition(200,self.playerBg:getBoundingBox().height/2+20)
    rivalAvatar:setPosition(avatar_bg:getBoundingBox().width/2,avatar_bg:getBoundingBox().height/2-2)
    avatar_bg:addChild(rivalAvatar)
    rivalAvatar:setScale(1.05)

    

    local rivalLevel = getCommonWhiteBMFontLabel(rivalData.level)
    rivalLevel:setAnchorPoint(1,0)
    rivalLevel:setPosition(rivalAvatar:getBoundingBox().width-5,-7)
    rivalAvatar:addChild(rivalLevel)

    --地府昵称背景
    local n_bg2 = cc.Sprite:create("res/image/plugin/competitive_layer/n_bg" .. rivalData.campId .. ".png")
    n_bg2:setAnchorPoint(0,1)
    n_bg2:setPosition(rivalAvatar:getPositionX()+rivalAvatar:getBoundingBox().width+80,rivalAvatar:getPositionY()+rivalAvatar:getBoundingBox().height/2+30)
    self.rivalBg:addChild(n_bg2)
    --地府昵称
    local rivalName = XTHDLabel:createWithParams({
        text = rivalData.name,
        fontSize = 22,
        color = cc.c3b(155,0,0)
    })
    rivalName:setAnchorPoint(0,1)
    rivalName:setPosition(rivalAvatar:getPositionX()+rivalAvatar:getBoundingBox().width+100,rivalAvatar:getPositionY()+rivalAvatar:getBoundingBox().height/2+25)
    self.rivalBg:addChild(rivalName)

    local rivalCampStr = cc.Sprite:create("res/image/plugin/competitive_layer/camp_str_"..rivalData.campId..".png")
    rivalCampStr:setAnchorPoint(1,0)
    rivalCampStr:setPosition(rivalAvatar:getPositionX()+rivalAvatar:getBoundingBox().width+220,rivalAvatar:getPositionY()-rivalAvatar:getBoundingBox().height/2-3+40)
    self.rivalBg:addChild(rivalCampStr)

    local rivalCampIcon = cc.Sprite:create("res/image/common/camp_Icon_"..rivalData.campId..".png")
    rivalCampIcon:setAnchorPoint(1,0)
    rivalCampIcon:setPosition(rivalCampStr:getPositionX()+rivalCampStr:getBoundingBox().width-150,rivalCampStr:getPositionY()-20)
    self.rivalBg:addChild(rivalCampIcon)

     --ly天庭战力背景
     local zl_bg = cc.Sprite:create("res/image/common/zl_bg.png")
     zl_bg:setPosition(480,self.rivalBg:getBoundingBox().height/2+3)
     self.rivalBg:addChild(zl_bg)
    --战力
--    local powerSp = cc.Sprite:create("res/image/common/fightValue_Image.png")
--    powerSp:setPosition(20,zl_bg:getContentSize().height*0.5)
--    zl_bg:addChild(powerSp)

    --战力值
    local powerNum = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt",rivalData.teams[1].power)
    powerNum:setAnchorPoint(0,0.5)
    powerNum:setPosition(65,zl_bg:getContentSize().height*0.5 - 3)
   zl_bg:addChild(powerNum)

    if self.enemyTeamBtn then
        self.enemyTeamBtn:removeFromParent()
        self.enemyTeamBtn = nil
    end

    if self.teamBg then
        self.teamBg:removeFromParent()
        self.teamBg = nil
    end

    self.rivalBg:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,self.rivalPos),cc.CallFunc:create(function ()
        if self.addSilver then
            self.addSilver:removeFromParent()
        end
        if self.addFeicui then
            self.addFeicui:removeFromParent()
        end
        local function scaleNode(node,isShine)
            if isShine == true then
                local light = cc.Sprite:create("res/image/plugin/competitive_layer/reward_light.png")
                light:setPosition(node:getBoundingBox().width/2,node:getBoundingBox().height/2)
                node:addChild(light,-1)
                light:setOpacity(0)
                light:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.5),cc.FadeOut:create(0.5))))
            end
            node:setScale(0)
            node:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.15, 1.2),
                cc.ScaleTo:create(0.05, 1),
                cc.CallFunc:create(function()
                    node:setTouchShowTip(true)
                end)
            ))
        end
        self.addSilver = ItemNode:createWithParams({
            _type_ = XTHD.resource.type.gold,
            count = rivalData.addSilver,
            isShowCount = true,
            touchShowTip = false
        })
        -- self.addSilver:setAnchorPoint(0,0)
        self.addSilver:setPosition(self.addSilver:getBoundingBox().width/2+50,self.addSilver:getBoundingBox().height/2+20)
        self.rewardBg:addChild(self.addSilver)

        self.addFeicui = ItemNode:createWithParams({
            _type_ = XTHD.resource.type.feicui,
            count = rivalData.addFeicui,
            isShowCount = true,
            touchShowTip = false
        })
        -- self.addFeicui:setAnchorPoint(1,0)
        self.addFeicui:setPosition(self.rewardBg:getBoundingBox().width-self.addFeicui:getBoundingBox().width/2-30,self.addFeicui:getBoundingBox().height/2+20)
        self.rewardBg:addChild(self.addFeicui)
        scaleNode(self.addSilver,rivalData.addSilver >= gameUser.getLevel() * 80)
        scaleNode(self.addFeicui,rivalData.addFeicui >= gameUser.getLevel() * 80)

        local enemyTeamBtn = XTHD.createCommonButton({
            btnColor = "write_1",
            btnSize = cc.size(200,80),
            isScrollView = false,
            musicFile = XTHD.resource.music.effect_btn_common,
            text = LANGUAGE_BTN_KEY.checkLineup,
            fontSize = 22,
        })
        enemyTeamBtn:setScale(0.8)
        enemyTeamBtn:setAnchorPoint(0.5,0.5)
		enemyTeamBtn:setPosition(self._bg:getContentSize().width *0.85,enemyTeamBtn:getContentSize().height * 0.5 - 20)
        self._bg:addChild(enemyTeamBtn)
        self.enemyTeamBtn = enemyTeamBtn

        enemyTeamBtn:setTouchEndedCallback(function ()
            if self.teamBg then
                self.teamBg:removeFromParent()
                self.teamBg = nil
                return
            end

            self.teamBg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
            self.teamBg:setContentSize(cc.size(319,123))
            self.teamBg:setAnchorPoint(1,0)
            self.teamBg:setPosition(self.rivalBg:getPositionX()+self.rivalBg:getBoundingBox().width * 0.2 + 20,self:getContentSize().height *0.15 + self.teamBg:getContentSize().width *0.5)
            self:addChild(self.teamBg)

            local teamStr = cc.Sprite:create("res/image/plugin/competitive_layer/enemy_team.png")
            teamStr:setAnchorPoint(0.5,1)
            teamStr:setPosition(self.teamBg:getBoundingBox().width/2,self.teamBg:getBoundingBox().height-15)
            self.teamBg:addChild(teamStr)

            local heroBg = ccui.Scale9Sprite:create(cc.rect(20,20,1,1),"res/image/common/shadow_bg.png")
            heroBg:setOpacity(0)
            heroBg:setContentSize(cc.size(295,68))
            heroBg:setAnchorPoint(0.5,0)
            heroBg:setPosition(self.teamBg:getBoundingBox().width/2,10)
            self.teamBg:addChild(heroBg)

            local heros = data.rivals[1].teams[1].heros
            for i=1,5 do
                local _avator = nil
                if i <= #heros then
                    _avator = HeroNode:createWithParams({
                        heroid   = heros[i].petId,
                        advance = heros[i].phase,
                        star = heros[i].star,
                        level = heros[i].level,
                    })
                    _avator:setScale(0.58)
                else
                    _avator = cc.Sprite:create("res/image/common/no_hero.png")
                    -- _avator:setScale(0.94)
                    _avator:setScale(0.58)
                end
                -- _avator:setAnchorPoint(0.5,0)
                _avator:setPosition(XTHD.resource.getPosInArr({
                    lenth = 5,
                    bgWidth = 295,
                    num = 5,
                    nodeWidth = _avator:getBoundingBox().width,
                    now = i,
                }),heroBg:getBoundingBox().height/2)
                heroBg:addChild( _avator )
            end
        end)
    end)))
end

function JingJiRobberyLayer:create(data)
	return JingJiRobberyLayer.new(data)
end

function JingJiRobberyLayer:onEnter( )
     YinDaoMarg:getInstance():addGuide({index = 5,parent = self},9)
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self._challageBtn,-----排位赛设置防守队伍
        index = 6,
    },9)
    YinDaoMarg:getInstance():doNextGuide()
end

return JingJiRobberyLayer