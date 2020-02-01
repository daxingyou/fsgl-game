local YingXiongXianJi = class("YingXiongXianJi", function(...)
	return XTHD.createPopLayer()
end )
-- SheZhiLayer.__index = SheZhiLayer

function YingXiongXianJi:ctor()
	local bg = cc.Sprite:create("res/image/DeleteHero/recyclebg.png")
	bg:setAnchorPoint(0.5, 0.5)
	self:addContent(bg)
	bg:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self.bg = bg

	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=34});
            self:addChild(StoredValue)
        end,
	})
	self.bg:addChild(help_btn)
	help_btn:setPosition(help_btn:getContentSize().width + 20,self.bg:getContentSize().height - help_btn:getContentSize().height - 80)

	-- 关闭按钮
	local btn_close = XTHD.createBtnClose( function()
		self:hide()
	end )
	btn_close:setZOrder(1)
	self.bg:addChild(btn_close)
	btn_close:setPosition(self.bg:getContentSize().width - 25, self.bg:getContentSize().height - 55)

	local TouXiangBg = cc.Sprite:create("res/image/DeleteHero/Touxiangbg.png")
	self.bg:addChild(TouXiangBg)
	TouXiangBg:setPosition(160, self.bg:getContentSize().height / 2 + 100)
	self._TouXiangBg = TouXiangBg

	local tishi = XTHDLabel:create("献祭后可获得：", 16, "res/fonts/def.ttf")
	tishi:setColor(cc.c3b(255,255,255))
	tishi:setAnchorPoint(0, .05)
	self.bg:addChild(tishi)
	tishi:setPosition(52, 240)
	tishi:enableOutline(cc.c4b(55,18,9,255),3)

	local tishi2 = XTHDLabel:create("英雄只有在1级时才可进行献祭", 16, "res/fonts/def.ttf")
	tishi2:setColor(cc.c3b(255,255,255))
	tishi2:setAnchorPoint(0, .05)
	self.bg:addChild(tishi2)
	tishi2:setPosition(52, 270)
	tishi2:enableOutline(cc.c4b(55,18,9,255),3)

	local btn_XianJi = XTHD.createButton( {
		normalFile = "res/image/DeleteHero/recyclebtn_1.png",
		selectedFile = "res/image/DeleteHero/recyclebtn_2.png",
	} )
	self.bg:setAnchorPoint(0.5, 0.5)
	self.bg:addChild(btn_XianJi)
	btn_XianJi:setPosition(TouXiangBg:getPositionX(), 75)
	btn_XianJi:setTouchEndedCallback( function()
		self:XianJiHeroTiShi()
	end )

	for i = 1, 5 do
		local name1 = string.format("res/image/DeleteHero/starBtn_%d_1.png", i)
		local name2 = string.format("res/image/DeleteHero/starBtn_%d_2.png", i)
		local btn = XTHD.createButton( {
			normalFile = name1,
			selectedFile = name2
		} )
		btn:setTag(i)
		self.bg:addChild(btn)
		local x = 350 +((i - 1) *(btn:getContentSize().width + 4))
		btn:setPosition(x, self.bg:getContentSize().height - 100)
		btn:setTouchEndedCallback( function()
			self:ShowHeroList(btn:getTag())
		end )
		self._btnList[#self._btnList + 1] = btn
		local btnBg = cc.Sprite:create(name2)
		btnBg:setAnchorPoint(0.5, 0.5)
		btnBg:setPosition(btnBg:getContentSize().width / 2, btnBg:getContentSize().height / 2)
		btn:addChild(btnBg)
		btnBg:setName("btnBg")
		if i ~= 1 then
			btnBg:setVisible(false)
		end

	end
	
	local smelterBgLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
	smelterBgLayer:setOpacity(120)
	smelterBgLayer:setAnchorPoint(0.5, 0.5)
	smelterBgLayer:setContentSize(self:getContentSize())
	self:addChild(smelterBgLayer)
	smelterBgLayer:setPosition(0, 0)
	smelterBgLayer:setVisible(false)
	self._smelterBgLayer = smelterBgLayer
	
	local op_btn = XTHDPushButton:createWithParams({
            touchSize = self._smelterBgLayer:getContentSize(),
            musicFile = XTHD.resource.music.effect_btn_common,
            })
    op_btn:setPosition(self._smelterBgLayer:getContentSize().width/2,self._smelterBgLayer:getContentSize().height/2)
    self._smelterBgLayer:addChild(op_btn)
	-- 回收炉
	-- local smelter = sp.SkeletonAnimation:create( "res/spine/effect/compose_effect/ldl.json", "res/spine/effect/compose_effect/ldl.atlas", 1.0 )
	local smelter = sp.SkeletonAnimation:create("res/spine/effect/compose_effect/ronglianlu.json", "res/spine/effect/compose_effect/ronglianlu.atlas", 1.0)
	smelter:setAnchorPoint(cc.p(0.5, 0.5))
	smelter:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height * 0.5)
	smelter:setTimeScale(2)
	-- 先透明化
	-- smelter:setOpacity(0)
	smelterBgLayer:addChild(smelter)
	smelter:setAnimation(0, "idle", true)
	self._smelter = smelter

	self:ShowHeroList(1)

