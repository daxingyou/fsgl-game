local ShangCheng = class("ShangCheng",function( )
    return XTHD.createBasePageLayer()
end)

function ShangCheng:ctor(params,isUpdate,callFunc)
    self._storeIndex = self:getStoreIndexByName(params.which) or 1 ------当前选中的是哪个商店
	self._extraCallback = params.callback 
	self._goodsType = params._type or 1 -----商品类型（1良品 2高级 3顶级 4稀有)
	self._bg = nil -------中间大横条背景
	self._pinkBg = nil -----中间第二层粉红色背景
	self._buttonList = nil ----按钮列表
	self._storeList = nil ------商店列表
	self._selectedButton = nil  ------被选中的商店按钮（左边）
	self._selectedLabel = nil ------被选中的商店标签
	self._storeButtons = {}
	self._playerResAmount = nil -----玩家资源节点 
	self._playerResIcon = nil ----玩家资源图标 
	self._labelTabContainer = nil -----商店下面的商店各类标签容器
	self._titleContainer = nil ----在商品列表上方的内容
    self._canChangeStore = true ------是否可以切换商店（防止恶意切换，在一个商店的请求未结束之前就切换）

	self._storeServerData = nil ----商店数据（服务器全部）
	self._storeLocalData = nil ----商店数据（本地）
	self._OtherShopNode = nil

	self._displayDatas = {} ---需要显示的数据组
    self._storeCell = {} -----商店物品们
    self._groupTip = nil -----团购提示
	self._selectedName = nil
	self._isUpdate = isUpdate
	self._callFunc = callFunc
	self.Tag = {
		ktag_countDown = 100,
	}

    -- self._storeTags = {6,8,1,2,3,4,5,7,9} ----团购、运镖、竞技商店、回收商店、神器商店、阵营商店、悬赏、修罗,帮派
    self._funcValid = {84,33,34,35,32,73,74,77,76,72,35,84,84,84,84,84}-----元宝、竞技商店、回收商店、神器商店、阵营商店、悬赏、团购/修罗、运镖，帮派,将军府,强化
   -- self._storeTags = {1,12,2,3,4,5,6,8,10,11} ----元宝、竞技商店、回收商店、神器商店、阵营商店、悬赏、团购/修罗,帮派,将军府,强化,鲜花
	if gameUser.getLimitTimeShopState() == 1 then
        self._storeTags = {1,12,7,14,15}
		-- self._storeTags = {1,12,2,3,4,5,6,7,8,10,13}
	else
        self._storeTags = {1,12,14,15}
		-- self._storeTags = {1,12,2,3,4,5,6,8,10,13}
	end

    self._storeLocalDataArray = {
        gameData.getDataFromCSV("yuanbaoShop"),
        gameData.getDataFromCSV("ArenaStore"),
        gameData.getDataFromCSV("RecyclingShop"),
        gameData.getDataFromCSV("SuperWeaponStore"),
        gameData.getDataFromCSV("RaceStore"),
        gameData.getDataFromCSV("XsTaskShop"),
        gameData.getDataFromCSV("TimeShop"),
        gameData.getDataFromCSV("SingleRaceStore"),
        gameData.getDataFromCSV("LiangcaoStoreB"),
        gameData.getDataFromCSV("SectStore"),
        gameData.getDataFromCSV("ServantExchange"),
		gameData.getDataFromCSV("StrengthenShop"),
		gameData.getDataFromCSV("FlowerShop"),
		gameData.getDataFromCSV("WanbaogeStore"),
    }-----元宝、竞技商店、回收商店、神器商店、阵营商店、悬赏、团购/修罗、运镖 帮派
    self._storeRequest = {
        "yuanbaoShopList?",
        "shopList?",
        "smeltExchangeWindow?",
        "beastExchangeList?",
        "campExchangeList?",
        "wantedShopList?",
        "mallList?",
        "asuraSwapWin?",
        "dartRenownSwapWin?",
        "guildExchangeList?",
        "servantExchangeList?",
		"strengthenShopList?",
		"flowerShopList?",
		"weaponWindow?"
    }----元宝、竞技场、回收、神器、阵营、悬赏、团购(服务器原始数据请求),修罗、运镖 帮派
    self._storeExRequest = {
        "yuanbaoShopBuy?",
        "buyRequest?",
        "smeltExchange?",
        "beastExchange?",
        "campExchange?",
        "wantedShopBuy?",
        "buyMallItem?",
        "asuraSwap?",
        "dartRenownSwap?",
        "guildExchange?",
        "servantExchange?",
		"strengthenShopBuy?",
		"flowerShopBuy?",
		"buyWeaponItem?"
    } ----元宝、竞技场、回收、神器、阵营、悬赏、团购(执行商品兑换请求)，修罗、运镖 帮派、元宝
    self._playerResPath = { ----商店对应的消耗资源图标
        IMAGE_KEY_HEADER_INGOT,
        IMAGE_KEY_HEADER_AWARD,
        IMAGE_KEY_HEADER_SMELT,
        IMAGE_KEY_HEADER_SAINTSTONE,
        IMAGE_KEY_HEADER_HONOR,
        IMAGE_KEY_HEADER_OFFERREWARD,
        IMAGE_KEY_HEADER_GOLD,
        IMAGE_KEY_HEADER_BLOOD,        
        IMAGE_KEY_HEADER_PRESTIGE_SMALL,
        IMAGE_KEY_HEADER_CONTRI,
        IMAGE_KEY_HEADER_SERVANTSTONE,
		IMAGE_KEY_HEADER_INGOT,
		IMAGE_KEY_HEADER_FLOWER,
    }
	
	self._playeLablePath = {
		"元宝",
		"奖牌",
		"回收点",
		"神石",
		"荣誉点",
		"悬赏令牌",
		"银两",
		"修罗血",
		"威望",
		"帮派贡献",
		"万灵魂",
		"元宝",
		"鲜花"
	}
	
end

function ShangCheng:create(params,isUpdate,callFunc)
	local store = ShangCheng.new(params,isUpdate,callFunc)
	if store then 
		store:init()
	end 
	return store
end

function ShangCheng:onEnter( )
end

function ShangCheng:onExit( )
	if self._extraCallback and type(self._extraCallback) == "function" then 
		self._extraCallback()
	end 
    RedPointManage:reFreshDynamicItemData()
end

function ShangCheng:onCleanup( )
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
    for k,v in pairs(self._storeCell) do 
        v:release()
    end 
    self._storeCell = {}
end

function ShangCheng:init( )
    local bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
	bg:setPosition(self:getContentSize().width / 2,(self:getContentSize().height - self.topBarHeight) / 2)
    self:addChild(bg)
    self._bg = bg

    local centerBg = cc.Sprite:create("res/image/store/store_bg.png")
    self._bg:addChild(centerBg)
    centerBg:setContentSize(1026,490)
    centerBg:setPosition(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2 - 5)

	local title = "res/image/public/shangdian_title.png"
	XTHD.createNodeDecoration(self._bg,title)

	local figurebg = cc.Sprite:create("res/image/store/figure.png")
	self._bg:addChild(figurebg)
	figurebg:setAnchorPoint(0,0.5)
	figurebg:setPosition(195,self._bg:getContentSize().height *0.5 - 5)
	self._figurebg = figurebg

	local normalnode = cc.Sprite:create("res/image/common/btn/btn_write_up.png")
	normalnode:setContentSize(cc.size(120,60))
	local selectednode = cc.Sprite:create("res/image/common/btn/btn_write_down.png")
	selectednode:setContentSize(cc.size(120,60))
	local refreshbtn = XTHD.createCommonButton({
		text = "立即刷新",
		btnColor = "write_1",
		normalNode = normalnode,
		selectedNode = selectednode,
		isScrollView = true,
		fontSize = 18,
		endCallback = function ()
			self:refreshShenMiStore()
		end
	})
	self._bg:addChild(refreshbtn)
	refreshbtn:setPosition(self._bg:getContentSize().width *0.3 + 20,self._bg:getContentSize().height *0.1)
	self._refreshbtn = refreshbtn
	self._refreshbtn:setVisible(false)

	local iconbg = cc.Sprite:create("res/image/store/shenmiStore/iconbg.png")
	self._bg:addChild(iconbg)
	iconbg:setPosition(self._refreshbtn:getPositionX(),self._refreshbtn:getPositionY() + self._refreshbtn :getContentSize().height *0.5 + 20)
	self._iconbg = iconbg
	self._iconbg:setVisible(false)
	
	local iconNum = XTHDLabel:create(XTHD.resource.getItemNum(2303),18)
	iconNum:setColor(cc.c3b(255,255,255))
	iconbg:addChild(iconNum)
	iconNum:setPosition(iconbg:getContentSize().width *0.5 + 5,iconbg:getContentSize().height *0.5)
	self._iconNum = iconNum
    ------分隔
    -- local _vLine = cc.Sprite:create("res/image/common/common_split_v.png")
    -- _vLine:setScaleY(self._bg:getContentSize().height / _vLine:getContentSize().height)
    -- _vLine:setFlippedX(true)
    -- self._bg:addChild(_vLine)
    -- _vLine:setAnchorPoint(0,0.5)
    -- _vLine:setPosition(122,self._bg:getContentSize().height / 2)

	-------左边的第二层背景    
	local pinkBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_25.png")
	pinkBg:setContentSize(bg:getContentSize().width-160 - figurebg:getContentSize().width *0.5,bg:getContentSize().height-50)
	self._bg:addChild(pinkBg)
    pinkBg:setAnchorPoint(0,0)
	pinkBg:setPosition(193 + figurebg:getContentSize().width *0.5,26)
    --pinkBg:setScale(0.94)
	pinkBg:setOpacity(0)
    self._pinkBg = pinkBg
	
    -------提示
    local _tip = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_WORDS236,XTHD.SystemFont,20)
    self._pinkBg:addChild(_tip)
    _tip:setColor(XTHD.resource.color.gray_desc)
    _tip:setPosition(self._pinkBg:getContentSize().width / 2,self._pinkBg:getContentSize().height / 2)
    self._groupTip = _tip
    ------每个商店的资源栏
	local node = cc.Node:create()
    node:setAnchorPoint(0,1)
	pinkBg:addChild(node,5)
	node:setPosition(pinkBg:getContentSize().height*2 - 65,pinkBg:getContentSize().height - 10)
	self._titleContainer = node

 	self:switchTitleContainer(self._storeIndex)
    ------
	self:initButtonsView()
