local PopShopLayer = class("PopShopLayer",function()
	return  XTHD.createPopLayer()
end)

function PopShopLayer:ctor(key)
	self._key = key
	self._titleFile = nil
	self._shopdata = nil
	self._severData = nil
	self._storeExRequest = nil
	self._iconFile = nil
	self._huobiNum = nil
	self:refreshShopdata()
	self:createShopData()
	
end

function PopShopLayer:init()
	local bg = cc.Sprite:create("res/image/PopShop/bg.png")
	self:addContent(bg)
	bg:setPosition(self:getContentSize().width *0.5,self:getContentSize().height *0.5)
	self._bg = bg
	
	local btn_close = XTHDPushButton:createWithParams({
		normalFile = "res/image/PopShop/btn_close_up.png",
		selectedFile ="res/image/PopShop/btn_close_down.png"
	})
	self._bg:addChild(btn_close,2)
	btn_close:setPosition(self._bg:getContentSize().width - btn_close:getContentSize().width *0.5 - 5,self._bg:getContentSize().height - btn_close:getContentSize().height *0.5 - 44)
	btn_close:setTouchEndedCallback(function()
		self:hide()
	end)

	local shopTitle = cc.Sprite:create(self._titleFile)
	self._bg:addChild(shopTitle)
	shopTitle:setPosition(self._bg:getContentSize().width *0.5,self._bg:getContentSize().height - shopTitle:getContentSize().height *0.5 - 10)

	local icon = cc.Sprite:create(self._iconFile)
	self._bg:addChild(icon)
	icon:setPosition(icon:getContentSize().width * 0.5 + 65, icon:getContentSize().height + 15)

	local num = self:getItemNum()
	local iconCount = XTHDLabel:create(num,18,"res/fonts/def.ttf")
	iconCount:setAnchorPoint(0,0.5)
	self._bg:addChild(iconCount)
	iconCount:setPosition(icon:getPositionX() + icon:getContentSize().width *0.5 + 5,icon:getPositionY() - 2)
	self._iconCount = iconCount
	
	self:initTableView()
end

function PopShopLayer:initTableView()
	self._talbeView = CCTableView:create(cc.size(595,478))
	self._talbeView:setPosition(335,33)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._bg:addChild(self._talbeView)
	TableViewPlug.init(self._talbeView)

	local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,215
    end
	
    local function numberOfCellsInTableView(table)
        return math.ceil(#self._shopdata / 3)
    end

    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(self._talbeView:getContentSize().width,215)
        else
            cell:removeAllChildren()
        end
		self:loadStores(idx,cell)
		return cell
	end
	self._talbeView.getCellNumbers=numberOfCellsInTableView
	self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self._talbeView.getCellSize=cellSizeForTable
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._talbeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
	self._talbeView:reloadData()
end

function PopShopLayer:loadStores(index,cell)
	index = index + 1
	for i = 1, 3 do
		local _index = (index - 1) * 3 + i
		local data = self._shopdata[_index]
		if data then
			local cellbg = cc.Sprite:create("res/image/PopShop/cellbg.png")
			cell:addChild(cellbg)
			cellbg:setPosition(20 + cellbg:getContentSize().width *0.5 + (i - 1) * (cellbg:getContentSize().width + 20),cell:getContentSize().height *0.5)

			local _itemId = nil
			local _type = nil
			if self._key == "guild" then
				_type = 4
				_itemId = data.resourceid
			elseif self._key == "camp" or self._key == "Artifact" then
				_type = data.resourcetype
				_itemId = data.resourceid
			else
				_type = 4
				_itemId = data.itemid
			end
			
			local itemNode = ItemNode:createWithParams({
				_type_ = _type,
				itemId = _itemId,
				count = data.num,
			})
			itemNode:setScale(0.7)
			cellbg:addChild(itemNode)
			itemNode:setPosition(cellbg:getContentSize().width *0.5, cellbg:getContentSize().height *0.6 + 2.5)

			local name = nil
			if self._key == "recycle" then
				local item = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = data.itemid}) 
				name = item.name
			elseif self._key == "reward" then
				local item = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = data.itemid}) 
				name = item.name
			elseif self._key == "shura" then
				local item = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = data.itemid}) 
				name = item.name
			elseif self._key == "Artifact" then
				if data.resourcetype == 4 then
					local item = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = data.resourceid}) 
					name = item.name
				else
					local item = gameData.getDataFromCSV("SuperWeaponUpInfo",{id = data.resourceid}) 
					name = item.name
				end
			else
				name = data.itemname
			end
			local itemName = XTHDLabel:create(name,15,"res/fonts/def.ttf")
			cellbg:addChild(itemName)
			itemName:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height - itemName:getContentSize().height *0.5 - 8)
			
			self:createNeednum(cellbg,data,_index)
			
			local btn_buy = XTHDPushButton:createWithParams({
				normalFile = "res/image/PopShop/btn_buy_up.png",
				selectedFile = "res/image/PopShop/btn_buy_down.png",
			})
			cellbg:addChild(btn_buy)
			btn_buy:setPosition(cellbg:getContentSize().width *0.5,btn_buy:getContentSize().height*0.5)
			btn_buy:setTouchEndedCallback(function()
				self:buyItem(_index)
			end)
		end
	end
