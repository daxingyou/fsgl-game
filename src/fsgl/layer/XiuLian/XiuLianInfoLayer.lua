--[[
    宝典信息界面
    唐实聪
    2015.12.28
]]
local XiuLianInfoLayer = class("XiuLianInfoLayer", function()
    return XTHD.createBasePageLayer()
end )

function XiuLianInfoLayer:ctor(data)
    self._exist = true
    self:initData(data)
    self:ownData()
    self:initUI(data.bibleId)
    XTHD.addEventListener( {
        name = CUSTOM_EVENT.REFRESH_BIBLE,
        callback = function()
            if self._exist then
                -- 刷新已拥有的英雄和装备数据
                self:ownData()
                -- 刷新当前界面数据
                self:refreshData(self._objectData[self._typeId][self._selectedIndex].needID)
            end
        end,
    } )
    XTHD.addEventListener( {
        name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK,
        callback = function()
            if self._exist then
                -- 刷新已拥有的英雄和装备数据
                self:ownData()
                -- 刷新当前界面数据
                self:refreshData(self._objectData[self._typeId][self._selectedIndex].needID)
            end
        end,
    } )

end
-- 调用回调函数，传入bibleid
function XiuLianInfoLayer:onCleanup()
    self._exist = false
    if self._callFunc then
        self._callFunc(self._bibleId)
    end
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_BIBLE)
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK)
end
-- 初始化全局的数据
function XiuLianInfoLayer:initData(data)
    self._addProperty = data.addProperty
    -- 配置表，保存宝典的激活升级数据
    self._configList = { }
    for i, v in ipairs(data.configList) do
        self._configList[tostring(v.configId)] = v.level
    end
    self._bibleId = data.bibleId or 1
    self._typeId = data.typeId or 1

    -- 宝典数据，添加rank
    local bibleList = gameData.getDataFromCSV("Cultivation")
    -- 英雄rank信息
    local heroRankList = gameData.getDataFromCSV("GeneralInfoList")
    local heroRankData = { }
    for i, v in ipairs(heroRankList) do
        heroRankData[tostring(v.heroid)] = v.rank
    end
    -- 装备rank信息
    local equipRankList = gameData.getDataFromCSV("ArticleInfoSheet")
    local equipRankData = { }
    for i, v in ipairs(equipRankList) do
        equipRankData[tostring(v.itemid)] = v.rank
    end
    -- 添加rank到宝典信息
    self._bibleList = { }
    for i, v in ipairs(bibleList) do
        if v.show == 1 then
            if v.pos == 1 then
                v.rank = tonumber(heroRankData[tostring(v.needID)] or 1)
            else
                v.rank = tonumber(equipRankData[tostring(v.needID)] or 1)
            end
            self._bibleList[v.addtype] = self._bibleList[v.addtype] or { }
            self._bibleList[v.addtype][v.pos] = self._bibleList[v.addtype][v.pos] or { }
            self._bibleList[v.addtype][v.pos][#self._bibleList[v.addtype][v.pos] + 1] = v
        end
    end

    self._objectData = { { }, { } }
    self._callFunc = data.callFunc
end
-- 获取玩家拥有的英雄数据
function XiuLianInfoLayer:ownData()

    -- 保存已有的数据
    self._ownObjectData = { }
    -- 保存已有的英雄数据
    self._ownObjectData[1] = { }
    local ownHeroList = DBTableHero.getData(gameUser.getUserId())
    if table.nums(ownHeroList) > 0 and not ownHeroList[1] then
        ownHeroList = { ownHeroList }
    end
    for i, v in ipairs(ownHeroList) do
        self._ownObjectData[1][tostring(v.heroid)] = true
    end
    -- dump( self._ownObjectData[1], "self._ownObjectData[1]")
    -- 保存已有的装备数据
    self._ownObjectData[2] = { }
    local ownItemList = DBTableItem.getData(gameUser.getUserId(), { item_type = 3 })
    if table.nums(ownItemList) > 0 and not ownItemList[1] then
        ownItemList = { ownItemList }
    end
    for i, v in ipairs(ownItemList) do
        self._ownObjectData[2][tostring(v.itemid)] = true
    end
    local ownEquipList = DBTableEquipment.getData(gameUser.getUserId())
    if table.nums(ownEquipList) > 0 and not ownEquipList[1] then
        ownEquipList = { ownEquipList }
    end
    for i, v in ipairs(ownEquipList) do
        self._ownObjectData[2][tostring(v.itemid)] = true
    end
    -- dump( self._ownObjectData[2], "self._ownObjectData[2]")
end
-- 筛选当前type的数据，计算材料
function XiuLianInfoLayer:buildData(objectId)
    -- 从静态表中筛选本界面的数据
    self._objectData = clone(self._bibleList[self._bibleId] or { })
    for i, v in ipairs(self._objectData) do
        for j, u in ipairs(v) do
            u.level = self._configList[tostring(u.id)] or 0
            -- 计算所需材料
            u.iconData = self:calculate(u)
        end
    end
    -- dump( self._objectData, "self._objectData" )

    self:judgeEnough(objectId)
end
-- 计算每个对象激活升级所需材料
function XiuLianInfoLayer:calculate(data)
    -- 前缀
    local prefix = ""
    -- 倍数
    local times = 0
    if data.level == 0 then
        -- 未激活
        prefix = "unlockcost"
        times = 0
    elseif data.level < data.maxlevel then
        -- 已激活
        prefix = "upcost"
        times = data.level
    else
        -- 已满级
        return { }
    end
    local k = 1
    local iconData = { }
    while data[prefix .. k] and type(data[prefix .. k]) == "string" do
        local tmpData = string.split(data[prefix .. k], "#")
        if tonumber(tmpData[1]) ~= 0 then
            -- 数量
            local count = tonumber(tmpData[3])
            if times ~= 0 and tmpData[4] then
                count = count + times * tonumber(tmpData[4])
            end
            iconData[#iconData + 1] = {
                _type_ = tonumber(tmpData[1]),
                itemId = tonumber(tmpData[2]),
                count = count,
            }
        end
        k = k + 1
    end

    return iconData
end
-- 判断材料是否足够，排序
function XiuLianInfoLayer:judgeEnough(objectId)
    -- 判断当前宝典每个对象是否可以激活或者升级
    local myIngot = gameUser.getIngot()
    local myGold = gameUser.getGold()
    local myFeicui = gameUser.getFeicui()
    local mySmeltPoint = gameUser.getSmeltPoint()
    local myBpgx = gameUser.getGuildPoint()
    for i, v in ipairs(self._objectData) do
        for j, u in ipairs(v) do
            -- dump( u )
            local enoughFlag = true
            if u.level == 0 then
                enoughFlag = self._ownObjectData[i][tostring(u.needID)] or false
            elseif u.level == u.maxlevel then
                enoughFlag = false
            end
            for k, w in ipairs(u.iconData) do
                if not enoughFlag then
                    break
                end
                if w._type_ == XTHD.resource.type.ingot then
                    -- 元宝
                    enoughFlag = myIngot >= w.count and true or false
                elseif w._type_ == XTHD.resource.type.gold then
                    -- 银两
                    enoughFlag = myGold >= w.count and true or false
                elseif w._type_ == XTHD.resource.type.feicui then
                    -- 翡翠
                    enoughFlag = myFeicui >= w.count and true or false
                elseif w._type_ == XTHD.resource.type.item then
                    -- 道具
                    local ownData = DBTableItem.getData(gameUser.getUserId(), { itemid = w.itemId })
                    local ownNum = 0
                    if #ownData ~= 0 and type(ownData[1]) == "table" then
                        for i = 1, #ownData do
                            ownNum = ownNum + ownData[i].count
                        end
                    else
                        ownNum = ownData.count or 0
                    end
                    enoughFlag = ownNum >= w.count and true or false
                elseif w._type_ == XTHD.resource.type.smeltPoint then
                    -- 回收点
                    enoughFlag = mySmeltPoint >= w.count and true or false
                elseif w._type_ == XTHD.resource.type.guild_contri then
                    --帮派贡献
                    enoughFlag = myBpgx >= w.count and true or false
                end
            end
            self._objectData[i][j].enoughFlag = enoughFlag
        end
    end
    -- dump( self._objectData[self._typeId], "self._objectData[self._typeId]" )

    -- 排序
    for i, v in ipairs(self._objectData) do
        local tmpTable = { }
        -- 升级
        tmpTable[1] = { }
        -- 激活
        tmpTable[2] = { }
        for j, u in ipairs(v) do
            if u.level == 0 then
                tmpTable[2][#tmpTable[2] + 1] = u
            else
                tmpTable[1][#tmpTable[1] + 1] = u
            end
        end
        if i ~= 1 then
            -- 装备
            for j, u in ipairs(tmpTable) do
                table.sort(tmpTable[j], function(a, b)
                    if not(a.enoughFlag and b.enoughFlag) and(a.enoughFlag or b.enoughFlag) then
                        return a.enoughFlag
                    elseif a.rank == b.rank then
                        return a.id < b.id
                    else
                        return a.rank > b.rank
                    end
                end )
            end
        else
            -- 英雄
            for j, u in ipairs(tmpTable) do
                table.sort(tmpTable[j], function(a, b)
                    if not(a.enoughFlag and b.enoughFlag) and(a.enoughFlag or b.enoughFlag) then
                        return a.enoughFlag
                    elseif a.rank == b.rank then
                        return a.id < b.id
                    else
                        return a.rank > b.rank
                    end
                end )
            end
        end
        objTable = { }
        for j, u in ipairs(tmpTable) do
            for k, w in ipairs(u) do
                objTable[#objTable + 1] = w
            end
        end
        self._objectData[i] = objTable
    end

    self:selectObject(objectId)
end
-- 查找原来选中的对象
function XiuLianInfoLayer:selectObject(objectId)
    -- 查找原来选中的对象
    self._selectedIndex = 1
    self._selectedCell = nil
    if objectId and objectId ~= 0 then
        for i, v in ipairs(self._objectData[self._typeId]) do
            if objectId == v.needID then
                self._selectedIndex = i
                break
            end
        end
    end
end
-- 初始化界面
function XiuLianInfoLayer:initUI(bibleId)
    -- local bg = XTHDLabel:create(gameUser.getGuildPoint(),13,"res/fonts/def.ttf")
    -- self:addChild(bg,10)
    -- bg:setPosition(self:getContentSize().width/2,self:getContentSize().height - 100)
    self._size = self:getContentSize()
    local background = XTHD.createSprite("res/image/plugin/bible_layer/background2.png")
    background:setAnchorPoint(cc.p(0.5, 0.5))
    background:setPosition(self._size.width * 0.5,(self._size.height - self.topBarHeight) * 0.5)
    self:addChild(background)
    background:setContentSize(cc.Director:getInstance():getWinSize())
    self._bg = background

    self._leftSize = cc.size(background:getContentSize().width - 490, 477)
    self._rightSize = cc.size(490, 477)

    self:initRight()
    self:initLeft(bibleId)

    self._animationBg = XTHDDialog:create()
    self._animationBg:setSwallowTouches(true)
    self._animationBg:setContentSize(self._size)
    self._animationBg:setOpacity(127.5)
    self._animationBg:setPosition(0, 0)
    self._animationBg:setVisible(false)
    self:addChild(self._animationBg)

    self._animationNum = 0
end
-- 初始化左边
function XiuLianInfoLayer:initLeft(bibleId)
    -- 容器
    local offsetX = GetScreenOffsetX()*2
    local leftContainer = XTHD.createSprite()
    leftContainer:setContentSize(self._leftSize)
    leftContainer:setAnchorPoint(cc.p(0, 0.5))
    leftContainer:setPosition(0 - offsetX,(self._size.height - self.topBarHeight) * 0.5)
    self._bg:addChild(leftContainer)
    self._leftContainer = leftContainer

    -- 宝典
    -- tableview
    local bibleCellWidth = 380 * 0.8
    local bibleCellHeight = 383 * 0.8
    local biblePager = ccui.PageView:create()
    PageViewPlug.init(biblePager)
    biblePager:setContentSize(bibleCellWidth, bibleCellHeight)
    biblePager:setPosition(self._leftSize.width * 0.5 - bibleCellWidth / 2, self._leftSize.height - 145 - bibleCellHeight / 2)
    biblePager:setSaveCache(true)
    self._leftContainer:addChild(biblePager)
    self._biblePager = biblePager

    local help_btn = XTHDPushButton:createWithParams( {
        normalFile = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create( { type = 25 });
            self:addChild(StoredValue)
        end,
    } )
    self._leftContainer:addChild(help_btn)
    help_btn:setAnchorPoint(0,0.5)
    help_btn:setPosition(44 + offsetX, self._leftContainer:getContentSize().height - help_btn:getContentSize().height / 2 + 30)

    biblePager:onLoadListener( function(page, index)
        -- 背景
        local bibleSpriteBg = XTHD.createSprite("res/image/plugin/bible_layer/bibleBg.png")
        bibleSpriteBg:setPosition(bibleCellWidth * 0.5, bibleCellHeight * 0.5)
        page:addChild(bibleSpriteBg)
        bibleSpriteBg:setScale(0.7)
        -- 宝典图
        local bibleSprite = XTHD.createSprite("res/image/plugin/bible_layer/bible_" .. index .. ".png")
        bibleSprite:setPosition(bibleCellWidth * 0.5, bibleCellHeight * 0.5 + 10)
        page:addChild(bibleSprite)
        bibleSprite:setScale(0.7)
    end )

    biblePager:onSelectedListener( function(page, index)
        self._bibleId = index
        self:refreshBible(index)
    end )

    -- 宝典名字背景
    local bibleNameBg = XTHD.createSprite("res/image/plugin/bible_layer/nameBg.png")
    bibleNameBg:setPosition(self._leftSize.width * 0.5, biblePager:getPositionY() + bibleCellHeight / 2 - 135)
    leftContainer:addChild(bibleNameBg)
    bibleNameBg:setScale(0.8)
    -- 宝典名字
    local bibleName = XTHD.createLabel( {
        fontSize = 26,
        color = cc.c3b(255,255,255),
        ttf = "res/fonts/def.ttf"
    } )
    -- bibleName:enableShadow(cc.c3b(255,255,255),cc.size(0.4,-0.4),2)
    bibleName:enableOutline(cc.c3b(70,42,25), 2)
    getCompositeNodeWithNode(bibleNameBg, bibleName)
    self._bibleName = bibleName

    -- 左右按钮
    -- 左
    local leftArrow = XTHD.createButton( {
        normalFile = "res/image/plugin/bible_layer/leftArrow_up.png",
        selectedFile = "res/image/plugin/bible_layer/leftArrow_down.png",
        pos = cc.p(self._leftSize.width * 0.5 - 170,biblePager:getPositionY() + bibleCellHeight / 2),
        touchSize = cc.size(100,200),
        endCallback = function()
            self._bibleId = self._bibleId - 1
            self._biblePager:scrollToLast()
        end
    } )
    leftContainer:addChild(leftArrow)
    leftArrow:runAction(
    cc.RepeatForever:create(
    cc.Sequence:create(
    cc.EaseInOut:create(
    cc.MoveBy:create(
    1, cc.p(-15, 0)
    ), 1.5
    ),
    cc.EaseInOut:create(
    cc.MoveBy:create(
    1, cc.p(15, 0)
    ), 1.5
    )
    )
    )
    )
    -- 右
    local rightArrow = XTHD.createButton( {
        normalFile = "res/image/plugin/bible_layer/rightArrow_up.png",
        selectedFile = "res/image/plugin/bible_layer/rightArrow_down.png",
        pos = cc.p(self._leftSize.width * 0.5 + 165,biblePager:getPositionY() + bibleCellHeight / 2),
        touchSize = cc.size(100,200),
        endCallback = function()
            self._biblePager:scrollToNext()
            self._bibleId = self._bibleId + 1
        end
    } )
    leftContainer:addChild(rightArrow)
    rightArrow:runAction(
    cc.RepeatForever:create(
    cc.Sequence:create(
    cc.EaseInOut:create(
    cc.MoveBy:create(
    1, cc.p(15, 0)
    ), 1.5
    ),
    cc.EaseInOut:create(
    cc.MoveBy:create(
    1, cc.p(-15, 0)
    ), 1.5
    )
    )
    )
    )

    -- 属性总加成对所有英雄有效
    local tipUp = XTHD.createLabel( {
        text = LANGUAGE_BIBLE_TEXT[22],
        fontSize = 20,
        color = cc.c3b(81,50,30),
        pos = cc.p(self._leftSize.width * 0.5,bibleNameBg:getPositionY() -45),
        ttf = "res/fonts/def.ttf"
    } )
    tipUp:enableShadow(cc.c4b(81, 50, 30, 255), cc.size(1, 0))
    leftContainer:addChild(tipUp)

    -- 总加成
    -- 背景
    local totalAdditionBg = ccui.Scale9Sprite:create("res/image/plugin/bible_layer/hb.png")
    totalAdditionBg:setContentSize(self._leftSize.width/2, 45)
    totalAdditionBg:setPosition(self._leftSize.width * 0.5, tipUp:getPositionY() -45)
    leftContainer:addChild(totalAdditionBg)
    -- -- 云
    -- local topCloud = XTHD.createSprite( "res/image/illustration/cloud.png" )
    -- topCloud:setFlippedX( true )
    -- topCloud:setFlippedY( true )
    -- topCloud:setAnchorPoint( cc.p( 0, 1 ) )
    -- topCloud:setPosition( 5, totalAdditionBg:getContentSize().height - 5 )
    -- totalAdditionBg:addChild( topCloud )
    -- local bottomCloud = XTHD.createSprite( "res/image/illustration/cloud.png" )
    -- bottomCloud:setAnchorPoint( cc.p( 1, 0 ) )
    -- bottomCloud:setPosition( totalAdditionBg:getContentSize().width - 5, 5 )
    -- totalAdditionBg:addChild( bottomCloud )
    -- -- 光
    -- local topLight = XTHD.createSprite( "res/image/plugin/bible_layer/lightUp.png" )
    -- topLight:setAnchorPoint( cc.p( 0, 1 ) )
    -- topLight:setPosition( 0, totalAdditionBg:getContentSize().height + 9 )
    -- totalAdditionBg:addChild( topLight )
    -- local bottomLight = XTHD.createSprite( "res/image/plugin/bible_layer/lightDown.png" )
    -- bottomLight:setAnchorPoint( cc.p( 1, 0 ) )
    -- bottomLight:setPosition( totalAdditionBg:getContentSize().width, -6 )
    -- totalAdditionBg:addChild( bottomLight )
    -- 加成
    -- 文字
    local totalAdditionText = XTHD.createLabel( {
        fontSize = 22,
        color = cc.c3b(0,0,0),
        anchor = cc.p(1,0.5),
        pos = cc.p(totalAdditionBg:getContentSize().width * 0.5 + 20,totalAdditionBg:getContentSize().height * 0.5),
        ttf = "res/fonts/def.ttf"
    } )
    totalAdditionBg:addChild(totalAdditionText)
    self._totalAdditionText = totalAdditionText

    --"+"符号
    local lable =  XTHD.createLabel( {
        fontSize = 24,
        color = cc.c3b(253,192,35),
        anchor = cc.p(0,0.5),
        pos = cc.p(totalAdditionBg:getContentSize().width * 0.5 + 30,totalAdditionBg:getContentSize().height * 0.5 + 2),
        ttf = "res/fonts/def.ttf"
    } )
    totalAdditionBg:addChild(lable)
    self._fhLable = lable
    -- 数字
    local totalAdditionNum = XTHD.createLabel( {
        fontSize = 24,
        color = cc.c3b(253,192,35),
        anchor = cc.p(0,0.5),
        pos = cc.p(totalAdditionBg:getContentSize().width * 0.5 + 50,totalAdditionBg:getContentSize().height * 0.5),
        ttf = "res/fonts/def.ttf"
    } )
    totalAdditionBg:addChild(totalAdditionNum)
    self._totalAdditionNum = totalAdditionNum

    -- 可激活全部已拥有英雄，获得属性加成
    local tipDown = XTHD.createLabel( {
        fontSize = 16,
        color = XTHD.resource.color.gray_desc,
        pos = cc.p(self._leftSize.width * 0.5,totalAdditionBg:getPositionY() -37)
    } )
    leftContainer:addChild(tipDown)
    self._tipDown = tipDown

    -- 全部激活
    local activateAllBtn_disable = ccui.Scale9Sprite:create("res/image/common/btn/btn_blue_disable.png")
    activateAllBtn_disable:setContentSize(cc.size(145, 45))
    local activateAllBtn = XTHD.createButton({
        normalFile = "res/image/common/btn/qbsj.png",
        selectedFile = "res/image/common/btn/qbsj2.png",
        btnSize = cc.size( 145, 45 ),
        disableNode = activateAllBtn_disable,
    })
    activateAllBtn:setScale(0.8)
    activateAllBtn:setPosition(self._leftSize.width * 0.5, 25)
    leftContainer:addChild(activateAllBtn)
    -- activateAllBtn:setScale(0.8)
    self._activateAllBtn = activateAllBtn


    -- 按钮上的特效
    local activateAllBtnSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)
    activateAllBtn:addChild(activateAllBtnSpine)
    -- activateAllBtnSpine:setScaleX( activateAllBtnSpine:getContentSize().width/activateAllBtn:getContentSize().width )
    -- activateAllBtnSpine:setScaleY( activateAllBtnSpine:getContentSize().height/activateAllBtn:getContentSize().height )
    activateAllBtnSpine:setScale(0.9)
    activateAllBtnSpine:setPosition(activateAllBtn:getBoundingBox().width * 0.5 + 15, activateAllBtn:getContentSize().height / 2 + 3)
    activateAllBtnSpine:setAnimation(0, "querenjinjie", true)

    -- 没有可以激活或升级的宝典
    local noActivateBibleLabel = XTHD.createLabel( {
        text = LANGUAGE_BIBLE_TEXT[15],
        fontSize = 22,
        color = cc.c3b(0,0,0),
        pos = cc.p(self._leftSize.width * 0.5,(totalAdditionBg:getPositionY() - totalAdditionBg:getContentSize().height * 0.5) * 0.5),
        ttf = "res/fonts/def.ttf"
    } )
    leftContainer:addChild(noActivateBibleLabel)
    self._noActivateBibleLabel = noActivateBibleLabel
    biblePager:reloadData(bibleId or 1, 5)
end
-- 初始化右边
function XiuLianInfoLayer:initRight()
    -- 容器
    local offsetX = GetScreenOffsetX()*1.5
    local rightContainer = XTHD.createSprite()
    rightContainer:setContentSize(self._rightSize)
    rightContainer:setAnchorPoint(cc.p(1, 0.5))
    rightContainer:setPosition(self._size.width-(32 + offsetX),(self._size.height - self.topBarHeight) * 0.5)
    self._bg:addChild(rightContainer)
    self._rightContainer = rightContainer

    -- 过渡
    -- local splitSprite = ccui.Scale9Sprite:create("res/image/ranklistreward/splitY.png" )
    -- splitSprite:setContentSize(2,self._rightSize.height-10)
    -- splitSprite:setAnchorPoint( cc.p( 0, 0.5 ) )
    -- splitSprite:setPosition( -10, rightContainer:getContentSize().height*0.5 )
    -- splitSprite:setFlippedX( true )
    -- rightContainer:addChild( splitSprite )

    -- 顶部
    -- 英雄
    local heroBtn = XTHD.createButton( {
        normalNode = XTHD.getScaleNode("res/image/plugin/bible_layer/btn_tabTop_up.png",cc.size(200,45)),
        selectedNode = XTHD.getScaleNode("res/image/plugin/bible_layer/btn_tabTop_down.png",cc.size(200,45)),
        anchor = cc.p(0,0.5),
        pos = cc.p(50,self._rightSize.height - 25),
        endCallback = function()
            if self._typeId == 2 then
                self._typeId = 1
                self._heroBtn:setSelected(true)
                self._equipBtn:setSelected(false)
                self._selectedIndex = 1
                self._selectedCell = nil
                self._tableView:reloadData()
                self:refreshRight()
            end
        end
    } )
    local heroBtn_Label = XTHD.createLabel( {
        text = LANGUAGE_BIBLE_TEXT[17],
        fontSize = 20,
        color = cc.c3b(255,255,255),
        ttf = "res/fonts/def.ttf"
    } )
    heroBtn_Label:enableShadow(cc.c4b(255, 255, 255, 255), cc.size(1, 0), 2)
    heroBtn_Label:enableOutline(cc.c3b(70,42,25), 2)
    getCompositeNodeWithNode(heroBtn, heroBtn_Label)
    rightContainer:addChild(heroBtn)
    self._heroBtn = heroBtn
    -- 装备
    local equipBtn = XTHD.createButton( {
        normalNode = XTHD.getScaleNode("res/image/plugin/bible_layer/btn_tabTop_up.png",cc.size(200,45)),
        selectedNode = XTHD.getScaleNode("res/image/plugin/bible_layer/btn_tabTop_down.png",cc.size(200,45)),
        anchor = cc.p(0,0.5),
        pos = cc.p(self._heroBtn:getContentSize().width + 60,self._rightSize.height - 25),
        endCallback = function()
            if self._typeId == 1 then
                self._typeId = 2
                self._heroBtn:setSelected(false)
                self._equipBtn:setSelected(true)
                self._selectedIndex = 1
                self._selectedCell = nil
                self._tableView:reloadData()
                self:refreshRight()
            end
        end
    } )
    local equipBtn_Label = XTHD.createLabel( {
        text = LANGUAGE_BIBLE_TEXT[18],
        fontSize = 20,
        color = cc.c3b(255,255,255),
        ttf = "res/fonts/def.ttf"
    } )
    equipBtn_Label:enableShadow(cc.c4b(255, 255, 255, 255), cc.size(1, 0), 2)
    equipBtn_Label:enableOutline(cc.c3b(70,42,25), 2)
    getCompositeNodeWithNode(equipBtn, equipBtn_Label)
    rightContainer:addChild(equipBtn)
    self._equipBtn = equipBtn
    if self._typeId == 1 then
        heroBtn:setSelected(true)
        equipBtn:setSelected(false)
    else
        heroBtn:setSelected(false)
        equipBtn:setSelected(true)
    end

    -- 底部
    -- 背景
    local bottomBg = ccui.Scale9Sprite:create()
    bottomBg:setContentSize(self._rightSize.width - 40, 155)
    bottomBg:setAnchorPoint(cc.p(0.5, 0))
    bottomBg:setPosition(self._rightSize.width * 0.5 + 10, 5)
    rightContainer:addChild(bottomBg, 1)
    -- 吞噬层
    -- local swallow = XTHDPushButton:createWithParams({
    --     touchSize = bottomBg:getContentSize(),
    --     needSwallow = true,
    --     pos = cc.p( bottomBg:getContentSize().width*0.5, bottomBg:getContentSize().height*0.5 ),
    -- })
    -- bottomBg:addChild( swallow )
    -- 宝典名字
    local bibleName = XTHD.createLabel( {
        fontSize = 18,
        color = cc.c3b(55,54,112),
        anchor = cc.p(1,0.5),
        pos = cc.p(200,bottomBg:getContentSize().height - 16),
        ttf = "res/fonts/def.ttf"
    } )
    bottomBg:addChild(bibleName)
    self._rightBibleName = bibleName
    -- 英雄装备名字
    local objectName = XTHD.createLabel( {
        fontSize = 18,
        color = cc.c3b(55,54,112),
        anchor = cc.p(0,0.5),
        pos = cc.p(203,bottomBg:getContentSize().height - 16),
        ttf = "res/fonts/def.ttf"
    } )
    bottomBg:addChild(objectName)
    self._objectName = objectName
    -- 当前属性
    local currAttr = XTHD.createLabel( {
        fontSize = 18,
        color = cc.c3b(55,54,112),
        anchor = cc.p(0.5,0.5),
        pos = cc.p(125,bottomBg:getContentSize().height - 50),
        ttf = "res/fonts/def.ttf"
    } )
    bottomBg:addChild(currAttr)
    self._currAttr = currAttr
    -- 中间属性
    local midAttr = XTHD.createLabel( {
        fontSize = 18,
        color = cc.c3b(55,54,112),
        anchor = cc.p(0.5,0.5),
        pos = cc.p(225,bottomBg:getContentSize().height - 45),
        ttf = "res/fonts/def.ttf"
    } )
    bottomBg:addChild(midAttr)
    self._midAttr = midAttr
    -- 下级属性
    local nextAttr = XTHD.createRichLabel( {
        fontSize = 18,
        color = cc.c3b(55,54,112),
        anchor = cc.p(0.5,0.5),
        pos = cc.p(335,bottomBg:getContentSize().height - 50),
        ttf = "res/fonts/def.ttf"
    } )
    bottomBg:addChild(nextAttr)
    self._nextAttr = nextAttr
    -- 分隔
    -- local splitLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
    -- splitLine:setContentSize( bottomBg:getContentSize().width - 6, 2 )
    -- splitLine:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    -- splitLine:setPosition( bottomBg:getContentSize().width*0.5, 95 )
    -- bottomBg:addChild( splitLine )
    -- 尚未拥有该英雄，无法激活
    local noHeroLabel = XTHD.createLabel( {
        text = LANGUAGE_BIBLE_TEXT[21],
        fontSize = 18,
        color = cc.c3b(55,54,112),
        pos = cc.p(bottomBg:getContentSize().width * 0.5 - 70,47),
        ttf = "res/fonts/def.ttf"
    } )
    bottomBg:addChild(noHeroLabel)
    self._noHeroLabel = noHeroLabel
    -- 获取途径按钮
    local getHeroBtn = XTHD.createCommonButton( {
        btnColor = "write_1",
        btnSize = cc.size(100,45),
        isScrollView = false,
        text = LANGUAGE_BTN_KEY.getWay,
        fontSize = 20,
        anchor = cc.p(1,0.5),
        pos = cc.p(bottomBg:getContentSize().width - 15,47),
    } )
    bottomBg:addChild(getHeroBtn)
    self._getHeroBtn = getHeroBtn
    -- 获取该装备后可以激活
    local noEquipLabel = XTHD.createLabel( {
        text = LANGUAGE_BIBLE_TEXT[23],
        fontSize = 18,
        color = cc.c3b(55,54,112),
        pos = cc.p(bottomBg:getContentSize().width * 0.5,47),
        ttf = "res/fonts/def.ttf"
    } )
    bottomBg:addChild(noEquipLabel)
    self._noEquipLabel = noEquipLabel

    -- 已升级至满级
    local maxLevelLabel = XTHD.createLabel( {
        text = LANGUAGE_BIBLE_TEXT[19],
        fontSize = 22,
        color = cc.c3b(55,54,112),
        pos = cc.p(bottomBg:getContentSize().width * 0.5,47),
        ttf = "res/fonts/def.ttf"
    } )
    bottomBg:addChild(maxLevelLabel)
    self._maxLevelLabel = maxLevelLabel
    -- 消耗品
    local consumeIcons = XTHD.createSprite()
    consumeIcons:setContentSize(300, 95)
    consumeIcons:setAnchorPoint(cc.p(0, 0))
    consumeIcons:setPosition(cc.p(25, 0))
    bottomBg:addChild(consumeIcons)
    self._consumeIcons = consumeIcons
    -- 激活按钮
    local activateBtn = XTHD.createCommonButton( {
        btnColor = "write",
        btnSize = cc.size(100,45),
        isScrollView = false,
        fontSize = 26,
        anchor = cc.p(1,0.5),
        pos = cc.p(bottomBg:getContentSize().width - 15,47),
        ttf = "res/fonts/def.ttf"
    } )
    activateBtn:setScale(0.8)
    bottomBg:addChild(activateBtn)
    self._activateBtn = activateBtn

    -- tableviewBg
    local tableViewBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
    tableViewBg:setContentSize(rightContainer:getContentSize().width - 40, rightContainer:getContentSize().height - 210)
    tableViewBg:setAnchorPoint(cc.p(0.5, 0))
    tableViewBg:setPosition(rightContainer:getContentSize().width * 0.5 + 10, 162)
    rightContainer:addChild(tableViewBg)
    -- tableview
    self._tableView = CCTableView:create(cc.size(tableViewBg:getContentSize().width - 10, tableViewBg:getContentSize().height - 10))
    self._tableView:setPosition(5, 5)
    self._tableView:setBounceable(true)
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableViewBg:addChild(self._tableView)
    local cellWidth = tableViewBg:getContentSize().width - 10
    local cellHeight = 120
    local numPerLine = 4

    function numberOfCellsInTableView(tableView)
        return math.ceil(#(self._objectData[self._typeId]) / numPerLine)
    end

    function cellSizeForTable(tableView, index)
        return cellWidth, cellHeight
    end

    function tableCellAtIndex(tableView, index)
        local cell = tableView:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
        end

        cell._selected = { }
        local typeTable = {
            "hpadd","atadd","dfadd","matadd","mdfadd",
        }
        for i = 1, numPerLine do
            local data = self._objectData[self._typeId][numPerLine * index + i]
            -- dump( data, "data" )
            if not data then
                break
            end
            -- 图标
            local icon = nil
            if self._typeId == 1 then
                icon = HeroNode:createWithParams( {
                    heroid = data.needID,
                    level = - 1,
                    star = - 1,
                    advance = 1,
                } )
            else
                icon = ItemNode:createWithParams( {
                    itemId = data.needID,
                    needSwallow = false,
                    isShowDrop = false,
                    _type_ = 4,
                } )
            end
            icon:setPosition(cellWidth / numPerLine *(i - 0.5), cellHeight - 45)
            cell:addChild(icon)
            icon:setScale(80 / icon:getContentSize().width)
            if data.level and data.level > 0 then
                local addAttr = XTHD.createLabel( {
                    text = LANGUAGE_BIBLE_CURR(self._bibleId,data[typeTable[self._bibleId]] * data.level),
                    fontSize = 20,
                    color = cc.c3b(55,54,112),
                    pos = cc.p(icon:getPositionX(),icon:getPositionY() -55),
                } )
                cell:addChild(addAttr)
            elseif data.level and data.level == 0 then
                local addAttr = XTHD.createLabel( {
                    text = LANGUAGE_BIBLE_CURR(self._bibleId,data[typeTable[self._bibleId]]),
                    fontSize = 20,
                    color = cc.c3b(55,54,112),
                    pos = cc.p(icon:getPositionX(),icon:getPositionY() -55),
                    ttf = "res/fonts/def.ttf"
                } )
                cell:addChild(addAttr)
            end
            -- 阴影
            if data.level == 0 then
                local grayImage = XTHD.createSprite("res/image/plugin/bible_layer/mask.png")
                grayImage:setScale(icon:getContentSize().width / grayImage:getContentSize().width)
                getCompositeNodeWithNode(icon, grayImage)
            end
            -- 选中框
            local selected = ccui.Scale9Sprite:create("res/image/illustration/selected.png")
            -- selected:setContentSize( icon:getContentSize() )
            getCompositeNodeWithNode(icon, selected)
            cell._selected[i] = selected
            -- 箭头
            if data.enoughFlag then
                local arrowPath = ""
                if data.level == 0 then
                    arrowPath = "res/image/plugin/hero/item_canChangeItemSpr.png"
                else
                    arrowPath = "res/image/plugin/hero/hero_propertyadd.png"
                end
                local arrow = XTHD.createSprite(arrowPath)
                arrow:setPosition(73, 15)
                icon:addChild(arrow)
                arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.4, cc.p(0, 10)), cc.MoveBy:create(0.6, cc.p(0, -10)))))
            end

            if numPerLine * index + i == self._selectedIndex then
                selected:setVisible(true)
                self._selectedCell = cell
            else
                selected:setVisible(false)
            end

            icon:setTouchEndedCallback( function()
                if numPerLine * index + i ~= self._selectedIndex then
                    if self._selectedCell then
                        local selectedIndex =(self._selectedIndex - 1) % numPerLine + 1
                        if self._selectedCell._selected[selectedIndex] then
                            self._selectedCell._selected[selectedIndex]:setVisible(false)
                        end
                    end
                    selected:setVisible(true)
                    self._selectedIndex = numPerLine * index + i
                    self._selectedCell = cell
                    self:refreshRight()
                end
            end )
        end

        return cell

    end
    self._tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)

    self._tableView:reloadData()
