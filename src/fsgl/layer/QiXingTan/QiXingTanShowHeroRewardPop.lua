--Create By hezhitao 2015年05月22日
--抽英雄界面
local bet = 0.9

local QiXingTanShowHeroRewardPop = class("QiXingTanShowHeroRewardPop",function ()
    return XTHDDialog:create()
end)

function QiXingTanShowHeroRewardPop:ctor(param)

    self._param = {} 
    self._effect_tab = {}  --存放特效，为了提高播放动画的效率，提前加载动画
    self._item_name = {}   --通过查表获取装备名字
    self._item_tab = {}    --存放Item/Hero Node 使用
    self._data = param
    self._parent = param.parent

    --存放转换召唤石的数据
    self._ex_effect_tab = {}  --存放特效，为了提高播放动画的效率，提前加载动画
    self._ex_item_name = {}   --通过查表获取装备名字
    self._ex_item_tab = {}  

    self._btn_is_click = true  --设置按钮是否可点，防止快速点击出现问题

    self._juan_zhou_bg = nil
    self._img_bg = nil
    self._gold_num = nil
    


     --如果其中有一个大于1，则表示是抽了10次
    local times = 1
    if #param["resultList"] > 1 or #param["addPets"] > 1 then
        times = 10
    else
        times = 1
    end
   
    local size = cc.Director:getInstance():getWinSize()
    local bg = XTHD.createSprite()
    bg:setContentSize(XTHD.resource.visibleSize)
    bg:setPosition(size.width/2, size.height/2)
    self:addChild(bg)

    local img_bg = cc.Sprite:create("res/image/exchange/reward/reward_background.png") 
    img_bg:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
    bg:addChild(img_bg)
    self._img_bg = img_bg

     --加载UI
    self:dealWithData( param )

end

--获取再抽一/十次按钮
function QiXingTanShowHeroRewardPop:getTryAgainButton( try_times )
    local try_again = XTHD.createCommonButton({
        btnColor = "write",
        isScrollView = false,
        btnSize = cc.size(240, 46),
        endCallback = function()
            --判断再抽抽奖的类型
            local targetNum = self.rewardType == 1 and 1 or 10*bet
            current_num = 0
            if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}) then
                current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}).count or 0
            end
            if current_num < targetNum then
                self:noItemsDialog(2306)
            else
                self:doHttpRequest(try_times)
            end
        end,
        text = "",
    })

    --元宝图标
    local gold_icon = XTHD.createSprite("res/image/common/yxmlicon1.png")
    gold_icon:setPosition(try_again:getPositionX()+250,try_again:getPositionY()+35)
    try_again:addChild(gold_icon)

    -- 当前拥有的英雄密令
    local current_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}) then
        current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}).count or 0
    end
    -- local cost_num = gameData.getDataFromCSV("QxtRecruitmentNeeds",{id = 1}).costparam
    -- local spend_num = (tonumber(try_times) == 1 and cost_num) or (tonumber(try_times)-1)*tonumber(cost_num)
    local spend_txt = getCommonLabel(current_num.."/1")
    spend_txt:setPosition(gold_icon:getPositionX()+gold_icon:getContentSize().width/2,gold_icon:getPositionY()-6)
    spend_txt:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
    spend_txt:setAnchorPoint(0,0.5)
    try_again:addChild(spend_txt)
    self.spend_txt = spend_txt

    --再抽一/十次
    local image_path = ""
    if tonumber(try_times) > 1 then
        image_path = LANGUAGE_BTN_KEY.zaichoushici
        spend_txt:setString(current_num.."/"..10*bet)
        self.rewardType = 10*bet
    else
        image_path = LANGUAGE_BTN_KEY.zaichouyici
        spend_txt:setString(current_num.."/1")
        self.rewardType = 1
    end
    local one_or_ten = try_again:getLabel()
    one_or_ten:setString(image_path)
    one_or_ten:setAnchorPoint(0.5, 0.5)
    one_or_ten:setPosition(cc.p(try_again:getContentSize().width/2,try_again:getContentSize().height/2 + 3))

    --打折
    -- local dazhe = XTHD.createSprite("res/image/exchange/reward/reward_dazhe.png")
    -- dazhe:setPosition(try_again:getContentSize().width-25,50)
    -- try_again:addChild(dazhe)

    -- if tonumber(try_times) > 1 then
    --     dazhe:setVisible(true)
    -- else
    --     dazhe:setVisible(true)
    -- end

    try_again:setCascadeOpacityEnabled(true)

    return try_again
