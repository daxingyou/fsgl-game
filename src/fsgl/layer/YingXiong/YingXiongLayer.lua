-- xingchen
local YingXiongLayer = class("YingXiongLayer", function()
    return XTHD.createBasePageLayer()
end )

function YingXiongLayer:ctor()
    -- 设置页面存在	
    SCENEEXIST.HEROLAYER = true

    self.m_herosData = { }
    -- 已拥有英雄数据
    self.canRecruit_herosData = { }
    -- 可招募英雄
    self.other_herosData = { }
    -- 未拥有英雄数据
    self.other_chipData = { }
    -- 魂石数据
    self.tableView = nil
    self.hero_select_bg = nil
    --
    self.tableViewSize = cc.size(0, 0)
    self.m_cellNumber = 0
    -- 分割线上cell数量
    self.canRecruit_heroNumber = 0
    -- 可招募英雄数量
    self.other_cellNumber = 0
    -- 分割线下cell数量
    self.canRecruit_herosArr = { }
    -- 存放cell中的已拥有英雄信息
    self.m_herosArr = { }
    -- 存放cell中的已拥有英雄信息
    self.other_herosArr = { }
    -- 存放cell中的未拥有英雄信息
    self.createSpCells = 0
    -- 已经创建过精灵的行数
    self.right_btn_arr = { }
    self.items_data = { }
    -- 道具信息 有key值
    self._countIndex = 1
    -- 用来计数是否刷新主城红点 (碰到true就要去刷新，但是因为会继续调用刷新函数，所以写个计数只会刷新一次)

    self.starupchipData = { }

    self.showType = 1
    -- 当前显示的是全部，前中后排

    self.staticItemData = { }
    -- Item静态数据
    self.dynamicItemData = { }
    -- 动态数据库Item的数据
    self.dynamicEquipmentData = { }
    -- 动态数据库Equipment的数据
    self.__heros = { }
    -- 记录英雄列表里的英雄
    self.__lockedHeros = { }
    -- 未解锁的英雄们
    self.clickNumber = 0
    -- 点击次数，保证点击过一个后无法点击第二个
    self._offset = 0
    -- 偏移量
    self._subDistance = 2
    -- 中间
    self.heroBgWidth = 410
    -- 英雄背景宽度

    self.turnRefreshData = { _offset = nil, _tab = 1 }

    --    --重写TopbarLayer的backBtn函数
    --    self:getChildByName("TopBarLayer1"):setBackCallFunc(function()
    --    	if tonumber(self.clickNumber) > 0 then
    --    		return
    --    	end
    -- 	self:getChildByName("TopBarLayer1"):getChildByName("topBarBackBtn"):setClickable(false)
    -- 	LayerManager.popModule()
    -- end)
    YinDaoMarg:getInstance():getACover(self)
end

function YingXiongLayer:onEnter()

    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
    -- 判断是否跳转
    if tonumber(self.clickNumber) ~= 0 then
        self:reFreshHeroChipByTurn()
    end
    self.clickNumber = 0
end

function YingXiongLayer:onExit()
    self.__heros = { }
    self.__lockedHeros = { }
    self:setAllNil()
    self.clickNumber = 1

end

function YingXiongLayer:onCleanup()
    -- 设置页面不存在
    SCENEEXIST.HEROLAYER = false
    helper.collectMemory()
    -- XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER)
end