end
-- 刷新左侧
function XiuLianInfoLayer:refreshLeft()
    local bibleNameTable = {
        {
            LANGUAGE_BIBLE_TEXT[1],
            LANGUAGE_BIBLE_TEXT[6],
        },
        {
            LANGUAGE_BIBLE_TEXT[2],
            LANGUAGE_BIBLE_TEXT[7],
        },
        {
            LANGUAGE_BIBLE_TEXT[3],
            LANGUAGE_BIBLE_TEXT[8],
        },
        {
            LANGUAGE_BIBLE_TEXT[4],
            LANGUAGE_BIBLE_TEXT[9],
        },
        {
            LANGUAGE_BIBLE_TEXT[5],
            LANGUAGE_BIBLE_TEXT[10],
        },
    }
    self._bibleName:setString(bibleNameTable[self._bibleId][1])
    self._rightBibleName:setString(bibleNameTable[self._bibleId][1] .. ":")
    self._totalAdditionText:setString(bibleNameTable[self._bibleId][2])
    self._fhLable:setString("+")
    self._totalAdditionNum:setString(self._addProperty[self._bibleId])

    -- 判断激活还是升级
    -- dump( self._objectData[self._typeId], "self._objectData[self._typeId]" )
    local activateFlag = false
    local levelupFlag = false
    for i, v in ipairs(self._objectData) do
        for j, u in ipairs(v) do
            if u.enoughFlag then
                if u.level == 0 then
                    activateFlag = true
                    break
                else
                    levelupFlag = true
                end
            end
        end
        if activateFlag then
            break
        end
    end
    -- 统计材料
    local consumeIngot = 0
    local consumeGold = 0
    local consumeFeicui = 0
    local consumeItem = { }
    local consumeSmeltPoint = 0
    local consumeBpgx = 0
    -- 拥有材料
    local myIngot = gameUser.getIngot()
    local myGold = gameUser.getGold()
    local myFeicui = gameUser.getFeicui()
    local mySmeltPoint = gameUser.getSmeltPoint()
    local myBpgx = gameUser.getGuildPoint()

    if activateFlag then
        -- 全部激活
        for i, v in ipairs(self._objectData) do
            for j, u in ipairs(v) do
                if u.enoughFlag and u.level == 0 then
                    -- dump( u, "j" )
                    -- 判断当前对象激活材料是否全部拥有，全部拥有的才加到总消耗里
                    local tmpIngot = 0
                    local tmpGold = 0
                    local tmpFeicui = 0
                    local tmpItem = { }
                    local tmpSmeltPoint = 0
                    local tmpBpgx = 0
                    for k, w in ipairs(u.iconData) do
                        if w._type_ == XTHD.resource.type.ingot then
                            -- 元宝
                            tmpIngot = w.count
                        elseif w._type_ == XTHD.resource.type.gold then
                            -- 银两
                            tmpGold = w.count
                        elseif w._type_ == XTHD.resource.type.feicui then
                            -- 翡翠
                            tmpFeicui = w.count
                        elseif w._type_ == XTHD.resource.type.item then
                            -- 道具
                            tmpItem[tostring(w.itemId)] = w.count
                        elseif w._type_ == XTHD.resource.type.smeltPoint then
                            -- 回收点
                            tmpSmeltPoint = w.count
                        elseif w._type_ == XTHD.resource.type.guild_contri then
                            -- 帮派贡献
                            tmpBpgx = w.count
                        end
                    end

                    local tmpFlag = true
                    if consumeIngot + tmpIngot > myIngot then
                        tmpFlag = false
                    elseif consumeGold + tmpGold > myGold then
                        tmpFlag = false
                    elseif consumeFeicui + tmpFeicui > myFeicui then
                        tmpFlag = false
                    elseif consumeSmeltPoint + tmpSmeltPoint > mySmeltPoint then
                        tmpFlag = false
                    elseif consumeBpgx + tmpBpgx > myBpgx then
                        tmpFlag = false
                    else
                        for k, v in pairs(tmpItem) do
                            local ownData = DBTableItem.getData(gameUser.getUserId(), { itemid = tonumber(k) })
                            local ownNum = 0
                            if #ownData ~= 0 and type(ownData[1]) == "table" then
                                for i = 1, #ownData do
                                    ownNum = ownNum + ownData[i].count
                                end
                            else
                                ownNum = ownData.count or 0
                            end
                            if (consumeItem[k] or 0) + v > ownNum then
                                tmpFlag = false
                                break
                            end
                        end
                    end

                    if tmpFlag then
                        consumeIngot = consumeIngot + tmpIngot
                        consumeGold = consumeGold + tmpGold
                        consumeFeicui = consumeFeicui + tmpFeicui
                        consumeSmeltPoint = consumeSmeltPoint + tmpSmeltPoint
                        consumeSmeltPoint = consumeSmeltPoint + tmpSmeltPoint
                        consumeBpgx = consumeBpgx + tmpBpgx
                        for k, v in pairs(tmpItem) do
                            consumeItem[k] =(consumeItem[k] or 0) + v
                        end
                    end
                end
            end
        end
        self._tipDown:setString(LANGUAGE_BIBLE_TEXT[11])
        self._tipDown:setVisible(true)
