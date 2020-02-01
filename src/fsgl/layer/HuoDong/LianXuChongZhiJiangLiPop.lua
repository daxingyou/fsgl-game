--[[
	FileName: LianXuChongZhiJiangLiPop.lua
	Author: andong
	Date: 2016-1-13
	Purpose: 连续充值奖励列表
]]
local LianXuChongZhiJiangLiPop = class( "LianXuChongZhiJiangLiPop", function ()
    return XTHDPopLayer:create({isRemoveLayout = true})
end)
function LianXuChongZhiJiangLiPop:ctor(params)
	self:initData(params)
	self:initUI()
	self:show()
end
function LianXuChongZhiJiangLiPop:initData(params)
	self._data = params
	table.sort(params.list, function(a,b)
		return tonumber(a.configId) < tonumber(b.configId)
	end)
	self._rewardList = {}
	for i = 1, 3 do
		local id = params.list[i].configId or 101
		local staticdata = gameData.getDataFromCSV("ContinuityChongzhi", {["id"]=id})
		self._rewardList[i] = {}
		for j = 1 ,4 do
			self._rewardList[i][j] = {}
			self._rewardList[i][j].rewardtype = staticdata["rewardtype"..j]
			local rewardTab = string.split(staticdata["canshu"..j], "#")
			self._rewardList[i][j].num = rewardTab[2]
			if tonumber(self._rewardList[i][j].rewardtype) == 4 then
				self._rewardList[i][j].id = rewardTab[1]
			end
			self._rewardList[i][j]._state = params.list[i].state
			self._rewardList[i][j]._days = staticdata.needcanshu
			self._rewardList[i][j]._configid = id
		end
	end
end
function LianXuChongZhiJiangLiPop:initUI()
	local popSize = cc.size(525, 466)
	local popNode = ccui.Scale9Sprite:create( "res/image/activities/dailyRecharge/tanchuan.png")
	popNode:setContentSize(popSize)
	popNode:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
	self:addContent(popNode)
	local close = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create("res/image/activities/dailyRecharge/close.png"),
		selectedNode = cc.Sprite:create("res/image/activities/dailyRecharge/close.png"),
		needSwallow = true,
		enable = true,
		endCallback = function ()
			self:hide()
		end
   })
	close:setPosition(popSize.width-5, popSize.height-5)
	popNode:addChild(close, 10)

	local titleImg = XTHD.getScaleNode("res/image/activities/dailyRecharge/common_title_barBg.png", cc.size(popSize.width-14, 44))
	titleImg:setAnchorPoint(cc.p(0.5, 1))
	titleImg:setPosition(cc.p(popSize.width/2, popSize.height-8))
	popNode:addChild(titleImg)

	local title = XTHDLabel:createWithParams({
		text = LANGUAGE_RECHARGE_POPTITLE, -----------------------连续充值奖励中断或全部领取后会重置
		fontSize = 22,
		color = cc.c3b(242,202,11),
		anchor = cc.p(0.5, 0.5),
		pos = cc.p(titleImg:getContentSize().width/2, titleImg:getContentSize().height/2),
	})
	titleImg:addChild(title)
	
	local tableSize = cc.size(popSize.width-16, popSize.height-44-24)
	local tableNode = popNode
	
	local myTableBg = ccui.Scale9Sprite:create()
	myTableBg:setContentSize(tableSize)
	myTableBg:setAnchorPoint(cc.p(0.5, 0))
	myTableBg:setPosition(cc.p(tableNode:getContentSize().width/2, 8))
	tableNode:addChild(myTableBg)
	
	local myTable = CCTableView:create(cc.size(myTableBg:getContentSize().width-4,myTableBg:getContentSize().height-4))
	myTable:setPosition(2,2)
	myTable:setBounceable(true)
	myTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
	myTable:setDelegate()
	myTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	
	myTableBg:addChild(myTable)
	self._tableview = myTable
	
	local function cellSizeForTable(table,idx)
		return tableSize.width,125
	end
	local function numberOfCellsInTableView(table)
	    return #self._rewardList
	end
	local function tableCellAtIndex(table,idx)
		local nowIdx = idx + 1
		local cell = table:dequeueCell()
	    if cell == nil then
	        cell = cc.TableViewCell:new()
	        cell:setContentSize(cc.size(tableSize.width, 124))
	    else
	    	cell:removeAllChildren()
	    end
	    self:initCell(cell, nowIdx)
	    return cell

	end
	myTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	myTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
	myTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
	
	myTable:reloadData()
	

