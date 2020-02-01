local XiongShouLaiXiLayer=class("XiongShouLaiXiLayer",function ()
    return XTHD.createBasePageLayer({
        bg = "res/image/worldboss/unOpenBack0.png",
        isOnlyBack = true,
    })
end)

function XiongShouLaiXiLayer:createForLayerManager( params )
    XiongShouLaiXiLayer:doHttpOpenBossWindow(params.par, function ( data )
        LayerManager.addShieldLayout()
        local pLay = XiongShouLaiXiLayer.new(data)
        LayerManager.addLayout(pLay)
    end)
end

function XiongShouLaiXiLayer:ctor(data)
    self.data = data
    self._globalScheduler = GlobalScheduler:create(self)
    self._scheduleName = "GLOBAL_WORLDBOSS"
    self._scheduleName2 = "GLOBAL_WORLDBOSS_CD"
	self:initUI()
end
function XiongShouLaiXiLayer:onEnter( )
    if not self._isInit then
        self._isInit = true
        self:delaytime()
    else
        self:delaytime(0)
    end 
    self:showWorldBossHatredPop()
end

function XiongShouLaiXiLayer:onCleanup ( )
    self._globalScheduler:destroy(true)
    self._globalScheduler = nil
    self._worldBossUnOpen = nil
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
    self:unscheduleUpdate()
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/worldboss/unOpenBack0.png")
    textureCache:removeTextureForKey("res/image/worldboss/sss_03.png")
    textureCache:removeTextureForKey("res/spine/effect/bossBackEff/haidi.png")

    XTHD.removeEventListener(CUSTOM_EVENT.WORLDBOSS_HURT) 
end

function XiongShouLaiXiLayer:onExit( )
end

