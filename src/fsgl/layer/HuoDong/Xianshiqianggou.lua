--Created By Liuluyang 2015年06月13日
local Xianshiqianggou = class("Xianshiqianggou",function ()
	local layer = XTHD.createSprite()
	layer:setContentSize( 539, 399 )
	return layer
end)

function Xianshiqianggou:onEnter()
end

function Xianshiqianggou:onCleanup()
	self._exist = false
end

function Xianshiqianggou:ctor(parent,data)
--	dump(data)
	self._exist = true
	self._parent = parent
	self._data = data
	self._closeTime = data.close - os.time()
	self._closeTimeLable = {}
	self._cellList = {}
	self._selectList = {}
	self._curCommodity = {}
	self._futureCommodity = {}
	self._selectIndex = 1
	self._curPage = 0
	self._MaxPage = 0
	self:freshData()
	self:initUI()
	self:updateTime()
end

function Xianshiqianggou:updateTableViewCell()
	ClientHttp:requestAsyncInGameWithParams({
        modules = "fristGroupList?",
        successCallback = function( data )
			self._data = data
			self._dataList = data.list
			self:freshData()
			self._talbeView:reloadData()
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

function Xianshiqianggou:freshData()
	self._curCommodity = {}
	self._futureCommodity = {}
	
	local list = gameData.getDataFromCSV("OpenServerDiscountShop")
	self._MaxPage = list[#list].group
	for k,v in pairs(list) do 
		if v.id == self._data.list[#self._data.list].configId then
			self._selectIndex = v.group
			self._curPage = v.group
		end
	end

	local _table = {}
	for k,v in pairs(list) do
		if v.group == self._selectIndex then
			self._curCommodity[#self._curCommodity + 1] = v
		else
			self._futureCommodity[v.group] = {}
			_table[#_table + 1] = v
		end
	end

	for i = 1, self._MaxPage do
		for k,v in pairs(list) do
			if i == v.group and self._selectIndex ~= i then
				self._futureCommodity[v.group][#self._futureCommodity[v.group] + 1] = v
			end
		end
	end

end

function Xianshiqianggou:ClickCeilbtn(index)
	for i = 1,#self._selectList do
		if self._selectList[i] then
			self._selectList[i]:setVisible(false)
		end
	end
	if self._selectList[index] then
		self._selectList[index]:setVisible(true)
	end

	if index == 1 then
		if self._curPage == self._selectIndex then
			return
		end
		self._curPage = self._selectIndex
	else
		if self._curPage >= self._selectIndex + 1 then
			return
		end
		self._curPage = self._selectIndex + 1
	end
	
	self._curPageLable:setString(self._curPage.." / "..self._MaxPage)
	self._closeTimeLable = {} 
	self._talbeView:reloadData()
end

function Xianshiqianggou:initUI()
	local title = cc.Sprite:create("res/image/activities/Bingfenfuli/xianshiqianggou/title.png")
	self:addChild(title)
	title:setPosition(self:getContentSize().width *0.5 - 4,self:getContentSize().height - title:getContentSize().height *0.5 - 5)
	
	local btn_name = {"btn_nowcommodity","btn_futurecommodity"}
	for i = 1, #btn_name do
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/activities/Bingfenfuli/xianshiqianggou/".. btn_name[i] .. "_up.png",
			selectedFile = "res/image/activities/Bingfenfuli/xianshiqianggou/".. btn_name[i] .."_down.png",
		})
		title:addChild(btn)
		btn:setPosition(10 + btn:getContentSize().width * 0.5 + (i-1)* (btn:getContentSize().width + 10), btn:getContentSize().height * 0.5 + 5)
		btn:setTouchEndedCallback(function()
			self:ClickCeilbtn(i)
		end)
		local sp = cc.Sprite:create("res/image/activities/Bingfenfuli/xianshiqianggou/".. btn_name[i] .."_down.png")
		btn:addChild(sp)
		sp:setPosition(btn:getContentSize().width*0.5,btn:getContentSize().height*0.5)
		self._selectList[#self._selectList + 1] = sp
		if i ~= 1 then
			sp:setVisible(false)
		end
	end

	self._talbeView = CCTableView:create(cc.size(532, 275))
	self._talbeView:setPosition(0,52)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self._talbeView)

    local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,74
    end
	
	local _tableList = {}
    local function numberOfCellsInTableView(table)
		if self._curPage == self._selectIndex then
			_tableList = self._curCommodity
		else
			_tableList = self._futureCommodity[self._curPage]
		end
		return #_tableList
    end

    local function tableCellTouched(table,cell)
    end
	
    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
			
            cell = cc.TableViewCell:new()
			cell:setContentSize(self._talbeView:getContentSize().width,74)
			self._cellList[idx+1] = cell
        else
            cell:removeAllChildren()
        end
        local _index = idx + 1
		
		local cellbg = cc.Sprite:create("res/image/activities/Bingfenfuli/xianshiqianggou/cellbg.png")
		cell:addChild(cellbg)
		cellbg:setName("cellbg")
		
		cellbg:setPosition(cell:getContentSize().width*0.5,cell:getContentSize().height *0.5)

		local itemNode = nil
		if _tableList[_index].resourcetype ~= 4 then
			itemNode = ItemNode:createWithParams({
				_type_ = _tableList[_index].resourcetype,
				count = _tableList[_index].num,
				showDrropType = 2,
			})
		else
			itemNode = ItemNode:createWithParams({
				_type_ = _tableList[_index].resourcetype,
				itemId = _tableList[_index].resourceid,
				count = _tableList[_index].num,
				showDrropType = 2,
			})
		end
		itemNode:setScale(0.6)
		cellbg:addChild(itemNode)
		itemNode:setPosition(itemNode:getContentSize().width*0.5,cellbg:getContentSize().height *0.5)

		local zhekou = nil
		if self._curPage > self._selectIndex then	
			zhekou = cc.Sprite:create("res/image/activities/Bingfenfuli/xianshiqianggou/zhekou_0.png")
		else
			zhekou = cc.Sprite:create("res/image/activities/Bingfenfuli/xianshiqianggou/zhekou_".._tableList[_index].dazhe * 10 .. ".png")
		end	
		itemNode:addChild(zhekou)
		zhekou:setScale(0.6)
		zhekou:setPosition(itemNode:getContentSize().width*0.5 - 18,itemNode:getContentSize().height*0.5 + 20)

		if self._curPage == self._selectIndex then
			self:SelectCurPage(_tableList[_index],cellbg,itemNode,_index,cell)
		else
			self:SelectOtherPage(_tableList[_index],cellbg,itemNode,_index)
		end
		
        return cell
    end
    self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._talbeView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._talbeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
	self._talbeView:reloadData()

	local btn_pageNext = XTHDPushButton:createWithParams({
		normalFile = "res/image/activities/Bingfenfuli/xianshiqianggou/btn_next.png",
		selectedFile = "res/image/activities/Bingfenfuli/xianshiqianggou/btn_next.png",
		needEnableWhenMoving = true
	})
	self:addChild(btn_pageNext)
	btn_pageNext:setPosition(self:getContentSize().width *0.6 + btn_pageNext:getContentSize().width,btn_pageNext:getContentSize().height - 3)

	btn_pageNext:setTouchBeganCallback(function()
		btn_pageNext:setScale(0.95)
	end)
	
	btn_pageNext:setTouchMovedCallback(function()
		btn_pageNext:setScale(1)
	end)	

	btn_pageNext:setTouchEndedCallback(function()
		btn_pageNext:setScale(1)
		self:ClickPageBtn(1)
	end)	

	self._curPageLable = XTHDLabel:create(self._curPage.." / "..self._MaxPage,18,"res/fonts/def.ttf")
	self:addChild(self._curPageLable)
	self._curPageLable:setPosition(self:getContentSize().width *0.5,btn_pageNext:getPositionY())

	local btn_pageLast = XTHDPushButton:createWithParams({
		normalFile = "res/image/activities/Bingfenfuli/xianshiqianggou/btn_last.png",
		selectedFile = "res/image/activities/Bingfenfuli/xianshiqianggou/btn_last.png",
		needEnableWhenMoving = true
	})
	self:addChild(btn_pageLast)
	btn_pageLast:setPosition(self:getContentSize().width *0.4 - btn_pageNext:getContentSize().width,btn_pageNext:getContentSize().height - 3)
	
	btn_pageLast:setTouchBeganCallback(function()
		btn_pageLast:setScale(0.95)
	end)
	
	btn_pageLast:setTouchMovedCallback(function()
		btn_pageLast:setScale(1)
	end)	

	btn_pageLast:setTouchEndedCallback(function()
		btn_pageLast:setScale(1)
		self:ClickPageBtn(-1)
	end)	

end

function Xianshiqianggou:SelectCurPage(_tableList,cellbg,itemNode,_index,cell)
	local itemName = XTHDLabel:create(_tableList.itemname,14,"res/fonts/def.ttf")
	itemName:setAnchorPoint(0,0.5)
	itemName:setColor(cc.c3b(0,0,0))
	cellbg:addChild(itemName)
	itemName:setPosition(itemNode:getPositionX() + itemNode:getContentSize().width *0.5 - 5,cellbg:getContentSize().height - itemName:getContentSize().height - 5)

	local shengyushijian = XTHDLabel:create("剩余时间:" .. LANGUAGE_KEY_CARNIVALDAY(self._closeTime), 14, "res/fonts/def.ttf")
	shengyushijian:setAnchorPoint(0, 0.5)
	shengyushijian:setColor(cc.c3b(0, 0, 0))
	cell:addChild(shengyushijian)
	shengyushijian:setPosition(itemName:getPositionX(), itemNode:getPositionY() - shengyushijian:getContentSize().height)
	shengyushijian:setName("Timer")

	-- 原价
	local yuanjia = XTHDLabel:create("原价：", 14, "res/fonts/def.ttf")
	yuanjia:setAnchorPoint(0, 0.5)
	yuanjia:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(yuanjia)
	yuanjia:setPosition(cellbg:getContentSize().width * 0.5 + 5, cellbg:getContentSize().height - itemName:getContentSize().height - 5)

	local exitem = cc.Sprite:create("res/image/common/common_gold.png")
	cellbg:addChild(exitem)
	exitem:setScale(0.65)
	exitem:setPosition(yuanjia:getContentSize().width + yuanjia:getPositionX() + 5, yuanjia:getPositionY())

	local needNum = XTHDLabel:create(_tableList.ingotprice, 14, "res/fonts/def.ttf")
	needNum:setAnchorPoint(0, 0.5)
	needNum:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(needNum)
	needNum:setPosition(exitem:getPositionX() + exitem:getContentSize().width * 0.5, yuanjia:getPositionY())

	local hengxian = XTHDLabel:create("———————", 14, "res/fonts/def.ttf")
	hengxian:setAnchorPoint(0, 0.5)
	hengxian:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(hengxian)
	hengxian:setPosition(yuanjia:getPositionX(), yuanjia:getPositionY())

	-- 现价
	local xianjia = XTHDLabel:create("现价：", 14, "res/fonts/def.ttf")
	xianjia:setAnchorPoint(0, 0.5)
	xianjia:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(xianjia)
	xianjia:setPosition(yuanjia:getPositionX(), shengyushijian:getPositionY())

	local exitem = cc.Sprite:create("res/image/common/common_gold.png")
	cellbg:addChild(exitem)
	exitem:setScale(0.65)
	exitem:setPosition(xianjia:getContentSize().width + xianjia:getPositionX() + 5, xianjia:getPositionY())

	local needNum = XTHDLabel:create(_tableList.ingotprice2, 14, "res/fonts/def.ttf")
	needNum:setAnchorPoint(0, 0.5)
	needNum:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(needNum)
	needNum:setPosition(exitem:getPositionX() + exitem:getContentSize().width * 0.5, xianjia:getPositionY())

	local goumaicout = XTHDLabel:create("购买次数：" .. self._data.list[_index].selfSurplusCount .. "/" .. _tableList.dailynum, 14, "res/fonts/def.ttf")
	goumaicout:setAnchorPoint(0, 0.5)
	goumaicout:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(goumaicout)
	goumaicout:setPosition(cellbg:getContentSize().width - 120, yuanjia:getPositionY())

	if self._data.list[_index].selfSurplusCount <= 0 then
		local yigoumai = cc.Sprite:create("res/image/activities/Bingfenfuli/xianshiqianggou/yigoumai.png")
		cellbg:addChild(yigoumai)
		yigoumai:setAnchorPoint(0, 0.5)
		yigoumai:setPosition(cellbg:getContentSize().width - yigoumai:getContentSize().width - 30, yigoumai:getContentSize().height * 0.5 + 5)
	else
		local btn = XTHDPushButton:createWithParams( {
			normalFile = "res/image/activities/Bingfenfuli/xianshiqianggou/btn_buy_up.png",
			selectedFile = "res/image/activities/Bingfenfuli/xianshiqianggou/btn_buy_down.png",
			needEnableWhenMoving = true
		} )
		btn:setSwallowTouches(false)
		cellbg:addChild(btn)
		btn:setAnchorPoint(0, 0.5)
		btn:setPosition(cellbg:getContentSize().width - btn:getContentSize().width - 30, btn:getContentSize().height * 0.5 + 2)
		btn:setTouchEndedCallback( function()
			self:BuyItem(_index)
		end )
	end

end

function Xianshiqianggou:SelectOtherPage(_tableList,cellbg,itemNode,_index)
	local itemName = XTHDLabel:create(_tableList.itemname,14,"res/fonts/def.ttf")
	itemName:setAnchorPoint(0,0.5)
	itemName:setColor(cc.c3b(0,0,0))
	cellbg:addChild(itemName)
	itemName:setPosition(itemNode:getPositionX() + itemNode:getContentSize().width *0.5 - 5,cellbg:getContentSize().height - itemName:getContentSize().height - 5)

	local text = nil

	if self._curPage < self._selectIndex then
		text = "活动已结束"
	elseif self._curPage > self._selectIndex then
		text = "再登录"..self._curPage - self._selectIndex.."天后开启"
	end	

	local shengyushijian = XTHDLabel:create(text, 14, "res/fonts/def.ttf")
	shengyushijian:setAnchorPoint(0, 0.5)
	shengyushijian:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(shengyushijian)
	shengyushijian:setPosition(itemName:getPositionX(), itemNode:getPositionY() - shengyushijian:getContentSize().height)

	-- 原价
	local yuanjia = XTHDLabel:create("原价：", 14, "res/fonts/def.ttf")
	yuanjia:setAnchorPoint(0, 0.5)
	yuanjia:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(yuanjia)
	yuanjia:setPosition(cellbg:getContentSize().width * 0.5 + 5, cellbg:getContentSize().height - itemName:getContentSize().height - 5)

	local exitem = cc.Sprite:create("res/image/common/common_gold.png")
	cellbg:addChild(exitem)
	exitem:setScale(0.65)
	exitem:setPosition(yuanjia:getContentSize().width + yuanjia:getPositionX() + 5, yuanjia:getPositionY())

	local needNum = XTHDLabel:create(_tableList.ingotprice, 14, "res/fonts/def.ttf")
	needNum:setAnchorPoint(0, 0.5)
	needNum:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(needNum)
	needNum:setPosition(exitem:getPositionX() + exitem:getContentSize().width * 0.5, yuanjia:getPositionY())

	local hengxian = XTHDLabel:create("———————", 14, "res/fonts/def.ttf")
	hengxian:setAnchorPoint(0, 0.5)
	hengxian:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(hengxian)
	hengxian:setPosition(yuanjia:getPositionX(), yuanjia:getPositionY())

	-- 现价
	local xianjia = XTHDLabel:create("现价：", 14, "res/fonts/def.ttf")
	xianjia:setAnchorPoint(0, 0.5)
	xianjia:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(xianjia)
	xianjia:setPosition(yuanjia:getPositionX(), shengyushijian:getPositionY())

	local exitem = cc.Sprite:create("res/image/common/common_gold.png")
	cellbg:addChild(exitem)
	exitem:setScale(0.65)
	exitem:setPosition(xianjia:getContentSize().width + xianjia:getPositionX() + 5, xianjia:getPositionY())

	if self._curPage < self._selectIndex then
		text = tostring(_tableList.ingotprice2)
	elseif self._curPage > self._selectIndex then
		text = "???"
	end	 
	local needNum = XTHDLabel:create(text, 14, "res/fonts/def.ttf")
	needNum:setAnchorPoint(0, 0.5)
	needNum:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(needNum)
	needNum:setPosition(exitem:getPositionX() + exitem:getContentSize().width * 0.5, xianjia:getPositionY())
	
	local goumaicout = XTHDLabel:create("购买次数：" ..tostring(0) .."/???", 14, "res/fonts/def.ttf")
	goumaicout:setAnchorPoint(0, 0.5)
	goumaicout:setColor(cc.c3b(0, 0, 0))
	cellbg:addChild(goumaicout)
	goumaicout:setPosition(cellbg:getContentSize().width - 120, yuanjia:getPositionY())

	
		local btn = XTHDPushButton:createWithParams( {
			normalFile = "res/image/activities/Bingfenfuli/xianshiqianggou/btn_buy_up.png",
			selectedFile = "res/image/activities/Bingfenfuli/xianshiqianggou/btn_buy_down.png",
			needEnableWhenMoving = true
		} )
		btn:setSwallowTouches(false)
		cellbg:addChild(btn)
		btn:setAnchorPoint(0, 0.5)
		btn:setPosition(cellbg:getContentSize().width - btn:getContentSize().width - 30, btn:getContentSize().height * 0.5 + 2)
		btn:setTouchEndedCallback( function()
			if self._curPage < self._selectIndex then
				XTHDTOAST("活动时间已过")
			elseif self._curPage > self._selectIndex then
				XTHDTOAST("活动暂未开启")
			end	 
		end )
end


function Xianshiqianggou:ClickPageBtn(index)
	self._curPage = self._curPage + index
	if self._curPage <= 0 then
		self._curPage = self._MaxPage
	end
	if self._curPage > self._MaxPage then
		self._curPage = 1
	end

	if self._curPage == self._selectIndex then
		self._selectList[1]:setVisible(true)
		self._selectList[2]:setVisible(false)
	else
		self._selectList[1]:setVisible(false)
		self._selectList[2]:setVisible(true)
	end

	self._curPageLable:setString(self._curPage.." / "..self._MaxPage)
	self._closeTimeLable = {} 
	self._talbeView:reloadData()
end

function Xianshiqianggou:selectedTable(index)
	for i = 1,#self._btnList do
		if self._btnList[i]:getChildByName("selectedBg") then
			self._btnList[i]:getChildByName("selectedBg"):setVisible(false)
		end
	end
	if self._btnList[index]:getChildByName("selectedBg") then
		self._btnList[index]:getChildByName("selectedBg"):setVisible(true)
	end

	self._curPage = index
	self:freshData()
	self._talbeView:reloadData()
end

function Xianshiqianggou:BuyItem(index)
	local _configid = self._curCommodity[index].id
		ClientHttp:requestAsyncInGameWithParams({
			modules = "buyOpenServerDiscountItem?",
			params = { configId  = _configid },
			successCallback = function( data )
				if data.result == 0 then
--					dump(data,"111")
					if data.bagItems then
						local show_data = {}
						for i = 1 ,#data.bagItems do
							local _data = data.bagItems[i]
							local num_2 = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _data.itemId}).count or 0
							local num = _data.count - num_2
							show_data[#show_data+1] = {rewardtype = 4,id =_data.itemId,num = num}
							DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
						end
						ShowRewardNode:create(show_data)
					end
					for i = 1, #data.property do
						local _data = string.split(data.property[i],",")
						gameUser.updateDataById(_data[1],_data[2])
					end
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
					self._data.list[index].selfSurplusCount = data.selfSurplusCount
					self:freshData()
					self._talbeView:reloadData()
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

function Xianshiqianggou:updateTime()
	schedule(self, function(dt)
		self._closeTime = self._closeTime - 1
		for i = 1,#self._cellList do
            local label=self._cellList[i]:getChildByName("Timer")
			if label then
				label:setString("剩余时间:" .. LANGUAGE_KEY_CARNIVALDAY(self._closeTime))
			end
		end
  	end,1,10)
end


function Xianshiqianggou:create(parent,data)
	return Xianshiqianggou.new(parent,data)
end

return Xianshiqianggou