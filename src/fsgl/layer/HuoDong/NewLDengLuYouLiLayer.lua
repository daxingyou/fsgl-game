--[[
    新登录有礼活动
]]
local NewLDengLuYouLiLayer = class("NewLDengLuYouLiLayer", function()
    return XTHD.createPopLayer()
end)

function NewLDengLuYouLiLayer:ctor( data )
    self._size = self:getContentSize()
    -- data
    self.showRewardData = {}
    self.localData =  gameData.getDataFromCSV("LoginRewardByCreate")
    self._activityData = self:sortData( data.list )
    -- print("封装好的数据为：")
    -- print_r(self._activityData)
    -- 创建界面
    self:initUI( data )
end

function NewLDengLuYouLiLayer:onCleanup()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "newlgdl"}})
    helper.collectMemory()
end

-- 初始化界面
function NewLDengLuYouLiLayer:initUI( data )
    -- 背景
    local contentBg = XTHD.createSprite( "res/image/activities/newloginreward/bg.png" )
    contentBg:setPosition( self:getContentSize().width/2, self:getContentSize().height/2)
    self:addContent( contentBg )
    self._contentBg = contentBg

    local title = XTHD.createSprite("res/image/activities/newloginreward/title.png")
    title:setPosition(self._contentBg:getContentSize().width/2,self._contentBg:getContentSize().height-29)
    self._contentBg:addChild(title)

    local role = cc.Sprite:create("res/image/activities/newloginreward/hero.png")
    self._contentBg:addChild(role)
    role:setPosition(180,self._contentBg:getContentSize().height/2 + 30)

    local text1 = cc.Sprite:create("res/image/activities/newloginreward/text1.png")
    self._contentBg:addChild(text1,10)
    text1:setPosition(180,self._contentBg:getContentSize().height/2 - 150)

    local text2 = cc.Sprite:create("res/image/activities/newloginreward/text2.png")
    self._contentBg:addChild(text2,11)
    text2:setPosition(190,text1:getPositionY() - 50)

    local stone = cc.Sprite:create("res/image/activities/stone.png")
    self._contentBg:addChild(stone,12)
    stone:setPosition(self._contentBg:getContentSize().width - 80,40)

    self:initActivity( data )
