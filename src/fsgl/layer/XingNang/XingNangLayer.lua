--yanyuling行囊
local  XingNangLayer  = class( "XingNangLayer", function ( ... )
    return XTHD.createBasePageLayer()
end)

function XingNangLayer:InitUI(item_data)
    --backGround
    self._bg_sp = cc.Sprite:create("res/image/common/layer_bottomBg.png")
    self._bg_sp:setName("self._bg_sp")
    self._bg_sp:setPosition(self:getContentSize().width/2, self:getContentSize().height/2 - self.topBarHeight/2)
    self:addChild(self._bg_sp)
	self._bg_sp:setContentSize(933,468)
	
	local title = "res/image/public/xingnang_title.png"
	XTHD.createNodeDecoration(self._bg_sp,title)

	self._bg_sp:getChildByName("hengliang"):setScale(0.91)
	self._bg_sp:getChildByName("dibian"):setScale(0.91)

    local bsize=self._bg_sp:getContentSize()

--    --阴影
--	local shadow = ccui.Scale9Sprite:create("res/image/common/common_black_shadow.png")
--	shadow:setPosition(bsize.width,bsize.height/2)
--	shadow:setAnchorPoint(1,0.5)
--	self._bg_sp:addChild(shadow)
    --底部两个角里面的花纹
    -- local pattern_left = cc.Sprite:create("res/image/plugin/warehouse/pattern_left.png")
    -- pattern_left:setAnchorPoint(0,0)
    -- pattern_left:setPosition(0,0)
    -- self:addChild(pattern_left)

    -- local pattern_right = cc.Sprite:create("res/image/plugin/warehouse/pattern_right.png")
    -- pattern_right:setAnchorPoint(1,0)
    -- pattern_right:setPosition(self:getContentSize().width,0)
    -- self:addChild(pattern_right)

    --右侧内背景
    
    -- local normalNode
    -- local _normalNode = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_1.png")
    -- _normalNode:setOpacity(0)
    
    -- _normalNode:setContentSize(cc.size(370,450+2))
    -- _normalNode:setCascadeOpacityEnabled(true)
    -- _normalNode:setCascadeColorEnabled(true)
    -- self._inner_right_bg = XTHDPushButton:createWithParams({
    --     musicFile = XTHD.resource.music.effect_btn_common,
    --     normalNode = _normalNode,
    -- })
    --self._inner_right_bg = ccui.Scale9Sprite:create(cc.rect(5,5,1,1),"res/image/common/scale9_bg_14.png")
    self._inner_right_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
    self._inner_right_bg:setContentSize(cc.size(435,bsize.height-40))
    self._inner_right_bg:setAnchorPoint(1,0)
    
    --self._inner_right_bg:setPosition(self:getContentSize().width/2-100, (self:getContentSize().height-57-26)/2 + 30)
    self._inner_right_bg:setPosition(bsize.width-32, 19 )
    self._bg_sp:addChild(self._inner_right_bg,1)

    self._tip_label = cc.Sprite:create("res/image/plugin/warehouse/tips2.png")
    self._tip_label:setPosition(  self._inner_right_bg:getContentSize().width/2,   self._inner_right_bg:getContentSize().height/2 + 20)
    self._tip_label:setOpacity(0)
    self._inner_right_bg:addChild(self._tip_label,1)
    self.tipLabel = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_NOGOODS, "Helvetica", 22)
    self.tipLabel:setPosition(self._tip_label:getContentSize().width/2 - 20, 0)
    self.tipLabel:setColor(cc.c3b(169,156,137))
    self._tip_label:addChild(self.tipLabel,1)
    self.tipLabel:setOpacity(0)
    --中间分隔线

    self._line1 = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
    self._line1:setContentSize(400,3)
    self._line1:setRotation(90)
    self._line1:setPosition(390, bsize.height / 2)
    self._bg_sp:addChild(self._line1,1)
    self._line1:setOpacity(0)

    self.splitY = cc.Sprite:create("res/image/ranklistreward/splitY.png")
    self.splitY:setRotation(180)
    self.splitY:setPosition(self._line1:getPositionX()+35, bsize.height/2)
    self._bg_sp:addChild(self.splitY,10)
    self.splitY:setOpacity(0)


    --左侧内背景
    --self._inner_left_bg = ccui.Scale9Sprite:create(cc.rect(5,5,1,1),"res/image/common/scale9_bg_14.png")
    self._inner_left_bg = cc.Sprite:create()
    self._inner_left_bg:setContentSize(cc.size(370,bsize.height-60))
    self._inner_left_bg:setCascadeOpacityEnabled(true)
    self._inner_left_bg:setCascadeColorEnabled(true)
    self._inner_left_bg:setAnchorPoint(1,0)
    self._inner_left_bg:setPosition(370, 38)
    
    self._inner_left_bg.showPos = cc.p(bsize.width/2 + 20, self._inner_left_bg:getPositionY())
    self._inner_left_bg.hidePos = cc.p(bsize.width/2 + 20 + self._inner_left_bg:getContentSize().width+5, self._inner_left_bg.showPos.y)
    if #self._ItemTotalData == 0 then
        self._tip_label:setOpacity(255)
        self.tipLabel:setOpacity(255)
    end
    self._bg_sp:addChild(self._inner_left_bg,1)

--    self._line2 = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
--    self._line2:setContentSize(300,3)
--    self._line2:setPosition(180, self._inner_left_bg:getContentSize().height - 130)
--    self._inner_left_bg:addChild(self._line2,1)

--    self._line3 = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
--    self._line3:setContentSize(300,3)
--    self._line3:setPosition(180, self._inner_left_bg:getContentSize().height / 2 - 100)
--    self._inner_left_bg:addChild(self._line3,1)



    self._ItemTableview =  cc.TableView:create(cc.size(self._inner_right_bg:getContentSize().width-10,self._inner_right_bg:getContentSize().height-14))
    self._ItemTableview:setPosition(7, 12)
    self._ItemTableview:setBounceable(false)
    self._ItemTableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._ItemTableview:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._inner_right_bg:addChild(self._ItemTableview)
	TableViewPlug.init(self._ItemTableview)
	
	self._ItemTableview.getCellNumbers = self.numberOfCellsInTableView
    self._ItemTableview:registerScriptHandler(function (table_view)
           return self:numberOfCellsInTableView(table_view)
        end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	self._ItemTableview.getCellSize = self.cellSizeForTable
    self._ItemTableview:registerScriptHandler(function (table_view,idx)
            return self:cellSizeForTable(table_view,idx)
        end,cc.TABLECELL_SIZE_FOR_INDEX)

     self._ItemTableview:registerScriptHandler(function (table_view,idx)
            return self:tableCellAtIndex(table_view,idx)
        end,cc.TABLECELL_SIZE_AT_INDEX)

    --左侧5个选择按钮
    --[[
        1.消耗品
        2.魂石
        3.装备
        4.碎片，碎片
        5.玄符
    ]]
    for i=1,5 do
        local tab_btn = XTHDPushButton:createWithParams({
            normalNode      = getCompositeNodeWithImg("res/image/common/btn/btn_tabClassify_normal.png","res/image/plugin/warehouse/warehouse_btn_icon"..i.."_1.png"),
            selectedNode    = getCompositeNodeWithImg("res/image/common/btn/btn_tabClassify_selected.png","res/image/plugin/warehouse/warehouse_btn_icon"..i.."_2.png"),
            musicFile = XTHD.resource.music.effect_btn_common,
            anchor          =cc.p(0,1),
            pos             = cc.p(30,435 -85*(i-1))
        })
       tab_btn:setScale(0.7)
        if i == 1 then
             tab_btn:setTag(5)
        elseif i == 5 then
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            tab_btn:addChild(redDot)
            redDot:setPosition(tab_btn:getContentSize().width, tab_btn:getContentSize().height)
            self._redDot = redDot
            if self._redPointNum <= 0 then
                self._redDot:setVisible(false)
            end

            tab_btn:setTag(1)
            self:ChangeBtnStatusAndRefreshData(tab_btn)

        elseif i == 2 then
            tab_btn:setTag(3)
        elseif i == 3 then
            tab_btn:setTag(2)
        else
             tab_btn:setTag(i)
        end
        tab_btn:setTouchEndedCallback(function()
            self:ChangeBtnStatusAndRefreshData(tab_btn)
        end)
        self._bg_sp:addChild(tab_btn, 0)
        if i == 5 then
            tab_btn:setLocalZOrder(1)
        end
    end

    self._ItemTableview:reloadData()
end

--[[reason show 人物消失，详情界面出现
    hide 人物出现，详情界面消失]]
function XingNangLayer:doAction(reason)
    if (reason == "show" and self._inner_left_bg.m_status == "show") or (reason == "hide" and self._inner_left_bg.m_status == "hide")  then
        return
    end
     self._inner_left_bg:stopAllActions()
    if reason == "show" then
        self._inner_left_bg:setVisible(true)
        self._line1:setVisible(true)
        self.splitY:setVisible(true)
        self._inner_left_bg.m_status = "show"
        self._inner_left_bg:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.30,self._inner_left_bg.showPos)))
    elseif reason == "hide" then
        self._inner_left_bg.m_status = "hide"
        self._inner_left_bg:runAction(cc.EaseBackIn:create(cc.MoveTo:create(0.30,self._inner_left_bg.hidePos)))
        self._inner_left_bg:setVisible(false)
        self._line1:setVisible(false)
        self.splitY:setVisible(false)
    end
