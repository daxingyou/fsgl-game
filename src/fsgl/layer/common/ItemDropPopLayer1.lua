local ItemDropPopLayer1 = class("ItemDropPopLayer1",function()
	return XTHDPopLayer:create()
	end)

function ItemDropPopLayer1:ctor(_itemid,_layerid,dropType)
	self._itemDropData = {}
	self._itemId = tonumber(_itemid)
    self.systemNameTable = nil  --跳转地名称
    self.itemdynamicData = {}
    self.stageData = {}         --副本静态数据
    self._layerid = _layerid or nil
	self._dropType = dropType
	self:setItemDropData()
    self:setStaticSystemName()
    self:setItemDynamicData()
    self:setStaticStage()

    self.dropwayNode = nil
    self.getDropWayBtn = nil    --掉落途径按钮
    self.setHideBtn = nil
    self.property_bg = nil      --属性
    self._fontSize = 18

	self:init()
end

function ItemDropPopLayer1:init()
    
    local _popBgSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
    _popBgSprite:setContentSize(cc.size(370,370))
	local popNode = XTHDPushButton:createWithParams({
                        normalNode = _popBgSprite
                    })
    popNode:setAnchorPoint(cc.p(1,0.5))
    popNode:setTouchEndedCallback(function ()
        print("点到背景了")
    end)
    popNode:setScale(0.8)
    popNode:setPosition(self:getContentSize().width / 2+ popNode:getContentSize().width/2,self:getContentSize().height / 2)
    popNode:setCascadeOpacityEnabled(true)
    popNode:setCascadeColorEnabled(true)
    self:getContainerLayer():addChild(popNode,2)
    self.popNode = popNode
    --掉落途径按钮
    self.getDropWayBtn = self:createDropWayBtn()
    self.getDropWayBtn:setAnchorPoint(cc.p(0.5,0.5))
    self.getDropWayBtn:setPosition(cc.p(popNode:getContentSize().width/2,18 + self.getDropWayBtn:getContentSize().height/2))
    popNode:addChild(self.getDropWayBtn)
	self.getDropWayBtn:setVisible(false)

    self.setHideBtn = self:createDropWayBtn("hide")
    self.setHideBtn:setAnchorPoint(cc.p(0.5,0.5))
    self.setHideBtn:setPosition(cc.p(self.getDropWayBtn:getPositionX(),self.getDropWayBtn:getPositionY()))
    popNode:addChild(self.setHideBtn)
    self.setHideBtn:setVisible(false)
    self.setHideBtn:setClickable(false)

    --道具头像
    local _itemSprite = ItemNode:createWithParams({
        dbId = nil,
        itemId = self._itemId,
        _type_ = 4,
        touchShowTip = false,
        isShowDrop = false,
        quality = self._itemDropData.rank
    })
    _itemSprite:setAnchorPoint(cc.p(0,1))
    _itemSprite:setPosition(cc.p(10,popNode:getContentSize().height - 10))
    popNode:addChild(_itemSprite)

    --名称
    local _nameLabel = XTHDLabel:create(self._itemDropData.name,self._fontSize,"res/fonts/def.ttf")
    _nameLabel:setColor(cc.c3b(89,64,63))
    _nameLabel:setAnchorPoint(cc.p(0,1))
    _nameLabel:setPosition(cc.p(_itemSprite:getBoundingBox().x + _itemSprite:getBoundingBox().width + 5,_itemSprite:getPositionY() -5))
    popNode:addChild(_nameLabel)
    --拥有件数
    local _hadNumTitleLabel = XTHDLabel:create("( "..LANGUAGE_VERBS.owned..":"..self.itemdynamicData.count.."件 )",self._fontSize)----拥有:"
    _hadNumTitleLabel:setColor(cc.c3b(89,64,63))
    _hadNumTitleLabel:setAnchorPoint(cc.p(0,0.5))
    _hadNumTitleLabel:setPosition(cc.p(_nameLabel:getPositionX(),_itemSprite:getBoundingBox().y + _itemSprite:getBoundingBox().height/2 + 10))
    popNode:addChild(_hadNumTitleLabel)
  
	local line = cc.Sprite:create("res/image/public/line.png")
	popNode:addChild(line)
	line:setScale(0.7)
	line:setAnchorPoint(0,0.5)
	line:setPosition(popNode:getContentSize().width *0.25 + 20,_itemSprite:getPositionY() - _itemSprite:getContentSize().height + 20)

	local showbg = cc.Sprite:create("res/image/public/Dropbg.png")
	showbg:setContentSize(340,150)
	popNode:addChild(showbg)
	showbg:setPosition(popNode:getContentSize().width *0.5,showbg:getContentSize().height *0.5 +50)
	self._showbg = showbg

    if self._itemDropData.type and tonumber(self._itemDropData.type)==3 and self._itemDropData.equipmentInfo and next(self._itemDropData.equipmentInfo)~=nil then
        --限制
        local _useTypeTitle = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.itemHeroTypeTextXc,self._fontSize)
        _useTypeTitle:setColor(self:getTextColor())
        _useTypeTitle:setAnchorPoint(cc.p(0,1))
        _useTypeTitle:setPosition(cc.p(_hadNumTitleLabel:getPositionX(),_hadNumTitleLabel:getPositionY() - _hadNumTitleLabel:getContentSize().height +5))
        popNode:addChild(_useTypeTitle)

        local _herotypeTable = string.split(self._itemDropData.equipmentInfo["herotype"],'#')

        local _heroTypeCount = 0
        for i=1,#_herotypeTable do
            local _heroType_spr = cc.Sprite:create(XTHD.resource.getHeroTypeImgPath(tonumber(_herotypeTable[i])))
            _heroType_spr:setAnchorPoint(cc.p(0,0.5))
			_heroType_spr:setScale(0.8)
            _heroType_spr:setPosition(cc.p(_useTypeTitle:getPositionX()+_useTypeTitle:getContentSize().width+_heroTypeCount*(3+_heroType_spr:getContentSize().width)+3,_useTypeTitle:getBoundingBox().y + _useTypeTitle:getBoundingBox().height/2))
            _heroTypeCount = _heroTypeCount + 1 
            popNode:addChild(_heroType_spr)
        end
    end
	--展示道具详细信息的listview
	local itemInfoListView = ccui.ListView:create()
    itemInfoListView:setContentSize(showbg:getContentSize().width - 10,showbg:getContentSize().height - 10)
    itemInfoListView:setDirection(ccui.ScrollViewDir.vertical)
	itemInfoListView:setScrollBarEnabled(false)
    itemInfoListView:setBounceEnabled(true)
    itemInfoListView:setPosition(0,5)
	showbg:addChild(itemInfoListView)
	self._itemInfoListView = itemInfoListView

    self:setItemPropertyPart()
    self:initDropWayLayer()
	
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
		popNode:addChild(btn)
		btn:setPosition(30 + (i-1)*(btn:getContentSize().width + 20) + btn:getContentSize().width*0.5,popNode:getContentSize().height *0.65 + btn:getContentSize().height*0.5 - 25)
		btn:setTouchEndedCallback(function()
			self:swichNode(i)
		end)
	end
	self:swichNode(1)
    self:show()
