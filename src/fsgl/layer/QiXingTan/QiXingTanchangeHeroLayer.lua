--Create By hezhitao 2015年05月20日
--抽英雄界面
local SCHEDULE_TAY_ONE = 10000
local SCHEDULE_TAY_TEN = 10001
local bet = 0.9  --折扣

local QiXingTanchangeHeroLayer = class("QiXingTanchangeHeroLayer",function ()
    return XTHD.createBasePageLayer({bg = "res/image/exchange/zhaohuan_bg.png"})
end)

function QiXingTanchangeHeroLayer:ctor(data,callback)
    self:initUI(data)
    self._callback = callback	
end

function QiXingTanchangeHeroLayer:initUI(data)
    local topbar = self:getChildByName("TopBarLayer1")
    if topbar then 
        topbar:setNeedReleaseGuide(false)
        ---引导 
        if YinDaoMarg:getInstance():getGuideSteps() == 1 then 
            topbar:setBackCallFunc(function( )
                YinDaoMarg:getInstance():releaseGuideLayer()
                gotoMaincity()
                YinDaoMarg:getInstance():doNextGuide()
            end)
        end 
    end 
    local fontColor = cc.c3b(53,25,26)

    self._one_times_timeDown = nil
    self._tem_times_timeDown = nil
    self._free_font = nil
    self._one_times_cd = 0   --抽英雄cd
    self._one_times_cd1 = 0  --抽装备cd
    -- self._ten_times_cd = 0
    self._free_exchange = nil --免费抽取一次播放特效
    self._one_times_btn = nil
    self._soul_piece_num = nil
    self._element = {}  --用于存放一些局部变量，但是这些局部变量又在它的生命周期之外使用
    self._table_array = {} 

    if data and data["petCD"] then
        self._one_times_cd = tonumber(data["petCD"])
        self._one_times_cd1 = tonumber(data["itemCD"])
    end

    --设置当前可兑换碎片的次数
    local exchangenum = data["exchangePetSum"] or 0
    gameUser.setRecruitExchangeSum(exchangenum)

    local background_bg = XTHD.createSprite("res/image/exchange/exchange_bg.png")
    background_bg:setAnchorPoint(0,0)
    background_bg:setPosition(0,0)
    self:addChild(background_bg)
    background_bg:setScaleX(self:getContentSize().width/background_bg:getContentSize().width)


    --透明层bg放在除去顶部topbar的高度之后的中间，为了适配各种机型
    local size = cc.Director:getInstance():getWinSize()
    local layer_height = size.height - self.topBarHeight
    local bg = XTHD.createSprite()
    bg:setContentSize(XTHD.resource.visibleSize.width,layer_height)
    bg:setPosition(size.width/2, layer_height/2)
    self:addChild(bg)

    --背景
    local sb_bg = cc.Sprite:create("res/image/exchange/qiehuan_bg.png")
    sb_bg:setPosition(bg:getContentSize().width-140,bg:getContentSize().height-70)
    sb_bg:setAnchorPoint(0.8,0.5)
    sb_bg:setScale(0.8)
    bg:addChild(sb_bg)
    
    local _normalNode = cc.Sprite:create("res/image/exchange/exchange_equip2.png")
    local _selectedNode = cc.Sprite:create("res/image/exchange/exchange_equip2.png")
    _selectedNode:setScale(0.8)
    --切换到兑换装备界面
    local change_to_equip = XTHD.createButton({
        normalNode = _normalNode,
        selectedNode = _selectedNode,
        touchSize = cc.size(300,100),
        pos = cc.p(bg:getContentSize().width-127,bg:getContentSize().height-60),
        endCallback = function()
            XTHD.createExchangeLayer(self:getParent(),self,nil,self:getLocalZOrder())       
        end
    })
    bg:addChild(change_to_equip)
    change_to_equip:setScale(0.3)
    self._toEquipBtn = change_to_equip

    local go_tip = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS61,-----"点击进入天降异宝",
        fontSize = 20,
        color = cc.c3b(255,255,255)
    })
    go_tip:setAnchorPoint(1,0.5)
    go_tip:enableShadow(cc.c4b(70,34,34,0),cc.size(0.4,-0.4),1)
    go_tip:setPosition(change_to_equip:getPositionX()-60,change_to_equip:getPositionY()-5)
    bg:addChild(go_tip)

    if data and data["itemCD"] and tonumber(data["itemCD"]) == 0 then
        --可以免费抽取装备
        local red_point_1 = XTHD.createSprite("res/image/common/heroList_redPoint.png")
        red_point_1:setPosition(change_to_equip:getContentSize().width-40,change_to_equip:getContentSize().height-40)
        change_to_equip:addChild(red_point_1)
        red_point_1:setScale(2.5)

        XTHD.dispatchEvent({name = "EXCHANGE_REFRESH_RED_POINT",data = {_type = "equip",free = true}})
    end

    -- local middle_bg = XTHD.createSprite("res/image/exchange/exchange_frame.png")
    local middle_bg = ccui.Scale9Sprite:create("res/image/exchange/exchange_frame.png")
    middle_bg:setContentSize(900,461)
    middle_bg:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2-30)
    bg:addChild(middle_bg)

    -- 图鉴
    local illustration = XTHD.createButton({
        normalFile = "res/image/homecity/menu_illustration1.png",
        selectedFile = "res/image/homecity/menu_illustration2.png",
        pos = cc.p(85,middle_bg:getContentSize().height/2-130),
        endCallback = function()
            XTHD.createIllustrationLayer()
        end
    })
    middle_bg:addChild(illustration)

    heroIcon_bg = cc.Sprite:create("res/image/exchange/hero_bg.png")
    heroIcon_bg:setPosition(middle_bg:getContentSize().width/5+90,middle_bg:getContentSize().height/2)
    heroIcon_bg:setScale(0.8)
    middle_bg:addChild(heroIcon_bg)
    
    local hero_icon = XTHD.createSprite("res/image/exchange/exchange_hero2.png")
    hero_icon:setPosition(heroIcon_bg:getContentSize().width/2,heroIcon_bg:getContentSize().height/2+20)---------------英雄
    -- hero_icon:setScale(0.8)
    heroIcon_bg:addChild(hero_icon)

    --群英降临
    local hero_font = XTHD.createSprite("res/image/exchange/exchange_hero_font.png")
    hero_font:setPosition(95,middle_bg:getContentSize().height/2+50-10)
    hero_font:setScale(0.8)
    middle_bg:addChild(hero_font)

    --可获得背景
    local wenzi_bg = ccui.Scale9Sprite:create("res/image/exchange/wenzi_bg.png")
    wenzi_bg:setPosition(middle_bg:getContentSize().width/2-40,middle_bg:getContentSize().height-100)
    wenzi_bg:setScaleY(0.7)
    wenzi_bg:setScaleX(0.65)
    wenzi_bg:setAnchorPoint(0,1)
    middle_bg:addChild(wenzi_bg)

    local tip_txt1 = XTHDLabel:createWithParams({
        text = LANGUAGE_VERBS.canGet,-------"可获得",
        fontSize = 18,
        color = cc.c3b(0,0,0)
        })
    tip_txt1:setAnchorPoint(0,1)
    tip_txt1:setPosition(middle_bg:getContentSize().width/2-40,middle_bg:getContentSize().height-104)
    middle_bg:addChild(tip_txt1)

    local tip_txt2 = XTHDLabel:createWithParams({
        text = LANGUAGE_EXCHANGE_TEXT[8],-----"英雄或碎片",
        fontSize = 18,
        color = cc.c3b(255,255,0)
        })
    tip_txt2:setAnchorPoint(0,1)
    tip_txt2:setPosition(tip_txt1:getPositionX()+tip_txt1:getContentSize().width+5,tip_txt1:getPositionY())
    middle_bg:addChild(tip_txt2)

    local tip_txt3 = XTHDLabel:createWithParams({
        text = ","..LANGUAGE_TIPS_WORDS63,-------"抽中已有英雄自动转化为",
        fontSize = 18,
        color = cc.c3b(0,0,0)
        })
    tip_txt3:setAnchorPoint(0,1)
    tip_txt3:setPosition(tip_txt2:getPositionX()+tip_txt2:getContentSize().width+5,tip_txt2:getPositionY())
    middle_bg:addChild(tip_txt3)

    local tip_txt5 = XTHDLabel:createWithParams({
        text = LANGUAGE_NAMES.TLStone,-------"召唤石",
        fontSize = 18,
        color = cc.c3b(255,255,0)
        })
    tip_txt5:setAnchorPoint(0,1)
    tip_txt5:setPosition(tip_txt3:getPositionX()+tip_txt3:getContentSize().width+5,tip_txt3:getPositionY())
    middle_bg:addChild(tip_txt5) 

	--首次十连必得高星级英雄
	local tip_txt8 = XTHDLabel:createWithParams({
        text = "首次十连必得高星级英雄",
        fontSize = 18,
        color = cc.c3b(255,255,0)
        })
    tip_txt8:setAnchorPoint(0,1)
    tip_txt8:setPosition(tip_txt3:getPositionX() - 60,tip_txt3:getPositionY() - 35)
    middle_bg:addChild(tip_txt8) 

    -- 当前拥有的英雄密令
    local current_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}) then
        current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}).count or 0
    end

    --抽一次按钮
    local one_times_btn =  XTHD.createCommonButton({
        btnColor = "write",
        btnSize = cc.size(200, 46),
        isScrollView = false,
        pos = cc.p(middle_bg:getContentSize().width*0.5+60, middle_bg:getContentSize().height*0.5+47),
        endCallback = function()
            current_num = 0
            if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}) then
                current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}).count or 0
            end
            if current_num < 1 and self._table_array["this_free_label"]:isVisible() == false then
                self:noItemsDialog(2306)
            else
                self:doHttpRequest(1)
            end
        end,
        text = "招募一次",
    })
    one_times_btn:setScale(0.7)
    middle_bg:addChild(one_times_btn)

    --抽一次字体
    local btn_font_one = one_times_btn:getLabel()
    btn_font_one:setPosition(cc.p(one_times_btn:getContentSize().width*0.5, one_times_btn:getContentSize().height*0.5))

    local one_times_gold = XTHD.createSprite("res/image/common/yxmlicon1.png")
    one_times_gold:setPosition(one_times_btn:getPositionX()-20,one_times_btn:getPositionY()-one_times_gold:getContentSize().height-5)
    middle_bg:addChild(one_times_gold)
    self._table_array["one_times_gold"] = one_times_gold

    local cost_num = gameData.getDataFromCSV("QxtRecruitmentNeeds",{id = 1}).costparam
    local one_spend_diamond_num = getCommonLabel(current_num.."/1") 
    one_spend_diamond_num:setPosition(one_times_btn:getPositionX()+one_times_gold:getContentSize().width-15,one_times_gold:getPositionY())
    middle_bg:addChild(one_spend_diamond_num)
    self._table_array["one_spend_diamond_num"] = one_spend_diamond_num

    local this_free_label = XTHDLabel:createWithParams({
        text = LANGUAGE_BTN_KEY.bencimianfei,
        size = 20,
        color = XTHD.resource.btntextcolor.green,
        anchor = cc.p(0.5, 0.5),
        pos = cc.p(one_times_btn:getPositionX(),one_times_btn:getPositionY()-40),
    })
    middle_bg:addChild(this_free_label)
    self._table_array["this_free_label"] = this_free_label
    self._one_times_btn = one_times_btn

    --抽一次倒计时
    self._one_times_timeDown = XTHDLabel:createWithParams({
        text = getCdStringWithNumber(tonumber(self._one_times_cd),{h=":"}).." "..LANGUAGE_TIPS_AFTER,
        fontSize = 18,
        color = fontColor
        })
    self._one_times_timeDown:setPosition(one_times_btn:getPositionX()-15,one_times_btn:getPositionY()-75)
    middle_bg:addChild(self._one_times_timeDown)

    self._free_font = XTHDLabel:createWithParams({
        text = LANGUAGE_ADJ.free,------"免费",
        fontSize = 18,
        color = cc.c3b(255,255,255)
        })
    self._free_font:setPosition(self._one_times_timeDown:getPositionX()+self._one_times_timeDown:getContentSize().width/2+25,self._one_times_timeDown:getPositionY()-5)
    middle_bg:addChild(self._free_font)
    --抽十次按钮
    local ten_times_btn = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(200, 46),
        isScrollView = false,
        pos = cc.p(one_times_btn:getContentSize().width+one_times_btn:getPositionX()+30,one_times_btn:getPositionY()),
        endCallback = function()
            current_num = 0
            if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}) then
                current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}).count or 0
            end
            if current_num < 10*bet then  --九折
                self:noItemsDialog(2306)
            else
                self:doHttpRequest(10)
            end
        end,
        text = "招募十次",
    })
    ten_times_btn:setScale(0.7)
    middle_bg:addChild(ten_times_btn)
    
    --抽十次字体
    -- local btn_font_ten = ten_times_btn:getLabel()
    -- btn_font_ten:setPosition(cc.p(45,one_times_btn:getContentSize().height/2))

    local ten_times_gold = XTHD.createSprite("res/image/common/yxmlicon1.png")
    ten_times_gold:setPosition(ten_times_btn:getPositionX()-20,ten_times_btn:getPositionY()-ten_times_gold:getContentSize().height - 5)
    middle_bg:addChild(ten_times_gold)

    -- local ten_spend_diamond_num = XTHDLabel:createWithParams({
    --     text = tonumber(cost_num)*9,
    --     fontSize = 25,
    --     color = cc.c3b(255,255,255)
    --     })
    local ten_spend_diamond_num = getCommonLabel(current_num.."/"..10*bet) 
    ten_spend_diamond_num:setPosition(ten_times_btn:getPositionX()+ten_times_gold:getContentSize().width-15,ten_times_gold:getPositionY())
    -- ten_spend_diamond_num:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(2,-2))
    middle_bg:addChild(ten_spend_diamond_num)
    self.tenSpendDiamond = ten_spend_diamond_num

    --打折
    local dazhe = XTHD.createSprite("res/image/exchange/reward/reward_dazhe.png")
    dazhe:setPosition(ten_times_btn:getContentSize().width-20,47)
    ten_times_btn:addChild(dazhe)

    --bg 
    local a_bg = cc.Sprite:create("res/image/exchange/anniu_bg.png")
    a_bg:setPosition(ten_times_btn:getPositionX(),ten_times_btn:getPositionY()-75)
    middle_bg:addChild(a_bg)

    local ten_tip_txt = ccui.RichText:create()
    ten_tip_txt:setPosition(ten_times_btn:getPositionX(),ten_times_btn:getPositionY()-75)
    middle_bg:addChild(ten_tip_txt)
    local re1 = ccui.RichElementText:create(1, fontColor, 255, LANGUAGE_ADJ.mustGet, "Helvetica", 18) ---------------------------------必得
    local re2 = ccui.RichElementText:create(2, cc.c3b(255,255,0), 255,LANGUAGE_TIPS_WORDS100[1], "Helvetica", 18)----------------------英雄
    ten_tip_txt:pushBackElement(re1)
    ten_tip_txt:pushBackElement(re2)
    

    --兑换
    local exchange_show_bg = ccui.Scale9Sprite:create()
    exchange_show_bg:setContentSize(452,54)
    exchange_show_bg:setPosition(middle_bg:getContentSize().width/2+185-30,85)
    middle_bg:addChild(exchange_show_bg)

    -- 每次抽取时必然获得5个召唤石
    local tip_msg = XTHDLabel:createWithParams({
        text = LANGUAGE_EXCHANGE_TEXT[9],-------"每次抽取时必然获得5个召唤石",
        fontSize = 18,
        color = fontColor
        })
    tip_msg:setPosition(260,exchange_show_bg:getContentSize().height/2+65)
    exchange_show_bg:addChild(tip_msg)

    local soul_piece_label = XTHDLabel:createWithParams({
        -- text = LANGUAGE_NAMES.TLStone..":",--------召唤石:",
        text = "召唤石:",--------召唤石:",
        fontSize = 20,
        color = fontColor
    })
    soul_piece_label:enableShadow(cc.c4b(70,34,34,0),cc.size(0.4,-0.4),1)
    soul_piece_label:setPosition(110,exchange_show_bg:getContentSize().height/2+20)
    exchange_show_bg:addChild(soul_piece_label)

    local exchange_piece_icon = XTHD.createSprite("res/image/exchange/exchange_diamond.png")
    exchange_piece_icon:setPosition(soul_piece_label:getPositionX()+soul_piece_label:getContentSize().width/2+25,soul_piece_label:getPositionY())
    exchange_show_bg:addChild(exchange_piece_icon)

    -- self._soul_piece_num = XTHDLabel:createWithParams({
    --     text = "0",
    --     fontSize = 18,
    --     color = fontColor
    --     })
    --背景
    local title_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png")
    title_bg:setPosition(exchange_piece_icon:getPositionX()+20,exchange_piece_icon:getPositionY())
    title_bg:setAnchorPoint(0,0.5)
    exchange_show_bg:addChild(title_bg)
    
    self._soul_piece_num = getCommonWhiteBMFontLabel("0")
    self._soul_piece_num:setAnchorPoint(0.5,1)
    self._soul_piece_num:setPosition(title_bg:getContentSize().width/2,title_bg:getContentSize().height/2+10)
    title_bg:addChild(self._soul_piece_num)

    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}) then
        self._soul_piece_num:setString(gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}).count or 0)
    end

     --进入兑换界面的限制
    local can_enter_sub = true
    local function_table = gameData.getDataFromCSV("FunctionInfoList", {id = 57})
    local unlocktype = function_table["unlocktype"] or 2
    local unlockparam = function_table["unlockparam"] or 1
    local msg_tip = function_table["tip"] or "null"
    if tonumber(unlocktype) == 2 then
        if gameUser.getInstancingId() < tonumber(unlockparam) then
            can_enter_sub = false
        end
    elseif tonumber(unlocktype) == 1 then
        if gameUser.getLevel() < tonumber(unlockparam) then
            can_enter_sub = false
        end
    end

    --兑换按钮

    local exchange_btn = XTHD.createButton({
        normalFile = "res/image/common/btn/duihuan_up.png",
        selectedFile = "res/image/common/btn/duihuan_down.png",
    -- local exchange_btn = XTHD.createCommonButton({
    --     btnColor = "blue",
    --     text = LANGUAGE_BTN_KEY.duihuan,
    --     fontSize = 22,
     --    btnSize = cc.size(130,46),
        pos = cc.p(400,exchange_show_bg:getContentSize().height/2+22),
        endCallback = function()
            if can_enter_sub == true then
                local exchange_hero_sum = requires("src/fsgl/layer/QiXingTan/QiXingTanchangeHeroSubLayer.lua"):create()
                LayerManager.addLayout(exchange_hero_sum, {par = self})
            else
                XTHDTOAST(msg_tip)
            end
        end
    })
    --exchange_btn:getLabel():setPositionX(exchange_btn:getLabel():getPositionX()-15)
    --exchange_btn:getLabel():setPositionY(exchange_btn:getLabel():getPositionY()-10)
    exchange_btn:setScale(0.8)
    exchange_show_bg:addChild(exchange_btn)

    --兑换提示，添加小红点
    local red_point = XTHD.createSprite("res/image/common/heroList_redPoint.png")
    red_point:setPosition(exchange_btn:getContentSize().width,exchange_btn:getContentSize().height)
    exchange_btn:addChild(red_point)
    if tonumber(gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}).count or 0) < 1 or gameUser.getRecruitExchangeSum() < 1 or can_enter_sub == false then
        red_point:setVisible(false)
    else
        red_point:setVisible(true)
    end

    self._element[#self._element+1] = red_point 


    -- print(exchange_btn:getPositionX(),exchange_btn:getPositionY(),"position123")

    --注册一个监听事件，回调方法为callback
    XTHD.addEventListener({name = "UPDATE_PIECE_NUM" ,callback = function()
      --   print("call back UPDATE_PIECE_NUM")
      --   local piece_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}).count or 0
      -- self._soul_piece_num:setString(piece_num)
      --  if tonumber(piece_num) < 1 then
      --     red_point:setVisible(false)
      --   else
      --       red_point:setVisible(true)
      --  end
      if not self._soul_piece_num or not self._element then
            return
        end
        local piece_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}).count or 0
        self._soul_piece_num:setString(piece_num)
       if tonumber(piece_num) < 1 or gameUser.getRecruitExchangeSum() < 1 or can_enter_sub == false then
          self._element[1]:setVisible(false)
        else
          self._element[1]:setVisible(true)
       end
    end})
    
    -- self:checkFreeExchange()
    self:checkFreeExchange()

