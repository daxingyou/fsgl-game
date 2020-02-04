--[[生命之树界面]]
local ShengMingZhiShu = class("ShengMingZhiShu",function( )
	return cc.Layer:create()
end)

function ShengMingZhiShu:ctor(parent)
	self._parent = parent
end
local this = nil
function ShengMingZhiShu:create(datalist,parent)
	local lifeTree = ShengMingZhiShu.new(funcID,parent)
    if lifeTree then 
        lifeTree:init(datalist)
    end 
    return lifeTree
end

function ShengMingZhiShu:init(datalist)
	--背景
    this = self
    self._curExp = datalist._curExp              --当前经验
    self._maxExp = datalist._maxExp              --升级所需经验
    self._treeLevel = datalist._treeLevel        --当前树的等级
    self._addExperience = nil                    --浇水一次可获得经验
    self._nextTimeLable = nil                    --收获倒计时显示的文本
    self._nextTime = datalist._nextTime          --收货倒计时时间 
    self._freeCount = datalist._freeCount        --剩余免费浇水次数
    self._List = {}
    self._state = datalist._state                --領取狀態
    self._addExp = 0
    self._maxFreeCount = 0                       --最大免费浇水次数
    self._curWaterCount = 0                      --当前浇水次数
    self._buyWaterCount = gameUser.getVip()
    self:initScene()
end


