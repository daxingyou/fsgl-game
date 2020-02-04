local XingNangShowNode = class("XingNangShowNode",function()
	local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	return node
end)

function XingNangShowNode:ctor(size,itemdata)
	self._itemdata = itemdata
--	dump(self._itemdata)
	self._winSize = size
	self:setItemDropData()
	self:setStaticSystemName()
	self:setStaticStage()
	self:init()
end

function XingNangShowNode:init()
	self:setContentSize(self._winSize)
	local _bg = cc.Sprite:create("res/image/common/scale9_bg3_34.png")
	_bg:setAnchorPoint(0.5,0.5)
	self:addChild(_bg)
	_bg:setContentSize(self._winSize)
	_bg:setPosition(self:getContentSize().width *0.5,self:getContentSize().height *0.5)
	self._bg = _bg
	self._bg:setOpacity(0)

	local itemNode = ItemNode:createWithParams({
		itemId = self._itemdata.itemid,
		_type_ = 4,
		isShowDrop = false,
		touchShowTip = false,
	})
	itemNode:setScale(0.9)
	self._bg:addChild(itemNode)
	itemNode:setPosition(itemNode:getContentSize().width *0.5 + 25,self._bg:getContentSize().height - itemNode:getContentSize().height *0.5 - 10)

	local itemName = XTHDLabel:create(self._itemdata.name,20)
	itemName:setAnchorPoint(0,0.5)
	itemName:setColor(cc.c3b(0,0,0))
	self._bg:addChild(itemName)
	itemName:setPosition(itemNode:getPositionX() + itemNode:getContentSize().width *0.5 + 10,itemNode:getPositionY() + itemNode:getContentSize().height *0.4 - itemName:getContentSize().height *0.5)
	
	if self._itemdata.item_type == 3 then
		-- print("限制：")
		-- local xianzhi = XTHDLabel:create("限制：",20)
		-- self._bg:addChild(xianzhi)
		-- xianzhi:setColor(cc.c3b(0,0,0))
		-- xianzhi:setAnchorPoint(0,0.5)
		-- xianzhi:setPosition(itemName:getPositionX(),itemName:getPositionY() - itemName:getContentSize().height *0.5 - 15)

		-- local itemType = cc.Sprite:create(XTHD.resource.getHeroTypeImgPath(tonumber(self._itemdata.item_type)))
		-- itemType:setScale(0.8)
		-- self._bg:addChild(itemType)
		-- itemType:setAnchorPoint(0,0.5)
		-- itemType:setPosition(xianzhi:getPositionX() + xianzhi:getContentSize().width,xianzhi:getPositionY())
	end
	
	local count = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = self._itemdata.itemid}).count or 0
	--拥有数量
	local haveNum = XTHDLabel:create("拥有：" ..tostring(count).."件",20)
	haveNum:setColor(cc.c3b(0,0,0))
	haveNum:setAnchorPoint(0,0.5)
	self._bg:addChild(haveNum)
	haveNum:setPosition(itemName:getPositionX(),itemNode:getPositionY() - itemNode:getContentSize().height *0.4 + haveNum:getContentSize().height *0.5)

	local texts = {"详细信息","获取途径"}
	local colors = {cc.c3b(71,47,2),cc.c3b(71,47,2)}
	for i = 1, 2 do
		local normal = cc.Sprite:create("res/image/public/btn_normalSprite.png")
		normal:setContentSize(normal:getContentSize().width *0.6,normal:getContentSize().height *0.65)
		local selected = cc.Sprite:create("res/image/public/btn_selectedSprite.png")
		selected:setContentSize(selected:getContentSize().width *0.6,selected:getContentSize().height *0.65)
		local btn = XTHDPushButton:createWithParams({
			normalNode = normal,
			selectedNode = selected,
			text = texts[i],
			fontColor = colors[i],
		})
		self._bg:addChild(btn)
		btn:setPosition(32 + (i-1)*(btn:getContentSize().width + 20) + btn:getContentSize().width*0.5,self._bg:getContentSize().height *0.65 + btn:getContentSize().height*0.5 - 40)
		btn:setTouchEndedCallback(function()
			self:swichNode(i)
		end)
	end

	local showbg = cc.Sprite:create("res/image/plugin/warehouse/listviewbg.png")
	showbg:setContentSize(310,160)
	self._bg:addChild(showbg)
	showbg:setPosition(self._bg:getContentSize().width *0.5,showbg:getContentSize().height *0.5)
	self._showbg = showbg
	
	--展示道具详细信息的listview
	local itemInfoListView = ccui.ListView:create()
    itemInfoListView:setContentSize(showbg:getContentSize().width - 10,showbg:getContentSize().height - 10)
    itemInfoListView:setDirection(ccui.ScrollViewDir.vertical)
	itemInfoListView:setScrollBarEnabled(false)
    itemInfoListView:setBounceEnabled(true)
    itemInfoListView:setPosition(0,5)
	self._showbg:addChild(itemInfoListView)
	self._itemInfoListView = itemInfoListView

	--展示获取途径的listview
	local itemDorpListView = ccui.ListView:create()
    itemDorpListView:setContentSize(self._showbg:getContentSize().width - 10,self._showbg:getContentSize().height - 10)
    itemDorpListView:setDirection(ccui.ScrollViewDir.vertical)
	itemDorpListView:setScrollBarEnabled(false)
    itemDorpListView:setBounceEnabled(true)
    itemDorpListView:setPosition(0,5)
	self._showbg:addChild(itemDorpListView)
	self._itemDorpListView = itemDorpListView
	self._itemDorpListView:setVisible(false)
	
	self:setItemPropertyPart()
	self:initDropWayLayer()
	self:swichNode(1)