end

function YingXiongXianJi:createTableView()

	self._heroTebleView = cc.TableView:create(cc.size(530, 338))
	self._heroTebleView:setAnchorPoint(cc.p(0.5, 0.5))
	self._heroTebleView:setPosition(cc.p(295, 44))
	self._heroTebleView:setBounceable(true)
	self._heroTebleView:setDirection(ccui.ScrollViewDir.vertical)
	self._heroTebleView:setDelegate()
	self._heroTebleView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self.bg:addChild(self._heroTebleView)

	local cellSize = cc.size(self.bg:getContentSize().width - 8, 110)
	local function numberOfCellsInTableView(table)
		return math.ceil(#self._heroList / 5)
	end
	local function cellSizeForTable(table, index)
		return cellSize.width, cellSize.height
	end
	local function tableCellAtIndex(table, index)
		local cell = cc.TableViewCell:new()
		for i = 1, 5 do
			if index * 5 + i <= #self._heroList then
				local nowData = self._heroList[index * 5 + i]

				local YingXiongItem = YingXiongItem:createWithParams( {
					heroid = nowData.heroid,
					star = nowData.star,
					level = nowData.level
				} )
				YingXiongItem:setTag(index+1)
				cell:addChild(YingXiongItem)
				local x =(i - 1) *(YingXiongItem:getContentSize().width + 10) + 57
				local y = YingXiongItem:getContentSize().height / 2
				YingXiongItem:setPosition(x, y)
				local btn_selected = ccui.Scale9Sprite:create("res/image/DeleteHero/selected.png")
				cell:addChild(btn_selected)
				btn_selected:setScaleY(0.93)
				btn_selected:setScaleX(0.9)
				btn_selected:setPosition(YingXiongItem:getPositionX(), YingXiongItem:getPositionY() -3)
				btn_selected:setVisible(false)
				self._selectedBg[#self._selectedBg + 1] = btn_selected

				if self._selectHeroId == nowData.heroid then
					btn_selected:setVisible(true)
					self._selectedData = nowData
				end
				YingXiongItem:setTouchEndedCallback( function()
					nowData = self._heroList[index * 5 + i]
					for i = 1, #self._selectedBg do
						self._selectedBg[i]:setVisible(false)
					end
					self._selectedBg[index * 5 + i]:setVisible(true)
					if self._selectHeroId == nowData.heroid then
						self._selectedData = nowData
					end
					self._selectedData = nowData
					if self._selectedHero then
						self._selectedHero:removeFromParent()
						self._selectedHero = nil
					end
					self:ShowSelectedHero()
				end )
			end
		end
		return cell
	end

	self._heroTebleView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self._heroTebleView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	self._heroTebleView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	self._heroTebleView:reloadData()

end

function YingXiongXianJi:createReimbursementList()
	self._heroFree = gameData.getDataFromCSV("HeroFree", { rank = self._selectedData.star })
	local Item = ItemNode:createWithParams( {
		_type_ = 4,
		itemId = self._heroFree.getitem,
		count = self._heroFree.num,
		isShowCount = true,
	} )
	self.bg:addChild(Item)
	Item:setPosition(158, 190)
	Item:setScale(0.8)
	self._Item = Item

	local ItemListDate = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = self._heroFree.getitem })
	local itemName = XTHDLabel:create(ItemListDate.name, 21, "res/fonts/def.ttf")
	itemName:setColor(cc.c3b(255,255,255))
	itemName:setAnchorPoint(0.5, 0.5)
	Item:addChild(itemName)
	itemName:setPosition(itemName:getContentSize().width / 2 + 5, - itemName:getContentSize().height)
	itemName:enableOutline(cc.c4b(55,18,9,255),3)
end

