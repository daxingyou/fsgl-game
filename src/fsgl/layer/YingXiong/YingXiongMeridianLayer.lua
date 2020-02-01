local YingXiongMeridianLayer = class("YingXiongMeridianLayer",function()
	return XTHD.createBasePageLayer({bg = "res/image/plugin/meridian/meridian_bg.png",isShadow = true})
end)
--经脉

function YingXiongMeridianLayer:ctor(_heroid)
	self.meridianStaticData = {}
	self.rankStaticData = {}			--BingshuAdvanced处理后的数据
	self.heroListData = {}				--英雄列表数据

	self.meridianData = {}
	self.meridianItems = {}
	self.meridianEnergy = nil 			--当前经验值
	self.propertyValueData = {} 		--当前英雄所有经脉一共提升的总属性值。

	self.heroid = 1
	self.propertyKey = {"addhp","addat","addmat","adddf","addmdf","addbj","addsb","addmz","addbjbl","addbsjm","addnq","addct","addjm"}
	self.propertyName = {200,201,203,202,204,302,301,300,303,304,314,306,305}

	self:setStaticData()
	self:setHeroListData()
	self:setHeroSelected(_heroid)
	self:initLayer()

end

function YingXiongMeridianLayer:onCleanup()
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
end

function YingXiongMeridianLayer:initLayer()
	local _itemPosTable = {}
	local _topBarHeight = self.topBarHeight or 40

	--经脉背景X在竖线右边居中,Y在英雄头像背景和背景上方77像素之间居中
	local _meridianSp = cc.Sprite:create("res/image/plugin/meridian/meridianSp.png")
	_meridianSp:setPosition(cc.p( (self:getContentSize().width+260)/2,(self:getContentSize().height - 77+127)/2))
	_meridianSp:setScale(0.7)
	self:addChild(_meridianSp)
	self.meridianSp = _meridianSp

	self:setLeftLayer()
	self:setMeridianLayer()
	self:refreshLayerWhenExchangeHero()
	self:setHeroListLayer()

	XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK,node=self,callback = function( event)
		self:setMeridianData()
		self:setPropertyValue()
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_HERODATABYID,data = {heroid = self.heroid}})
		self:refreshPropertyValue()
		self:refreshMeridianItems()
		self:refreshMeridianEnergy()
	end})
end
--------------------------meridianlayer--------------------------
function YingXiongMeridianLayer:setMeridianLayer()
	if self.meridianSp==nil then
		return
	end
	local _itemPosTable = self:getPosTable()
	local _rotationTable = self:getRotationTable()
	self.meridianItems = {}
	self.lineItems = {}
	for i=1,8 do
		local _item = self:createMeridianItem(i)
		self.meridianItems[i] = _item
		_item:setPosition(cc.p(_itemPosTable[i]))
		self.meridianSp:addChild(_item,1)

		if i>1 then
			local _lineSp = cc.Sprite:create("res/image/plugin/meridian/meridian_linkline" .. i-1 .. ".png")
			-- _lineSp:setRotation(_rotationTable[i-1])
			_lineSp:setPosition(cc.p((_itemPosTable[i].x+_itemPosTable[i-1].x)/2,(_itemPosTable[i].y+_itemPosTable[i-1].y)/2))
			self.meridianSp:addChild(_lineSp,0)
			self.lineItems[i-1] = _lineSp
		end
		--刷新当前item和line
		-- self:refreshMeridianItemState(i)
		-- self:playWakeUpAnimation(i)
	end
end

function YingXiongMeridianLayer:createMeridianItem(_idx)
	if _idx ==nil then
		return
	end
	local _meridianStaticData = self.meridianStaticData[_idx] or {}
	local _itemSp = XTHD.createButton({
			normalNode = cc.Sprite:create("res/image/plugin/meridian/meridian_normal.png"),
			selectedNode = cc.Sprite:create("res/image/plugin/meridian/meridian_selected.png"),
			touchSize = cc.size(73,73),
		})
	_itemSp:setTouchEndedCallback(function()
			self:meridianCallback(_idx)
		end)
	local _meridianName = cc.Sprite:create("res/image/plugin/meridian/meridian_" .. _idx .. ".png")
	_meridianName:setName("meridianName")
	_meridianName:setPosition(cc.p(_itemSp:getContentSize().width/2,0))
	_itemSp:addChild(_meridianName)
	local _textColor = XTHD.resource.textColor.blue_text_1
	local _fontSize = 18
	local _textLabel = XTHDLabel:create("0",_fontSize)
	_textLabel:setName("textLabel")
	_textLabel:setColor(_textColor)
	_textLabel:setAnchorPoint(cc.p(0.5,1))
	_textLabel:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
	_textLabel:setPosition(cc.p(_itemSp:getContentSize().width/2,-15))
	_itemSp:addChild(_textLabel)
	return _itemSp