function XiongShouLaiXiLayer:initUI( )
    local size = self:getContentSize()

    -- local __sp = sp.SkeletonAnimation:create("res/spine/effect/bossBackEff/haidi.json", "res/spine/effect/bossBackEff/haidi.atlas", 1.0)
    -- local pos = cc.p(size.width*0.5, size.height*0.5)
    -- __sp:setPosition(pos)
    -- self:addChild(__sp)
    -- __sp:setAnimation(0, "animation", true)

    --伤害排名
    self:hurtRankView()
    --实时造成伤害
    -- self:hurtView()
    
    --boss相关

    local  boss_sp= cc.Node:create()
    boss_sp:setContentSize(557, 379)
    boss_sp:setAnchorPoint(1,0.5)
    boss_sp:setPosition(size.width, size.height/2+20)
    self:addChild(boss_sp)

    local  boss_effect = sp.SkeletonAnimation:createWithBinaryFile( "res/spine/801.skel", "res/spine/801.atlas",1.0);
    boss_effect:setPosition(boss_sp:getContentSize().width*0.5 - GetScreenOffsetX(), 50)
    boss_effect:setAnimation(0,BATTLE_ANIMATION_ACTION.IDLE,true)
    boss_effect:setScaleX(-1)
    boss_sp:addChild(boss_effect)
    self._bossSp = boss_sp
    self._bossEffect = boss_effect
 
    
    --进度条君
    local exp_progress_bg = cc.Sprite:create("res/image/worldboss/loardingbar_green_bg.png")
    self.exp_progress_bg=exp_progress_bg
    exp_progress_bg:setAnchorPoint(0,0)
    exp_progress_bg:setPosition(size.width/2,100)
    self:addChild(exp_progress_bg)
    local now_percent=string.format("%.4f", tonumber(self.data.curHp)/tonumber(self.data.maxHp)) *100--math.floor((tonumber(self.data.curHp)/tonumber(self.data.maxHp))) *100
    local exp_progress_timer = cc.ProgressTimer:create(cc.Sprite:create("res/image/worldboss/loardingbar_green.png"))
    self.exp_progress_timer=exp_progress_timer
    exp_progress_timer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    exp_progress_timer:setMidpoint(cc.p(0,0))
    exp_progress_timer:setBarChangeRate(cc.p(1,0))
    exp_progress_timer:setPosition(exp_progress_bg:getContentSize().width/2, exp_progress_bg:getContentSize().height/2)
    exp_progress_timer:setPercentage(now_percent)
    exp_progress_bg:addChild(exp_progress_timer)
    local percent_label=getCommonWhiteBMFontLabel(tostring(now_percent).."%")
    self.percent_label=percent_label                              
    percent_label:setPosition(exp_progress_bg:getContentSize().width/2,exp_progress_bg:getContentSize().height/2-5)
    exp_progress_bg:addChild(percent_label)

    --查看奖励
    local reward_btn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/worldboss/rewarld_1.png", 
        selectedFile      = "res/image/worldboss/rewarld_2.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        pos = cc.p(size.width-32,150),
        endCallback = function()
            local reward_pop=requires("src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiRewardPop.lua"):create()
            LayerManager.addLayout(reward_pop, {noHide = true})
        end
    })
    reward_btn:setScale(0.7)
    reward_btn:setAnchorPoint(1,0)
    self:addChild(reward_btn)
    --马上参战
     local battle_btn = XTHDPushButton:createWithParams({
         normalFile        = "res/image/common/btn/kstz_up.png", 
         selectedFile      = "res/image/common/btn/kstz_down.png",
    --local battle_btn = XTHD.createCommonButton({
        --btnColor = "blue",
        --text = "马上参战",
        --fontSize = 20,
        musicFile = XTHD.resource.music.effect_btn_common,
        pos = cc.p(size.width/4*3,20),
        endCallback = function()
            if self.data.openState and self.data.openState==1 then
                if self.data.cd ==0 then
                    LayerManager.addShieldLayout()
                    local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongCopyLayer.lua"):create(BattleType.WORLDBOSS_PVE)
                    fnMyPushScene(_layer)
                else 
                    local layer=self:revival()
                    self:addChild(layer)
                end
            else 
                XTHDTOAST(LANGUAGE_TIPS_WORDS237)
            end
        end
    })
    self.battle_btn=battle_btn
    self.battle_btn:setPositionX(self.battle_btn:getPositionX()-15)
    self.battle_btn:setPositionY(self.battle_btn:getPositionY()-10)
    battle_btn:setAnchorPoint(0.5,0)
    self:addChild(battle_btn)   
    --倒计时cd
    local cd_label = XTHDLabel:createWithParams({
        text = "",
        size = 22,
        anchor = cc.p(0, 0.5),
        pos = cc.p(battle_btn:getContentSize().width+20,battle_btn:getContentSize().height/2),
    })
    self.cd_label=cd_label
    battle_btn:addChild(cd_label)
  
    if self.data.cd and self.data.cd>0 then
         self.battle_btn:setStateSelected("res/image/common/btn/fuhuo_up.png")
         self.battle_btn:setStateNormal("res/image/common/btn/fuhuo_down.png")
        --self.battle_btn:getLabel():setString("复活")
        self.cd_label:setString(LANGUAGE_KEY_WORLDBOSS_TIME(self.data.cd))
        self:cdRefresh(self.data.cd)
    end

    --活动倒计时
    local time_bg=cc.Sprite:create("res/image/worldboss/tim_bg.png")
    time_bg:setPosition(size.width/4*3,size.height-20)
    self:addChild(time_bg)
    time_bg:setScale(0.8)

    local time_sp=cc.Sprite:create("res/image/worldboss/cd_sp1.png")
    self.time_sp=time_sp
    time_sp:setAnchorPoint(1,0.5)
    -- time_sp:enableOutline(cc.c4b(79,46,31,255),2)
    time_sp:setPosition(time_bg:getContentSize().width/2,time_bg:getContentSize().height/2-5)
    time_bg:addChild(time_sp)

    local time=getCommonWhiteBMFontLabel(tostring(XTHD.getTimeHMS(self.data.diffTime,true))) 
    time:setFontSize(28)
    self.time=time 
    time:setAnchorPoint(0,0.5)                            
    time:setPosition(time_bg:getContentSize().width/2,time_bg:getContentSize().height/2-5)
    time_bg:addChild(time)
    -- self:cdActive(self.data.diffTime)
    -- XTHD.getTimeHMS(time,needHour)
    --挑战人数
   
    local peo_lable=cc.Sprite:create("res/image/worldboss/battle_num.png")
    self.peo_lable=peo_lable
    peo_lable:setAnchorPoint(0.5,0.5)
    peo_lable:setPosition(time_bg:getContentSize().width/2,-30)
    time_bg:addChild(peo_lable)
    local peo_num=cc.Label:createWithBMFont("res/fonts/campbegin.fnt",tostring(self.data.totalSum))--getCommonRedBMFontLabel("1000")
    self.peo_num=peo_num
    peo_num:setAnchorPoint(1,0.5)
    peo_num:setPosition(-10,peo_lable:getContentSize().height/2 - 4)
    peo_lable:addChild(peo_num)
    local str = "每日挑战BOSS超过50次后将不再获得挑战奖励，排名和最后一击奖励不受影响！"
    local tipStr = XTHDLabel:create(str,21)
    tipStr:setPosition(30,peo_num:getPositionY() - 40)
    tipStr:setColor(cc.c3b(230, 215, 133))
    peo_lable:addChild(tipStr)
    -- if self.data.openState == 0 then 
    --     battle_btn:setVisible(false)
    --     exp_progress_bg:setVisible(false)
    --     self.peo_num:setVisible(false)
    --     self.peo_lable:setTexture("res/image/worldboss/bosskill_"..self.data.deadState..".png")
    --     time_sp:setTexture("res/image/worldboss/cd_sp2.png")
    --     self:showUnOpenLay()
    -- else
    --     self:doCheckHurtLabel(true)
    -- end 
    self:freshData()
    -- self:delaytime(1)

	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=32});
            self:addChild(StoredValue)
        end,
	})
	self:addChild(help_btn)
	help_btn:setPosition(self:getContentSize().width / 2 -  help_btn:getContentSize().width + 50,self:getContentSize().height - help_btn:getContentSize().height / 2)
   