end

function ItemDropPopLayer1:swichNode(_index)
	if _index == 1 then
		self._itemInfoListView:setVisible(true)
		self._itemDorpListView:setVisible(false)
	elseif _index == 2 then
		self._itemInfoListView:setVisible(false)
		self._itemDorpListView:setVisible(true)
	end
end

--创建获得途径
function ItemDropPopLayer1:initDropWayLayer()
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

    local _labelPosY = self._itemDorpListView:getContentSize().height-10-10 - 30/2
    local _dropwayCount = 0
    for i=1,3 do
        if self._itemDropData["instancingid" .. i] then
            local _dropWayItem = self:createDropWayItem(self._itemDropData["instancingid" .. i])
            if not _dropWayItem then
                break
            end
            local layout = ccui.Layout:create()
            layout:setContentSize(cc.size(self._showbg:getContentSize().width - 10,self._showbg:getContentSize().height/2))
            _dropWayItem:setAnchorPoint(cc.p(0.5,0.5))
   --          _dropWayItem:setPosition(cc.p(self._itemDorpListView:getContentSize().width/2,_labelPosY-_dropwayCount*(9+58)))
			_dropWayItem:setSwallowTouches(false)
            layout:addChild(_dropWayItem)
            _dropWayItem:setPosition(layout:getContentSize().width/2,layout:getContentSize().height/2)
            _dropwayCount = _dropwayCount + 1
            -- self._itemDorpListView:addChild(_dropWayItem)
            self._itemDorpListView:pushBackCustomItem(layout)
            if i == 1 then 
                self._blockGoBtn = _dropWayItem
            end 
        end
    end
    if _dropwayCount == 0 then
        local _noneDrop_label = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.nonedropWayTextXc,30)
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
--设置道具属性块
function ItemDropPopLayer1:setItemPropertyPart()
    local _itemid = self._itemId
    local _itemidData = self._itemDropData or {}
    if not self._itemInfoListView then
        return
    end
    self._itemInfoListView:removeAllChildren()
    --解析属性
    local _rowHeight = 29
    local _linewidth = self._itemInfoListView:getContentSize().width - 15
    --其他显示的是描述，装备显示的是属性
    if tonumber(self._itemDropData.type) ==3 then  --装备
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
            local _nameLabel = XTHDLabel:create(_currentPropertyData[i].name .. ":",self._fontSize,"res/fonts/def.ttf")
            _nameLabel:setColor(self:getTextColor()) 
            _nameLabel:setAnchorPoint(cc.p(0,0))
            _nameLabel:setPosition(cc.p(10,self._itemInfoListView:getContentSize().height - 2-_rowHeight*i+1))
            self._itemInfoListView:addChild(_nameLabel)
            --value
            local _valueStr = XTHD.resource.addPercent(_currentPropertyData[i].propertyNum,_currentPropertyData[i].propertyValue[1])
            if _currentPropertyData[i].propertyValue[2]~=nil then
                _valueStr = _valueStr .. " ~ " .. XTHD.resource.addPercent(_currentPropertyData[i].propertyNum,_currentPropertyData[i].propertyValue[2])
            end
            local _minValue = XTHDLabel:create(_valueStr,self._fontSize,"res/fonts/def.ttf")
            _minValue:setColor(self:getTextColor()) 
            _minValue:setAnchorPoint(cc.p(0,0))
            _minValue:setPosition(cc.p(_nameLabel:getContentSize().width + _nameLabel:getBoundingBox().x +5,_nameLabel:getPositionY()))
            self._itemInfoListView:addChild(_minValue)
        end
    else
        local _currentPropertyData = self._itemDropData.effect or ""
        local _propertyBgWidth = self._itemInfoListView:getContentSize().width
        local _propertyLabel = XTHDLabel:create(_currentPropertyData,self._fontSize,"res/fonts/def.ttf")
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