end

--显示装备详细信息界面
--only_refresh_count 只刷新数量，当使用道具的时候，或者卖出部分的时候，其实只需要刷新数量即可
function XingNangLayer:ShowItemDetailPanel(idx,only_refresh_count)
    --如果上次刷新的对象
    self._last_select_idx = idx

    local item_data = self._tableDataSource[idx]
    if not item_data then
        self:doAction("hide")
        return
    end
    -- item_data
     if only_refresh_count then
        if self._count_label then
            self._count_label:setString(item_data["count"])
        end
        if self._inner_left_bg:getChildByName("item_sp")  then
            self._inner_left_bg:getChildByName("item_sp"):refreshStregthenLevel(item_data["strengLevel"])
        end
        return
    end

    self:doAction("show")
    if self._inner_left_bg:getChildByName("item_sp")  then
        local fsp = self._inner_left_bg:getChildByName("item_sp")
        fsp:removeFromParent()

        local _tmp_data = clone(item_data)
        _tmp_data["count"] = nil
        local item_sp = ZhuangBeiItem:createClickedItem(_tmp_data)
        item_sp:setScale(0.8)
        item_sp:setCascadeOpacityEnabled(true)
        item_sp:setAnchorPoint(0,1)
        item_sp:setPosition(17 + 30,self._inner_left_bg:getContentSize().height-17 )
        self._inner_left_bg:addChild(item_sp)
        item_sp:setName("item_sp")
		item_sp:setVisible(false)
        --特效
        if tonumber(_tmp_data.item_type) == 3 and tonumber(_tmp_data.quality) > 3 then
            XTHD.addEffectToEquipment(item_sp, _tmp_data.quality)
        end
        self:refreshDetailInfo(item_data,idx)
    else
        local item_info = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=item_data["itemid"]})
        --装备图标
        local item_sp = ZhuangBeiItem:createSimpleItem(item_data)
        item_sp:setCascadeOpacityEnabled(true)
        item_sp:setName("item_sp")
        item_sp:setAnchorPoint(0,1)
        item_sp:setPosition(17 + 30, self._inner_left_bg:getContentSize().height-17 )
        -- item_sp:setScale(0.5)
        item_sp:setScale(0.8)
		item_sp:setVisible(false)
        self._inner_left_bg:addChild(item_sp)
        --特效
        if tonumber(item_data.item_type) == 3 and tonumber(item_data.quality) > 3 then
            XTHD.addEffectToEquipment(item_sp, item_data.quality)
        end
        --装备名字背景
        local zb_bg = ccui.Scale9Sprite:create("res/image/plugin/warehouse/wp_bg.png")
        zb_bg:setContentSize(self._inner_left_bg:getContentSize().width-100,35)
        zb_bg:setPosition(cc.p(item_sp:getPositionX() + item_sp:getContentSize().width+5-20,item_sp:getPositionY()))
        zb_bg:setAnchorPoint(0,1)
        self._inner_left_bg:addChild(zb_bg)
		zb_bg:setVisible(false)

        --装备名字
         self._item_name_label = XTHDLabel:createWithParams({
            text = "",--item_data["name"],
            anchor=cc.p(0,1),
            fontSize = 18,--字体大小
            pos = cc.p(item_sp:getPositionX() + item_sp:getContentSize().width+5,item_sp:getPositionY()-5),
            color = cc.c3b(70,34,34),--XTHD.resource.getQualityItemColor(item_data["quality"]),
            ttf = "res/fonts/def.ttf"
        })
        self._item_name_label:enableShadow(cc.c4b(70, 34, 34, 255), cc.size(0.4, -0.4),1)
        self._inner_left_bg:addChild(self._item_name_label)

        --品阶label
        self._item_quality_label = XTHDLabel:createWithParams({
            text = "",--item_data["name"],
            anchor=cc.p(0,1),
            fontSize = 18,--字体大小
            pos = cc.p(self._item_name_label:getPositionX() + self._item_name_label:getContentSize().width+10,self._item_name_label:getPositionY()),
            color = XTHD.resource.getQualityItemColor(item_data["quality"]),
            ttf = "res/fonts/def.ttf"
        })
        self._inner_left_bg:addChild(self._item_quality_label)
        
        --local _inner_info_bg = ccui.Scale9Sprite:create(cc.rect(15,15,1,1),"res/image/common/scale9_bg_5.png")
        local _inner_info_bg = cc.Sprite:create()
        _inner_info_bg:setName("_inner_info_bg")
        _inner_info_bg:setContentSize(cc.size(323,184))
        _inner_info_bg:setCascadeOpacityEnabled(true)
        _inner_info_bg:setCascadeColorEnabled(true)
        _inner_info_bg:setAnchorPoint(0.5,1)
        _inner_info_bg:setPosition(self._inner_left_bg:getContentSize().width/2, item_sp:getPositionY()-item_sp:getContentSize().height-10)
        self._inner_left_bg:addChild(_inner_info_bg)
		_inner_info_bg:setVisible(false)

        --local owm_bg = ccui.Scale9Sprite:create(cc.rect(43,18,1,1),"res/image/plugin/warehouse/owm_bg.png")-- cc.Sprite:create("res/image/plugin/warehouse/owm_bg.png")
        local owm_bg = cc.Sprite:create()
        owm_bg:setContentSize(cc.size(220,36))
        owm_bg:setAnchorPoint(0.5,0)
        owm_bg:setCascadeOpacityEnabled(true)
        owm_bg:setCascadeColorEnabled(true)
        owm_bg:setAnchorPoint(0.5,0)
        owm_bg:setOpacity(0)
        owm_bg:setName("owm_bg")
        owm_bg:setPosition(self._inner_left_bg:getContentSize().width/2, 48)
        self._inner_left_bg:addChild(owm_bg)
        
        --拥有数量
        local owm_label = XTHDLabel:createWithParams({
            text = "",--拥有"..tostring(item_data["count"]),
            anchor=cc.p(0,0.5),
            fontSize = 18,--字体大小
            pos = cc.p(self._item_name_label:getPositionX(),item_sp:getPositionY()-item_sp:getContentSize().height/2-5 ),
            color = cc.c3b(70,34,34),
            ttf = "res/fonts/def.ttf"
        })
        owm_label:setName("owm_label")
        self._inner_left_bg:addChild(owm_label)

        self._count_label = getCommonWhiteBMFontLabel("")
        self._count_label:setAnchorPoint(0,0.5)
		self._count_label:setScale(0.9)
        self._count_label:setPosition(owm_label:getPositionX()+owm_label:getContentSize().width+5,owm_label:getPositionY() - 5)
		self._count_label:setVisible(false)

        self._count_label:setName("owm_label")
        self._inner_left_bg:addChild(self._count_label)

        local jian_label = XTHDLabel:createWithParams({
            text = "",--拥有"..tostring(item_data["count"]),
            anchor=cc.p(0,0.5),
            fontSize = 18,--字体大小
            pos = cc.p(self._count_label:getPositionX()+self._count_label:getContentSize().width+35,owm_label:getPositionY()),
            color = owm_label:getColor(),
            ttf = "res/fonts/def.ttf"
        })
        jian_label:setName("jian_label")
        self._inner_left_bg:addChild(jian_label)
		jian_label:setVisible(false)

        local equip_info =nil
        if tonumber(item_data["item_type"]) == 3 then

             equip_info  = gameData.getDataFromCSV("EquipInfoList", {["itemid"]=item_data.itemid})
        end
            self._hero_type_limit_txt = XTHDLabel:createWithParams({
                text = "",
                anchor=cc.p(0,0),
                fontSize = 18,--字体大小
                pos = cc.p(self._item_name_label:getPositionX() - 50,item_sp:getPositionY() - 52),
                color = owm_label:getColor(),
                ttf = "res/fonts/def.ttf"
            })
            self._hero_type_limit_txt._original_pos =cc.p(self._hero_type_limit_txt:getPositionX(),self._hero_type_limit_txt:getPositionY())
            self._hero_type_limit_txt:setOpacity(0)
            self._inner_left_bg:addChild(self._hero_type_limit_txt)
            local _tab ={}
            if equip_info then
                local _tab = string.split(equip_info["herotype"], '#')
            end
            for i=1,3 do
                local _sp = cc.Sprite:create()
                local imgPath = nil
                if _tab[i] then
                   imgPath= "res/image/plugin/hero/hero_type_".._tab[i]..".png"
                else
                     imgPath= "res/image/plugin/hero/hero_type_1.png"
                end
                _sp:setScale(0.8)
                _sp:setOpacity(0)
                _sp:setAnchorPoint(0,0.5)
                _sp:setPosition(self._hero_type_limit_txt:getPositionX()+ self._hero_type_limit_txt:getContentSize().width+(_sp:getContentSize().width*_sp:getScale()+1)*(i-1),self._hero_type_limit_txt:getPositionY()+self._hero_type_limit_txt:getContentSize().height/2)
               self._inner_left_bg:addChild(_sp)
                _sp:setName("_sp" .. i)
            end
         if tonumber(item_data["item_type"]) == 3 then
            self._hero_type_limit_txt:setOpacity(255)
            for i=1,3 do
                local _child = self._inner_left_bg:getChildByName("_sp"..i)
                if  _child then
                    _child:setOpacity(255)
                end
            end
         end
        self._effect_label = XTHDLabel:createWithParams({
            text = "", --item_info["description"],
            anchor=cc.p(0,0), 
            fontSize = 18,--字体大小
            pos = cc.p(20,_inner_info_bg:getPositionY()-_inner_info_bg:getContentSize().height-18),
            color = cc.c3b(255,79,2),--owm_label:getColor()  -- owm_label:getColor(),
            ttf = "res/fonts/def.ttf"
        })
        -- self._effect_label:setLineHeight(28)
        self._effect_label:setDimensions(300, 100)
        self._effect_label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT )
        self._effect_label:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
        self._inner_left_bg:addChild( self._effect_label)
		self._effect_label:setVisible(false)
        --加个背景

        self._sell_btn = XTHD.createCommonButton({
            btnColor = "write_1",
            isScrollView = false,
            btnSize = cc.size(150, 46),
            text = LANGUAGE_KEY_ENSURE[1],
            needSwallow = false,
            fontSize = 24,
        })
        self._sell_btn:setScale(0.8)
        self._sell_btn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
        self._sell_btn:setCascadeOpacityEnabled(true)
        self._sell_btn:setOpacity(0)
        self._sell_btn:setPosition(self._inner_left_bg:getContentSize().width/2+70, -self._sell_btn:getContentSize().height/2+50)
        self._inner_left_bg:addChild(self._sell_btn)
        
        local price_label = XTHDLabel:createWithParams({
            text = LANGUAGE_SHOP_TIPS1,------"出售单价:", --item_info["description"],
            anchor=cc.p(0,0.5), 
            fontSize = 18,--字体大小
            pos = cc.p(25,owm_bg:getContentSize().height/2 - 15),
            color = owm_label:getColor(),  -- owm_label:getColor(),
            ttf = "res/fonts/def.ttf"
        })
        price_label:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
        price_label:setName("price_label")
        self._price_label = price_label
        owm_bg:addChild(price_label)

        local gold_sp = cc.Sprite:create("res/image/common/header_gold.png")
        gold_sp:setName("gold_sp_")
        gold_sp:setAnchorPoint(1,0.5)
        gold_sp:setPosition(owm_bg:getContentSize().width-75, owm_bg:getContentSize().height/2 - 15)
        owm_bg:addChild(gold_sp)
        self._gold_sp = gold_sp

        self._item_price =  getCommonWhiteBMFontLabel("")
        self._item_price:setAnchorPoint(0,0.5)
        self._item_price:setPosition(gold_sp:getPositionX()+5+5, gold_sp:getPositionY()-7)
        -- self._item_price:setOpacity(0)
        owm_bg:addChild(self._item_price)

        -- 确认使用
        self._use_btn = XTHD.createCommonButton({
            btnColor = "write_1",
            isScrollView = false,
            btnSize = cc.size(150, 46),
            text = LANGUAGE_TIP_CONFIRM_TOUSE,
            needSwallow = false,
            fontSize = 24,
        })
        self._use_btn:setScale(0.8)
        self._use_btn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
        self._use_btn:setCascadeOpacityEnabled(true)
        self._use_btn:setOpacity(0)
        self._use_btn:setPosition(self._inner_left_bg:getContentSize().width/2+70, -self._sell_btn:getContentSize().height/2+50)
        self._inner_left_bg:addChild(self._use_btn)

        self._fenjie_btn = XTHD.createCommonButton({
            btnColor = "write_1",
            isScrollView = false,
            btnSize = cc.size(150, 46),
            text = "确认分解",
            needSwallow = false,
            fontSize = 24,
        })
        self._fenjie_btn:setScale(0.8)
        self._fenjie_btn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
        self._fenjie_btn:setCascadeOpacityEnabled(true)
        self._fenjie_btn:setOpacity(255)
        self._fenjie_btn:setVisible(false)
        self._fenjie_btn:setPosition(self._inner_left_bg:getContentSize().width/2-20, -self._sell_btn:getContentSize().height/2+50)
        self._inner_left_bg:addChild(self._fenjie_btn)

        self._share_btn = XTHD.createCommonButton({
            btnColor = "write_1",
            isScrollView = false,
            btnSize = cc.size(150, 46),
            text = "分    享",
            needSwallow = false,
            fontSize = 24,
        })
        self._share_btn:setVisible(true)
        self._share_btn:setScale(0.8)
        self._inner_left_bg:addChild(self._share_btn)
        self._share_btn:setPosition(self._inner_left_bg:getContentSize().width/2-110, -self._sell_btn:getContentSize().height/2+50)

        self._usebtnPos = cc.p(0,0)
        self._fenjiePos = cc.p(0,0)
        self._sharePos = cc.p(0,0)

        self._usebtnPos = cc.p(self._use_btn:getPositionX(),self._use_btn:getPositionY())
        self._fenjiePos = cc.p(self._fenjie_btn:getPositionX(),self._fenjie_btn:getPositionY())
        self._sharePos = cc.p(self._share_btn:getPositionX(),self._share_btn:getPositionY())
		
        self:ShowItemDetailPanel(idx)
    end
