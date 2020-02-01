--以下英雄未拥有 255,210,80
local ChaKanOtherInternalLayer = class("ChaKanOtherInternalLayer", function()
	-- local select_sp = XTHDSprite:create("res/image/plugin/hero/baseInfo_bg.png")
    local select_sp = XTHD.createFunctionLayer()
    return select_sp
end)

function ChaKanOtherInternalLayer:ctor(params)
    if params._contentSize ~=nil then
        self:setTextureRect(cc.rect(0,0,params._contentSize.width,params._contentSize.height))
    end
    self:setOpacity(0)
    self._fontSize = 18
    self.internalStrengthStaticData = {}
    self.internalData = {}

    self.property_scrollView = nil

    self.propertyNumberKey = {200,201,202,203,204,301,302,303,306,309}
    self:setInternalData(params._data)
    self:setInternalStrengthData(params._data.id)

    self:init()
end

function ChaKanOtherInternalLayer:init()
    local _herotitleBg_path = "res/image/plugin/hero/heroTitle_bg.png"
    --[[英雄介绍]]
    local _internalLevel = 0
    for i=1,#self.internalData do
        _internalLevel = _internalLevel + tonumber(self.internalData[i])
    end
    local _titleStr = LANGUAGE_KEY_TITLENAME_internalLevelTitleTextXc(_internalLevel)
    local _heroPropertyTitle_bg = cc.Sprite:create(_herotitleBg_path)
    _heroPropertyTitle_bg:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height - 20 - _heroPropertyTitle_bg:getContentSize().height/2 + 20))
    self:addChild(_heroPropertyTitle_bg)

    local _heroPropertyTitle_label = XTHDLabel:create(_titleStr,self._fontSize)
    _heroPropertyTitle_label:enableShadow(self:getTextColor("shenhese"),cc.size(0.4,-0.4),1)
    _heroPropertyTitle_label:setColor(self:getTextColor("shenhese"))
    _heroPropertyTitle_label:setPosition(cc.p(_heroPropertyTitle_bg:getContentSize().width/2,_heroPropertyTitle_bg:getContentSize().height/2))
    _heroPropertyTitle_bg:addChild(_heroPropertyTitle_label)
    --属性值
    -- local _propertyHeight = 37*10 + 4
    -- local property_bg = ccui.Scale9Sprite:create(cc.rect(10,10,10,10),"res/image/common/scale9_bg_5.png")
    -- property_bg:setContentSize(cc.size(326,_propertyBgHeright))
    -- property_bg:setCascadeOpacityEnabled(true)
    -- property_bg:setCascadeColorEnabled(true)
    -- property_bg:setAnchorPoint(0.5,0)
    -- property_bg:setPosition(self:getContentSize().width/2,15)
    -- self:addChild(property_bg)

    -- self.property_scrollView = ccui.ScrollView:create()
    -- -- self.property_scrollView:setBounceEnabled(true)
    -- self.property_scrollView:setDirection(ccui.ScrollViewDir.vertical)
    -- self.property_scrollView:setTouchEnabled(true)
    -- self.property_scrollView:setContentSize(cc.size(326,_propertyBgHeright))
    -- self.property_scrollView:setInnerContainerSize(cc.size(326,_propertyHeight))
    -- self.property_scrollView:setPosition(self:getContentSize().width/2 -326/2 ,0)
    -- self:addChild(self.property_scrollView)

    -- self:setPropertyPart()

    local _downPosY = 5
    local _propertyHeight = _heroPropertyTitle_bg:getBoundingBox().y - 5 -5
    local _contentWidth = self:getContentSize().width 
    local _lineWidth = 300
    local _downLine = ccui.Scale9Sprite:create(cc.rect(130,0,140,4),"res/image/common/common_split_line.png")
    _downLine:setContentSize(cc.size(_lineWidth,2))
    _downLine:setPosition(cc.p(self:getContentSize().width/2,_downPosY-1))
    self:addChild(_downLine)

    local _downShade = ccui.Scale9Sprite:create(cc.rect(28,0,2,15),"res/image/common/common_scale_shade.png")
    _downShade:setContentSize(cc.size(_lineWidth,15))
    _downShade:setAnchorPoint(cc.p(0.5,0))
    _downShade:setPosition(cc.p(self:getContentSize().width/2,_downPosY-2))
    self:addChild(_downShade)
    _downShade:setVisible(false)

    local _tableViewCellSize = cc.size(_contentWidth,28)
    self._tableView = CCTableView:create(cc.size(_contentWidth,_propertyHeight))
    self._tableView:setPosition(cc.p(0,_downPosY))
    self._tableView:setBounceable(true)
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._tableView:setDelegate()
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self._tableView)

    local function cellSizeForTable(table,idx)
        return _tableViewCellSize.width,_tableViewCellSize.height
    end

    local function numberOfCellsInTableView(table)
        return #self.propertyNumberKey
    end

    local function scrollViewDidScroll(view)
        local offset = self._tableView:getContentOffset().y
        if offset < 0 then
            _downShade:setVisible(true)
        else
            _downShade:setVisible(false)
        end
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
        end
        local _index = idx + 1
        local _propertyKey = XTHD.resource.AttributesName[tonumber(self.propertyNumberKey[_index])]
        local _propertyName = LANGUAGE_KEY_ATTRIBUTESNAME(tostring(self.propertyNumberKey[_index])) or ""
        local _propertyValue = tonumber(self.internalStrengthStaticData["add" .. _propertyKey] or 0) *tonumber(self.internalData[_index])

        local info_label_name = XTHDLabel:create(_propertyName .. ":",self._fontSize)
        info_label_name:setColor(self:getTextColor("shenhese"))
        info_label_name:setAnchorPoint(1,0.5)
        info_label_name:setPosition(_tableViewCellSize.width/2+5,_tableViewCellSize.height/2)
        cell:addChild(info_label_name)
        if tonumber(self.propertyNumberKey[_index]) < 205 then
            info_label_name:setColor(self:getTextColor("chenghongse"))
        end

        local current_info_number = XTHDLabel:create("+" .. _propertyValue .. "%", self._fontSize)
        current_info_number:setColor(self:getTextColor("lvse"))
        current_info_number:setAnchorPoint(0,0.5)
        current_info_number:setPosition(cc.p(info_label_name:getBoundingBox().x+info_label_name:getBoundingBox().width+20,_tableViewCellSize.height/2))
        cell:addChild(current_info_number)

        return cell
    end

    self._tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:reloadData()

    if tonumber(self._tableView:getContentOffset().y)<0 then
        _downShade:setVisible(true)
    end
