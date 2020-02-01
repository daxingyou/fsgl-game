--[[
    重构的装备回收界面
]]
local ZhuangBeiSmeltLayer = class( "ZhuangBeiSmeltLayer",function ()
    return XTHD.createBasePageLayer()
end)

function ZhuangBeiSmeltLayer:ctor( dbid, callFunc )
    self._exist = true
    self:initData( callFunc )
    self:initUI( dbid )
    self:refreshData()
    XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK,
        callback = function ()
            self:refreshData()
        end,
    })
end
function ZhuangBeiSmeltLayer:onCleanup()
    self._exist = false
    XTHD.removeEventListener( CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK )
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TASKLIST})
    if self._callFunc then
        self._callFunc()
    end
    local textureTable = {
        "res/image/plugin/equip_smelt/smeltShop_up.png",
        "res/image/plugin/equip_smelt/smeltShop_down.png",
        "res/image/plugin/reforge/smelt_icon.png",
        "res/image/plugin/equip_smelt/smelterBg.png",
        "res/image/plugin/equip_smelt/smelter.png",
        "res/image/plugin/equip_smelt/smeltPointTip.png",
        "res/image/ranklistreward/splitY.png",
        "res/image/common/btn/btn_tabTop_up.png",
        "res/image/common/btn/btn_tabTop_down.png",
        "res/image/plugin/equip_smelt/smeltBg.png",
        "res/image/plugin/equip_smelt/topSplit.png",
        "res/image/plugin/equip_smelt/bottomSplit.png",
        "res/image/plugin/equip_smelt/noEquipBg.png",
        "res/image/illustration/selected.png",
        "res/image/common/common_progressBg_2.png",
        "res/image/common/common_progress_2.png",
    }
    local textureCache = cc.Director:getInstance():getTextureCache()
    for i, v in ipairs( textureTable ) do
        textureCache:removeTextureForKey( v )
    end
    
    for i = 1, 6 do
        textureCache:removeTextureForKey( "res/image/plugin/equip_smelt/quality"..i.."_up.png" )
        textureCache:removeTextureForKey( "res/image/plugin/equip_smelt/quality"..i.."_down.png" )
    end

    if self._smelter then
        self._smelter:removeFromParent()
        self._smelter = nil
    end
end
function ZhuangBeiSmeltLayer:initData( callFunc )
    self._callFunc = callFunc
    -- 所有装备数据
    self._equipData = {}
    -- 装备是否选中状态
    self._selectedEquip = {}
    -- tab内选中装备的数量
    self._selectedNum = {}
    for i = 1, 6 do
        self._equipData[i] = {}
        self._selectedEquip[i] = {}
        self._selectedNum[i] = 0
    end
    -- 回收数据
    self._smeltData = gameData.getDataFromCSV( "EquipRecyclingList" )
    -- 可获得的回收点数
    self._canGetSmeltPoint = 0
    -- 获得物品
    self._rewardData = {}
end
-- 创建ui
function ZhuangBeiSmeltLayer:initUI( dbid )
    self._equipDbid = dbid or 0
    self._tabIndex = 1
    self._equipIndex = 1

    -- tab
    self._tabsTable = {}
    -- 红点
    self._redDotsTable = {}
    -- 装备icon，播放动画用
    self._equipIcon = {}

    self._size = self:getContentSize()
    -- 背景
    local bottomBg = XTHD.createSprite( "res/image/plugin/equip_smelt/equipsmelt.png" )
    bottomBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    bottomBg:setPosition( self._size.width * 0.5, ( self._size.height - self.topBarHeight ) * 0.5 )
	self._bottomBg = bottomBg
    self:addChild( bottomBg )

	local title = "res/image/public/huishou_title.png"
	XTHD.createNodeDecoration(self._bottomBg,title)
    self._bottomBgSize = bottomBg:getContentSize()
    self._leftSize = cc.size( self._bottomBgSize.width - 86*6 - 10, self._bottomBgSize.height - 40 )
    self._rightSize = cc.size( 86*6-20, self._bottomBgSize.height - 60 )

    self:initLeft()
    self:initRight()
