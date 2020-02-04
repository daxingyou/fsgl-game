--Create By hezhitao 2015年05月20日
--抽装备界面
local SCHEDULE_TAY_ONE = 10000
local SCHEDULE_TAY_TEN = 10001
local bet = 0.9  --折扣

local QiXingTanchangeEquipLayer = class("QiXingTanchangeEquipLayer",function ()
    return XTHD.createBasePageLayer({bg = "res/image/exchange/zhaohuan_bg.png"})
end)

function QiXingTanchangeEquipLayer:ctor(data,callback)
    --1关闭，2装备英雄切换，3抽一次，4抽十次，5兑换,6抽到英雄后的确定按钮
    self._functionButtons = {}
    self:initUI(data)
    self._callback = callback
end

function QiXingTanchangeEquipLayer:initUI(data)

    local topbar = self:getChildByName("TopBarLayer1")
    if topbar then 
        topbar:setNeedReleaseGuide(false)
    end 
    local fontColor = cc.c3b(53,25,26)
    self._one_times_timeDown = nil
    self._tem_times_timeDown = nil
    self._free_font = nil
    self._one_times_cd = 0   --抽取装备cd
    self._one_times_cd1 = 0   --抽取英雄cd
    self._progress_times = 0   --progress_bar执行动作的次数

    self._free_exchange = nil --免费抽取一次播放特效
    self._one_times_btn = nil
    self._table_array = {}  

    self._soul_piece_num = nil
    self._element = {}    --用于存放一些局部变量，但是这些局部变量又在它的生命周期之外使用

    if data["itemCD"] then
        self._one_times_cd = tonumber(data["itemCD"])
    end

     --设置当前可兑换装备的次数
    local exchangenum = data["exchangeItemSum"] or 0
    gameUser.setRecruitExchangeEquipSum(exchangenum)
     --公告
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

    function getMenuNodeTable(filepath)
        local _normalNode = cc.Sprite:create(filepath)
        local _selectedNode = cc.Sprite:create(filepath)
        _selectedNode:setScale(0.8)
        return {
            normalNode = _normalNode,
            selectedNode=_selectedNode,
        }
    end

    --背景
    local sb_bg = cc.Sprite:create("res/image/exchange/qiehuan_bg.png")
    sb_bg:setPosition(bg:getContentSize().width-140,bg:getContentSize().height-70)
    sb_bg:setAnchorPoint(0.8,0.5)
    sb_bg:setScale(0.8)
    bg:addChild(sb_bg)

    --切换到兑换英雄界面
    local _normalNode = cc.Sprite:create("res/image/exchange/exchange_hero.png")
    local _selectedNode = cc.Sprite:create("res/image/exchange/exchange_hero.png")
    _selectedNode:setScale(0.8)
    --切换到兑换装备界面
    local change_to_equip = XTHD.createButton({
        normalNode = _normalNode,
        selectedNode = _selectedNode,
        touchSize = cc.size(300,100),
        pos = cc.p(bg:getContentSize().width-127,bg:getContentSize().height-60),
        endCallback = function()
            XTHD.createExchangeLayer(self:getParent(),nil,nil)       
        end
    })
    bg:addChild(change_to_equip)
    change_to_equip:setScale(0.3)

    local go_tip = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS56,------"点击进入群英降临",
        fontSize = 20,
        color = cc.c3b(255,255,255)
    })
    go_tip:setAnchorPoint(1,0.5)
    go_tip:enableShadow(cc.c4b(70,34,34,0),cc.size(0.4,-0.4),1)
    go_tip:setPosition(change_to_equip:getPositionX()-60,change_to_equip:getPositionY()-5)
    bg:addChild(go_tip)

    self._functionButtons[2] = change_to_equip

    if data and data["petCD"] and tonumber(data["petCD"]) == 0 then
        --可以免费抽取英雄
        local red_point_1 = XTHD.createSprite("res/image/common/heroList_redPoint.png")
        red_point_1:setPosition(change_to_equip:getContentSize().width-75,change_to_equip:getContentSize().height-40)
        change_to_equip:addChild(red_point_1)
        red_point_1:setScale(2.5)

        XTHD.dispatchEvent({name = "EXCHANGE_REFRESH_RED_POINT",data = {_type = "hero",free = true}})
    end
    --背景图
    -- local middle_bg = XTHD.createSprite("res/image/exchange/exchange_frame.png")
    local middle_bg = ccui.Scale9Sprite:create("res/image/exchange/exchange_frame.png")
    middle_bg:setContentSize(900,461)
    middle_bg:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2-30)
    bg:addChild(middle_bg)

    equipIcon_bg = cc.Sprite:create("res/image/exchange/hero_bg.png")
    equipIcon_bg:setPosition(middle_bg:getContentSize().width/5+90,middle_bg:getContentSize().height/2)
    equipIcon_bg:setScale(0.8)
    middle_bg:addChild(equipIcon_bg)

    local equip_icon = XTHD.createSprite("res/image/exchange/exchange_equip.png")
    equip_icon:setPosition(equipIcon_bg:getContentSize().width/2,equipIcon_bg:getContentSize().height/2+10)--------------------天降异宝图
    -- equip_icon:setScale(0.8)
    equipIcon_bg:addChild(equip_icon)

     --天降异宝
    local hero_font = XTHD.createSprite("res/image/exchange/exchange_equip_font.png")
    hero_font:setPosition(95,middle_bg:getContentSize().height/2+50)
    hero_font:setScale(0.8)
    middle_bg:addChild(hero_font)

    --可获得背景
    local wenzi_bg = ccui.Scale9Sprite:create("res/image/exchange/wenzi_bg.png")
    wenzi_bg:setPosition(middle_bg:getContentSize().width/2-40,middle_bg:getContentSize().height-100)
    wenzi_bg:setScaleY(0.7)
    wenzi_bg:setScaleX(0.65)
    wenzi_bg:setAnchorPoint(0,1)
    middle_bg:addChild(wenzi_bg)
    

    local tip_txt = ccui.RichText:create()
    tip_txt:setPosition(middle_bg:getContentSize().width/2+185,middle_bg:getContentSize().height-115)
    middle_bg:addChild(tip_txt)
    local re1 = ccui.RichElementText:create(1, fontColor, 255, LANGUAGE_VERBS.canGet, "Helvetica", 18)------"可获得", "Helvetica", 18)
    local re2 = ccui.RichElementText:create(2, cc.c3b(159, 201, 35), 255,LANGUAGE_EXCHANGE_TEXT[10],"Helvetica", 18)----"稀有道具", "Helvetica", 18)
    local re3 = ccui.RichElementText:create(1, fontColor, 255, LANGUAGE_KEY_AND, "Helvetica", 18)
    local re4 = ccui.RichElementText:create(3, cc.c3b(11,77,89), 255, LANGUAGE_EXCHANGE_TEXT[11],"Helvetica", 18)-------"装备碎片", "Helvetica", 18)
    local re5 = ccui.RichElementText:create(1, fontColor, 255, LANGUAGE_EXCHANGE_TEXT[12],"Helvetica", 18)------"，有概率获得", "Helvetica", 18)
    local re6 = ccui.RichElementText:create(1, cc.c3b(102,44,152), 255, LANGUAGE_EXCHANGE_TEXT[13],"Helvetica", 18)----------"整件", "Helvetica", 18)
    -- local re7 = ccui.RichElementText:create(1, fontColor, 255, LANGUAGE_VERBS.equip, "Helvetica", 18)------"装备", "Helvetica", 18)
    tip_txt:pushBackElement(re1)
    tip_txt:pushBackElement(re2)
    tip_txt:pushBackElement(re3)
    tip_txt:pushBackElement(re4)
    tip_txt:pushBackElement(re5)
    tip_txt:pushBackElement(re6)
    -- tip_txt:pushBackElement(re7)

    -- 当前拥有的神兵密令
    local current_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}) then
        current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}).count or 0
    end

    --抽一次按钮
    local one_times_btn = XTHD.createCommonButton({
        btnColor = "write",
        btnSize = cc.size(200, 46),
        isScrollView = false,
        pos = cc.p(middle_bg:getContentSize().width*0.5+60, middle_bg:getContentSize().height*0.5+47),
        endCallback = function()
            current_num = 0
            if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}) then
                current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}).count or 0
            end
            if current_num < 1 and self._table_array["this_free_label"]:isVisible() == false then
                self:noItemsDialog(2307)
            else
                self:doHttpRequest(1)
            end
        end,
        text = "召唤一次",
    })
    one_times_btn:setScale(0.7)
    middle_bg:addChild(one_times_btn)

    --抽一次字体
    local btn_font_one = one_times_btn:getLabel()
    btn_font_one:setPosition(cc.p(one_times_btn:getContentSize().width*0.5, one_times_btn:getContentSize().height*0.5))
    
    local one_times_gold = XTHD.createSprite("res/image/common/sbhjicon1.png")
    one_times_gold:setPosition(one_times_btn:getPositionX()-20,one_times_btn:getPositionY()-one_times_gold:getContentSize().height-5)
    middle_bg:addChild(one_times_gold)
    self._table_array["one_times_gold"] = one_times_gold

    local cost_num = gameData.getDataFromCSV("QxtRecruitmentNeeds",{id = 2}).costparam
    local one_spend_diamond_num = getCommonLabel(current_num.."/1")
    one_spend_diamond_num:setPosition(one_times_btn:getPositionX()+one_times_gold:getContentSize().width-20,one_times_gold:getPositionY())
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
        text = LANGUAGE_KEY_TIME_END(getCdStringWithNumber(tonumber(self._one_times_cd),{h=":"})),--------" 后",
        fontSize = 18,
        color = fontColor
    })
    self._one_times_timeDown:setPosition(one_times_btn:getPositionX()-15,one_times_btn:getPositionY()-75)
    middle_bg:addChild(self._one_times_timeDown)
    self._functionButtons[3] = one_times_btn

    self._free_font = XTHDLabel:createWithParams({
        text = LANGUAGE_ADJ.free,-----"免费",
        fontSize = 18,
        color = cc.c3b(12,91,16)
        })
    self._free_font:setPosition(self._one_times_timeDown:getPositionX()+self._one_times_timeDown:getContentSize().width/2+25,self._one_times_timeDown:getPositionY())
    middle_bg:addChild(self._free_font)

    -- --判断是否免费
    -- if self._one_times_cd <= 0 then
    --     self._one_times_timeDown:setString("免费")
    --     self._one_times_timeDown:setPositionX(self._one_times_timeDown:getPositionX()+30)
    --     self._free_font:setString("")
    -- else
    --     schedule(self,self.timeCountDowmOne,1,SCHEDULE_TAY_ONE)   --倒计时时间调度
    -- end
    --抽十次按钮
    local ten_times_btn = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(200, 46),
        isScrollView = false,
        pos = cc.p(one_times_btn:getContentSize().width+one_times_btn:getPositionX()+30,one_times_btn:getPositionY()),
        endCallback = function()
            current_num = 0
            if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}) then
                current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}).count or 0
            end
            if current_num < 10*bet then   --九折
                self:noItemsDialog(2307)
            else
                self:doHttpRequest(10)
            end
        end,
        text = "召唤十次",
    })
    ten_times_btn:setScale(0.7)
    middle_bg:addChild(ten_times_btn)
    
    --抽十次字体
    -- local btn_font_ten = ten_times_btn:getLabel()
    -- btn_font_ten:setPosition(cc.p(45,one_times_btn:getContentSize().height/2))

    local ten_times_gold = XTHD.createSprite("res/image/common/sbhjicon1.png")
    ten_times_gold:setPosition(ten_times_btn:getPositionX()-20,ten_times_btn:getPositionY()-ten_times_gold:getContentSize().height-5)
    middle_bg:addChild(ten_times_gold)

    -- local ten_spend_diamond_num = XTHDLabel:createWithParams({
    --     text = tonumber(cost_num)*9,
    --     fontSize = 25,
    --     color = cc.c3b(255,255,255)
    --     })
    local ten_spend_diamond_num = getCommonLabel(current_num.."/"..10*bet)
    ten_spend_diamond_num:setPosition(ten_times_btn:getPositionX()+ten_times_gold:getContentSize().width-17,ten_times_gold:getPositionY())
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
    local re1 = ccui.RichElementText:create(1, fontColor, 255, LANGUAGE_VERBS.canGet,"Helvetica", 18)----"可获得", "Helvetica", 18)
    local re2 = ccui.RichElementText:create(2, cc.c3b(102,44,152), 255,LANGUAGE_EXCHANGE_TEXT[14], "Helvetica", 18)---"更多道具"
    ten_tip_txt:pushBackElement(re1)
    ten_tip_txt:pushBackElement(re2)
    self._functionButtons[4] = ten_times_btn


     --兑换
    -- local exchange_show_bg = XTHD.createSprite("res/image/exchange/exchange_pieceNum_bg.png")
    local exchange_show_bg = ccui.Scale9Sprite:create()
    exchange_show_bg:setContentSize(452,54)
    exchange_show_bg:setPosition(tip_txt:getPositionX()-30,85)
    middle_bg:addChild(exchange_show_bg)

    --进度条
    local bar_bg = XTHD.createSprite("res/image/exchange/sub/sub_bar_bg.png")
    bar_bg:setPosition(cc.p(180,exchange_show_bg:getContentSize().height/2+20))
    exchange_show_bg:addChild(bar_bg)
    bar_bg:setScaleX(0.8)

    -- local tip_msg = XTHDLabel:createWithParams({
    --     text = LANGUAGE_TIPS_WORDS58,-------"每次抽取时必然获得天星石",
    --     fontSize = 18,
    --     color = fontColor
    --     })
    -- tip_msg:setPosition(bar_bg:getPositionX()+60,bar_bg:getPositionY()+45)
    -- exchange_show_bg:addChild(tip_msg)

    local soul_icon = cc.Sprite:create("res/image/exchange/exchange_soul_icon.png")
    soul_icon:setPosition(bar_bg:getPositionX()-bar_bg:getContentSize().width*0.5 +15, bar_bg:getPositionY())
    soul_icon:setAnchorPoint(1,0.5)
    exchange_show_bg:addChild(soul_icon)
    
    local piece_txt = XTHDLabel:createWithParams({
        text = LANGUAGE_NAMES.TJStone,------"天星石:",
        fontSize = 20,
        color = fontColor,
        anchor = cc.p(1,0.5),
        pos = cc.p(soul_icon:getPositionX() - soul_icon:getContentSize().width - 5, soul_icon:getPositionY())
    })
    piece_txt:enableShadow(cc.c4b(70,34,34,0),cc.size(0.4,-0.4),1)
    exchange_show_bg:addChild(piece_txt)

    local progress_bar = cc.ProgressTimer:create(cc.Sprite:create("res/image/exchange/sub/sub_bar.png"))
    progress_bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress_bar:setMidpoint(cc.p(0, 0))
    progress_bar:setBarChangeRate(cc.p(1, 0))
    progress_bar:setPosition(cc.p(bar_bg:getContentSize().width / 2, bar_bg:getContentSize().height / 2))
    progress_bar:setPercentage(0)
    bar_bg:addChild(progress_bar)

    self._element[1] = progress_bar

    local current_equip_piece = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count then
        current_equip_piece = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count or 0
    end

    -- local progress_txt = XTHDLabel:createWithParams({
    --     text = current_equip_piece.."/14",
    --     fontSize = 18,
    --     color = fontColor,
    --     })
    local progress_txt = getCommonWhiteBMFontLabel(current_equip_piece.."/15")
    progress_txt:setPosition(bar_bg:getContentSize().width/2,bar_bg:getContentSize().height/2-6)
    bar_bg:addChild(progress_txt)  
    self._element[2] = progress_txt

   -- exProgress.actionWithProgressBar(progress_bar,(current_equip_piece/14)*100)
   progress_bar:runAction(cc.ProgressTo:create(0.3,(current_equip_piece/15)*100))
    -- function checkExchangeEquip( ... )
    --     if current_equip_piece >= 14 then
    --         XTHDTOAST("能够兑换装备啦")
    --     end
    -- end
    -- checkExchangeEquip()

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
    --     fontSize = 22,
    --     text = LANGUAGE_BTN_KEY.duihuan,
        --btnSize = cc.size(130,46),
        pos = cc.p(400,bar_bg:getPositionY()+4),
        endCallback = function()
            if can_enter_sub == true then
                local exchange_equip_sum = requires("src/fsgl/layer/QiXingTan/QiXingTanchangeEquipSubLayer.lua"):create()
                LayerManager.addLayout(exchange_equip_sum, {par = self})
            else
                XTHDTOAST(msg_tip)
            end
        end
    })
    --exchange_btn:getLabel():setPositionX(exchange_btn:getLabel():getPositionX()-15)
    --exchange_btn:getLabel():setPositionY(exchange_btn:getLabel():getPositionY()-10)
    exchange_btn:setScale(0.8)
    exchange_show_bg:addChild(exchange_btn)

    local red_point = XTHD.createSprite("res/image/common/heroList_redPoint.png")
    red_point:setPosition(exchange_btn:getContentSize().width-10,exchange_btn:getContentSize().height)
    exchange_btn:addChild(red_point)
    self._element[3] = red_point
    if current_equip_piece < 15 or gameUser.getRecruitExchangeEquipSum() < 1 or can_enter_sub == false then
        red_point:setVisible(false)
    else
        red_point:setVisible(true)
    end
    self._functionButtons[5] = exchange_btn
     --注册一个监听事件，回调方法为callback
    XTHD.addEventListener({name = "UPDATE_PIECE_DATA" ,callback = function()
        if not self._element or not self._element[1] or not self._element[2] or not self._element[3] then
            print("return refreshData")
            return
        end

        local tmp_current_equip_piece = 0
        if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count then
            tmp_current_equip_piece = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count or 0
        end

        self._element[2]:setString(tmp_current_equip_piece.."/15")

        -- exProgress.actionWithProgressBar(progress_bar,(tmp_current_equip_piece/14)*100)
        self._element[1]:runAction(cc.ProgressTo:create(0.3,(tmp_current_equip_piece/15)*100))

        if tmp_current_equip_piece < 15 or gameUser.getRecruitExchangeEquipSum() < 1 or can_enter_sub == false then
            self._element[3]:setVisible(false)
        else
            self._element[3]:setVisible(true)
        end

    end})
    self:checkFreeExchange()
