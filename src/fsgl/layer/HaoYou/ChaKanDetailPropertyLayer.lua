--[=[
    FileName:ChaKanDetailPropertyLayer.lua
    Autor:xingchen
    Date:2015.11.13
    Content:查看信息英雄属性界面
    PS:这是复制了一份
]=]
local ChaKanDetailPropertyLayer = class("ChaKanDetailPropertyLayer", function()
	-- local select_sp = XTHDSprite:create("res/image/plugin/hero/baseInfo_bg.png")
    local select_sp = XTHD.createFunctionLayer()
    return select_sp
end)

function ChaKanDetailPropertyLayer:ctor(params)
    if params._contentSize ~=nil then
        self:setTextureRect(cc.rect(0,0,params._contentSize.width,params._contentSize.height))
    end
    self:setOpacity(0)
    self.isOther = isOther
    self.otherDistance = 0
    if self.isOther~=nil and self.isOther == true then
        self:setTextureRect(cc.rect(0,0,357,446))
        self.otherDistance = 5
    end
    
    self.infoLayer = params._parentLayer

    self.detail_fontSize = 18

    self.data = params._data or {}

    self:init()
end

function ChaKanDetailPropertyLayer:init()

    local _contentWidth = 365
    --英雄介绍框
    local kuang1 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
    kuang1:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height - 15 - self.otherDistance - kuang1:getContentSize().height/2 -10))
    --设置一下框的大小
    kuang1:setContentSize(_contentWidth,120)
    self:addChild(kuang1)
    -- local _herotitleBg_path = ""
    
    --[[英雄介绍]]
    local _heroPropertyTitle_bg = cc.Sprite:create("res/image/plugin/hero/YXJS.png")
    _heroPropertyTitle_bg:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height - 15 - self.otherDistance - _heroPropertyTitle_bg:getContentSize().height/2+30))
    self:addChild(_heroPropertyTitle_bg)
    -- local _heroPropertyTitle_label = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.heroIntroduceTextXc,self.detail_fontSize)
    -- _heroPropertyTitle_label:enableShadow(cc.c4b(70, 34, 34, 255),cc.size(0.4,-0.4),1)
    -- _heroPropertyTitle_label:setColor(self:getDetailTextColor("lanse"))
    -- _heroPropertyTitle_label:setPosition(cc.p(_heroPropertyTitle_bg:getContentSize().width/2,_heroPropertyTitle_bg:getContentSize().height/2))
    -- _heroPropertyTitle_bg:addChild(_heroPropertyTitle_label)
    --介绍
    local _heroDescript_label = XTHDLabel:create(self.data["description"],self.detail_fontSize-2)
     _heroDescript_label:setColor(self:getDetailTextColor("zongse"))
    _heroDescript_label:setAnchorPoint(cc.p(0.5,1))
    _heroDescript_label:setWidth(305)
    _heroDescript_label:setLineBreakWithoutSpace(true)
    _heroDescript_label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT )
    _heroDescript_label:setPosition(cc.p(self:getContentSize().width/2,_heroPropertyTitle_bg:getBoundingBox().y ))
    self:addChild(_heroDescript_label)
