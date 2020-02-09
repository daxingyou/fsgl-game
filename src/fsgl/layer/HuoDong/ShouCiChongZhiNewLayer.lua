local ShouCiChongZhiNewLayer = class("ShouCiChongZhiNewLayer",function()
	return XTHD.createPopLayer()
end)

function ShouCiChongZhiNewLayer:ctor(data)
	self._exist = true
	self._size = self:getContentSize()
	self._uiNode = nil
	self._selectedIndex = 0
	local jianglilist = {1,2,3}

--	dump(gameUser.getThreeTimePayList(),"当前未领取")
--	dump(gameUser.getFinishThreePayRewardList(),"当前已领取")
	local RewardList = gameUser.getFinishThreePayRewardList()
	if #gameUser.getThreeTimePayList() == 0 then
		for k, v in pairs(RewardList) do
			for i = 1,#jianglilist do
				if v == jianglilist[i] then
					jianglilist[i] = nil
				end
			end
		end
		for i = 1,3 do
			if jianglilist[i] then
				self._selectedIndex = jianglilist[i]
				break
			end
		end
	elseif #gameUser.getThreeTimePayList() ~= 0 then
		self._selectedIndex = gameUser.getThreeTimePayList()[1]
	end

	-- 数据
	self._rewardList = {}
	self._listData  = gameData.getDataFromCSV( "ThreeTimePay" )
	-- dump( rewardList, "rewardList")
	for j = 1, #self._listData do
		local i = 1 
		self._rewardList[j] = {}
		while self._listData[j]["rewardtype"..i] do
			if self._listData[j]["rewardnum"..i] > 0 then
				self._rewardList[j][#self._rewardList[j] + 1] = {
					rewardtype = self._listData[j]["rewardtype"..i],
					id = self._listData[j]["rewardID"..i],
					num = self._listData[j]["rewardnum"..i],
				}
			end
			i = i + 1
		end
	end

	-- 添加监听事件
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG,callback = function()
		if self._exist then
			self:refreshUI()
		end
	end})
	self:saveFristPayWindow()
	
end

function ShouCiChongZhiNewLayer:saveFristPayWindow()
		ClientHttp:requestAsyncInGameWithParams({
		modules = "saveFristPayWindow?",
		params = { state  = 1},
		successCallback = function( backData )
			if tonumber(backData.result) == 0 then
				gameUser.setFirstLayerState(backData.state)
				self:initLayer()
				self:refreshUI()
			else
				XTHDTOAST(backData.msg)
			end 
		end,
		failedCallback = function()
			XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
		end,--失败回调
		loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
		loadingParent = self,
	})
end

function ShouCiChongZhiNewLayer:initLayer()
	local _containerLayer = self:getContainerLayer()
	_containerLayer:setClickable(true)

	-- 背景
	local _popNode = XTHDSprite:create("res/image/activities/firstrechargeNew/bg.png")
	_popNode:setPosition(cc.p(_containerLayer:getContentSize().width/2, _containerLayer:getContentSize().height/2))
	self.popNode = _popNode
	_containerLayer:addChild(_popNode)
	_popNode:setSwallowTouches(true)
	_popNode:setScale(0.8)

	-- 前去充值按钮
	self._rechargeBtn = XTHD.createButton({
		normalFile = "res/image/activities/firstrechargeNew/recharge_up.png",
		selectedFile = "res/image/activities/firstrechargeNew/recharge_down.png",
		endCallback = function()
			XTHD.createRechargeVipLayer( self,nil,10 )
		end
	})
	self._rechargeBtn:setPosition( _popNode:getContentSize().width - self._rechargeBtn:getContentSize().width - 5, self._rechargeBtn:getContentSize().height + 70)
	_popNode:addChild( self._rechargeBtn )

	-- 领取奖励按钮
	self._fetchBtn = XTHD.createButton({
		normalFile = "res/image/activities/firstrechargeNew/fetch_up.png",
		selectedFile = "res/image/activities/firstrechargeNew/fetch_down.png",
		endCallback = function()
			self:LingquJiangLi()
		end,
	})
	self._fetchBtn:setPosition(_popNode:getContentSize().width - self._fetchBtn:getContentSize().width - 10, self._fetchBtn:getContentSize().height + 75)
	_popNode:addChild( self._fetchBtn )
	local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
	self._fetchBtn:addChild(fetchSpine)
	fetchSpine:setPosition(self._fetchBtn:getBoundingBox().width*0.5 + 1, self._fetchBtn:getContentSize().height*0.5+2)
	fetchSpine:setAnimation(0, "querenjinjie", true )
