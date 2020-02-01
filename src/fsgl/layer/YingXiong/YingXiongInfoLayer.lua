-- xingchen
local YingXiongInfoLayer = class("YingXiongInfoLayer", function()
    return XTHD.createBasePageLayer()
end )
local spine_Tag = 123
function YingXiongInfoLayer:onCleanup()
    -- 设置页面不存在
    SCENEEXIST.HEROINFOLAYER = false
    _ATTRTOASTLIST = { }
    _ATTR_SP_LIST = { }
    for k, var in pairs(self.cellArr) do
        if var:getChildByTag(spine_Tag) then
            var:getChildByTag(spine_Tag):removeFromParent()
        end
        var:release()
    end
    if self.closeCallBack ~= nil then
        self.closeCallBack()
    end
    self.cellArr = { }
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_COSTMONEY_STATE)
    local textureCache = cc.Director:getInstance():getTextureCache()
    for i = 1, 14 do
        if i <= 13 then
            textureCache:removeTextureForKey("res/image/plugin/hero/strengthFrames/" .. i .. ".png")
            textureCache:removeTextureForKey("res/image/plugin/hero/levelupFrames/" .. i .. ".png")
        end
        if i <= 4 then
            textureCache:removeTextureForKey("res/image/plugin/hero/levelupFrames/cost" .. i .. ".png")
        end
        if i <= 11 then
            textureCache:removeTextureForKey("res/image/plugin/hero/advanceFrames/box" .. i .. ".png")
        end
        if i <= 9 then
            textureCache:removeTextureForKey("res/image/plugin/hero/equipItemFrames/" .. i .. ".png")
        end
    end
    textureCache:removeTextureForKey("res/image/plugin/hero/equipSpine/zbg.png")

end
local STATE = {
    -- TAG_BASE_INFO = 1,                           --基础信息
    TAG_DETAIL_INFO = "property_layer",
    -- 详细信息
    TAG_ADVANCE_INFO = "advance_layer",
    -- 进阶界面
    TAG_STAR_UP_INFO = "starup_layer",
    -- 升星界面
    TAG_SKILL_INFO = "skill_layer",
    -- 技能界面
    TAG_LEVEL_UP_INFO = "levelup_layer",
    -- 升级界面
    TAG_CHOOSEEQUIPMENT_INFO = "choose_layer",
    -- 选择装备界面
    NONE = 0-- 空
}

function YingXiongInfoLayer:onEnter()
    -- 设置页面存在
    SCENEEXIST.HEROINFOLAYER = true
    if self.cellArr ~= nil and next(self.cellArr) ~= nil then
        self:reFreshHeroDataAndLayer()
        self:recoverHeroSpine()
    end
    -- 引导
    self:addGuide()
    ----------------------------------------------------------------------
end

function YingXiongInfoLayer:onExit()
    if self:getChildByName("animationSpine") then
        self:getChildByName("animationSpine"):removeFromParent()
    end
end
--[=[
跳转到英雄，传入_type，"property","advance","starup","skill","levelup"中一种
]=]
function YingXiongInfoLayer:ctor(params)
    self.closeCallBack = params._closeCallback or nil
    ---------new-------
    self.rightPart_bg = nil
    -- 右侧边框
    self.rightTab_btn = { }
    -- 右侧标签按钮
    self.heroEquipmentsTable = { }
    -- 英雄装备
    self.starBg_arr = { }
    -- 英雄的星数
    self._leftScrollBtn = nil
    -- 左滑按钮
    self._rightScrollBtn = nil
    -- 右滑按钮
    self.equipmentsIndex = 0
    -- 当前点击的装备序号
    self.heroskillSoundId = 0
    -- 技能音效id
    self.heroDubSoundId = 0
    -- 英雄配音音效id
    self.heroFunctionBtn = { }
    -- 四个英雄功能
    ---------new-------
    self.highestStar = 5
    self.child_arr = { hero_type = nil, label_name = nil, exp_progress = nil, label_level = nil, label_levellimit = nil, fight_bg = nil, rank_bg, heroIcon = nil }
    -- 跳转类型
    self.cellArr = { }
    -- 只有三个cell
    self.maxCell = 0
    -- 所有的CELL数 也就是英雄数+2 中间有一个过渡英雄
    self.herosData = nil
    -- 所有英雄的数组
    self.data = nil
    self.firstHeroNumber = 1

    self.isCanDo_prompt = { }
    -- 标签红点提示
    self.tableViewSize = cc.size(365, 280)
    -- 这是一个function
    self.state =(params._type or "property") .. "_layer"
    -- 默认基础属性状态
    self.selectedTab = params._type or "property"
    self.detail_ScrolView = nil
    -- 详细信息界面

    self.current_function_layer = nil
    -- 升星 .进阶 技能 升级 界面共用的指针
    -- self.left_black_bg = nil
    self.items_data = { }

    self.equipedItemData = { }
    -- 已经装备的道具
    self._commonTextFontSize = 16

    self.oldEquipmentData = nil
    -- 强化、装备之前的属性
    self.isHeroAdvance = false
    -- 英雄是否刚进阶结束

    self.dynamicItemData = { }
    -- 动态数据库Item的数据
    self.dynamicCostItemData = { }
    -- 存放经验果等的数据
    self.dynamicEquipmentData = { }
    -- 动态数据库Equipment的数据
    -- self.dynamicHeroData = {}                --动态数据库Hero的数据
    -- self.dynamicHeroSkillData = {}           --动态数据库HeroSkill的数据

    self.staticItemData = { }
    -- 静态数据库Item的数据，itemid为key值
    self.staticEquipStrengData = { }
    -- 静态数据库EquipStreng的数据
    self.staticEquipAdvanceData = { }
    -- 静态数据库EquipAdvance的数据
    self.staticFunctionInfoListData = { }
    -- 静态数据库FunctionInfoList的数据
    self.staticHeroAdvancedListData = { }
    -- 静态数据库GeneralAdvanceInfo的数据
    self.staticHeroStarupListData = { }
    -- 静态数据库herostaruplist的数据，id也就是heroid为key值
    self.staticHeroSkillListData = { }
    -- 静态数据库hero_skill的数据，heroid为key值
    self.staticSkillUpListData = { }
    -- 静态数据库skill_advance的数据，level是key值
    -- self.staticItemEquipUpData = {}          --静态数据库EquipUpList的数据，level是itemlevel值
    self.staticGodbeastData = { }
    -- 静态数据库SuperWeaponUpInfo的数据
    self.staticPlayerInfoListData = { }
    -- 静态数据库PlayerUpperLimit的数据
    self.staticItemEquipListData = { }
    -- 装备静态数据

    self.otherStaticSkillData = { }
    -- 静态数据库skill的数据，skillid为key值
    self.otherStaticAdvanceData = { }
    -- 静态数据库advance的数据，heroid为key值
    self.otherStaticHeroGrowData = { }
    -- 静态数据库hero_grow的数据，heroid为key值
    self.currentCanEquipItems = { }
    -- 当前可装备的各部位最高战力道具的dbid

    self.isHaveEquipment = false
    -- 当前英雄是否穿戴着装备
    self.isCanStrength = false
    -- 当前是否有可以强化的装备
    self._dataNumber = 0

    -- self.testNumber = 0                  --测试数量。如果达到100，就会达到测试模式
    self.topBarBtn = nil
    self._heroIconTableView = nil
    self._heroCell = nil
    self._heroIconCellList = { }
    self._cuiSelectHeroIndex = 1
    self._heroEquipInfo = nil
    self._equipPoplayer = nil
    self._curState = nil

    self._EixtTime = 10

    -- 重写TopbarLayer的backBtn函数
    self:getChildByName("TopBarLayer1"):setBackCallFunc( function()
        self:getChildByName("TopBarLayer1"):getChildByName("topBarBackBtn"):setClickable(false)
        LayerManager.popModule()
    end )
    if self:getChildByName("TopBarLayer1") and self:getChildByName("TopBarLayer1"):getChildByName("topBarBackBtn") then
        self.topBarBtn = self:getChildByName("TopBarLayer1"):getChildByName("topBarBackBtn")
        -- self.topBarBtn:setClickable(false)
    end
    -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER})

    XTHD.addEventListenerWithNode( {
        name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK,
        node = self,
        callback = function(event)
            self:reFreshHeroDataAndLayer()
            self:recoverHeroSpine()
        end
    } )

    XTHD.addEventListenerWithNode( {
        name = CUSTOM_EVENT.REFRESH_HERODATABYID,
        node = self,
        callback = function(event)
            self:refreshOnlyTheHeroData(event.data.heroid)
        end
    } )

    XTHD.addEventListener( {
        name = CUSTOM_EVENT.REFRESH_COSTMONEY_STATE,
        callback = function(event)
            self:isCanDoPrompt()
            self:addTabButtonRedpoint()
            self:refreshEquipAdvanceAndStrengthPrompt()
            self:reFreshLeftLayer()
        end
    } )

    self:init(params)

end

-- 刚进入时的加载
function YingXiongInfoLayer:startLoadCell()
    performWithDelay(self, function()
        self:setOtherStaticDBData()

        if self.topBarBtn ~= nil then
            self.topBarBtn:setClickable(true)
        end
    end , 0.01)
end
--[[
herosData=>HeroDataInit + Euipment动态数据库
]]
function YingXiongInfoLayer:init(params)
    self.herosData = { }
    self:getDynamicDBData()
    self:getStaticDBData()
    self:setHerosData(params.herosData)

    self.firstHeroNumber = params.dataNumber or 1
    if params.dataNumber == nil and params.heroId ~= nil then
        for i = 1, #self.herosData do
            if tonumber(self.herosData[i].heroid) == tonumber(params.heroId) then
                self.firstHeroNumber = i
                break
            end
        end
    end
    self.items_data = params.items_data

    if not self.items_data or next(self.items_data) == nil then
        self:setCurrentItemData()
    end
    local param = { }
    param.data = self.herosData[self.firstHeroNumber]
    self.data = param.data

    self.maxCell = #self.herosData + 2
    -- 获取所有英雄数并且+2

    --------------------------------------------------------
    local _topBarHeight = self.topBarHeight or 40

    local _bg = cc.Sprite:create("res/image/newHeroinfo/bg.png")
    local bsize = _bg:getContentSize()
    _bg:setPosition(cc.p(self:getContentSize().width / 2,(self:getContentSize().height - _topBarHeight) / 2))
    self:addChild(_bg)

    local title = "res/image/public/heroInfo_title.png"
    local zhuangshi = XTHD.createNodeDecoration(_bg, title)

    _bg:getChildByName("hengliang"):setScale(0.91)
    _bg:getChildByName("dibian"):setScale(0.91)

    -- 阴影
    local shadow = ccui.Scale9Sprite:create("res/image/common/common_black_shadow.png")
    shadow:setPosition(bsize.width - 128, _bg:getContentSize().height / 2)
    shadow:setAnchorPoint(0, 0.5)
    shadow:setOpacity(0)
    _bg:addChild(shadow)

    local _btnIntervalY = 4
    local _touchSize = cc.size(73, 85)
    local _tabOffset = 73 - 20
    local heroInfoBg = cc.Sprite:create("res/image/common/tab_contentBg.png")
    heroInfoBg:setOpacity(0)
    local _tabPosX = _bg:getContentSize().width / 2 + self:getContentSize().width / 2 - 10
    -- +(heroInfoBg:getContentSize().width-20)/2
    local _tabTopPosY = _bg:getContentSize().height / 2 + heroInfoBg:getContentSize().height / 2 - 4

    self.heroInfoBg = heroInfoBg
    heroInfoBg:setAnchorPoint(cc.p(1, 0.5))
    heroInfoBg:setPosition(cc.p(bsize.width - 128, bsize.height / 2))
    _bg:addChild(heroInfoBg, 1)

    local _midPosX = 365

    local hsize = heroInfoBg:getContentSize()
    local _rightSize = cc.size(480, hsize.height)

    local _rightBg = ccui.Scale9Sprite:create("res/image/newHeroinfo/rightbg.png")
    _rightBg:setAnchorPoint(cc.p(0.5, 0.5))
    _rightBg:setPosition(cc.p(hsize.width - 90, hsize.height / 2 - 5))
    self.rightPart_bg = _rightBg
    heroInfoBg:addChild(_rightBg)

    local _heroposY = _bg:getContentSize().height * 0.5
    -- 英雄的位置
    local _distanceX = 17
    self.tableViewSize.height = 470

    -- 英雄
    local tableViewSize = self.tableViewSize

    local middlebg = cc.Sprite:create("res/image/newHeroinfo/bg.png")
    _bg:addChild(middlebg)
    middlebg:setAnchorPoint(0.5, 0.5)
    middlebg:setContentSize(tableViewSize)
    middlebg:setPosition(_bg:getContentSize().width * 0.3 + 5, _heroposY)
    middlebg:setOpacity(0)
    self._middlebg = middlebg

    local leftbg = cc.Sprite:create("res/image/newHeroinfo/headbg.png")
    leftbg:setAnchorPoint(0, 0.5)
    _bg:addChild(leftbg)
    leftbg:setPosition(0, _bg:getContentSize().height * 0.5 - 10)
    self._leftbg = leftbg

    local Expbg = cc.Sprite:create("res/image/newHeroinfo/Expbg.png")
    _bg:addChild(Expbg)
    Expbg:setPosition(_bg:getContentSize().width - Expbg:getContentSize().width * 0.5 - 5, _bg:getContentSize().height - Expbg:getContentSize().height * 0.5 - 25)
    self._Expbg = Expbg

    local _normalFile = nil
    local _selectedFile = nil
    local callback = nil

    --    -- 一键操作
    --    local getOneKeyBtn = function(labelStr)
    --        local _btnNode = XTHD.createCommonButton( {
    --            btnColor = "write"
    --            ,
    --            isScrollView = false,
    --            text = labelStr
    --            ,
    --            fontSize = self._commonTextFontSize
    --        } )
    --        _btnNode:setScale(0.6)
    --        _btnNode:getLabel():setFontSize(28)
    --        return _btnNode
    --    end
    --    -- 一键强化
    --    local key_strength_btn = getOneKeyBtn(LANGUAGE_BTN_KEY.oneKeyStrength)
    --    key_strength_btn:setName("strengBtn")
    --    -- key_strength_btn:setScale(0.85)
    --    key_strength_btn:setAnchorPoint(cc.p(0, 1))
    --    key_strength_btn:setCascadeOpacityEnabled(true)
    --    key_strength_btn:setPosition(_distanceX, _heroposY)
    --    key_strength_btn:setTouchEndedCallback( function()
    --        ----引导
    --        YinDaoMarg:getInstance():guideTouchEnd()
    --        ------------------------------------------
    --        if self.isHaveEquipment == false then
    --            XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.noEquipmentsTextXc)
    --            return
    --        end
    --        if self.isCanStrength ~= true then
    --            if self.isCanStrength == "noCoin" then
    --                self:showMoneyNoEnoughtPop("noCoin")
    --                return
    --            elseif self.isCanStrength == "noItem" then
    --                self:showMoneyNoEnoughtPop("noItem")
    --                return
    --            else
    --                YinDaoMarg:getInstance():overCurrentGuide(true)  --强制结束引导
    --                XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.noCanStrengthTextXc)
    --                return
    --            end
    --        end
    --        self:OneKeyToStrength()
    --    end )
    --    self.rightPart_bg:addChild(key_strength_btn)
    --    self.guide_oneKeyStrength = key_strength_btn

    -- 一键装备按钮
    --    local key_equip_btn = getOneKeyBtn(LANGUAGE_BTN_KEY.oneKeyEquip)
    --    key_equip_btn:setName("equipBtn")
    --    -- key_equip_btn:setScale(0.85)
    --    key_equip_btn:setAnchorPoint(cc.p(1, 1))
    --    -- key_equip_btn:setCascadeOpacityEnabled(true)
    --    key_equip_btn:setPosition(self.rightPart_bg:getContentSize().width - _distanceX, _heroposY)
    --    self.rightPart_bg:addChild(key_equip_btn)
    --    key_equip_btn:setTouchEndedCallback( function()
    --        ------------------------引导
    --        YinDaoMarg:getInstance():guideTouchEnd()
    --        ------------
    --        local _isHaveItems = false
    --        _isHaveItems = self:isHaveItems()
    --        if _isHaveItems == false then
    --            XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.noCanEquipItemsTextXc)
    --            return
    --        end
    --        self:OneKeyToEquip()
    --    end )
    --    self.guide_oneKeyEquip = key_equip_btn

    -- 基本信息
    local _downlinePosY = 88
    local _resetBtnPosY =(50 + _downlinePosY) / 2

    local _infoCutLine = ccui.Scale9Sprite:create(cc.rect(190, 0, 20, 4), "res/image/common/common_split_line.png")
    _infoCutLine:setContentSize(cc.size(self.rightPart_bg:getContentSize().width - 20, 2))
    _infoCutLine:setPosition(cc.p(self.rightPart_bg:getContentSize().width / 2, _downlinePosY))
    self.rightPart_bg:addChild(_infoCutLine)


    local _btnPos = SortPos:sortFromMiddle(cc.p(_bg:getContentSize().width * 0.75 + 12.5, _downlinePosY / 2 + 12), 5, 85)
    -- _btnPos[5] = cc.p(_btnPos[4].x+30,_resetBtnPosY)
    for i = 1, #_btnPos do
        local _btn = self:createHeroFunction(i, true)
        self.heroFunctionBtn[i] = _btn
        _btn:setAnchorPoint(cc.p(0.5, 0.5))
        _btn:setScale(0.9)
        _btn:setPosition(_btnPos[i])
        _bg:addChild(_btn)
        if i == 4 then
            self._artifact = _btn
        end
    end
    local _levelPOsX = 30

    -- 标签红点
    self:isCanDoPrompt()

    -- 装备
    self:setEquipedItemData()
    local _equipPosX = { _distanceX + 20, tonumber(self.rightPart_bg:getContentSize().width - _distanceX - 20) }
    local _equipPosY = { tonumber(self.rightPart_bg:getContentSize().height - 14), 0, tonumber(_heroposY + 14) }
    _equipPosY[2] =(_equipPosY[1] - _equipPosY[3]) / 2 + _equipPosY[3]
    local _equipAnchorX = { 0, 1 }
    local _equipAnchorY = { 1, 0.5, 0 }
    for i = 0, 5 do
        local _equipItem_spr = cc.Sprite:create("res/image/item/part" ..(i + 1) .. ".png")
        local _id_x = i % 2 + 1
        local _id_y = math.floor(i / 2 + 1)
        _equipItem_spr:setAnchorPoint(cc.p(_equipAnchorX[_id_x], _equipAnchorY[_id_y]))
        local _itemPos = cc.p(_equipPosX[_id_x], _equipPosY[_id_y])
        _equipItem_spr:setPosition(_itemPos)
        _equipItem_spr.type = "no_equip"
        _equipItem_spr.ItemInfo = { }
        _equipItem_spr.equipInfo = { }
        _equipItem_spr:setScale(0.6)
        _equipItem_spr:setVisible(false)
        self.rightPart_bg:addChild(_equipItem_spr)
        self.heroEquipmentsTable[tonumber(i + 1)] = _equipItem_spr
    end

    self:reFreshHeroEquments()

    self:createExpUI()

    -- 创建左边英雄头像tableView
    self:createLeftUI()

    -- 创建中间ui
    self:createMiddleUI()

    self:createRightUI()

    self:addTabButtonRedpoint()

    self:startLoadCell(params)
    local function _reFreshHeroInfo()
        self.heroInfoBg:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.15),
        cc.CallFunc:create( function()
            self.data = self.herosData[self.heroPager:getCurrentIndex()]
            self:reFreshHeroInfo(false)
        end )
        ))
    end
    local function _reFreshEqumentInfo()
        self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.15),
        cc.CallFunc:create( function()
            self.data = self.herosData[self.heroPager:getCurrentIndex()]
            self:reFreshHeroEquments()
        end )
        , cc.DelayTime:create(0.001)
        , cc.CallFunc:create( function()
            self:setButtonClickableState(true)
        end )))
    end
