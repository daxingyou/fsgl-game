--Created By Liuluyang 2015年08月07日(第一版2015年06月01日)
-- 神器界面
local ShenQiLayer = class("ShenQiLayer",function ()
	return XTHD.createBasePageLayer({
--		bg = "res/image/login/login_bg.png",
    })
end)

function ShenQiLayer:ctor(godid,ownArtifact,callback)
    self._exitCallback = callback
	self.isStop = false
	self._isIngjinjie = false
	self._godid = godid or ownArtifact[1].godid
	self:initUI() --创建固定UI
	self._isYiJianJinJie = false
    self._artifactData = gameData.getDataFromCSV("SuperWeaponUpInfo")
    self._ownArtifact = ownArtifact
    print("------ ownArtifact count ------"..#self._ownArtifact)
	self:refreshDataById(self._godid,self._ownArtifact) --创建数据
end

function ShenQiLayer:initUI()

--	local csbNode = cc.CSLoader:createNode("res/LoginLayer/LoginLayer.csb");
--	self:addChild(csbNode,10)

--	local aanimateLine = cc.CSLoader:createTimeline("res/LoginLayer/Node.csb");
--	aanimateLine:gotoFrameAndPlay(0, true);
--	csbNode:runAction(aanimateLine);

    self._topBar = self:getChildByName("TopBarLayer1") --userinfo
    --backGround
    local backGround = cc.Sprite:create("res/image/common/layer_bottomBg.png")
    -- backGround:setScale(0.75)
    backGround:setPosition(self:getContentSize().width/2, self:getContentSize().height/2 - self.topBarHeight/2)
    self:addChild(backGround)
    self._backGround = backGround
    local bsize=backGround:getContentSize()
	
	local title = "res/image/public/shenqi_title.png"
	XTHD.createNodeDecoration(self._backGround,title)

    --左边
    local leftBg = cc.Sprite:create()
    -- local leftBg = ccui.Scale9Sprite:create(cc.rect(5,5,1,1),"res/image/common/scale9_bg_14.png")
    leftBg:setContentSize(546,473)
    leftBg:setAnchorPoint(0,0)
    leftBg:setPosition(40, 18)
    backGround:addChild(leftBg)
    self._leftBg = leftBg

    --右边背景
    self._rightBg = XTHD.createSprite()
    -- self._rightBg = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_14.png")
    self._rightBg:setContentSize(cc.size(352,self._leftBg:getContentSize().height))
    self._rightBg:setAnchorPoint(1,0)
    self._rightBg:setPosition(bsize.width-32,18)
    backGround:addChild(self._rightBg)

    self:initLeft()
    self:initRight()
end

function ShenQiLayer:initLeft() 
    local leftArrow = XTHDPushButton:createWithParams({
        musicFile = XTHD.resource.music.effect_btn_common,
        normalFile = "res/image/plugin/saint_beast/leftArrow_up.png",
        selectedFile = "res/image/plugin/saint_beast/leftArrow_down.png",
        touchSize = cc.size(50, 60),
    })
    leftArrow:setAnchorPoint(0.5,0.5)
    leftArrow:setPosition(self._leftBg:getContentSize().width/2-160,self._leftBg:getContentSize().height/2+80)
    self._leftBg:addChild(leftArrow)

	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=26});
            self:addChild(StoredValue)
        end,
	})
	self._leftBg:addChild(help_btn)
	help_btn:setPosition(self._leftBg:getContentSize().width - help_btn:getContentSize().width / 2 + 35,self._leftBg:getContentSize().height - help_btn:getContentSize().height / 2 - 10)

    leftArrow:setTouchEndedCallback(function ()
		if self._isIngjinjie then
			XTHDTOAST("请先取消进阶")
			return
		end
        for i=1,#self._ownArtifact do
            if self._ownArtifact[i].godid == self._godid then
                if i == 1 then
                    self:refreshDataById(self._ownArtifact[#self._ownArtifact].godid)
                    return
                end
                self:refreshDataById(self._ownArtifact[i-1].godid)
                return
            end
        end
    end)

    leftArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.EaseInOut:create(cc.MoveBy:create(1,cc.p(-15,0)),1.5),
        cc.EaseInOut:create(cc.MoveBy:create(1,cc.p(15,0)),1.5)
    )))

    local rightArrow = XTHDPushButton:createWithParams({
        musicFile = XTHD.resource.music.effect_btn_common,
        normalFile = "res/image/plugin/saint_beast/rightArrow_up.png",
        selectedFile = "res/image/plugin/saint_beast/rightArrow_down.png",
        touchSize = cc.size(50, 60),
    })
    rightArrow:setAnchorPoint(0.5,0.5)
    rightArrow:setPosition(self._leftBg:getContentSize().width/2+160,self._leftBg:getContentSize().height/2+80)
    self._leftBg:addChild(rightArrow)

    rightArrow:setTouchEndedCallback(function ()
		if self._isIngjinjie then
			XTHDTOAST("请先取消进阶")
			return
		end
        for i=1,#self._ownArtifact do
            if self._ownArtifact[i].godid == self._godid then
                if i == #self._ownArtifact then
                    self:refreshDataById(self._ownArtifact[1].godid)
                    return
                end
                self:refreshDataById(self._ownArtifact[i+1].godid)
                return
            end
        end
    end)

    rightArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.EaseInOut:create(cc.MoveBy:create(1,cc.p(15,0)),1.5),
        cc.EaseInOut:create(cc.MoveBy:create(1,cc.p(-15,0)),1.5)
    )))

    local stage = cc.Sprite:create("res/image/plugin/saint_beast/stage.png")
    stage:setAnchorPoint(0.5,0)
    --台子缩放大小
    stage:setScale(0.8)
    stage:setPosition(self._leftBg:getContentSize().width/2, 90)
    self._leftBg:addChild(stage)
