--Created By Liuluyang 2015年06月13日
local ChaozhiduihuanDuihuanLayer = class("ChaozhiduihuanDuihuanLayer",function ()
	local layer = XTHD.createSprite()
	layer:setContentSize( 685, 339 )
	return layer
end)

function ChaozhiduihuanDuihuanLayer:ctor(parent)
	self._parent = parent
	self._listData = gameData.getDataFromCSV("CheapExchange")
	self:initUI()
end

function ChaozhiduihuanDuihuanLayer:initUI()	
	self._talbeView = CCTableView:create(cc.size(685, 340))
	self._talbeView:setPosition(75,0)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self._talbeView)

    local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,170
    end
    local function numberOfCellsInTableView(table)
        return math.ceil(#self._listData/4)
    end
    local function tableCellTouched(table,cell)
    end
    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(self._talbeView:getContentSize().width,170)
        else
            cell:removeAllChildren()
        end
        for i=1,4 do
        	if idx*4+i <= #self._listData then
				local _index = idx*4+i
        		local bg = cc.Sprite:create("res/image/activities/chaozhiduihuan/cellbg.png")
				local x = bg:getContentSize().width *0.8+ (i -1)*bg:getContentSize().width * 1.1 + 5
				bg:setPosition(x,cell:getContentSize().height * 0.5)
				cell:addChild(bg)
				
				local buyBtn = XTHDPushButton:createWithFile({
					normalFile = "res/image/activities/chaozhiduihuan/buy_up.png",
					selectedFile = "res/image/activities/chaozhiduihuan/buy_down.png",
					needEnableWhenMoving = true,
					isScrollView = true,
					endCallback  = function()
					   self:costExcharge(_index)
					end,
				})
				bg:addChild(buyBtn)
				buyBtn:setPosition(bg:getContentSize().width * 0.5,buyBtn:getContentSize().height *0.5 + 5)
				
				--兑换获得
				local data = self._listData[_index]
				local item = ItemNode:createWithParams({
					itemId =  data.itemid,
					_type_ = 4,
					count = data.num,
					showDrropType = 2,
				})
				bg:addChild(item)
				item:setScale(0.6)
				item:setPosition(bg:getContentSize().width *0.5,bg:getContentSize().height * 0.5 + 30)

				--兑换消耗
				local Exitem = cc.Sprite:create("res/image/activities/chaozhiduihuan/duihuan_icon.png")
				bg:addChild(Exitem)
				Exitem:setScale(0.8)
				Exitem:setPosition(bg:getContentSize().width *0.5 - 18,bg:getContentSize().height * 0.5 - 25)

				local lable = XTHDLabel:create("x " .. data.exchangenum, 20 ,"res/fonts/def.ttf")
				lable:setAnchorPoint(0,0.5)
				lable:setColor(cc.c3b(215,138,17))  --XTHD.resource.textColor.green_text
				bg:addChild(lable)
				lable:setPosition(Exitem:getPositionX() + Exitem:getContentSize().width * 0.5,Exitem:getPositionY())

        	end
        end
        return cell
    end
    self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._talbeView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._talbeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)


    self._talbeView:reloadData()
end

function ChaozhiduihuanDuihuanLayer:costExcharge(index)
	local rightCallfunc = function()
		ClientHttp:requestAsyncInGameWithParams({
			modules = "costExcharge?",
			params = { configId  = self._listData[index].id },
			successCallback = function( data )  
				if data.result == 0 then
					if data.bagItems then
						local show_data = {}
						for i = 1 ,#data.bagItems do
							local _data = data.bagItems[i]
							local num_2 = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _data.itemId}).count or 0
							local num = _data.count - num_2
							if num > 0 then
								show_data[#show_data+1] = {rewardtype = 4,id =_data.itemId,num = num}
							end
							DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
						end

						ShowRewardNode:create(show_data)
						self._parent._juanCount:setString(XTHD.resource.getItemNum(2324))
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

	local name = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = self._listData[index].itemid}).name
	local _confirmLayer = XTHDConfirmDialog:createWithParams( {
		rightCallback = rightCallfunc,
		msg = ("确定消耗" .. tostring(self._listData[index].exchangenum) .."兑换券兑换" .. self._listData[index].num .. "个".. name .. "吗？")
    });
    cc.Director:getInstance():getRunningScene():addChild(_confirmLayer, 1)
end

function ChaozhiduihuanDuihuanLayer:create(parent)
	return ChaozhiduihuanDuihuanLayer.new(parent)
end

return ChaozhiduihuanDuihuanLayer