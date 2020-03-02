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
    self.mapLayer = params.par
    self.mapData = params.mapData or {}
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
    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_ZHONGZU_SHOUWEI ,callback = function()
        self:freshData()
    end})
end

function ZhongZuShouWei:onCleanup ( )
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_ZHONGZU_SHOUWEI)
end

function ZhongZuShouWei:onExit( )
end

function ZhongZuShouWei:initUI( )
    local size = self:getContentSize()

    local  boss_sp= cc.Node:create()
    boss_sp:setContentSize(557, 379)
    boss_sp:setAnchorPoint(0.5,0.5)
    boss_sp:setPosition(size.width/2, size.height/2)
    self:addChild(boss_sp)

    local heroid = gameData.getDataFromCSV("EnemyList",{monsterid = self.data1.bossId}).heroid
    if heroid < 10 then
        heroid = "0"..heroid
    end
    
    --进度条君
    local exp_progress_bg = cc.Sprite:create("res/image/worldboss/loardingbar_green_bg.png")
    self.exp_progress_bg=exp_progress_bg
    exp_progress_bg:setAnchorPoint(0.5,0.5)
    exp_progress_bg:setPosition(size.width/4 + 60,size.height - 100)
    exp_progress_bg:setScale(0.7)
    self:addChild(exp_progress_bg)
    local now_percent=string.format("%.4f", tonumber(self.data1.curHp)/tonumber(self.data1.maxHp)) *100--math.floor((tonumber(self.data.curHp)/tonumber(self.data.maxHp))) *100
    local exp_progress_timer = cc.ProgressTimer:create(cc.Sprite:create("res/image/worldboss/loardingbar_green.png"))
    exp_progress_timer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    exp_progress_timer:setMidpoint(cc.p(0,0))
    exp_progress_timer:setBarChangeRate(cc.p(1,0))
    exp_progress_timer:setPosition(exp_progress_bg:getContentSize().width/2, exp_progress_bg:getContentSize().height/2)
    exp_progress_timer:setPercentage(now_percent)
    self.exp_progress_timer=exp_progress_timer
    exp_progress_bg:addChild(exp_progress_timer)
    local percent_label=getCommonWhiteBMFontLabel(tostring(now_percent).."%")
    self.percent_label=percent_label                              
    percent_label:setPosition(exp_progress_bg:getContentSize().width/2,exp_progress_bg:getContentSize().height/2-5)
    exp_progress_bg:addChild(percent_label)
    percent_label:setVisible(false)

	local  boss_effect = sp.SkeletonAnimation:createWithBinaryFile( "res/spine/0"..heroid..".skel", "res/spine/0"..heroid..".atlas",1.0);
    boss_effect:setPosition(exp_progress_bg:getPositionX(), size.height *0.4 - 30)
    boss_effect:setAnimation(0,BATTLE_ANIMATION_ACTION.IDLE,true)
    boss_effect:setScale(1)
    self:addChild(boss_effect)
    self._bossSp = boss_sp
    self._bossEffect = boss_effect

    --查看奖励
    local reward_btn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/camp/shouwei/rewardBtn1.png", 
        selectedFile      = "res/image/camp/shouwei/rewardBtn2.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        pos = cc.p(32,15),
        endCallback = function()
            local reward_pop=requires("src/fsgl/layer/ZhongZu/ShouWeiRewardLayer.lua"):create()
            LayerManager.addLayout(reward_pop, {noHide = true})
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
            if self.mapLayer.__currentHost == 1 then
                XTHDTOAST("不能攻打自己领地的守卫！")
                return
            end
            ZhongZuDatas.requestServerData({
                target = self.mapLayer,
                method = "campRivalCity?",
                params = {cityId = self.__cityID},
                success = function(data)       		
                    if self.data1.deadState and self.data1.deadState==0 then
                        cityID = self.__cityID
                        LayerManager.addShieldLayout()
                        local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongCopyLayer.lua"):create(BattleType.CAMP_SHOUWEI,cityID,{monsterid = self.data1.bossId,cityid = cityID},true)
                        fnMyPushScene(_layer)
                    else 
                        cityID = self.__cityID
                        self.mapLayer:updateEnemyCityDFDSUM(cityID,data)
			            local page = requires("src/fsgl/layer/ZhongZu/EnemyCitySPLayer1.lua"):create(cityID,self.mapLayer.__currentHost,self.mapLayer)
			            self:addChild(page,10)	
                    end
    	        end,
    	        failure = function(data)
    		        if data and data.result == 4801 then  ----城市已被占领
				        ZhongZuDatas.requestServerData({
					        target = self.mapLayer,
				            method = "rivalCampCityList?",
				            success = function( )
				    	        self.mapLayer:updateCitysTips()
				    	        self.mapLayer:refreshTopBars()
				            end
				        })
    		        end 
    	        end
            })
        end
    })
    self.battle_btn=battle_btn
    self.battle_btn:setPositionX(self.battle_btn:getPositionX()-30)
    self.battle_btn:setPositionY(self.battle_btn:getPositionY()+10)
    self.battle_btn:setScale(1.3)
    battle_btn:setAnchorPoint(0.5,0)
    self:addChild(battle_btn)   

    local jisha = XTHDLabel:create("守卫已被击杀", 23, "res/fonts/def.ttf")
    self:addChild(jisha)
    jisha:setPosition(battle_btn:getPositionX(),self:getContentSize().height - 75)
    jisha:setColor(cc.c3b(255,10,10))
    self.jishaText = jisha

    local tip = XTHDLabel:create("请点击攻城攻入城内", 23, "res/fonts/def.ttf")
    self:addChild(tip)
    tip:setPosition(battle_btn:getPositionX(),battle_btn:getPositionY() - 15)
    tip:setColor(cc.c3b(255,10,10))
    self.tip = tip

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
           XTHDTOAST("暂未开启！")
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

    local attack = XTHDLabel:create("总伤害：0", 15, "res/fonts/def.ttf")
    rankBg:addChild(attack)
    attack:setPosition(215,26)
    attack:setColor(cc.c3b(255,255,255))
    attack:setString(self.data2.myHurt == 0 and "总伤害：暂无" or "总伤害："..self.data2.myHurt)
    self.attackText = attack

    if self.data1.deadState == 1 then
        self.tip:setVisible(true)
        self.jishaText:setVisible(true)
    else
        self.tip:setVisible(false)
        self.jishaText:setVisible(false)
    end

	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=40});
            self:addChild(StoredValue)
        end,
	})
	self:addChild(help_btn)
	help_btn:setPosition(self:getContentSize().width / 2 -  help_btn:getContentSize().width + 50,self:getContentSize().height - help_btn:getContentSize().height / 2)

    --伤害排行榜
    self:hurtRankView()
   