end

-- function ChaKanOtherInternalLayer:setPropertyPart()
--     if self.internalData ==nil or next(self.internalData) ==nil then
--         return
--     end
--     local _innerHeight = self.property_scrollView:getInnerContainerSize().height
--     self.property_scrollView:setInnerContainerSize(cc.size(326,_innerHeight))
--     local _rowHeight = 37
--     local _propertyOrder = 0
--     for i=1,#self.propertyNumberKey do
--         _propertyOrder = _propertyOrder + 1
--         if i~=#self.propertyNumberKey then
--             local _lineSpr = ccui.Scale9Sprite:create(cc.rect(5,0,1,1),"res/image/common/scale_line.png")
--             _lineSpr:setContentSize(cc.size(self.property_scrollView:getContentSize().width-4,1))
--             _lineSpr:setName("lineSpr")
--             _lineSpr:setPosition(cc.p(self.property_scrollView:getContentSize().width/2,_innerHeight - 2-_rowHeight*_propertyOrder))
--             self.property_scrollView:addChild(_lineSpr)
--         end
--         local _propertyKey = XTHD.resource.AttributesName[tonumber(self.propertyNumberKey[i])]
--         local _propertyName = LANGUAGE_KEY_ATTRIBUTESNAME(tostring(self.propertyNumberKey[i])) or ""
--         local _propertyValue = tonumber(self.internalStrengthStaticData["add" .. _propertyKey] or 0) *tonumber(self.internalData[i])

--         local info_label_name = XTHDLabel:create(_propertyName .. ":",self._fontSize)
--         info_label_name:setColor(self:getTextColor("shenhese"))
--         info_label_name:setAnchorPoint(0,0.5)
--         info_label_name:setPosition(20,_innerHeight - 2-_rowHeight*i +18)
--         self.property_scrollView:addChild(info_label_name)
--         if tonumber(self.propertyNumberKey[i]) < 205 then
--             info_label_name:setColor(self:getTextColor("chenghongse"))
--         end

--         local current_info_number = XTHDLabel:create("+" .. _propertyValue .. "%", self._fontSize)
--         current_info_number:setColor(self:getTextColor("lvse"))
--         current_info_number:setAnchorPoint(0,0.5)
--         current_info_number:setPosition(cc.p(110,info_label_name:getPositionY()))
--         self.property_scrollView:addChild(current_info_number)
--     end
-- end
function ChaKanOtherInternalLayer:setInternalData(_data)
    if _data ==nil then
        return
    end
    self.internalData = {}
    local _propertyStr = _data.neigongs or ""
    self.internalData = string.split(_propertyStr,",")
end

function ChaKanOtherInternalLayer:setInternalStrengthData(_heroid)
    self.internalStrengthStaticData = {}
    self.internalStrengthStaticData = gameData.getDataFromCSV("GeneralXinfa",{id = _heroid}) or {}
end

--获取英雄升级界面的文字颜色
function ChaKanOtherInternalLayer:getTextColor(_str)
    -- local _nameColor = XTHD.resource.getQualityItemColor(self.itemInfoData["rank"])
    local _textColor = {
        hongse = cc.c4b(204,2,2,255),                           --红色
        shenhese = cc.c4b(70,34,34,255),                        --深褐色，用的比较多
        lanse = cc.c4b(3,102,204,255),                        --蓝色
        chenghongse = cc.c4b(255,79,2,255), 
        zongse = cc.c4b(70,34,34,255),
        baise = cc.c4b(255,255,255,255),                        --白色
        lvse = cc.c4b(104,157,0,255),                           --绿色
    }
    return _textColor[_str]
end

function ChaKanOtherInternalLayer:create(params)
	local _node = self.new(params);
	return _node;
end

return ChaKanOtherInternalLayer