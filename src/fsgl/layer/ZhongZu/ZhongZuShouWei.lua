--领地战守卫界面
local ZhongZuShouWei=class("ZhongZuShouWei",function ()
    return XTHD.createBasePageLayer({
        bg = "res/image/camp/shouwei/bg.png",
        isOnlyBack = true,
    })
end)

function ZhongZuShouWei:createForLayerManager( params )
    print("领地战守卫服务器返回的数据为：")
    print_r(params)
    self.__cityID = params.cityID
    ZhongZuShouWei:doHttpOpenBossWindow(params.par, function ( data )
        LayerManager.addShieldLayout()
        local pLay = ZhongZuShouWei.new(params.serverData,data)
        LayerManager.addLayout(pLay)
    end)
end

function ZhongZuShouWei:ctor(serverData,rankData)
    self.data1 = serverData
    self.data2 = rankData
    self.name = {"汜\n水\n守\n将","陈\n塘\n守\n将","西\n岐\n守\n将","朝\n歌\n守\n将","长\n安\n守\n将"}
	self:initUI()
end

function ZhongZuShouWei:onEnter( )

end

function ZhongZuShouWei:onCleanup ( )

end

function ZhongZuShouWei:onExit( )
end

function ZhongZuShouWei:initUI( )
    local size = self:getContentSize()

    --伤害排名
--    self:hurtRankView()

    local  boss_sp= cc.Node:create()
    boss_sp:setContentSize(557, 379)
    boss_sp:setAnchorPoint(0.5,0.5)
    boss_sp:setPosition(size.width/2, size.height/2)
    self:addChild(boss_sp)

    local heroid = gameData.getDataFromCSV("EnemyList",{monsterid = self.data1.bossId}).heroid
    if heroid < 10 then
        heroid = "0"..heroid
    end
    local  boss_effect = sp.SkeletonAnimation:createWithBinaryFile( "res/spine/0"..heroid..".skel", "res/spine/0"..heroid..".atlas",1.0);
    boss_effect:setPosition(GetScreenOffsetX() + 80, 90)
    boss_effect:setAnimation(0,BATTLE_ANIMATION_ACTION.IDLE,true)
    boss_effect:setScale(1)
    boss_sp:addChild(boss_effect)
    self._bossSp = boss_sp
    self._bossEffect = boss_effect
    
    --进度条君
    local exp_progress_bg = cc.Sprite:create("res/image/worldboss/loardingbar_green_bg.png")
    self.exp_progress_bg=exp_progress_bg
    exp_progress_bg:setAnchorPoint(0.5,0.5)
    exp_progress_bg:setPosition(size.width/4 + 60,size.height - 100)
    exp_progress_bg:setScale(0.7)
    self:addChild(exp_progress_bg)
    local now_percent=string.format("%.4f", tonumber(self.data1.curHp)/tonumber(self.data1.maxHp)) *100--math.floor((tonumber(self.data.curHp)/tonumber(self.data.maxHp))) *100
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
    percent_label:setVisible(false)

    --查看奖励
    local reward_btn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/camp/shouwei/rewardBtn1.png", 
        selectedFile      = "res/image/camp/shouwei/rewardBtn2.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        pos = cc.p(32,15),
        endCallback = function()
--            local reward_pop=requires("src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiRewardPop.lua"):create()
--            LayerManager.addLayout(reward_pop, {noHide = true})
        end
    })
    reward_btn:setScale(1.5)
    reward_btn:setAnchorPoint(0,0)
    self:addChild(reward_btn)
    --攻城
    local battle_btn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/camp/shouwei/battleBtn1.png", 
        selectedFile      = "res/image/camp/shouwei/battleBtn2.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        pos = cc.p(size.width/4 + 100,135),
        endCallback = function()