end
function YingXiongMeridianLayer:meridianCallback(_idx)
	if self.meridianData[tonumber(_idx)]~=nil and next(self.meridianData[tonumber(_idx)])~=nil then
		--跳到经脉
		local _heroid = self.heroid
		local _meridianLayer = requires("src/fsgl/layer/YingXiong/YingXiongMeridianLevelUpLayer.lua")
		 		-- self:addChild()
 		LayerManager.addLayout(_meridianLayer:create(_idx,_heroid),{noHide = true})
	else
		
		self:activeMeridianItem(_idx)
	end
end

function YingXiongMeridianLayer:activeMeridianItem(_idx)
	local _meridianData = self.meridianStaticData[_idx] or {}
	local _needCost = _meridianData.activity
	if _needCost == nil then
		return
	end
	if _idx~=1 and (self.meridianData[tonumber(_idx-1)]==nil or next(self.meridianData[tonumber(_idx-1)])==nil or tonumber(self.meridianData[tonumber(_idx-1)].level)<tonumber(_meridianData.maxlevel)) then
		XTHDTOAST(LANGUAGE_MERIDIAN_ACTIVITYLIMIT(_idx-1))
		return
	end
	--真气充足
	if tonumber(string.split(_needCost,'#')[2])<=tonumber(XTHD.resource.getItemNum(tonumber(string.split(_needCost,'#')[1]))) then
		self:enoughEnergyCallback(_idx,_needCost)
	else
		self:noEnoughEnergyCallback(_idx)
	end
end

function YingXiongMeridianLayer:enoughEnergyCallback(_idx,_needCost)
	local _meridianName = LANGUAGE_KEY_HEROMERIDIANVEIN[_idx]
	-- local _msgStr = LANGUAGE_MERIDIAN_ACTIVITYCOST(_meridianName,_needCost)
	local strArr = string.split(_needCost,'#')
    local name = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = tonumber(strArr[1])}).name
	local _msgStr = "激活" .. _meridianName .. "需要消耗" ..name.."x".. strArr[2].."，是否立即激活？"
	local confirmDialog = XTHDConfirmDialog:createWithParams({
		msg = _msgStr,
		rightCallback =function()
			self:httpToActiveMeridianItem(_idx)
		end
		})
	self:addChild(confirmDialog)
end

function YingXiongMeridianLayer:noEnoughEnergyCallback(_idx)
	local _meridianData = self.meridianStaticData[_idx] or {}
	local _needCost = _meridianData.activity
	local _subCost = tonumber(string.split(_needCost,'#')[2]) - tonumber(XTHD.resource.getItemNum(tonumber(string.split(_needCost,'#')[1])))
--	local _needIngot = XTHD.resource.getIngotNumToReplaceZhenqi(_subCost)
	local name = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = tonumber(string.split(_needCost,'#')[1])}).name
	local _msgStr = "道具不足，缺少" .. name.."x".._subCost
	local confirmDialog = XTHDConfirmDialog:createWithParams({
		msg = _msgStr,
		rightCallback =function()
			--跳转到铁匠铺界面
			local StoredValue = requires("src/fsgl/layer/TieJiangPu/TieJiangPuLayer.lua"):create()
            LayerManager.addLayout(StoredValue, {par = self})
--			self:httpToActiveMeridianItem(_idx)
		end
		})
	self:addChild(confirmDialog)
end

function YingXiongMeridianLayer:httpToActiveMeridianItem(_idx)
	local _heroid = self.heroid
	ClientHttp:httpCommon( "activateVeins?", self,{petId = _heroid,veinsType = _idx}, function(data)
			self:refreshHttpData(data,_idx,_heroid)
		end)