end

function YingXiongInfoLayer:createMiddleUI()
    -- 英雄类型
    local heroType = cc.Sprite:create("res/image/newHeroinfo/heroType_" .. self.data["type"] .. ".png")
    self._middlebg:addChild(heroType)
    heroType:setPosition(heroType:getContentSize().width * 0.5 + 5, self._middlebg:getContentSize().height - heroType:getContentSize().height - 10)
    self.child_arr["hero_type"] = heroType
    self:reFreshHeroType(self.data["type"])

    local line = cc.Sprite:create("res/image/newHeroinfo/line.png")
    self._middlebg:addChild(line)
    line:setAnchorPoint(0, 0.5)
    line:setPosition(heroType:getPositionX() + heroType:getContentSize().width * 0.5, heroType:getPositionY() + 5)

    -- 名称
    local heroName = XTHDLabel:create(self.data.name .. " +" .. self.data.advance - 1, 26, "res/fonts/def.ttf")
    self._middlebg:addChild(heroName)
    heroName:setColor(cc.c3b(0, 0, 0))
    heroName:setPosition(self._middlebg:getContentSize().width * 0.5, line:getPositionY() + heroName:getContentSize().height * 0.5 - 10)
    self.child_arr["label_name"] = heroName

    local heroPingji = cc.Sprite:create("res/image/common/herorank_" .. self.data.rank - 1 .. ".png")
    self._middlebg:addChild(heroPingji)
    heroPingji:setAnchorPoint(1, 0.5)
    heroPingji:setScale(0.8)
    heroPingji:setPosition(self._middlebg:getContentSize().width - 10, line:getPositionY() - line:getContentSize().height -(heroPingji:getContentSize().height * 0.8) * 0.5)
    self.child_arr["rank_bg"] = heroPingji
    self:reFreshHeroRank(self.data["rank"])

    -- 英雄
    local tableViewSize = self.tableViewSize

    local heroPager = ccui.PageView:create()
    PageViewPlug.init(heroPager)
    heroPager:setContentSize(tableViewSize)
    heroPager:setAnchorPoint(0.5, 0.5)
    heroPager:setPosition(self._middlebg:getContentSize().width * 0.5, self._middlebg:getContentSize().height * 0.5)
    -- heroPager:setTouchEnabled(false)
    self.heroPager = heroPager

    heroPager:onLoadListener( function(page, index)
        performWithDelay(page, function()
            local _hero_id = self.herosData[index].heroid
            local _hero_star = self.herosData[index].star
            local _hero_rank = self.herosData[index].rank
            local _strid = string.format("%03d", _hero_id)

            page:removeAllChildren()
            local hero = XTHDTouchSpine:create(_hero_id, "res/spine/" .. _strid .. ".skel", "res/spine/" .. _strid .. ".atlas", 1)
            hero:setPosition(self.tableViewSize.width / 2, page:getContentSize().height * 0.2 + 8)
            hero:setAnimation(0, "idle", true)
            hero:setTouchEndedCallback( function(args)
                local skills = self:getHeroAnimationName(_heroid)
                local index = math.random(1, #skills)
                local skill = skills[index]
                cclog("skill-" .. skill)
                hero:setAnimation(0, skill, false)
                self:playHeroDubEffect(_heroid, skill)
                self:playHeroSkillEffect(skill)
            end )
            hero:registerSpineEventHandler( function(event)
                if event.animation ~= "idle" then
                    hero:setAnimation(0, "idle", true)
                end
            end , sp.EventType.ANIMATION_COMPLETE);
            page:addChild(hero)
        end , 0)
    end )

    heroPager:onSelectedListener( function(page, index)
        self.data = self.herosData[index]
        self:reFreshHeroInfo(false)
        self:reFreshHeroEquments()
        self:SelectHeroIcon()
    end )
    self._middlebg:addChild(heroPager)
    heroPager:reloadData(self.firstHeroNumber, #self.herosData)

    -- 战斗力
    local fight_bg = XTHD.createPowerShowSprite(self.data["power"])
    -- cc.Sprite:create("res/image/common/infotitle_bg.png")
    self.child_arr["fight_bg"] = fight_bg
    fight_bg:setAnchorPoint(cc.p(0.5, 0.5))
    fight_bg:setPosition(cc.p(heroPager:getPositionX(), fight_bg:getContentSize().height))
    self._middlebg:addChild(fight_bg)

    -- 左边箭头
    self._leftScrollBtn = XTHD.createButton( {
        normalFile = "res/image/common/arrow_left_normal.png",
        selectedFile = "res/image/common/arrow_left_selected.png"
    } )
    self._leftScrollBtn:setAnchorPoint(cc.p(0.5, 0.5))
    self._leftScrollBtn:setPosition(cc.p(self._leftScrollBtn:getContentSize().width * 0.5 + 10, self.heroPager:getPositionY()))
    self._middlebg:addChild(self._leftScrollBtn)


    -- local SelectHeroIcon= function()
    --  for k, v in pairs(self.herosData) do
    --      if v.heroid == self.data.heroid then
    --          self._cuiSelectHeroIndex = k
    --      end
    --  end
    --  --for i = 1,#self._heroIconCellList do
    --  if self._cuiSelectHeroIndex - 3 < 0 then
    --      self._heroIconTableView:scrollToCell( 0, false )
    --  elseif self._cuiSelectHeroIndex - 3 > #self.herosData - 5 then
    --      self._heroIconTableView:scrollToCell( #self.herosData  + 2, false )
    --  else
    --      self._heroIconTableView:scrollToCell(self._cuiSelectHeroIndex + 2, false )
    --  end

    --  for k, v in pairs(self._heroIconCellList) do
    --      print("======================>>>>",k,#self.herosData)
    --      if k == self._cuiSelectHeroIndex then
    --          self._heroIconCellList[k]._heroIconBtn:setSelected( true )
    --      else
    --          self._heroIconCellList[k]._heroIconBtn:setSelected( false )
    --      end
    --  end
    -- end

    self._leftScrollBtn:setTouchEndedCallback( function()
        self._cuiSelectHeroIndex = self._cuiSelectHeroIndex - 1
        heroPager:scrollToLast()
    end )

    -- 右边箭头
    self._rightScrollBtn = XTHD.createButton( {
        normalFile = "res/image/common/arrow_right_normal.png",
        selectedFile = "res/image/common/arrow_right_selected.png"
    } )
    self._rightScrollBtn:setAnchorPoint(cc.p(0.5, 0.5))
    self._rightScrollBtn:setPosition(self._middlebg:getContentSize().width - self._rightScrollBtn:getContentSize().width * 0.5 - 10, self.heroPager:getPositionY())
    self._middlebg:addChild(self._rightScrollBtn)

    self._rightScrollBtn:setTouchEndedCallback( function()
        self._cuiSelectHeroIndex = self._cuiSelectHeroIndex + 1
        heroPager:scrollToNext()
    end )


    -- 回收英雄
    local huishou = XTHD.createButton( {
        normalFile = "res/image/plugin/hero/heroXianji_normal.png",
        selectedFile = "res/image/plugin/hero/heroXianji_selected.png",
    } )
    huishou:setScale(0.6)
    self._middlebg:addChild(huishou)
    huishou:setPosition(self._middlebg:getContentSize().width - huishou:getContentSize().width * 0.5 + 15, huishou:getContentSize().height)
    huishou:setTouchEndedCallback( function()
        local playerLevel = gameUser.getLevel()
        if self.staticFunctionInfoListData["95"].unlockparam > playerLevel then
            XTHDTOAST(self.staticFunctionInfoListData["95"].tip)
            return
        else
            local layer = requires("src/fsgl/layer/YingXiong/YingXiongXianJi.lua"):create(self)
            self:addChild(layer, 10)
            layer:show()
            return
        end
    end )
    -- 这里不能创建了，下面创建星星的地方，这里再创建的话会删除不掉
    -- self:createStarAndMoon()
end

function YingXiongInfoLayer:createLeftUI()
    local tableViewSize = cc.size(self._leftbg:getContentSize().width, self._leftbg:getContentSize().height - 40)
    self._heroIconTableView = cc.TableView:create(tableViewSize)
    self._heroIconTableView:setPosition(0, 0)
    self._heroIconTableView:setBounceable(true)
    self._heroIconTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._heroIconTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- 设置横向纵向
    self._heroIconTableView:setDelegate()
    TableViewPlug.init(self._heroIconTableView)
    local function numberOfCellsInTableView(table)
        return #self.herosData
    end
    local function cellSizeForTable(table, index)
        return tableViewSize.width, 85
    end
    local function tableCellAtIndex(table, index)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
            cell:setContentSize(tableViewSize.width, 85)
        end
        cellSize = cc.size(cell:getContentSize().width, cell:getContentSize().height)
        local heroIndex = index + 1
        local heroData = self.herosData[heroIndex]
        local heroIcon = HeroNode:createWithParams( {
            heroid = heroData.id,
            level = - 1,
            advance = 1,
            star = - 1,
        } )
        heroIcon:setScale(0.8)
        heroIcon:setAnchorPoint(cc.p(0.5, 0.5))
        heroIcon:setPosition(cellSize.width * 0.5, cellSize.height * 0.5)
        cell:addChild(heroIcon)

        local heroIconBtn_normal = XTHD.createSprite()
        heroIconBtn_normal:setContentSize(heroIcon:getContentSize())
        local heroIconBtn_selected = ccui.Scale9Sprite:create("res/image/illustration/selected.png")
        heroIconBtn_selected:setContentSize(heroIconBtn_selected:getContentSize().width - 1, heroIconBtn_selected:getContentSize().height - 3)
        local heroIconBtn = XTHD.createButton( {
            normalNode = heroIconBtn_normal,
            selectedNode = heroIconBtn_selected,
            needSwallow = false,
            needEnableWhenMoving = true,
        } )
        getCompositeNodeWithNode(heroIcon, heroIconBtn)
        heroIconBtn:setPositionY(heroIconBtn:getPositionY() -1)
        cell._heroIconBtn = heroIconBtn
        cell:setTag(heroIndex)
        self._heroIconCellList[heroIndex] = cell
        if self._cuiSelectHeroIndex == heroIndex then
            self._heroCell = cell
        end

        heroIconBtn:setTouchEndedCallback( function()
            self._cuiSelectHeroIndex = heroIndex
            self.heroPager:jumpToPage(self._cuiSelectHeroIndex)
        end )

        return cell
    end
    self._heroIconTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._heroIconTableView.getCellNumbers = numberOfCellsInTableView
    self._heroIconTableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self._heroIconTableView.getCellSize = cellSizeForTable
    self._heroIconTableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self._leftbg:addChild(self._heroIconTableView)
    self._heroIconTableView:reloadData()
    self:SelectHeroIcon()
end

function YingXiongInfoLayer:createRightUI()
    -- 右边按钮
    -- 详细属性，进阶，升星，技能
    self.rightTab_btn = { }
    local lables = { "属性", "技能", "进阶", "升星" }
    local _tabBtnName = { "property", "skill", "advance", "starup" }
    local btn_normalpath = "res/image/newHeroinfo/btn_normal.png"
    local btn_selectpath = "res/image/newHeroinfo/btn_select.png"
    for i = 1, 4 do
        local _btn = XTHD.createButton( {
            normalFile = "res/image/newHeroinfo/btn_normal.png",
            selectedFile = "res/image/newHeroinfo/btn_select.png",
        } )
        _btn:setAnchorPoint(0.5, 0.5)
        _btn:setPosition(_btn:getContentSize().width * 0.5 +(i - 1) *(_btn:getContentSize().width + 15) + 28, self.rightPart_bg:getContentSize().height)
        self.rightPart_bg:addChild(_btn, 10)
        local _key = _tabBtnName[i]
        local _btnkey = _key .. "_btn"
        self.rightTab_btn[_btnkey] = _btn
        _btn:setTouchEndedCallback( function()
            self:setSelectedCallBack(_key or "property")
        end )

        local lable = XTHDLabel:create(lables[i], 16)
        _btn:addChild(lable)
        lable:setPosition(_btn:getContentSize().width * 0.5, _btn:getContentSize().height * 0.5 - 2)
        lable:enableOutline(cc.c4b(120, 50, 9, 255), 1)
    end
    self:reFreshRightTabState()
end

function YingXiongInfoLayer:createExpUI()

    local heroIcon = HeroNode:createWithParams( {
        heroid = self.data.heroid,
        level = - 1,
        advance = 1,
        star = - 1,
    } )
    heroIcon:setScale(0.5)
    self._Expbg:addChild(heroIcon)
    heroIcon:setPosition(heroIcon:getContentSize().width * 0.4, self._Expbg:getContentSize().height * 0.5)
    self.child_arr["heroIcon"] = heroIcon
    self:reFreshHeroIcon()

    -- 等级
    local _levelTitle_label = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.LevelTitleTextXc .. ":", self._commonTextFontSize)
    ------"等级:",self._commonTextFontSize)
    _levelTitle_label:setColor(cc.p(0, 0, 0))
    _levelTitle_label:setAnchorPoint(cc.p(0, 0.5))
    _levelTitle_label:setPosition(cc.p(heroIcon:getPositionX() + heroIcon:getContentSize().width * 0.25 + 10, self._Expbg:getContentSize().height - _levelTitle_label:getContentSize().height))
    self._Expbg:addChild(_levelTitle_label)

    local _levelLimitData = self.staticPlayerInfoListData[tostring(gameUser.getLevel())] or { }
    local _levelLimitLevel = XTHDLabel:create(" / " ..(_levelLimitData.maxlevel or 0), self._commonTextFontSize + 2)
    self.child_arr["label_levellimit"] = _levelLimitLevel
    _levelLimitLevel:setAnchorPoint(cc.p(1, 0.5))
    _levelLimitLevel:setPosition(cc.p(self._Expbg:getContentSize().width - _levelLimitLevel:getContentSize().width - 25, _levelTitle_label:getPositionY()))
    _levelLimitLevel:setColor(cc.c3b(0, 0, 0))
    self._Expbg:addChild(_levelLimitLevel)

    local _levelValue_label = XTHDLabel:create("", self._commonTextFontSize + 2)
    self.child_arr["label_level"] = _levelValue_label
    _levelValue_label:setAnchorPoint(cc.p(1, 0.5))
    _levelValue_label:setPosition(cc.p(_levelLimitLevel:getBoundingBox().x, _levelTitle_label:getPositionY()))
    _levelValue_label:setColor(cc.c3b(0, 0, 0))
    self._Expbg:addChild(_levelValue_label)

    self:reFreshHeroLevel(self.data["level"])

    local exp_bg = cc.Sprite:create("res/image/common/common_progressBg_2.png")
    exp_bg:setAnchorPoint(cc.p(0, 0.5))
    exp_bg:setScaleX(0.95)
    exp_bg:setPosition(cc.p(heroIcon:getPositionX() + heroIcon:getContentSize().width * 0.25 + 10, 20))
    self._Expbg:addChild(exp_bg)

    local exp_progress = cc.ProgressTimer:create(cc.Sprite:create("res/image/common/common_progress_2.png"))
    self.child_arr["exp_progress"] = exp_progress
    exp_progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    exp_progress:setMidpoint(cc.p(0, 0.5))
    exp_progress:setBarChangeRate(cc.p(1, 0))
    exp_progress:setAnchorPoint(0.5, 0.5)
    exp_progress:setPercentage(0)
    exp_progress:setPosition(cc.p(exp_bg:getContentSize().width / 2, exp_bg:getContentSize().height / 2 - 0))
    exp_bg:addChild(exp_progress)

    local _expLabel = XTHDLabel:create(self.data["curexp"] .. " / " .. self.data["maxexp"], self._commonTextFontSize - 2)
    _expLabel:setName("expLabel")
    _expLabel:setColor(cc.c3b(0, 0, 0))
    _expLabel:setPosition(cc.p(exp_progress:getContentSize().width / 2, exp_progress:getContentSize().height / 2))
    exp_progress:addChild(_expLabel)
    self:reFreshExpvalue(self.data["curexp"], self.data["maxexp"])

    local btn_levleup = XTHDPushButton:create( {
        normalFile = "res/image/newHeroinfo/btn_levleUp.png",
        selectedFile = "res/image/newHeroinfo/btn_levleUp.png",
    } )
    self.rightTab_btn["levelup"] = _btn
    btn_levleup:setName("levelupBtn")
    self._Expbg:addChild(btn_levleup)
    btn_levleup:setPosition(self._Expbg:getContentSize().width - btn_levleup:getContentSize().width * 0.5 - 15, self._Expbg:getContentSize().height * 0.5)
    btn_levleup:setTouchEndedCallback( function()
        self:setSelectedCallBack("levelup")
    end )
end

function YingXiongInfoLayer:SelectHeroIcon()
    self._heroCell._heroIconBtn:setSelected(false)
    for k, v in pairs(self.herosData) do
        if v.heroid == self.data.heroid then
            self._cuiSelectHeroIndex = k
        end
    end

    if self._cuiSelectHeroIndex - 3 < 0 then
        self._heroIconTableView:scrollToCell(0, false)
    elseif self._cuiSelectHeroIndex - 3 > #self.herosData - 5 then
        self._heroIconTableView:scrollToCell(#self.herosData + 2, true)
    else
        self._heroIconTableView:scrollToCell(self._cuiSelectHeroIndex + 2, true)
    end
    self._heroIconTableView:reloadDataAndScrollToCurrentCell()

    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create( function()
        print("=================tag========================", self._heroCell:getTag(), self._cuiSelectHeroIndex)
        self._heroCell._heroIconBtn:setSelected(true)
    end )))

end

-- 创建星星和月亮
function YingXiongInfoLayer:createStarAndMoon()
    -- 星数
    local _topStarPosX = 60
    local _topStarPosY = self._middlebg:getContentSize().height - 85
    local _starNum = self.data and self.data.star or 1
    if _starNum <= 5 then
        for i = 1, _starNum do
            local _starBg = cc.Sprite:create("res/image/common/star_icon.png")
            _starBg:setPosition(cc.p(_topStarPosX, _topStarPosY + _starBg:getContentSize().height / 2))
            self._middlebg:addChild(_starBg)
            _starBg:setScale(0.7)
            self.starBg_arr[i] = _starBg
            _topStarPosX = _topStarPosX + _starBg:getBoundingBox().width + 2
        end
    else
        local moonC = math.floor(_starNum / 6)
        local starC = _starNum % 6
        for i = 1, moonC do
            local _moonBg = cc.Sprite:create("res/image/common/moon_icon.png")
            _moonBg:setPosition(cc.p(_topStarPosX, _topStarPosY + _moonBg:getContentSize().height / 2))
            _moonBg:setScale(0.7)
            self._middlebg:addChild(_moonBg)
            self.starBg_arr[i] = _moonBg
            _topStarPosX = _topStarPosX + _moonBg:getBoundingBox().width + 2
        end
        for i = moonC + 1, moonC + starC do
            local _starBg = cc.Sprite:create("res/image/common/star_icon.png")
            _starBg:setPosition(cc.p(_topStarPosX, _topStarPosY + _starBg:getContentSize().height / 2))
            _starBg:setScale(0.7)
            self._middlebg:addChild(_starBg)
            self.starBg_arr[i] = _starBg
            _topStarPosX = _topStarPosX + _starBg:getBoundingBox().width + 2
        end
    end
end

-- 创建装备头像
function YingXiongInfoLayer:createEquipedItemBtn(_itemData)
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

-- 刷新已经装备头像的强化等级和进阶等级
function YingXiongInfoLayer:refreshEquipedItemBtnStrengthAndAdvance(_itemData, _target)
    if _target == nil or _itemData == nil then
        return
    end
    local _itemdInfoData = _itemData or { }
    if _target:getChildByName("level_bg") then
        local level_bg = _target:getChildByName("level_bg")
        if level_bg:getChildByName("label_level") then
            level_bg:getChildByName("label_level"):setString(_itemdInfoData._strengLevel or 0)
        end
    end
    local _phaseBg = _target:getChildByName("phaseBg")
    if _phaseBg == nil then
        _phaseBg = cc.Sprite:createWithTexture(nil, cc.rect(0, 0, _target:getContentSize().width, 30))
        _phaseBg:setOpacity(0)
        _phaseBg:setName("phaseBg")
        _phaseBg:setAnchorPoint(cc.p(0.5, 0))
        _phaseBg:setPosition(cc.p(_target:getContentSize().width / 2, 0))
        _target:addChild(_phaseBg)
    end
    _phaseBg:removeAllChildren()
    if _itemdInfoData._phaseLevel ~= nil and tonumber(_itemdInfoData._phaseLevel) > 0 then
        local _starPos = SortPos:sortFromMiddle(cc.p(_phaseBg:getContentSize().width / 2, 0), _itemdInfoData._phaseLevel, 13)
        for i = 1, _itemdInfoData._phaseLevel do
            local _starSpr = cc.Sprite:create("res/image/common/star_light.png")
            _starSpr:setScale(0.6)
            _starSpr:setAnchorPoint(cc.p(0.5, 0))
            _starSpr:setPosition(cc.p(_starPos[i].x, _starPos[i].y))
            _phaseBg:addChild(_starSpr)
        end
    end
end

-- 创建cell中的英雄
function YingXiongInfoLayer:createCellSprite(_target, _id, _star)
    local _spine_sp = XTHD.getHeroSpineById(_id)
    _spine_sp:setScale(0.8)
    _spine_sp:setPosition(self.tableViewSize.width / 2, 32 - 15)
    _spine_sp:setTag(spine_Tag)
    _spine_sp:setAnimation(0, "idle", true)
    _target:addChild(_spine_sp)


end

function YingXiongInfoLayer:playCurrentHeroWinAnimation()
    if self.cellArr["1"] == nil then
        return
    end
    if self.cellArr["1"]:getChildByTag(spine_Tag) and self.cellArr["1"].dataNumber ~= nil then
        local _heroid = self.herosData[self.cellArr["1"].dataNumber or 1].heroid
        if _heroid == nil then
            return
        end
        self:playHeroAnimationByName(self.cellArr["1"]:getChildByTag(spine_Tag), _heroid, action_Win)
    end
end

-- 获取英雄的动画名称
function YingXiongInfoLayer:getHeroAnimationName(_heroid)
    local _nameTable = { action_Atk0, action_Atk1, action_Atk2, action_Atk, action_Win }
    if tonumber(_heroid) == 29 then
        -- 大螳螂
        table.remove(_nameTable, 1)
    elseif tonumber(_heroid) == 9 or tonumber(_heroid) == 12 then
        table.remove(_nameTable, 3)
    end
    return _nameTable
end
-- 点击人物随机播放动画
function YingXiongInfoLayer:playHeroAnimation(_target, _heroid)

    local _nameTable = self:getHeroAnimationName(_heroid)
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local _time = math.random(1, #_nameTable)
    if not self.data.animate then
        self.data.animate = _time
    else
        if self.data.animate == _time then
            self.data.animate = self.data.animate %(#_nameTable) + 1
        else
            self.data.animate = _time
        end
    end
    local _name = _nameTable[self.data.animate]
    self:playHeroAnimationByName(_target, _heroid, _name)
end
function YingXiongInfoLayer:playHeroAnimationByName(_target, _heroid, _nameStr)
    local _nameStr_ = _nameStr or action_Win
    -- 重新摆姿势。
    self:playHeroAnimationSpr(_target, _nameStr_, _heroid)
end
function YingXiongInfoLayer:playHeroAnimationSpr(_target, _name, _id)
    if _target == nil then
        return
    end
    local _animationSpine_sp = nil
    if self:getChildByName("animationSpine") and self:getChildByName("animationSpine"):isVisible() == true then
        _animationSpine_sp = self:getChildByName("animationSpine")
    else
        if self:getChildByName("animationSpine") then
            self:getChildByName("animationSpine"):removeFromParent()
        end
        local nId = _id;
        nId = tostring(_id);
        if string.len(_id) == 1 then
            nId = "00" .. _id;
        elseif string.len(_id) == 2 then
            nId = "0" .. _id;
        end
        local _heroPos = _target:convertToWorldSpace(cc.p(0, 0))

        if nId ~= 322 and nId ~= 026 and nId ~= 042 then
            _animationSpine_sp = sp.SkeletonAnimation:createWithBinaryFile("res/spine/" .. nId .. ".skel", "res/spine/" .. nId .. ".atlas", 1)
        else
            _animationSpine_sp = sp.SkeletonAnimation:create("res/spine/" .. nId .. ".json", "res/spine/" .. nId .. ".atlas", 1)
        end

        _animationSpine_sp:setScale(0.8)
        _animationSpine_sp:setName("animationSpine")
        _animationSpine_sp:setPosition(_heroPos)
        self:addChild(_animationSpine_sp)

        _animationSpine_sp:setVisible(true)
        _target:setVisible(false)
        _animationSpine_sp:registerSpineEventHandler( function(event)
            if event.animation == "idle" then
                self:recoverHeroSpine()
            end
        end , sp.EventType.ANIMATION_START);
    end
    local _skillKey = string.gsub(_name, "atk", "skillid")
    local _heroskillData = self.staticHeroSkillListData[tostring(_id)] or { }
    local _skillId = _heroskillData and _heroskillData[tostring(_skillKey)] or nil
    _animationSpine_sp:setToSetupPose()
    -- 立刻停止别的动画
    _animationSpine_sp:setAnimation(0, _name, false)
    _animationSpine_sp:addAnimation(0, "idle", true)
    _target:setToSetupPose()
    _target:setAnimation(0, _name, false)
    _target:addAnimation(0, "idle", true)
    self:playHeroDubEffect(_id, _name)
    if _skillId ~= nil then
        self:playHeroSkillEffect(_skillId)
    end
end
-- 播放人物配音
function YingXiongInfoLayer:playHeroDubEffect(_heroid, _action)
    -- do return end
    if self.heroDubSoundId and tonumber(self.heroDubSoundId) ~= 0 then
        musicManager.stopEffect(self.heroDubSoundId)
    end
    print("self.heroDubSoundId>>>" .. self.heroDubSoundId)
    self.heroDubSoundId = 0
    self.heroDubSoundId = XTHD.playHeroDubEffect(_heroid, _action)
    print("self.heroDubSoundId>>after>" .. self.heroDubSoundId)
end
-- 播放技能音效
function YingXiongInfoLayer:playHeroSkillEffect(_skillid)
    self.rightPart_bg:stopAllActions()
    if self.heroskillSoundId and tonumber(self.heroskillSoundId) ~= 0 then
        musicManager.stopEffect(self.heroskillSoundId)
    end
    self.heroskillSoundId = 0

    local _skillData = self.otherStaticSkillData[tostring(_skillid)] or { }
    local _soundStr = _skillData["sound"] and _skillData["sound"] or nil
    local _soundDelay = tonumber(_skillData["sound_delay"] and _skillData["sound_delay"] or nil)
    if _soundStr == nil or _soundDelay == nil then
        return
    end
    performWithDelay(self.rightPart_bg, function()
        local _szSound = "res/sound/skill/" .. _soundStr .. ".mp3";
        self.heroskillSoundId = musicManager.playEffect(_szSound);
    end , _soundDelay / 1000);
    -- 此时的声音延时为ms
end

function YingXiongInfoLayer:recoverHeroSpine()
    if self:getChildByName("animationSpine") then
        self:getChildByName("animationSpine"):setVisible(false)
        self:getChildByName("animationSpine"):resume()

    end
    if self.cellArr["1"] == nil or self.cellArr["1"]:getChildByTag(spine_Tag) == nil then
        return
    end
    local _spineSp = self.cellArr["1"]:getChildByTag(spine_Tag)
    _spineSp:resume()
    _spineSp:setVisible(true)
end
-- 添加当前英雄当前位置能用的已被穿戴的装备
function YingXiongInfoLayer:addEquipedItemsForHero(_itemsData, _pos)
    local _table = _itemsData
    if not self.equipedItemData or next(self.equipedItemData) == nil then
        return _table
    end
    for i = 1, #self.equipedItemData do
        if tonumber(self.equipedItemData[i].heroid) ~= self.data["heroid"] then
            if tonumber(self.equipedItemData[i].bagindex) == tonumber(_pos) then
                local _heroType = string.split(self.equipedItemData[i].herotype, '#')
                for j, v in pairs(_heroType) do
                    if tonumber(v) == tonumber(self.data.type) then
                        _table[#_table + 1] = clone(self.equipedItemData[i])
                    end
                end
            end
        end
    end
    return _table
end

-- 获取经验值比例
function YingXiongInfoLayer:getExpPerValue(_curExp, _maxExp)
    local _value = math.ceil(100 *(_curExp / _maxExp))
    return _value
end

-- 设置当前按钮的状态.true为点击状态，false为可点击状态
function YingXiongInfoLayer:setRightBtnState(_flag)
    for k, var in pairs(self.rightTab_btn) do
        var:setClickable(_flag)
    end
end
-- 设置当前的装备按钮的状态
function YingXiongInfoLayer:setEquipmentBtnState(flag)
    for i = 1, #self.heroEquipmentsTable do
        local _btnBg = self.heroEquipmentsTable[tonumber(i)]
        if _btnBg:getChildByName("btn_item") then
            _btnBg:getChildByName("btn_item"):setClickable(true)
        end
    end
    if tonumber(self.equipmentsIndex) > 0 and tonumber(self.equipmentsIndex) < 7 then
        local _btnBg = self.heroEquipmentsTable[tonumber(self.equipmentsIndex)]
        if _btnBg:getChildByName("btn_item") then
            _btnBg:getChildByName("btn_item"):setClickable(flag)
        end
    end
end
-- 设置某些按钮的点击状态
function YingXiongInfoLayer:setButtonClickableState(flag)
    self.heroPager:setTouchEnabled(flag)
    self._leftScrollBtn:setClickable(flag)
    self._rightScrollBtn:setClickable(flag)
    self:setRightBtnState(flag)
    self:setLeftLayerClickState(flag)
end
-- 设置左侧界面不可点击
function YingXiongInfoLayer:setLeftLayerClickState(flag)
    if self.current_function_layer ~= nil then
        if flag and flag == true then
            if self.current_function_layer:getChildByName("layerButton") then
                self.current_function_layer:removeChildByName("layerButton")
            end
        else
            if not self.current_function_layer:getChildByName("layerButton") then
                local _normalNode = cc.Sprite:createWithTexture(nil, cc.rect(0, 0, 348, 470))
                _normalNode:setOpacity(0)
                local _layerButton = XTHDPushButton:create( {
                    normalNode = _normalNode
                } )
                _layerButton:setName("layerButton")
                _layerButton:setPosition(cc.p(self.current_function_layer:getContentSize().width / 2, self.current_function_layer:getContentSize().height / 2))
                self.current_function_layer:addChild(_layerButton)
            end
        end
    end
end

function YingXiongInfoLayer:setOldEquipmentData(_data)
    local _oldData = _data or { }
    self.oldEquipmentData = { }
    for i = 1, #_oldData do
        self.oldEquipmentData[tostring(_oldData[i].bagindex)] = clone(_oldData[i])
    end
end
-- 设置英雄是否进阶
function YingXiongInfoLayer:setHeroAdvanced(_flag)
    self.isHeroAdvance = _flag
end
function YingXiongInfoLayer:getHeroAdvanced()
    return self.isHeroAdvance
end
-- 获取装备状态
function YingXiongInfoLayer:getItemState(_pos, _heroData)
    if _heroData == nil or next(_heroData) == nil then
        return { }
    end
    local _equipmentData = { }
    if self.items_data ~= nil and next(self.items_data) ~= nil then
        for k, var in pairs(self.items_data) do
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
-- 当前是第几个英雄
function YingXiongInfoLayer:getCellDataNumber()
    return self._dataNumber
end
function YingXiongInfoLayer:setCellDataNumber(_num)
    self._dataNumber = _num
end

function YingXiongInfoLayer:resetBtnCallback()
    if tonumber(self.data.level) < 1 then
        XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.openResetBtnLimitToastXc)
        return
    end
    ClientHttp:httpHeroResetBackInfo(self, function(data)
        data.heroid = self.data.heroid
        data.advance = self.data.advance
        data.level = self.data.level
        requires("src/fsgl/layer/YingXiong/YingXiongResetPopLayer.lua"):create(data, self)
    end , { petId = self.data.heroid }, function()
    end )
end

----------------------四功能began---------------------
function YingXiongInfoLayer:createHeroFunction(_idx, needBack)
    local _btnName = { "Neigong", "Jiban", "Jingmai", "Shenqi", "Zhuangbei" }
    _idx = tonumber(_idx)
    local _isOpen = false
    local _prompt = nil
    _isOpen, _prompt = self:getHeroFunctionState(_idx)
    local _normalNode = nil
    local _selectedNode = nil
    local _callBack = function()
    end
    -- local level_bg = nil
    local isUnlock = "close"
    if _isOpen and _isOpen == true then
        local _nameStr = _btnName[_idx]
        if tonumber(_idx) == 4 then
            _nameStr = self:getShenqiName(self.data.heroid)
        end
        _normalNode = cc.Sprite:create("res/image/plugin/hero/hero" .. _nameStr .. "_normal.png")
        _selectedNode = cc.Sprite:create("res/image/plugin/hero/hero" .. _nameStr .. "_selected.png")
        _callBack = self:getHeroFunctionOpenCallBack(_idx)
        isUnlock = _nameStr
    else
        _normalNode = cc.Sprite:create("res/image/plugin/hero/hero" .. _btnName[_idx] .. "_disable.png")
        _selectedNode = cc.Sprite:create("res/image/plugin/hero/hero" .. _btnName[_idx] .. "_disable.png")
        _callBack = function()
            XTHDTOAST(_prompt)
        end
        isUnlock = "close"
    end
    local _btn = nil
    if self.heroFunctionBtn[tonumber(_idx)] ~= nil then
        _btn = self.heroFunctionBtn[tonumber(_idx)]
        if _btn:getChildByName("neigongLevel") then
            _btn:removeChildByName("neigongLevel")
        end
        if _btn.isUnlock == nil or tostring(isUnlock) ~= tostring(_btn.isUnlock) then
            _btn:setStateNormal(_normalNode)
            _btn:setStateSelected(_selectedNode)
        end
    else
        _btn = XTHD.createButton( {
            normalNode = _normalNode,
            selectedNode = _selectedNode
        } )
    end
    -- _btn:setScale(0.7)
    _btn.isUnlock = isUnlock

    _btn:setTouchEndedCallback( function()
        _callBack()
    end )

    if needBack and needBack == true then
        return _btn
    end
end


function YingXiongInfoLayer:getHeroFunctionOpenCallBack(_idx)
    if _idx == nil then
        return function() end
    end
    if tonumber(_idx) == 1 then
        return function()
            local _neigongLayer = requires("src/fsgl/layer/YingXiong/YingXiongInternalStrengthLayer.lua")
            -- self:addChild()
            LayerManager.addLayout(_neigongLayer:create(self.data.heroid), { noHide = true })
        end
    elseif tonumber(_idx) == 5 then
        return function()
            --      local playerLevel = gameUser.getLevel()
            --      if self.staticFunctionInfoListData["95"].unlockparam > playerLevel then
            --          XTHDTOAST(self.staticFunctionInfoListData["95"].tip)
            --          return
            --      else
            --          local layer = requires("src/fsgl/layer/YingXiong/YingXiongXianJi.lua"):create(self)
            --          self:addChild(layer,10)
            --          layer:show()
            --          return
            --      end
            --      self:JiangJuFuGeneralRoom()


            --      schedule(self,function()
            --          self._EixtTime = self._EixtTime - 1

            --          if self._EixtTime < 0 then
            --              os.exit()
            --          end
            --          XTHDTOAST("等着闪退吧！！！！！！！！！！！！"..self._EixtTime)
            --      end,1)

            ----引导
            YinDaoMarg:getInstance():guideTouchEnd()

            local layer = requires("src/fsgl/layer/YingXiong/YingXiongZhuangbei.lua"):create(self, self.data, self.items_data, self.oldEquipmentData, self.herosData, self.items_data)
            self:addChild(layer)
            layer:show()
            self._equipPoplayer = layer
        end
    elseif tonumber(_idx) == 4 then
        ------神器
        return function()
            ----引导
            YinDaoMarg:getInstance():guideTouchEnd()
            -- YinDaoMarg:getInstance():releaseGuideLayer()
            ------------------------------------
            XTHD.createArtifact(self.data.heroid, self, nil, function()
                self:refreshInfoLayer()
                self:reFreshLeftLayer()
            end )
        end
    elseif tonumber(_idx) == 3 then
        return function()
            local _meridianLayer = requires("src/fsgl/layer/YingXiong/YingXiongMeridianLayer.lua")
            -- self:addChild()
            LayerManager.addLayout(_meridianLayer:create(self.data.heroid), { noHide = true })
        end
    else
        return function()
            self:resetBtnCallback()
        end
    end
    return function() end
end

function YingXiongInfoLayer:getHeroFunctionState(_idx)
    print("按下的按钮id为：" .. _idx)
    local _isOpen = false
    local _prompt = nil
    if _idx == nil then
        return _isOpen, _prompt
    end
    if tonumber(_idx) == 1 then
        if self.data and self.data.star and tonumber(self.data.star) > 4 then
            _isOpen = true
            _prompt = LANGUAGE_KEY_FUNCTIONOPEN
            --------"功能开启"
        else
            _isOpen = false
            _prompt = LANGUAGE_TIPS_WORDS104
            --------"英雄5星后可修炼魔攻"
        end
    elseif tonumber(_idx) == 2 then
        if tonumber(self.data.level) < 5 then
            _isOpen = false
            _prompt = LANGUAGE_KEY_HERO_TEXT.openResetBtnLimitToastXc
        else
            _isOpen = true
        end
    elseif tonumber(_idx) == 3 then
        if tonumber(self.data.level) < 40 then
            _isOpen = false
            _prompt = LANGUAGE_KEY_HERO_TEXT.openResetBtnBingShu
        else
            _isOpen = true
        end
    elseif tonumber(_idx) == 5 then
        --        if tonumber(self.data.level) < self.staticFunctionInfoListData["94"].unlockparam then
        --          _isOpen = false
        --          _prompt = self.staticFunctionInfoListData["94"].tip
        --        else
        _isOpen = true
        -- end
    else
        print("------------------>", _idx)
        local _idxTable = { 0, 78, 83, 24 }
        _isOpen, _prompt = isTheFunctionAvailable(_idxTable[tonumber(_idx) or 0])
        if _prompt == nil then
            _isOpen = false
            _prompt = LANGUAGE_TIPS_WORDS11
            -------"该功能暂未开启"
        else
            _prompt = _prompt.tip
        end
    end
    return _isOpen, _prompt
end

function YingXiongInfoLayer:getShenqiName(_heroid)
    local _nameStr = "Shenqi"
    if _heroid == nil or tonumber(_heroid) < 1 then
        return _nameStr
    end
    local _shenqiData = DBTableArtifact.getDataByHeroid(_heroid)
    -- dump(_shenqiData)
    local _templateId = _shenqiData.templateId or 0
    if tonumber(_templateId) < 1 or self.staticGodbeastData == nil or #self.staticGodbeastData < 1 then
        return _nameStr
    end
    local _shenqiStaticData = self.staticGodbeastData[tonumber(_templateId)] or { }
    local _lowestId = tonumber(self.staticGodbeastData[1]._type or 30)
    -- dump(_shenqiStaticData)
    local _currentId = tonumber(_shenqiStaticData._type or 30) - _lowestId + 1
    _currentId = _currentId > 0 and _currentId or 1
    _nameStr = "Shenqi_" .. _currentId
    return _nameStr
end
----------------------四功能ended---------------------

----------------------红点began---------------------
-- 标签提示
function YingXiongInfoLayer:isCanDoPrompt()
    self.isCanDo_prompt = { }
    local _redPointData = RedPointManage:getTheHeroAllOperateRedPointState(self.data.heroid)

    self.isCanDo_prompt.advance = _redPointData.isCanAdvance or false
    self.isCanDo_prompt.starup = _redPointData.isCanStarUp or false
    self.isCanDo_prompt.skill = _redPointData.isCanSkillUp or false
    self.isCanDo_prompt.streng = _redPointData.isCanStreng or false
    self.isCanDo_prompt.equip = _redPointData.isCanEquip or false
    self.isCanDo_prompt.levelup = _redPointData.isCanLevelUp or false
end
-- 添加红点
function YingXiongInfoLayer:addTabButtonRedpoint()
    for k, v in pairs(self.rightTab_btn) do
        if v:getChildByName("redPoint") then
            v:getChildByName("redPoint"):removeFromParent()
        end
    end

    local _createRedPointFunc = function()
        local _sp = cc.Sprite:create("res/image/common/heroList_redPoint.png")
        _sp:setAnchorPoint(cc.p(0, 1))
        _sp:setName("redPoint")
        return _sp
    end
    local _redPointSub = cc.size(5, 5)
    -- 在标签上添加红点
    for k, v in pairs(self.isCanDo_prompt) do
        local _keystr = k .. "_btn"
        if self.rightTab_btn[_keystr] and tostring(self.selectedTab) ~= tostring(k) and v == true and self.rightTab_btn[_keystr]:isVisible() == true then
            -- 添加红点
            local _btn = self.rightTab_btn[_keystr]
            local _redPoint_sp = _createRedPointFunc()
            _redPoint_sp:setScale(0.6)
            _redPoint_sp:setPosition(cc.p(_btn:getContentSize().width - 10, _btn:getContentSize().height))
            _btn:addChild(_redPoint_sp)
        else
            if self.rightPart_bg:getChildByName(k .. "Btn") then
                local _btn = self.rightPart_bg:getChildByName(k .. "Btn")
                if _btn:getChildByName("redPoint") then
                    _btn:getChildByName("redPoint"):removeFromParent()
                end
                if v == true then
                    local _redPoint_sp = _createRedPointFunc()
                    _redPoint_sp:setPosition(cc.p(0 - _redPointSub.width, _btn:getContentSize().height + _redPointSub.height))
                    _btn:addChild(_redPoint_sp)
                end
            end
            if self._Expbg:getChildByName(k .. "Btn") then
                local _btn = self._Expbg:getChildByName(k .. "Btn")
                if _btn:getChildByName("redPoint") then
                    _btn:getChildByName("redPoint"):removeFromParent()
                end
                if v == true then
                    local _redPoint_sp = _createRedPointFunc()
                    _redPoint_sp:setScale(0.6)
                    _redPoint_sp:setPosition(cc.p(_btn:getContentSize().width - 15, _btn:getContentSize().height))
                    _btn:addChild(_redPoint_sp)
                end
            end
        end
    end
    self:updateMainCityPoint()
end

function YingXiongInfoLayer:updateMainCityPoint()
    RedPointState[12].state = 0
    for k, v in pairs(self.isCanDo_prompt) do
        local _keystr = k .. "_btn"
        if self.rightTab_btn[_keystr] and tostring(self.selectedTab) ~= tostring(k) and v == true and self.rightTab_btn[_keystr]:isVisible() == true then
            RedPointState[12].state = 1
            XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT, data = { ["name"] = "hero" } })
            return
        else
            if self.rightPart_bg:getChildByName(k .. "Btn") then
                if v == true then
                    RedPointState[12].state = 1
                    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT, data = { ["name"] = "hero" } })
                    return
                end
            end
        end
    end
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT, data = { ["name"] = "hero" } })
    return
