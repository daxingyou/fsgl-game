--Create By hezhitao 2015年05月20日

-- 英雄碎片兑换界面

local SELECTEC_BOX_TAY = 1000 
local fontColor = cc.c3b(53,25,26)
local QiXingTanchangeHeroSubLayer = class("QiXingTanchangeHeroSubLayer",function ()
	return XTHD.createBasePageLayer()
end)

function QiXingTanchangeHeroSubLayer:ctor()
	self:initUI()
end

function QiXingTanchangeHeroSubLayer:initUI()
	self.stoneCount = 0
    self._tableview = nil
    self._hero_soul_data = {}
    self._cell_arr  = {}
    self._left_bg = nil
    self._selected_item_position = 1
    self._first_select_flag = true   --第一个装备选中标志
    self._already_had_soul = {}      -- 玩家已经拥有的魂石
    self._all_hero = {}              --获取所有的英雄(包括没有的)
    self._soul_sum = nil       --拥有魂石数量
    self._ex_soul_sum = nil    --可兑换魂石次数

    self._left_data = nil    --保存左边边显示的数据

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
    self:initLeftUI(self._left_bg,self._hero_soul_data[1])
    
   

    self._left_data = self._hero_soul_data[1]
     --注册一个监听事件，回调方法为callback
    XTHD.addEventListenerWithNode({name = "REFRESH_HERO_SUB_DATA" ,node = self,callback = function(event)
      local soul_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}).count or 0 
      self._soul_sum:setString(soul_num)
      --能够兑换的总次数
      -- local total_exchange_num = gameData.getDataFromCSV("VipInfo",{id = 12})["vip"..gameUser.getVip()] or 0
      -- self._ex_soul_sum:setString(gameUser.getRecruitExchangeSum().."/"..total_exchange_num)
      self._ex_soul_sum:setString(gameUser.getRecruitExchangeSum())
      self:initLeftUI(self._left_bg,self._left_data)

    XTHD.dispatchEvent({name = "UPDATE_PIECE_NUM" });
		self:getChildByName("TopBarLayer1"):refreshData()
	end})
    
    
end