function ShengMingZhiShu:initScene(  )
   -- LayerManager.setChatRoomVisable(false)
    local bg = ccui.Scale9Sprite:create("res/image/camp/lifetree/shubg1.png")
	local size = cc.Director:getInstance():getWinSize()
	bg:setContentSize(size)
    self:addChild(bg)
    bg:setAnchorPoint(cc.p(0.5,0.5))
    bg:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
    self._bg = bg
   -- self._bg:setContentSize(self:gemBg:getContentSize())

    self._nextTimeLeble = XTHDLabel:create("下次收获还需：00：00：00",18,"res/fonts/def.ttf")
    self._nextTimeLeble:setColor(cc.c3b(255,255,255))
    self._bg:addChild(self._nextTimeLeble)
    self._nextTimeLeble:setPosition(self._bg:getContentSize().width/2,self._bg:getContentSize().height - 50)
    
    self:updateHarvestTime()

    --关闭按钮
    local close_btn = XTHD.createNewBackBtn(function ()
        self:stopAllActions()
        --LayerManager.setChatRoomVisable(true)
        LayerManager.removeLayout()
    end)
    close_btn:setAnchorPoint(1,1)
    bg:addChild(close_btn)
    close_btn:setPosition(cc.p(bg:getContentSize().width,self:getContentSize().height))

    local _freeCount = self._freeCount
    if _freeCount < 0 then
        _freeCount = 0
    end
    --免费浇水次数
    local _freeCoutnLable = XTHDLabel:createWithParams({
            text = "每日免费浇水次数：".. tostring(_freeCount),-----"派出队伍:",
            fontSize = 16,
            color = cc.c3b(255,255,255),
        })
    bg:addChild(_freeCoutnLable)
    _freeCoutnLable:setAnchorPoint(0,1)
    _freeCoutnLable:setPosition(cc.p(36,self:getContentSize().height - 10))
    self._freeCoutnLable = _freeCoutnLable

    local _buycount = gameUser.getVip()
    if self._freeCount <= 0 then
        _buycount = gameUser.getVip() + self._freeCount
    end
    self._buyWaterCount = _buycount
    --剩余购买次数
    local buyCount = XTHDLabel:createWithParams({
        text = "每日可购买浇水次数：".. tostring(_buycount),-----"派出队伍:",
        fontSize = 16,
        color = cc.c3b(255,255,255),
    })
    bg:addChild(buyCount)
    buyCount:setAnchorPoint(0,1)
    buyCount:setPosition(cc.p(_freeCoutnLable:getContentSize().width + _freeCoutnLable:getContentSize().width / 2,self:getContentSize().height - 10))
    self._buyCount = buyCount
    -- --元宝显示
    -- local _barkBG = cc.Sprite:create("res/image/common/topbarItem_bg.png")
    -- _barkBG:setAnchorPoint(cc.p(0.5,0.5))
    -- bg:addChild(_barkBG)
    -- _barkBG:setPosition(cc.p(bg:getContentSize().width - 200,bg:getContentSize().height - 65))

    -- local _numLabel = getCommonWhiteBMFontLabel("999")
    -- _barkBG:addChild(_numLabel)
    -- _numLabel:setPosition(cc.p(_barkBG:getContentSize().width/2,_barkBG:getContentSize().height/2 - 5))
    -- _numLabel:setString(getHugeNumberWithLongNumber(gameUser.getIngot(),1000000))
    -- self._numLabel = _numLabel

    -- local gold = cc.Sprite:create("res/image/common/common_gold.png")
    -- gold:setAnchorPoint(cc.p(0.5,0.5))
    -- _barkBG:addChild(gold)
    -- gold:setPosition(cc.p(0,_barkBG:getContentSize().height/2))

    -- --增加元宝按钮
    -- local _addButton  = XTHDPushButton:createWithParams({
    --     normalFile        = "res/image/common/btn/btn_plus_normal.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
    --     selectedFile      = "res/image/common/btn/btn_plus_selected.png",
    --     musicFile = XTHD.resource.music.effect_btn_common,
    --     endCallback       = function()
    --    -- self:getParent():cleanOperatorBtns()
    --         XTHD.createRechargeVipLayer( self)  
    --     end,
    -- })
    -- local _size = _addButton:getContentSize()
    -- _addButton:setAnchorPoint(1,0.5)
    -- _addButton:setPosition(_barkBG:getContentSize().width + 10, _barkBG:getContentSize().height/2)
    -- _barkBG:addChild(_addButton)
    -- _addButton:setTouchSize(cc.size(_addButton:getContentSize().width + 20,_addButton:getContentSize().height))
    -- _addButton:setTouchSize(cc.size(_size.width + 20,_size.height + 20))

    --生命s树
    local btn_tree = XTHDPushButton:createWithParams({
        normalNode = cc.Sprite:create("res/image/camp/lifetree/shu.png"),
        selectedNode = cc.Sprite:create("res/image/camp/lifetree/shu.png"),
        needSwallow = true,
        enable = true,
        touchScale = 0.99,
        endCallback = function ()
            self:ClickTreeCallback()
        end
    })
    bg:addChild(btn_tree)
    btn_tree:setAnchorPoint(cc.p(0.5,0))
    btn_tree:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height/2 - 170))
    btn_tree:setScale(0.8)
    self._btn_tree = btn_tree

	local offsetX = GetScreenOffsetX()

    --浇水按钮
    local watering_btn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/camp/lifetree/jiaoshui_up.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = "res/image/camp/lifetree/jiaoshui_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            self:Watering()
        end,
    })
    self._watering_btn = watering_btn

    local _size = watering_btn:getContentSize()
    watering_btn:setAnchorPoint(0,0.5)
    watering_btn:setPosition(20 + offsetX,self:getContentSize().height - 90)
    self._bg:addChild(watering_btn)
    watering_btn:setTouchSize(cc.size(watering_btn:getContentSize().width + 20,watering_btn:getContentSize().height))
    watering_btn:setTouchSize(cc.size(_size.width + 20,_size.height + 20))

    --排行榜按鈕
    local ranking_btn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/camp/lifetree/raking_up.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = "res/image/camp/lifetree/shubtn3_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            self:initWaterList()
        end,
    })
    self._bg:addChild(ranking_btn)
    ranking_btn:setAnchorPoint(0,0.5)
    ranking_btn:setPosition(20 + offsetX,watering_btn:getPositionY() - watering_btn:getContentSize().height -20 )

    --玩法說明
    local help_btn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/camp/lifetree/shubtn3_up.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = "res/image/camp/lifetree/shubtn3_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=21}); --生命之树玩法说明
            self:addChild(StoredValue)
        end,
    })
    local consumeStr = "<color=#FFFFFF fontSize=20 font=Helvetica>".. "生命之树 " ..":</color>"
                        .."/><color=#FFFFFF fontSize=20 font=Helvetica>".."LV" .. tostring(self._treeLevel).."</color>"
    local tree_Level = RichLabel:createARichText(consumeStr,true)
    tree_Level:setAnchorPoint(cc.p(0.5,0.5))
    self._bg:addChild(tree_Level)
    tree_Level:setPosition(cc.p(btn_tree:getPositionX()+10,160))
    self._tree_Level = tree_Level

    consumeStr = "<color=#FFFFFF fontSize=20 font=Helvetica>".. "当前经验值： " .."</color>"
                        .."/><color=#FFFFFF fontSize=20 font=Helvetica>"..tostring(self._curExp) .."  </color>"
                        .."/><color=#FFFFFF fontSize=20 font=Helvetica>".."升级还需".."</color>"
                        .."/><color=#FFFFFF fontSize=20 font=Helvetica>".. tostring(self._maxExp - self._curExp ) .."</color>"
                        .."/><color=#FFFFFF fontSize=20 font=Helvetica>".. "经验值" .."</color>"
    local tree_exp = RichLabel:createARichText(consumeStr,true)
    tree_exp:setAnchorPoint(cc.p(0.5,0.5))
    self._bg:addChild(tree_exp)
    tree_exp:setPosition(cc.p(self._tree_Level:getPositionX(),self._tree_Level:getPositionY()-70))
    self._tree_exp = tree_exp

    self._bg:addChild(help_btn)
    help_btn:setAnchorPoint(cc.p(1,0.5))
    help_btn:setPosition(self._bg:getContentSize().width-20,help_btn:getContentSize().height/2+30)

    --进度条
    local bar_bg = cc.Sprite:create("res/image/camp/lifetree/smzs_loading1.png")
    self._bg:addChild(bar_bg)
    bar_bg:setScale(0.9)
    bar_bg:setAnchorPoint(0.5,1)
    bar_bg:setPosition(self._bg:getContentSize().width / 2,125)

    ---经验进度条
    local _exp_progress_timer = cc.ProgressTimer:create(cc.Sprite:create("res/image/camp/lifetree/smzs_loading2.png"))
    _exp_progress_timer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    _exp_progress_timer:setMidpoint(cc.p(0, 0))
    _exp_progress_timer:setBarChangeRate(cc.p(1, 0))
    _exp_progress_timer:setPosition(bar_bg:getContentSize().width/2, bar_bg:getContentSize().height/2)
    bar_bg:addChild(_exp_progress_timer)
    self._exp_progress_timer = _exp_progress_timer

    local percentage = 0
    if self._maxExp ~= 0 and self._curExp >= 0 then
        percentage = self._curExp/self._maxExp*100
    else
        percentage = 0
    end

    self._exp_progress_timer:setPercentage(percentage);

    local guoshibg = cc.Sprite:create( "res/image/camp/lifetree/light.png");
    btn_tree:addChild(guoshibg)
    guoshibg:setPosition(cc.p(btn_tree:getContentSize().width/2 + 20,100))
    self._guoshibg = guoshibg

    local guoshi = cc.Sprite:create( "res/image/camp/lifetree/guoshi1.png"); 
    btn_tree:addChild(guoshi)
    guoshi:setPosition(cc.p(btn_tree:getContentSize().width/2 + 20,100))
    self._guoshi = guoshi
    self._guoshi:setVisible(true)

    local rotate = cc.RotateBy:create(1,60)
    local scaleTo = cc.ScaleTo:create(1.5,1.5)
    local scaleTo_2 = cc.ScaleTo:create(1.5,1)
    local seq = cc.Sequence:create(scaleTo,scaleTo_2,nil)
    self._guoshi:runAction(cc.RepeatForever:create(seq))
    self._guoshibg:runAction(cc.RepeatForever:create(rotate))

    self._guoshibg:setVisible(false)
    self._guoshi:setVisible(false)

    --浇水获得经验文本
    local addExpLable = XTHDLabel:createWithParams({
        text = "获得经验值".. tostring(self._addExp),-----"派出队伍:",
        fontSize = 22,
        color = cc.c3b(255,255,0)
    })
    self._bg:addChild(addExpLable)
    addExpLable:setAnchorPoint(0.5,0.5)
    addExpLable:setVisible(false)
    addExpLable:setPosition(cc.p(self._tree_exp:getPositionX(),self._tree_exp:getPositionY()-40))
    self.addExpLable = addExpLable