end

function QiXingTanchangeEquipLayer:refreshData( ... )
    if not self._element or not self._element[1] or not self._element[2] or not self._element[3] then
        return
    end

    local tmp_current_equip_piece = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count then
        tmp_current_equip_piece = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count or 0
    end

    self._element[2]:setString(tmp_current_equip_piece.."/15")

    -- exProgress.actionWithProgressBar(progress_bar,(tmp_current_equip_piece/14)*100)
    self._element[1]:runAction(cc.ProgressTo:create(0.3,(tmp_current_equip_piece/15)*100))

    if tmp_current_equip_piece < 15 or gameUser.getRecruitExchangeEquipSum() then
        self._element[3]:setVisible(false)
    else
        self._element[3]:setVisible(true)
    end
end


function QiXingTanchangeEquipLayer:timeCountDowmOne(  )
    if tonumber(self._one_times_cd) < 1 then
        
        self:stopActionByTag(SCHEDULE_TAY_ONE)
        self._one_times_timeDown:setString(LANGUAGE_ADJ.free)-------"免费")
        self._one_times_timeDown:setPositionX(self._one_times_timeDown:getPositionX()+30)
        self._free_font:setString("")

        self._one_times_cd = 0

         --添加免费抽取特效
        self:addEffectForBtn()

        --抽奖按钮上的元宝图标和消耗数量消失，显示“本次免费”字样
        self._table_array["one_times_gold"]:setVisible(false)
        self._table_array["one_spend_diamond_num"]:setVisible(false)
        self._table_array["this_free_label"]:setVisible(true)
    else
        
        self._one_times_timeDown:setString(LANGUAGE_KEY_TIME_END(getCdStringWithNumber(self._one_times_cd,{h=":"})))-------" 后")
        self._free_font:setPosition(self._one_times_timeDown:getPositionX()+self._one_times_timeDown:getContentSize().width/2+25,self._one_times_timeDown:getPositionY())
        self._free_font:setString(LANGUAGE_ADJ.free)------"免费")

        self._one_times_cd = self._one_times_cd-1

         --移除免费抽取特效
        if self._free_exchange ~= nil then
            self._free_exchange:removeFromParent()
            self._free_exchange = nil
        end
    end
    
