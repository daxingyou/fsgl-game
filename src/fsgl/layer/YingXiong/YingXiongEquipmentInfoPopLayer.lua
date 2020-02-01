--xingchen
local YingXiongEquipmentInfoPopLayer = class("YingXiongEquipmentInfoPopLayer",function()
		return XTHDPopLayer:create()
	end)

local equipDes = {
	[3] = {
		"2件5星蓝色装备: 生命+2000",
		"4件5星蓝色装备: 物防+500\n                魔防+500",
		"6件5星蓝色装备: 物攻+500\n                魔攻+500",
	},
	[4] = {
		"2件5星紫色装备: 生命+10000",
		"4件5星紫色装备: 物防+1000\n                魔防+1000",
		"6件5星紫色装备: 物攻+1000\n                魔攻+1000",
	},
	[5] = {
		"2件5星橙色装备: 生命+30000",
		"4件5星橙色装备: 物防+5000\n                魔防+5000",
		"6件5星橙色装备: 物攻+5000\n                魔攻+5000",
	},
	[6] = {
		"2件5星红色装备: 生命+70000",
		"4件5星红色装备: 物防+10000\n                魔防+10000",
		"6件5星红色装备: 物攻+10000\n                魔攻+10000",
	},
}

function YingXiongEquipmentInfoPopLayer:ctor(_pos,HeroInfoLayer,_dbid,_prompt,parent)
	if  not _dbid then
		_dbid = 0
	end
	self._parent = parent
	self._prompt = _prompt or {}
	self.infoLayer = HeroInfoLayer
	self._heroid = self.infoLayer.data["heroid"]
	self.equipment_fontSize = 16
	self._oldFightValue = self.infoLayer.data.power or 0
    self._newFightValue = self._oldFightValue 
	self.index = _pos
	self.dbid = _dbid

	self.itemInfoData = {}
	self._itemProperty = {}

	if not self.dbid or self.dbid == 0 then --已经穿戴的装备
		self:setEquipedItemData()
	end
	self:analyzeItemProperty()

	self:init()
end