end

function PopShopLayer:createNeednum(cellbg,data,index)
	local Params = {"goldprice","jadeprice","coinprice","ingotprice"}
	local needItemfiles = {}
	local needItemcoutns = {}
	local n = 0

	if self._key == "ArenaStore" or self._key == "recycle" or self._key == "flower" or self._key == "reward" or self._key == "arena" or self._key == "shura" then
		for i = 1,#Params do
			if data[Params[i]] and data[Params[i]] > 0 then
				n = n + 1 
				if self._key == "flower" then
					needItemfiles[n] = IMAGE_KEY_HEADER_FLOWER
				elseif self._key == "ArenaStore" then
					if  i == 1 then
					needItemfiles[n] = IMAGE_KEY_HEADER_GOLD
					elseif i == 2 then
						needItemfiles[n] = IMAGE_KEY_HEADER_FEICUI
					elseif i == 3 then
						needItemfiles[n] = IMAGE_KEY_HEADER_AWARD
					elseif i == 4 then
						needItemfiles[n] = IMAGE_KEY_HEADER_INGOT
					end
				elseif self._key == "recycle" then
					needItemfiles[n] = IMAGE_KEY_HEADER_SMELT
				elseif self._key == "reward" then
					needItemfiles[n] = IMAGE_KEY_HEADER_OFFERREWARD
				elseif self._key == "arena" then
					needItemfiles[n] = IMAGE_KEY_HEADER_AWARD
				elseif self._key == "shura" then
					if i == 3 then
						needItemfiles[n] = IMAGE_KEY_HEADER_BLOOD
					elseif i == 4 then
						needItemfiles[n] = IMAGE_KEY_HEADER_INGOT
					end
				end
			
				needItemcoutns[n] = data[Params[i]]
			end
		end
	elseif self._key == "guild" or self._key == "camp" or self._key == "Artifact" then
		local _index = 0
		 while true do
			_index = _index + 1
			if data["type"..tostring(_index)] and data["type"..tostring(_index)] ~= 0 then
				n = n + 1
				if self._key == "guild" then
					needItemfiles[n] = IMAGE_KEY_HEADER_CONTRI
				elseif self._key == "camp" then
					needItemfiles[n] = IMAGE_KEY_HEADER_HONOR
				elseif self._key == "Artifact" then
					if data["type"..tostring(_index)] == 10 then
						needItemfiles[n] = IMAGE_KEY_HEADER_SAINTSTONE
					elseif data["type"..tostring(_index)] == 6 then
						needItemfiles[n] = IMAGE_KEY_HEADER_FEICUI
					elseif data["type"..tostring(_index)] == 3 then
						needItemfiles[n] = IMAGE_KEY_HEADER_INGOT
					end
				end
				needItemcoutns[n] = data["num"..tostring(_index)]
			else
				break
			end
		 end
	end
			
	for i = 1, #needItemfiles do
		local icon = cc.Sprite:create(needItemfiles[i])
		icon:setScale(0.65)
		icon:setAnchorPoint(0,0.5)	
		local needCount = XTHDLabel:create(needItemcoutns[i],16,"res/fonts/def.ttf")
		needCount:setAnchorPoint(0,0.5)
		needCount:setColor(cc.c3b(0,0,0))

		local node = cc.Node:create()
		node:setAnchorPoint(0,0.5)
		cellbg:addChild(node)
		node:setContentSize(icon:getContentSize().width + needCount:getContentSize().width + 5,icon:getContentSize().height *0.8)
		
		node:addChild(icon)
		node:addChild(needCount)

		icon:setPosition(0,node:getContentSize().height *0.5)
		needCount:setPosition(icon:getPositionX() + icon:getContentSize().width *0.5 + 8,node:getContentSize().height *0.5)

		if #needItemfiles == 1 then
			node:setPosition(cellbg:getContentSize().width *0.3,cellbg:getContentSize().height *0.35)
		elseif #needItemfiles == 2 then
			node:setPosition(15 + (i - 1) *70,cellbg:getContentSize().height *0.35)
		end
	end

	if self._key == "arena" then
		local duanName = {"青铜组","白银组","黄金组","白金组","钻石组","至尊组","王者组"}
		if gameUser.getDuanId() > data.rank then
			local lable = XTHDLabel:create("限购次数："..self._severData[index].count.."次",15)
			cellbg:addChild(lable)
			lable:setAnchorPoint(0.5,0.5)
			lable:setColor(cc.c3b(64,46,7))
			lable:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.25 - 2)
		else
			local lable = XTHDLabel:create(duanName[data.rank].."可购买",15)
			cellbg:addChild(lable)
			lable:setAnchorPoint(0.5,0.5)
			lable:setColor(cc.c3b(64,46,7))
			lable:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.25 - 2)
		end
	elseif self._key == "guild" then
		local lable = XTHDLabel:create("限购次数："..self._severData[index].exchangeSum.."次",15)
		cellbg:addChild(lable)
		lable:setAnchorPoint(0.5,0.5)
		lable:setColor(cc.c3b(64,46,7))
		lable:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.25 - 2)
	elseif self._key == "recycle" then
		local lable = XTHDLabel:create("限购次数："..self._severData[index].count.."次",15)
		cellbg:addChild(lable)
		lable:setAnchorPoint(0.5,0.5)
		lable:setColor(cc.c3b(64,46,7))
		lable:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.25 - 2)
	elseif self._key == "camp" then
		local lable = XTHDLabel:create("限购次数："..self._severData[index].exchangeSum.."次",15)
		cellbg:addChild(lable)
		lable:setAnchorPoint(0.5,0.5)
		lable:setColor(cc.c3b(64,46,7))
		lable:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.25 - 2)
	elseif self._key == "Artifact" then
		local lable = XTHDLabel:create("限购次数："..self._severData[index].exchangeSum.."次",15)
		cellbg:addChild(lable)
		lable:setAnchorPoint(0.5,0.5)
		lable:setColor(cc.c3b(64,46,7))
		lable:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.25 - 2)
	elseif self._key == "flower" then
		local lable = XTHDLabel:create("限购次数："..self._severData[index].count.."次",15)
		cellbg:addChild(lable)
		lable:setAnchorPoint(0.5,0.5)
		lable:setColor(cc.c3b(64,46,7))
		lable:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.25 - 2)
	elseif self._key == "reward" then
		local lable = XTHDLabel:create("限购次数："..self._severData[index].surplusCount.."次",15)
		cellbg:addChild(lable)
		lable:setAnchorPoint(0.5,0.5)
		lable:setColor(cc.c3b(64,46,7))
		lable:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.25 - 2)
	elseif self._key == "shura" then
		local lable = XTHDLabel:create("限购次数："..self._severData[index].count.."次",15)
		cellbg:addChild(lable)
		lable:setAnchorPoint(0.5,0.5)
		lable:setColor(cc.c3b(64,46,7))
		lable:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.25 - 2)
	end
