--Create By hezhitao 2015年05月20日

--********************************声明********************************--
--[[       本界面是的实现逻辑和英雄兑换界面（QiXingTanchangeHeroSubLayer）的
           实现逻辑几乎一样，本界面的代码是参考QiXingTanchangeHeroSubLayer，
           所以本界面中的变量名没有修改，如需查看本界面的实现逻辑，请参
           考QiXingTanchangeHeroSubLayer.lua文件                      ]]
--********************************声明********************************--

local SELECTEC_BOX_TAY = 1000 

local QiXingTanchangeEquipSubLayer = class("QiXingTanchangeEquipSubLayer",function ()
    return XTHD.createBasePageLayer()
end)

function QiXingTanchangeEquipSubLayer:ctor()
    self._tableview = nil
    self._hero_soul_data = {}
    self._cell_arr  = {}
    self._left_bg = nil
    self._selected_item_position = 1
    self._first_select_flag = true   --第一个装备选中标志
    self._already_had_soul = {}      -- 玩家已经拥有的魂石
    self._all_hero = {}              --获取所有的英雄(包括没有的)
    self._soul_sum_label = nil       --拥有魂石数量
    self._soul_sum = nil       --拥有魂石数量
    self._ex_soul_sum_label = nil    --可兑换魂石次数

    self._left_data = nil       --保存右边显示的数据

    -- 背景
    local bottomBg = XTHD.createSprite( "res/image/common/layer_bottomBg.png" )
    bottomBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    bottomBg:setPosition( self:getContentSize().width * 0.5, ( self:getContentSize().height - self.topBarHeight ) * 0.5 )
    self:addChild( bottomBg )

	local title = "res/image/public/duihuan_title.png"
	XTHD.createNodeDecoration(bottomBg,title)

    self:readDBData() --初始化数据

     --透明层bg放在除去顶部topbar的高度之后的中间，为了适配各种机型
    local size = cc.Director:getInstance():getWinSize()
    local layer_height = size.height - self.topBarHeight
    local bg = XTHD.createSprite()
    bg:setContentSize(self:getContentSize().width,layer_height)
    bg:setPosition(size.width/2, layer_height/2)
    self:addChild(bg)

    self._left_bg = XTHD.createSprite()
    self._left_bg:setContentSize(bottomBg:getContentSize().width-510,453)
    self._left_bg:setAnchorPoint(0,0.5)
    self._left_bg:setPosition(0,bottomBg:getContentSize().height/2)
    bottomBg:addChild(self._left_bg)

    local right_bg = XTHD.createSprite()
    right_bg:setContentSize(510,473)
    right_bg:setAnchorPoint(0,0.5)
    right_bg:setPosition(self._left_bg:getContentSize().width,bottomBg:getContentSize().height/2)
    bottomBg:addChild(right_bg)

    self:initRightUI(right_bg)
    self._left_data = self._hero_soul_data[1]
    self:initLeftUI(self._left_bg,self._left_data)

    XTHD.addEventListener({name = "UPDATE_EQUIP_PIECE_NUM" ,callback = function()

        self:initLeftUI(self._left_bg, self._left_data)

         local piece_num = 0
        if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}) then
            piece_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count or 0
        end
        self._soul_sum:setString(piece_num)
        --能够兑换的总次数
        local total_exchange_num = gameData.getDataFromCSV("VipInfo",{id = 13})["vip"..gameUser.getVip()] or 0
        self._ex_soul_sum:setString(gameUser.getRecruitExchangeEquipSum())

        XTHD.dispatchEvent({name = "UPDATE_PIECE_NUM" });
    end})
end