end

function XiongShouLaiXiLayer:doCheckHurtLabel( isOpen )
    if not isOpen then
        if self._labelAction then
            self:stopAction(self._labelAction)
            self._labelAction = nil
        end
        XTHD.removeEventListener(CUSTOM_EVENT.WORLDBOSS_HURT) 
        self._hurtShowList = {}
        return
    end

    self._hurtShowList = {}
    XTHD.removeEventListener(CUSTOM_EVENT.WORLDBOSS_HURT) 
    XTHD.addEventListener({name = CUSTOM_EVENT.WORLDBOSS_HURT ,callback = function(event)
        local data = event["data"]
        local hurt = event["data"].hurt or 0
        if #self._hurtShowList >= 50 then
            table.remove(self._hurtShowList)
        end
        table.insert(self._hurtShowList, 1, hurt)
    end })

    local function _show( ... )
        if #self._hurtShowList <= 0 then
            return
        end
        local hurt = table.remove(self._hurtShowList)
        local point = 25 - math.fmod( (math.random()*100000), 50) 
        local hurt_label = cc.Label:createWithBMFont("res/fonts/hongsezi.fnt",hurt)--XTHDLabel:createWithParams({text="哈哈哈哈"..tostring(c),ttf="",size=18})
        hurt_label:setPosition(self._bossSp:getContentSize().width/2+point,self._bossSp:getContentSize().height/4*3+point)
        self._bossSp:addChild(hurt_label,10)
        self._bossEffect:runAction(cc.Sequence:create(
            cc.TintTo:create(0.1 / 2,255,0,0),
            cc.TintTo:create(0,255,255,255)
        ))
        hurt_label:runAction(cc.Spawn:create(cc.Sequence:create(cc.ScaleTo:create(0.15,1.7),cc.ScaleTo:create(0.2,1),cc.Spawn:create(cc.MoveBy:create(2.5,cc.p(point,150)),cc.FadeOut:create(2.5))),
            cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function ()
            hurt_label:removeFromParent()
        end))))
    end

    local function _randomDelay( ... )
        local pTime = math.random(10,20)/100
        self._labelAction = cc.Sequence:create(
            cc.CallFunc:create(_show),
            cc.DelayTime:create(pTime),
            cc.CallFunc:create(_randomDelay)
        )
        self:runAction(self._labelAction)
    end
    _randomDelay()    
end

function XiongShouLaiXiLayer:showUnOpenLay( onlyRemove )
    if self._worldBossUnOpen then
        self._worldBossUnOpen:removeFromParent()
        self._worldBossUnOpen = nil
    end
    if onlyRemove then
        self:doCheckHurtLabel(true)
        return
    end
    if self.data.openState ~= 0 then   --只要openstate为0则是关的，不为0则开的
        self:doCheckHurtLabel(true)
        return
    end
    self:doCheckHurtLabel(false)
    local _data = {deadState = self.data.deadState, hurtList = self.data.hurtList, backCall = function ()
        LayerManager.removeLayout(self)
    end}
    self._worldBossUnOpen = requires("src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiUnOpen.lua"):createForLayerManager(_data)
    self:addChild(self._worldBossUnOpen, 2)
    self:freshData()
