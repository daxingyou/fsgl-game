--[[
    日常活动
    2019.06.03
]]
local RiChangHuoDongLayer = class("RiChangHuoDongLayer", function()
    return XTHD.createPopLayer()
end)

function RiChangHuoDongLayer:ctor( data )
    self.redDotTable = {}
    self._exist = true
    -- 默认选中
    self._tabIndex = 1
    -- ui
    self._size = self:getContentSize()
    -- data
    self._activityData = self:sortData( data.list )
    -- 创建界面
    self:initUI( data )
    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG ,callback = function()
        if self._exist then
            self:refreshData()
        end
    end})
end

function RiChangHuoDongLayer:onCleanup()
    self._exist = false
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_GONGXIFACAI)
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/activities/daily/background.png")
    for i=1, 8 do
        textureCache:removeTextureForKey("res/image/activities/daily/activitiesTab_" .. i .. ".png")
    end
    helper.collectMemory()
end
-- 构造数据
function RiChangHuoDongLayer:buildData()
    -- 活动信息
    local activityStatic = {
        -- 登录有礼
        [1] = {
            urlId      = 18,
            priority   = 10,
            isOpen     = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid   = 18,                     -- 活动开启id，后端控制
            pictureid  = 1,
        },
        -- 充值返利
        [2] = {
            urlId      = 12,
            priority   = 20,
            isOpen     = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid   = 12,                     -- 活动开启id，后端控制
            pictureid  = 2,
        },
        -- 消费返利
        [3] = {
            urlId      = 13,
            priority   = 30,
            isOpen     = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid   = 13,                     -- 活动开启id，后端控制
            pictureid  = 3,
        },
        -- 开采返利
        [4] = {
            urlId      = 14,
            priority   = 40,
            isOpen     = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid   = 14,                     -- 活动开启id，后端控制
            pictureid  = 4,
            functionId = 48,
        },
        -- 招募返利
        [5] = {
            urlId      = 15,
            priority   = 50,
            isOpen     = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid   = 15,                     -- 活动开启id，后端控制
            pictureid  = 5,
            functionId = 18,
        },
        -- 神兵返利
        [6] = {
            urlId      = 16,
            priority   = 60,
            isOpen     = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid   = 16,                     -- 活动开启id，后端控制
            pictureid  = 6,
            functionId = 19,
        },
        -- 神器返利
        [7] = {
            urlId      = 17,
            priority   = 70,
            isOpen     = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid   = 17,                     -- 活动开启id，后端控制
            pictureid  = 7,
        },
    }
    -- 筛选开启的活动
    self._activityOpen = {}
    local _openState = gameUser.getActivityOpenStatus() or {}
    -- print("*****CTX_log:获取的活动表为：*****")
    -- print_r(_openState)
    for i, v in ipairs( activityStatic ) do
        if tonumber( v.isOpen ) == 1  then
            -- 长期开启
            self._activityOpen[#self._activityOpen + 1] = v
        else
            -- 后端控制
            local activityState = _openState[tostring( v.isOpenid or 0 )] or 0
            if tonumber( activityState ) == 1 then
                self._activityOpen[#self._activityOpen + 1] = v
            end
        end
    end
    -- 按活动优先级排序
    table.sort(self._activityOpen,function(data1,data2)
            return tonumber(data1.priority) < tonumber(data2.priority)
        end)
    self._tabNumber = table.nums(self._activityOpen)

    return self._activityOpen[1].urlId
end
-- 初始化界面
function RiChangHuoDongLayer:initUI( data )
    -- 背景
    local contentBg = XTHD.createSprite( "res/image/activities/daily/background.png" )
    contentBg:setPosition( self:getContentSize().width/2, self:getContentSize().height/2)
    self:addContent( contentBg )
    self._contentBg = contentBg
    self._contentBg:setScale(0.9)
    --日常活动文字 
    -- local title = XTHD.createSprite("res/image/activities/daily/richanghuodong.png")
    -- title:setPosition(self._contentBg:getContentSize().width/2,self._contentBg:getContentSize().height-17)
    -- self._contentBg:addChild(title)
    -- 活动列表
    local tabTableView = cc.TableView:create( cc.size( 150, 460 ) )
    tabTableView:setBounceable(true)
    tabTableView:setPosition(65,45)
    tabTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) 
    tabTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tabTableView:setDelegate()
    self._contentBg:addChild(tabTableView)
    self._tabTableView = tabTableView

    local cellSize = cc.size(150, 65)
    local function numberOfCellsInTableView(table)
        return self._tabNumber
    end
    local function cellSizeForTable(table, idx)
        return cellSize.width,cellSize.height
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
			cell:setContentSize(cellSize.width,cellSize.height)
        end
        local index = idx + 1
        local _activityData = self._activityOpen[index] or {}
        -- local btn_normal = getCompositeNodeWithImg( "res/image/activities/newyear/actTab_normal.png", "res/image/activities/daily/tab_" .. (_activityData.pictureid or 1) .. "_normal.png" )
        -- local btn_selected = getCompositeNodeWithImg( "res/image/activities/newyear/actTab_selected.png", "res/image/activities/daily/tab_" .. (_activityData.pictureid or 1) .. "_selected.png" )
        local _cellBtn = XTHD.createButton({
            normalFile           = "res/image/activities/daily/tab_" .. (_activityData.pictureid or 1) .. "_normal.png",
            selectedFile         = "res/image/activities/daily/tab_" .. (_activityData.pictureid or 1) .. "_selected.png",
            needSwallow          = false,
            anchor               = cc.p(0.5,0.5),
            pos                  = cc.p(cellSize.width*0.5+2,cellSize.height*0.5 + 1),
            needEnableWhenMoving = true,
			isScrollView = true,
        })
        if self._tabIndex == index then
            self._tabSelected = cell
            _cellBtn:setSelected( true )
        else
            _cellBtn:setSelected( false )
        end
        self:addTabRedPoint(_cellBtn,idx)
         ClientHttp:requestAsyncInGameWithParams({
                modules="totalActivateList?",
                params = {activateId = _activityData.urlId},
                successCallback = function( backData )
                    if tonumber( backData.result ) == 0 then
                        local isHave = false
                        for i = 1,#backData.list do
                            if backData.list[i].state == 1 then
                                isHave = true    
                                break
                            end
                        end
                        if isHave then
                             self.redDotTable[index]:setVisible(true)
                        else
                             self.redDotTable[index]:setVisible(false)
                        end
                        RedPointState[8].state = 0
                        for j = 1,#self.redDotTable do
                            if self.redDotTable[j]:isVisible() == true then
                                RedPointState[8].state = 1
                            end
                        end
                        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "rchd"}})
                    else
                        XTHDTOAST(backData.msg)
                    end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                loadingParent = self,
            })

        _cellBtn:setTouchEndedCallback(function()
            _cellBtn:setSelected(true)
            ClientHttp:requestAsyncInGameWithParams({
                modules="totalActivateList?",
                params = {activateId = _activityData.urlId},
                successCallback = function( backData )
                    -- print("*****CTX_log:向服务器请求的日常活动表为：*****")
                    -- print_r(backData)
                    if tonumber( backData.result ) == 0 then
                        if self._exist then
                            if self._tabSelected and self._tabSelected._cellBtn then
                                self._tabSelected._cellBtn:setSelected( false )
                            end
                            _cellBtn:setSelected(true)
                            self._tabSelected = cell
                            self._tabIndex = index
                            self._activityData = self:sortData( backData.list )
                            self._activityDate:setString( LANGUAGE_PRAYER_DAYS( backData.beginMonth, backData.beginDay, backData.endMonth, backData.endDay ) )
                            self:timer( backData.surplusTime )
                            self:switchTab()
                        end
                    else
                        _cellBtn:setSelected(false)
                        XTHDTOAST(backData.msg)
                    end
                end,--成功回调
                failedCallback = function()
                    _cellBtn:setSelected(false)
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                loadingParent = self,
            })
        end)

        cell:addChild(_cellBtn)
		cell:setScale(0.9)
        cell._cellBtn = _cellBtn
        
        return cell
    end
    tabTableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tabTableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tabTableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tabTableView:reloadData()

    self:initActivity( data )