end

function ShangCheng:initButtonsView()
	local tableView = ccui.ListView:create()
    tableView:setContentSize(150,self._pinkBg:getContentSize().height)
    tableView:setDirection(ccui.ScrollViewDir.vertical)
    tableView:setBounceEnabled(true)
	tableView:setScrollBarEnabled(false)
    tableView:setPosition(10 ,15)
    self._bg:addChild(tableView,1)
    self._buttonList = tableView
    self:loadButtons()
end

function ShangCheng:loadButtons( )	
    for k,v in pairs(self._storeTags) do 
        local a,b = isTheFunctionAvailable(self._funcValid[v])
		if isTheFunctionAvailable(self._funcValid[v]) then 		 
			local layout = ccui.Layout:create()
			layout:setContentSize(cc.size(150,70))
			---------
            local normal = cc.Sprite:create("res/image/store/store_button1.png")
            normal:setContentSize(normal:getContentSize().width + 30,normal:getContentSize().height)
            local _word
            if v == 1 or v == 12 or v == 7 or v == 14 or v == 15 or v == 16 then
                _word = cc.Sprite:create("res/image/store/newname_"..v..".png")
            else
                _word = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_STORENAMES[v],XTHD.SystemFont,22)
                _word:setColor(cc.c3b(152,54,0))
            end 
            normal:addChild(_word)
            _word:setPosition(normal:getContentSize().width / 2,normal:getContentSize().height / 2)
            local selected = cc.Sprite:create("res/image/store/store_button2.png")
            selected:setContentSize(selected:getContentSize().width + 30,selected:getContentSize().height)
            if v == 1 or v == 12 or v == 7 or v == 14 or v == 15 or v == 16 then
                _word = cc.Sprite:create("res/image/store/newname_"..v..".png")
            else
                _word = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_STORENAMES[v],XTHD.SystemFont,22)
                _word:setColor(cc.c3b(32,124,0))
            end 
            selected:addChild(_word)
            _word:setPosition(selected:getContentSize().width / 2,selected:getContentSize().height / 2)            

			local button = XTHD.createPushButtonWithSound({
				normalNode = normal,
				isScrollView = true,
				selectedNode = selected,
				needSwallow = false,
			},3)
			button:setTag(v)
            button.index = k
			button:setTouchEndedCallback(function( )
				self:changeStoreList(button:getTag())
			end)		
			if v == self._storeIndex then 
				self:changeStoreList(v)
			end 
			self._storeButtons[v] = button

			layout:addChild(button)
			button:setPosition(layout:getContentSize().width / 2,layout:getContentSize().height / 2)
			layout:setTag(v)

			self._buttonList:pushBackCustomItem(layout)
		end 
	end 
    self:setTheStoreButtonVisible()
end

function ShangCheng:initStoreView(viewSize,pos)

    local function cellSizeForTable(table,idx)
        --ly
        return viewSize.width,235
    end

    local function numberOfCellsInTableView(table)
		return math.ceil(#self._displayDatas / 3)
    end

    local function scrollViewDidScroll(view)
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
			cell:setContentSize(table:getContentSize().width,105)
        end
	
		if self._storeIndex == 14 then
			if self._storeCell[idx + 1] then
				self._storeCell[idx + 1]:removeFromParent()
			end
			self._storeCell[idx + 1] = nil
		end 		
        local node = self._storeCell[idx + 1]
        if not node then 
            if self._storeIndex == 7 then ---团购商店 
                node = self:loadGroupStores(idx + 1)
				node:setPosition(node:getPositionX(),node:getPositionY() - 5)
			elseif self._storeIndex == 14 then
				node = self:loadShenMiStores(idx)
				node:setPosition(node:getPositionX(),node:getPositionY() - 5)
            else 
            	node = self:loadStores(idx)
				node:setPosition(node:getPositionX(),node:getPositionY() - 5)
            end 
            node:retain()
            self._storeCell[idx + 1] = node
        else 
            node:removeFromParent()
        end 
        if node then 
            cell:addChild(node)
        end 
        return cell
    end

    self._storeList = cc.TableView:create(viewSize)
    self._storeList:setPosition(pos)
    self._storeList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._storeList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._storeList:setDelegate()
    self._pinkBg:addChild(self._storeList,0)

    self._storeList:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._storeList:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._storeList:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._storeList:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
end

function ShangCheng:changeStoreList( index )
    if not self._canChangeStore then 
        return 
    end 
	if index == 11 then
		XTHDTOAST("侍仆商店暂未开放，敬请期待！")
		return
	end
	
    self._canChangeStore = false
    --ly
    local _size = cc.size(self._pinkBg:getContentSize().width,self._pinkBg:getContentSize().height - 13)
    local pos = cc.p(0,2)
    -- self:showMultiTypeLabels(false)
    if not self._storeList then 
        self:initStoreView(_size,pos)
    end     
    self._storeLocalData = self._storeLocalDataArray[index]
    self:stopActionByTag(self.Tag.ktag_countDown)

	if index == 15 then
		self._canChangeStore = true
		if self._selectedButton then 
            self._selectedButton:setSelected(false)
        end 
		self._storeButtons[index]:setSelected(true)
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function() 
			self._storeIndex = index
			self._selectedButton = self._storeButtons[index]
			self._refreshbtn:setVisible(false)
			self._iconbg:setVisible(false)
			self._figurebg:setVisible(false)
			self._storeList:setVisible(false)
			self:createOtherStore()
		end)))	
		return
	else
		self:requestServerDatas(index,function()
			if self._OtherShopNode then
				self._OtherShopNode:removeFromParent()
				self._OtherShopNode = nil
			end
			
			self._storeList:setVisible(true)
			self._figurebg:setVisible(true)
			if (index == 7 and self._storeIndex ~= index) or (self._storeIndex == 7 and index ~= 7) or (index == 7 and self._storeIndex == 7) then -----仅当在团购商店与其它商店切换的时候刷新顶部信息
				self:switchTitleContainer(index)
			else 
	--            self._playerResIcon:setTexture(self._playerResPath[index])     
				if index == 13 then
	--                self._playerResIcon:setScale(0.7)
				else
	--                self._playerResIcon:setScale(1)
				end 
			end 
			self._storeIndex = index
			if self._selectedButton then 
				self._selectedButton:setSelected(false)
			end 
			self._storeButtons[index]:setSelected(true)
			if self._storeIndex ~= 14 then
				self._refreshbtn:setVisible(false)
				self._iconbg:setVisible(false)
			else
				self._refreshbtn:setVisible(true)
				self._iconbg:setVisible(true)
			end

			self._selectedButton = self._storeButtons[index]

			self._displayDatas = self:selecteDataByTab()
        
			self:createStoreCellBat()
			self._storeList:reloadData()
			self:refreshGroupStoreTitle()
		end)
	end
end