--    local light = cc.Sprite:create("res/image/plugin/saint_beast/light.png")
--     light:setAnchorPoint(0.5,0)
--     light:setPosition(stage:getContentSize().width/2, 50)
--     stage:addChild(light)


    self._changeBtn = XTHD.createCommonButton({
        btnColor = "write_1",
        text = LANGUAGE_BTN_KEY.change,
        isScrollView = false,
        fontSize = 26,
    })
    self._changeBtn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
    self._changeBtn:setPosition(155,150)
    self._leftBg:addChild(self._changeBtn)

    self._disboard = XTHD.createCommonButton({
        btnColor = "write",
        isScrollView = false,
        text = LANGUAGE_BTN_KEY.disboard,
        fontSize = 26,
    })
    self._disboard:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
    self._disboard:setPosition(390,150)
    self._leftBg:addChild(self._disboard)
    self._changeBtn:setScale(0.7)
    self._disboard:setScale(0.7)

    -- local artifactNameBg = cc.Sprite:create("res/image/plugin/saint_beast/artifact_name_bg.png")
    local artifactNameBg = cc.Sprite:create()
    artifactNameBg:setAnchorPoint(0.5,1)
    artifactNameBg:setPosition(self._leftBg:getContentSize().width/2,self._leftBg:getContentSize().height-23)
    self._leftBg:addChild(artifactNameBg)
    self._artifactNameBg = artifactNameBg

    --神器商店按钮
    local saintBeastChangeLayer = XTHDPushButton:createWithParams({
        musicFile = XTHD.resource.music.effect_btn_common,
        normalFile = "res/image/plugin/saint_beast/saint_beast_change_normal.png",
        selectedFile = "res/image/plugin/saint_beast/saint_beast_change_selected.png",
    })
    saintBeastChangeLayer:setTouchEndedCallback(function ()
        XTHD.createSaintBeastChange(self,function ()
            self:createConsume(self.consume1.nowCSV)
        end)
    end)
    saintBeastChangeLayer:setScale(0.8)
    saintBeastChangeLayer:setAnchorPoint(0,1)
    saintBeastChangeLayer:setPosition(-20,self._leftBg:getContentSize().height)
    self._leftBg:addChild(saintBeastChangeLayer)

    self._artifactName = XTHDLabel:createWithParams({
        text = "",
        fontSize = 20,
        color = cc.c3b(205,101,8)
    })
    self._artifactName:setAnchorPoint(0,0.5)
    
    self._artifactAdvance = XTHDLabel:createWithParams({
        text = "",
        fontSize = 22,
        color = cc.c3b(104,157,0)
    })
    self._artifactAdvance:setAnchorPoint(0,0.5)

    self._artifactName:setPosition((self._artifactNameBg:getBoundingBox().width-(self._artifactName:getBoundingBox().width+self._artifactAdvance:getBoundingBox().width))/2,self._artifactNameBg:getBoundingBox().height/2)
    self._artifactNameBg:addChild(self._artifactName)
    self._artifactAdvance:setPosition(self._artifactName:getPositionX()+self._artifactName:getBoundingBox().width,self._artifactName:getPositionY())
    self._artifactNameBg:addChild(self._artifactAdvance)

    self._artifactSp = cc.Sprite:create()
    -- self._artifactSp:setScale(0.7)
    self._artifactSp:setPosition(self._leftBg:getBoundingBox().width/2,self._leftBg:getBoundingBox().height/2+90)
    self._leftBg:addChild(self._artifactSp,1)

    -- local ownHeroBg = XTHD.createSprite("res/image/plugin/saint_beast/own_bg.png")
    -- ownHeroBg:setAnchorPoint(0.5,0)
    -- ownHeroBg:setPosition(self._leftBg:getContentSize().width/2, 10)
    -- self._leftBg:addChild(ownHeroBg)
end

