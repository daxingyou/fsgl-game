local YingXiongZhuangbei = class("YingXiongZhuangbei", function()
    return XTHDPopLayer:create()
end )

function YingXiongZhuangbei:ctor(parent)
    self._parent = parent
    self._tableView = nil
    self.staticItemData = nil
    self.staticItemEquipListData = nil
    self._equipments = nil
    self._equipState = nil
    self.currentCanEquipItems = { }
    -- 当前可装备的各部位最高战力道具的dbi
    self.equipedItemData = { }
    -- 已经装备的道具
    self.dynamicEquipmentData = { }
    -- 动态数据库Equipment的数据
    self.dynamicItemData = { }
    self.current_function_layer = nil
    self._isFirstShow = false

    self:setOldEquipmentData(self._parent.data["equipments"])
    self:getStaticDBData()
    self:getDynamicDBData()
    self:setEquipedItemData()
    self._endCallback = function()
        if self.current_function_layer then
            self.current_function_layer:removeFromParent()
            self.current_function_layer = nil
            self._bg:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.5, cc.p(self:getContentSize().width * 0.5, self._bg:getPositionY())),
            cc.CallFunc:create( function()
                self._isFirstShow = false
            end )
            ))
        else
            self:hide( { music = true })
        end
    end
    self:init()
end

function YingXiongZhuangbei:init()
    local bg = cc.Sprite:create("res/image/newHeroinfo/heroEquip/heroEquipbg.png")
    bg:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height * 0.5)
    self:addContent(bg)
    self._bg = bg

    local tableViewSize = cc.size(bg:getContentSize().width - 90, bg:getContentSize().height - 150)
    self._tableView = cc.TableView:create(tableViewSize)
    self._tableView:setBounceable(true)
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setDelegate()
    self._tableView:setPosition(45, 115)
    bg:addChild(self._tableView)

    local numberOfCellsInTableView = function(table_view)
        return 6
    end

    local cellSizeForTable = function(table_view, idx)
        return tableViewSize.width, tableViewSize.height / 4 + 5
    end

    local tableCellAtIndex = function(table_view, idx)
        local cell = table_view:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
            cell:setContentSize(tableViewSize.width, 85)
        end
        local _index = idx + 1
        self:createCellbg(_index, cell)
        return cell
    end

    self._tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:reloadData()

    -- 一键操作
    local getOneKeyBtn = function(labelStr)
        local _btnNode = XTHD.createCommonButton( {
            btnColor = "write"
            ,
            isScrollView = false,
            text = labelStr
            ,
            fontSize = self._commonTextFontSize
        } )
        _btnNode:setScale(0.6)
        _btnNode:getLabel():setFontSize(28)
        return _btnNode
    end


    local key_strength_btn = getOneKeyBtn(LANGUAGE_BTN_KEY.oneKeyStrength)
    key_strength_btn:setName("strengBtn")
    key_strength_btn:setAnchorPoint(cc.p(0, 1))
    key_strength_btn:setCascadeOpacityEnabled(true)
    key_strength_btn:setTouchEndedCallback( function()
        ----引导
        YinDaoMarg:getInstance():guideTouchEnd()

        if self._parent.isHaveEquipment == false then
            XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.noEquipmentsTextXc)
            return
        end
        self._parent:OneKeyToStrength()
    end )
    self._bg:addChild(key_strength_btn)
    key_strength_btn:setPosition(key_strength_btn:getContentSize().width * 0.5 + 20, self._tableView:getPositionY() -20)
    self.guide_oneKeyStrength = key_strength_btn

    YinDaoMarg:getInstance():addGuide( {
        parent = self,
        target = key_strength_btn,
        needNext = false,
    } , {
        { 2, 7 }
    } )

    --      一键装备按钮
    local key_equip_btn = getOneKeyBtn(LANGUAGE_BTN_KEY.oneKeyEquip)
    key_equip_btn:setName("equipBtn")
    key_equip_btn:setAnchorPoint(cc.p(0, 1))
    key_equip_btn:setTouchEndedCallback( function()
        ----引导
        YinDaoMarg:getInstance():guideTouchEnd()

        _isHaveItems = self._parent:isHaveItems()
        if _isHaveItems == false then
            XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.noCanEquipItemsTextXc)
            return
        end
        self._parent:OneKeyToEquip()
    end )
    key_equip_btn:setPosition(self._bg:getContentSize().width - key_equip_btn:getContentSize().width - 30, self._tableView:getPositionY() -20)
    self._bg:addChild(key_equip_btn)
    self.guide_oneKeyEquip = key_equip_btn

    YinDaoMarg:getInstance():addGuide( {
        parent = self,
        target = key_equip_btn,
        needNext = false,
    } , {
        { 2, 6 }
    } )

    YinDaoMarg:getInstance():doNextGuide()