function ItemDropPopLayer1:createDropWayBtn(_type)
    -- local _textpath = "res/image/common/dropwayBtn_text.png"
    local _btnText = LANGUAGE_BTN_KEY.getWay
    local _callback = function()
        if self.setHideBtn~= nil then
            self.setHideBtn:setVisible(true)
            self.setHideBtn:setClickable(false)
            if self.getDropWayBtn~=nil then
                self.getDropWayBtn:setVisible(false)
                self.getDropWayBtn:setClickable(false)
            end
        end
        self:showDropWayLayer()
    end
    if _type~=nil and _type =="hide" then
        -- _textpath = "res/image/common/hidedropwayBtn_text.png"
        _btnText = LANGUAGE_BTN_KEY.packUp
        _callback = function()
            if self.getDropWayBtn~=nil then
                self.getDropWayBtn:setVisible(true)
                self.getDropWayBtn:setClickable(false)
                if self.setHideBtn~= nil then
                    self.setHideBtn:setVisible(false)
                    self.setHideBtn:setClickable(false)
                end
            end
            self:hideDropWayLayer()
        end
    end
    local _btnSize = cc.size(150,46)
    local _btn = XTHD.createCommonButton({
            btnColor = "write_1"
            ,
            isScrollView = false,
            touchSize = _btnSize
            ,btnSize = _btnSize
            ,text = _btnText,
            fontColor = cc.c3b(255,255,255)
            -- ,label = XTHDLabel:create(_btnText,20)
        })
        _btn:setScale(0.7)
    _btn:setTouchEndedCallback(function()
        _callback()
        end)
    return _btn
