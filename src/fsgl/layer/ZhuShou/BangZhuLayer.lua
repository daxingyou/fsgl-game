
--@author hezhitao 2015.06.30

local BangZhuLayer = class( "BangZhuLayer", function ()
    return XTHD.createBasePageLayer()
end)

local _tmp_dat = gameData.getDataFromCSV("HelpManual",{_type = 1})
local add_height = 44*(#_tmp_dat)

function BangZhuLayer:ctor()

    self._scrollview = nil
    self._base_bg = nil
    self._table = {} --用于存放各种元素
    self._is_open = false
    self._cell_array = {}  --存放cell
    self._item_array = {}  --用于存放itemNode的数组
    self._base_array = {}  --用于存放base元素的数组
    self._item_frame = {}

    self._is_finish_action = true  --用于记录动画是否播放完，只有动画播放完毕后才能响应事件，这样做是为了避免狂点”基本说明按钮“按钮的处理


	--底部两个角里面的花纹
    local pattern_left = cc.Sprite:create("res/image/plugin/warehouse/pattern_left.png")
    pattern_left:setAnchorPoint(0,0)
    pattern_left:setPosition(0,0)
    self:addChild(pattern_left)

    local pattern_right = cc.Sprite:create("res/image/plugin/warehouse/pattern_right.png")
    pattern_right:setAnchorPoint(1,0)
    pattern_right:setPosition(self:getContentSize().width,0)
    self:addChild(pattern_right)

    --透明层bg放在除去顶部topbar的高度之后的中间，为了适配各种机型
    -- local layer_height = self:getChildByName("_notic_bg"):getBoundingBox().y
    local size = cc.Director:getInstance():getWinSize()
    local bg = XTHD.createSprite("res/image/common/layer_bottomBg.png")
    -- bg:setContentSize(XTHD.resource.visibleSize.width,layer_height)
    bg:setPosition(size.width/2, size.height/2-self.topBarHeight/2)
	self._bottomBg = bg
    self:addChild(bg)


    --左边背景
    -- local left_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_2.png")
    local left_bg = cc.Sprite:create()
    left_bg:setContentSize(size.width,bg:getContentSize().height-40)
    left_bg:setAnchorPoint(0,0)
    left_bg:setPosition(0,bg:getPositionY()/4 - 30)
    self._bottomBg:addChild(left_bg)

    local btn_bg = XTHD.createSprite()
    btn_bg:setContentSize(195,left_bg:getContentSize().height-2)
    btn_bg:setAnchorPoint(0,0.5)
    btn_bg:setPosition(0,left_bg:getContentSize().height/2 - 15)
    left_bg:addChild(btn_bg)

    --scrollView
    local scrollview = ccui.ScrollView:create()
    -- scrollview:setBounceEnabled(false)
    scrollview:setTouchEnabled(true)
    scrollview:setDirection(ccui.ScrollViewDir.vertical)
    scrollview:setContentSize(cc.size(btn_bg:getContentSize().width,btn_bg:getContentSize().height-10))
    scrollview:setInnerContainerSize(cc.size(btn_bg:getContentSize().width,117*7+90))  --117为一个ItemNode的高度
    scrollview:setPosition(24,-10)
	scrollview:setScrollBarEnabled(false)
    btn_bg:addChild(scrollview)
    self._scrollview = scrollview


    --基本说明按钮
    local baseBtn = XTHD.createButton({
        touchSize = cc.size(185,54),
        needSwallow = false,
--		isScrollView = true,
    })
    baseBtn:setScale(0.85)
    local normal = ccui.Scale9Sprite:create("res/image/help/btn_normal.png")
    -- normal:setContentSize(cc.size(185,54))
    baseBtn:addChild(normal)
    local selected = ccui.Scale9Sprite:create("res/image/help/btn_selected.png")
    -- selected:setContentSize(cc.size(185,54))
    baseBtn:addChild(selected)
    selected:setVisible(false)
    local title = cc.Sprite:create("res/image/help/font_normal_1.png")
    title:setPosition(-15,0)
    baseBtn:addChild(title)
    local up = cc.Sprite:create("res/image/help/arrow_up.png")
    up:setAnchorPoint(0,0.5)
    up:setPosition(title:getPositionX()+title:getContentSize().width/2,title:getPositionY())
    baseBtn:addChild(up)
    local down = cc.Sprite:create("res/image/help/arrow_down.png")
    down:setAnchorPoint(0,0.5)
    down:setPosition(title:getPositionX()+title:getContentSize().width/2,title:getPositionY())
    baseBtn:addChild(down)
    down:setVisible(false)

    baseBtn:setPosition(scrollview:getInnerContainerSize().width/2,scrollview:getInnerContainerSize().height-35)
    baseBtn:setTouchEndedCallback(function (  )
        --如果展开动画没有播放完毕，则不处理响应事件
        if self._is_finish_action == false then
           return
        else
            self._is_finish_action = false
        end

        if self._is_open == false then
            self:doActionOpen()
            up:setVisible(false)
            down:setVisible(true)
            normal:setVisible(false)
            selected:setVisible(true)
            self._is_open = true
        else
            self:doActionClose()
            up:setVisible(true)
            down:setVisible(false)
            normal:setVisible(true)
            selected:setVisible(false)
            self._is_open = false
        end
    end)
    scrollview:addChild(baseBtn)
    self._table["base"] = baseBtn




    --用于存放基本元素的背景
    local base_bg = XTHD.createSprite()
    -- local base_bg = ccui.Scale9Sprite:create(cc.rect(5,5,1,1), "res/image/common/scale_bg_15.png")
    base_bg:setContentSize(btn_bg:getContentSize().width,43*15)
    base_bg:setAnchorPoint(0,1)
    base_bg:setPosition(0,baseBtn:getPositionY()-54/2-5)
    scrollview:addChild(base_bg)
    -- self._base_bg = base_bg

    self._table["base_bg"] = base_bg
    

    --基本说明的子数据
    local temp_data = self:readDBData(1)
    --创建基本说明的子内容
    for i=1,#temp_data do
        local btn = XTHDPushButton:createWithParams({
            normalFile = "res/image/help/btn_classify_normal.png",
            selectedFile = "res/image/help/btn_classify_selected.png",
            needSwallow = false,
            musicFile = XTHD.resource.music.effect_btn_common,
			isScrollView = true,
            })
        btn:setPosition(base_bg:getContentSize().width/2,base_bg:getContentSize().height-25-(i-1)*43)
        btn:setTag(i)
        btn:setTouchEndedCallback(function (  )
            self:setOnClickCallback_base(btn)
        end)
        base_bg:addChild(btn)
        --变强途径的文字
        local data = temp_data[i]
        local str = ""
        if data then
            str = data.name
        end

        local label = XTHDLabel:createWithParams({   ---------------------基本说明{}
            text = str,
            fontSize = 22,
            color = cc.c3b(255,255,255),
            ttf = "res/fonts/def.ttf"
            })
            label:enableOutline(cc.c4b(106,36,13,255),1)
        label:setPosition(btn:getContentSize().width/2,btn:getContentSize().height/2)
        label:setName("label")
        btn:addChild(label)

        self._base_array[#self._base_array+1] = btn
    end
    base_bg:setOpacity(0)
    base_bg:setVisible(false)
    setAllChildrenCascadeOpacityEnabled(base_bg)

    --用于存放基本元素的背景
    local item_bg = XTHD.createSprite()
    -- local item_bg = ccui.Scale9Sprite:create(cc.rect(5,5,1,1), "res/image/common/scale9_bg_14.png")
    item_bg:setContentSize(btn_bg:getContentSize().width,117*7+20)
    item_bg:setAnchorPoint(0,1)
    item_bg:setPosition(0,baseBtn:getPositionY()-54/2-5)
    scrollview:addChild(item_bg)
    self._table["item_bg"] = item_bg

    --我要资源按钮
    -- local btn_n_sp_2 = cc.Sprite:create("res/image/help/btn_normal.png")
    local btn_n_sp_2 = ccui.Scale9Sprite:create("res/image/help/btn_normal.png")
    -- btn_n_sp_2:setContentSize(cc.size(185,54))
    local btn_font_n_2 = cc.Sprite:create("res/image/help/font_normal_2.png")
    btn_font_n_2:setPosition(btn_n_sp_2:getContentSize().width/2-15,btn_n_sp_2:getContentSize().height/2)
    btn_n_sp_2:addChild(btn_font_n_2)
    local up2 = cc.Sprite:create("res/image/help/arrow_up.png")
    up2:setAnchorPoint(0,0.5)
    up2:setPosition(btn_font_n_2:getPositionX()+btn_font_n_2:getContentSize().width/2,btn_n_sp_2:getContentSize().height/2)
    btn_n_sp_2:addChild(up2)

    -- local btn_s_sp_2 = cc.Sprite:create("res/image/help/btn_selected.png")
    local btn_s_sp_2 = ccui.Scale9Sprite:create("res/image/help/btn_selected.png")
    -- btn_s_sp_2:setContentSize(cc.size(185,54))
    local btn_font_s_2 = cc.Sprite:create("res/image/help/font_normal_2.png")
    btn_font_s_2:setPosition(btn_s_sp_2:getContentSize().width/2-15,btn_s_sp_2:getContentSize().height/2)
    btn_s_sp_2:addChild(btn_font_s_2)
    local down2 = cc.Sprite:create("res/image/help/arrow_down.png")
    down2:setAnchorPoint(0,0.5)
    down2:setPosition(btn_font_s_2:getPositionX()+btn_font_s_2:getContentSize().width/2,btn_s_sp_2:getContentSize().height/2)
    btn_s_sp_2:addChild(down2)

    local show_item_element = XTHDPushButton:createWithParams({
        normalNode = btn_n_sp_2,
        selectedNode =btn_s_sp_2,
        needSwallow = false,
        musicFile = XTHD.resource.music.effect_btn_common,
		isScrollView = true,
    })
    show_item_element:setScale(0.85)

    show_item_element:setPosition(item_bg:getContentSize().width/2,item_bg:getContentSize().height-37)
    item_bg:addChild(show_item_element)

    btn_n_sp_2:setVisible(false)
    btn_s_sp_2:setVisible(true)
    --创建六个item
    local type_tab = {4,4,30,4,3,2,6,5,1,1,4,4,4,2}  --1经验、2银两、3元宝、4道具、5体力、6翡翠
    local itemid = {"1001","310061","1","10001","1","1","1","1","1","1","2251","2302","2301","1"}
    local item_name = LANGUAGE_TIPS_WORDS100-----=-{"英雄","装备","神器","玄符","元宝","银两","翡翠","体力","玩家经验","英雄经验","进阶丹","升星道具","装备材料","其他货币"}
    for i=1,#type_tab do
        local item = nil
        
        if i == 1 then
            item = HeroNode:createWithParams({
                heroid = 1,
                star = -1,
                level = -1,
				isScrollView = true,
                })
            local tmp_item = cc.Sprite:create("res/image/quality/item_1.png")
            item:setScale(tmp_item:getContentSize().width/item:getContentSize().width)
        elseif i == 10 then
            item = XTHDPushButton:createWithParams({
                normalFile = "res/image/common/common_hero_exp.png",
                selectedFile = "res/image/common/common_hero_exp.png",
                needSwallow = false,
                musicFile = XTHD.resource.music.effect_btn_common,
				isScrollView = true,
                })
            local frame = cc.Sprite:create("res/image/quality/item_4.png")
            frame:setPosition(item:getContentSize().width/2,item:getContentSize().height/2)
            item:addChild(frame)
            
        else
           item = ItemNode:createWithParams({
                _type_ = type_tab[i],
                touchShowTip = false,
                -- quality = 6,
                itemId = itemid[i],
                isShowDrop = false,
				isScrollView = true,
                })
        end
        item_bg:addChild(item)
        item:setTag(i)
        item:setScale(0.8)
        item:setTouchEndedCallback(function (  )
            self:onClickCallback(item)
        end)
        local x = i%2 ~= 0 and 52 or 142
        local y = item_bg:getContentSize().height-math.ceil(i/2)*110
        item:setPosition(x,y)

        --选择状态
        local selected = ccui.Scale9Sprite:create("res/image/illustration/selected.png")
        -- selected:setPosition(item:getContentSize().width/2,item:getContentSize().height/2)
        -- item:addChild(selected)
        -- selected:setTag(i)
        selected:setContentSize(item:getContentSize().width+10,item:getContentSize().height+10)
        selected:setPosition(x,y - 2)
        item_bg:addChild(selected)
        selected:setVisible(false)
        self._item_frame[#self._item_frame+1] = selected

        -- local name = XTHDLabel:createWithParams({
        --     text = item_name[i],
        --     fontSize = 18,
        --     color = cc.c3b(53,25,26)
        --     })
            --先用文字，等给全了图片之后在换成图片
        local name = ccui.Scale9Sprite:create("res/image/help/item_name" .. i .. ".png")
        name:setPosition(item:getContentSize().width/2,-15)
        item:addChild(name)
        if i >=7 then
            -- if i == 10 then
            --     name:setPositionY(name:getPositionY()-15)
            -- end
            name:setScale(0.8)
        end

        self._item_array[#self._item_array+1] = item
    end

    --我要资源按钮添加触摸显示隐藏功能
    show_item_element:setTouchEndedCallback(function ()
        if not self._isWantResourceOpen then
            --说明当前子节点并未打开 则显示
            self._isWantResourceOpen = true
            btn_s_sp_2:setVisible(true)
            btn_n_sp_2:setVisible(false)

            for i = 1, #type_tab do
                local item = item_bg:getChildByTag(i)
                if item then
                    item:setVisible(true)
                end
            end
            self._item_frame[1]:setVisible(true)
        else    --说明当前子节点已经打开 则隐藏    
            self._isWantResourceOpen = false
            btn_s_sp_2:setVisible(false)
            btn_n_sp_2:setVisible(true)

            for i = 1, #type_tab do
                local item = item_bg:getChildByTag(i)
                if item then
                    item:setVisible(false)
                end
            end

            --隐藏选中的光
            for i=1,#self._item_frame do
                self._item_frame[i]:setVisible(false)
            end
        end
    end)

    --我想要资源默认是打开状态
    self._isWantResourceOpen = true
    --默认选择第一个item
    -- self._item_array[1]:getChildByTag(1):setVisible(true)
    self._item_frame[1]:setVisible(true)

    --显示基本说明的详细内容背景框
    -- local right_base_bg = XTHD.createSprite()
    local right_base_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
    local right_base_bg_width = self._bottomBg:getContentSize().width - 230
    right_base_bg:setContentSize(right_base_bg_width,left_bg:getContentSize().height-30)
    right_base_bg:setAnchorPoint(0,0.5)
    right_base_bg:setPosition(btn_bg:getContentSize().width+20,left_bg:getContentSize().height/2 + 15)
    self._bottomBg:addChild(right_base_bg)
    self._table["right_base_bg"] = right_base_bg

    --进入到界面不显示基本说明的详细内容
    right_base_bg:setVisible(false)

    local title_bg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277,50))
    title_bg:setPosition(right_base_bg:getContentSize().width/2,right_base_bg:getContentSize().height-10)
    right_base_bg:addChild(title_bg)

    -- local base_detail_title = XTHDLabel:createWithParams({
    --     text = "",
    --     fontSize = 22,
    --     color = cc.c3b(53,25,26)
        -- })
    local base_detail_title = XTHD.createSprite()
    base_detail_title:setName("base_detail_title")
    base_detail_title:setPosition(right_base_bg:getContentSize().width/2,title_bg:getPositionY() + 5)
    right_base_bg:addChild(base_detail_title)

    local base_detail_txt = XTHDLabel:createWithParams({
        text = "",
        fontSize = 18,
        color = cc.c3b(0,0,0)
        })
    base_detail_txt:setName("base_detail_txt")
    base_detail_txt:setDimensions(right_base_bg:getContentSize().width-60,400)
    base_detail_txt:setAnchorPoint(0.5,1)
    base_detail_txt:setPosition(base_detail_title:getPositionX(),base_detail_title:getPositionY()-40)
    right_base_bg:addChild(base_detail_txt)


    --tablevie bg右侧背景图
    local tableBg = ccui.Scale9Sprite:create()
    tableBg:setContentSize(right_base_bg_width,left_bg:getContentSize().height-15)
    tableBg:setAnchorPoint(0,0.5)
    tableBg:setPosition(btn_bg:getContentSize().width+20,left_bg:getContentSize().height/2 + 15)
    self._bottomBg:addChild(tableBg)
    self._tableBg = tableBg
    --tableview
    local tableview = CCTableView:create( cc.size(tableBg:getContentSize().width-8, tableBg:getContentSize().height-8) );
    tableview:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL );
    tableview:setPosition( cc.p(4, 4) );
    tableview:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN );
    tableview:setBounceable(true);
    tableview:setDelegate();
    tableBg:addChild(tableview);
    self._table["tableview"] = tableview

    -- tableView注册事件
    local function numberOfCellsInTableView( table )
        return  #self._cell_array
    end
    local function cellSizeForTable( table, idx )
        return  tableview:getViewSize().width ,125
    end
    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell();
        if cell == nil then
            cell = cc.TableViewCell:new();
            cell:setContentSize( tableview:getViewSize().width,125 );
            -- cell:retain()
        else
            cell:removeAllChildren()
        end
        return self:initCell(cell,idx+1)
        -- return cell
    end

    tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)

    --从表中拿取数据
    self._cell_array =  self:readDBData(2,1)

    tableview:reloadData()

    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_HELP_DATA ,callback = function()
        tableview:reloadData()
    end})


