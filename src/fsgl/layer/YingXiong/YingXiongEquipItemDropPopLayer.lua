local YingXiongEquipItemDropPopLayer = class("YingXiongEquipItemDropPopLayer",function()
		return XTHDPopLayer:create()
	end)
requires("src/fsgl/staticdata/ShenbinggeDrop.lua")
function YingXiongEquipItemDropPopLayer:ctor(_partId)
	self._fontSize = 18
    self.partId = _partId or 0
	self.systemNameTable = {}
    self.stageInfoData = {}
    self.instanceChooseData = {}

	self:setStaticSystemName()
    self:setStaticStageInfo()
    self:setStaticChooseInstance()
	self:init()
end
function YingXiongEquipItemDropPopLayer:init()
    -- local _dropwayBgSprite = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_.png")
    local _dropwayBgSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
    _dropwayBgSprite:setContentSize(cc.size(350,446))
    local dropwayNode = XTHDPushButton:createWithParams({
                        normalNode = _dropwayBgSprite
                    })
    dropwayNode:setAnchorPoint(cc.p(0.5,0.5))
    dropwayNode:setTouchEndedCallback(function ()
        print("点到背景了")
    end)
    dropwayNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    dropwayNode:setCascadeOpacityEnabled(true)
    dropwayNode:setCascadeColorEnabled(true)
    self:getContainerLayer():addChild(dropwayNode,1)
    self.dropwayNode = dropwayNode


    local _itemId_ = 10011 + 100000*tonumber(self.partId)
    local item_sp = ItemNode:createWithParams({
        dbId = nil,
        itemId = _itemId_,
        _type_ = 4,
        touchShowTip = false,
        quality = 1
    })
    item_sp:setAnchorPoint(cc.p(0,1))
    item_sp:setPosition(cc.p( 18,dropwayNode:getContentSize().height - 10))
    dropwayNode:addChild(item_sp)
    --名称
    local label_name = XTHDLabel:create(XTHD.resource.getEquipName(tonumber(self.partId)), self._fontSize)
    label_name:setAnchorPoint(cc.p(0,1))
    label_name:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
    label_name:setColor(self:getTextColor())
    label_name:setPosition(cc.p(item_sp:getBoundingBox().x + item_sp:getBoundingBox().width +15,item_sp:getPositionY() - 12))
    dropwayNode:addChild(label_name)

    --掉落途径
    -- local dropwayItem_bg = ccui.Scale9Sprite:create(cc.rect(43,18,1,1),"res/image/common/shadow_bg.png")
    local dropwayItem_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
    dropwayItem_bg:setContentSize(cc.size(323,320))
    dropwayItem_bg:setAnchorPoint(0.5,0)
    dropwayItem_bg:setPosition(dropwayNode:getContentSize().width / 2 , 22)
    dropwayNode:addChild(dropwayItem_bg)

    local _labelPosY = dropwayItem_bg:getContentSize().height-10-92/2
    local _dropwayCount = 0
    local _systemId = {1,19,5}
    for i=1,3 do
        if _systemId[i] then
            local _dropWayItem = self:createDropWayItem(_systemId[i])
            if not _dropWayItem then
                break
            end
            _dropWayItem:setAnchorPoint(cc.p(0.5,0.5))
            _dropWayItem:setPosition(cc.p(dropwayItem_bg:getContentSize().width/2,_labelPosY-_dropwayCount*(9+92)))
            _dropwayCount = _dropwayCount + 1
            dropwayItem_bg:addChild(_dropWayItem)
        end
    end

    self:show()
end
function YingXiongEquipItemDropPopLayer:createDropWayItem(_systemId)
    if _systemId==nil then
        return
    end
    local _backItem = nil
    if tonumber(_systemId)~=1 then
        _backItem = self:otherDropWayItem(_systemId)
    else
        _backItem = self:copyDropWayItem()
    end
    return _backItem
end