function YingXiongEquipmentInfoPopLayer:init()
	local _popBgSprite  = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
 	_popBgSprite:setContentSize(cc.size(355,445))
 	local popNode = XTHDPushButton:createWithParams({
                        normalNode = _popBgSprite
                    })
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:getContainerLayer():addChild(popNode)
    self.popNode = popNode

    if next(self.itemInfoData)==nil then
    	self:removeFromParent()
    	return
    end
    --道具头像
    local _itemPath = XTHD.resource.getItemImgById(self.itemInfoData.resourceid)
    local _bgPath = XTHD.resource.getQualityItemBgPath(self.itemInfoData.rank)
    local item_spr = cc.Sprite:create(_itemPath)
    item_spr:setAnchorPoint(0.5,0.5)
    local _item_bg = cc.Sprite:create(_bgPath)
    _item_bg:setAnchorPoint(cc.p(0.5,0.5))
    _item_bg:setPosition(cc.p(item_spr:getContentSize().width/2,item_spr:getContentSize().height/2))
    item_spr:addChild(_item_bg)

	item_spr:setPosition(18+40,popNode:getContentSize().height - 16 - 40)
	item_spr:setScale(0.8)
	popNode:addChild(item_spr)
	-- print("道具的数据为：")
	-- print_r(self.itemInfoData)
	if tonumber(self.itemInfoData.rank)>3 then
		XTHD.addEffectToEquipment(item_spr,self.itemInfoData.rank)
    end


	--名称
	local _subPosY = 10
	local label_name = XTHDLabel:create(self.itemInfoData["name"], self.equipment_fontSize)
	label_name:enableShadow(cc.c4b(70,34,34,255),cc.size(.04,-0.4),1)
	label_name:setColor(self:getEquipmentinfoTextColor("shenhese"))
	label_name:setAnchorPoint(cc.p(0,0.5))
	label_name:setPosition(18 + 80 +5,item_spr:getBoundingBox().y + item_spr:getBoundingBox().height - _subPosY)
	popNode:addChild(label_name)
	if self.itemInfoData["phaseLevel"] and tonumber(self.itemInfoData["phaseLevel"])> 0 then
		local _phaseLabel = XTHDLabel:create("+" .. self.itemInfoData["phaseLevel"],self.equipment_fontSize)
		_phaseLabel:setColor(self:getEquipmentinfoTextColor("lvse"))
		_phaseLabel:setAnchorPoint(cc.p(0,0.5))
		_phaseLabel:setPosition(cc.p(label_name:getBoundingBox().x + label_name:getBoundingBox().width + 5,label_name:getPositionY()))
		popNode:addChild(_phaseLabel)
	end
	--强化等级
	local _strengthLevelTitle = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.itemStrengLevelTitleTextXc,self.equipment_fontSize)
	_strengthLevelTitle:setAnchorPoint(cc.p(0,0.5))
	_strengthLevelTitle:setColor(self:getEquipmentinfoTextColor("shenhese"))
	_strengthLevelTitle:setPosition(cc.p(label_name:getPositionX() ,item_spr:getBoundingBox().y + item_spr:getBoundingBox().height/2))
	popNode:addChild(_strengthLevelTitle)
	local _strengLevelStr = self.itemInfoData["strengLevel"] or 0
	_strengLevelStr = tonumber(_strengLevelStr)>0 and _strengLevelStr or 0
	local _strengLevel_label = XTHDLabel:create(_strengLevelStr,self.equipment_fontSize)
	_strengLevel_label:setAnchorPoint(cc.p(0,0.5))
	_strengLevel_label:setColor(self:getEquipmentinfoTextColor("shenhese"))
	_strengLevel_label:setPosition(cc.p(_strengthLevelTitle:getBoundingBox().x + _strengthLevelTitle:getBoundingBox().width,_strengthLevelTitle:getPositionY()))
	popNode:addChild(_strengLevel_label)
	--穿戴英雄类型
	local _herotypeTable = string.split(self.itemInfoData["herotype"],'#')
	local _itemHeroType_label = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.itemHeroTypeTextXc,self.equipment_fontSize)
	_itemHeroType_label:setColor(self:getEquipmentinfoTextColor("shenhese"))
	_itemHeroType_label:setAnchorPoint(cc.p(0,0.5))
	_itemHeroType_label:setPosition(cc.p(label_name:getPositionX(),item_spr:getBoundingBox().y + _subPosY))
	popNode:addChild(_itemHeroType_label)

	local _heroTypeCount = 0
	for i=1,#_herotypeTable do
		local _heroType_spr = cc.Sprite:create(XTHD.resource.getHeroTypeImgPath(tonumber(_herotypeTable[i])))
		_heroType_spr:setAnchorPoint(cc.p(0,0.5))
		_heroType_spr:setPosition(cc.p(2+_itemHeroType_label:getPositionX()+_itemHeroType_label:getContentSize().width+_heroTypeCount*(4+_heroType_spr:getContentSize().width),_itemHeroType_label:getBoundingBox().y + _itemHeroType_label:getBoundingBox().height/2))
		_heroTypeCount = _heroTypeCount + 1 
		popNode:addChild(_heroType_spr)
	end
	
	--属性
	local property_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
    property_bg:setContentSize(cc.size(326,204))
    property_bg:setCascadeOpacityEnabled(true)
    property_bg:setCascadeColorEnabled(true)
    property_bg:setAnchorPoint(0.5,1)
    property_bg:setPosition(popNode:getContentSize().width/2,popNode:getContentSize().height - 16 -80 -10)
    popNode:addChild(property_bg)
   
    local _scrollviewSize = cc.size(property_bg:getContentSize().width,property_bg:getBoundingBox().height - 15)
	self._propertyScrollView = ccui.ScrollView:create()
	self._propertyScrollView:setBounceEnabled(true)
	self._propertyScrollView:setTouchEnabled(true)
	self._propertyScrollView:setScrollBarEnabled(false)
	self._propertyScrollView:setDirection(ccui.ScrollViewDir.vertical)
	self._propertyScrollView:setContentSize(_scrollviewSize)
	self._propertyScrollView:setInnerContainerSize(_scrollviewSize)
	self._propertyScrollView:setPosition(cc.p(0,6))
	property_bg:addChild(self._propertyScrollView)

	self:setPropertyPart(self._itemProperty)

	--按钮
	if self.itemInfoData._euipedType== true then
		self:setButtonPart(self._prompt)
	end
	self:show()
end