--      self._activateAllBtn:getLabel():setVisible(false)
--        self._activateAllBtn:setText(LANGUAGE_BIBLE_TEXT[12])
--        self._activateAllBtn:getLabel():enableOutline(cc.c4b(45, 13, 103, 255), 2)
--        self._activateAllBtn:getLabel():setPositionX(self._activateAllBtn:getLabel():getPositionX())
--        self._activateAllBtn:getLabel():setPositionY(self._activateAllBtn:getLabel():getPositionY() + 3)
--        self._activateAllBtn:getLabel():setAnchorPoint(cc.p(0.5, 0.6))
        self._activateAllBtn:setVisible(true)
        self._activateAllBtn:setTouchEndedCallback( function()
            local params = {
                modules = "activateAllBaoDian?",
                consumeIngot = consumeIngot,
                consumeGold = consumeGold,
                consumeFeicui = consumeFeicui,
                consumeSmeltPoint = consumeSmeltPoint,
                consumeItem = consumeItem,
                consumeBpgx = consumeBpgx,
                consumeItem = consumeItem,
                actionId = 1,
            }
            self:createPop(params)
        end )
        self._noActivateBibleLabel:setVisible(false)
    elseif levelupFlag then
        -- 全部升级
        for i, v in ipairs(self._objectData) do
            for j, u in ipairs(v) do
                if u.enoughFlag and u.level ~= 0 then
                    -- dump( u, "j" )
                    -- 判断当前对象升级材料是否全部拥有，全部拥有的才加到总消耗里
                    local tmpIngot = 0
                    local tmpGold = 0
                    local tmpFeicui = 0
                    local tmpItem = { }
                    local tmpSmeltPoint = 0
                    local tmpBpgx = 0
                    for k, w in ipairs(u.iconData) do
                        if w._type_ == XTHD.resource.type.ingot then
                            -- 元宝
                            tmpIngot = w.count
                        elseif w._type_ == XTHD.resource.type.gold then
                            -- 银两
                            tmpGold = w.count
                        elseif w._type_ == XTHD.resource.type.feicui then
                            -- 翡翠
                            tmpFeicui = w.count
                        elseif w._type_ == XTHD.resource.type.item then
                            -- 道具
                            tmpItem[tostring(w.itemId)] = w.count
                        elseif w._type_ == XTHD.resource.type.smeltPoint then
                            -- 回收点
                            tmpSmeltPoint = w.count
                        elseif w._type_ == XTHD.resource.type.guild_contri then
                            -- 帮派贡献
                            tmpBpgx = w.count
                        end
                    end

                    local tmpFlag = true
                    if (consumeIngot or 0) + tmpIngot > myIngot then
                        tmpFlag = false
                    elseif (consumeGold or 0) + tmpGold > myGold then
                        tmpFlag = false
                    elseif (consumeFeicui or 0) + tmpFeicui > myFeicui then
                        tmpFlag = false
                    elseif (consumeSmeltPoint or 0) + tmpSmeltPoint > mySmeltPoint then
                        tmpFlag = false
                    elseif (consumeBpgx or 0) + tmpBpgx > myBpgx then
                        tmpFlag = false
                    else
                        for k, v in pairs(tmpItem) do
                            local ownData = DBTableItem.getData(gameUser.getUserId(), { itemid = tonumber(k) })
                            local ownNum = 0
                            if #ownData ~= 0 and type(ownData[1]) == "table" then
                                for i = 1, #ownData do
                                    ownNum = ownNum + ownData[i].count
                                end
                            else
                                ownNum = ownData.count or 0
                            end
                            if (consumeItem[k] or 0) + v > ownNum then
                                tmpFlag = false
                                break
                            end
                        end
                    end

                    if tmpFlag then
                        consumeIngot =(consumeIngot or 0) + tmpIngot
                        consumeGold =(consumeGold or 0) + tmpGold
                        consumeFeicui =(consumeFeicui or 0) + tmpFeicui
                        consumeSmeltPoint =(consumeSmeltPoint or 0) + tmpSmeltPoint
                        consumeBpgx = (consumeBpgx or 0) + tmpBpgx
                        for k, v in pairs(tmpItem) do
                            consumeItem[k] =(consumeItem[k] or 0) + v
                        end
                    end
                end
            end
        end
        self._tipDown:setString(LANGUAGE_BIBLE_TEXT[13])
        self._tipDown:setVisible(true)