end

function XiongShouLaiXiLayer:updateUnOpenLay( time )
    if not self._worldBossUnOpen then
        return
    end
    self._worldBossUnOpen:updateTimeShow(time)
end

--伤害排名
function XiongShouLaiXiLayer:hurtRankView(  )
    local _hei = 60
    local _bgSize = cc.size(513, self:getContentSize().height)
    local hurtRankView_bg = ccui.Scale9Sprite:create("res/image/worldboss/sss_03.png")
    self._hurtRankView_bg = hurtRankView_bg
    hurtRankView_bg:setContentSize(_bgSize)
    -- local hurtRankView_bg=cc.Sprite:create("res/image/worldboss/hurtrank_bg.png")
    hurtRankView_bg:setAnchorPoint(0, 0.5)
    hurtRankView_bg:setPosition(0 + GetScreenOffsetX(), _bgSize.height*0.5+10)
    self:addChild(hurtRankView_bg)

    -- local _upSide = cc.Sprite:create("res/image/worldboss/sss_07.png")
    -- _upSide:setAnchorPoint(0.5, 0)
    -- _upSide:setPosition(_bgSize.width*0.5, _bgSize.height - _hei)
    -- hurtRankView_bg:addChild(_upSide)
    -- _upSide:setOpacity(0)

    local pHeight = 125
    local _hurtListSize = cc.size(hurtRankView_bg:getContentSize().width - 10, _bgSize.height - pHeight - _hei)
    -- local _upSide = cc.Sprite:create("res/image/worldboss/sss_10.png")
    -- _upSide:setAnchorPoint(0.5, 1)
    -- _upSide:setPosition(_bgSize.width*0.5, pHeight)
    -- hurtRankView_bg:addChild(_upSide)

    local _myRankTitle = cc.Sprite:create("res/image/worldboss/worldBoss_myRank.png")----我的排名
	_myRankTitle:setScale(0.8)
    self._myRankTitle = _myRankTitle
    _myRankTitle:setAnchorPoint(0, 0.5)
    _myRankTitle:setPosition(_bgSize.width*0.5 - 50, _bgSize.height - 35)
    hurtRankView_bg:addChild(_myRankTitle)

     --我的排名
    -- if _mRankNum > 0 then 
    --     self.my_rank:setString(_mRankNum)
    -- end 
    -- local _mRankNum = tonumber(self.data.myRank) or 0
    local my_rank = getCommonWhiteBMFontLabel("0")
    self.my_rank = my_rank
    my_rank:setAnchorPoint(1, 0.5)
    my_rank:setPosition(_myRankTitle:getPositionX() , _myRankTitle:getPositionY() )
    hurtRankView_bg:addChild(my_rank)


    --我的伤害
    local my_hurt = XTHDLabel:createWithParams({text="",size=22})
    self.my_hurt = my_hurt
    my_hurt:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
    my_hurt:setAnchorPoint(0.5, 1)
    my_hurt:enableShadow(cc.c4b(70,34,34,255), cc.size(0.4,-0.4), 1)
    my_hurt:setColor(cc.c3b(230, 215, 133))
    my_hurt:setPosition(_bgSize.width*0.5 + 10, _myRankTitle:getPositionY() - _myRankTitle:getContentSize().height*0.5 - 5)
    hurtRankView_bg:addChild(my_hurt)

    self:freshSelfRankAndHurt(self.data.myRank, self.data.myHurt)

    local hurtRankTableView = CCTableView:create(_hurtListSize)
    self.hurtRankTableView = hurtRankTableView
    hurtRankTableView:setName("hurtRankTableView")
    hurtRankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    hurtRankTableView:setPosition(cc.p(32, pHeight-20))
    hurtRankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    hurtRankTableView:setBounceable(true)
    hurtRankTableView:setDelegate() 
    hurtRankView_bg:addChild(hurtRankTableView)
    -- 注册事件
    local _cellSize = cc.size(hurtRankView_bg:getContentSize().width - 10, 80 )
    local function numberOfCellsInTableView( table )
        local pCount = self.data.hurtList and #self.data.hurtList or 0
        return pCount
    end

    local function _showFriend( _charId )
        if not _charId then
            return
        end
        if _charId == gameUser.getUserId() then
            return
        end
        local function showFirendInfo( ... )
            HaoYouPublic.showFirendInfo(_charId, self)
        end
        local pData = HaoYouPublic.getFriendData()
        if not pData then
            HaoYouPublic.httpGetFriendData( self, showFirendInfo)
        else
            showFirendInfo()
        end 
    end
    local function tableCellTouched(table, cell)
        local _charId = cell._charId
        _showFriend(_charId)
    end
    local function cellSizeForTable( table, idx )
        return _cellSize.width,_cellSize.height
    end
    local function tableCellAtIndex( table, idx )
        if #self.data.hurtList then
            local cell = table:dequeueCell()
            if cell == nil then
                cell = cc.TableViewCell:new()
                cell:setContentSize(_cellSize)
            else
                cell:removeAllChildren()
            end 

            local cell_bg=ccui.Scale9Sprite:create("res/image/worldboss/sss_03.png")
            cell_bg:setContentSize(393,_cellSize.height+5)
            cell_bg:setAnchorPoint(0, 0.5)
            cell_bg:setPosition(0, cell:getContentSize().height*0.5)
            cell:addChild(cell_bg)
            --排名
            local index = idx + 1
            local rank_id
            if index >= 1 and index <= 3 then
                rank_id = cc.Sprite:create("res/image/worldboss/rank_" .. index .. ".png")
            else
                rank_id = XTHDLabel:createWithParams({text = index, size = 22})
            end
            rank_id:setPosition(35, cell:getContentSize().height*0.5-10)
            cell:addChild(rank_id)
             -- 图标
            -- dump(self.data.hurtList)
            local _hurtListData = self.data.hurtList[index] or {}
            cell._charId = _hurtListData.charId
            local icon_mum = _hurtListData.campId 
            icon_mum = tonumber(icon_mum) or 1
            icon_mum = icon_mum == 0 and 1 or icon_mum
            local icon1 = cc.Sprite:create("res/image/common/camp_Icon_"..icon_mum..".png")
            icon1:setAnchorPoint(0,0)
            icon1:setPosition(70,cell:getContentSize().height/2-15)   
            icon1:setScale(0.5) 
            cell:addChild(icon1)
            --玩家名字
            local name=XTHDLabel:createWithParams({text=_hurtListData.name,ttf="",size=18})
            name:setColor(cc.c3b(211,210,210))
            name:setAnchorPoint(0,0)
            name:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
            -- name:setColor(cc.c3b(70, 34, 34))
            name:setPosition(icon1:getPositionX()+icon1:getContentSize().width-10,cell:getContentSize().height/2-5)
            cell:addChild(name)

            --伤害
            local hurt = XTHDLabel:createWithParams({text=LANGUAGE_KEY_WORLDBOSS_TODAYATK(_hurtListData.hurt), size=18})
            hurt:setAnchorPoint(0,1)
            -- hurt:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
            hurt:setColor(cc.c3b(230, 215, 133))
            hurt:setPosition(70,cell:getContentSize().height/2-10)
            cell:addChild(hurt)
            return cell
        end 
    end
    hurtRankTableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    hurtRankTableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    hurtRankTableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    hurtRankTableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    hurtRankTableView:reloadData()