end
function LianXuChongZhiJiangLiPop:initCell(cell, idx)

	local reward = self._rewardList[idx]
	local cellimg = XTHD.getScaleNode("res/image/activities/dailyRecharge/scale9_bg_25.png", cc.size(cell:getContentSize().width-10,cell:getContentSize().height-3))
	cellimg:setAnchorPoint(cc.p(0.5, 0.5))
	cellimg:setPosition(cc.p(cell:getContentSize().width/2-2, cell:getContentSize().height/2+1))
	cell:addChild(cellimg)

	-- local itemimg = ccui.Scale9Sprite:create(cc.rect(5,5,1,1), "res/image/common/scale9_bg_14.png")
	local itemimg = XTHD.createSprite()
	itemimg:setContentSize(cc.size(300, 75))
	itemimg:setAnchorPoint(cc.p(0, 0))
	itemimg:setPosition(cc.p(17, 2))
	cellimg:addChild(itemimg)

	local pos = SortPos:sortFromMiddle(cc.p(itemimg:getContentSize().width/2, itemimg:getContentSize().height/2+3), #reward, itemimg:getContentSize().width/(#reward))
	for i = 1, #reward do
		local item = ItemNode:createWithParams({
			_type_ = reward[i].rewardtype,
			itemId = reward[i].id,
			count = reward[i].num,
		})
		item:setScale(0.75)
		item:setPosition(pos[i])
		itemimg:addChild(item)
	end

	-- local cellline = XTHD.getScaleNode("res/image/setting/line.png", cc.size(cellimg:getContentSize().width,1))
	-- cellline:setAnchorPoint(cc.p(0.5, 0.5))
	-- cellline:setPosition(cc.p(cellimg:getContentSize().width/2, cellimg:getContentSize().height - 23))
	-- cellimg:addChild(cellline)

	local celltitle = XTHDLabel:createWithParams({
		text = LANGUAGE_DAILYRECHARGE_DAYS2(reward[1]._days),
		fontSize = 18,
		color =  cc.c3b(242,202,11),
		anchor = cc.p(0, 1),
		pos = cc.p(20, cellimg:getContentSize().height-5),
	})
	cellimg:addChild(celltitle)
	
	local numlab = XTHDLabel:createWithParams({
		text = tostring(self._data.curPayDay).."/"..tostring(reward[1]._days),
		fontSize = 18,
		color =  cc.c3b(242,202,11),
		anchor = cc.p(1, 1),
		pos = cc.p(cellimg:getContentSize().width-15, cellimg:getContentSize().height-1),
	})
	cellimg:addChild(numlab)
	
	local btncolor 
	local str 
	local flag 

	if tonumber(reward[1]._state) == 0 then
		btncolor = "write"
		str = LANGUAGE_BTN_KEY.noAchieve
		flag = 0
	elseif tonumber(reward[1]._state) == 1 then
		btncolor = "write_1"
		str = LANGUAGE_KEY_SPACEFETCH
		flag = 1
	elseif tonumber(reward[1]._state) == 2 then
		flag = 2
	end

	if flag ~= 2 then
		local getBtn = XTHD.createCommonButton({
			btnColor = btncolor,
			text = str,
			isScrollView = true,
			endCallback = function()
				
				if flag == 0 then
					XTHDTOAST(LANGUAGE_BTN_KEY.noAchieve)
					if self._data.callback and type(self._data.callback) == "function" then
						self._data.callback()
					end	
				elseif flag == 1 then
					self:getReward(idx, reward, reward[1]._configid)	
				end
			end,
			anchor = cc.p(1, 0),
			pos = cc.p(cellimg:getContentSize().width-17, 13),
		})
		getBtn:setScale(0.8)
		if flag == 1 then
			local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
			getBtn:addChild(fetchSpine)
			fetchSpine:setPosition(getBtn:getContentSize().width*0.5 + 2, getBtn:getContentSize().height*0.5+2)
			fetchSpine:setAnimation(0, "querenjinjie", true )
		end
		cellimg:addChild(getBtn)
	else
		local yilingqu = XTHD.createSprite( "res/image/vip/yilingqu.png" )
		yilingqu:setAnchorPoint(cc.p(1, 0))
		yilingqu:setScale(0.8)
	    yilingqu:setPosition( cc.p(cellimg:getContentSize().width-17, 13))
		cellimg:addChild(yilingqu)
	end

end
function LianXuChongZhiJiangLiPop:getReward(idx, showdata, id)
	ClientHttp:requestAsyncInGameWithParams({
	    modules = "receiveContinuousPayDayReward?",      --接口
	    params = {configId=id}, --参数
	    successCallback = function(data)
	        if tonumber(data.result) == 0 then --请求成功
	            ShowRewardNode:create( showdata )
            	-- 更新属性
		    	if data.property and #data.property > 0 then
	                for i=1, #data.property do
	                    local pro_data = string.split( data.property[i], ',' )
	                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
	                end
	                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
	            end
	            -- 更新背包
	            if data.bagItems and #data.bagItems ~= 0 then
	                for i=1, #data.bagItems do
	                    local item_data = data.bagItems[i]
	                    if item_data.count and tonumber( item_data.count ) ~= 0 then
	                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
	                    else
	                        DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
	                    end
	                end
	            end 

	        	self._rewardList[idx][1]._state = 2
	        	self._tableview:reloadData()
        		if self._data.callback and type(self._data.callback) == "function" then
					self._data.callback(self._rewardList[idx][1]._configid)
				end
	        else
	           XTHDTOAST(data.msg) --出错信息(后端返回)
	        end
	    end,--成功回调
	    loadingParent = self,
	    failedCallback = function()
	        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
	    end,--失败回调
	    targetNeedsToRetain = self,--需要保存引用的目标
	    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})
end
function LianXuChongZhiJiangLiPop:create(params)
	return self.new(params)
end

function LianXuChongZhiJiangLiPop:onEnter()
	-- print("onEnter ====")
end
function LianXuChongZhiJiangLiPop:onCleanup()
	-- print("onCleanup ====")
end
function LianXuChongZhiJiangLiPop:onExit()
	-- print("onExit ====")
end

return LianXuChongZhiJiangLiPop