end

function YingXiongZhuangbei:createCellbg(index, cell)
    local cellbg = cc.Sprite:create("res/image/newHeroinfo/heroEquip/cellbg.png")
    cell:addChild(cellbg)
    cellbg:setPosition(cell:getContentSize().width * 0.5, cell:getContentSize().height * 0.5)

    local _equipItem_spr = cc.Sprite:create("res/image/item/part" .. index .. ".png")
    cellbg:addChild(_equipItem_spr)
    _equipItem_spr:setScale(0.6)
    _equipItem_spr:setPosition((_equipItem_spr:getContentSize().width * 0.6) * 0.5 + 10, cellbg:getContentSize().height * 0.5 - 1)

    local equip_id = -1
    local _equipData = { }
    if self._equipments[tostring(index)] and next(self._equipments[tostring(index)]) ~= nil and self._equipments[tostring(index)].itemid then
        equip_id = self._equipments[tostring(index)].itemid
        _equipData = self._equipments[tostring(index)]
    end
    local _btnType = "no_equip"


    if equip_id == -1 then
        -- 创建去获取装备按钮
        equip_id = index + 1
        _equipData = { }
        _itemInfo = self:getItemState(index, { _type = self._parent.data["type"] or 0, _level = self._parent.data["level"] or 0 })
        if not _itemInfo or next(_itemInfo) == nil then
            _btnType = "no_equip"
            _itemInfo = { }
            self.currentCanEquipItems[index] = ""
            btn_item = XTHD.createButton( {
                normalFile = "res/image/plugin/hero/noItemgo_normal.png",
                selectedFile = "res/image/plugin/hero/noItemgo_selected.png",
                endCallback = function()
                    local _popLayer = requires("src/fsgl/layer/YingXiong/YingXiongEquipItemDropPopLayer.lua"):create(index)
                    self:addChild(_popLayer)
                end
            } )
            btn_item:setScale(1.2)
            btn_item:setName("btn_item")
            btn_item:setPosition(cc.p(_equipItem_spr:getContentSize().width / 2, _equipItem_spr:getContentSize().height / 2))
            _equipItem_spr:addChild(btn_item)
        elseif _itemInfo and next(_itemInfo) ~= nil then
            local _imgPathStr = "CanEquip"
            if _itemInfo[1] == nil or next(_itemInfo[1]) == nil or tonumber(_itemInfo[1].equipState) ~= 1 then
                _btnType = "cannot_equip"
                _imgPathStr = "CanNotEquip"
            else
                _btnType = "can_equip"
                _imgPathStr = "CanEquip"
            end
            self.currentCanEquipItems[index] = _itemInfo[1].dbid or ""
            btn_item = XTHD.createButton( {
                normalFile = "res/image/plugin/hero/hero" .. _imgPathStr .. "Btn_normal.png",
                selectedFile = "res/image/plugin/hero/hero" .. _imgPathStr .. "Btn_selected.png"
            } )
            btn_item:setScale(1.2)
            btn_item:setName("btn_item")
            btn_item:setPosition(cc.p(_equipItem_spr:getContentSize().width / 2, _equipItem_spr:getContentSize().height / 2))
            _equipItem_spr:addChild(btn_item)
            btn_item.index = i
            local _iteminfo_ = { }
            for k, v in pairs(_itemInfo) do
                _iteminfo_[#_iteminfo_ + 1] = v
            end
            local _Data = self:addEquipedItemsForHero(_iteminfo_, index)
            self._heroEquipInfo = _Data
            btn_item:setTouchEndedCallback( function()
                if index > 0 and index < 7 and next(_Data) ~= nil then
                    self:turnToChooseEquipment(_Data, index)
                else
                    XTHDTOAST(LANGUAGE_TIPS_WORDS103)
                    -----"没有可以装备的道具")
                end
            end )
        end
    else
        self.isHaveEquipment = true
        local equipItem_data = self.staticItemData[tostring(equip_id)]
        if _equipItem_spr:getChildByName("btn_item") then
            btn_item = _equipItem_spr:getChildByName("btn_item")
            self:refreshEquipedItemBtnStrengthAndAdvance( {
                _strengLevel = _equipData["strengLevel"],
                _phaseLevel = _equipData["phaseLevel"]
            } , btn_item)
        else
            btn_item = self:createEquipedItemBtn( {
                _rank = equipItem_data["rank"],
                _resourceid = equipItem_data["resourceid"],
                _strengLevel = _equipData["strengLevel"],
                _phaseLevel = _equipData["phaseLevel"]
            } )
            btn_item:setPosition(cc.p(_equipItem_spr:getContentSize().width / 2, _equipItem_spr:getContentSize().height / 2))
            btn_item:setScale(1.1)
            btn_item:setName("btn_item")
            _equipItem_spr:addChild(btn_item)

            -- 装备名
            local equipName = XTHDLabel:create(equipItem_data.name, 20, "res/fonts/def.ttf")
            equipName:setColor(cc.c3b(70, 20, 20))
            equipName:setAnchorPoint(0, 0.5)
            equipName:setPosition(btn_item:getPositionX() + btn_item:getContentSize().width * 0.25 + 10, cellbg:getContentSize().height - equipName:getContentSize().height)
            cellbg:addChild(equipName)

            -- 装备等级
            local equipLevel = XTHDLabel:create("Lv: " .. _equipData.strengLevel, 16)
            equipLevel:setColor(cc.c3b(0, 0, 0))
            equipLevel:setAnchorPoint(0, 0.5)
            equipLevel:setPosition(cellbg:getContentSize().width * 0.8, cellbg:getContentSize().height - equipLevel:getContentSize().height)
            cellbg:addChild(equipLevel)

            local line = cc.Sprite:create("res/image/newHeroinfo/heroEquip/line.png")
            line:setAnchorPoint(0, 0.5)
            cellbg:addChild(line)
            line:setPosition(btn_item:getPositionX() + btn_item:getContentSize().width * 0.25 + 10, cellbg:getContentSize().height * 0.5)

            -- 装备加成
            self:createAddtionlable(_equipData, cellbg, index)

            _btnType = "is_equipped"
            btn_item._prompt = { }
            btn_item:setCascadeOpacityEnabled(true)
            btn_item.index = i

            _itemInfo = self:getItemState(index, { _type = self._parent.data["type"] or 0, _level = self._parent.data["level"] or 0 })

            if not _itemInfo then
                _itemInfo = { }
            end
            local _changeItemStr = self:getChangeBetterItemPrompt(_equipData, _itemInfo) or nil
            if _changeItemStr ~= nil then
                btn_item._prompt[#btn_item._prompt + 1] = _changeItemStr
                self.currentCanEquipItems[index] = _itemInfo[1].dbid or ""
            else
                self.currentCanEquipItems[index] = _equipData.dbid or ""
            end

            if self._equipState[tostring(index)] ~= nil then
                if self._equipState[tostring(index)] == "equip" then
                    btn_item:setOpacity(0)
                    local _animation = cc.Spawn:create(cc.Sequence:create(cc.DelayTime:create(0.033 * 5), cc.FadeIn:create(0.5)), cc.CallFunc:create( function()
                        local _lightAni = getAnimation("res/image/plugin/hero/equipItemFrames/", 1, 9, 0.065)
                        local _sp = cc.Sprite:create("res/image/plugin/hero/equipItemFrames/1.png")
                        -- _sp:setScale(1.4)
                        _sp:setPosition(_equipItem_spr:getContentSize().width / 2, _equipItem_spr:getContentSize().height / 2)
                        _equipItem_spr:addChild(_sp)
                        _sp:runAction(cc.Sequence:create(_lightAni, cc.CallFunc:create( function()
                            _sp:removeFromParent()
                        end )))
                    end ))
                    btn_item:runAction(_animation)
                elseif self._equipState[tostring(i)] == "streng" then
                    local _animation = cc.Sequence:create(cc.Show:create(), cc.CallFunc:create( function()
                        local _lightAni = getAnimation("res/image/plugin/hero/strengthFrames/", 1, 13, 0.065)
                        local _sp = cc.Sprite:create("res/image/plugin/hero/strengthFrames/1.png")
                        _sp:setScale(1.4)
                        _sp:setPosition(btn_item:getContentSize().width / 2 - 1, btn_item:getContentSize().height / 2)
                        btn_item:addChild(_sp)
                        _sp:runAction(cc.Sequence:create(_lightAni, cc.CallFunc:create( function()
                            _sp:removeFromParent()
                        end )))
                    end ))
                    btn_item:runAction(_animation)
                end
            end
            btn_item:setTouchEndedCallback( function()
                local _prompt = btn_item._prompt or { }
                local _popLayer = requires("src/fsgl/layer/YingXiong/YingXiongEquipmentInfoPopLayer.lua"):create(index, self._parent, nil, _prompt, self)
                self:addChild(_popLayer, 3)
            end )
        end
        _equipItem_spr.ItemInfo = _itemInfo
        _equipItem_spr.type = _btnType
        _equipItem_spr.equipInfo = clone(_equipData)
    end
end

-- 创建装备加成描述lable

function YingXiongZhuangbei:createAddtionlable(data, parentNode, index)
    local pos = {
        { 82 },
        { 82, 220 },
        { 82, 220 },
        { 82 },
        { 82, 220 },
        { 82 }
    }
    if data.bagindex == 1 then
        local _data = string.split(data.baseProperty, ",")
        local text = nil
        text = _data[1] == "201" and "物攻加成：" or "魔攻加成："
        local lable = XTHDLabel:create(text .. _data[2], 14)
        lable:setColor(cc.c3b(0, 100, 20))
        lable:setAnchorPoint(0, 0.5)
        parentNode:addChild(lable)
        lable:setPosition(pos[index][1], lable:getContentSize().height * 0.5 + 5)
    elseif data.bagindex == 2 then
        local _data = string.split(data.baseProperty, "#")
        for i = 1, #_data do
            local __data = string.split(_data[i], ",")
            if __data[1] == "201" or __data[1] == "203" then
                local text = __data[1] == "201" and "物攻加成：" or "魔攻加成："
                local lable = XTHDLabel:create(text .. __data[2], 14)
                lable:setColor(cc.c3b(0, 100, 20))
                lable:setAnchorPoint(0, 0.5)
                parentNode:addChild(lable)
                lable:setPosition(pos[index][i], lable:getContentSize().height * 0.5 + 5)
            end
        end
    elseif data.bagindex == 3 then
        local _data = string.split(data.baseProperty, "#")
        for i = 1, #_data do
            local __data = string.split(_data[i], ",")
            if __data[1] == "202" or __data[1] == "204" then
                local text = __data[1] == "202" and "物防加成：" or "魔防加成："
                local lable = XTHDLabel:create(text .. __data[2], 14)
                lable:setColor(cc.c3b(0, 100, 20))
                lable:setAnchorPoint(0, 0.5)
                parentNode:addChild(lable)
                lable:setPosition(pos[index][i], lable:getContentSize().height * 0.5 + 5)
            end
        end
    elseif data.bagindex == 4 then
        local _data = string.split(data.baseProperty, ",")
        local text = nil
        text = "生命加成："
        local lable = XTHDLabel:create(text .. _data[2], 14)
        lable:setColor(cc.c3b(0, 100, 20))
        lable:setAnchorPoint(0, 0.5)
        parentNode:addChild(lable)
        lable:setPosition(pos[index][1], lable:getContentSize().height * 0.5 + 5)
    elseif data.bagindex == 5 then
        local _data = string.split(data.baseProperty, "#")
        for i = 1, #_data do
            local __data = string.split(_data[i], ",")
            if __data[1] == "202" or __data[1] == "204" then
                local text = __data[1] == "202" and "物防加成：" or "魔防加成："
                local lable = XTHDLabel:create(text .. __data[2], 14)
                lable:setColor(cc.c3b(0, 100, 20))
                lable:setAnchorPoint(0, 0.5)
                parentNode:addChild(lable)
                lable:setPosition(pos[index][i], lable:getContentSize().height * 0.5 + 5)
            end
        end
    elseif data.bagindex == 6 then
        local _data = string.split(data.baseProperty, "#")
        for i = 1, #_data do
            local __data = string.split(_data[i], ",")
            if __data[1] == "200" then
                local text = "生命加成："
                local lable = XTHDLabel:create(text .. __data[2], 14)
                lable:setColor(cc.c3b(0, 100, 20))
                lable:setAnchorPoint(0, 0.5)
                parentNode:addChild(lable)
                lable:setPosition(pos[index][i], lable:getContentSize().height * 0.5 + 5)
            end
        end
    end
end

-- 创建装备头像
function YingXiongZhuangbei:createEquipedItemBtn(_itemData)
    local _itemdInfoData = _itemData or { }
    local _itemPath = XTHD.resource.getItemImgById(_itemdInfoData._resourceid or 0)
    local _bgPath = XTHD.resource.getQualityItemBgPath(_itemdInfoData._rank or 1)
    local _normalNode = cc.Sprite:create(_itemPath)
    local _selectedNode = cc.Sprite:create(_itemPath)
    -- _selectedNode:setScale(0.95)
    local _itemBtn = XTHD.createButton( {
        normalNode = _normalNode,
        selectedNode = _selectedNode,
    } )
    _itemBtn:setAnchorPoint(cc.p(0.5, 0.5))
    local _itembg = cc.Sprite:create(_bgPath)
    _itembg:setPosition(cc.p(_itemBtn:getContentSize().width / 2, _itemBtn:getContentSize().height / 2))
    _itemBtn:addChild(_itembg)
    local level_bg = cc.Sprite:create("res/image/common/common_herolevelBg.png")
    level_bg:setTag(1)
    level_bg:setName("level_bg")
    level_bg:setAnchorPoint(0, 0)
    level_bg:setPosition(0 + 2, 15)
    _itemBtn:addChild(level_bg)

    local label_level = XTHDLabel:create(_itemdInfoData._strengLevel or 0, 20)
    label_level:setName("label_level")
    label_level:setColor(cc.c3b(255, 255, 255))
    label_level:enableShadow(cc.c4b(255, 255, 255, 255), cc.size(0.4, -0.4), 0.4)
    label_level:setCascadeColorEnabled(true)
    label_level:setPosition(level_bg:getContentSize().width / 2, level_bg:getContentSize().height / 2)
    level_bg:addChild(label_level)
    if _itemdInfoData._phaseLevel ~= nil and tonumber(_itemdInfoData._phaseLevel) > 0 then
        local _phaseBg = cc.Sprite:createWithTexture(nil, cc.rect(0, 0, _itemBtn:getContentSize().width, 30))
        _phaseBg:setOpacity(0)
        _phaseBg:setName("phaseBg")
        _phaseBg:setAnchorPoint(cc.p(0.5, 0))
        _phaseBg:setPosition(cc.p(_itemBtn:getContentSize().width / 2, 0))
        _itemBtn:addChild(_phaseBg)
        local _starPos = SortPos:sortFromMiddle(cc.p(_phaseBg:getContentSize().width / 2, 0), _itemdInfoData._phaseLevel, 13)
        for i = 1, _itemdInfoData._phaseLevel do
            local _starSpr = cc.Sprite:create("res/image/common/star_light.png")
            _starSpr:setScale(0.6)
            _starSpr:setAnchorPoint(cc.p(0.5, 0))
            _starSpr:setPosition(cc.p(_starPos[i].x, _starPos[i].y))
            _phaseBg:addChild(_starSpr)
        end
    end
    if _itemdInfoData._rank ~= nil and tonumber(_itemdInfoData._rank) > 3 then
        XTHD.addEffectToEquipment(_itemBtn, _itemdInfoData._rank)
    end
    return _itemBtn
end

-- 装备是否可更换更好提示
function YingXiongZhuangbei:getChangeBetterItemPrompt(_equipData, _equipmentListData)
    local _prompt = nil
    local _quality = tonumber(_equipData.quality) or 0
    local _power = tonumber(_equipData.power) or 0
    if _equipmentListData ~= nil and next(_equipmentListData) ~= nil and _equipmentListData[1] ~= nil and next(_equipmentListData[1]) ~= nil and tonumber(_equipmentListData[1].equipState or 0) ~= 1 then
        return nil
    end
    for k, v in pairs(_equipmentListData) do
        if v.equipState and tonumber(v.equipState) == 1 then
            if v.quality and tonumber(v.quality) > _quality then
                _prompt = "canChangeBetterItem"
                break
            elseif v.quality and tonumber(v.quality) == _quality and tonumber(v.power) > _power then
                _prompt = "canChangeBetterItem"
                break
            end
        end
    end
    return _prompt
end

function YingXiongZhuangbei:setOldEquipmentData(_data)
    local _oldData = _data or { }
    self._parent.oldEquipmentData = { }
    for i = 1, #_oldData do
        self._parent.oldEquipmentData[tostring(_oldData[i].bagindex)] = clone(_oldData[i])
    end
end

function YingXiongZhuangbei:getStaticDBData()
    self.staticItemData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet")
    self.staticItemEquipListData = gameData.getDataFromCSVWithPrimaryKey("EquipInfoList")
    self:refreshEquipInfo()
end

function YingXiongZhuangbei:refreshEquipInfo()
    local equipments = {
        ["1"] = { },
        ["2"] = { },
        ["3"] = { },
        ["4"] = { },
        ["5"] = { },
        ["6"] = { },
    }
    local _hero_data = self._parent.data
    for i = 1, #self._parent.data["equipments"] do
        equipments[tostring(self._parent.data["equipments"][i].bagindex)] = self._parent.data["equipments"][i]
    end
    self._equipments = equipments

    local _equipState = {
        ["1"] = nil,
        ["2"] = nil,
        ["3"] = nil,
        ["4"] = nil,
        ["5"] = nil,
        ["6"] = nil,
    }
    -- 判断是否是强化或者装备
    if self._parent.oldEquipmentData ~= nil then
        for i = 1, #_hero_data["equipments"] do
            if _hero_data["equipments"][i] ~= nil or next(_hero_data["equipments"][i]) ~= nil then
                local _bagindex = _hero_data["equipments"][i].bagindex or 0
                if self._parent.oldEquipmentData[tostring(_bagindex)] ~= nil and next(self._parent.oldEquipmentData[tostring(_bagindex)]) ~= nil then

                    if self._parent.oldEquipmentData[tostring(_bagindex)].dbid and tostring(self._parent.oldEquipmentData[tostring(_bagindex)].dbid) ~= tostring(_hero_data["equipments"][i].dbid) then
                        _equipState[tostring(_bagindex)] = "equip"
                    elseif self._parent.oldEquipmentData[tostring(_bagindex)].strengLevel == nil or tonumber(self._parent.oldEquipmentData[tostring(_bagindex)].strengLevel) ~= tonumber(_hero_data["equipments"][i].strengLevel) then
                        _equipState[tostring(_bagindex)] = "streng"
                    end
                else
                    _equipState[tostring(_bagindex)] = "equip"
                end
            end
        end
    end
    self._equipState = _equipState
end

-- 获取装备状态
function YingXiongZhuangbei:getItemState(_pos, _heroData)
    if _heroData == nil or next(_heroData) == nil then
        return { }
    end
    local _equipmentData = { }
    if self._parent.items_data ~= nil and next(self._parent.items_data) ~= nil then
        for k, var in pairs(self._parent.items_data) do
            if var.equipment and tonumber(var.equipment.equippos) == tonumber(_pos) then
                local _heroType = string.split(var.equipment.herotype, '#')
                for i, v in pairs(_heroType) do
                    if _heroData._type and tonumber(v) == tonumber(_heroData._type) then
                        local _index = tonumber(#_equipmentData + 1)
                        _equipmentData[_index] = clone(var)
                        -- 0表示可装备，1表示等级不足
                        _equipmentData[_index].equipState = 1
                        if _heroData._level and tonumber(_heroData._level) < tonumber(var.level) then
                            _equipmentData[_index].equipState = 0
                        end
                    end
                end
            end
        end
    end
    if _equipmentData and next(_equipmentData) ~= nil then
        table.sort(_equipmentData, function(data1, data2)
            local _dataNum1 = tonumber(data1.equipState or 0) * 100 + tonumber(data1.quality)
            local _dataNum2 = tonumber(data2.equipState or 0) * 100 + tonumber(data2.quality)
            if tonumber(_dataNum1) == tonumber(_dataNum2) then
                return tonumber(data1.power) > tonumber(data2.power)
            else
                return tonumber(_dataNum1) > tonumber(_dataNum2)
            end
        end )
    end
    return _equipmentData
end

-- 添加当前英雄当前位置能用的已被穿戴的装备
function YingXiongZhuangbei:addEquipedItemsForHero(_itemsData, _pos)
    local _table = _itemsData
    if not self.equipedItemData or next(self.equipedItemData) == nil then
        return _table
    end
    for i = 1, #self.equipedItemData do
        if tonumber(self.equipedItemData[i].heroid) ~= self._parent.data["heroid"] then
            if tonumber(self.equipedItemData[i].bagindex) == tonumber(_pos) then
                local _heroType = string.split(self.equipedItemData[i].herotype, '#')
                for j, v in pairs(_heroType) do
                    if tonumber(v) == tonumber(self._parent.data.type) then
                        _table[#_table + 1] = clone(self.equipedItemData[i])
                    end
                end
            end
        end
    end
    return _table
end

-- 重新获取当前已经装备上的道具的数据
function YingXiongZhuangbei:setEquipedItemData()
    local _itemsPair = { }
    self.equipedItemData = { }
    _itemsPair = self.dynamicEquipmentData or { }
    local _staticItemData = { }
    local _staticEquipmentData = { }
    local _EquipmentTable = self.staticItemEquipListData
    -- gameData.getDataFromCSVWithPrimaryKey("EquipInfoList")
    for i, var in pairs(_itemsPair) do
        self.equipedItemData[i] = { }
        self.equipedItemData[i] = var
        self.equipedItemData[i].level = self.staticItemData[tostring(var["itemid"])] and self.staticItemData[tostring(var["itemid"])].levelfloor or 0
        self.equipedItemData[i].name = self.staticItemData[tostring(var["itemid"])] and self.staticItemData[tostring(var["itemid"])].name or 0
        self.equipedItemData[i].resourceid = self.staticItemData[tostring(var["itemid"])] and self.staticItemData[tostring(var["itemid"])].resourceid or 0
        self.equipedItemData[i].herotype = _EquipmentTable[tostring(var["itemid"])] and _EquipmentTable[tostring(var["itemid"])].herotype or 1
    end
end

-- 跳转选择装备
function YingXiongZhuangbei:turnToChooseEquipment(_itemsData, _idx)
    if self.current_function_layer then
        self.current_function_layer:removeFromParent()
        self.current_function_layer = nil
    end

    if not self._isFirstShow then
        self._bg:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.5, cc.p(self:getContentSize().width * 0.5 + self._bg:getContentSize().width * 0.25, self._bg:getPositionY())),
        cc.CallFunc:create( function()
            local _node = requires("src/fsgl/layer/YingXiong/YingXiongChooseEquipmentLayer.lua")
            self.current_function_layer = _node:create(_itemsData, self._parent, self._parent.data.heroid or 1, _idx, cc.size(269, self._bg:getContentSize().height), self)
            self.current_function_layer:setAnchorPoint(1, 0.5)
            self.current_function_layer:setPosition(0, self._bg:getContentSize().height * 0.5)
            self._bg:addChild(self.current_function_layer)
            self._isFirstShow = true
        end )
        ))
    else
        local _node = requires("src/fsgl/layer/YingXiong/YingXiongChooseEquipmentLayer.lua")
        self.current_function_layer = _node:create(_itemsData, self._parent, self._parent.data.heroid or 1, _idx, cc.size(269, self._bg:getContentSize().height), self)
        self.current_function_layer:setAnchorPoint(1, 0.5)
        self.current_function_layer:setPosition(0, self._bg:getContentSize().height * 0.5)
        self._bg:addChild(self.current_function_layer)
    end