function YingXiongLayer:init()
    -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER})
    XTHD.addEventListenerWithNode( {
        name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK,
        node = self,
        callback = function()
            self:reFreshHeroChipByTurn()
        end
    } )

    self.m_herosData = { }
    self.other_herosData = { }
    self.other_chipData = { }
    local _topBarHeight = self.topBarHeight or 45

    local _bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
    local bsize = _bg:getContentSize()
    _bg:setPosition(cc.p(self:getContentSize().width / 2,(self:getContentSize().height - _topBarHeight) / 2))
    self:addChild(_bg)

    local title = "res/image/public/yingxiong.png"
    XTHD.createNodeDecoration(_bg, title)

    -- 阴影
    local shadow = ccui.Scale9Sprite:create("res/image/common/common_black_shadow.png")
    shadow:setAnchorPoint(1, 0.5)
    shadow:setPosition(_bg:getContentSize().width, _bg:getContentSize().height / 2)
    _bg:addChild(shadow)

    -- local hero_select_bg = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_2.png")
    -- hero_select_bg:setContentSize(cc.size(802,468))
    -- self.hero_select_bg = hero_select_bg
    -- hero_select_bg:setPosition(self:getContentSize().width / 2 -47, (self:getContentSize().height - 84 + 8) / 2)
    -- self:addChild(hero_select_bg)

    local btn_normalpath = "res/image/common/btn/btn_tabClassify_normal.png"
    local btn_selectpath = "res/image/common/btn/btn_tabClassify_selected.png"
    -- 右侧按钮
    for i = 1, 5 do
        local _btn = XTHD.createButton( {
            normalNode = getCompositeNodeWithImg(btn_normalpath,"res/image/plugin/hero/tab_labelnormal_" .. i .. ".png")
            ,
            selectedNode = getCompositeNodeWithImg(btn_selectpath,"res/image/plugin/hero/tab_labelselected_" .. i .. ".png")
            ,
            touchSize = cc.size(73,85)
        } )
        _btn:setScale(0.7)
        self.right_btn_arr[#self.right_btn_arr + 1] = _btn
        _btn:setAnchorPoint(0, 1)
        _btn:setPosition(32, 460 - _btn:getContentSize().height *(i - 1) * 0.7)
        shadow:addChild(_btn)
        _btn:setTouchEndedCallback( function()
            self:selectHeroTypeCallback(i)
            self.tableView:reloadData()
        end )
    end

    local hero_select_bg = cc.Sprite:create("res/image/common/tab_contentBg.png")
    hero_select_bg:setContentSize(hero_select_bg:getContentSize().width, hero_select_bg:getContentSize().height - 5)
    self.hero_select_bg = hero_select_bg
    hero_select_bg:setAnchorPoint(cc.p(1, 0))
    hero_select_bg:setPosition(cc.p(bsize.width - 72, 18))
    _bg:addChild(hero_select_bg, 1)

    self._subDistance = 2
    self.tableViewSize = cc.size(bsize.width - 128, hero_select_bg:getContentSize().height)
    self.heroBgWidth =(self.tableViewSize.width - self._subDistance) / 2


    self.tableView = cc.TableView:create(self.tableViewSize)
    TableViewPlug.init(self.tableView)
    self.tableView:setAnchorPoint(0, 0)
    self.tableView:setPosition(-50, 0)
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:setDelegate()
    hero_select_bg:addChild(self.tableView)

    local _titleheight = 46
    -- do return end
    local _cellContentSize = cc.size(self.tableViewSize.width, 116 + 10)

    self.tableView.getCellNumbers = function(table_view)
        return self.m_cellNumber + self.other_cellNumber
    end

    self.tableView:registerScriptHandler(self.tableView.getCellNumbers, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    self.tableView.getCellSize = function(table_view, idx)
        if idx == self.m_cellNumber - 1 and self.other_cellNumber > 0 then
            return self.tableViewSize.width, _titleheight
        end
        return self.tableViewSize.width, _cellContentSize.height
    end

    self.tableView:registerScriptHandler(self.tableView.getCellSize, cc.TABLECELL_SIZE_FOR_INDEX)

    self.tableView:registerScriptHandler( function(table_view, idx)
        local cell = table_view:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
            if idx == self.m_cellNumber - 1 and self.other_cellNumber > 0 then
                cell:setContentSize(cc.size(self.tableViewSize.width, _titleheight))
            else
                cell:setContentSize(cc.size(self.tableViewSize.width, _cellContentSize.height))
            end
        end
        if self.m_cellNumber == idx + 1 and self.other_cellNumber > 0 then
            local _lineBgSpr = ccui.Scale9Sprite:create("res/image/common/common_scale_titlebg.png")
            _lineBgSpr:setContentSize(cc.size(265, 34))
            _lineBgSpr:setAnchorPoint(cc.p(0.5, 0.5))
            _lineBgSpr:setPosition(cc.p(_cellContentSize.width / 2, _titleheight / 2))
            local _lineLabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.noRecruitHeroTextXc, 20)
            _lineLabel:setColor(self:getHeroListTextColor("shenhese"))
            _lineLabel:setAnchorPoint(cc.p(0.5, 0.5))
            _lineLabel:setPosition(cc.p(_lineBgSpr:getContentSize().width / 2, _lineBgSpr:getContentSize().height / 2))
            _lineBgSpr:addChild(_lineLabel)
            cell:addChild(_lineBgSpr)
            return cell
        elseif self.m_cellNumber >= idx + 1 then
            for i = 1, 2 do
                local _numLeft = tonumber(idx * 2 + i)
                local _currentData = { }
                local _currentArr = { }
                -- self.canRecruit_heroNumber的值在每次更换标签时改变（前排变后排）
                if _numLeft > self.canRecruit_heroNumber then
                    _numLeft = _numLeft - self.canRecruit_heroNumber
                    _currentData = self.m_herosData
                    _currentArr = self.m_herosArr
                else
                    _currentData = self.canRecruit_herosData
                    _currentArr = self.canRecruit_herosArr
                end

                if not _currentArr[_numLeft] then
                    return cell
                elseif tonumber(_currentArr[_numLeft]._type) ~= self.showType and self.showType ~= 1 and self.showType ~= 5 then
                    return cell
                end
                if _currentArr[_numLeft].cell then
                    _currentArr[_numLeft].cell:removeFromParent()
                end
                local _leftHero = _currentArr[_numLeft].cell or nil
                if not _leftHero then
                    local _createType = "mine"
                    if _currentArr[_numLeft]._isCanRecruit ~= nil and tonumber(_currentArr[_numLeft]._isCanRecruit) == 1 then
                        _createType = "others"
                    else
                        _createType = "mine"
                    end
                    _leftHero = self:createHero(_currentData[_currentArr[_numLeft]._idx], _createType)
                    _leftHero:retain()
                    _currentArr[_numLeft].cell = _leftHero
                    local _num = _currentArr[_numLeft]._idx
                    _leftHero:setTouchEndedCallback( function()
                        ------引导
                        YinDaoMarg:getInstance():guideTouchEnd()
                        YinDaoMarg:getInstance():releaseGuideLayer()
                        ---------------------------------------
                        if self.clickNumber > 0 then
                            return
                        end
                        if _leftHero.isCanRecruit and _leftHero.isCanRecruit == true then
                            self:toRecruitHero(_num)
                            return
                        end
                        self._offset = self.tableView:getContentOffset().y
                        self.turnRefreshData._offset = self.tableView:getContentOffset().y
                        self.turnRefreshData._tab = self.showType or 1
                        local _layer = requires("src/fsgl/layer/YingXiong/YingXiongInfoLayer.lua"):create( {
                            dataNumber = _num
                            ,
                            herosData = self.m_herosData
                            ,
                            items_data = self.items_data
                        } )
                        LayerManager.pushModule(_layer)
                    end )
                end
                local _distance_ = tonumber(self._subDistance + _leftHero:getContentSize().width / 2)
                _leftHero:setPosition(_cellContentSize.width / 2 +(i * 2 * _distance_ - 3 * _distance_), _cellContentSize.height / 2)
                cell:addChild(_leftHero)
            end
        elseif self.m_cellNumber < idx + 1 then
            for i = 1, 2 do
                local _numLeft =(idx - self.m_cellNumber) * 2 + i
                if not self.other_herosArr[_numLeft] then
                    return cell
                elseif tonumber(self.other_herosArr[_numLeft]._type) ~= self.showType and self.showType ~= 1 and self.showType ~= 5 then
                    return cell
                end
                if self.other_herosArr[_numLeft].cell then
                    self.other_herosArr[_numLeft].cell:removeFromParent()
                end
                local _leftotherHero = self.other_herosArr[_numLeft].cell or nil
                local _leftHeroId = self.other_herosData[self.other_herosArr[_numLeft]._idx].heroid
                if not _leftotherHero then
                    _leftotherHero = self:createHero(self.other_herosData[self.other_herosArr[_numLeft]._idx], "others")
                    _leftotherHero:retain()
                    self.other_herosArr[_numLeft].cell = _leftotherHero
                    local _data_id = self.other_herosArr[_numLeft]._idx
                    _leftotherHero:setTouchEndedCallback( function()
                        if self.clickNumber > 0 then
                            return
                        end
                        local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
                        popLayer = popLayer:create(tonumber(_leftHeroId) + 1000)
                        popLayer:setName("ItemDropPop")
                        self:addChild(popLayer)
                    end )
                end
                local _distance_ = tonumber(self._subDistance + _leftotherHero:getContentSize().width / 2)
                _leftotherHero:setPosition(_cellContentSize.width / 2 +(i * 2 * _distance_ - 3 * _distance_), _cellContentSize.height / 2)
                cell:addChild(_leftotherHero)
            end
        end
        return cell
    end , cc.TABLECELL_SIZE_AT_INDEX)

    local _loadLabel = XTHDLabel:create(LANGUAGE_KEY_LOADINGWAIT .. "...", 20)
    --------正在加载资源，请稍后...",20)
    _loadLabel:setColor(self:getHeroListTextColor("shenhese"))
    _loadLabel:setPosition(cc.p(hero_select_bg:getContentSize().width / 2, hero_select_bg:getContentSize().height / 2))
    hero_select_bg:addChild(_loadLabel)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.000001), cc.CallFunc:create( function()
        self:refreshTableView()
        _loadLabel:removeFromParent()
    end )))
    -- ,cc.DelayTime:create(0.00001),cc.CallFunc:create(function()
    -- 	self:preloadHeroSpine()
    -- end)