end

function XingNangShowNode:swichNode(index)
	if index == 1 then
		self._itemInfoListView:setVisible(true)
		self._itemDorpListView:setVisible(false)
	elseif index == 2 then
		self._itemInfoListView:setVisible(false)
		self._itemDorpListView:setVisible(true)
	end
end


--设置道具属性块
function XingNangShowNode:setItemPropertyPart()
    local _itemid = self._itemdata.itemid
    local _itemidData = self._itemDropData or {}
    if not self._itemInfoListView then
        return
    end
    self._itemInfoListView:removeAllChildren()
    --解析属性
    local _rowHeight = 29
    local _linewidth = self._itemInfoListView:getContentSize().width - 15
    --其他显示的是描述，装备显示的是属性
    if tonumber(self._itemdata.item_type) == 3 then  --装备
        local _currentPropertyData = XTHD.getEquipPropertyData(self._itemDropData.equipmentInfo or {})
        local _rowNum = #_currentPropertyData
        _rowNum = _rowNum>0 and _rowNum or 1
        for i=1,#_currentPropertyData do
            if i~=(#_currentPropertyData) then
                local _lineSpr = cc.Sprite:create("res/image/plugin/warehouse/warehouse_line.png")
                _lineSpr:setAnchorPoint(cc.p(0.5,0.5))
                _lineSpr:setScaleX(_linewidth/_lineSpr:getContentSize().width)
                _lineSpr:setPosition(cc.p(self._itemInfoListView:getContentSize().width/2,self._itemInfoListView:getContentSize().height - 2-_rowHeight*i))
                self._itemInfoListView:addChild(_lineSpr)
            end
            local _nameLabel = XTHDLabel:create(_currentPropertyData[i].name .. ":",16,"res/fonts/def.ttf")
            _nameLabel:setColor(cc.c3b(71,47,2)) 
            _nameLabel:setAnchorPoint(cc.p(0,0))
            _nameLabel:setPosition(cc.p(10,self._itemInfoListView:getContentSize().height - 2-_rowHeight*i+1))
            self._itemInfoListView:addChild(_nameLabel)
            --value
            local _valueStr = XTHD.resource.addPercent(_currentPropertyData[i].propertyNum,_currentPropertyData[i].propertyValue[1])
            if _currentPropertyData[i].propertyValue[2]~=nil then
                _valueStr = _valueStr .. " ~ " .. XTHD.resource.addPercent(_currentPropertyData[i].propertyNum,_currentPropertyData[i].propertyValue[2])
            end
            local _minValue = XTHDLabel:create(_valueStr,16,"res/fonts/def.ttf")
            _minValue:setColor(cc.c3b(71,47,2)) 
            _minValue:setAnchorPoint(cc.p(0,0))
            _minValue:setPosition(cc.p(_nameLabel:getContentSize().width + _nameLabel:getBoundingBox().x +5,_nameLabel:getPositionY()))
            self._itemInfoListView:addChild(_minValue)
        end
    else
        local _currentPropertyData = self._itemDropData.effect or ""
        local _propertyBgWidth = self._itemInfoListView:getContentSize().width
        local _propertyLabel = XTHDLabel:create(_currentPropertyData,16,"res/fonts/def.ttf")
        _propertyLabel:setColor(cc.c3b(71,47,2)) 
        _propertyLabel:setWidth(_propertyBgWidth-5*2)
        _propertyLabel:setLineBreakWithoutSpace(true)
        _propertyLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        local _labelHeight = _propertyLabel:getContentSize().height
        if _labelHeight<(_rowHeight*3+4-9) then
            _propertyLabel:setAnchorPoint(cc.p(0,1))
            _propertyLabel:setPosition(cc.p(10,self._itemInfoListView:getContentSize().height - 10))
        else
            _propertyLabel:setAnchorPoint(cc.p(0,1))
            _propertyLabel:setPosition(cc.p(10,self._itemInfoListView:getContentSize().height-15))
        end
        self._itemInfoListView:addChild(_propertyLabel)
    end
end

--获取碎片数据
function XingNangShowNode:setItemDropData()
    local _itemTable = gameData.getDataFromCSV("ArticleInfoSheet")
    self._itemDropData = {}
    for k,v in pairs(_itemTable) do
        if v.itemid == self._itemdata.itemid then
            self._itemDropData = v
            break
        end
    end
    if self._itemDropData.type and tonumber(self._itemDropData.type)==3 then
        local _euipmentTable = gameData.getDataFromCSV("EquipInfoList")
        for k,v in pairs(_euipmentTable) do
            if v.itemid == self._itemdata.itemid then
                self._itemDropData.equipmentInfo = v
                break
            end
        end
    end
end

--创建获得途径
function XingNangShowNode:initDropWayLayer()
    local _labelPosY = self._itemDorpListView:getContentSize().height-10-10 - 30/2
    local _dropwayCount = 0
    for i=1,3 do
        if self._itemDropData["instancingid" .. i] then
            local _dropWayItem = self:createDropWayItem(self._itemDropData["instancingid" .. i])
            if not _dropWayItem then
                break
            end
            local layout = ccui.Layout:create()
            layout:setContentSize(cc.size(self._showbg:getContentSize().width - 10,self._showbg:getContentSize().height/2.5))
            _dropWayItem:setAnchorPoint(cc.p(0.5,0.5))
			_dropWayItem:setSwallowTouches(false)
            layout:addChild(_dropWayItem)
            _dropWayItem:setPosition(layout:getContentSize().width/2 + 5,layout:getContentSize().height/2)
            _dropwayCount = _dropwayCount + 1
            self._itemDorpListView:pushBackCustomItem(layout)
            if i == 1 then 
                self._blockGoBtn = _dropWayItem
            end 
        end
    end
    if _dropwayCount == 0 then
        local _noneDrop_label = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.nonedropWayTextXc,16)
        _noneDrop_label:setColor(cc.c3b(54,18,8))
        _noneDrop_label:setAnchorPoint(cc.p(0.5,0.5))
        --无掉落途径，背景收缩
        _noneDrop_label:setPosition(cc.p(self._itemDorpListView:getContentSize().width/2,self._itemDorpListView:getContentSize().height/2))
        self._itemDorpListView:addChild(_noneDrop_label)
    end

    --添加刷新数量的监听
    XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_ITEMDROP_HASNUMBER,node = self,callback = function(event)
        self:refreshHasNumber()
    end})
