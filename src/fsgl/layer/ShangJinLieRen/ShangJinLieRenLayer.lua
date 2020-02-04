--赏金猎人

local ShangJinLieRenLayer = class( "ShangJinLieRenLayer", function ()
	return XTHD.createBasePageLayer({bg = "res/image/goldcopy/background.png"})
end)

local fontColor = cc.c3b(53,25,26)
function ShangJinLieRenLayer:ctor(data)
    self:init(data)
end

function ShangJinLieRenLayer:init( data )

    self._element = {}  --存放各种元素
    self._reward_arr = {}  --存放伤害奖励cell数据
    self._rank_arr = {}    --存放伤害排行cell数据
    self._btn_arr = {}     --存放button
    self._buy_times = data["buySum"] or 1
    self._surplusSum = 0
    self._levelup = data["ectypeLevel"]
    self._totalHurt = 0

    self._seed = 1   --随机数种子

    self._reward_arr = self:readDBData(data)

    local function _doNext()

        --透明层bg放在除去顶部topbar的高度之后的中间，为了适配各种机型
        local size = self:getContentSize()
        local layer_height = size.height - self.topBarHeight
        local bg = XTHD.createSprite()
        bg:setContentSize(XTHD.resource.visibleSize.width,layer_height)
        bg:setPosition(size.width*0.5, layer_height*0.5)
        self:addChild(bg)

         --boss
         local boss = cc.Sprite:create("res/image/goldcopy/boss.png")
         boss:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
         bg:addChild(boss)
         boss:setScale(0.7)

        --用于存放猛犸象副本文字及按钮信息
        -- local font_bg = cc.Sprite:create("res/image/goldcopy/font_bg.png")
        -- font_bg:setAnchorPoint(1,1)
        -- font_bg:setPosition(bg:getContentSize().width,bg:getContentSize().height)
        -- bg:addChild(font_bg)
        -- self._font_bg = font_bg


        --中间分割部分
        -- local millde_line = cc.Sprite:create("res/image/goldcopy/millde_line.png")
        -- millde_line:setPosition(font_bg:getContentSize().width/2,font_bg:getContentSize().height/2+45)
        -- font_bg:addChild(millde_line)  
        
        --新的
        local font_bg1 = ccui.Scale9Sprite:create("res/image/goldcopy/font_bg1.png")
        font_bg1:setContentSize(248,90)
        font_bg1:setAnchorPoint(0,1)
        font_bg1:setPosition(20,bg:getContentSize().height-100)
        bg:addChild(font_bg1)
        

        --狂化张飞
        local boss_font = cc.Sprite:create("res/image/goldcopy/boss_font.png")
        boss_font:setAnchorPoint(0.5,0.5)
        boss_font:setPosition(font_bg1:getContentSize().width/2,font_bg1:getContentSize().height/2)
        font_bg1:addChild(boss_font)

        --升级回调
        local function call_back ( level )
            self._levelup = level
        end

        --kuang2
        local font_bg2 = ccui.Scale9Sprite:create("res/image/goldcopy/font_bg2.png")
        font_bg2:setContentSize(248,90)
        font_bg2:setAnchorPoint(0,0.5)
        font_bg2:setPosition(20,bg:getContentSize().height/2+30)
        
        bg:addChild(font_bg2)
        --应该是这个
        self._font_bg = font_bg2

        --今日排行
        local today_rank = cc.Sprite:create("res/image/goldcopy/today_rank.png")
        today_rank:setAnchorPoint(0.5,0)
        today_rank:setPosition(font_bg2:getContentSize().width/2,font_bg2:getContentSize().height-today_rank:getContentSize().height/2)
        font_bg2:addChild(today_rank)
        self._today_rank = today_rank

        if type(self._rank) == "number" then
            self._rankNum = self:getArtFont(self._rank or 0)
            self._rankNum:setScale(0.8)
           self._rankNum:setAnchorPoint(0.5,0.5)
            self._rankNum:setPosition(today_rank:getPositionX(),font_bg2:getContentSize().height/2)
        else
            self._rankNum = cc.Sprite:create("res/image/goldcopy/022.png")
            self._rankNum:setAnchorPoint(0.5,0.5)
            self._rankNum:setPosition(today_rank:getPositionX(),font_bg2:getContentSize().height/2)
        end
        font_bg2:addChild(self._rankNum)

        --框3
        local font_bg3 = ccui.Scale9Sprite:create("res/image/goldcopy/font_bg2.png")
        font_bg3:setContentSize(248,110)
        font_bg3:setAnchorPoint(0,0.5)
        font_bg3:setPosition(20,bg:getContentSize().height/2-90)
        bg:addChild(font_bg3)
        --闯关信息
        local chuangguan = cc.Sprite:create("res/image/goldcopy/cgxx.png")
        chuangguan:setAnchorPoint(0.5,0)
        chuangguan:setPosition(font_bg3:getContentSize().width/2,font_bg3:getContentSize().height-chuangguan:getContentSize().height/2)
        font_bg3:addChild(chuangguan) 

        --历史最高
        local max_height = cc.Sprite:create("res/image/goldcopy/max_height.png")
        max_height:setAnchorPoint(0.5,0.5)
        max_height:setPosition(font_bg3:getContentSize().width/2-70,font_bg3:getContentSize().height/2+20)
        font_bg3:addChild(max_height)

        --历史最高数字
        local max_num = self:getArtFont(data["maxHurt"] or 0)
        max_num:setScale(0.7)
        max_num:setAnchorPoint(0.5,0.5)
        max_num:setPosition(max_height:getPositionX()+max_height:getContentSize().width+10,max_height:getPositionY())
        font_bg3:addChild(max_num)
        self._element["max_num"] = max_num

        --今日伤害
        local today_hurt = cc.Sprite:create("res/image/goldcopy/today_hurt.png")
        today_hurt:setAnchorPoint(0.5,0.5)
        today_hurt:setPosition(max_height:getPositionX(),max_height:getPositionY()-40)
        font_bg3:addChild(today_hurt)

        --如果今天没有打副本，则显示两个横杠
        local none_data = cc.Sprite:create("res/image/goldcopy/022.png")
        none_data:setAnchorPoint(0.5,0.5)
        none_data:setPosition(today_hurt:getPositionX()+today_hurt:getContentSize().width+10,today_hurt:getPositionY()-7)
        font_bg3:addChild(none_data)
        self._element["none_data"] = none_data

         --今日伤害数字
        local today_hurt_num = self:getArtFont("0")
        today_hurt_num:setScale(0.7)
        today_hurt_num:setAnchorPoint(0.5,0.5)
        today_hurt_num:setPosition(today_hurt:getPositionX()+today_hurt:getContentSize().width+10,today_hurt:getPositionY())
        font_bg3:addChild(today_hurt_num)
        self._element["today_hurt_num"] = today_hurt_num


        self._totalHurt = data["totalHurt"] or 0
        if tonumber(self._totalHurt) <= 0 then
            today_hurt_num:setVisible(false)
            none_data:setVisible(true)
        else
            today_hurt_num:setVisible(true)
            none_data:setVisible(false)
        end
        today_hurt_num:setString(self._totalHurt)

        --奖励
        local reward_btn = XTHDPushButton:createWithParams({
            normalFile = "res/image/goldcopy/reward_btn_normal.png",
            selectedFile = "res/image/goldcopy/reward_btn_selected.png",
            musicFile = XTHD.resource.music.effect_btn_common,
            })
            reward_btn:setScale(0.8)
        reward_btn:setPosition(bg:getContentSize().width-120,bg:getContentSize().height*0.5+reward_btn:getContentSize().height)
        bg:addChild(reward_btn)
        reward_btn:setTouchEndedCallback(function (  )

            local reward_layer = requires("src/fsgl/layer/ShangJinLieRen/ShangJinLieRenRewardPop.lua")
            self:addChild(reward_layer:create(self._reward_arr,self._totalHurt, self._rank), 1)

        end)

         --可领取奖励红点
        local red_point = XTHD.createSprite("res/image/common/heroList_redPoint.png")
        red_point:setPosition(reward_btn:getContentSize().width-15,reward_btn:getContentSize().height-15)
        reward_btn:addChild(red_point)
        self._element["red_point"] = red_point

        --排行
        local rank_btn = XTHDPushButton:createWithParams({
            normalFile = "res/image/goldcopy/rank_btn_normal.png",
            selectedFile = "res/image/goldcopy/rank_btn_selected.png",
            musicFile = XTHD.resource.music.effect_btn_common,
            })
        rank_btn:setPosition(reward_btn:getPositionX()+100,reward_btn:getPositionY())
        bg:addChild(rank_btn)
        rank_btn:setScale(0.8)
        rank_btn:setTouchEndedCallback(function (  )
            local rank_layer = requires("src/fsgl/layer/ShangJinLieRen/ShangJinLieRenRankPop.lua")
            self:addChild(rank_layer:create(self._rank_arr), 1)
        end)

		--升级按钮
        local levelup_btn  = XTHDPushButton:createWithFile({
            normalFile        = "res/image/goldcopy/daxiangtou_normal.png",
            selectedFile      = "res/image/goldcopy/daxiangtou_selected.png",
            musicFile = XTHD.resource.music.effect_btn_common,
        })
        levelup_btn:setPosition(bg:getContentSize().width-80,bg:getContentSize().height*0.5 - 20)
        levelup_btn:setScale(0.8)
        bg:addChild(levelup_btn)
        levelup_btn:setTouchEndedCallback(function (  )
            local _layer = requires("src/fsgl/layer/ShangJinLieRen/ShangJinLieRenLevelUpPop.lua"):create(self._levelup,call_back)
            self:addChild(_layer, 1)
        end)


        local goldStage_data = gameData.getDataFromCSV("SilverGame",{["level"] = self._levelup})

		local node = cc.Node:create()
		node:setAnchorPoint(0.5,0.5)
		node:setContentSize(cc.size(self:getContentSize().width,90))
		bg:addChild(node)
		node:setPosition(bg:getContentSize().width * 0.5,node:getContentSize().height * 0.5)
		
        --挑战次数
        local challenge_label = XTHDLabel:createWithParams({
            text = LANGUAGE_TIP_CHALLENGE_TIMES..":",------ LANGUAGE_KEY_CHALLENGTIMES..":",------挑战次数:",
            fontSize = 24,
			color = cc.c3b(XTHD.resource.textColor.green_text)
            })
        challenge_label:setAnchorPoint(0,0.5)
        challenge_label:setPosition(node:getContentSize().width/2+40,node:getContentSize().height *0.5)
        node:addChild(challenge_label)

        self._surplusSum = data["surplusSum"]
        -- local challenge_num = XTHDLabel:createWithParams({
        --     text = data["surplusSum"] or 0,
        --     fontSize = 18
        --     }) 
        --背景
        local bgg = ccui.Scale9Sprite:create("res/image/common/topbarItem_bg.png")
        bgg:setContentSize(100,38)
        bgg:setPosition(challenge_label:getPositionX()+challenge_label:getContentSize().width+10,challenge_label:getPositionY())
        bgg:setAnchorPoint(0,0.5)
        node:addChild(bgg)

        local challenge_num = getCommonWhiteBMFontLabel(self._surplusSum)
        challenge_num:setAnchorPoint(0.5,0.5)
        challenge_num:setPosition(bgg:getContentSize().width/2,bgg:getContentSize().height/2-8)
        bgg:addChild(challenge_num)
        self._element["challenge_num"] = challenge_num

        --购买挑战次数
        local buy_challenge_times = XTHDPushButton:createWithParams({
                normalFile = "res/image/common/btn/btn_plus_normal.png",
                selectedFile = "res/image/common/btn/btn_plus_selected.png",
                musicFile = XTHD.resource.music.effect_btn_common,
                touchSize = cc.size(80,60)
                })
        buy_challenge_times:setTouchEndedCallback(function (  )
            self:buyChallengeTimes()
        end)
        buy_challenge_times:setPosition(bgg:getContentSize().width,bgg:getContentSize().height/2)
        bgg:addChild(buy_challenge_times)

        --挑战消耗
        local challenge_use_label = XTHDLabel:createWithParams({
            text = LANGUAGE_TIP_CHALLENGE_COST,------"挑战消耗:",
            fontSize = 24,
			color = cc.c3b(XTHD.resource.textColor.green_text)
            })
        challenge_use_label:setAnchorPoint(0.5,0.5)
        challenge_use_label:setPosition(node:getContentSize().width * 0.5 - 200, node:getContentSize().height * 0.5)
        node:addChild(challenge_use_label)

        --包子
        local use_icon = cc.Sprite:create("res/image/common/common_baozi.png")
        use_icon:setPosition(challenge_use_label:getPositionX()+challenge_use_label:getContentSize().width - 20,challenge_use_label:getPositionY())
        node:addChild(use_icon)

        -- local challenge_use_num = XTHDLabel:createWithParams({
        --     text = goldStage_data["hpcost"] or 0,
        --     fontSize = 18
        --     })
        local bgg2 = ccui.Scale9Sprite:create("res/image/common/topbarItem_bg.png")
        bgg2:setContentSize(100,38)
        bgg2:setPosition(use_icon:getPositionX()+use_icon:getContentSize().width/2+10,use_icon:getPositionY())
        bgg2:setAnchorPoint(0,0.5)
        node:addChild(bgg2)

        local challenge_use_num = getCommonWhiteBMFontLabel(goldStage_data["hpcost"])
        challenge_use_num:setAnchorPoint(0.5,0.5)
        challenge_use_num:setPosition(bgg2:getContentSize().width/2,bgg2:getContentSize().height/2-8)
        bgg2:addChild(challenge_use_num)
        self._element["challenge_use_num"] = challenge_use_num

        --开始战斗动画
        -- local attack_btn = XTHD.createFightBtn({
        --     par = bg,
        --     pos = cc.p(bg:getContentSize().width-70,70+20)
        -- })
	

        local attack_btn = XTHD.createButton({
            normalFile = "res/image/common/btn/kstz_up.png",
            selectedFile = "res/image/common/btn/kstz_down.png",
            btnSize = cc.size(142,49),
            anchor = cc.p(0.5, 0.5),
           -- pos = cc.p(bg:getContentSize().width-120,70+50)
        })
        --attack_btn:getLabel():setPosition(attack_btn:getLabel():getPositionX()-15,attack_btn:getLabel():getPositionY()-10)
		attack_btn:setPosition(bg:getContentSize().width-80,levelup_btn:getPositionY() - levelup_btn:getContentSize().height*0.5 - 40)
        bg:addChild(attack_btn)

        attack_btn:setTouchEndedCallback(function (  )
            if tonumber(self._surplusSum) > 0 then
                ----引导
                YinDaoMarg:getInstance():guideTouchEnd() 
                ---------------------------------------------
                LayerManager.addShieldLayout()
                local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongCopyLayer.lua"):create( BattleType.GOLD_COPY_PVE )
                fnMyPushScene(_layer)
            else
                XTHDTOAST(LANGUAGE_TIPS_WORDS32)-----"今日挑战次数不足")
            end
        end)
        self._fightBtn = attack_btn

        --创建透明button
        local op_btn = XTHDPushButton:createWithParams({
            touchSize = cc.size(340,480),
            musicFile = XTHD.resource.music.effect_btn_common,
            })
        op_btn:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
        bg:addChild(op_btn)

        local function star_animate( )
            local _x = {80-237,400-326+15,600-385+32}
            local _y = {100-276,50-275+15,100-321+37}
            for i=1,3 do
                local star = cc.Sprite:create("res/image/goldcopy/star.png")
                star:setPosition(_x[i],_y[i])
                op_btn:addChild(star)
                star:setScale(0.01)

                -- star:runAction( cc.Sequence:create( cc.DelayTime:create(i*0.4),cc.RepeatForever:create( cc.RotateTo:create(1,180) ) ) )
                local dt = 0.25
                star:runAction( cc.Sequence:create( cc.DelayTime:create(i*dt*2),cc.Spawn:create( cc.ScaleTo:create(dt,1.5),cc.RotateTo:create(dt,120) ),cc.Spawn:create( cc.ScaleTo:create(dt,0.01),cc.RotateTo:create(dt,120) ),cc.CallFunc:create(function (  )
                    star:removeFromParent()
                end) ) )
            end
        end

        op_btn:setTouchEndedCallback(function (  )
            self:showTalkingPop(bg,self._levelup)
        end)

        --如果3秒后没有触摸大象，自动弹出说话框
        performWithDelay(self,function (  )
            self:showTalkingPop(bg,self._levelup)
        end,3)

        self:checkRedPoint()

        -- self._is_need_refresh_data 控制场景切回来的时候是否刷新数据
        self._is_need_refresh_data = false
        XTHD.addEventListener({name = "JADITE_IS_NEED_REFRESH" ,callback = function()
            self._is_need_refresh_data = true
        end})

        local tamp_effect_sprite = XTHD.createSprite()
        tamp_effect_sprite:setContentSize(200,200)
        tamp_effect_sprite:setPosition(op_btn:getContentSize().width/2+50,op_btn:getContentSize().height/2)
        op_btn:addChild(tamp_effect_sprite)
        tamp_effect_sprite:setScale(2)


        XTHD.addEventListener({name = "PLAY_EFFECT" ,callback = function()
            local animation = getAnimation("res/image/goldcopy/daxiangshengji_0000",1,15,0.1)
            tamp_effect_sprite:runAction(animation)
            star_animate()
        end})
    end

    self._firstIn = true
    self:refreshRankData(_doNext)
