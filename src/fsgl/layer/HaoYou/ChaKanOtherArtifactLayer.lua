local ChaKanOtherArtifactLayer = class("ChaKanOtherArtifactLayer",function()
		local select_sp = XTHD.createFunctionLayer()
	    return select_sp
	end)

function ChaKanOtherArtifactLayer:ctor(params)
    if params._contentSize ~=nil then
        self:setTextureRect(cc.rect(0,0,params._contentSize.width,params._contentSize.height))
    end
    self:setOpacity(0)
    self._fontSize = 18
    self.artifactStaticData = {}
    self.data =  params._data and params._data.godBeast or {}

    self.property_scrollView = nil
    self.property_bg = nil
    self:setArtifactStaticData()
    self:setArtifactData()

    self:init()
end

function ChaKanOtherArtifactLayer:init()
    local _herotitleBg_path = "res/image/plugin/hero/heroTitle_bg.png"
    --[[神器]]
    local _titleStr = self.data.name
    if tonumber(self.data.rank)>0 then
    	_titleStr = self.data.name .. " +" .. self.data.rank

    end
    -- if tonumber(self.data.artifactType)>0 then
    -- 	local _artifactBg = cc.Sprite:create("res/image/common/lookinfo_artifactBg_" .. self.data.artifactType .. ".jpg")
    -- 	_artifactBg:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
    -- 	self:addChild(_artifactBg)
    -- end
    local _heroPropertyTitle_bg = cc.Sprite:create(_herotitleBg_path)
    _heroPropertyTitle_bg:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height - 20 - _heroPropertyTitle_bg:getContentSize().height/2+ 20))
    self:addChild(_heroPropertyTitle_bg)

    local _heroPropertyTitle_label = XTHDLabel:create(_titleStr,self._fontSize)
    _heroPropertyTitle_label:enableShadow(self:getTextColor("shenhese"),cc.size(0.4,-0.4),1)
    _heroPropertyTitle_label:setColor(self:getTextColor("shenhese"))
    _heroPropertyTitle_label:setPosition(cc.p(_heroPropertyTitle_bg:getContentSize().width/2,_heroPropertyTitle_bg:getContentSize().height/2))
    _heroPropertyTitle_bg:addChild(_heroPropertyTitle_label)
    -- --属性值
    -- local _propertyHeight = 37*10 + 4
    -- local _propertyBgHeright = 374
    -- local property_bg = ccui.Scale9Sprite:create(cc.rect(10,10,10,10),"res/image/common/scale9_bg_5.png")
    -- property_bg:setContentSize(cc.size(326,_propertyBgHeright))
    -- property_bg:setCascadeOpacityEnabled(true)
    -- property_bg:setCascadeColorEnabled(true)
    -- property_bg:setAnchorPoint(0.5,1)
    -- self.property_bg = property_bg
    -- property_bg:setPosition(self:getContentSize().width/2,self:getContentSize().height - 57)
    -- self:addChild(property_bg)

    -- self.property_scrollView = ccui.ScrollView:create()
    -- self.property_scrollView:setBounceEnabled(true)
    -- self.property_scrollView:setDirection(ccui.ScrollViewDir.vertical)
    -- self.property_scrollView:setTouchEnabled(true)
    -- self.property_scrollView:setContentSize(cc.size(326,_propertyBgHeright))
    -- self.property_scrollView:setInnerContainerSize(cc.size(326,_propertyHeight))
    -- self.property_scrollView:setPosition(0,0)
    -- property_bg:addChild(self.property_scrollView)

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

    local _propertyData = XTHD.getPropertyValueByTurn(self.data)
    local _detailData = XTHD.getHeroPropertyData(_propertyData)

    local function cellSizeForTable(table,idx)
        return _tableViewCellSize.width,_tableViewCellSize.height
    end

    local function numberOfCellsInTableView(table)
        return #_detailData
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
        local _index = idx+1
        local info_label_name = XTHDLabel:create(_detailData[_index].name .. ":",self._fontSize)
        info_label_name:setColor(self:getTextColor("shenhese"))
        info_label_name:setAnchorPoint(1,0.5)
        info_label_name:setPosition(_tableViewCellSize.width/2+5,_tableViewCellSize.height/2)
        cell:addChild(info_label_name)

        local current_info_number = XTHDLabel:create(XTHD.resource.addPercent(_detailData[_index].propertyNum,_detailData[_index].propertyValue), self._fontSize)
        current_info_number:setColor(self:getTextColor("shenhese"))
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

