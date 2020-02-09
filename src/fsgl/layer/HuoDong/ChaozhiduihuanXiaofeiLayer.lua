--Created By Liuluyang 2015年06月13日
local ChaozhiduihuanXiaofeiLayer = class("ChaozhiduihuanXiaofeiLayer",function ()
	local layer = XTHD.createSprite()
	layer:setContentSize( 685, 339 )
	return layer
end)

function ChaozhiduihuanXiaofeiLayer:ctor(parent,data)
	self._activityData = data
	self._activityList = data.list
	self._parent = parent
	self._listData = gameData.getDataFromCSV("CostReward")

	
	print("====================",self._parent._selectedIndex)
	
	for i = 1,#self._listData do
		self._listData[i].state =  self._activityList[i].state
	end
	self._listData = self:SortList(self._listData)
	self._activityList = self:SortList(self._activityList)
	
	self:initUI()
end

function ChaozhiduihuanXiaofeiLayer:initUI()	
	self._talbeView = CCTableView:create(cc.size(685, 340))
	self._talbeView:setPosition(75,0)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self._talbeView)

    local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,110
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
			cell:setContentSize(self._talbeView:getContentSize().width,110)
        else
            cell:removeAllChildren()
        end
       
        local bg = cc.Sprite:create("res/image/activities/newyear/redpacket/cellbg_2.png" )
		bg:setContentSize(cell:getContentSize().width - 35,105)
		cell:addChild(bg)
		bg:setPosition(cell:getContentSize().width *0.5 - 3,cell:getContentSize().height *0.5)

		local data = self._listData[idx + 1]
		for i = 1,4 do
			local itemdate = string.split(data["canshu" .. tostring(i)],"#")
			local item = ItemNode:createWithParams({
				itemId =  itemdate[1],
				_type_ = data["rewardtype"..tostring(i)],
				count = itemdate[2],
				showDrropType = 2,
			})
			item:setScale(0.65)
			bg:addChild(item)
			item:setPosition( 5 + (item:getContentSize().width * 0.8) *(i - 1) + item:getContentSize().width*0.5, bg:getContentSize().height * 0.5 - 10)
		end

		if self._listData[idx + 1].state == 1 then
			local normalnode = cc.Sprite:create("res/image/common/btn/btn_write_up.png")
			normalnode:setContentSize(cc.size(120,60))
			local selectednode = cc.Sprite:create("res/image/common/btn/btn_write_down.png")
			selectednode:setContentSize(cc.size(120,60))
			-- 领取
			local btn_duihuan = XTHD.createCommonButton({
					text = "领 取",
					fontColor = cc.c3b( 255, 255, 255 ),
					fontSize = 20,
					normalNode = normalnode,
					selectedNode = selectednode,
					isScrollView = true,
					endCallback = function ()
						self:receiveCostReward(idx + 1)
					end
				})
			bg:addChild(btn_duihuan)
			btn_duihuan:setPosition(bg:getContentSize().width - btn_duihuan:getContentSize().width * 0.5 - 40,bg:getContentSize().height *0.5 - 20)
			local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
			btn_duihuan:addChild(fetchSpine)
			fetchSpine:setScaleX(0.8)
			fetchSpine:setScaleY(0.7)
			fetchSpine:setPosition(btn_duihuan:getBoundingBox().width*0.5 + 1, btn_duihuan:getContentSize().height*0.5+2)
			fetchSpine:setAnimation(0, "querenjinjie", true )
		elseif self._listData[idx + 1].state == 2 then
			local yilingqu = cc.Sprite:create("res/image/camp/camp_reward_getted.png")
			bg:addChild(yilingqu)
			yilingqu:setPosition(bg:getContentSize().width - yilingqu:getContentSize().width * 0.5 - 27,bg:getContentSize().height *0.5 - 20)
			yilingqu:setScale(0.8)
		else
			local normalnode = cc.Sprite:create("res/image/common/btn/btn_write_up.png")
			normalnode:setContentSize(cc.size(120,60))
			local selectednode = cc.Sprite:create("res/image/common/btn/btn_write_down.png")
			selectednode:setContentSize(cc.size(120,60))
			-- 前往
			local btn_duihuan = XTHD.createCommonButton({
					text = "前 往",
					fontColor = cc.c3b( 255, 255, 255 ),
					fontSize = 20,
					normalNode = normalnode,
					selectedNode = selectednode,
					isScrollView = true,
					endCallback = function ()
						local callback = function()
							self._parent:SelectedActivityLayer(self._parent._selectedIndex)
						end
						local _store = requires("src/fsgl/layer/ShangCheng/ShangCheng.lua"):create({which = 'yuanbao'},true,callback)
						LayerManager.addLayout(_store)
					end
				})
			bg:addChild(btn_duihuan)
			btn_duihuan:setPosition(bg:getContentSize().width - btn_duihuan:getContentSize().width * 0.5 - 40,bg:getContentSize().height *0.5 - 20)
		end

		--消费进度
		local lable = XTHDLabel:create( tostring(self._activityData.sum) .. " / " .. data.canshu,18,"res/fonts/def.ttf" ) --self._activityData
		lable:setColor(cc.c3b(60,6,6))
		bg:addChild(lable)
		lable:setAnchorPoint(0.5,0.5)
		lable:setPosition(bg:getContentSize().width  - 100,bg:getContentSize().height *0.5 + 20)

		--标题描述
		local lable = XTHDLabel:create(data.describe,16,"res/fonts/def.ttf")
		lable:setColor(cc.c3b(60,6,6))
		bg:addChild(lable)
		lable:setAnchorPoint(0,0.5)
		lable:setPosition(20,bg:getContentSize().height - lable:getContentSize().height)
	
        return cell
    end
    self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._talbeView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._talbeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)


    self._talbeView:reloadData()
end

function ChaozhiduihuanXiaofeiLayer:receiveCostReward(index)
	ClientHttp:requestAsyncInGameWithParams({
        modules = "receiveCostReward?",
		params = { configId  = self._listData[index].id },
        successCallback = function( data )
			if data.result == 0 then
				if data.bagItems then
					local show_data = {}
					for i = 1 ,#data.bagItems do
						local _data = data.bagItems[i]
						local num_2 = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _data.itemId}).count or 0 
						local num = _data.count - num_2
						show_data[#show_data+1] = {rewardtype = 4,id =_data.itemId,num = num}
						DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
					end

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
				ShowRewardNode:create(show_data)            
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
				self._activityList = data.list
				table.sort(self._listData,function(data1,data2)
					return tonumber(data1.id)<tonumber(data2.id)
			 	end)

				for i = 1,#self._listData do
					self._listData[i].state =  self._activityList[i].state
				end
				self._listData = self:SortList(self._listData)
				self._severListData = self:SortList(self._activityList)
				self._talbeView:reloadData()
				self._parent._juanCount:setString(XTHD.resource.getItemNum(2324))
				self._parent:updateRedDot()
				end
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

function ChaozhiduihuanXiaofeiLayer:SortList( _table )
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

function ChaozhiduihuanXiaofeiLayer:create(parent,data)
	return ChaozhiduihuanXiaofeiLayer.new(parent,data)
end

return ChaozhiduihuanXiaofeiLayer