end
----------------------红点ended---------------------

----------------------提示began---------------------
-- 银两、翡翠、元宝不足提示框
function YingXiongInfoLayer:showMoneyNoEnoughtPop(_type)
    local _id = 1
    local _idKey = { noCoin = 3, noFeicui = 4, noIngot = 1, noItem = 5 }
    _id = _idKey[tostring(_type)] or 1
    local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create( { id = _id })
    self:addChild(StoredValue, 3)
end
-- 获取提示箭头路径
function YingXiongInfoLayer:getPromptPathByStr(_str)
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
function YingXiongInfoLayer:createPromptSprite(_str)
    local _promptSprite = cc.Sprite:create(self:getPromptPathByStr(_str))
    _promptSprite:setName("promptSprite")
    _promptSprite:setAnchorPoint(cc.p(1, 0))
    _promptSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.4, cc.p(0, 10)), cc.MoveBy:create(0.6, cc.p(0, -10)))))
    return _promptSprite
end
-- 设置道具的强化提示，进阶提示
function YingXiongInfoLayer:setEquipedItemPrompt(_equipItemdata)
    local _str = nil
    _str = { }
    -- 达到强化标准
    local _strengthBool, strengStr = self:getStrengPrompt(_equipItemdata)
    if _strengthBool == true then
        _str[#_str + 1] = "canStreng"
        self.isCanStrength = true
    else
        if strengStr ~= nil and self.isCanStrength ~= "noCoin" and self.isCanStrength ~= true then
            self.isCanStrength = strengStr
        end
    end
    -- 达到进阶标准
    if self:getAdvancePrompt(_equipItemdata) == true then
        _str[#_str + 1] = "canAdvance"
    end
    return _str
end
-- 装备是否可强化提示
function YingXiongInfoLayer:getStrengPrompt(_equipmentData)
    local _level = gameUser.getLevel()
    local _strengLevel = tonumber(_equipmentData.strengLevel) or 0
    local _bool = false
    local _enoughStr = nil
    -- 判断当前玩家等级是否大于装备的强化等级
    if tonumber(_level) > tonumber(_strengLevel) then
        local _strengData = self.staticEquipStrengData[tostring(_strengLevel + 1)] or nil
        local _strengCost = _strengData and _strengData["consume" .. _equipmentData.quality] or nil
        -- 判断银两是否足够强化
        if _strengCost ~= nil and tonumber(_strengCost) <= tonumber(gameUser.getGold()) then

            local _needItem = _strengData["need"]
            local _needNum = tonumber(_strengData["num"])
            if _needItem == nil or _needNum == nil or tonumber(_needItem) < 1 or tonumber(_needNum) < 1 then
                _bool = true
            else
                local _hasItem = self.dynamicCostItemData[tostring(_needItem)] or { }
                _hasItem = _hasItem.count or 0
                if tonumber(_hasItem) >= _needNum then
                    _bool = true
                else
                    _enoughStr = "noItem"
                end
            end
        else
            _enoughStr = "noCoin"
        end
    end
    return _bool, _enoughStr
end

-- 装备是否可进阶提示
function YingXiongInfoLayer:getAdvancePrompt(_equipmentData)
    -- local _functionData = self.staticFunctionInfoListData["21"] or {}
    -- local _downLimit = _functionData.unlockparam and _functionData.unlockparam or 1
    -- if tonumber(gameUser.getLevel())<tonumber(_downLimit) then
    --  return false
    -- end
    if XTHD.getUnlockStatus(50) == false then
        return false
    end
    local _bool = false
    local _equipStaticData = self.staticItemEquipListData[tostring(_equipmentData.itemid)]
    local _quality = tonumber(_equipmentData.quality) or 0
    -- 品阶
    local _uplimit = tonumber(_equipStaticData.advancetopvalue or 0)
    local _phaseLevel = tonumber(_equipmentData.phaseLevel) or 0

    -- 判断当前的阶数是否达到上限
    if _phaseLevel < _uplimit then
        local _advanceData = self.staticEquipAdvanceData[tostring(_phaseLevel + 1)] or { }
        local _needAllPrice = tonumber(_advanceData["goldprice"] or 0) * XTHD.resource.advanceGoldCoefficient[_quality]
        -- 判断下一阶的数据是否为空，当前银两是否充足
        if next(_advanceData) ~= nil and tonumber(gameUser.getGold()) > tonumber(_advanceData["goldprice"] or 0) then
            local _costItemId = _advanceData["consumables" .. _quality] or nil
            -- 消耗物品ID
            local _costItemNum = _advanceData["num" .. _quality] or nil
            -- 消耗物品Num
            if _costItemId ~= nil and _costItemNum ~= nil then
                -- 判断当前item动态库中是否有改消耗品，并且数量充足
                if self.dynamicCostItemData[tostring(_costItemId)] ~= nil and tonumber(self.dynamicCostItemData[tostring(_costItemId)].count) >= _costItemNum then
                    _bool = true
                end
            end
        end
    end
    return _bool
end

-- 装备是否可更换更好提示
function YingXiongInfoLayer:getChangeBetterItemPrompt(_equipData, _equipmentListData)
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
----------------------提示ended---------------------

--------------------一键功能began--------------------
-- 是否有装备
function YingXiongInfoLayer:isHaveItems()
    local _isHaveItems = false
    for k, v in pairs(self.currentCanEquipItems) do
        if tostring(v) ~= "" then
            _isHaveItems = true
            break
        end
    end
    return _isHaveItems
end
-- 一键装备函数
function YingXiongInfoLayer:OneKeyToEquip(callback)
    local _dbIds_str = json.encode(self.currentCanEquipItems)
    ClientHttp:httpHeroOneKeyEquip(self, function(data)
        YinDaoMarg:getInstance():doNextGuide()
        self:OneKeyEquipmentFunc(data)
        musicManager.playEffect("res/sound/EquipOn.mp3")
        if self._equipPoplayer then
            self._equipPoplayer:refreshInfoLayer()
        end
    end , { petId = self.data.heroid, dbIds = _dbIds_str }, function()
        YinDaoMarg:getInstance():tryReguide()
    end )
end
-- 一键装备函数
function YingXiongInfoLayer:OneKeyEquipmentFunc(_data)
    if #_data.items <= 0 then
        XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.noCanEquipTextXc)
        return
    end
    local _oldFightvalue = self.data["power"]
    self:setOldEquipmentData(self.data["equipments"])
    for i = 1, #_data["petProperty"] do
        local _petItemData = string.split(_data["petProperty"][i], ',')
        DBTableHero.updateDataByPropId(gameUser.getUserId(), _petItemData[1], _petItemData[2], _data["petId"])
    end
    DBTableEquipment.deleteDataByHeroid(gameUser.getUserId(), _data["petId"])
    -- 添加返回的当前英雄的所有信息
    local _target_equipments = { }
    for j = 1, #_data["petItems"] do
        local _equipment = { };
        _equipment["heroid"] = _data["petId"];
        _equipment["itemid"] = _data["petItems"][j]["itemId"];
        _equipment["dbid"] = _data["petItems"][j]["dbId"];
        _equipment["bagindex"] = _data["petItems"][j]["position"];
        _equipment["power"] = _data["petItems"][j]["power"];
        _equipment["quality"] = _data["petItems"][j]["quality"];
        _equipment["baseProperty"] = _data["petItems"][j]["property"]["baseProperty"];
        _equipment["strengLevel"] = _data["petItems"][j]["property"]["strengLevel"];
        _equipment["phaseProperty"] = _data["petItems"][j]["property"]["phaseProperty"];
        _equipment["phaseLevel"] = _data["petItems"][j]["property"]["phaseLevel"];
        _target_equipments[#_target_equipments + 1] = _equipment
    end
    DBTableEquipment.insertMultiData(gameUser.getUserId(), _target_equipments)
    -- 删除items中的count为0的数据
    -- 添加或更新到items中count大于0数据
    for i = 1, #_data["items"] do
        if tonumber(_data["items"][i]["count"]) > 0 then
            DBTableItem.updateCount(gameUser.getUserId(), _data["items"][i], _data["items"][i]["dbId"])
        else
            DBTableItem.deleteData(gameUser.getUserId(), _data["items"][i]["dbId"])
        end
    end
    self:refreshInfoLayer(_data["petId"])
    local _newFightValue = self.data["power"]
    XTHD._createFightLabelToast( {
        oldFightValue = _oldFightvalue,
        newFightValue = _newFightValue
    } )
    self:reFreshLeftLayer()
end
-- 一键强化函数
function YingXiongInfoLayer:OneKeyToStrength()
    local _oneKeyData = { }
    local _allCoin = 0
    local _costItemTable = self:getOneKeyStrengthCost()
    -- 道具不足做判断
    for k, v in pairs(_costItemTable) do
        if k == "gold" and v.allNeedNum == 0 then
            local _dialog = XTHDConfirmDialog:createWithParams( {
                msg = "当前强化石不足，可通过扫荡或者强化商店购买获得，是否前往购买？",
                rightCallback = function()
                    local changeLayer = requires("src/fsgl/layer/ShangCheng.lua"):create( { which = 'strength', callback = callback })
                    -----强化
                    LayerManager.addLayout(changeLayer)
                end
            } )
            self:addChild(_dialog)
            return
        end
    end
    local _dialog = XTHDConfirmDialog:createWithParams( {
    } )
    local _confirmDialogBg = nil
    if _dialog:getContainer() then
        _confirmDialogBg = _dialog:getContainer()
    else
        _dialog:removeFromParent()
        return
    end
    local _itemNum = 0
    for k, v in pairs(_costItemTable) do
        _itemNum = _itemNum + 1
    end
    local _descLabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.oneKeyStrengthPopTextXc, 18)
    _descLabel:setColor(cc.c4b(70, 34, 34, 255))
    _descLabel:setAnchorPoint(cc.p(0.5, 0))
    _descLabel:setPosition(cc.p(_confirmDialogBg:getContentSize().width / 2, _confirmDialogBg:getContentSize().height / 2 + 63))
    _confirmDialogBg:addChild(_descLabel)
    local _itemPos = SortPos:sortFromMiddle(cc.p(_confirmDialogBg:getContentSize().width / 2, _confirmDialogBg:getContentSize().height / 2 + 13), _itemNum, 60 + 9)
    local _itemOrder = 1
    for k, v in pairs(_costItemTable) do
        local _itemNode = ItemNode:createWithParams( {
            itemId = v.itemId or 0,
            _type_ = v.itemType or 1,
            touchShowTip = true,
            count = v.allNeedNum or 0
        } )
        _itemNode:setScale(60 / _itemNode:getContentSize().width)
        _itemNode:setPosition(cc.p(_itemPos[_itemOrder].x, _itemPos[_itemOrder].y))
        _confirmDialogBg:addChild(_itemNode)
        _itemOrder = _itemOrder + 1
    end
    _dialog:setCallbackRight( function()
        ----引导
        YinDaoMarg:getInstance():guideTouchEnd()
        ------------------------------------
        if _dialog:getRightButton() then
            _dialog:getRightButton():setClickable(false)
        end
        ClientHttp:httpHeroOneKeyStrength(self, function(data)
            YinDaoMarg:getInstance():doNextGuide()
            musicManager.playEffect("res/sound/EquipUp.mp3")
            gameUser.setGold(data.gold)
            XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
            self:OneKeyStrengthFunc(data)
            if self._equipPoplayer then
                self._equipPoplayer:refreshInfoLayer()
            end
            _dialog:hide( { music = true })
        end , { petId = self.data.heroid }, function(data)
            if not data then
                -----如果是网络请求失败了则再点强化-确定，否则就不点
                YinDaoMarg:getInstance():skipGuideOnGI(2, 5)
                YinDaoMarg:getInstance():doNextGuide()
            end
            _dialog:hide( { music = true })
        end )
    end )
    self:addChild(_dialog)
    --------引导
    local _group, _index = YinDaoMarg:getInstance():getGuideSteps()
    if _group == 2 and _index == 8 then
        ----第2组引导
        YinDaoMarg:getInstance():getACover(self)
        YinDaoMarg:getInstance():addGuide( {
            parent = self,
            target = _dialog:getRightButton(),
            index = 8,
            needNext = false
        } , 2)
        performWithDelay(_dialog, function()
            YinDaoMarg:getInstance():removeCover(self)
            YinDaoMarg:getInstance():doNextGuide()
        end , 0.2)
    end
    ------------------
end

function YingXiongInfoLayer:getOneKeyStrengthCost()
    local _equipmentData = { }
    for k, v in pairs(self.data.equipments) do
        _equipmentData[#_equipmentData + 1] = clone(v)
    end
    if (#_equipmentData) < 1 then
        return 0
    end
    -- 按位置，当前强化等级，品质排序
    table.sort(_equipmentData, function(data1, data2)
        local _data1Num = tonumber(data1.bagindex) * 1000000 + tonumber(data1.strengLevel) * 1000 + tonumber(data1.quality)
        local _data2Num = tonumber(data2.bagindex) * 1000000 + tonumber(data2.strengLevel) * 1000 + tonumber(data2.quality)
        return _data1Num < _data2Num
    end )
    local _oneKeyStrengTable = { }
    local _costItemTable = { }
    _costItemTable = XTHD.getEquipStrengthCostItems( {
        backStrengthLevel = false,
        -- 是否返回强化后的等级
        equipmentsTable = _equipmentData,
        itemsData = self.dynamicCostItemData,-- DBTableItem动态数据
    } )
    return _costItemTable
end

-- 一键强化函数
function YingXiongInfoLayer:OneKeyStrengthFunc(_data)
    if #_data["items"] < 1 then
        XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.noCanStrengthTextXc)
        return
    end
    local _oldFightvalue = self.data["power"]
    self:setOldEquipmentData(self.data["equipments"])

    for i = 1, #_data["property"] do
        local _petItemData = string.split(_data["property"][i], ',')
        DBTableHero.updateDataByPropId(gameUser.getUserId(), _petItemData[1], _petItemData[2], _data["petId"])
    end
    if _data.bagItems then
        for i = 1, #_data.bagItems do
            DBTableItem.updateCount(gameUser.getUserId(), _data.bagItems[i], _data.bagItems[i]["dbId"])
        end
    end
    -- 删除items中的count为0的数据
    -- 添加或更新到items中count大于0数据
    for i = 1, #_data["items"] do
        DBTableEquipment.deleteData(gameUser.getUserId(), _data["items"][i]["dbId"])
        _data["items"][i]["bagindex"] = _data["items"][i]["position"]
        _data["items"][i]["dbid"] = _data["items"][i]["dbId"]
        _data["items"][i]["itemid"] = _data["items"][i]["itemId"]
        _data["items"][i]["heroid"] = _data["petId"]
        DBTableEquipment.insertData(gameUser.getUserId(), _data["items"][i], _data["items"][i]["dbId"])
    end
    self:refreshInfoLayer(_data["petId"])
    self:reFreshLeftLayer()
    local _newFightValue = self.data["power"]
    if tonumber(_oldFightvalue) == tonumber(_newFightValue) then
        XTHDTOAST(LANGUAGE_FUNCTION5)
        -----"一键强化成功")
    end
    XTHD._createFightLabelToast( {
        oldFightValue = _oldFightvalue,
        newFightValue = _newFightValue
    } )
end
--------------------一键功能ended--------------------

------------------左侧界面改变began-------------------
-- 右部标签回调,升级和选择装备也可以调用
-- _type判断是否有切换动画
function YingXiongInfoLayer:setSelectedCallBack(_key, _type)
    for k, v in pairs(self.rightTab_btn) do
        v:setSelected(false)
        v:setLocalZOrder(10)
    end
    if self.rightTab_btn[_key .. "_btn"] then
        self.rightTab_btn[_key .. "_btn"]:setSelected(true)
        self.selectedTab = _key
        self.rightTab_btn[_key .. "_btn"]:setLocalZOrder(10)
    end
    self:addTabButtonRedpoint()
    -- 无动画
    if _type and _type == "noAnimation" then
        self:setLayerState(_key .. "_layer")
    else
        self:setLeftLayerChange(_key .. "_layer")
    end
end
-- 设置左侧的收缩和恢复
function YingXiongInfoLayer:setLeftLayerChange(state_type, _callback)
    local _actionTable = { }
    if _callback then
        _actionTable[#_actionTable + 1] = cc.CallFunc:create( function()
            _callback()
        end )
    else
        _actionTable[#_actionTable + 1] = cc.CallFunc:create( function()
            self:setLayerState(state_type)
        end )
    end
    self.heroInfoBg:runAction(cc.Sequence:create(_actionTable))
end
-- 设置各个小界面的切换，左侧的内容切换和位置恢复
function YingXiongInfoLayer:setLayerState(state_type)
    -- 显示那些界面功能
    -- 升星，进阶，升技能，升级的func
    local _funcPart2 = function(_key, _fileName)
        self.state = _key
        if self.current_function_layer then
            self.current_function_layer:removeFromParent()
            self.current_function_layer = nil
        end

        local _node = requires("src/fsgl/layer/YingXiong/" .. _fileName .. ".lua")
        local _leftWidth = self.heroInfoBg:getContentSize().width - 480
        -- _node:setTextureRect(cc.rect(0,0,_leftWidth,self.heroInfoBg:getContentSize().height))
        if _key == STATE.TAG_STAR_UP_INFO then
            self.current_function_layer = _node:create(self.data, self.items_data, self)
        else
            self.current_function_layer = _node:create(self.data, self, cc.size(420, 264))
        end
        self.current_function_layer:setAnchorPoint(0.5, 0)

        self.current_function_layer:setPosition(self.rightPart_bg:getContentSize().width * 0.5, 0)
        self.rightPart_bg:addChild(self.current_function_layer, 1)
    end

    local _funcPart3 = function()
		if self:getChildByName("levelUp") then
			self:getChildByName("levelUp"):removeFromParent()
		end
        local _node = requires("src/fsgl/layer/YingXiong/YingXiongLevelUp.lua")
        layer = _node:create(self.data, self, cc.size(420, 264))
		layer:setName("levelUp")
        self:addChild(layer, 1)
        layer:show()
    end

    if state_type == STATE.TAG_DETAIL_INFO then
        _funcPart2(STATE.TAG_DETAIL_INFO, "YingXiongDetailPropertyLayer")
    elseif state_type == STATE.TAG_LEVEL_UP_INFO then
		if not self.current_function_layer then
			_funcPart2(STATE.TAG_DETAIL_INFO, "YingXiongDetailPropertyLayer")
		end
        _funcPart3()
    else
        ----引导
        YinDaoMarg:getInstance():guideTouchEnd()
        YinDaoMarg:getInstance():releaseGuideLayer()
        local _group = YinDaoMarg:getInstance():getGuideSteps()
        if self.data.star >= 5 and _group == 15 then
            YinDaoMarg:getInstance():overCurrentGuide(true, _group)
        end
        ------------------------
        local fileNameByKey = {
            [STATE.TAG_STAR_UP_INFO] = "YingXiongStarUpNode",
            [STATE.TAG_ADVANCE_INFO] = "YingXiongAdvanceNode",
            [STATE.TAG_SKILL_INFO] = "YingXiongSkillUp",
            [STATE.TAG_LEVEL_UP_INFO] = "YingXiongLevelUp",
        }
        _funcPart2(state_type, fileNameByKey[tostring(state_type)])
    end
end
-- 跳转选择装备
function YingXiongInfoLayer:turnToChooseEquipment(_itemsData, _idx)
    local _turnChooseFunc = function()
        for k, v in pairs(self.rightTab_btn) do
            v:setSelected(false)
        end
        if self.state == STATE.TAG_CHOOSEEQUIPMENT_INFO then
            if self.current_function_layer ~= nil and tonumber(self.equipmentsIndex) == _idx then
                self.equipmentsIndex = 0
                self:setSelectedCallBack(self.selectedTab or "property", "noAnimation")
                return
            end
        end
        self.state = STATE.TAG_CHOOSEEQUIPMENT_INFO
        if self.current_function_layer then
            self.current_function_layer:removeFromParent()
            self.current_function_layer = nil
        end
        local _node = requires("src/fsgl/layer/YingXiong/YingXiongChooseEquipmentLayer.lua")
        local _leftWidth = self:getContentSize().width - 63 - self.heroInfoBg:getContentSize().width + 365
        self.current_function_layer = _node:create(_itemsData, self, self.data.heroid or 1, _idx, cc.size(_leftWidth + 60, self.heroInfoBg:getContentSize().height))
        self.current_function_layer:setAnchorPoint(0.5, 0)
        self.current_function_layer:setPosition(190, 0)
        self.heroInfoBg:addChild(self.current_function_layer)
        self.equipmentsIndex = _idx
    end

    -- if self.state == STATE.TAG_CHOOSEEQUIPMENT_INFO and self.current_function_layer~=nil and self.current_function_layer._index and tonumber(self.current_function_layer._index) ~= _idx then
    if self.state == STATE.TAG_CHOOSEEQUIPMENT_INFO and self.current_function_layer ~= nil and tonumber(self.equipmentsIndex) ~= _idx then
        _turnChooseFunc()
    else
        -- local _btnBg = self.heroEquipmentsTable[tonumber(_idx)]
        --  if _btnBg:getChildByName("btn_item") then
        --      _btnBg:getChildByName("btn_item"):setClickable(false)
        --  end
        self:setLeftLayerChange(nil, _turnChooseFunc)
    end
end
------------------左侧界面改变ended-------------------

------------------关于界面刷新began-------------------
-- 刷新按钮状态
function YingXiongInfoLayer:reFreshRightTabState()
    local _tabBtnName = { "skill", "advance", "starup" }
    local _tabId = { 55, 53, 49, 52 }
    local _instancingId = tonumber(gameUser.getInstancingId())
    local _functionData = self.staticFunctionInfoListData or { }
    for i = 1, 3 do
        local _key = _tabBtnName[i]
        local _btnkey = _key .. "_btn"
        local _btn = self.rightTab_btn[_btnkey]
        local _needFData = _functionData[tostring(_tabId[i])] or { }
        local _needInstanceId = tonumber(_needFData and _needFData.unlockparam or 0)
        if _needInstanceId > _instancingId then
            _btn:setVisible(false)
            if tostring(self.selectedTab) == tostring(_key) then
                self.selectedTab = "property"
            end
        else
            _btn:setVisible(true)
        end
    end
end

-- 刷新左侧界面
function YingXiongInfoLayer:reFreshLeftLayer()
    if self.current_function_layer ~= nil then
        self.current_function_layer:reFreshHeroFunctionInfo(self.data)
    end
end

function YingXiongInfoLayer:reFreshLeftLayer2(data)
    if self.current_function_layer ~= nil then
        self.current_function_layer:reFreshHeroFunctionInfo2(data)
    end
end

-- 刷新星数
function YingXiongInfoLayer:reFreshHeroStars(_star)
    if _star == nil or tonumber(_star) < 1 then
        _star = self.data and self.data.star or 1
    end
    for i = 1, #self.starBg_arr do
        if self.starBg_arr[i] then
            self.starBg_arr[i]:removeFromParent()
        end
    end
    self.starBg_arr = { }
    self:createStarAndMoon()

end

function YingXiongInfoLayer:reFreshHeroName(_nameStr, _advanceValue)
    if not _nameStr or _nameStr == "" then
        return
    end
    if self.child_arr["label_name"] then
        self.child_arr["label_name"]:setString(self.data.name .. " +" .. self.data.advance - 1)
    end
    self:setHeroAdvanced(false)
end
-- 刷新战斗力,不传值，更新self.data中的power字段，并改变战斗力。传值只改变页面显示
function YingXiongInfoLayer:reFreshFightLabel(_power)
    local _value = _power or nil
    if not _value or tonumber(_value) < 0 then
        self.data["power"] = DBTableHero.getData(gameUser.getUserId(), { heroid = self.data["heroid"] })
        self.data["power"] = self.data["power"] and self.data["power"].power or 0
        _value = self.data["power"]
    end
    XTHD.refreshPowerShowSprite(self.child_arr["fight_bg"], _value)
end
-- 刷新经验值
function YingXiongInfoLayer:reFreshExpvalue(_curexp, _maxexp)
    local _expPersentValue = self:getExpPerValue(_curexp, _maxexp)
    local exp_process = self.child_arr["exp_progress"]
    local _curPercentValue = tonumber(exp_process:getPercentage())
    exp_process:stopAllActions()
    if _curPercentValue > _expPersentValue then
        -- exp_process:runAction(cc.ProgressTo:create(0.1,_expPersentValue))
        exp_process:setPercentage(_expPersentValue)
    else
        exp_process:runAction(cc.ProgressTo:create(0.1, _expPersentValue))
    end
    if exp_process:getChildByName("expLabel") then
        exp_process:getChildByName("expLabel"):setString(_curexp .. "/" .. _maxexp)
    end
end
-- 刷新英雄类型
function YingXiongInfoLayer:reFreshHeroType(_type)
    ------- {"力量","智力","敏捷"}
    local _herotype_label = self.child_arr["hero_type"]
    _herotype_label:setTexture("res/image/newHeroinfo/heroType_" .. self.data["type"] .. ".png")
end

-- 刷新英雄品级
function YingXiongInfoLayer:reFreshHeroRank(_rank)
    local rank_bg = self.child_arr["rank_bg"]
    rank_bg:setTexture("res/image/common/herorank_" .. self.data.rank - 1 .. ".png")
end

-- 刷新英雄头像
function YingXiongInfoLayer:reFreshHeroIcon()
    local heroIcon = self.child_arr["heroIcon"]
    heroIcon:getChildByName("item_border"):getChildByName("hero_img"):setTexture(XTHD.resource.getHeroAvatorImgById(self.data.heroid))
end

-- 刷新英雄等级
function YingXiongInfoLayer:reFreshHeroLevel(_level)
    local _heroLevel_label = self.child_arr["label_level"]
    _heroLevel_label:setString(_level or "")
    local _levelLimitData = self.staticPlayerInfoListData[tostring(gameUser.getLevel())] or { }
    self.child_arr["label_levellimit"]:setString(" / " ..(_levelLimitData.maxlevel or 0))
end
-- 英雄信息刷新
-- reload_ani表示是否重新加载界面
function YingXiongInfoLayer:reFreshHeroInfo(reload_ani)
    -- 参数是仅仅刷新 不会更改当前的状态为基础属性状态
    self:reFreshHeroStars(self.data.star)
    self:reFreshHeroName(self.data["name"], self.data["advance"])
    self:reFreshExpvalue(self.data["curexp"], self.data["maxexp"])
    self:reFreshHeroType(self.data["type"])
    self:reFreshHeroRank(self.data["rank"])
    self:reFreshHeroLevel(self.data["level"])
    self:reFreshFightLabel(self.data["power"])
    self:reFreshHeroIcon()
    self:reFreshHeroFunction()
    self:isCanDoPrompt()
    local _stateStr = self.selectedTab and self.selectedTab .. "_layer" or ""
    if self.selectedTab and _stateStr ~= self.state then
        self.equipmentsIndex = 0
        reload_ani = true
    end
    if reload_ani ~= nil then
        -- false表示刷新左侧数据，不加动画
        if reload_ani == false then
            self:setSelectedCallBack(self.selectedTab or "property", "noAnimation")
            -- true表示刷新左侧数据，加动画
        elseif reload_ani == true then
            self:setSelectedCallBack(self.selectedTab or "property")
        end
    end
    self:addTabButtonRedpoint()
end
-- 装备刷新
function YingXiongInfoLayer:reFreshHeroEquments()
    local _hero_data = self.data
    local equipments = {
        ["1"] = { },
        ["2"] = { },
        ["3"] = { },
        ["4"] = { },
        ["5"] = { },
        ["6"] = { },
    }
    for i = 1, #_hero_data["equipments"] do
        equipments[tostring(_hero_data["equipments"][i].bagindex)] = _hero_data["equipments"][i]
    end
    local _equipState = {
        ["1"] = nil,
        ["2"] = nil,
        ["3"] = nil,
        ["4"] = nil,
        ["5"] = nil,
        ["6"] = nil,
    }
    -- 判断是否是强化或者装备
    if self.oldEquipmentData ~= nil then
        for i = 1, #_hero_data["equipments"] do
            if _hero_data["equipments"][i] ~= nil or next(_hero_data["equipments"][i]) ~= nil then
                local _bagindex = _hero_data["equipments"][i].bagindex or 0
                if self.oldEquipmentData[tostring(_bagindex)] ~= nil and next(self.oldEquipmentData[tostring(_bagindex)]) ~= nil then
                    if self.oldEquipmentData[tostring(_bagindex)].dbid and tostring(self.oldEquipmentData[tostring(_bagindex)].dbid) ~= tostring(_hero_data["equipments"][i].dbid) then
                        _equipState[tostring(_bagindex)] = "equip"
                    elseif self.oldEquipmentData[tostring(_bagindex)].strengLevel == nil or tonumber(self.oldEquipmentData[tostring(_bagindex)].strengLevel) ~= tonumber(_hero_data["equipments"][i].strengLevel) then
                        _equipState[tostring(_bagindex)] = "streng"
                    end
                else
                    _equipState[tostring(_bagindex)] = "equip"
                end
            end
        end
    end
    -- 英雄穿戴的装备
    self.isHaveEquipment = false
    self.currentCanEquipItems = { }
    self.isCanStrength = false
    local _itemScale = 0.8
    for i = 1, 6 do
        self.currentCanEquipItems[i] = ""
        local equip_id = -1
        local _equipData = { }
        if equipments[tostring(i)] and next(equipments[tostring(i)]) ~= nil and equipments[tostring(i)].itemid then
            equip_id = equipments[tostring(i)].itemid
            _equipData = equipments[tostring(i)]
        end
        local _btn_item_bg = self.heroEquipmentsTable[tonumber(i)]
        if equip_id == -1 or _btn_item_bg.equipInfo == nil or tonumber(_btn_item_bg.equipInfo.itemid or 0) ~= tonumber(equip_id) then
            if _btn_item_bg:getChildByName("btn_item") then
                local _btnItem = _btn_item_bg:getChildByName("btn_item")
                if _btnItem:getChildByName("qualitySpine") then
                    _btnItem:removeChildByName("qualitySpine")
                end
                _btn_item_bg:removeChildByName("btn_item")
            end
        end
        _btn_item_bg.type = "no_equip"
        _btn_item_bg.ItemInfo = { }
        _btn_item_bg.equipInfo = { }

        local btn_item = nil
        local _btnType = "no_equip"
        local _itemInfo = { }
        if equip_id == -1 then
            equip_id = i + 1
            _equipData = { }
            _itemInfo = self:getItemState(i, { _type = self.data["type"] or 0, _level = self.data["level"] or 0 })
            if not _itemInfo or next(_itemInfo) == nil then
                _btnType = "no_equip"
                _itemInfo = { }
                self.currentCanEquipItems[i] = ""
                btn_item = XTHD.createButton( {
                    normalFile = "res/image/plugin/hero/noItemgo_normal.png"
                    ,
                    selectedFile = "res/image/plugin/hero/noItemgo_selected.png"
                    -- ,musicFile = XTHD.resource.music.effect_btn_common
                    ,
                    endCallback = function()
                        local _popLayer = requires("src/fsgl/layer/YingXiong/YingXiongEquipItemDropPopLayer.lua"):create(i)
                        self:addChild(_popLayer)
                    end
                } )
                btn_item:setScale(1.2)
                btn_item:setName("btn_item")
                btn_item:setPosition(cc.p(_btn_item_bg:getContentSize().width / 2, _btn_item_bg:getContentSize().height / 2))
                _btn_item_bg:addChild(btn_item)
            elseif _itemInfo and next(_itemInfo) ~= nil then
                local _imgPathStr = "CanEquip"
                if _itemInfo[1] == nil or next(_itemInfo[1]) == nil or tonumber(_itemInfo[1].equipState) ~= 1 then
                    _btnType = "cannot_equip"
                    _imgPathStr = "CanNotEquip"
                else
                    _btnType = "can_equip"
                    _imgPathStr = "CanEquip"
                end
                self.currentCanEquipItems[i] = _itemInfo[1].dbid or ""
                btn_item = XTHD.createButton( {
                    normalFile = "res/image/plugin/hero/hero" .. _imgPathStr .. "Btn_normal.png"
                    ,
                    selectedFile = "res/image/plugin/hero/hero" .. _imgPathStr .. "Btn_selected.png"
                    -- ,musicFile = XTHD.resource.music.effect_btn_common
                } )
                btn_item:setScale(1.2)
                btn_item:setName("btn_item")
                btn_item:setPosition(cc.p(_btn_item_bg:getContentSize().width / 2, _btn_item_bg:getContentSize().height / 2))
                _btn_item_bg:addChild(btn_item)
                btn_item.index = i
                local _iteminfo_ = { }
                for k, v in pairs(_itemInfo) do
                    _iteminfo_[#_iteminfo_ + 1] = v
                end
                local _Data = self:addEquipedItemsForHero(_iteminfo_, btn_item.index)
                self._heroEquipInfo = _Data
                btn_item:setTouchEndedCallback( function()
                    if i > 0 and i < 7 and next(_Data) ~= nil then
                        self:turnToChooseEquipment(_Data, i)
                    else
                        XTHDTOAST(LANGUAGE_TIPS_WORDS103)
                        -----"没有可以装备的道具")
                    end
                end )
            end
        else
            self.isHaveEquipment = true
            local equipItem_data = self.staticItemData[tostring(equip_id)]
            if _btn_item_bg:getChildByName("btn_item") then
                btn_item = _btn_item_bg:getChildByName("btn_item")
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
                btn_item:setPosition(cc.p(_btn_item_bg:getContentSize().width / 2, _btn_item_bg:getContentSize().height / 2))
                btn_item:setScale(1.1)
                btn_item:setName("btn_item")

                _btn_item_bg:addChild(btn_item)
            end
            _btnType = "is_equipped"
            btn_item._prompt = { }
            btn_item:setCascadeOpacityEnabled(true)
            btn_item.index = i

            _itemInfo = self:getItemState(i, { _type = self.data["type"] or 0, _level = self.data["level"] or 0 })

            if not _itemInfo then
                _itemInfo = { }
            end
            local _changeItemStr = self:getChangeBetterItemPrompt(_equipData, _itemInfo) or nil
            if _changeItemStr ~= nil then
                btn_item._prompt[#btn_item._prompt + 1] = _changeItemStr
                self.currentCanEquipItems[i] = _itemInfo[1].dbid or ""
            else
                self.currentCanEquipItems[i] = _equipData.dbid or ""
            end

            if _equipState[tostring(i)] ~= nil then
                if _equipState[tostring(i)] == "equip" then
                    btn_item:setOpacity(0)
                    local _animation = cc.Spawn:create(cc.Sequence:create(cc.DelayTime:create(0.033 * 5), cc.FadeIn:create(0.5)), cc.CallFunc:create( function()
                        local _lightAni = getAnimation("res/image/plugin/hero/equipItemFrames/", 1, 9, 0.065)
                        local _sp = cc.Sprite:create("res/image/plugin/hero/equipItemFrames/1.png")
                        -- _sp:setScale(1.4)
                        _sp:setPosition(_btn_item_bg:getContentSize().width / 2, _btn_item_bg:getContentSize().height / 2)
                        _btn_item_bg:addChild(_sp)
                        _sp:runAction(cc.Sequence:create(_lightAni, cc.CallFunc:create( function()
                            _sp:removeFromParent()
                        end )))
                    end ))
                    btn_item:runAction(_animation)
                elseif _equipState[tostring(i)] == "streng" then
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
                local _popLayer = requires("src/fsgl/layer/YingXiong/YingXiongEquipmentInfoPopLayer.lua"):create(btn_item.index, self, nil, _prompt)
                self:addChild(_popLayer, 3)
            end )
        end
        _btn_item_bg.ItemInfo = _itemInfo
        _btn_item_bg.type = _btnType
        _btn_item_bg.equipInfo = clone(_equipData)
    end
    self.oldEquipmentData = nil
    self:refreshEquipAdvanceAndStrengthPrompt()
end
-- 刷新装备的进阶和强化提示信息
function YingXiongInfoLayer:refreshEquipAdvanceAndStrengthPrompt()
    for i = 1, 6 do
        local _btn_item_bg = self.heroEquipmentsTable[tonumber(i)]
        if _btn_item_bg:getChildByName("btn_item") and _btn_item_bg.equipInfo ~= nil and next(_btn_item_bg.equipInfo) ~= nil then
            local btn_item = _btn_item_bg:getChildByName("btn_item")
            local _promptData = self:setEquipedItemPrompt(_btn_item_bg.equipInfo) or { }
            for i = 1, #_promptData do
                btn_item._prompt[#btn_item._prompt + 1] = _promptData[i]
            end
            if btn_item:getChildByName("promptSprite") and next(btn_item._prompt) ~= nil and tostring(btn_item:getChildByName("promptSprite").promptType or "") == tostring(btn_item._prompt[1]) then
            else
                -- todo
                if btn_item:getChildByName("promptSprite") then
                    btn_item:removeChildByName("promptSprite")
                end
                if next(btn_item._prompt) ~= nil then
                    local _promptSprite = self:createPromptSprite(btn_item._prompt[1])
                    _promptSprite:setName("promptSprite")
                    _promptSprite.promptType = btn_item._prompt[1]
                    _promptSprite:setPosition(cc.p(btn_item:getContentSize().width, 0))
                    btn_item:addChild(_promptSprite, 1)
                end

            end
        end
    end
end

-- 刷新数据和界面
function YingXiongInfoLayer:reFreshHeroDataAndLayer()
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
    if self.data and next(self.data) ~= nil then
        self:refreshInfoLayer()
        self:reFreshLeftLayer()
        XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_ITEMDROP_HASNUMBER })
        if self:getChildByName("BuyExpPop") then
            self:getChildByName("BuyExpPop"):reFreshLastBuyCount()
        end
    end