end
-- 创建左侧
function ZhuangBeiSmeltLayer:initLeft()

	
    -- 容器
    local leftContainer = XTHD.createSprite()
    leftContainer:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    leftContainer:setContentSize( self._leftSize )
    leftContainer:setPosition( self._leftSize.width * 0.5 , self._leftSize.height * 0.5)
    self._bottomBg:addChild( leftContainer )
    -- 回收商店
    self._smeltShopBtn = XTHD.createButton({
        normalFile = "res/image/plugin/equip_smelt/smeltShop_up.png",
        selectedFile = "res/image/plugin/equip_smelt/smeltShop_down.png",
    })
    self._smeltShopBtn:setScale(0.7)
    self._smeltShopBtn:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    self._smeltShopBtn:setPosition( self._smeltShopBtn:getContentSize().width * 0.4+10, self._leftSize.height - self._smeltShopBtn:getContentSize().height * 0.25 +5)
    leftContainer:addChild( self._smeltShopBtn )

	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=27});
            self:addChild(StoredValue)
        end,
	})
	leftContainer:addChild(help_btn)
	help_btn:setPosition(self._leftSize.width,self._smeltShopBtn:getPositionY())

    -- 已拥有回收点
    local ownSmeltPointText = XTHD.createLabel({
        text = LANGUAGE_EQUIP_TEXT[12],
        fontSize = 20,
        color = cc.c3b( 252, 231, 204 ),
        ttf = "res/fonts/def.ttf"
    })
    ownSmeltPointText:enableOutline(cc.c4b(117, 54, 5,255),1)
    ownSmeltPointText:setAnchorPoint( cc.p( 1, 0.5 ) )
    ownSmeltPointText:setPosition( self._leftSize.width/2 + 20, self._leftSize.height - 27 )
    leftContainer:addChild( ownSmeltPointText )
    -- 回收点图标
    local smeltPointIcon = XTHD.createSprite( "res/image/plugin/reforge/smelt_icon.png" )
    smeltPointIcon:setAnchorPoint( cc.p( 0, 0.5 ) )
    smeltPointIcon:setPosition( ownSmeltPointText:getPosition() )
    leftContainer:addChild( smeltPointIcon )
    -- 回收点数
    self._ownSmeltPointNum = XTHD.createLabel({
        text = gameUser.getSmeltPoint(),
        fontSize = 24,
        color = cc.c3b( 252, 231, 204 ),
        ttf = "res/fonts/def.ttf"
    })
    self._ownSmeltPointNum:setAnchorPoint( cc.p( 0, 0.5 ) )
    self._ownSmeltPointNum:enableOutline(cc.c4b(117, 54, 5,255),1)
    self._ownSmeltPointNum:setPosition( smeltPointIcon:getPositionX() + 30, smeltPointIcon:getPositionY() )
    leftContainer:addChild( self._ownSmeltPointNum )
    self._smeltShopBtn:setTouchEndedCallback( function()
        local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("recycle")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
    end)
    -- 回收炉背景
    -- local smelterBg = XTHD.createSprite( "res/image/plugin/equip_smelt/smelterBg.png" )
    -- smelterBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    -- smelterBg:setPosition( self._leftSize.width*0.5 - 5, self._leftSize.height*0.5 - 23 )
    -- leftContainer:addChild( smelterBg )
    --看效果的图片
    local smelter2 = XTHD.createSprite("res/image/equipCopies/equip_base.png" )
    smelter2:setAnchorPoint( cc.p( 0.5, 1 ) )
    smelter2:setPosition( self._leftSize.width*0.5 + 5, self._leftSize.height*0.5-15  )
    smelter2:setScale(0.65)
    leftContainer:addChild( smelter2 )
	
    -- 回收炉
    -- local smelter = sp.SkeletonAnimation:create( "res/spine/effect/compose_effect/ldl.json", "res/spine/effect/compose_effect/ldl.atlas", 1.0 )
    local smelter = sp.SkeletonAnimation:create( "res/spine/effect/compose_effect/ronglianlu.json", "res/spine/effect/compose_effect/ronglianlu.atlas", 1.0 )
    smelter:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    smelter:setScale(0.65)
    smelter:setPosition( self._leftSize.width*0.5 + 5, self._leftSize.height*0.5 + 40 )
	
	smelter:setAnimation(0,"atk",false)