end
-- 活动
function RiChangHuoDongLayer:initActivity( data )
    local activitySize = cc.size( 707, 465 )
    -- 活动背景707*465
    local activityBg = cc.Sprite:create()
    activityBg:setContentSize( activitySize )
    activityBg:setAnchorPoint(cc.p(0,0))
    activityBg:setPosition( 190, 30)
    self._contentBg:addChild( activityBg )
    self._activityBg = activityBg
    -- 顶部背景
    local topBg = XTHD.createSprite( "res/image/activities/daily/top_"..self._activityOpen[self._tabIndex].pictureid..".png" )
    -- topBg:setContentSize( 696, 102 )
    topBg:setPosition( activitySize.width/2+30, activitySize.height - 40 )
    activityBg:addChild( topBg )
    self._topBg = topBg
    -- 活动日期
    local activityDate = XTHD.createLabel({
        text = LANGUAGE_PRAYER_DAYS( data.beginMonth, data.beginDay, data.endMonth, data.endDay ),
        fontSize  = 18,
        anchor    = cc.p( 0, 0.5 ),
        pos       = cc.p( 16, 8 ),
		color	  = cc.c3b(255,255,159),
        clickable = false,
    })
    topBg:addChild( activityDate )
    self._activityDate = activityDate
    -- 活动时间
    local activityTime = XTHD.createLabel({
        fontSize  = 18,
        anchor    = cc.p( 1, 0.5 ),
        pos       = cc.p( topBg:getContentSize().width - 16, 8 ),
		color	  = cc.c3b(255,255,159),
        clickable = false,
    })
    topBg:addChild( activityTime )
    self._activityTime = activityTime
    schedule( self, function()
        self:timer()
    end, 1.0, 233 )
    self:timer( data.surplusTime )

    --飘带
    local leftpd = cc.Sprite:create("res/image/activities/daily/left.png")
    self._contentBg:addChild(leftpd)
    leftpd:setPosition(50,self._contentBg:getContentSize().height - 272)
    local rightpd = cc.Sprite:create("res/image/activities/daily/right.png")
    self._contentBg:addChild(rightpd)
    rightpd:setPosition(self._contentBg:getContentSize().width - 50,self._contentBg:getContentSize().height - 272)

    local btn_close = XTHDPushButton:createWithFile({
        normalFile = "res/image/activities/TimelimitActivity/btn_close_up.png",
        selectedFile = "res/image/activities/TimelimitActivity/btn_close_down.png",
		musicFile = XTHD.resource.music.effect_btn_commonclose,
        endCallback  = function()
           self:hide()
        end,
    })
    self._contentBg:addChild(btn_close)
    btn_close:setPosition(self._contentBg:getContentSize().width - btn_close:getContentSize().width * 0.5 + 18,self._contentBg:getContentSize().height - btn_close:getContentSize().height * 0.5 - 10)
    
    -- tableview背景
    local tableViewBg = ccui.Scale9Sprite:create()
    tableViewBg:setContentSize( activitySize.width - 8, activitySize.height - 100 )
    tableViewBg:setAnchorPoint( cc.p( 0.5, 0 ) )
    tableViewBg:setPosition( activitySize.width*0.5+30, 10 )
    activityBg:addChild( tableViewBg )
    -- 活动tableView
    local actTableView = cc.TableView:create( cc.size( tableViewBg:getContentSize().width - 6, tableViewBg:getContentSize().height - 6 ) )
    actTableView:setPosition( 3, 3 )
    actTableView:setBounceable( true )
    actTableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
    actTableView:setDelegate()
    actTableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
    tableViewBg:addChild( actTableView )
    self._actTableView = actTableView
	TableViewPlug.init( self._actTableView)

    local cellWidth = tableViewBg:getContentSize().width - 6
    local cellHeight = 127
	
	self._actTableView.getCellNumbers = function( table )
        return #self._activityData
    end
	
	self._actTableView.getCellSize = function( table, index )
        return cellWidth,cellHeight
    end
     
    local function tableCellAtIndex( table, index )
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
			cell:setContentSize(cellWidth,cellHeight)
            self:buildCell( cell, index, cellWidth, cellHeight )
        end
        self:updateCell( cell, index )

        return cell
    end
    actTableView:registerScriptHandler( self._actTableView.getCellNumbers, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    actTableView:registerScriptHandler( self._actTableView.getCellSize, cc.TABLECELL_SIZE_FOR_INDEX )
    actTableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    actTableView:reloadData()
end

function RiChangHuoDongLayer:buildCell( cell, index, cellWidth, cellHeight )
    -- cell背景
    local cellBg = ccui.Scale9Sprite:create("res/image/activities/daily/cellBg.png" )
    cellBg:setContentSize( cellWidth - 6, cellHeight - 8 )
    cellBg:setPosition( cellWidth/2, cellHeight/2 )
    cell:addChild( cellBg )
    -- 标题
    local title = XTHD.createLabel({
        anchor = cc.p( 0, 0.5 ),
        pos = cc.p( 12, cellBg:getContentSize().height - 17 ),
        color = cc.c3b( 168, 23, 43 ),
        fontSize = 20,
    })
    cellBg:addChild( title )
    cell._title = title
    -- 进度
    local progress = XTHD.createLabel({
        fontSize = 18,
        color    = cc.c3b( 48, 40, 101 ),
        anchor   = cc.p( 0.5, 0.5 ),
        pos      = cc.p( cellBg:getContentSize().width - 75, title:getPositionY() - 3 ),
    })
    cellBg:addChild( progress )
    cell._progress = progress
    -- 分界线
    -- local split1 = XTHD.createSprite( "res/image/activities/daily/split1.png" )
    -- split1:setPosition( cellBg:getContentSize().width*0.5, cellBg:getContentSize().height - 34 )
    -- cellBg:addChild( split1 )
    -- 奖励图片
    local taskReward = XTHD.createSprite( "res/image/plugin/tasklayer/taskrewardtext.png" )
    taskReward:setPosition( 30, 46 )
    taskReward:setScale(0.9)
    cellBg:addChild( taskReward )
    -- 奖励容器
    local iconContainer = XTHD.createSprite()
    iconContainer:setContentSize( 400, 85 )
    iconContainer:setAnchorPoint( 0, 0 )
    iconContainer:setPosition( 60, 0 )
    cellBg:addChild( iconContainer )
    cell._iconContainer = iconContainer
    -- 领取按钮
    local fetchBtn = XTHD.createButton({
        normalFile = "res/image/activities/hdbtn/btn_gray_up.png",
        selectedFile = "res/image/activities/hdbtn/btn_gray_down.png",
        btnSize = cc.size(100,49),
        text = LANGUAGE_BTN_KEY.getReward,
        fontSize = 26,
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( cellBg:getContentSize().width - 80, taskReward:getPositionY() ),
		isScrollView = true,
    })
    fetchBtn:setScale(0.7)
    cellBg:addChild( fetchBtn )
    local fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
    fetchBtn:addChild( fetchSpine )
    -- fetchSpine:setScaleX( fetchBtn:getContentSize().width/102 )
    -- fetchSpine:setScaleY( fetchBtn:getContentSize().height/46 )
    fetchSpine:setPosition( fetchBtn:getContentSize().width*0.5+7, fetchBtn:getContentSize().height/2+2 )
    fetchSpine:setAnimation( 0, "querenjinjie", true )
    cell._fetchBtn = fetchBtn
    -- 未完成按钮
    local notFinishBtn = XTHD.createButton({
        normalFile = "res/image/activities/hdbtn/btn_gray_up.png",
        selectedFile = "res/image/activities/hdbtn/btn_gray_down.png",
        btnSize = cc.size(100,49),
        text = LANGUAGE_KEY_NOTREACHABLE,
        fontSize = 26,
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( fetchBtn:getPosition() ),
		isScrollView = true,
    })
    notFinishBtn:setScale(0.7)
    cellBg:addChild( notFinishBtn )
    cell._notFinishBtn = notFinishBtn
    -- 前往按钮
    local gotoBtn = XTHD.createButton({
        normalFile = "res/image/activities/hdbtn/btn_gray_up.png",
        selectedFile = "res/image/activities/hdbtn/btn_gray_down.png",
        btnSize = cc.size(100,49),
        text = LANGUAGE_KEY_HERO_TEXT.chapterGoTextXc,
        fontSize = 26,
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( fetchBtn:getPosition() ),
		isScrollView = true,
    })
    gotoBtn:setScale(0.7)
    cellBg:addChild( gotoBtn )
    cell._gotoBtn = gotoBtn
    -- 已领取
    local fetchedImageView = XTHD.createSprite( "res/image/vip/yilingqu.png" )
    fetchedImageView:setPosition( fetchBtn:getPosition() )
    cellBg:addChild( fetchedImageView )
    fetchedImageView:setScale(0.7)
    cell._fetchedImageView = fetchedImageView
    -- 分界线
    -- local split2 = XTHD.createSprite( "res/image/activities/daily/split2.png" )
    -- split2:setPosition( cellWidth*0.5, 0 )
    -- cell:addChild( split2 )
end

function RiChangHuoDongLayer:updateCell( cell, index )
    index = index + 1
    -- 数据
    local cellData = self._activityData[index]
    -- dump( cellData, "cellData" )
    -- 标题
    cell._title:setString( LANGUAGE_ACTIVITYDAILY_TITLE( self._activityOpen[self._tabIndex].urlId, cellData.param ) )
    -- 进度
    if self._activityOpen[self._tabIndex].urlId == 17 then
        cell._progress:setString( cellData.curSum.."/"..string.split(cellData.param,"#")[1] )
    elseif self._activityOpen[self._tabIndex].urlId == 12 then
        cell._progress:setString( ( tonumber(cellData.curSum)/10 ).."/"..( tonumber(cellData.param)/10 ) )
    else
        cell._progress:setString( cellData.curSum.."/"..cellData.param )
    end
    -- 奖励
    cell._iconContainer:removeAllChildren()
    local iconNum = #cellData.rewardList
    local posX = 100--cell._iconContainer:getContentSize().width/(iconNum + 0.5)
    local posY = cell._iconContainer:getContentSize().height/2
    local showRewardData = {}
    for i, v in ipairs( cellData.rewardList ) do
        showRewardData[#showRewardData + 1] = {
            rewardtype = v.rewardType,
            id = v.rewardId,
            num = v.rewardSum,
            isLightAct = true,
        }
        local rewardIcon = ItemNode:createWithParams({
            _type_ = v.rewardType,
            itemId = v.rewardId,
            count = v.rewardSum,
            isLightAct = true,
        })
        rewardIcon:setPosition( posX*( i - 0.5 ), posY )
        rewardIcon:setScale( 0.7 )
        cell._iconContainer:addChild( rewardIcon )
    end
    -- 按钮
    if cellData.state == 1 then
        -- 可以领取
        cell._fetchBtn:setVisible( true )
        cell._fetchBtn:setTouchEndedCallback(function()
            ClientHttp:requestAsyncInGameWithParams({
                modules="totalActivateReward?",
                params = {configId = cellData.configId},
                successCallback = function( backData )
                    -- dump(backData,"领取返回")
                    if tonumber( backData.result ) == 0 then
                        if self._exist then
                            -- 更新属性
                            if backData.property and #backData.property > 0 then
                                for i=1, #backData.property do
                                    local pro_data = string.split( backData.property[i], ',' )
                                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
                                end
                                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
                            end
                            -- 更新背包
                            if backData.bagItems and #backData.bagItems ~= 0 then
                                for i=1, #backData.bagItems do
                                    local item_data = backData.bagItems[i]
                                    if item_data.count and tonumber( item_data.count ) ~= 0 then
                                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
                                    else
                                        DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
                                    end
                                end
                            end
                            ShowRewardNode:create( showRewardData )
                            self:refreshData()
                            --刷新主城信息
                            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
                            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
                        end
                    else
                        XTHDTOAST(backData.msg)
                    end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                loadingParent = self,
            })
        end)
        cell._notFinishBtn:setVisible( false )
        cell._gotoBtn:setVisible( false )
        cell._fetchedImageView:setVisible( false )
    elseif cellData.state == 2 then
        -- 已经领取
        cell._fetchBtn:setVisible( false )
        cell._notFinishBtn:setVisible( false )
        cell._gotoBtn:setVisible( false )
        cell._fetchedImageView:setVisible( true )
    else
        -- 不能领取
        cell._fetchBtn:setVisible( false )
        local urlId = self._activityOpen[self._tabIndex].urlId
        if urlId == 12 then
            cell._notFinishBtn:setVisible( false )
            cell._gotoBtn:setVisible( true )
            cell._gotoBtn:setTouchEndedCallback(function()
                XTHD.createRechargeVipLayer(self)
            end)
        elseif urlId == 14 then
            -- 切石
            cell._notFinishBtn:setVisible( false )
            cell._gotoBtn:setVisible( true )
            cell._gotoBtn:setTouchEndedCallback(function()
                XTHD.createStoneGambling(function()
                    self:refreshData()
                end)
            end)
        elseif urlId == 15 then
            -- 抽英雄
            cell._notFinishBtn:setVisible( false )
            cell._gotoBtn:setVisible( true )
            cell._gotoBtn:setTouchEndedCallback(function()
                XTHD.createExchangeLayer(self,nil,function()
                    self:refreshData()
                end)
            end)
        elseif urlId == 16 then
            -- 抽装备
            cell._notFinishBtn:setVisible( false )
            cell._gotoBtn:setVisible( true )
            cell._gotoBtn:setTouchEndedCallback(function()
                XTHD.createExchangeLayer(self,nil,function()
                    self:refreshData()
                end)
            end)
        elseif urlId == 17 then
            -- 神器
            cell._notFinishBtn:setVisible( false )
            cell._gotoBtn:setVisible( true )
            cell._gotoBtn:setTouchEndedCallback(function()
                self:enterArtifact()
            end)
        else
            cell._notFinishBtn:setVisible( true )
            cell._gotoBtn:setVisible( false )
        end
        cell._fetchedImageView:setVisible( false )
    end
end

function RiChangHuoDongLayer:enterArtifact(  )
     local isOpen,data = isTheFunctionAvailable(35)    
    if not isOpen then 
        XTHDTOAST(data.tip)
        return 
    end 
    local ownArtifact = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ARTIFACT)
    if ownArtifact and ownArtifact.godid then
        ownArtifact = {ownArtifact}
    end
    if #ownArtifact > 0 then 
        --主城界面选择神器
        local function getArtifact()
            local artifactData = gameData.getDataFromCSV("SuperWeaponUpInfo")
            table.sort(ownArtifact, function(a,b)
                if tonumber(artifactData[a.templateId].rank) == tonumber(artifactData[b.templateId].rank) then
                    return tonumber(artifactData[a.templateId]._type) < tonumber(artifactData[b.templateId]._type)
                else
                    return tonumber(artifactData[a.templateId].rank) > tonumber(artifactData[b.templateId].rank)
                end
            end)
            return ownArtifact[1].godid
        end
        local gid = getArtifact()
        XTHD.createArtifact(nil,nil, gid , function()
            self:refreshData()
        end)
    else 
        XTHDTOAST(LANGUAGE_TIPS_WORDS4)        
    end     
