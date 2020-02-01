--Author:xing chen
--Data:2015-10-14
--purpose:查看其他玩家英雄资料
local ChaKanOtherPlayerInfoLayer = class("ChaKanOtherPlayerInfoLayer",function()
	return XTHD.createBasePageLayer({showPlus = false})
end)

function ChaKanOtherPlayerInfoLayer:ctor(data)
	self.heroListData = {}
	self._fontSize = 18
	self.tabState = 1 				--左侧状态
	self.selectedIndex = 0
	self.selectedHeroSp = nil
	
	self.data = {}
	self.staticItemInfoData = {}

	self.bottomBg = nil

	self.leftInfoBg = nil
	self.rightInfoBg = nil
	self.current_tab_layer = nil
	self.heroSpine = nil
	self.heroBg = nil
	self.tabBtnArr = {} 				--下边按钮
	self.starBg_arr = {} 				--星星背景
	self.heroEquipmentsTable = {} 		--装备背景

	self:setStaticItemInfoData()
	self:setHeroListData(data)
	self:initLayer()
end
function ChaKanOtherPlayerInfoLayer:onCleanup( ... )
    -- local textureCache = cc.Director:getInstance():getTextureCache()
    -- textureCache:removeTextureForKey("res/image/activities/activity_bg.jpg")
end
function ChaKanOtherPlayerInfoLayer:initLayer()
	local _topBarHeight = self.topBarHeight or 40


	local _bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
	_bg:setPosition(cc.p(self:getContentSize().width/2,(self:getContentSize().height - _topBarHeight)/2))
	self._bg = _bg
	self:addChild(_bg)
	
	local title = "res/image/public/heroInfo_title.png"
	XTHD.createNodeDecoration(self._bg,title)

	
    local bsize=_bg:getContentSize()

	self:setBottomLayer()

	local _rightSize = cc.size(480,bsize.height-150)
	-- local _rightInfoBg = cc.Sprite:createWithTexture(nil, cc.rect(0,0,_rightSize.width,_rightSize.height))
	local _rightInfoBg = ccui.Scale9Sprite:create("res/image/plugin/hero/heroBg_Image2.png")
	_rightInfoBg:setContentSize(cc.size(_rightSize.width+40,_rightSize.height))
	-- _rightInfoBg:setOpacity(0)
	_rightInfoBg:setAnchorPoint(cc.p(1,1))
	_rightInfoBg:setPosition(bsize.width-48,bsize.height-39)
	self.rightInfoBg = _rightInfoBg
	self._bg:addChild(_rightInfoBg)
	--tab
 	local _btnName = {"Shuxing","Jineng","Neigong","Shenqi"}
 	local _tabPosWidth = _rightInfoBg:getContentSize().width/8
	for i=1,4 do
		local _tabBtn = XTHD.createButton({
				normalFile = "res/image/plugin/hero/hero" .. _btnName[i] .. "_normal.png",
				selectedFile = "res/image/plugin/hero/hero" .. _btnName[i] .. "_selected.png",
			})
			_tabBtn:setScale(0.8)
		_tabBtn:setAnchorPoint(cc.p(0.5,0))
		_tabBtn:setPosition(cc.p(_tabPosWidth*(i*2-1),0))
		self.tabBtnArr[i] = _tabBtn
		_tabBtn:setTouchEndedCallback(function()
				self:setTabCallback(i)
			end)
		_rightInfoBg:addChild(_tabBtn)
	end
	self:refreshHeroFunction()
	self:setRightLayer()

end