function ShangCheng:showMultiTypeLabels( isDisplay )
    -- if isDisplay then 
    --     if not self._labelTabContainer then 
    --         local node = cc.Node:create()
    --         node:setContentSize(cc.size(self._pinkBg:getContentSize().width - 4,40))
    --         self._pinkBg:addChild(node,2)
    --         node:setPosition(3,2)
    --         self._labelTabContainer = node
    --     end         
    --     self._labelTabContainer:setVisible(true)
    --     self._labelTabContainer:removeAllChildren()
    --     ----横线
    --     local _line = ccui.Scale9Sprite:create("res/image/common/scale_line.png")
    --     _line:setContentSize(cc.size(self._labelTabContainer:getContentSize().width - 4,1))     
    --     self._labelTabContainer:addChild(_line)
    --     _line:setPosition(self._labelTabContainer:getContentSize().width / 2,self._labelTabContainer:getContentSize().height - _line:getContentSize().height / 2)
    --     local x = self._labelTabContainer:getContentSize().width 
    --     for i = 4,1,-1 do 
    --         local _tabBtn = XTHD.createPushButtonWithSound({
    --             normalFile = "res/image/store/store_tab_bg2.png",
    --             selectedFile = "res/image/store/store_tab_bg1.png",
    --             needSwallow = true,             
    --         },3)
    --         _tabBtn:setTag(i)
    --         _tabBtn:setTouchEndedCallback(function( )
    --             _tabBtn:setSelected(true)
    --             if self._selectedLabel then 
    --                 self._selectedLabel:setSelected(false)                  
    --             end 
    --             self._selectedLabel = _tabBtn
    --             self._goodsType = _tabBtn:getTag()
    --             self._displayDatas = self:selecteDataByTab()
    --             self:createStoreCellBat()
    --             self._storeList:reloadData()
    --         end)
    --         self._labelTabContainer:addChild(_tabBtn)
    --         _tabBtn:setAnchorPoint(1,1)
    --         _tabBtn:setPosition(x,self._labelTabContainer:getContentSize().height)
    --         x = x - _tabBtn:getContentSize().width - 2
    --         ------类型名
    --         local _name = cc.Sprite:create("res/image/store/store_type_"..i..".png")
    --         if self._storeIndex == 6 then -------团购
    --             _name = cc.Sprite:create("res/image/store/store_type2"..i..".png")
    --         end 
    --         _tabBtn:addChild(_name)
    --         _name:setPosition(_tabBtn:getContentSize().width / 2,_tabBtn:getContentSize().height / 2)
    --         if i == 1 then 
    --             _tabBtn:setSelected(true)
    --             self._selectedLabel = _tabBtn
    --             self._goodsType = _tabBtn:getTag()
    --         end             
    --     end 
    -- else 
    --     if self._labelTabContainer then 
    --         self._labelTabContainer:setVisible(false)
    --     end 
    -- end 
end
------批量生成商店cel
function ShangCheng:createStoreCellBat( )
    for k,v in pairs(self._storeCell) do 
        v:release()
    end 
    self._storeCell = {}
end

function ShangCheng:refreshBuyLabel()
	
end

--神秘商店
function ShangCheng:loadShenMiStores(index)
	local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(self._storeList:getContentSize().width,215))  

	local _index = 0
	for i = (index + 1) * 3 - 2,(index + 1) * 3 do
		_index = _index + 1
		
        local data = self._displayDatas[i]
		
    	if not data then 
    		return layout
    	end 
		local _bg = ccui.Scale9Sprite:create("res/image/store/cellBg.png")
    	layout:addChild(_bg)
		_bg:setScale(1.05)
    	_bg:setPosition(_bg:getContentSize().width *0.5 + 5 + ((_index-1) * (_bg:getContentSize().width + 44)),layout:getContentSize().height / 2 + 20)

		local _type = 4
        local _itemID = data.localD.itemid
        local _amount = data.localD.num
		local icon = ItemNode:createWithParams({
            _type_ = _type,
            itemId = _itemID,
            count = _amount,
        })
        _bg:addChild(icon)
		icon:setScale(0.7)
        icon:setAnchorPoint(0.5,0.5)
		
		if data.serverD.tuijian == 1 then
			local recommended = cc.Sprite:create("res/image/store/shenmiStore/activity_tips_tag_tuijian.png")
            recommended:setAnchorPoint(0.5,0.5)
            recommended:setPosition(recommended:getContentSize().width *0.5 + 3,_bg:getContentSize().height - recommended:getContentSize().height *0.5 - 43)
            _bg:addChild(recommended)
		end
        --ly
        local itemName = XTHDLabel:createWithParams({
            text = icon._Name,
            fontSize = 22,
            color = cc.c3b(255,255,200),
            ttf = "res/fonts/hkys.ttf",
            anchor = cc.p(0.5,0.5)
        })
		itemName:enableOutline(cc.c4b(30,0,0,255),1)
        itemName:setScale(0.8)
        itemName:setPosition(_bg:getContentSize().width *0.5,_bg:getContentSize().height - itemName:getContentSize().height *0.5 - 18.5)
        _bg:addChild(itemName) 

		self._selectedName = icon._Name  
		icon:setPosition(_bg:getContentSize().width *0.5,_bg:getContentSize().height * 0.6 - 8)

		--消耗道具
		local __data = string.split(data.localD.price,"#")
		local item_img = nil
		print("=====================",tostring(__data[1]),XTHD.resource.type.ingot)
		if tonumber(__data[1]) == XTHD.resource.type.ingot then
			item_img = IMAGE_KEY_HEADER_INGOT
		elseif tonumber(__data[1]) == XTHD.resource.type.gold then
			item_img = IMAGE_KEY_HEADER_GOLD
		elseif tonumber(__data[1]) == XTHD.resource.type.feicui then
			item_img = IMAGE_KEY_HEADER_FEICUI
		end
		local xiaohao_icon = cc.Sprite:create(item_img)
		_bg:addChild(xiaohao_icon)
		xiaohao_icon:setAnchorPoint(0,0.5)
		xiaohao_icon:setPosition(25,xiaohao_icon:getContentSize().height *0.5 + 20)

		local xiaohao_numLable = XTHDLabel:create(__data[3],16,"res/fonts/def.ttf")
		_bg:addChild(xiaohao_numLable)
		xiaohao_numLable:setColor(cc.c3b(255,255,200))
		xiaohao_numLable:enableOutline(cc.c4b(30,0,0,255),1)
		xiaohao_numLable:setAnchorPoint(0,0.5)
		xiaohao_numLable:setPosition(xiaohao_icon:getContentSize().width + xiaohao_icon:getPositionX() + 5,xiaohao_icon:getPositionY() - 3)
		
		local btn = XTHDPushButton:createWithParams({
			touchSize =cc.size(_bg:getContentSize().width,_bg:getContentSize().height - 30),
			needEnableWhenMoving = true,
			musicFile = XTHD.resource.music.effect_btn_common,
		})

		btn:setTag(index)
		_bg:addChild(btn)
		btn:setPosition(_bg:getContentSize().width*0.5,_bg:getContentSize().height *0.5 - 5)
		btn:setTouchBeganCallback(function()
			_bg:setScale(0.98)
		end)

		btn:setTouchMovedCallback(function()
			_bg:setScale(1)
		end)

		btn:setTouchEndedCallback(function()
			_bg:setScale(1)
			self:doExchange(data,btn:getTag(),_bg,nil,i)
		end)

		if data.serverD.state == 1 then
			local Sold = cc.Sprite:create("res/image/plugin/weaponshop/weapon_sold.png")
            Sold:setPosition(_bg:getBoundingBox().width*0.5 - 5,_bg:getBoundingBox().height*0.5 - 10)
            _bg:addChild(Sold)
            Sold:setContentSize(_bg:getContentSize().width - 10,_bg:getContentSize().height - 30)

            local SoldLabel = cc.Sprite:create("res/image/plugin/weaponshop/sold.png")
            SoldLabel:setAnchorPoint(0.5,0.5)
            SoldLabel:setPosition(_bg:getContentSize().width *0.5,_bg:getContentSize().height *0.5)
            _bg:addChild(SoldLabel)

            btn:setEnable(false)
		end
	end
	return layout
end

