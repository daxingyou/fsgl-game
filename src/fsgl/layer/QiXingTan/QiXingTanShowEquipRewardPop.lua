--Create By hezhitao 2015年05月22日

--[[特效执行流程：处理数据(dealWithData_hero_ten)->预加载资源(loadDataForHero)->加载UI(initTen)->动画(doActionForTen)]]
local bet = 0.9

local QiXingTanShowEquipRewardPop = class("QiXingTanShowEquipRewardPop",function ()
    return XTHDDialog:create()
end)

function QiXingTanShowEquipRewardPop:ctor(param)
    -- self:showPop()
    self:init(param)
end

function QiXingTanShowEquipRewardPop:init( param )
    self._param = {} 
    self._effect_tab = {}  --存放特效，为了提高播放动画的效率，提前加载动画
    self._item_name = {}   --通过查表获取装备名字

    self._juan_zhou_bg = nil
    self._img_bg = nil
    self._gold_num = nil
    self._parent = param.parent


     --如果其中有一个大于1，则表示是抽了10次
     local times = 1
    if #param["resultList"] > 1 then
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
	img_bg:setContentSize(self:getContentSize())
    bg:addChild(img_bg)
    self._img_bg = img_bg
    -- self.popNode = bg

    --  --当前元宝背景
    -- local gold_bg = cc.Sprite:create("res/image/exchange/reward/reward_gold_bg.png")
    -- gold_bg:setPosition(100,bg:getContentSize().height-30)
    -- bg:addChild(gold_bg)

    -- --当前元宝数量
    -- local gold_icon = cc.Sprite:create("res/image/common/common_gold.png")
    -- gold_icon:setPosition(20,gold_bg:getContentSize().height/2)
    -- gold_bg:addChild(gold_icon)

    -- local gold_num = getCommonWhiteBMFontLabel(getHugeNumberWithLongNumber(gameUser.getIngot(),1000000))
    -- gold_num:setPosition(gold_icon:getPositionX()+gold_icon:getContentSize().width/2+5,gold_icon:getPositionY()-5)
    -- gold_num:setAnchorPoint(0,0.5)
    -- gold_bg:addChild(gold_num)

    -- self._gold_num = gold_num

     --为了解决游戏卡顿的情况，先处理数据，然后再播放动画
    if tonumber(times) == 1 then    --抽取装备一次
        self:dealWithData_equip_one(param)
    else                            --处理抽取10次的情况
        self:dealWithData_equip_ten(param)
    end

end

--获取再抽一/十次按钮
function QiXingTanShowEquipRewardPop:getTryAgainButton( try_times )
    local try_again = XTHD.createCommonButton({
        btnSize = cc.size(240, 46),
        isScrollView = false,
        endCallback = function()
            --判断再抽抽奖的类型
            local targetNum = self.rewardType == 1 and 1 or 10*bet
            current_num = 0
            if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}) then
                current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}).count or 0
            end
            if current_num < targetNum then
                self:noItemsDialog(2307)
            else
                self:doHttpRequest(try_times)
            end
        end,
        text = "",
    })
--ly3.26
    --元宝图标
    local gold_icon = XTHD.createSprite("res/image/common/sbhjicon1.png")
    gold_icon:setPosition(try_again:getPositionX()+215,try_again:getPositionY()+35)
    try_again:addChild(gold_icon)

    --消耗的神兵
    local current_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}) then
        current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}).count or 0
    end
    -- local cost_num = gameData.getDataFromCSV("QxtRecruitmentNeeds",{id = 2}).costparam
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
    one_or_ten:setAnchorPoint(cc.p(0.5, 0.5))
    one_or_ten:setPosition(cc.p(try_again:getContentSize().width/2,try_again:getContentSize().height/2))

    -- --打折
    -- local dazhe = XTHD.createSprite("res/image/exchange/reward/reward_dazhe.png")
    -- dazhe:setPosition(try_again:getContentSize().width-25,50)
    -- try_again:addChild(dazhe)

    -- if tonumber(try_times) > 1 then
    --     dazhe:setVisible(true)
    -- else
    --     dazhe:setVisible(false)
    -- end

    return try_again
end