function ChaKanOtherPlayerInfoLayer:setRightLayer()
	if self.rightInfoBg ==nil then
		return
	end
	--人物后面的太极图片
	local _heroBg = cc.Sprite:create("res/image/plugin/hero/heroBg_Image.png")
	self.heroBg = _heroBg
	_heroBg:setOpacity(0)
	_heroBg:setPosition(cc.p(self.rightInfoBg:getContentSize().width/2,self.rightInfoBg:getContentSize().height - 8 - _heroBg:getContentSize().height/2))
	self.rightInfoBg:addChild(_heroBg)

	--英雄
	self:refreshHeroSpine()

	local _rightMidPosY = self.rightInfoBg:getContentSize().height - 255-5
	local _namePosY = (_rightMidPosY + 88)/2

	--英雄名称
	local _heroNameSp =  XTHD.createHeroNameShowSprite(self.data["name"], self.data["phaseLevel"],self.data.id)
 	-- cc.Sprite:create("res/image/plugin/hero/heroName_white.png")
 	self.heroNameSp = _heroNameSp
 	_heroNameSp:setAnchorPoint(cc.p(0.5,0))
 	_heroNameSp:setPosition(cc.p(self.rightInfoBg:getContentSize().width/2,_namePosY - _heroNameSp:getContentSize().height/2))
 	self.rightInfoBg:addChild(_heroNameSp)
 	--英雄战斗力
 	local _heroPowerSp = XTHD.createPowerShowSprite(self.data["power"])
 	self.heroPowerSp = _heroPowerSp
 	_heroPowerSp:setAnchorPoint(cc.p(0.5,1))
 	_heroPowerSp:setPosition(cc.p(self.rightInfoBg:getContentSize().width/2,self.rightInfoBg:getContentSize().height - 15))
 	self.rightInfoBg:addChild(_heroPowerSp)

 	--英雄等级，类型
	 local _levelposY = _namePosY - 25
	 --等级
 	local _levelTitleLabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.LevelTitleTextXc .. ":",self._fontSize+4)
 	_levelTitleLabel:setColor(self:getTextColor("baise"))
 	_levelTitleLabel:setAnchorPoint(cc.p(0,0))
 	_levelTitleLabel:setPosition(cc.p(20,_levelposY))
 	self.rightInfoBg:addChild(_levelTitleLabel)

 	local _levelLabel = XTHDLabel:create(self.data.level or 1,self._fontSize+4)
 	self.levelLabel = _levelLabel
 	_levelLabel:setColor(self:getTextColor("baise"))
 	_levelLabel:setAnchorPoint(cc.p(0,0))
 	_levelLabel:setPosition(cc.p(_levelTitleLabel:getBoundingBox().x+_levelTitleLabel:getBoundingBox().width,_levelposY))
 	self.rightInfoBg:addChild(_levelLabel)

	 --类型
 	local _typeTitleLabel = XTHDLabel:create(LANGUAGE_KEY_TYPE .. ":",self._fontSize+4)
 	_typeTitleLabel:setColor(self:getTextColor("baise"))
 	_typeTitleLabel:setAnchorPoint(cc.p(-0.5,0))
 	_typeTitleLabel:setPosition(cc.p(_heroNameSp:getBoundingBox().x+_heroNameSp:getBoundingBox().width + 30,_levelposY)) 
 	self.rightInfoBg:addChild(_typeTitleLabel)

 	local _typeLabel = XTHDLabel:create(LANGUAGE_TIPS_WORDS105[tonumber(self.data.type or 1)],self._fontSize+4)
 	self.typeLabel = _typeLabel
 	_typeLabel:setAnchorPoint(cc.p(0,0))
 	_typeLabel:setColor(self:getTextColor("baise"))
 	_typeLabel:setPosition(cc.p(_typeTitleLabel:getBoundingBox().x+_typeTitleLabel:getBoundingBox().width,_levelposY))
 	self.rightInfoBg:addChild(_typeLabel)

 	--星级
	self:createStarAndMoon()