-- end

--伤害显示
-- function XiongShouLaiXiLayer:hurtView()
    -- local hurtView_bg=ccui.Scale9Sprite:create(cc.rect(20,20,1,1),"res/image/worldboss/hurt_bg.png")--cc.Sprite:create("res/image/worldboss/hurtrank_bg.png")
    -- hurtView_bg:setContentSize(_hurtViewSize)
    -- hurtView_bg:setAnchorPoint(0,0)
    -- hurtView_bg:setPosition(10,0)
    -- self.bg:addChild(hurtView_bg)

    local _hurtViewSize = cc.size(hurtRankView_bg:getContentSize().width - 10, pHeight)
    local hurtTableView = CCTableView:create(_hurtViewSize)
    self.hurtTableView = hurtTableView
    hurtTableView:setName("hurtTableView")
    hurtTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    hurtTableView:setPosition(cc.p(32+GetScreenOffsetX(), 0))
    hurtTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)--(cc.TABLEVIEW_FILL_TOPDOWN);
    hurtTableView:setBounceable(true)
    -- hurtTableView:scrollToLastCell(true)
    hurtTableView:setDelegate()
    hurtRankView_bg:addChild(hurtTableView)
    -- 注册事件
    local function numberOfCellsInTableView( table )
        local pCount = self.data.logList and #self.data.logList or 0
        return pCount
    end
    local function cellSizeForTable( table, idx )
        return  (hurtTableView:getContentSize().width-10),30
    end
    local function tableCellAtIndex( table, idx )
        if #self.data.logList then 
            local cell = table:dequeueCell()
            if cell == nil then
                cell = cc.TableViewCell:new()
            else
                cell:removeAllChildren()
            end
            cell:setContentSize(cc.size(hurtTableView:getContentSize().width - 10, 30 ))
            --伤害
            local index = idx + 1
            local hurt = XTHDLabel:createWithParams({
                text = self.data.logList[index], 
                size = 18,
                color = cc.c3b(230, 215, 133),
                anchor = cc.p(0,0.5),
                pos = cc.p(5,cell:getContentSize().height/2),
            })
            hurt:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
            cell:addChild(hurt)
            return cell
        end 
    end
    hurtTableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    hurtTableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    hurtTableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    hurtTableView:reloadData()