end


-- --更新碎片数量
-- function QiXingTanchangeHeroLayer:updatePieceNum(  )
--     XTHDTOAST("haha geng xin chenggong")
--     self._soul_piece_num:setString(gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}).count)
-- end

function QiXingTanchangeHeroLayer:refreshData( ... )
    if not self._soul_piece_num or not self._element then
        return
    end
    local piece_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}).count or 0
    self._soul_piece_num:setString(piece_num)
   if tonumber(piece_num) < 1 or gameUser.getRecruitExchangeSum() < 1 then
      self._element[1]:setVisible(false)
    else
      self._element[1]:setVisible(true)
   end
end

function QiXingTanchangeHeroLayer:checkFreeExchange(  )
    self:stopActionByTag(SCHEDULE_TAY_ONE)
    if self._one_times_cd <= 0 then
        self._one_times_timeDown:setString(LANGUAGE_ADJ.free)------"免费")
        self._one_times_timeDown:setPositionX(self._one_times_timeDown:getPositionX()+15)
        self._free_font:setString("")

        --抽奖按钮上的元宝图标和消耗数量消失，显示“本次免费”字样
        self._table_array["one_times_gold"]:setVisible(false)
        self._table_array["one_spend_diamond_num"]:setVisible(false)
        self._table_array["this_free_label"]:setVisible(true)

         --添加免费抽取特效
        self:addEffectForBtn()
        gameUser.setFreeChouHero(1)  --设置可以免费抽取状态
        XTHD.dispatchEvent({name = "EXCHANGE_REFRESH_RED_POINT",data = {_type = "hero",free = true}})
    else
        self._one_times_timeDown:setString(getCdStringWithNumber(self._one_times_cd,{h=":"}).." 后")
        -- self._one_times_timeDown:setPositionX(self._one_times_timeDown:getPositionX()-25)
        self._free_font:setPosition(self._one_times_timeDown:getPositionX()+self._one_times_timeDown:getContentSize().width/2+25,self._one_times_timeDown:getPositionY())
        self._free_font:setString(LANGUAGE_ADJ.free)-----"免费")
        schedule(self,self.timeCountDowmOne,1,SCHEDULE_TAY_ONE)   --倒计时时间调度

         --移除免费抽取特效
        if self._free_exchange ~= nil then
            self._free_exchange:removeFromParent()
            self._free_exchange = nil
        end

        --抽奖按钮上的元宝图标和消耗数量显示，“本次免费”字样消失
        self._table_array["one_times_gold"]:setVisible(true)
        self._table_array["one_spend_diamond_num"]:setVisible(true)
        self._table_array["this_free_label"]:setVisible(false)

        gameUser.setFreeChouHero(0)  --设置不可以免费抽取状态
        XTHD.dispatchEvent({name = "EXCHANGE_REFRESH_RED_POINT",data = {_type = "hero",free = false}})
    end

    --检测是否可以免费抽取，如果不能，则把主城的红点消失
    if tonumber(self._one_times_cd) > 0 and tonumber(self._one_times_cd1) > 0 then
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "chouka",visible = false} })
    end

