local YingXiongChooseEquipmentLayer = class("YingXiongChooseEquipmentLayer", function()
 	local select_sp = XTHD.createFunctionLayer()
    return select_sp
end)

function YingXiongChooseEquipmentLayer:onCleanup()
	for k,v in pairs(self.equipmentCellArr) do
		v:release()
	end
end

function YingXiongChooseEquipmentLayer:ctor(_equipmentData,YingXiongInfoLayer,_heroid,_pos,_size,parent)
	if _size ~=nil then
		self:setTextureRect(cc.rect(0,0,_size.width,_size.height))
	end
	self._parent = parent
	self.infoLayer = YingXiongInfoLayer
	self.equipmentListData = {}
	self.equipmentCellArr = {}
	self.selectedCellidx = 0
	self.equipmentTableView = nil
	self.propertyTips = nil

	self.chooseEquip_fontSize = 16

	self._oldFightValue = self.infoLayer.data.power or 0
    self._newFightValue = self._oldFightValue

	self._equipedProperty = {}   --存放已经装备上的道具的属性

	self._heroid = _heroid or 1

	self.animationed = false   --是否播放了动画

	self:setOpacity(0)

	self.index = _pos
	--
	self:getEquipedProperty()

	--获取装备列表数据
	self:setEquipmentData(_equipmentData)
	self:init()
end

function YingXiongChooseEquipmentLayer:init()

	local bg = cc.Sprite:create("res/image/newHeroinfo/heroEquip/Equipbg.png")
	self:addChild(bg)
	bg:setPosition(self:getContentSize().width *0.5,self:getContentSize().height *0.5)
	self._bg = bg

	local _bgSize = cc.size(self._bg:getContentSize().width - 40,self._bg:getContentSize().height - 60)

	--cell的大小
	local _tableViewSize = cc.size(_bgSize.width,_bgSize.height-2)	--tableview的大小
	local _tableviewCellSize = cc.size(_tableViewSize.width,100)
	self.tableviewCellSize = _tableviewCellSize

	local _equipListBg = ccui.Scale9Sprite:create(cc.rect(12,12,1,1),"res/image/common/scale9_bg_25.png")
	_equipListBg:setOpacity(0)
	_equipListBg:setContentSize(_bgSize)
	_equipListBg:setAnchorPoint(cc.p(0.5,0))
	_equipListBg:setPosition(cc.p(self:getContentSize().width/2,8))
	self:addChild(_equipListBg)

	self.equipmentTableView = CCTableView:create(_tableViewSize)
    self.equipmentTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.equipmentTableView:setPosition(-1,23)
    self.equipmentTableView:setBounceable(true)
    self.equipmentTableView:setDelegate()
    self.equipmentTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    _equipListBg:addChild(self.equipmentTableView)

    local function cellSizeForTable(table,idx)
        return _tableviewCellSize.width,_tableviewCellSize.height 
    end
    local function numberOfCellsInTableView(table)
        return #self.equipmentListData
    end
    local function tableCellAtIndex(table, idx)
        -- print("Big>>>>tableCellAtIndex")
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
        	cell = cc.TableViewCell:create()
        end
        
        local _cell_bg = self.equipmentCellArr[idx+1]
        if _cell_bg then
        	_cell_bg:removeFromParent()
        	cell:addChild(_cell_bg)
        	return cell
        end
        _cell_bg = self:createCellInfo(idx+1)
        _cell_bg:retain()
        _cell_bg:setPosition(cc.p(_tableviewCellSize.width/2,_tableviewCellSize.height/2+2))
        self.equipmentCellArr[idx+1] = _cell_bg
        cell:addChild(_cell_bg)
        return cell
    end   

    self.equipmentTableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.equipmentTableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self.equipmentTableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    
    self.equipmentTableView:reloadData()
end