end

function XingNangLayer:refreshDetailInfo(item_data,idx)
    self._share_btn:setTouchEndedCallback(function()
        ClientHttp:requestAsyncInGameWithParams({
            modules = "shareItem?",
            params  = {dbId = item_data["dbid"]},
            successCallback = function( data )
                -- dump(data,"7777")
                if tonumber(data.result) == 0 then
                    XTHDTOAST("分享成功")
                else
                    XTHDTOAST(data.msg)
                end 
            end,
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            end,--失败回调
            loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            loadingParent = node,
        })
    end)
--[[
    0无法使用
    1加主角增加银两 
    2加主角增加元宝 ok
    3加主角增加体力
    4为主角增加经验
    5为英雄增加经验（点击使用打开英雄框）
    6宝箱（调用掉落组）
    7战斗道具（只能在战斗中使用，填写技能ID，在钱庄中显示出售）
    8加主角翡翠
    9加主角精力
    战斗道具不能在钱庄中使用，只能出售
]]

    local static_item_info = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=item_data.itemid})
--    self._item_name_label:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
--        self._item_name_label:setString(item_data["name"])
--        end),cc.FadeIn:create(0.2)))

    self._item_quality_label:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
        if tonumber(item_data["item_type"]) == 3 then 
            if item_data["strengLabel"] and tonumber(item_data["strengLabel"]) > 0 then
                self._item_quality_label:setString("+"..item_data["strengLabel"])
                self._item_quality_label:setPosition(cc.p(self._item_name_label:getPositionX() + self._item_name_label:getContentSize().width+10,self._item_name_label:getPositionY()))
                self._item_quality_label:setColor(XTHD.resource.getQualityItemColor(item_data["quality"]))
            end
        else
            self._item_quality_label:setString("")
        end
    end),cc.FadeIn:create(0.2)))



    local _inner_info_bg =  self._inner_left_bg:getChildByName("_inner_info_bg")
    local desc_tab ,_line_count = self:getDescription(item_data)
    local _origi_line_count = _line_count
    local _tar_height = 0
    if #desc_tab == 1 then
        local __tab = string.split(desc_tab[1], "#")
        local pLabel = XTHDLabel:createWithParams({text = __tab[1], fontSize = 18})
        pLabel:setWidth(300)
        pLabel:updateContent()
        _tar_height = pLabel:getContentSize().height + 10
    else
        if _line_count then
            _tar_height = _line_count*28+10
        end
    end

    if _tar_height < 100 then
        _tar_height = 100
    end

    if _inner_info_bg then
        _inner_info_bg:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
             _inner_info_bg:setContentSize(cc.size(_inner_info_bg:getContentSize().width,_tar_height))
             if _inner_info_bg.original_count then
                for i=1,_inner_info_bg.original_count do
                    -- local line_sp = _inner_info_bg:getChildByName("line_sp"..tostring(i))
                    -- if line_sp then
                    --     line_sp:removeFromParent()
                    -- end
                    local desc_label = _inner_info_bg:getChildByName("desc"..tostring(i))
                    if desc_label then
                        desc_label:removeFromParent()
                    end
                    local value_label = _inner_info_bg:getChildByName("value"..tostring(i))
                    if value_label then
                        value_label:removeFromParent()
                    end
                end
             end

             _inner_info_bg.original_count = #desc_tab
             if _line_count == 0 then
                for i=1,#desc_tab do
                    local __tab = string.split(desc_tab[i], "#")
                    local desc_label = XTHDLabel:createWithParams({
                        text = __tab[1], --item_info["description"],
                        anchor=cc.p(0,1), 
                        fontSize = 18,--字体大小
                        pos = cc.p(10 + 10,_inner_info_bg:getContentSize().height-9-(i-1)*28),
                        color = cc.c3b(105,77,56),
                    })
                    desc_label:setDimensions(300, _tar_height)
                    desc_label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT )
                    desc_label:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
                    desc_label:setName("desc"..tostring(i))
                    _inner_info_bg:addChild(desc_label)
                end
             else
                 if #desc_tab > 0  then
                     for i=1,#desc_tab do
                        local __tab = string.split(desc_tab[i], "#")
                         local desc_label = XTHDLabel:createWithParams({
                            text = __tab[1], --item_info["description"],
                            anchor=cc.p(0,1), 
                            fontSize = 18,--字体大小
                            pos = cc.p(10 + 10,_inner_info_bg:getContentSize().height-9-(i-1)*28),
                            color = cc.c3b(105,77,56),
                        })
                        desc_label:setName("desc"..tostring(i))
                        _inner_info_bg:addChild(desc_label)

                        local value_label = XTHDLabel:createWithParams({
                            text = __tab[2], --item_info["description"],
                            anchor=cc.p(0,1), 
                            fontSize = 18,--字体大小
                            pos = cc.p(desc_label:getPositionX()+desc_label:getContentSize().width+2,desc_label:getPositionY()),
                            color = cc.c3b(104,157,0),
                        })
                        value_label:enableShadow(cc.c4b(104,157,0,255),cc.size(0.4,-0.4),1)
                        value_label:setName("value"..tostring(i))
                        _inner_info_bg:addChild(value_label)

                        -- if i < #desc_tab then
                        --     line_sp = cc.Sprite:create("res/image/plugin/warehouse/warehouse_line.png")
                        --     line_sp:setName("line_sp"..tostring(i))
                        --     line_sp:setScaleX(308/line_sp:getContentSize().width)
                        --     line_sp:setPosition(_inner_info_bg:getContentSize().width/2, _inner_info_bg:getContentSize().height-7-28*i)
                        --     _inner_info_bg:addChild(line_sp)
                        -- end
	end
                end
             end
            
        end),cc.FadeIn:create(0.2)))
    end
    self._effect_label:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
        self._effect_label:setString("") --static_item_info["description"]
        self._effect_label:setPosition(cc.p(50,_inner_info_bg:getPositionY()-_inner_info_bg:getContentSize().height-8-96-20))
    end),cc.FadeIn:create(0.2)))
	self._effect_label:setVisible(false)

	local owm_label = self._inner_left_bg:getChildByName("owm_label")
    local jian_label = self._inner_left_bg:getChildByName("jian_label")

	if self._showItemNode then
		self._showItemNode:removeFromParent()
	end
	
	local nodeSize = cc.size(self._inner_left_bg:getContentSize().width,self._inner_left_bg:getContentSize().height *0.7 + 50)
	local node = requires("src/fsgl/layer/XingNang/XingNangShowNode.lua"):create(nodeSize,item_data)
	self._inner_left_bg:addChild(node)
	node:setPosition(self._inner_left_bg:getContentSize().width *0.5 - 32,self._inner_left_bg:getContentSize().height *0.65 - 25)
	self._showItemNode = node
    