--	local move = cc.MoveTo:create(10,cc.p(200,0))
--	rld_bg:runAction(cc.Speed:create(move,10))
    --先透明化
    -- smelter:setOpacity(0)
    leftContainer:addChild( smelter )
    smelter:setAnimation(0,"idle",true)
    self._smelter = smelter
	self._smelter:setTimeScale(1.5)

    --回收后可获得回收点背景
    local rld_bg = cc.Sprite:create("res/image/plugin/equip_smelt/rld_bg.png")
    rld_bg:setPosition(self._leftSize.width/2+20,105)
    leftContainer:addChild(rld_bg)
    rld_bg:setScale(0.7)

    -- 回收后可获得回收点
    -- local canGetSmeltPointTip = XTHD.createSprite( "res/image/plugin/equip_smelt/smeltPointTip.png" )
    local canGetSmeltPointTip = XTHDLabel:create("回收后可获得回收点：",22)
    canGetSmeltPointTip:setColor(cc.c3b(0,0,0))
    canGetSmeltPointTip:setAnchorPoint( cc.p( 1, 0.5 ) )
    canGetSmeltPointTip:setPosition( self._leftSize.width*0.5 + 95, rld_bg:getPositionY() )
    leftContainer:addChild( canGetSmeltPointTip )
    -- 回收点图标
    local canGetSmeltPointIcon = XTHD.createSprite( "res/image/plugin/reforge/smelt_icon.png" )
    canGetSmeltPointIcon:setAnchorPoint( cc.p( 0, 0.5 ) )
    canGetSmeltPointIcon:setPosition( canGetSmeltPointTip:getPosition() )
    leftContainer:addChild( canGetSmeltPointIcon )
    -- 可获得回收点数
    self._canGetSmeltPointNum = getCommonWhiteBMFontLabel( 0 )
    self._canGetSmeltPointNum:setAnchorPoint( cc.p( 0, 0.5 ) )
    self._canGetSmeltPointNum:setPosition( canGetSmeltPointIcon:getPositionX() + 30, canGetSmeltPointIcon:getPositionY() - 7 )
    leftContainer:addChild( self._canGetSmeltPointNum )
    -- 开始回收按钮
    local smeltBtn = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(140, 46),
        isScrollView = false,
        text = LANGUAGE_EQUIP_TEXT[13],
        fontSize = 26,
        fontColor = cc.c3b( 255, 255, 255 ),
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( self._leftSize.width*0.5 + 5, 55 ),
        endCallback = function()
            local existFlag = false
            for i, v in ipairs( self._selectedNum ) do
                if v > 0 then
                    existFlag = true
                end
            end
            if not existFlag then
                XTHDTOAST(LANGUAGE_TIPS_WORDS52)-----"请先添加一件装备")
                return
            end

            -- 计算回收获得的材料
            local dbidData = self:getSmeltReward()
            local function confirmFunc()
                local jsonTable = json.encode( dbidData )
                XTHDHttp:requestAsyncInGameWithParams({
                    modules = "itemSmelt?",
                    params = {dbId = jsonTable},
                    successCallback = function( backData )
                        -- dump( backData, "itemSmelt" )
                        if tonumber( backData.result ) == 0 then
                            XTHD.saveItem({items = backData.costItems})
                            XTHD.saveItem({items = backData.addItems})
                            gameUser.setGold( backData.gold )
                            gameUser.setSmeltPoint( backData.smeltPoint )
                            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})

                            self.swallowBg = XTHDPushButton:createWithParams({
                                touchSize = cc.size(self:getBoundingBox().width,self:getBoundingBox().height),
                                needSwallow = true
                            })
                            self.swallowBg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
                            self:addChild( self.swallowBg )

                            self:playSmeltAnimation()
                            do
                                return
                            end

                            if self._selectedNum[self._tabIndex] > 0 then
                                -- 当前tab有回收的装备，需要播放动画
                                local animationSprite = {}
                                local data = self._equipData[self._tabIndex]
                                -- dump( data, "data")
                                for i, v in ipairs( self._selectedEquip[self._tabIndex] ) do
                                    if v and self._equipIcon[i] and self._equipIcon[i]._selected then
                                        -- print(1)
                                        local _node = ItemNode:createWithParams({
                                            itemId = data[i].itemid,
                                            needSwallow = false,
                                            _type_ = 4,
                                            isShowDrop = false,
                                            pos = self._equipIcon[i]:getParent():convertToWorldSpace( cc.p(self._equipIcon[i]:getPosition()) )--self._equipIcon[i]:getParent():convertToWorldSpace( cc.p( self._equipIcon[i]:getPosition() ) ),
                                        })
                                        self:addChild( _node )
                                        self._equipIcon[i]:setVisible( false )
                                        animationSprite[#animationSprite + 1] = _node
                                    end
                                end
								
                                self:runAction(
                                    cc.Sequence:create(
                                        cc.CallFunc:create(
                                            function()
												--cc.Director:getInstance():getScheduler():setTimeScale(0.1)
                                                -- 开盖
                                                self._smelter:setAnimation(0,"atk",false)
												
                                                local pointNode = self._smelter:getNodeForSlot( "xiaoguo_00017" )
                                                if not pointNode then
                                                    return 
                                                end
                                                local pointWorldPos = pointNode:convertToWorldSpace(cc.p(-5, 40))
                                                local _pos = self:convertToNodeSpace( pointWorldPos )
                                                print("_pos:".._pos)
                                                for i, v in ipairs( animationSprite ) do
                                                    local randomTime = (math.random()*0.3 + 0.2)*1.5 - (math.random()*0.3 + 0.2)
                                                    animationSprite[i]:runAction(
                                                        cc.Sequence:create(
                                                            cc.Spawn:create(
                                                                cc.MoveTo:create(
                                                                    randomTime, _pos
                                                                ),
                                                                cc.ScaleTo:create(
                                                                    randomTime, 0.3
                                                                ),
                                                                cc.RotateBy:create(
                                                                    randomTime, 1440
                                                                )
                                                            ),
                                                            cc.DelayTime:create(
                                                                randomTime
                                                            ),
                                                            cc.CallFunc:create(
                                                                function()
                                                                    animationSprite[i]:removeFromParent()
                                                                end
                                                            )
                                                        )
                                                    )
                                                end
                                            end
                                        ),
                                        cc.DelayTime:create(
                                            0.5*1.5-0.5
                                        ),
                                        cc.CallFunc:create(
                                            function()
                                                -- 跳动
                                                self._smelter:setAnimation(0,"atk",true)
                                            end
                                        ),
                                        cc.DelayTime:create(
                                            0.8*1.5-0.8
                                        ),
                                        cc.CallFunc:create(
                                            function()
                                                self._smelter:registerSpineEventHandler(
                                                    function ( event )
                                                        if event.eventData.name == "atk" then
                                                            if not self._exist then
                                                                return
                                                            end
                                                            self.swallowBg:removeFromParent()
                                                            ShowRewardNode:create( self._rewardData )
                                                            self._selectAllBtn:setText( LANGUAGE_EQUIP_TEXT[14] )
                                                            self:refreshData()
                                                        end
                                                    end
                                                , sp.EventType.ANIMATION_EVENT)
                                                -- 爆炸
                                                self._smelter:setAnimation(0,"atk",false)
                                            end
                                        )
                                    )
                                )
                            end
                        else
                            if backData.msg then
                                XTHDTOAST( backData.msg )
                            else
                                XTHDTOAST( LANGUAGE_TIPS_WEBERROR )---"网络请求失败!")
                            end
                        end
                    end,--成功回调
                    failedCallback = function()
                        XTHDTOAST( LANGUAGE_TIPS_WEBERROR )-----"网络请求失败")
                    end,--失败回调
                    targetNeedsToRetain = self,--需要保存引用的目标
                    loadingParent = self,
                    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                })
            end
            local ZhuangBeiSmeltRewardPop = requires("src/fsgl/layer/ZhuangBei/ZhuangBeiSmeltRewardPop.lua"):create(self._rewardData,confirmFunc)
            self:addChild(ZhuangBeiSmeltRewardPop,3)
            ZhuangBeiSmeltRewardPop:show()
        end,
    })
    smeltBtn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
    leftContainer:addChild( smeltBtn )
    smeltBtn:setScale(0.7)