function QiXingTanShowEquipRewardPop:doActionForTen( ... )

    function try_again_callback(  )
        --再抽十次按钮
        local try_again = self:getTryAgainButton(10)
        try_again:setPosition(self._img_bg:getContentSize().width/3+30,160+30)
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
        self._img_bg:addChild(be_ok)
    end

    local play_times = 0
    --播放特效在此处使用递归实现
    local function playEffectOneByOne(  )
        play_times = play_times + 1
        
        local item = ItemNode:createWithParams({
            _type_ = 4,
            itemId = self._param[play_times]["itemId"],
            count = self._param[play_times]["itemCount"] ,
            needSwallow = true
            })
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

        item:setScale(0.08)
        -- flash_effect:setScale(0.3)
        local item_name = self._item_name[play_times]
        item_name:setPosition(x,y-60)
        self._juan_zhou_bg:addChild(item_name)

        --如果是紫装，需要添加特效
        local xingxing_effect = nil
        if item_name and ( (tonumber(item_name["quality"]) >= 4 and tonumber(item_name["sType"]) == 3)
          or (tonumber(item_name["quality"]) >= 5) ) then
            xingxing_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/teshu.json", "res/spine/effect/exchange_effect/teshu.atlas",1 )
            xingxing_effect:setPosition(x,y)
            self._juan_zhou_bg:addChild(xingxing_effect)
            xingxing_effect:setVisible(false)
        end
        musicManager.playEffect("res/sound/sound_effect_drawcard.mp3")
        item:runAction(cc.Sequence:create( cc.ScaleTo:create(0.1, 0.8),cc.CallFunc:create(function (  )
            if play_times < 10 then
                playEffectOneByOne()
            end
            
            if xingxing_effect ~= nil then
                xingxing_effect:setVisible(true)
                xingxing_effect:setAnimation(0,"animation",true)
            end
        end) ))

        if play_times == 10 then
            try_again_callback()
        end
    end

     self:runAction(cc.Sequence:create( cc.DelayTime:create(0.2),cc.CallFunc:create(function (  )
        playEffectOneByOne()
    end) ))
end

function QiXingTanShowEquipRewardPop:doActionForOne(  )
    local item = ItemNode:createWithParams({
        _type_ = 4,
        itemId = self._param[1]["itemId"],
        count = self._param[1]["itemCount"] ,
        needSwallow = true
        })
    item:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2+12)
    self._img_bg:addChild(item)
    item:setClickable(false)

     --闪烁动画
    local flash_effect =  self._effect_tab[1]
    flash_effect:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2+12)
    self._img_bg:addChild(flash_effect)
    flash_effect:setAnimation(0,"animation",false)

    local item_name = self._item_name[1]
    item_name:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2-48)
    self._img_bg:addChild(item_name)

     --如果是紫装，需要添加特效
    local xingxing_effect = nil
    if item_name and ( (tonumber(item_name["quality"]) >= 4 and tonumber(item_name["sType"]) == 3)
          or (tonumber(item_name["quality"]) >= 5) ) then
        xingxing_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/teshu.json", "res/spine/effect/exchange_effect/teshu.atlas",1 )
        xingxing_effect:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2+12)
        self._img_bg:addChild(xingxing_effect)
        xingxing_effect:setVisible(false)
    end

    item:setScale(0.1)
    item:runAction(cc.Sequence:create( cc.ScaleTo:create(0.1,1),cc.CallFunc:create(function (  )
        item:setClickable(true)
            if xingxing_effect ~= nil then
                xingxing_effect:setVisible(true)
                xingxing_effect:setAnimation(0,"animation",true)
            end
        end) ))

end

--初始化一个奖励装备界面
function QiXingTanShowEquipRewardPop:initOne( param )

    self._img_bg:removeAllChildren()
    local img_bg = self._img_bg
    self:addMengBan(img_bg)

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
    -- light_circle:runAction( cc.Sequence:create( cc.DelayTime:create(0.23),cc.RepeatForever:create( cc.RotateBy:create(1,15) ) ) )
    light_circle:runAction(cc.RepeatForever:create( cc.RotateBy:create(1,15) ))

    --台子
    local taizi = cc.Sprite:create("res/image/exchange/taizi.png")
    taizi:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2-20)
    img_bg:addChild(taizi)
     -- 框的动画
    local frame_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/kuang.json", "res/spine/effect/exchange_effect/kuang.atlas",1 );
    frame_effect:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2)
    img_bg:addChild(frame_effect)
    frame_effect:setOpacity(0)
    frame_effect:setAnimation(0,"animation3",false)

    --恭喜获得静图
    local gxhd = cc.Sprite:create("res/image/exchange/gxhd.png")
    gxhd:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2+178)
    img_bg:addChild(gxhd)

     --标题动画
    local title_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/gxhd.json", "res/spine/effect/exchange_effect/gxhd.atlas",1 );
    title_effect:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2-145)
    img_bg:addChild(title_effect)
    title_effect:setAnimation(0,"animation",false)
    --恭喜获得静图
    local gxhd = cc.Sprite:create("res/image/exchange/gxhd.png")
    gxhd:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2+178)
    img_bg:addChild(gxhd)
    title_effect:setOpacity(0)

    --再抽一次按钮
    local try_again = self:getTryAgainButton(1)
    try_again:setPosition(img_bg:getContentSize().width/3+30,100)
    img_bg:addChild(try_again)

    --确定按钮
    local be_ok = XTHD.createCommonButton({
        text = LANGUAGE_BTN_KEY.sure,
        isScrollView = false,
        fontSize = 22,
        btnSize = cc.size(130,46),
        pos = cc.p(img_bg:getContentSize().width/3*2,try_again:getPositionY()),
        endCallback = function()    
            ----引导 
            YinDaoMarg:getInstance():guideTouchEnd() 
            YinDaoMarg:getInstance():releaseGuideLayer()
            ------------------------------------------
            -- cc.Director:getInstance():popScene()
            LayerManager.popModule()
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_QIXINGTAN_NUMLABLE})
        end
    })
    img_bg:addChild(be_ok)
    self.guide_okayBtn = be_ok