end

function QiXingTanShowHeroRewardPop:noItemsDialog(_itemid)
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

function QiXingTanShowHeroRewardPop:refreshBuyLabel()
    local current_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}) then
        current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}).count or 0
    end

    if self.rewardType == 1 then
        self.spend_txt:setString(current_num.."/1")
    else
        self.spend_txt:setString(current_num.."/"..10*bet)
    end
end

--抽取英雄第一次特效
function QiXingTanShowHeroRewardPop:doActionForTen( params )

    local function try_again_callback(  )
        --确定按钮
        -- if param and param["addPets"] and #param["addPets"] == 0 
        --   and param["resultList"] and #param["resultList"] == 0 then
        --     self:toExchangeEquip()
        --     self._btn_is_click = false
        --     return
        -- end
        local be_ok = XTHD.createCommonButton({
            btnColor = "write_1",
            isScrollView = false,
            text = LANGUAGE_BTN_KEY.sure,
            fontSize = 22,
            btnSize = cc.size(130,46),
            pos = cc.p(self._img_bg:getContentSize().width/2,160+30+65),
            endCallback = function()     
                if self._btn_is_click == true then
                    self:toExchangeEquip()
                    self._btn_is_click = false
                end
            end
        })
        be_ok:setName("be_ok")
        self._img_bg:addChild(be_ok)
    end

    local play_times = 0
    local size = XTHD.createSprite("res/image/common/item_blueBg.png"):getContentSize().width
    --播放特效在此处使用递归实现
    local function playEffectOneByOne(  )
        play_times = play_times + 1
        
        local item = self._item_tab[play_times]
        if not item then
            return
        end
        local x = 1
        local y = self._juan_zhou_bg:getContentSize().height/2+50

        if play_times < 6 then
            x = 103+play_times*120
            y = self._juan_zhou_bg:getContentSize().height/2+110
        else
            x = 103+(play_times-5)*120
            y = self._juan_zhou_bg:getContentSize().height/2-10
        end
        item:setPosition(x,y)
        self._juan_zhou_bg:addChild(item)

        --闪烁动画
        local flash_effect =  self._effect_tab[play_times]
        flash_effect:setPosition(x,y)
        self._juan_zhou_bg:addChild(flash_effect)
        flash_effect:setAnimation(0,"animation",false)

        --抽到3星英雄，需要播放特效
        if item.show_type == 1 then
            local star = gameData.getDataFromCSV("GeneralInfoList", {heroid = item["id"]})["star"] or 1
            if tonumber(star) >= 3 then
                local xingxing_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/teshu.json", "res/spine/effect/exchange_effect/teshu.atlas",1 )
                xingxing_effect:setPosition(x,y)
                xingxing_effect["is_new"] = item["is_new"]
                xingxing_effect:setAnimation(0,"animation",true)
                self._juan_zhou_bg:addChild(xingxing_effect)
                xingxing_effect:setTag(1000+play_times)
            end
        end

        item:setScale(0.1)
        -- flash_effect:setScale(0.3)
        local item_name = self._item_name[play_times]
        item_name:setPosition(x,y-60)
        self._juan_zhou_bg:addChild(item_name)

        local scale = size/item:getContentSize().width
        musicManager.playEffect("res/sound/sound_effect_drawcard.mp3")
        item:runAction(cc.Sequence:create( cc.ScaleTo:create(0.1,scale),cc.CallFunc:create(function (  )
            if play_times <= #self._effect_tab then
                if item["is_new"] == true then   --抽到新英雄
                    local layer = requires("src/fsgl/layer/QiXingTan/QiXingTanGetNewHeroLayer.lua"):create({
                        par = self,
                        id = item["id"],
                        star = item["star"],
                        callBack = playEffectOneByOne
                    })
                else
                    playEffectOneByOne()
                end
            end
        end) ))

        if play_times == #self._effect_tab then
            try_again_callback()
        end
    end   

     self:runAction(cc.Sequence:create( cc.DelayTime:create(0.2),cc.CallFunc:create(function (  )
        playEffectOneByOne()
    end) ))