--        self._activateAllBtn:setText(LANGUAGE_BIBLE_TEXT[14])
--        self._activateAllBtn:getLabel():enableOutline(cc.c4b(45, 13, 103, 255), 2)
--        self._activateAllBtn:getLabel():setPositionX(self._activateAllBtn:getLabel():getPositionX())
--        self._activateAllBtn:getLabel():setPositionY(self._activateAllBtn:getLabel():getPositionY() + 3)
--        self._activateAllBtn:getLabel():setAnchorPoint(cc.p(0.5, 0.6))
        self._activateAllBtn:setVisible(true)
        self._activateAllBtn:setTouchEndedCallback( function()
            local params = {
                modules = "upAllBaoDian?",
                consumeIngot = consumeIngot,
                consumeGold = consumeGold,
                consumeFeicui = consumeFeicui,
                consumeSmeltPoint = consumeSmeltPoint,
                consumeItem = consumeItem,
                consumeBpgx = consumeBpgx,
                actionId = 2,
            }
            self:createPop(params)
        end )
        self._noActivateBibleLabel:setVisible(false)
    else
        -- 都没有
        self._tipDown:setVisible(false)
        self._activateAllBtn:setVisible(false)
        self._noActivateBibleLabel:setVisible(true)
    end
end
-- 刷新右侧
function XiuLianInfoLayer:refreshRight()
    -- 数据
    local data = self._objectData[self._typeId][self._selectedIndex]
    -- dump( data, "refreshRight")
    local typeTable = {
        "hpadd","atadd","dfadd","matadd","mdfadd",
    }
    -- 对象名字
    local objData = { }
    if data.pos == 1 then
        objData = gameData.getDataFromCSV("GeneralInfoList", { heroid = data.needID })
    else
        objData = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = data.needID })
    end
    if objData.name and data.level then
        self._objectName:setString(objData.name .. " 等级." .. data.level .. " / " .. data.maxlevel)
    else
        self._objectName:setString("")
    end

    self._consumeIcons:removeAllChildren()

    local modules = ""
    if data.level == 0 then
        -- 激活
        -- 中间属性加成
        self._midAttr:setString(LANGUAGE_BIBLE_ATTR(1, self._bibleId, data[typeTable[self._bibleId]] *(data.level + 1)))
        self._midAttr:setVisible(true)
        -- 当前属性加成
        self._currAttr:setVisible(false)
        -- 下级属性加成
        self._nextAttr:setVisible(false)

        if not self._ownObjectData[self._typeId][tostring(data.needID)] then
            if self._typeId == 1 then
                -- 未拥有英雄，显示获取途径
                -- 没有英雄
                self._noHeroLabel:setVisible(true)
                self._getHeroBtn:setVisible(true)
                self._getHeroBtn:setTouchEndedCallback( function()
                    local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
                    popLayer = popLayer:create(tonumber(data.needID) + 1000)
                    self:addChild(popLayer)
                end )
                self._noEquipLabel:setVisible(false)
            else
                self._noHeroLabel:setVisible(false)
                self._getHeroBtn:setVisible(false)
                self._noEquipLabel:setVisible(true)
            end
            -- 升至最高等级
            self._maxLevelLabel:setVisible(false)
            -- 升级
            self._activateBtn:setVisible(false)

            return
        else
            -- 没有英雄
            self._noHeroLabel:setVisible(false)
            self._getHeroBtn:setVisible(false)
            self._noEquipLabel:setVisible(false)
            -- 升至最高等级
            self._maxLevelLabel:setVisible(false)
            -- 升级
            self._activateBtn:setText("激 活")
            self._activateBtn:getLabel():enableOutline(cc.c4b(159, 79, 39, 255), 2)
            self._activateBtn:getLabel():setAnchorPoint(cc.p(0.5, 0.6))
            self._activateBtn:getLabel():setPositionY(self._activateBtn:getLabel():getPositionY() + 5)
            self._activateBtn:setVisible(true)
            modules = "activateBaoDian?"
        end
    elseif data.level == data.maxlevel then
        -- 满级
        -- 中间属性加成
        self._midAttr:setString(LANGUAGE_BIBLE_ATTR(2, self._bibleId, data[typeTable[self._bibleId]] * data.level))
        self._midAttr:setVisible(true)
        -- 当前属性加成
        self._currAttr:setVisible(false)
        -- 下级属性加成
        self._nextAttr:setVisible(false)

        -- 没有英雄
        self._noHeroLabel:setVisible(false)
        self._getHeroBtn:setVisible(false)
        self._noEquipLabel:setVisible(false)
        -- 升至最高等级
        self._maxLevelLabel:setVisible(true)
        -- 升级
        self._activateBtn:setVisible(false)
    else
        -- 升级
        -- 中间属性加成
        self._midAttr:setVisible(false)
        -- 当前属性加成
        self._currAttr:setString(LANGUAGE_BIBLE_ATTR(2, self._bibleId, data[typeTable[self._bibleId]] * data.level))
        self._currAttr:setVisible(true)
        -- 下级属性加成
        self._nextAttr:setString(LANGUAGE_BIBLE_ATTR(3, self._bibleId, data[typeTable[self._bibleId]] *(data.level + 1)))
        self._nextAttr:setVisible(true)

        -- 没有英雄
        self._noHeroLabel:setVisible(false)
        self._getHeroBtn:setVisible(false)
        self._noEquipLabel:setVisible(false)
        -- 升至最高等级
        self._maxLevelLabel:setVisible(false)
        -- 升级
        self._activateBtn:setText("升 级")
        self._activateBtn:getLabel():enableOutline(cc.c4b(159, 79, 39, 255), 2)
        self._activateBtn:getLabel():setAnchorPoint(cc.p(0.5, 0.7))
        self._activateBtn:getLabel():setPositionY(self._activateBtn:getLabel():getPositionY() + 8)
        self._activateBtn:setVisible(true)
        modules = "upBaoDian?"
    end
    -- 消耗品
    local iconWidth = self._consumeIcons:getContentSize().width / #data.iconData
    local iconHeight = self._consumeIcons:getContentSize().height * 0.5

    local myIngot = gameUser.getIngot()
    local myGold = gameUser.getGold()
    local myFeicui = gameUser.getFeicui()
    local mySmeltPoint = gameUser.getSmeltPoint()
    local myBpgx = gameUser.getGuildPoint()

    local ingotFlag = false
    local goldFlag = false
    local feicuiFlag = false
    local smeltPointFlag = false
    local bpgxFlag = false
    local itemFlag = 0
    for i, v in ipairs(data.iconData) do
        -- dump( v, "v" )
        local tmpData = clone(v)
        if v._type_ == XTHD.resource.type.ingot then
            -- 元宝
            if myIngot >= v.count then
                tmpData.fnt_type = 1
            else
                ingotFlag = true
                tmpData.fnt_type = 2
            end
            tmpData.count = v.count
        elseif v._type_ == XTHD.resource.type.gold then
            -- 银两
            if myGold >= v.count then
                tmpData.fnt_type = 1
            else
                goldFlag = true
                tmpData.fnt_type = 2
            end
            tmpData.count = v.count
        elseif v._type_ == XTHD.resource.type.feicui then
            -- 翡翠
            if myFeicui >= v.count then
                tmpData.fnt_type = 1
            else
                feicuiFlag = true
                tmpData.fnt_type = 2
            end
            tmpData.count = v.count
        elseif v._type_ == XTHD.resource.type.item then
            -- 道具
            local ownData = DBTableItem.getData(gameUser.getUserId(), { itemid = v.itemId })
            local ownNum = 0
            if #ownData ~= 0 and type(ownData[1]) == "table" then
                for i = 1, #ownData do
                    ownNum = ownNum + ownData[i].count
                end
            else
                ownNum = ownData.count or 0
            end
            if ownNum >=(v.count or 0) then
                tmpData.fnt_type = 1
            else
                itemFlag = v.itemId
                tmpData.fnt_type = 2
            end
            tmpData.count = ownNum .. "/" ..(v.count or 0)
        elseif v._type_ == XTHD.resource.type.smeltPoint then
            -- 回收点
            if mySmeltPoint >= v.count then
                tmpData.fnt_type = 1
            else
                smeltPointFlag = true
                tmpData.fnt_type = 2
            end
            tmpData.count = v.count
        elseif v._type_ == XTHD.resource.type.guild_contri then
            -- 帮派贡献
            if myBpgx >= v.count then
                tmpData.fnt_type = 1
            else
                bpgxFlag = true
                tmpData.fnt_type = 2
            end
            tmpData.count = v.count
        end
        local icon = ItemNode:createWithParams(tmpData)
        icon:setScale(64 / icon:getContentSize().width)
        icon:setPosition(10 + (i-1)*icon:getContentSize().width, iconHeight)
        self._consumeIcons:addChild(icon)
    end
    self._activateBtn:setTouchEndedCallback( function()
        if ingotFlag then
            local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create( { id = 1 })
            self:addChild(layer)
            return
        end
        if goldFlag then
            local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create( { id = 3 })
            self:addChild(layer)
            return
        end
        if feicuiFlag then
            local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create( { id = 4 })
            self:addChild(layer)
            return
        end
        if smeltPointFlag then
            local rightCallback = function()
                replaceLayer( { id = 5, fNode = self })
            end
            local layer = requires("src/fsgl/layer/ZhuangBei/ZhuangBeiLacePop.lua"):create( { _type_ = XTHD.resource.type.smeltPoint, rightCallback = rightCallback })
            self:addChild(layer)
            return
        end
        if bpgxFlag then
            XTHDTOAST("帮派贡献不足，请前往帮派进行获取")
            return
        end
        if itemFlag ~= 0 then
            local rightCallback = function()
                local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
                popLayer = popLayer:create(itemFlag)
                self:addChild(popLayer)
            end
            local layer = requires("src/fsgl/layer/ZhuangBei/ZhuangBeiLacePop.lua"):create( { itemId = itemFlag, rightCallback = rightCallback })
            self:addChild(layer)
            return
        end
        self:activateBtnCallback(data.id, modules, data.addtype, data[typeTable[self._bibleId]])
        -- self:createAnimation( data[typeTable[self._bibleId]] )
    end )
