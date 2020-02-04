-- FileName: XuanShangRenWuLayer.lua
-- Purpose: 悬赏任务界面
--[[TODO List]]

local XuanShangRenWuLayer = class("XuanShangRenWuLayer", function()
    return XTHD.createBasePageLayer({bg = "res/image/offerReward/offerReward_bg.png"})
end)

function XuanShangRenWuLayer:onCleanup( ... )
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
    local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey("res/image/offerReward/offerReward_bg.jpg")
	textureCache:removeTextureForKey("res/image/offerReward/offerReward01.png")
end

function XuanShangRenWuLayer:ctor(data)
	self._stageInfo = {1,2,3}
	self._stageNode = {}
	self.xiangBtn = {}
	
	self._startPos = {
		{false, true, false},
		{true, false, true},
		{true, true, true},
	}

	local _node, _starNodes, _startSp, _nameNode, _descNode, _condNode, _startBtn, _nodeSize, _touchSize, _normalNode, _selectedNode, _tagSp
	local _color = cc.c3b(255,255,255)
	local _worldWidth = self:getContentSize().width
	local _showHeight = self:getContentSize().height
	local pXs = {_worldWidth*0.18, _worldWidth*0.5, _worldWidth*0.82}
	for i = 1, 3 do
		_node = ccui.Scale9Sprite:create("res/image/offerReward/offerReward01.png")
		_node:setContentSize(297,426)
		_nodeSize = _node:getContentSize()
		self:addChild(_node)
		if i == 1 then
			_node:setPosition(_worldWidth*0.5 - _nodeSize.width - 10, _showHeight*0.5 + 20)
		elseif i == 2 then
			_node:setPosition(_worldWidth*0.5, _showHeight*0.5 + 20)
		elseif i == 3 then
			_node:setPosition(_worldWidth*0.5 + _nodeSize.width + 10, _showHeight*0.5 + 20)
		end

		_starNodes = {}
		for j=1,3 do
			_startSp = cc.Sprite:create("res/image/tmpbattle/star_light.png")
			_node:addChild(_startSp)
			_startSp:setScale(0.9)
			_startSp:setPositionY(_nodeSize.height - 8)
			_starNodes[j] = _startSp
		end

		-- _nameNode = XTHDLabel:createWithSystemFont("", "Helvetica", 20)
		_nameNode = XTHDLabel:create("",20,"res/fonts/def.ttf")
		_nameNode:setColor(_color)
		_nameNode:setAnchorPoint(cc.p(0.5, 0.5))
		_nameNode:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),2)
		_nameNode:enableOutline(cc.c4b(120,50,9,255),1)
	    _nameNode:setPosition(cc.p(_nodeSize.width*0.5, _nodeSize.height - 65))
		_node:addChild(_nameNode)

		_descNode = XTHDLabel:create("", 16,"res/fonts/def.ttf")
		_descNode:setColor(cc.c3b(0,0,0))
	    _descNode:setAnchorPoint(cc.p(0, 1))
	    _descNode:setPosition(cc.p(30, _nodeSize.height - 90))
	    _descNode:setWidth(_nodeSize.width*0.82)
		_node:addChild(_descNode)
		--关卡限制
		local _condTag = XTHDLabel:create(LANGUAGE_TIPS_WORDS216,20, "res/fonts/def.ttf")
		_condTag:setColor(_color)
		--_condTag:enableShadow(cc.c4b(0,0,0,0),cc.size(1,0),2)
		_condTag:enableOutline(cc.c4b(0,0,0,0),1)
	    _condTag:setAnchorPoint(cc.p(0, 1))
	    _condTag:setPosition(cc.p(30, _nodeSize.height - 155+5))
		_node:addChild(_condTag)

		_condNode = XTHDLabel:create("", 16,"res/fonts/def.ttf")
		_condNode:setColor(cc.c3b(0,0,0))
	    _condNode:setAnchorPoint(cc.p(0, 1))
    	_condNode:setPosition(cc.p(30, _nodeSize.height - 180+5))
	    _condNode:setWidth(_nodeSize.width*0.85)
		_node:addChild(_condNode)
		--奖励
		local _rewardTag = XTHDLabel:create(LANGUAGE_TIPS_WORDS215,18, "res/fonts/def.ttf")
		_rewardTag:setColor(_color)
		_rewardTag:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),2)
		_rewardTag:enableOutline(cc.c4b(120,50,9,255),1)
	    _rewardTag:setAnchorPoint(cc.p(0, 1))
	    _rewardTag:setPosition(cc.p(40, _nodeSize.height - 222))
		_node:addChild(_rewardTag)

		_touchSize = cc.size(_nodeSize.width*0.9, 50)
    	_startBtn = XTHD.createButton({
			normalFile = "res/image/common/btn/kstz_up.png",
			selectedFile = "res/image/common/btn/kstz_down.png",
            btnSize = _touchSize,
			endCallback = function( ... )
				if self._datas and self._datas.surplusCount then
					local pNum = tonumber(self._datas.surplusCount) or 0
					if pNum <= 0 then
						XTHDTOAST(LANGUAGE_TIPS_WORDS214)
						return
					end
				end
				local _data = self._stageInfo[i]
				if type(_data) ~= "table" then
					return
				end
				if self:_checkNotHaveForcedHero(_data) then
					XTHDTOAST(LANGUAGE_TIPS_WORDS218)
					return
				end
				LayerManager.addShieldLayout()
				local _tab = {instancingid = _data.instancingid, battle_type = BattleType.OFFERREWARD_PVE, stageData = _data}
				local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongCopyLayer.lua"):createWithParams( _tab )
				fnMyPushScene(_layer)
			end,
			anchor = cc.p(0.5, 0),
			pos = cc.p(_nodeSize.width*0.5 , 40)
		})
		_startBtn:setScale(0.9)
		_node:addChild(_startBtn)

		_node._starNodes = _starNodes
		_node._nameNode = _nameNode
		_node._descNode = _descNode
		_node._condNode = _condNode
		_node._rewardNodes = {}
		_node._startBtn = _startBtn
		self._stageNode[i] = _node
	end


	_node = cc.LayerColor:create(cc.c4b(0,0,0,0), _worldWidth, 100) 
	_node:setAnchorPoint(0, 0)
	_node:setPosition(0, 0)
	self:addChild(_node)

	_showHeight = _node:getContentSize().height*0.5
	-- 刷新按钮
	local _touchSize = cc.size(150, 50)
    local btn = XTHD.createCommonButton({
		btnSize = _touchSize,
		isScrollView = false,
		endCallback = function( ... )
			local pNum = tonumber(self._datas.surplusCount) or 0
			if pNum <= 0 then
				XTHDTOAST(LANGUAGE_TIPS_WORDS214)
				return
			end
			XuanShangRenWuData.httpRefreshOfferRewardList({parNode = self, callBack = function ( sDatas )
				if tonumber(sDatas.ingot) then
					gameUser.setIngot(sDatas.ingot)
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
				end
				sDatas.starSum = self._datas.starSum
				sDatas.starReward = self._datas.starReward
				self:initUI(sDatas)
			end})
		end,
		anchor = cc.p(0,0.5),
		pos = cc.p(30 , _showHeight - 10),
		text = LANGUAGE_BTN_KEY.shuaxin,
		fontSize = 20
	})
	btn:setScaleY(0.9)
	self:addChild(btn)
	self._btnFresh = btn

	local _actionIcon = btn:getLabel()
	_actionIcon:setAnchorPoint(cc.p(0, 0.5))
	_actionIcon:setPosition(cc.p(20, btn:getContentSize().height*0.5))

	local _icon = XTHD.createSprite(XTHD.resource.getResourcePath(XTHD.resource.type.ingot))
	_icon:setAnchorPoint(cc.p(0, 0.5))
	btn:addChild(_icon)
	_icon:setPosition(cc.p(_actionIcon:getPositionX() + _actionIcon:getContentSize().width, _actionIcon:getPositionY()))

	local _numBm = getCommonWhiteBMFontLabel("")
    _numBm:setAnchorPoint(0,0.5)
    _numBm:setPosition(_icon:getPositionX() + _icon:getContentSize().width + 2, _actionIcon:getPositionY() - 7)
    btn:addChild(_numBm)
    self._costBm = _numBm

	-- 挑战次数
	local _challengeTTF = XTHDLabel:createWithParams({
		text = XTHD.resource.name[XTHD.resource.type.bounty] .. ":",
		size = 20,
		color = XTHD.resource.color.white_desc,
		anchor = cc.p(0, 0.5),
		pos = cc.p(btn:getPositionX()+ 2, _showHeight + 27),
		ttf = "res/fonts/def.ttf"
	})
	_challengeTTF:enableShadow(cc.c3b(255,255,255),cc.size(1,0),20)
