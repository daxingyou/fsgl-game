--@author hezhitao 2015.08.21

local SCHEDULE_TAY = 1000
local SCHEDULE_TAY_1 = 1000
local BattleUIGoldCopyLayer = class( "BattleUIGoldCopyLayer", function ()
    return cc.Layer:create()
end)

function BattleUIGoldCopyLayer:ctor(  cd,level,instancingid,battlelayer  )
    self:init( cd,level,instancingid,battlelayer )
end

function BattleUIGoldCopyLayer:init( cd,level,instancingid,battlelayer   )

    -- self._cd = tonumber(cd)
    -- self._bar_cd = tonumber(cd)
    -- self._total_cd = tonumber(cd)
    self._bar = nil
    self._time = nil

    g_cd = tonumber(cd)
    g_bar_cd = tonumber(cd)
    g_total_cd = tonumber(cd)

    --透明层bg放在除去顶部topbar的高度之后的中间，为了适配各种机型
    local size = cc.Director:getInstance():getWinSize()
    local bg = XTHD.createSprite()
    bg:setContentSize(size)
    bg:setPosition(size.width/2, size.height/2)
    self:addChild(bg)
    --自动战斗
    -- local btnAuto = createAutoButton(BattleType.GOLD_COPY_PVE)--XTHDSprite:create("res/image/tmpbattle/autocombat_off.png")
    -- btnAuto:setPosition(cc.p(btnAuto:getContentSize().width / 2 + 17, self:getContentSize().height - btnAuto:getContentSize().height / 2 - 10))
    -- self:addChild(btnAuto)  

    --透明层，存放倒计时组件
    local op_layer = XTHD.createSprite()
    op_layer:setContentSize(620,130)
    op_layer:setAnchorPoint(0.5,1)
    op_layer:setPosition(bg:getContentSize().width/2,bg:getContentSize().height)
    bg:addChild(op_layer)

    --头像背景框
    local hero_frame_bg = cc.Sprite:create("res/image/goldcopy/time_down_1.png")
    hero_frame_bg:setPosition(550,op_layer:getContentSize().height-50)
    op_layer:addChild(hero_frame_bg)
    hero_frame_bg:setFlippedX(true)

    --头像框
    local hero_frame = cc.Sprite:create("res/image/goldcopy/time_down_6.png")
    hero_frame:setPosition(50+2+124,hero_frame_bg:getContentSize().height/2)
    hero_frame_bg:addChild(hero_frame)

    --头像
    local hero_icon = cc.Sprite:create("res/image/avatar/avatar_circle_31.png")
    hero_icon:setPosition(hero_frame:getContentSize().width/2,hero_frame:getContentSize().height/2)
    hero_frame:addChild(hero_icon)
    hero_icon:setFlippedX(true)

    -- local hero_frame_sp = cc.Sprite:create("res/image/goldcopy/time_down_3.png")
    -- hero_frame_sp:setPosition(hero_icon:getContentSize().width-17,hero_icon:getContentSize().height/2-13)
    -- hero_icon:addChild(hero_frame_sp)

    --boss名字
    local boss_name = cc.Sprite:create("res/image/goldcopy/time_down_4.png")
    boss_name:setPosition(hero_frame_bg:getContentSize().width/2+30+10-77,37)
    hero_frame_bg:addChild(boss_name)

    --进度条背景
    local bar_bg = cc.Sprite:create("res/image/goldcopy/time_down_7.png")
    bar_bg:setAnchorPoint(1,0.5)
    bar_bg:setPosition(150+3,hero_frame_bg:getContentSize().height-30)
    hero_frame_bg:addChild(bar_bg,-1)
    bar_bg:setFlippedX(true)

    --进度条
    local bar_sp = cc.Sprite:create("res/image/goldcopy/time_down_2.png")
    bar_sp:setFlippedX(true)
    
    local progress_bar = cc.ProgressTimer:create(bar_sp)
    progress_bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress_bar:setMidpoint(cc.p(1, 0))
    progress_bar:setBarChangeRate(cc.p(1, 0))
    progress_bar:setPosition(cc.p(bar_bg:getContentSize().width / 2, bar_bg:getContentSize().height / 2))
    progress_bar:setPercentage(100)
    bar_bg:addChild(progress_bar)
    self._bar = progress_bar

    --倒计时
    local time_label = getCommonWhiteBMFontLabel( self:getTimeString(g_cd) )
    time_label:setPosition(bar_bg:getContentSize().width/2 + 200 - 45,bar_bg:getContentSize().height/2-6)
    time_label:setScale(0.85)
    bar_bg:addChild(time_label)
    self._time = time_label

    --漏斗背景
    local loudou_bg = cc.Sprite:create("res/image/goldcopy/time_down_5.png")
    loudou_bg:setAnchorPoint(0,0.5)
    loudou_bg:setPosition(bar_bg:getPositionX()-bar_bg:getContentSize().width-40,bar_bg:getPositionY())
    hero_frame_bg:addChild(loudou_bg)
    loudou_bg:setFlippedX(true)

    --漏斗
    local loudou = cc.Sprite:create("res/image/goldcopy/time_down_8.png")
    loudou:setPosition(loudou_bg:getContentSize().width/2-5,loudou_bg:getContentSize().height/2)
    loudou_bg:addChild(loudou)

    --银两的现实
    local gold_icon = cc.Sprite:create("res/image/common/header_gold.png")
    gold_icon:setPosition(op_layer:getContentSize().width/2-200,op_layer:getContentSize().height/2+15+15+5)
    op_layer:addChild(gold_icon)

    --银两的数量
    local gold_num = getCommonWhiteBMFontLabel( "0" )
    -- gold_num:setAnchorPoint(0,0.5)
    gold_num:setPosition(gold_icon:getPositionX()-gold_icon:getContentSize().width/2-35,gold_icon:getPositionY()-6)
    op_layer:addChild(gold_num)

    local limit_gold = gameData.getDataFromCSV("SilverGame", {instancingid = instancingid})["limit"] or 0
    local total_num = 0
    --event = {data = {hurt_num = "123456"} }  通知传递过来参数格式
     XTHD.addEventListener({name = "GOLD_COPY_GET_GOLD_NUM" ,callback = function(event)
        local data = event["data"]
        local killmoney = data["killmoney"] or 0
        local hurt_num = data["hurt_num"] or 0
        local target = data["target"]
        -- print(hurt_num,level,limit_gold,"lajsdfladjksf--------------------------------------->")
        local gold_num_str = math.floor( tonumber(level)*tonumber(hurt_num) ) or "0"
        -- print(tonumber(level)*tonumber(hurt_num),gold_num_str,"aaaaaaaaaaaaaaaa--------------------------------------->")
        local isFull = false
        if gold_num_str == limit_gold then
            isFull = true
        end
        local preNum = total_num
        total_num = total_num + gold_num_str
        -- print(total_num,"total_numtotal_numtotal_numtotal_num--------------------------------------->")
        if tonumber(total_num) >= tonumber(limit_gold) then
            total_num = limit_gold
        end
        local plusNum = total_num - preNum

        if tonumber(killmoney) > 0 then
            total_num = total_num + tonumber(killmoney)
        end
        gold_num:runAction( cc.Sequence:create( cc.ScaleTo:create(0.15,1.5),cc.CallFunc:create(function (  )
            gold_num:setString(total_num)
        end),cc.ScaleTo:create(0.15,1) ) )
        if target and not isFull then
            local emitter1 = cc.Sprite:create()
            local pos = target
            emitter1:setPosition(pos.x, pos.y - 25)
            -- emitter1:setScale(1.5)
            XTHD.dispatchEvent({
                name = EVENT_NAME_BATTLE_PLAY_EFFECT,
                data = {node = emitter1, zorder = 20},
            })
            local action = getAnimation("res/spine/effect/goldDrop/djb", 1, 19, 0.067)
            emitter1:runAction(action)
            performWithDelay(emitter1, function ( ... )
                emitter1:removeFromParent()
            end, 0.067*19)

            local icon = cc.Sprite:create("res/image/common/header_gold.png")
            icon:setScale(0.5)
            local rewardLabel = cc.Label:createWithBMFont("res/fonts/jinbizengjia.fnt","+"..plusNum)
            rewardLabel:setAnchorPoint(0,0.5)
            rewardLabel:setScale(0.625)
            rewardLabel:setPosition(icon:getBoundingBox().width + 15, icon:getBoundingBox().height / 2 + 12)
            icon:setCascadeOpacityEnabled(true)                
            icon:addChild(rewardLabel, 2)
            icon:setOpacity(0)
            icon:setPosition(pos)
            XTHD.dispatchEvent({
                name = EVENT_NAME_BATTLE_PLAY_EFFECT,
                data = {node = icon, zorder = 20},
            })
            icon:setScale(0.2)

            local t = 0.1
            local arr = {-10,-5,0,5,10,15,20}
            local random = math.random(#arr)
            local scale = 0.75
            local fadeTime = 0.3
            local height = 70
            local action = cc.Sequence:create(
                cc.Spawn:create(
                    cc.MoveBy:create(t, cc.p(0, arr[random] + height)),
                    cc.FadeIn:create(t),
                    cc.ScaleTo:create(t, 0.4)
                ),
                cc.ScaleTo:create(t, scale),
                cc.FadeTo:create(0.4, 180),
                cc.Spawn:create(
                    cc.FadeOut:create(fadeTime),
                    cc.MoveBy:create(fadeTime, cc.p(0, 20+40))
                ),
                cc.RemoveSelf:create(true)
            )
            icon:runAction(action)
        end

     end})

     -- XTHD.dispatchEvent({name = "GOLD_COPY_GET_GOLD_NUM",data = {hurt_num = g_cd} }) 

     g_bar = self._bar
     g_time = self._time
     g_self = self
     g_battlelayer = battlelayer

    schedule(battlelayer,self.timeDown,1,SCHEDULE_TAY)   --倒计时时间调度
    schedule(battlelayer,self.timeDown1,0.1,SCHEDULE_TAY_1)   --倒计时时间调度

    -- op_layer:setFlippedX(true)
    -- local function setFlippedXAllNode( op_layer )
    --     local child_array = op_layer:getChildren()
    --     print("child_array = ",#child_array)
    --     for i=1,#child_array do
    --         local sub_child_array = child_array[i]:getChildren()
    --         print("sub_child_array = ",#sub_child_array)
    --         if #sub_child_array > 0 then
    --             setFlippedXAllNode(child_array[i])
    --         else
    --             child_array[i]:setFlippedX(true)
    --         end
    --     end
    -- end

    -- setFlippedXAllNode(op_layer)

    local handle = function ( event )
        if event == "cleanup" then
            self:onCleanup()
        end
    end
    self:registerScriptHandler(handle)

end

function BattleUIGoldCopyLayer:timeDown(  )
    --倒计时结束
    if tonumber(g_cd) <= 0 then
        g_battlelayer:stopActionByTag(SCHEDULE_TAY)
    else
        g_cd = g_cd - 1
        g_time:setString( g_self:getTimeString(g_cd) )
        
    end
end

--此倒计时是用来处理进度条的
function BattleUIGoldCopyLayer:timeDown1(  )
    --倒计时结束
    if tonumber(g_bar_cd) <= 0 then
        g_battlelayer:stopActionByTag(SCHEDULE_TAY_1)
    else
        g_bar_cd = g_bar_cd - 0.1
        local percent = tonumber(g_bar_cd)/tonumber(g_total_cd)
        g_bar:setPercentage(percent*100)
    end
end

--此方法只处理一个小时之内的倒计时
function BattleUIGoldCopyLayer:getTimeString( cd )
    local time_str = ""
    local min_str = math.floor(tonumber(cd)/60)
    local second_str = tonumber(cd)%60

    --如果大于10分钟，则不用前缀处理
    if tonumber(min_str) >= 10 then
        time_str = min_str..":"
        if tonumber(second_str) >= 10 then
            time_str = time_str..second_str
        else
            time_str = time_str.."0"..second_str
        end
    else
        time_str = "0"..min_str..":"
        if tonumber(second_str) >= 10 then
            time_str = time_str..second_str
        else
            time_str = time_str.."0"..second_str
        end
    end

    return time_str

end

function BattleUIGoldCopyLayer:onEnter( ... )

end

function BattleUIGoldCopyLayer:onExit( ... )

end

function BattleUIGoldCopyLayer:onCleanup()
    print("BattleUIGoldCopyLayer:onCleanup")
    XTHD.removeEventListener("GOLD_COPY_GET_GOLD_NUM")
    g_cd = nil
    g_bar_cd = nil
    g_total_cd = nil
    g_bar = nil
    g_time = nil
    g_self = nil
    g_battlelayer = nil
    musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_main,true)
end

function BattleUIGoldCopyLayer:create( cd,level,instancingid,battlelayer )
    local target = self.new( cd,level,instancingid,battlelayer )
    return target
end

return BattleUIGoldCopyLayer