end

--创建掉落途径的项目
function XingNangShowNode:createDropWayItem(_dropStr)--313,92
    --分析字符串
    local analyzeStr = string.split(_dropStr,'#')
    local _item = nil
    if #analyzeStr >1 then
        _item = self:copyDropWayItem(analyzeStr)
    else
        _item = self:otherDropWayItem(analyzeStr)
    end
    _item:setContentSize(_item:getContentSize().width,_item:getContentSize().height + 10)
    return _item
end

--其他跳转
function XingNangShowNode:otherDropWayItem(_analySizeTable)
    --背景
    local function toDropWay(_strData)
        local _data = self.systemNameTable[tostring(_strData._id)] or {}

        if self._layerid and tonumber(self._layerid)==tonumber(_strData._id) then
            return
        end
        local _functionId = _data and _data.functionid or 0
        local _type = nil
        local _fNode = self:getParent()
        local _zorder = self:getLocalZOrder()
        
        replaceLayer({
            fNode = _fNode,
            id = _strData._id,
            functionId = _functionId,
            chapterId = _strData._type,
            zorder = _zorder
        })
    end
    local _turnData = {}
    _turnData._id = _analySizeTable[1]
    _turnData._type = 0
    if tonumber(_analySizeTable[1])~=nil and tonumber(_analySizeTable[1])>1000 then
        _turnData._type = tonumber(_analySizeTable[1])%1000
        _turnData._id = math.floor(tonumber(_analySizeTable[1])/100)
    end
    
    local _btnNode = self:getBtnNode()
    local _background_Item = XTHDPushButton:createWithParams({
            normalNode = _btnNode[1]
            ,selectedNode = _btnNode[2]
			,needEnableWhenMoving = true
            ,endCallback = function()
                toDropWay(_turnData)
            end,
            needEnableWhenMoving = false
        })
    local _nameStr = nil
    if self.systemNameTable[tostring(_turnData._id)]~=nil and next(self.systemNameTable)~=nil then
        _nameStr = LANGUAGE_KEY_HERO_TEXT_chapterGoTextXc(self.systemNameTable[tostring(_turnData._id)].systemName)
        
    else
        _background_Item:setClickable(false)
        _nameStr = tostring(_turnData._id)
    end
    local _turnNameLabel = XTHDLabel:create(_nameStr,20)
    _turnNameLabel:setColor(cc.c3b(71,47,2))
    _turnNameLabel:setAnchorPoint(cc.p(0.5,0.5))
    _turnNameLabel:setPosition(cc.p(_background_Item:getContentSize().width/2,_background_Item:getContentSize().height/2))
    _background_Item:addChild(_turnNameLabel)
    
    return _background_Item