-- function ChaKanOtherArtifactLayer:setPropertyPart()
--     if self.data.property ==nil or next(self.data.property) ==nil then
--         return
--     end
--     local _propertyData = XTHD.getPropertyValueByTurn(self.data)
--     local _detailData = XTHD.getHeroPropertyData(_propertyData)
--     local _propertyNum = #_detailData
--     local _contentHeight = self.property_scrollView:getContentSize().height
--     local _innerHeight = 37*_propertyNum + 4
--     local _innerSize = cc.size(326,_innerHeight)
--     if tonumber(_innerHeight)<tonumber(_contentHeight) then
--         -- _innerHeight = _contentHeight
--         self.property_bg:setContentSize(_innerSize)
--         self.property_scrollView:setContentSize(_innerSize)
--     end
--     self.property_scrollView:setInnerContainerSize(_innerSize)
--     local _rowHeight = 37
--     for i=1,_propertyNum do
--         if i~=_propertyNum then
--             local _lineSpr = ccui.Scale9Sprite:create(cc.rect(5,0,1,1),"res/image/common/scale_line.png")
--             _lineSpr:setContentSize(cc.size(self.property_scrollView:getContentSize().width-4,1))
--             _lineSpr:setName("lineSpr")
--             _lineSpr:setPosition(cc.p(self.property_scrollView:getContentSize().width/2,_innerHeight - 2-_rowHeight*i))
--             self.property_scrollView:addChild(_lineSpr)
--         end
--         local info_label_name = XTHDLabel:create(_detailData[i].name .. ":",self._fontSize)
--         info_label_name:setColor(self:getTextColor("shenhese"))
--         info_label_name:setAnchorPoint(0,0.5)
--         info_label_name:setPosition(15,_innerHeight - 2-_rowHeight*i +18)
--         self.property_scrollView:addChild(info_label_name)
--         local current_info_number = XTHDLabel:create(XTHD.resource.addPercent(_detailData[i].propertyNum,_detailData[i].propertyValue), self._fontSize)
--         current_info_number:setColor(self:getTextColor(_detailData[i]._color))
--         current_info_number:setAnchorPoint(0,0.5)
--         current_info_number:setPosition(cc.p(110,info_label_name:getPositionY()))
--         self.property_scrollView:addChild(current_info_number)
--     end
-- end
function ChaKanOtherArtifactLayer:setArtifactData()
	local _templateId = self.data.templateId
	local _godbeastData = self.artifactStaticData[tonumber(_templateId)] or {}
	self.data.rank = _godbeastData.rank or 0
	self.data.name = _godbeastData.name or ""
	local _lowTypeId = tonumber(self.artifactStaticData[1] and self.artifactStaticData[1]._type or 30)
	self.data.artifactType = self.data._type or 30
	self.data.artifactType = self.data.artifactType - _lowTypeId + 1
end

function ChaKanOtherArtifactLayer:setArtifactStaticData()
    self.artifactStaticData = {}
    self.artifactStaticData = gameData.getDataFromCSV("SuperWeaponUpInfo")
end

--获取英雄升级界面的文字颜色
function ChaKanOtherArtifactLayer:getTextColor(_str)
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

function ChaKanOtherArtifactLayer:create(params)
	local _node = self.new(params);
	return _node;
end

return ChaKanOtherArtifactLayer