--	-- 已领取
	self._fetchedImageView = XTHD.createSprite( "res/image/vip/yilingqu.png" )
	self._fetchedImageView:setScale(0.8)
	self._fetchedImageView:setPosition( self._fetchBtn:getPosition())
	_popNode:addChild( self._fetchedImageView )
	self:updateUI()
	
	self:show(true)
end

function ShouCiChongZhiNewLayer:updateUI()
	if self._uiNode then
		self._uiNode:removeFromParent()
	end
	if self._selectedIndex == 1 then
		self:createUI_one()
	elseif self._selectedIndex == 2 then
		self:createUI_Two()
	else
		self:createUI_Three()
	end
end

function ShouCiChongZhiNewLayer:createUI_one()
	self._uiNode = cc.Node:create()
	self._uiNode:setContentSize(self.popNode:getContentSize())
	self._uiNode:setAnchorPoint(0.5,0.5)
	self.popNode:addChild(self._uiNode)
	self._uiNode:setPosition(self.popNode:getContentSize().width *0.5,self.popNode:getContentSize().height *0.5)

	local titlebg = XTHDSprite:create("res/image/activities/firstrechargeNew/titlebg.png")
	titlebg:setPosition(cc.p(self._uiNode:getContentSize().width - titlebg:getContentSize().width *0.6 - 15, self._uiNode:getContentSize().height - titlebg:getContentSize().height + 5))
	self._uiNode:addChild(titlebg)
	
	local titlebg = XTHDSprite:create("res/image/activities/firstrechargeNew/title.png")
	titlebg:setPosition(cc.p(self._uiNode:getContentSize().width - titlebg:getContentSize().width *0.5 + 10, self._uiNode:getContentSize().height - titlebg:getContentSize().height - 5))
	self._uiNode:addChild(titlebg)

	--标题
	local titleNode = XTHDSprite:create("res/image/activities/firstrechargeNew/shouchong-jiangli_1.png")
	titleNode:setPosition(cc.p(self._uiNode:getContentSize().width - titleNode:getContentSize().width *0.8 + 10, self._uiNode:getContentSize().height/2 + 70))
	self._uiNode:addChild(titleNode)

	local line = cc.Sprite:create("res/image/activities/firstrechargeNew/line.png")
	self._uiNode:addChild(line)
	line:setPosition(self._uiNode:getContentSize().width - line:getContentSize().width + 2,self._uiNode:getContentSize().height*0.5 + 32)

	local heroHead = cc.Sprite:create("res/image/activities/firstrechargeNew/herohead_11.png")
	self._uiNode:addChild(heroHead)
	heroHead:setScale(0.53)
	heroHead:setPosition(line:getPositionX() - 20,line:getPositionY() - heroHead:getContentSize().height *0.25 - 5)

	local heroName = cc.Sprite:create("res/image/activities/firstrechargeNew/heroName_11.png")
	self._uiNode:addChild(heroName)
	heroName:setPosition(heroHead:getPositionX() + heroHead:getContentSize().width*0.35,heroHead:getPositionY())
	
	local line_2 = cc.Sprite:create("res/image/activities/firstrechargeNew/line.png")
	self._uiNode:addChild(line_2)
	line_2:setPosition(line:getPositionX(),line:getPositionY() - heroHead:getContentSize().height *0.5 - 10)

	--圆盘
	local dipan = cc.Sprite:create("res/image/activities/firstrechargeNew/dipan.png")
	self._uiNode:addChild(dipan)
	dipan:setPosition(cc.p(self._uiNode:getContentSize().width*0.4,self._uiNode:getContentSize().height *0.5 + 40))
	
	local hero = sp.SkeletonAnimation:createWithBinaryFile("res/spine/003.skel", "res/spine/003.atlas", 1.0)
	hero:setAnimation(0,"atk1",true)
	dipan:addChild(hero)
	hero:setPosition(dipan:getContentSize().width *0.5, 50)
		
	--脚上的迷雾	
	local miwu = cc.Sprite:create("res/image/activities/firstrechargeNew/miwu.png")
	dipan:addChild(miwu)
	miwu:setPosition(dipan:getContentSize().width *0.5,dipan:getContentSize().height *0.5)
	local pos = {
		cc.p(208,160),
		cc.p(318,125),
		cc.p(428,125),
		cc.p(538,160),
	}
	for i = 1,#self._rewardList[self._selectedIndex] do
		local item = ItemNode:createWithParams({
			itemId = self._rewardList[self._selectedIndex][i].id ,
			-- quality = data.rank,
			_type_ = self._rewardList[self._selectedIndex][i].rewardtype,
			count = self._rewardList[self._selectedIndex][i].num,
			showDrropType = 2,
		})
		item:setScale(0.85)
		self._uiNode:addChild(item)
		item:setPosition(pos[i])
	end

	--创建礼包tableview
	local function create_tableview(cell_arr)
		local _extrWidth = 350
		local _extrHight = 85
		local tableview = cc.TableView:create(cc.size(_extrWidth, _extrHight))
		tableview:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
		tableview:setPosition(cc.p(self._uiNode:getContentSize().width/2 - 100, 68))
		tableview:setBounceable(true)
		tableview:setDelegate()
		self._uiNode:addChild(tableview)
		-- tableView注册事件
		local function numberOfCellsInTableView( table )
			return #cell_arr  
		end
		local function cellSizeForTable( table, idx )
			return 80, 80  
		end
		local function tableCellAtIndex( table, idx )
			local cell = table:dequeueCell()
			if cell == nil then
				cell = cc.TableViewCell:new()
				cell:setContentSize(80,80)
				cell:setScale(0.9)
			else
				cell:removeAllChildren()
			end

			local item = createItem(cell_arr[idx+1])
			item:setPosition(cell:getContentSize().width*0.5,cell:getContentSize().height*0.5)
			cell:addChild(item)

			return cell
		end
		tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
		tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
		tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
		tableview:reloadData()
	end