end

function YingXiongMeridianLayer:playWakeUpAnimation(_idx)
	if _idx == nil or self.meridianItems[_idx]==nil then
		return
	end
	local _itemSp = self.meridianItems[_idx]
	local _itemPosTable = self:getPosTable()
	local _rotationTable = self:getRotationTable()
	
	if _itemSp:getChildByName("spine1") then
		_itemSp:removeChildByName("spine1")
	end
	local actionTable = {}
	-- actionTable[#actionTable+1] = cc.DelayTime:create(_idx*2)
	if _idx ~= 1 then
		actionTable[#actionTable+1] = cc.Spawn:create(cc.CallFunc:create(function()
				if self.meridianSp==nil then
					return
				end
				local _lineSpine = self:getLineSpine()
				_lineSpine:setName("lineSpine")
				 _lineSpine:setRotation(_rotationTable[_idx-1] or 0)
				 _lineSpine:setPosition(_itemPosTable[_idx-1])
				 self.meridianSp:addChild(_lineSpine)
				 _lineSpine:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,_itemPosTable[_idx]),cc.RemoveSelf:create()))
				--试一下
--				_lineSpine:setPosition(0,0)
--				self.lineItems[_idx]:addChild(_lineSpine)
--				_lineSpine:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,cc.p(self.lineItems[i]:getContentSize().width))))
				
			end),cc.DelayTime:create(0.3))
	end
	actionTable[#actionTable+1] = cc.CallFunc:create(function()

			local _spine1 = self:getSelectedSpine()
			_spine1:setName("spine1")
			_spine1:setPosition(cc.p(_itemSp:getContentSize().width/2-5,_itemSp:getContentSize().height/2+4.3))
			_itemSp:addChild(_spine1)
			_spine1:runAction(cc.Sequence:create(cc.DelayTime:create(0.90),cc.RemoveSelf:create()))
			if _itemSp:getChildByName("activityState") then
				_itemSp:removeChildByName("activityState")
			end
		end)
	self:runAction(cc.Sequence:create(actionTable))
	-- self:runAction(cc.RepeatForever:create(cc.Sequence:create(actionTable)))
end
--------------------------meridianlayer-end--------------------------