end

--转换为召唤石的特效
function QiXingTanShowHeroRewardPop:doActionForTenSecond( ... )

    for i=1,#self._ex_item_tab do
        local x = 1
        local y = self._juan_zhou_bg:getContentSize().height/2+50

        if i < 6 then
            x = 103+i*120
            y = self._juan_zhou_bg:getContentSize().height/2+110
        else
            x = 103+(i-5)*120
            y = self._juan_zhou_bg:getContentSize().height/2-10
        end

        --需要转换为召唤石的item
        local item = self._ex_item_tab[i]

        --判断是否抽到新英雄，如果是新英雄，则不用转换为召唤石

        if not item["is_new"] and item["id"] and item["itemId"] then
            item:setPosition(x,y)
            self._juan_zhou_bg:addChild(item)
            item:setOpacity(0)
            item:runAction(cc.FadeIn:create(1))

            --显示英雄的Item，主要是为了实现渐隐和移除操作
            local before_item = self._item_tab[i]
            before_item:runAction(cc.Sequence:create( cc.DelayTime:create(0.7),cc.FadeOut:create(0.3),cc.CallFunc:create(function (  )
                before_item:removeFromParent()
            end) ))

            --英雄的名字
            local before_name = self._item_name[i]
            before_name:runAction(cc.Sequence:create( cc.FadeOut:create(0.5),cc.CallFunc:create(function (  )
                before_name:removeFromParent()
            end) ))

            --召唤石名字
            local new_name = self._ex_item_name[i]
            new_name:setPosition(x,y-60)
            self._juan_zhou_bg:addChild(new_name)
            new_name:setOpacity(0)
            new_name:runAction(cc.Sequence:create( cc.DelayTime:create(0.5),cc.FadeIn:create(0.5) ))

            local scan_effect = self._ex_effect_tab[i]
            scan_effect:setPosition(x,y+6)
            self._juan_zhou_bg:addChild(scan_effect)
            scan_effect:setAnimation(0,"animation",false)

        end
    end

    --按钮的渐隐
    local before_be_ok = self._img_bg:getChildByName("be_ok")
    if before_be_ok ~= nil then
        before_be_ok:runAction(cc.Sequence:create( cc.FadeOut:create(0.5),cc.CallFunc:create(function (  )
            before_be_ok:removeFromParent()
            -- self._btn_is_click = true
        end) ))
    end

    --再抽十次按钮的渐现显示
    local try_again = self:getTryAgainButton(10)
    try_again:setPosition(self._img_bg:getContentSize().width/3+30,190+65)
    self._img_bg:addChild(try_again)

    --确定按钮

    local be_ok = XTHD.createCommonButton({
        text = LANGUAGE_BTN_KEY.sure,
        isScrollView = false,
        fontSize = 22,
        btnSize = cc.size(130,46),
        pos = cc.p(self._img_bg:getContentSize().width/3*2,try_again:getPositionY()),
        endCallback = function()     
            LayerManager.popModule()
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_QIXINGTAN_NUMLABLE})
        end
    })
    be_ok:setCascadeOpacityEnabled(true)
    self._img_bg:addChild(be_ok)

    try_again:setOpacity(0)
    be_ok:setOpacity(0)

    try_again:runAction(cc.Sequence:create( cc.DelayTime:create(0.5),cc.FadeIn:create(0.5) ))
    be_ok:runAction(cc.Sequence:create( cc.DelayTime:create(0.5),cc.FadeIn:create(0.5) ))
end