end

function ShouCiChongZhiNewLayer:createUI_Two()
	self._uiNode = cc.Node:create()
	self._uiNode:setContentSize(self.popNode:getContentSize())
	self._uiNode:setAnchorPoint(0.5,0.5)
	self.popNode:addChild(self._uiNode)
	self._uiNode:setPosition(self.popNode:getContentSize().width *0.5,self.popNode:getContentSize().height *0.5)

	local titlebg = XTHDSprite:create("res/image/activities/firstrechargeNew/titlebg.png")
	titlebg:setPosition(cc.p(self._uiNode:getContentSize().width - titlebg:getContentSize().width *0.6 - 15, self._uiNode:getContentSize().height - titlebg:getContentSize().height + 5))
	self._uiNode:addChild(titlebg)

	local titlebg = XTHDSprite:create("res/image/activities/firstrechargeNew/thirty/title.png")
	titlebg:setPosition(cc.p(self._uiNode:getContentSize().width - titlebg:getContentSize().width *0.5 + 10, self._uiNode:getContentSize().height - titlebg:getContentSize().height - 5))
	self._uiNode:addChild(titlebg)
	
	--奖励
	local titleNode = XTHDSprite:create("res/image/activities/firstrechargeNew/thirty/jiangli.png")
	titleNode:setPosition(cc.p(self._uiNode:getContentSize().width - titleNode:getContentSize().width *0.7, self._uiNode:getContentSize().height/2 + 70))
	self._uiNode:addChild(titleNode)

	local line = cc.Sprite:create("res/image/activities/firstrechargeNew/line.png")
	self._uiNode:addChild(line)
	line:setPosition(self._uiNode:getContentSize().width - line:getContentSize().width + 2,self._uiNode:getContentSize().height*0.5 + 32)

	local itemNode = cc.Sprite:create("res/image/activities/firstrechargeNew/thirty/itemNode.png")
	self._uiNode:addChild(itemNode)
	itemNode:setScale(0.53)
	itemNode:setPosition(line:getPositionX() - 20,line:getPositionY() - itemNode:getContentSize().height *0.25 - 5)

	local itemName = cc.Sprite:create("res/image/activities/firstrechargeNew/thirty/name.png")
	self._uiNode:addChild(itemName)
	itemName:setPosition(itemNode:getPositionX() + itemNode:getContentSize().width*0.35,itemNode:getPositionY())
	
	local line_2 = cc.Sprite:create("res/image/activities/firstrechargeNew/line.png")
	self._uiNode:addChild(line_2)
	line_2:setPosition(line:getPositionX(),line:getPositionY() - itemNode:getContentSize().height *0.5 - 10)

	--圆盘
	local dipan = cc.Sprite:create("res/image/activities/firstrechargeNew/thirty/ditu.png")
	self._uiNode:addChild(dipan)
	dipan:setPosition(cc.p(self._uiNode:getContentSize().width*0.4,self._uiNode:getContentSize().height *0.5 + 40))

	--播放帧动画
	local frameArr = {}
	for j=1,9 do
		local _path = string.format("res/image/activities/firstrechargeNew/thirty/gong/gong_%d.png",j)
		local texture = cc.Director:getInstance():getTextureCache():addImage(_path)
		frameArr[j] = cc.SpriteFrame:createWithTexture(texture,cc.rect(0,0,texture:getPixelsWide(),texture:getPixelsHigh()))
	end
	local act = cc.Animation:createWithSpriteFrames(frameArr,1/12)
	act = cc.Animate:create(act)
	act = cc.RepeatForever:create(act)
	
	local target = cc.Sprite:create()
	dipan:addChild(target)
	target:setPosition(dipan:getContentSize().width *0.5, dipan:getContentSize().height *0.5 + 50)
	target:runAction(act)

		local pos = {
		cc.p(208,160),
		cc.p(318,125),
		cc.p(428,125),
		cc.p(538,160),
	}
	for i = 1,#self._rewardList[self._selectedIndex] do
		local item = ItemNode:createWithParams({
			itemId = self._rewardList[self._selectedIndex][i].id ,
			-- quality = data.rank,
			_type_ = self._rewardList[self._selectedIndex][i].rewardtype,
			count = self._rewardList[self._selectedIndex][i].num,
			showDrropType = 2,
			-- touchShowTip = false,
		})
		item:setScale(0.85)
		self._uiNode:addChild(item)
		item:setPosition(pos[i])
	end

	--创建礼包tableview
	local function create_tableview(cell_arr)
		local _extrWidth = 350
		local _extrHight = 85
		local tableview = cc.TableView:create(cc.size(_extrWidth, _extrHight))
		tableview:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
		tableview:setPosition(cc.p(self._uiNode:getContentSize().width/2 - 100, 68))
		tableview:setBounceable(true)
		tableview:setDelegate()
		self._uiNode:addChild(tableview)
		-- tableView注册事件
		local function numberOfCellsInTableView( table )
			return #cell_arr  
		end
		local function cellSizeForTable( table, idx )
			return 80, 80  
		end
		local function tableCellAtIndex( table, idx )
			local cell = table:dequeueCell()
			if cell == nil then
				cell = cc.TableViewCell:new()
				cell:setContentSize(80,80)
				cell:setScale(0.9)
			else
				cell:removeAllChildren()
			end

			local item = createItem(cell_arr[idx+1])
			item:setPosition(cell:getContentSize().width*0.5,cell:getContentSize().height*0.5)
			cell:addChild(item)

			return cell
		end
		tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
		tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
		tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
		tableview:reloadData()
	end