--    --标签
--    local _heroAutograph_label = XTHDLabel:create(self.data["autograph"] or "",self.detail_fontSize-2)
--    _heroAutograph_label:setColor(self:getDetailTextColor("lanse"))
--    _heroAutograph_label:setAnchorPoint(cc.p(0.5,1))
--    -- _heroAutograph_label:setWidth(305)
--    -- _heroAutograph_label:setLineBreakWithoutSpace(true)
--    -- _heroAutograph_label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT )
--    _heroAutograph_label:setPosition(cc.p(self:getContentSize().width/2,_heroDescript_label:getBoundingBox().y ))
--    self:addChild(_heroAutograph_label)

    -- local _infoCutLine = ccui.Scale9Sprite:create(cc.rect(130,0,140,4),"res/image/common/common_split_line.png")
    -- _infoCutLine:setContentSize(cc.size(_contentWidth,2))
    -- _infoCutLine:setPosition(cc.p(self:getContentSize().width/2,_heroAutograph_label:getBoundingBox().y-10))
    
    -- self:addChild(_infoCutLine)
    --英雄属性
    --英雄属性框
    local kuang2 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
    kuang2:setPosition(cc.p(self:getContentSize().width/2,4))
    kuang2:setAnchorPoint(0.5,0)
    --设置一下框的大小
    kuang2:setContentSize(_contentWidth,240)
    self:addChild(kuang2)

    local _heroDetailTitle_bg = cc.Sprite:create("res/image/plugin/hero/YXSX.png")
    _heroDetailTitle_bg:setAnchorPoint(cc.p(0.5,1))
    _heroDetailTitle_bg:setPosition(cc.p(self:getContentSize().width/2 ,kuang2:getContentSize().height+13))
    self:addChild(_heroDetailTitle_bg)
    -- local _heroDetailTitle_label = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.heroPropertyTextXc,self.detail_fontSize)
    -- _heroDetailTitle_label:enableShadow(cc.c4b(70, 34, 34, 255),cc.size(0.4,-0.4),1)
    -- _heroDetailTitle_label:setColor(self:getDetailTextColor("lanse"))
    -- _heroDetailTitle_label:setPosition(cc.p(_heroDetailTitle_bg:getContentSize().width/2,_heroDetailTitle_bg:getContentSize().height/2))
    -- _heroDetailTitle_bg:addChild(_heroDetailTitle_label)

    --属性介绍
    -- local _propertyIntroduceBtn = XTHDPushButton:createWithParams({
    --     normalFile = "res/image/camp/camp_help1.png"
    --     ,selectedFile  = "res/image/camp/camp_help2.png"
    --     ,musicFile = XTHD.resource.music.effect_btn_common
    --     ,endCallback = function()
    --         local _popLayer = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=14})
    --         self.infoLayer:addChild(_popLayer)
    --     end
    --     })
    -- _propertyIntroduceBtn:setScale(0.7)
    -- _propertyIntroduceBtn:setAnchorPoint(cc.p(1,0.5))
    -- _propertyIntroduceBtn:setPosition(cc.p(self:getContentSize().width/2 + _contentWidth/2 - 20,_heroDetailTitle_bg:getBoundingBox().y + _propertyIntroduceBtn:getBoundingBox().height/2))
    -- self:addChild(_propertyIntroduceBtn)
    -- if self.isOther ~=nil and self.isOther == true then
    --     _propertyIntroduceBtn:setVisible(false)
    -- end
    --属性值
    local _downPosY = 10
    local _propertyHeight = _heroDetailTitle_bg:getBoundingBox().y - 5-_downPosY - self.otherDistance

    -- local _downLine = ccui.Scale9Sprite:create(cc.rect(130,0,140,4),"res/image/common/common_split_line.png")
    -- _downLine:setContentSize(cc.size(_contentWidth,2))
    -- _downLine:setPosition(cc.p(self:getContentSize().width/2,_downPosY-1))
    -- self:addChild(_downLine)

    local _downShade = ccui.Scale9Sprite:create(cc.rect(28,0,2,15),"res/image/common/common_scale_shade.png")
    _downShade:setContentSize(cc.size(_contentWidth-10,15))
    _downShade:setAnchorPoint(cc.p(0.5,0))
    _downShade:setPosition(cc.p(self:getContentSize().width/2,_downPosY-2))
    self:addChild(_downShade)
    _downShade:setVisible(false)

    local _tableViewCellSize = cc.size(_contentWidth,28)
    self._tableView = CCTableView:create(cc.size(_contentWidth,_propertyHeight - 5))
    self._tableView:setPosition(cc.p(self:getContentSize().width/2 - _contentWidth/2,_downPosY))
    self._tableView:setBounceable(true)
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._tableView:setDelegate()
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self._tableView)

    self.propertyData = XTHD.getHeroPropertyData(self.data)

    local function cellSizeForTable(table,idx)
        return _tableViewCellSize.width,_tableViewCellSize.height
    end

    local function numberOfCellsInTableView(table)
        return #self.propertyData
    end

    local function scrollViewDidScroll(view)
        local offset = self._tableView:getContentOffset().y
        if offset < 0 then
            _downShade:setVisible(false)
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
        local _propertyPosX = 45
        local _detailData = self.propertyData[idx+1]
        local info_label_name = XTHDLabel:create(_detailData.name .. ":",self.detail_fontSize)
        info_label_name:setColor(self:getDetailTextColor("shenhese"))
        if idx<5 then
            info_label_name:setColor(self:getDetailTextColor("chenghongse"))
        end
        info_label_name:setAnchorPoint(0,0.5)
        info_label_name:setPosition(cc.p(_propertyPosX,_tableViewCellSize.height/2))
        cell:addChild(info_label_name)
        local current_info_number = XTHDLabel:create(XTHD.resource.addPercent(_detailData.propertyNum,_detailData.propertyValue), self.detail_fontSize)
        current_info_number:setColor(self:getDetailTextColor(_detailData._color))
        current_info_number:setAnchorPoint(0,0.5)
        current_info_number:setPosition(cc.p(_propertyPosX + 90,info_label_name:getPositionY()))
        cell:addChild(current_info_number)

        return cell
    end

    self._tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:reloadData()

    if tonumber(self._tableView:getContentOffset().y)<0 then
        _downShade:setVisible(false)
    end