end

--添加免费抽取特效
function QiXingTanchangeEquipLayer:addEffectForBtn(  )
    
    -- if self._free_exchange == nil then
    --     self._free_exchange = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/mf_15.json", "res/spine/effect/exchange_effect/mf_15.atlas",1 );
    --     self._free_exchange:setPosition(self._one_times_btn:getContentSize().width/2,self._one_times_btn:getContentSize().height/2)
    --     self._one_times_btn:addChild(self._free_exchange)
    --     self._free_exchange:setScaleY(0.85)
    --     self._free_exchange:setAnimation(0,"animation",true)
    --     self._free_exchange:setTimeScale(0.5)    --setTimeScale参数，1表示正常
    -- end
end

function QiXingTanchangeEquipLayer:refreshBuyLabel()
    local current_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}) then
        current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}).count or 0
    end

    self._table_array["one_spend_diamond_num"]:setString(current_num.."/1")
    self.tenSpendDiamond:setString(current_num.."/"..10*bet)
end

function QiXingTanchangeEquipLayer:noItemsDialog(_itemid)
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


function QiXingTanchangeEquipLayer:doHttpRequest( times )
    --recruitType = 1 表示英雄， recruitType = 2 表示道具
    -- YinDaoMarg:getInstance():guideTouchEnd()
    ClientHttp:requestAsyncInGameWithParams({
        modules = "recruitRequest?",
        params = {recruitType=2,sum=times},
        successCallback = function(data)
            --获取奖励成功
            if  tonumber(data.result) == 0 then
                ----引导 
                -- YinDaoMarg:getInstance():doNextGuide()
                ------------------------------------------
                 --刷新用户数据
                self:refreshTopBarData(data)
                self:getHeroReward(data)
                self._one_times_cd = tonumber(data.itemCD) - 1
                self._one_times_cd1 = data.petCD
                self:checkFreeExchange() 
                -- dump(data,"点击抽取")
                if data["ingot"] then
                    gameUser.setIngot(data["ingot"])
                end
                if data["gold"] then
                    gameUser.setGold( data["gold"])
                end
                self:refreshBuyLabel()
            else
                -- YinDaoMarg:getInstance():tryReguide()
                XTHDTOAST(data.msg)
            end          
        end,--成功回调
        failedCallback = function()
            -- YinDaoMarg:getInstance():tryReguide()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function QiXingTanchangeEquipLayer:refreshTopBarData(data)
    if data and data.ingot then
        gameUser.setIngot(data.ingot)
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) ---刷新主城市的，
    XTHD.dispatchEvent({name = "EXCHANGE_LAYER_TOPBAR_DATA"}) ---QiXingTanchangeLayer界面的topBar数据
    self:getChildByName("TopBarLayer1"):refreshData()
end

function QiXingTanchangeEquipLayer:getHeroReward( data )
    if not data or not data["addPets"] or not data["resultList"] then
        return
    end
    data.parent = self
    -- local scene = cc.Scene:create()
    local showReward = requires("src/fsgl/layer/QiXingTan/QiXingTanShowEquipRewardPop.lua"):create(data)
    LayerManager.pushModule(showReward)
    -- scene:addChild(showReward)
    -- cc.Director:getInstance():pushScene(scene)

    -- local scene = cc.Scene:create()
    -- local showReward = requires("src/fsgl/layer/QiXingTan/ExShowRewardPoP.lua"):create(data,2)
    -- scene:addChild(showReward)
    -- cc.Director:getInstance():pushScene(scene)
    
end

function QiXingTanchangeEquipLayer:checkFreeExchange(  )
    self:stopActionByTag(SCHEDULE_TAY_ONE)
    if self._one_times_cd <= 0 then
        self._one_times_timeDown:setString(LANGUAGE_ADJ.free)------"免费")
        self._one_times_timeDown:setPositionX(self._one_times_timeDown:getPositionX()+15)
        self._free_font:setString("")

        --添加免费抽取特效
        self:addEffectForBtn()

         --抽奖按钮上的元宝图标和消耗数量消失，显示“本次免费”字样
        self._table_array["one_times_gold"]:setVisible(false)
        self._table_array["one_spend_diamond_num"]:setVisible(false)
        self._table_array["this_free_label"]:setVisible(true)

        gameUser.setFreeChouTools(1)  --设置可以免费抽取状态
        XTHD.dispatchEvent({name = "EXCHANGE_REFRESH_RED_POINT",data = {_type = "equip",free = true}})
    else
        self._one_times_timeDown:setString(LANGUAGE_KEY_TIME_END(getCdStringWithNumber(self._one_times_cd,{h=":"})))------" 后")
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

        gameUser.setFreeChouTools(0)  --设置不可以免费抽取状态
        XTHD.dispatchEvent({name = "EXCHANGE_REFRESH_RED_POINT",data = {_type = "equip",free = false}})
    end
    --检测是否可以免费抽取，如果不能，则把主城的红点消失
    if tonumber(self._one_times_cd) > 0 and tonumber(self._one_times_cd1) > 0 then
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "chouka",visible = false} })
    end