end
-- 创建英雄
function YingXiongLayer:createHero(hero_data, _type)
    local _contentSize = cc.size(self.heroBgWidth, 114 + 10)
    local _btnNormal_node = ccui.Scale9Sprite:create(cc.rect(12, 12, 1, 1), "res/image/common/scale9_bg_25.png")
    _btnNormal_node:setOpacity(0)
    _btnNormal_node:setContentSize(_contentSize)
    local select_bg = XTHDPushButton:createWithParams( {
        normalNode = _btnNormal_node
        ,
        needEnableWhenMoving = true
        ,
        needSwallow = false
        ,
        touchScale = 0.95
        ,
        touchSize = _contentSize
        ,
        isScrollView = true
        -- ,musicFile = XTHD.resource.music.effect_btn_common
    } )
    local _herobg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
    _herobg:setContentSize(cc.size(_contentSize.width - 5 * 2, _contentSize.height - 5 * 2))
    _herobg:setPosition(cc.p(select_bg:getContentSize().width / 2, select_bg:getContentSize().height / 2))
    select_bg:addChild(_herobg)

    -- 英雄头像
    local _starNum = 0
    if _type == "others" then
        _starNum = 0
    elseif _type == "mine" then
        _starNum = hero_data["star"]
    end
    local head_bg = HeroNode:createWithParams( {
        heroid = hero_data["heroid"] or 1,
        star = _starNum,
        isShowType = false,
        level = hero_data["level"] or 0,
        advance = hero_data["advance"] or 1,
        clickable = false
    } )
    head_bg:setName("head_bg")
    head_bg:setAnchorPoint(0, 0.5)
    head_bg:setPosition(20, select_bg:getContentSize().height / 2)
    select_bg:addChild(head_bg)

    -- 英雄评分等级
    local showHero = gameData.getDataFromCSV("GeneralShow", { heroid = hero_data["heroid"] })
    local herorankbg = cc.Sprite:create("res/image/common/herorank_" .. showHero.rank .. ".png")
    head_bg:addChild(herorankbg)
    herorankbg:setScale(0.8)
    herorankbg:setPosition(head_bg:getContentSize().width * 0.5, head_bg:getContentSize().height - 15)

    local _nameBg = ccui.Scale9Sprite:create("res/image/plugin/competitive_layer/n_bg1.png")
    _nameBg:setContentSize(cc.size(400, 30))
    _nameBg:setAnchorPoint(cc.p(0, 0.5))
    _nameBg:setPosition(cc.p(head_bg:getBoundingBox().x + head_bg:getBoundingBox().width + 5
    , head_bg:getBoundingBox().y + head_bg:getBoundingBox().height - 23))
    select_bg:addChild(_nameBg)
    local type_bg = cc.Sprite:create("res/image/plugin/hero/hero_type_" ..(hero_data.type or 1) .. ".png")
    -- type_bg:setAnchorPoint(cc.p(0,0.5))
    type_bg:setPosition(20, _nameBg:getContentSize().height / 2)
    _nameBg:addChild(type_bg)

    -- 红点
    if select_bg:getChildByName("redPoint") then
        select_bg:getChildByName("redPoint"):removeFromParent()
    end

    local heroRankTab = { }
    if _type == "others" then
        XTHD.setGray(type_bg, true)

        -- 如果数据不存在或数据为空
        if not self.starupchipData or next(self.starupchipData) == nil then
            self:setStarUpChip()
        end
        local _itemBorder = head_bg:getChildByName("item_border")
        local _headSp = _itemBorder:getChildByName("hero_img")
        for i = 1, 5 do
            if _itemBorder:getChildByName("star_sp" .. i) then
                _itemBorder:removeChildByName("star_sp" .. i)
            end
        end
        XTHD.setGray(_itemBorder, true)
        XTHD.setGray(_headSp, true)
        heroRankTab.color = cc.c4b(255, 255, 255, 255)
        heroRankTab.addNumber = 0

        -- 进度条	
        local _chipBg = cc.Sprite:create("res/image/common/common_progressYX_bg.png")
        _chipBg:setScaleY(0.8)
        _chipBg:setScaleX(0.6)
        _chipBg:setAnchorPoint(cc.p(0, 0.5))
        _chipBg:setPosition(cc.p(head_bg:getBoundingBox().x + head_bg:getBoundingBox().width + 12, 30))
        select_bg:addChild(_chipBg)
        local _progressChip = cc.ProgressTimer:create(cc.Sprite:create("res/image/common/common_progressYX.png"))
        _progressChip:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        _progressChip:setMidpoint(cc.p(0, 0.5))
        _progressChip:setBarChangeRate(cc.p(1, 0))
        _progressChip:setAnchorPoint(cc.p(0.5, 0.5))
        _progressChip:setPercentage(0)
        _progressChip:setPosition(cc.p(_chipBg:getContentSize().width / 2, _chipBg:getContentSize().height / 2 - 3))
        _chipBg:addChild(_progressChip)

        local _m_chipNum = hero_data.chipNumber
        local _star_count = hero_data.star and tonumber(hero_data.star) or 0
        local _all_chipNum = self.starupchipData[tonumber(hero_data["heroid"])]["starcount" .. _star_count]
        local _label_sprite = nil
        local _labelPosY = _progressChip:getContentSize().height / 2
        if tonumber(_m_chipNum) ~= 0 and tonumber(_m_chipNum) >= tonumber(_all_chipNum) then
            _label_sprite = cc.Sprite:create("res/image/plugin/hero/label_kezhaomu.png")
            _progressChip:setPercentage(100)
            select_bg.isCanRecruit = true
            _labelPosY = _progressChip:getContentSize().height / 2
        else
            _label_sprite = getCommonWhiteBMFontLabel(tostring(hero_data.chipNumber or 0) .. "/" .. tostring(_all_chipNum))
            _progressChip:setPercentage(tonumber(hero_data.chipPercent))
            select_bg.isCanRecruit = false
            _labelPosY = _progressChip:getContentSize().height / 2 - 7

        end
        _label_sprite:setAnchorPoint(cc.p(0.5, 0.5))
        _label_sprite:setPosition(cc.p(_progressChip:getContentSize().width / 2, _labelPosY + 2))
        _label_sprite:setScale(1.2)
        _progressChip:addChild(_label_sprite)
        self:createHerosRedPoint(select_bg, hero_data, "other")
    elseif _type == "mine" then
        heroRankTab = XTHD.resource.getRankColor_number(hero_data["advance"] or 0, hero_data.heroid)
        heroRankTab.color = self:getHeroListTextColor("shenhese")
        -- heroRankTab["addNumber"] = hero_data["advance"] or 0
        self:createHerosRedPoint(select_bg, hero_data, "mine")
        self:createMyHerosEquipments(select_bg, hero_data)
    else
        return select_bg
    end

    local label_name = XTHDLabel:create(hero_data["name"], 20)
    label_name:setName("label_name")
    label_name:setColor(self:getHeroListTextColor("shenhese"))
    label_name:setAnchorPoint(0, 0.5)
    label_name:enableShadow(cc.c4b(70, 34, 34, 0), cc.size(0.4, -0.4), 1)
    label_name:setPosition(cc.p(50, _nameBg:getContentSize().height / 2))
    _nameBg:addChild(label_name)
    if tonumber(heroRankTab["addNumber"]) > 0 then
        local label_addNumber = XTHDLabel:create(heroRankTab["addNumberStr"], 20)
        label_addNumber:setColor(heroRankTab["color"])
        label_addNumber:setName("label_addNumber")
        label_addNumber:setAnchorPoint(cc.p(0, 0.5))
        label_addNumber:enableShadow(heroRankTab["color"], cc.size(0.4, -0.4), 0.5)
        -- label_name:setPositionX(_nameBg:getContentSize().width/2 - 4/2-label_addNumber:getContentSize().width/2)
        label_addNumber:setPosition(cc.p(label_name:getBoundingBox().x + label_name:getContentSize().width + 4, label_name:getPositionY()))
        _nameBg:addChild(label_addNumber)
    end

    return select_bg