--创建cell中的内容存到数组中
function YingXiongChooseEquipmentLayer:createCellInfo(_idx)
	local _equipmentinfodata = self.equipmentListData[_idx]
	local _levelEnough = true
	local _btnSize = cc.size(self.tableviewCellSize.width,self.tableviewCellSize.height - 10)
	local _cell_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
	_cell_bg:setContentSize(_btnSize)
	_cell_bg:setName("cellBg")


	--更换装备按钮
	local _exchangeBtn = XTHD.createCommonButton({
			btnColor = "write_1",
			isScrollView = false,
			text = LANGUAGE_BTN_KEY.exchange,
			fontSize = self.chooseEquip_fontSize + 60,
			needEnableWhenMoving = true,
			needSwallow = false,
		})
	_exchangeBtn:setScale(0.45)
	_exchangeBtn.index = _idx
	_exchangeBtn:setAnchorPoint(cc.p(1,0))
	_exchangeBtn:setPosition(cc.p(_cell_bg:getContentSize().width-5,5))
	_cell_bg:addChild(_exchangeBtn)
	_exchangeBtn:getLabel():setScale(1.5)
	_exchangeBtn:setTouchEndedCallback(function()
		self.selectedCellidx = _exchangeBtn.index or 0
		local _index = _exchangeBtn.index
		self:toEquipItem(_index)
	end)
	self.guide_exchangeBtn = _exchangeBtn

	local _herolevel = tonumber(self.infoLayer.data.level or 0)
	local _itemLevel = tonumber(_equipmentinfodata.level or 0)
	if _herolevel<_itemLevel then
		_levelEnough = false
		-- local _levelLabel = getCommonWhiteBMFontLabel(_itemLevel)
		-- _levelLabel:setAnchorPoint(cc.p(1,0.5))
		_exchangeBtn:getLabel():setString(LANGUAGE_BTN_KEY.noEnoughLevel)
		_exchangeBtn:getLabel():setFontSize(self.chooseEquip_fontSize +2)

		-- _exchangeBtn:getLabel():setPositionX(_exchangeBtn:getContentSize().width/2+_levelLabel:getContentSize().width/2)
		-- _levelLabel:setScale(1.3)
		-- _levelLabel:setPosition(cc.p(_exchangeBtn:getLabel():getBoundingBox().x,_exchangeBtn:getContentSize().height/2-7))
		-- _exchangeBtn:addChild(_levelLabel)
		_exchangeBtn:setTouchEndedCallback(function()
				XTHDTOAST(LANGUAGE_TIPS_equipItemLevelPromptTextXc(_itemLevel))
			end)
	elseif _equipmentinfodata.heroid and tonumber(_equipmentinfodata.heroid)>0 then
		_exchangeBtn:getLabel():setString(LANGUAGE_BTN_KEY.exchange)
		_exchangeBtn:getLabel():setFontSize(self.chooseEquip_fontSize+4)
	else
		_exchangeBtn:getLabel():setString(LANGUAGE_BTN_KEY.equip)
		_exchangeBtn:getLabel():setFontSize(self.chooseEquip_fontSize+4)
	end

	local item_bg =  XTHDPushButton:createWithFile(XTHD.resource.getItemImgById(_equipmentinfodata.resourceid))
	local _scale = 62/item_bg:getBoundingBox().width
    item_bg:setScale(_scale)
    item_bg:setAnchorPoint(0,0.5)
	item_bg:setPosition(cc.p(7+4,_cell_bg:getContentSize().height/2))
	item_bg:setEnableWhenOut(true)
	item_bg:setTouchBeganCallback(function()
			self.propertyTips = self:setPropertyTipLayer(_idx)
			local tmpPos = item_bg:convertToWorldSpace(cc.p(0,0))
			if tmpPos.x >= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y >= cc.Director:getInstance():getWinSize().height/2 then --第一象限
				self.propertyTips:setAnchorPoint(cc.p(1,1))
				self.propertyTips:setPosition(tmpPos.x,tmpPos.y)
			elseif tmpPos.x <= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y >= cc.Director:getInstance():getWinSize().height/2 then --第二象限
				self.propertyTips:setAnchorPoint(cc.p(0,1))
				self.propertyTips:setPosition(tmpPos.x+item_bg:getBoundingBox().width,tmpPos.y)
			elseif tmpPos.x <= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y <= cc.Director:getInstance():getWinSize().height/2 then --第三象限
				self.propertyTips:setAnchorPoint(cc.p(0,0))
				self.propertyTips:setPosition(tmpPos.x+item_bg:getBoundingBox().width,tmpPos.y+item_bg:getBoundingBox().height)
			elseif tmpPos.x >= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y <= cc.Director:getInstance():getWinSize().height/2 then --第四象限
				self.propertyTips:setAnchorPoint(cc.p(1,0))
				self.propertyTips:setPosition(tmpPos.x,tmpPos.y+item_bg:getBoundingBox().height)
			end

			cc.Director:getInstance():getRunningScene():addChild(self.propertyTips)
			self.propertyTips:setScale(0)
	        self.propertyTips:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.05),cc.ScaleTo:create(0.01,1)))
		end)
	item_bg:setTouchEndedCallback(function()
			if self.propertyTips ~=nil then
				self.propertyTips:removeAllChildren()
				self.propertyTips:removeFromParent()
				self.propertyTips = nil
			end
		end)
	local _itemBGSp = cc.Sprite:create(XTHD.resource.getQualityItemBgPath( _equipmentinfodata.quality))
	_itemBGSp:setPosition(cc.p(item_bg:getContentSize().width/2,item_bg:getContentSize().height/2))
	item_bg:addChild(_itemBGSp)

	if tonumber(_equipmentinfodata.quality)>3 then
		XTHD.addEffectToEquipment(item_bg,_equipmentinfodata.quality)	
	end
	

	_cell_bg:addChild(item_bg)

	--名称
	local _nameStr = tostring(_equipmentinfodata.name)
	if _equipmentinfodata.phaseLevel and tonumber(_equipmentinfodata.phaseLevel)>0 then
		_nameStr = _nameStr .. "+" .. _equipmentinfodata.phaseLevel
	end
	local name_label = XTHDLabel:create(_nameStr,self.chooseEquip_fontSize)
	name_label:setColor(cc.c3b(0,0,0))
	name_label:setAnchorPoint(cc.p(0,1))
	name_label:setPosition(cc.p(item_bg:getBoundingBox().width+item_bg:getBoundingBox().x+5+5,item_bg:getBoundingBox().y + item_bg:getBoundingBox().height - 2))
	_cell_bg:addChild(name_label)

	--等级
	local _level_label = XTHDLabel:create("Lv："..(tostring(_equipmentinfodata.strengLevel or 0)),self.chooseEquip_fontSize)
	_level_label:setColor(self:getEquipmentinfoTextColor("shenhese"))
	_level_label:setAnchorPoint(cc.p(0,1))
	_level_label:setPosition(cc.p(name_label:getPositionX(),name_label:getBoundingBox().y- 1))
	_cell_bg:addChild(_level_label)
	--战斗力
	local _subFightValue = 0
	local _equipedItemPower = tonumber(self._equipedProperty.power or 0)
	local _currentItemPower = tonumber(_equipmentinfodata.power or 0)
	_subFightValue = _currentItemPower - _equipedItemPower

	--战力差
	local _powerPath = "res/image/plugin/hero/hero_propertyadd.png"
	if _subFightValue<0 then
		_powerPath = "res/image/plugin/hero/hero_propertysub.png"
	else
		_powerPath = "res/image/plugin/hero/hero_propertyadd.png"
	end
	local _powerSpr = cc.Sprite:create(_powerPath)
	_powerSpr:setScale(0.5)
	_powerSpr:setAnchorPoint(cc.p(0,1))
	_powerSpr:setPosition(cc.p(_level_label:getPositionX(),item_bg:getBoundingBox().y + 20))
	_cell_bg:addChild(_powerSpr)
	local _subPowerValue_label = XTHDLabel:createWithParams({fnt = "res/image/common/common_num/yellowwordforcamp.fnt" , text = math.abs(_subFightValue) , kerning = -2})
	_subPowerValue_label:setScale(0.5)
	_subPowerValue_label:setAnchorPoint(cc.p(0,0))
	_subPowerValue_label:setPosition(cc.p(_powerSpr:getBoundingBox().x + _powerSpr:getBoundingBox().width + 2,_powerSpr:getPositionY()-18))
	_cell_bg:addChild(_subPowerValue_label)

	--穿戴
	if _equipmentinfodata.heroid and tonumber(_equipmentinfodata.heroid)>0 then
		local _hero_sp = HeroNode:createWithParams({
			heroid   = _equipmentinfodata.heroid or 1,
			star   = 0,
			advance = 1,
			clickable = false
		})
		_hero_sp:setScale(45/_hero_sp:getContentSize().width)
		_hero_sp:setAnchorPoint(cc.p(1,1))
		_hero_sp:setPosition(cc.p(_cell_bg:getBoundingBox().width - 13,_cell_bg:getContentSize().height - 5))
		_cell_bg:addChild(_hero_sp)
	elseif _idx == 1 and _levelEnough == true then 	--推荐
		if next(self._equipedProperty)==nil or self._equipedProperty.quality == nil or tonumber(_equipmentinfodata.quality)>tonumber(self._equipedProperty.quality) or (tonumber(_equipmentinfodata.quality)==tonumber(self._equipedProperty.quality) and _subFightValue>0) then
			local _recommend_spr = cc.Sprite:create("res/image/common/recommend_img.png")
			_recommend_spr:setAnchorPoint(cc.p(0.5,0.5))
			_recommend_spr:setPosition(cc.p(_recommend_spr:getContentSize().width*0.5 + 4,item_bg:getContentSize().height - _recommend_spr:getContentSize().height*0.5 - 5))
			item_bg:addChild(_recommend_spr)
		end
	end
	return _cell_bg
