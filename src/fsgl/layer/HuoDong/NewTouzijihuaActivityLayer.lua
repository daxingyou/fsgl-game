--Created By Liuluyang 2015年06月13日
local NewTouzijihuaActivityLayer = class("NewTouzijihuaActivityLayer",function ()
	local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	node:setContentSize(830,342)
	return node
end)

function NewTouzijihuaActivityLayer:ctor(data,parent)
	self._parent = parent
	self._staticData = data
	self._investReward = self._staticData.investReward
	self._selectedIndex = 1
	self._btnList = {}
	self._listData = nil
	self._listData = gameData.getDataFromCSV("InvestmentPlan",{type = self._selectedIndex})
	self._InvestmentPrice = gameData.getDataFromCSV("InvestmentPrice",{type = self._selectedIndex})
--	dump(self._InvestmentPrice,"投资计划数据")
	self:initUI()
end

function NewTouzijihuaActivityLayer:initUI()	
	local bg = cc.Sprite:create()
	self:addChild(bg)
	bg:setContentSize(self:getContentSize())
	bg:setPosition(self:getContentSize().width*0.5,self:getContentSize().height *0.5)
	self._bg = bg

	local listviewbg = cc.Sprite:create("res/image/activities/newhuoyueyouli/listviewbg.png")
	self._bg:addChild(listviewbg)
	listviewbg:setContentSize(listviewbg:getContentSize().width,self._bg:getContentSize().height)
	listviewbg:setPosition(listviewbg:getContentSize().width *0.5,listviewbg:getContentSize().height *0.5)
	self._listviewbg = listviewbg
	
	local title = cc.Sprite:create("res/image/activities/newhuoyueyouli/title_huoyueyouli.png")
	title:setScale(1.187)
	title:setAnchorPoint(0,1)
	self._bg:addChild(title)
	title:setPosition(listviewbg:getContentSize().width,self._bg:getContentSize().height)
	
	local bg3 = cc.Sprite:create("res/image/activities/newhuoyueyouli/renwu.png")
	bg3:setScale(0.7)
	self._bg:addChild(bg3)
	bg3:setPosition(self._bg:getContentSize().width - bg3:getContentSize().width *0.4 + 30,self._bg:getContentSize().height - bg3:getContentSize().height *0.5)

	self._tableViewBg = cc.Sprite:create("res/image/activities/huoyueyouli/bg_2.png")
	self._tableViewBg:setAnchorPoint(0,1)
	self._bg:addChild(self._tableViewBg)
	self._tableViewBg:setContentSize(self._tableViewBg:getContentSize().width,self:getContentSize().height - title:getContentSize().height *1.18)
	self._tableViewBg:setPosition(listviewbg:getContentSize().width,self._bg:getContentSize().height - title:getContentSize().height * 1.187)

	--左边按钮
	local btn_listView = ccui.ListView:create()
    btn_listView:setContentSize(listviewbg:getContentSize())
    btn_listView:setDirection(ccui.ScrollViewDir.vertical)
    btn_listView:setBounceEnabled(true)
	btn_listView:setScrollBarEnabled(false)
	btn_listView:setSwallowTouches(true)
    listviewbg:addChild(btn_listView,10)
    btn_listView:setPosition(cc.p(0,0))
    self._btn_listView = btn_listView	
	local list = gameData.getDataFromCSV("InvestmentPrice")
	
	for i = 1, #list do
		local layout = ccui.Layout:create()
		layout:setContentSize(151,75)
		
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/activities/newTouzijihua/btn_".. list[i].type .. "_up.png",
			selectedFile = "res/image/activities/newTouzijihua/btn_".. list[i].type  .."_down.png",
			isScrollView = true,
			needEnableWhenMoving = true,
			endCallback  = function()
				 self:selecteTableView(list[i].type)
			end,
		})
		btn:setSwallowTouches(false)
		layout:addChild(btn)
		btn:setPosition(layout:getContentSize().width*0.5,layout:getContentSize().height *0.5)
		self._btnList[#self._btnList + 1] = btn
		
		local selectedbg = cc.Sprite:create("res/image/activities/newTouzijihua/btn_" .. list[i].type .. "_down.png")
		btn:addChild(selectedbg)
		selectedbg:setPosition(btn:getContentSize().width *0.5,btn:getContentSize().height *0.5)
		selectedbg:setVisible(false)
		selectedbg:setName("selectedbg")

		
		local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
        btn:addChild(redDot)
        redDot:setPosition(10, btn:getBoundingBox().height - 10)
		redDot:setScale(0.6)
		redDot:setVisible(false)	
		redDot:setName("redDot")

		
		self._btn_listView:pushBackCustomItem(layout)
		
	end
	
	--购买投资计划按钮
	local goumai = XTHD.createCommonButton({
		text = "购 买",
		fontColor = cc.c3b( 255, 255, 255 ),
		fontSize = 24,
		normalNode = normalnode,
		selectedNode = selectednode,
		isScrollView = true,
		endCallback = function ()
			self:InvestPlanBuy()
		end
	}) 
	title:addChild(goumai)
	goumai:setScale(0.6)
	goumai:setPosition(title:getContentSize().width - goumai:getContentSize().width *0.5 + 20, goumai:getContentSize().height*0.25)
	self.goumai = goumai

	self._tishiLable = XTHDLabel:create("aaaaaaaaaaaaaaaaa",14,"res/fonts/def.ttf")
	title:addChild(self._tishiLable)
	self._tishiLable:setAnchorPoint(1,0.5)
	self._tishiLable:setPosition(goumai:getPositionX() - goumai:getContentSize().width*0.5,self._tishiLable:getContentSize().height *0.5 + 3)
	
	self:inittableView()
	self:selecteTableView(1)
end

function NewTouzijihuaActivityLayer:selecteTableView(index)
	self._selectedIndex = index
	for i = 1,#self._btnList do
		if self._btnList[i]:getChildByName("selectedbg") then
			self._btnList[i]:getChildByName("selectedbg"):setVisible(false)
		end
	end
	local idx = nil
	if index >= 3 then
		idx = index -1 
	else
		idx = index
	end
	if self._btnList[idx]:getChildByName("selectedbg") then
		self._btnList[idx]:getChildByName("selectedbg"):setVisible(true)
	end

	self._listData = gameData.getDataFromCSV("InvestmentPlan",{type = self._selectedIndex})
	self._InvestmentPrice = gameData.getDataFromCSV("InvestmentPrice",{id = self._selectedIndex})
	lsit = gameData.getDataFromCSV("InvestmentPrice",{id = idx})
	self._tishiLable:setString(lsit.describe)
	self:ChangeTableView()
	self:updateRedDot()
end

function NewTouzijihuaActivityLayer:inittableView()
	self._talbeView = CCTableView:create(self._tableViewBg:getContentSize())
	self._talbeView:setPosition(151,0)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._bg:addChild(self._talbeView)


    local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,80
    end
    local function numberOfCellsInTableView(table)
        return #self._listData
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
		self:selecetdJiangliTableView(cell,idx)

		return cell
	end
    self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._talbeView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._talbeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)

    self._talbeView:reloadData()