-- 	local _topStarPosX = 103
-- 	local _topStarPosY = self.rightInfoBg:getContentSize().height - 140
-- 	local _starNum = self.data and self.data.starLevel or 1
-- 	for i=1,5 do
-- 		local _starBg = cc.Sprite:create("res/image/common/star_dark.png")
-- 		_starBg:setPosition(cc.p(_topStarPosX+20,_topStarPosY + _starBg:getContentSize().height/2))
-- 		_starBg:setScale(0.93)
-- 		self.rightInfoBg:addChild(_starBg)
-- 		self.starBg_arr[i] = _starBg
-- 		_topStarPosY = _topStarPosY + _starBg:getBoundingBox().height +2
-- 		if tonumber(_starNum)>=i then
-- 			local _starSpr= cc.Sprite:create("res/image/common/star_light.png")
-- 			_starSpr:setName("starSpr")
-- 			_starSpr:setPosition(cc.p(_starBg:getContentSize().width/2,_starBg:getContentSize().height/2))
-- 			_starBg:addChild(_starSpr)
-- 		end
-- 	end

 	--装备
 	local _distanceX = 15
 	local _equipPosX = {_distanceX+20,tonumber(self.rightInfoBg:getContentSize().width-_distanceX)-20}
 	local _equipPosY = {tonumber(self.rightInfoBg:getContentSize().height - 15),0,_rightMidPosY + 5}
 	_equipPosY[2] = (_equipPosY[1]+_equipPosY[3])/2
 	local _equipAnchorX = {0,1}
 	local _equipAnchorY = {1,0.5,0}
 	--1,3,5是左侧列，锚点是cc.p(_equipAnchorX[1],_equipAnchorY[i])
 	for i = 0,5 do
 		local _equipItem_spr = cc.Sprite:create("res/image/item/part" .. (i+1) .. ".png")
 		local _id_x = i%2+1
 		local _id_y = math.floor(i/2+1)
 		_equipItem_spr:setAnchorPoint(cc.p(_equipAnchorX[_id_x],_equipAnchorY[_id_y]))
 		local _itemPos = cc.p(_equipPosX[_id_x],_equipPosY[_id_y])
		 _equipItem_spr:setPosition(_itemPos)
		 _equipItem_spr:setScale(0.6)
 		self.rightInfoBg:addChild(_equipItem_spr)
 		self.heroEquipmentsTable[tonumber(i+1)] = _equipItem_spr
 	end
 	self:refreshHeroEquipments()

 	self:setTabCallback(1,false)
end

--创建星星和月亮
function ChaKanOtherPlayerInfoLayer:createStarAndMoon()
    local _topStarPosX = 103
    local _topStarPosY = self.rightInfoBg:getContentSize().height - 155
    local _starNum = self.data and self.data.starLevel or 1
	if _starNum <= 5 then
		for i = 1,_starNum do
			local _starBg = cc.Sprite:create("res/image/common/star_icon.png")
			_starBg:setPosition(cc.p(_topStarPosX + 20, _topStarPosY + _starBg:getContentSize().height / 2))
			_starBg:setScale(0.9)
			self.rightInfoBg:addChild(_starBg)
			self.starBg_arr[i] = _starBg
			_topStarPosY = _topStarPosY + _starBg:getBoundingBox().height + 2
		end
	else
		local moonC = math.floor(_starNum/6)
		local starC = _starNum%6
--		print("月亮星星的数量："..starC.."  "..moonC)
		for i = 1,moonC do
			local _moonBg = cc.Sprite:create("res/image/common/moon_icon.png")
			_moonBg:setPosition(cc.p(_topStarPosX + 20, _topStarPosY + _moonBg:getContentSize().height / 2))
			_moonBg:setScale(0.9)
			self.rightInfoBg:addChild(_moonBg)
			self.starBg_arr[i] = _moonBg
			_topStarPosY = _topStarPosY + _moonBg:getBoundingBox().height + 2
		end
		for i = moonC + 1,moonC + starC do
			local _starBg = cc.Sprite:create("res/image/common/star_icon.png")
			_starBg:setPosition(cc.p(_topStarPosX + 20, _topStarPosY + _starBg:getContentSize().height / 2))
			_starBg:setScale(0.9)
			self.rightInfoBg:addChild(_starBg)
			self.starBg_arr[i] = _starBg
			_topStarPosY = _topStarPosY + _starBg:getBoundingBox().height + 2
		end
	end
end