end

function QiXingTanchangeEquipLayer:create(data,callback)
	return QiXingTanchangeEquipLayer.new(data,callback)
end

function QiXingTanchangeEquipLayer:onCleanup( ... )
    XTHD.removeEventListener("UPDATE_PIECE_DATA")
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_BIBLE })
    RedPointManage:reFreshDynamicItemData()
    if self._callback ~= nil and type(self._callback) == "function" then
        self._callback()
    end
    --清理比较大的纹理
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/exchange/exchange_bg.png") 
    textureCache:removeTextureForKey("res/image/exchange/exchange_frame.png")
end

function QiXingTanchangeEquipLayer:onEnter( ) 
    XTHD.dispatchEvent({name = "UPDATE_PIECE_DATA" });
    self:refreshTopBarData()
    -----引导 
    self:addGuide()
end

function QiXingTanchangeEquipLayer:addGuide( )
    -- local close = self:getChildByName("TopBarLayer1"):getChildByName("topBarBackBtn")
    -- YinDaoMarg:getInstance():addGuide({index = 8,parent = self},1) ---- 
    -- YinDaoMarg:getInstance():addGuide({ ----点击抽一次
    --     parent = self,
    --     target = self._one_times_btn,
    --     index = 9,
    --     updateServer = true,
    --     needNext = false
    -- },1)
    -- YinDaoMarg:getInstance():addGuide({index = 11,parent = self},1) ---- 
    -- if close then 
    --     YinDaoMarg:getInstance():addGuide({ ----点击返回
    --         parent = self,
    --         target = close,
    --         index = 12,
    --         needNext = false,
    --     },1)
    -- end 
    -- YinDaoMarg:getInstance():doNextGuide()   
    -------------------
end

return QiXingTanchangeEquipLayer