end

--展开动画
function BangZhuLayer:doActionOpen( ... )
    self._scrollview:setInnerContainerSize(cc.size(253,self._scrollview:getInnerContainerSize().height+add_height))
    self._table["base_bg"]:setPositionY(self._table["base_bg"]:getPositionY()+add_height)
    self._table["base"]:setPositionY(self._table["base"]:getPositionY()+add_height)
    self._table["item_bg"]:setPositionY(self._table["item_bg"]:getPositionY()+add_height)
    self._table["base_bg"]:setVisible(true)

    local item_bg = self._table["item_bg"]
    item_bg:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.50,cc.p(item_bg:getPositionX(), item_bg:getPositionY()-add_height))))
    self._table["base_bg"]:runAction(cc.Sequence:create( cc.FadeIn:create(0.5),cc.CallFunc:create(function (  )
        self._is_finish_action = true
    end) ))
end

--关闭动画
function BangZhuLayer:doActionClose( ... )
    self._scrollview:setInnerContainerSize(cc.size(253,self._scrollview:getInnerContainerSize().height-add_height))
    self._table["base_bg"]:setPositionY(self._table["base_bg"]:getPositionY()-add_height)
    self._table["base"]:setPositionY(self._table["base"]:getPositionY()-add_height)
    self._table["item_bg"]:setPositionY(self._table["item_bg"]:getPositionY()-add_height)

    local item_bg = self._table["item_bg"]
    item_bg:runAction(cc.EaseBackIn:create(cc.MoveTo:create(0.50,cc.p(item_bg:getPositionX(), item_bg:getPositionY()+add_height))))
    self._table["base_bg"]:runAction(cc.Sequence:create( cc.FadeOut:create(0.5),cc.CallFunc:create(function (  )
        self._table["base_bg"]:setVisible(false)
        self._is_finish_action = true
    end) ))