function ChaKanOtherPlayerInfoLayer:setBottomLayer()
	local _bottomBg = ccui.Scale9Sprite:create()
	self.bottomBg = _bottomBg
	_bottomBg:setAnchorPoint(cc.p(0.5,0))
	_bottomBg:setContentSize(cc.size(self._bg:getContentSize().width,111))
	_bottomBg:setPosition(cc.p(self._bg:getContentSize().width/2,0))
	self._bg:addChild(_bottomBg)

	local _heroListNumber = 8
    if #self.heroListData >8 then
		_heroListNumber = #self.heroListData
	end
	local _cellWidth = 104
	local _tableViewSize = cc.size(_cellWidth*8,_bottomBg:getContentSize().height)
	local _tableViewCellSize = cc.size(_cellWidth,_tableViewSize.height)
	local _tableView = CCTableView:create(_tableViewSize)
    TableViewPlug.init(_tableView)
	_tableView:setPosition(cc.p((self._bg:getContentSize().width -_tableViewSize.width)/2,0))
    -- _tableView:setBounceable(true)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) --设置横向纵向
    _tableView:setDelegate()

    self._bg:addChild(_tableView)

    --左边箭头
    local _arrowDistance = (self._bg:getContentSize().width - _tableViewSize.width)/4
    local _leftScrollBtn = XTHD.createButton({
            normalFile = "res/image/plugin/stageChapter/btn_left_arrow.png",
            selectedFile = "res/image/plugin/stageChapter/btn_left_arrow.png",
            touchScale = 0.95
        })
    _leftScrollBtn:setAnchorPoint(cc.p(0.5,0.5))
    _leftScrollBtn:setPosition(cc.p(_arrowDistance+3,_bottomBg:getContentSize().height/2))
    _bottomBg:addChild(_leftScrollBtn)
    _leftScrollBtn:setTouchEndedCallback(function()
            _tableView:scrollToNext()
        end)
    --右边箭头
    local _rightScrollBtn = XTHD.createButton({
            normalFile = "res/image/plugin/stageChapter/btn_right_arrow.png",
            selectedFile = "res/image/plugin/stageChapter/btn_right_arrow.png",
            touchScale = 0.95
            -- ,musicFile = XTHD.resource.music.effect_btn_common
        })
    _rightScrollBtn:setAnchorPoint(cc.p(0.5,0.5))
    _rightScrollBtn:setPosition(cc.p(_bottomBg:getContentSize().width - _arrowDistance,_bottomBg:getContentSize().height/2))
    _bottomBg:addChild(_rightScrollBtn)

    _rightScrollBtn:setTouchEndedCallback(function()
            _tableView:scrollToLast()
        end)

    -- self.isScrolling = false

    local function numberOfCellsInTableView(table_view)
    	return _heroListNumber
    end
    local function cellSizeForTable(table_view, idx)
    	return _tableViewCellSize.width,_tableViewCellSize.height
    end
    -- local function scrollViewDidScroll(table_view)
    -- 	self.isScrolling = true
    -- end
    local function tableCellAtIndex(table_view, idx)
    	local cell = table_view:dequeueCell()
    	if cell then
    		if cell:getChildByName("heroBtn") then
    			local _heroBtn = cell:getChildByName("heroBtn")
    			if _heroBtn.isSelected ~= nil and _heroBtn.isSelected == true then
    				self.selectedHeroSp = nil
	    			_heroBtn.isSelected = nil
    			end
    		end
    		cell:removeAllChildren()
    	else
    		cell = cc.TableViewCell:create()
    	end
    	local _heroData = self.heroListData[idx+1]
    	if _heroData ==nil or next(_heroData)==nil then
    		-- local _noneHeroSp = cc.Sprite:create("res/image/common/no_hero.png")
    		local _noneHeroSp = cc.Sprite:create("res/image/imgSelHero/hero_box.png")
    		_noneHeroSp:setPosition(cc.p(_tableViewCellSize.width/2,_tableViewCellSize.height/2))
    		cell:addChild(_noneHeroSp)
    		return cell
    	end

    	local _heroSp = YingXiongItem:createWithParams({
	        	heroid = _heroData.id,
	        	star = _heroData.starLevel,
	        	level = _heroData.level,
	        	advance = _heroData.phaseLevel
	    	})
    	_heroSp:setScale(92/_heroSp:getContentSize().width)
    	_heroSp:setPosition(cc.p(_tableViewCellSize.width/2,_tableViewCellSize.height/2))
    	cell:addChild(_heroSp)

    	local _normalSprite = cc.Sprite:createWithTexture(nil,cc.rect(0,0,105,106))
    	_normalSprite:setOpacity(0)
    	local _heroBtn = XTHD.createButton({
    			normalNode = _normalSprite,
    			selectedNode = cc.Sprite:create("res/image/common/heroSelected_sp.png"),
    			needEnableWhenMoving = true,
    			-- beganCallback = function()
	    		-- 	self.isScrolling = false
	    		-- end
    		})
    	_heroBtn:setTouchEndedCallback(function()
    			-- if self.isScrolling~=nil and self.isScrolling == false then
	    			_heroBtn.isSelected = true
	    			_heroBtn:setSelected(true)
	    			if self.selectedHeroSp ~= nil then
	    				self.selectedHeroSp.isSelected = false
	    				self.selectedHeroSp:setSelected(false)
	    				self.selectedHeroSp = nil
	    			end
	    			self.selectedHeroSp = _heroBtn
	    			self.selectedIndex = idx
	    			self:refreshHeroInfoLayer(idx+1)
	    		-- end
    			-- self.isScrolling = false
    		end)
    	_heroBtn:setSwallowTouches(false)
    	_heroBtn:setName("heroBtn")
    	_heroBtn:setPosition(cc.p(_tableViewCellSize.width/2,_tableViewCellSize.height/2))
    	cell:addChild(_heroBtn)

    	if self.selectedIndex == idx then
    		self.selectedHeroSp = _heroBtn
    		if self.selectedHeroSp ~= nil then
    			self.selectedHeroSp:setSelected(false)
    			self.selectedHeroSp.isSelected = false
    			self.selectedHeroSp = nil
    		end
    		self.selectedHeroSp = _heroBtn
    		_heroBtn:setSelected(true)
    		_heroBtn.isSelected = true
    	end

    	return cell
    end
    _tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView.getCellNumbers=numberOfCellsInTableView
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView.getCellSize=cellSizeForTable
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:reloadData()
end