function ShenQiLayer:initRight() 
    local splitY = ccui.Scale9Sprite:create("res/image/ranklistreward/splitY.png")
    splitY:setContentSize(2,400)
    splitY:setAnchorPoint(0,0.5)
    splitY:setRotation(180)
    splitY:setPosition(630, self._backGround:getContentSize().height/2)
    self._backGround:addChild(splitY)
    -- local line = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
    -- local line = ccui.Scale9Sprite:create("res/image/ranklistreward/splitX.png" )
    -- line:setContentSize(400,2)
    -- line:setRotation(90)
    -- line:setPosition(splitY:getPositionX()-splitY:getContentSize().width/2,self._backGround:getPositionY())
    -- self:addChild(line)

    --框
    local kuang1 = ccui.Scale9Sprite:create("res/image/common/sq_kuang.png")
    kuang1:setContentSize(self._rightBg:getContentSize().width-25,self._rightBg:getContentSize().height/2-40)
    kuang1:setPosition(self._rightBg:getBoundingBox().width/2+10, self._rightBg:getBoundingBox().height-15)
    kuang1:setAnchorPoint(0.5,1)
    self._rightBg:addChild(kuang1)

    local tableTitle = cc.Sprite:create("res/image/plugin/saint_beast/jcsx.png")
    tableTitle:setAnchorPoint(0.5,1)
    tableTitle:setPosition(kuang1:getContentSize().width/2+30, self._rightBg:getBoundingBox().height-5)
    self._rightBg:addChild(tableTitle)

    -- local tableTitleLabel = XTHDLabel:createWithParams({
    --     text = LANGUAGE_KEY_BASICPROP,---- "基本属性",
    --     fontSize = 18,
    --     color = XTHD.resource.color.brown_desc
    -- })
    -- tableTitleLabel:setPosition(tableTitle:getBoundingBox().width/2,tableTitle:getBoundingBox().height/2)
    -- tableTitle:addChild(tableTitleLabel)

    --框
    local kuang2 = ccui.Scale9Sprite:create("res/image/common/sq_kuang.png")
    kuang2:setContentSize(self._rightBg:getContentSize().width-25,self._rightBg:getContentSize().height/2+10)
    kuang2:setPosition(self._rightBg:getBoundingBox().width/2+10, tableTitle:getPositionY() - 215)
    kuang2:setAnchorPoint(0.5,1)
    self._rightBg:addChild(kuang2)

	local function advance( flag,id )
        if self._isProgressing or self._isRequest then
            YinDaoMarg:getInstance():releaseGuideLayer()
            return
        end
		local index = id and id or 1
		local mo = "godBeastPhase?"
		if index == 2 then
			mo = "godBeastOkyPhase?"
		end
        self._isRequest = true
        XTHDHttp:requestAsyncInGameWithParams({
            modules = mo,
            params = {godId=self._godid},
            successCallback = function(Phase)
				-- print("一键进阶服务器返回的数据为：")
				-- print_r(Phase)
                self._isRequest = false
                if tonumber(Phase.result) == 0 then
                    YinDaoMarg:getInstance():releaseGuideLayer()
                    if not flag then
                        XTHDTOAST(LANGUAGE_TIPS_PRESSLONG)
                    end
                    XTHD.saveItem({items = Phase.items})
                    local oldData = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ARTIFACT, {godid = self._godid})
                    if Phase.phaseResult == 1 then

                        local plus = getCommonYellowBMFontLabel("+"..tostring(Phase.curLucky-oldData.curLucky))
                        plus:setPosition(self._luckBar:getParent():getBoundingBox().width/2,self._luckBar:getParent():getBoundingBox().height+5)
                        self._luckBar:getParent():addChild(plus)
                        plus:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(1,cc.p(0,30)),cc.FadeOut:create(1)),cc.RemoveSelf:create()))
                    end
                    local tmpList = {}
                    for k,v in pairs(Phase.godProperty) do
                        tmpList[XTHD.resource.AttributesName[tonumber(k)]] = v
                    end
                    tmpList["curLucky"] = Phase.curLucky
                    tmpList["tempLateId"] = Phase.templateId
                    tmpList["cdTime"] = Phase.cdTime + os.time()
                    DBTableArtifact.multiUpdate(self._godid,tmpList)
                    DBTableArtifact.UpdateAtfData(nil,self._godid,"templateId",Phase.templateId)
                    DBTableHero.multiUpdate(gameUser.getUserId(),Phase.petId,Phase.petProperty)
                    DBTableArtifact.deleteRedDotData(oldData._artifactType, Phase.items[1].count)

                    self._ownArtifact = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ARTIFACT)
                    if self._ownArtifact.godid then
                        self._ownArtifact = {self._ownArtifact}
                    end
                    if Phase.phaseResult == 0 then
                        if self.isStop == false then
							self:stopScheduler()
						end
                        self._isSuccessed = true
                        XTHDTOAST(LANGUAGE_TIP_SUCCESS_TO_ADVANCE) ---进阶成功
                    end
                    self._stopSpAction = true
                    self:refreshDataById(self._godid, nil , true)
					self._isYiJianJinJie = false
                else
                    YinDaoMarg:getInstance():tryReguide()
					self._oneKeyAdvanceBtn:setVisible(true)
					self._stopBtn:setVisible(false)
                    self:stopScheduler()
					self._isIngjinjie = false
                    XTHDTOAST(Phase.msg)
                end
            end,--成功回调
            failedCallback = function()
                YinDaoMarg:getInstance():tryReguide()
                self:stopScheduler()
                self._isRequest = false
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----("网络请求失败")
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end
	
	--一键进阶按钮
	self._oneKeyAdvanceBtn = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(140,46),
        isScrollView = false,
        musicFile = XTHD.resource.music.effect_btn_common,
        text = "一键进阶",
        fontSize = 26,
        fontColor = cc.c3b(255,255,255),
    })
	self._oneKeyAdvanceBtn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
    self._oneKeyAdvanceBtn:setAnchorPoint(0.5,0)
    self._oneKeyAdvanceBtn:setPosition(self._rightBg:getBoundingBox().width/2 + 90,20)
    self._rightBg:addChild(self._oneKeyAdvanceBtn)
    self._oneKeyAdvanceBtn:setScale(0.7)
	self._oneKeyAdvanceBtn:setTouchEndedCallback(function ()
--		self._isYiJianJinJie = true
--        advance( true,2 )
		self.isStop = true
		self._isIngjinjie = true
		self._stopBtn:setVisible(true)
		self._oneKeyAdvanceBtn:setVisible(false)
		 schedule(self, function()
            schedule(self, function()
                self._isUsing = true
                if self:getActionByTag(10000) then
                    self:stopActionByTag(10000)
                end
                if not self._isProgressing and not self._isRequest then
                    advance( true )
                end
            end, 0.01, 10001)
        end, 0.05, 10000)    
    end)

	--取消一键进阶
	self._stopBtn = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(140,46),
        isScrollView = false,
        musicFile = XTHD.resource.music.effect_btn_common,
        text = "取 消",
        fontSize = 26,
        fontColor = cc.c3b(255,255,255),
    })
	self._stopBtn:setVisible(false)
	self._stopBtn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
    self._stopBtn:setAnchorPoint(0.5,0)
    self._stopBtn:setPosition(self._rightBg:getBoundingBox().width/2 + 90,20)
    self._rightBg:addChild(self._stopBtn)
    self._stopBtn:setScale(0.7)
	self._stopBtn:setTouchEndedCallback(function ()
		self._isIngjinjie = false
		self:stopScheduler()
		self._stopBtn:setVisible(false)
		self._oneKeyAdvanceBtn:setVisible(true)
    end)


    --开始进阶按钮
    self._advanceBtn = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(140,46),
        isScrollView = false,
        musicFile = XTHD.resource.music.effect_btn_common,
        text = LANGUAGE_EQUIP_TEXT[4],
        fontSize = 26,
        fontColor = cc.c3b(255,255,255),
    })
    self._advanceBtn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
    self._advanceBtn:setAnchorPoint(0.5,0)
    self._advanceBtn:setPosition(self._rightBg:getBoundingBox().width/2 - 65,20)
    self._rightBg:addChild(self._advanceBtn)
    self._advanceBtn:setScale(0.7)
    
    self._advanceBtn:setTouchBeganCallback(function()
        self:stopScheduler()
		self._stopBtn:setVisible(false)
		self._oneKeyAdvanceBtn:setVisible(true)
        schedule(self, function()
            schedule(self, function()
                self._isUsing = true
                if self:getActionByTag(10000) then
                    self:stopActionByTag(10000)
                end
                if not self._isProgressing and not self._isRequest then
                    advance( true )
                end
            end, 0.01, 10001)
        end, 0.05, 10000)    
    end)
    self._advanceBtn:setTouchMovedCallback(function( touch )
        if not cc.rectContainsPoint( cc.rect( 0, 0, self._advanceBtn:getBoundingBox().width, self._advanceBtn:getBoundingBox().height ), self._advanceBtn:convertToNodeSpace( touch:getLocation() ) ) then
            self:stopScheduler()
            self._isUsing = false
        end
    end)
    self._advanceBtn:setTouchEndedCallback(function ()
        self:stopScheduler()    
        -----引导
        YinDaoMarg:getInstance():guideTouchEnd() 
        --------------------------------------------------
        if not self._isUsing then
            advance( false )
        end
        self._isUsing = false
    end)

    local consumeTitle = cc.Sprite:create("res/image/plugin/saint_beast/jjxh.png")
    consumeTitle:setAnchorPoint(0.5,1)
    consumeTitle:setPosition(kuang2:getContentSize().width/2+30,tableTitle:getPositionY() - 205)
    self._rightBg:addChild(consumeTitle)
    self._consumeTitle = consumeTitle

    -- local consumeTitleLabel = XTHDLabel:createWithParams({
    --     text = LANGUAGE_TIP_ADVANCE_COST,------ "进阶消耗",
    --     fontSize = 18,
    --     color = XTHD.resource.color.brown_desc
    -- })
    -- consumeTitleLabel:setPosition(consumeTitle:getBoundingBox().width/2,consumeTitle:getBoundingBox().height/2)
    -- consumeTitle:addChild(consumeTitleLabel)


    -- local line3 = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
    -- line3:setContentSize(self._rightBg:getContentSize().width - 10,2)
    -- line3:setPosition(self._rightBg:getContentSize().width/2, consumeTitle:getPositionY()-110)
    -- self._rightBg:addChild(line3,1)
    -- self._line3 = line3

    local luckyBarBg = cc.Sprite:create("res/image/common/sq_common_progressBg_2.png")
    luckyBarBg:setAnchorPoint(0.5,0)
    luckyBarBg:setPosition(self._rightBg:getContentSize().width/2+10,100)
    self._rightBg:addChild(luckyBarBg)
    self._luckyBarBg = luckyBarBg
    self._luckyBarBg:setScale(0.8)

    self._luckBar = cc.ProgressTimer:create(cc.Sprite:create("res/image/common/sq_common_progress_2.png"))
    self._luckBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._luckBar:setBarChangeRate(cc.p(1,0))
    self._luckBar:setMidpoint(cc.p(0,0.5))
    self._luckBar:setPosition(luckyBarBg:getContentSize().width/2,luckyBarBg:getContentSize().height/2+1)
    luckyBarBg:addChild(self._luckBar)
    

    self._luckBar2 = cc.ProgressTimer:create(cc.Sprite:create("res/image/common/sq_common_progress_2.png"))
    self._luckBar2:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._luckBar2:setBarChangeRate(cc.p(1,0))
    self._luckBar2:setMidpoint(cc.p(0,0.5))
    self._luckBar2:setPosition(luckyBarBg:getContentSize().width*0.5,luckyBarBg:getContentSize().height*0.5+1)
    luckyBarBg:addChild(self._luckBar2)
    self._luckBar2:setVisible(false)

    self._luckFire = cc.Sprite:create("res/image/plugin/saint_beast/lucky_barLight.png")
    self._luckFire:setAnchorPoint(cc.p(1,0.5))
    self._luckFire:setBlendFunc(gl.SRC_ALPHA,gl.DST_ALPHA)
    self._luckFire:setPosition(luckyBarBg:getBoundingBox().width*0.5,luckyBarBg:getBoundingBox().height*0.5 + 5)
    luckyBarBg:addChild(self._luckFire)
    self._luckFire:setVisible(false)

    -- local luckyLabel = XTHDLabel:createWithParams({
    --     text = LANGUAGE_TIPS_WORDS5,----"祝福值越高，成功率越高！",
    --     fontSize = 16,
    --     color = XTHD.resource.color.brown_desc,
    -- })
    -- luckyLabel:setPosition(luckyBarBg:getContentSize().width/2,luckyBarBg:getContentSize().height/2+25)
    -- luckyBarBg:addChild(luckyLabel)

    self._luckyNum = getCommonWhiteBMFontLabel("")
    self._luckyNum = XTHDLabel:createWithParams({
        text = "",
        fontSize = 22,
    })
    self._luckyNum:setPosition(luckyBarBg:getContentSize().width/2,luckyBarBg:getContentSize().height/2)
    luckyBarBg:addChild(self._luckyNum)

    -- self._cdLabel = XTHDLabel:createWithParams({
    --     text = "",
    --     fontSize = 16,
    --     color = XTHD.resource.color.brown_desc,
    -- })
    -- self._cdLabel:setPosition(luckyBarBg:getContentSize().width/2,-luckyBarBg:getContentSize().height/2-5)
    -- luckyBarBg:addChild(self._cdLabel)

    local ownerLabel = cc.Sprite:create()
    ownerLabel:setAnchorPoint(0.5,0)
    ownerLabel:setPosition(self._leftBg:getContentSize().width/2,85)
    self._leftBg:addChild(ownerLabel)
    self.ownerLabel = ownerLabel

    -- local tableviewBg = ccui.Scale9Sprite:create(cc.rect(15,15,1,1),"res/image/common/scale9_bg_5.png")
    local tableviewBg = XTHD.createSprite()
    tableviewBg:setContentSize(cc.size(320, 150))
    tableviewBg:setAnchorPoint(0.5,1)
    tableviewBg:setPosition(self._rightBg:getBoundingBox().width/2 + 15,tableTitle:getPositionY()-40)
    self._rightBg:addChild(tableviewBg)

    -- local line2  = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
    -- line2:setContentSize(self._rightBg:getContentSize().width-10,2)
    -- line2:setPosition(self._rightBg:getContentSize().width/2, tableviewBg:getPositionY() - tableviewBg:getContentSize().height)
    -- self._rightBg:addChild(line2,1)


    self._attrTable = CCTableView:create(cc.size(tableviewBg:getBoundingBox().width,tableviewBg:getBoundingBox().height))--761
    self._attrTable:setPosition(0,0)--20
    self._attrTable:setBounceable(true)
    self._attrTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._attrTable:setDelegate()
    self._attrTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableviewBg:addChild(self._attrTable)

    self.nowAttrList = {}

    local function cellSizeForTable(table,idx)
        return tableviewBg:getBoundingBox().width,27
    end

    local function numberOfCellsInTableView(table)
        return #self.nowAttrList
    end

    local function tableCellTouched(table,cell)
    end

    local function tableCellAtIndex(table1,idx)
        local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else
            cell:removeAllChildren()
        end
        local nowData = string.split(self.nowAttrList[idx+1],",")
        local attrName = XTHDLabel:createWithParams({
            text = XTHD.resource.getAttributes(nowData[1]),
            fontSize = 18,
            color = XTHD.resource.color.brown_desc
        })
        attrName:setAnchorPoint(0,0.5)
        attrName:setPosition(30,27/2)
        cell:addChild(attrName)

        local baseNum = self._artifactData[tonumber(nowData[2])][XTHD.resource.AttributesName[tonumber(nowData[1])]]
        if self.gemAttrList[XTHD.resource.AttributesName[tonumber(nowData[1])]] then
            baseNum = tonumber(self._artifactData[tonumber(nowData[2])][XTHD.resource.AttributesName[tonumber(nowData[1])]]) + tonumber(self.gemAttrList[XTHD.resource.AttributesName[tonumber(nowData[1])]])
        end
        local attrPlus = XTHDLabel:createWithParams({
            text = " +"..baseNum,
            fontSize = 20,
            color = XTHD.resource.color.brown_desc
        })
        attrPlus:setAnchorPoint(0,0.5)
        attrPlus:setPosition(attrName:getPositionX()+attrName:getBoundingBox().width,attrName:getPositionY())
        cell:addChild(attrPlus)

        -- XTHDTOAST(nowData[4])
        if tonumber(nowData[4]) ~= 0 then
            local percent = XTHD.resource.isPercent(tonumber(nowData[1])) == true and "%" or ""
            local attrNum = XTHDLabel:createWithParams({
                text = "("..nowData[3]..percent..")",
                fontSize = 20,
                color = cc.c3b(104,157,0)
            })
            attrNum:setAnchorPoint(0,0.5)
            attrNum:setPosition(200,attrPlus:getPositionY())
            cell:addChild(attrNum)
        end

        return cell
    end

    self._attrTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._attrTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._attrTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._attrTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._attrTable:reloadData()
