--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local VoucherDanbi = class("VoucherDanbi",function()
	local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	node:setContentSize(705,430)
	return node
end)

function VoucherDanbi:ctor()
	self:init()
end

function VoucherDanbi:init()
	local _bg = cc.Sprite:create("res/image/newGuild/memberbg.png")
	_bg:setContentSize(460,330)
	self:addChild(_bg)
	_bg:setPosition(self:getContentSize().width *0.65 + 10,self:getContentSize().height *0.6)
	self._bg = _bg	
	self._bg:setOpacity(0)

	self._talbeView = cc.TableView:create(self._bg:getContentSize())
	self._talbeView:setPosition(0,-2)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._bg:addChild(self._talbeView)

	local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,190
    end
    local function numberOfCellsInTableView(table)
        return 3
    end
	
    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(self._talbeView:getContentSize().width,190)
        else
            cell:removeAllChildren()
        end
		idx = idx + 1
		self:createTableViewCell( idx, cell )
        return cell
    end
	local function tableCellTouched(table,cell)
		print("***************************")
	end
    self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
	self._talbeView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._talbeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
	self._talbeView:reloadData()
	
	local haibao = cc.Sprite:create("res/image/VoucherCenter/haibaobg.png")
	self:addChild(haibao)
	haibao:setScaleX(0.85)
	haibao:setScaleY(0.8)
	haibao:setPosition(self:getContentSize().width *0.5 - 20,haibao:getContentSize().height *0.5 + 5)

	local title = cc.Sprite:create("res/image/VoucherCenter/danbi/title.png")
	haibao:addChild(title)
	title:setPosition(haibao:getContentSize().width *0.5,haibao:getContentSize().height *0.5)
end

function VoucherDanbi:createTableViewCell(index,cell)
	for i = 1, 3 do
		local cellbg = cc.Sprite:create("res/image/VoucherCenter/cellbg_2.png")
		cell:addChild(cellbg)
		cellbg:setScale(0.85)
		local x = 15 + cellbg:getContentSize().width *0.5 + (i - 1) * (cellbg:getContentSize().width *0.85 + 20)
		cellbg:setPosition(x,cell:getContentSize().height *0.5)

		local itemNode = ItemNode:createWithParams({
			_type_ = 4,
			itemId = 2031,
			count = 100,
		})
		itemNode:setScale(0.65)
		cellbg:addChild(itemNode)
		itemNode:setPosition(cellbg:getContentSize().width *0.5 - 1,cellbg:getContentSize().height *0.5 + 9)
		
		local money = XTHDLabel:create("100",20)
		money:setColor(cc.c3b(55,44,33))
		cellbg:addChild(money)
		money:setPosition(cellbg:getContentSize().width *0.5,money:getContentSize().height *0.5 + 25)
		
		local buyBtn = XTHDPushButton:createWithParams({
			touchSize =cc.size(cellbg:getContentSize().width,cell:getContentSize().height),
			needEnableWhenMoving = true,
		})
		cellbg:addChild(buyBtn)
		buyBtn:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.5)
		
		buyBtn:setTouchBeganCallback(function()
			cellbg:setScale(0.83)
		end)
	
		buyBtn:setTouchMovedCallback(function()
			cellbg:setScale(0.85)
		end)
	
		buyBtn:setTouchEndedCallback(function()
			 cellbg:setScale(0.85)
		end)

	end
end

function VoucherDanbi:create()
	return VoucherDanbi.new()
end

return VoucherDanbi

--endregion