end

function NewTouzijihuaActivityLayer:selecetdJiangliTableView(cell,index)
	index = index + 1 
	local cellbg = cc.Sprite:create("res/image/activities/newhuoyueyouli/cellbg.png")
	cellbg:setContentSize(cell:getContentSize().width - 5,cell:getContentSize().height - 5)
	cellbg:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.5)
	cell:addChild(cellbg)
	
	local _index = nil
	if self._selectedIndex >= 3 then
		_index =  self._investReward[index].configId - (self._selectedIndex-2) * 7	
	else
		_index =  self._investReward[index].configId - (self._selectedIndex-1) * 7	
	end

	local jiangli = {}
	for i = 1, #self._listData do
		if self._listData[i]["num"..tostring(i)] ~= nil and self._listData[i]["num"..tostring(i)] > 0 then
			local item = ItemNode:createWithParams({
				_type_ = self._listData[_index]["type" .. tostring(i)],
				itemId = self._listData[_index]["id" .. tostring(i)],
				count = self._listData[_index]["num"..tostring(i)],
				showDrropType = 2,
			})
			item:setScale(0.6)
			cellbg:addChild(item)
			item:setPosition(item:getContentSize().width * 0.5 + (i-1) * item:getContentSize().width , cellbg:getContentSize().height * 0.5)
			jiangli[#jiangli + 1] = item
		end
	end
	
	
	local tishi = cc.Sprite:create("res/image/activities/newTouzijihua/lingqu_" .. _index .. ".png")
	cellbg:addChild(tishi)
	tishi:setPosition(jiangli[#jiangli]:getPositionX() + jiangli[#jiangli]:getContentSize().width, cellbg:getContentSize().height *0.5 + 10)

	--领取按钮
	if self._investReward[index].state == 2 then
		local yilingqu = cc.Sprite:create("res/image/vip/yilingqu.png")
		yilingqu:setScale(0.6)
		cellbg:addChild(yilingqu)
		yilingqu:setPosition(cellbg:getContentSize().width - yilingqu:getContentSize().width *0.5,cellbg:getContentSize().height *0.5 )
	elseif self._investReward[index].state == 1 then
		local normalnode = cc.Sprite:create("res/image/common/btn/btn_write_up.png")
		normalnode:setContentSize(cc.size(100,50))
		local selectednode = cc.Sprite:create("res/image/common/btn/btn_write_down.png")
		selectednode:setContentSize(cc.size(100,50))
		local btn_lingqu = XTHD.createCommonButton({
			text = "领 取",
			fontColor = cc.c3b( 255, 255, 255 ),
			fontSize = 18,
			normalNode = normalnode,
			selectedNode = selectednode,
			isScrollView = true,
			endCallback = function ()
				self:InvestPlanReward(index)
			end
		})
		cellbg:addChild(btn_lingqu)
		btn_lingqu:setPosition(cellbg:getContentSize().width - btn_lingqu:getContentSize().width *0.5 - 20,cellbg:getContentSize().height *0.5 - 5)

		local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		btn_lingqu:addChild(fetchSpine)
		fetchSpine:setScaleX(0.65)
		fetchSpine:setScaleY(0.6)
		fetchSpine:setPosition(btn_lingqu:getBoundingBox().width*0.5 + 1, btn_lingqu:getContentSize().height*0.5+2)
		fetchSpine:setAnimation(0, "querenjinjie", true )
	else
		local normalnode = cc.Sprite:create("res/image/common/btn/btn_write_up.png")
		normalnode:setContentSize(cc.size(100,50))
		local selectednode = cc.Sprite:create("res/image/common/btn/btn_write_down.png")
		selectednode:setContentSize(cc.size(100,50))
		local btn_lingqu = XTHD.createCommonButton({
			text = "未完成",
			fontColor = cc.c3b( 255, 255, 255 ),
			fontSize = 18,
			normalNode = normalnode,
			selectedNode = selectednode,
			isScrollView = true,
			endCallback = function ()
				self:InvestPlanReward(index)
			end
		})
		cellbg:addChild(btn_lingqu)
		btn_lingqu:setPosition(cellbg:getContentSize().width - btn_lingqu:getContentSize().width *0.5 - 20,cellbg:getContentSize().height *0.5 - 5)

	end

end

function NewTouzijihuaActivityLayer:InvestPlanReward(index)
	ClientHttp:requestAsyncInGameWithParams({
        modules = "InvestPlanReward?",
		params = { configId  = self._investReward[index].configId},
        successCallback = function( data )
			if data.result == 0 then
--				dump(data,"领取奖励")
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
				for i = 1 ,#data.items do
					local _data = data.items[i]
					local num_2 = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _data.itemId}).count or 0
					local num = _data.count - num_2
					show_data[#show_data+1] = {rewardtype = 4,id =_data.itemId,num = num}
					DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
				end
				ShowRewardNode:create(show_data)
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})

				self._investReward = self:SortList(data.investReward)
				self._talbeView:reloadData()
				self:updateRedDot()
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

function NewTouzijihuaActivityLayer:InvestPlanBuy()
	local rightfunc = function()
 		ClientHttp:requestAsyncInGameWithParams({
			modules = "InvestPlanBuy?",
			params = { type  = self._selectedIndex},
			successCallback = function( data )
				if data.result == 0 then
					if data.playerProperty then
						for i = 1, #data.playerProperty do
							local _data = string.split(data.playerProperty[i],",")
							gameUser.updateDataById(_data[1],_data[2])
							XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
							self:selecteTableView(self._selectedIndex)
						end
					end
					XTHDTOAST("购买成功")
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
	local _confirmLayer = XTHDConfirmDialog:createWithParams( {
		rightCallback = rightfunc,
		msg = ("确认购买此投资计划吗？")
    } );
    cc.Director:getInstance():getRunningScene():addChild(_confirmLayer, 1)
end

function NewTouzijihuaActivityLayer:ChangeTableView()
	ClientHttp:requestAsyncInGameWithParams({
        modules = "InvestPlanRecord?",
		params = { type  = self._selectedIndex },
        successCallback = function( data )
			if data.result == 0 then
				if data.isBuy then
					self.goumai:setVisible(false)
				else
					self.goumai:setVisible(true)
				end
				self._staticData = data
				self._investReward = self:SortList(self._staticData.investReward)
				self._talbeView:reloadData()
			end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

function NewTouzijihuaActivityLayer:updateRedDot()
	local _redPointStata = {}
	for i = 1,#self._btnList do
		ClientHttp:requestAsyncInGameWithParams({
			modules = "InvestPlanRecord?",
			params = { type  = i },
			successCallback = function( data )
				if data.result == 0 then
					for j = 1, #data.investReward do
						if data.investReward[j].state == 1 then
							self._btnList[i]:getChildByName("redDot"):setVisible(true)
							break
						else
							self._btnList[i]:getChildByName("redDot"):setVisible(false)
						end
					end
					_redPointStata[#_redPointStata + 1] = data.investReward
					if i == #self._btnList then
						self:updataMainCityRedPoint(_redPointStata)
					end
				end
			end,
			failedCallback = function()
				XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
			end,--失败回调
			loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
			loadingParent = node,
		})
	end
end

function NewTouzijihuaActivityLayer:updataMainCityRedPoint(data)
	RedPointState[6].state = 0
	for i = 1,#data do
		for j = 1,#data[i] do
			if data[i][j].state == 1 then
				RedPointState[6].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "hyyl"}})
				return
			end
		end
	end
	self._parent:refreshRedDot()
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "hyyl"}})
end

function NewTouzijihuaActivityLayer:SortList( _table )
	local list_1,list_2,list_3 = {},{},{}
	for k,v in pairs(_table) do
		if v.state == 0 then
			list_2[#list_2 + 1] = v
		elseif v.state == 1 then
			list_1[#list_1 + 1] = v
		else
			list_3[#list_3 + 1] = v
		end
	end
	local listData = {}
	_table = {}
	for k,v in pairs(list_1) do
		listData[#listData + 1] = v
	end

	for k,v in pairs(list_2) do
		listData[#listData + 1] = v
	end

	for k,v in pairs(list_3) do
		listData[#listData + 1] = v
	end
	_table = listData
	return _table
end

function NewTouzijihuaActivityLayer:create(data,parent)
	return NewTouzijihuaActivityLayer.new(data,parent)
end

return NewTouzijihuaActivityLayer