end

--副本跳转
function XingNangShowNode:copyDropWayItem(_analySizeTable)
    local _chapterInfo = self:getChapterType(_analySizeTable[2])

    local _itemInfoData = self:getDropWayItemInfoData(_analySizeTable)
    if not _itemInfoData then
        return nil
    end

    --背景
    local function toDropWay(_strTab)
        replaceLayer({
            id = _strTab[1],
            chapterId = _strTab[2],
        })
    end
    local _btnNode = self:getBtnNode()
    local _background_Item = XTHDPushButton:createWithParams({
            normalNode = _btnNode[1]
            ,selectedNode = _btnNode[2]
			,needEnableWhenMoving = true
            ,endCallback = function()
                toDropWay(_analySizeTable)
            end,
            needEnableWhenMoving = false
        })

    --章节图片
    if tonumber(_itemInfoData._bossHeroid)>0 then
        local _chapterImage = XTHD.createChapterIcon({
            _bossHeroid = tonumber(_itemInfoData._bossHeroid)
            ,_star = _itemInfoData._star
            })
        _chapterImage:setScale(0.6)
        _chapterImage:setAnchorPoint(cc.p(0.5,0.5))
        _chapterImage:setPosition(cc.p(50,_background_Item:getContentSize().height/2))
        _background_Item:addChild(_chapterImage)
    end
    
    local _item_spr = cc.Sprite:create("res/image/common/rhombusPoint.png")
    _item_spr:setAnchorPoint(cc.p(0.5,0.5))
    _item_spr:setPosition(cc.p(95 + _item_spr:getContentSize().width/2,_background_Item:getContentSize().height/3*2))
    _background_Item:addChild(_item_spr)

    --第几章
    local _chapterText = XTHDLabel:create(LANGUAGE_TIPS_chapterTextXc(_itemInfoData._chapters),16)
    _chapterText:setColor(cc.c3b(71,47,2))
    _chapterText:setAnchorPoint(cc.p(0,0.5))
    _chapterText:setPosition(cc.p(_item_spr:getBoundingBox().x + _item_spr:getBoundingBox().width + 5,_item_spr:getPositionY()))
    _background_Item:addChild(_chapterText)
    --章节类型精英还是普通
    local _chapterTypeText = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.chapterTypeTextXc[tonumber(_analySizeTable[1])],16)
    _chapterTypeText:setColor(cc.c3b(71,47,2))
    _chapterTypeText:setAnchorPoint(cc.p(0,0.5))
    _chapterTypeText:setPosition(cc.p(_chapterText:getContentSize().width + _chapterText:getPositionX()+5,_chapterText:getPositionY()))
    _background_Item:addChild(_chapterTypeText)
    --名字
    local _chapterNameText = XTHDLabel:create(_itemInfoData._name,16)
    _chapterNameText:setColor(cc.c3b(71,47,2))
    _chapterNameText:setAnchorPoint(cc.p(0,0.5))
    _chapterNameText:setPosition(cc.p(_item_spr:getBoundingBox().x,_background_Item:getContentSize().height/3*1))
    _background_Item:addChild(_chapterNameText)

    --精英被打过几次
    if _itemInfoData._isOpen then
        if tonumber(_analySizeTable[1])==2 then
            local _chapterTimes = XTHDLabel:create(_itemInfoData._num,16)  
            _chapterTimes:setColor(cc.c3b(71,47,2))
            _chapterTimes:setAnchorPoint(cc.p(0,0))  
            _chapterTimes:setPosition(cc.p(_chapterTypeText:getContentSize().width + _chapterTypeText:getPositionX()+5,_chapterTypeText:getPositionY()))
            _background_Item:addChild(_chapterTimes)
        end

    else
        self:setDropItemClose(_background_Item)
    end

    return _background_Item