end

function BangZhuLayer:initCell( cell,idx )
    local data = self._cell_array[idx]
    if data == nil or next(data) == nil then
        return cell
    end

    local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
    bg:setContentSize(cc.size(cell:getContentSize().width-2, cell:getContentSize().height-2))
    bg:setPosition(cell:getContentSize().width/2,cell:getContentSize().height/2)
    cell:addChild(bg)

    --标题背景
    local title_bg = ccui.Scale9Sprite:create("res/image/store/store_cell_title.png")
    title_bg:setPosition(25,bg:getContentSize().height-25)
    title_bg:setAnchorPoint(0,0.5)
    bg:addChild(title_bg)
    --标题
    local title_txt = XTHDLabel:createWithParams({
        text = data.biaoti,
        fontSize = 22,
        color = cc.c3b(255,255,255),
        ttf = "res/fonts/def.ttf"
        })
    title_txt:enableOutline(cc.c4b(103,36,13,255),1)
    title_txt:setAnchorPoint(0,0.5)
    title_txt:setPosition(25,bg:getContentSize().height-25)
    bg:addChild(title_txt)

    local line = ccui.Scale9Sprite:create(cc.rect( 0, 0, 20, 2 ) ,"res/image/ranklistreward/splitX.png")
    line:setContentSize(cc.size(bg:getContentSize().width-30, 2))
    line:setPosition(bg:getContentSize().width/2, title_txt:getPositionY() - 15)
    bg:addChild(line)

    --获取速度
    local get_speed = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_GETSPEED,
        fontSize = 18,
        color = cc.c3b(54,55,112)
        })

    get_speed:setAnchorPoint(1,0.5)
    get_speed:setPosition(bg:getContentSize().width-220,title_txt:getPositionY())
    bg:addChild(get_speed)

    --星星
    for i=1,tonumber(data.speed) do
        local star = cc.Sprite:create("res/image/common/item_star.png")
        star:setPosition(get_speed:getPositionX()+10+(i-1)*25,get_speed:getPositionY())
        bg:addChild(star)
        star:setScale(0.8)
    end

    -- --中间的线
    -- local line = cc.Sprite:create("res/image/common/level_up_line.png")
    -- line:setPosition(bg:getContentSize().width/2,bg:getContentSize().height-35)
    -- line:setColor(cc.c3b(53,25,26))
    -- line:setScale(0.95)
    -- bg:addChild(line)

    --详细内容
    local detail_txt = XTHDLabel:createWithParams({
        text = data.miaoshu,
        fontSize = 16,
        color = cc.c3b(54,55,112)
        })
    detail_txt:setDimensions(cell:getContentSize().width-220,90)
    detail_txt:setAnchorPoint(0,1)
    detail_txt:setPosition(title_txt:getPositionX()-10,75)
    bg:addChild(detail_txt)

    local normal_file = ""
    local selected_file = ""
    local btnType = ""
    local need_level = data["needlevel"] or 0
    local tmp_data = gameData.getDataFromCSV("FunctionInfoList", {id = need_level})
    local is_open = true    --是否开启标记
    if need_level == 0 then
        normal_file = "write_1"
    else
        local unlockparam = tmp_data["unlockparam"] or 0    --通过关卡数
        local unlocktype = tmp_data["unlocktype"] or 1      --开启类型
        if unlocktype == 1 then
            if gameUser.getLevel() < tonumber(unlockparam) then
                normal_file = "write"
                is_open = false
            else
                normal_file = "write_1"
            end
        elseif unlocktype == 2 then
            if gameUser.getInstancingId() < tonumber(unlockparam) then
                normal_file = "write"
                is_open = false
            else
                normal_file = "write_1"
            end
        end
    end

    -- if gameUser.getLevel() < tonumber(need_level) then
    --     normal_file = "res/image/common/btn/btn_cancel_normal.png"
    --     selected_file = "res/image/common/btn/btn_cancel_selected.png"
    -- else
    -- end
    local str_file = ""
    if is_open == false then
        str_file = LANGUAGE_KEY_UNLOCK
    else
        str_file = LANGUAGE_KEY_SPACEGOTO
    end

    local button = XTHD.createCommonButton({               -----------------前往
        btnColor = normal_file, 
        isScrollView = true,           
        needSwallow = false,
        text = str_file,
    })
    button:setScale(0.8)
    button:setTouchEndedCallback(function (  )
        if is_open then
            local id = tonumber(data.idid) or 1
            -- if id == 1 or id == 2 or id == 31 or id == 34 or id == 36 or id == 38 then  --这些需要切换场景，特殊处理
            --     button:setSelected(true)
            -- end
            LayerManager.addShieldLayout()
            replaceLayer({
                fNode = self,
                id = tonumber(data.idid)
            })
        end
    end)

    button:setPosition(bg:getContentSize().width-90,45)
    bg:addChild(button)

    return cell