end


function ShouCiChongZhiNewLayer:createUI_Three()
	self._uiNode = cc.Node:create()
	self._uiNode:setContentSize(self.popNode:getContentSize())
	self._uiNode:setAnchorPoint(0.5,0.5)
	self.popNode:addChild(self._uiNode)
	self._uiNode:setPosition(self.popNode:getContentSize().width *0.5,self.popNode:getContentSize().height *0.5)

	local titlebg = XTHDSprite:create("res/image/activities/firstrechargeNew/titlebg.png")
	titlebg:setPosition(cc.p(self._uiNode:getContentSize().width - titlebg:getContentSize().width *0.6 - 15, self._uiNode:getContentSize().height - titlebg:getContentSize().height + 5))
	self._uiNode:addChild(titlebg)

	local titlebg = XTHDSprite:create("res/image/activities/firstrechargeNew/sixty_eight/tltle.png")
	titlebg:setPosition(cc.p(self._uiNode:getContentSize().width - titlebg:getContentSize().width *0.5 + 10, self._uiNode:getContentSize().height - titlebg:getContentSize().height - 5))
	self._uiNode:addChild(titlebg)
	
	--奖励
	local titleNode = XTHDSprite:create("res/image/activities/firstrechargeNew/sixty_eight/jiangli.png")
	titleNode:setPosition(cc.p(self._uiNode:getContentSize().width - titleNode:getContentSize().width *0.7, self._uiNode:getContentSize().height/2 + 70))
	self._uiNode:addChild(titleNode)

	local line = cc.Sprite:create("res/image/activities/firstrechargeNew/line.png")
	self._uiNode:addChild(line)
	line:setPosition(self._uiNode:getContentSize().width - line:getContentSize().width + 2,self._uiNode:getContentSize().height*0.5 + 32)

	local itemNode = cc.Sprite:create("res/image/activities/firstrechargeNew/sixty_eight/itemNode.png")
	self._uiNode:addChild(itemNode)
	itemNode:setScale(0.53)
	itemNode:setPosition(line:getPositionX() - 20,line:getPositionY() - itemNode:getContentSize().height *0.25 - 5)

	local itemName = cc.Sprite:create("res/image/activities/firstrechargeNew/sixty_eight/itemName.png")
	self._uiNode:addChild(itemName)
	itemName:setPosition(itemNode:getPositionX() + itemNode:getContentSize().width*0.35,itemNode:getPositionY())
	
	local line_2 = cc.Sprite:create("res/image/activities/firstrechargeNew/line.png")
	self._uiNode:addChild(line_2)
	line_2:setPosition(line:getPositionX(),line:getPositionY() - itemNode:getContentSize().height *0.5 - 10)

	--圆盘
	local dipan = cc.Sprite:create("res/image/activities/firstrechargeNew/sixty_eight/ditu.png")
	self._uiNode:addChild(dipan)
	dipan:setPosition(cc.p(self._uiNode:getContentSize().width*0.4,self._uiNode:getContentSize().height *0.5 + 40))
	
	local node = cc.Node:create()
	node:setContentSize(dipan:getContentSize())
	node:setAnchorPoint(0.5,0.5)
	dipan:addChild(node)
	node:setPosition(dipan:getContentSize().width *0.5,dipan:getContentSize().height *0.5 + 10)
	
	local move_1 = cc.MoveBy:create(2.5,cc.p(0,70))
	local move_2 = cc.MoveBy:create(2.5,cc.p(0,-70))
	node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.EaseSineInOut:create(move_1),cc.EaseSineInOut:create(move_2))))

	local guang = cc.Sprite:create("res/image/activities/firstrechargeNew/sixty_eight/guang.png")
	node:addChild(guang)
	guang:setScale(2)
	guang:setPosition(node:getContentSize().width *0.5, node:getContentSize().height *0.5)
	
	local roteta = cc.RotateBy:create(1,60)
	guang:runAction(cc.RepeatForever:create(roteta))

	local item = cc.Sprite:create("res/image/activities/firstrechargeNew/sixty_eight/pojun.png")
	node:addChild(item)
	item:setPosition(node:getContentSize().width *0.5,node:getContentSize().height*0.5)
		local pos = {
		cc.p(208,160),
		cc.p(318,125),
		cc.p(428,125),
		cc.p(538,160),
	}
	if self._selectedIndex == 0 then
		self._selectedIndex = 3
	end
	for i = 1,#self._rewardList[self._selectedIndex] do
		local item = ItemNode:createWithParams({
			itemId = self._rewardList[self._selectedIndex][i].id ,
			-- quality = data.rank,
			_type_ = self._rewardList[self._selectedIndex][i].rewardtype,
			count = self._rewardList[self._selectedIndex][i].num,
			showDrropType = 2,
			-- touchShowTip = false,
		})
		item:setScale(0.85)
		self._uiNode:addChild(item)
		item:setPosition(pos[i])
	end

	--创建礼包tableview
	local function create_tableview(cell_arr)
		local _extrWidth = 350
		local _extrHight = 85
		local tableview = cc.TableView:create(cc.size(_extrWidth, _extrHight))
		tableview:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
		tableview:setPosition(cc.p(self._uiNode:getContentSize().width/2 - 100, 68))
		tableview:setBounceable(true)
		tableview:setDelegate()
		self._uiNode:addChild(tableview)
		-- tableView注册事件
		local function numberOfCellsInTableView( table )
			return #cell_arr  
		end
		local function cellSizeForTable( table, idx )
			return 80, 80  
		end
		local function tableCellAtIndex( table, idx )
			local cell = table:dequeueCell()
			if cell == nil then
				cell = cc.TableViewCell:new()
				cell:setContentSize(80,80)
				cell:setScale(0.9)
			else
				cell:removeAllChildren()
			end

			local item = createItem(cell_arr[idx+1])
			item:setPosition(cell:getContentSize().width*0.5,cell:getContentSize().height*0.5)
			cell:addChild(item)

			return cell
		end
		tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
		tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
		tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
		tableview:reloadData()
	end