end

--设置掉落途径未开启
function XingNangShowNode:setDropItemClose(_target)
    _target:setClickable(false)
    local _closeSpr = ccui.Scale9Sprite:create(cc.rect(6,5,1,1),"res/image/common/scale9_bg_14.png")
    _closeSpr:setContentSize(cc.size(313,60))
    _closeSpr:setPosition(cc.p(_target:getContentSize().width/2,_target:getContentSize().height/2 + 1))
    _target:addChild(_closeSpr)
    local _lock_sp = cc.Sprite:create("res/image/common/lock_sp.png")
    _lock_sp:setAnchorPoint(cc.p(0.5,0))
    _lock_sp:setPosition(cc.p(_target:getContentSize().width-60,_target:getContentSize().height/2-2))
    _target:addChild(_lock_sp)
    local _lockText_sp = cc.Sprite:create("res/image/common/noOpen_text.png")
    _lockText_sp:setAnchorPoint(cc.p(0.5,1))
    _lockText_sp:setPosition(cc.p(_lock_sp:getPositionX(),_lock_sp:getPositionY() - 5))
    _target:addChild(_lockText_sp)
end

--其他跳转
function XingNangShowNode:otherDropWayItem(_analySizeTable)
    --背景
    local function toDropWay(_strData)
        local _data = self.systemNameTable[tostring(_strData._id)] or {}

        if self._layerid and tonumber(self._layerid)==tonumber(_strData._id) then
            return
        end
        local _functionId = _data and _data.functionid or 0
        local _type = nil
        local _fNode = self:getParent()
        local _zorder = self:getLocalZOrder()
        replaceLayer({
            fNode = _fNode,
            id = _strData._id,
            functionId = _functionId,
            chapterId = _strData._type,
            zorder = _zorder
        })
    end
    local _turnData = {}
    _turnData._id = _analySizeTable[1]
    _turnData._type = 0
    if tonumber(_analySizeTable[1])~=nil and tonumber(_analySizeTable[1])>1000 then
        _turnData._type = tonumber(_analySizeTable[1])%1000
        _turnData._id = math.floor(tonumber(_analySizeTable[1])/100)
    end
    
    local _btnNode = self:getBtnNode()
    local _background_Item = XTHDPushButton:createWithParams({
            normalNode = _btnNode[1]
            ,selectedNode = _btnNode[2]
            ,endCallback = function()
                toDropWay(_turnData)
            end,
            needEnableWhenMoving = false
        })
    local _nameStr = nil
    if self.systemNameTable[tostring(_turnData._id)]~=nil and next(self.systemNameTable)~=nil then
        _nameStr = LANGUAGE_KEY_HERO_TEXT_chapterGoTextXc(self.systemNameTable[tostring(_turnData._id)].systemName)
        
    else
        _background_Item:setClickable(false)
        _nameStr = tostring(_turnData._id)
    end
    local _turnNameLabel = XTHDLabel:create(_nameStr,20)
    _turnNameLabel:setColor(cc.c3b(71,47,2))
    _turnNameLabel:setAnchorPoint(cc.p(0.5,0.5))
    _turnNameLabel:setPosition(cc.p(_background_Item:getContentSize().width/2,_background_Item:getContentSize().height/2))
    _background_Item:addChild(_turnNameLabel)

    return _background_Item
end