end
-- 更改宝典刷新
function XiuLianInfoLayer:refreshBible()
    self:buildData()
    self:refreshLeft()
    self._tableView:reloadData()
    self:refreshRight()
end
-- 点击激活和升级按钮
function XiuLianInfoLayer:activateBtnCallback(id, modules, addtype, addProperty)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = modules,
        params = { configId = id },
        successCallback = function(backData)
            -- dump(backData,"激活升级宝典返回")
            if tonumber(backData.result) == 0 then
                -- 更新主角属性
                gameUser.setGuildPoint(backData.totalContribution)      
                if backData.property and #backData.property > 0 then
                    for i = 1, #backData.property do
                        local pro_data = string.split(backData.property[i], ',')
                        DBUpdateFunc:UpdateProperty("userdata", pro_data[1], pro_data[2])
                    end
                    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
                    -- 刷新数据信息
                end
                -- 更新背包
                if backData.bagItems and #backData.bagItems ~= 0 then
                    for i = 1, #backData.bagItems do
                        local item_data = backData.bagItems[i]
                        if item_data.count and tonumber(item_data.count) ~= 0 then
                            DBTableItem.updateCount(gameUser.getUserId(), item_data, item_data.dbId)
                        else
                            DBTableItem.deleteData(gameUser.getUserId(), item_data.dbId)
                        end
                    end
                end
                -- 更新英雄属性
                if backData.petPropertys then
                    for i, v in ipairs(backData.petPropertys) do
                        DBTableHero.multiUpdate(gameUser.getUserId(), v.baseId, v.property)
                    end
                end
                -- 动画
                self:createAnimation(addProperty, function()
                    -- 更新当前界面
                    self._configList[tostring(id)] = self._configList[tostring(id)] and self._configList[tostring(id)] + 1 or 1
                    self._objectData[self._typeId][self._selectedIndex].level = self._configList[tostring(id)]
                    self._addProperty[addtype] = self._addProperty[addtype] + addProperty
                    self._objectData[self._typeId][self._selectedIndex].iconData = self:calculate(self._objectData[self._typeId][self._selectedIndex])
                    self:judgeEnough(self._objectData[self._typeId][self._selectedIndex].needID)
                    self:refreshLeft()
                    self._tableView:reloadData()
                    self:refreshRight()
                end )
            else
                XTHDTOAST(backData.msg)
            end
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        targetNeedsToRetain = self,
        -- 需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,
        -- 加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    } )