end

function QiXingTanchangeHeroLayer:refreshBuyLabel()
    local current_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}) then
        current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}).count or 0
    end

    self._table_array["one_spend_diamond_num"]:setString(current_num.."/1")
    self.tenSpendDiamond:setString(current_num.."/"..10*bet)
end

function QiXingTanchangeHeroLayer:noItemsDialog(_itemid)
	local _dialog = XTHDConfirmDialog:createWithParams({
		msg = LANGUAGE_KEY_HERO_TEXT.noItemsToGetTextXc
		,rightCallback = function()
		    local popLayer = requires("src/fsgl/layer/YingXiong/BuyExpByIngotPopLayer1.lua")
		    popLayer= popLayer:create(_itemid, self)
		    popLayer:setName("BuyExpPop")
		    self:addChild(popLayer)
		end
	})
	self:addChild(_dialog)
end

function QiXingTanchangeHeroLayer:doHttpRequest( times )
    --recruitType = 1 表示英雄， recruitType = 2 表示道具
    YinDaoMarg:getInstance():guideTouchEnd()
    ClientHttp:requestAsyncInGameWithParams({
        modules = "recruitRequest?",
        params = {recruitType=1,sum=times},
        successCallback = function(data)
            --获取奖励成功
            if  tonumber(data.result) == 0 then
                ----引导 
                -- YinDaoMarg:getInstance():doNextGuide()
                ------------------------------------------
                --刷新用户数据                self:refreshTopBarData(data)
                self:getHeroReward(data)
                self._one_times_cd = tonumber(data.petCD) - 1
                self._one_times_cd1 = tonumber(data.itemCD)
                self:checkFreeExchange()   
                self:refreshBuyLabel()            
            else
                YinDaoMarg:getInstance():tryReguide()
                XTHDTOAST(data.msg)
            end
            if data["ingot"] then
                gameUser.setIngot(data["ingot"])
            end
            if data["gold"] then
                gameUser.setGold( data["gold"])
            end          
        end,--成功回调
        failedCallback = function()
            YinDaoMarg:getInstance():tryReguide()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function QiXingTanchangeHeroLayer:refreshTopBarData(data)
    if data and data.ingot then
        gameUser.setIngot(data.ingot)
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO}) ---刷新主城市的，
    XTHD.dispatchEvent({name = "EXCHANGE_LAYER_TOPBAR_DATA"}) ---QiXingTanchangeLayer界面的topBar数据
    self:getChildByName("TopBarLayer1"):refreshData()