function ShangCheng:loadStores(index)
    local layout = ccui.Layout:create()
    --ly
    layout:setContentSize(cc.size(self._storeList:getContentSize().width,215))  
	local _index = 0	

    for i = (index + 1) * 3 - 2,(index + 1) * 3 do
		_index = _index + 1
		
        local data = self._displayDatas[i]
    	if not data then 
    		return layout
    	end 
    	---------背景
    	local _bg = ccui.Scale9Sprite:create("res/image/store/cellBg.png")
    	layout:addChild(_bg)
		_bg:setScale(1.05)
    	_bg:setPosition(_bg:getContentSize().width *0.5 + 5 + ((_index-1) * (_bg:getContentSize().width + 44)),layout:getContentSize().height / 2 + 20)
        -------图标
        local _type = 4
        local _itemID = data.localD.itemid
        local _amount = data.localD.num
        if self._storeIndex == 4 or self._storeIndex == 5 or self._storeIndex == 10 or self._storeIndex == 11 then 
            _type = data.localD.resourcetype
            _itemID = data.localD.resourceid
        end 
        local icon = ItemNode:createWithParams({
            _type_ = _type,
            itemId = _itemID,
            count = _amount,
        })
        _bg:addChild(icon)
		icon:setScale(0.7)
        icon:setAnchorPoint(0.5,0.5)
        --ly
        local itemName = XTHDLabel:createWithParams({
            text = icon._Name,
            fontSize = 22,
            color = cc.c3b(255,255,200),
            ttf = "res/fonts/hkys.ttf",
            anchor = cc.p(0.5,0.5)
        })
		itemName:enableOutline(cc.c4b(30,0,0,255),1)
        itemName:setScale(0.8)
        itemName:setPosition(_bg:getContentSize().width *0.5,_bg:getContentSize().height - itemName:getContentSize().height *0.5 - 18.5)
        _bg:addChild(itemName) 

		self._selectedName = icon._Name    
		
        icon:setPosition(_bg:getContentSize().width *0.5,_bg:getContentSize().height * 0.6 - 8)
        -----消耗
        local _costLabel = XTHDLabel:createWithParams({
            text = "",
            fontSize = 18,
            color = cc.c3b(128,112,91)
        })
        _bg:addChild(_costLabel)
        _costLabel:setAnchorPoint(cc.p(0,0.5))
        _costLabel:setPosition(icon:getPositionX() - icon:getBoundingBox().width + 15,_bg:getContentSize().height *0.15 + 5)

        local consumePath = IMAGE_KEY_HEADER_INGOT
        local consumeNum = 0
        local isIgnot = false

        if data.localD.goldprice and data.localD.goldprice ~= 0 then
        	consumePath = IMAGE_KEY_HEADER_GOLD
        	consumeNum = data.localD.goldprice
        end
        if data.localD.jadeprice and data.localD.jadeprice ~= 0 then
        	consumePath = IMAGE_KEY_HEADER_FEICUI
        	consumeNum = data.localD.jadeprice
        end
        if data.localD.ingotprice and data.localD.ingotprice ~= 0 then
        	consumePath = IMAGE_KEY_HEADER_INGOT
            consumeNum = data.localD.ingotprice
            isIgnot = true
        end
		local _playerResLabel = nil
        local x = _costLabel:getPositionX() + _costLabel:getContentSize().width + 20
        for j = 1,2 do
            local price = 0
            if self._storeIndex == 4 or self._storeIndex == 5 or self._storeIndex == 10 or self._storeIndex == 11 then 
                price = data.localD["num"..j] 
			else
                price = (j == 1 and data.localD.coinprice or consumeNum) 
                if isIgnot == true and j > 1 then
                    price = 0
                end    
				if self._storeIndex == 12 and j == 2 then
					price = 0
				end
            end 
 
            if price > 0 then 
                price = getHugeNumberWithLongNumber(price,10000)
                local consumeIcon,numLabel
                if self._storeIndex == 4 or self._storeIndex == 5 or self._storeIndex == 11 then 
                    consumeIcon = XTHD.createHeaderIcon(data.localD["type"..j])
                    numLabel = XTHDLabel:create(price,16,"res/fonts/def.ttf")
				elseif self._storeIndex == 12 then
					consumeIcon = cc.Sprite:create(consumePath)
					numLabel = XTHDLabel:create(price,16,"res/fonts/def.ttf")
                else
					consumeIcon = cc.Sprite:create(j == 1 and self._playerResPath[self._storeIndex] or consumePath)
                    if self._storeIndex == 13 then
                        consumeIcon:setScale(0.7)
                    else
                        consumeIcon:setScale(1)
                    end
					numLabel = XTHDLabel:create(price,16,"res/fonts/def.ttf")          
                end 
                --消耗框
                local rewardBg = ccui.Scale9Sprite:create()
                rewardBg:setContentSize(cc.size(90,24))                    
                rewardBg:setAnchorPoint(cc.p(0,0.5))
                rewardBg:setPosition(x,_costLabel:getPositionY())
                _bg:addChild(rewardBg)

                consumeIcon:setPosition(0,rewardBg:getBoundingBox().height/2)
                rewardBg:addChild(consumeIcon)
				
				numLabel:setColor(cc.c3b(255,255,200))
				numLabel:enableOutline(cc.c4b(30,0,0,255),1)
				numLabel:setAnchorPoint(0,0.5)
                numLabel:setPosition(consumeIcon:getContentSize().width *0.5 + consumeIcon:getPositionX() + 5,consumeIcon:getPositionY() - 3)
                rewardBg:addChild(numLabel)

            	x = x + rewardBg:getBoundingBox().width
            end 
        end

        ------兑换次数
        local changeTime = XTHDLabel:createWithParams({
            text = LANGUAGE_KEY_EXCHANGETIMES..":",----"兑换次数：",
            fontSize = 18,
            color = cc.c3b(128,112,91)
        })

        if self._storeIndex == 1 then
            changeTime:setString("剩余购买次数:")
        end

		if self._storeIndex == 12 then
			changeTime:setString("剩余购买数量:")
		end

        changeTime:setAnchorPoint(0,0.5)
--        changeTime:setPosition(0,_bg:getBoundingBox().height - changeTime:getContentSize().height - 5)
--        _bg:addChild(changeTime)

        local _count = data.serverD.count
        if self._storeIndex == 4 or self._storeIndex == 5 or self._storeIndex == 10 or self._storeIndex == 11 then 
            _count = data.serverD.exchangeSum
        elseif self._storeIndex == 6 then 
            _count = data.serverD.surplusCount      
        end 
        local changeLabel = XTHDLabel:createWithParams({
            text = _count,
            fontSize = 18,
            color = cc.c3b(129,0,0)
        })
        changeLabel:setAnchorPoint(0,0.5)
		if self._storeIndex == 13 and _count == nil then
			changeLabel:setString("无限")
		end

        _bg.exchangeTimesL = changeLabel

		local node = cc.Node:create()
		node:setAnchorPoint(0,0.5)
		node:setContentSize(changeTime:getContentSize().width + changeLabel:getContentSize().width + 10,changeTime:getContentSize().height + 10 )
		node:addChild(changeTime)
		node:addChild(changeLabel)
		changeTime:setPosition(5,node:getContentSize().height*0.5)
		changeLabel:setPosition(5 + changeTime:getContentSize().width, changeTime:getPositionY())

		_bg:addChild(node)
		node:setPosition(_bg:getContentSize().width - node:getContentSize().width - 5,_bg:getContentSize().height - node:getContentSize().height + 5)
		node:setVisible(false)
        -------不可兑换的时候，
        local _word = nil
        if self._storeIndex == 2 and gameUser.getDuanId() < tonumber(data.localD.rank) then ---竞技场
            changeTime:setVisible(false)
            changeLabel:setVisible(false)
            local _rankList = gameData.getDataFromCSV("CompetitiveDaily")
            _word = LANGUAGE_KEY_STORE_CANEXCHANGE(_rankList[data.localD.rank].rankname) ---"可兑换",
        elseif self._storeIndex == 3 and tonumber(data.localD.lv) > gameUser.getLevel() then ----回收
            changeTime:setVisible(false)
            changeLabel:setVisible(false)
            _word = LANGUAGE_KEY_NEEDLEVEL(data.localD.lv) ---需求等级
        elseif self._storeIndex == 4 and tonumber(data.serverD.tongguan) == 0 then ----神器
            changeTime:setVisible(false)
            changeLabel:setVisible(false)
            if data.localD.exchange ~= 0 then 
                local _temp = gameData.getDataFromCSV("SuperWeaponList")
                _word = LANGUAGE_KEY_STORE_CANEXCHANGE(_temp[data.localD.exchange].chptername) ------"可兑换",
            end 
        elseif self._storeIndex == 5 and tonumber(self._storeServerData.totalForce) < tonumber(data.localD.exchangeneed) then -----阵营
            changeTime:setVisible(false)
            changeLabel:setVisible(false)
            _word = LANGUAGE_CAMP_TIPSWORDS2(tonumber(data.localD.exchangeneed)) -----需要势力点
        elseif self._storeIndex == 6 and tonumber(data.localD.viplevel) > tonumber(gameUser.getVip()) then ----悬赏
            changeTime:setVisible(false)
            changeLabel:setVisible(false)
            _word = "Vip3以上才可兑换" -----需要Vip等级
        elseif self._storeIndex == 10 and self._storeServerData.totalContribution < data.localD.exchangeneed then ------帮派
            changeTime:setVisible(false)
            changeLabel:setVisible(false)
            _word = LANGUAGE_TIPS_NEEDCONTRIBUTION(data.localD.exchangeneed)
        elseif self._storeIndex == 1 or self._storeIndex == 12 then
            changeLabel:setString(data.serverD.count)
        elseif self._storeIndex == 11 and tonumber(data.serverD.tongguan) == 0 then ----侍仆
            changeTime:setVisible(false)
            changeLabel:setVisible(false)
            if data.localD.exchange ~= 0 then 
                local _temp = gameData.getDataFromCSV("ServantOpenList")
                _word = LANGUAGE_KEY_STORE_CANEXCHANGE(_temp[data.localD.exchange].chptername) ------"可兑换",
            end 
        end 
        if _word then
            local unlockSection = XTHDLabel:createWithParams({
                text = _word,
                fontSize = 18,
                color = XTHD.resource.color.red_desc
            })
            unlockSection:setAnchorPoint(0,0.5)
            unlockSection:setPosition(_bg:getContentSize().width - unlockSection:getContentSize().width - 25,_bg:getContentSize().height - unlockSection:getContentSize().height - 5)
            _bg:addChild(unlockSection)
        end

		local btn = XTHDPushButton:createWithParams({
			touchSize =cc.size(_bg:getContentSize().width,_bg:getContentSize().height - 30),
			needEnableWhenMoving = true,
			musicFile = XTHD.resource.music.effect_btn_common,
		})
		btn:setTag(index)
		_bg:addChild(btn)
		btn:setPosition(_bg:getContentSize().width*0.5,_bg:getContentSize().height *0.5 - 5)
		btn:setTouchBeganCallback(function()
			_bg:setScale(0.98)
		end)

		btn:setTouchMovedCallback(function()
			_bg:setScale(1)
		end)

		btn:setTouchEndedCallback(function()
			_bg:setScale(1)
			if self._storeIndex == 1 or self._storeIndex == 12 then
                local popLayer = requires("src/fsgl/layer/YingXiong/BuyExpByIngotPopLayer1.lua")
				if self._storeIndex == 1 then
					self.buyType = 2
				else
					self.buyType = 4
				end       
                self.configId = data.localD.id
				data.localD.numLabel = _bg.exchangeTimesL
				data.localD.payM = self._storeExRequest[self._storeIndex] 
				data.localD.sCount = tonumber(data.localD.numLabel:getString()) or data.localD.numLabel:getString()
                self.data = data.localD
                popLayer= popLayer:create(data.localD.itemid, self,self._isUpdate,self._callFunc)
                popLayer:setName("BuyExpPop")
                self:addChild(popLayer)
            else
				self:doExchange(data,btn:getTag(),_bg,icon._Name)
            end
		end)

        pos = layout:getContentSize().width * 3/4
    end 
    return layout