end

--创建掉落途径的项目
function ItemDropPopLayer1:createDropWayItem(_dropStr)--313,92
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

--副本跳转
function ItemDropPopLayer1:copyDropWayItem(_analySizeTable)
    local _chapterInfo = self:getChapterType(_analySizeTable[2])

    local _itemInfoData = self:getDropWayItemInfoData(_analySizeTable)
    if not _itemInfoData then
        return nil
    end

    --背景
    local function toDropWay(_strTab)
        self:removeFromParent()
        replaceLayer({
            id = _strTab[1],
            chapterId = _strTab[2],
        })
    end
    local _btnNode = self:getBtnNode()
    local _background_Item = XTHDPushButton:createWithParams({
            normalNode = _btnNode[1]
            ,selectedNode = _btnNode[2]
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
    _item_spr:setPosition(cc.p(105 + _item_spr:getContentSize().width/2,_background_Item:getContentSize().height/3*2))
    _background_Item:addChild(_item_spr)

    --第几章
    local _chapterText = XTHDLabel:create(LANGUAGE_TIPS_chapterTextXc(_itemInfoData._chapters),self._fontSize)
    _chapterText:setColor(self:getTextColor())
    _chapterText:setAnchorPoint(cc.p(0,0.5))
    _chapterText:setPosition(cc.p(_item_spr:getBoundingBox().x + _item_spr:getBoundingBox().width + 5,_item_spr:getPositionY()))
    _background_Item:addChild(_chapterText)
    --章节类型精英还是普通
    local _chapterTypeText = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.chapterTypeTextXc[tonumber(_analySizeTable[1])],self._fontSize)
    _chapterTypeText:setColor(self:getTextColor())
    _chapterTypeText:setAnchorPoint(cc.p(0,0.5))
    _chapterTypeText:setPosition(cc.p(_chapterText:getContentSize().width + _chapterText:getPositionX()+5,_chapterText:getPositionY()))
    _background_Item:addChild(_chapterTypeText)
    --名字
    local _chapterNameText = XTHDLabel:create(_itemInfoData._name,self._fontSize)
    _chapterNameText:setColor(self:getTextColor())
    _chapterNameText:setAnchorPoint(cc.p(0,0.5))
    _chapterNameText:setPosition(cc.p(_item_spr:getBoundingBox().x,_background_Item:getContentSize().height/3*1))
    _background_Item:addChild(_chapterNameText)

    --精英被打过几次
    if _itemInfoData._isOpen then
        if tonumber(_analySizeTable[1])==2 then
            local _chapterTimes = XTHDLabel:create(_itemInfoData._num,self._fontSize)  
            _chapterTimes:setColor(self:getTextColor())
            _chapterTimes:setAnchorPoint(cc.p(0,0))  
            _chapterTimes:setPosition(cc.p(_chapterTypeText:getContentSize().width + _chapterTypeText:getPositionX()+5,_chapterTypeText:getPositionY()))
            _background_Item:addChild(_chapterTimes)
        end

    else
        self:setDropItemClose(_background_Item)
    end

    return _background_Item
end
--其他跳转
function ItemDropPopLayer1:otherDropWayItem(_analySizeTable)
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
        self:removeFromParent()
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
				if self._dropType == 1 then
					LayerManager.removeLayoutToDefult( )
				else
					if LayerManager.getCurLay() then
						print("获取到当前图层")
						if LayerManager.getCurLay():getChildByName("Poplayer") then
							LayerManager.getCurLay():getChildByName("Poplayer"):removeFromParent()
						end
					end
					if cc.Director:getInstance():getRunningScene():getChildByName("Poplayer") then
						cc.Director:getInstance():getRunningScene():getChildByName("Poplayer"):hide()
					end
					LayerManager.removeLayoutToDefult( )
				end
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
    _turnNameLabel:setColor(self:getTextColor())
    _turnNameLabel:setAnchorPoint(cc.p(0.5,0.5))
    _turnNameLabel:setPosition(cc.p(_background_Item:getContentSize().width/2,_background_Item:getContentSize().height/2))
    _background_Item:addChild(_turnNameLabel)

    -- local _level = tonumber(gameUser.getLevel())
    -- local _levelFloor = self.systemNameTable[tostring(_analySizeTable[1])] or {}
    -- _levelFloor = _levelFloor.level and tonumber(_levelFloor.level) or 0
    -- if _level < _levelFloor then
    --     self:setDropItemClose(_background_Item)
    --     return
    -- end
    
    return _background_Item
end
--按钮节点
function ItemDropPopLayer1:getBtnNode()
    local _btnNodeTable = {}
    local _normalSprite = ccui.Scale9Sprite:create("res/image/public/huoqutujingbg1.png")
	_normalSprite:setScaleY(0.8)
    local _selectedSprite = ccui.Scale9Sprite:create("res/image/public/huoqutujingbg2.png")
	_selectedSprite:setScaleY(0.8)
    _btnNodeTable[1] = _normalSprite
    _btnNodeTable[2] = _selectedSprite
    return _btnNodeTable
end

--设置掉落途径未开启
function ItemDropPopLayer1:setDropItemClose(_target)
    _target:setClickable(false)
    local _closeSpr = ccui.Scale9Sprite:create(cc.rect(6,5,1,1),"res/image/common/scale9_bg_14.png")
    _closeSpr:setContentSize(cc.size(313,82))
    _closeSpr:setPosition(cc.p(_target:getContentSize().width/2,_target:getContentSize().height/2))
    _target:addChild(_closeSpr)
    local _lock_sp = cc.Sprite:create("res/image/common/lock_sp.png")
    _lock_sp:setAnchorPoint(cc.p(0.5,0))
    _lock_sp:setPosition(cc.p(_target:getContentSize().width-40,_target:getContentSize().height/2-2))
    _target:addChild(_lock_sp)
    local _lockText_sp = cc.Sprite:create("res/image/common/noOpen_text.png")
    _lockText_sp:setAnchorPoint(cc.p(0.5,1))
    _lockText_sp:setPosition(cc.p(_lock_sp:getPositionX(),_lock_sp:getPositionY() - 5))
    _target:addChild(_lockText_sp)
end

--返回普通或精英的信息
function ItemDropPopLayer1:getChapterType(_str)
    local _chapterInfo = {}
    _chapterInfo._chapterLevel = tonumber(_str)
    if tonumber(_str)==1 then
        _chapterInfo._chapterType = ChapterType.Normal  -- 普通
    else
        _chapterInfo._chapterType = ChapterType.ELite --精英
    end
    return _chapterInfo
end
--获取掉落途径项目的数据
function ItemDropPopLayer1:getDropWayItemInfoData(_dropStr)
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

--刷新拥有数量
function ItemDropPopLayer1:refreshHasNumber()
    self:setItemDynamicData()
    if self.popNode:getChildByName("hadNumberlabel") then
        local _hadNumberlabel = self.popNode:getChildByName("hadNumberlabel")
        _hadNumberlabel:setString(self.itemdynamicData.count or 0)
        if self.popNode:getChildByName("jianlabel") then
            self.popNode:getChildByName("jianlabel"):setPositionX(_hadNumberlabel:getBoundingBox().x + _hadNumberlabel:getBoundingBox().width+3)
        end
    end
end
-------------------动画Began-------------------
function ItemDropPopLayer1:showDropWayLayer()
    if self.popNode ==nil then
        return
    end
    if self.dropwayNode==nil then
        self:initDropWayLayer()
    end
    self.dropwayNode:runAction(cc.Sequence:create(cc.CallFunc:create(function()
        self.dropwayNode:setVisible(true)
        end),cc.MoveBy:create(0.2,cc.p(350/2+3,0)),cc.CallFunc:create(function()
        self.dropwayNode:setVisible(true)
        self.setHideBtn:setVisible(true)
        self.setHideBtn:setClickable(true)
        end) ))
    self.popNode:runAction(cc.MoveBy:create(0.2,cc.p(-350/2-3,0)))

end
function ItemDropPopLayer1:hideDropWayLayer()
    if self.popNode ==nil then
        return
    end
    if self.dropwayNode~=nil then
        self.dropwayNode:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                self.dropwayNode:setVisible(true)
            end) ,cc.MoveBy:create(0.2,cc.p(-350/2-3,0)),
            cc.CallFunc:create(function()
                self.dropwayNode:setVisible(false)
                self.getDropWayBtn:setVisible(true)
                self.getDropWayBtn:setClickable(true)
                end)))
        self.popNode:runAction(cc.MoveBy:create(0.2,cc.p(350/2+3,0)))
    end