--	_challengeTTF:enableOutline(cc.c4b(0,0,0,255),1)
	self:addChild(_challengeTTF)
    self._ttfChallenge = _challengeTTF

    -- 一键挑战
	btn = XTHD.createCommonButton({
		btnColor = "write",
		btnSize = _touchSize,
		isScrollView = false,
		text = LANGUAGE_BTN_KEY.yijiantiaozhan,
		fontSize = 22,
		endCallback = function ( ... )
			if self._datas and self._datas.surplusCount then
				local pNum = tonumber(self._datas.surplusCount) or 0
				if pNum <= 0 then
					XTHDTOAST(LANGUAGE_TIPS_WORDS214)
					return
				end
			else
				XTHDTOAST(LANGUAGE_TIPS_WORDS214)
				return
			end
			XuanShangRenWuData.httpChallengeOfferRewardOkey({parNode = self, callBack = function ( sDatas )
				-- self:initUI(sDatas)
				-- 显示全部获得的奖励
				XTHD.updateProperty(sDatas.playerProperty)
				XTHD.saveItem({items = sDatas.bagItems})
				local rewardList = {}
				for i=1,#sDatas.addItem do
					local itemSplit = string.split(sDatas.addItem[i],",")
					local tmpList = {
						rewardtype = 4,
						id = itemSplit[1],
						num = itemSplit[2]
					}
					rewardList[#rewardList+1] = tmpList
				end
				rewardList[#rewardList+1] = {
					rewardtype = XTHD.resource.type.bounty,
					num = sDatas.addBounty
				}
				rewardList[#rewardList+1] = {
					rewardtype = XTHD.resource.type.exp,
					num = sDatas.addExp
				}
				ShowRewardNode:create(rewardList,3)


				-- 处理完添加数据显示之后获取数据做刷新界面
				XuanShangRenWuData.httpGetOfferRewardData({parNode = self, callBack = function ( sDatas )
					self:initUI(sDatas)
				end})
			end})
		end,
		anchor = cc.p(0.5, 0.5),
		pos = cc.p(_worldWidth*0.5, _showHeight)
	})
	_node:addChild(btn)
	self._oneKey = btn
	btn:setVisible(false)

	--商店按钮
	_touchSize = cc.size(150, 50)
    btn = XTHD.createButton({
		normalFile = "res/image/offerReward/change.png",
		selectedFile = "res/image/offerReward/change.png",
		touchSize = _touchSize,
		endCallback = function ( ... )
			
		end,
		anchor = cc.p(1,0.5),
		pos = cc.p(_worldWidth - 10, _showHeight)
	})
	
	btn:setTouchBeganCallback(function()
		btn:setScale(0.78)
	end)
	
	btn:setTouchMovedCallback(function()
		btn:setScale(0.8)
	end)

	btn:setTouchEndedCallback(function()
		btn:setScale(0.8)
		local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("reward")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
	end)

	btn:setScale(0.8)
	_node:addChild(btn)
	self._btnShop = btn

	_icon = cc.Sprite:create(XTHD.resource.getResourcePath(XTHD.resource.type.bounty))
	_icon:setAnchorPoint(1, 0.5)
	_icon:setPosition(btn:getPositionX() - 80, _showHeight-10)
	_node:addChild(_icon)

	_numBm = getCommonWhiteBMFontLabel("")
    _numBm:setAnchorPoint(1, 0.5)
    _numBm:setPosition(_icon:getPositionX() - _icon:getContentSize().width - 5, _showHeight - 17)
    _node:addChild(_numBm)
    self._bountyNumBm = _numBm


	self._starTa = {
		tonumber(gameData.getDataFromCSV("XsTaskReward", {["id"]=1}).stars),
		tonumber(gameData.getDataFromCSV("XsTaskReward", {["id"]=2}).stars),
		tonumber(gameData.getDataFromCSV("XsTaskReward", {["id"]=3}).stars),
	}

	local gole = XTHDLabel:create(LANGUAGE_KEY_HAVEGOT(data.starSum,self._starTa[#self._starTa]),18,"res/fonts/def.ttf")
	gole:setAnchorPoint(0,0.5)
	gole:setPosition(cc.p(self:getContentSize().width/2 - 260,_showHeight - 10))
	_node:addChild(gole)
	self._gole = gole

 	local star = cc.Sprite:create("res/image/offerReward/item_star.png")
	star:setAnchorPoint(0,0.5)
	star:setPosition(gole:getPositionX()+gole:getContentSize().width, _showHeight - 10)
	_node:addChild(star)
	self._star = star

	--progressBar
	local progressBg = ccui.Scale9Sprite:create("res/image/offerReward/progressBg.png")
	-- progressBg:setContentSize(375,47)
	progressBg:setAnchorPoint(cc.p(0,0.5))
	progressBg:setPosition(cc.p(star:getPositionX()+star:getContentSize().width +10, _showHeight - 10))
	progressBg:setScaleX(0.75)
	progressBg:setScaleY(0.8)
	_node:addChild(progressBg)

	local progressBar = cc.ProgressTimer:create(cc.Sprite:create("res/image/offerReward/progressBar.png"))
	progressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	progressBar:setMidpoint(cc.p(0,0.5))
	progressBar:setBarChangeRate(cc.p(1,0))
	progressBar:setAnchorPoint(cc.p(0.5,0.5))
	progressBar:setPosition(cc.p(progressBg:getContentSize().width/2,progressBg:getContentSize().height/2))
	progressBg:addChild(progressBar)
	self._progressBar = progressBar


	self._spineList = {}
	self._rewardBtn = {}

	local initPosx = progressBg:getPositionX() + 350/3
	for i = 1, 3 do
		local rewardBtn = XTHDPushButton:createWithParams({
			touchSize = cc.size(80,80),
			musicFile = XTHD.resource.music.effect_btn_common,
		})
		rewardBtn:setPosition(initPosx + 360/3 * (i-1) , _showHeight + 23)
		_node:addChild(rewardBtn)
		self._rewardBtn[#self._rewardBtn+1] = rewardBtn
	    -- local _spine = sp.SkeletonAnimation:create("res/spine/effect/qiandai/qiandai.json","res/spine/effect/qiandai/qiandai.atlas",1.0)
		-- _node:addChild(_spine) 
	    -- _spine:setPosition(initPosx + 360/3 * (i-1) , _showHeight + 23)
		--  self._spineList[#self._spineList+1] = _spine
		 --看效果的图片
--		if tonumber(data[i].state) == 0 then --未领取
--            xiangzi = ccui.Scale9Sprite:create("res/image/camp/camp_task_box" .. i .. "_1.png")
--        else
--            xiangzi = ccui.Scale9Sprite:create("res/image/camp/camp_task_box" .. i .. "_2.png")
--        end
		local xiangzi = cc.Sprite:create("res/image/camp/camp_task_box" .. (i + 2) .. "_1.png")
		_node:addChild(xiangzi)
		xiangzi:setPosition(initPosx + 360/3 * (i-1) , _showHeight + 20)
		if i == 3 then
			xiangzi:setScale(0.6)
		else
			xiangzi:setScale(0.7)
		end
		self.xiangBtn[i] = xiangzi
		
	 	local starNum = XTHDLabel:createWithSystemFont(self._starTa[i],"Helvetica",22)
	 	_node:addChild(starNum)
	 	starNum:setPosition(initPosx + 360/3 * (i-1) -10, _showHeight - 30)
	 	local just = 0
	 	if i == 1 then
			just = 6
	 	end
	 	local starImg = cc.Sprite:create("res/image/offerReward/item_star.png")
	 	_node:addChild(starImg)
	 	starImg:setPosition(starNum:getPositionX()+starNum:getContentSize().width + just, _showHeight - 30)

	end
end

function XuanShangRenWuLayer:refreshSpineList()


end

function XuanShangRenWuLayer:onEnter( ... )
	if self.haveIn then
		XuanShangRenWuData.httpGetOfferRewardData({parNode = self, callBack = function ( sDatas )
			self:initUI(sDatas)
		end})
	end
	self.haveIn = true
    -----------引导
    YinDaoMarg:getInstance():addGuide({index = 5,parent = self},13) 
    YinDaoMarg:getInstance():doNextGuide()
end

function XuanShangRenWuLayer:onExit( ... )
	-- XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_TOP_INFO)
end

function XuanShangRenWuLayer:initUI( sDatas )
	self._datas = sDatas
	local _data, _node
	for i=1, 3 do
		_data = gameData.getDataFromCSV("XsTaskList", {["instancingid"] = sDatas.list[i]})
		print("ID大的点点滴滴：" .. sDatas.list[i])
		self._stageInfo[i] = _data
		_node = self._stageNode[i]
		if _data and _G.next(_data) ~= nil and _node then
			self:freshStartPos(_data.starlevel, _node._starNodes, _node:getContentSize().width*0.5)
			_node._nameNode:setString(_data.name)
			_node._descNode:setString(_data.description)
			_node._condNode:setString(_data.tips)
			for i=1,#_node._rewardNodes do
				_node._rewardNodes[i]:removeFromParent()
				_node._rewardNodes[i] = nil
			end
			_node._rewardNodes = {}
			local items = {}
			if _data.bountyreward > 0 then
				items[#items + 1]  = {
                    ["_type_"] = XTHD.resource.type.bounty,
                    ["isShowCount"] = true,
                    ["count"] = _data.bountyreward
                }
			end
			if _data.expierence > 0 then
				items[#items + 1]  = {
                    ["_type_"] = XTHD.resource.type.exp,
                    ["isShowCount"] = true,
                    ["count"] = _data.expierence
                }
			end
			local _itemrewards = string.split(_data.itemreward or "", '#')
			for j = 1,#_itemrewards do
				if _itemrewards[j] and #_itemrewards[j] > 0 then
					local _dropInfo = gameData.getDataFromCSV("ExploreDropList", {["dropid"] = _itemrewards[j]}).dropprops1
					local _itemInfo = string.split(_dropInfo or "", '#')
					-- local _item = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=_itemInfo[1]})
					items[#items + 1]  = {
						["_type_"] = XTHD.resource.type.item,
						itemId = _itemInfo[1],
					}
				end
			end	
            local _width = _node:getContentSize().width*0.5
            local pH = 150
			for k=1, #items do
                local equip_data = items[k]
                if equip_data then
                    local equip_item = ItemNode:createWithParams(equip_data)
                    if not equip_item then
                        break
                    end
                    local pScale = 0.5
                    equip_item:setScale(pScale)
                    local pWidth = equip_item:getContentSize().width*pScale
					equip_item:setAnchorPoint(0.5, 0.5)
					equip_item:setPosition(_width - pWidth*0.5 - 60 + (k - 1)*55 , pH)
                    _node._rewardNodes[#_node._rewardNodes + 1] = equip_item
                    _node:addChild(equip_item)
                    if k ~= 3 then
                    	local pSp = cc.Sprite:create("res/image/offerReward/offerReward03.png")
                    	equip_item:addChild(pSp)
                    	pSp:setAnchorPoint(0,1)
                    	pSp:setPosition(-3, equip_item:getContentSize().height + 2)
                    	pSp:setScale(1/0.8)
                    end
                end
            end
		end
	end

	if self._ttfChallenge then
		local pNum1 = tonumber(sDatas.surplusCount) or 0
		local pNum2 = tonumber(sDatas.maxCount) or 0
		self._ttfChallenge:setString(LANGUAGE_TIPS_WORDS213(pNum1, pNum2))
	end
	if self._costBm then
		local pNum = tonumber(self._datas.needIngot) or 0
		self._costBm:setString(pNum)
	end
	if self._bountyNumBm then
		self._bountyNumBm:setString(gameUser.getBounty())
	end

	--

	local rewardState = {0,0,0}
	for i = 1, 3 do
		if tonumber(sDatas.starSum) >= self._starTa[i] and rewardState[i] == 0 then
			rewardState[i] = 1
		end

		if sDatas.starReward[i] then
			if tonumber(sDatas.starReward[i]) == self._starTa[1] then
				rewardState[1] = 2
			elseif tonumber(sDatas.starReward[i]) == self._starTa[2] then
				rewardState[2] = 2
			elseif tonumber(sDatas.starReward[i]) == self._starTa[3] then
				rewardState[3] = 2
			end
		end
	end

	for i = 1, 3 do
	    local ani
	    if rewardState[i] == 0 then
	    	ani = "hd"..i.."0"
	    elseif rewardState[i] == 1 then
	    	ani = "hd"..i.."1"
	    elseif rewardState[i] == 2 then
	    	ani = "hd"..i.."2"
	    end
		if rewardState[i] == 2 then
			self.xiangBtn[i]:initWithFile("res/image/camp/camp_task_box" .. (i + 2) .. "_2.png")
		end
		--满足星星个数箱子上的动作
	    -- self._spineList[i]:setAnimation(0,ani,true) 
		local _scale = self.xiangBtn[i]:getScale()
		self._rewardBtn[i]:setTouchBeganCallback(function()
			self.xiangBtn[i]:setScale(_scale - 0.1)
		end)

		self._rewardBtn[i]:setTouchMovedCallback(function()
			self.xiangBtn[i]:setScale(_scale)
		end)

	 	self._rewardBtn[i]:setTouchEndedCallback(function()
			self.xiangBtn[i]:setScale(_scale)
	 		local function refresh(data)
	 			self._datas.starReward = data.starReward
	 			self:initUI(self._datas)
	 		end
	 		local params = {type=i, state = rewardState[i],callback = refresh}   --state == 1,可领取 2已领取，0不可领取
            local reward_pop=requires("src/fsgl/layer/XuanShangRenWu/XuanShangRenWuGetPopLayer.lua"):create(params)
            LayerManager.addLayout(reward_pop, {noHide = true})
	 	end)
	end
	
	self._progressBar:setPercentage(tonumber(sDatas.starSum)/self._starTa[#self._starTa] * 100)
	self._gole:setString(LANGUAGE_KEY_HAVEGOT(sDatas.starSum,self._starTa[#self._starTa]))
	self._star:setPosition(self._gole:getPositionX()+self._gole:getContentSize().width, self._gole:getPositionY())

end

function XuanShangRenWuLayer:freshStartPos( _num, _starNodes, midPosX )
	local _datas = self._startPos[_num]
	for i=1, #_starNodes do
		local pNode = _starNodes[i]
		if pNode then
			pNode:setVisible(_datas[i])
			if _datas[i] then
				if _num == 2 then
					if i == 1 then
						pNode:setPositionX(midPosX - pNode:getContentSize().width*0.5 - 2)
					elseif i == 3 then
						pNode:setPositionX(midPosX + pNode:getContentSize().width*0.5 + 2)
					end
				else
					if i == 1 then
						pNode:setPositionX(midPosX - pNode:getContentSize().width - 2)
					elseif i == 2 then
						pNode:setPositionX(midPosX)
					elseif i == 3 then
						pNode:setPositionX(midPosX + pNode:getContentSize().width + 2)
					end
				end
			end
		end
	end
end

function XuanShangRenWuLayer:_checkHaveHero( _id )
	local _heroData = DBTableHero.getData(gameUser.getUserId())
	for k,v in pairs(_heroData) do
		if _id == v.heroid then
			return true
		end
	end
	return false
end

function XuanShangRenWuLayer:_checkNotHaveForcedHero( _stageData )
	if not _stageData then
		return false
	end
	local function _checkNotHave( sCond, sValue)
		local _cond = tonumber(sCond) or 0
		if _cond ~= 1 then
			return false
		end
		local _tab = string.split(sValue or "", '#') or {}
		for k,v in pairs(_tab) do
			local have = self:_checkHaveHero(tonumber(v) or 0)
			if not have then
				return true
			end
		end
		return false
	end
	if _checkNotHave(_stageData.condition1, _stageData.value1) then
		return true
	end

	return _checkNotHave(_stageData.condition2, _stageData.value2)
end

function XuanShangRenWuLayer:createForLayerManager( sParams )
	local function createSelf( datas )
		LayerManager.addShieldLayout()
		local lay = XuanShangRenWuLayer.new(datas)
		lay:initUI(datas)
        LayerManager.addLayout(lay)
	end
	XuanShangRenWuData.httpGetOfferRewardData({parNode = sParams.node, callBack = createSelf})
end

return XuanShangRenWuLayer