--初始化右边UI
function QiXingTanchangeEquipSubLayer:initRightUI( right_bg )
    -- 过渡
    local splitSprite = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitY.png" )
    splitSprite:setContentSize(2,right_bg:getContentSize().height-40)
    splitSprite:setAnchorPoint( cc.p( 0, 0.5 ) )
    splitSprite:setPosition( 0, right_bg:getContentSize().height*0.5 )
    splitSprite:setFlippedX( true )
    right_bg:addChild( splitSprite )

    -- 请选择要兑换的英雄
    local title = XTHD.createLabel({
        text = LANGUAGE_EXCHANGE_TEXT[1],
        fontSize = 18,
        ttf = "res/fonts/def.ttf",
        color = cc.c3b(55,54,112),
    })
    title:setPosition( right_bg:getContentSize().width*0.5, right_bg:getContentSize().height - 15 )
    right_bg:addChild( title )
    local _leftPattern = cc.Sprite:create("res/image/common/titlepattern_left.png")
    _leftPattern:setAnchorPoint(cc.p(1,0.5))
    _leftPattern:setPosition(cc.p(title:getPositionX()-90,title:getPositionY()))
    right_bg:addChild(_leftPattern)
    local _rightPattern = cc.Sprite:create("res/image/common/titlepattern_right.png")
    _rightPattern:setAnchorPoint(cc.p(0,0.5))
    _rightPattern:setPosition(cc.p(title:getPositionX()+90,title:getPositionY()))
    right_bg:addChild(_rightPattern)

    -- tableview背景
    local tableViewBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
    tableViewBg:setContentSize(470,440)
    tableViewBg:setAnchorPoint( cc.p( 0.5, 0 ) )
    tableViewBg:setPosition( right_bg:getContentSize().width*0.5, 5 )
    right_bg:addChild( tableViewBg )

    self._tableview =  CCTableView:create(cc.size(470,390))
    self._tableview:setPosition(0, 40)
    self._tableview:setBounceable(true)
    self._tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._tableview:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableViewBg:addChild(self._tableview)

    function numberOfCellsInTableView( tableView )
        return (math.ceil(#self._hero_soul_data/5))
    end

    function cellSizeForTable( tableView,idx )
        return 450,100   --此处为高跟宽
    end

    function tableCellAtIndex( tableView,idx )

        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
            cell:setContentSize(450,90)
        else 
            cell:removeAllChildren()
        end
        self:initCellData(cell,idx)
        return cell

    end

    self._tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)

    self._tableview:reloadData()

    -- 分隔线
    -- local splitTableViewLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
    -- splitTableViewLine:setContentSize( tableViewBg:getContentSize().width - 6, 2 )
    -- splitTableViewLine:setAnchorPoint( cc.p( 0, 1 ) )
    -- splitTableViewLine:setPosition( 3, 40 )
    -- tableViewBg:addChild( splitTableViewLine )

    local piece_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}) then
        piece_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count or 0
    end

    local soul_sum_label =  XTHDLabel:createWithParams({
        text = LANGUAGE_TIP_OWNED_TJSTONE..":",--------拥有天星石:",
        fontSize = 18,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    soul_sum_label:setAnchorPoint(0,0.5)
    soul_sum_label:setPosition(20,20)
    tableViewBg:addChild(soul_sum_label)
    local soul_icon = cc.Sprite:create("res/image/exchange/exchange_soul_icon.png");
    soul_icon:setAnchorPoint( cc.p( 0, 0.5 ) )
    soul_icon:setPosition(soul_sum_label:getPositionX()+soul_sum_label:getContentSize().width+5,soul_sum_label:getPositionY())
    tableViewBg:addChild(soul_icon)
    self._soul_sum = XTHD.createLabel({
        text = piece_num,
        fontSize = 18,
        color = cc.c3b(0,0,0),
        ttf = "res/fonts/def.ttf",
    })
    self._soul_sum:setAnchorPoint(0,0.5)
    self._soul_sum:setPosition(soul_icon:getPositionX()+soul_icon:getContentSize().width+5,soul_sum_label:getPositionY())
    tableViewBg:addChild(self._soul_sum)

    local num = (gameUser.getRecruitExchangeEquipSum() ~= nil and gameUser.getRecruitExchangeEquipSum()) or 0
    local ex_soul_sum_label = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS133..":",-----今日剩余兑换数量:",
        fontSize = 18,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    ex_soul_sum_label:setAnchorPoint(0,0.5)
    ex_soul_sum_label:setPosition(245,soul_sum_label:getPositionY())
    tableViewBg:addChild(ex_soul_sum_label)

    --能够兑换的总次数
    local total_exchange_num = gameData.getDataFromCSV("VipInfo",{id = 13})["vip"..gameUser.getVip()] or 0

    self._ex_soul_sum = XTHD.createLabel({
        text = num,
        fontSize = 18,
        color = cc.c3b(0,0,0),
        ttf = "res/fonts/def.ttf",
    })
    self._ex_soul_sum:setAnchorPoint(0,0.5)
    self._ex_soul_sum:setPosition(ex_soul_sum_label:getPositionX()+ex_soul_sum_label:getContentSize().width+10,ex_soul_sum_label:getPositionY())
    tableViewBg:addChild(self._ex_soul_sum)

end

--渐隐动作
function QiXingTanchangeEquipSubLayer:fadeAction( left_bg,data )
    local bg_1 = left_bg:getChildByName("bg_1")
    bg_1:runAction(cc.Sequence:create( cc.FadeOut:create(0.2),cc.CallFunc:create(function (  )
        left_bg:removeAllChildren()
        self:initLeftUI(left_bg,data)
    end) ))

    local bg_2 = left_bg:getChildByName("bg_2")
    bg_2:runAction(cc.Sequence:create( cc.FadeOut:create(0.2) ))
end

--初始化左边UI
function QiXingTanchangeEquipSubLayer:initLeftUI( left_bg,data )
    left_bg:removeAllChildren()
    local middlePos = left_bg:getContentSize().width*0.5

    local bg_1 = XTHD.createSprite()
    bg_1:setContentSize(left_bg:getContentSize().width,105)
    bg_1:setAnchorPoint(0,1)
    bg_1:setPosition(10,left_bg:getContentSize().height)
    bg_1:setName("bg_1")
    left_bg:addChild(bg_1)
    -- bg_1:setOpacity(0)

     -- 天星石介绍
    local desc_btn = XTHDPushButton:createWithParams({
        normalFile = "res/image/common/btn/tip_up.png",
        selectedFile = "res/image/common/btn/tip_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
    })
    desc_btn:setPosition(middlePos+170,bg_1:getContentSize().height-30)
    bg_1:addChild(desc_btn)
    desc_btn:setScale( 0.8 )
    desc_btn:setTouchEndedCallback(function (  )
        self:addChild(requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=12}))
    end)

     local item = ItemNode:createWithParams({
            itemId = data.itemid,
            dbId = data.dbid or nil,
            quality = data.quality,
            _type_ = 4,
            touchShowTip = false,
            })
    item:setScale(0.8)
    item:setPosition(middlePos-125,bg_1:getContentSize().height-55)
    bg_1:addChild(item)

    --一次兑换能够获得的数量
    local item_name_num = 1
    if gameData.getDataFromCSV("QxtExchange",{id = data._id}).exchangeNum then
       item_name_num = gameData.getDataFromCSV("QxtExchange",{id = data._id}).exchangeNum
    end
    local item_name = XTHDLabel:createWithParams({
        text = data.name.." x"..item_name_num,
        fontSize = 18,
        -- color = XTHD.resource.getQualityItemColor(data.quality)
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    item_name:setPosition(item:getPositionX()+item:getContentSize().width*0.5+15,bg_1:getContentSize().height-25)
    item_name:setAnchorPoint(0,0.5)
    -- item_name:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1,-1))
    bg_1:addChild(item_name)

    --从本地动态数据库中获取拥有魂石的数量

    local temp_data= gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = data.itemid})

    local equip_num = 0
    if tonumber(data.itemid) > 100000 then
         
        if temp_data and #temp_data == 0 and next(temp_data) ~= nil then
            equip_num = 1
        elseif #temp_data > 1 then
            equip_num = #temp_data
        end
    else
        if temp_data.count then
            equip_num = temp_data.count
        end
    end

    local have_num_label_1 = XTHDLabel:createWithParams({
        text = LANGUAGE_VERBS.owned,----"拥有" ,
        fontSize = 18,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    have_num_label_1:setPosition(item_name:getPositionX(),bg_1:getContentSize().height-55)
    have_num_label_1:setAnchorPoint(0,0.5)
    bg_1:addChild(have_num_label_1)

    local have_num = XTHD.createLabel({
        text = equip_num,
        fontSize = 20,
        color = cc.c3b(0,0,0),
        ttf = "res/fonts/def.ttf",
    })
    have_num:setPosition(have_num_label_1:getPositionX()+have_num_label_1:getContentSize().width+5,have_num_label_1:getPositionY())
    have_num:setAnchorPoint(0,0.5)
    bg_1:addChild(have_num)

    local have_num_label_2 = XTHDLabel:createWithParams({
        text = LANGUAGE_OTHER_TXTJIAN,------"件" ,
        fontSize = 18,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    have_num_label_2:setPosition(have_num:getPositionX()+have_num:getContentSize().width+5,have_num_label_1:getPositionY())
    have_num_label_2:setAnchorPoint(0,0.5)
    bg_1:addChild(have_num_label_2)

    if tonumber(data.itemid) > 100000 then
        local limit_condition = XTHDLabel:createWithParams({
            text = LANGUAGE_KEY_HERO_TEXT.itemHeroTypeTextXc,-----"限制类型:" ,
            fontSize = 18,
            color = cc.c3b(55,54,112),
            ttf = "res/fonts/def.ttf",
            })
        limit_condition:setPosition(item_name:getPositionX(),bg_1:getContentSize().height-80)
        limit_condition:setAnchorPoint(0,0.5)
        bg_1:addChild(limit_condition)

        local _tb = string.split(data.herotype,"#")
        if #_tb == 3 then
            local heroType = XTHDLabel:createWithParams({
                text = LANGUAGE_KEY_ALLHERO,-----"全英雄",
                fontSize = 18,
                color = cc.c3b(55,54,112),
                ttf = "res/fonts/def.ttf",
            })
            heroType:setAnchorPoint(0,0.5)
            heroType:setPosition(limit_condition:getPositionX()+limit_condition:getContentSize().width+10,limit_condition:getPositionY())
            bg_1:addChild(heroType)
        else
            for i=1,#_tb do
                local heroType = cc.Sprite:create("res/image/plugin/hero/hero_type_".._tb[i]..".png")
                heroType:setScale(0.8)
                heroType:setPosition(item_name:getPositionX()+60+(i-1)*30,limit_condition:getPositionY())
                bg_1:addChild(heroType)
            end
        end
    end

    -- 分界线
    local splitLine1 = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
    splitLine1:setContentSize( bg_1:getContentSize().width, 2 )
    splitLine1:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    splitLine1:setPosition( bg_1:getContentSize().width*0.5, 0 )
    bg_1:addChild( splitLine1 )



    local bg_2 = XTHD.createSprite()
    bg_2:setContentSize(left_bg:getContentSize().width,155)
    bg_2:setAnchorPoint(0,1)
    bg_2:setPosition(0,left_bg:getContentSize().height-bg_1:getContentSize().height)
    bg_2:setName("bg_2")
    left_bg:addChild(bg_2)
    -- bg_2:setOpacity(0)

    if tonumber(data.itemid) > 100000 then
         -- 显示装备属性信息
        local idx = 0
        for i=1,#XTHD.resource.AttributesNum do
            --属性值
            local attr_value = data[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]]
            local attr_name = XTHD.resource.getAttributes(XTHD.resource.AttributesNum[i])
            if tonumber(attr_value) ~= 0 then
                local _tb = string.split(attr_value,"#")
                local min_value = _tb[1]
                local max_value = _tb[2]

                --判断是否添加 “%”
                if tonumber(XTHD.resource.AttributesNum[i]) > 300 and tonumber(XTHD.resource.AttributesNum[i]) < 315 then
                    min_value = min_value.."%"
                    max_value = max_value.."%"
                end

                --要显示的属性     
                local attr_txt = attr_name.." + ("..min_value.."-"..max_value..")" 
                local attr_label = XTHDLabel:createWithParams({
                    text = attr_txt,
                    fontSize = 18,
                    color = cc.c3b(55,54,112),
                    ttf = "res/fonts/def.ttf",
                    })
                attr_label:setPosition(middlePos-160,139-idx*31)
                attr_label:setAnchorPoint(0,0.5)
                bg_2:addChild(attr_label)
                
                idx = idx + 1
            end

        end
    else
        local desc = XTHDLabel:createWithParams({
            text = data.effect,
            fontSize = 18,
            color = cc.c3b(55,54,112),
            ttf = "res/fonts/def.ttf",
            })
        
        desc:setAnchorPoint(0,1)
        desc:setDimensions(320,150)
        bg_2:addChild(desc)

        --一排放16个汉字，每个汉字占3个字节
        local len = math.ceil(string.len(data.effect)/48)
        -- bg_2:setContentSize(318,len*30)

        desc:setPosition(middlePos-160,bg_2:getContentSize().height-10)
    end
    -- 分界线
    local splitLine2 = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
    splitLine2:setContentSize( bg_2:getContentSize().width, 2 )
    splitLine2:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    splitLine2:setPosition( bg_2:getContentSize().width*0.5, -20 )
    bg_2:addChild( splitLine2 )

   

    -- 容器
    local exchange_num_bg = XTHD.createSprite()
    exchange_num_bg:setAnchorPoint( cc.p( 0, 0 ) )
    exchange_num_bg:setContentSize(left_bg:getContentSize().width,left_bg:getContentSize().height-bg_1:getContentSize().height-bg_2:getContentSize().height)
    exchange_num_bg:setPosition(0, 0)
    left_bg:addChild(exchange_num_bg)
    -- 标题
    local exchange_txtBg = XTHD.createSprite( "res/image/plugin/hero/heroTitle_bg.png" )
    exchange_txtBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    exchange_txtBg:setPosition( exchange_num_bg:getContentSize().width*0.5, exchange_num_bg:getContentSize().height - 25 )
    -- exchange_num_bg:addChild( exchange_txtBg )
    local exchange_txt = XTHDLabel:createWithParams({
        text = LANGUAGE_EXCHANGE_TEXT[2],--------"天星石兑换",
        fontSize = 18,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    getCompositeNodeWithNode(exchange_txtBg, exchange_txt)

    local exchangeTip = XTHD.createLabel({
        text = LANGUAGE_EXCHANGE_TEXT[3],
        fontSize = 16,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        anchor = cc.p(0.5,0.5),
        pos = cc.p(exchange_num_bg:getContentSize().width*0.5,exchange_num_bg:getContentSize().height-60),
    })
    -- exchange_num_bg:addChild( exchangeTip )

    -- local bar_bg = XTHD.createSprite("res/image/common/common_progressBg_1.png")
    -- bar_bg:setPosition(cc.p(exchange_num_bg:getContentSize().width*0.5,exchange_num_bg:getContentSize().height-90))
    -- bar_bg:setAnchorPoint(0.5,0.5)
    -- exchange_num_bg:addChild(bar_bg)

    -- local progress_bar = cc.ProgressTimer:create(cc.Sprite:create("res/image/common/common_progress_1.png"))
    -- progress_bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    -- progress_bar:setMidpoint(cc.p(0, 0))
    -- progress_bar:setBarChangeRate(cc.p(1, 0))
    -- progress_bar:setPosition(cc.p(bar_bg:getContentSize().width / 2, bar_bg:getContentSize().height / 2))
    -- progress_bar:setPercentage(0)
    -- bar_bg:addChild(progress_bar)

    -- local tmp_current_equip_piece = 0
    -- if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count then
    --     tmp_current_equip_piece = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count
    -- end

    -- progress_bar:runAction(cc.ProgressTo:create(0.3,tmp_current_equip_piece/14*100))

    -- local progress_txt = XTHD.createLabel({
    --     text = tmp_current_equip_piece.."/14",
    --     fontSize = 18,
    -- })
    -- progress_txt:setPosition(bar_bg:getContentSize().width/2,bar_bg:getContentSize().height/2)
    -- bar_bg:addChild(progress_txt)


    local need_piece_num = 0
    if gameData.getDataFromCSV("QxtExchange",{id = data._id}).needNum then
       need_piece_num = gameData.getDataFromCSV("QxtExchange",{id = data._id}).needNum
    end
    local need_soul_txt = XTHDLabel:createWithParams({
        text = LANGUAGE_TIP_COST_TJSTONE..":",------------消耗天星石:",
        fontSize = 16,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    need_soul_txt:setPosition(exchange_num_bg:getContentSize().width/2-30,80)
    exchange_num_bg:addChild(need_soul_txt)

    local soul_icon = cc.Sprite:create("res/image/exchange/exchange_soul_icon.png")
    soul_icon:setPosition(need_soul_txt:getPositionX()+need_soul_txt:getContentSize().width/2 + 20,need_soul_txt:getPositionY())
    exchange_num_bg:addChild(soul_icon)

    local need_soul = XTHD.createLabel({
        text = need_piece_num,
        fontSize = 20,
        color = XTHD.resource.color.gray_desc,
    })
    need_soul:setPosition(soul_icon:getPositionX()+soul_icon:getContentSize().width/2 + 25,need_soul_txt:getPositionY())
    exchange_num_bg:addChild(need_soul)


    local piece_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}) then
        piece_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count or 0
    end
    if tonumber(need_piece_num) > tonumber(piece_num) then
        need_soul:setColor(cc.c3b(255,0,0))
    end

    --兑换按钮
    -- local disableNode = ccui.Scale9Sprite:create(cc.rect(26,25,1,1),"res/image/common/btn/btn_black_up.png")
    local disableNode = ccui.Scale9Sprite:create("res/image/common/btn/btn_blue_disable.png")
    disableNode:setContentSize(143,45)
    local exchange_btn = XTHD.createCommonButton({
        btnSize = cc.size(143,45),
        isScrollView = false,
        disableNode = disableNode,
        pos = cc.p(exchange_num_bg:getContentSize().width*0.5, 25),
        endCallback = function()
            if tonumber(need_piece_num) > tonumber(piece_num) then
                XTHDTOAST(LANGUAGE_TIPS_WORDS60)-----"天星石不足，无法兑换")
            elseif tonumber(gameUser.getRecruitExchangeEquipSum()) < 1 then
                XTHDTOAST(LANGUAGE_TIPS_WORDS10)-------"今天的兑换次数用完了，不能继续兑换")
            else
                local config_id = gameData.getDataFromCSV("QxtExchange",{id = data._id}).id
                self:doHttpRequest(config_id,item_name_num)
            end
        end
    })
    exchange_btn:setScale(0.8)
    exchange_num_bg:addChild(exchange_btn)

    local exchange_font = XTHDLabel:createWithParams({
        text = LANGUAGE_BTN_KEY.duihuan,
        size = 24,
        color = cc.c3b(255,255,255),
        ttf = "res/fonts/def.ttf",
        pos = cc.p(exchange_btn:getContentSize().width/2,exchange_btn:getContentSize().height/2),
    })
    exchange_font:enableOutline(cc.c4b(150,79,39,255),2)
    exchange_btn:addChild(exchange_font)

    if tonumber(gameUser.getLevel()) >= tonumber(gameData.getDataFromCSV("QxtExchange",{id = data._id}).needLevel) then
        
    else
        exchange_btn:setEnable(false)

        local need_level_tip = XTHDLabel:createWithParams({
            text = LANGUAGE_FORMAT_TIPS12(gameData.getDataFromCSV("QxtExchange",{id = data._id}).needLevel),-----"达到"..gameData.getDataFromCSV("QxtExchange",{id = data._id}).needLevel.."级可以兑换",
            fontSize = 20,
            color = cc.c3b(255,255,255),
            ttf = "res/fonts/def.ttf",
        })
        exchange_font:enableOutline(cc.c4b(150,79,39,255),2)
        need_level_tip:setPosition(exchange_btn:getContentSize().width/2,exchange_btn:getContentSize().height/2)
        -- need_level_tip:enableShadow(cc.c4b(0,0,0,255),cc.size(2,-2))
        exchange_btn:addChild(need_level_tip)

        exchange_font:setVisible(false)
    end

    

    function setAllChildOpacity( parent )
        parent:setCascadeOpacityEnabled(true)
        local all_child = parent:getChildren()
        for i=1,#all_child do
            setAllChildOpacity(all_child[i])
        end
    end

    bg_1:setCascadeOpacityEnabled(true)
    bg_2:setCascadeOpacityEnabled(true)
    -- setAllChildOpacity(bg_1)
    
    bg_1:setOpacity(0)
    bg_2:setOpacity(0)

    bg_1:runAction(cc.FadeIn:create(0.2))
    bg_2:runAction(cc.FadeIn:create(0.2))

end


--获取动态数据库中的数据
function QiXingTanchangeEquipSubLayer:readDBData(  )
    --获取table的大小
    -- function getTableNum( table )  
    --     local count = 0
    --     for k,v in pairs(table) do
    --         count = count + 1
    --     end
    --     return  tonumber(count)
    -- end

    -- local not_have_table = {}  --
    -- local temp_hero_tab = {}


    --从兑换表中拿到需要兑换的英雄（主要是拿到equipid）
    local ex_hero_soul = gameData.getDataFromCSV("QxtExchange",{_type = 1})


    --把需求等级存放到临时数组中
    local need_level_tab = {}
    for i=1,#ex_hero_soul do
        need_level_tab[i] = ex_hero_soul[i].needLevel
    end


    --冒泡排序，从小到大
    local tmp_need_level_value = need_level_tab[1]
    for i=1,#need_level_tab do
        for j=1,#need_level_tab-i do
            if need_level_tab[j] > need_level_tab[j+1] then
                tmp_need_level_value = need_level_tab[j]
                need_level_tab[j] = need_level_tab[j+1]
                need_level_tab[j+1] = tmp_need_level_value
            end
        end
    end

    --找到要显示的等级
    local show_level = gameUser.getLevel()
    local tmp_flag = true
    for i=1,#need_level_tab do
        if show_level < need_level_tab[i] and tmp_flag then
            show_level = need_level_tab[i]
            tmp_flag = false
        end
    end

    --从英雄表中拿到兑换英雄的所有数据
    for i=1,#ex_hero_soul do
        if ex_hero_soul[i].needLevel <= show_level then
            local hero_soul = {}
            if tonumber(ex_hero_soul[i].equipid) > 100000 then
                hero_soul = gameData.getDataFromCSV("EquipInfoList",{itemid = ex_hero_soul[i].equipid})
                hero_soul._id = ex_hero_soul[i].id
            else
                hero_soul = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = ex_hero_soul[i].equipid})
                hero_soul._id = ex_hero_soul[i].id
            end
            local item_quality = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = ex_hero_soul[i].equipid}).rank or 1
            hero_soul.quality = item_quality

            -- --实现深拷贝
            -- local tmp_tab = {}
            -- for k,v in pairs(hero_soul) do
            --     tmp_tab[k] = v
            -- end
            self._hero_soul_data[#self._hero_soul_data+1] = clone(hero_soul)
        end
        
    end

    -- --比对动态库中的数据，把已经拥有的英雄加入到self._hero_soul_data的前部
    -- for i=1,#temp_hero_tab do
    --     local tmp_tab = gameData.getDataFromDynamicDB(gameUser.getUserId(),"hero_id",{heroid = temp_hero_tab[i]["resourceid"]})
    --     if getTableNum(tmp_tab) ~= 0 then
    --         temp_hero_tab[i].is_had = true
    --         self._hero_soul_data[#self._hero_soul_data+1] = temp_hero_tab[i]
    --     else
    --         not_have_table[#not_have_table+1] = temp_hero_tab[i]
    --     end
    -- end

    -- --把没有的英雄加入到self._hero_soul_data的后部
    -- for i=1,#not_have_table do
        
    -- end
end


function QiXingTanchangeEquipSubLayer:initCellData(cell,idx)

    local temp_idx = idx*5
    local TAG = 1
    for i=tonumber(temp_idx)+1,tonumber(temp_idx)+5 do
        if i <= #self._hero_soul_data then
            local item_data = self._hero_soul_data[i]
            -- dbid,count,
            -- local item_quality = gameData.getDataFromCSV("item",{itemid = item_data.itemid}).rank or 1
            -- item_data.quality = item_quality
            local item = ItemNode:createWithParams({
                itemId = item_data.itemid,
                dbId = item_data.dbid or nil,
                quality = item_data.quality,
                -- count = item_data.count or nil,
                _type_ = 4,
                clickScale = 0.95,
                isShowDrop = false,
                -- touchShowTip = false,
                })
            item:setScale(0.8)
            item:setPosition(((i-1)%5)*90+55,cell:getContentSize().height/2)
            cell:addChild(item)

            local selected_box = ccui.Scale9Sprite:create("res/image/illustration/selected.png")
            --selected_box:setContentSize(item:getContentSize().width+10,item:getContentSize().height+10)
            selected_box:setScale(0.8)
            selected_box:setPosition(item:getPositionX(),item:getPositionY() - 2)
            selected_box:setTag(SELECTEC_BOX_TAY+TAG)
            cell:addChild(selected_box)

            TAG = TAG + 1

            item:setTouchBeganCallback(function (  )
                item:setScale(0.9)
            end)

            item:setTouchEndedCallback(function (  )
                item:setScale(1.0)
                self._selected_item_position = i
                self:setSelectItemStatus(selected_box)
                --初始化右边UI及数据
                self._left_data = item_data
                self:fadeAction(self._left_bg,item_data)
            end)
            selected_box:setVisible(false)

            --玩家没有的魂石，加遮罩

            if self._first_select_flag then
                self._selected_item_position = 1
                selected_box:setVisible(true)
                self._first_select_flag = false   --第一个装备选中的标志

            end
            --当cell滑动到显示区域外边的时候，cell上的所有child都会被删除，所以在这里需要记住选中item的位置，便于再次初始化cell的时候，item还处于被选中的状态
            if self._selected_item_position == i then   
                selected_box:setVisible(true)
            end

        end
    end

    --第一次添加cell
    if #self._cell_arr == 0 then
        self._cell_arr[#self._cell_arr+1] = cell
    else  --如果self._cell_arr不为空，则需要判断里边的cell是否已经添加过了，如果没有添加过，则加入数组self._cell_arr中，否则不加入
        local flag = true
        for i=1,#self._cell_arr do
            local temp_cell = self._cell_arr[i]
            if temp_cell == cell then
                flag = false
            end
        end
        if flag then
            self._cell_arr[#self._cell_arr+1] = cell
        else
        end
    end

end

function QiXingTanchangeEquipSubLayer:doHttpRequest( configid,num )
    --recruitType = 1 表示英雄， recruitType = 2 表示道具
     ClientHttp:requestAsyncInGameWithParams({
        modules = "recruitExchange?",
        params = {configId=configid,count=1},
        successCallback = function(data)
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end

        --获取奖励成功
        if  tonumber(data.result) == 0 then
            gameUser.setRecruitExchangeEquipSum(data.exchangeItemSum)
            self:getHeroReward(data,num)
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_QIXINGTAN_NUMLABLE})
        else
            XTHDTOAST(data.msg)
        end
          
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function QiXingTanchangeEquipSubLayer:getHeroReward( data,num )

    --由于后端返回的只是刷新背包的数据信息，没有包含当前兑换成功的魂石的数量，所以需要把数据处理一下
    function dealData( )
        local tmp_tab = {}
        tmp_tab.itemId = data["items"][2].itemId
        tmp_tab.name = data["items"][2].name
        tmp_tab.count = num
        tmp_tab.quality = data["items"][2].quality

        data["items"][#data["items"]+1] = tmp_tab

    end

    dealData()

    -- local showReward = requires("src/fsgl/layer/QiXingTan/ExShowResultPoP.lua"):create(data,2)
    local showReward = requires("src/fsgl/layer/QiXingTan/QiXingTanShowResultLayer.lua"):create(data,2)
    self:addChild(showReward)
end

--重置item的选中状态
function QiXingTanchangeEquipSubLayer:setSelectItemStatus( item )
    for i=1,#self._cell_arr do
        local temp_cell = self._cell_arr[i]
        for i=1,5 do
            if temp_cell:getChildByTag(SELECTEC_BOX_TAY+i) then
                temp_cell:getChildByTag(SELECTEC_BOX_TAY+i):setVisible(false)
            end
        end
    end
    item:setVisible(true)
    
end


function QiXingTanchangeEquipSubLayer:create()
	return QiXingTanchangeEquipSubLayer.new()
end

function QiXingTanchangeEquipSubLayer:onCleanup()
    XTHD.removeEventListener("UPDATE_EQUIP_PIECE_NUM")
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
end

return QiXingTanchangeEquipSubLayer