end

function ShengMingZhiShu:LifeTreeInit(  )
    ClientHttp:requestAsyncInGameWithParams({
        modules = "openTree?",
        successCallback = function( data )
            -- dump(data,"获取服务器参数")
            self._curExp = data.curExp
            self._maxExp = data.maxExp
            self._treeLevel = data.level 
            self._state = data.state
            --self._addExperience = 0
            self._nextTime = data.nextTime/1000 - os.time()
            if self._nextTime <= 0 then
                self._nextTime = 0
            end
            print(self._nextTime)
            self._freeCount = data.freeCount
            print("--------------------",self._curExp,self._maxExp,self._treeLevel)
            self:initScene()
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    })
end

function ShengMingZhiShu:initWaterList( ... )
     ClientHttp:requestAsyncInGameWithParams({
        modules = "waterList?",
        successCallback = function( data )
           self._List = data.list
           self:RankingList()
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    })
end

function ShengMingZhiShu:RankingList()
    local maskLayer = XTHDDialog:create()
    maskLayer:setSwallowTouches( true )
    maskLayer:setContentSize( self:getContentSize() )
    maskLayer:setOpacity( 127.5 )
    maskLayer:setPosition( 0, 0 )
    self:addChild( maskLayer )
    local scale9_sp = getScale9SpriteWithImg("res/image/common/scale9_bg1_34.png",cc.size( 664, 484 ))
    local pop_bg =  XTHDPushButton:createWithParams({normalNode =scale9_sp })
    -- XTHDImage:create("res/image/plugin/warehouse/warehouse_chose_hero_bg.png")
    pop_bg:setAnchorPoint(0.5,1)
    pop_bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height-85)
    self:addChild(pop_bg,5)

    local orderTable = {}

    for i = 1, 20 do
    	orderTable[i] = i
    end

    local tableView = cc.TableView:create(cc.size(pop_bg:getContentSize().width - 10,pop_bg:getContentSize().height-40))
    tableView:setAnchorPoint(cc.p(0.5,0.5))
	tableView:setPosition(cc.p(5,25))
	tableView:setBounceable( true )
	tableView:setDirection(ccui.ScrollViewDir.vertical)
	tableView:setDelegate()
	tableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	pop_bg:addChild( tableView )

	local cellSize = cc.size( pop_bg:getContentSize().width - 8, 95 )
	local function numberOfCellsInTableView( table )
		return #self._List
	end
	local function cellSizeForTable( table, index )
		return cellSize.width,cellSize.height
	end
	local function tableCellAtIndex( table, index )
        print("名词索引==============>",index)
		local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
        end
        -- 数据
        index = index + 1
        --local data = staticData[index]
        -- cell背景
        local cellBg = ccui.Scale9Sprite:create( "res/image/common/scale9_bg_32.png" )
        cellBg:setContentSize( cellSize.width - 50, cellSize.height - 5 )
        cellBg:setAnchorPoint( cc.p( 0, 0 ) )
        cellBg:setPosition( 22, 5 )
        cell:addChild( cellBg )
        -- 分隔线
        local splitLine = ccui.Scale9Sprite:create( cc.rect( 0, 0, 3, 2 ), "res/image/ranklistreward/splitcell.png" )
        splitLine:setContentSize( cellSize.width - 55, 1 )
        splitLine:setAnchorPoint( cc.p( 0.5, 0 ) )
        splitLine:setPosition( cellSize.width/2 - 2, 3 )
        cell:addChild( splitLine )
        -- 排名icon
        local rankIcon = XTHD.createSprite()
        rankIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
        rankIcon:setPosition( 40, cellSize.height*0.5 + 3 )
        cellBg:addChild( rankIcon )

        --玩家昵称
        local playerInfo = XTHD.createLabel({
	    	anchor = cc.p( 0.5, 0.5 ),
	    	pos = cc.p( cellBg:getContentSize().width*0.5, cellBg:getContentSize().height*0.5 ),
	    	fontSize = 18,
	    	color = XTHD.resource.color.gray_desc,
		})
	    cellBg:addChild( playerInfo )
	    playerInfo:setString( self._List[index].name )

	    --VIP等级
	    local freeCount = XTHD.createLabel({
			fontSize = 18,
			color = XTHD.resource.color.gray_desc,
			anchor = cc.p(0.5,0.5),
		})
		freeCount:setString( "浇水次数"..tostring(self._List[index].count) )
    	cell:addChild(freeCount)
    	freeCount:setPosition(cc.p(cellSize.width - 120,cellSize.height*0.5))

    	local rankNum = cc.Label:createWithBMFont( "res/fonts/paihangbangword.fnt", 0 )
	    rankNum:setPosition( 40, cellSize.height*0.5 - 4 )
	    cellBg:addChild( rankNum )
	    rankNum:setString( index )
	    if index < 10 then
			local rankIconPath = ""
			if index <= 3 then
				rankIconPath = "res/image/ranklistreward/"..( index)..".png"
				rankNum:setVisible(false)
			else
				rankIconPath = "res/image/ranklist/rank_4.png"
				rankNum:setVisible(true)
			end
			rankIcon:setTexture( rankIconPath )
			rankIcon:setScale(0.8)
			rankIcon:setVisible( true )
		else
			rankIcon:setVisible( false )
		end

    	return cell
	end
	tableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    tableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    tableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    tableView:reloadData()

    local close_btn = XTHD.createBtnClose(function()
        if self._schedule  then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schedule)
            self._schedule = nil
        end
        pop_bg:removeFromParent()
        maskLayer:removeFromParent()
    end)
    pop_bg:addChild(close_btn)
    close_btn:setPosition(cc.p(pop_bg:getContentSize().width-5, pop_bg:getContentSize().height-5))