end

function XiongShouLaiXiLayer:freshSelfRankAndHurt( rankNum, hurtNum )
    local pWidth = self._hurtRankView_bg:getContentSize().width - 70

    local pNum = tonumber(rankNum) or 0
    pNum = pNum > 0 and pNum or 0
    self.my_rank:setString(pNum)
    self.my_rank:setFontSize(28)
    local _width = self.my_rank:getContentSize().width + self._myRankTitle:getContentSize().width
    self._myRankTitle:setPositionX(pWidth*0.5 - _width*0.5)
    self.my_rank:setPositionX(self._myRankTitle:getPositionX() + self._myRankTitle:getContentSize().width + 20)
    
    self.my_hurt:setString(LANGUAGE_KEY_WORLDBOSS_TODAYATK(hurtNum))
    self.my_hurt:setPositionX(pWidth*0.5 + 15)
end

function XiongShouLaiXiLayer:freshData( ... )
    local _timeString = XTHD.getTimeHMS(self.data.diffTime,true)
    self.time:setString(_timeString) 
    self:updateUnOpenLay(_timeString)
    local now_percent=string.format("%.4f", tonumber(self.data.curHp)/tonumber(self.data.maxHp)) *100--math.floor((tonumber(self.data.curHp)/tonumber(self.data.maxHp))) *100
    self.exp_progress_timer:setPercentage(now_percent)
    self.percent_label:setString(tostring(now_percent.."%"))
    self.peo_num:setString(tostring(self.data.totalSum))
    self:freshSelfRankAndHurt(self.data.myRank, self.data.myHurt)
    self.hurtRankTableView:reloadData()
    self.hurtTableView:reloadData()
    -- self.hurtTableView:scrollToLastCell(true)
    self:cdActive(self.data.diffTime)
    if self.data.openState and self.data.openState==1 then
        self:showUnOpenLay(true)
        if self.data.cd and self.data.cd>0 then
             self.battle_btn:setStateSelected("res/image/common/btn/fuhuo_up.png")
             self.battle_btn:setStateNormal("res/image/common/btn/fuhuo_down.png")
            --self.battle_btn:getLabel():setString("复活")
            self.cd_label:setString(LANGUAGE_KEY_WORLDBOSS_TIME(self.data.cd))
            self:cdRefresh(self.data.cd)
        end 
        self:delaytime()
        self.battle_btn:setVisible(true)
        self.exp_progress_bg:setVisible(true)
        self.peo_num:setVisible(true)
        self.peo_lable:setTexture("res/image/worldboss/battle_num.png")
        self.time_sp:setTexture("res/image/worldboss/cd_sp1.png")
    elseif self.data.openState==0 then
        self.battle_btn:setVisible(false)
        self.exp_progress_bg:setVisible(false)
        self.peo_num:setVisible(false)
        self.peo_lable:setTexture("res/image/worldboss/bosskill_"..self.data.deadState..".png")
        self.time_sp:setTexture("res/image/worldboss/cd_sp2.png")
        if not self._worldBossUnOpen then
            self:showUnOpenLay()
        end
    end
    self:showWorldBossHatredPop()
end

