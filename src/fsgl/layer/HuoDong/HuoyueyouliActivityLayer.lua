--Created By Liuluyang 2015年06月13日
local HuoyueyouliActivityLayer = class("HuoyueyouliActivityLayer",function ()
	return XTHD.createPopLayer()
end)

function HuoyueyouliActivityLayer:ctor(data,parent)
	self._parent = parent
	self._data = data --全局存储请求服务器的数据
	self._exist = true
	self._stateData = {}--存储从服务器返回回来的每一组数据
	self._btnList = {}--存储左边的按钮
	self._listData = gameData.getDataFromCSV("Positive")
	self._tableListdata = {} --存储从表中读取的每一组数据
	self._redData = data.list --用来刷新小红点的显示
	self._selectedIndex = 1 
	-- 添加监听事件
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_HUOYUEJIANGLI ,callback = function()
		if self._exist then
        	self:updateTableViewCell()
        end
    end})
	self:initUI()
end

function HuoyueyouliActivityLayer:onCleanup()
	self._exist = false
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_RECHARGE_HUOYUEJIANGLI)
end

function HuoyueyouliActivityLayer:initUI()	
	local bg = cc.Sprite:create("res/image/activities/huoyueyouli/bg_1.png")
	bg:setPosition(self:getContentSize().width*0.5,self:getContentSize().height*0.5)
	self:addContent(bg)
	self._bg = bg
	
	local curtain = cc.Sprite:create("res/image/activities/huoyueyouli/curtain.png")
	self._bg:addChild(curtain,11)
	curtain:setPosition(curtain:getContentSize().width *0.5 + 22, self._bg:getContentSize().height *0.5 - 13)
	
	local bg2 = cc.Sprite:create("res/image/activities/huoyueyouli/bg_4.png")
	self._bg:addChild(bg2)
	bg2:setPosition(bg2:getContentSize().width *0.5 + 230,self._bg:getContentSize().height - bg2:getContentSize().height - 32)

	local bg3 = cc.Sprite:create("res/image/activities/huoyueyouli/bg3.png")
	self._bg:addChild(bg3)
	bg3:setPosition(self._bg:getContentSize().width - bg3:getContentSize().width *0.5,self._bg:getContentSize().height - bg3:getContentSize().height *0.5)

	local listviewbg = cc.Sprite:create("res/image/activities/huoyueyouli/btnbg.png")
	self._bg:addChild(listviewbg)
	listviewbg:setPosition(listviewbg:getContentSize().width *0.5 + 74,listviewbg:getContentSize().height *0.5 + 29)
	
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

	local num = tonumber(self._listData[#self._listData].tagpart)

	for i = 1, num do
		local layout = ccui.Layout:create()
		layout:setContentSize(151,75)
		
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/activities/huoyueyouli/btn_".. i .. "_up.png",
			selectedFile = "res/image/activities/huoyueyouli/btn_".. i .."_down.png",
			isScrollView = true,
			needEnableWhenMoving = true,
			endCallback  = function()
				 self:selecteTableView(i)
			end,
		})
		btn:setSwallowTouches(false)
		layout:addChild(btn)
		btn:setPosition(layout:getContentSize().width*0.5,layout:getContentSize().height *0.5)
		self._btnList[#self._btnList + 1] = btn

		local selectedbg = cc.Sprite:create("res/image/activities/huoyueyouli/btn_" .. i .. "_down.png")
		btn:addChild(selectedbg)
		selectedbg:setPosition(btn:getContentSize().width *0.5,btn:getContentSize().height *0.5)
		selectedbg:setVisible(false)
		selectedbg:setName("selectedbg")

		local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
        btn:addChild(redDot)
        redDot:setPosition(btn:getContentSize().width - 10, btn:getBoundingBox().height - 10)
		redDot:setScale(0.6)
		redDot:setVisible(false)	
		redDot:setName("redDot")

		self._btn_listView:pushBackCustomItem(layout)
	end
	
	self._tableViewBg = cc.Sprite:create("res/image/activities/huoyueyouli/bg_2.png")
	self._bg:addChild(self._tableViewBg)
	self._tableViewBg:setPosition(445,self._bg:getContentSize().height *0.5 - 58)

	local btn_close = XTHDPushButton:createWithFile({
		normalFile = "res/image/activities/chaozhiduihuan/btn_close_up.png",
		selectedFile = "res/image/activities/chaozhiduihuan/btn_close_down.png",
		musicFile = XTHD.resource.music.effect_btn_commonclose,
		endCallback  = function()
           self:hide()
		end,
	})
	self._bg:addChild(btn_close)
	btn_close:setPosition(self._bg:getContentSize().width - btn_close:getContentSize().width * 0.5 + 12,self._bg:getContentSize().height - btn_close:getContentSize().height * 0.5 - 12)

	self:initTableView()
	self:selecteTableView(1)

end

function HuoyueyouliActivityLayer:initTableView()
	self._talbeView = CCTableView:create(self._tableViewBg:getContentSize())
	self._talbeView:setPosition(230,28)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._bg:addChild(self._talbeView)


    local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,80
    end
    local function numberOfCellsInTableView(table)
        return #self._tableListdata
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
		self:buildCell(cell,idx)

		return cell
	end
    self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._talbeView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._talbeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)

    self._talbeView:reloadData()