end
-- 创建右侧
function ZhuangBeiSmeltLayer:initRight()
    -- 容器
    local rightContainer = XTHD.createSprite()
    rightContainer:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    rightContainer:setContentSize( self._rightSize )
    rightContainer:setPosition(self._bottomBg:getContentSize().width -  rightContainer:getContentSize().width * 0.5 + 15, self._bottomBg:getContentSize().height * 0.5 )
    self._bottomBg:addChild( rightContainer )
    -- 过渡
    -- local splitSprite = XTHD.createSprite( "res/image/ranklistreward/splitY.png" )
    -- splitSprite:setAnchorPoint( cc.p( 0, 0 ) )
    -- splitSprite:setPosition( 0, 0 )
    -- splitSprite:setFlippedX( true )
    -- rightContainer:addChild( splitSprite )

    -- tab点击处理
    local function tabCallback( index )
        if self._tabIndex ~= index then
            -- 更改tabs状态
            self:changeTab( index )
            self._equipIcon = {}
            self._equipTableView:reloadData()
            if #self._equipData[self._tabIndex] == 0 then
                self._noEquipBg:setVisible( true )
            else
                self._noEquipBg:setVisible( false )
            end
        end
    end

    -- 循环创建tab
    local colorTab = {"白色","绿色","蓝色","紫色","橙色","红色"}
    for i = 1, 6 do
        local colorLabel = XTHDLabel:create(colorTab[i],22)
        local tabBtn_normal = getCompositeNodeWithImg( "res/image/common/btn/btn_tabTop_up.png", "res/image/plugin/equip_smelt/quality"..i.."_up.png",colorLabel )
        local tabBtn_selected = getCompositeNodeWithImg( "res/image/common/btn/btn_tabTop_down.png", "res/image/plugin/equip_smelt/quality"..i.."_down.png",colorLabel )
        local tabBtn = XTHD.createButton({
            normalNode = tabBtn_normal,
            selectedNode = tabBtn_selected,
            anchor = cc.p( 0.5, 1 ),
            touchSize = cc.size( 86, 45 ),
            endCallback = function()
                tabCallback( i )
            end,
        })
        tabBtn:setPosition( self._rightSize.width + 80*( i - 6.5 )-25, self._rightSize.height-5 )
        tabBtn:setScale(0.8)
        rightContainer:addChild( tabBtn )
        self._tabsTable[i] = tabBtn
        -- 红点
        local redDot = cc.Sprite:create( "res/image/common/heroList_redPoint.png" )
        redDot:setAnchorPoint( 1, 1 )
        redDot:setPosition( tabBtn:getBoundingBox().width+15, tabBtn:getBoundingBox().height + 11 )
        tabBtn:addChild( redDot )
        self._redDotsTable[i] = redDot
    end
    self._tabsTable[self._tabIndex]:setSelected( true )
    self._tabsTable[self._tabIndex]:setEnable( false )
    self._tabsTable[self._tabIndex]:setLocalZOrder( 1 )

    -- 下面的背景
    -- local tabBg = ccui.Scale9Sprite:create( cc.rect( 18, 12, 1, 1 ), "res/image/plugin/equip_smelt/smeltBg.png" )
    local tabBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png" )
    tabBg:setContentSize( self._rightSize.width-16, self._rightSize.height - 10 - 33 - 65 )
    tabBg:setAnchorPoint( cc.p( 0, 0 ) )
    tabBg:setPosition( -10, 62 )
    rightContainer:addChild( tabBg )
    -- 顶部分隔
    -- local splitTop = XTHD.createSprite( "res/image/plugin/equip_smelt/topSplit.png" )
    -- splitTop:setScaleX( self._rightSize.width/splitTop:getContentSize().width )
    -- splitTop:setAnchorPoint( cc.p( 0.5, 1 ) )
    -- splitTop:setPosition( self._rightSize.width*0.5, tabBg:getContentSize().height )
    -- tabBg:addChild( splitTop )
    -- 底部分隔
    -- local splitBottom = XTHD.createSprite( "res/image/plugin/equip_smelt/bottomSplit.png" )
    -- splitBottom:setScaleX( self._rightSize.width/splitBottom:getContentSize().width )
    -- splitBottom:setAnchorPoint( cc.p( 0.5, 0 ) )
    -- splitBottom:setPosition( self._rightSize.width*0.5, 0 )
    -- tabBg:addChild( splitBottom )
    -- 没有装备的时候显示
    self._noEquipBg = XTHD.createSprite( "res/image/plugin/equip_smelt/noEquipBg.png" )
    self._noEquipBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    self._noEquipBg:setPosition( self._rightSize.width*0.5, tabBg:getContentSize().height*0.5 )
    tabBg:addChild( self._noEquipBg )
    -- tableview
    local cellWidth = self._rightSize.width - 32
    self._equipTableView = CCTableView:create( cc.size( cellWidth, tabBg:getContentSize().height-10) )
    TableViewPlug.init(self._equipTableView)
    self._equipTableView:setPosition( 0, 5 )
    self._equipTableView:setBounceable( true )
    self._equipTableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL ) --设置横向纵向
    self._equipTableView:setDelegate()
    self._equipTableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
    local iconPosX = {}
    for i = 1, 5 do
        iconPosX[i] = cellWidth/5*( i - 0.5 )
    end
    local iconsPerCell = 5
    local function numberOfCellsInTableView( table )
        return math.ceil( #self._equipData[self._tabIndex]/iconsPerCell )
    end
    local function cellSizeForTable( table, index )
        local tmp = math.ceil( ( #self._equipData[self._tabIndex] - index*iconsPerCell )/5 )
        return cellWidth,( tmp < iconsPerCell/5 and tmp or iconsPerCell/5 )*90 
    end
    local function tableCellAtIndex( table, index )
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
        end

        local tabData = self._equipData[self._tabIndex]
        -- 当前cell里icon行数
        local curLines = math.ceil( ( #self._equipData[self._tabIndex] - index*iconsPerCell )/5 )
        curLines = curLines < iconsPerCell/5 and curLines or iconsPerCell/5

        for i = 1, iconsPerCell do
            local equipData = tabData[index*iconsPerCell + i]
            if equipData then
                -- 装备icon
                local equipIcon = ItemNode:createWithParams({
                    dbId = equipData.dbid,
                    needSwallow = false,
                    isShowDrop = false,
                    _type_ = 4,
                })
                -- equipIcon:setScale( 0.8 )
                equipIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
                equipIcon:setPosition( iconPosX[( i - 1 )%5 + 1], 42 + 90*( curLines - math.ceil( i/5 ) ) )
                cell:addChild( equipIcon )
                equipIcon:setScale(0.8)
                self._equipIcon[index*iconsPerCell + i] = equipIcon
                -- 等级
                local equipLevelBg = cc.Sprite:createWithTexture( nil, cc.rect( 0, 0, 35, 22) )
                equipLevelBg:setColor( cc.c3b( 0, 0, 0 ) )
                equipLevelBg:setOpacity( 125.0 )
                equipLevelBg:setAnchorPoint( 0, 0 )
                equipLevelBg:setPosition( 5, 20 )
                equipIcon:addChild( equipLevelBg )
                -- 装备icon等级
                local equipLevel = getCommonWhiteBMFontLabel( equipData.strengLevel )
                equipLevel:setAnchorPoint( cc.p( 0.5, 0.5 ) )
                equipLevel:setPosition( equipLevelBg:getContentSize().width*0.5, equipLevelBg:getContentSize().height*0.5 - 7 )
                equipLevelBg:addChild( equipLevel )
                -- 选中框
                -- local selected = ccui.Scale9Sprite:create( cc.rect( 10, 10, 2, 2 ), "res/image/illustration/selected.png" )
                local selected = ccui.Scale9Sprite:create("res/image/illustration/selected.png" )
                -- selected:setContentSize( equipIcon:getContentSize() )
                -- selected:setContentSize( cc.size(105,105) )
                getCompositeNodeWithNode( equipIcon, selected )
                equipIcon._selected = selected
                if self._selectedEquip[self._tabIndex][index*iconsPerCell + i] then
                    selected:setVisible( true )
                else
                    selected:setVisible( false )
                end
                equipIcon:setTouchEndedCallback( function()
                    if self._selectedEquip[self._tabIndex][index*iconsPerCell + i] then
                        self._selectedEquip[self._tabIndex][index*iconsPerCell + i] = false
                        selected:setVisible( false )
                        self._selectedNum[self._tabIndex] = self._selectedNum[self._tabIndex] - 1
                        self._canGetSmeltPoint = self._canGetSmeltPoint - self._smeltData[equipData.quality].getpoint
                        self._canGetSmeltPointNum:setString( self._canGetSmeltPoint )
                    else
                        self._selectedEquip[self._tabIndex][index*iconsPerCell + i] = true
                        selected:setVisible( true )
                        self._selectedNum[self._tabIndex] = self._selectedNum[self._tabIndex] + 1
                        self._canGetSmeltPoint = self._canGetSmeltPoint + self._smeltData[equipData.quality].getpoint
                        self._canGetSmeltPointNum:setString( self._canGetSmeltPoint )
                    end
                    -- 全选按钮
                    if #self._selectedEquip[self._tabIndex] > 0 and self._selectedNum[self._tabIndex] == #self._selectedEquip[self._tabIndex] then
                        self._selectAllBtn:setText( LANGUAGE_EQUIP_TEXT[15] )
                    else
                        self._selectAllBtn:setText( LANGUAGE_EQUIP_TEXT[14] )
                    end
                end)
            end
        end

        return cell
    end
    self._equipTableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    self._equipTableView.getCellNumbers=numberOfCellsInTableView
    self._equipTableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    self._equipTableView.getCellSize=cellSizeForTable
    self._equipTableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    tabBg:addChild( self._equipTableView )

    -- 全选按钮
    self._selectAllBtn = XTHD.createCommonButton({
        btnColor = "write",
        btnSize = cc.size(140, 46),
        isScrollView = false,
        text = LANGUAGE_EQUIP_TEXT[14],
        fontSize = 26,
        fontColor = cc.c3b( 255, 255, 255 ),
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( self._rightSize.width/2, 35 ),
        endCallback = function()
            if self._selectedNum[self._tabIndex] == #self._selectedEquip[self._tabIndex] then
                -- 已经全选了
                for i = 1, #self._equipData[self._tabIndex] do
                    -- progress = progress + 1
                    self._selectedEquip[self._tabIndex][i] = false
                end
                self._canGetSmeltPoint = self._canGetSmeltPoint - self._smeltData[self._tabIndex].getpoint*self._selectedNum[self._tabIndex]
                self._selectedNum[self._tabIndex] = 0
                self._selectAllBtn:setText( LANGUAGE_EQUIP_TEXT[14] )
                for i, v in ipairs( self._equipIcon ) do
                    if v and v._selected then
                        v._selected:setVisible( false )
                    end
                end
            else
                -- 没有全选
                for i = 1, #self._equipData[self._tabIndex] do
                    -- progress = progress + 1
                    self._selectedEquip[self._tabIndex][i] = true
                end
                self._canGetSmeltPoint = self._canGetSmeltPoint + self._smeltData[self._tabIndex].getpoint*( #self._selectedEquip[self._tabIndex] - self._selectedNum[self._tabIndex] )
                self._selectedNum[self._tabIndex] = #self._selectedEquip[self._tabIndex]
                self._selectAllBtn:setText( LANGUAGE_EQUIP_TEXT[15] )
                for i, v in ipairs( self._equipIcon ) do
                    if v and v._selected then
                        v._selected:setVisible( true )
                    end
                end
            end
            self._canGetSmeltPointNum:setString( self._canGetSmeltPoint )
        end,
    })
    self._selectAllBtn:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
    self._selectAllBtn:setScale(0.7)
    rightContainer:addChild( self._selectAllBtn ) 
end
-- 更改tab
function ZhuangBeiSmeltLayer:changeTab( index )
    self._tabsTable[self._tabIndex]:setSelected( false )
    self._tabsTable[self._tabIndex]:setEnable( true )
    self._tabsTable[self._tabIndex]:setLocalZOrder( 0 )
    self._tabsTable[index]:setSelected( true )
    self._tabsTable[index]:setEnable( false )
    self._tabsTable[index]:setLocalZOrder( 1 )
    self._tabIndex = index
    if #self._selectedEquip[self._tabIndex] > 0 and self._selectedNum[self._tabIndex] == #self._selectedEquip[self._tabIndex] then
        self._selectAllBtn:setText( LANGUAGE_EQUIP_TEXT[15] )
    else
        self._selectAllBtn:setText( LANGUAGE_EQUIP_TEXT[14] )
    end
end
-- 播放回收动画
function ZhuangBeiSmeltLayer:playSmeltAnimation()
    if self._selectedNum[self._tabIndex] > 0 then
        local curEquipNum = 0
        local topEquipPos = nil
        local animationSprite = {}
        local data = self._equipData[self._tabIndex]
        for i, v in ipairs( self._selectedEquip[self._tabIndex] ) do
            if v then
                -- 选中了
                topEquipPos = topEquipPos or math.ceil( i/5 ) - 1
                if self._equipIcon[i] and self._equipIcon[i]._selected then
                    -- 当前界面
                    curEquipNum = curEquipNum + 1
                    local _node = ItemNode:createWithParams({
                        itemId = data[i].itemid,
                        needSwallow = false,
                        _type_ = 4,
                        isShowDrop = false,
                        pos = self._equipIcon[i]:getParent():convertToWorldSpace( cc.p(self._equipIcon[i]:getPosition()) )--self._equipIcon[i]:getParent():convertToWorldSpace( cc.p( self._equipIcon[i]:getPosition() ) ),
                    })
                    self:addChild( _node )
                    self._equipIcon[i]:setVisible( false )
                    animationSprite[#animationSprite + 1] = _node
                end
            end
        end

        if curEquipNum == 0 then
            -- 当前界面没有选中的装备，移到最上面的选中装备
            self._equipTableView:scrollToCell( topEquipPos )
            self:playSmeltAnimation()
            return
        else
            self:runAction(
                cc.Sequence:create(
                    cc.CallFunc:create(
                        function()
                            -- 开盖
                            self._smelter:setAnimation(0,"atk",false)
                            local pointNode = self._smelter:getNodeForSlot( "xiaoguo_00017" )
                            pointNode:setPosition(0, 0)
                            if not pointNode then
                                return 
                            end
                            local pointWorldPos = pointNode:convertToWorldSpace(cc.p(-5, 40))
                            local _pos = self:convertToNodeSpace( pointWorldPos )
                            -- dump(_pos)
                            for i, v in ipairs( animationSprite ) do
                                local randomTime = (math.random()*0.5)*1.5 - math.random()*0.5
                                animationSprite[i]:runAction(
                                    cc.Sequence:create(
                                        cc.Spawn:create(
                                            cc.MoveTo:create(
                                                randomTime, _pos
                                            ),
                                            cc.ScaleTo:create(
                                                randomTime, 0.3
                                            ),
                                            cc.RotateBy:create(
                                                randomTime, 1440
                                            )
                                        ),
                                        cc.DelayTime:create(
                                            randomTime
                                        ),
                                        cc.CallFunc:create(
                                            function()
                                                animationSprite[i]:removeFromParent()
                                            end
                                        )
                                    )
                                )
                            end
                        end
                    ),
                    cc.DelayTime:create(
                        0.5*1.5-0.5
                    ),
                    cc.CallFunc:create(
                        function()
                            -- 跳动
                            self._smelter:setAnimation(0,"atk",true)
                        end
                    ),
                    cc.DelayTime:create(
                        0.8*1.5 - 0.8
                    ),
                    cc.CallFunc:create(
                        function()
                            self._smelter:registerSpineEventHandler(
                                function ( event )
                                    if event.eventData.name == "atk" then
                                        print(11111)
                                        self.swallowBg:removeFromParent()
                                        ShowRewardNode:create( self._rewardData )
                                        self._selectAllBtn:setText( LANGUAGE_EQUIP_TEXT[14] )
                                        self:refreshData()
                                    end
                                end
                            , sp.EventType.ANIMATION_EVENT)
                            -- 爆炸
                            self._smelter:setAnimation(0,"atk",false)
                        end
                    )
                )
            )
        end
    else
        -- 移到品级最低的有选中装备的tab
        for i, v in ipairs( self._selectedNum ) do
            if v > 0 then
                self:changeTab( i )
                self._equipIcon = {}
                self._equipTableView:reloadData()
                if #self._equipData[self._tabIndex] == 0 then
                    self._noEquipBg:setVisible( true )
                else
                    self._noEquipBg:setVisible( false )
                end
                self:playSmeltAnimation()
                break
            end
        end
    end
end
-- 计算回收得到的物品
function ZhuangBeiSmeltLayer:getSmeltReward()
    -- 回收装备的dbid，给后端
    local dbidData = {}
    -- 返回道具
    local backItem = {}
    -- 返回银两
    local backGold = 0
    -- 数据
    local strengthenData = gameData.getDataFromCSV( "EquipUpList" )
    local starupData = gameData.getDataFromCSV( "EquipAscendingStar" )

    -- 计算返回物品
    for i, v in ipairs( self._selectedEquip ) do
        for j, w in ipairs( v ) do
            if w then
                -- 选中了
                local equipData = self._equipData[i][j]
                local quality = equipData.quality
                dbidData[#dbidData + 1] = equipData.dbid
                -- 回收返回
                if self._smeltData[quality].num > 0 then
                    local itemId = self._smeltData[quality].getitem
                    -- 如果没有itemid，初始化为0
                    backItem[itemId] = backItem[itemId] or 0
                    -- 累加当前回收返回item数量
                    backItem[itemId] = backItem[itemId] + self._smeltData[quality].num
                end

                -- 强化返回
                for k = 1, equipData.strengLevel do
                    backGold = backGold + math.floor( strengthenData[k]["consume"..quality]*0.8 )
                    if strengthenData[k]["num"..quality] > 0 then
                        local itemId = strengthenData[k].need
                        backItem[itemId] = backItem[itemId] or 0
                        backItem[itemId] = backItem[itemId] + strengthenData[k]["num"..quality]
                    end
                end

                -- 进阶返回
                for k = 1, equipData.phaseLevel do
                    backGold = backGold + starupData[k].goldprice*XTHD.resource.advanceGoldCoefficient[quality]
                    if starupData[k]["num"..quality] then
                        local numTable = string.split( starupData[k]["num"..quality], "#" )
                        local csmTable = string.split( starupData[k]["consumables"..quality], "#" )
                        local i = 1
                        while numTable[i] do
                            backItem[csmTable[i]] = backItem[csmTable[i]] or 0
                            backItem[csmTable[i]] = backItem[csmTable[i]] + numTable[i]
                            i = i + 1
                        end
                    end
                end
            end
        end 
    end

    -- 奖励物品
    self._rewardData = {}
    -- 道具
    for k, v in pairs( backItem ) do
        self._rewardData[#self._rewardData + 1] = {
            rewardtype = 4,
            id = k,
            num = v,
        }
    end
    -- 回收点
    if self._canGetSmeltPoint > 0 then
        self._rewardData[#self._rewardData + 1] = {
            rewardtype = XTHD.resource.type.smeltPoint,
            num = self._canGetSmeltPoint,
        }
    end
    -- 银两
    if backGold > 0 then
        self._rewardData[#self._rewardData + 1] = {
            rewardtype = XTHD.resource.type.gold,
            num = backGold,
        }
    end

    -- dump( self._rewardData, "self._rewardData" )

    return dbidData
end
-- 刷新红点显示，tab有装备显示红点，没装备不显示红点
function ZhuangBeiSmeltLayer:refreshRedDot()
    for i, v in ipairs( self._equipData ) do
        if #v ~= 0 then
            self._redDotsTable[i]:setVisible( true )
        else
            self._redDotsTable[i]:setVisible( false )
        end
    end
    RedPointState[14].state = 0
    for j = 1,#self._redDotsTable do
        if self._redDotsTable[j]:isVisible() == true then
            RedPointState[14].state = 1
        end
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "hs"}})
end
-- 重新获取数据，刷新界面
function ZhuangBeiSmeltLayer:refreshData()
    if not self._exist then
        return
    end
    -- 获取所有装备的数据，按品级分类
    local itemData = DBTableItem.getData()
    local equipData = {}
    for i, v in pairs( itemData ) do 
        if v.position > 0 then 
            equipData[#equipData + 1] = v
        end 
    end
    -- dump( equipData, "equipData" )
    -- 初始化self._equipData
    self._equipData = {}
    self._selectedEquip = {}
    for i = 1, 6 do
        self._equipData[i] = {}
        self._selectedEquip[i] = {}
        self._selectedNum[i] = 0
    end
    -- 分类
    for i, v in ipairs( equipData ) do
        self._equipData[v.quality][#self._equipData[v.quality] + 1] = v
        self._selectedEquip[v.quality][#self._selectedEquip[v.quality] + 1] = false
    end
    -- dump( self._equipData, "self._equipData" )
    self._canGetSmeltPoint = 0
    
    self:refreshUI()
end
-- 刷新界面
function ZhuangBeiSmeltLayer:refreshUI()
    if not self._exist then
        return
    end
    -- 如果当前tab没有装备，移到品级最低的有装备的tab
    if #self._equipData[self._tabIndex] == 0 then
        for i, v in ipairs( self._equipData ) do
            if #v ~= 0 then
                self:changeTab( i )
                break
            end
        end
    end
    -- 刷新红点
    self:refreshRedDot()
    -- 刷新tableView
    self._equipIcon = {}
    self._equipTableView:reloadDataAndScrollToCurrentCell()
    -- 刷新没装备的背景显示
    if #self._equipData[self._tabIndex] == 0 then
        self._noEquipBg:setVisible( true )
    else
        self._noEquipBg:setVisible( false )
    end
    self._canGetSmeltPointNum:setString( 0 )
    self._ownSmeltPointNum:setString( gameUser.getSmeltPoint() )
end

function ZhuangBeiSmeltLayer:create( dbid, callFunc )
    return ZhuangBeiSmeltLayer.new( dbid, callFunc )
end

function ZhuangBeiSmeltLayer:onEnter( )
    self:addGuide()
end
-- 引导
function ZhuangBeiSmeltLayer:addGuide()
    -- -----------引导
    -- if gameUser.getInstancingId() == 39 then ---第组20引导 
    --     YinDaoMarg:getInstance():addGuide({index = 4,parent = self},19) 
    -- end 
    -- YinDaoMarg:getInstance():doNextGuide()
end

return ZhuangBeiSmeltLayer