--抽取十次后，点击确定，处理数据及播放动画
function QiXingTanShowHeroRewardPop:toExchangeEquip(  )

    --播放转换召唤石动画
    local flash_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/zhsm.json", "res/spine/effect/exchange_effect/zhsm.atlas",1 )
    flash_effect:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2+53)
    -- self._img_bg:addChild(flash_effect)
    flash_effect:setAnimation(0,"animation",false)

    local isFlashEffect = false
    if self._data and self._data["resultList"] and #self._data["resultList"] ~= 0 then      
        for i =1, #self._data["resultList"] do
            if self._data["resultList"][i].itemId == 2302 then
                isFlashEffect = true
                break
            end
        end
        self._img_bg:addChild(flash_effect)
    end

    if #self._item_tab > 1 then
        self:dealWithDataForShow(self._data)
        flash_effect:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2+53)
    else
        self:dealWithDataForShow(self._data)
        flash_effect:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2+150)
    end

    if isFlashEffect then
        flash_effect:setVisible(true)
    else 
        flash_effect:setVisible(false)
    end
end

--抽取一次动画
function QiXingTanShowHeroRewardPop:doActionForOne(  )
    local item = self._item_tab[1]
    item:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2+12)
    self._img_bg:addChild(item)

     --闪烁动画
    local flash_effect =  self._effect_tab[1]
    flash_effect:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2+12)
    self._img_bg:addChild(flash_effect)
    flash_effect:setAnimation(0,"animation",false)

    local item_name = self._item_name[1]
    item_name:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2-48)
    self._img_bg:addChild(item_name)


    item:setScale(0.1)
    local size = XTHD.createSprite("res/image/common/item_blueBg.png"):getContentSize().width
    local scale = size/item:getContentSize().width
    item:runAction(cc.Sequence:create( cc.ScaleTo:create(0.1,scale),cc.CallFunc:create(function (  )
            -- if item["is_new"] == true then   --抽到新英雄

            --     function callback(  )
            --         self:doActionForButton(0,0)
            --     end

            --     local layer = requires("src/fsgl/layer/QiXingTan/QiXingTanGetNewHeroLayer.lua"):create(item["id"],item["star"],callback)
            --     self:addChild(layer)

            -- end
        end) ))

end
--抽取一次动画
function QiXingTanShowHeroRewardPop:doActionForOneSecond(  )

    --需要转换为召唤石的item
    local item = self._ex_item_tab[1]
    local x = self._img_bg:getContentSize().width/2
    local y = self._img_bg:getContentSize().height/2+12
    --判断是否抽到新英雄，如果是新英雄，则不用转换为召唤石
    if item == nil then
        -- cc.Director:getInstance():popScene()
        LayerManager.popModule()
        return
    end
    if item["is_new"] == false then   
        
        item:setPosition(x,y)
        self._img_bg:addChild(item)
        item:setOpacity(0)
        item:runAction(cc.FadeIn:create(1))

        --显示英雄的Item，主要是为了实现渐隐和移除操作
        local before_item = self._item_tab[1]
        before_item:runAction(cc.Sequence:create( cc.DelayTime:create(0.7),cc.FadeOut:create(0.3),cc.CallFunc:create(function (  )
            before_item:removeFromParent()
        end) ))

        --英雄的名字
        local before_name = self._item_name[1]
        before_name:runAction(cc.Sequence:create( cc.FadeOut:create(0.5),cc.CallFunc:create(function (  )
            before_name:removeFromParent()
        end) ))

        --召唤石名字
        local new_name = self._ex_item_name[1]
        new_name:setPosition(x,y-60)
        self._img_bg:addChild(new_name)
        new_name:setOpacity(0)
        new_name:runAction(cc.Sequence:create( cc.DelayTime:create(0.5),cc.FadeIn:create(0.5) ))

        local scan_effect = self._ex_effect_tab[1]
        scan_effect:setPosition(x,y + 8)
        self._img_bg:addChild(scan_effect)
        scan_effect:setAnimation(0,"animation",false)

    end
    -- self._btn_is_click = true
    self:doActionForButton(0.5,0.5)

