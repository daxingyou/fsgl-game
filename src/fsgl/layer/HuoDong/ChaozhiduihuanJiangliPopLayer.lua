--Created By Liuluyang 2015年06月13日
local ChaozhiduihuanJiangliPopLayer = class("ChaozhiduihuanJiangliPopLayer",function ()
	return XTHD.createPopLayer()
end)

function ChaozhiduihuanJiangliPopLayer:ctor()
	self:initUI()
end

function ChaozhiduihuanJiangliPopLayer:initUI()	
	local staticData = gameData.getDataFromCSV( "CheapExchangeRanking")
	-- 背景
    local background = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
    background:setContentSize( 664, 484 )
    background:setPosition( self:getContentSize().width/2, self:getContentSize().height/2 )
    self:addContent( background )
    self._bgSize = cc.size( 664, 484)
	
	local lable = XTHDLabel:create("消耗兑换券冲榜活动，活动结束后，奖励将由邮件发放",20,"res/fonts/def.ttf")
	lable:setColor(cc.c3b(107,70,43))
	lable:setAnchorPoint(0,0.5)
	background:addChild(lable)
	lable:setPosition(30,background:getContentSize().height - lable:getContentSize().height - 5)

    -- 关闭按钮
    local closeBtn = XTHD.createBtnClose(function()
        self:hide()
    end)
    closeBtn:setPosition( self._bgSize.width - 10, self._bgSize.height - 10 )
    background:addChild( closeBtn )
    -- 标题
    local titleSp = XTHD.createSprite( "res/image/ranklist/rankListReward.png" )
    titleSp:setPosition( self._bgSize.width/2, self._bgSize.height + 10 )
    background:addChild( titleSp )

	local tableViewBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png" )
	tableViewBg:setContentSize( self._bgSize.width - 25, 405 )
	tableViewBg:setAnchorPoint( cc.p( 0.5, 0 ) )
	tableViewBg:setPosition( self._bgSize.width*0.5-1, 37 )
	background:addChild( tableViewBg )

	local normalnode = cc.Sprite:create("res/image/common/btn/btn_write_up.png")
	normalnode:setContentSize(cc.size(120,60))
	local selectednode = cc.Sprite:create("res/image/common/btn/btn_write_down.png")
	selectednode:setContentSize(cc.size(120,60))
	--查看排行榜按钮
	local btn_duihuan = XTHD.createCommonButton({
		text = "查看排行",
		fontColor = cc.c3b( 255, 255, 255 ),
		fontSize = 20,
		normalNode = normalnode,
		selectedNode = selectednode,
		endCallback = function ()
			self:popLayer()
		end
	})	
	tableViewBg:addChild(btn_duihuan,5)
	btn_duihuan:setPosition(tableViewBg:getContentSize().width - btn_duihuan:getContentSize().width *0.5 - 10,btn_duihuan:getContentSize().height *0.5)

  
	local tableView = cc.TableView:create( cc.size( tableViewBg:getContentSize().width - 15, tableViewBg:getContentSize().height ) )
	tableView:setPosition( 9, 0 )
	tableView:setBounceable( true )
	tableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	tableView:setDelegate()
	tableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	tableViewBg:addChild( tableView )
	local cellSize = cc.size( tableViewBg:getContentSize().width - 8, 95 )
	local function numberOfCellsInTableView( table )
		return #staticData
	end
	local function cellSizeForTable( table, index )
		return cellSize.width,cellSize.height
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
        end
        -- 数据
        index = index + 1
        local data = staticData[index]
        -- cell背景
        local cellBg = ccui.Scale9Sprite:create( "res/image/common/scale9_bg_32.png" )
        cellBg:setContentSize( cellSize.width - 16, cellSize.height - 5 )
        cellBg:setAnchorPoint( cc.p( 0, 0 ) )
        cellBg:setPosition( 3, 5 )
        cell:addChild( cellBg )

		local rankIcon = XTHD.createSprite( "res/image/ranklistreward/"..( index > 4 and 4 or index )..".png" )
        rankIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
        rankIcon:setPosition( 48, cellSize.height*0.5 + 3 )
        cell:addChild( rankIcon )

		local lable = XTHDLabel:create("第"..tostring(index) .. "名奖励",24,"res/fonts/def.ttf")
		lable:setColor(cc.c3b(107,70,43))
		lable:setPosition(rankIcon:getContentSize().width + rankIcon:getPositionX() + lable:getContentSize().width *0.5 - 20,cellBg:getContentSize().height*0.5)
		cellBg:addChild(lable)

		local _index = 0
		local data = staticData[index]
		local reward = string.split(data.reward,",")
		for i = 1, #reward do
			if reward[i] ~= nil then
				_index = _index + 1 
				local _data = string.split(reward[i],"#")
				local item = ItemNode:createWithParams({
					itemId = tonumber(_data[2]),
					_type_ = tonumber(_data[1]),
					count = tonumber(_data[3])
				})
				cellBg:addChild(item)
				item:setScale(0.6)
				item:setPosition(cellBg:getContentSize().width*0.5 + item:getContentSize().width *0.5 + (_index -1)*item:getContentSize().width,cellBg:getContentSize().height *0.5)
			end
		end

    	return cell
	end
	tableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    tableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    tableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    tableView:reloadData()
	
end

function ChaozhiduihuanJiangliPopLayer:popLayer(args)
	ClientHttp:requestAsyncInGameWithParams({
        modules = "exchargeCostRank?",
        successCallback = function( data )
			if data.result == 0 then
				local biyedianliLayer = requires("src/fsgl/layer/HuoDong/ChaozhiduihuanRankPopLayer.lua")
				local layer = biyedianliLayer:create(data)
				cc.Director:getInstance():getRunningScene():addChild(layer)
				layer:show()		
			end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

function ChaozhiduihuanJiangliPopLayer:create()
	return ChaozhiduihuanJiangliPopLayer.new()
end

return ChaozhiduihuanJiangliPopLayer