end

function ShenQiLayer:stopScheduler()
    self:stopActionByTag(10000)
    self:stopActionByTag(10001)
end

function ShenQiLayer:doCountDown()
    self._cdLabel:stopAllActions()
    self._cdLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function ()
        if self._cdLabel.cd == 0 then
            -- self._cdLabel:stopAllActions()
            -- self._cdLabel:setString("")
            self._luckyNum:setString(0)
            self._luckBar:setPercentage(0)
            self._luckBar:setVisible(true)
            self._luckBar2:setVisible(false)
            self._luckFire:setVisible(false)
        end
        self._cdLabel:setString(LANGUAGE_TIPS_WORDS6..getCdStringWithNumber(self._cdLabel.cd,{ -----祝福值
            h = ":",
            m = ":",
            s = "",
        }))
        self._cdLabel.cd = self._cdLabel.cd - 1
    end),cc.DelayTime:create(1))))
end

function ShenQiLayer:refreshDataById(godid,data, isShowAni)
    self._godid = godid

    if not data then
        self._ownArtifact = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ARTIFACT)
        if self._ownArtifact.godid then
            self._ownArtifact = {self._ownArtifact}
        end
    end
    local nowData = nil
    for i=1,#self._ownArtifact do
        if self._ownArtifact[i].godid == godid then
            nowData = self._ownArtifact[i]
			-- dump(nowData,"神器")
        end
    end
    local nowCSV = self._artifactData[nowData.templateId]
	local godType = nowCSV._type

    if not self._stopSpAction then
        self._artifactSp:stopAllActions()
        self._artifactSp:initWithFile(XTHD.resource.artifactSp[godType])
        self._artifactSp:setPosition(self._leftBg:getBoundingBox().width/2,self._leftBg:getBoundingBox().height/2+90)
        self._artifactSp:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.EaseInOut:create(cc.MoveBy:create(1.5,cc.p(0,20)),2),
            cc.EaseInOut:create(cc.MoveBy:create(1.5,cc.p(0,-20)),2)
        )))
    end
    self._artifactName:setString(XTHD.resource.name[godType])
    self._artifactAdvance:setString(" +"..nowCSV.rank)
    self._artifactName:setPosition((self._artifactNameBg:getBoundingBox().width-(self._artifactName:getBoundingBox().width+self._artifactAdvance:getBoundingBox().width))/2,self._artifactNameBg:getBoundingBox().height/2)
    self._artifactAdvance:setPosition(self._artifactName:getPositionX()+self._artifactName:getBoundingBox().width,self._artifactName:getPositionY())
    if self._isSuccessed then
        self._artifactAdvance:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.5,2.0),
            cc.ScaleTo:create(0.3,1.0)
        ))
    end
    self._isSuccessed = false
    self._stopSpAction = false

    self:createGemWithData(nowData)

    if os.time() >= nowData.cdTime and nowCSV.clern == 1 then
        self._luckyNum:setString(0)
        self._luckBar:setVisible(true)
        self._luckBar:setPercentage(0)
        self._luckBar2:setVisible(false)
        self._luckFire:setVisible(false)
    else
        self._luckyNum:setString(nowData.curLucky.."/"..nowCSV.maxlucky)
        local pNum_new = nowData.curLucky/nowCSV.maxlucky*100
        if not isShowAni or pNum_new == 0 and self._isYiJianJinJie == false then
            self._luckBar:setPercentage(pNum_new)
        else
            self._isProgressing = true
            self._luckBar:setVisible(false)
            self._luckBar2:setVisible(true)
            self._luckFire:setVisible(true)
            local pNum_old = self._luckBar:getPercentage()
            local pNowPos = pNum_old*0.01*self._luckBar:getContentSize().width
            self._luckFire:setPositionX(pNowPos + 2)
            local pTime = (1-(pNum_new - pNum_old)*0.01)*0.2
            self._luckBar2:setPercentage(pNum_old)
			local action  = nil
			if self._isYiJianJinJie == true then
				self._luckFire:setVisible(false)
				action = cc.Sequence:create(
					cc.ProgressTo:create(0.5, 100),
					cc.CallFunc:create(function ( ... )
						self._isProgressing = false
						self._luckFire:setVisible(false)
						self._luckBar2:setVisible(false)
						self._luckBar:setVisible(true)
						self._luckBar:setPercentage(pNum_new)
						self._luckBar2:setPercentage(0)
					end)
				)
			else
				action = cc.Sequence:create(
					cc.ProgressTo:create(pTime, pNum_new),
					cc.CallFunc:create(function ( ... )
						self._isProgressing = false
						self._luckFire:setVisible(false)
						self._luckBar2:setVisible(false)
						self._luckBar:setVisible(true)
						self._luckBar:setPercentage(pNum_new)
					end)
				)
			end

            local pMove = pNum_new*0.01*self._luckBar:getContentSize().width - pNowPos + 2
            self._luckBar2:runAction(action)
			if self._isYiJianJinJie == true then
				action = cc.Sequence:create(
					cc.MoveBy:create(0.5, cc.p(pMove,0))
				)
			else
				action = cc.Sequence:create(
					cc.MoveBy:create(pTime, cc.p(pMove,0))
				)
			end
            self._luckFire:runAction(action)
        end
        if os.time() < nowData.cdTime and nowCSV.clern == 1 then
            -- self._cdLabel.cd = nowData.cdTime - os.time()
            -- self:doCountDown()
        else
            -- self._cdLabel:stopAllActions()
            -- self._cdLabel:setString("")
        end
    end

    self.nowAttrList = {}
    self.gemAttrList = {}
    for i=1,6 do --把宝石加的属性摘出来 一会儿在遍历神器属性的时候加上
        if nowData["items"..i] ~= -1 then
            local gemData = gameData.getDataFromCSV("Runelist",{id = nowData["items"..i]})
            for j=1,#XTHD.resource.AttributesNum do
                if gemData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[j])]] ~= 0 then
                    self.gemAttrList[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[j])]] = gemData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[j])]]
                end
            end
        end
    end
    for i=1,#XTHD.resource.AttributesNum do
        if nowData.petId ~= 0 then
            if nowData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]] ~= 0 then
                self.nowAttrList[#self.nowAttrList+1] = tostring(XTHD.resource.AttributesNum[i])..","..tostring(nowData.templateId)..","..nowData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]]..","..nowData.petId
            end
        else
            if nowCSV[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]] ~= 0 then
                self.nowAttrList[#self.nowAttrList+1] = tostring(XTHD.resource.AttributesNum[i])..","..tostring(nowData.templateId)..","..nowData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]]..","..nowData.petId
            else
                for k,v in pairs(self.gemAttrList) do
                    if k == XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])] then
                        self.nowAttrList[#self.nowAttrList+1] = tostring(XTHD.resource.AttributesNum[i])..","..tostring(nowData.templateId)..","..nowData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]]..","..nowData.petId
                    end
                end
            end
        end
    end
    self._attrTable:reloadData()

    --佩戴者
    if self.ownHero then
        self.ownHero:removeFromParent()
        self.ownHero = nil
    end
    if nowData.petId ~= 0 then
		self.heorID = nowData.petId
        self.ownerLabel:initWithFile("res/image/plugin/saint_beast/owner_label.png")
        self.ownHero = HeroNode:createWithParams({
            heroid = nowData.petId
        })
        self.ownHero:setScale(88/92)

        self._changeBtn:setTouchEndedCallback(function ()
            local ShenQiSelectPop = requires("src/fsgl/layer/ShenQi/ShenQiSelectPop.lua"):create(nowData.petId,nil,function (godId)
                self:refreshDataById(godId)
            end)
            self:addChild(ShenQiSelectPop)
            ShenQiSelectPop:show()
        end)
        self._disboard:setTouchEndedCallback(function()
            self:dropOutArtifact(nowData.petId)
        end)

        self.ownHero:setTouchEndedCallback(function()
            local YingXiongSelectPop = requires("src/fsgl/layer/YingXiong/YingXiongSelectPop.lua"):create(function (heroId)
                -- print("the hero id is,at artifactlayer ----------------------------------LITAO 566",heroId)
                self:putOnArtifact(heroId)
            end)
            self:addChild(YingXiongSelectPop)
            YingXiongSelectPop:show()
        end)
    else
        self.ownerLabel:initWithFile("res/image/plugin/saint_beast/select_hero_label.png")
        self.ownHero = cc.Sprite:create("res/image/common/no_hero.png")
        self.ownHero:setOpacity(204)
        self.ownHero:setScale(88/self.ownHero:getBoundingBox().height)

        local plus = XTHDPushButton:createWithParams({
            musicFile = XTHD.resource.music.effect_btn_common,
            normalFile = "res/image/plugin/saint_beast/green_add.png",
            seletedFile = "res/image/plugin/saint_beast/green_add.png",
            touchSize = cc.size(60,60),
        })
        plus:setTouchEndedCallback(function ()
            local YingXiongSelectPop = requires("src/fsgl/layer/YingXiong/YingXiongSelectPop.lua"):create(function (heroId)
                -- print("the hero id is,at artifactlayer ----------------------------------LITAO 566",heroId)
                self:putOnArtifact(heroId)
            end)
            self:addChild(YingXiongSelectPop)
            YingXiongSelectPop:show()
        end)
        plus:setPosition(self.ownHero:getContentSize().width/2,self.ownHero:getContentSize().height/2)
        self.ownHero:addChild(plus)

        self._changeBtn:setTouchEndedCallback(function ()
            XTHDTOAST(LANGUAGE_TIPS_WORDS7)-----("先要装备在英雄身上")
        end)
        self._disboard:setTouchEndedCallback(function()
            XTHDTOAST(LANGUAGE_TIPS_WORDS7)
        end)
    end--self.ownerLabel
    self.ownHero:setAnchorPoint(0.5,0)
    self.ownHero:setPosition(self._leftBg:getBoundingBox().width/2,100)
    self._leftBg:addChild(self.ownHero)

    self:createConsume(nowCSV)
end

function ShenQiLayer:createConsume(nowCSV)
    --删除之前的消耗并且创建新的消耗品
    if self.consume1 then
        self.consume1:removeFromParent()
        self.consume1 = nil
    end
    if self.consume2 then
        self.consume2:removeFromParent()
        self.consume2 = nil
    end
    if self._maxLevelLab then
        self._maxLevelLab:removeFromParent()
        self._maxLevelLab = nil
    end
    self._luckyBarBg:setVisible(true)
    -- self._line3:setVisible(true)
    self._advanceBtn:setVisible(true)
	self._oneKeyAdvanceBtn:setVisible(true)
    self._consumeTitle:setVisible(true)

    if tonumber(nowCSV.rank) >= 12 then
        self._luckyBarBg:setVisible(false)
        -- self._line3:setVisible(false)
        self._advanceBtn:setVisible(false)
		self._oneKeyAdvanceBtn:setVisible(false)
        self._consumeTitle:setVisible(false)
        self._maxLevelLab = XTHDLabel:createWithParams({
            text = LANGUAGE_TIPS_GOD_MAXLEVEL,
            fontSize = 22,
            color = XTHD.resource.color.brown_desc,
            anchor = cc.p(0.5, 0),
            pos = cc.p(self._rightBg:getBoundingBox().width/2, 120),
        })
        self._rightBg:addChild(self._maxLevelLab)
        return 
    end

    local item1Num = XTHD.resource.getItemNum(nowCSV.needitem1)
    local item2Num = XTHD.resource.getItemNum(nowCSV.needitem2)
    self.consume1 = ItemNode:createWithParams({
        _type_ = 4,
        itemId = nowCSV.needitem1,
        count = item1Num.."/"..nowCSV.num1,
        isShowCount = true,
        isShowDrop = false,
        fnt_type = item1Num >= nowCSV.num1 and 1 or 2
    })
    self.consume1.nowCSV = nowCSV
    self.consume1:setScale(0.75)
    self.consume1:setAnchorPoint(0.5,1)
    self.consume1:setPosition(self._rightBg:getBoundingBox().width/2-50,self._consumeTitle:getPositionY() - 40)
    self._rightBg:addChild(self.consume1)
    --如果数量不足
    if tonumber(item1Num) < tonumber(nowCSV.num1) then
        self:toBuyItem(self.consume1, nowCSV.needitem1, nowCSV.num1)
    end
    if tonumber(item2Num) > 0 then
        self.consume2 = ItemNode:createWithParams({
            _type_ = 4,
            itemId = nowCSV.needitem2,
            count = item2Num.."/"..nowCSV.num2,
            isShowCount = true,
            isShowDrop = false,
            fnt_type = item2Num >= nowCSV.num2 and 1 or 2
        })
        self.consume2:setScale(0.75)
        self.consume2:setAnchorPoint(0.5,1)
        self.consume2:setPosition(self._rightBg:getBoundingBox().width/2+50, self._consumeTitle:getPositionY() - 40)
        self._rightBg:addChild(self.consume2)
        --如果数量不足
        if tonumber(item2Num) < tonumber(nowCSV.num2) and nowCSV.rank < 4 then
            self:toBuyItem(self.consume2, nowCSV.needitem2, nowCSV.num2)
        end
    elseif tonumber(item2Num) == 0 then
       self.consume1:setPositionX(self._rightBg:getBoundingBox().width/2) 
    end
end
--进价石不足，购买
function ShenQiLayer:toBuyItem(_node, _id, _limit)
    local addBtn = XTHD.createButton({
        touchSize = cc.size(_node:getContentSize().width, _node:getContentSize().height),
        needSwallow = true,
        endCallback = function()
            local function refresh(data)
                local countLab = _node:getNumberLabel()
                if _node:getChildByName("addBtn") then
                    if tonumber(data[1].count) >= tonumber(_limit) then
                        _node:getChildByName("addBtn"):removeFromParent()
                        _node:getChildByName("addSp"):removeFromParent()
                        countLab:removeFromParent()
                        local newCountLab = getCommonWhiteBMFontLabel(getHugeNumberWithLongNumber(data[1].count,100000).."/".._limit)
                        newCountLab:setName("_num_label")
                        newCountLab:setAnchorPoint(1,0)
                        newCountLab:setPosition(_node:getContentSize().width-3-3, -7)
                        _node:addChild(newCountLab)
                    else
                       countLab:setString(data[1].count.."/".._limit) 
                    end
                else
                    countLab:setString(data[1].count.."/".._limit) 
                end
            end
            local popLayer = requires("src/fsgl/layer/ShenQi/buyItemPop1.lua"):create(_id, self, refresh)
            self:addChild(popLayer)
        end,
        pos = cc.p(_node:getContentSize().width/2, _node:getContentSize().height/2),
    })
    addBtn:setName("addBtn")
    _node:addChild(addBtn)
    local addSp = cc.Sprite:create("res/image/plugin/hero/label_add_green.png")
    addSp:setAnchorPoint(cc.p(0.5, 0.5))
    addSp:setPosition(cc.p(_node:getContentSize().width/2, _node:getContentSize().height/2))
    addSp:setScale(2.0)
    addSp:setName("addSp")
    _node:addChild(addSp)
    addSp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5))))