end

function QiXingTanShowHeroRewardPop:doActionForButton( delaytime,dt )
    --按钮的渐隐
    local before_be_ok = self._img_bg:getChildByName("be_ok")
    if before_be_ok ~= nil then
        before_be_ok:runAction(cc.Sequence:create( cc.FadeOut:create(dt),cc.CallFunc:create(function (  )
            before_be_ok:removeFromParent()
        end) ))
    end

    --再抽十次按钮的渐现显示
    local try_again = self:getTryAgainButton(1)
    try_again:setPosition(self._img_bg:getContentSize().width/3+30,190)
    self._img_bg:addChild(try_again)

    --确定按钮
    local be_ok = XTHD.createCommonButton({
        text = LANGUAGE_BTN_KEY.sure,
        isScrollView = false,
        fontSize = 22,
        btnSize = cc.size(130,46),
        pos = cc.p(self._img_bg:getContentSize().width/3*2,try_again:getPositionY()),
        endCallback = function()  
            if self._parent then
                self._parent:refreshBuyLabel()
            end   
            LayerManager.popModule()
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_QIXINGTAN_NUMLABLE})
        end
    })
    be_ok:setCascadeOpacityEnabled(true)
    self._img_bg:addChild(be_ok)
    self.guide_okayBtn = be_ok

    try_again:setOpacity(0)
    be_ok:setOpacity(0)

    try_again:runAction(cc.Sequence:create( cc.DelayTime:create(delaytime),cc.FadeIn:create(dt) ))
    be_ok:runAction(cc.Sequence:create( cc.DelayTime:create(delaytime),cc.FadeIn:create(dt) ))
end

--初始化一个奖励装备界面
function QiXingTanShowHeroRewardPop:initOne( param )

    self._img_bg:removeAllChildren()
    local img_bg = self._img_bg
    self:addMengBan(img_bg)

    local function play_action( showBtn )
        local light_circle = cc.Sprite:create("res/image/exchange/reward/reward_light_circle.png")
        light_circle:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2+30)
        img_bg:addChild(light_circle)
        light_circle:setScale(0.8)
         --光圈动画
        light_circle:runAction(cc.Sequence:create( cc.DelayTime:create(0.1333),cc.CallFunc:create(function (  )
            musicManager.playEffect("res/sound/sound_effect_drawcard.mp3")
            self:doActionForOne()
        end),cc.CallFunc:create(function (  )
            -- light_circle:setScale(1)
            light_circle:setVisible(false)
        end),cc.DelayTime:create(0.067), cc.CallFunc:create(function (  )
            light_circle:setVisible(true)
        end),cc.CallFunc:create(function (  )
            --调用特效
            -- self:doActionForOne()
        end),cc.CallFunc:create(function (  )
            
        end)))
        light_circle:runAction(cc.RepeatForever:create( cc.RotateBy:create(1,15) ))

        --台子
        local taizi = cc.Sprite:create("res/image/exchange/taizi.png")
        taizi:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2-20)
        img_bg:addChild(taizi)

         -- 框的动画
        local frame_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/kuang.json", "res/spine/effect/exchange_effect/kuang.atlas",1 );
        frame_effect:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2)
        img_bg:addChild(frame_effect)
        frame_effect:setAnimation(0,"animation3",false)
        frame_effect:setOpacity(0)

        --恭喜获得静图
        local gxhd = cc.Sprite:create("res/image/exchange/gxhd.png")
        gxhd:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2+178)
        img_bg:addChild(gxhd)
         --标题动画(恭喜获得)
        local title_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/gxhd.json", "res/spine/effect/exchange_effect/gxhd.atlas",1 );
        title_effect:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2-145)
        img_bg:addChild(title_effect)
        title_effect:setAnimation(0,"animation",false)
        title_effect:setOpacity(0)
        local _showBtn = showBtn == nil and true or showBtn
        if _showBtn then
            --确定按钮
            local be_ok = XTHD.createCommonButton({
                text = LANGUAGE_BTN_KEY.sure,
                isScrollView = false,
                fontSize = 22,
                btnSize = cc.size(130,46),
                pos = cc.p(img_bg:getContentSize().width/2,100),
                endCallback = function()     
                    if self._btn_is_click == true then
                        self:toExchangeEquip()
                        self._btn_is_click = false
                    end
                end
            })
            be_ok:setName("be_ok")
            img_bg:addChild(be_ok)
        end
    end

    local item = self._item_tab[1]
    if item and item["is_new"] == true then   --抽到新英雄
        function callback(  )
            play_action()
            self:doActionForButton(0,0)
        end
        local layer = requires("src/fsgl/layer/QiXingTan/QiXingTanGetNewHeroLayer.lua"):create({
            par = self,
            id = item["id"],
            star = item["star"],
            callBack = callback})
        -- self:addChild(layer)
    else
        if not item or not item.id then
            play_action(false)
            self:toExchangeEquip()
            self._btn_is_click = false
        else
            play_action()
        end
    end

        