end

function PopShopLayer:buyItem(index)
	local param  = nil
	
	if self._key == "arena" then
		param = {configId = self._shopdata[index].id,count = 1}
	elseif self._key == "recycle" then
		param = {configId = self._shopdata[index].id,sum = 1}
	else
		param = {configId = self._shopdata[index].id}
	end

	XTHDHttp:requestAsyncInGameWithParams({
		modules = self._storeExRequest,
		params = param,
		successCallback = function(data)
			if tonumber(data.result) == 0 then
				local showlist = {}
           		if data.items then
					for i = 1,#data.items do
						local _data = data.items[i]
						local num_1 = _data.count
						local num_2 = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _data.itemId}).count or 0
						local _num = num_1 - num_2
						showlist[#showlist + 1] = {rewardtype = 4,id = _data.itemId,num = _num}
						DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
					end
					if data.property then
						for i = 1,#data.property do
							local _data = string.split(data.property[i],",")
							local num_1 = _data[2]
							local num_2 = gameUser.getDataById(_data[1])
							if tonumber(_data[1]) ~= 445 then
								if num_1 - num_2 > 0 then
									local idx = #showlist + 1
									showlist[idx] = {}
									showlist[idx].rewardtype = XTHD.resource.propertyToType[tonumber(_data[1])]
									showlist[idx].num = num_1 - num_2
								end
							end
							gameUser.updateDataById(_data[1],_data[2])
						end
					end
					if data.gods then
						
						for i = 1, #data.gods do
							local _data = data.gods[i]
							local goddata = gameData.getDataFromCSV("SuperWeaponUpInfo",{id = _data.templateId})
							local idx = #showlist + 1
							showlist[idx] = {}
							--showlist[idx].rewardtype = 4
							showlist[idx].rewardtype = goddata._type
							showlist[idx].num = 1
						end
					end
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
				end
				ShowRewardNode:create(showlist)
				self:refreshShopcount(data,index)
				self._iconCount:setString(self:getItemNum())
				self._talbeView:reloadDataAndScrollToCurrentCell()
			elseif tonumber(data.result) == 5501 then ----全服次数没了                
				XTHDTOAST(data.msg)
				XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
			else
				XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
			end
		end,--成功回调
		failedCallback = function()
			XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
		end,--失败回调        
		loadingParent = self,        
		loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})