end
------加载团购限时商品
function ShangCheng:loadGroupStores(index)
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(self._storeList:getContentSize().width,215))  
    
	local _index = 0
	--self._displayDatas[idx + 1]
    for i = index *3 - 2,index * 3 do
		_index = _index + 1
		local data = self._displayDatas[i]
		if not data then 
			return layout
		end 

		local _bg = ccui.Scale9Sprite:create("res/image/store/cellBg.png")
		layout:addChild(_bg)
		_bg:setScale(1.05)
		_bg:setPosition(_bg:getContentSize().width *0.5 + 5 + ((_index-1) * (_bg:getContentSize().width + 44)),layout:getContentSize().height / 2 + 20)
		
		-------图标
		local icon = ItemNode:createWithParams({
			_type_ = data.localD.resourcetype,
			itemId = data.localD.resourceid,
			count = data.localD.num,
		})
		_bg:addChild(icon)
		icon:setScale(0.7)
		icon:setAnchorPoint(0.5,0.5)
		icon:setPosition(_bg:getContentSize().width *0.5,_bg:getContentSize().height / 2 + 12.5)
	
		-----打折图片
		local discount = (data.localD.dazhe * 10)
		if discount > 0 then 
			local _discount = cc.Sprite:create("res/image/store/store_discount"..discount..".png")
			_bg:addChild(_discount)
			_discount:setAnchorPoint(0,0)
			_discount:setPosition(4,_bg:getContentSize().height *0.5 + 5)
		end 
	
		-----线们
--		local _lineV = cc.Sprite:create("res/image/guild/guild_verticalLine.png")
--		_bg:addChild(_lineV)
--		_lineV:setScaleY((_bg:getBoundingBox().height - 6) / _lineV:getContentSize().height)
--		_lineV:setPosition(icon:getBoundingBox().width + icon:getPositionX() + 5,_bg:getBoundingBox().height / 2)
--		local _lineH = cc.Sprite:create("res/image/guild/guild_horizontalLine.png")
--		_bg:addChild(_lineH)
--		_lineH:setScaleX((_bg:getBoundingBox().width - _lineV:getPositionX() - 10) / _lineH:getContentSize().width)
--		_lineH:setAnchorPoint(0,0.5)
--		_lineH:setPosition(_lineV:getPositionX(),_bg:getBoundingBox().height / 2)
	
		------名字
		local itemName = XTHDLabel:createWithParams({
			text = icon._Name,
            fontSize = 22,
            color = cc.c3b(255,255,200),
            ttf = "res/fonts/hkys.ttf",
            anchor = cc.p(0.5,0.5)
		})
		itemName:enableOutline(cc.c4b(30,0,0,255),1)
        itemName:setScale(0.8)
        itemName:setPosition(_bg:getContentSize().width *0.5,_bg:getContentSize().height - itemName:getContentSize().height *0.5 - 18.5)
        _bg:addChild(itemName) 

		local btn = XTHDPushButton:createWithParams({
			touchSize =cc.size(_bg:getContentSize().width,_bg:getContentSize().height - 30),
			needEnableWhenMoving = true,
			musicFile = XTHD.resource.music.effect_btn_common,
		})

		btn:setTag(index)
		_bg:addChild(btn)
		btn:setPosition(_bg:getContentSize().width*0.5,_bg:getContentSize().height *0.5 - 5)
		btn:setTouchBeganCallback(function()
			_bg:setScale(0.98)
		end)

		btn:setTouchMovedCallback(function()
			_bg:setScale(1)
		end)

		btn:setTouchEndedCallback(function()
			_bg:setScale(1)
			self:doExchange(data,btn:getTag(),_bg)
		end)
	
		-----获取按钮
		local getBtn = XTHD.createCommonButton({
			text = "购买",
			fontSize = 23,
			isScrollView = true,
			fontColor = cc.c3b(255,255,255),
			needSwallow = false,
			needEnableWhenMoving = true,
		})
		getBtn:setTag(index)    
		getBtn:setTouchSize(cc.size(getBtn:getBoundingBox().width,getBtn:getBoundingBox().height + 20))
		getBtn:setTouchEndedCallback(function(  )
			self:doExchange(data,getBtn:getTag(),_bg)
		end)
		getBtn:setVisible(false)
		getBtn:setScale(0.6)
		getBtn:setAnchorPoint(1,0.5)                
		getBtn:setPosition(_bg:getBoundingBox().width - 15,getBtn:getContentSize().height / 2 - 5)
		_bg:addChild(getBtn)

--		-----购买条件
--		local vip = data.localD.vip
--		local lv = data.localD.lv
--		local str = ""
--		if tonumber(vip) > 0 and tonumber(lv) > 0 then 
--			str = LANGUAGE_FORMAT_TIPS45(vip,lv)
--		elseif tonumber(vip) > 0 and tonumber(lv) <= 0 then 
--			str = LANGUAGE_FORMAT_TIPS47(vip)
--		elseif tonumber(vip) <= 0 and tonumber(lv) > 0 then     
--			str = LANGUAGE_FORMAT_TIPS46(lv)
--		end 
--		local _tips = XTHDLabel:createWithParams({
--			text = str,
--			fontSize = 18,
--			color = cc.c3b(128,112,91)
--		})
--		_bg:addChild(_tips)
--		_tips:setAnchorPoint(1,0.5)
--		_tips:setPosition(getBtn:getPositionX() - getBtn:getBoundingBox().width - 3,getBtn:getPositionY())

		------当前个人购买次数
		local _count = data.serverD.selfSurplusCount
--		local changeLabel = XTHDLabel:createWithParams({
--			text = _count,
--			fontSize = 20,
--			color = cc.c3b(129,0,0)
--		})
--		changeLabel:setAnchorPoint(1,0.5)
--		changeLabel:setPosition(_bg:getBoundingBox().width - 15,_bg:getBoundingBox().height * 3/4)
--		_bg:addChild(changeLabel)
--		_bg.exchangeTimesL = changeLabel

--		local changeTime = XTHDLabel:createWithParams({
--			text = "个人"..LANGUAGE_TIP_BUYTIMES..":",----"购买次数",
--			fontSize = 18,
--			color = cc.c3b(128,112,91)
--		})
--		changeTime:setAnchorPoint(1,0.5)
--		changeTime:setPosition(changeLabel:getPositionX() - changeLabel:getBoundingBox().width,changeLabel:getPositionY())
--		_bg:addChild(changeTime)

		------当前全服剩余次量
		_count = data.serverD.allSurplusCount
		_count = (_count == nil or _count < 0) and 0 or _count
--		local allChangeL = XTHDLabel:createWithParams({
--			text = _count,
--			fontSize = 20,
--			color = cc.c3b(129,0,0)
--		})
--		allChangeL:setAnchorPoint(1,0.5)
--		allChangeL:setPosition(changeTime:getPositionX() - changeTime:getBoundingBox().width - 15,changeTime:getPositionY())
--		_bg:addChild(allChangeL)
--		_bg.serverLeftTimesL = allChangeL

