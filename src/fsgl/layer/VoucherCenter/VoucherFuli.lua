--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local VoucherFuli = class("VoucherFuli",function()
	local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	node:setContentSize(705,468)
	return node
end)

function VoucherFuli:ctor(parent,data)
	self._parent = parent
	self._severData = data
	self._buyIndex = 0
	self._data = {}
	dump(self._severData)
	self:refreshData()
	self:init()
end

function VoucherFuli:init()
	local _bg = cc.Sprite:create("res/image/newGuild/memberbg.png")
	_bg:setContentSize(450,370)
	self:addChild(_bg)
	_bg:setPosition(self:getContentSize().width *0.6 + 15,self:getContentSize().height *0.6 - 4)
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
        return math.ceil(#self._data/3)
    end
	
    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(self._talbeView:getContentSize().width,190)
        else
            cell:removeAllChildren()
        end
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

	local title = cc.Sprite:create("res/image/VoucherCenter/fulilibao/title.png")
	haibao:addChild(title)
	title:setPosition(haibao:getContentSize().width *0.5,haibao:getContentSize().height *0.5)
end

function VoucherFuli:createTableViewCell(index,cell)
	for i = 1,3 do
		local _index = index * 3 + i
		print("-----------------index",_index)
		local _data = self._data[_index]
		if _data == nil then
			return
		end
		local cellbg = cc.Sprite:create("res/image/VoucherCenter/cellbg_2.png")
		cell:addChild(cellbg)
		cellbg:setScale(0.9)
		local x = cellbg:getContentSize().width *0.5 + (i - 1) * (cellbg:getContentSize().width + 10)
		cellbg:setPosition(x,cell:getContentSize().height *0.5)
		
		local itembtn = XTHDPushButton:createWithParams({
			normalFile = "res/image/VoucherCenter/fulilibao/fulilibao_" .. _data.id ..".png",
			selectedFile = "res/image/VoucherCenter/fulilibao/fulilibao_" .. _data.id ..".png",
			needEnableWhenMoving = true,
		})
		itembtn:setSwallowTouches(false)
		cellbg:addChild(itembtn,10)
		itembtn:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.5 + 10)
		itembtn:setScale(0.7)
		itembtn:setTouchEndedCallback(function()
			local layer = requires("src/fsgl/layer/VoucherCenter/ItemNodePop.lua"):create(_data,"fuli")
			cc.Director:getInstance():getRunningScene():addChild(layer)
			layer:show()
		end)

		local itemName = XTHDLabel:create(_data.name,18,"res/fonts/hkys.ttf")
		itemName:setColor(cc.c3b(70,40,0))
		--itemName:enableOutline(cc.c4b(255,230,180,255),1)
		cellbg:addChild(itemName)
		itemName:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height - itemName:getContentSize().height *0.5 - 10)

		local restrictSumLable = XTHDLabel:create("限购次数：".._data.restrictSum - _data.sum,16,"res/fonts/hkys.ttf")
		restrictSumLable:setAnchorPoint(0.5,0.5)
		restrictSumLable:setColor(cc.c3b(70,40,0))
		--restrictSumLable:enableOutline(cc.c4b(255,230,180,255),1)
		cellbg:addChild(restrictSumLable)
		restrictSumLable:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.3 + 2)

		local money = XTHDLabel:create("￥".._data.rmb,20,"res/fonts/hkys.ttf")
		money:setColor(cc.c3b(70,40,0))
		--money:enableOutline(cc.c4b(255,230,180,255),1)
		cellbg:addChild(money)
		money:setPosition(cellbg:getContentSize().width *0.5,money:getContentSize().height *0.5 + 25)
		
		local buyBtn = XTHDPushButton:createWithParams({
			touchSize =cc.size(cellbg:getContentSize().width,cell:getContentSize().height),
			needEnableWhenMoving = true,
		})
		buyBtn:setSwallowTouches(false)
		cellbg:addChild(buyBtn)
		buyBtn:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.5)
		
		buyBtn:setTouchBeganCallback(function()
			cellbg:setScale(0.83)
		end)
	
		buyBtn:setTouchMovedCallback(function()
			cellbg:setScale(0.85)
		end)
	
		buyBtn:setTouchEndedCallback(function()
			self._buyIndex = _index
			if _data.Rechargeid ~= 0 then
				cellbg:setScale(0.85)
				_data.needGold = 0
				_data.configId = _data.Rechargeid
				XTHD.pay(_data,nil,self)
			else
				self:BuyMianfeilibao()
			end
		end)
		
		if _data.sum >= _data.restrictSum then
			XTHD.setGray(cellbg,true)
			buyBtn:setEnable(false)
		end
	
	end
end

function VoucherFuli:refreshData()
	local list = gameData.getDataFromCSV("WelfareMall")
	for k,v in pairs(self._severData.list) do
		list[k].state = v.state
		list[k].sum = v.sum
	end
	
	for i = 1 ,#list do
		if list[i].tpyeA == 3 and list[i].state == 0 then
			list[i] = nil
		end
	end
	
	self._data = {}

	for k,v in pairs(list) do
		self._data[#self._data + 1] = v
	end
end

function VoucherFuli:updateCell()
	for i = 1,#self._severData.list do
		if self._severData.list[i].configId == self._data[self._buyIndex].id then
			self._severData.list[i].sum = self._severData.list[i].sum + 1
			if self._severData.list[i].sum >= self._data[self._buyIndex].restrictSum then
				self._severData.list[i].state = 0
			end
		end
	end
	self:refreshData()
	self._talbeView:reloadData()
end

function VoucherFuli:BuyMianfeilibao()
	HttpRequestWithOutParams("receiveWelfareShop", function(data)
		dump(data)
		local showlist = {}
		if data.bagItems then
			for i = 1,#data.bagItems do
				local _data = data.bagItems[i]
				local num1 = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _data.itemId}).count or 0
				local getNum = tonumber(_data.count) - tonumber(num1)
				showlist[#showlist+1] = {rewardtype = 4,id =_data.itemId,num =getNum}
			end
		end
		ShowRewardNode:create(showlist)
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
		self:updateCell()
	end )
end

function VoucherFuli:create(parent,data)
	return VoucherFuli.new(parent,data)
end

return VoucherFuli

--endregion