end

--初始化十个奖励装备界面
function QiXingTanShowEquipRewardPop:initTen(param )

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
    title_effect:setPosition(juan_zhou:getContentSize().width/2,230)
    juan_zhou:addChild(title_effect)
    title_effect:setOpacity(0)
    title_effect:setAnimation(0,"animation",false)

    self:doActionForTen()
end

function QiXingTanShowEquipRewardPop:refreshBuyLabel()
    local current_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}) then
        current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}).count or 0
    end

    if self.rewardType == 1 then
        self.spend_txt:setString(current_num.."/1")
    else
        self.spend_txt:setString(current_num.."/"..10*bet)
    end
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_QIXINGTAN_NUMLABLE})
end

function QiXingTanShowEquipRewardPop:noItemsDialog(_itemid)
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

function QiXingTanShowEquipRewardPop:doHttpRequest( do_times )
    --recruitType = 1 表示英雄， recruitType = 2 表示道具
     ClientHttp:requestAsyncInGameWithParams({
        modules = "recruitRequest?",
        params = {recruitType=2,sum=do_times,activityId=0},
        successCallback = function(data)

        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            return
        end

        if  tonumber(data.result) == 0 then
           --刷新用户数据
           gameUser.setIngot(data.ingot)
           --刷新左上角元宝数量
           --self._gold_num:setString( getHugeNumberWithLongNumber(gameUser.getIngot(),1000000) )
           XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 

           if tonumber(do_times) == 1 then
                self:dealWithData_equip_one(data)
            else
                self:dealWithData_equip_ten(data)
           end
			self._parent:refreshBuyLabel()
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

function QiXingTanShowEquipRewardPop:dealWithData( param )
    --更新数据库
    gameData.saveDataToDB(param["bagItems"],2)

    --解析天星石
    local txsdata = param["txs"]

    if txsdata ~= nil and txsdata.count ~= nil then
        print("TXS : ".. txsdata.count)
        DBTableItem.updateCount(gameUser.getUserId(),txsdata,txsdata.dbId)
    end
    --清空数据
    self._param = param["resultList"] or {}

    self:releaseEquipData()
     --预加载动画
    for i=1,#self._param do
        local _data = self._param[i]
        local flash_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/tubiao.json", "res/spine/effect/exchange_effect/tubiao.atlas",1 )

        --必须要retain一下,否则会被回收
        flash_effect:retain()

        local table = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = _data.itemId})
        if table then
            local name = table["name"]
            local quality = table["rank"]
            local sType = table["type"]
            local label = XTHDLabel:createWithParams({
                text = name,
                fontSize = 18,
                color = XTHD.resource.getQualityItemColor( quality )
                })
            label["quality"] = quality
            label["sType"] = sType
            label:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
            label:retain()
            self._item_name[#self._item_name+1] = label
        end
    
        self._effect_tab[#self._effect_tab+1] = flash_effect
    end
end

--处理抽一次次的数据
function QiXingTanShowEquipRewardPop:dealWithData_equip_one( param )
    self:dealWithData( param )
   
    --加载UI
    self:initOne( param )

end
--处理抽十次的数据
function QiXingTanShowEquipRewardPop:dealWithData_equip_ten( param ) 
    self:dealWithData( param )

    --加载UI
    self:initTen(param)
end


function QiXingTanShowEquipRewardPop:releaseEquipData( ... )

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
    self._effect_tab = {}
    self._item_name = {}
end


--添加蒙版效果
function QiXingTanShowEquipRewardPop:addMengBan( img_bg )
    local mengban_bg = cc.LayerColor:create()
    mengban_bg:setColor(cc.c3b(0,0,0))
    mengban_bg:setOpacity(127.5)
    mengban_bg:setContentSize(img_bg:getContentSize())
    mengban_bg:setPosition(0,0)
    img_bg:addChild(mengban_bg)
end

function QiXingTanShowEquipRewardPop:create(param,_type)
    local layer = self.new(param,_type)
    return layer
end

function QiXingTanShowEquipRewardPop:onEnter( )
    if self.guide_okayBtn then 
        YinDaoMarg:getInstance():addGuide({ ----点击确定 
            parent = self,
            target = self.guide_okayBtn,
            index = 10,
            updateServer = true,
            needNext = false
        },1)
    end
    YinDaoMarg:getInstance():doNextGuide()   
end

function QiXingTanShowEquipRewardPop:onCleanup( ... )
    --清空数据
    self:releaseEquipData()

     --清理比较大的纹理
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/exchange/reward/reward_background.jpg") 
end

return QiXingTanShowEquipRewardPop