end


--显示说话的泡泡
function ShangJinLieRenLayer:showTalkingPop( node,id )

    self:stopAllActions()
    if node:getChildByName("pop_layer") then
        node:getChildByName("pop_layer"):removeFromParent()
    end

    local data = gameData.getDataFromCSV("SilverGame",{["level"] = id})

    local idx = self._seed % 3 +1

    self._seed = self._seed + 1

    local pop_layer = cc.Sprite:create("res/image/goldcopy/talk_frame.png")
    pop_layer:setPosition(node:getContentSize().width-300,node:getContentSize().height-160)
    pop_layer:setName("pop_layer")
    node:addChild(pop_layer)

    self:stopAllActions()

    local talk_msg = XTHDLabel:createWithParams({
        text = data[tostring("words"..idx)] or "",
        fontSize = 16,
        -- color = fontColor
        })
    talk_msg:setDimensions(190,82)
    talk_msg:setAnchorPoint(0,1)
    talk_msg:setPosition(25,pop_layer:getContentSize().height-10)
    pop_layer:addChild(talk_msg)

    performWithDelay(pop_layer,function (  )
        pop_layer:removeFromParent()
    end,5)
end


function ShangJinLieRenLayer:buyChallengeTimes(  )

    local function doHttpBuy(  )
        ClientHttp:requestAsyncInGameWithParams({
            modules = "buyGoldEctype?",
            -- params = {"configId="..tonumber(configId)},
            successCallback = function(data)
            if not data or next(data) == nil then
                XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
                return
            end

                if data["result"] == 0 then

                    --购买次数增加
                    self._buy_times = self._buy_times + 1
                   --刷新各种数据
                   self._element["challenge_num"]:setString(data["surplusSum"])
                   self._surplusSum = data["surplusSum"]
                   gameUser.setIngot(data["ingot"])
                   XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})      --刷新topbar数据
                   XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) --刷新主城市的，
                   XTHDTOAST(LANGUAGE_TIP_SUCCESS_TO_BUY)------"购买成功")

                else
                    XTHDTOAST(data["msg"])
                end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingParent = self,
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end

    local _confirmLayer = XTHDConfirmDialog:createWithParams( {
            rightCallback = doHttpBuy,
            msg = LANGUAGE_FORMAT_TIPS21(50+15*(tonumber(self._buy_times)+1-1))-------"是否花费"..tostring(10+15*(tonumber(self._buy_times)+1-1)).."元宝购买挑战次数？"
        } );
    self:addChild(_confirmLayer, 1)