function ChaKanOtherPlayerInfoLayer:setTabCallback(_idx,isAnimation)
	for k,var in pairs(self.tabBtnArr) do
		var:setSelected(false)
	end
	if self.tabBtnArr[_idx]~=nil then
		self.tabBtnArr[_idx]:setSelected(true)
	end
	if isAnimation ~=nil and isAnimation == false then
		self:setLayerState(_idx)
	else
		self:setLeftLayerChange(_idx)
	end
end

--设置左侧的收缩和恢复
function ChaKanOtherPlayerInfoLayer:setLeftLayerChange(state_type)
	local _actionTable = {}

	_actionTable[#_actionTable + 1] = cc.CallFunc:create(function()
			--按钮设为不可点击
	    	self:setTabButtonState(false)
		end)
	-- _actionTable[#_actionTable + 1] = cc.MoveBy:create(0.3,cc.p(self.leftInfoBg:getBoundingBox().width+10,0))
	_actionTable[#_actionTable + 1] = cc.CallFunc:create(function()
			self:setLayerState(state_type)
		end)
	--恢复动画
	_actionTable[#_actionTable + 1] = cc.Spawn:create(cc.Sequence:create(cc.DelayTime:create(0.15),cc.CallFunc:create(function()
			--按钮设为可点击
	    	self:setTabButtonState(true)
		end)))
	-- , cc.MoveBy:create(0.3,cc.p(-self.leftInfoBg:getBoundingBox().width-10,0)))
	self:runAction(cc.Sequence:create(_actionTable))
