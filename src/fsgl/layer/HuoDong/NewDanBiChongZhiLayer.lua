--[[
	单笔充值活动
]]
local NewDanBiChongZhiLayer = class("NewDanBiChongZhiLayer", function()
    local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	node:setContentSize(705,468)
	return node
end)

function NewDanBiChongZhiLayer:ctor(parent,params)
	self._exist = true
	self._parent = parent
	-- print("单笔充值服务器返回的数据为：")
	-- print_r(params)
	self.serverData = params or {}
	self.closeTime = params.close

	-- 开启时间
	self._openTime = {
		beginMonth = params.beginMonth or "",
		beginDay = params.beginDay or "",
		endMonth = params.endMonth or "",
		endDay = params.endDay or "",
	}

	-- 数据
	self._localData = gameData.getDataFromCSV( "SingleCharging" )
	self:sortList(params)

	-- 添加监听事件
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG ,callback = function()
		if self._exist then
        	self:refreshData()
        end
    end})

	self:initUI()
	LayerManager.layerOpen(1, self)
end
-- 
function NewDanBiChongZhiLayer:onCleanup()
	LayerManager.layerClose(1)
	self._exist = false
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_RECHARGE_MSG)
end

-- 创建界面
function NewDanBiChongZhiLayer:initUI()	
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
        return math.ceil(#self._localData/3)
    end
    local function tableCellTouched(table,cell)
    end
    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(self._talbeView:getContentSize().width,190)
        else
            cell:removeAllChildren()
        end
		self:initCell(cell,idx)

		return cell
	end
    self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._talbeView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
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

function NewDanBiChongZhiLayer:initCell(cell,index)
	for i = 1, 3 do
		local index = index * 3 + i
		local cellbg = cc.Sprite:create("res/image/VoucherCenter/cellbg_2.png")
		cellbg:setScale(0.9)
		local x = cellbg:getContentSize().width *0.5 + (i - 1) * (cellbg:getContentSize().width + 10)
		cellbg:setPosition(x,cell:getContentSize().height *0.5)
		cell:addChild(cellbg)
		
		local itembtn = XTHDPushButton:createWithParams({
			normalFile = "res/image/VoucherCenter/danbi/danbi_"..index ..".png",
			selectedFile = "res/image/VoucherCenter/danbi/danbi_"..index ..".png",
			needEnableWhenMoving = true,
		})
		itembtn:setSwallowTouches(false)
		cellbg:addChild(itembtn,10)
		itembtn:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.5 + 10)
		itembtn:setScale(0.7)
		itembtn:setTouchEndedCallback(function()
			local layer = requires("src/fsgl/layer/VoucherCenter/ItemNodePop.lua"):create(self._localData[index],"danbi")
			cc.Director:getInstance():getRunningScene():addChild(layer)
			layer:show()
		end)

		local buyTip = XTHDLabel:create("单笔充值"..self._localData[index].charge.."元",16,"res/fonts/hkys.ttf")
		buyTip:setColor(cc.c3b(70,40,0))
		cellbg:addChild(buyTip)
		buyTip:setPosition(cellbg:getContentSize().width*0.5,cellbg:getContentSize().height - buyTip:getContentSize().height *0.5 - 15)
		
		local miaoshu = XTHDLabel:create(self._localData[index].charge.."元礼包",20,"res/fonts/hkys.ttf")
		miaoshu:setColor(cc.c3b(70,40,0))
		--miaoshu:enableOutline(cc.c4b(255,230,180,255),1)
		cellbg:addChild(miaoshu)
		miaoshu:setPosition(cellbg:getContentSize().width *0.5,miaoshu:getContentSize().height *0.5 + 26)

		--领取按钮
		if self._localData[index].state == 1 then
			miaoshu:setString("可领取")
			local btn_lingqu = XTHDPushButton:createWithParams({
				touchSize = cc.size(cellbg:getContentSize().width,cellbg:getContentSize().height),
				needEnableWhenMoving = true,
			})
			cellbg:addChild(btn_lingqu)
			btn_lingqu:setPosition(cellbg:getContentSize().width - btn_lingqu:getContentSize().width *0.5 - 25,cellbg:getContentSize().height *0.5 - 10)
			
			btn_lingqu:setTouchBeganCallback(function()
				cellbg:setScale(0.83)
			end)
	
			btn_lingqu:setTouchMovedCallback(function()
				cellbg:setScale(0.85)
			end)

			btn_lingqu:setTouchEndedCallback(function()
				cellbg:setScale(0.85)
				self:receiveReward(index)
			end)

			local guang = cc.Sprite:create("res/image/VoucherCenter/danbi/guang.png")
			cellbg:addChild(guang)
			guang:setPosition(itembtn:getPosition())
			guang:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,15)))
		else