end

--读取数据
function ShangJinLieRenLayer:readDBData(data)
   local gold_copy_data = gameData.getDataFromCSV("SilverGameRewardBox")
   -- dump(data,"datadata123")
   -- dump(gold_copy_data,"datadata456")
   local num = #gold_copy_data < #data["list"] and #gold_copy_data or #data["list"]
   for i=1,num do
        gold_copy_data[i].configId = data["list"][i].configId
        gold_copy_data[i].state = data["list"][i].state
   end

   return gold_copy_data
end

function ShangJinLieRenLayer:refreshRankData(callback)
    ClientHttp:requestAsyncInGameWithParams({
        modules = "goldEctypeHurtList?",
        successCallback = function(data)
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end

            if data["result"] == 0 then
                self._rank_arr = data["list"]

                self._rank = LANGUAGE_KEY_OUTOFRANGE
                local selfId = gameUser.getUserId()
                for i = 1, #self._rank_arr do
                    if tonumber(selfId) == tonumber(self._rank_arr[i].passportId) then
                        self._rank = i
                        break
                    end
                end 
                if not self._firstIn and type(self._rank) == "number" then
                    if self._rankNum then
                        self._rankNum:removeFromParent()
                        self._rankNum = nil
                    end
                    self._rankNum = self:getArtFont(self._rank or 0)
                    self._rankNum:setScale(0.8)
                    self._rankNum:setAnchorPoint(0.5,0.5)
                    self._rankNum:setPosition(self._today_rank:getPositionX(),self._font_bg:getContentSize().height/2)
                    self._font_bg:addChild(self._rankNum) 
                end

                if self._firstIn and callback then
                    callback()
                    self._firstIn = false
                    self:addGuide()
                end
            else
                XTHDTOAST(data["msg"])
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ShangJinLieRenLayer:refreshRewardData()
    ClientHttp:requestAsyncInGameWithParams({
        modules = "goldEctypeBase?",
        successCallback = function(data)
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end
            
            if data["result"] == 0 then
                -- print("赏金猎人的数据为：--------------")
                -- print_r(data)
                --刷新挑战次数
                self._surplusSum = data["surplusSum"]
                self._element["challenge_num"]:setString(data["surplusSum"])

                --刷新体力消耗
                local goldStage_data = gameData.getDataFromCSV("SilverGame",{["level"] = data["ectypeLevel"]})
                self._element["challenge_use_num"] = goldStage_data["hpcost"] or 0

                --刷新今天总伤害量
                self._totalHurt = data["totalHurt"] or 0
                if tonumber(self._totalHurt) <= 0 then
                    self._element["none_data"]:setVisible(true)
                    self._element["today_hurt_num"]:setVisible(false)
                else
                    self._element["none_data"]:setVisible(false)
                    self._element["today_hurt_num"]:setVisible(true)
                end
                self._element["today_hurt_num"]:setString(self._totalHurt)
                self._element["max_num"]:setString(data["maxHurt"] or 0)
              
                self._reward_arr = self:readDBData(data)
                self:checkRedPoint()

            else
                XTHDTOAST(data["msg"])
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ShangJinLieRenLayer:setRedPointVisible( is_visible )
    self._element["red_point"]:setVisible(is_visible)
end

function ShangJinLieRenLayer:checkRedPoint(  )
    local flag = false
    for i=1,#self._reward_arr do
        local item = self._reward_arr[i]
        if tonumber(item["state"]) == 0 then
            flag = true
        end
    end
    self:setRedPointVisible(flag)
end

function ShangJinLieRenLayer:updateData(  )
     --从战斗会来，刷新tableview数据和银两数据
    if self._element ~= nil then
        self:refreshRewardData()
        self:refreshRankData()

        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})      --刷新topbar数据
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) ---刷新主城市的，
    end
end


function ShangJinLieRenLayer:getArtFont( str )
    return XTHDLabel:createWithParams({fnt = "res/fonts/10/red6.fnt" , text = str , kerning = -2})
end

function ShangJinLieRenLayer:create(data)
	return self.new(data);
end

function ShangJinLieRenLayer:onEnter(  )
   if self._is_need_refresh_data == true then
        self:updateData()
    end
end

function ShangJinLieRenLayer:onCleanup(  )
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/goldcopy/background.jpg")
    textureCache:removeTextureForKey("res/image/goldcopy/boss_font.png")
    
    for i=1,15 do
        textureCache:removeTextureForKey("res/image/goldcopy/daxiangshengji_0000" .. i .. ".png")
    end
    XTHD.removeEventListener("JADITE_IS_NEED_REFRESH")
    XTHD.removeEventListener("PLAY_EFFECT")
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
end

function ShangJinLieRenLayer:onExit(  )
end

function ShangJinLieRenLayer:addGuide( )
    YinDaoMarg:getInstance():addGuide({index = 5,parent = self},14) ----         
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self._fightBtn,
        index = 6,
        needNext = false,
    },14)
    YinDaoMarg:getInstance():doNextGuide()
end

return ShangJinLieRenLayer