end

function BangZhuLayer:setButtonSelected( btn )
    -- body
end

--点击itemNode事件回调
function BangZhuLayer:onClickCallback( node )

    --设置按钮选择状态
    self:setItemSelectStatus(node)
    self:setItemSelectStatus_base()
    self._table["tableview"]:setVisible(true)  --tableview可见
    self._tableBg:setVisible(true)
    self._table["right_base_bg"]:setVisible(false)
    self._cell_array = {}
    self._cell_array = self:readDBData(2,node:getTag())
    self._table["tableview"]:reloadData()
end

--设置itemNode选择状态
function BangZhuLayer:setItemSelectStatus( node )
    for i=1,#self._item_frame do
        self._item_frame[i]:setVisible(false)
    end
    --如果不传参，则item设置成全部不选择状态
    if node == nil then
        return
    end
    self._item_frame[node:getTag()]:setVisible(true)
    -- self._item_array[node:getTag()]:getChildByTag(node:getTag()):setVisible(true)
end

--点击基本说明子按钮回调
function BangZhuLayer:setOnClickCallback_base( node )

    self:setItemSelectStatus_base(node)
    self:setItemSelectStatus()
    self._table["tableview"]:setVisible(false)  --tableview不可见
    self._tableBg:setVisible(false)
    self._table["right_base_bg"]:setVisible(true)

    --设置显示数据
    local data = self:readDBData(1)[node:getTag()]
    local temp_label_1 = self._table["right_base_bg"]:getChildByName("base_detail_txt")
    local temp_label_2 = self._table["right_base_bg"]:getChildByName("base_detail_title")
    if temp_label_1 and temp_label_2 then
        temp_label_1:setString(tostring(data.miaoshu))
        -- temp_label_2:setString(data.biaoti)
        temp_label_2:setTexture("res/image/help/" .. data.id .. ".png")
    end

    --单独处理换换的问题
    if node:getTag() == 1 then
        local tmpdata = self:readDBData(1)[node:getTag()]
        local tmp_tab = string.split(tmpdata.miaoshu,"*")
        local str = ""
        for i=1,#tmp_tab do
            str = str..tmp_tab[i].."\n"
        end
        temp_label_1:setString(tostring(str))
    end