--            if self.data1.openState and self.data1.openState==1 then
--                if self.data.cd ==0 then
--                    YinDaoMarg:getInstance():overCurrentGuide(true)
--                    LayerManager.addShieldLayout()
--                    local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongCopyLayer.lua"):create(BattleType.WORLDBOSS_PVE)
--                    fnMyPushScene(_layer)
--                else 
--                    local layer=self:revival()
--                    self:addChild(layer)
--                end
--            else 
--                XTHDTOAST(LANGUAGE_TIPS_WORDS237)
--            end
        end
    })
    self.battle_btn=battle_btn
    self.battle_btn:setPositionX(self.battle_btn:getPositionX()-30)
    self.battle_btn:setPositionY(self.battle_btn:getPositionY()+10)
    self.battle_btn:setScale(1.3)
    battle_btn:setAnchorPoint(0.5,0)
    self:addChild(battle_btn)   

    local textBg = cc.Sprite:create("res/image/camp/shouwei/textBg.png")
    self:addChild(textBg)
    textBg:setPosition(self:getContentSize().width/4 - 80,self:getContentSize().height/2 + 100)
    textBg:setScale(1.3)
    local textName = XTHDLabel:create(self.name[self.__cityID], 17, "res/fonts/def.ttf")
    textBg:addChild(textName)
    textName:setPosition(textBg:getContentSize().width/2 - 2,textBg:getContentSize().height/2 + 3)
    textName:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    textName:setColor(cc.c3b(255,255,255))

    local rankBg = cc.Sprite:create("res/image/camp/shouwei/scrollBg.png")
    self:addChild(rankBg)
    rankBg:setPosition(self:getContentSize().width/4*3,self:getContentSize().height/2)
    rankBg:setScale(1.3)
    self.rankBg = rankBg

    local guild_btn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/camp/shouwei/crankBtn1.png", 
        selectedFile      = "res/image/camp/shouwei/crankBtn2.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback = function()
           
        end
    })
    rankBg:addChild(guild_btn)
    guild_btn:setPosition(115,rankBg:getContentSize().height - 28)

    local geren_btn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/camp/shouwei/grankBtn1.png", 
        selectedFile      = "res/image/camp/shouwei/grankBtn2.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback = function()
           
        end
    })
    rankBg:addChild(geren_btn)
    geren_btn:setPosition(225,rankBg:getContentSize().height - 28)

    local topBg = cc.Sprite:create("res/image/camp/shouwei/top.png")
    rankBg:addChild(topBg)
    topBg:setPosition(rankBg:getContentSize().width/2,rankBg:getContentSize().height - 60)

    local text1 = XTHDLabel:create("排名", 15, "res/fonts/def.ttf")
    topBg:addChild(text1)
    text1:setPosition(25,topBg:getContentSize().height/2 - 2)
    text1:setColor(cc.c3b(255,10,10))
    local text2 = XTHDLabel:create("玩家昵称", 15, "res/fonts/def.ttf")
    topBg:addChild(text2)
    text2:setPosition(105,topBg:getContentSize().height/2 - 2)
    text2:setColor(cc.c3b(255,10,10))
    local text3 = XTHDLabel:create("总伤害", 15, "res/fonts/def.ttf")
    topBg:addChild(text3)
    text3:setPosition(210,topBg:getContentSize().height/2 - 2)
    text3:setColor(cc.c3b(255,10,10))

    local nickName = XTHDLabel:create(gameUser.getNickname(), 13, "res/fonts/def.ttf")
    rankBg:addChild(nickName)
    nickName:setPosition(95,26)
    nickName:setColor(cc.c3b(255,255,255))

    local attack = XTHDLabel:create("总伤害：暂无", 15, "res/fonts/def.ttf")
    rankBg:addChild(attack)
    attack:setPosition(215,26)
    attack:setColor(cc.c3b(255,255,255))

--	local help_btn = XTHDPushButton:createWithParams({
--		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
--        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
--        musicFile = XTHD.resource.music.effect_btn_common,
--        endCallback       = function()
--            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=32});
--            self:addChild(StoredValue)
--        end,
--	})
--	self:addChild(help_btn)
--	help_btn:setPosition(self:getContentSize().width / 2 -  help_btn:getContentSize().width + 50,self:getContentSize().height - help_btn:getContentSize().height / 2)
   
end

--伤害排名
function ZhongZuShouWei:hurtRankView(  )
    local _hei = 60
    local _bgSize = cc.size(513, self:getContentSize().height)
    local hurtRankView_bg = ccui.Scale9Sprite:create("res/image/worldboss/sss_03.png")
    self._hurtRankView_bg = hurtRankView_bg
    hurtRankView_bg:setContentSize(_bgSize)
    -- local hurtRankView_bg=cc.Sprite:create("res/image/worldboss/hurtrank_bg.png")
    hurtRankView_bg:setAnchorPoint(0, 0.5)
    hurtRankView_bg:setPosition(0 + GetScreenOffsetX(), _bgSize.height*0.5+10)
    self:addChild(hurtRankView_bg)

    local pHeight = 125
    local _hurtListSize = cc.size(hurtRankView_bg:getContentSize().width - 10, _bgSize.height - pHeight - _hei)

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
             --?图标
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

function ZhongZuShouWei:freshSelfRankAndHurt( rankNum, hurtNum )
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

function ZhongZuShouWei:freshData()

end

function ZhongZuShouWei:doHttpOpenBossWindow( par, callSuccess, callFail )
    ClientHttp:requestAsyncInGameWithParams({
        modules = "campBossHurtRank?",
        params = {cityId = self.__cityID,campId = gameUser.getCampID()},
        successCallback = function(data)
         print("伤害排行榜服务器返回数据为：")
         print_r(data)
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

return ZhongZuShouWei