end
--设置各个小界面的切换，左侧的内容切换和位置恢复
function ChaKanOtherPlayerInfoLayer:setLayerState( state_type) --显示那些界面功能
	if self.tabBtnArr[tonumber(state_type)] ~= nil  then
		if self.tabBtnArr[tonumber(state_type)]:isEnable()==false then
			self:setTabCallback(1)
			return
		end
	end
	--升星，进阶，升技能，升级的func
	local _fileNameTable = {
		"HaoYou/ChaKanDetailPropertyLayer.lua",
		"HaoYou/ChaKanOtherSkillLayer.lua",
		"HaoYou/ChaKanOtherInternalLayer.lua",
		"HaoYou/ChaKanOtherArtifactLayer.lua",
	}
	local _stateIndex = state_type or 1
	self.tabState = _stateIndex 
    if self.current_tab_layer~=nil then
        self.current_tab_layer:removeFromParent()
        self.current_tab_layer = nil
    end
    local _node = requires("src/fsgl/layer/" .. _fileNameTable[_stateIndex])
    self.current_tab_layer = _node:create({
    		_data = self.data,
    		_contentSize = cc.size(400,380),
    		_parentLayer = self
    	})
    self.current_tab_layer:setAnchorPoint(cc.p(0,0))
    self.current_tab_layer:setPosition(28,100)
    self._bg:addChild(self.current_tab_layer)
end

function ChaKanOtherPlayerInfoLayer:setTabButtonState(_flag)
	for k,var in pairs(self.tabBtnArr) do
		var:setClickable(_flag)
	end
end
---
function ChaKanOtherPlayerInfoLayer:createHeroSpine(_id)
	local _spine_sp = XTHD.getHeroSpineById(_id)
	_spine_sp:setAnimation(0,"idle",true)
	_spine_sp:setScale(0.8)
	return _spine_sp
end

function ChaKanOtherPlayerInfoLayer:createEquipedItemBtn(_itemData)
	-- dump(_itemData)
    local _itemdInfoData = _itemData or{}
	local _itemPath = XTHD.resource.getItemImgById(_itemdInfoData._resourceid or 0)
	local _bgPath = XTHD.resource.getQualityItemBgPath(_itemdInfoData._rank or 1)
	local _itemSp = cc.Sprite:create(_itemPath)
	local _itembg = cc.Sprite:create(_bgPath)
	_itembg:setPosition(cc.p(_itemSp:getContentSize().width/2,_itemSp:getContentSize().height/2))
	_itemSp:addChild(_itembg)

    local level_bg = cc.Sprite:create("res/image/common/common_herolevelBg.png")
    level_bg:setTag(1)
    level_bg:setName("level_bg")
    level_bg:setAnchorPoint(0,0)
    level_bg:setPosition(0,15)
    _itemSp:addChild(level_bg)
    
    local label_level = XTHDLabel:create(_itemdInfoData._strengLevel or 0, 20)
    label_level:setColor(cc.c3b(255,255,255))
    label_level:enableShadow(cc.c4b(255, 255, 255, 255), cc.size(0.4, -0.4),0.4)
    label_level:setCascadeColorEnabled(true)
    label_level:setPosition(level_bg:getContentSize().width / 2 , level_bg:getContentSize().height / 2)
    level_bg:addChild(label_level)
    if _itemdInfoData._phaseLevel~=nil and tonumber(_itemdInfoData._phaseLevel)>0 then
    	local _starPos = SortPos:sortFromMiddle(cc.p(_itemSp:getContentSize().width/2,0) ,_itemdInfoData._phaseLevel,13)
        for i=1,_itemdInfoData._phaseLevel do
            local _starSpr= cc.Sprite:create("res/image/common/star_light.png")
            _starSpr:setScale(0.6)
            _starSpr:setAnchorPoint(cc.p(0.5,0))
            _starSpr:setPosition(cc.p(_starPos[i].x,_starPos[i].y))
            _itemSp:addChild(_starSpr)
        end
    end
    if _itemdInfoData._rank~=nil and tonumber(_itemdInfoData._rank)>3 then
    	XTHD.addEffectToEquipment(_itemSp,_itemdInfoData._rank)
    end

	return _itemSp
end