end

--初始化十个奖励装备界面
function QiXingTanShowHeroRewardPop:initTen(param )
    --初始化数据
    self._img_bg:removeAllChildren()
    self._juan_zhou_bg = nil
    local img_bg = self._img_bg

    self:addMengBan(img_bg)

     --卷轴动画
    local juan_zhou = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/juanzhou.json", "res/spine/effect/exchange_effect/juanzhou.atlas",1 );
    juan_zhou:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2-30)
    img_bg:addChild(juan_zhou)
    juan_zhou:setAnimation(0,"animation",false)

    --初始化的时候juan_zhou的size是0，所以在此处要创建一个跟卷轴大小一个的layer
    local juan_zhou_bg = XTHD.createSprite()
    juan_zhou_bg:setContentSize(cc.size(925,420))
    juan_zhou_bg:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2)
    img_bg:addChild(juan_zhou_bg)
    self._juan_zhou_bg = juan_zhou_bg

    local light_circle = cc.Sprite:create("res/image/exchange/reward/reward_light_circle.png")
    light_circle:setPosition(juan_zhou:getContentSize().width/2,230)
    juan_zhou:addChild(light_circle)
    light_circle:setScale(0.8)
    light_circle:runAction(cc.RepeatForever:create( cc.RotateBy:create(1,15) ))

     --恭喜获得静图
     local gxhd = cc.Sprite:create("res/image/exchange/gxhd.png")
     gxhd:setPosition(juan_zhou:getContentSize().width/2,230)
     juan_zhou:addChild(gxhd)
     --标题动画
    local title_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/gxhd.json", "res/spine/effect/exchange_effect/gxhd.atlas",1 );
    title_effect:setPosition(juan_zhou:getContentSize().width/2,juan_zhou:getContentSize().height/2+10)
    juan_zhou:addChild(title_effect)
    title_effect:setAnimation(0,"animation",false)
    title_effect:setOpacity(0)

    --播放动画
    self:doActionForTen(param)
end