end

function QiXingTanchangeHeroLayer:getHeroReward( data )
    local _data = data
    if not _data then
        return
    end
    if not _data["addPets"] or not _data["resultList"] then
        return
    end
    _data.parent = self
    local function _goShowReward()
        local showReward = requires("src/fsgl/layer/QiXingTan/QiXingTanShowHeroRewardPop.lua"):create(_data)
        LayerManager.pushModule(showReward)
    end 

    if _data.serverAddress ~= "" and _data.token ~= "" then
        gameUser.setToken(_data.token)
        gameUser.setNewLoginToken(_data.token) 
        GAME_API = _data.serverAddress.."/game/"
        XTHDHttp:requestAsyncWithParams({
            url = _data.serverAddress .. "/game/newLogin?token="..gameUser.getNewLoginToken(),
            successCallback = function( sData )
                if sData.result == 0 then
                    cc.UserDefault:getInstance():setStringForKey(KEY_NAME_LAST_UUID, sData["uuid"])
                    cc.UserDefault:getInstance():flush()
                    gameUser.setSocketIP(0)
                    gameUser.setSocketPort(0)
                    gameUser.initWithData(sData)
                    MsgCenter:getInstance()
                    _goShowReward()
                    return 
                end
                gameUser.setToken(nil)
                LayerManager.backToLoginLayer()
            end,
            failedCallback = function()
                gameUser.setToken(nil)
                LayerManager.backToLoginLayer()
            end,
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    else
        if _data.serverAddress ~= "" then
            MsgCenter:getInstance()
        end
        _goShowReward()
    end
end

function QiXingTanchangeHeroLayer:timeCountDowmOne(  )
    if tonumber(self._one_times_cd) < 1 then
        self:stopActionByTag(SCHEDULE_TAY_ONE)
        self._one_times_timeDown:setString(LANGUAGE_ADJ.free)------"免费")
        self._one_times_timeDown:setPositionX (self._one_times_timeDown:getPositionX()+30)
        self._free_font:setString("")
        self._one_times_cd = 0
         --添加免费抽取特效
        self:addEffectForBtn()

        --抽奖按钮上的元宝图标和消耗数量消失，显示“本次免费”字样
        self._table_array["one_times_gold"]:setVisible(false)
        self._table_array["one_spend_diamond_num"]:setVisible(false)
        self._table_array["this_free_label"]:setVisible(true)


    else
        
        self._one_times_timeDown:setString(LANGUAGE_KEY_TIME_END(getCdStringWithNumber(self._one_times_cd,{h=":"})))-----" 后")
        self._free_font:setPosition(self._one_times_timeDown:getPositionX()+self._one_times_timeDown:getContentSize().width/2+25,self._one_times_timeDown:getPositionY())
        self._free_font:setString(LANGUAGE_ADJ.free)----"免费")
        
        self._one_times_cd = self._one_times_cd-1

        --移除免费抽取特效
        if self._free_exchange ~= nil then
            self._free_exchange:removeFromParent()
            self._free_exchange = nil
        end

    end
    