function ChaKanOtherPlayerInfoLayer:refreshHeroInfoLayer(_idx)
	
	local _heroData = self.heroListData[tonumber(_idx)]
	if _heroData ==nil or next(_heroData)==nil then
		return
	end
	self.data = _heroData
	self:refreshHeroEquipments()
	self:refreshHeroName()
	self:refreshHeroPower()
	self:refreshHeroLevel()
	self:refreshHeroType()
	self:reFreshHeroStars()
	self:refreshHeroSpine()
	self:refreshHeroFunction()
	self:setTabCallback(self.tabState,false)
	
end

function ChaKanOtherPlayerInfoLayer:refreshHeroName()
	XTHD.refreshHeroNameShowSprite(self.heroNameSp,self.data["name"],self.data["phaseLevel"],self.data.id)
end

function ChaKanOtherPlayerInfoLayer:refreshHeroPower()
	XTHD.refreshPowerShowSprite(self.heroPowerSp,self.data["power"])
end

function ChaKanOtherPlayerInfoLayer:refreshHeroLevel()
	if self.levelLabel ==nil then
		return
	end
	self.levelLabel:setString(self.data.level or 1)
end

function ChaKanOtherPlayerInfoLayer:refreshHeroType()
	if self.typeLabel==nil then
		return
	end
	self.typeLabel:setString(LANGUAGE_TIPS_WORDS105[tonumber(self.data.type or 1)])
end

--刷新星数
function ChaKanOtherPlayerInfoLayer:reFreshHeroStars()
	local _star = self.data.starLevel or 1
	for i = 1,#self.starBg_arr do
		if self.starBg_arr[i] then
			self.starBg_arr[i]:setVisible(false)
		end
	end
	self:createStarAndMoon()
--	for i=1,5 do
--		local _starBg = self.starBg_arr[i]
--		local _starSpr = _starBg:getChildByName("starSpr") or nil
--		if tonumber(_star)>= i then
--			if _starSpr==nil then
--				_starSpr = cc.Sprite:create("res/image/common/star_light.png")
--				_starSpr:setName("starSpr")
--				_starSpr:setPosition(cc.p(_starBg:getContentSize().width/2,_starBg:getContentSize().height/2))
--				_starBg:addChild(_starSpr)
--			end
--		else
--			if _starSpr~=nil then
--				_starSpr:removeFromParent()
--			end
--		end
--	end
end

function ChaKanOtherPlayerInfoLayer:refreshHeroFunction()
	local _btnName = {"Shuxing","Jineng","Neigong","Shenqi"}
	for i=3,4 do
		local _isOpen = self:heroFunctionIsOpen(i)
		local _normalNode = nil
		local _selectedNode = nil
		if _isOpen ~=nil and _isOpen ==true then
			_normalNode = cc.Sprite:create("res/image/plugin/hero/hero" .. _btnName[i] .. "_normal.png")
			_selectedNode = cc.Sprite:create("res/image/plugin/hero/hero" .. _btnName[i] .. "_selected.png")
		else
			_normalNode = cc.Sprite:create("res/image/plugin/hero/hero" .. _btnName[i] .. "_disable.png")
			_selectedNode = cc.Sprite:create("res/image/plugin/hero/hero" .. _btnName[i] .. "_disable.png")
		end
		if self.tabBtnArr[i]~=nil then
			local _btn = self.tabBtnArr[i]
			_btn:setStateNormal(_normalNode)
			_btn:setStateSelected(_selectedNode)
			_btn:setEnable(_isOpen)
			_btn:setClickable(true)
		end
	end
end
function ChaKanOtherPlayerInfoLayer:heroFunctionIsOpen(_idx)
	local _bool = false
	if _idx == nil then
		return _bool
	end
	if _idx ==3 then
		if self.data.starLevel and tonumber(self.data.starLevel)>=5 then
			_bool = true
		end
	elseif _idx ==4 then
		if self.data.godBeast and next(self.data.godBeast)~=nil then
			_bool = true
		end
	end
	return _bool
end