end
-- 点击全部激活和全部升级按钮
function XiuLianInfoLayer:activateAllBtnCallback(bibleId, modules)
    -- print("activateAllBtnCallback  ",bibleId,modules)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = modules,
        params = { propertyType = bibleId },
        successCallback = function(backData)
            -- dump(backData,"激活升级全部宝典返回")
            if tonumber(backData.result) == 0 then
                -- 更新主角属性
                gameUser.setGuildPoint(backData.totalContribution)                  
                if backData.property and #backData.property > 0 then
                    for i = 1, #backData.property do
                        local pro_data = string.split(backData.property[i], ',')
                        DBUpdateFunc:UpdateProperty("userdata", pro_data[1], pro_data[2])
                    end
                    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
                    -- 刷新数据信息
                end
                -- 更新背包
                if backData.bagItems and #backData.bagItems ~= 0 then
                    for i = 1, #backData.bagItems do
                        local item_data = backData.bagItems[i]
                        if item_data.count and tonumber(item_data.count) ~= 0 then
                            DBTableItem.updateCount(gameUser.getUserId(), item_data, item_data.dbId)
                        else
                            DBTableItem.deleteData(gameUser.getUserId(), item_data.dbId)
                        end
                    end
                end
                -- 更新英雄属性
                if backData.petPropertys then
                    for i, v in ipairs(backData.petPropertys) do
                        DBTableHero.multiUpdate(gameUser.getUserId(), v.baseId, v.property)
                    end
                end
                self:createAllAnimation(backData.addProperty[self._bibleId] - self._addProperty[self._bibleId], function()
                    -- 更新当前界面
                    self._configList = { }
                    if backData.configList then
                        for i, v in ipairs(backData.configList) do
                            self._configList[tostring(v.configId)] = v.level
                        end
                    end
                    self._addProperty = backData.addProperty
                    -- 刷新
                    self:refreshData(self._objectData[self._typeId][self._selectedIndex].needID)
                end )
            else
                XTHDTOAST(backData.msg)
            end
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        targetNeedsToRetain = self,
        -- 需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,
        -- 加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    } )
