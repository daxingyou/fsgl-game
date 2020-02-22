--Created By Liuluyang 2015年06月13日
local Shouchongtuangou = class("Shouchongtuangou",function ()
	local layer = XTHD.createSprite()
	layer:setContentSize( 539, 399 )
	return layer
end)

function Shouchongtuangou:onEnter()
end

function Shouchongtuangou:onCleanup()
	self._exist = false
end

function Shouchongtuangou:ctor(parent,data)
--	dump(data)
	self._exist = true
	self._parent = parent
	self._data = data
	self._listData = {}
	self._dataList = data.list
	self._curPage = 1
	self._buyLableList = {}
	self._CurdateList = {}	
	self._btnList = {}
	self._redPointList = {}
	self:freshData()
	self:initUI()
	self:freshRedPoint()
	self:selectedTable(self._curPage)
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG,callback = function()
		if self._exist then
        	self:updateTableViewCell()
        end
    end})
end

function Shouchongtuangou:updateTableViewCell()
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

function Shouchongtuangou:freshData()
	self._CurdateList = {}
	local list = gameData.getDataFromCSV("FristGroupPurchase")
	for i = 1, #list do
		if list[i].taskid == self._dataList[i].configId then
			list[i].state = self._dataList[i].state
		end
	end

	for k,v in pairs(list) do
		if v.page == self._curPage then
			self._CurdateList[#self._CurdateList + 1] = v
		end
	end
	self._CurdateList = self:SortList(self._CurdateList)
end

function Shouchongtuangou:freshRedPoint()
	local list = gameData.getDataFromCSV("FristGroupPurchase")
	for i = 1, #list do
		if list[i].taskid == self._dataList[i].configId then
			list[i].state = self._dataList[i].state
		end
	end

	for k,v in pairs(list) do
		if v.page == 1 then
			if v.state == 1 then
				self._redPointList[v.page]:setVisible(true)
				break
			else
				self._redPointList[v.page]:setVisible(false)
			end
		end
	end

	for k,v in pairs(list) do
		if v.page == 2 then
			if v.state == 1 then
				self._redPointList[v.page]:setVisible(true)
				break
			else
				self._redPointList[v.page]:setVisible(false)
			end
		end
	end

	for k,v in pairs(list) do
		if v.page == 3 then
			if v.state == 1 then
				self._redPointList[v.page]:setVisible(true)
				break
			else
				self._redPointList[v.page]:setVisible(false)
			end
		end
	end

end

function Shouchongtuangou:initUI()
	local title = cc.Sprite:create("res/image/activities/Bingfenfuli/shouchongtuangou/title.png")
	self:addChild(title)
	title:setPosition(self:getContentSize().width *0.5 - 4,self:getContentSize().height - title:getContentSize().height *0.5 - 4)

	local btnNameList = {"btn_tuangou_20_","btn_tuangou_50_","btn_tuangou_70_"}
	for i = 1, 3 do
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/activities/Bingfenfuli/shouchongtuangou/"..btnNameList[i].."up.png",
			selectedFile = "res/image/activities/Bingfenfuli/shouchongtuangou/"..btnNameList[i].."down.png"
		})
		title:addChild(btn)
		btn:setPosition(10 + btn:getContentSize().width *0.5 + (i -1) *(btn:getContentSize().width + 5), btn:getContentSize().height*0.5)
		btn:setTouchEndedCallback(function()
			self:selectedTable(i)
		end)
		self._btnList[#self._btnList + 1] =  btn
	
		local _redPointSp = cc.Sprite:create("res/image/common/heroList_redPoint.png")
		_redPointSp:setScale(0.5)
		_redPointSp:setAnchorPoint(cc.p(1,1))
		_redPointSp:setPosition(cc.p(btn:getContentSize().width,btn:getContentSize().height))
		btn:addChild(_redPointSp,1)
		_redPointSp:setVisible(false)
		self._redPointList[#self._redPointList + 1] = _redPointSp
	end

	local chongzhi = XTHDPushButton:createWithParams({
			normalFile = "res/image/activities/Bingfenfuli/shouchongtuangou/btn_chongzhi_up.png",
			selectedFile = "res/image/activities/Bingfenfuli/shouchongtuangou/btn_chongzhi_down.png",
	})
	title:addChild(chongzhi)
	chongzhi:setPosition(title:getContentSize().width - chongzhi:getContentSize().width*0.5,title:getContentSize().height *0.5)
	chongzhi:setTouchEndedCallback(function()
		XTHD.createRechargeVipLayer(self,nil,nil,true)
	end)

	self._talbeView = CCTableView:create(cc.size(532, 263))
	self._talbeView:setPosition(0,2)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self._talbeView)

    local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,90
    end
    local function numberOfCellsInTableView(table)
        return #self._CurdateList
    end
    local function tableCellTouched(table,cell)
    end
    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
			print("============",idx)
            cell = cc.TableViewCell:new()
			cell:setContentSize(self._talbeView:getContentSize().width,90)
        else
            cell:removeAllChildren()
        end
        local _index = idx + 1
		local cellbg = cc.Sprite:create("res/image/activities/Bingfenfuli/shouchongtuangou/cellbg.png")
		cell:addChild(cellbg)
		cellbg:setPosition(cell:getContentSize().width*0.5,cell:getContentSize().height *0.5)

		local cellbg2 = cc.Sprite:create("res/image/activities/Bingfenfuli/shouchongtuangou/cellbg2.png")
		cellbg2:setContentSize(cellbg2:getContentSize().width + 130,cellbg2:getContentSize().height)
		cellbg:addChild(cellbg2)
		cellbg2:setAnchorPoint(0,0.5)
		cellbg2:setPosition(0,cellbg:getContentSize().height - cellbg2:getContentSize().height *0.5)

		local taskname = XTHDLabel:create(self._CurdateList[_index].taskname.."：",13,"res/fonts/def.ttf")
		taskname:setColor(cc.c3b(255,255,150))
		taskname:setAnchorPoint(0,0.5)
		cellbg2:addChild(taskname)
		taskname:setPosition(5,cellbg2:getContentSize().height *0.5)
		
		local text = nil
		if self._CurdateList[_index].taskparam2 and tonumber(self._CurdateList[_index].taskparam2) > 0 then
			text = "全服首充人数达到"..tostring(self._CurdateList[_index].taskparam1).." [".. tostring(self._data.curServerSum) .."/"..tostring(self._CurdateList[_index].taskparam1).."]"
					..",且个人充值达到".. tostring(self._CurdateList[_index].taskparam2).." [" ..tostring(self._data.curPersonalSum).."]"
		else
			text = "全服首充人数达到"..tostring(self._CurdateList[_index].taskparam1).." ["..tostring(self._data.curServerSum).."]"
		end
		local description = XTHDLabel:create(text,13,"res/fonts/def.ttf")
		description:setColor(cc.c3b(255,255,150))
		description:setAnchorPoint(0,0.5)
		cellbg2:addChild(description)
		description:setPosition(taskname:getPositionX() + taskname:getContentSize().width - 5,cellbg2:getContentSize().height *0.5)

		local jiangliList = {}
		for i = 1, 4 do
			if self._CurdateList[_index]["reward".. tostring(i) .. "type"] then
				if self._CurdateList[_index]["reward".. tostring(i) .. "type"] ~= 4 then
					local data = string.split(self._CurdateList[_index]["reward"..tostring(i).."param"],"#")
					local itemnode = ItemNode:createWithParams({
						_type_ = self._CurdateList[_index]["reward".. tostring(i) .. "type"],
						count = data[2],
						showDrropType = 2,
					})
					jiangliList[#jiangliList + 1] = itemnode
				else
					local data = string.split(self._CurdateList[_index]["reward"..tostring(i).."param"],"#")
					local itemnode = ItemNode:createWithParams({
						itemId =  data[1],
						_type_ = 4,
						count = data[2],
						showDrropType = 2,
					})
					jiangliList[#jiangliList + 1] = itemnode
				end
			end
		end

		for i = 1,#jiangliList do
			jiangliList[i]:setScale(0.5)
			jiangliList[i]:setPosition(jiangliList[i]:getContentSize().width *0.5 + (i-1) *jiangliList[i]:getContentSize().width *0.6,cellbg:getContentSize().height *0.5 - 12)
			cellbg:addChild(jiangliList[i])
		end

		if self._CurdateList[_index].state == 0 then
			local weidacheng = cc.Sprite:create("res/image/activities/Bingfenfuli/shouchongtuangou/weidacheng.png")
			cellbg:addChild(weidacheng)
			weidacheng:setPosition(cellbg:getContentSize().width - weidacheng:getContentSize().width *0.5 - 20,cellbg:getContentSize().height*0.5 - 10)
		elseif self._CurdateList[_index].state == 1 then
			local btn_lingqu = XTHDPushButton:createWithParams({
				normalFile = "res/image/activities/Bingfenfuli/shouchongtuangou/lingqu_up.png",
				selectedFile = "res/image/activities/Bingfenfuli/shouchongtuangou/lingqu_down.png",
				isScrollView = true,
			})
			cellbg:addChild(btn_lingqu)
			btn_lingqu:setPosition(cellbg:getContentSize().width - btn_lingqu:getContentSize().width *0.5 - 20,cellbg:getContentSize().height*0.5 - 10)
			btn_lingqu:setTouchEndedCallback(function()
				self:Lingqujiangli(_index)
			end)
			local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
			btn_lingqu:addChild(fetchSpine)
			fetchSpine:setScaleX(0.6)
			fetchSpine:setScaleY(0.6)
			fetchSpine:setPosition(btn_lingqu:getBoundingBox().width*0.5 + 1, btn_lingqu:getContentSize().height*0.5+2)
		fetchSpine:setAnimation(0, "querenjinjie", true )
		else
			local yilingqu = XTHD.createSprite( "res/image/activities/huoyueyouli/yilingqu.png" )
			yilingqu:setScale(0.9)
			cellbg:addChild(yilingqu)
			yilingqu:setPosition(cellbg:getContentSize().width - yilingqu:getContentSize().width + 10,cellbg:getContentSize().height *0.5 - 8)
		end
		
        return cell
    end
    self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._talbeView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._talbeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
end

function Shouchongtuangou:selectedTable(index)
	for i = 1,#self._btnList do
		self._btnList[i]:setSelected(false)
	end
	self._btnList[index]:setSelected(true)

	self._curPage = index
	self:freshData()
	self._talbeView:reloadData()
end

function Shouchongtuangou:Lingqujiangli(index)
	local _configid = self._CurdateList[index].taskid
		ClientHttp:requestAsyncInGameWithParams({
			modules = "receiveFristGroupReward?",
			params = { configId  = _configid },
			successCallback = function( data )
				if data.result == 0 then
					dump(data,"111")
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
					for i = 1,#self._dataList do
						if self._dataList[i].configId == _configid then
							self._dataList[i].state = 2
						end
					end
					self:freshData()
					self._talbeView:reloadData()
					self:freshRedDot(self._dataList)
					self:freshRedPoint()
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

function Shouchongtuangou:SortList( _table )
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

function Shouchongtuangou:freshRedDot(data)
	if data then
		for k,v in pairs(data) do
			if v.state == 1 then
				RedPointState[20].state = 1
				break
			else
				RedPointState[20].state = 0
			end
		end
	end
	self._parent:freshRedDot(self._parent.selectedIndex)
end

function Shouchongtuangou:create(parent,data)
	return Shouchongtuangou.new(parent,data)
end

return Shouchongtuangou