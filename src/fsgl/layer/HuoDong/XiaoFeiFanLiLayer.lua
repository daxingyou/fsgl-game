--[[
	累计充值界面
    20190611
]]
local XiaoFeiFanLiLayer = class("XiaoFeiFanLiLayer", function(params)
	local layer = XTHD.createSprite()
	layer:setContentSize( 640, 428 )
	return layer
end)

function XiaoFeiFanLiLayer:ctor(params,data)
	self._exist = true
	self._ListData = {}
	self._severListData = params.list
	-- dump( params, "LeiJiChongZhiLayer ctor" )
	-- ui
	self._size = self:getContentSize()
    self.parentLayer = params.parentLayer
    self.httpData = params.httpData
	self._anctivityid = params.anctivityid
	-- 状态
	self:initData( params.httpData )
	-- 添加监听事件
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG ,callback = function()
		if self._exist then
        	self:refreshData()
        end
    end})
	
	local list = gameData.getDataFromCSV("HolidayAction" )
	for k,v in pairs(list) do
		if v.actype == tonumber(self._anctivityid) then
			self._ListData[#self._ListData + 1] = v
		end
	end
	-- dump(self._ListData,"消费")

	
	self._severListData = params.data.list
	for i = 1,#self._ListData do
		self._ListData[i].state =  self._severListData[i].state
	end
	self._ListData = self:SortList(self._ListData)
	self._severListData = self:SortList(self._severListData)
	self:initUI()

	--self:getAnctivityStata()
	--self:initUI()
	
end
-- 
function XiaoFeiFanLiLayer:onCleanup()
	self._exist = false
end

--刷新小红点
function XiaoFeiFanLiLayer:freshRedDot(data)

end

-- 处理数据
function XiaoFeiFanLiLayer:initData(  )

end
-- 创建界面
function XiaoFeiFanLiLayer:initUI()
	-- 标题背景
	local titleBg = XTHD.createSprite( "res/image/activities/newyear/titlebg.png" )
	titleBg:setPosition( self._size.width*0.5+22, self._size.height - titleBg:getContentSize().height*0.5 +4)
	titleBg:setPosition( self._size.width*0.5+27, self._size.height - titleBg:getContentSize().height*0.5 - 5)
	titleBg:setScaleY(1.1)
	titleBg:setScaleX(1)
	self:addChild( titleBg )
	
	local titleLable = cc.Sprite:create("res/image/activities/newyear/xiaofeiyouli.png")
	titleBg:addChild(titleLable)
	--titleLable:setScale(0.8)
	titleLable:setPosition(titleLable:getContentSize().width - 120,titleBg:getContentSize().height *0.5 + 5)
	local time = XTHDLabel:createWithParams({
    	text = "活动剩余时间："..LANGUAGE_KEY_CARNIVALDAY(self.httpData.close),
    	fontSize = 18,
    	color = cc.c3b(255, 255, 255),
    	anchor = cc.p(0, 0),
		pos = cc.p(5, 5),
		ttf = "res/fonts/def.ttf",
    })
    titleBg:addChild(time)
    time:setPosition(titleBg:getContentSize().width/4 - 135,titleBg:getContentSize().height/4 - 30)
    self.Time = time
    self:updateTime()

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

function XiaoFeiFanLiLayer:updateTime()
    self:stopActionByTag(10)
    schedule(self, function()
        self.httpData.close = self.httpData.close - 1
        local time = "活动剩余时间："..LANGUAGE_KEY_CARNIVALDAY(self.httpData.close)
        self.Time:setString(time)
    end,1,10)
end

function XiaoFeiFanLiLayer:buildCell( cell, index, cellWidth, cellHeight )
	local _index = index + 1
    local bg2 = ccui.Scale9Sprite:create("res/image/activities/newyear/redpacket/cellbg_2.png" )
	bg2:setContentSize(cellWidth - 25,cellHeight - 20)
    bg2:setPosition( cellWidth*0.5-2, cellHeight*0.5 )
	cell:addChild( bg2 )

	local biaoti = XTHDLabel:create(self._ListData[_index].describe, 16,"res/fonts/def.ttf")
	cell:addChild(biaoti)
	biaoti:setColor(cc.c3b(139,69,19))
	biaoti:setAnchorPoint(cc.p(0,0.5))
	biaoti:setPosition(20,bg2:getContentSize().height - biaoti:getContentSize().height / 2)
		
	local maxNum = self._ListData[_index]["canshu"]
	print(">>>>>>>>>>>>>>>>>>>>>>",maxNum)
	local curNum = self._severListData[_index].curSum
	local progress = XTHDLabel:create(tostring(curNum) .. " / " .. tostring(maxNum), 16,"res/fonts/def.ttf")
	progress:setColor(cc.c3b(139,69,19))
	progress:setAnchorPoint(0,0.5)
	cell:addChild(progress,10)
	progress:setPosition(bg2:getContentSize().width*0.8 ,bg2:getContentSize().height - biaoti:getContentSize().height / 2)
	cell._progress = progress
	local JiangLi = {}
	
	for i = 1, 4 do
		if self._ListData[_index]["rewardtype"..i] ~= nil then
			if self._ListData[_index]["rewardtype"..i] == 6 then
				local _data = string.split(self._ListData[_index]["canshu"..i],"#")
				local item = ItemNode:createWithParams({
						_type_ = 6,
						count = _data[2]
				})
				JiangLi[#JiangLi + 1] = item
			end
			if self._ListData[_index]["rewardtype"..i] == 4 then
				local _data = string.split(self._ListData[_index]["canshu"..i],"#")
				local item = ItemNode:createWithParams({
						 itemId =  _data[1],
						_type_ = 4,
						count = _data[2]
				})
				JiangLi[#JiangLi + 1] = item
			end
			if self._ListData[_index]["rewardtype"..i] == 2 then
				local _data = string.split(self._ListData[_index]["canshu"..i],"#")
				local item = ItemNode:createWithParams({
						_type_ = 2,
						count = _data[2]
				})
				JiangLi[#JiangLi + 1] = item
			end
		end
	end
	
	for i = 1,#JiangLi do
		JiangLi[i]:setScale(0.6)
		cell:addChild(JiangLi[i])
		JiangLi[i]:setPosition((i-1)* JiangLi[i]:getContentSize().width *0.7 +50,cellHeight*0.5 - 10)
	end
	
	--state
	local btn_duihuan
	if self._ListData[_index].state == 1 then
		local normalnode = cc.Sprite:create("res/image/common/btn/btn_write_up.png")
		normalnode:setContentSize(cc.size(120,60))
		local selectednode = cc.Sprite:create("res/image/common/btn/btn_write_down.png")
		selectednode:setContentSize(cc.size(120,60))
		-- 领取
		btn_duihuan = XTHD.createButton({
				normalNode = normalnode,
				selectedNode = selectednode,
				isScrollView = true,
				endCallback = function ()
					self:LingQuJiangLi(_index)
				end
			})
		cell:addChild(btn_duihuan)
		btn_duihuan:setPosition(bg2:getContentSize().width*0.9 - 2 ,bg2:getContentSize().height / 2  - 10)
		local btn_lable = XTHDLabel:create("领 取", 18,"res/fonts/def.ttf")
		btn_lable:setColor(cc.c3b(255,255,255))
		btn_lable:enableOutline(cc.c4b(150, 79, 39, 255), 2)
		btn_duihuan:addChild(btn_lable)
		btn_lable:setPosition(btn_duihuan:getContentSize().width * 0.5,btn_duihuan:getContentSize().height * 0.5)
		
		local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		btn_duihuan:addChild(fetchSpine)
		fetchSpine:setScale(0.8)
		fetchSpine:setPosition(btn_duihuan:getBoundingBox().width*0.5 + 1, btn_duihuan:getContentSize().height*0.5+2)
		fetchSpine:setAnimation(0, "querenjinjie", true )	
		--btn_duihuan:setScale(0.5)
	elseif self._ListData[_index].state == 0 then
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
		cell:addChild(btn_duihuan)
		btn_duihuan:setPosition(bg2:getContentSize().width*0.9 - 2,bg2:getContentSize().height / 2  - 10)
		local btn_lable = XTHDLabel:create("未完成", 18,"res/fonts/def.ttf")
		btn_lable:setColor(cc.c3b(255,255,255))
		btn_duihuan:addChild(btn_lable)
		btn_lable:enableOutline(cc.c4b(103, 34, 13, 255), 2)
		btn_lable:setPosition(btn_duihuan:getContentSize().width * 0.5,btn_duihuan:getContentSize().height * 0.5)
	else
		local yilingqu = cc.Sprite:create("res/image/vip/yilingqu.png")
		cell:addChild(yilingqu)
		yilingqu:setPosition(bg2:getContentSize().width*0.9 - 2,bg2:getContentSize().height / 2 )
		yilingqu:setContentSize(cc.size(115,40))
	end

	return cell
end

function XiaoFeiFanLiLayer:LingQuJiangLi(index)
	ClientHttp:requestAsyncInGameWithParams({
        modules = "holidayActivateReward?",
		params = { configId  = self._severListData[index].configId },
        successCallback = function( data )
			if data.result == 0 then
--				dump(data)
				local show_data = {}
				if data.bagItems then
					for i = 1, #data["bagItems"] do
						local _data = data["bagItems"][i]
						local num_2 = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _data.itemId}).count
						if num_2 == nil then
							num_2 = 0
						end
						local num = tonumber(_data.count) - tonumber(num_2)
						show_data[#show_data+1] = {rewardtype = 4,id =_data.itemId,num = num}
						DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
					end
				end

				if data.property then
					for i = 1, #data.property do
						local _data = string.split(data.property[i],",")
						local getNum = tonumber(_data[2]) - tonumber(gameUser.getDataById(_data[1]))
						if getNum > 0 then
							local idx = #show_data + 1
                            show_data[idx] = {}
                            show_data[idx].rewardtype = XTHD.resource.propertyToType[tonumber(_data[1])]
                            show_data[idx].num = getNum
						end
						gameUser.updateDataById(_data[1],_data[2])
					end
				end
			
				ShowRewardNode:create(show_data)
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

function XiaoFeiFanLiLayer:updateTableViewCell()
	ClientHttp:requestAsyncInGameWithParams({
        modules = "holidayActivatList?",
		params = { activityId  = self._anctivityid },
        successCallback = function( data )
			if data.result == 0 then
				self._severListData = data.list
	
				table.sort(self._ListData,function(data1,data2)
					return tonumber(data1.id)<tonumber(data2.id)
			 	end)				

				for i = 1,#self._ListData do
					self._ListData[i].state =  self._severListData[i].state
				end
				self._ListData = self:SortList(self._ListData)
				self._severListData = self:SortList(self._severListData)
				self:refreshRedDot(data.list)
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

function XiaoFeiFanLiLayer:refreshRedDot(list)
	for k, v in pairs(list) do
		if v.state == 1 then
			RedPointState[24].state = 1
			break
		else
			RedPointState[24].state = 0
		end
	end
	self.parentLayer:freshRedDot()
end

--获取当前活动状态
function XiaoFeiFanLiLayer:getAnctivityStata()
	ClientHttp:requestAsyncInGameWithParams({
        modules = "holidayActivatList?",
		params = { activityId  = self._anctivityid },
        successCallback = function( data )
			
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

function XiaoFeiFanLiLayer:SortList( _table )
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

-- 领取奖励
function XiaoFeiFanLiLayer:fetchReward( yuanbao, iconData, index )
	
end
-- 对数据进行排序
function XiaoFeiFanLiLayer:sortData( dataTable )
	
end

function XiaoFeiFanLiLayer:create(params)
    return self.new(params)
end

return XiaoFeiFanLiLayer