end

--伤害排名
function ZhongZuShouWei:hurtRankView(  )

    table.sort(self.data2.hurtList, function(a, b)
        return a.rank < b.rank
    end)

    local _hurtListSize = cc.size(self.rankBg:getContentSize().width - 60,self.rankBg:getContentSize().height - 130)

    local hurtRankTableView = CCTableView:create(_hurtListSize)
    hurtRankTableView:setName("hurtRankTableView")
    hurtRankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    hurtRankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    hurtRankTableView:setBounceable(true)
    hurtRankTableView:setDelegate() 
    self.hurtRankTableView = hurtRankTableView
    self.rankBg:addChild(hurtRankTableView)
    hurtRankTableView:setPosition(30,56)
    -- 注册事件
    local function numberOfCellsInTableView( table )
        return #self.data2.hurtList
    end

    local function tableCellTouched(table, cell)
        
    end
    local function cellSizeForTable( table, idx )
        return self.rankBg:getContentSize().width - 60,40
    end
    local function tableCellAtIndex( table, idx )
        if #self.data2.hurtList then
            local cell = table:dequeueCell()
            if cell == nil then
                cell = cc.TableViewCell:new()
                cell:setContentSize(self.rankBg:getContentSize().width - 60,50)
            else
                cell:removeAllChildren()
            end 

            local cell_bg=cc.Sprite:create("res/image/camp/shouwei/cellBg.png")
            cell:addChild(cell_bg)
            cell_bg:setPosition(cell:getContentSize().width/2, cell:getContentSize().height/2)
            --排名
            local index = idx + 1
            local rank_id
--            if index >= 1 and index <= 3 then
--                rank_id = cc.Sprite:create("res/image/worldboss/rank_" .. index .. ".png")
--            else
                rank_id = XTHDLabel:createWithParams({text = index, size = 20})
                rank_id:setColor(cc.c3b(0,0,0))
--            end
            rank_id:setPosition(30, cell:getContentSize().height/2)
            cell:addChild(rank_id)

            --玩家名字
            local name=XTHDLabel:createWithParams({text=self.data2.hurtList[index].name,ttf="",size=15})
            name:setColor(cc.c3b(0,0,0))
--            name:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
            name:setPosition(rank_id:getPositionX()+82,cell:getContentSize().height/2)
            cell:addChild(name)

            --伤害
            local hurt = XTHDLabel:createWithParams({text=self.data2.hurtList[index].hurt, size=15})
            -- hurt:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
            hurt:setColor(cc.c3b(0, 0, 0))
            hurt:setPosition(name:getPositionX() + 105,cell:getContentSize().height/2)
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

end

function ZhongZuShouWei:freshData()
    --刷新数据
    print("刷新种族守卫界面")
    local campID 
    if self.mapLayer.__currentHost == 1 then
        campID = gameUser.getCampID()
    else
        campID = gameUser.getCampID() == 1 and 2 or 1
    end
    HttpRequestWithParams("campBossInfo",{cityId = self.__cityID,campId = campID}, function(data)
        self.data1 = data
        local now_percent = string.format("%.4f", tonumber(data.curHp)/tonumber(data.maxHp)) *100
        self.exp_progress_timer:setPercentage(now_percent)
        if data.deadState == 1 then
            self.tip:setVisible(true)
            self.jishaText:setVisible(true)
        else
            self.tip:setVisible(false)
            self.jishaText:setVisible(false)
        end
    end )
    HttpRequestWithParams("campBossHurtRank",{cityId = self.__cityID,campId = campID}, function(data)
        self.data2 = data
        table.sort(self.data2.hurtList, function(a, b)
            return a.rank < b.rank
        end)
        self.attackText:setString(self.data2.myHurt == 0 and "总伤害：暂无" or "总伤害："..self.data2.myHurt)
        self.hurtRankTableView:reloadData()
    end )
end

function ZhongZuShouWei:doHttpOpenBossWindow( par, callSuccess, callFail )
    local campID 
    if self.mapLayer.__currentHost == 1 then
        campID = gameUser.getCampID()
    else
        campID = gameUser.getCampID() == 1 and 2 or 1
    end
    ClientHttp:requestAsyncInGameWithParams({
        modules = "campBossHurtRank?",
        params = {cityId = self.__cityID,campId = campID},
        successCallback = function(data)
--         print("伤害排行榜服务器返回数据为：")
--         print_r(data)
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