end

function PopShopLayer:refreshShopcount(data,index)
	if self._key == "arena" then	--竞技商店
		self._severData[index].count = data.count
	elseif self._key == "recycle" then	--回收商店
		self._severData[index].count = data.count
		self._huobiNum = data.smeltPoint
	elseif self._key == "Artifact" then	--神器商店
		self._severData[index].exchangeSum = data.exchangeSum
	elseif self._key == "camp" then	--阵营商店
		self._severData[index].exchangeSum = data.exchangeSum
	elseif self._key == "reward" then	--悬赏商店
		self._severData[index].surplusCount = data.surplusCount
	elseif self._key == "shura" then	--修罗商店
		self._severData[index].exchangeSum = data.exchangeSum
	elseif self._key == "guild" then	--帮派商店
		self._severData[index].exchangeSum = data.exchangeSum
		self._huobiNum = data.totalContribution
	elseif self._key == "flower" then --鲜花商店
		self._severData[index].count = data.count
	end
end

function PopShopLayer:createShopData()
	if self._key == "arena" then	--竞技商店
		self._shopdata = gameData.getDataFromCSV("ArenaStore")
		self._titleFile = "res/image/PopShop/jingji_title.png"
		self._storeExRequest = "buyRequest?"
		self._iconFile = IMAGE_KEY_HEADER_AWARD
	elseif self._key == "recycle" then	--回收商店
		self._shopdata = gameData.getDataFromCSV("RecyclingShop")
		self._titleFile = "res/image/PopShop/huishou_title.png"
		self._storeExRequest = "smeltExchange?"
		self._iconFile = IMAGE_KEY_HEADER_SMELT
	elseif self._key == "Artifact" then	--神器商店
		self._shopdata = gameData.getDataFromCSV("SuperWeaponStore")
		self._titleFile = "res/image/PopShop/shenqi_title.png"
		self._storeExRequest = "beastExchange?"
		self._iconFile = IMAGE_KEY_HEADER_SAINTSTONE
	elseif self._key == "camp" then	--阵营商店
		self._shopdata = gameData.getDataFromCSV("RaceStore")
		self._titleFile = "res/image/PopShop/lingdi_title.png"
		self._storeExRequest = "campExchange?"
		self._iconFile = IMAGE_KEY_HEADER_HONOR
	elseif self._key == "reward" then	--悬赏商店
		self._shopdata = gameData.getDataFromCSV("XsTaskShop")
		self._titleFile = "res/image/PopShop/xuanshang_title.png"
		self._storeExRequest = "wantedShopBuy?"
		self._iconFile = IMAGE_KEY_HEADER_OFFERREWARD
	elseif self._key == "shura" then	--修罗商店
		self._shopdata = gameData.getDataFromCSV("SingleRaceStore")
		self._titleFile = "res/image/PopShop/xiuluo_title.png"
		self._storeExRequest = "asuraSwap?"
		self._iconFile = IMAGE_KEY_HEADER_BLOOD
	elseif self._key == "guild" then	--帮派商店
		self._shopdata = gameData.getDataFromCSV("SectStore")
		self._titleFile = "res/image/PopShop/guild_title.png"
		self._storeExRequest = "guildExchange?"
		self._iconFile = IMAGE_KEY_HEADER_CONTRI
	elseif self._key == "flower" then --鲜花商店
		self._shopdata = gameData.getDataFromCSV("FlowerShop")
		self._titleFile = "res/image/PopShop/xianhua_title.png"
		self._storeExRequest = "flowerShopBuy?"
		self._iconFile = IMAGE_KEY_HEADER_FLOWER
	elseif self._key == "servant" then --侍仆商店
		self._shopdata = gameData.getDataFromCSV("ServantExchange")
		self._titleFile = "res/image/PopShop/shipi_title.png"
	end