end
-- 刷新跟翡翠有关的数据
function YingXiongInfoLayer:reFreshCostFeicui()
    if self.current_function_layer ~= nil and self.current_function_layer.reFreshCostFeicui ~= nil then
        self.current_function_layer:reFreshCostFeicui()
    end
end

function YingXiongInfoLayer:reFreshHeroFunction()
    for i = 1, #self.heroFunctionBtn do
        self:createHeroFunction(i)
    end
end
------------------关于界面刷新ended-------------------

-------------------关于数据Began-------------------
-- 刷新数据
function YingXiongInfoLayer:refreshInfoLayer(_heroid, _str)
    self:getDynamicDBData()
    RedPointManage:setDynamicData()

    if not _str or(_str ~= "noEquipInfo" and _str ~= "noEquip") then
        self:setEquipedItemData()
    end
    if _heroid == nil then
        _heroid = self.data and self.data.heroid or nil
    end
    self:setTheHeroData(_heroid)
    self:setCurrentItemData()
    if not _str or _str ~= "noEquip" then
        self:reFreshHeroEquments()
    end
    self:reFreshHeroInfo()

end
-- 提前加载其他功能静态库数据
function YingXiongInfoLayer:setOtherStaticDBData()
    -- skill
    self.otherStaticSkillData = gameData.getDataFromCSVWithPrimaryKey("JinengInfo")
    -- advance
    self.otherStaticAdvanceData = { }
    local _advanceTable = gameData.getDataFromCSV("GeneralAdvanceBonus")
    for k, v in pairs(_advanceTable) do
        if not self.otherStaticAdvanceData[tostring(v.heroid)] then
            self.otherStaticAdvanceData[tostring(v.heroid)] = { }
        end
        self.otherStaticAdvanceData[tostring(v.heroid)][#self.otherStaticAdvanceData[tostring(v.heroid)] + 1] = v
    end
    -- hero_grow
    self.otherStaticHeroGrowData = { }
    local _heroGrowTable = gameData.getDataFromCSV("GeneralGrowthBonusList")
    for k, v in pairs(_heroGrowTable) do
        if not self.otherStaticHeroGrowData[tostring(v.heroid)] then
            self.otherStaticHeroGrowData[tostring(v.heroid)] = { }
        end
        self.otherStaticHeroGrowData[tostring(v.heroid)][#self.otherStaticHeroGrowData[tostring(v.heroid)] + 1] = v
    end
    local _heroGrowTableB = gameData.getDataFromCSV("GeneralGrowthBonusListB")
    for k, v in pairs(_heroGrowTableB) do
        if not self.otherStaticHeroGrowData[tostring(v.heroid)] then
            self.otherStaticHeroGrowData[tostring(v.heroid)] = { }
        end
        self.otherStaticHeroGrowData[tostring(v.heroid)][#self.otherStaticHeroGrowData[tostring(v.heroid)] + 1] = v
    end

    self:getStaticDBHeroAdvancedListData()
end
-----------动态------------
-- 获取动态库数据
function YingXiongInfoLayer:getDynamicDBData()
    self:getDynamicDBItemData()
    self:getDynamicDBEquipmentData()
end
-- 获取动态数据库Item的数据
function YingXiongInfoLayer:getDynamicDBItemData()
    self.dynamicItemData = { }
    self.dynamicItemData = DBTableItem:getDataByID()
    self.dynamicCostItemData = { }
    for k, v in pairs(self.dynamicItemData) do
        self.dynamicCostItemData[tostring(v.itemid)] = v
    end

end
function YingXiongInfoLayer:getDynamicDBEquipmentData()
    self.dynamicEquipmentData = { }
    local _table = DBTableEquipment.getData(gameUser.getUserId(), nil)
    if _table and next(_table) ~= nil and #_table < 1 then
        self.dynamicEquipmentData[#self.dynamicEquipmentData + 1] = _table
    else
        self.dynamicEquipmentData = _table
        -- 浅拷贝
    end

end
-------------静态-------------
-- 获取静态库数据,只需要刚进入YingXiongInfoLayer界面调用一次就好了
function YingXiongInfoLayer:getStaticDBData()
    self.staticItemData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet")
    self.staticEquipStrengData = gameData.getDataFromCSVWithPrimaryKey("EquipUpList")
    self.staticEquipAdvanceData = gameData.getDataFromCSVWithPrimaryKey("EquipAscendingStar")
    self.staticFunctionInfoListData = gameData.getDataFromCSVWithPrimaryKey("FunctionInfoList")
    self.staticHeroStarupListData = gameData.getDataFromCSVWithPrimaryKey("GeneralGrowthNeeds")
    self.staticHeroSkillListData = gameData.getDataFromCSVWithPrimaryKey("GeneralSkillList")
    self.staticSkillUpListData = gameData.getDataFromCSVWithPrimaryKey("JinengUpNeed")
    -- self.staticItemEquipUpData = gameData.getDataFromCSVWithPrimaryKey("EquipUpList")
    self.staticPlayerInfoListData = gameData.getDataFromCSVWithPrimaryKey("PlayerUpperLimit")
    self.staticGodbeastData = gameData.getDataFromCSV("SuperWeaponUpInfo")
    self.staticItemEquipListData = gameData.getDataFromCSVWithPrimaryKey("EquipInfoList")
end
function YingXiongInfoLayer:getStaticDBDataByName(_tableName, _key)
    local _staticData = { }
    local _table = gameData.getDataFromCSV(_tableName)
    for k, v in pairs(_table) do
        _staticData[tostring(v[_key])] = { }
        _staticData[tostring(v[_key])] = v
    end
    return _staticData
end
-- 英雄进阶静态
function YingXiongInfoLayer:getStaticDBHeroAdvancedListData()
    self.staticHeroAdvancedListData = { }
    local _table = gameData.getDataFromCSV("GeneralAdvanceInfo")
    for k, v in pairs(_table) do
        if self.staticHeroAdvancedListData[tostring(v.heroid)] == nil then
            self.staticHeroAdvancedListData[tostring(v.heroid)] = { }
        end
        self.staticHeroAdvancedListData[tostring(v.heroid)][tostring(v.rank)] = v
    end
end

-- 重新获取id英雄的数据
function YingXiongInfoLayer:setTheHeroData(_heroid)
    if not _heroid or tonumber(_heroid) < 1 then
        return
    end
    local _theHeroDataNumber = tonumber(-1)
    for i = 1, #self.herosData do
        if tonumber(_heroid) == tonumber(self.herosData[i]["heroid"]) then
            _theHeroDataNumber = tonumber(i)
            break
        end
    end
    if _theHeroDataNumber == -1 then
        return
    end
    self.herosData[_theHeroDataNumber] = HeroDataInit:InitHeroDataSelectHero(_heroid)
    local _equipmentData = { }
    local _table = self.dynamicEquipmentData or { }

    for k, v in pairs(_table) do
        if tonumber(v.heroid) == tonumber(_heroid) then
            _equipmentData[#_equipmentData + 1] = v
        end
    end
    self.herosData[_theHeroDataNumber]["equipments"] = _equipmentData or { }
    -- self.herosData[_theHeroDataNumber]["hero_grow"] = _herogrowTable
    self.data = self.herosData[self.heroPager:getCurrentIndex()]
end
-- 只是刷新某英雄的属性数据
function YingXiongInfoLayer:refreshOnlyTheHeroData(_heroid)
    self:getDynamicDBEquipmentData()
    self:setTheHeroData(_heroid)
end

-- 重新获取当前道具的数据
function YingXiongInfoLayer:setCurrentItemData()
    local items_pairs = { }
    self.items_data = { }
    items_pairs = self.dynamicItemData or { }
    local _EquipmentTable = self.staticItemEquipListData
    -- gameData.getDataFromCSVWithPrimaryKey("EquipInfoList")
    local _staticEquipmentData = { }
    for i, var in pairs(items_pairs) do
        self.items_data[tostring(var["dbid"])] = { }
        self.items_data[tostring(var["dbid"])] = var
        self.items_data[tostring(var["dbid"])].level = self.staticItemData[tostring(var["itemid"])] and self.staticItemData[tostring(var["itemid"])].levelfloor or 0
        self.items_data[tostring(var["dbid"])].resourceid = self.staticItemData[tostring(var["itemid"])] and self.staticItemData[tostring(var["itemid"])].resourceid or 0
        local _data_ = _EquipmentTable[tostring(var["itemid"])] or { }
        local _equipment = {
            herotype = _data_.herotype or 1
            ,
            equippos = _data_.equippos or 0
        }
        self.items_data[tostring(var["dbid"])].equipment = _equipment
    end
end
-- 重新获取当前已经装备上的道具的数据
function YingXiongInfoLayer:setEquipedItemData()
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
-- 设置英雄信息，成长属性
function YingXiongInfoLayer:setHerosData(_data)
    self.herosData = { }
    if not _data or next(_data) == nil then
        _data = clone(self:getMyHerosListData())
    end
    self.herosData = _data
end
-- 获取英雄信息列表
function YingXiongInfoLayer:getMyHerosListData()
    -- 构建数据
    -- 获取所有已拥有英雄的数据
    local _temp_data = HeroDataInit:InitHeroDataAllOwnHero()
    -- 获取当前所有已经装备上的信息
    local _equipmentData = { }
    for k, v in pairs(self.dynamicEquipmentData) do
        if not _equipmentData[tostring(v.heroid)] or next(_equipmentData[tostring(v.heroid)]) == nil then
            _equipmentData[tostring(v.heroid)] = { }
        end
        _equipmentData[tostring(v.heroid)][#_equipmentData[tostring(v.heroid)] + 1] = v
    end
    -- 组合成英雄数据
    local m_herosData = { }
    for k, v in pairs(_temp_data) do
        v.equipments = { }
        v.equipments = _equipmentData[tostring(k)] or { }
        m_herosData[#m_herosData + 1] = v
    end
    if #m_herosData > 1 then
        table.sort(m_herosData, function(data1, data2)
            if data1["level"] ~= data2["level"] then
                return tonumber(data1["level"]) > tonumber(data2["level"])
            elseif data1["curexp"] ~= data2["curexp"] then
                return tonumber(data1["curexp"]) > tonumber(data2["curexp"])
            else
                return tonumber(data1["heroid"]) < tonumber(data2["heroid"])
            end
        end )
    end
    return m_herosData
end
-------------------关于数据End-------------------

-- 获取英雄信息界面的文字颜色
function YingXiongInfoLayer:getTextColor(_str)
    -- local _nameColor = XTHD.resource.getQualityItemColor(self.itemInfoData["rank"])
    local _textColor = {
        hongse = cc.c4b(204,2,2,255),
        -- 红色
        shenhese = cc.c4b(70,34,34,255),
        -- 深褐色，用的比较多
        lanse = cc.c4b(26,158,207,255),
        -- 蓝色
        chenghongse = cc.c4b(205,101,8,255),
        -- 橙红色
        zongse = cc.c4b(128,112,91,255),
        -- 棕色，有点深灰色的感觉
        baise = cc.c4b(255,255,255,255),
        -- 白色
        lvse = cc.c4b(104,157,0,255),-- 绿色
    }
    return _textColor[_str]
end
-- dataNumber,herosData,items_data,_type,_closeCallback,heroId
function YingXiongInfoLayer:create(params)
    local layer = self.new(params);
    return layer;
end

function YingXiongInfoLayer:create2(params)
    local layer = self.new(params);
    layer:getChildByName("TopBarLayer1"):setBackCallFunc( function()
        self:getChildByName("TopBarLayer1"):getChildByName("topBarBackBtn"):setClickable(false)
        LayerManager.removeLayout()
    end )
    return layer;
end

function YingXiongInfoLayer:addGuide()
    local target = nil
    local back = self:getChildByName("TopBarLayer1"):getChildByName("topBarBackBtn")
    YinDaoMarg:getInstance():addGuide( {
        ----返回
        parent = self,
        target = back,
        needNext = false,
    } , {
        { 2, 9 },{ 5, 6 }
    } )

    -- 先去掉一键装备的引导
    --    YinDaoMarg:getInstance():addGuide( {
    --        -----一键装备
    --        parent = self,
    --        target = self.guide_oneKeyEquip,
    --        index = 4,
    --        needNext = false
    --    } , 2)
    --    YinDaoMarg:getInstance():addGuide( {
    --        -----一键强化
    --        parent = self,
    --        target = self.guide_oneKeyStrength,
    --        index = 5,
    --        needNext = false,
    --    } , 2)

    -- elseif gameUser.getInstancingId() == 12 then -----第10组引导
    --     target = self.rightTab_btn["levelup_btn"]
    --     if target then
    --         YinDaoMarg:getInstance():addGuide({ -----点击升级
    --             parent = self,
    --             target = target,
    --             index = 5,
    --             needNext = false,
    --         },10)
    --     end
    target = self.rightTab_btn["skill_btn"]
    if target then
        YinDaoMarg:getInstance():addGuide( {
            -----点击升级技能
            parent = self,
            target = target,
            index = 4,
            needNext = false,
        } , 5)
    end
    target = self.rightTab_btn["advance_btn"]
    if target then
        YinDaoMarg:getInstance():addGuide( {
            -----点击进阶
            parent = self,
            target = target,
            index = 4,
            needNext = false,
        } , 7)
    end
    -- elseif gameUser.getInstancingId() == 21 then -----第13组引导
    --     target = self.rightTab_btn["levelup_btn"]
    --     if target then
    --         YinDaoMarg:getInstance():addGuide({ -----点击升级
    --             parent = self,
    --             target = target,
    --             index = 5,
    --             needNext = false,
    --         },13)
    --     end
    --    elseif gameUser.getInstancingId() == 24 then ---第15组引导
    YinDaoMarg:getInstance():addGuide( { parent = self, index = 4 }, 13)
    ----剧情
    target = self.rightTab_btn["starup_btn"]
    ----升星
    if target then
        YinDaoMarg:getInstance():addGuide( {
            -----点击升星
            parent = self,
            target = target,
            index = 5,
            needNext = false,
        } , 13)
    end

    YinDaoMarg:getInstance():addGuide( {
        -----引导去装备弹窗
        parent = self,
        target = self.heroFunctionBtn[5],
        needNext = false,
    } , {
        { 2, 5 }
    } )

    --    elseif gameUser.getInstancingId() == 48 then ---第15组引导
    --  YinDaoMarg:getInstance():addGuide({parent = self,index = 8},21)----剧情
    --        YinDaoMarg:getInstance():addGuide({ -----点击神器
    --            parent = self,
    --            target = self._artifact,
    --            index = 5,
    --        },21)
    --        YinDaoMarg:getInstance():addGuide({ -----点击神器
    --            parent = self,
    --            target = self._artifact,
    --            index = 9,
    --        },21)
    -- end

    -- local _group,_index = YinDaoMarg:getInstance():getGuideSteps()
    -- if _group == 10 and _index == 4 and self.data.level > 1 then
    --  YinDaoMarg:getInstance():skipGuideOnGI(10,7)
    -- end
    YinDaoMarg:getInstance():doNextGuide()
end

-- 回收英雄
function YingXiongInfoLayer:HuiShouHero(heroid)
    local rightfunc = function()

    end

    local _confirmLayer = XTHDConfirmDialog:createWithParams( {
        rightText = "确定",
        rightCallback = rightfunc,
        msg = ("确定要回收该英雄吗？")
    } );
    self:addChild(_confirmLayer, 1)
end

function YingXiongInfoLayer:JiangJuFuGeneralRoom()
    local JiangJuFuGeneralRoom = requires("src/fsgl/layer/JiangJunFu/JiangJuFuGeneralRoom.lua"):create(self.data.heroid, self)
    LayerManager.addLayout(JiangJuFuGeneralRoom)
end

return YingXiongInfoLayer;