--初始化右边UI
function QiXingTanchangeHeroSubLayer:initRightUI( right_bg )
    -- 过渡
    local splitSprite = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitY.png" )
    splitSprite:setContentSize(2,right_bg:getContentSize().height-40)
    splitSprite:setAnchorPoint( cc.p( 0, 0.5 ) )
    splitSprite:setPosition( 0, right_bg:getContentSize().height*0.5 )
    splitSprite:setFlippedX( true )
    right_bg:addChild( splitSprite )

    -- 请选择要兑换的英雄
    local title = XTHD.createLabel({
        text = LANGUAGE_EXCHANGE_TEXT[4],
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
    --local change = (screenRadio-1024/615)
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
        return 450,100  --此处为宽跟高
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
    -- splitTableViewLine:setContentSize( tableViewBg:getContentSize().width-6, 2 )
    -- splitTableViewLine:setAnchorPoint( cc.p( 0, 1 ) )
    -- splitTableViewLine:setPosition( 3, 40 )
    -- tableViewBg:addChild( splitTableViewLine )

    -- 拥有的召唤石数量
    local piece_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}) then
        piece_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}).count or 0
    end
	self.stoneCount = piece_num

    local soul_sum_label =  XTHDLabel:createWithParams({
        text = LANGUAGE_TIP_OWNED_TLSTONE,------拥有召唤石:",
        fontSize = 18,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    soul_sum_label:setAnchorPoint(0,0.5)
    soul_sum_label:setPosition(20,20)
    tableViewBg:addChild(soul_sum_label)
    local dimond_icon = cc.Sprite:create("res/image/exchange/exchange_diamond.png");
    dimond_icon:setAnchorPoint( cc.p( 0, 0.5 ) )
    dimond_icon:setPosition(soul_sum_label:getPositionX()+soul_sum_label:getContentSize().width+5,soul_sum_label:getPositionY())
    tableViewBg:addChild(dimond_icon)
    self._soul_sum = XTHD.createLabel({
        text = piece_num,
        fontSize = 18,
        color = cc.c3b( 0, 0, 0 ),
        ttf = "res/fonts/def.ttf"
    })
    self._soul_sum:setAnchorPoint(0,0.5)
    self._soul_sum:setPosition(dimond_icon:getPositionX()+dimond_icon:getContentSize().width+5,soul_sum_label:getPositionY())
    tableViewBg:addChild(self._soul_sum)

    local num = (gameUser.getRecruitExchangeSum() ~= nil and gameUser.getRecruitExchangeSum()) or 0
    local ex_soul_sum_label = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS133..":",--------今日剩余兑换数量:",
        fontSize = 18,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    ex_soul_sum_label:setAnchorPoint(0,0.5)
    ex_soul_sum_label:setPosition(245,soul_sum_label:getPositionY())
    tableViewBg:addChild(ex_soul_sum_label)

    --能够兑换的总次数
    -- local total_exchange_num = gameData.getDataFromCSV("VipInfo",{id = 12})["vip"..gameUser.getVip()] or 0

    -- self._ex_soul_sum = getCommonWhiteBMFontLabel(num.."/"..total_exchange_num)
    self._ex_soul_sum = XTHD.createLabel({
        text = num,
        fontSize = 18,
        color = cc.c3b( 0, 0, 0 ),
        ttf = "res/fonts/def.ttf"
    })
    self._ex_soul_sum:setAnchorPoint(0,0.5)
    self._ex_soul_sum:setPosition(ex_soul_sum_label:getPositionX()+ex_soul_sum_label:getContentSize().width+10,ex_soul_sum_label:getPositionY())
    tableViewBg:addChild(self._ex_soul_sum)

end

--渐隐动作
function QiXingTanchangeHeroSubLayer:fadeAction( left_bg,data )
    local bg_1 = left_bg:getChildByName("bg_1")
    bg_1:runAction(cc.Sequence:create( cc.FadeOut:create(0.2),cc.CallFunc:create(function (  )
        left_bg:removeAllChildren()
        self:initLeftUI(left_bg,data)
    end) ))

    -- bg_1:getChildByName("item"):runAction(cc.FadeTo:create(0.2,100))

    local up_star_bg = left_bg:getChildByName("up_star_bg")
    up_star_bg:runAction(cc.Sequence:create( cc.FadeOut:create(0.2) ))
end

--初始化左边UI
function QiXingTanchangeHeroSubLayer:initLeftUI( left_bg,data )

    left_bg:removeAllChildren()
    local middlePos = left_bg:getContentSize().width*0.5

    local bg_1 = XTHD.createSprite()
    bg_1:setContentSize(left_bg:getContentSize().width,105)
    bg_1:setAnchorPoint(0,1)
    bg_1:setPosition(0,left_bg:getContentSize().height)
    bg_1:setName("bg_1")
    left_bg:addChild(bg_1)

    --召唤石介绍
    local desc_btn = XTHDPushButton:createWithParams({
        normalFile = "res/image/common/btn/tip_up.png",
        selectedFile = "res/image/common/btn/tip_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        })
    desc_btn:setPosition(middlePos+180,bg_1:getContentSize().height-30)
    bg_1:addChild(desc_btn)
    desc_btn:setScale( 0.8 )
    desc_btn:setTouchEndedCallback(function (  )
        self:addChild(requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=11}))
    end)

     local item = ItemNode:createWithParams({
            itemId = data.itemid,
            -- dbId = data.dbid or nil,
            quality = data.rank,
            _type_ = 4,
            touchShowTip = false,
            })
    item:setScale(0.8)
    item:setPosition(middlePos-125,bg_1:getContentSize().height-55)
    bg_1:addChild(item)

    local item_name = XTHDLabel:createWithParams({
        text = data.name,
        fontSize = 18,
        -- color = XTHD.resource.getQualityItemColor(data.rank)
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    item_name:setPosition(item:getPositionX()+item:getContentSize().width*0.5+15,bg_1:getContentSize().height-25)
    item_name:setAnchorPoint(0,0.5)
    -- item_name:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1,-1))
    bg_1:addChild(item_name)

    --从本地动态数据库中获取拥有魂石的数量
    local temp_data= gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = data.itemid})
    local have_num_label_1 = XTHDLabel:createWithParams({
        text = LANGUAGE_VERBS.owned,-------"拥有" ,
        fontSize = 18,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    have_num_label_1:setPosition(item_name:getPositionX(),bg_1:getContentSize().height-55)
    have_num_label_1:setAnchorPoint(0,0.5)
    bg_1:addChild(have_num_label_1)

    local have_num = XTHD.createLabel({
        text = (temp_data.count ~= nil and temp_data.count ) or 0,
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

    -- 分界线
    local splitLine1 = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
    splitLine1:setContentSize( bg_1:getContentSize().width, 2 )
    splitLine1:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    splitLine1:setPosition( bg_1:getContentSize().width*0.5, 0 )
    bg_1:addChild( splitLine1 )




    --获取英雄星级，如果满星，则不显示升星操作
    local heroInfo = gameData.getDataFromDynamicDB(gameUser.getUserId(),"hero",{heroid = data.resourceid})
	local star = heroInfo.star or 1
    --用于玩家没有英雄时，显示的信息
    local no_hero_bg = XTHD.createSprite()
    no_hero_bg:setAnchorPoint( cc.p( 0, 1 ) )
    no_hero_bg:setContentSize(left_bg:getContentSize().width,155)
    no_hero_bg:setPosition(0, left_bg:getContentSize().height-bg_1:getContentSize().height)
    left_bg:addChild(no_hero_bg)

    local no_hero_tip_bg = XTHD.createSprite()
    no_hero_tip_bg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    no_hero_tip_bg:setContentSize(no_hero_bg:getContentSize())
    no_hero_tip_bg:setPosition(no_hero_bg:getContentSize().width/2, no_hero_bg:getContentSize().height/2)
    no_hero_bg:addChild(no_hero_tip_bg)

    local no_hero_tip = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS64,------ "尚未拥有该英雄，无法兑换",
        fontSize = 18,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    no_hero_tip:setPosition(no_hero_tip_bg:getContentSize().width/2,no_hero_tip_bg:getContentSize().height/2)
    no_hero_tip_bg:addChild(no_hero_tip)

    --如果有这个英雄，并且满星
	local maxStar = XTHD.getHeroMaxStar(data.resourceid)
    if data.is_had == true and tonumber(star) == maxStar then
        no_hero_tip:setString(LANGUAGE_TIPS_WORDS65)--------"该英雄已满星")
    end

    --用于存放升星信息，当玩家没有英雄是，这个layout隐藏
    local up_star_bg = XTHD.createSprite()
    up_star_bg:setAnchorPoint( cc.p( 0, 1 ) )
    up_star_bg:setContentSize(no_hero_bg:getContentSize())
    up_star_bg:setPosition(no_hero_bg:getPosition())
    up_star_bg:setName("up_star_bg")
    left_bg:addChild(up_star_bg)

    -- 升星进度
    local up_star_txtBg = XTHD.createSprite( "res/image/plugin/hero/heroTitle_bg.png" )
    up_star_txtBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    up_star_txtBg:setPosition( up_star_bg:getContentSize().width*0.5, up_star_bg:getContentSize().height - 25 )
    up_star_bg:addChild( up_star_txtBg )
    local up_star_txt = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS66,--------"升星进度",
        fontSize = 16,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    getCompositeNodeWithNode( up_star_txtBg, up_star_txt )

    -- 
    local temp_name = gameData.getDataFromCSV("GeneralInfoList",{heroid = data.resourceid})
    local hero_name = XTHDLabel:createWithParams({
        text = (temp_name.name ~= nil and temp_name.name) or "",
        fontSize = 22,
        color = cc.c3b(105,77,56),
        })
    hero_name:setPosition(middlePos-100,75)
    up_star_bg:addChild(hero_name)
    
	local moonC = math.floor(star/6)
	local starC = star%6
	print("当前英雄的star:"..star.."   maxStar:"..maxStar.."   moonC:"..moonC.."   starC:"..starC)
    for i=1,math.max(tonumber(star),5) do
        local img_file = ""
        if star ~= nil and i <= tonumber(star) then
			if moonC > 0 then
				img_file = "res/image/common/moon_icon.png"	
			end
			if starC > 0 and moonC < 1 then
				img_file = "res/image/common/star_icon.png"
				starC = starC - 1
			end
			moonC = moonC - 1
        else
            img_file = "res/image/common/star_dark.png"
        end
        if img_file ~= "" then
            local star_icon = XTHD.createSprite(img_file)
			if i <= 30 then
				star_icon:setPosition(middlePos-40+i*30,hero_name:getPositionY())
			else
				star_icon:setPosition(middlePos-40+(i-5)*30,hero_name:getPositionY() - 25)
			end
        
			up_star_bg:addChild(star_icon)
        end

    end

    local bar_bg = XTHD.createSprite("res/image/common/common_progressBg_1.png")
    bar_bg:setPosition(cc.p(up_star_bg:getContentSize().width/2,30))
    up_star_bg:addChild(bar_bg)

    local progress_bar = cc.ProgressTimer:create(cc.Sprite:create("res/image/common/common_progress_1.png"))
    progress_bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress_bar:setMidpoint(cc.p(0, 0))
    progress_bar:setBarChangeRate(cc.p(1, 0))
    progress_bar:setPosition(cc.p(bar_bg:getContentSize().width / 2, bar_bg:getContentSize().height / 2))
    progress_bar:setPercentage(0)
    bar_bg:addChild(progress_bar)

    --从数据库中获取拥有召唤石的数量
    local had_num = (temp_data.count ~= nil and temp_data.count ) or 0

    --获取需要兑换的总数量
    local total_num_tab = gameData.getDataFromCSV("GeneralGrowthNeeds",{id = data.resourceid})
    local total_num = 1
    local temp_idx = 0
    if star then
        temp_idx = star
    end
    if total_num_tab and total_num_tab["starcount"..(tonumber(temp_idx)+1)] then
        total_num = tonumber(total_num_tab["starcount"..(tonumber(temp_idx)+1)])
    end

    local progress_txt = XTHD.createLabel({
        text = had_num.."/"..total_num,
        fontSize = 18,
    })
    progress_txt:setPosition(bar_bg:getContentSize().width/2,bar_bg:getContentSize().height/2)
    bar_bg:addChild(progress_txt)

	--如果该英雄为5星以上则隐藏相应进度条展示
	if star < 5 then
		bar_bg:setVisible(false)
		progress_bar:setVisible(false)
		progress_txt:setVisible(false)
	else
		bar_bg:setVisible(false)
		progress_bar:setVisible(false)
		progress_txt:setVisible(false)
	end

    --如果已经满星了
    if tonumber(total_num) == 1 then
        progress_txt:setString(had_num)
    end

    progress_bar:runAction(cc.ProgressTo:create(0.3,had_num/total_num*100))

    --英雄满星的时候，显示满星信息
    local up_star_bg_1 = XTHD.createSprite()
    up_star_bg_1:setAnchorPoint( cc.p( 0, 1 ) )
    up_star_bg_1:setContentSize(no_hero_bg:getContentSize())
    up_star_bg_1:setPosition(no_hero_bg:getPosition())
    up_star_bg_1:setName("up_star_bg_1")
    left_bg:addChild(up_star_bg_1)
    

    local full_star_label = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS67,---------"五星英雄可以开始修炼魔攻\n使用英雄碎片和翡翠为英雄魔攻升级!",
        fontSize = 18,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    full_star_label:setPosition(up_star_bg_1:getContentSize().width/2,up_star_bg_1:getContentSize().height/2)
    up_star_bg_1:addChild(full_star_label)

    
    if tonumber(star) >= maxStar then
        up_star_bg:setVisible(false)
        up_star_bg_1:setVisible(true)
    else
        up_star_bg:setVisible(true)
        up_star_bg_1:setVisible(false)
    end
    -- 分界线
    local splitLine2 = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
    splitLine2:setContentSize( up_star_bg:getContentSize().width, 2 )
    splitLine2:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    splitLine2:setPosition( up_star_bg:getContentSize().width*0.5, 0 )
    up_star_bg:addChild( splitLine2 )

    -- 分界线
    local splitLine3 = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
    splitLine3:setContentSize( up_star_bg:getContentSize().width, 2 )
    splitLine3:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    splitLine3:setPosition( up_star_bg:getContentSize().width*0.5, 0 )
    up_star_bg_1:addChild( splitLine3 )

    --用于存放升星信息，当玩家没有英雄是，这个layout隐藏
    local exchange_num_bg = XTHD.createSprite()
    exchange_num_bg:setAnchorPoint( cc.p( 0, 0 ) )
    exchange_num_bg:setContentSize(left_bg:getContentSize().width,left_bg:getContentSize().height-bg_1:getContentSize().height-up_star_bg:getContentSize().height)
    exchange_num_bg:setPosition(0, 0)
    left_bg:addChild(exchange_num_bg)

    --用于提示玩家前往升星
--    local exchange_num_bg_1 = XTHD.createSprite()
--    exchange_num_bg_1:setAnchorPoint( cc.p( 0, 0 ) )
--    exchange_num_bg_1:setContentSize(exchange_num_bg:getContentSize())
--    exchange_num_bg_1:setPosition(0, 0)
--    left_bg:addChild(exchange_num_bg_1)
--    local tip_label = XTHDLabel:createWithParams({
--        text = LANGUAGE_TIPS_WORDS68,---------"已经拥有足够的碎片\n点击下方按钮进入升星界面",
--        fontSize = 20,
--        color = fontColor,
--        ttf = "res/fonts/def.ttf",
--        })
--    tip_label:setPosition(exchange_num_bg_1:getContentSize().width/2,exchange_num_bg_1:getContentSize().height-75)
--    exchange_num_bg_1:addChild(tip_label)
--    exchange_num_bg_1:setVisible(false)

    local up_star_txtBg2 = XTHD.createSprite( "res/image/plugin/hero/heroTitle_bg.png" )
    up_star_txtBg2:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    up_star_txtBg2:setPosition( exchange_num_bg:getContentSize().width*0.5, exchange_num_bg:getContentSize().height + 20)
    exchange_num_bg:addChild( up_star_txtBg2 )
    local up_star_txt2 = XTHDLabel:createWithParams({
        text = LANGUAGE_EXCHANGE_TEXT[6],--------"兑换数量",
        fontSize = 16,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    getCompositeNodeWithNode(up_star_txtBg2, up_star_txt2)

    --背景框图片
    local sub_ex_num_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png")
    sub_ex_num_bg:setContentSize(162,36)
    
    sub_ex_num_bg:setPosition(175,150)
    sub_ex_num_bg:setAnchorPoint(0,0.5)
    exchange_num_bg:addChild(sub_ex_num_bg)

    --当前拥有的碎片
    local current_soul_piece = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}).count or 0

    --兑换一个装备需要的碎片
    local need_piece = gameData.getDataFromCSV("QxtExchange",{equipid = data.itemid}).needNum or 1

    --能够兑换装备的数量，如果小于30，则显示能兑换的最大值，如果大于30，则显示30
    local ex_num = (math.floor(current_soul_piece/need_piece) == 0 and 1) or math.floor(current_soul_piece/need_piece)

    local tmp_tab = {ex_num,gameUser.getRecruitExchangeSum(),tonumber(total_num-had_num)}

    --拥有召唤石的数量
    local piece_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}) then
        piece_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}).count or 0
    end
	self.stoneCount = piece_num

     --从小到大排序
    local tmp_value = tmp_tab[1]
    for i=1,#tmp_tab do
        for j=1,#tmp_tab-i do
            if tmp_tab[j] > tmp_tab[j+1] then
                tmp_value = tmp_tab[j]
                tmp_tab[j] = tmp_tab[j+1]
                tmp_tab[j+1] = tmp_value
            end
        end
    end

    if tonumber(tmp_tab[1]) >= 30 then
        ex_num = 30
    else
        if tonumber(tmp_tab[1]) > 0 then
            ex_num = tonumber(tmp_tab[1])
        else
            if tonumber(piece_num) < 30 then
                ex_num = piece_num
            else
                ex_num = 30
            end
            
        end
    end


    --当前需要花费的碎片数量
    local total_need_piece = ex_num*need_piece

    --显示兑换的数量
    -- local ex_num_txt = XTHD.createLabel({
    --     text = ex_num,
    --     fontSize = 24,
    --     color = cc.c3b(0,0,0),
    -- })
    -- ex_num_txt:setPosition(sub_ex_num_bg:getContentSize().width/2,sub_ex_num_bg:getContentSize().height/2)
    -- sub_ex_num_bg:addChild(ex_num_txt)
    local editbox_account = nil;
    local need_soul_num = nil;
    --编辑框代理
    function editboxHandler( event,sender )

        if event == "began" then
            sender:setText("")
        elseif event == "ended" then
        elseif event == "return" then
        elseif event == "changed" then
            ex_num = tonumber(sender:getText())
	           if type(ex_num) ~= "number" then
                XTHDTOAST("您输入的格式有问题")
                ex_num = 1
                return
            end
            total_need_piece = ex_num*need_piece
            if ex_num > tonumber(piece_num) then
                XTHDTOAST(LANGUAGE_TIPS_WORDS69)
            end

            if tonumber(star) < maxStar then
                -- 大于兑换碎片总次数
                -- 如果兑换数量大于实际数量 
                -- 大于拥有的召唤石 并且也大于 碎片
                if tonumber(ex_num) > (tonumber(total_num) - tonumber(had_num)) or tonumber(ex_num) >= tonumber(piece_num) or tonumber(ex_num) >= tonumber(gameUser.getRecruitExchangeSum()) then
                   -- ex_num = tonumber(total_num) - tonumber(had_num);
                end
            else
                --如果兑换次数小于用于的召唤石的数量的时候，则显示最大的兑换次数
                if tonumber(piece_num) <= tonumber(gameUser.getRecruitExchangeSum()) then
                    --ex_num = tonumber(piece_num)
                else
                    --ex_num = tonumber(gameUser.getRecruitExchangeSum())
                end
            end
			
            editbox_account:setText(ex_num)
            local heroShow =  gameData.getDataFromCSV( "GeneralShow",{heroid = heroInfo.heroid})
            -- if heroShow.rank == 4 then
            --     need_soul_num:setString(ex_num*2)
            -- else
            --     need_soul_num:setString(ex_num)
            -- end
            need_soul_num:setString(ex_num*need_piece)
        end
    end
    --编辑框
    editbox_account = ccui.EditBox:create(cc.size(sub_ex_num_bg:getContentSize().width,sub_ex_num_bg:getContentSize().height), ccui.Scale9Sprite:create(),nil,nil)
    editbox_account:setFontColor(cc.c3b(0,0,0))
    editbox_account:setText(ex_num)
    editbox_account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    editbox_account:setAnchorPoint(0.5,0.5)
    editbox_account:setMaxLength(20)
	--editbox_account:setHACenter()
    editbox_account:setPosition(sub_ex_num_bg:getContentSize().width/2+editbox_account:getContentSize().width/4 - 40, sub_ex_num_bg:getContentSize().height/2)
    -- editbox_account:setPlaceholderFontColor(cc.c3b(0,0,0))
    editbox_account:setFontName("Helvetica")
    editbox_account:setPlaceholderFontName("Helvetica")
    editbox_account:setFontSize(20)
	editbox_account:setTextHorizontalAlignment(1)--输入框里面的文字对齐方式，0 是 向左对齐，1 是居中 ，2 是向右
	--setHorizontalAlignment
    -- editbox_account:setPlaceholderFontSize(24)
    editbox_account:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    sub_ex_num_bg:addChild(editbox_account)
    editbox_account:registerScriptEditBoxHandler(function ( event,sender)
        editboxHandler(event,sender)
    end)

     --减少兑换次数按钮
    local reduce_btn = XTHDPushButton:createWithParams({
        normalFile = "res/image/common/btn/btn_reduceDot_normal.png",
        selectedFile = "res/image/common/btn/btn_reduceDot_selected.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        needEnableWhenOut = true,
        touchSize = cc.size(80,80)
        })
    reduce_btn:setScale( 0.8 )
    reduce_btn:setPosition(sub_ex_num_bg:getPositionX() - 20, sub_ex_num_bg:getPositionY())
    exchange_num_bg:addChild(reduce_btn)


    --增加兑换次数按钮
    local plus_btn = XTHDPushButton:createWithParams({
        normalFile = "res/image/common/btn/btn_addDot_normal.png",
        selectedFile = "res/image/common/btn/btn_addDot_selected.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        needEnableWhenOut = true,
        touchSize = cc.size(80,80)
        })
    plus_btn:setScale( 0.8 )
    plus_btn:setAnchorPoint(0,0.5)
    plus_btn:setPosition(sub_ex_num_bg:getPositionX()+sub_ex_num_bg:getContentSize().width+5,sub_ex_num_bg:getPositionY())
    exchange_num_bg:addChild(plus_btn)

    

    --显示要花费的碎片的数量
    local need_soul_txt = XTHDLabel:createWithParams({
        text = LANGUAGE_TIP_COST_TLSTONE,------消耗召唤石:",
        fontSize = 30,
        color = cc.c3b(55,54,112),
        ttf = "res/fonts/def.ttf",
        })
    need_soul_txt:setPosition(middlePos-30,90)
    exchange_num_bg:addChild(need_soul_txt)

    local dimond_icon = cc.Sprite:create("res/image/exchange/exchange_diamond.png");
    dimond_icon:setPosition(need_soul_txt:getPositionX()+need_soul_txt:getContentSize().width/2+20,need_soul_txt:getPositionY())
    exchange_num_bg:addChild(dimond_icon)

    need_soul_num = XTHD.createLabel({
        text = total_need_piece,
        fontSize = 26,
        color = XTHD.resource.color.gray_desc,
    })
	need_soul_num:setAnchorPoint(0,0.5)
    need_soul_num:setPosition(dimond_icon:getPositionX()+dimond_icon:getContentSize().width/2+5,dimond_icon:getPositionY())
    exchange_num_bg:addChild(need_soul_num)

    --增加到最大兑换数量
    -- local max_btn = XTHD.createCommonButton({
    --     btnColor = "gray",
    --     btnSize = cc.size(80,38),
    --     musicFile = XTHD.resource.music.effect_btn_common,
    --     needEnableWhenOut = true,
    --     touchSize = cc.size(80,80),
    --     text = "MAX",
    --     fontSize = 20,
    --     isEnableShadow = false,
    --     })
    local max_btn = XTHD.createMaxBtn(cc.size(80,38))
    max_btn:setAnchorPoint(0,0.5)
    max_btn:setPosition(plus_btn:getPositionX()+plus_btn:getContentSize().width+5,plus_btn:getPositionY())
    exchange_num_bg:addChild(max_btn)

    max_btn:setTouchEndedCallback(function ()
        if tonumber(star) <= maxStar then
			if star < 5 then
				--如果兑换次数小于用于的召唤石的数量的时候，则显示最大的兑换次数
				if tonumber(total_num) - tonumber(had_num) <= tonumber(gameUser.getRecruitExchangeSum()) and tonumber(total_num) - tonumber(had_num) <= tonumber(piece_num) then
					if tonumber(total_num) - tonumber(had_num) <= 0 then
						ex_num = math.min(gameUser.getRecruitExchangeSum(),math.floor(self.stoneCount/need_piece))
					else
						ex_num = tonumber(total_num) - tonumber(had_num)
					end
				else
					-- ex_num = tonumber(gameUser.getRecruitExchangeSum())
					ex_num = math.min(tonumber(piece_num),tonumber(gameUser.getRecruitExchangeSum()))
				end
			else
				ex_num = math.min(gameUser.getRecruitExchangeSum(),math.floor(self.stoneCount/need_piece))
			end		
        else
            --如果兑换次数小于用于的召唤石的数量的时候，则显示最大的兑换次数
            if tonumber(piece_num) <= tonumber(gameUser.getRecruitExchangeSum()) then
                ex_num = tonumber(piece_num)
            else
                ex_num = tonumber(gameUser.getRecruitExchangeSum())
            end
        end
        -- ex_num_txt:setString( ex_num )
        -- need_soul_num:setString( ex_num )
		local heroShow =  gameData.getDataFromCSV( "GeneralShow",{heroid = heroInfo.heroid})
		-- if heroShow.rank == 4 then
		-- --	ex_num = ex_num*2
		-- 	need_soul_num:setString(ex_num*2)
		-- else
		-- 	need_soul_num:setString(ex_num)
		-- end
        need_soul_num:setString(ex_num*need_piece)
        editbox_account:setText(ex_num)
    end)

    -- local disableNode = ccui.Scale9Sprite:create(cc.rect(26,25,1,1),"res/image/common/btn/btn_black_up.png")
    local disableNode = ccui.Scale9Sprite:create("res/image/common/btn/btn_blue_disable.png")
    disableNode:setContentSize(143,45)
    local exchange_btn = XTHD.createCommonButton({
        btnSize = cc.size(143,45),
        isScrollView = false,
        disableNode = disableNode,
        pos = cc.p(left_bg:getContentSize().width*0.5, 25),
        endCallback = function()
            local config_id = gameData.getDataFromCSV("QxtExchange",{equipid = data.itemid}).id
            if tonumber(ex_num) > tonumber(piece_num) then
                XTHDTOAST(LANGUAGE_TIPS_WORDS69)------"召唤石不足，无法兑换")
            elseif tonumber(ex_num) > tonumber(gameUser.getRecruitExchangeSum()) then
               XTHDTOAST(LANGUAGE_TIPS_WORDS10)-------"今天的兑换次数用完了，不能继续兑换")
            else
                if tonumber(ex_num) > 0 then
                    print("ex_num:"..ex_num)
                    self:doHttpRequest(config_id,ex_num)
                else
                    XTHDTOAST(LANGUAGE_TIPS_WORDS10)-------"今日兑换次数已用完或召唤石不足")
                end
            end
        end
    })
    exchange_btn:setScale(0.8)
    left_bg:addChild(exchange_btn)

    local exchange_font = XTHDLabel:createWithParams({
        text = LANGUAGE_BTN_KEY.sureExchange,
        size = 24,
        color = cc.c3b(255,255,255),
        pos = cc.p(exchange_btn:getContentSize().width/2,exchange_btn:getContentSize().height/2),
        ttf = "res/fonts/def.ttf"
    })
    exchange_font:enableOutline(cc.c4b(150,79,39,255),2)
    exchange_btn:addChild(exchange_font)


    -- if data.is_had == true and tonumber(star) < 5 then
    if data.is_had == true then
        no_hero_bg:setVisible(false)
        exchange_btn:setVisible(true)
    else
        exchange_num_bg:setVisible(false)
        up_star_bg:setVisible(false)
        -- exchange_btn:setVisible(false)
        exchange_font:setVisible(false)
        exchange_btn:setEnable(false)

        --遍历所有的children,设置颜色
        -- function setAllChildColor( pushbutton,color )
        --     local child = pushbutton:getChildren()
        --     if child ~= nil and type(child) == "table" and table.getn(child) > 0 then
        --         for k,v in pairs(child) do
        --             if v ~= nil then
        --                 v:setColor(color)
        --                 setAllChildColor(v,color)
        --             end
        --         end
        --     end
        -- end
        -- setAllChildColor(exchange_btn,cc.c3b(118,118,118))

        local can_not_exchange = XTHDLabel:createWithParams({
            text = LANGUAGE_BTN_KEY.bunengduihuan,
            size = 20,
            color = cc.c3b(255,255,255),
            pos = cc.p(exchange_btn:getContentSize().width/2,exchange_btn:getContentSize().height/2),
            ttf = "res/fonts/def.ttf"
    })
        can_not_exchange:enableOutline(cc.c4b(150,79,39,255),2)
        exchange_btn:addChild(can_not_exchange)
        exchange_btn:setVisible(false)
        -- can_not_exchange:setColor(cc.c3b(118,118,118))
        -- can_not_exchange:enableShadow(cc.c4b(0,0,0,255),cc.size(2,-2))

    end 

    -- 如果可以升星，则跳转到升星界面