end

-- 获取提示箭头路径
function YingXiongZhuangbei:getPromptPathByStr(_str)
    local _path = nil
    if _str == "canStreng" then
        _path = "res/image/plugin/hero/hero_propertyadd.png"
    elseif _str == "canAdvance" then
        _path = "res/image/plugin/hero/item_canAdvanceSpr.png"
    elseif _str == "canChangeBetterItem" then
        _path = "res/image/plugin/hero/item_canChangeItemSpr.png"
    end
    return _path
end

-- 创建提示箭头
function YingXiongZhuangbei:createPromptSprite(_str)
    local _promptSprite = cc.Sprite:create(self:getPromptPathByStr(_str))
    _promptSprite:setName("promptSprite")
    _promptSprite:setAnchorPoint(cc.p(1, 0))
    _promptSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.4, cc.p(0, 10)), cc.MoveBy:create(0.6, cc.p(0, -10)))))
    return _promptSprite
end

-- 刷新数据
function YingXiongZhuangbei:refreshInfoLayer()
    self:refreshEquipInfo()
    self._tableView:reloadData()
    if self.current_function_layer then
        self._endCallback()
    end
end


function YingXiongZhuangbei:setEquipedItemData()
    local _itemsPair = { }
    self.equipedItemData = { }
    _itemsPair = self.dynamicEquipmentData or { }
    local _staticItemData = { }
    local _staticEquipmentData = { }
    local _EquipmentTable = self.staticItemEquipListData
    for i, var in pairs(_itemsPair) do
        self.equipedItemData[i] = { }
        self.equipedItemData[i] = var
        self.equipedItemData[i].level = self.staticItemData[tostring(var["itemid"])] and self.staticItemData[tostring(var["itemid"])].levelfloor or 0
        self.equipedItemData[i].name = self.staticItemData[tostring(var["itemid"])] and self.staticItemData[tostring(var["itemid"])].name or 0
        self.equipedItemData[i].resourceid = self.staticItemData[tostring(var["itemid"])] and self.staticItemData[tostring(var["itemid"])].resourceid or 0
        self.equipedItemData[i].herotype = _EquipmentTable[tostring(var["itemid"])] and _EquipmentTable[tostring(var["itemid"])].herotype or 1
    end
end

-- 获取动态数据库Item的数据
function YingXiongZhuangbei:getDynamicDBItemData()
    self.dynamicItemData = { }
    self.dynamicItemData = DBTableItem:getDataByID()
    self.dynamicCostItemData = { }
    for k, v in pairs(self.dynamicItemData) do
        self.dynamicCostItemData[tostring(v.itemid)] = v
    end

end

function YingXiongZhuangbei:getDynamicDBData()
    self:getDynamicDBItemData()
    self:getDynamicDBEquipmentData()
end

function YingXiongZhuangbei:getDynamicDBEquipmentData()
    self.dynamicEquipmentData = { }
    local _table = DBTableEquipment.getData(gameUser.getUserId(), nil)
    if _table and next(_table) ~= nil and #_table < 1 then
        self.dynamicEquipmentData[#self.dynamicEquipmentData + 1] = _table
    else
        self.dynamicEquipmentData = _table
        -- 浅拷贝
    end
end

function YingXiongZhuangbei:create(parent)
    print("啪啪啪啪啪啪铺铺铺铺铺铺铺铺铺")
    local YingXiongZhuangbei = YingXiongZhuangbei.new(parent)
    return YingXiongZhuangbei
end

return YingXiongZhuangbei