function YingXiongEquipItemDropPopLayer:copyDropWayItem()
    local _chapterData = self:getDropWayItemInfoData()
    if not _chapterData then
        return nil
    end
    --背景
    local function toDropWay(_instancingid)
        replaceLayer({
            id = 1,
            chapterId = _instancingid,
        })
    end
    local _background_Item = XTHDPushButton:createWithParams({
            normalNode = self:getBtnNode("res/image/common/select_bg_10.png")
            ,selectedNode = self:getBtnNode("res/image/common/scale9_bg_13.png")
            ,endCallback = function()
                toDropWay(_chapterData._turnInstanceId)
            end
        })

    --章节图片
    if tonumber(_chapterData._bossHeroid)>0 then
        local _chapterImage = XTHD.createChapterIcon({
            _bossHeroid = tonumber(_chapterData._bossHeroid)
            ,_star = _chapterData._star
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
    local _chapterText = XTHDLabel:create(LANGUAGE_TIPS_chapterTextXc(_chapterData._chapters),self._fontSize)
    _chapterText:setColor(self:getTextColor())
    _chapterText:setAnchorPoint(cc.p(0,0.5))
    _chapterText:setPosition(cc.p(_item_spr:getBoundingBox().x + _item_spr:getBoundingBox().width + 5,_item_spr:getPositionY()))
    _background_Item:addChild(_chapterText)
    --章节类型精英还是普通
    local _chapterTypeText = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.chapterTypeTextXc[1],self._fontSize)
    _chapterTypeText:setColor(self:getTextColor())
    _chapterTypeText:setAnchorPoint(cc.p(0,0.5))
    _chapterTypeText:setPosition(cc.p(_chapterText:getContentSize().width + _chapterText:getPositionX()+5,_chapterText:getPositionY()))
    _background_Item:addChild(_chapterTypeText)
    --名字
    local _chapterNameText = XTHDLabel:create(_chapterData._name,self._fontSize)
    _chapterNameText:setColor(self:getTextColor())
    _chapterNameText:setAnchorPoint(cc.p(0,0.5))
    _chapterNameText:setPosition(cc.p(_item_spr:getBoundingBox().x,_background_Item:getContentSize().height/3*1))
    _background_Item:addChild(_chapterNameText)

    if _chapterData._isOpen == false then
        self:setDropItemClose(_background_Item)
    end
    return _background_Item
end

function YingXiongEquipItemDropPopLayer:otherDropWayItem(_systemId)
    --背景
    local function toDropWay(_id)
    	if tonumber(_systemId)==1 then
	        replaceLayer({id = 1})
	    else
	    	local _data = self.systemNameTable[tostring(_id)] or {}

	        local _functionId = _data and _data.functionid or 0
	        replaceLayer({
	            fNode = self:getParent(),
	            id = _id,
	            functionId = _functionId
	        })
    	end
        -- self:hidePop()
    end
    local _background_Item = XTHDPushButton:createWithParams({
            normalNode = self:getBtnNode("res/image/common/select_bg_10.png")
            ,selectedNode = self:getBtnNode("res/image/common/scale9_bg_13.png")
            ,endCallback = function()
                toDropWay(tonumber(_systemId))
            end
        })
    local _nameStr = nil
    if self.systemNameTable[tostring(_systemId)] and next(self.systemNameTable)~=nil then
        _nameStr = LANGUAGE_KEY_HERO_TEXT_chapterGoTextXc(self.systemNameTable[tostring(_systemId)].systemName)
    else
        _background_Item:setClickable(false)
        _nameStr = tostring(_systemId)
    end
    local _turnNameLabel = XTHDLabel:create(_nameStr,20)
    _turnNameLabel:setColor(self:getTextColor())
    _turnNameLabel:setAnchorPoint(cc.p(0.5,0.5))
    _turnNameLabel:setPosition(cc.p(_background_Item:getContentSize().width/2,_background_Item:getContentSize().height/2))
    _background_Item:addChild(_turnNameLabel)

    return _background_Item
end
--按钮节点
function YingXiongEquipItemDropPopLayer:getBtnNode(_path)
    -- local _node = ccui.Scale9Sprite:create(cc.rect(27,28,1,1),_path)
    local _node = ccui.Scale9Sprite:create(_path)
    _node:setContentSize(cc.size(300,92))
    return _node
end

--设置掉落途径未开启
function YingXiongEquipItemDropPopLayer:setDropItemClose(_target)
    _target:setClickable(false)
    local _closeSpr = ccui.Scale9Sprite:create(cc.rect(6,5,1,1),"res/image/common/scale9_bg_14.png")
    _closeSpr:setContentSize(cc.size(313,92))
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

--获取掉落途径项目的数据
function YingXiongEquipItemDropPopLayer:getDropWayItemInfoData()
    --icon路径
    --第几章
    --章节名
    --剩余次数和最大次数
    local _currentInstanceid = tonumber(gameUser.getInstancingId())
    local _itemInfo = {}
    _itemInfo._chapters = 0
    _itemInfo._turnInstanceId = 0
    _itemInfo._name = ""
    _itemInfo._isOpen = false
    _itemInfo._bossHeroid = 0
    _itemInfo._star = 0

    --如果比id1得关卡id小，就是id1的关卡id，如果比id1的大，id2的小，还是id1的关卡id。
    --只有循环的第一次，break后是跳转关卡是未开启的
    for i=1,14 do
        local _oldIndex = i-1
        if i<=1 then
            _oldIndex = 1
            _itemInfo._isOpen = false
        else
            _itemInfo._isOpen = true
        end
        local _oldturnId = tonumber(self.instanceChooseData[tostring("id" .. _oldIndex)] or 0)
        local _turnId = tonumber(self.instanceChooseData[tostring("id" .. i)] or 0)
        if _currentInstanceid<_turnId then
            _itemInfo._turnInstanceId = _oldturnId
            break
        end
    end

    _itemInfo._star = CopiesData.GetNormalStar(tonumber(_itemInfo._turnInstanceId))
    local _instanceTable =  self.stageInfoData[tonumber(_itemInfo._turnInstanceId)] or {}

    _itemInfo._bossHeroid = tonumber(_instanceTable["bossid"]) or 1
    _itemInfo._chapters = _instanceTable["chapterid"] or 0
    _itemInfo._name = _instanceTable["name"] or ""
    return _itemInfo
end

--跳转信息
function YingXiongEquipItemDropPopLayer:setStaticSystemName()
    local _table = gameData.getDataFromCSV("MenubarId")
    self.systemNameTable = {}
    for i=1,#_table do
        self.systemNameTable[tostring(_table[i].id)] = _table[i]
    end
end
--副本信息
function YingXiongEquipItemDropPopLayer:setStaticStageInfo()
    self.stageInfoData = {}
    self.stageInfoData = gameData.getDataFromCSV("ExploreInfoList") or {}
end
--副本关卡选择
function YingXiongEquipItemDropPopLayer:setStaticChooseInstance()
    self.instanceChooseData = {}
    local _table = ShenbinggeDrop or {}
    self.instanceChooseData = clone(_table[tonumber(self.partId)] or {})
end

--获取文字颜色
function YingXiongEquipItemDropPopLayer:getTextColor()
    local _color = cc.c4b(70,34,34,255)
    return _color
end
function YingXiongEquipItemDropPopLayer:create(_partId)
	local _layer = self.new(_partId)
	return _layer
end
return YingXiongEquipItemDropPopLayer