end
-- 激活和升级动画
function XiuLianInfoLayer:createAnimation(addAttr, callback)
    self._animationBg:setVisible(true)
    self._animationNum = self._animationNum + 1

    local dstPos = self._totalAdditionNum:convertToWorldSpace(cc.p(self._totalAdditionNum:getBoundingBox().width * 0.5 + 5, 35))
    local icons = self._consumeIcons:getChildren()

    local xlTime = 0.375
    local lzTime = 0.75
    local zkTime = 0.56
    local sxTime = 1

    for i, v in ipairs(icons) do
        local oriPos = v:convertToWorldSpace(cc.p(v:getBoundingBox().width * 0.5 + 7, v:getBoundingBox().width * 0.5 + 7))
        -- 蓄力
        local _xlData = {
            file = "res/image/plugin/bible_layer/effect/bdgx",
            name = "xl",
            startIndex = 1,
            endIndex = 25,
            perUnit = 0.05,
            isCircle = false,
        }
        local xlAnimation = XTHD.createSpriteFrameSp(_xlData)
        xlAnimation:setScale(1.3)
        xlAnimation:setPosition(oriPos)
        -- xlAnimation:setTag( i )
        self:addChild(xlAnimation)
        -- 粒子
        local particle = nil
        performWithDelay(self, function()
            particle = cc.ParticleSystemQuad:create("res/image/plugin/bible_layer/effect/bdlz.plist")
            particle:setAutoRemoveOnFinish(false)
            particle:setPosition(oriPos)
            self:addChild(particle)
            particle:runAction(
            cc.MoveTo:create(
            lzTime, cc.p(dstPos.x, dstPos.y - 10)
            )
            )
        end , xlTime)
        performWithDelay(self, function()
            -- 移除屏幕
            particle:setPosition(-10000, -10000)
        end , xlTime + lzTime)
        performWithDelay(self, function()
            -- 移除粒子
            particle:removeFromParent()
        end , xlTime + lzTime + 0.3 + sxTime)
    end
    performWithDelay(self, function()
        -- 炸开
        -- local _zkData = {
        --     file = "res/image/plugin/bible_layer/effect/bdgx",
        --     name = "zk",
        --     startIndex = 1,
        --     endIndex = 14,
        --     perUnit = 0.066,
        --     isCircle = false,
        -- }
        -- local zkAnimation = XTHD.createSpriteFrameSp( _zkData )
        -- zkAnimation:setScale( 2.7 )
        -- zkAnimation:setPosition( dstPos )
        -- self:addChild( zkAnimation )
        local titleSpine = sp.SkeletonAnimation:create("res/image/plugin/bible_layer/effect/xiulian.json", "res/image/plugin/bible_layer/effect/xiulian.atlas", 1.0)
        titleSpine:setPosition(dstPos)
        titleSpine:setScale(0.6)
        titleSpine:setAnimation(0, "xiulian", false)
        self:addChild(titleSpine)
    end , xlTime + lzTime)
    performWithDelay(self, function()
        -- 属性变化
        local addAttrLabel = XTHD.createLabel( {
            text = "+" .. addAttr,
            fontSize = 40,
            color = cc.c3b(255,100,0),
            -- cc.c3b( 103, 147, 18 ),
            pos = cc.p(dstPos),
        } )
        self:addChild(addAttrLabel)
        addAttrLabel:runAction(
        cc.Spawn:create(
        cc.MoveBy:create(
        sxTime, cc.p(0, 50)
        ),
        cc.FadeOut:create(
        sxTime
        )
        )
        )
    end , xlTime + lzTime + 0.3)
    performWithDelay(self, function()
        -- 移除背景
        self._animationNum = self._animationNum - 1
        if self._animationNum <= 0 then
            self._animationNum = 0
            self._animationBg:setVisible(false)
        end
        if callback then
            callback()
        end
    end , xlTime + lzTime + 0.3 + sxTime)