end
function YingXiongLayer:createHerosRedPoint(_targetBg, _hero_data, _type)
    if _targetBg:getChildByName("redPoint") then
        _targetBg:getChildByName("redPoint"):removeFromParent()
    end
    local _headBgRedPointState = false
    if _type and tostring(_type) == "mine" then
        _headBgRedPointState = RedPointManage:getTheHeroRedPointState(_hero_data.heroid)
    else
        _headBgRedPointState = RedPointManage:getTheHeroRecruitState(_hero_data.heroid)
    end
    if _headBgRedPointState == true then
        self:createRedPointSp(_targetBg)
    end
    if self._countIndex == 1 then
        self:updateMainCityRedPoint(_targetBg, _hero_data, _type)
    end
end

function YingXiongLayer:updateMainCityRedPoint(_targetBg, _hero_data, _type)
    RedPointState[12].state = 0
    local _headBgRedPointState = false
    if _type and tostring(_type) == "mine" then
        _headBgRedPointState = RedPointManage:getTheHeroRedPointState(_hero_data.heroid)
    else
        _headBgRedPointState = RedPointManage:getTheHeroRecruitState(_hero_data.heroid)
    end
    if _headBgRedPointState == true then
        self._countIndex = 2
        RedPointState[12].state = 1
        XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT, data = { ["name"] = "hero" } })
        return
    end
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT, data = { ["name"] = "hero" } })
end

function YingXiongLayer:createRedPointSp(_targetBg)
    if not _targetBg:getChildByName("redPoint") then
        local _redPoint = cc.Sprite:create("res/image/common/heroList_redPoint.png")
        _redPoint:setName("redPoint")
        _redPoint:setAnchorPoint(cc.p(1, 1))
        _redPoint:setPosition(cc.p(_targetBg:getContentSize().width, _targetBg:getContentSize().height))
        _targetBg:addChild(_redPoint)
    end
end
-- 已招募英雄的装备部分
function YingXiongLayer:createMyHerosEquipments(_targetBg, _hero_data)
    local _headBg = _targetBg:getChildByName("head_bg")
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
    -- 英雄穿戴的装备
    for i = 1, 6 do
        if _targetBg:getChildByName("item" .. i) then
            _targetBg:getChildByName("item" .. i):removeAllChildren()
            _targetBg:getChildByName("item" .. i):removeFromParent()
        end
        local equip_id = -1
        local _equipData = { }
        if equipments[tostring(i)] and next(equipments[tostring(i)]) ~= nil and equipments[tostring(i)].itemid then
            equip_id = equipments[tostring(i)].itemid
            _equipData = equipments[tostring(i)]
        end
        local _distanceToHero = 12
        -- 如果已经穿戴了这个装备
        if equip_id ~= -1 then
            local _itemStaticData = self.staticItemData[tostring(_equipData["itemid"])] or { }
            local item_bg = cc.Sprite:create(XTHD.resource.getItemImgById(_itemStaticData.resourceid or 0))

            local item_border = cc.Sprite:create(XTHD.resource.getQualityItemBgPath(_equipData.quality or 0))
            item_border:setPosition(cc.p(item_bg:getContentSize().width / 2, item_bg:getContentSize().height / 2))
            item_bg:addChild(item_border)

            item_bg:setName("item_bg" .. i)
            item_bg:setAnchorPoint(0, 0.5)
            item_bg:setScale(36 / item_bg:getContentSize().width)
            item_bg:setPosition(_headBg:getBoundingBox().x + _headBg:getBoundingBox().width + _distanceToHero +(i - 1) *(4 + 40), 10 + 30)
            _targetBg:addChild(item_bg)
        else
            local item_bg = cc.Sprite:create("res/image/plugin/hero/item_bg.png")
            item_bg:setAnchorPoint(0, 0.5)
            item_bg:setName("item_bg" .. i)
            item_bg:setScale(0.9)
            item_bg:setPosition(_headBg:getBoundingBox().x + _headBg:getBoundingBox().width + _distanceToHero +(i - 1) *(4 + 40), 10 + 30)
            _targetBg:addChild(item_bg)
            local _texturetype = self:getItemState(i, {
                _type = _hero_data.type or 0,
                _level = _hero_data.level or 0
            } )
            if _texturetype ~= nil then
                local _imgPath = nil
                if _texturetype == "canEquip" then
                    _imgPath = "res/image/plugin/hero/label_add_green.png"
                else
                    _imgPath = "res/image/plugin/hero/label_add_yellow.png"
                end
                local _itemIdentify = cc.Sprite:create(_imgPath)
                _itemIdentify:setScale(0.7)
                _itemIdentify:setName("itemIdentify")
                _itemIdentify:setAnchorPoint(cc.p(0.5, 0.5))
                _itemIdentify:setPosition(cc.p(item_bg:getContentSize().width / 2, item_bg:getContentSize().height / 2))
                item_bg:addChild(_itemIdentify)
            else
                if item_bg:getChildByName("itemIdentify") then
                    item_bg:getChildByName("itemIdentify"):removeFromParent()
                end
            end
        end
    end