end

--tip属性对比框
function YingXiongChooseEquipmentLayer:setPropertyTipLayer(_idx)
	local _equipmentinfodata = self.equipmentListData[_idx]
	local _propertyBg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
	_propertyBg:setContentSize(cc.size(200,104))

	local _itemProperty = self:analyzeItemProperty(_equipmentinfodata.baseProperty or {})
	local _propertyTitlelabel = XTHDLabel:create(LANGUAGE_KEY_RPOPCOMPARE..":",self.chooseEquip_fontSize)-------属性对比:",self.chooseEquip_fontSize)
	local _contentHeight = 24 + (#_itemProperty + 1) *(8 + _propertyTitlelabel:getContentSize().height)
	_propertyBg:setContentSize(cc.size(200,_contentHeight))
	_propertyTitlelabel:setColor(cc.c3b(45,14,7))
	_propertyTitlelabel:setAnchorPoint(cc.p(0,1))
	_propertyTitlelabel:setPosition(cc.p(20,_propertyBg:getContentSize().height - 16))
	_propertyBg:addChild(_propertyTitlelabel)
	
	for i=1,#_itemProperty do
		local var = LANGUAGE_KEY_ATTRIBUTESNAME(_itemProperty[i][1])
		local label_info_number = XTHDLabel:create(var .. ":",self.chooseEquip_fontSize)
		label_info_number:setColor(cc.c3b(45,14,7))
		label_info_number:setAnchorPoint(0,1)
		label_info_number:setPosition(20,_propertyTitlelabel:getBoundingBox().y - 8 - (i-1)*(8+label_info_number:getContentSize().height))
		_propertyBg:addChild(label_info_number)
		local _spritePath = "res/image/plugin/hero/hero_propertyadd.png"
		local _sprite = nil
		if _itemProperty[i]._type and _itemProperty[i]._type == "add" then
			_sprite = cc.Sprite:create("res/image/plugin/hero/hero_propertyadd.png")
		elseif _itemProperty[i]._type and _itemProperty[i]._type == "sub" then
			_sprite = cc.Sprite:create("res/image/plugin/hero/hero_propertysub.png")
		else
			_sprite = XTHDLabel:create(" ",self.chooseEquip_fontSize)
		end
		_sprite:setAnchorPoint(cc.p(0,0.5))
		_sprite:setPosition(cc.p(label_info_number:getPositionX()+label_info_number:getContentSize().width+5,label_info_number:getBoundingBox().y + label_info_number:getBoundingBox().height/2))
		_propertyBg:addChild(_sprite)
		--值
		local _label_value = XTHDLabel:create(XTHD.resource.addPercent(_itemProperty[i][1],_itemProperty[i][2]),self.chooseEquip_fontSize)
		_label_value:setAnchorPoint(cc.p(0,0))
		_label_value:setColor(cc.c3b(45,14,7))
		_label_value:setPosition(cc.p(_sprite:getPositionX()+_sprite:getContentSize().width+5,label_info_number:getBoundingBox().y))
		_propertyBg:addChild(_label_value)
	end
	return _propertyBg
end

function YingXiongChooseEquipmentLayer:toEquipItem(_idx)
	self._oldFightValue = self.infoLayer.data.power or 0
    self._newFightValue = self._oldFightValue
	if self.equipmentListData[_idx].heroid and tonumber(self.equipmentListData[_idx].heroid)>0 then
		self:httpToExchangeItem(_idx)
	else
		self:httpToEquipItem(_idx)
	end
end

--穿戴的网络请求
function YingXiongChooseEquipmentLayer:httpToEquipItem(_idx)
	self.infoLayer:setButtonClickableState(false)
	ClientHttp:httpHeroEquipItem(self,function(data)
			local _normalNode = cc.Sprite:createWithTexture(nil, cc.rect(0,0,348,470))
	    	_normalNode:setOpacity(0)
    		self:addShadeLayer()
    		self.infoLayer:setOldEquipmentData(self.infoLayer.data["equipments"])
            if data["bodyItemProperty"] and next(data["bodyItemProperty"])~=nil then
            	--Equipments插入数据
                data.bodyItemProperty["heroid"] 	= data["petId"];
	            data.bodyItemProperty["dbid"] 	   	= data.bodyItemProperty["dbId"];
	            data.bodyItemProperty["itemid"]     = data.bodyItemProperty["itemId"];
	            data.bodyItemProperty["bagindex"]   = data.bodyItemProperty["position"] or 0;
	            DBTableEquipment.insertData(gameUser.getUserId(), data.bodyItemProperty)
	            --删除Item中的数据
	            DBTableItem.deleteData(gameUser.getUserId(), tostring(data.bodyItemProperty["dbid"]))
	        end
            if data["bagItemProperty"] and next(data["bagItemProperty"])~=nil then
            	--Items插入数据
	            DBTableItem.insertData(gameUser.getUserId(),data.bagItemProperty)
	            --删除equipments中的数据
	            DBTableEquipment.deleteData(gameUser.getUserId(),tostring(data.bagItemProperty["dbId"]))
            end
            --更新属性
            for i = 1,#data["petProperty"] do
        		local _petItemData = string.split( data["petProperty"][i],',')
        		DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[1],_petItemData[2],data["petId"])	
        		if tonumber(_petItemData[1]) == 407 then
	                self._newFightValue = tonumber(_petItemData[2])
	            end
        	end
        	self:reFreshRedPointData()
        	--刷新数据
        	self.infoLayer:refreshInfoLayer(data["petId"])
			self._parent:refreshEquipInfo()
			self._parent._tableView:reloadData()
        	--刷新当前身上的装备的属性
        	self:getEquipedProperty()
			self.equipmentTableView:reloadData()
			XTHD._createFightLabelToast({
 				oldFightValue = self._oldFightValue,
		        newFightValue = self._newFightValue 
				})
        	self._oldFightValue = self._newFightValue
        	self.infoLayer:setButtonClickableState(true)
	        ------引导    
	        self.__needRestGuide = false
	        self._parent._endCallback()
		end,{dbId = tostring(self.equipmentListData[_idx]["dbid"] or ""),petId=tostring(self._heroid or 1)},function()
	        self.infoLayer:setButtonClickableState(true)
		end)