end

function ShouCiChongZhiNewLayer:onCleanup()
	self._exist = false
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_RECHARGE_MSG)
	if gameUser.getMeiRiQianDaoState() == 1 then
    	local popLayer = requires("src/fsgl/layer/ConstraintPoplayer/MeiRiQianDaoPopLayer.lua"):create()
		cc.Director:getInstance():getRunningScene():addChild(popLayer)
    end
end

function ShouCiChongZhiNewLayer:refreshUI()
	if not self._exist then
		return
	end
	local jianglilist = {1,2,3}
	local RewardList = gameUser.getFinishThreePayRewardList()

	for k, v in pairs(RewardList) do
			for i = 1,#jianglilist do
				if v == jianglilist[i] then
					jianglilist[i] = nil
				end
			end
		end
		for i = 1,3 do
			if jianglilist[i] then
				self._selectedIndex = jianglilist[i]
				break
			end
		end
	
	local list = gameUser.getThreeTimePayList()
	table.sort(list)
	if #list > 0 and self._selectedIndex == list[1] then
		self._state = 1
		self._fetchBtn:setVisible( true )
		self._rechargeBtn:setVisible( false )
		self._fetchedImageView:setVisible( false )
		RedPointState[22].state = 1
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "scsc"}})
	else
		if #RewardList < 3 then
			self._rechargeBtn:setVisible( true )
			self._fetchBtn:setVisible( false )
			self._fetchedImageView:setVisible( false )
			RedPointState[22].state = 0
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "scsc"}})
		else
			self._rechargeBtn:setVisible( false )
			self._fetchBtn:setVisible( false )
			self._fetchedImageView:setVisible( true )
			RedPointState[22].state = 0
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "scsc"}})
		end
	end
	
	self:updateUI()