end

function RiChangHuoDongLayer:switchTab()
    local topId = self._activityOpen[self._tabIndex].pictureid
    self._topBg:setTexture( "res/image/activities/daily/top_"..topId..".png" )
    self._actTableView:reloadData()
end

function RiChangHuoDongLayer:refreshData()
    ClientHttp:requestAsyncInGameWithParams({
        modules="totalActivateList?",
        params = {activateId = self._activityOpen[self._tabIndex].urlId},
        successCallback = function( backData )
            if tonumber( backData.result ) == 0 then
                if self._exist then
                    self._activityData = self:sortData( backData.list )
                    self._activityDate:setString( LANGUAGE_PRAYER_DAYS( backData.beginMonth, backData.beginDay, backData.endMonth, backData.endDay ) )
                    self:timer( backData.surplusTime )
                    self._actTableView:reloadDataAndScrollToCurrentCell()
                end
                --刷新小红点
                local isHave = false
                for i = 1,#backData.list do
                    if backData.list[i].state == 1 then
                        isHave = true    
                        break
                    end
                end
                if isHave then
                     self.redDotTable[self._tabIndex]:setVisible(true)
                else
                     self.redDotTable[self._tabIndex]:setVisible(false)
                end
                RedPointState[8].state = 0
                for j = 1,#self.redDotTable do
                    if self.redDotTable[j]:isVisible() == true then
                        RedPointState[8].state = 1
                    end
                end
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "rchd"}})
            else
                XTHDTOAST(backData.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    })
