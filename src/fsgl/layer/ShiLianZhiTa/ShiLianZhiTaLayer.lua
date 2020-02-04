--试炼之塔
--@author 2019 06 03
local ShiLianZhiTaLayer = class( "ShiLianZhiTaLayer", function ()
    return XTHD.createBasePageLayer({bg="res/image/jaditecopy/background.png"})
end)

function ShiLianZhiTaLayer:onCleanup( ... )
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/jaditecopy/background.png")
    textureCache:removeTextureForKey("res/image/goldcopy/font_bg1.png")
    textureCache:removeTextureForKey("res/image/goldcopy/font_bg2.png")
    textureCache:removeTextureForKey("res/image/jaditecopy/sy_bg.png")
    textureCache:removeTextureForKey("res/image/jaditecopy/jadite_boss_font.png")
    textureCache:removeTextureForKey("res/image/jaditecopy/jadite_millde_line.png")
end

local fontColor = cc.c3b(53,25,26)
function ShiLianZhiTaLayer:ctor(data, callFunc)
    self._callFunc = callFunc
    self:init(data)
    
end

function ShiLianZhiTaLayer:init( data )

    self._element = {}  --存放各种元素
    self._rank_arr = {}    --存放伤害排行cell数据
    self._btn_arr = {}     --存放button
    self._reward_arr = {}
    self.fightFinish = false
    self.historyLevel = data["myMaxEctypeId"] or 1       --表示自己历史最高挑战层数
    self.curLevel = data["nextEctypeId"] or 1            --当前要挑战层数
    if( self.curLevel > 100) then
        self.curLevel = 100
    end

    -- 如果玩家已经通关
    if(data["myMaxEctypeId"] == 100 and  data["nextEctypeId"] == -1) then
        self.curLevel = 100
        self.fightFinish = true
    end

    self._current_first = data["curFirstReward"] or 1  --本层是否为首杀
    self._next_first = data["nextFirstReward"] or 1   --下层是否为首杀
    self._canChallenge = data["canChallenge"] or 0   --0可以挑战，1不能挑战
 
    self._challenge_btn = nil           --可以挑战按钮
    -- self._challenge_btn_effect = nil    --可以挑战按钮特效
    self.notChallengeBg = nil           --挑战次数已用完背景

    self:refreshRankData()
    self:doHttpRewardData()

     --透明层bg放在除去顶部topbar的高度之后的中间，为了适配各种机型
    local size = self:getContentSize()
    local layer_height = size.height - self.topBarHeight
    local bg = XTHD.createSprite()
    bg:setContentSize(XTHD.resource.visibleSize.width,layer_height)
    bg:setPosition(size.width/2, layer_height/2)
    self:addChild(bg)

    --  --用于存放翡翠副本文字及按钮信息
    -- local font_bg = cc.Sprite:create("res/image/jaditecopy/jadite_font_bg.png")
    -- font_bg:setAnchorPoint(0,1)
    -- font_bg:setPosition(20,bg:getContentSize().height)
    -- bg:addChild(font_bg)

    --新的
    local font_bg1 = ccui.Scale9Sprite:create("res/image/goldcopy/font_bg1.png")
    font_bg1:setContentSize(268,90)
    font_bg1:setAnchorPoint(0,1)
    font_bg1:setPosition(20,bg:getContentSize().height-80)
    bg:addChild(font_bg1)

    -- --中间分割部分
    -- local millde_line = cc.Sprite:create("res/image/jaditecopy/jadite_millde_line.png")
    -- millde_line:setPosition(font_bg:getContentSize().width/2,font_bg:getContentSize().height/2+35)
    -- font_bg:addChild(millde_line)   

    --试炼之塔文字
    local boss_font = cc.Sprite:create("res/image/jaditecopy/jadite_boss_font.png")
    boss_font:setAnchorPoint(0.5,0.5)
    boss_font:setPosition(font_bg1:getContentSize().width/2,font_bg1:getContentSize().height/2)
    font_bg1:addChild(boss_font)

    --kuang2
    local font_bg2 = ccui.Scale9Sprite:create("res/image/goldcopy/font_bg2.png")
    font_bg2:setContentSize(268,120)
    font_bg2:setAnchorPoint(0,0.5)
    font_bg2:setPosition(20,bg:getContentSize().height/2+30)
    bg:addChild(font_bg2)

    --透明层，存放一下层奖励信息
    local next_reward_layer = XTHD.createSprite()
    -- local next_reward_layer = ccui.Scale9Sprite:create(cc.rect(5,5,1,1), "res/image/common/scale9_bg_14.png")
    next_reward_layer:setContentSize(270,120)
    next_reward_layer:setAnchorPoint(0.5,0.5)
    next_reward_layer:setPosition(font_bg2:getContentSize().width/2,font_bg2:getContentSize().height/2)
    font_bg2:addChild(next_reward_layer)
    self._element["next_reward_layer"] = next_reward_layer

     --框3
     local font_bg3 = ccui.Scale9Sprite:create("res/image/goldcopy/font_bg2.png")
     font_bg3:setContentSize(268,110)
     font_bg3:setAnchorPoint(0,0.5)
     font_bg3:setPosition(20,bg:getContentSize().height/2-120)
     bg:addChild(font_bg3)

    --通关信息
    local today_rank = cc.Sprite:create("res/image/jaditecopy/pass_font.png")
    today_rank:setAnchorPoint(0.5,0.5)
    today_rank:setPosition(font_bg3:getContentSize().width/2,font_bg3:getContentSize().height)
    font_bg3:addChild(today_rank)

    --历史最高
    local max_height = cc.Sprite:create("res/image/jaditecopy/max_layer.png")
    max_height:setAnchorPoint(0.5,0.5)
    max_height:setPosition(font_bg3:getContentSize().width/2-50,font_bg3:getContentSize().height/2+20)
    font_bg3:addChild(max_height)

    --历史最高数字
    local max_num = self:getArtFont(data["myMaxEctypeId"])
    max_num:setScale(0.8)
    max_num:setAnchorPoint(0,0.5)
    max_num:setPosition(max_height:getContentSize().width+20,max_height:getPositionY())
    font_bg3:addChild(max_num)
    self._element["max_layer_num"] = max_num

    --当前层数
    local today_hurt = cc.Sprite:create("res/image/jaditecopy/current_layer.png")
    today_hurt:setAnchorPoint(0.5,0.5)
    today_hurt:setPosition(today_rank:getPositionX()-50,max_height:getPositionY()-40)
    font_bg3:addChild(today_hurt)

    local today_hurt_num = self:getArtFont(self.curLevel)
    today_hurt_num:setScale(0.8)
    today_hurt_num:setAnchorPoint(0,0.5)
    today_hurt_num:setPosition(today_hurt:getContentSize().width+20,today_hurt:getPositionY())
    font_bg3:addChild(today_hurt_num)
    self._element["layer_num"] = today_hurt_num

    --本层通关奖励
    local reward_btn = XTHDPushButton:createWithParams({
        normalFile = "res/image/goldcopy/reward_btn_normal.png",
        selectedFile = "res/image/goldcopy/reward_btn_selected.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        })
    reward_btn:setScale(0.8)
    reward_btn:setPosition(bg:getContentSize().width-200,boss_font:getPositionY()+360)
    bg:addChild(reward_btn)
    reward_btn:setTouchEndedCallback(function (  )
        local ShiLianZhiTaRewardPop = requires("src/fsgl/layer/ShiLianZhiTa/ShiLianZhiTaRewardPop.lua"):create(self._reward_arr)
        self:addChild(ShiLianZhiTaRewardPop, 1)
    end)

     --可领取奖励红点
    local red_point = XTHD.createSprite("res/image/common/heroList_redPoint.png")
    red_point:setPosition(reward_btn:getContentSize().width-15,reward_btn:getContentSize().height-15)
    reward_btn:addChild(red_point)
    self._element["red_point"] = red_point
    red_point:setVisible(false)

    --排行
    local rank_btn = XTHDPushButton:createWithParams({
        normalFile = "res/image/goldcopy/rank_btn_normal.png",
        selectedFile = "res/image/goldcopy/rank_btn_selected.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        })
        rank_btn:setScale(0.8)
    rank_btn:setPosition(reward_btn:getPositionX()+100,reward_btn:getPositionY())
    bg:addChild(rank_btn)
    rank_btn:setTouchEndedCallback(function (  )
        local rank_layer = requires("src/fsgl/layer/ShiLianZhiTa/ShiLianZhiTaRankPop.lua")
        self:addChild(rank_layer:create(self._rank_arr), 1)
    end)


    --框4
    local font_bg4 = ccui.Scale9Sprite:create("res/image/goldcopy/font_bg2.png")
    font_bg4:setContentSize(248,110)
    font_bg4:setAnchorPoint(0,0.5)
    font_bg4:setPosition(bg:getContentSize().width-280,80+153)
    bg:addChild(font_bg4)
    --透明层，存放本层奖励信息
    local current_reward_layer = XTHD.createSprite()
    -- local current_reward_layer = ccui.Scale9Sprite:create(cc.rect(5,5,1,1), "res/image/common/scale9_bg_14.png")
    current_reward_layer:setContentSize(400,130)
    current_reward_layer:setAnchorPoint(0.5,0.5)
    current_reward_layer:setPosition(font_bg4:getContentSize().width/2,font_bg4:getContentSize().height/2)
    font_bg4:addChild(current_reward_layer)
    self._element["current_reward_layer"] = current_reward_layer

    self:refreshRewardData()
    
   
    --开始挑战按钮
    -- local challenge_btn, battle_effect = XTHD.createFightBtn({
    --     par = bg,
    --     pos = cc.p(bg:getContentSize().width-70,70+30)
    -- })
    local challenge_btn = XTHD.createButton({
        normalFile = "res/image/common/btn/kstz_up.png",
        selectedFile = "res/image/common/btn/kstz_down.png",
        btnSize = cc.size(142,49),
        anchor = cc.p(0.5, 0.5),
        pos = cc.p(bg:getContentSize().width-160,70+35)
    })
    --challenge_btn:getLabel():setPosition(challenge_btn:getLabel():getPositionX()-15,challenge_btn:getLabel():getPositionY()-10)
    bg:addChild(challenge_btn)
    challenge_btn:setScale(0.7)

    challenge_btn:setTouchEndedCallback(function (  )
--        if self.fightFinish then
--            XTHDTOAST(LANGUAGE_FORMAT_TIPS49)
--            return
--        end
        YinDaoMarg:getInstance():guideTouchEnd() 
        LayerManager.addShieldLayout()
		print("当前通关层数："..self.curLevel)
        local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongCopyLayer.lua"):create( BattleType.JADITE_COPY_PVE, math.min(self.curLevel,100) )
        fnMyPushScene(_layer)
    end)
    self._fightBtn = challenge_btn



     --背景
     self.resttime_bg = ccui.Scale9Sprite:create("res/image/jaditecopy/sy_bg.png")
     self.resttime_bg:setContentSize(248,45)
     self.resttime_bg:setAnchorPoint(0,0.5)
     self.resttime_bg:setPosition(bg:getContentSize().width - 280, 30)
     bg:addChild(self.resttime_bg)

     --剩余挑战次数
    if tonumber(data.canChallenge) == 0 then
        self._restTimes = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_REST_FIGHTTIMES(data.surplusCount), "Helvetica", 20)
        self._restTimes:setAnchorPoint(0,0.5)
        self._restTimes:setColor(cc.c3b(0,180,226))
        self._restTimes:setPosition(55, self.resttime_bg:getContentSize().height/2)
        self.resttime_bg:addChild(self._restTimes)
    end

    self._challenge_btn = challenge_btn           --可以挑战按钮
    -- self._challenge_btn_effect = battle_effect    --可以挑战按钮特效
    
    --挑战次数已用完背景
    self.notChallengeBg = ccui.Scale9Sprite:create("res/image/jaditecopy/sy_bg.png")
    self.notChallengeBg:setContentSize(200,100)
    self.notChallengeBg:setAnchorPoint(0,0.5)
    self.notChallengeBg:setPosition(bg:getContentSize().width - 251, 90)
    bg:addChild(self.notChallengeBg)

    local can_not_challenge = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS114,-----"今日挑战次数已用完",
        fontSize = 20,
        -- color = fontColor
        })
    can_not_challenge:enableOutline(cc.c4b(0,0,0,0), 1.5)
    can_not_challenge:setPosition(self.notChallengeBg:getContentSize().width / 2, self.notChallengeBg:getContentSize().height / 2);
    self.notChallengeBg:addChild(can_not_challenge)

    --可以打
    if tonumber(self._canChallenge) == 0 then
        self.notChallengeBg:setVisible(false)
        self._challenge_btn:setVisible(true)
        self.resttime_bg:setVisible(true)
        -- self._challenge_btn_effect:setVisible(true)
    else    --次数已用完
        self.notChallengeBg:setVisible(true)
        self._challenge_btn:setVisible(false)
        self.resttime_bg:setVisible(false)
        -- self._challenge_btn_effect:setVisible(false)
    end

    if self.fightFinish then
        self.resttime_bg:setVisible(false)
    end

    -- self._is_need_refresh_data 控制场景切回来的时候是否刷新数据
    self._is_need_refresh_data = false
    XTHD.addEventListener({name = "JADITE_IS_NEED_REFRESH" ,callback = function()
        self._is_need_refresh_data = true
    end})
end

--请求领取奖励界面数据
function ShiLianZhiTaLayer:doHttpRewardData(  )
     ClientHttp:requestAsyncInGameWithParams({
        modules = "feicuiEctypeRewardList?",
        successCallback = function(data)
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end
        if data["result"] == 0 then
            self._reward_arr = data["list"] or {}
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

--读取数据
function ShiLianZhiTaLayer:readDBData(data)
   local gold_copy_data = gameData.getDataFromCSV("SilverGameRewardBox")
   for i=1,#gold_copy_data do
        gold_copy_data[i].configId = data["list"][i].configId
        gold_copy_data[i].state = data["list"][i].state
   end

   return gold_copy_data
end

function ShiLianZhiTaLayer:refreshRewardData(  )

    self._element["next_reward_layer"]:removeAllChildren()
    self._element["current_reward_layer"]:removeAllChildren()
    local node1 = self._element["next_reward_layer"]
    local node2 = self._element["current_reward_layer"]

    local reward_1 = cc.Sprite:create("res/image/jaditecopy/current_reward.png")
    reward_1:setPosition(node2:getContentSize().width/2,node2:getContentSize().height-10)
    node2:addChild(reward_1)

    local reward_2 = cc.Sprite:create("res/image/jaditecopy/next_reward.png")
    reward_2:setPosition(node1:getContentSize().width/2,node1:getContentSize().height)
    node1:addChild(reward_2)
    
    --本层奖励数据
    local tmp_data = gameData.getDataFromCSV("TrialTower")
    local data_1 = nil;
    data_1 = gameData.getDataFromCSV("TrialTower",{["instancingid"] = self.curLevel })
    local data_2 = {}
    --dump(self.curLevel,"selfcurLevel")
    --dump(data_1,"data_1")
    --dump(data_2,"data_2")
    -- 如果为True说明没有下一关
    local is_show_max_layer = true
    if self.curLevel + 1 <= #tmp_data then
        data_2 = gameData.getDataFromCSV("TrialTower",{["instancingid"] = tonumber(self.curLevel + 1)})
        is_show_max_layer = false
    end

    --列出静态表奖励的id、类型和数量(配的表太难看)
    local rewardTa = {
        [1] = { -- tonumber(self._current_first) == 1 --本层首杀
            id_1 = 1,
            _type_1 = XTHD.resource.type.feicui,          
            count_1 = tonumber(self._current_first) == 1 and tonumber(data_1["reward"])+tonumber(data_1["reward2"]) or tonumber(data_1["reward2"]),
            count_2 = not is_show_max_layer and tonumber(self._current_first) == 1 and tonumber(data_2["reward"])+tonumber(data_2["reward2"]) or tonumber(data_2["reward2"]) or nil,
        },
        [2] = {
            id_1 = 1,
            _type_1 = XTHD.resource.type.soul,
            count_1 = tonumber(data_1["reward3"]),
            count_2 = not is_show_max_layer and tonumber(data_2["reward3"]) or nil,
        },
    }
    if data_1["item1id"] and data_1["item1id"] ~= 0 then
        rewardTa[#rewardTa + 1] = {
            id_1 = data_1["item1id"],
            _type_1 = 4,
            count_1 = data_1["num1"],
            count_2 = not is_show_max_layer and data_2["num1"] or nil,
        }
    end
    if data_1["item2id"] and data_1["item2id"] ~= 0 then
        rewardTa[#rewardTa + 1] = {
            id_1 = data_1["item2id"],
            _type_1 = 4,
            count_1 = data_1["num2"],
            count_2 = not is_show_max_layer and data_2["num2"] or nil,
        }
    end

    --本层奖励
    local posTa1 = SortPos:sortFromMiddle(cc.p(node2:getContentSize().width/2,node2:getContentSize().height/2),
        #rewardTa, 95) 
    for i=1, #rewardTa do
        local current_item = ItemNode:createWithParams({
            itemId = rewardTa[i].id_1,
            _type_ = rewardTa[i]._type_1,
            count = rewardTa[i].count_1,
            })
            current_item:setScale(0.8)
        current_item:setPosition(posTa1[i])
        node2:addChild(current_item)
    end

    if is_show_max_layer then
        local no_reward = XTHDLabel:createWithParams({
            text = LANGUAGE_TIPS_WORDS115,------"已达到最高层",
            fontSize = 25,
            color = cc.c3b(36,106,14)
        })
        no_reward:setPosition(node1:getContentSize().width/2,node1:getContentSize().height/2)
        node1:addChild(no_reward)
        return
    end

    --下层奖励
    local posTa2 = SortPos:sortFromMiddle(cc.p(node1:getContentSize().width/2,node1:getContentSize().height/2),
    #rewardTa,  85)
    for i=1, #rewardTa do
        local next_item = ItemNode:createWithParams({
            itemId = rewardTa[i].id_1,
            _type_ = rewardTa[i]._type_1,
            count = rewardTa[i].count_2,
            })
        next_item:setPosition(posTa2[i])
        next_item:setScale(0.75)
        node1:addChild(next_item)
    end
end

function ShiLianZhiTaLayer:refreshRankData()
    ClientHttp:requestAsyncInGameWithParams({
        modules = "feicuiEctypeRank?",
        successCallback = function(data)
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end

            if data["result"] == 0 then
                self._rank_arr = data["list"]
                -- self._element["tableview_rank"]:reloadData()
                --  --如果去战斗的时候显示的是”当前暂无数据“时，战斗结束后，已经有伤害数据了，这个时候就需要隐藏”当前暂无数据“
                -- if #self._rank_arr ~= 0 then
                --     self._element["no_msg"]:setVisible(false)
                -- end
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

function ShiLianZhiTaLayer:doHttpRefreshRewardData()

    if self.curLevel == nil or self._current_first == nil or self._next_first == nil then
        return
    end

    ClientHttp:requestAsyncInGameWithParams({
        modules = "feicuiEctypeBase?",
        successCallback = function(data)
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end
        -- dump(data)

            if data["result"] == 0 then
                self.curLevel = data["nextEctypeId"] == -1 and 100 or data["nextEctypeId"]
                self._current_first = data["curFirstReward"] or 1  --本层是否为首杀
                self._next_first = data["nextFirstReward"] or 1   --下层是否为首杀
                self._canChallenge = data["canChallenge"] or 0   --0可以挑战，1不能挑战

                --判断是否可以挑战
                if tonumber(self._canChallenge) == 0 then
                    self.notChallengeBg:setVisible(false)
                    self._challenge_btn:setVisible(true)
                    -- self._challenge_btn_effect:setVisible(true)
                    self._restTimes:setString(LANGUAGE_KEY_REST_FIGHTTIMES(data.surplusCount))
                    self.resttime_bg:setVisible(true)
                else
                    self.notChallengeBg:setVisible(true)
                    self._challenge_btn:setVisible(false)
                    -- self._challenge_btn_effect:setVisible(false)
                    self.resttime_bg:setVisible(false)
                end

                if self.fightFinish then
                    self.resttime_bg:setVisible(false)
                end

                self:refreshRewardData(self._element["reward_bg"])
                
                self._element["max_layer_num"]:setString(data["myMaxEctypeId"])
               

                if tonumber(data["nextEctypeId"]) > 0 then
                    self._element["layer_num"]:setString(tonumber(data["nextEctypeId"]))
                else
                    self.curLevel = 100
                    self._element["layer_num"]:setString("100")
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

function ShiLianZhiTaLayer:updateData(  )
     --从战斗会来，刷新tableview数据和银两数据
    if self._element ~= nil then
        self:refreshRankData()
        self:doHttpRefreshRewardData()
        self:doHttpRewardData()

        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})      --刷新topbar数据
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) ---刷新主城市的，
    end
end

function ShiLianZhiTaLayer:getArtFont( str )
    return XTHDLabel:createWithParams({fnt = "res/fonts/10/red6.fnt" , text = str , kerning = -2})
end

function ShiLianZhiTaLayer:setRedPointVisible( is_visible )
    if self._element and self._element.red_point then
        self._element["red_point"]:setVisible(is_visible)
    end
end

function ShiLianZhiTaLayer:checkRedPoint(  )
    local flag = false
    for i=1,#self._reward_arr do
        local item = self._reward_arr[i]
        if tonumber(item["state"]) == 1 then
            flag = true
        end
    end
    self:setRedPointVisible(flag)
end

function ShiLianZhiTaLayer:create(data, callFunc)

    return self.new(data, callFunc);
end

function ShiLianZhiTaLayer:onEnter(  )
    if self._is_need_refresh_data == true then
        self:updateData()
    end
    self:addGuide()   
end

function ShiLianZhiTaLayer:onExit(  )
    if self._callFunc then
        self._callFunc()
    end
end

function ShiLianZhiTaLayer:addGuide( )
    YinDaoMarg:getInstance():addGuide({index = 9,parent = self},15) ---- 
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self._fightBtn, -----点击返回
        index = 10,
    },15)
    YinDaoMarg:getInstance():doNextGuide()    
end

return ShiLianZhiTaLayer