function YingXiongEquipmentInfoPopLayer:setPropertyPart(_data)
    if self._propertyScrollView~=nil then
        self._propertyScrollView:removeAllChildren()
    end
    local _rowHeight = 28
    local _rowPosY = 15
    local _propertyNum = #_data or 0
    local _innerHeight = 28*_propertyNum + 150
    local _contentHeight = self._propertyScrollView:getContentSize().height
    if tonumber(_innerHeight)<tonumber(_contentHeight) then
        _innerHeight = _contentHeight
    end
    self._propertyScrollView:setInnerContainerSize(cc.size(326,_innerHeight))
    local count = 0
    if equipDes[self.itemInfoData.rank] then
    	count = #equipDes[self.itemInfoData.rank]
    end
    for i=1,_propertyNum + count do
        if i~=_propertyNum then
            local _lineSpr = ccui.Scale9Sprite:create(cc.rect(5,0,1,1),"res/image/common/scale_line.png")
            _lineSpr:setContentSize(cc.size(self._propertyScrollView:getContentSize().width-26,1))
            _lineSpr:setName("lineSpr")
            _lineSpr:setPosition(cc.p(self._propertyScrollView:getContentSize().width/2,self._propertyScrollView:getInnerContainerSize().height -7-_rowHeight*i))
            self._propertyScrollView:addChild(_lineSpr)
            _lineSpr:setVisible(false)
        end
        if i <= _propertyNum then
        	local info_label_name = XTHDLabel:create(LANGUAGE_KEY_ATTRIBUTESNAME(_data[i]["keyNum"]) .. ":",self.equipment_fontSize)
	        info_label_name:setColor(self:getEquipmentinfoTextColor("shenhese"))
	        info_label_name:setAnchorPoint(0,0.5)
	        info_label_name:setPosition(15,self._propertyScrollView:getInnerContainerSize().height-7-_rowHeight*i +_rowPosY)
	        self._propertyScrollView:addChild(info_label_name)
	        local current_info_number = XTHDLabel:create(XTHD.resource.addPercent(_data[i]["keyNum"],_data[i]["baseValue"]), self.equipment_fontSize)
	        current_info_number:setColor(self:getEquipmentinfoTextColor("hongse"))
	        current_info_number:setAnchorPoint(0,0.5)
	        current_info_number:setPosition(cc.p(info_label_name:getBoundingBox().x + info_label_name:getBoundingBox().width +10,info_label_name:getPositionY()))
	        self._propertyScrollView:addChild(current_info_number)
	        if _data[i]["phaseValue"] and  tonumber(_data[i]["phaseValue"])>0 then
	        	local add_info_number = XTHDLabel:create("+" .. XTHD.resource.addPercent(_data[i]["keyNum"],_data[i]["phaseValue"]), self.equipment_fontSize)
		        add_info_number:setColor(self:getEquipmentinfoTextColor("lvse"))
		        add_info_number:setAnchorPoint(0,0.5)
		        add_info_number:setPosition(cc.p(190,current_info_number:getPositionY()))
		        self._propertyScrollView:addChild(add_info_number)
	        end
        else
        	-- print("套装属性加成"..(i - _propertyNum))
        	if (i - _propertyNum) == 1 then
        		_rowHeight = 28
        	elseif (i - _propertyNum) == 2 then
        		_rowHeight = 30
        	else
        		_rowHeight = 33
        	end
        	local info_label_name = XTHDLabel:create(equipDes[self.itemInfoData.rank][i - _propertyNum],self.equipment_fontSize)
	        if self:adjustPropertyCondition((i - _propertyNum)*2) then
        		info_label_name:setColor(self:getEquipmentinfoTextColor("shenhese"))
        	else
        		info_label_name:setColor(self:getEquipmentinfoTextColor("gray"))
        	end
	        info_label_name:setAnchorPoint(0,0.5)
	        info_label_name:setPosition(15,self._propertyScrollView:getInnerContainerSize().height-7-_rowHeight*i +_rowPosY)
	        self._propertyScrollView:addChild(info_label_name)
        end 
    end