end
--更换的网络请求
function YingXiongChooseEquipmentLayer:httpToExchangeItem(_idx)
	self.infoLayer:setButtonClickableState(false)
	ClientHttp:httpHeroExchangeItem(self,function(data)
			local _normalNode = cc.Sprite:createWithTexture(nil, cc.rect(0,0,348,470))
	    	_normalNode:setOpacity(0)
	    	self:addShadeLayer()
        	self.infoLayer:setOldEquipmentData(self.infoLayer.data["equipments"])
        	--刷新英雄属性
        	DBTableHero.multiUpdate(gameUser.getUserId(),data.sourcePetId,data.sourceProperty)
        	DBTableHero.multiUpdate(gameUser.getUserId(),data.targetPetId,data.targetProperty)
        	--改变装备中的heroid
        	DBTableEquipment.updateHeroid(gameUser.getUserId(),data.targetPetId,data.dbId)
        	--Item添加
        	if data.addItem and next(data.addItem)~=nil then
        		DBTableEquipment.deleteData(gameUser.getUserId(),tostring(data.addItem["dbId"]))
        		DBTableItem.updateCount(gameUser.getUserId(), data.addItem, data.addItem.dbId )
        	end
        	for i = 1,#data["targetProperty"] do
        		local _petItemData = string.split( data["targetProperty"][i],',')
        		if tonumber(_petItemData[1]) == 407 then
	                self._newFightValue = tonumber(_petItemData[2])
	                break
	            end
        	end
        	self:reFreshRedPointData()
        	--刷新数据
        	self.infoLayer:refreshInfoLayer(data.targetPetId)
        	--刷新被更换者的数据
        	self.infoLayer:setTheHeroData(data.sourcePetId)
			self._parent:refreshEquipInfo()
			self._parent._tableView:reloadData()
        	--刷新当前身上的装备的属性
        	self:getEquipedProperty()

			XTHD._createFightLabelToast({
 				oldFightValue = self._oldFightValue,
		        newFightValue = self._newFightValue
				})
        	self._oldFightValue = self._newFightValue
        	self.infoLayer:setButtonClickableState(true)
			self._parent._endCallback()
		end,{sourcePetId=self.equipmentListData[_idx].heroid,dbId=self.equipmentListData[_idx]["dbid"],targetPetId=self._heroid},function()
			self.infoLayer:setButtonClickableState(true)
		end)
	-- ClientHttp:requestAsyncInGameWithParams({
	-- 	modules = "exchangeEquip?",
 --        params = {sourcePetId=self.equipmentListData[_idx].heroid,dbId=self.equipmentListData[_idx]["dbid"],targetPetId=self._heroid},
 --        successCallback = function(data,obj,response)
 --            if tonumber(data.result) == 0 then
 --            	local _normalNode = cc.Sprite:createWithTexture(nil, cc.rect(0,0,348,470))
	-- 	    	_normalNode:setOpacity(0)
	-- 	    	self:addShadeLayer()
 --            	self.infoLayer:setOldEquipmentData(self.infoLayer.data["equipments"])
 --            	--刷新英雄属性
 --            	DBTableHero.multiUpdate(gameUser.getUserId(),data.sourcePetId,data.sourceProperty)
 --            	DBTableHero.multiUpdate(gameUser.getUserId(),data.targetPetId,data.targetProperty)
 --            	--改变装备中的heroid
 --            	DBTableEquipment.updateHeroid(gameUser.getUserId(),data.targetPetId,data.dbId)
 --            	--Item添加
 --            	if data.addItem and next(data.addItem)~=nil then
 --            		DBTableEquipment.deleteData(gameUser.getUserId(),tostring(data.addItem["dbId"]))
 --            		DBTableItem.updateCount(gameUser.getUserId(), data.addItem, data.addItem.dbId )
 --            	end
 --            	for i = 1,#data["targetProperty"] do
 --            		local _petItemData = string.split( data["targetProperty"][i],',')
 --            		if tonumber(_petItemData[1]) == 407 then
	-- 	                self._newFightValue = tonumber(_petItemData[2])
	-- 	                break
	-- 	            end
 --            	end
 --            	self:reFreshRedPointData()
 --            	--刷新数据
 --            	self.infoLayer:refreshInfoLayer(data.targetPetId)
 --            	--刷新被更换者的数据
 --            	self.infoLayer:setTheHeroData(data.sourcePetId)
 --            	--刷新当前身上的装备的属性
 --            	self:getEquipedProperty()

	-- 			XTHD._createFightLabelToast({
	--  				oldFightValue = self._oldFightValue,
	-- 		        newFightValue = self._newFightValue
 -- 				})
 --            	self._oldFightValue = self._newFightValue
 --            else
 --            	--ShowNetTipWithResultValue(net_data.result)
 --               -- XTHDTOAST("返回数字为: " .. data.result)
 --               XTHDTOAST(data.msg)
 --            end
 --            self.infoLayer:setButtonClickableState(true)
 --        end,--成功回调
 --        targetNeedsToRetain = button,
 --        failedCallback = function()
	--         self.infoLayer:setButtonClickableState(true)
 --            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)--------"网络请求失败")
 --        end,--失败回调
 --        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
 --    })
