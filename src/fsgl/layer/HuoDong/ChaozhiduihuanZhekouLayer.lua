--Created By Liuluyang 2015年06月13日
local ChaozhiduihuanZhekouLayer = class("ChaozhiduihuanZhekouLayer",function ()
	local layer = XTHD.createSprite()
	layer:setContentSize( 431, 268 )
	return layer
end)

function ChaozhiduihuanZhekouLayer:ctor(parent,data)
	self._parent = parent
	self._listData = {}
	self._data = data
	self._selectedIndex = 0
	self._buyLableList = {}
	for i = 1,#data.list do
		self._listData[#self._listData + 1] =  gameData.getDataFromCSV("DiscountShop",{id = data.list[i].configId})
	end
	self:initUI()
end

function ChaozhiduihuanZhekouLayer:initUI()	
	self._talbeView = CCTableView:create(self:getContentSize())
	self._talbeView:setPosition(-50,18)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self._talbeView)

    local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,170
    end
    local function numberOfCellsInTableView(table)
        return math.ceil(#self._listData/3)
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
        for i=1,3 do
        	if idx*3+i <= #self._listData then
				local _index = idx*3+i
        		local bg = cc.Sprite:create("res/image/activities/chaozhiduihuan/cellbg.png")
				local x = bg:getContentSize().width *0.5+ (i -1)*bg:getContentSize().width * 1.05 + 3
				bg:setPosition(x,cell:getContentSize().height * 0.5)
				cell:addChild(bg)
				
				local buyBtn = XTHDPushButton:createWithFile({
					normalFile = "res/image/activities/chaozhiduihuan/buybtn_up.png",
					selectedFile = "res/image/activities/chaozhiduihuan/buybtn_down.png",
					needEnableWhenMoving = true,
					isScrollView = true,
					endCallback  = function()
					   self:buyDiscountItem(_index)
					end,
				})
				bg:addChild(buyBtn)
				buyBtn:setPosition(bg:getContentSize().width * 0.5,buyBtn:getContentSize().height *0.5 + 5)
				
				local data = self._listData[_index]
				local item = ItemNode:createWithParams({
					itemId =  data.resourceid,
					_type_ = data.resourcetype,
					count = data.num,
					showDrropType = 2,
				})
				bg:addChild(item)
				item:setScale(0.6)
				item:setPosition(bg:getContentSize().width *0.5,bg:getContentSize().height * 0.5 + 30)
		
				--原价
				local yuanjia = XTHDLabel:create("原价：",13,"res/fonts/def.ttf")
				yuanjia:setAnchorPoint(0,0.5)
				yuanjia:setColor(cc.c3b(0,140,20))
				bg:addChild(yuanjia)
				yuanjia:setPosition(15,item:getPositionY() - item:getContentSize().height * 0.5 * 0.8 - 2)
				
				local exitem = cc.Sprite:create("res/image/common/common_gold.png")
				bg:addChild(exitem)
				exitem:setScale(0.65)
				exitem:setPosition(yuanjia:getContentSize().width + yuanjia:getPositionX() + 5,yuanjia:getPositionY())

				local yuanjiaxiaohao = XTHDLabel:create("x " .. tostring(data.ingotprice),13,"res/fonts/def.ttf")
				yuanjiaxiaohao:setColor(cc.c3b(0,140,20))
				yuanjiaxiaohao:setAnchorPoint(0,0.5)
				bg:addChild(yuanjiaxiaohao)
				yuanjiaxiaohao:setPosition(exitem:getPositionX() + exitem:getContentSize().width*0.5,exitem:getPositionY())
				
				local node = cc.Node:create()
				node:setAnchorPoint(0.5,0.5)
				node:setContentSize(yuanjiaxiaohao:getContentSize().width + 5,10)
				bg:addChild(node)
				node:setPosition(yuanjiaxiaohao:getPositionX() + yuanjiaxiaohao:getContentSize().width *0.5,yuanjiaxiaohao:getPositionY())
				node:setRotation(3)
				node:setScaleY(1.5)

				local hengxian = XTHDLabel:create("———",16,"res/fonts/def.ttf")
				hengxian:setColor(XTHD.resource.textColor.red_text)
				node:addChild(hengxian)
				hengxian:setPosition(node:getContentSize().width *0.5,node:getContentSize().height *0.5)

				--现价
				local xianjia = XTHDLabel:create("现价：",13,"res/fonts/def.ttf")
				xianjia:setAnchorPoint(0,0.5)
				xianjia:setColor(cc.c3b(0,140,20))
				bg:addChild(xianjia)
				xianjia:setPosition(15,item:getPositionY() - item:getContentSize().height * 0.5 * 0.8 - yuanjia:getContentSize().height - 7)

				local exitem_2 = cc.Sprite:create("res/image/common/common_gold.png")
				bg:addChild(exitem_2)
				exitem_2:setScale(0.65)
				exitem_2:setPosition(xianjia:getContentSize().width + xianjia:getPositionX() + 5,xianjia:getPositionY())
				
				local yuanjiaxiaohao = XTHDLabel:create("x " .. tostring(data.ingotprice2),13,"res/fonts/def.ttf")
				yuanjiaxiaohao:setColor(cc.c3b(0,140,20))
				yuanjiaxiaohao:setAnchorPoint(0,0.5)
				bg:addChild(yuanjiaxiaohao)
				yuanjiaxiaohao:setPosition(exitem_2:getPositionX() + exitem_2:getContentSize().width*0.5,exitem_2:getPositionY())

				--限购次数
				local lable = XTHDLabel:create("剩余购买次数："..self._data.list[_index].selfSurplusCount,13,"res/fonts/def.ttf")
				lable:setAnchorPoint(0.5,0.5)
				lable:setColor(cc.c3b(200,0,20))
				bg:addChild(lable)
				lable:setPosition(bg:getContentSize().width *0.5,bg:getContentSize().height - lable:getContentSize().height)
				self._buyLableList[_index] = lable
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

function ChaozhiduihuanZhekouLayer:buyDiscountItem(index)
	self._selectedIndex = index
	local rightCallfunc = function()
		ClientHttp:requestAsyncInGameWithParams({
			modules = "buyDiscountItem?",
			params = { configId  = self._listData[index].id },
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
					self._buyLableList[self._selectedIndex]:setString("剩余购买次数："..data.selfSurplusCount)
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
		rightCallback = rightCallfunc,
		msg = ("确定消耗" .. tostring(self._listData[index].ingotprice2) .."元宝购买" .. self._listData[index].num .. "个".. self._listData[index].itemname .. "吗？")
    });
    cc.Director:getInstance():getRunningScene():addChild(_confirmLayer, 1)
end

function ChaozhiduihuanZhekouLayer:create(parent,data)
	return ChaozhiduihuanZhekouLayer.new(parent,data)
end

return ChaozhiduihuanZhekouLayer