--------------------------left--------------------------
function YingXiongMeridianLayer:setLeftLayer()
	local _shadowposY = 115
	local _topBarHeight = self.topBarHeight or 40

	local _shadowContent = cc.size(316,self:getContentSize().height - _topBarHeight-_shadowposY)
	local _leftShadow = ccui.Scale9Sprite:create(cc.rect(0,0,316,10),"res/image/plugin/meridian/leftshadow_meridian.png")
	_leftShadow:setContentSize(_shadowContent)
	_leftShadow:setAnchorPoint(cc.p(0,0))
	_leftShadow:setPosition(cc.p(0,_shadowposY))
	self:addChild(_leftShadow)

	-- local _verLineSp = cc.Sprite:create("res/image/plugin/meridian/meridian_verline.png")
	-- _verLineSp:setPosition(cc.p(245,_shadowposY + _shadowContent.height/2))
	-- self:addChild(_verLineSp)

	--kuang 
	local kuang = ccui.Scale9Sprite:create("res/image/camp/kuang2.png")
	kuang:setContentSize(220,50)
	kuang:setPosition(cc.p(32, _leftShadow:getContentSize().height - 52))
	kuang:setAnchorPoint(0,0.5)
	_leftShadow:addChild(kuang)

	local _hasZhenqiLabel = XTHDLabel:create(LANGUAGE_HEROMERIDIAN.zhenqiValue,22,"res/fonts/def.ttf")
	_hasZhenqiLabel:setColor(cc.c3b(54,55,112))
	_hasZhenqiLabel:enableShadow(cc.c3b(54,55,112),cc.size(0.4,-0.4),0.4)
	_hasZhenqiLabel:setAnchorPoint(cc.p(0,0.5))
	local _zhenqiPosY = _leftShadow:getContentSize().height - 52
	_hasZhenqiLabel:setPosition(cc.p(36,_zhenqiPosY))
	_leftShadow:addChild(_hasZhenqiLabel)
	local _addBtn = XTHD.createButton({
			normalFile = "res/image/common/btn/btn_plus_normal.png",
			selectedFile = "res/image/common/btn/btn_plus_selected.png",
		})
	_addBtn:setPosition(cc.p(_hasZhenqiLabel:getBoundingBox().x + 195,_zhenqiPosY))
	_leftShadow:addChild(_addBtn)
	_addBtn:setTouchEndedCallback(function()
			self:addZhenqiBtnCallback()
		end)

	local _energyPosX = (_addBtn:getBoundingBox().x+_hasZhenqiLabel:getBoundingBox().x+_hasZhenqiLabel:getBoundingBox().width)/2
	-- local _energyValue = getHugeNumberWithLongNumber(gameUser.getZhenqi(),1000000)
	--背景 
	local l_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png")
	l_bg:setContentSize(100,30)
	l_bg:setPosition(cc.p(_energyPosX,_zhenqiPosY))
	_leftShadow:addChild(l_bg)

	local _energyLabel = XTHDLabel:create(0,20)
	self.meridianEnergy = _energyLabel
	_energyLabel:setColor(cc.c3b(255,255,255))
	_energyLabel:enableShadow(cc.c3b(255,255,255),cc.size(0.4,-0.4),0.4)
	_energyLabel:setPosition(cc.p(_energyPosX,_zhenqiPosY))
	_leftShadow:addChild(_energyLabel)
	self:refreshMeridianEnergy()

	--属性框
	local sxk = ccui.Scale9Sprite:create("res/image/plugin/meridian/sxk.png")
	sxk:setScaleX(0.45)
	sxk:setPosition(cc.p(32,_leftShadow:getContentSize().height-93))
	sxk:setAnchorPoint(0,1)
	_leftShadow:addChild(sxk)
	local _titleBg = cc.Sprite:create("res/image/plugin/meridian/sxjc.png")
	_titleBg:setPosition(cc.p(140,_leftShadow:getContentSize().height-93))
	_leftShadow:addChild(_titleBg)
	-- local _titleLabel = XTHDLabel:create(LANGUAGE_HEROMERIDIAN.propertyAdd,24)
	-- _titleLabel:setColor(XTHD.resource.textColor.blue_text_1)
	-- _titleLabel:setPosition(cc.p(_titleBg:getContentSize().width/2,_titleBg:getContentSize().height/2))
	-- _titleBg:addChild(_titleLabel)

	local _propertyContentSize = cc.size(245,_titleBg:getBoundingBox().y)
	local _innerContentSize = cc.size(245,28*(#self.propertyName))
	if tonumber(_propertyContentSize.height)>= tonumber(_innerContentSize.height) then
		_innerContentSize.height = _propertyContentSize.height
	end

	local property_bg = ccui.ScrollView:create()
	self.property_bg = property_bg
	property_bg:setScrollBarEnabled(false)
    property_bg:setBounceEnabled(false)
    property_bg:setDirection(ccui.ScrollViewDir.vertical)
    property_bg:setTouchEnabled(true)
    property_bg:setContentSize(_propertyContentSize)
    property_bg:setInnerContainerSize(_innerContentSize)
    property_bg:setPosition(cc.p(30,0))
    _leftShadow:addChild(property_bg)
    
    self:refreshPropertyValue()
end
function YingXiongMeridianLayer:setPropertyValue()
	self.propertyValueData = {}
	for k,v in pairs(self.meridianData) do
		local _curMeridianData = v
		local _curLevel = tonumber(v.level)
		local _curVeinType = tonumber(v.veinsType)
		local _curPhase = tonumber(v.phase)--tonumber(XTHD.getMeridianCurPhase(_curLevel))-1
		local _levelStaticData = self.meridianStaticData[_curVeinType] or {}
		local _rankStaticData = self.rankStaticData[_curVeinType] or {}
		
		for i=1,#self.propertyKey do
			local _key =self.propertyKey[i]
--			print(_key.."-------------------".._levelStaticData[_key].."          ".._curLevel)
			local _allValue = self.propertyValueData[_key] or 0
			self.propertyValueData[_key] = _allValue + tonumber(_levelStaticData[_key] or 0)*_curLevel
			for j=1,_curPhase do
				self.propertyValueData[_key] = self.propertyValueData[_key] + tonumber(_rankStaticData[tonumber(j)][_key] or 0)
			end
		end
	end
end
--刷新属性值
function YingXiongMeridianLayer:refreshPropertyValue()
	if self.property_bg==nil then
		return
	end
	self.property_bg:removeAllChildren()
	local _innerContentSize = self.property_bg:getInnerContainerSize()
	local _noZeroCount = 0
    for i=1,#self.propertyName do
    	local _propertyValue = tonumber(self.propertyValueData[self.propertyKey[i]] or 0)
    	if _propertyValue>0 or i<6 then
    		local _keyNum = self.propertyName[i]
			local _nameStr = LANGUAGE_KEY_ATTRIBUTESNAME(_keyNum)
			local _valueStr = ": +" .. _propertyValue.."%"--XTHD.resource.addPercent(_keyNum,_propertyValue)

    		local _posY = _innerContentSize.height - 30*_noZeroCount-15
			local _propertyValueLabel = XTHDLabel:create(_nameStr .. _valueStr,20,"res/fonts/def.ttf")
			--绿色
			_propertyValueLabel:setColor(cc.c3b(17,247,72))
	    	_propertyValueLabel:setAnchorPoint(cc.p(0,0.5))
	    	_propertyValueLabel:setPosition(cc.p(30,_posY))
	    	self.property_bg:addChild(_propertyValueLabel)
	    	_noZeroCount = _noZeroCount +1
    	end    		
    end
    local _contentHeight = self.property_bg:getContentSize().width
    local _innerHeight = _noZeroCount*30
    if _innerHeight>_contentHeight then
    	self.property_bg:setTouchEnabled(true)
    else
    	self.property_bg:setTouchEnabled(false)
    end
end
--------------------------left-end--------------------------
--------------------------herolist--------------------------
function YingXiongMeridianLayer:setHeroListLayer()
	local _herolistBg = cc.Sprite:create("res/image/plugin/meridian/herolist_bg.png")
	_herolistBg:setAnchorPoint(cc.p(0.5,0))
	_herolistBg:setPosition(cc.p(self:getContentSize().width/2,0))
	self:addChild(_herolistBg)
	local _tableViewCellSize = cc.size(102,100)
	local _tableViewSize = cc.size(8*_tableViewCellSize.width,_tableViewCellSize.height)

	local _tableView = cc.TableView:create(_tableViewSize)
	TableViewPlug.init(_tableView)
	_tableView:setPosition(cc.p((self:getContentSize().width -_tableViewSize.width)/2,0))
    -- _tableView:setBounceable(true)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) --设置横向纵向
    _tableView:setDelegate()
    self:addChild(_tableView)

    local _heroListNumber = 8
    if #self.heroListData >8 then
		_heroListNumber = #self.heroListData
	end

	_tableView.getCellNumbers = function (table_view)
       return _heroListNumber
    end

	_tableView:registerScriptHandler(_tableView.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	_tableView.getCellSize = function (table_view,idx)
       return _tableViewCellSize.width, _tableViewCellSize.height
    end
	_tableView:registerScriptHandler(_tableView.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)

    _tableView:registerScriptHandler(
    	function (table_view,idx)
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
	    		local _noneHeroSp = cc.Sprite:create("res/image/plugin/meridian/nohero_sp.png")
	    		_noneHeroSp:setPosition(cc.p(_tableViewCellSize.width/2,_tableViewCellSize.height/2))
	    		cell:addChild(_noneHeroSp)
	    		return cell
	    	end

	    	local _heroSp = YingXiongItem:createWithParams({
		        	heroid = _heroData.heroid,
		        	star = _heroData.star,
		        	level = _heroData.level,
		        	advance = _heroData.advance
		    	})
	    	_heroSp:setScale(80/_heroSp:getContentSize().width)
	    	_heroSp:setPosition(cc.p(_tableViewCellSize.width/2,_tableViewCellSize.height/2))
	    	cell:addChild(_heroSp)

	    	local _normalSprite = cc.Sprite:createWithTexture(nil,cc.rect(0,0,102,102))
	    	_normalSprite:setOpacity(0)
	    	local _heroBtn = XTHD.createButton({
	    			normalNode = _normalSprite,
	    			selectedNode = cc.Sprite:create("res/image/illustration/selected.png"),
	    			needEnableWhenMoving = true,
	    			touchSize = cc.size(102,102),
				})
				_heroBtn:setScaleX(0.84)
				_heroBtn:setScaleY(0.85)
	    	local _heroid = _heroData.heroid
	    	_heroBtn:setTouchEndedCallback(function()
		    			_heroBtn.isSelected = true
		    			_heroBtn:setSelected(true)
		    			if self.selectedHeroSp ~= nil then
		    				self.selectedHeroSp.isSelected = false
		    				self.selectedHeroSp:setSelected(false)
		    				self.selectedHeroSp = nil
		    			end
		    			self.selectedHeroSp = _heroBtn
		    			
		    			self:selectHeroCallback(_heroid)
	    		end)
	    	_heroBtn:setSwallowTouches(false)
	    	_heroBtn:setName("heroBtn")
	    	_heroBtn:setPosition(cc.p(_tableViewCellSize.width/2 ,_tableViewCellSize.height/2 - 1.5))
	    	cell:addChild(_heroBtn)

	    	if self.heroid == _heroid then
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
    ,cc.TABLECELL_SIZE_AT_INDEX)
	_tableView:reloadData()
	local _curCellIdx = self:getCurHeroCell()
	_tableView:scrollToCell(_curCellIdx,false)


	--左边箭头
    local _arrowDistance = (self:getContentSize().width - _tableViewSize.width)/4
    local _leftScrollBtn = XTHD.createButton({
            normalFile = "res/image/plugin/stageChapter/btn_left_arrow.png",
            selectedFile = "res/image/plugin/stageChapter/btn_left_arrow.png",
            touchScale = 0.95
        })
    _leftScrollBtn:setPosition(cc.p(_arrowDistance+3,55))
    self:addChild(_leftScrollBtn)
    _leftScrollBtn:setTouchEndedCallback(function()
            local _page = _tableView:getCurrentPage()
            if _page <1 then
                return
            end
            _tableView:scrollToCell(_page-1)
        end)
    --右边箭头
    local _rightScrollBtn = XTHD.createButton({
            normalFile = "res/image/plugin/stageChapter/btn_right_arrow.png",
            selectedFile = "res/image/plugin/stageChapter/btn_right_arrow.png",
            touchScale = 0.95
            -- ,musicFile = XTHD.resource.music.effect_btn_common
        })
    _rightScrollBtn:setPosition(cc.p(self:getContentSize().width - _arrowDistance,55))
    self:addChild(_rightScrollBtn)

    _rightScrollBtn:setTouchEndedCallback(function()
            local _page = _tableView:getCurrentPage()
            if _page >(_heroListNumber-8-1) then
                return
            end
            _tableView:scrollToCell(_page+1)
        end)
end

function YingXiongMeridianLayer:getCurHeroCell()
	local _cellIdx = 0
	for i=1,#self.heroListData do
		if tonumber(self.heroListData[i].heroid)== self.heroid then
			_cellIdx = i-1
			break
		end
	end
	return _cellIdx
end

--------------------------herolist-end--------------------------

function YingXiongMeridianLayer:addZhenqiBtnCallback()
	replaceLayer({fNode = self,id = 59})
end

function YingXiongMeridianLayer:refreshHttpData(_data,_idx,_heroid)
	local _heroData = DBTableHero.getData(gameUser.getUserId(), {["heroid"] = _heroid})
	local _oldPower = _heroData.power or 0
	local _newPower = _oldPower
	if _data.veinsJson~=nil and next(_data.veinsJson)~=nil then
		DBTableHero.updateHeroPetVeinsData(_data.veinsJson,_heroid)
	end
	local property = _data.charProperty
    if property then
        for i=1,#property do
            local _tab = string.split(property[i],',')
            gameUser.updateDataById(_tab[1],_tab[2])
            
        end
    end
	if _data.bagItems and #_data.bagItems ~= 0 then
        for i=1,#_data.bagItems do
            local item_data = _data.bagItems[i]
            local showCount = item_data.count
            if item_data.count and tonumber(item_data.count) ~= 0 then
                DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
            else
                DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
            end
        end
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    for i=1,#_data.petProperty do
        local _tab = string.split(_data.petProperty[i],',')
        DBTableHero.updateDataByPropId( gameUser.getUserId(), _tab[1],_tab[2],_heroid);
        if tonumber(_tab[1]) ==407 then
        	_newPower = tonumber(_tab[2])
        end
    end
    self:setMeridianData()
    self:setPropertyValue()
    self:refreshPropertyValue()
    XTHD._createFightLabelToast({
        oldFightValue = _oldPower,
        newFightValue = _newPower
    })

	self:playWakeUpAnimation(_idx)
    performWithDelay(self,function()
	    	self:refreshMeridianItemState(_idx)
			self:refreshMeridianItemState(_idx+1)
    	end,0.3)
	

	self:refreshMeridianEnergy()

	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_HERODATABYID,data = {heroid = _heroid}})
	