--    owm_label:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
--        owm_label:setString(LANGUAGE_VERBS.owned..":")-----拥有: ")
--    end),cc.FadeIn:create(0.2)))

--    self._count_label:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
--            self._count_label:setString(tostring(item_data["count"]))
--            self._count_label:setPosition(owm_label:getPositionX()+owm_label:getContentSize().width, self._count_label:getPositionY())
--    end),cc.FadeIn:create(0.2)))
    
--    jian_label:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
--        jian_label:setString(LANGUAGE_OTHER_TXTJIAN)-------" 件")
--        jian_label:setPosition(self._count_label:getPositionX()+self._count_label:getContentSize().width, jian_label:getPositionY())
--    end),cc.FadeIn:create(0.2)))

    if tonumber(item_data["item_type"]) == 3 then
            local equip_info  = gameData.getDataFromCSV("EquipInfoList", {["itemid"]=item_data.itemid})
            local _tab = string.split(equip_info["herotype"], '#')
            self._hero_type_limit_txt:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
                self._hero_type_limit_txt:setString(LANGUAGE_KEY_HERO_TEXT.itemHeroTypeTextXc)------"限制 ")
                self._hero_type_limit_txt:setPosition(self._hero_type_limit_txt._original_pos)
            end),cc.FadeIn:create(0.2)))

            for i=1,3 do
                local _child = self._inner_left_bg:getChildByName("_sp"..i)
                if  _child then
                    -- _child:setScale(1.5)
                    if _tab[i] then
                        _child:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
                            _child:setPosition(self._hero_type_limit_txt:getPositionX()+ self._hero_type_limit_txt:getContentSize().width+(_child:getContentSize().width*_child:getScale()+1)*(i-1),self._hero_type_limit_txt:getPositionY()+self._hero_type_limit_txt:getContentSize().height/2)
                            _child:initWithFile("res/image/plugin/hero/hero_type_".._tab[i]..".png")
                            _child:setAnchorPoint(cc.p(0,0.5))
                        end),cc.FadeIn:create(0.2)))
                    else
                        _child:runAction(cc.FadeOut:create(0.001))
                    end
                end
            end
        else
            self._hero_type_limit_txt:runAction(cc.FadeOut:create(0.2))
            for i=1,3 do
                local _child = self._inner_left_bg:getChildByName("_sp"..i)
                if  _child then
                    _child:runAction(cc.FadeOut:create(0.2))
                end
            end
        end

    if tonumber(item_data["item_type"]) == 1 and tonumber(static_item_info["effecttype"]) > 0 then
        self._share_btn:setVisible(true)
        self._inner_left_bg:getChildByName("owm_bg"):runAction(cc.FadeOut:create(0.2))
        self._item_price:setString("")
        self._use_btn:setEnable(true)
        self._sell_btn:setEnable(false)

        self._sell_btn:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
                self._use_btn:runAction(cc.FadeIn:create(0.2))
            end)))
        local vipcardList = gameData.getDataFromCSV("ItemDecompose", {["itemid"]=item_data.itemid})
        local isVisable = false
        if vipcardList.id ~= nil and vipcardList.id < 12 then
            isVisable = true
        end
        if ( tonumber(static_item_info["effecttype"]) < 5 and tonumber(static_item_info["effecttype"]) > 0) 
            or tonumber(static_item_info["effecttype"]) == 6 
            or tonumber(static_item_info["effecttype"]) == 8 
            or tonumber(static_item_info["effecttype"]) == 9 
            or tonumber(static_item_info["effecttype"]) == 10
            or tonumber(static_item_info["effecttype"]) == 11 
            or tonumber(static_item_info["effecttype"]) == 12 
            or tonumber(static_item_info["effecttype"]) == 13 then
                if tonumber(static_item_info["effecttype"]) == 10 and isVisable then
                    self._use_btn:setPosition(self._fenjiePos)
                    self._fenjie_btn:setPosition(self._inner_left_bg:getContentSize().width/2+120, -self._sell_btn:getContentSize().height/2+50)
                    self._share_btn:setPosition(self._inner_left_bg:getContentSize().width/2-160, -self._sell_btn:getContentSize().height/2+50)
                    self._fenjie_btn:setVisible(true)
                else
                    self._use_btn:setPosition(self._usebtnPos)
                    self._fenjie_btn:setPosition(self._fenjiePos)
                    self._share_btn:setPosition(self._sharePos )
                    self._fenjie_btn:setVisible(false)
                end
                self._use_btn:setTouchEndedCallback(function()
                self:UseItemForLord(item_data,static_item_info["effecttype"],static_item_info["effectvalue"],idx)
                -- self:UseItemForLord(item_data.itemid,static_item_info["effecttype"],static_item_info["effectvalue"],item_data["dbid"],idx)
            end)
            self._fenjie_btn:setTouchEndedCallback(function()
                self:FenjieVipCard(item_data)
            end)
        elseif tonumber(static_item_info["effecttype"])  == 5 then  --经验丹
            self._fenjie_btn:setVisible(false)
            self._use_btn:setPosition(self._usebtnPos)
            self._fenjie_btn:setPosition(self._fenjiePos)
            local function callBack(_data)
                self:upDateJson(_data["dbid"],_data["count"])
                if tonumber(_data["count"]) > 0 then
                     self:ShowItemDetailPanel(idx,true)
                else
                    if tonumber(table.nums(self._tableDataSource) ) > 0 then
                        local newIdx = idx <= table.nums(self._tableDataSource) and idx or table.nums(self._tableDataSource)
                        self._last_select_item = nil
                        self._last_select_dbid = self._tableDataSource[newIdx].dbid
                        self:ShowItemDetailPanel(table.nums(self._tableDataSource),false)
                        self._ItemTableview:reloadDataAndScrollToCurrentCell()
                    end
                end
            end
            self._use_btn:setTouchEndedCallback(function()
                local XingNangUsePop = requires("src/fsgl/layer/XingNang/XingNangUsePop.lua")
                self:addChild(XingNangUsePop:create({
                    ["dbid"] = item_data["dbid"],
                    ["itemid"] = item_data["itemid"],
                    ["effect"]=static_item_info["effectvalue"],
                    ["totalCount"] = item_data["count"],
                    ["callback"] = callBack
                }),2)
            end)
        elseif tonumber(static_item_info["effecttype"])  == 7 then   --暂时还没有道具
        end
    else
        -- dump(item_data)
        -- if item_data.item_type == 3 then
        --     self._share_btn:setVisible(true)
        --     self._price_label:setVisible(false)
        --     self._gold_sp:setVisible(false)
        --     self._item_price:setVisible(false)
        --     self._sell_btn:setText("出  售")
        -- else
        --     self._share_btn:setVisible(false)
        --     self._price_label:setVisible(true)
        --     self._gold_sp:setVisible(true)
        --     self._item_price:setVisible(true)
        --     self._sell_btn:setText(LANGUAGE_KEY_ENSURE[1])
        -- end
        
        self._fenjie_btn:setVisible(false)
        self._use_btn:setPosition(self._usebtnPos)
        self._fenjie_btn:setPosition(self._fenjiePos)
        self._inner_left_bg:getChildByName("owm_bg"):runAction(cc.FadeIn:create(0.2))
         self._item_price:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
             self._item_price:setString(static_item_info["price"])
            end),cc.FadeIn:create(0.2)))
        self._use_btn:setEnable(false)
        self._sell_btn:setEnable(true)
        
        self._sell_btn:runAction(cc.Sequence:create(cc.FadeIn:create(0.2),cc.CallFunc:create(function()
            self._use_btn:runAction(cc.FadeOut:create(0.2))
        end)))
        self._sell_btn:setTouchEndedCallback(function()
            --出售
            local function sellCallback(return_data,close_or_not)
                gameUser.setGold(return_data["silver"])
                self:upDateJson(return_data["dbId"],return_data["itemCount"])
                    --此处用大写dbId 、是因为从后端返回的数据
                if tonumber(return_data["itemCount"]) > 0 then
                    self:ShowItemDetailPanel(idx,true)
                else
                    if tonumber(table.nums(self._tableDataSource) ) > 0 then
                        local newIdx = idx <= table.nums(self._tableDataSource) and idx or table.nums(self._tableDataSource)
                        self._last_select_item = nil
                        self._last_select_dbid = self._tableDataSource[newIdx].dbid
                        self:ShowItemDetailPanel(table.nums(self._tableDataSource),false)
                        self._ItemTableview:reloadDataAndScrollToCurrentCell()
                    end
                end
            end
            local XingNangSellPop = requires("src/fsgl/layer/XingNang/XingNangSellPop.lua"):create(item_data,sellCallback)
            self:addChild(XingNangSellPop,2)
        end)
    end