end

function RiChangHuoDongLayer:sortData( dataTable )
    -- 分离数据
    local notFetchTable = {}
    local fetchedTable = {}
    for i, v in ipairs( dataTable ) do
        if v.state == 2 then
            fetchedTable[#fetchedTable + 1] = v
        else
            notFetchTable[#notFetchTable + 1] = v
        end
    end
    -- 排序
    table.sort( notFetchTable, function( a, b )
        return a.configId < b.configId
    end)
    table.sort( fetchedTable, function( a, b )
        return a.configId < b.configId
    end)
    -- 组合数据
    local sortedTable = {}
    for i, v in ipairs( notFetchTable ) do
        sortedTable[#sortedTable + 1] = v
    end
    for i, v in ipairs( fetchedTable ) do
        sortedTable[#sortedTable + 1] = v
    end
    return sortedTable
end

function RiChangHuoDongLayer:addTabRedPoint(_target,_idx)
    if _target==nil or _idx == nil then
        return 
    end
    if _target:getChildByName("redPoint") then
        _target:removeChildByName("redPoint")
    end
    local _redPointSp = cc.Sprite:create("res/image/common/heroList_redPoint.png")
    _redPointSp:setName("redPoint")
    _redPointSp:setAnchorPoint(cc.p(1,1))
    _redPointSp:setPosition(cc.p(_target:getContentSize().width,_target:getContentSize().height))
    _target:addChild(_redPointSp)
    self.redDotTable[_idx + 1] = _redPointSp
    self.redDotTable[_idx + 1]:setVisible(false)
end

function RiChangHuoDongLayer:timer( _time )
    -- 赋值
    self._surplusTime = _time or self._surplusTime or 0
    -- 减1
    self._surplusTime = self._surplusTime - 1
    -- 边界
    self._surplusTime = self._surplusTime > 0 and self._surplusTime or 0
    self._activityTime:setString("活动剩余时间："..LANGUAGE_KEY_CARNIVALDAY( self._surplusTime ) )
end

function RiChangHuoDongLayer:firstActivityId()
    return self:buildData()
end

function RiChangHuoDongLayer:create(data)
    return RiChangHuoDongLayer.new(data)
end

return RiChangHuoDongLayer