end

function HuoyueyouliActivityLayer:buildCell(cell,idx)
	local index = idx + 1
	local cellbg = cc.Sprite:create("res/image/activities/huoyueyouli/cellbg.png")
	cell:addChild(cellbg)
	cellbg:setContentSize(cell:getContentSize().width - 5,cell:getContentSize().height - 5)
	cellbg:setPosition(cell:getContentSize().width *0.5, cell:getContentSize().height *0.5)
	
	local data = self._tableListdata[index]
	local num = 0
	local jiangli = {}
	for i = 1 , 4 do
		if data["reward".. tostring(i) .."param"] ~= nil then
			num = num + 1
			local _data = string.split(data["reward".. tostring(i) .."param"],"#")
			local item = ItemNode:createWithParams({
				_type_ = data["reward" ..tostring(i).."type"],
				itemId = _data[1],
				count = _data[2],
				showDrropType = 2,
			})
			cellbg:addChild(item)
			item:setScale(0.6)
			item:setPosition(item:getContentSize().width*0.5 + (num-1)*item:getContentSize().width,cellbg:getContentSize().height *0.5)
			jiangli[#jiangli +1] = item
		end
	end
	
	local lable = XTHDLabel:create(data.description,"16","res/fonts/def.ttf")
	cellbg:addChild(lable)
	lable:setAnchorPoint(0,0.5)
	lable:setColor(cc.c3b(81,46,14))
	-- lable:enableOutline(cc.c4b(182,152,110),1)
	lable:setPosition( jiangli[#jiangli]:getContentSize().width*0.5 + jiangli[#jiangli]:getPositionX(),cellbg:getContentSize().height *0.5 + 6 )

	local line = cc.Sprite:create("res/image/activities/huoyueyouli/cellline.png")
	line:setAnchorPoint(0,0.5)
	cellbg:addChild(line)
	line:setPosition(lable:getPositionX() - 18,lable:getPositionY() - lable:getContentSize().height * 0.5 - 5)
	
	local progressLable = XTHDLabel:create(tostring(self._stateData[index].curNum) .. " / " .. self._stateData[index].maxNum,16,"res/fonts/def.ttf")
	progressLable:setAnchorPoint(0,0.5)
	progressLable:setColor(cc.c3b(81,46,14))
	progressLable:setPosition(cellbg:getContentSize().width - 95,cellbg:getContentSize().height *0.5 + 18)
	cellbg:addChild(progressLable)
	
	if self._stateData[index].state == -1 then
		local btn = XTHDPushButton:createWithFile({
			normalFile = "res/image/activities/huoyueyouli/btn_qianwang_up.png",
			selectedFile = "res/image/activities/huoyueyouli/btn_qianwang_down.png",
			isScrollView = true,
			endCallback = function ()
--				dump(self._tableListdata,"刷新")
				replaceLayer({id = self._tableListdata[1].gotype ,parent = self._parent})
			end
		})
		cellbg:addChild(btn)
		btn:setPosition(cellbg:getContentSize().width - btn:getContentSize().width *0.5 - 20,cellbg:getContentSize().height *0.5 -10)
	elseif  self._stateData[index].state == 1 then
		local btn = XTHDPushButton:createWithFile({
			normalFile = "res/image/activities/huoyueyouli/btn_lingqu_up.png",
			selectedFile = "res/image/activities/huoyueyouli/btn_lingqu_down.png",
			isScrollView = true,
			endCallback = function ()
				self:activeActivityReward(index)
			end
		})
		cellbg:addChild(btn)
		btn:setPosition(cellbg:getContentSize().width - btn:getContentSize().width *0.5 - 20,cellbg:getContentSize().height *0.5 -10)
		local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		btn:addChild(fetchSpine)
		fetchSpine:setScale(0.6)
		fetchSpine:setPosition(btn:getContentSize().width *0.5 + 2, btn:getContentSize().height*0.5)
		fetchSpine:setAnimation(0, "querenjinjie", true )
	else
		local yilingqu = XTHD.createSprite( "res/image/activities/huoyueyouli/yilingqu.png" )
		yilingqu:setScale(0.9)
		cellbg:addChild(yilingqu)
		yilingqu:setPosition(cellbg:getContentSize().width - yilingqu:getContentSize().width + 10,cellbg:getContentSize().height *0.5 - 8)
	end
end

function HuoyueyouliActivityLayer:activeActivityReward(index)
	ClientHttp:requestAsyncInGameWithParams({
        modules = "activeActivityReward?",
		params = { configId  = self._stateData[index].configId},
        successCallback = function( data )
			if data.result == 0 then
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
						XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
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
				self._data.list = data.list
				self._redData = data.list
				self:selecteTableView(self._selectedIndex)
			end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

function HuoyueyouliActivityLayer:updateTableViewCell()
	ClientHttp:requestAsyncInGameWithParams({
        modules = "activeActivityList?",
        successCallback = function( data )
			if data.result == 0 then
--				dump(data,"=============7777")
				self._redData = data.list
				self._data.list = self:SortList(data.list)
				self:selecteTableView(self._selectedIndex)
				self:updateRedPoint()
			end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

function HuoyueyouliActivityLayer:selecteTableView(index)
	self._tableListdata = {}
	self._stateData = {}
	for i = 1, #self._btnList do
		if self._btnList[i]:getChildByName("selectedbg") then
			self._btnList[i]:getChildByName("selectedbg"):setVisible(false)
		end
	end
	self._btnList[index]:getChildByName("selectedbg"):setVisible(true)

	for k , v in pairs(self._listData) do
		if v.tagpart == index then
			self._tableListdata[#self._tableListdata +1] = v
		end
	end

	for k, v in pairs(self._tableListdata) do
		for i = 1,#self._data.list do
			if v.id == self._data.list[i].configId then
				self._stateData[#self._stateData + 1] = self._data.list[i]
			end
		end
	end
	
	for i = 1,#self._stateData do
		self._tableListdata[i].state = self._stateData[i].state
	end
	
	self._tableListdata = self:SortList(self._tableListdata)
	self._stateData = self:SortList(self._stateData)
	self._selectedIndex = index
	self:updateRedPoint()
	self._talbeView:reloadData()
end

function HuoyueyouliActivityLayer:SortList( _table )
	local list_1,list_2,list_3 = {},{},{}
	for k,v in pairs(_table) do
		if v.state == -1 then
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

function HuoyueyouliActivityLayer:updateRedPoint()
	local list_2 = {}
	for i = 1, #self._listData do
		self._listData[i].state = self._redData[i].state
	end
	
	local maxNum = self._listData[#self._listData].tagpart
	for i = 1, maxNum do
		local list = {}
		for j = 1,#self._listData do
			if i == self._listData[j].tagpart then
				list[#list +1] = self._listData[j]
			end
		end
		list_2[#list_2 + 1] = list
	end

	for i = 1, #list_2 do
		for j = 1, #list_2[i] do
			if list_2[i][j].state == 1 then
				self._btnList[list_2[i][j].tagpart]:getChildByName("redDot"):setVisible(true)
				break
			else
				self._btnList[list_2[i][j].tagpart]:getChildByName("redDot"):setVisible(false)
			end
		end
	end
	
	RedPointState[5].state = 0
	for i = 1, #list_2 do
		for j = 1, #list_2[i] do
			if list_2[i][j].state == 1 then
				RedPointState[5].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "hyyl"}})
				return
			end
		end
	end
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "hyyl"}})
end

function HuoyueyouliActivityLayer:create(data,parent)
	return HuoyueyouliActivityLayer.new(data,parent)
end

return HuoyueyouliActivityLayer