--			local normalnode = cc.Sprite:create("res/image/activities/newsinglerecharge/goBtn_normal.png")
--			local selectednode = cc.Sprite:create("res/image/activities/newsinglerecharge/goBtn_selected.png")
--			local btn_go = XTHD.createCommonButton({
--				normalNode = normalnode,
--				selectedNode = selectednode,
--				isScrollView = true,
--				endCallback = function ()
--					XTHD.createRechargeVipLayer(self)
--				end
--			})
--			cellbg:addChild(btn_go)
--			btn_go:setPosition(cellbg:getContentSize().width - btn_go:getContentSize().width *0.5 - 25,cellbg:getContentSize().height *0.5 - 10)
		end
	end
end

function NewDanBiChongZhiLayer:receiveReward(index)
	HttpRequestWithParams("singlePayReward",{ configId  = self._localData[index].id},function (data)
  --       print("领取单笔充值返回的参数为")
		-- print_r(data)
		local show_data = {}
		if data.property then
			for i = 1, #data.property do
				local _data = string.split(data.property[i],",")
				local num_1 = gameUser.getDataById(_data[1])
				if num_1 ~= nil then
					local getNum = tonumber(_data[2]) - tonumber(num_1)
					if getNum > 0 then
						local idx = #show_data + 1
						show_data[idx] = {}
						show_data[idx].rewardtype = XTHD.resource.propertyToType[tonumber(_data[1])]
						show_data[idx].num = getNum
					end
					gameUser.updateDataById(_data[1],_data[2])
				end
			end
		end
		for i = 1 ,#data.bagItems do
			local _data = data.bagItems[i]
			local num_2 = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _data.itemId}).count or 0
			local num = _data.count - num_2
			show_data[#show_data+1] = {rewardtype = 4,id =_data.itemId,num = num}
			DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
		end
		ShowRewardNode:create(show_data)
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
		self:refreshData()
    end)
end

-- 重新请求数据，刷新界面
function NewDanBiChongZhiLayer:refreshData()
	HttpRequestWithOutParams("singlePayRewardList",function (data)
		if self._exist then
        	self:sortList(data)
			self._talbeView:reloadData()
        end
    end)  
end

function NewDanBiChongZhiLayer:sortList(data)
	for i = 1,#data.list do
		self._localData[i] =  gameData.getDataFromCSV("SingleCharging",{id = data.list[i].configId})
		self._localData[i].state = data.list[i].isGet
		if self._localData[i].state == 1 then
			self._localData[i].sortid = self._localData[i].id + 10
		else
			self._localData[i].sortid = math.abs(self._localData[i].id - 6)
		end
	end
	table.sort(self._localData, function(a, b)
        return a.sortid > b.sortid
    end )
	self._parent:freshRedDot(self._parent.selectedIndex)
end

function NewDanBiChongZhiLayer:updateTime()
    self:stopActionByTag(10)
    self.Time:setString("活动剩余时间："..LANGUAGE_KEY_CARNIVALDAY(self.closeTime))
    schedule(self, function()
        self.closeTime = self.closeTime - 1
        if self.closeTime < 0 then
            self.Time:setString("活动已结束")
            return
        end
        local time = "活动剩余时间："..LANGUAGE_KEY_CARNIVALDAY(self.closeTime)
        self.Time:setString(time)
    end,1,10)
end

function NewDanBiChongZhiLayer:create(parent,params)
    return self.new(parent,params)
end

return NewDanBiChongZhiLayer