end
function XingNangLayer:getDescription(item_data)
    local _line_count = 0
    local _str_tab = {}
    if tonumber(item_data["item_type"]) == 3 then

         local equip_info = gameData.getDataFromCSV("EquipInfoList", {["itemid"]=item_data.itemid})
         local baseProperty = string.split(item_data["baseProperty"],'#') or {}
         _line_count = #baseProperty
         local desc_str = ""
         local function add_desc_str(_pro_str)
             for i=1,#_pro_str do

                local _tab = string.split(_pro_str[i], ',')
                if _tab[1] and _tab[2] then
                     if  tonumber(_tab[1]) >= 300 and tonumber(_tab[1]) <= 314 then
                        local _str = XTHD.resource.getAttributes(_tab[1]) .. "#(+".._tab[2].."%)"
                        desc_str = desc_str .. _str..""
                        _str_tab[#_str_tab +1] = _str
                    else
                         local _str = XTHD.resource.getAttributes(_tab[1]) .. "#+".._tab[2]..""
                         desc_str = desc_str .. _str..""
                         _str_tab[#_str_tab +1] = _str
                    end
                end
             end
         end
         add_desc_str(baseProperty)

         return _str_tab , _line_count
    else
        local item_info = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=item_data.itemid})
        _str_tab[#_str_tab +1] = item_info["effect"]
        return  _str_tab,0
    end
end

function XingNangLayer:FenjieVipCard( data )
    -- dump(data,"vip卡片")
    local static_item_info = gameData.getDataFromCSV("ItemDecompose", {["itemid"]=data.itemid})
    local rightCallback = function()
        ClientHttp:requestAsyncInGameWithParams({
            modules = "decomposeItem?",
            params  = {configId = static_item_info.id, count = 1 },
            successCallback = function( data )
                -- dump(data,"服務器返回參數")
                if tonumber(data.result) == 0 then
                     for i=1,#data.newItems do
                        local _data = data["newItems"][i] 
                        if _data then
                            DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
                            if self._last_select_dbid == _data["dbId"] and tonumber(_data["count"]) == 0 then
                                self._last_select_dbid = nil --如果当前种族变更卡的数量为0 ，则把self._last_select_dbid 置为nil
                            end
                        end
                     end
                     for i=1,#data.items do
                        local _data = data["items"][i] 
                        if _data then
                            DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
                            if self._last_select_dbid == _data["dbId"] and tonumber(_data["count"]) == 0 then
                                self._last_select_dbid = nil --如果当前种族变更卡的数量为0 ，则把self._last_select_dbid 置为nil
                            end
                            self:updateBoxCount(_data["count"])
                        end
                     end
                    local show_data = {}
                    for i=1,#data["newItems"] do
                        show_data[#show_data+1] = {rewardtype = 4,id = data["newItems"][i].itemId,num = static_item_info.getSum}
                    end
                    ShowRewardNode:create(show_data)
                    self:refreshListWhenOpenBox()   
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
                else
                    XTHDTOAST(data.msg)
                end 
            end,
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            end,--失败回调
            loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            loadingParent = node,
        })
    end
    
    local _confirmLayer = XTHDConfirmDialog:createWithParams({
            rightText = "分  解",
            rightCallback = rightCallback,
            msg = ("确定分解"..static_item_info.name.."吗？")
    });
    self:addChild(_confirmLayer, 1)

end

--批量使用框
function XingNangLayer:showBatchDialog(callback,max_count)
    local Dialog  = XTHDPopLayer:create()
    local dialig_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png" )
    dialig_bg:setContentSize(375,228)
    Dialog.beginPos = cc.p(self:getContentSize().width/2,self:getContentSize().height/2)
    dialig_bg:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
    Dialog.popNode = dialig_bg
    Dialog:addContent(dialig_bg)
    
    local tip_label = XTHDLabel:createWithParams({
            text = LANGUAGE_SHOP_TIPS2,------"选择使用数量",--item_data["name"],
            anchor=cc.p(0.5,0.5),
            fontSize = 22,--字体大小
            pos = cc.p(dialig_bg:getContentSize().width/2,dialig_bg:getContentSize().height-30),
            color = cc.c3b(54,55,112) --XTHD.resource.getQualityItemColor(item_data["quality"]),
        })
        dialig_bg:addChild(tip_label)
    local count_num = 1
    -- local count_label = getCommonWhiteBMFontLabel("1")

    

        -- 黑背景
        local dark_bg = ccui.Scale9Sprite:create(cc.rect(64,14,1,1),"res/image/friends/input_bg.png")
        dark_bg:setContentSize(cc.size(180,31))
        dark_bg:setAnchorPoint(0,0.5)
        -- dark_bg:setPosition(Reduce_btn:getPositionX()+Reduce_btn:getContentSize().width+3, Reduce_btn:getPositionY())
        dark_bg:setPosition(60, dialig_bg:getContentSize().height/2+17)
        dialig_bg:addChild(dark_bg)
        
        -- count_label:setPosition(dark_bg:getContentSize().width/2, dark_bg:getContentSize().height/2-7)
        -- dark_bg:addChild(count_label)


        --编辑框代理
        function editboxHandler( event,sender )
            if event == "began" then
                sender:setText("")
            elseif event == "ended" then
            elseif event == "return" then
            elseif event == "changed" then
                count_num = tonumber(sender:getText())
                -- count_label:setString(tostring(count_num)) 
                if count_num > max_count then
                    XTHDTOAST(LANGUAGE_KEY_TOLIMIT)

                elseif count_num < 1 then
                    XTHDTOAST(LANGUAGE_SHOP_TIPS3)
                    sender:setText("1")
                end

             end
        end
        --编辑框
        local editbox_account = ccui.EditBox:create(cc.size(dark_bg:getContentSize().width/2 + 90,dark_bg:getContentSize().height/2 + 15), ccui.Scale9Sprite:create(),nil,nil)
        editbox_account:setFontColor(cc.c3b(255,255,255))
        editbox_account:setText("1")
        editbox_account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
        editbox_account:setAnchorPoint(0.5,0.5)
        editbox_account:setMaxLength(20)
        editbox_account:setPosition(dark_bg:getContentSize().width/2+editbox_account:getContentSize().width/4 - 44, dark_bg:getContentSize().height/2)
        -- editbox_account:setPlaceholderFontColor(cc.c3b(0,0,0))
        editbox_account:setFontName("Helvetica")
        editbox_account:setPlaceholderFontName("Helvetica")
		editbox_account:setTextHorizontalAlignment(1)
        editbox_account:setFontSize(20)
        -- editbox_account:setPlaceholderFontSize(24)
        editbox_account:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        dark_bg:addChild(editbox_account)
        editbox_account:registerScriptEditBoxHandler(function ( event,sender)
            editboxHandler(event,sender)
        end)
        self.editbox_account = editbox_account

        --减少按钮
        local Reduce_btn = XTHDPushButton:createWithParams({
            normalFile     = "res/image/common/btn/btn_reduce_normal.png",
            selectedFile   = "res/image/common/btn/btn_reduce_selected.png",
            anchor         = cc.p(0,0.5),
            pos            = cc.p(23,dialig_bg:getContentSize().height/2+17),
            musicFile = XTHD.resource.music.effect_btn_common,
            endCallback = function()
                if count_num <= 1 then
                    XTHDTOAST(LANGUAGE_SHOP_TIPS3)------"数量最少为1")
                    return
                end
                count_num = count_num -1
                -- count_label:setString(tostring(count_num))
                self.editbox_account:setText(count_num)
            end
        })
        Reduce_btn:setLabelColor(cc.c3b(255,255,0))
        dialig_bg:addChild(Reduce_btn)

        --全部
        local All_btn = XTHDPushButton:createWithParams({
            normalFile     = "res/image/common/btn/btn_max_normal.png",
            selectedFile   = "res/image/common/btn/btn_max_selected.png",
            anchor         = cc.p(1,0.5),
            pos            = cc.p(dialig_bg:getContentSize().width-14,Reduce_btn:getPositionY()),
            musicFile = XTHD.resource.music.effect_btn_common,
            endCallback = function()
                if count_num == tonumber(max_count) then
                    XTHDTOAST(LANGUAGE_KEY_TOLIMIT)----"数量已达上限")
                    return
                end
                count_num = max_count
                -- count_label:setString(tostring(count_num))
                self.editbox_account:setText(count_num)
            end
        })
        All_btn:setLabelColor(cc.c3b(255,255,0))
        dialig_bg:addChild(All_btn)


        --增加
        local Plus_btn = XTHDPushButton:createWithParams({
            normalFile     = "res/image/common/btn/btn_plus_normal.png",
            selectedFile   = "res/image/common/btn/btn_plus_selected.png",
            anchor         = cc.p(1,0.5),
            pos            = cc.p(All_btn:getPositionX() -All_btn:getContentSize().width -7,Reduce_btn:getPositionY()),
            musicFile = XTHD.resource.music.effect_btn_common,
            endCallback = function()
                if count_num >= tonumber(max_count) then
                    XTHDTOAST(LANGUAGE_KEY_TOLIMIT)------"数量已达上限,不可再增加")
                    return
                end
                count_num = count_num +1
                -- count_label:setString(tostring(count_num))
                self.editbox_account:setText(count_num)
            end
        })
        Plus_btn:setLabelColor(cc.c3b(255,255,0))
        dialig_bg:addChild(Plus_btn)

    local btn_left = XTHD.createCommonButton({
        btnColor = "write",
        isScrollView = false,
        btnSize = cc.size(130,46),
        text = LANGUAGE_KEY_CANCEL,
        fontSize = 22,
        pos = cc.p(100 + 5,50),
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback = function()
            Dialog:hide()
        end
    })
    btn_left:setScale(0.8)
    btn_left:setCascadeOpacityEnabled(true)
    btn_left:setOpacity(255)
    dialig_bg:addChild(btn_left)
    
    local btn_right = XTHD.createCommonButton({
        btnColor = "write_1",
        isScrollView = false,
        btnSize = cc.size(130,46),
        text = LANGUAGE_KEY_SURE,
        fontSize = 22,
        pos = cc.p(dialig_bg:getContentSize().width-100-5,btn_left:getPositionY()),
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback = function()
            if callback then
                callback(count_num)
            end
            Dialog:hide()
        end
    })
    btn_right:setScale(0.8)
    btn_right:setCascadeOpacityEnabled(true)
    btn_right:setOpacity(255)
    dialig_bg:addChild(btn_right)

    self:addChild(Dialog,3)
    Dialog:show()