--    print(had_num,total_num,tonumber(star),tonumber(-140),"laldal")
--    if data.is_had == true and had_num >= total_num and tonumber(star) < maxStar then
--        exchange_num_bg:setVisible(false)
--        exchange_num_bg_1:setVisible(true)
--        exchange_font:setVisible(false)

--        -- local go_up_star = XTHDLabel:createWithParams({
--        --     text = "前往升星",
--        --     fontSize = 26,
--        --     })

--        local go_up_star = XTHDLabel:createWithParams({
--            text = LANGUAGE_BTN_KEY.qianwangshegnxing,
--            size = 24,
--            color = cc.c3b(255,255,255),
--            pos = cc.p(exchange_btn:getContentSize().width/2,exchange_btn:getContentSize().height/2),
--            ttf = "res/fonts/def.ttf"
--        })
--        go_up_star:enableOutline(cc.c4b(150,79,39,255),2)
--        exchange_btn:addChild(go_up_star)
--        -- go_up_star:enableShadow(cc.c4b(0,0,0,255),cc.size(2,-2))

--        --添加前往升星特效
--        -- local  effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/mf_15.json", "res/spine/effect/exchange_effect/mf_15.atlas",1 );
--        -- effect:setPosition(exchange_btn:getContentSize().width/2,exchange_btn:getContentSize().height/2)
--        -- exchange_btn:addChild(effect)
--        -- effect:setAnimation(0,"animation",true)
--        -- effect:setTimeScale(0.5)    --setTimeScale参数，1表示正常
--        -- effect:setScaleX(0.7)
--        -- effect:setScaleY(0.82)

