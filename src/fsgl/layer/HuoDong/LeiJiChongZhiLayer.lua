--[[
	累计充值界面
    20190611
]]
local LeiJiChongZhiLayer = class("LeiJiChongZhiLayer", function(params)
	local layer = XTHD.createSprite()
	layer:setContentSize( 640, 428 )
	return layer
end)

function LeiJiChongZhiLayer:ctor(params)
	self._exist = true
	-- dump( params, "LeiJiChongZhiLayer ctor" )
	-- ui
	self._size = self:getContentSize()
    self.parentLayer = params.parentLayer
    self.httpData = params.httpData
	-- 状态
	self:initData( params.httpData )
	-- 添加监听事件
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG ,callback = function()
		if self._exist then
        	self:refreshData()
        end
    end})

	self:initUI()
end
-- 
function LeiJiChongZhiLayer:onCleanup()
	self._exist = false
end

--刷新小红点
function LeiJiChongZhiLayer:freshRedDot(data)

end

-- 处理数据
function LeiJiChongZhiLayer:initData(  )

end
-- 创建界面
function LeiJiChongZhiLayer:initUI()
	-- 标题背景
	local titleBg = XTHD.createSprite( "res/image/activities/newyear/redpacket/title.png" )
	titleBg:setPosition( self._size.width*0.5+22, self._size.height - titleBg:getContentSize().height*0.5 +4)
	titleBg:setPosition( self._size.width*0.5+22, self._size.height - titleBg:getContentSize().height*0.5 + 4)
	titleBg:setScaleY(1.2)
	titleBg:setScaleX(1.07)
	self:addChild( titleBg )
--	-- 活动时间
--	local titleTime = XTHD.createLabel({
--		text     = LANGUAGE_PRAYER_DAYS(self._openTime.beginMonth,self._openTime.beginDay,self._openTime.endMonth,self._openTime.endDay),
--		fontSize = 18,
--		color    = cc.c3b( 255, 252, 0 ),
--		anchor   = cc.p( 0, 0 ),
--		pos      = cc.p( 15, 7 ),
--	})
--	titleBg:addChild( titleTime )
--	self._titleTime = titleTime

	-- tableview
	local tableView = CCTableView:create( cc.size( self._size.width, self._size.height - titleBg:getContentSize().height - 32 ) )
	tableView:setPosition( 25, 3 )
	tableView:setBounceable( true )
	tableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	tableView:setDelegate()
	tableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	self:addChild( tableView )
	self._tableView = tableView

	local cellWidth = self._size.width 
	local cellHeight = 120

	local function numberOfCellsInTableView( table )
		return 10
	end
	local function cellSizeForTable( table, index )
		return  cellWidth,cellHeight - 10
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
            self:buildCell( cell, index, cellWidth, cellHeight )
        end
        self:updateCell( cell, index )

    	return cell
    end
	tableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    tableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    tableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    tableView:reloadData()
end

function LeiJiChongZhiLayer:buildCell( cell, index, cellWidth, cellHeight )

    local bg2 = ccui.Scale9Sprite:create("res/image/activities/newyear/redpacket/cellbg_2.png" )
	bg2:setContentSize(cellWidth - 25,cellHeight - 20)
    bg2:setPosition( cellWidth*0.5-2, cellHeight*0.5 )
	cell:addChild( bg2 )

	local cellBg = XTHD.createSprite( "res/image/activities/newyear/redpacket/cellbg.png" )
	cellBg:setPosition( 0, 3 )
	cellBg:setOpacity(0)
    cellBg:setPosition( cellWidth*0.5, cellHeight*0.5 )
	cell:addChild( cellBg )
	-- 标题
	local title = XTHD.createLabel({
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( 35, cellBg:getContentSize().height - 45 ),
	})
	title:setColor(XTHD.resource.textColor.green_text)
	title:setFontSize(16)
	cell:addChild( title )
	cell._title = title
	-- 进度
	local progress = XTHD.createLabel({
		fontSize = 20,
		color    = cc.c3b( 103, 147, 18 ),
		anchor   = cc.p( 0.5, 0.5 ),
		pos      = cc.p( cellBg:getContentSize().width - 40, title:getPositionY()-20 ),
	})
	cell:addChild( progress )
	cell._progress = progress

	-- 奖励容器
	local iconContainer = XTHD.createSprite()
	iconContainer:setContentSize( 450, 90 )
	iconContainer:setAnchorPoint( 0, 0 )
	iconContainer:setPosition( 10, 13 )
	cell:addChild( iconContainer )
	cell._iconContainer = iconContainer
	
	for i = 1,3 do
		local item = ItemNode:createWithParams({
			_type_ = 3,
			 touchShowTip = false,
			 count = 1
		})
		iconContainer:addChild(item)
		item:setScale(0.7)
		item:setPosition((i-1)*item:getContentSize().width*0.8 + 50,iconContainer:getContentSize().height / 2)
	end

	-- 兌換按钮
	local btn_duihuan = XTHD.createButton({
			normalFile = "res/image/activities/newyear/duihuan_1.png",
            selectedFile = "res/image/activities/newyear/duihuan_2.png",
		})
	cell:addChild(btn_duihuan)
	btn_duihuan:setPosition(cellBg:getContentSize().width - btn_duihuan:getContentSize().width / 2,cellBg:getContentSize().height - btn_duihuan:getContentSize().height - 40)
end

function LeiJiChongZhiLayer:updateCell( cell, index )
    
end
-- 领取奖励
function LeiJiChongZhiLayer:fetchReward( yuanbao, iconData, index )
	
end
-- 对数据进行排序
function LeiJiChongZhiLayer:sortData( dataTable )
	
end

function LeiJiChongZhiLayer:create(params)
    return self.new(params)
end

return LeiJiChongZhiLayer