end
function YingXiongEquipmentInfoPopLayer:setButtonPart(_promptTable)
	_promptTable = _promptTable or {}
	local _btnNumber = 3 	 	--按钮数量
	local _btnGap = 116 		--按钮间距
	local _btn_pos_arr = SortPos:sortFromMiddle(cc.p(self.popNode:getContentSize().width / 2,24+45) , _btnNumber , _btnGap)
	local _btnText = {"change" ,"demount" ,"strength"}
	local _btnPrompt = {strength = "none",change = "none"}
	for i=1,#_promptTable do
		if tostring(_promptTable[i]) == "canStreng" then
			_btnPrompt.strength = tostring(_promptTable[i])
		elseif tostring(_promptTable[i]) == "canAdvance" then
			if _btnPrompt.strength == "none" then
				_btnPrompt.strength = tostring(_promptTable[i])
			end
		elseif tostring(_promptTable[i]) == "canChangeBetterItem" then
			_btnPrompt.change = tostring(_promptTable[i])
		end
	end
	for i=1,3 do
		local _btn = XTHD.createButton({
			normalFile = "res/image/plugin/hero/" .. _btnText[i] .. "Btn_text.png"
			,selectedFile = "res/image/plugin/hero/" .. _btnText[i] .. "Btn_text.png"
		})
		-- local _btnText_sp = cc.Sprite:create("res/image/plugin/hero/" .. _btnText[i] .. "Btn_text.png")
		-- _btnText_sp:setPosition(cc.p(_btn:getContentSize().width/2,_btn:getContentSize().height/2))
		-- _btn:addChild(_btnText_sp)
		_btn:setName(_btnText[i] .. "Btn")
		_btn:setPosition(cc.p(_btn_pos_arr[i]))
		local _btnName = _btnText[i]
		self.popNode:addChild(_btn)
		if _btnPrompt[_btnText[i]] and _btnPrompt[_btnText[i]]~="none" then
			local _promptSprite = self.infoLayer:createPromptSprite(_btnPrompt[_btnText[i]])
			_promptSprite:setAnchorPoint(cc.p(1,0))
			_promptSprite:setPosition(cc.p(_btn:getContentSize().width + 15,0))
			_promptSprite:setName("promptSprite")
			_btn:addChild(_promptSprite)
		end
		_btn:setTouchEndedCallback(function()
			if _btn:getChildByName("promptSprite") then
				_btn:getChildByName("promptSprite"):stopAllActions()
				_btn:getChildByName("promptSprite"):removeFromParent()
			end
			self:clickToItemBtnCallback(_btnName,self._heroid,_btnPrompt[_btnText[i]])
		end)
	end
end
function YingXiongEquipmentInfoPopLayer:EquipCallBack(_heroid)
	self.infoLayer:refreshInfoLayer(_heroid)
	self.infoLayer:reFreshLeftLayer()
	-- self.infoLayer:refreshheroLayerEquipmentsData()
	self:hide({music = true})
end
function YingXiongEquipmentInfoPopLayer:clickToItemBtnCallback(_type,_heroid,_turnType)
	if _type==nil then
		return
	end
	if _type == "strength" then
		self:clickToItemStrength(_heroid,_turnType)
	elseif _type == "demount" then
		self:clickToItemDemount(_heroid)
	elseif _type == "change" then
		self:clickToItemChange(_heroid)
	end
end
--强化
function YingXiongEquipmentInfoPopLayer:clickToItemStrength(_heroid,_turnType)
	local _turnId = 1
	if _turnType ~=nil and _turnType == "canAdvance" then
		_turnId = 2
	end
	XTHD.createEquipLayer(_heroid,self.dbid,_turnId,function ()
    	self:EquipCallBack(_heroid)
	end)
	self:setVisible(false)
end
--卸下
function YingXiongEquipmentInfoPopLayer:clickToItemDemount(_heroid)
	if not self.dbid and next(self.dbid)==nil then
		XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.itemDemountFailTextXc)
		return
	end
	self._oldFightValue = self.infoLayer.data.power or 0
    self._newFightValue = self._oldFightValue 
    ClientHttp:httpHeroDemountItem(self,function(data)
    		--Items插入数据
            DBTableItem.insertData(gameUser.getUserId(), data.itemProperty)
            --删除equipments中的数据
            DBTableEquipment.deleteData(gameUser.getUserId(), tostring(data.itemProperty["dbId"]))
            --更新属性
            for i = 1,#data["petProperty"] do
        		local _petItemData = string.split( data["petProperty"][i],',')
        		DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[1],_petItemData[2],data["petId"])
        		if tonumber(_petItemData[1]) == 407 then
	                self._newFightValue = tonumber(_petItemData[2])
	            end
        	end
        	--刷新数据
        	self.infoLayer:refreshInfoLayer(data["petId"])
			self._parent:refreshEquipInfo()
			self._parent._tableView:reloadData()
        	--self.infoLayer:reFreshLeftLayer()
        	XTHD._createFightLabelToast({
 				oldFightValue = self._oldFightValue,
		        newFightValue = self._newFightValue 
				})
				self._oldFightValue = self._newFightValue
				
        	self:hide({music = true})
    	end,{dbId=self.dbid,petId=_heroid})