--        exchange_btn:setTouchEndedCallback(function (  )
--            -- LayerManager.removeLayout(self)
--            local _id = data["resourceid"]
--            if SCENEEXIST.HEROINFOLAYER then
--                local nowScene = self:getScene()
--                nowScene:removeAllChildren()
--                LayerManager.popModule()
--                if nowScene then
--                    nowScene:cleanup()
--                    nowScene = nil
--                end
--            end
--            replaceLayer({id = 34,heroid = _id})
--        end)
--    end


    function setAllChildOpacity( parent )
        parent:setCascadeOpacityEnabled(true)
        local all_child = parent:getChildren()
        for i=1,#all_child do
            setAllChildOpacity(all_child[i])
        end
    end

    -- bg_1:setCascadeOpacityEnabled(true)
    -- up_star_bg:setCascadeOpacityEnabled(true)
    setAllChildOpacity(bg_1)
    setAllChildOpacity(up_star_bg)
    
    bg_1:setOpacity(0)
    up_star_bg:setOpacity(0)

    bg_1:runAction(cc.FadeIn:create(0.2))
    up_star_bg:runAction(cc.FadeIn:create(0.2))


    local is_click = true
    local numbers = 0
    --[[减少按钮点击和长按操作]]
    function quickReduceExNum(  )
        if ex_num > 1 then
            ex_num = ex_num -1
            numbers = numbers + 1
        else
            reduce_btn:stopAllActions()
            numbers = 0
        end
        -- ex_num_txt:setString(ex_num)
        editbox_account:setText(ex_num)
        need_soul_num:setString(ex_num*need_piece)

        --如果减少次数持续10次，则加快减少速度
        if numbers > 10 and numbers < 30 then
            reduce_btn:stopAllActions()
            schedule(reduce_btn,quickReduceExNum,0.05,100)
        elseif numbers > 30 then
            reduce_btn:stopAllActions()
            schedule(reduce_btn,quickReduceExNum,0.01,100)
        end
    end

    function pressLongTimeCallback_reduce(  )
        is_click = false
        schedule(reduce_btn,quickReduceExNum,0.1,100)
    end
    reduce_btn:setTouchBeganCallback(function (  )
        -- 延时多少秒操作，此处是延时1秒后回调pressLongTimeCallback_reduce
        performWithDelay(reduce_btn,pressLongTimeCallback_reduce,0.3)
        
    end)

    reduce_btn:setTouchEndedCallback(function (  )

        if is_click then
            if ex_num > 1 then
                ex_num = ex_num -1
            end
            -- ex_num_txt:setString(ex_num)
            editbox_account:setText(ex_num)
            -- need_soul_txt:setString("消耗召唤石:         "..ex_num*need_piece)
            need_soul_num:setString(ex_num*need_piece)
        end
        is_click = true
        reduce_btn:stopAllActions()
        numbers = 0
    end)

    --[[增加按钮点击和长按操作]]
    local current_ex_times = gameUser.getRecruitExchangeSum()
    function quickAddExNum(  )
        if star >= 5 then
			local compareNum = math.min(gameUser.getRecruitExchangeSum(),math.floor(self.stoneCount/need_piece))
			if ex_num > compareNum then
				if gameUser.getRecruitExchangeSum() > math.floor(self.stoneCount/need_piece) then
					XTHDTOAST("召唤石不足！")
					plus_btn:stopAllActions()
				else
					XTHDTOAST("兑换次数不足，请提升vip等级获取更多的兑换次数！")
					plus_btn:stopAllActions()
				end
				return
			end
		end