function ChaKanOtherPlayerInfoLayer:refreshHeroEquipments()
	local _equipsData = self.data.items or {}
	for i=1,6 do
		if self.heroEquipmentsTable[i] ~= nil then
			self.heroEquipmentsTable[i]:removeAllChildren()
		end
	end
	for i=1,#_equipsData do
		local _positionIdx = tonumber(_equipsData[i].position or 0)
		if self.heroEquipmentsTable[_positionIdx] ~= nil then
			local _equipBg = self.heroEquipmentsTable[_positionIdx]
			local _itemid = tonumber(_equipsData[i].itemId or 0)
			local _itemData = self.staticItemInfoData[tostring(_itemid)] or {}
			-- dump(_equipsData[i])
			local _equipItemSp = self:createEquipedItemBtn({
	 				_rank = _itemData.rank,
	 				_resourceid = _itemData.resourceid,
	 				_strengLevel = _equipsData[i].strengLevel,
	 				_phaseLevel =_equipsData[i].phaseLevel
	 			})
			-- (_itemData.rank,_itemData.resourceid,_equipsData[i].strengLevel,_equipsData[i].phaseLevel)
			_equipItemSp:setScale(1.1)
			_equipItemSp:setPosition(cc.p(_equipBg:getContentSize().width/2,_equipBg:getContentSize().height/2))
			_equipBg:addChild(_equipItemSp)
		end
	end
end

function ChaKanOtherPlayerInfoLayer:refreshCurrentTabLayer()
	if self.current_tab_layer ==nil then
		return
	end
	self.current_tab_layer:reFreshHeroFunctionInfo(self.data)
end

function ChaKanOtherPlayerInfoLayer:refreshHeroSpine()
	if self.heroBg ==nil then
		return
	end
	local _heroId = self.data.id or 1
	if self.heroSpine~=nil then
		self.heroSpine:removeFromParent()
		self.heroSpine = nil
	end
	self.heroSpine = self:createHeroSpine(_heroId)
	self.heroSpine:setPosition(cc.p(self.heroBg:getContentSize().width/2,15))
	self.heroBg:addChild(self.heroSpine)
end

function ChaKanOtherPlayerInfoLayer:setHeroListData(data)
	self.heroListData = {}
	self.heroListData = data and data.pets or {}
	--先按战斗力后按id排序
	table.sort(self.heroListData,function(data1,data2)
			if tonumber(data1.power) == tonumber(data2.power) then
				return tonumber(data1.id) < tonumber(data2.id)
			else
				return tonumber(data1.power)>tonumber(data2.power)
			end
		end)
	local data = gameData.getDataFromCSVWithPrimaryKey("GeneralInfoList")
	local _staticHeroListData = {}
	for k,v in pairs(data) do
		_staticHeroListData[v.heroid] = v
	end

	for i=1,#self.heroListData do
		local _heroid = self.heroListData[i].id
		local _herostaticData = _staticHeroListData[_heroid] or {}
		self.heroListData[i].description = _herostaticData.description or ""
		self.heroListData[i].autograph = _herostaticData.autograph or ""
		self.heroListData[i].type = _herostaticData.type or 1
		self.heroListData[i].name = _herostaticData.name or 1
		self.heroListData[i] = XTHD.getPropertyValueByTurn(self.heroListData[i])
	end
	self.data = self.heroListData[1] or {}
end

function ChaKanOtherPlayerInfoLayer:setStaticItemInfoData()
	self.staticItemInfoData = {}
	self.staticItemInfoData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet")
end

function ChaKanOtherPlayerInfoLayer:getTextColor(_str)
	-- local _nameColor = XTHD.resource.getQualityItemColor(self.itemInfoData["rank"])
	local _textColor = {
		hongse = cc.c4b(204,2,2,255), 							--红色
		shenhese = cc.c4b(70,34,34,255),
		baise = cc.c4b(255,255,255,255),						--深褐色，用的比较多
	}
	return _textColor[_str]
end

function ChaKanOtherPlayerInfoLayer:create(data)
	local _layer = self.new(data)
	return _layer
end

return ChaKanOtherPlayerInfoLayer