function YingXiongXianJi:ShowSelectedHero()
	if self._selectedHero then
		self._selectedHero:removeFromParent()
		self._selectedHero = nil
	end
	local YingXiongItem = YingXiongItem:createWithParams( {
		heroid = self._selectedData.heroid,
		star = self._selectedData.star,
		level = self._selectedData.level
	} )
	self._TouXiangBg:addChild(YingXiongItem)
	YingXiongItem:setPosition(self._TouXiangBg:getContentSize().width / 2, self._TouXiangBg:getContentSize().height / 2)
	self._selectedHero = YingXiongItem
end

function YingXiongXianJi:ShowHeroList(index)
	if self._heroTebleView then
		self._heroTebleView:removeFromParent()
		self._heroTebleView = nil
		self._Item:removeFromParent()
		self._Item = nil
		self._heroList = { }
		self._selectedBg = { }
	end
	local Tishi = self.bg:getChildByName("Tishi")
	if Tishi then
		Tishi:removeFromParent()
	end
	self._selecteIndex = index
	local star = index + 4
	for k, v in pairs(DBTableHero.DBData) do
		if v.star == star then
			self._heroList[#self._heroList + 1] = v
		end
	end

	-- dump(DBTableHero.DBData)

	for i = 1, 5 do
		if i ~= index then
			self._btnList[i]:getChildByName("btnBg"):setVisible(false)
		else
			self._btnList[i]:getChildByName("btnBg"):setVisible(true)
		end
	end

	if #self._heroList >= 1 then
		self._selectHeroId = self._heroList[1].heroid
		self._selectedData = self._heroList[1]
		self:createTableView()
		self:ShowSelectedHero()
		self:createReimbursementList()
	else
		local Tishi = XTHDLabel:create("暂时还没有" .. tostring(star) .. "星英雄哦", 26, "res/fonts/def.ttf")
		Tishi:setColor(cc.c3b(0, 0, 0))
		self.bg:addChild(Tishi)
		Tishi:setAnchorPoint(0.5, 0.5)
		Tishi:setPosition(570, 220)
		Tishi:setName("Tishi")
	end
end

function YingXiongXianJi:XianJiHeroTiShi()
	print("=========================", self._selectedData.heroid)
	local Callback = function()
		XTHDHttp:requestAsyncInGameWithParams( {
			modules = "freeReset?",
			params = { petId = self._selectedData.heroid },
			successCallback = function(data)
				if data.result == 0 then
					self:UpdatePlayerData(data)
					if data.bagItems then
						local _data = data.bagItems
						local showList = { }
						for i = 1, #_data do
							showList[#showList + 1] = { rewardtype = 4, id = _data[i].itemId, num = 1 }
							DBTableItem.updateCount(gameUser.getUserId(), _data[i], _data["dbId"])
							for k,v in pairs(self._parent.items_data) do
								if v.itemid == _data[i].itemId then
									v.count = _data[i].count
								end
							end
						end
						self:runAction(cc.Sequence:create(
						cc.CallFunc:create(
						function()
							-- 开盖
							self._smelterBgLayer:setVisible(true)
							self._smelter:setAnimation(0, "atk", false)
							local pointNode = self._smelter:getNodeForSlot("xiaoguo_00017")
							if not pointNode then
								return
							end
							local pointWorldPos = pointNode:convertToWorldSpace(cc.p(-5, 40))
							local _pos = self:convertToNodeSpace(pointWorldPos) 				
						end ),
						cc.DelayTime:create(
						0.5 * 0.5
						),
						cc.CallFunc:create(
						function()
							-- 跳动
							self._smelter:setAnimation(0, "atk", true)
						end ),
						cc.DelayTime:create(
						0.8 *0.5
						),
						cc.CallFunc:create(
						function()
							self._smelter:registerSpineEventHandler(
							function(event)
								if event.eventData.name == "atk" then
									ShowRewardNode:create(showList)
									self:refreshHeroInfo(self._selectedData.heroid)
									self._parent.heroPager:reloadData(self._parent.firstHeroNumber, #self._parent.herosData)
									self._parent._heroIconTableView:reloadData()
									self:ShowHeroList(self._selecteIndex)
									XTHDTOAST("回收成功")
								end
							end , sp.EventType.ANIMATION_EVENT)
							-- 爆炸
							self._smelter:setAnimation(0, "atk", false)
						end ),
						cc.DelayTime:create(1 * 0.5),
						cc.CallFunc:create(function ()
							self._smelterBgLayer:setVisible(false)
						end)
						)
						)
					end
				else
					XTHDTOAST(data.msg)
				end
			end,
			-- 成功回调
			failedCallback = function()
				XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
			end,
			-- 失败回调
			targetNeedsToRetain = self,
			-- 需要保存引用的目标
			loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
		} )
	end

	local msg = nil
	local heroInfo = gameData.getDataFromCSV("GeneralShow", { heroid = self._selectedData.heroid })
	local text = nil
		
	local Chongsheng = function ()
		ClientHttp:httpHeroResetBackInfo(self._parent, function(data)
			data.heroid = self._selectedData.heroid
			data.advance = self._selectedData.advance
			data.level = self._selectedData.level
			requires("src/fsgl/layer/YingXiong/YingXiongResetPopLayer.lua"):create(data,self._parent)
			self:removeFromParent()
			end , { petId = self._selectedData.heroid }, function()
		end )
	end

	local HuiShouCallBack = function()
		if self._selectedData.level >= 5 then
			local _confirmLayer = XTHDConfirmDialog:createWithParams( {
				rightText = "确定",
				rightCallback = Callback,
				msg = "确定直接回收已经培养过的英雄:"..heroInfo.name.."吗？"
			} );
			self:addChild(_confirmLayer, 1)
		else
			Callback()
		end
	end	

	local back = nil
	if self._selectedData.level >= 2 then
		msg = heroInfo.name .. "已经到达" .. tostring(self._selectedData.level) .. "级，推荐重生之后再次进行回收！"
		text = "重生"
		back = Chongsheng
	else
		msg = "确定要回收" .. heroInfo.name .. "吗？"
		text = "确　定"
		back = Callback
	end

	local _confirmLayer = XTHDConfirmDialog:createWithParams( {
		rightText = text,
		rightCallback = back,
		msg = msg
	} );
	self:addChild(_confirmLayer, 1)
end

function YingXiongXianJi:refreshHeroInfo(heroid)
	local heroList = clone(self._parent.herosData)
	for k,v in pairs(heroList) do
		if v.heroid == heroid then
			heroList[k] = nil
		end
	end

	self._parent.herosData = {}
	for k,v in pairs(heroList) do
		self._parent.herosData[#self._parent.herosData + 1] = v
	end
end

function YingXiongXianJi:UpdatePlayerData(data)
	-- dump(data)
	-- 刷新已有英雄数据
	DBTableHero.removeHeroFromHeroid(self._selectedData.heroid)

	-- 刷新已有神器数据
	local tmpList = { }
	for k, v in pairs(data.godProperty) do
		tmpList[XTHD.resource.AttributesName[tonumber(k)]] = v
	end
	DBTableArtifact.multiUpdate(data.godId, tmpList)
	DBTableHero.multiUpdate(gameUser.getUserId(), data.petId, data.petProperty)
	DBTableArtifact.UpdateAtfData(gameUser.getUserId(), data.godId, "petId", 0)

	-- 刷新已有装备数据
	-- 删除equipments中的数据
	for i = 1, #data.bagItems do
		DBTableEquipment.updateHeroid(gameUser.getUserId(), 0, tostring(data.bagItems[i]["dbId"]))
	end
end

function YingXiongXianJi:create(parent)
	self._parent = parent
	self._ZhanDouLiData = data
	self._heroList = { }
	self._selectedBg = { }
	self._heroFree = nil
	self._selectedData = nil
	self._btnList = { }
	self._selecteIndex = 1
	local YingXiongXianJi = YingXiongXianJi.new()
	if YingXiongXianJi then
		YingXiongXianJi:init(parent)
		YingXiongXianJi:registerScriptHandler( function(event)
			if event == "enter" then
				YingXiongXianJi:onEnter()
			elseif event == "exit" then
				YingXiongXianJi:onExit()
			end
		end )
	end
	return YingXiongXianJi
end

function YingXiongXianJi:init(parent)
	self._parent = parent
	self._canClick = true
	-- self._heroTebleView = nil
	-- self.tableViewSize = cc.size(530,280)
end


function YingXiongXianJi:onEnter()
	local function TOUCH_EVENT_BEGAN(touch, event)
		return true
	end

	local function TOUCH_EVENT_MOVED(touch, event)
		-- body
	end

	local function TOUCH_EVENT_ENDED(touch, event)
		if self._canClick == false then
			return
		end
		local pos = touch:getLocation()
		local rect = self.bg:getBoundingBox()
		rect.width = rect.width - 50
		rect.height = rect.height - 50
		if cc.rectContainsPoint(rect, pos) == false then
			self._canClick = false
			if self.isTurnAnimEnd == false then
				return
			end
			-- self:removeFromParent()
		end
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(TOUCH_EVENT_BEGAN, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(TOUCH_EVENT_MOVED, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(TOUCH_EVENT_ENDED, cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function YingXiongXianJi:onExit()
end

return YingXiongXianJi