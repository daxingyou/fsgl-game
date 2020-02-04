--[[
	节日兑换
    20190611
]]
local JieriduihuanLayer = class("JieriduihuanLayer", function(params)
	local layer = XTHD.createSprite()
	layer:setContentSize( 640, 428 )
	return layer
end)

function JieriduihuanLayer:ctor(params,data)
	self._exist = true
	self._ListData = {}
	self._severListData = params.list

	self._size = self:getContentSize()
    self.parentLayer = params.parentLayer
    self.httpData = params.httpData
	self._anctivityid =  params.anctivityid
	-- 添加监听事件
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG ,callback = function()
		if self._exist then
        	self:refreshData()
        end
    end})
	
	local list = gameData.getDataFromCSV("HolidayExchange" )
	for k,v in pairs(list) do
		if v.type == tonumber(self._anctivityid) then
			self._ListData[#self._ListData + 1] = v
		end
	end

	self._severListData = params.data.configList
	for i = 1,#self._ListData do
		self._ListData[i].curCount =  self._severListData[i].count
	end
	for i = 1,#self._ListData do
		self._ListData[i].stata =  1
	end
	self._ListData = self:SortList(self._ListData)
	self._severListData = self:SortList(self._severListData)
	self:initUI()
	--self:getAnctivityStata()
	--self:initUI()
	
end

-- 创建界面
function JieriduihuanLayer:initUI()
	-- 标题背景
	local titleBg = XTHD.createSprite( "res/image/activities/newyear/titlebg.png" )
	titleBg:setPosition( self._size.width*0.5+22, self._size.height - titleBg:getContentSize().height*0.5 +4)
	titleBg:setPosition( self._size.width*0.5+27, self._size.height - titleBg:getContentSize().height*0.5 - 5)
	titleBg:setScaleY(1.1)
	titleBg:setScaleX(1)
	self:addChild( titleBg )

	local titleLable = cc.Sprite:create("res/image/activities/newyear/jieriduihuan.png")
	titleBg:addChild(titleLable)
--	titleLable:setScale(0.8)
	titleLable:setPosition(titleLable:getContentSize().width - 120,titleBg:getContentSize().height *0.5 + 5)


--	-- 活动时间
--	local titleTime = XTHD.createLabel({
--		text     = LANGUAGE_PRAYER_DAYS(self._openTime.beginMonth,self._openTime.beginDay,self._openTime.endMonth,self._openTime.endDay),
--		fontSize = 18,
--		color    = cc.c3b( 255, 252, 0 ),
--		anchor   = cc.p( 0, 0 ),
--		pos      = cc.p( 15, 7 ),
--	})
--	titleBg:addChild( titleTime )
--	self._titleTime = titleTime
	-- tableview
	local tableView = CCTableView:create( cc.size( self._size.width, self._size.height - titleBg:getContentSize().height - 30 ) )
	tableView:setPosition( 30, 8)
	tableView:setBounceable( true )
	tableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	tableView:setDelegate()
	tableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	self:addChild( tableView )
	self._tableView = tableView

	local cellWidth = self._size.width 
	local cellHeight = 120

	local function numberOfCellsInTableView( table )
		return #self._ListData
	end
	local function cellSizeForTable( table, index )
		return  cellWidth,cellHeight - 10
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
            cell:setContentSize(cellWidth,cellHeight - 10)
		else
			cell:removeAllChildren()
        end
		--cell:removeAllChildren()
		self:buildCell( cell, index, cellWidth, cellHeight )	
    	return cell
    end
	tableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    tableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    tableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    tableView:reloadData()
end

function JieriduihuanLayer:buildCell( cell, index, cellWidth, cellHeight )
	local _index = index + 1
    local bg2 = ccui.Scale9Sprite:create("res/image/activities/newyear/redpacket/cellbg_2.png" )
	bg2:setContentSize(cellWidth - 25,cellHeight - 20)
    bg2:setPosition( cellWidth*0.5-2, cellHeight*0.5 )
	cell:addChild( bg2 )

	local biaoti = XTHDLabel:create(self._ListData[_index].describe, 16,"res/fonts/def.ttf")
	cell:addChild(biaoti)
	biaoti:setColor(XTHD.resource.textColor.green_text)
	biaoti:setAnchorPoint(cc.p(0,0.5))
	biaoti:setPosition(20,bg2:getContentSize().height - biaoti:getContentSize().height / 2)
		
	local JiangLi = {}
	
	local needItem = {}
    --local getNum = allGem.
	for i = 1, 4 do
		if self._ListData[_index]["exchangenum"..i] ~= nil and  self._ListData[_index]["exchangenum"..i] ~= 0 then
            local _itemId =  self._ListData[_index]["exchangeid"..i]
            local num = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _itemId}).count
            if num == nil then
                num = 0
            end
			local item = ItemNode:createWithParams({
				itemId =  self._ListData[_index]["exchangeid"..i],
				_type_ = 4,
				count = num.. "/"..self._ListData[_index]["exchangenum"..i]
			})
			needItem[#needItem + 1] = item
			if num < self._ListData[_index]["exchangenum"..i] then
				self._ListData[_index].stata = -1
			end
		end
	end

	--res/image/plugin/hero/addMaterialNumber.png
    for i = 1,#needItem do
        bg2:addChild(needItem[i])
        needItem[i]:setScale(0.6)
        needItem[i]:setPosition( -5 + needItem[i]:getContentSize().width / 2 +(i-1)* needItem[i]:getContentSize().width * 1,
                                bg2:getContentSize().height * 0.5-2)
    end

    for i = 1,#needItem do
        if i <= #needItem - 1 then
            local JiaHao = cc.Sprite:create("res/image/activities/newyear/jia.png")
			JiaHao:setScale(0.7)
            bg2:addChild(JiaHao)
            JiaHao:setPosition(needItem[i]:getPositionX()+needItem[i]:getContentSize().width *0.5,
                                bg2:getContentSize().height/2)
		else
			local JiaHao = cc.Sprite:create("res/image/activities/newyear/dengyu.png")
			JiaHao:setScale(0.7)
            bg2:addChild(JiaHao)
            JiaHao:setPosition(needItem[i]:getPositionX()+needItem[i]:getContentSize().width *0.5,
                                bg2:getContentSize().height/2)
        end
    end
    
    local getItem = ItemNode:createWithParams({
		itemId =  self._ListData[_index]["itemid"],
		_type_ = 4,
		count = self._ListData[_index]["num"]
	})
    bg2:addChild(getItem)
    getItem:setScale(0.6)
    getItem:setPosition(needItem[#needItem]:getPositionX() + getItem:getContentSize().width*1,
                        bg2:getContentSize().height *0.5 - 2)

   --兑换次数
    local num_1 = self._ListData[_index].curCount
    local num_2 = self._ListData[_index].dailynum
    local press = XTHDLabel:create("兑换次数："..tostring(num_1), 18,"res/fonts/def.ttf")
    press:setColor(cc.c3b(139,69,19))
    bg2:addChild(press)
    press:setPosition(bg2:getContentSize().width *0.88,bg2:getContentSize().height - press:getContentSize().height)

	--state
	local btn_duihuan
	if self._ListData[_index].curCount >= 1 and self._ListData[_index].stata == 1 then
		local normalnode = cc.Sprite:create("res/image/common/btn/btn_write_up.png")
		normalnode:setContentSize(cc.size(120,60))
		local selectednode = cc.Sprite:create("res/image/common/btn/btn_write_down.png")
		selectednode:setContentSize(cc.size(120,60))
		-- 兑换
		btn_duihuan = XTHD.createButton({
				normalNode = normalnode,
				selectedNode = selectednode,
				isScrollView = true,
				endCallback = function ()
					self:LingQuJiangLi(_index)
				end
			})
		btn_duihuan:setScale(0.8)
		cell:addChild(btn_duihuan)
		btn_duihuan:setPosition(bg2:getContentSize().width*0.9 - 2 ,bg2:getContentSize().height / 2)
		local btn_lable = XTHDLabel:create("兑 换", 18,"res/fonts/def.ttf")
		btn_lable:setColor(cc.c3b(255,255,255))
		btn_lable:enableOutline(cc.c4b(150, 79, 39, 255), 2)
		btn_duihuan:addChild(btn_lable)
		btn_lable:setPosition(btn_duihuan:getContentSize().width * 0.5,btn_duihuan:getContentSize().height * 0.5)
		
		local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		btn_duihuan:addChild(fetchSpine)
		fetchSpine:setScale(0.8)
		fetchSpine:setPosition(btn_duihuan:getBoundingBox().width*0.5 + 15, btn_duihuan:getContentSize().height*0.5+2)
		fetchSpine:setAnimation(0, "querenjinjie", true )	
		--btn_duihuan:setScale(0.5)
	elseif self._ListData[_index].curCount == 0 then
		local normalnode = cc.Sprite:create("res/image/common/btn/btn_write_up.png")
		normalnode:setContentSize(cc.size(120,60))
		local selectednode = cc.Sprite:create("res/image/common/btn/btn_write_down.png")
		normalnode:setContentSize(cc.size(120,60))
		-- 兌換按钮
		btn_duihuan = XTHD.createButton({
				normalNode = normalnode,
				selectedNode = selectednode,
				enable = false,
				isScrollView = true,
			})
		btn_duihuan:setScale(0.8)
		cell:addChild(btn_duihuan)
		btn_duihuan:setPosition(bg2:getContentSize().width*0.9 - 2,bg2:getContentSize().height / 2)
		local btn_lable = XTHDLabel:create("次数不足", 18,"res/fonts/def.ttf")
		btn_lable:setColor(cc.c3b(255,255,255))
		btn_lable:enableOutline(cc.c4b(103, 34, 13, 255), 2)
		btn_duihuan:addChild(btn_lable)
		btn_lable:setPosition(btn_duihuan:getContentSize().width * 0.5,btn_duihuan:getContentSize().height * 0.5)
	else
		local normalnode = cc.Sprite:create("res/image/common/btn/btn_write_up.png")
		normalnode:setContentSize(cc.size(120,60))
		local selectednode = cc.Sprite:create("res/image/common/btn/btn_write_down.png")
		normalnode:setContentSize(cc.size(120,60))
		-- 兌換按钮
		btn_duihuan = XTHD.createButton({
				normalNode = normalnode,
				selectedNode = selectednode,
				enable = false,
				isScrollView = true,
			})
		btn_duihuan:setScale(0.8)
		cell:addChild(btn_duihuan)
		btn_duihuan:setPosition(bg2:getContentSize().width*0.9 - 2,bg2:getContentSize().height / 2)
		local btn_lable = XTHDLabel:create("材料不足", 18,"res/fonts/def.ttf")
		btn_lable:setColor(cc.c3b(255,255,255))
		btn_lable:enableOutline(cc.c4b(103, 34, 13, 255), 2)
		btn_duihuan:addChild(btn_lable)
		btn_lable:setPosition(btn_duihuan:getContentSize().width * 0.5,btn_duihuan:getContentSize().height * 0.5)
	end

	return cell
end

function JieriduihuanLayer:LingQuJiangLi(index)
	ClientHttp:requestAsyncInGameWithParams({
        modules = "holidayActivateExchange?",
		params = { configId  = self._ListData[index].id },
        successCallback = function( data )
			if data.result == 0 then
--				dump(data)
				local show_data = {}
				if data.bagItems then
					for i = 1, #data["bagItems"] do
						local _data = data["bagItems"][i]
						DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
					end
				end

				if data.property then
					for i = 1, #data.property do
						local _data = string.split(data.property[i],",")
						local getNum = tonumber(_data[2]) - tonumber(gameUser.getDataById(_data[1]))
						gameUser.updateDataById(_data[1],_data[2])
					end
				end
				
				if data.newItems then
					for i = 1, #data.newItems do
						local _data = data.newItems[i]
						local num1 = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _data.itemId}).count or 0
						local getNum = tonumber(_data.count) - tonumber(num1)
						show_data[#show_data+1] = {rewardtype = 4,id =_data.itemId,num =getNum}
						
						DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
					end
				end

				ShowRewardNode:create(show_data)
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
				self:updateTableViewCell()
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


function JieriduihuanLayer:freshRedDot(list)
	self.parentLayer._duihuan = list
	self.parentLayer:freshRedDot()
end

function JieriduihuanLayer:updateTableViewCell()
	ClientHttp:requestAsyncInGameWithParams({
        modules = "holidayActivatExchangeList?",
		params = { activityId  = self._anctivityid },
        successCallback = function( data )
			if data.result == 0 then
				self._severListData = data.configList
				table.sort(self._ListData,function(data1,data2)
					return tonumber(data1.id)<tonumber(data2.id)
			 	end)
				for i = 1,#self._ListData do
					self._ListData[i].curCount =  self._severListData[i].count
				end
				self._ListData = self:SortList(self._ListData)
				self._severListData = self:SortList(self._severListData)
				self:freshRedDot(data.configList)
				self._tableView:reloadData()
			end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

--获取当前活动状态
function JieriduihuanLayer:getAnctivityStata()
	print("========================",self._anctivityid)
	ClientHttp:requestAsyncInGameWithParams({
        modules = "holidayActivatExchangeList?",
		params = { activityId  = self._anctivityid },
        successCallback = function( data )
			if data.result == 0 then
				
			end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

function JieriduihuanLayer:SortList( _table )
	local list_1,list_2= {},{}
	for k,v in pairs(_table) do
		if v.count == 0 then
			list_1[#list_1 + 1] = v
		else
			list_2[#list_2 + 1] = v
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

	_table = listData
	return _table
end

-- 领取奖励
function JieriduihuanLayer:fetchReward( yuanbao, iconData, index )
	
end
-- 对数据进行排序
function JieriduihuanLayer:sortData( dataTable )
	
end

function JieriduihuanLayer:create(params)
    return self.new(params)
end

return JieriduihuanLayer