end

--设置基本说明子按钮选择状态
function BangZhuLayer:setItemSelectStatus_base( node )
    for i=1,#self._base_array do
        self._base_array[i]:setSelected(false)
        self._base_array[i]:getChildByName("label"):setColor(cc.c3b(255,255,255))
    end
    --如果不传参，则item设置成全部不选择状态
    if node == nil then
        return
    end
    node:setSelected(true)
    node:getChildByName("label"):setColor(cc.c3b(255,255,255))
end


--读取数据
function BangZhuLayer:readDBData( type,team )
   local temp_table = {}
   local compass_data = gameData.getDataFromCSV("HelpManual",{_type = type})
   if compass_data and #compass_data ~= 0 then
       for i=1,#compass_data do
           local item_data = compass_data[i]
           --如果team不为nil，则需要把指定的team放入到temp_table中，否则数据全部放入temp_table中
           if item_data and next(item_data) and item_data["team"] and tonumber(item_data["team"]) == team and team ~= nil then
               temp_table[#temp_table+1] = item_data
            elseif team == nil then
               temp_table[#temp_table+1] = item_data
           end
       end
   end
   return temp_table

end


function BangZhuLayer:create()
	return self.new();
end

function BangZhuLayer:onCleanup(  )
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_HELP_DATA)
end

function BangZhuLayer:onEnter( )
    if self._table["tableview"] ~= nil then
        self._table["tableview"]:reloadData()
    end
end

return BangZhuLayer