end
-- 活动
function NewLDengLuYouLiLayer:initActivity( data )
    local activitySize = cc.size( 600, 500 )
    -- 活动背景707*465
    local activityBg = cc.Sprite:create()
    activityBg:setContentSize( activitySize )
    activityBg:setAnchorPoint(cc.p(0,0))
    activityBg:setPosition( 260, 40)
    self._contentBg:addChild( activityBg )
    self._activityBg = activityBg

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
    local cellHeight = 100
	
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
        end
        cell:removeAllChildren()
        self:buildCell( cell, index, cellWidth, cellHeight )
        return cell
    end
    actTableView:registerScriptHandler( self._actTableView.getCellNumbers, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    actTableView:registerScriptHandler( self._actTableView.getCellSize, cc.TABLECELL_SIZE_FOR_INDEX )
    actTableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    actTableView:reloadData()
end

function NewLDengLuYouLiLayer:buildCell( cell, index, cellWidth, cellHeight )
    -- cell背景
    local cellBg = ccui.Scale9Sprite:create("res/image/activities/newloginreward/cellbg.png" )
    cellBg:setContentSize( cellWidth - 6, cellHeight - 8 )
    cellBg:setPosition( cellWidth/2, cellHeight/2 )
    cell:addChild( cellBg )
    -- 标题
    local titleBg = cc.Sprite:create("res/image/activities/newloginreward/daybg.png")
    cellBg:addChild(titleBg)
    titleBg:setPosition(45,cellBg:getContentSize().height/2)
    local title = XTHD.createLabel({
        text = "第"..self._activityData[index + 1].configId.."天",
        anchor = cc.p( 0, 0.5 ),
        pos = cc.p( 20, cellBg:getContentSize().height/2 ),
        color = cc.c3b( 50, 10, 10 ),
        fontSize = 20,
    })
    cellBg:addChild( title )
    cell._title = title
    -- 进度
    -- local progress = XTHD.createLabel({
    --     fontSize = 18,
    --     color    = cc.c3b( 48, 40, 101 ),
    --     anchor   = cc.p( 0.5, 0.5 ),
    --     pos      = cc.p( cellBg:getContentSize().width - 75, title:getPositionY() - 3 ),
    -- })
    -- cellBg:addChild( progress )
    -- cell._progress = progress
    -- 分界线
    -- local split1 = XTHD.createSprite( "res/image/activities/daily/split1.png" )
    -- split1:setPosition( cellBg:getContentSize().width*0.5, cellBg:getContentSize().height - 34 )
    -- cellBg:addChild( split1 )
    -- 奖励图片
    -- local taskReward = XTHD.createSprite( "res/image/plugin/tasklayer/taskrewardtext.png" )
    -- taskReward:setPosition( 30, 46 )
    -- taskReward:setScale(0.9)
    -- cellBg:addChild( taskReward )
    -- 奖励容器
    local iconContainer = XTHD.createSprite()
    iconContainer:setContentSize( 400, 85 )
    iconContainer:setAnchorPoint( 0, 0 )
    iconContainer:setPosition( 80, 3 )
    cellBg:addChild( iconContainer )
    cell._iconContainer = iconContainer
    local iconNum = #self._activityData[index + 1].staticData
    local posX = 65--cell._iconContainer:getContentSize().width/(iconNum + 0.5)
    local posY = cell._iconContainer:getContentSize().height/2
    self.showRewardData = {}
    for i = 1,4 do
        self.showRewardData[#self.showRewardData + 1] = {
            rewardtype = self._activityData[index + 1].staticData["reword"..i.."type"],
            id = self._activityData[index + 1].staticData["reword"..i.."id"],
            num = self._activityData[index + 1].staticData["reword"..i.."num"],
            isLightAct = true,
        }
        local rewardIcon = ItemNode:createWithParams({
            _type_ = self._activityData[index + 1].staticData["reword"..i.."type"],
            itemId = self._activityData[index + 1].staticData["reword"..i.."id"],
            count = self._activityData[index + 1].staticData["reword"..i.."num"],
            isLightAct = true,
        })
        rewardIcon:setPosition( posX*( i - 0.5 ), posY )
        rewardIcon:setScale( 0.6 )
        cell._iconContainer:addChild( rewardIcon )
    end
    -- 领取按钮
    local fetchBtn = XTHD.createButton({
        normalFile = "res/image/activities/newloginreward/getBtn_normal.png",
        selectedFile = "res/image/activities/newloginreward/getBtn_selected.png",
        btnSize = cc.size(100,49),
        fontSize = 26,
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( cellBg:getContentSize().width - 80, cellBg:getPositionY() - 2 ),
		isScrollView = true,
    })
    cellBg:addChild( fetchBtn )
    local fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
    fetchBtn:addChild( fetchSpine )
    fetchSpine:setScaleX(0.7)
    fetchSpine:setScaleY(0.8)
    fetchSpine:setPosition( fetchBtn:getContentSize().width*0.5, fetchBtn:getContentSize().height/2+2 )
    fetchSpine:setAnimation( 0, "querenjinjie", true )
    cell._fetchBtn = fetchBtn
    fetchBtn:setScale(0.9)
    fetchBtn:setTouchEndedCallback(function ()
        self:receiveBtnClick(index)
    end)
    -- 未完成按钮
    local notFinishBtn = XTHD.createButton({
        normalFile = "res/image/activities/newloginreward/unfinish_normal.png",
        selectedFile = "res/image/activities/newloginreward/unfinish_selected.png",
        btnSize = cc.size(100,49),
        fontSize = 26,
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( fetchBtn:getPosition() ),
		isScrollView = true,
    })
    notFinishBtn:setScale(0.9)
    cellBg:addChild( notFinishBtn )
    cell._notFinishBtn = notFinishBtn

    -- 已领取
    local fetchedImageView = XTHD.createSprite( "res/image/vip/yilingqu.png" )
    fetchedImageView:setPosition( fetchBtn:getPosition() )
    cellBg:addChild( fetchedImageView )
    fetchedImageView:setScale(0.6)
    cell._fetchedImageView = fetchedImageView
    if self._activityData[index + 1].state == 1 then
        cell._fetchBtn:setVisible( true )
        cell._notFinishBtn:setVisible( false )
        cell._fetchedImageView:setVisible( false )
    elseif self._activityData[index + 1].state == 2 then
        cell._fetchBtn:setVisible( false )
        cell._notFinishBtn:setVisible( false )
        cell._fetchedImageView:setVisible( true )
    else
        cell._fetchBtn:setVisible( false )
        cell._notFinishBtn:setVisible( true )
        cell._fetchedImageView:setVisible( false )
    end
    -- 分界线
    -- local split2 = XTHD.createSprite( "res/image/activities/daily/split2.png" )
    -- split2:setPosition( cellWidth*0.5, 0 )
    -- cell:addChild( split2 )
end

function NewLDengLuYouLiLayer:receiveBtnClick(index)
    HttpRequestWithParams("receiveCreateLoginReward",{day = self._activityData[index + 1].configId},function (data)
--        print("领取奖励服务器返回的数据为：")
--        print_r(data)
         -- 更新属性
        if data.property and #data.property > 0 then
            for i=1, #data.property do
                local pro_data = string.split( data.property[i], ',' )
                DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
            end
        end
        -- 更新背包
        if data.bagItems and #data.bagItems ~= 0 then
            for i=1, #data.bagItems do
                local item_data = data.bagItems[i]
                if item_data.count and tonumber( item_data.count ) ~= 0 then
                    DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
                else
                    DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
                end
            end
        end
        self.showRewardData = {}
        for i = 1,4 do
            self.showRewardData[#self.showRewardData + 1] = {
                rewardtype = self._activityData[index + 1].staticData["reword"..i.."type"],
                id = self._activityData[index + 1].staticData["reword"..i.."id"],
                num = self._activityData[index + 1].staticData["reword"..i.."num"],
                isLightAct = true,
            }
        end
        ShowRewardNode:create( self.showRewardData )
        -- self._activityData[index + 1].state = 2
        self._activityData = self:sortData(data.list)
        --刷新主城信息
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
        self._actTableView:reloadData()
    end)
end

function NewLDengLuYouLiLayer:sortData( dataTable )
    -- 分离数据
    local notFetchTable = {}
    local fetchedTable = {}
    RedPointState[17].state = 0
    for i, v in ipairs( dataTable ) do
        if v.state == 1 then
            RedPointState[17].state = 1
        end
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
    for i = 1,#sortedTable do
        for j = 1,#self.localData do
            if sortedTable[i].configId == self.localData[j].id then
                sortedTable[i].staticData = self.localData[j]
                break
            end
        end
    end
    return sortedTable
end

function NewLDengLuYouLiLayer:timer( _time )
    -- 赋值
    self._surplusTime = _time or self._surplusTime or 0
    -- 减1
    self._surplusTime = self._surplusTime - 1
    -- 边界
    self._surplusTime = self._surplusTime > 0 and self._surplusTime or 0
    self._activityTime:setString("活动剩余时间："..LANGUAGE_KEY_CARNIVALDAY( self._surplusTime ) )
end

function NewLDengLuYouLiLayer:create(data)
    return NewLDengLuYouLiLayer.new(data)
end

return NewLDengLuYouLiLayer