end

function ShenQiLayer:createGemWithData(data) --Data为动态库中的一条数据
    --如果之前已经创建过就先删掉
    self._gemList = self._gemList or {}
    for i=1,#self._gemList do
        self._gemList[i]:removeFromParent()
    end
    self._gemList = {}
    --创建正八边形
    local r = 175
    local nowBox = {1,3,5,7,9,12}

    local posTable = {
        [1] = cc.p(60,36),
        [2] = cc.p(150,36),
        [3] = cc.p(240,36),
        [4] = cc.p(330,36),
        [5] = cc.p(420,36),
        [6] = cc.p(510,36),
    }
    for i=1,6 do
        
            -- local gemBg = cc.Sprite:create("res/image/plugin/saint_beast/item_bg.png")
            local gemBg = cc.Sprite:create()
            gemBg:setPosition(posTable[i])
            gemBg:setScale(0.7)
            self._leftBg:addChild(gemBg)
            
            

            local nowParam = nowBox[i]
            local showUnlockTip = true
            local btnPath = "res/image/plugin/saint_beast/lock.png"
            if self._artifactData[data.templateId].rank - 1 >= nowParam - 1 then
                btnPath = "res/image/plugin/saint_beast/unlock.png"
                showUnlockTip = false
            end
            local gemBgUnlock = XTHDPushButton:createWithParams({
                musicFile = XTHD.resource.music.effect_btn_common,
                normalFile = btnPath,
                selectedFile = btnPath,
                touchSize = cc.size(80, 80),
            })
            --加号
            local jahao = cc.Sprite:create("res/image/plugin/saint_beast/green_add.png")
            jahao:setPosition(gemBgUnlock:getContentSize().width/2,gemBgUnlock:getContentSize().height/2)
            gemBgUnlock:addChild(jahao)
            self.jiahao = jahao

            gemBgUnlock:setPosition(gemBg:getContentSize().width/2-1,gemBg:getContentSize().height/2)
            gemBg:addChild(gemBgUnlock)

            gemBgUnlock:setTouchEndedCallback(function ()
                if self._artifactData[data.templateId].rank - 1 < nowParam - 1 then
                    XTHDTOAST(LANGUAGE_KEY_ADVANCE_TOUNLOCK(tostring(nowParam)))-----("进阶到"..tostring(nowParam+1).."阶解锁")
                    return
                end
                --弹出选择宝石界面
                self:showSelectGem(i)
            end)

            --如果这个槽里有宝石
            if data["items"..i] ~= -1 then
                gemBgUnlock:setTouchEndedCallback(function ()
                    
                end)
                local gemBtn = ItemNode:createWithParams({
                    _type_ = 4,
                    itemId = data["items"..i],
                    needSwallow = true,
                    isShowDrop = false,
                    touchShowTip = false
                })
                -- gemBtn:setScale(60/gemBtn:getBoundingBox().width)
                gemBtn:setPosition(gemBgUnlock:getContentSize().width/2,gemBgUnlock:getContentSize().height/2)
                gemBgUnlock:addChild(gemBtn)
                gemBtn:setTouchEndedCallback(function ()
                    local GemPop = requires("src/fsgl/layer/ShenQi/ShenQiGemPop.lua"):create(i,data["items"..i])
                    self:addChild(GemPop)
                    GemPop:show()
                end)
            end

            self._gemList[#self._gemList+1] = gemBg
            -- nowBox = nowBox + 1

            if showUnlockTip then
                local tip = XTHDLabel:createWithParams({
                    text = LANGUAGE_KEY_ARTIFACT_UNLOCK(tostring(nowParam)),
                    fontSize = 18,
                    color = XTHD.resource.color.brown_desc,
                    anchor = cc.p(0.5, 0.5),
                    pos = cc.p(gemBgUnlock:getContentSize().width/2, -gemBgUnlock:getContentSize().height/2+10),
                })
                gemBgUnlock:addChild(tip)
                self.jiahao:setVisible(false)
            else
                self.jiahao:setVisible(true)
            end
        
    end
end

function ShenQiLayer:showSelectGem(index)
    local allGem = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{item_type = 5})
    -- ZCLOG(gemData)
    if allGem.itemid then
        allGem = {allGem}
    end
    if #allGem == 0 then
        --如果包里没有宝石
        --TODO
        XTHDTOAST(LANGUAGE_TIPS_WORDS8)-----("您的背包中没有玄符，请去神器商店中获取！")
        return
    end
    local GemSelectPop = requires("src/fsgl/layer/ShenQi/ShenQiGemSelectPop.lua"):create(allGem,function (dbid)
        self:changeGem(dbid,index)
    end)
    self:addChild(GemSelectPop)
    GemSelectPop:show()