--        if tonumber(ex_num*need_piece+had_num) >= tonumber(total_num) and tonumber(star) < maxStar then
--            XTHDTOAST(LANGUAGE_TIPS_WORDS70)------"已达到升星需求数量，不用继续兑换")
--            plus_btn:stopAllActions()
--            return
--        end

        if ex_num*need_piece > current_soul_piece-need_piece then
            XTHDTOAST(LANGUAGE_TIPS_WORDS71)------"召唤石不足")
            plus_btn:stopAllActions()
            numbers = 0
        else
            if ex_num*need_piece < tonumber(current_ex_times) then
                ex_num = ex_num + 1
                numbers = numbers + 1
             -- else
             --    XTHDTOAST("兑换次数不足")
            end
        end
		plus_btn:stopAllActions()
        -- ex_num_txt:setString(ex_num)
        editbox_account:setText(ex_num)
        -- need_soul_txt:setString("消耗召唤石:         "..ex_num*need_piece)
        need_soul_num:setString(ex_num*need_piece)

         --如果增加次数持续10次，则加快减少速度
        if numbers > 10 and numbers < 30 then
            plus_btn:stopAllActions()
            schedule(plus_btn,quickAddExNum,0.05,100)
        elseif numbers > 30 then
            plus_btn:stopAllActions()
            schedule(plus_btn,quickAddExNum,0.01,100)
        end
    end

    function pressLongTimeCallback_add(  )
        is_click = false
        schedule(plus_btn,quickAddExNum,0.1,100)
    end

    plus_btn:setTouchBeganCallback(function (  )
         performWithDelay(plus_btn,pressLongTimeCallback_add,0.3)
    end)

    plus_btn:setTouchEndedCallback(function (  )

        if is_click then
			if star >= 5 then
				local compareNum = math.min(gameUser.getRecruitExchangeSum(),math.floor(self.stoneCount/need_piece))
				if ex_num > compareNum then
					if gameUser.getRecruitExchangeSum() > math.floor(self.stoneCount/need_piece) then
						XTHDTOAST("召唤石不足！")
						plus_btn:stopAllActions()
					else
						XTHDTOAST("兑换次数不足，请提升vip等级获取更多的兑换次数！")
						plus_btn:stopAllActions()
					end
					return
				end
			end
--            if tonumber(ex_num*need_piece+had_num) >= tonumber(total_num) and tonumber(star) < maxStar then
--                XTHDTOAST(LANGUAGE_TIPS_WORDS70)------"已达到升星需求数量，不用继续兑换")
--                plus_btn:stopAllActions()
--                return
--            end

            if ex_num*need_piece > current_soul_piece-need_piece then
                XTHDTOAST(LANGUAGE_TIPS_WORDS71)-----"召唤石不足")
				plus_btn:stopAllActions()
            else
                if ex_num + 1 <= tonumber(current_ex_times) then
                    ex_num = ex_num + 1
                else
                    XTHDTOAST(LANGUAGE_TIPS_WORDS10)------"兑换次数不足")
					plus_btn:stopAllActions()
                end
            end

            -- ex_num_txt:setString(ex_num)
            editbox_account:setText(ex_num)
            -- need_soul_txt:setString("消耗召唤石:         "..ex_num*need_piece)
            need_soul_num:setString(ex_num*need_piece)
        end
        is_click = true
        plus_btn:stopAllActions()
        numbers = 0
    end)