function QiXingTanShowHeroRewardPop:doHttpRequest( do_times )
    --recruitType = 1 表示英雄， recruitType = 2 表示道具
     ClientHttp:requestAsyncInGameWithParams({
        modules = "recruitRequest?",
        params = {recruitType=1,sum=do_times,activityId=0},
        successCallback = function(data)
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败")
            return
        end

        if  tonumber(data.result) == 0 then
            --刷新用户数据
            gameUser.setIngot(data.ingot)
            --刷新左上角元宝数量
            --self._gold_num:setString( getHugeNumberWithLongNumber(gameUser.getIngot(),1000000) )
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 

            --获取新的数据
            self._data = data
            if tonumber(do_times) == 1 then
                self:dealWithData( data )
            else
                if self._img_bg ~= nil then
                    self._img_bg:removeAllChildren()
                end
                self:dealWithData(data)
           end
			self._parent:refreshBuyLabel()
           self._btn_is_click = true
        else
            XTHDTOAST(data.msg)
        end
          
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

--根据idx创建不同的node
function QiXingTanShowHeroRewardPop:createNode( _type,idx )
    if _type == 2 then
        local num = self._param[idx].count
        local item = ItemNode:createWithParams({
                _type_ = 4,
                itemId = self._param[idx].itemId,
                count = num ,
                needSwallow = true
            })
        return item
    elseif _type == 1 then
        local item = HeroNode:createWithParams({
                heroid = self._param[idx].id,
                needSwallow = true,
                level = -1,
                advance = 1,
                star = self._param[idx].starLevel
            })
        return item
    end
end

--预加载资源
function QiXingTanShowHeroRewardPop:loadDataForHero( param )

    --清空数据
    self:releaseHeroData()
    local size = XTHD.createSprite("res/image/common/item_blueBg.png"):getContentSize().width
    for i=1, #self._param do
        local item_data = self._param[i]
        --加载Item
        local item = self:createNode(item_data["show_type"],i)
        local scale = size/item:getContentSize().width
        item:setScale(scale)
        item:retain()
        item["is_new"] = item_data["is_new"]
        item["id"] = item_data["id"]
        item["star"] = item_data["starLevel"]
        item["show_type"] = item_data["show_type"]

        self._item_tab[#self._item_tab+1] = item

        --加载特效
        local flash_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/tubiao.json", "res/spine/effect/exchange_effect/tubiao.atlas",1 )
        --必须要retain一下,否则会被回收
        flash_effect:retain()
        self._effect_tab[#self._effect_tab+1] = flash_effect

        --如果为抽取一次，则用白色字体
--        if #self._data["resultList"] > 1 or #self._data["addPets"] > 1 then
--            font_color = cc.c3b(0,0,0)
--        else
--            font_color = cc.c3b(0,0,0)
--        end

        --加载item的名字
        local name
		local quality
        if item_data["show_type"] == 1 then
            name = gameData.getDataFromCSV("GeneralInfoList",{heroid = item_data.id}).name
			quality = gameData.getDataFromCSV("GeneralInfoList",{heroid = item_data.id}).rank
        else
            name = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = item_data.itemId}).name
			quality = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = item_data.itemId}).rank
        end
        local label = XTHDLabel:createWithParams({
            text = name,
            fontSize = 18,
            color = XTHD.resource.getQualityItemColor( quality )
        })
		label["quality"] = quality
        label:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
        label:retain()
        self._item_name[#self._item_name+1] = label
    end

    --加载UI
    if #self._item_tab > 1 then
        self:initTen(param)
    else
        self:initOne(param)
    end

end

--预加载资源
function QiXingTanShowHeroRewardPop:loadDataForEquip(  )

    --清空数据
    self:releaseEquipData()

    local size = XTHD.createSprite("res/image/common/item_blueBg.png"):getContentSize().width
    for i=1,#self._param do
        local item_data = self._param[i]
        --加载Item
        local item = self:createNode(item_data["show_type"], i)
        local scale = size/item:getContentSize().width
        item:setScale(scale)
        item:retain()
        item["is_new"] = item_data["is_new"]
        item["id"] = item_data["id"]
        item["itemId"] = item_data["itemId"]
        self._ex_item_tab[#self._ex_item_tab+1] = item

        --加载特效
        local scan_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/yxzhs.json", "res/spine/effect/exchange_effect/yxzhs.atlas",1 )
        --必须要retain一下,否则会被回收
        scan_effect:retain()
        self._ex_effect_tab[#self._ex_effect_tab+1] = scan_effect

         --如果为抽取一次，则用白色字体
--        if #self._data["resultList"] > 1 or #self._data["addPets"] > 1 then
--            font_color = cc.c3b(0,0,0)
--        else
--            font_color = cc.c3b(0,0,0)
--        end

        --加载item的名字
        local name = ""
        if item_data["show_type"] == 1 then
            name = gameData.getDataFromCSV("GeneralInfoList",{heroid = item_data.id}).name
			quality = gameData.getDataFromCSV("GeneralInfoList",{heroid = item_data.id}).rank
        else
            name = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = item_data.itemId}).name
			quality = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = item_data.itemId}).rank
        end
        local label = XTHDLabel:createWithParams({
            text = name,
            fontSize = 18,
            color = XTHD.resource.getQualityItemColor( quality )
            })
		label["quality"] = quality
        label:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
        label:retain()
        self._ex_item_name[#self._ex_item_name+1] = label
    end


    --加载动画
    if #self._item_tab > 1 then
        self:doActionForTenSecond()
    else
        self:doActionForOneSecond()
    end

end

--处理数据
function QiXingTanShowHeroRewardPop:_countData( param, doType )
    --清空数据
    self._param = {}
    local _count = param.resultList and #param.resultList or 0
    if _count > 0 then
        local _data
        for i=1, _count do
            _data = param.resultList[i]
            local tmp_tab = {}
            if _data.showType == 1 then
                tmp_tab.id = _data.petId
                tmp_tab.starLevel = _data.starLevel
                tmp_tab.is_new = true
                tmp_tab.show_type = 1
            elseif _data.showType == 2 then
                tmp_tab.id = _data.petId
                tmp_tab.starLevel = _data.starLevel
                tmp_tab.itemId = _data.itemId
                tmp_tab.count = _data.itemCount
                tmp_tab.is_new = false
                tmp_tab.show_type = doType
            else
                tmp_tab.itemId = _data.itemId
                tmp_tab.count = _data.itemCount
                tmp_tab.show_type = 2
                tmp_tab.is_new = false
            end
            self._param[#self._param+1] = tmp_tab
        end
    end
end

--显示初始ui结果
function QiXingTanShowHeroRewardPop:dealWithData( param )
    self:_countData(param, 1)
    --更新数据库
    gameData.saveDataToDB(param["addPets"], 1)
    gameData.saveDataToDB(param["bagItems"], 2)

    self:loadDataForHero(param)

end

function QiXingTanShowHeroRewardPop:dealWithDataForShow( param )
    self:_countData(param, 2)
    self:loadDataForEquip()
end

function QiXingTanShowHeroRewardPop:releaseHeroData( ... )

    for i=1,#self._item_tab do
        local item = self._item_tab[i]
        if item ~= nil then
            item:release()
        end
    end


    for i=1,#self._effect_tab do
        local item = self._effect_tab[i]
        if item ~= nil then
            item:release()
        end
    end


    for i=1,#self._item_name do
        local item = self._item_name[i]
        if item ~= nil then
            item:release()
        end
    end

    --清空数据
    self._item_tab = {}
    self._effect_tab = {}
    self._item_name = {}

end

function QiXingTanShowHeroRewardPop:releaseEquipData( ... )

    for i=1,#self._ex_item_tab do
        local item = self._ex_item_tab[i]
        if item ~= nil then
            item:release()
        end
    end


    for i=1,#self._ex_effect_tab do
        local item = self._ex_effect_tab[i]
        if item ~= nil then
            item:release()
        end
    end


    for i=1,#self._ex_item_name do
        local item = self._ex_item_name[i]
        if item ~= nil then
            item:release()
        end
    end

     --清空数据
    self._ex_item_tab = {}
    self._ex_effect_tab = {}
    self._ex_item_name = {}
end

--添加蒙版效果
function QiXingTanShowHeroRewardPop:addMengBan( img_bg )
    local mengban_bg = cc.LayerColor:create()
    mengban_bg:setColor(cc.c3b(0,0,0))
    mengban_bg:setOpacity(127.5)
    mengban_bg:setContentSize(img_bg:getContentSize())
    mengban_bg:setPosition(0,0)
    img_bg:addChild(mengban_bg)
end

function QiXingTanShowHeroRewardPop:create(param,_type)
    local layer = self.new(param,_type)
    return layer
end

function QiXingTanShowHeroRewardPop:onCleanup( ... )
    -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER})
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
    self:releaseHeroData()
    self:releaseEquipData()

     --清理比较大的纹理
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/exchange/reward/reward_background.jpg") 
end

return QiXingTanShowHeroRewardPop