end

-- function ChaKanDetailPropertyLayer:setPropertyPart(_data)
--     if _data == nil then
--         return
--     end
--     --5星成长属性*（当前等级-1）-4星成长属性*（当前等级-1）
--     if self.property_scrollView~=nil then
--         self.property_scrollView:removeAllChildren()
--     end
--     local _detailData = XTHD.getHeroPropertyData(_data)
--     local _propertyNum = #_detailData
--     local _contentHeight = self.property_scrollView:getContentSize().height
--     local _innerHeight = 38*_propertyNum + 4
--     if tonumber(_innerHeight)<tonumber(_contentHeight) then
--         _innerHeight = _contentHeight
--     end
--     self.property_scrollView:setInnerContainerSize(cc.size(326,_innerHeight))
--     local _rowHeight = 38
--     -- print("8431>>self.property_bg>>" .. _innerHeight)
--     for i=1,_propertyNum do
--         if i~=_propertyNum then
--             local _lineSpr = ccui.Scale9Sprite:create(cc.rect(5,0,1,1),"res/image/common/scale_line.png")
--             _lineSpr:setContentSize(cc.size(self.property_scrollView:getContentSize().width-4,1))
--             _lineSpr:setName("lineSpr")
--             _lineSpr:setPosition(cc.p(self.property_scrollView:getContentSize().width/2,_innerHeight - 2-_rowHeight*i))
--             self.property_scrollView:addChild(_lineSpr)
--         end

--         local info_label_name = XTHDLabel:create(_detailData[i].name .. ":",self.detail_fontSize)
--         -- info_label_name:setColor(self:getDetailTextColor(_detailData[i]._color))
--          info_label_name:setColor(self:getDetailTextColor("shenhese"))
--          if  i<6 then--by huangjunjain
--             info_label_name:setColor(self:getDetailTextColor("chenghongse"))
--          end
--         info_label_name:setAnchorPoint(0,0.5)
--         info_label_name:setPosition(15,_innerHeight - 2-_rowHeight*i +18)
--         self.property_scrollView:addChild(info_label_name)
--         local current_info_number = XTHDLabel:create(XTHD.resource.addPercent(_detailData[i].propertyNum,_detailData[i].propertyValue), self.detail_fontSize)
--         current_info_number:enableShadow(self:getDetailTextColor("shenhese"),cc.size(0.4,-0.4),0.4)
--         current_info_number:setColor(self:getDetailTextColor(_detailData[i]._color))
--         current_info_number:setAnchorPoint(0,0.5)
--         current_info_number:setPosition(cc.p(110,info_label_name:getPositionY()))
--         self.property_scrollView:addChild(current_info_number)
--     end
-- end
function ChaKanDetailPropertyLayer:reFreshHeroFunctionInfo()
    self.data = nil
    self.data = clone(self.infoLayer and self.infoLayer.data)
    self.propertyData = XTHD.getHeroPropertyData(self.data)
    self._tableView:reloadData()
end

--获取英雄升级界面的文字颜色
function ChaKanDetailPropertyLayer:getDetailTextColor(_str)
    -- local _nameColor = XTHD.resource.getQualityItemColor(self.itemInfoData["rank"])
    local _textColor = {
        hongse = cc.c4b(204,2,2,255),                           --红色
        shenhese = cc.c4b(70,34,34,255),                        --深褐色，用的比较多
        -- lanse = cc.c4b(26,158,207,255), 
        lanse = cc.c4b(3,102,204,255),                        --蓝色
        -- chenghongse = cc.c4b(205,101,8,255),                    --橙红色
       chenghongse = cc.c4b(255,79,2,255), 
        -- zongse = cc.c4b(128,112,91,255),                        --棕色，有点深灰色的感觉
        zongse = cc.c4b(70,34,34,255),
        baise = cc.c4b(255,255,255,255),                        --白色
        lvse = cc.c4b(104,157,0,255),                           --绿色
    }
    return _textColor[_str]
end

function ChaKanDetailPropertyLayer:create(params)
	local _node = self.new(params);
	return _node;
end

return ChaKanDetailPropertyLayer