end


--获取动态数据库中的数据
function QiXingTanchangeHeroSubLayer:readDBData(  )

    self._hero_soul_data = {}
    --获取table的大小
    function getTableNum( table )  
        local count = 0
        for k,v in pairs(table) do
            count = count + 1
        end
        return  tonumber(count)
    end

    local not_have_table = {}  --
    local temp_hero_tab = {}
    --从动态数据库中获取玩家已经拥有的魂石
    self._already_had_soul = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{item_type = 2})

    --从兑换表中拿到需要兑换的英雄（主要是拿到equipid）
    local ex_hero_soul = gameData.getDataFromCSV("QxtExchange",{_type = 2})
    --从英雄表中拿到兑换英雄的所有数据
    for i=1,#ex_hero_soul do
        local hero_soul = gameData.getDataFromCSV("ArticleInfoSheet",{resourceid = ex_hero_soul[i].beforeExNeedHero})
        temp_hero_tab[#temp_hero_tab+1] = hero_soul
    end

    --比对动态库中的数据，把已经拥有的英雄加入到self._hero_soul_data的前部
    for i=1,#temp_hero_tab do
        local tmp_tab = gameData.getDataFromDynamicDB(gameUser.getUserId(),"hero",{heroid = temp_hero_tab[i]["resourceid"]})["heroid"] or 0
        -- if getTableNum(tmp_tab) ~= 0 then
        if tonumber(temp_hero_tab[i]["resourceid"]) == tonumber(tmp_tab) then
            temp_hero_tab[i].is_had = true
            self._hero_soul_data[#self._hero_soul_data+1] = temp_hero_tab[i]
        else
            temp_hero_tab[i].is_had = false
            not_have_table[#not_have_table+1] = temp_hero_tab[i]
        end
    end

    table.sort(self._hero_soul_data,function(a,b)
        if a.rank == b.rank then
            return a.itemid < b.itemid
        else
            return a.rank > b.rank
        end
    end)
    table.sort(not_have_table,function(a,b)
        if a.rank == b.rank then
            return a.itemid < b.itemid
        else
            return a.rank > b.rank
        end
    end)
    --把没有的英雄加入到self._hero_soul_data的后部
    for i=1,#not_have_table do
        self._hero_soul_data[#self._hero_soul_data+1] = not_have_table[i]
    end

end


function QiXingTanchangeHeroSubLayer:initCellData(cell,idx)

    local temp_idx = idx*5
    local TAG = 1
    for i=tonumber(temp_idx)+1,tonumber(temp_idx)+5 do
        if i <= #self._hero_soul_data then
            local item_data = self._hero_soul_data[i]
            -- dbid,count,
            local item = ItemNode:createWithParams({
                itemId = item_data.itemid,
                dbId = item_data.dbid or nil,
                quality = item_data.rank,
				isScrollView = true,
                -- count = item_data.count or nil,
                _type_ = 4,
                -- touchShowTip = false,
                isShowDrop = false,
                })
            item:setScale(0.8)
            item:setPosition(((i-1)%5)*90+55,cell:getContentSize().height/2)
            cell:addChild(item)

            local selected_box = ccui.Scale9Sprite:create("res/image/illustration/selected.png")
--            selected_box:setContentSize(item:getContentSize().width+15,item:getContentSize().height+12)
            selected_box:setScale(0.8)
            selected_box:setPosition(item:getPositionX(),item:getPositionY())
            selected_box:setTag(SELECTEC_BOX_TAY+TAG)
            cell:addChild(selected_box)

            TAG = TAG + 1

            item:setTouchBeganCallback(function (  )
                item:setScale(0.7)
            end)

            item:setTouchEndedCallback(function (  )
                item:setScale(0.8)
                self._selected_item_position = i
                self:setSelectItemStatus(selected_box)
                --初始化右边UI及数据
                self._left_data = item_data
                self:fadeAction(self._left_bg,item_data)
            end)
            selected_box:setVisible(false)

            --玩家没有的魂石，加遮罩
            if item_data.is_had ~= true then
                local mask_layer = XTHD.createSprite("res/image/exchange/iconGray.png") --ccui.Scale9Sprite:create(cc.rect(39,39,2,2), "res/image/exchange/iconGray.png" )--cc.LayerColor:create()
				mask_layer:setScale(1.08)
                mask_layer:setAnchorPoint(cc.p(0.5,0.5))
                -- mask_layer:setOpacity(100)
                mask_layer:setPosition(cc.p(item:getContentSize().width/2,item:getContentSize().height/2))
                item:addChild(mask_layer)
            end

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

function QiXingTanchangeHeroSubLayer:doHttpRequest( configid,num )

    -- function getTableNum( table )
    --     local num = 0
    --     for k,v in pairs(table) do
    --         num = num + 1
    --     end
    --     return num
    -- end

    --recruitType = 1 表示英雄， recruitType = 2 表示道具
     ClientHttp:requestAsyncInGameWithParams({
        modules = "recruitExchange?",
        params = {configId=configid,count=num},
        successCallback = function(data)
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end
        -- if getTableNum(data) == 0 then
        --     XTHDTOAST("数据长度小于1")
        --     return
        -- end

        --获取奖励成功
        if  tonumber(data.result) == 0 then
            gameUser.setRecruitExchangeSum(data.exchangePetSum)
            self:getHeroReward(data,num)
            RedPointManage:getDynamicItemData()
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

function QiXingTanchangeHeroSubLayer:getHeroReward( data,num )

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
function QiXingTanchangeHeroSubLayer:setSelectItemStatus( item )
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

function QiXingTanchangeHeroSubLayer:onEnter(  )
    --升星回来刷新数据
    XTHD.dispatchEvent({name = "REFRESH_HERO_SUB_DATA",data = param })
end

function QiXingTanchangeHeroSubLayer:create()
	return QiXingTanchangeHeroSubLayer.new()
end

function QiXingTanchangeHeroSubLayer:onCleanup( ... )
    -- XTHD.removeEventListener("REFRESH_HERO_SUB_DATA")
    
    -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER})
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
end

return QiXingTanchangeHeroSubLayer