end

function YingXiongMeridianLayer:refreshMeridianItemState(_idx)
	if _idx == nil or self.meridianItems[_idx]==nil then
		return
	end
	if self.meridianItems[_idx]:getChildByName("textLabel")==nil or self.meridianItems[_idx]:getChildByName("meridianName")==nil then
		return
	end
	local _meridianStaticData = self.meridianStaticData[_idx] or {}
	local _itemSp = self.meridianItems[_idx]
	local _textLabel = _itemSp:getChildByName("textLabel")
	local _meridianName = _itemSp:getChildByName("meridianName")
	local _textColor = cc.c4b(255,255,255,255)
	local _textStr = nil
	-- local _playerLevel = tonumber(gameUser.getLevel())
	local _fontSize = 18
	local _grayFlag = true
	if _itemSp:getChildByName("activityState") then
		_itemSp:removeChildByName("activityState")
	end
	if self.meridianData[tonumber(_idx)]~=nil and next(self.meridianData[tonumber(_idx)])~=nil then
		_textColor = XTHD.resource.textColor.blue_text_1
		_textStr = self:getMeridianName(_idx)
		-- _itemSp:setClickable(true)
		_grayFlag = false
	else
		_grayFlag = true
		
		if (self.meridianData[tonumber(_idx)-1]~=nil and next(self.meridianData[tonumber(_idx)-1])~=nil and tonumber(self.meridianData[tonumber(_idx)-1].level)>=tonumber(_meridianStaticData.maxlevel)) or _idx == 1 then
			_textColor = XTHD.resource.textColor.blue_text_1
			_textStr = LANGUAGE_KEY_CANACTIVITY
			_fontSize = 20
			-- _itemSp:setClickable(true)
			local _spine = self:getActivitySpine()
			_spine:setScale(0.9)
			_spine:setName("activityState")
			_spine:setPosition(cc.p(_itemSp:getContentSize().width/2-3,_itemSp:getContentSize().height/2+7))
			_itemSp:addChild(_spine)
		else
			_textStr = LANGUAGE_KEY_UNLOCK
			-- _itemSp:setClickable(false)
		end
	end
	XTHD.setGray(_itemSp:getStateNormal(),_grayFlag)
	XTHD.setGray(_itemSp:getStateSelected() ,_grayFlag)
	XTHD.setGray(_meridianName,_grayFlag)
	_textLabel:setString(_textStr)
	_textLabel:setColor(_textColor)
	_textLabel:setFontSize(_fontSize)
	_textLabel:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)

	if self.lineItems[_idx-1]~=nil then
		XTHD.setGray(self.lineItems[_idx-1],_grayFlag)
	end