--		local allChangeT = XTHDLabel:createWithParams({
--			text = LANGUAGE_TIP_REST_EXCAHNGETIMS..":",----"全服剩余购买次数：",
--			fontSize = 18,
--			color = cc.c3b(128,112,91)
--		})
--		allChangeT:setAnchorPoint(1,0.5)
--		allChangeT:setPosition(allChangeL:getPositionX() - allChangeL:getBoundingBox().width,allChangeL:getPositionY())
--		_bg:addChild(allChangeT)

		local x = itemName:getPositionX() - itemName:getContentSize().width *0.5
		local y = -10
		for j = 1,2 do
			-----原价
			if j == 1 then
				local _costLabel = XTHDLabel:createWithParams({
					text = "原价：",
					fontSize = 18,
					color = cc.c3b(191,138,91)
				})
				--_bg:addChild(_costLabel)
				_costLabel:setAnchorPoint(cc.p(0,0.5))
				_costLabel:setPosition(_bg:getContentSize().width *0.2,y)

				local consumeNum = data.localD.ingotprice --(j == 1 and  or data.localD.ingotprice2)

				consumeNum = getHugeNumberWithLongNumber(consumeNum,10000)
				local numLabel = getCommonWhiteBMFontLabel(consumeNum)
				numLabel:setAnchorPoint(0,0.5)
				--_bg:addChild(numLabel)
				numLabel:setScale(0.8)
				numLabel:setPosition(_costLabel:getPositionX() + _costLabel:getContentSize().width,_costLabel:getPositionY() - 5)

				local node = cc.Node:create()
				node:setAnchorPoint(0.5,0.5)
				_bg:addChild(node)
				node:setContentSize(_costLabel:getContentSize().width + numLabel:getContentSize().width + 10,numLabel:getContentSize().height + 10)
				node:setPosition(_bg:getContentSize().width *0.5,y)

				node:addChild(_costLabel)
				node:addChild(numLabel)
				
				_costLabel:setPosition(5,node:getContentSize().height *0.5)
				numLabel:setPosition(_costLabel:getPositionX() + _costLabel:getContentSize().width - 5,node:getContentSize().height *0.5 - 5)
				
				local _line = cc.Sprite:create("res/image/common/line_2.png")
				_line:setContentSize(_costLabel:getContentSize().width + numLabel:getContentSize().width + 10,2)
				node:addChild(_line)
				_line:setAnchorPoint(0.5,0.5)
				_line:setPosition(node:getContentSize().width *0.5,node:getContentSize().height *0.5)
			else
				
				local icon = cc.Sprite:create(IMAGE_KEY_HEADER_INGOT)
				icon:setAnchorPoint(0,0.5)
				icon:setPosition(5 + icon:getContentSize().width *0.5,_bg:getContentSize().height *0.15 + 5)
                _bg:addChild(icon)

				local consumeNum = data.localD.ingotprice2 --(j == 1 and  or data.localD.ingotprice2)
				consumeNum = getHugeNumberWithLongNumber(consumeNum,10000)
				local numLabel = XTHDLabel:create(consumeNum,16,"res/fonts/def.ttf")
				numLabel:setAnchorPoint(0,0.5)
				_bg:addChild(numLabel)
				numLabel:setColor(cc.c3b(255,255,200))
				numLabel:enableOutline(cc.c4b(30,0,0,255),1)
				numLabel:setPosition(icon:getPositionX() + icon:getContentSize().width + 5,icon:getPositionY() - 2)
			end

			if data.localD.dazhe == 0 then 
				break
			else 
				
			end 
		end
	end
    return layout
end