end
-- 按钮点击
function YingXiongLayer:selectHeroTypeCallback(_type)
    self.canRecruit_heroNumber = 0
    for i, var in pairs(self.right_btn_arr) do
        var:setSelected(false)
        var:setLocalZOrder(0)
    end
    if self.hero_select_bg ~= nil and self.hero_select_bg:getChildByName("nohero_promptLabel") then
        self.hero_select_bg:getChildByName("nohero_promptLabel"):removeFromParent()
    end
    self.right_btn_arr[_type]:setSelected(true)
    self.right_btn_arr[_type]:setLocalZOrder(1)
    if _type == 1 then
        -- 全部
        table.sort(self.m_herosArr, function(data1, data2)
            return tonumber(data1._idx) < tonumber(data2._idx)
        end )
        table.sort(self.canRecruit_herosArr, function(data1, data2)
            return tonumber(data1._idx) < tonumber(data2._idx)
        end )
        table.sort(self.other_herosArr, function(data1, data2)
            return tonumber(data1._idx) < tonumber(data2._idx)
        end )
        self.canRecruit_heroNumber = #self.canRecruit_herosData
        self.m_cellNumber = math.ceil((#self.m_herosData + #self.canRecruit_herosData) / 2) + 1
        self.other_cellNumber = math.ceil(#self.other_herosData / 2)
    elseif _type >= 2 and _type <= 4 then
        -- 前中后排
        local _up_cellNumber = 0
        -- 已招募
        table.sort(self.m_herosArr, function(data1, data2)
            local _data1Num = data1._idx
            local _data2Num = data2._idx
            if tonumber(data1._type) ~= tonumber(_type) then
                _data1Num = _data1Num * 100
            end
            if tonumber(data2._type) ~= tonumber(_type) then
                _data2Num = _data2Num * 100
            end
            return _data1Num < _data2Num
        end )
        for i = 1, #self.m_herosArr do
            _up_cellNumber = i
            if tonumber(self.m_herosArr[i]._type) ~= _type then
                -- self.m_cellNumber = math.ceil((i-1)/2)+1
                _up_cellNumber = i - 1
                break
            end
        end
        -- 可招募
        table.sort(self.canRecruit_herosArr, function(data1, data2)
            local _data1Num = data1._idx
            local _data2Num = data2._idx
            if tonumber(data1._type) ~= tonumber(_type) then
                _data1Num = _data1Num * 100
            end
            if tonumber(data2._type) ~= tonumber(_type) then
                _data2Num = _data2Num * 100
            end
            return _data1Num < _data2Num
        end )
        for i = 1, #self.canRecruit_herosArr do
            self.canRecruit_heroNumber = i
            if tonumber(self.canRecruit_herosArr[i]._type) ~= _type then
                -- self.m_cellNumber = math.ceil((i-1)/2)+1
                self.canRecruit_heroNumber = i - 1
                break
            end
        end
        self.m_cellNumber = math.ceil((_up_cellNumber + self.canRecruit_heroNumber) / 2) + 1

        -- 未招募（暂时没有达到招募条件）
        table.sort(self.other_herosArr, function(data1, data2)
            local _data1Num = data1._idx
            local _data2Num = data2._idx
            if tonumber(data1._type) ~= tonumber(_type) then
                _data1Num = _data1Num * 100
            end
            if tonumber(data2._type) ~= tonumber(_type) then
                _data2Num = _data2Num * 100
            end
            return _data1Num < _data2Num
        end )
        for i = 1, #self.other_herosArr do
            if tonumber(self.other_herosArr[i]._type) ~= _type then
                self.other_cellNumber = math.ceil((i - 1) / 2)
                break
            end
        end
    elseif _type == 5 then
        table.sort(self.other_herosArr, function(data1, data2)
            return tonumber(data1._idx) < tonumber(data2._idx)
        end )
        self.m_cellNumber = 0
        self.canRecruit_heroNumber = 0
        self.other_cellNumber = math.ceil(#self.other_herosData / 2)
        if self.other_cellNumber < 1 and self.hero_select_bg ~= nil then
            local _nohero_promptLabel = XTHDLabel:create(LANGUAGE_TIPS_WORDS109, 30)
            -------"恭喜您已经收集到全部英雄了!",30)
            _nohero_promptLabel:setName("nohero_promptLabel")
            _nohero_promptLabel:setColor(self:getHeroListTextColor("shenhese"))
            _nohero_promptLabel:setPosition(cc.p(self.hero_select_bg:getContentSize().width / 2, self.hero_select_bg:getContentSize().height / 2))
            self.hero_select_bg:addChild(_nohero_promptLabel)
        end
    end
    self.showType = _type or 1
    if tonumber(self.other_cellNumber) == 0 and tonumber(self.m_cellNumber) > 0 then
        self.m_cellNumber = self.m_cellNumber - 1
    elseif tonumber(self.m_cellNumber) < 0 then
        self.m_cellNumber = 0
    end
    if tonumber(self.other_cellNumber) < 0 then
        self.other_cellNumber = 0
    end
end

-- 获取装备状态
function YingXiongLayer:getItemState(_pos, hero_Data)
    local _texture = nil
    local _state = false
    if self.items_data ~= nil and next(self.items_data) ~= nil then
        for k, var in pairs(self.items_data) do
            if var.equipment and tonumber(var.equipment.equippos) == tonumber(_pos) then
                local _heroType = string.split(var.equipment.herotype, '#')
                for i, v in pairs(_heroType) do
                    if tonumber(v) == tonumber(hero_Data._type) then
                        if not _state then
                            _texture = "cannotEquip"
                            _state = true
                        end
                        if tonumber(var.level) <= tonumber(hero_Data._level) then
                            _texture = "canEquip"
                            _state = true
                        end
                    end
                end
            end
        end
    end
    if _texture == nil then
        return nil
    else
        return _texture
    end
end

function YingXiongLayer:preloadHeroSpine()
    -- do return end
    local _heroidData = { }
    _heroidData[#_heroidData + 1] = self.m_herosData[1].heroid or 1
    if #self.m_herosData > 1 then
        _heroidData[#_heroidData + 1] = self.m_herosData[2].heroid or 1
    end
    for i = 1, #_heroidData do
        local _id = i
        local _spine_sp = XTHD.getHeroSpineById(_id)
    end

end

-- 获取相应id英雄的位置，并返回该对象
-- 注意调用回调的时机，一定要保证tableview已经reloadData了
function YingXiongLayer:getHeroObjAndScrollToCellByHeroid(_heroid)
    local _heroObj = nil
    if _heroid == nil or tonumber(_heroid) < 1 then
        return _heroObj
    end
    local _posIndex = 0
    for i = 1, #self.m_herosData do
        if tonumber(self.m_herosData[i].heroid) == _heroid then
            _posIndex = i
            break
        end
    end
    if _posIndex == 0 then
        return _heroObj
    end
    local _index = 0
    for i = 1, #self.m_herosArr do
        if tonumber(self.m_herosArr[i]._idx) == _posIndex then
            _index = i

            break
        end
    end
    if _index == 0 then
        return _heroObj
    end
    self.tableView:scrollToCell(math.ceil((_index + #self.canRecruit_herosData) / 2) -1)
    _heroObj = self.m_herosArr[tonumber(_index)].cell
    return _heroObj
end

------------------界面功能began-------------------
-- 招募英雄弹出框
function YingXiongLayer:toRecruitHero(_dataId)
    local _herodata = self.canRecruit_herosData[tonumber(_dataId)] or { }
    -- local str = string.format("<color=#462222 fontSize=18 >%s</color><color=#cd6614 fontSize=18 >%s</color>",LANGUAGE_KEY_POWER,data[1].power)
    -- local name = RichLabel:createARichText(str,false)
    local _heroStar_ = _herodata.star or 0
    local _costCoin = 0
    for i = 1, _heroStar_ do
        _costCoin = _costCoin +(self.starupchipData[tonumber(_herodata.heroid)]["goldcost" .. i .. "star"] or 0)
    end

    local _buyDialog = XTHDConfirmDialog:createWithParams( {
        -- msg = _labelStr,
        rightCallback = function()
            if tonumber(gameUser.getFeicui()) < tonumber(_costCoin) then
                local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create( { id = 4 })
                self:addChild(StoredValue)
                return
            end
            self:httpToRecruitHero(_herodata.heroid)
        end
    } )
    local _confirmDialogBg = nil
    if _buyDialog:getContainer() then
        _confirmDialogBg = _buyDialog:getContainer()
    else
        _buyDialog:removeFromParent()
        return
    end
    local _costCoinStr = getHugeNumberWithLongNumber(_costCoin, 10000)
    local _labelStr = "<color=#462222 fontSize=18 >" .. LANGUAGE_KEY_HERO_TEXT.isSureRecruitHeroOneTextXc .. "<img=res/image/common/header_feicui.png height=30 width=30 /></color><color=#689d00 fontSize=22 >" .. _costCoinStr .. "</color><color=#462222 fontSize=18 >" .. LANGUAGE_KEY_HERO_TEXT.isSureRecruitHeroTwoTextXc .. "</color>"
    local labelContent = RichLabel:createARichText(_labelStr, false)
    labelContent:setAnchorPoint(cc.p(0.5, 0.5))
    labelContent:setPosition(cc.p(_confirmDialogBg:getContentSize().width / 2, _confirmDialogBg:getContentSize().height / 2 + 50))
    _confirmDialogBg:addChild(labelContent)

    self:addChild(_buyDialog)
end

function YingXiongLayer:httpToRecruitHero(_heroid)
    ClientHttp:httpHeroToRecruit(self, function(data)
        gameUser.setFeicui(data["feicui"])
        -- 干掉或刷新魂石
        local _dbid = data["bagItems"][1]["dbId"]
        if data["bagItems"][1]["count"] and data["bagItems"][1]["count"] > 0 then
            DBTableItem.updateCount(gameUser.getUserId(), data["bagItems"][1], _dbid)
        else
            DBTableItem.deleteData(gameUser.getUserId(), _dbid)
        end
        gameData.saveDataToDB( { [1] = data["pet"] }, 1)

        local layer = requires("src/fsgl/layer/QiXingTan/QiXingTanGetNewHeroLayer.lua"):create( {
            par = self,
            id = data["pet"].id,
            star = data["pet"].starLevel,
        } )
        -- self:addChild(layer)
        -- 刷新界面
        RedPointManage:getDynamicHeroData()
        RedPointManage:getDynamicItemData()
        RedPointManage:getDynamicDBHeroSkillData()
        RedPointManage:resetRecruitHeroPoint()
        RedPointManage:resetNoRecruitHeroRedPoint()
        XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
        self:reFreshHeroLayerTableView()
    end , { petId = _heroid })
end
------------------界面功能ended-------------------

-----------------关于刷新began-----------------

function YingXiongLayer:setAllNil()
    for k, var in pairs(self.other_herosArr) do
        if var.cell then
            var.cell:release()
            var.cell = nil
        end
    end
    for k, var in pairs(self.m_herosArr) do
        if var.cell then
            var.cell:release()
            var.cell = nil
        end
    end
    for k, var in pairs(self.canRecruit_herosArr) do
        if var.cell then
            var.cell:release()
            var.cell = nil
        end
    end
    self.m_herosArr = { }
    self.other_herosArr = { }
    self.canRecruit_herosArr = { }
end

function YingXiongLayer:refreshTableView()
    self.m_herosData = { }
    self.other_herosData = { }
    self.other_chipData = { }
    self.canRecruit_herosData = { }
    -- 获取数据
    self:getInitData()

    self:selectHeroTypeCallback(self.turnRefreshData._tab or 1)
    if self.tableView ~= nil then
        self.tableView:reloadData()
    end
    if self.turnRefreshData ~= nil and self.turnRefreshData._offset ~= nil then
        self.tableView:setContentOffset(cc.p(0, self.turnRefreshData._offset or 0))
    end
    --------引导
    YinDaoMarg:getInstance():removeCover(self)
    self:addGuide()
    ----------------
end
-- 刷新列表
function YingXiongLayer:reFreshHeroLayerTableView()
    self.turnRefreshData._offset = self.tableView:getContentOffset().y
    self.turnRefreshData._tab = self.showType or 1
    self:setAllNil()
    self:refreshTableView()
end
-- 刷新红点
function YingXiongLayer:reFreshHerosRedPoint()
    if self.m_herosArr == nil or self.m_herosData == nil or next(self.m_herosArr) == nil or next(self.other_herosArr) == nil then
        return
    end
    RedPointManage:resetRecruitHeroPoint()
    for i = 1, #self.m_herosArr do
        local _cell = nil
        _cell = self.m_herosArr[i].cell
        if _cell == nil then
            return
        end
        local _hero_data = self.m_herosData[tonumber(self.m_herosArr[i]._idx)]
        self:createHerosRedPoint(_cell, _hero_data, "mine")
    end
    RedPointManage:resetNoRecruitHeroRedPoint()
    for i = 1, #self.other_herosArr do
        local _cell = nil
        _cell = self.other_herosArr[i].cell
        if _cell == nil then
            return
        end
        local _hero_data = self.other_herosData[tonumber(self.other_herosArr[i]._idx)]
        self:createHerosRedPoint(_cell, _hero_data, "other")
    end
    for i = 1, #self.canRecruit_herosArr do
        local _cell = nil
        _cell = self.canRecruit_herosArr[i].cell
        if _cell == nil then
            return
        end
        local _hero_data = self.canRecruit_herosData[tonumber(self.canRecruit_herosArr[i]._idx)]
        self:createHerosRedPoint(_cell, _hero_data, "other")
    end
end

function YingXiongLayer:reFreshHeroChipByTurn()
    self:refreshTableView()
    -- if self:getChildByName("ItemDropPop") then
    -- 	self:getChildByName("ItemDropPop"):refreshHasNumber()
    -- end
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_ITEMDROP_HASNUMBER })
end

-----------------关于刷新ended-----------------

------------------关于数据began-------------------
function YingXiongLayer:getInitData()
    self:getStaticItemData()

    self:setStarUpChip()
    self:getDynamicDBData()
    self:getItemData()
    self:getMyHeroData()
    self:getOtherHeroData()
    self:getChipData()
    -- 排序
    self:SortForMyHeroData()
    self:SortForCanRecruitHeroData()
    self:SortForOtherHeroData()
    -- 设置heroarray
    self:setMyHeroArray()
    self:setCanRecruitHeroArray()
    self:setOtherHeroArray()
end
function YingXiongLayer:getStaticItemData()
    self.staticItemData = { }
    self.staticItemData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet")
end
-- 获取动态库数据
function YingXiongLayer:getDynamicDBData()
    self:getDynamicDBItemData()
    self:getDynamicDBEquipmentData()
end
-- 获取动态数据库Item的数据
function YingXiongLayer:getDynamicDBItemData()
    self.dynamicItemData = { }
    self.dynamicItemData = DBTableItem:getDataByID()
end
-- 获取动态数据库Equipment的数据
function YingXiongLayer:getDynamicDBEquipmentData()
    self.dynamicEquipmentData = { }
    self.dynamicEquipmentData = DBTableEquipment:getDataByID()
end
-- 获取数装备数据
function YingXiongLayer:getItemData()
    local items_pairs = { }
    self.items_data = { }
    items_pairs = self.dynamicItemData or { }
    local _EquipmentTable = gameData.getDataFromCSVWithPrimaryKey("EquipInfoList")
    for i, var in pairs(items_pairs) do
        self.items_data[tostring(var["dbid"])] = { }
        self.items_data[tostring(var["dbid"])] = var
        self.items_data[tostring(var["dbid"])].level = self.staticItemData[tostring(var["itemid"])] and self.staticItemData[tostring(var["itemid"])].levelfloor or 0
        self.items_data[tostring(var["dbid"])].resourceid = self.staticItemData[tostring(var["itemid"])] and self.staticItemData[tostring(var["itemid"])].resourceid or 0
        local _data_ = _EquipmentTable[tostring(var["itemid"])] or { }
        local _equipmentData = {
            herotype = _data_.herotype or 1
            ,
            equippos = _data_.equippos or 0
        }
        self.items_data[tostring(var["dbid"])].equipment = _equipmentData
    end
end
-- 获取所有拥有的碎片
function YingXiongLayer:getChipData()
    self.other_chipData = { }
    self.canRecruit_herosData = { }
    -- 魂石的item_type都是2
    for k, v in pairs(self.dynamicItemData) do
        if tonumber(v.item_type) == 2 then
            self.other_chipData[tostring(tonumber(v.itemid) -1000)] = { }
            self.other_chipData[tostring(tonumber(v.itemid) -1000)] = v
        end
    end
    local _otherNum = #self.other_herosData
    for i = _otherNum, 1, -1 do
        local _index = i
        local _heroid = self.other_herosData[_index]["heroid"]
        local _chipData = self.other_chipData[tostring(_heroid)] or { }
        self.other_herosData[_index].chipNumber = _chipData.count and _chipData.count or 0
        local _starNum = tonumber(self.other_herosData[_index].star)
        local _chipPercent = math.floor(tonumber(self.other_herosData[_index].chipNumber) / tonumber(self.starupchipData[tonumber(_heroid)]["starcount" .. _starNum]) * 100)
        self.other_herosData[_index].chipPercent = _chipPercent
        if _chipPercent >= 100 then
            self.canRecruit_herosData[#self.canRecruit_herosData + 1] = clone(self.other_herosData[_index])
            table.remove(self.other_herosData, _index)
        end
    end
end
-- 获取所有拥有的英雄数据
function YingXiongLayer:getMyHeroData()
    -- 构建数据
    -- 获取所有已拥有英雄的数据
    local _temp_data = HeroDataInit:InitHeroDataAllOwnHero()
    -- 获取当前所有已经装备上的信息
    local _equipmentData = { }
    for k, v in pairs(self.dynamicEquipmentData) do
        if not _equipmentData[tostring(v.heroid)] or next(_equipmentData[tostring(v.heroid)]) == nil then
            _equipmentData[tostring(v.heroid)] = { }
        end
        _equipmentData[tostring(v.heroid)][#_equipmentData[tostring(v.heroid)] + 1] = clone(v)
    end
    -- 组合成英雄数据
    self.m_herosData = { }
    for k, v in pairs(_temp_data) do
        v.equipments = { }
        v.equipments = _equipmentData[tostring(k)] or { }
        self.m_herosData[#self.m_herosData + 1] = v
    end
end
-- 获取所有未拥有英雄
function YingXiongLayer:getOtherHeroData()
    self.other_herosData = gameData.getDataFromCSV("GeneralInfoList")
    local _allHeroData = { }
    _allHeroData = clone(self.other_herosData)
    local _myheroData = { }
    for j = 1, #self.m_herosData do
        _myheroData[tostring(self.m_herosData[j]["heroid"])] = self.m_herosData[j]
    end
    local _count = 0
    for i = #_allHeroData, 1, -1 do
        if _myheroData[tostring(_allHeroData[i]["heroid"])] ~= nil or tonumber(_allHeroData[i]["unlock"]) == 0 then
            table.remove(self.other_herosData, i)
            -- _count = _count + 1
        end
    end
end
-- 给self.m_herosData排序，level-》curexp-》heroid
function YingXiongLayer:SortForMyHeroData()
    if #self.m_herosData > 1 then
        table.sort(self.m_herosData, function(data1, data2)
            if data1["level"] ~= data2["level"] then
                return tonumber(data1["level"]) > tonumber(data2["level"])
            elseif tonumber(data1.rank) ~= tonumber(data2.rank) then
                return tonumber(data1.rank) > tonumber(data2.rank)
                -- elseif data1["curexp"]~=data2["curexp"] then
                -- 	return tonumber(data1["curexp"]) > tonumber(data2["curexp"])
            else
                return tonumber(data1["heroid"]) < tonumber(data2["heroid"])
            end
        end )
    end
end
function YingXiongLayer:SortForCanRecruitHeroData()
    if #self.canRecruit_herosData > 1 then
        table.sort(self.canRecruit_herosData, function(data1, data2)
            return tonumber(data1["heroid"]) < tonumber(data2["heroid"])
        end )
    end
end
-- 给self.other_herosData排序，chipCount-》heroid
function YingXiongLayer:SortForOtherHeroData()
    if #self.other_herosData > 1 then
        table.sort(self.other_herosData, function(data1, data2)
            if tonumber(data1.chipPercent) == 0 and tonumber(data2.chipPercent) == 0 then
                return tonumber(data1["heroid"]) < tonumber(data2["heroid"])
            elseif tonumber(data1.rank) ~= tonumber(data2.rank) then
                return tonumber(data1.rank) > tonumber(data2.rank)
            else
                return tonumber(data1.chipPercent) > tonumber(data2.chipPercent)
            end
            return _dataNumber1 < _dataNumber2
        end )
    end
end
-- 设置self.m_herosArr的type和idx
function YingXiongLayer:setMyHeroArray()
    for i = 1, #self.m_herosData do
        self.m_herosArr[i] = { }
        self.m_herosArr[i]._type = 1
        -- 全部
        self.m_herosArr[i]._idx = i
        -- 初始排序
        if tonumber(self.m_herosData[i].attackrange) < IntervalBeforeAndMiddle and tonumber(self.m_herosData[i].attackrange) > 0 then
            self.m_herosArr[i]._type = 2
            -- 前排
        elseif tonumber(self.m_herosData[i].attackrange) > IntervalMiddleAndAfter then
            self.m_herosArr[i]._type = 4
            -- 后排
        else
            self.m_herosArr[i]._type = 3
            -- 中排
        end
    end
end
-- 设置self.canRecruit_herosArr的type和idx
function YingXiongLayer:setCanRecruitHeroArray()
    for i = 1, #self.canRecruit_herosData do
        self.canRecruit_herosArr[i] = { }
        self.canRecruit_herosArr[i]._type = 1
        -- 全部
        self.canRecruit_herosArr[i]._idx = i
        -- 初始排序
        self.canRecruit_herosArr[i]._isCanRecruit = 1
        if tonumber(self.canRecruit_herosData[i].attackrange) < IntervalBeforeAndMiddle and tonumber(self.canRecruit_herosData[i].attackrange) > 0 then
            self.canRecruit_herosArr[i]._type = 2
            -- 前排
        elseif tonumber(self.canRecruit_herosData[i].attackrange) > IntervalMiddleAndAfter then
            self.canRecruit_herosArr[i]._type = 4
            -- 后排
        else
            self.canRecruit_herosArr[i]._type = 3
            -- 中排
        end
    end
end
-- 设置self.other_herosArr的type和idx
function YingXiongLayer:setOtherHeroArray()
    for i = 1, #self.other_herosData do
        self.other_herosArr[i] = { }
        self.other_herosArr[i]._type = 1
        -- 全部
        self.other_herosArr[i]._idx = i
        if tonumber(self.other_herosData[i].attackrange) < IntervalBeforeAndMiddle and tonumber(self.other_herosData[i].attackrange) > 0 then
            self.other_herosArr[i]._type = 2
            -- 前排
        elseif tonumber(self.other_herosData[i].attackrange) > IntervalMiddleAndAfter then
            self.other_herosArr[i]._type = 4
            -- 后排
        else
            self.other_herosArr[i]._type = 3
            -- 中排
        end
    end
end
-- 获取升星碎片需要数量
function YingXiongLayer:setStarUpChip()
    -- 都一样的
    local data = gameData.getDataFromCSV("GeneralGrowthNeeds") or { }
    self.starupchipData = { }
    for k, v in pairs(data) do
        self.starupchipData[v.id] = v
    end
    -- self.starupchipData = self.starupchipData and self.starupchipData or {}
    -- for i=1,#self.starupchipData do
    -- 	for j=1,5 do
    -- 		local _chipNumber = self.starupchipData[i]["starcount" .. (j-1)] or 0
    -- 		_chipNumber = _chipNumber + self.starupchipData[i]["starcount" .. j]
    -- 		self.starupchipData[i]["starcount" .. j] = _chipNumber
    -- 	end
    -- end

end
-------------------关于数据ended------------------


-- 文字颜色
function YingXiongLayer:getHeroListTextColor(_str)
    local _textColor = {
        shenhese = cc.c4b(70,34,34,255)
    }
    return _textColor[_str]
end

function YingXiongLayer:create()
    local layer = self.new();
    layer:init()
    return layer;
end

function YingXiongLayer:addGuide()
    local target = nil
    --    local close = self:getChildByName("TopBarLayer1"):getChildByName("topBarBackBtn")
    local _guideGroup, _guideIndex = YinDaoMarg:getInstance():getGuideSteps()
    if self.m_herosArr[1] then
        ----第5组引导
        YinDaoMarg:getInstance():addGuide( {
            ----点击熊猫
            parent = self,
            target = self.m_herosArr[1].cell,
            -----第一个英雄
            index = 3,
            needNext = false,
        } , {
            { 2, 4 },
            { 5, 3 },
            { 7, 3 },
        } )
    end
    if _guideGroup == 13 and _guideIndex == 3 then
        target = self:getHeroObjAndScrollToCellByHeroid(1)
        --- 选择熊猫
        if target then
            YinDaoMarg:getInstance():addGuide( {
                parent = self,
                target = target,
                index = 3,
                needNext = false,
            } , 13)
        else
            print("=============================at the guide hero layer ,no hero id 1")
        end
    end
    -- elseif gameUser.getInstancingId() == 15 then  -----第11组引导
    -- 	if _guideGroup == 11 and _guideIndex == 3 then
    -- 		target = self:getHeroObjAndScrollToCellByHeroid(1) ---选择熊猫
    -- 		if target then
    -- 	        YinDaoMarg:getInstance():addGuide({
    -- 	            parent = self,
    -- 	            target = target,
    -- 	            index = 4,
    -- 	            needNext = false,
    -- 	        },11)
    -- 	    else
    -- 	    	YinDaoMarg:getInstance():overCurrentGuide(true,11)		    	
    -- 	    end
    --     end
    -- elseif gameUser.getInstancingId() == 21 then  -----第13组引导
    -- 	if _guideGroup == 13 and _guideIndex == 3 then
    -- 		target = self:getHeroObjAndScrollToCellByHeroid(22) ---选择穿山甲
    -- 		if target then
    -- 	        YinDaoMarg:getInstance():addGuide({
    -- 	            parent = self,
    -- 	            target = target,
    -- 	            index = 4,
    -- 	            needNext = false,
    -- 	        },13)
    -- 	    else
    -- 	    	YinDaoMarg:getInstance():overCurrentGuide(true,13)		    	
    -- 	    end
    --     end
    --    elseif gameUser.getInstancingId() == 48 then ---第22组引导
    -- 	if _guideGroup == 21 and _guideIndex == 3 then
    -- 		target = self:getHeroObjAndScrollToCellByHeroid(1) ---选择熊猫
    -- 		if target then
    -- 	        YinDaoMarg:getInstance():addGuide({
    -- 	            parent = self,
    -- 	            target = target,
    -- 	            index = 4,
    -- 	            needNext = false,
    -- 	        },21)
    --       	else
    -- 	    	YinDaoMarg:getInstance():overCurrentGuide(true,21)
    -- 	    end
    --     end
    -- elseif gameUser.getInstancingId() == 24 then  -----15
    -- 	if _guideGroup == 15 and _guideIndex == 3 then
    -- 		target = self:getHeroObjAndScrollToCellByHeroid(1) ---选择熊猫
    -- 		if target then
    -- 	        YinDaoMarg:getInstance():addGuide({
    -- 	            parent = self,
    -- 	            target = target,
    -- 	            index = 4,
    -- 	            needNext = false,
    -- 	        },15)
    --       	else
    -- 	    	YinDaoMarg:getInstance():overCurrentGuide(true,15)
    -- 	    end
    --     end
    -- end
    YinDaoMarg:getInstance():doNextGuide()
end

return YingXiongLayer;