end

-------------------动画End-------------------

-------------------关于数据Began-------------------
--获取当前道具的动态数据库信息

--获取碎片数据
function ItemDropPopLayer1:setItemDropData()
    local _itemTable = gameData.getDataFromCSV("ArticleInfoSheet")
    self._itemDropData = {}
    for k,v in pairs(_itemTable) do
        if v.itemid == self._itemId then
            self._itemDropData = v
            break
        end
    end
    if self._itemDropData.type and tonumber(self._itemDropData.type)==3 then
        local _euipmentTable = gameData.getDataFromCSV("EquipInfoList")
        for k,v in pairs(_euipmentTable) do
            if v.itemid == self._itemId then
                self._itemDropData.equipmentInfo = v
                break
            end
        end
    end
end

--跳转信息
function ItemDropPopLayer1:setStaticSystemName()
    local _table = gameData.getDataFromCSV("MenubarId")
    self.systemNameTable = {}
    for i=1,#_table do
        self.systemNameTable[tostring(_table[i].id)] = _table[i]
    end
end

function ItemDropPopLayer1:setItemDynamicData()
    self.itemdynamicData = {}
    local _table = DBTableItem.getData(gameUser.getUserId(),{itemid = self._itemId}) or {}
    if _table and next(_table)~=nil and #_table <1 then
        self.itemdynamicData = _table
    else
        self.itemdynamicData = _table[1] or {}
        local _countNum = #_table
        _countNum = _countNum>0 and _countNum or 0
        self.itemdynamicData.count = _countNum
    end
end

--副本静态
function ItemDropPopLayer1:setStaticStage()
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


-------------------关于数据Ended-------------------

--获取文字颜色
function ItemDropPopLayer1:getTextColor()
    local _color = cc.c3b(77,54,12)
    return _color
end

--传入itemid
--_layerid是当前的界面的id，这个id根据界面跳转的id设定。目前是为了避免，从合成再次跳到合成
function ItemDropPopLayer1:create(_itemid,_layerid,dropType)
	local _layer = self.new(_itemid,_layerid,dropType)

	return _layer
end

return ItemDropPopLayer1