function XiongShouLaiXiLayer:showWorldBossHatredPop( )
    if gameUser._worldBossOver == 1 then
        local reward_pop=requires("src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiHatredPop.lua"):create()
        reward_pop:show()
        self:addChild(reward_pop, 3)
        gameUser._worldBossOver = 0
    end 
end

--数据刷新
function XiongShouLaiXiLayer:delaytime( _dTime )
    if self._isSending then
        return
    end
    self:stopAction(self._predAaction)
    self._predAaction = nil
    local pTiem = tonumber(_dTime) or 10
    local function _doHttp( ... )
        self._isSending = true
        self:doHttpOpenBossWindow(self, function ( data )
            self._isSending = false
            self.data = data 
            self:freshData()
        end, function ( ... )
            self._isSending = false
            self:delaytime()
        end)
    end
    if pTiem == 0 then
        _doHttp()
    else
        self._predAaction = performWithDelay(self, _doHttp, pTiem) 
    end
end

--复活倒计时刷新
function XiongShouLaiXiLayer:cdRefresh(cd)
    -- self:stopAction(self._cdAction )
    -- self._cdAction = nil
    -- if self.data.cd > 0 then
    --     self._cdAction = performWithDelay(self,
    --         function ( ... )
    --             cd=cd-1
    --             if cd>0 then
    --                 self.battle_btn:setStateSelected("res/image/worldboss/battle_select_0.png")
    --                 self.battle_btn:setStateNormal("res/image/worldboss/battle_normal_0.png")
    --                 self.cd_label:setString(LANGUAGE_KEY_WORLDBOSS_TIME(cd))
    --                 self:cdRefresh(cd)
    --             else
    --                 self.battle_btn:setStateSelected("res/image/worldboss/battle_select.png")
    --                 self.battle_btn:setStateNormal("res/image/worldboss/battle_normal.png")
    --                 self.cd_label:setString("")
    --                 self.data.cd = 0
    --             end  
    --     end, 1)
    -- else 
    --     self.cd_label:setString("")
    --     self.battle_btn:setStateSelected("res/image/worldboss/battle_select.png")
    --     self.battle_btn:setStateNormal("res/image/worldboss/battle_normal.png")
    -- end 

    local function _cdEnd( )
        self._globalScheduler:removeCallback(self._scheduleName2)
        self.cd_label:setString("")
         self.battle_btn:setStateSelected("res/image/common/btn/kstz_up.png")
         self.battle_btn:setStateNormal("res/image/common/btn/kstz_down.png")
        --self.battle_btn:getLabel():setString("马上参战")
        self.data.cd = 0
    end

    if self.data.cd > 0 then
         self.battle_btn:setStateSelected("res/image/common/btn/fuhuo_up.png")
         self.battle_btn:setStateNormal("res/image/common/btn/fuhuo_down.png")
        --self.battle_btn:getLabel():setString("复活")
        local function _updateTime( sTime )
            local _time = tonumber(sTime) or 0
            if _time > 0 then
                self.cd_label:setString(LANGUAGE_KEY_WORLDBOSS_TIME(_time))
            else
                _cdEnd()
            end
        end
        self._globalScheduler:addCallback(self._scheduleName2, {perCall = _updateTime, cdTime = self.data.cd})
        _updateTime(self.data.cd)
    else
       _cdEnd()
    end
   
end

--活动倒计时
function XiongShouLaiXiLayer:cdActive(cd)
    self._cd = cd
--     if self._cdActive then
--         return
--     end
--     self:docdActive()
-- end

-- function XiongShouLaiXiLayer:docdActive( )
--     local function _timeCount( dt )
--         self._countCd = self._countCd + dt
--         if self._countCd < 1 then
--             return
--         end
--         self._countCd = self._countCd - 1
--         self._cd = self._cd - 1
--         if self._cd > 0 then
--             local pString = XTHD.getTimeHMS(self._cd,true)
--             self.time:setString(pString) 
--             self:updateUnOpenLay(pString)
--             -- self:cdActive(cd)
--         else
--             self.time:setString("")
--             self:updateUnOpenLay(0)
--             self:delaytime(0)
--             self:cdActive(self.data.diffTime)
--         end 
--     end
--     self._countCd = 0
--     self._cdActive = true
--     self:scheduleUpdateWithPriorityLua(_timeCount, 0)
    local function _doEnd()
        self._globalScheduler:removeCallback(self._scheduleName)
        self.time:setString("")
        self:updateUnOpenLay(0)
        self:delaytime(0.1)
    end
    if self._cd <= 0 then
        _doEnd()
        return
    end
    local function _updateTime( sTime )
        local _time = tonumber(sTime) or 0
        if _time > 0 then
            local pString = XTHD.getTimeHMS(_time, true)
            self.time:setString(pString) 
            self:updateUnOpenLay(pString)
        else
            _doEnd()
        end
    end
    self._globalScheduler:addCallback(self._scheduleName, {perCall = _updateTime, cdTime = self._cd})
    _updateTime(self._cd)