end

function ShengMingZhiShu:ClickTreeCallback()
    if self._nextTime > 0  or self._state ~= 1 then
        XTHDTOAST("未到领取时间")
        return
    end
	ClientHttp:requestAsyncInGameWithParams({
        modules = "getFruit?",
        successCallback = function( data )
            -- dump(data,"aaa")
            if tonumber(data.result) == 0 then
                local show_data = {}
                for i = 1, #data.bagItems do
                    show_data[#show_data+1] = {rewardtype = 4,id = data["bagItems"][i].itemId,num =1}
                end
                ShowRewardNode:create(show_data)
                for i=1,#data.bagItems do
                    local _data = data["bagItems"][i] 
                    if _data then
                        DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
                        if self._last_select_dbid == _data["dbId"] and tonumber(_data["count"]) == 0 then
                            self._last_select_dbid = nil
                        end
                    end
                 end
                self:LifeTreeInit()
				self:stopAllActions()
				--self:updateHarvestTime()
                --self:refreshListWhenOpenBox()   
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
            else
                XTHDTOAST(data.msg)
            end 
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    })
end

function ShengMingZhiShu:Watering( ... )
    local onWatering = function ( ... )
          ClientHttp:requestAsyncInGameWithParams({
            modules = "watering?",
            successCallback = function( data )
                -- dump(data,"浇水data")
                if tonumber(data.result) == 0 then
                    local addExp = data.curExp - self._curExp
                    self._addExp = addExp
                    self._curExp = data.curExp
                    self._treeLevel = data.level
                    self._maxExp = data.maxExp
                    self._freeCount = self._freeCount - 1
                    self:Wateringback(addExp)
                    self._maxFreeCount = data.maxFreeCount
                    self._curWaterCount = data.curWaterCount
                    local show_data = {}
                    for i = 1,#data["bagItems"] do
                        show_data[#show_data+1] = {rewardtype = 4,id = data["bagItems"][i].itemId,num =1}
                    end
                    for i=1,#data.property do
                        local pro_data = string.split( data.property[i],',')
                        --如果奖励类型存在，而且不是vip升级(406)则加入奖励
                        if tonumber(pro_data[1]) ~= 406 and XTHD.resource.propertyToType[tonumber(pro_data[1])] then
                            local getNum = tonumber(pro_data[2]) - tonumber(gameUser.getDataById(pro_data[1]))
                            print("==========================>>>>>>",tonumber(pro_data[2]),tonumber(gameUser.getDataById(pro_data[1])))
                            if getNum > 0 then
                                local idx = #show_data + 1
                                show_data[idx] = {}
                                show_data[idx].rewardtype = XTHD.resource.propertyToType[tonumber(pro_data[1])]
                                show_data[idx].num = getNum
                            end
                        end
                        DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
                    end
                    ShowRewardNode:create(show_data)
                    for i=1,#data.bagItems do
                        local _data = data["bagItems"][i] 
                        if _data then
                            DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
                            if self._last_select_dbid == _data["dbId"] and tonumber(_data["count"]) == 0 then
                                self._last_select_dbid = nil
                            end
                        end
                    end
                    local buy = nil
                    if self._curWaterCount -  self._maxFreeCount > 0 then
                        buy = gameUser.getVip() - (self._curWaterCount - self._maxFreeCount)
                        self._buyWaterCount = buy
                    else
                        buy = gameUser.getVip()
                    end
                    local freeCount = self._maxFreeCount - self._curWaterCount
                    if freeCount <= 0 then
                        freeCount = 0
                    end
                    self._buyCount:setString("每日可购买浇水次数："..tostring(buy))
                    self._freeCoutnLable:setString("每日免费浇水次数："..tostring(freeCount))
                    self:WateringAction()
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
                else
                    XTHDTOAST(data.msg)
                end 
            end,
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            end,--失败回调
            loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            loadingParent = node,
        })
    end
    if self._freeCount >0 then
        onWatering()
    elseif self._freeCount <= 0 and self._buyWaterCount > 0 then
        local _confirmLayer = XTHDConfirmDialog:createWithParams( {
            rightCallback = onWatering,
            msg = ("今日免费浇水次数用完，是否花费50元宝浇水")
        } );
        self:addChild(_confirmLayer, 1)
    else
        local _confirmLayer = XTHDConfirmDialog:createWithParams( {
            rightText = "充 值",
            rightCallback = function ( ... )
                --LayerManager.addShieldLayout()
                XTHD.createRechargeVipLayer( self)
            end,
            msg = ("您今日的浇水次数不足，请提升您的VIP等级，是否前往充值？")
        } );
        self:addChild(_confirmLayer, 1)
    end
end
--997144959    997144909
function ShengMingZhiShu:Wateringback( index )
    print("浇一次水涨多少经验",index,self._maxExp)
    self._watering_btn:setEnable(false)
    if self._curExp < self._maxExp then
        self:setRichLabel(self._curExp,self._maxExp)
    else
        self._curExp = self._maxExp
        self:setRichLabel(self._curExp,self._maxExp)
        self._curExp = 0
    end
    local percentage = index / self._maxExp * 100
    local Seq = cc.Sequence:create(cc.ProgressTo:create(0.5,self._exp_progress_timer:getPercentage() + percentage),cc.CallFunc:create(function( ... )
        self._watering_btn:setEnable(true)
        if self._curExp == 0 then
           self._exp_progress_timer:setPercentage(0)
        end
        self:setRichLabel(self._curExp,self._maxExp)
    end))
    self._exp_progress_timer:runAction(Seq)
end

function ShengMingZhiShu:setRichLabel( str1,str2 )
    local consumeStr = "<color=#FFFFFF fontSize=20 font=Helvetica>".. "当前经验值： " .."</color>"
                        .."/><color=#FFFFFF fontSize=20 font=Helvetica>"..tostring(str1) .."  </color>"
                        .."/><color=#FFFFFF fontSize=20 font=Helvetica>".."升级还需".."</color>"
                        .."/><color=#FFFFFF fontSize=20 font=Helvetica>".. tostring(str2 - str1 ) .."</color>"
                        .."/><color=#FFFFFF fontSize=20 font=Helvetica>".. "经验值" .."</color>"
    self._tree_exp:setString(consumeStr)
end

--刷新倒计时时间
function ShengMingZhiShu:updateHarvestTime( ... )
	schedule(self, function(dt)
		self._nextTime = self._nextTime - 1
        if self._nextTime <= 0  or self._state == 1 then
            self._nextTime = 0
            --self._btn_tree:setEnable(true)
            self._nextTimeLeble:setString("点击生命树收获果实")
            self._guoshibg:setVisible(true)
            self._guoshi:setVisible(true)
        else
            self._guoshibg:setVisible(false)
            self._guoshi:setVisible(false)
            local h, m, s = self:AuToTime( self._nextTime )
            self._nextTimeLeble:setString("下次收获还需："..h..":"..m..":"..s)  
        end
  	end,1,10)
end

--浇水动画
function ShengMingZhiShu:WateringAction(  )
    self.addExpLable:setVisible(true)
    self.addExpLable:setString("获得经验值".. tostring(self._addExp))
    self.addExpLable:runAction(cc.Sequence:create(
        cc.Spawn:create(cc.ScaleTo:create(0.2, 0.8),cc.FadeIn:create(0.5)), 
        cc.MoveBy:create(0.8,cc.p(0,50)), 
        cc.FadeOut:create(0.5), 
        cc.CallFunc:create(function() 
        self.addExpLable:setVisible(false)
        self.addExpLable:setPosition(cc.p(self._tree_exp:getPositionX(),self._tree_exp:getPositionY()-40))
    end)))
end

function ShengMingZhiShu:AuToTime( time )
	local hour, min, second
	hour = math.floor(time / (3600))
	min = math.floor((time - hour * 3600)/60)
	second = time - (hour * 3600 + min *60)
    if hour < 10 then
        hour = tostring("0"..hour)
    else
        hour = tostring(hour)
    end

    if min < 10 then
        min = tostring("0"..min)
    else
        min = tostring(min)
    end 

    if second < 10 then
        second = tostring("0"..second)
    else
        second = tostring(second)
    end 
	return hour,min,second
end


return ShengMingZhiShu