end

function YingXiongChooseEquipmentLayer:addShadeLayer()
	do return end
	local _layerButton = XTHDPushButton:create({
			normalNode = _normalNode
		})
	_layerButton:setName("layerButton")
	_layerButton:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
	self:addChild(_layerButton)
end

--获取装备列表数据
function YingXiongChooseEquipmentLayer:setEquipmentData(_data)
	self.equipmentListData = {}
	for k,v in pairs(_data) do
		if (v.position and v.position == self.index) or (v.bagindex and v.bagindex == self.index) then
			if not v.heroid or v.heroid ~= self._heroid then
				self.equipmentListData[#self.equipmentListData + 1] = v
			end
		end
	end
	-- table.sort(self.equipmentListData,function(data1,data2)
	-- 		local _data1Num = data1.quality
	-- 		local _data2Num = data2.quality
	-- 		if not data1.heroid then
	-- 			_data1Num = 100 * _data1Num
	-- 		end
	-- 		if not data2.heroid then
	-- 			_data2Num = 100 * _data2Num
	-- 		end
	-- 		if tonumber(_data1Num) == tonumber(_data2Num) then
	-- 			if tonumber(data1.power) == tonumber(data2.power) then
	-- 				return tonumber(data1.itemid)>tonumber(data2.itemid)
	-- 			else
	-- 				return tonumber(data1.power)>tonumber(data2.power)
	-- 			end
	-- 		else
	-- 			return tonumber(_data1Num) > tonumber(_data2Num)
	-- 		end
	-- 	end)
end
--解析道具的基本属性
function YingXiongChooseEquipmentLayer:analyzeItemProperty(_property)
	local _propertyItem = {}
	--当前装备上的属性
	for i=1,#self._equipedProperty do
		_propertyItem[i] = {}
		_propertyItem[i]._type = "sub" 		--假设当前装备着的属性，在当前选中的装备属性中是没有的,也就是方向向下的
		for j=1,#self._equipedProperty[i] do
			_propertyItem[i][j] = nil
			_propertyItem[i][j] = self._equipedProperty[i][j]
		end
		-- _propertyItem[i][2] = XTHD.resource.addPercent(self._equipedProperty[i][1],self._equipedProperty[i][2])
	end
	local _propertyTable = string.split(_property,'#') or {}
	for i=1,#_propertyTable do
		local _property = string.split(_propertyTable[i],',') or {}
		_property._type = "add"
		--跟已经装备的属性进行对比
		for k,v in pairs(_propertyItem) do
			if _property and _property[1] == v[1] then
				v[2] = tonumber(_property[2]) - tonumber(v[2])
				if v[2] > 0 then
					v._type = "add"
				elseif v[2] < 0 then
					v[2] = math.abs(v[2])
					v._type = "sub"
				else
					v._type = "equal"
				end
				v[2] = v[2]
				-- XTHD.resource.addPercent(v[1],v[2])
				_property = nil
			end
		end

		if _property then
			-- XTHD.resource.addPercent(_property[1],_property[2])
			_propertyItem[#_propertyItem+1] = _property
		end
	end
	return _propertyItem
end
--已装备道具的基础属性
function YingXiongChooseEquipmentLayer:getEquipedProperty()
	--已装备的道具属性
	self._equipedProperty = {}
	local _equipedProperty = nil
	local _equipPower = 0
	local _equipQuality = 1
	for k,v in pairs(self.infoLayer.data["equipments"]) do
		if tonumber(v.bagindex) == self.index then
			_equipedProperty = v.baseProperty or nil
			_equipPower = v.power
			_equipQuality = v.quality
			break
		end
	end
	if not _equipedProperty then
		return
	end
	local _equipedItemTable = string.split(_equipedProperty,'#') or {}
	for i=1,#_equipedItemTable do
		local _property = string.split(_equipedItemTable[i],',')
		self._equipedProperty[i] = {}
		self._equipedProperty[i] = _property
	end
	self._equipedProperty.power = _equipPower
	self._equipedProperty.quality = _equipQuality
	-- print("8431>>>>.self._equipedProperty>>" .. zctech.print_table(self._equipedProperty))
end
function YingXiongChooseEquipmentLayer:reFreshHeroFunctionInfo()
	-- print("刷新》》YingXiongChooseEquipmentLayer:reFreshHeroFunctionInfo")
end

--获取装备信息界面的文字颜色
function YingXiongChooseEquipmentLayer:getEquipmentinfoTextColor(_str)
	local _textColor = {
		shenhese = cc.c4b(70,34,34,255)
	}
	return _textColor[_str]
end

function YingXiongChooseEquipmentLayer:reFreshRedPointData()
	RedPointManage:getDynamicItemData()
	RedPointManage:getDynamicEquipmentData()
end

function YingXiongChooseEquipmentLayer:onEnter()
end

function YingXiongChooseEquipmentLayer:onExit()
end

function YingXiongChooseEquipmentLayer:create(_equipmentData,YingXiongInfoLayer,_heroid,_pos,_size,parent)
	local _layer = self.new(_equipmentData,YingXiongInfoLayer,_heroid,_pos,_size,parent)
	return _layer
end

return YingXiongChooseEquipmentLayer