end

function YingXiongMeridianLayer:refreshMeridianItems()
	
	for i=1,8 do
		self:refreshMeridianItemState(i)
	end
end

function YingXiongMeridianLayer:refreshMeridianEnergy()
	if self.meridianEnergy == nil then
		return
	end
	local _zhengqiValue = gameUser.getZhenqi()
	self.meridianEnergy:setString(getHugeNumberWithLongNumber(_zhengqiValue,1000000))
end

-----------------------Spine---------------------------
--可激活的特效
function YingXiongMeridianLayer:getActivitySpine(flag)
	local _flag = flag==false and false or true
	-- local _spine = XTHD.createMeridianSpine()
	-- _spine:setAnimation(0,"xz",_flag)
	--新特效 
	local _spine = sp.SkeletonAnimation:create( "res/spine/effect/meridian_wakeupEffect/xinfa01.json", "res/spine/effect/meridian_wakeupEffect/xinfa01.atlas",1.0)
	_spine:setAnimation(0,"xinfa01",_flag)
	return _spine
end
--点击激活，经脉的特效
function YingXiongMeridianLayer:getSelectedSpine()
	-- local _spine = XTHD.createMeridianSpine()
	-- _spine:setAnimation(0,"zk",false)
	--新特效 
	local _spine = sp.SkeletonAnimation:create( "res/spine/effect/meridian_wakeupEffect/xinfa02.json", "res/spine/effect/meridian_wakeupEffect/xinfa02.atlas",1.0)
	_spine:setAnimation(0,"xinfa02",false)
	return _spine