end

function PopShopLayer:getItemNum()
	local num = nil
	if self._key == "arena" then	--奖牌
		num = gameUser.getAward()
	elseif self._key == "recycle" then	--回收点
		num = self._huobiNum
	elseif self._key == "Artifact" then	--神石
		num = gameUser.getSaintStone()
	elseif self._key == "camp" then	--阵营点
		num = gameUser.getHonor()
	elseif self._key == "reward" then	--悬赏奖牌
		num =  gameUser.getBounty()
	elseif self._key == "shura" then	--修罗血
		num = gameUser.getAsura()
	elseif self._key == "guild" then	--帮派贡献
		num = self._huobiNum
	elseif self._key == "flower" then --鲜花
		num = gameUser.getFlower()
	end
	return num
end

function PopShopLayer:refreshShopdata()
	local _modules = nil
	if self._key == "arena" then	--奖牌
		_modules = "shopList?"
	elseif self._key == "recycle" then	--回收点
		_modules = "smeltExchangeWindow?"
	elseif self._key == "Artifact" then	--神石
		_modules = "beastExchangeList?"
	elseif self._key == "camp" then	--阵营点
		_modules = "campExchangeList?"
	elseif self._key == "reward" then	--悬赏奖牌
		_modules = "wantedShopList?"
	elseif self._key == "shura" then	--修罗血
		_modules = "asuraSwapWin?"
	elseif self._key == "guild" then	--帮派贡献
		_modules = "guildExchangeList?"
	elseif self._key == "flower" then --鲜花
		_modules = "flowerShopList?"
	end
	
	 XTHDHttp:requestAsyncInGameWithParams({
        modules = _modules,
        successCallback = function(data)        
            if tonumber(data.result) == 0 then
--				dump(data,"商城返回数据")
				self._severData = data.list
				if self._key == "guild" then
					self._huobiNum = data.totalContribution
				elseif self._key == "recycle" then
					self._huobiNum = data.smeltPoint
				elseif self._key == "camp" then
					self._huobiNum = data.totalForce
				end
				self:init()
            else
				self:removeFromParent()
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调
        loadingParent = self,        
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function PopShopLayer:create(key)
	return PopShopLayer.new(key)
end

return PopShopLayer