end

--请求变更种族
function XingNangLayer:changeCamp()
    ClientHttp:requestAsyncInGameWithParams({
        modules = "changeCampItem?",
        params  = {campId = gameUser.getCampID() == 1 and 2 or 1},
        successCallback = function( data )
            -- print("请求变更种族服务器返回参数为：")
            -- print_r(data)
            if tonumber(data.result) == 0 then
                gameUser.setCampID(data.campId)
                for i=1,#data.bagItems do
                    local _data = data["bagItems"][i] 
                    if _data then
                        DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
                        if self._last_select_dbid == _data["dbId"] and tonumber(_data["count"]) == 0 then
                            self._last_select_dbid = nil --如果当前种族变更卡的数量为0 ，则把self._last_select_dbid 置为nil
                        end
                        self:updateBoxCount(_data["count"])
                    end
                end
                XTHDTOAST("种族变更成功")
                self:refreshListWhenOpenBox()   
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
            else
                XTHDTOAST(data.msg)
            end 
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    })
end

--对主公使用一些道具
 -- self:UseItemForLord(item_data.itemid,static_item_info["effecttype"],static_item_info["effectvalue"],item_data["dbid"],idx)
function XingNangLayer:UseItemForLord(item_data,item_type,effectvalue,item_idx)
    --判断使用的是否是改名卡
    -- print("当前使用的道具为------------：")
    -- print_r(item_data)
    if tonumber(item_data["itemid"]) == 2304 then  ----------------改名卡
        if item_data["count"] > 0 then
            self:addChild(XTHD.changPlayerNameLayer(function (data)
                for i=1,#data["costItems"]  do
                    local _data = data["costItems"][i] 
                    if _data then
                        gameUser.setNickname(data.name)
                        DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
                        if self._last_select_dbid == _data["dbId"] and tonumber(_data["count"]) == 0 then
                            self._last_select_dbid = nil --如果当前改名卡的数量为0 ，则把self._last_select_dbid 置为nil
                        end
                        XTHDTOAST("改名成功!")
                        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
                        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})        --刷新数据信息
                    end
                end
                self:refreshListWhenOpenBox()
            end), 1000)
        end
        return
    elseif tonumber(item_data["itemid"]) == 2303 then----------------------刷新令
        if item_data["count"] > 0 then
            requires("src/fsgl/layer/WanBaoGe/WanBaoGe.lua"):createWithType(1, {par = self})
        end
        return
    elseif tonumber(item_data["itemid"]) == 2305 then------------------------------重生灵牌
        if item_data["count"] > 0 then
            local _layer = requires("src/fsgl/layer/YingXiong/YingXiongLayer.lua"):create()
            LayerManager.pushModule(_layer)
        end
        return
    elseif tonumber(item_data["itemid"]) == 2306 then------------------------------英雄密令
        if item_data["count"] > 0 then
            XTHD.createExchangeLayer(self,nil,nil)
        end
        return
    elseif tonumber(item_data["itemid"]) == 2307 then------------------------------神兵号角
        if item_data["count"] > 0 then
            XTHD.createExchangeLayer(self,nil,nil,1)
        end
        return
    elseif tonumber(item_data["itemid"]) == 2308 then------------------------------种族变更卡
        if item_data["count"] > 0 then
            self:changeCamp()
        end
        return
	elseif  tonumber(item_data["itemid"]) == 2314 then
		local StoredValue = requires("src/fsgl/layer/TieJiangPu/TieJiangPuLayer.lua"):create()
        LayerManager.addLayout(StoredValue, {par = self})
		StoredValue:setTabClickFunc(2)
		return
    end

    local function useItems(_count)
            ClientHttp:requestAsyncInGameWithParams({
            modules = "useItem?",
            params = {itemId=item_data["itemid"],baseId=gameUser.getUserId(),param=tostring(_count),charType=0},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
            successCallback = function(data)
            if tonumber(data.result) == 0 then
                local _addvalue =  nil
                
                local mType = tonumber(item_type) or 0
                if mType ~= 6 then
                    _addvalue =  tonumber(effectvalue)*_count
                end
                
                if mType == 1 then
                    XTHDTOAST(LANGUAGE_SHOP_TIPS4..tostring(_addvalue)) --------"增加银两x"..tostring(_addvalue))
                elseif mType == 2 then
                    XTHDTOAST(LANGUAGE_SHOP_TIPS5..tostring(_addvalue)) -------"增加元宝x"..tostring(_addvalue))
                elseif mType == 3 then
                    XTHDTOAST(LANGUAGE_SHOP_TIPS6..tostring(_addvalue)) --------"增加体力x"..tostring(_addvalue))
                elseif mType == 4 then
                    XTHDTOAST(LANGUAGE_SHOP_TIPS7..tostring(_addvalue)) --------------"增加经验x"..tostring(_addvalue))
                elseif mType == 6 then
                    -- XTHDTOAST(LANGUAGE_SHOP_TIPS8) ---------"宝箱开启成功")
                elseif mType == 8 then
                    XTHDTOAST(LANGUAGE_SHOP_TIPS9..tostring(_addvalue))----------"增加翡翠x"..tostring(_addvalue))
                elseif mType == 8 then
                    XTHDTOAST(LANGUAGE_SHOP_TIPS10..tostring(_addvalue))--------------"增加精力x"..tostring(_addvalue))
                elseif mType == 11 or mType == 10 then
                    XTHDTOAST(LANGUAGE_SHOP_TIPS11..tostring(_addvalue))--------------"升级到VIP"..tostring(_addvalue))
                    if tonumber(data.silverSurplusSum) then
                        gameUser.setGoldSurplusExchangeCount(data.silverSurplusSum)
                    end
                    if tonumber(data.feicuiSurplusSum) then
                        gameUser.setFeicuiSurplusExchangeCount(data.feicuiSurplusSum)
                    end
                    if tonumber(data.timeVipCd) then
                        gameUser.setTimeVipCd(data.timeVipCd)
                    end
                    if data.expItemSurplusSum then
                        gameUser.setExpItemSurplusSum(data.expItemSurplusSum)
                    end
                elseif mType == 12 then
                    XTHDTOAST(LANGUAGE_SHOP_TIPS14..tostring(_addvalue))--------------"增加韬略x"..tostring(_addvalue))
                elseif mType == 13 then
                    XTHDTOAST("获得鲜花x"..tostring(_addvalue))----------"获得鲜花x"..tostring(_addvalue))
                end
                if mType == 6 then
                    for i=1,#data["items"]  do
                        local _data = data["items"][i] 
                        if _data then
                            DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
                            if self._last_select_dbid == _data["dbId"] and tonumber(_data["count"]) == 0 then
                                self._last_select_dbid = nil --如果当前宝箱的数量为0 ，则把self._last_select_dbid 置为nil
                            end
                        end
                    end
                    local show_data = {}
                    for i=1,#data["addItem"] do
                        local _tab = string.split(data["addItem"][i], ",")
                        show_data[#show_data+1] = {rewardtype = 4,id = _tab[1],num = _tab[2]}
                    end
                     ShowRewardNode:create(show_data)
                     self:updateBoxCount(data["items"][1]["count"])
                     self:refreshListWhenOpenBox()
                else
                    local items_data = data["items"][1]
                    DBTableItem.updateCount(gameUser.getUserId(),item_data,items_data["dbId"])
                    self:upDateJson(item_data["dbid"],items_data["count"])

                    if tonumber(items_data["count"]) > 0  then
                        --在这种情况下其实只需要刷新当前选中道具的数量
                         self:ShowItemDetailPanel(item_idx,true)
                    elseif tonumber(items_data["count"]) <= 0  then
                        if tonumber(table.nums(self._tableDataSource) ) > 0 then
                            local newIdx = item_idx <= table.nums(self._tableDataSource) and item_idx or table.nums(self._tableDataSource)
                            self._last_select_item = nil
                            self._last_select_dbid = self._tableDataSource[newIdx].dbid
                            self:ShowItemDetailPanel(table.nums(self._tableDataSource),false)
                            self._ItemTableview:reloadDataAndScrollToCurrentCell()
                        end
                    end
                end
                local property = data.property
                for i=1,#property do
                    local _tab = string.split(property[i], ",")
                    if tonumber(data["charType"]) == 0 then --主角信息的变更
                        DBUpdateFunc:UpdateProperty( "userdata", _tab[1], _tab[2] )
                        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
                    else --武将信息的变更
                        -- XTHDTOAST(" XingNangLayer line 414 error");
                    end
                end
                if mType == 10 or mType == 11 then
                    local vip_levelup = requires("src/fsgl/layer/Vip/VipLevelUpLayer1.lua")
                    self:addChild(vip_levelup:create(), 10)
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "vip",["visible"] = true}})
                end

                local itemEffecttype = tonumber(item_data.effecttype)
                if itemEffecttype == 1 or 
                    itemEffecttype == 2 or 
                    itemEffecttype == 3 or 
                    itemEffecttype == 6 or 
                    itemEffecttype == 8 or 
                    itemEffecttype == 10 then

                    self._redPointNum = self._redPointNum - tonumber(_count)

                    if self._redPointNum <= 0 then
                        self._redDot:setVisible(false)
                        gameUser.setPackageRedPoint(0)
                    end
                end
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "bag"}})
            else
                XTHDTOAST(data.msg)
            end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })

    end
    local mType = tonumber(item_type) or 0
    if tonumber(item_data["count"]) > 5 and mType ~= 10 then
        self:showBatchDialog(useItems,item_data["count"])   --使用道具数量确认框
    else
        useItems(1)
    end
   