--获取掉落途径项目的数据
function XingNangShowNode:getDropWayItemInfoData(_dropStr)
    --icon路径
    --第几章
    --章节名
    --剩余次数和最大次数
    local _itemInfo = {}
    _itemInfo._chapters = 0
    _itemInfo._name = ""
    _itemInfo._num = ""
    _itemInfo._isOpen = false
    _itemInfo._bossHeroid = 0
    _itemInfo._star = 0

    local _tableNameStr = "stageInfo"
    local last_fight_time = 0
    local all_fight_time = 0
    if tonumber(_dropStr[1])==1 then --普通
        _tableNameStr = "stageInfo"
        -- _itemInfo._star = DBTableInstance.getStar(gameUser.getUserId(),tonumber(_dropStr[2]) )
        _itemInfo._star = CopiesData.GetNormalStar(tonumber(_dropStr[2])) 
    elseif tonumber(_dropStr[1]) ==2 then --精英
        _tableNameStr = "eliteStageInfo"
        -- _itemInfo._star = DBTableInstance.getEliteStar(gameUser.getUserId(),tonumber(_dropStr[2]) )
        _itemInfo._star =CopiesData.GetEliteStar(tonumber(_dropStr[2]))
        last_fight_time = gameData.getDataFromDynamicDB(gameUser.getUserId(),"eliteinstancing",{id=tonumber(_dropStr[2])})
        if last_fight_time and next(last_fight_time) then
            last_fight_time = last_fight_time and last_fight_time["last_fight_times"] or 0
            last_fight_time = last_fight_time > 0 and last_fight_time or 0
        else
            last_fight_time = 0
        end
        
    else
        return  nil
    end

    local _instanceTable =  self.stageData[_tableNameStr][tostring(_dropStr[2])] or {}
    _itemInfo._bossHeroid = tonumber(_instanceTable["bossid"]) or 1
    all_fight_time = _instanceTable["attacklimit"] or 0
    all_fight_time = all_fight_time > 0 and all_fight_time or 0
    if last_fight_time>0 and all_fight_time > 0 then
        _itemInfo._num = last_fight_time .. "/" .. all_fight_time 
    end
    _itemInfo._chapters = _instanceTable["chapterid"] or 0
    _itemInfo._name = _instanceTable["name"] or ""
    --目前已经开发的关卡
    local _instancingid = gameUser.getInstancingId()
    if tonumber(_dropStr[1]) == 2 then
        _instancingid = gameUser.getEliteInstancingId()
    end
    if _dropStr[2] and tonumber(_dropStr[2])<=tonumber(_instancingid) then
        _itemInfo._isOpen = true
    end
    return _itemInfo
end

--按钮节点
function XingNangShowNode:getBtnNode()
    local _btnNodeTable = {}
    local _normalSprite = ccui.Scale9Sprite:create("res/image/plugin/warehouse/xingnangshownormal.png")
	_normalSprite:setScaleX(0.8)
	_normalSprite:setScaleY(0.6)
    local _selectedSprite = ccui.Scale9Sprite:create("res/image/plugin/warehouse/xingnangshowselected.png")
	_selectedSprite:setScaleX(0.8)
	_selectedSprite:setScaleY(0.6)
    _btnNodeTable[1] = _normalSprite
    _btnNodeTable[2] = _selectedSprite
    return _btnNodeTable
end

--副本静态
function XingNangShowNode:setStaticStage()
    local _table1 = gameData.getDataFromCSV("ExploreInfoList") or {}
    self.stageData = {}
    self.stageData["stageInfo"] = {}
    for i=1,#_table1 do
        self.stageData["stageInfo"][tostring(_table1[i].instancingid)] = _table1[i]
    end
    self.stageData["eliteStageInfo"] = {}
    local _table2 = gameData.getDataFromCSV("EliteCopyList") or {}
    for i=1,#_table2 do
        self.stageData["eliteStageInfo"][tostring(_table2[i].instancingid)] = _table2[i]
    end
end

--返回普通或精英的信息
function XingNangShowNode:getChapterType(_str)
    local _chapterInfo = {}
    _chapterInfo._chapterLevel = tonumber(_str)
    if tonumber(_str)==1 then
        _chapterInfo._chapterType = ChapterType.Normal  -- 普通
    else
        _chapterInfo._chapterType = ChapterType.ELite --精英
    end
    return _chapterInfo
end

--跳转信息
function XingNangShowNode:setStaticSystemName()
    local _table = gameData.getDataFromCSV("MenubarId")
    self.systemNameTable = {}
    for i=1,#_table do
        self.systemNameTable[tostring(_table[i].id)] = _table[i]
    end
end

function XingNangShowNode:create(size,itemdata)
	return XingNangShowNode.new(size,itemdata)
end

return XingNangShowNode
