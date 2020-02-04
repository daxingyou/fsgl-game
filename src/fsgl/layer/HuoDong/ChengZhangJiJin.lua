--Created By Liuluyang 2015年06月13日
local ChengZhangJiJin = class("ChengZhangJiJin",function ()
	local layer = XTHD.createSprite()
	layer:setContentSize( 539, 399 )
	return layer
end)

function ChengZhangJiJin:ctor(parent,data)
	self._parent = parent
	self._localData = {}
	self._data = data
	self:sortList(data)
	-- print("成长基金服务器返回的数据为：")
	-- print_r(data)
	self:initUI()
end

function ChengZhangJiJin:initUI()	

	local hero = cc.Sprite:create("res/image/activities/chengzhangjijin/role.png")
	self:addChild(hero)
	hero:setPosition(hero:getContentSize().width*0.5 - 30,hero:getContentSize().height *0.5 + 10)		

	local titleBg = cc.Sprite:create("res/image/activities/chengzhangjijin/title.png")
	self:addChild(titleBg)
	titleBg:setPosition(self:getContentSize().width/2 - 5,self:getContentSize().height - 50)

	local goumai = XTHDPushButton:createWithFile({
		normalFile = "res/image/activities/chengzhangjijin/buyBtn_normal.png",
		selectedFile = "res/image/activities/chengzhangjijin/buyBtn_selected.png",
		isScrollView = false,
		endCallback = function ()
			-- print("购买成长基金")
			XTHD.pay(gameData.getDataFromCSV("StoredValue",{id = 11}),3,self)
		end
	}) 
	titleBg:addChild(goumai)
	goumai:setPosition(titleBg:getContentSize().width - 80,titleBg:getContentSize().height/2 - 5)
	self.goumai = goumai
	self:freshRedDot()
	
	self._talbeView = CCTableView:create(cc.size(420, 300))
	self._talbeView:setPosition(115,2)
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

function ChengZhangJiJin:initCell(cell,index)
	index = index + 1 
	local cellbg = cc.Sprite:create("res/image/activities/chengzhangjijin/cellbg.png")
	cellbg:setContentSize(cell:getContentSize().width - 5,cell:getContentSize().height - 10)
	cellbg:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.5)
	cell:addChild(cellbg)
	
	local howdaybg = cc.Sprite:create("res/image/activities/chengzhangjijin/temp.png")
	cellbg:addChild(howdaybg)
	howdaybg:setPosition(10 + howdaybg:getContentSize().width*0.5,cellbg:getContentSize().height*0.5)

	local lable = XTHDLabel:create("第"..self._localData[index].id.."天",14,"res/fonts/def.ttf")
	lable:setColor(cc.c3b(115,74,2))
	howdaybg:addChild(lable)
	lable:setPosition(howdaybg:getContentSize().width *0.5,howdaybg:getContentSize().height *0.5)

	for i = 1, #self._localData do
		if self._localData[i]["num"..tostring(i)] ~= nil and self._localData[i]["num"..tostring(i)] > 0 then
			local item = ItemNode:createWithParams({
				_type_ = self._localData[index]["type" .. tostring(i)],
				itemId = self._localData[index]["id" .. tostring(i)],
				count = self._localData[index]["num"..tostring(i)]
			})
			item:setScale(0.6)
			cellbg:addChild(item)
			item:setPosition(item:getContentSize().width * 0.5 + (i-1) * item:getContentSize().width + howdaybg:getPositionX() + howdaybg:getContentSize().width *0.5, cellbg:getContentSize().height * 0.5)
		end
	end

	--领取按钮
	if self._localData[index].state == 2 then
		local yilingqu = cc.Sprite:create("res/image/activities/chengzhangjijin/yilingqu.png")
		cellbg:addChild(yilingqu)
		yilingqu:setPosition(cellbg:getContentSize().width - yilingqu:getContentSize().width + 15,cellbg:getContentSize().height *0.5 )
	elseif self._localData[index].state == 1 then
		local normalnode = cc.Sprite:create("res/image/activities/chengzhangjijin/receiveBtn_normal.png")
		local selectednode = cc.Sprite:create("res/image/activities/chengzhangjijin/receiveBtn_selected.png")
		local btn_lingqu = XTHD.createCommonButton({
			normalNode = normalnode,
			selectedNode = selectednode,
			isScrollView = true,
			endCallback = function ()
				self:receiveReward(index)
			end
		})
		cellbg:addChild(btn_lingqu)
		btn_lingqu:setPosition(cellbg:getContentSize().width - btn_lingqu:getContentSize().width *0.5 - 20,cellbg:getContentSize().height *0.5)

		local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		btn_lingqu:addChild(fetchSpine)
		fetchSpine:setScaleX(0.65)
		fetchSpine:setScaleY(0.6)
		fetchSpine:setPosition(btn_lingqu:getBoundingBox().width*0.5 + 1, btn_lingqu:getContentSize().height*0.5+2)
		fetchSpine:setAnimation(0, "querenjinjie", true )
	else
		-- local normalnode = cc.Sprite:create("res/image/common/btn/btn_write_up.png")
		-- normalnode:setContentSize(cc.size(100,50))
		-- local selectednode = cc.Sprite:create("res/image/common/btn/btn_write_down.png")
		-- selectednode:setContentSize(cc.size(100,50))
		-- local btn_lingqu = XTHD.createCommonButton({
		-- 	text = "未完成",
		-- 	fontColor = cc.c3b( 255, 255, 255 ),
		-- 	fontSize = 18,
		-- 	normalNode = normalnode,
		-- 	selectedNode = selectednode,
		-- 	isScrollView = true,
		-- 	endCallback = function ()
		-- 		print("请先购买成长基金")
		-- 	end
		-- })
		-- cellbg:addChild(btn_lingqu)
		-- btn_lingqu:setPosition(cellbg:getContentSize().width - btn_lingqu:getContentSize().width *0.5 - 20,cellbg:getContentSize().height *0.5 - 5)

		local unfinish = cc.Sprite:create("res/image/activities/chengzhangjijin/unenable.png")
		cellbg:addChild(unfinish)
		unfinish:setPosition(cellbg:getContentSize().width - unfinish:getContentSize().width + 15,cellbg:getContentSize().height *0.5 )
	end