end

function ShenQiLayer:unloadGem(index)
	local heroData = DBTableHero.getDataByID( self.heorID )
	self._oldFightValue = heroData.power
    XTHDHttp:requestAsyncInGameWithParams({
        modules="godDropkeyin?",
        params = {godId=self._godid,index=index},
        successCallback = function(drop)
        if tonumber(drop.result) == 0 then
            local tmpList = {}
            for k,v in pairs(drop.godProperty) do
                tmpList[XTHD.resource.AttributesName[tonumber(k)]] = v
            end
            DBTableArtifact.multiUpdate(drop.godId,tmpList,drop.godItems)
            XTHD.saveItem({items = drop.bagItems})
            self:refreshDataById(self._godid)

            --更新属性
            for i = 1,#drop["Petproperty"] do
                local _petItemData = string.split( drop["Petproperty"][i],',')
                DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[1],_petItemData[2],drop["petId"])	
                if tonumber(_petItemData[1]) == 407 then
                    self._newFightValue = tonumber(_petItemData[2])
                end
            end
            
            XTHD._createFightLabelToast({
                oldFightValue = self._oldFightValue,
                newFightValue = self._newFightValue
            })
           self._oldFightValue = self._newFightValue

        else
            XTHDTOAST(drop.msg or LANGUAGE_TIPS_WEBERROR)
        end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ShenQiLayer:changeGem(dbid,index)
	local heroData = DBTableHero.getDataByID( self.heorID )
	self._oldFightValue = heroData.power
    XTHDHttp:requestAsyncInGameWithParams({
        modules = "keyinGodBeast?",
        params = {godId=self._godid,dbId=dbid,index=index},
        successCallback = function(keyin)
            if tonumber(keyin.result) == 0 then
                DBTableHero.multiUpdate(gameUser.getUserId(),keyin.petId,keyin.petProperty)
                local tmpList = {}
                for k,v in pairs(keyin.godProperty) do
                    tmpList[XTHD.resource.AttributesName[tonumber(k)]] = v
                end
                DBTableArtifact.multiUpdate(keyin.godId,tmpList,keyin.godItems)
                XTHD.saveItem({items = keyin.bagItems})
                self:refreshDataById(self._godid)

                --更新属性
                for i = 1,#keyin["petProperty"] do
                    local _petItemData = string.split( keyin["petProperty"][i],',')
                    DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[1],_petItemData[2],keyin["petId"])	
                    if tonumber(_petItemData[1]) == 407 then
                        self._newFightValue = tonumber(_petItemData[2])
                    end
                end
                
                XTHD._createFightLabelToast({
                    oldFightValue = self._oldFightValue,
                    newFightValue = self._newFightValue
                })
                self._oldFightValue = self._newFightValue
            else
                XTHDTOAST(keyin.msg or LANGUAGE_TIPS_WEBERROR)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ShenQiLayer:create(godid,ownArtifact,callback,heroInfoLayer)
    if heroInfoLayer then
        self.infoLayer = heroInfoLayer
        self._oldFightValue = self.infoLayer.data.power or 0
    end
	return ShenQiLayer.new(godid,ownArtifact,callback)
end

function ShenQiLayer:onExit( )
    self:stopScheduler()
    if self._exitCallback and type(self._exitCallback) == "function" then 
        self._exitCallback()
    end 
end

function ShenQiLayer:onEnter( )
    -- local _back = self._topBar:getChildByName("topBarBackBtn")
    -- if gameUser.getInstancingId() == 48 then ----第21组引导 
    --     YinDaoMarg:getInstance():addGuide({parent = self,index = 11},21)----剧情            
    --     YinDaoMarg:getInstance():addGuide({ ----经验丹引导
    --         parent = self,
    --         target = self._advanceBtn,
    --         index = 10,
    --     },21)
    --     YinDaoMarg:getInstance():addGuide({ ----返回
    --         parent = self,
    --         target = _back,
    --         index = 12,
    --         needNext = false
    --     },21)
    -- end 
    -- YinDaoMarg:getInstance():doNextGuide()   
end

function ShenQiLayer:dropOutArtifact(heroId)
	--获取当前英雄的总战力
	local heroData = DBTableHero.getDataByID( heroId )
	self._oldFightValue = heroData.power
    -- XTHDTOAST(LANGUAGE_TIPS_WORDS11)
    ClientHttp:requestAsyncInGameWithParams({
        modules = "petDropGod?",      --接口
        params = {petId=heroId}, --参数
        successCallback = function(data)
            if tonumber(data.result) == 0 then --请求成功
                -- ... --相应处理
                local tmpList = {}
                for k,v in pairs(data.godProperty) do
                    tmpList[XTHD.resource.AttributesName[tonumber(k)]] = v
                end
                DBTableArtifact.multiUpdate(data.godId,tmpList)
                DBTableHero.multiUpdate(gameUser.getUserId(),data.petId,data.petProperty)
                DBTableArtifact.UpdateAtfData(gameUser.getUserId(),self._godid, "petId", 0)

                --更新属性
                for i = 1,#data["petProperty"] do
                    local _petItemData = string.split( data["petProperty"][i],',')
                    DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[1],_petItemData[2],data["petId"])	
                    if tonumber(_petItemData[1]) == 407 then
                        self._newFightValue = tonumber(_petItemData[2])
                    end
                end
                
                XTHD._createFightLabelToast({
                    oldFightValue = self._oldFightValue,
                    newFightValue = self._newFightValue
                })
                self._oldFightValue = self._newFightValue
                
                self._stopSpAction = true
                self:refreshDataById(data.godId)
            else
               XTHDTOAST(data.msg) --出错信息(后端返回)
            end
        end,--成功回调
        loadingParent = self,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ShenQiLayer:putOnArtifact( heroId )    
	--获取当前英雄的总战力
	local heroData = DBTableHero.getDataByID( heroId )
	self._oldFightValue = heroData.power
    XTHDHttp:requestAsyncInGameWithParams({
        modules="petDeployGod?",
        params = {petId = heroId,godId = self._godid},
        successCallback = function(Deploy)
            if tonumber(Deploy.result) == 0 then
                for i=1,#Deploy.petProperty do
                    DBTableHero.multiUpdate(gameUser.getUserId(),Deploy.petProperty[i].petId,Deploy.petProperty[i].property)
                    local _petItemData = string.split( Deploy["petProperty"][i]["property"][#Deploy["petProperty"][i]["property"]],',')
                    DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[1],_petItemData[2],Deploy["petId"])	
                    if tonumber(_petItemData[1]) == 407 then
                        self._newFightValue = tonumber(_petItemData[2])
                    end
                end
                for i=1,#Deploy.godProperty do
                    local nowGod = Deploy.godProperty[i]
                    local tmpList = {}
                    for k,v in pairs(nowGod.property) do
                        tmpList[XTHD.resource.AttributesName[tonumber(k)]] = v
                    end
                    DBTableArtifact.multiUpdate(nowGod.godId,tmpList)
                end
				
                XTHD._createFightLabelToast({
                    oldFightValue = self._oldFightValue,
                    newFightValue = self._newFightValue
                })
                self._oldFightValue = self._newFightValue
				

                DBTableArtifact.DeleteOldArtifact(gameUser.getUserId(),heroId)
                DBTableArtifact.UpdateAtfData(gameUser.getUserId(),self._godid, "petId", heroId)
                self:refreshWearer(heroId)
            else
                XTHDTOAST(Deploy.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end
-----刷新佩戴者
function ShenQiLayer:refreshWearer( heroid)
	self.heroID = heroid
    if self.ownerLabel then 
        self.ownerLabel:setTexture("res/image/plugin/saint_beast/owner_label.png")
    end 
    if self.ownHero then 
        local x,y = self.ownHero:getPosition()
        local achor = self.ownHero:getAnchorPoint()
        local factor  = self.ownHero:getScale()
        self.ownHero:removeFromParent()
        self.ownHero = HeroNode:createWithParams({
            heroid = heroid
        })
        self._leftBg:addChild(self.ownHero)
        self.ownHero:setScale(88/92)
        self.ownHero:setAnchorPoint(achor.x, achor.y)
        self.ownHero:setPosition(x,y)
        self._changeBtn:setTouchEndedCallback(function ()
            local ShenQiSelectPop = requires("src/fsgl/layer/ShenQi/ShenQiSelectPop.lua"):create(heroid,nil,function (godId)
                self:refreshDataById(godId)
            end)
            self:addChild(ShenQiSelectPop)
            ShenQiSelectPop:show()
        end)
        self.ownHero:setTouchEndedCallback(function()
            local YingXiongSelectPop = requires("src/fsgl/layer/YingXiong/YingXiongSelectPop.lua"):create(function (heroId)
                -- print("the hero id is,at artifactlayer ----------------------------------LITAO 566",heroId)
                self:putOnArtifact(heroId)
            end)
            self:addChild(YingXiongSelectPop)
            YingXiongSelectPop:show()
        end)

        self:refreshDataById(self._godid)
    end 
end

function ShenQiLayer:addGuide( )
    
end

return ShenQiLayer