end
-- 全部激活和全部升级动画
function XiuLianInfoLayer:createAllAnimation(addAttr, callback)
    self._animationBg:setVisible(true)
    self._animationNum = self._animationNum + 1

    local dstPos = self._totalAdditionNum:convertToWorldSpace(cc.p(self._totalAdditionNum:getBoundingBox().width * 0.5 + 5, 35))

    local zkTime = 0.56
    local sxTime = 1

    -- 炸开
    local _zkData = {
        file = "res/image/plugin/bible_layer/effect/bdgx",
        name = "zk",
        startIndex = 1,
        endIndex = 14,
        perUnit = 0.066,
        isCircle = false,
    }
    local zkAnimation = XTHD.createSpriteFrameSp(_zkData)
    zkAnimation:setScale(2.7)
    zkAnimation:setPosition(dstPos)
    self:addChild(zkAnimation)

    performWithDelay(self, function()
        -- 属性变化
        local addAttrLabel = XTHD.createLabel( {
            text = "+" .. addAttr,
            fontSize = 40,
            color = cc.c3b(255,100,0),
            pos = cc.p(dstPos),
        } )
        self:addChild(addAttrLabel)
        addAttrLabel:runAction(
        cc.Spawn:create(
        cc.MoveBy:create(
        sxTime, cc.p(0, 50)
        ),
        cc.FadeOut:create(
        sxTime
        )
        )
        )
    end , 0.3)
    performWithDelay(self, function()
        -- 移除背景
        self._animationNum = self._animationNum - 1
        if self._animationNum <= 0 then
            self._animationNum = 0
            self._animationBg:setVisible(false)
        end
        if callback then
            callback()
        end
    end , 0.3 + sxTime)
end
-- 全部激活和全部升级弹窗
function XiuLianInfoLayer:createPop(params)
    -- dump( params, "createPop" )
    local confirm = XTHDConfirmDialog:createWithParams( {
        rightCallback = function()
            self:activateAllBtnCallback(self._bibleId, params.modules)
        end
    } )
    
    local bg = confirm:getBgImage()
    local _size = bg:getContentSize()
    bg:setContentSize(_size.width,_size.height + 25)
    bg:setPositionY(bg:getPositionY()-15)
    
    local container = confirm:getContainer()

    local iconData = { }
    -- 道具
    for k, v in pairs(params.consumeItem) do
        iconData[#iconData + 1] = {
            _type_ = XTHD.resource.type.item,
            itemId = tonumber(k),
            count = v,
        }
    end
    table.sort(iconData, function(a, b)
        return a.itemId < b.itemId
    end )
    -- 回收点
    if params.consumeSmeltPoint > 0 then
        table.insert(iconData, 1, {
            _type_ = XTHD.resource.type.smeltPoint,
            count = params.consumeSmeltPoint,
        } )
    end
    -- 翡翠
    if params.consumeFeicui > 0 then
        table.insert(iconData, 1, {
            _type_ = XTHD.resource.type.feicui,
            count = params.consumeFeicui,
        } )
    end
    -- 银两
    if params.consumeGold > 0 then
        table.insert(iconData, 1, {
            _type_ = XTHD.resource.type.gold,
            count = params.consumeGold,
        } )
    end
    -- 元宝
    if params.consumeIngot > 0 then
        table.insert(iconData, 1, {
            _type_ = XTHD.resource.type.ingot,
            count = params.consumeIngot,
        } )
    end
     --帮派贡献
    if params.consumeBpgx > 0 then
        table.insert(iconData, 1, {
            _type_ = XTHD.resource.type.guild_contri,
            count = params.consumeBpgx,
        } )
    end
    -- 创建icon
    local scrollviewWidth = 460
    local scrollview = ccui.ScrollView:create()
    container:addChild(scrollview)
    scrollview:setAnchorPoint(0, 0)
    scrollview:setTouchEnabled(true)
    scrollview:setScrollBarEnabled(false)
    scrollview:setDirection(ccui.ScrollViewDir.vertical)
    if #iconData > 4 then
        scrollview:setBounceEnabled(true)
        -- container:setContentSize( scrollviewWidth + 55, 270 )
        scrollview:setContentSize(cc.size(scrollviewWidth, container:getContentSize().height - 120))
        scrollview:setInnerContainerSize(cc.size(scrollviewWidth, math.ceil(#iconData / 4) * 90))
        scrollview:setPosition(50, 80)
    else
        scrollview:setBounceEnabled(false)
        -- container:setContentSize( scrollviewWidth + 55, 228 )
        scrollview:setContentSize(cc.size(scrollviewWidth, 100))
        scrollview:setInnerContainerSize(cc.size(scrollviewWidth, 90))
        scrollview:setPosition(50, 185)
    end
    for i, v in ipairs(iconData) do
        v.isShowDrop = false
        local icon = ItemNode:createWithParams(clone(v))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        icon:setPosition((2 *((i - 1) % 4) + 1) * scrollviewWidth / 10,(math.ceil(#iconData / 4) - math.ceil(i / 4) + 0.5) * 95)
        icon:setScale(0.8)
        scrollview:addChild(icon)
    end
    confirm:getLeftButton():setPositionY(45)
    confirm:getRightButton():setPositionY(45)

    local tip = XTHD.createLabel( {
        text = LANGUAGE_BIBLE_ACTION(self._bibleId,params.actionId),
        fontSize = 20,
        color = XTHD.resource.color.gray_desc,
    } )
    tip:setPosition(container:getContentSize().width * 0.5, container:getContentSize().height - 25)
    container:addChild(tip)
    -- 分隔
    -- local splitLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
    -- splitLine:setContentSize( container:getContentSize().width - 14, 2 )
    -- splitLine:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    -- splitLine:setPosition( container:getContentSize().width*0.5, scrollview:getPositionY() )
    -- container:addChild( splitLine )

    self:addChild(confirm)
end
-- 刷新
function XiuLianInfoLayer:refreshData(objectId)
    self:buildData(objectId)
    self:refreshLeft()
    self._tableView:reloadData()
    self:refreshRight()
end

function XiuLianInfoLayer:create(data)
    return XiuLianInfoLayer.new(data)
end

function XiuLianInfoLayer:onEnter()
    YinDaoMarg:getInstance():addGuide( { parent = self, index = 5 }, 17)
    ----剧情
    YinDaoMarg:getInstance():doNextGuide()
end

return XiuLianInfoLayer