end
--点击激活，线的特效
function YingXiongMeridianLayer:getLineSpine()
	local _spine = XTHD.createMeridianSpine()
	_spine:setAnimation(0,"lzb",false)
	return _spine
end

-----------------------Spine-end--------------------------

function YingXiongMeridianLayer:selectHeroCallback(_heroid)
	self:setHeroSelected(_heroid)
	self:refreshLayerWhenExchangeHero()
end

function YingXiongMeridianLayer:setHeroSelected(_heroid)
	self.heroid = _heroid
	self:setMeridianData()
	self:setPropertyValue()
end

function YingXiongMeridianLayer:refreshLayerWhenExchangeHero()
	self:refreshMeridianItems()
	self:refreshPropertyValue()
end

function YingXiongMeridianLayer:getMeridianName(_idx)
	local _veinData = self.meridianData[tonumber(_idx)] or {}

	local _advanceValue = math.floor(tonumber(_veinData.level-1)/5)+1
	local _advanceNameStr = LANGUAGE_KEY_HEROMERIDIANRANK[_advanceValue] or ""
	local _levelValue = tonumber(_veinData.level-1)%5+1
	local _levelStr = LANGUAGE_KEY_HEROMERIDIANLEVEL[_levelValue]
	local _returnName = _advanceNameStr .. "." .. _levelStr
	return _returnName