end

function XiongShouLaiXiLayer:doHttpOpenBossWindow( par, callSuccess, callFail )
    ClientHttp:requestAsyncInGameWithParams({
        modules = "openBossWindown?",
        successCallback = function(data)
        -- print("世界boss服务器返回数据为：")
        -- print_r(data)
            if data.result==0 then
                if callSuccess then
                    callSuccess(data)
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
                if callFail then
                    callFail()
                end
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            if callFail then
                callFail()
            end
        end,--失败回调
        targetNeedsToRetain = par,--需要保存引用的目标
        loadingParent = par,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

--复活弹窗
function XiongShouLaiXiLayer:revival()
    local popLayer = XTHDDialog:create()
    local setnameBg=ccui.Scale9Sprite:create("res/image/worldboss/scale9_bg_34.png" )
    setnameBg:setContentSize(375,228)
    setnameBg:setPosition(popLayer:getContentSize().width/2, popLayer:getContentSize().height/2)
    popLayer:addChild(setnameBg)
    local txt_content  = nil
    local spent=(tonumber(self.data.clearCount)+1)*2
    if not contentNode then 
        txt_content = XTHDLabel:create(LANGUAGE_KEY_WORLDBOSS_FUHUO(spent),18)
        txt_content:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT )
        txt_content:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        txt_content:setColor(XTHD.resource.color.gray_desc)
        --解决文字过短居中的问题
        if tonumber(txt_content:getContentSize().width)<306 then
            txt_content:setDimensions(tonumber(txt_content:getContentSize().width), 120)
        else
            txt_content:setDimensions(306, 120)
        end
    else 
        txt_content = contentNode
    end
    txt_content:setPosition(setnameBg:getContentSize().width/2,setnameBg:getContentSize().height/2 + 30)
    setnameBg:addChild(txt_content)
    local btn_left = XTHD.createCommonButton({
        btnColor = "write",
        isScrollView = false,
        text = LANGUAGE_KEY_CANCEL,
        fontSize = 22,
        btnSize = cc.size(130, 51),
        pos = cc.p(100 + 5,50),
        endCallback = function()
            popLayer:removeFromParent()
        end
    })
    btn_left:setScale(0.8)
    btn_left:setCascadeOpacityEnabled(true)
    btn_left:setOpacity(255)
    setnameBg:addChild(btn_left)
    local btn_right = XTHD.createCommonButton({
        text = LANGUAGE_KEY_SURE,
        isScrollView = false,
        btnSize = cc.size(130, 51),
        fontSize = 22,
        pos = cc.p(setnameBg:getContentSize().width-100-5,btn_left:getPositionY()),
        endCallback = function()
            ClientHttp:requestAsyncInGameWithParams({
                modules = "clearBossCD?",
                successCallback = function(data)
                    if data.result and data.result==0 then
                        self.cd_label:setString("")
                         self.battle_btn:setStateSelected("res/image/common/btn/kstz_up.png")
                         self.battle_btn:setStateNormal("res/image/common/btn/kstz_down.png")
                        --self.battle_btn:getLabel():setString("马上参战")
                        popLayer:removeFromParent()
                        LayerManager.addShieldLayout()
                        local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongCopyLayer.lua"):create(BattleType.WORLDBOSS_PVE)
                        fnMyPushScene(_layer)  
                    else 
                        XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
                    end
                end,
                failedCallback = function()
                    if self then
                        self._isSending = false
                        self:delaytime()
                    end
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingParent = self,
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
            
        end 
    })
    btn_right:setScale(0.8)
    btn_right:setCascadeOpacityEnabled(true)
    btn_right:setOpacity(255)
    setnameBg:addChild(btn_right)
    return popLayer
end

return XiongShouLaiXiLayer