end
--添加免费抽取特效
function QiXingTanchangeHeroLayer:addEffectForBtn(  )
    
    -- if self._free_exchange == nil then
    --     self._free_exchange = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/mf_15.json", "res/spine/effect/exchange_effect/mf_15.atlas",1 );
    --     self._free_exchange:setPosition(self._one_times_btn:getContentSize().width/2,self._one_times_btn:getContentSize().height/2)
    --     self._one_times_btn:addChild(self._free_exchange)
    --     self._free_exchange:setScaleY(0.85)
    --     self._free_exchange:setAnimation(0,"animation",true)
    --     self._free_exchange:setTimeScale(0.5)    --setTimeScale参数，1表示正常
    -- end
end


function QiXingTanchangeHeroLayer:create(data,callback)
	return QiXingTanchangeHeroLayer.new(data,callback)
end

function QiXingTanchangeHeroLayer:onEnter( )
    ---------------------------------------------------------------------------------------------------
    XTHD.dispatchEvent({name = "UPDATE_PIECE_NUM" });
    self:refreshTopBarData()
    self:addGuide()
end

function QiXingTanchangeHeroLayer:onCleanup( ... )
    ---------------引导 ------------------
    YinDaoMarg:getInstance():releaseGuideLayer()
    ---------------引导 ------------------
    XTHD.removeEventListener("UPDATE_PIECE_NUM")
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_BIBLE })

    if self._callback ~= nil and type(self._callback) == "function" then
        self._callback()
    end

    --清理比较大的纹理
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/exchange/exchange_bg.png") 
    textureCache:removeTextureForKey("res/image/exchange/exchange_frame.png")
end

function QiXingTanchangeHeroLayer:addGuide( )
    YinDaoMarg:getInstance():addGuide({ ----点击抽一次
        parent = self,
        target = self._one_times_btn,
        index = 3,
        updateServer = true,
        needNext = false
    },1)
    -- YinDaoMarg:getInstance():addGuide({ ----点击抽进入天降异宝
    --     parent = self,
    --     target = self._toEquipBtn,
    --     index = 7,
    --     needNext = false
    -- },1)
    local close = self:getChildByName("TopBarLayer1"):getChildByName("topBarBackBtn")
    if close then 
        YinDaoMarg:getInstance():addGuide({ ----点击返回
            parent = self,
            target = close,
            index = 5,
            autoBackMainCity = false,
            needNext = false,
        },1)
    end 
    -- local server = gameUser.getGuideID()
    -- local group = YinDaoMarg:getInstance():getGuideSteps()
    -- if server and server.group == 1 and server.index == 5 and group == 1 then  ------表示已经抽过英雄了
    --     YinDaoMarg:getInstance():skipGuideOnGI(1,7) ---跳到抽装备 
    -- end 
    YinDaoMarg:getInstance():doNextGuide()   
    -------------------
end

return QiXingTanchangeHeroLayer