end

function YingXiongMeridianLayer:setMeridianData()
	self.meridianData = {}
	self.meridianData = DBTableHero.getPerVeinsData(self.heroid)
end

function YingXiongMeridianLayer:setHeroListData()
	self.heroListData = {}
	list = DBTableHero.getData(gameUser.getUserId());

	for k,v in pairs(list) do
		if v.level >= 40 then
			self.heroListData[#self.heroListData + 1] = v
		end
	end	

	table.sort(self.heroListData,function(data1,data2)
			if tonumber(data1.power) == tonumber(data2.power) then
				return tonumber(data1.heroid) < tonumber(data2.heroid)
			else
				return tonumber(data1.power)>tonumber(data2.power)
			end
		end)
end

function YingXiongMeridianLayer:setStaticData()
	self.meridianStaticData = {}
	self.meridianStaticData = gameData.getDataFromCSV("BingshuLvUp")
	local _table2 = gameData.getDataFromCSV("BingshuAdvanced")
	self.rankStaticData = {}
	for i=1,#_table2 do
		if self.rankStaticData[tonumber(_table2[i].jingmai)]==nil then
			self.rankStaticData[tonumber(_table2[i].jingmai)] = {}
		end
		self.rankStaticData[tonumber(_table2[i].jingmai)][#self.rankStaticData[tonumber(_table2[i].jingmai)] + 1] = _table2[i]
	end
end

function YingXiongMeridianLayer:getPosTable()
	local _itemPosTable = {
		cc.p(135,369),
		cc.p(150,107),
		cc.p(290,233),
		cc.p(407,321),
		cc.p(541,137),
		cc.p(880,97),
		cc.p(734,355),
		cc.p(485,502),
	}
	return _itemPosTable
end
function YingXiongMeridianLayer:getRotationTable()
	local _rotationTable = {
		80,40,-67,40,50,-23,-122
	}
	return _rotationTable
end

function YingXiongMeridianLayer:create(_heroid)
	local _layer = self.new(_heroid)
	return _layer
end

return YingXiongMeridianLayer