end
function XingNangLayer:numberOfCellsInTableView(table_view)
    return  math.ceil(#self._tableDataSource / 5)
end
function XingNangLayer:tableCellAtIndex( table_view, idx )

    local cell = table_view:dequeueCell();
    if cell then
        for i=1,5 do
            local _item = cell:getChildByTag(i)
            if _item and _item == self._last_select_item then
                self._last_select_item = nil
            end
        end
        cell:removeAllChildren()
    else
        cell = cc.TableViewCell:new()
    end
    cell:setContentSize(self:cellSizeForTable(table_view,idx))
    for i=1,5 do
        local item_data = self._tableDataSource[5*idx +i]

        if item_data then
            local _tmp_data = clone(item_data)
            _tmp_data["strengLevel"] = 0
            local item = ZhuangBeiItem:createClickedItem(_tmp_data)
            item:setEnableWhenMoving(true)
            item._cellidx = idx
            item:setTag(i)
            item:setScale(0.75)

            if item_data.item_type == 3 then
                item_data.strengLevel = item_data.strengLevel or 0
                if item_data.strengLevel > 0 then
                    -- local label_level = getCommonWhiteBMFontLabel()
                    local label_level = cc.LabelTTF:create(item_data.strengLevel, "def.ttf", 18)
                    label_level:setColor( cc.c3b(255,255,255) )
                    -- local _width = 28
                    -- if tonumber(label_level:getContentSize().width)>28 then
                        local _width = label_level:getContentSize().width + 4
                    -- end

                    local level_bg = cc.Sprite:createWithTexture(nil,cc.rect(0,0,_width,19))
                    level_bg:setColor(cc.c3b(0,0,0))
                    level_bg:setOpacity( 125.0 )
                    level_bg:setAnchorPoint(0,0)
                    level_bg:setPosition(4,25)

                    label_level:setAnchorPoint(cc.p(0.5,0.5))
                    label_level:setCascadeColorEnabled(true)
                    label_level:setPosition(level_bg:getContentSize().width/2, level_bg:getContentSize().height / 2)

                    item:addChild(level_bg)
                    level_bg:addChild(label_level)
                end
                --特效
                if tonumber(_tmp_data.quality)>3 then
                    XTHD.addEffectToEquipment(item,_tmp_data.quality)
                end
            end

            --item_select_box
            local select_box = ccui.Scale9Sprite:create("res/image/illustration/selected.png")
            -- select_box:setContentSize(item:getContentSize().width+20,item:getContentSize().height+20)
            select_box:setPosition(item:getContentSize().width/2, item:getContentSize().height/2)
            select_box:setName("select_box")
            item:addChild(select_box,3)
            select_box:setVisible(false)
            local _name_ = string.gsub(item_data["dbid"], " ", "") 
            item:setName(_name_)
            
            if self._last_select_dbid then
                if self._last_select_dbid == string.gsub(item_data["dbid"], " ", "") then
                    select_box:setVisible(true)
                    self._last_select_item = item
                     if self._last_select_idx and self._last_select_idx == 5*idx +i then
                    else
                        self:ShowItemDetailPanel(5*idx +i)
                    end
                end
            else
                if self._last_select_idx then
                    if self._last_select_idx < #self._tableDataSource then
                        -- self._last_select_dbid = self._tableDataSource[self._last_select_idx+1]["dbid"]  --改变为选中下一个 
                        -- self._last_select_dbid = self._tableDataSource[self._last_select_idx]["dbid"]    --改为选中当前的
                       self._last_select_dbid = self._tableDataSource[math.floor((self._last_select_idx-1)/5)*5+1]["dbid"]   --改为选中当前行的第一个
                        string.gsub(self._last_select_dbid, " ", "") 
                        -- print("sell  >>>>>11 " .. math.floor((self._last_select_idx-1)/4)*4+1)
                    else
                         self._last_select_dbid = self._tableDataSource[#self._tableDataSource]["dbid"]   
                         string.gsub(self._last_select_dbid, " ", "")
                    end
                    if self._last_select_idx == math.floor((self._last_select_idx-1)/5)*5+1 then
                        self:ShowItemDetailPanel(self._last_select_idx)
                    else
                         if self._last_select_dbid and _name_ == self._last_select_dbid then
                            -- print("sell  >>>>>22 " ..4*idx +i)
                            select_box:setVisible(true)
                            self._last_select_item = item
                            self:ShowItemDetailPanel(5*idx +i)
                        end
                    end
                else
                    if idx == 0 and i == 1 then
                        select_box:setVisible(true)
                        self:ShowItemDetailPanel(5*idx +i)
                        self._last_select_dbid =  _name_  
                        self._last_select_item = item
                    end
                end
            end

            item:setTouchEndedCallback(function()
                if self._last_select_item and self._last_select_item == item then
                    return
                else
                    if self._last_select_item then
                        if self._last_select_item:getChildByName("select_box") then
                            self._last_select_item:getChildByName("select_box"):setVisible(false)
                        end
                    end
                    self._last_select_dbid =item:getName()  
                    string.gsub(self._last_select_dbid, " ", "") 
                    item:getChildByName("select_box"):setVisible(true)
                    self._last_select_item = item
                    self:ShowItemDetailPanel(5*idx +i)
                end
            end)

            item:setAnchorPoint(0,0)
            item:setPosition(8+(i-1)*84, 0)
            cell:addChild(item)
        end
    end

    return cell
end
function XingNangLayer:cellSizeForTable( table_view, idx )
    return  table_view:getContentSize().width, 84
end

--用来更新数据 ，如果一个物品全部使用或者全部出售，则需要把该项从数据源中删除
function XingNangLayer:upDateJson(dbId,item_count)
  
    for i= #self._ItemTotalData,1 ,-1 do
        if self._ItemTotalData[i] then
            if tostring(self._ItemTotalData[i]["dbid"]) ==tostring(dbId)  then
                if tonumber(item_count) == 0 then
                    table.remove(self._ItemTotalData,i)
                    DBTableItem.deleteData(gameUser.getUserId(),dbId)
                else
                    DBTableItem.updateCount(gameUser.getUserId(),{["count"] = item_count},dbId)
                    self._ItemTotalData[i]["count"] = item_count
                end
            end
        end
        if self._tableDataSource[i] then 
            if tostring(self._tableDataSource[i]["dbid"]) == tostring(dbId) then
                if tonumber(item_count) == 0 then
                    table.remove(self._tableDataSource,i)
                else
                    self._tableDataSource[i]["count"] = item_count
                end
            end
        end
    end
    if #self._tableDataSource == 0 then
        self:doAction("hide")
        self._tip_label:stopAllActions()
        self._tip_label:runAction(cc.FadeIn:create(0.2))
        self.tipLabel:stopAllActions()
        self.tipLabel:runAction(cc.FadeIn:create(0.2))

        self._ItemTableview:reloadData()
    else
        self._tip_label:setOpacity(0)
        self.tipLabel:setOpacity(0)

         if tonumber(item_count) > 0 then
             if self._last_select_item then
                self._ItemTableview:updateCellAtIndex(tonumber(self._last_select_item._cellidx))
             else
                self._ItemTableview:reloadDataAndScrollToCurrentCell()
             end
        else
            self._last_select_item = nil
            self._last_select_dbid = nil
            self._ItemTableview:reloadDataAndScrollToCurrentCell()
        end
    end
end

function XingNangLayer:refreshListWhenOpenBox()
    self._ItemTotalData =  DBTableItem.getData(gameUser.getUserId(),nil,nil)
    self:ChangeBtnStatusAndRefreshData(self._last_selected_btn,"refresh_from_box")
end
function XingNangLayer:ChangeBtnStatusAndRefreshData(sender,refresh_from_box)
    --[[
        1.消耗品
        2.魂石
        3.装备
        4.碎片，碎片
        5.玄符
    ]]
    if self._last_selected_btn ~= nil then
        self._last_selected_btn:setSelected(false)
        self._last_selected_btn:setLocalZOrder(0)

    elseif self._last_selected_btn and self._last_selected_btn == sender then
        if not refresh_from_box then
            return
        end
    end
    sender:setSelected(true)
    sender:setLocalZOrder(1)

    self._last_selected_btn = sender

    local tag = sender:getTag()
    self._tableDataSource = {}

    if tonumber(tag) == 5 then
         self._tableDataSource = self._ItemTotalData
    else
        for i=1,#self._ItemTotalData do
            if tonumber(self._ItemTotalData[i]["item_type"]) == tonumber(tag) then
                self._tableDataSource[#self._tableDataSource + 1] = self._ItemTotalData[i]
            end
        end
    end

    local function sortFunc( a, b )
        if a.item_type ~= b.item_type then
            return a.item_type > b.item_type
        end
        if a.quality ~= b.quality then
            return a.quality > b.quality
        end
        return a.itemid < b.itemid
    end

    table.sort(self._tableDataSource, sortFunc)

    if self._ItemTableview then
        if #self._tableDataSource == 0 then
            self:doAction("hide")
            self._tip_label:stopAllActions()
            self._tip_label:runAction(cc.FadeIn:create(0.2))
            self.tipLabel:stopAllActions()
            self.tipLabel:runAction(cc.FadeIn:create(0.2))

            self:ShowItemDetailPanel(1)
            self._ItemTableview:reloadData()

        else
            self:doAction("show")
            self._tip_label:stopAllActions()
            self._tip_label:setOpacity(0)
            self.tipLabel:stopAllActions()
            self.tipLabel:setOpacity(0)
        end
        --当开宝箱然后刷新数据的时候，会走着，但是如果剩余宝箱的数量 >0 ，则此处_last_select_dbid 置空是不对的，因为一刷新选中位置就不对了
        self._last_select_item = nil
        
        self._last_select_idx = nil
        if not refresh_from_box then
            self._last_select_dbid = nil
        end
        self._ItemTableview:reloadData()
    end
end

function XingNangLayer:onCleanup()
    RedPointManage:getDynamicItemData()
    RedPointManage:reFreshDynamicHeroData()
end

function XingNangLayer:ctor()
    self:setOpacity(50)

    self._ItemTotalData =  DBTableItem.getData(gameUser.getUserId(),nil,nil)
    -- print("道具信息为：")
    -- print_r(self._ItemTotalData)
    if self._ItemTotalData.dbid then
        --当只有一条数据的时候 嵌套一层table 否则得到的长度是0
        self._ItemTotalData = {self._ItemTotalData}
    end
    self._redPointNum = 0 --记录红点标识物品的个数
    if self._ItemTotalData then
        for i = 1, #self._ItemTotalData do
            local eType =  tonumber(self._ItemTotalData[i].effecttype)
            if eType == 1 or 
                eType == 2 or 
                eType == 3 or 
                eType == 6 or 
                eType == 8 or 
                eType == 10 then
                
                -- dump(self._ItemTotalData[i])
                self._redPointNum = self._redPointNum + tonumber(self._ItemTotalData[i].count)
            end
        end 
    end

    self:InitUI(self._ItemTotalData)
end
function XingNangLayer:create()
    local layer =self.new()
     return layer
end

function XingNangLayer:updateBoxCount( count )
    local owm_label = self._inner_left_bg:getChildByName("owm_label")
    self._count_label:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
        self._count_label:setString(tostring(count))
        self._count_label:setPosition(owm_label:getPositionX()+owm_label:getContentSize().width, self._count_label:getPositionY())
    end),cc.FadeIn:create(0.2)))
end

return XingNangLayer