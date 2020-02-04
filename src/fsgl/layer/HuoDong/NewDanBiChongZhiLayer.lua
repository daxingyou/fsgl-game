--[[
	单笔充值活动
]]
local NewDanBiChongZhiLayer = class("NewDanBiChongZhiLayer", function()
    local layer = XTHD.createSprite()
	layer:setContentSize( 539, 399 )
	return layer
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
	-- 背景
	local titleBg = cc.Sprite:create("res/image/activities/newsinglerecharge/titlebg.png")
	self:addChild(titleBg)
	titleBg:setPosition(self:getContentSize().width/2 - 5,self:getContentSize().height - 40)

	self.Time = XTHDLabel:create("",15,"res/fonts/def.ttf")
    self.Time:setColor(cc.c3b(255,255,255))
    titleBg:addChild(self.Time)
    self.Time:setPosition(titleBg:getContentSize().width - 130,titleBg:getContentSize().height - 20)
    self:updateTime()
	
	self._talbeView = CCTableView:create(cc.size(535, 320))
	self._talbeView:setPosition(0,3)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self._talbeView)


    local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,80
    end
    local function numberOfCellsInTableView(table)
        return #self._localData
    end
    local function tableCellTouched(table,cell)
    end
    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(self._talbeView:getContentSize().width,80)
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
end

function NewDanBiChongZhiLayer:initCell(cell,index)
	index = index + 1 
	local cellbg = cc.Sprite:create("res/image/activities/newsinglerecharge/cellbg.png")
	cellbg:setContentSize(cell:getContentSize().width - 5,cell:getContentSize().height - 10)
	cellbg:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.5)
	cell:addChild(cellbg)

	--档位图片
	local typeIcon = cc.Sprite:create("res/image/activities/newsinglerecharge/box"..self._localData[index].id..".png")
	cellbg:addChild(typeIcon)
	typeIcon:setPosition(typeIcon:getContentSize().width - 20,cellbg:getContentSize().height/2)

	for i = 1, #self._localData do
		if self._localData[i]["item"..tostring(i).."num"] ~= nil and self._localData[i]["item"..tostring(i).."num"] > 0 then
			local item = ItemNode:createWithParams({
				_type_ = self._localData[index]["item"..tostring(i).."type"],
				itemId = self._localData[index]["item"..tostring(i).."ID"],
				count = self._localData[index]["item"..tostring(i).."num"]
			})
			item:setScale(0.5)
			cellbg:addChild(item)
			item:setPosition(item:getContentSize().width * 0.5 + (i-1) * item:getContentSize().width/5*4 + 70 , cellbg:getContentSize().height * 0.5)
		end
	end

	local buyTip = XTHDLabel:create("单笔充值"..self._localData[index].charge.."元",15,"res/fonts/def.ttf")
    buyTip:setColor(cc.c3b(0,0,0))
    cellbg:addChild(buyTip)
    buyTip:setPosition(cellbg:getContentSize().width - buyTip:getContentSize().width *0.5 - 20,cellbg:getContentSize().height *0.5 + 20)

	--领取按钮
	if self._localData[index].state == 1 then
		local normalnode = cc.Sprite:create("res/image/activities/newsinglerecharge/receiveBtn_normal.png")
		local selectednode = cc.Sprite:create("res/image/activities/newsinglerecharge/receiveBtn_selected.png")
		local btn_lingqu = XTHD.createCommonButton({
			normalNode = normalnode,
			selectedNode = selectednode,
			isScrollView = true,
			endCallback = function ()
				self:receiveReward(index)
			end
		})
		cellbg:addChild(btn_lingqu)
		btn_lingqu:setPosition(cellbg:getContentSize().width - btn_lingqu:getContentSize().width *0.5 - 25,cellbg:getContentSize().height *0.5 - 10)

		local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		btn_lingqu:addChild(fetchSpine)
		fetchSpine:setScaleX(0.65)
		fetchSpine:setScaleY(0.6)
		fetchSpine:setPosition(btn_lingqu:getBoundingBox().width*0.5 + 1, btn_lingqu:getContentSize().height*0.5+2)
		fetchSpine:setAnimation(0, "querenjinjie", true )
	else
		local normalnode = cc.Sprite:create("res/image/activities/newsinglerecharge/goBtn_normal.png")
		local selectednode = cc.Sprite:create("res/image/activities/newsinglerecharge/goBtn_selected.png")
		local btn_go = XTHD.createCommonButton({
			normalNode = normalnode,
			selectedNode = selectednode,
			isScrollView = true,
			endCallback = function ()
				XTHD.createRechargeVipLayer(self)
			end
		})
		cellbg:addChild(btn_go)
		btn_go:setPosition(cellbg:getContentSize().width - btn_go:getContentSize().width *0.5 - 25,cellbg:getContentSize().height *0.5 - 10)
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
	-- print("排好序的数据为")
 --    print_r(self._localData)
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