function ShangCheng:requestServerDatas(index,callback)
    -- if index == 10 then 
    --     self._canChangeStore = true
    --     if self._titleContainer then 
    --         self._titleContainer:setVisible(true)
    --     end 
    --     if callback then 
    --         callback()
    --     end
    --     return 
    -- end
    XTHDHttp:requestAsyncInGameWithParams({
        modules = self._storeRequest[index],
        successCallback = function(data)        
            self._canChangeStore = true
            if tonumber(data.result) == 0 then
                if self._titleContainer then 
                    self._titleContainer:setVisible(true)
                end 
                if self._storeIndex == 10 then ------帮派
                    gameUser.setGuildPoint(data.totalContribution)
                end 

            	self._storeServerData = data  
            	if callback then 
            		callback()
            	end                 
                self:isHideGroupShop(false)
            else
                -- if self._titleContainer then 
                --     self._titleContainer:setVisible(false)
                -- end 
                -- self._storeServerData = nil
                self._displayDatas = {}
                if self._storeIndex == 7 then ----团购商店
                    self:isHideGroupShop(true)
                end 
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            self._canChangeStore = true
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调
        loadingParent = self,        
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ShangCheng:selecteDataByTab( ) ----把商品按钮良品、高级等分出来
    local data = {}
    if self._storeServerData then 
    	local _value = {
            gameUser.getIngot(),                         --玩家元宝
            self._storeServerData.medal or 0, -----竞技场
            self._storeServerData.smeltPoint or 0, ----回收
            gameUser.getSaintStone(), ---神器
            self._storeServerData.honor or 0, ---阵营
            gameUser.getBounty(),---悬赏
            "", -----团购
            gameUser.getAsura(), --修罗
            gameUser.getReputation(),----运镖
            self._storeServerData.totalContribution or 0,---帮派贡献点
            gameUser.getServant(),  --万灵魂
			gameUser.getIngot(),
			gameUser.getFlower(), 
    	}
--    	if self._playerResAmount and self._storeIndex ~= 7 then
--    		self._playerResAmount:setString(_value[self._storeIndex])
--    	end 
		if self._storeIndex == 14 then
			self._storeServerData.items = self:SortList(self._storeServerData.items)
			for k,v in pairs(self._storeServerData.items) do 
    			local _local = self._storeLocalData[tonumber(v.configId)]		
				 if _local then 
					 data[#data + 1] = {localD = _local,serverD = v}
				 end
    		end
		else
    		for k,v in pairs(self._storeServerData.list) do 
    			local _local = self._storeLocalData[tonumber(v.configId)]		
				 if _local then 
					 data[#data + 1] = {localD = _local,serverD = v}
				 end
    			-- if self._storeIndex == 1 or self._storeIndex == 2 or self._storeIndex == 5 or self._storeIndex == 6 then 
    			-- 	if _local and _local.tab == self._goodsType then 
    			-- 		data[#data + 1] = {localD = _local,serverD = v}
    			-- 	end
    			-- else 
    			-- 	if _local then 
    			-- 		data[#data + 1] = {localD = _local,serverD = v}
    			-- 	end
    			-- end  
    		end 
			table.sort( data,function(a,b)
			   return a.serverD.configId < b.serverD.configId
			end)
		end
    end 
    
    return data
end

function ShangCheng:doExchange( storeData,index,targ, name,_index)
	if not storeData then 
		return 
	end 
	local param = {configId = storeData.localD.id}
	if self._storeIndex == 2 then 
		param.count = 1
	elseif self._storeIndex == 3 or self._storeIndex == 12 then 
		param.sum = 1
	end

	local text =  self:getNumTable(storeData,name,index)
	
	local rightFunc = function()
		if self._storeIndex == 14 then
			XTHDHttp:requestAsyncInGameWithParams({
				modules = self._storeExRequest[self._storeIndex],
				params = {configId = storeData.localD.id},
				successCallback = function(data)
					if tonumber(data.result) == 0 then
						dump(data)
            			gameUser.updateDataById(402,data.gold)
						gameUser.updateDataById(403,data.ingot)
						gameUser.updateDataById(418,data.feicui)
						if data.items then
							local show_data = {}
							for i = 1,#data.items do
								local _data = data.items[i]
								local num = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _data.itemId}).count or 0
								local num2 = _data.count - num
								show_data[#show_data+1] = {rewardtype = 4, id =_data.itemId, num = num2}
								DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
							end
							ShowRewardNode:create(show_data)
						end
						self._displayDatas[_index].serverD.state = 1
						 XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
						XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
						self._storeList:reloadData()
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
		else
			XTHDHttp:requestAsyncInGameWithParams({
				modules = self._storeExRequest[self._storeIndex],
				params = param,
				successCallback = function(data)
					if tonumber(data.result) == 0 then
            			self:refreshPlayerData(data,storeData,targ)
					elseif tonumber(data.result) == 5501 then ----全服次数没了                
						storeData.serverD.allSurplusCount = 0
						--targ.serverLeftTimesL:setString(0)
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
	end
    local _confirmLayer = XTHDConfirmDialog:createWithParams( {
            rightText = self._storeIndex == 7 and "购买" or "兑换",
            rightCallback = rightFunc,
            msg = text
        } );
    self:addChild(_confirmLayer, 1)
end

function ShangCheng:refreshPlayerData(data,localD,targ)
    if data.property then 
	    for i=1,#data.property do
            local _tb = string.split(data.property[i],",")
	        gameUser.updateDataById(_tb[1], _tb[2])
	    end
    end 

	local restTime = 0
	local _playerRes = 0
	local _reward = {
		_type = 4,
		dbID = nil,
		id = nil,
		num = localD.localD.num,
	}
	if self._storeIndex == 2 then 
        _playerRes = gameUser.getAward()
        self._storeServerData.medal = _playerRes

        if data.items[1] then 
            _reward.dbID = data.items[1].dbId
        end 
    	localD.serverD.count = data.count
        restTime = data.count
	elseif self._storeIndex == 3 then 
        _playerRes = data.smeltPoint
        self._storeServerData.smeltPoint = _playerRes
        if data.items[1] then 
            _reward.dbID = data.items[1].dbId
        end 
    	localD.serverD.count = data.count
        restTime = data.count

        gameUser.setSmeltPoint(data.smeltPoint)
        gameUser.setIngot(data.ingot) 
    elseif self._storeIndex == 4 then 
		_playerRes = gameUser.getSaintStone()        
    	localD.serverD.exchangeSum = data.exchangeSum
	    restTime = data.exchangeSum

		for i=1,#data.gods do
            DBTableArtifact.analysDataAndUpdate(data.gods[i])
        end		
	    _reward._type = localD.localD.resourcetype
	    _reward.id = localD.localD.resourceid
	    _reward.num = localD.localD.num
	elseif self._storeIndex == 5 then 
	    _playerRes = gameUser.getHonor()
        self._storeServerData.honor = _playerRes
    	localD.serverD.exchangeSum = data.exchangeSum
	    restTime = data.exchangeSum

	    _reward._type = localD.localD.resourcetype
	    _reward.id = localD.localD.resourceid
	    _reward.num = localD.localD.num
	elseif self._storeIndex == 6 then 
		_playerRes = gameUser.getBounty()
		localD.serverD.count = data.surplusCount
		restTime = data.surplusCount

        if data.items[1] then 
            _reward.dbID = data.items[1].dbId
        end 
    elseif self._storeIndex == 7 then --团购商店
    	restTime = data.selfSurplusCount
        -- restTime = "不限"
        localD.serverD.allSurplusCount = data.allSurplusCount
        localD.serverD.selfSurplusCount = data.selfSurplusCount
   	    --targ.serverLeftTimesL:setString(data.allSurplusCount)

        for i=1,#data.gods do
            DBTableArtifact.analysDataAndUpdate(data.gods[i])
        end     

        _reward._type = localD.localD.resourcetype
        _reward.id = localD.localD.resourceid
        _reward.num = localD.localD.num
    elseif self._storeIndex == 8 then ----修罗
        _playerRes = gameUser.getAsura()
        localD.serverD.count = data.swapSum
        restTime = data.swapSum

        if data.items[1] then 
            _reward.dbID = data.items[1].dbId
        end 
    elseif self._storeIndex == 9 then  -----运镖
        _playerRes = gameUser.getReputation()
        localD.serverD.count = data.swapSum
        restTime = data.swapSum

        if data.items[1] then 
            _reward.dbID = data.items[1].dbId
        end 
    elseif self._storeIndex == 10 then -----帮派
        gameUser.setGuildPoint(data.totalContribution)
        _playerRes = gameUser.getGuildPoint()
        localD.serverD.count = data.exchangeSum
        restTime = data.exchangeSum

        if data.items[1] then 
            _reward.dbID = data.items[1].dbId
        else
            if localD.localD.resourcetype == 207 then
                _reward._type = 207
            end
        end 
    elseif self._storeIndex == 1 or self._storeIndex == 12 then -----元宝  
        _playerRes = gameUser.getIngot()
        restTime = data.count  
        if data.items[1] then
            _reward.dbID = data.items[1].dbId
            _reward.id = data.items[1].itemId
        end
--        _reward.num = data.items[1].count - tonumber(DBTableItem.getCountByID(data.items[1].dbId))
    elseif self._storeIndex == 11 then 
        _playerRes = gameUser.getServant()        
        localD.serverD.exchangeSum = data.exchangeSum
        restTime = data.exchangeSum
        for i=1,#data.servants do
            -- print("侍仆商店服务器返回的数据为：")
            -- print_r(data.servants)
        end   
        _reward._type = localD.localD.resourcetype
        _reward.id = localD.localD.resourceid
        _reward.num = localD.localD.num
	elseif self._storeIndex == 13 then 
        -- print("鲜花商店兑换服务器返回的数据为：")
        -- print_r(data)
		_playerRes = gameUser.getFlower()
		restTime = data.count
		_reward._type = 4
		_reward.id = data.items[1].itemId
		local num1 = data.items[1].count
		local num_2 = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _reward.id}).count or 0
		_reward.num = num1 - num_2
    end 
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})

    ShowRewardNode:create({{
        rewardtype = _reward._type,
        dbId = _reward.dbID,
        id = _reward.id,
        num = _reward.num,
    }})
	XTHD.saveItem({items = data.items})
    if self._storeIndex ~= 7 then -----不是团购的商店
--        self._playerResAmount:setString(_playerRes)
    end 
--   targ.exchangeTimesL:setString(restTime)
end

function ShangCheng:switchTitleContainer(index)
	if self._titleContainer then 
		self._titleContainer:removeAllChildren()
        if index == 7 then          ---团购
			----倒计时
			local _label = XTHDLabel:createWithParams({
				text = " ",
				fontSize = 18,
				color = cc.c3b(200,200,200),
			})
			self._titleContainer:addChild(_label)
			_label:setAnchorPoint(1,1)
			_label:setPosition(-210,0)
			self._countDownL = _label
			----时间
			local _countDown = XTHDLabel:createWithParams({
				text = " ",
				fontSize = 18,
				color = XTHD.resource.color.gray_desc,
			})
			self._titleContainer:addChild(_countDown)
			_countDown:setAnchorPoint(0,1)
			_countDown:setPosition(_label:getBoundingBox().width + _label:getPositionX(),-1)
			self._groupCountDownT = _countDown

			----刷新提示
			-- local _tips = XTHDLabel:createWithParams({
			-- 	text = LANGUAGE_TIPS_WORDS219,
			-- 	fontSize = 18,
			-- 	color = XTHD.resource.color.gray_desc
			-- })
			-- self._titleContainer:addChild(_tips)
			-- _tips:setAnchorPoint(1,0.5)
			-- _tips:setPosition(self._pinkBg:getContentSize().width - 40,0)
		else 
			-----资源
--		    local darkBg = cc.Sprite:create("res/image/equipCopies/dikuang9.png")
--			darkBg:setScale(-1)
--		    darkBg:setContentSize(cc.size(150,40))
--		    darkBg:setAnchorPoint(0,0.5)
--		    self._titleContainer:addChild(darkBg)
--		    darkBg:setPosition(0,0)
		    ----奖励图标
--		    local icon = cc.Sprite:create()
--		    self._titleContainer:addChild(icon)
--		    icon:setPosition( -25,darkBg:getPositionY())
--            icon:setTexture(self._playerResPath[index])
--            if self._storeIndex == 13 then
--                icon:setScale(0.7)
--            else
--                icon:setScale(1)
--            end
----            self._playerResIcon = icon
--		    ---数量
--		    local amount = cc.Label:createWithBMFont("res/fonts/pvpshuzi.fnt",0)
--            self._titleContainer:addChild(amount)
--            amount:setAnchorPoint(cc.p(1,0.5))
--		    amount:setPosition(icon:getPositionX() - 25,darkBg:getPositionY() - 8)
--		    self._playerResAmount = amount
		end 
	end 
end
-----刷新团购商店顶上的信息（倒计时等）
function ShangCheng:refreshGroupStoreTitle( )
	if self._storeServerData and self._storeIndex == 7 then ----团购商店 
		local time = 0
		if self._storeServerData.close and self._storeServerData.close > 0 then 
			time = self._storeServerData.close
			self._countDownL:setString(LANGUAGE_TIPS_WORDS220)
		elseif self._storeServerData.open and self._storeServerData.open > 0 then 
			time = self._storeServerData.open
			self._countDownL:setString(LANGUAGE_TIPS_WORDS221)
		end	 
		if time > 0 then 
			self._groupCountDownT:setPositionX( self._countDownL:getPositionX())
			local str = getCdStringWithNumber(time,{d = LANGUAGE_UNKNOWN.day,h = LANGUAGE_UNKNOWN.hour,m = LANGUAGE_UNKNOWN.minute,s = LANGUAGE_UNKNOWN.second})
			self._groupCountDownT:setString(str)
			self:startCountDown(time)
		end
	else 
		self:stopActionByTag(self.Tag.ktag_countDown)
	end 
end

function ShangCheng:startCountDown( time )
	local function tick( )
		time = time - 1
		if time <= 0 then 
            gameUser.setLimitTimeShopState(0)  --关闭主界面的限时礼包按钮
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
			self:stopActionByTag(self.Tag.ktag_countDown)
			return 
		end 
		local str = getCdStringWithNumber(time,{d = LANGUAGE_UNKNOWN.day,h = LANGUAGE_UNKNOWN.hour,m = LANGUAGE_UNKNOWN.minute,s = LANGUAGE_UNKNOWN.second})
		self._groupCountDownT:setString(str)
	end
	schedule(self,tick,1.0,self.Tag.ktag_countDown)
end
-----当商店多的时候，如果跳转的商店是没有显示出来的，则显示
function ShangCheng:setTheStoreButtonVisible( )
	local items = self._buttonList:getItems()
	local idx = 0
	for k,v in pairs(items) do 
        if v:getTag() == self._storeIndex then 
            idx = self._buttonList:getIndex(v)
			break
		end 
	end
    local percent = 100 	
    if #items - 1 > 0 then 
	   percent = idx / (#items - 1) * 100
    end 
    performWithDelay(self,function( )
        self._buttonList:jumpToPercentVertical(percent)
    end,0.2)
end

function ShangCheng:getStoreIndexByName( name )
    local index = {
        -- yuanbao = 1,   --元宝
        -- groupBuy = 6, ---团购
        -- yunBiao = 8, ---运镖
        -- arena = 1, ---竞技场
        -- smelt = 2, ---回收
        -- artifact = 3, ----神器
        -- camp = 4, ---阵营
        -- offer = 5, ----悬赏
        -- XiuLuo = 7, -----修罗
        -- Guild = 9, ----帮派
        yuanbao = 1,   --元宝
        groupBuy = 7, ---团购
        -- yunBiao = 9, ---运镖
        -- arena = 2, ---竞技场
        -- smelt = 3, ---回收
        -- artifact = 4, ----神器
        -- camp = 5, ---阵营
        -- offer = 6, ----悬赏
        -- XiuLuo = 8, -----修罗
        -- Guild = 10, ----帮派
        -- servant = 11, --侍仆
	    strength = 12, --强化
		-- flower = 13		--鲜花商店
    }
    return index[name]
end

------当团购商店数据没有的时候，不显示团购商店
function ShangCheng:isHideGroupShop(isHide )
    if self._groupTip then 
        self._groupTip:setVisible(isHide)
    end 
    if isHide == true then 
        if self._labelTabContainer then 
            self._labelTabContainer:setVisible(false)
        end 
    else
        if self._labelTabContainer and not (self._storeIndex == 4 or self._storeIndex == 5 or self._storeIndex == 8 or self._storeIndex == 9 or self._storeIndex == 10) then 
            self._labelTabContainer:setVisible(true)
        end 
    end 
    if self._titleContainer then 
        self._titleContainer:setVisible(not isHide)
    end 
end

--刷新神秘商店
function ShangCheng:refreshShenMiStore()
	XTHDHttp:requestAsyncInGameWithParams({
		modules = "refreshWeapon?",
        successCallback = function(data)
			if tonumber(data.result) == 0 then
				dump(data)
				if data.costItems then
					for i = 1,#data.costItems do
						local _data = data.costItems[i]
						DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
					end
				end
				self._iconNum:setString(XTHD.resource.getItemNum(2303))
				self._storeServerData = data
				self._displayDatas = self:selecteDataByTab()
				self._storeList:reloadData()
            else
                XTHDTOAST(data.msg)
            end
         end,--成功回调
         failedCallback = function()
			XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
         end,--失败回调
         targetNeedsToRetain = self,--需要保存引用的目标
         loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})
end

--神秘商店界面排序
function ShangCheng:SortList(list)
	local ranklist = {{},{},{},{},{},{}}
	for i = 1, #list do
		local rank = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = list[i].itemId}).rank
		if tonumber(rank) == 6 then
			ranklist[1][#ranklist[1] + 1] = list[i]
			ranklist[1][#ranklist[1]].rank = rank
		elseif tonumber(rank) == 5 then
			ranklist[2][#ranklist[2] + 1] = list[i]
			ranklist[2][#ranklist[2]].rank = rank
		elseif tonumber(rank) == 4 then
			ranklist[3][#ranklist[3] + 1] = list[i]
			ranklist[3][#ranklist[3]].rank = rank
		elseif tonumber(rank) == 3 then
			ranklist[4][#ranklist[4] + 1] = list[i]
			ranklist[4][#ranklist[4]].rank = rank
		elseif tonumber(rank) == 2 then
			ranklist[5][#ranklist[5] + 1] = list[i]
			ranklist[5][#ranklist[5]].rank = rank
		elseif tonumber(rank) == 1 then
			ranklist[6][#ranklist[6] + 1] = list[i]
			ranklist[6][#ranklist[6]].rank = rank
		end
	end

	local list_2 = {{},{},{}}

	for i = 1,#ranklist do
		if #ranklist[i] > 0 then
			for k, v in pairs(ranklist[i]) do
				local data = string.split(v.price,"#")
				if tonumber(data[1]) == 2 then
					v._type = 1
				elseif tonumber(data[1]) == 6 then
					v._type = 2
				elseif tonumber(data[1]) == 3 then
					v._type = 3
				elseif tonumber(data[1]) == 4 then
					v._type = 4
				end
			end
		end
	end

	for i = 1,#ranklist do
		if #ranklist[i] > 0 then
			table.sort(ranklist[i],function( a,b )
                return a._type < b._type 
            end)
		end
	end
	
	list = {}
	
	for i = 1,#ranklist do
		for k, v in pairs(ranklist[i]) do
			list[#list + 1] = v
		end
	end

	return list
	
end

function ShangCheng:createOtherStore()
	self._OtherShopNode = cc.Node:create()
	self._OtherShopNode:setAnchorPoint(0.5,0.5)
	self._OtherShopNode:setContentSize(self._bg:getContentSize())
	self._bg:addChild(self._OtherShopNode)
	self._OtherShopNode:setPosition(self._bg:getContentSize().width *0.5,self._bg:getContentSize().height *0.5)

	local _type = {"recycle","arena","guild","Artifact","camp","flower","shura","reward"}
	local index = 0
	for i = 1, 2 do
		for j = 1, 4 do
			index = index + 1
			local btn = XTHDPushButton:create({
				normalFile = "res/image/store/gongnengStore/btn_shangcheng_".. index .. ".png",
				selectedFile = "res/image/store/gongnengStore/btn_shangcheng_".. index .. ".png",
			})
			self._OtherShopNode:addChild(btn)
			local x = 200 + btn:getContentSize().width *0.5 + (j - 1)*(btn:getContentSize().width + 5)
			local y = self._bg:getContentSize().height - i * btn:getContentSize().height *0.5 - (i - 1)*btn:getContentSize().height *0.7 - 30
			btn:setPosition(x,y)
			btn:setTag(index)			

			btn:setTouchBeganCallback(function()
				btn:setScale(0.98)
			end)
			
			btn:setTouchMovedCallback(function()
				btn:setScale(1)
			end)

			btn:setTouchEndedCallback(function()
				btn:setScale(1)
				local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create(_type[btn:getTag()])
				cc.Director:getInstance():getRunningScene():addChild(layer)
				layer:show()
			end)
		end
	end
end

function ShangCheng:getNumTable(data,name,index)
	if name == nil then
		name = ""
	end
	local _playeLablePath = self._playeLablePath[self._storeIndex]
	local table = {}
	if self._storeIndex == 4 or self._storeIndex == 5 or self._storeIndex == 10 or self._storeIndex == 11 then
		table[1] = data.localD.num
		table[2] = data.localD.num1
		table[3] = data.localD.num2
		if self._storeIndex == 11 then
			if index == 1 then
				_playeLablePath = "银两"
			elseif index == 2 then
				_playeLablePath = "元宝"	
			end
		end
	elseif self._storeIndex == 12 then
		if index % 2 == 1 then
			table[1] = data.localD.ingotprice
			table[2] = data.localD.num
			_playeLablePath = self._playeLablePath[self._storeIndex]
		else
			table[1] = data.localD.goldprice
			table[2] = data.localD.num
			_playeLablePath = "银两"
		end
	elseif self._storeIndex == 7 then
		_playeLablePath = "元宝"
		table[1] = data.localD.ingotprice2
		table[2] = data.localD.num
		text = "您是否确认使用" .. table[1] .. "个" .. _playeLablePath .. "购买" .. table[2] .. "个" .. data.localD.itemname
		return text
	elseif self._storeIndex == 14 then
		local _data = string.split(data.localD.price,"#")
		if tonumber(_data[1]) == 2 then
			_playeLablePath = "银两"
		elseif tonumber(_data[1]) == 3 then
			_playeLablePath = "元宝"
		else
			_playeLablePath = "翡翠"
		end
		text = "您是否确认使用" .. _data[3] .. "个" .. _playeLablePath .. "购买" .. "1个" .. data.localD.itemfalsename
		return text
	else
		table[1] = data.localD.coinprice
		table[2] = data.localD.num
	end
	local text = ""
	if #table >= 3 then
		if self._storeIndex == 4 then
			if index == 3 or index == 4 or index == 5 then
				text = "您是否确认使用"..table[2].."个".. _playeLablePath.. "和" .. table[3] .."元宝" .. "兑换" .. table[1] .."个" .. name
			elseif index == 1 or index == 2 then
				text = "您是否确认使用"..table[2].."个".."元宝" .. "兑换" .. table[1] .."个" .. name
				if data.localD.id == 1 then
					text = "您是否确认使用"..table[2].."个".."翡翠" .. "兑换" .. table[1] .."个" .. name
				end
			else
				text = "您是否确认使用"..table[2].."个".. _playeLablePath .. "兑换" .. table[1] .."个" .. name
			end
		else
			text = "您是否确认使用"..table[2].."个".. _playeLablePath .. "兑换" .. table[1] .."个" .. name
		end
	else
		text = "您是否确认使用" .. table[1] .. "个" .. _playeLablePath .. "兑换" .. table[2] .. "个" .. name
	end
	return text
end

return ShangCheng