end

function ShouCiChongZhiNewLayer:LingquJiangLi()
	ClientHttp:requestAsyncInGameWithParams({
		modules = "threeTimePayReward?",
		params = { configId  = self._listData[self._selectedIndex].id},
		successCallback = function( backData )
			if tonumber(backData.result) == 0 then
				ShowRewardNode:create( self._rewardList[self._selectedIndex] )
				-- 更新属性
				if backData.property and #backData.property > 0 then
					for i=1, #backData.property do
						local pro_data = string.split( backData.property[i], ',' )
						DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
					end
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
				end
				-- 更新背包
				if backData.bagItems and #backData.bagItems ~= 0 then
					for i=1, #backData.bagItems do
						local item_data = backData.bagItems[i]
						if item_data.count and tonumber( item_data.count ) ~= 0 then
							DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
						else
							DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
						end
				end
				end
				-- 更新英雄
				if backData.addPets then
					gameData.saveDataToDB(backData.addPets,1)
				end
				gameUser.setThreeTimePayId(backData.threeTimePayId)
				gameUser.setThreeTimePayList(backData.threeTimePayList)
				gameUser.setFinishThreePayRewardList(backData.finishThreePayRewardList)
				self:refreshUI()
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
			else
				XTHDTOAST(backData.msg)
			end 
		end,
		failedCallback = function()
			XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
		end,--失败回调
		loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
		loadingParent = self,
	})
end

function ShouCiChongZhiNewLayer:create(data)
	local _layer = self.new(data)
	if _layer ~= nil then
		return _layer
	end
end
return ShouCiChongZhiNewLayer