end
--更换
function YingXiongEquipmentInfoPopLayer:clickToItemChange(_heroid)
	local _iteminfo = {}
	local _allItemsData = self.infoLayer:addEquipedItemsForHero(_iteminfo,self.index)
	if self.index and self.index>0 and self.index<7 and next(_allItemsData)~=nil then
		self._parent:turnToChooseEquipment(_allItemsData,self.index)
	else
		XTHDTOAST(LANGUAGE_TIPS_WORDS103)-----"没有可以更换的装备")
	end
	self:hide({music = true})
end
--设置已经装备的道具数据
function YingXiongEquipmentInfoPopLayer:setEquipedItemData()
	local _itemData = DBTableEquipment.getData(gameUser.getUserId(), {heroid = self._heroid,bagindex = self.index} ) 
	_itemData = _itemData and _itemData or {}
	for k,v in pairs(_itemData) do
		self.itemInfoData[k] = v
	end
	local _staticEquipment_herotype= gameData.getDataFromCSV("EquipInfoList",{["itemid"] = _itemData["itemid"]})
	_staticEquipment_herotype = _staticEquipment_herotype and _staticEquipment_herotype["herotype"] or nil
	if _staticEquipment_herotype then
		self.itemInfoData.herotype = _staticEquipment_herotype
	end
	local _staticItemData = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = _itemData["itemid"]})
	_staticItemData = _staticItemData and _staticItemData or {}
	if next(_staticItemData)==nil then
		self.itemInfoData = {}
		return
	end
	for _k,_v in pairs(_staticItemData) do
		self.itemInfoData[_k] = _v
	end
	self.itemInfoData._euipedType = true
	self.dbid = self.itemInfoData["dbid"] or nil
end
--解析道具的基本属性
function YingXiongEquipmentInfoPopLayer:analyzeItemProperty()
	if next(self.itemInfoData)==nil then
		return
	end
	local _phaseTable = string.split(self.itemInfoData["phaseProperty"],'#') or {}
	local _phaseProperty = {}
	for i=1,#_phaseTable do
		local _phase = string.split(_phaseTable[i],',')
		local _key = tostring(_phase[1])
		local _value = tonumber(_phase[2] or 0)
		if _phaseProperty[_key] then
			_phaseProperty[_key] = tonumber(_phaseProperty[_key]) + tonumber(_value)
		else
			_phaseProperty[_key] = _value
		end
	end

	local _propertyTable = string.split(self.itemInfoData["baseProperty"],'#') or {}
	for i=1,#_propertyTable do
		local _property = string.split(_propertyTable[i],',')
		
		local _key = _property[1]
		local _addvalue = _phaseProperty[_key] or 0
		self._itemProperty[i] = {}
		self._itemProperty[i].keyNum = _property[1]
		self._itemProperty[i].baseValue = _property[2]
		self._itemProperty[i].phaseValue = _addvalue
	end
end
--获取装备信息界面的文字颜色
function YingXiongEquipmentInfoPopLayer:getEquipmentinfoTextColor(_str)
	local _textColor = {
		hongse = cc.c4b(204,2,2,255),                           --红色
        shenhese = cc.c4b(70,34,34,255),                        --深褐色，用的比较多
        lanse = cc.c4b(26,158,207,255),                         --蓝色
        chenghongse = cc.c4b(205,101,8,255),                    --橙红色
        zongse = cc.c4b(128,112,91,255),                        --棕色，有点深灰色的感觉
        baise = cc.c4b(255,255,255,255),                        --白色
        lvse = cc.c4b(104,157,0,255),                           --绿色
        juse=cc.c4b(255,79,2,255),                              --橘色
        gray=cc.c4b(128,128,128,255),                           --灰色
	}
	return _textColor[_str]
end

--套装属性是否达到条件
function YingXiongEquipmentInfoPopLayer:adjustPropertyCondition(_type)
	local count = 0
	for i = 1,#self.infoLayer.data.equipments do
		if self.itemInfoData.rank == self.infoLayer.data.equipments[i].quality then
			if self.infoLayer.data.equipments[i].phaseLevel >= 5 then
				count = count + 1
			end
		end
	end
	if count >= _type then
		return true
	end
	return false
end

function YingXiongEquipmentInfoPopLayer:create(_pos,HeroInfoLayer,dbid,_prompt,parent)
	if not dbid then 
		dbid = 0
	end
	local _layer = self.new(_pos,HeroInfoLayer,dbid,_prompt,parent)
	return _layer
end

function YingXiongEquipmentInfoPopLayer:onEnter( )
	
end

return YingXiongEquipmentInfoPopLayer