end

function ChengZhangJiJin:receiveReward(index)
	HttpRequestWithParams("receiveGrowthFundReward",{ configId  = self._localData[index].id},function (data)
  --       print("领取成长基金服务器返回的参数为")
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
		self:sortList(data)
		self._talbeView:reloadData()
		self:freshRedDot(data)
    end)
end

function ChengZhangJiJin:freshData()
	HttpRequestWithOutParams("growthFundList",function (data)
        self:sortList(data)
		self._talbeView:reloadData()
		self:freshRedDot(data)
    end)
end

function ChengZhangJiJin:sortList(data)
	for i = 1,#data.list do
		self._localData[i] =  gameData.getDataFromCSV("GrowthFund",{id = data.list[i].configId})
		self._localData[i].state = data.list[i].state
		if self._localData[i].state == 1 then
			self._localData[i].sortid = self._localData[i].id + 10
		elseif self._localData[i].state == 2 then
			self._localData[i].sortid = self._localData[i].id - 10
		else
			self._localData[i].sortid = math.abs(self._localData[i].id - 7)
		end
	end
	table.sort(self._localData, function(a, b)
        return a.sortid > b.sortid
    end )
end

function ChengZhangJiJin:freshRedDot(data)
	self.goumai:setVisible(true)
	local isBuy = 0
	for i = 1,#self._localData do
		if self._localData[i].state == 1 or self._localData[i].state == 2 then
			self.goumai:setVisible(false)
			break
		end
	end
	for i = 1,#self._localData do
		if self._localData[i].state == 2 then
			isBuy = isBuy + 1
		end
	end
	if isBuy == #self._localData then
		self.goumai:setVisible(false)
	end
	if data then
		for k,v in pairs(data.list) do
			if v.state == 1 then
				RedPointState[19].state = 1
				break
			else
				RedPointState[19].state = 0
			end
		end
	end
	-- self._parent:freshRedDot(self._parent.selectedIndex)
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ACTIVITY_BFYL})
end

function ChengZhangJiJin:create(parent,data)
	return ChengZhangJiJin.new(parent,data)
end

return ChengZhangJiJin