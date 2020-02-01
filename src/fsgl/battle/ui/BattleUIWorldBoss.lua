--世界boss
local BattleUIWorldBoss = class("BattleUIWorldBoss", function()
    return XTHD.createLayer()
end)

function BattleUIWorldBoss:ctor(data,battle_type)
    local width = self:getContentSize().width;
    local height = self:getContentSize().height;
    local maxhp=data.hp 
    local curhp=data.curHp
	--自动战斗按钮
	-- local btnAuto = createAutoButton(battle_type)--XTHDSprite:create("res/image/tmpbattle/autocombat_off.png")
	-- btnAuto:setPosition(cc.p(btnAuto:getContentSize().width / 2 + 17, self:getContentSize().height - btnAuto:getContentSize().height / 2 - 10))
	-- self:addChild(btnAuto)	
    
    --透明层，存放倒计时组件
    local op_layer = XTHD.createSprite()
    op_layer:setContentSize(620,130)
    op_layer:setAnchorPoint(0.5,1)
    op_layer:setPosition(self:getContentSize().width/2 + 60 ,self:getContentSize().height)   -- + 150
    self:addChild(op_layer)

    --头像背景框
    local hero_frame_bg = cc.Sprite:create("res/image/worldboss/avator_bg.png")
    -- hero_frame_bg:setFlippedX(true)
    hero_frame_bg:setPosition(170-30+400+110,op_layer:getContentSize().height-50)
    op_layer:addChild(hero_frame_bg)

    --头像框
    local hero_frame = cc.Sprite:create("res/image/goldcopy/time_down_6.png")
    hero_frame:setPosition(180+3,hero_frame_bg:getContentSize().height/2)
    hero_frame_bg:addChild(hero_frame)
    hero_frame:setOpacity(0)

    --头像
    local hero_icon = XTHD.createSprite(XTHD.resource.getHeroAvatarImgPath({_type = 2, heroid = data.heroid}))
    if data.heroid ~= 801 then
        hero_icon:setScaleX(-1)
    end
    hero_icon:setScale(0.90)
    hero_icon:setPosition(hero_frame:getContentSize().width/2,hero_frame:getContentSize().height/2)
    hero_frame:addChild(hero_icon)

    -- local hero_frame_sp = cc.Sprite:create("res/image/goldcopy/time_down_3.png")
    -- hero_frame_sp:setPosition(hero_icon:getContentSize().width-17,hero_icon:getContentSize().height/2-13)
    -- hero_icon:addChild(hero_frame_sp)

    --boss名字
    local boss_name = XTHD.createSprite(XTHD.resource.getBossNameImg({heroid = data.heroid}))
    boss_name:setPosition(80,37)
    hero_frame_bg:addChild(boss_name)
 
    --进度条背景
    local bar_bg = cc.Sprite:create("res/image/worldboss/loardingbar_boss_bg.png")
    bar_bg:setAnchorPoint(0,0.5)
    bar_bg:setPosition(60+14+40+130+90,hero_frame_bg:getContentSize().height)
    op_layer:addChild(bar_bg,-1)

    --进度条
    local progress_bar = cc.ProgressTimer:create(cc.Sprite:create("res/image/worldboss/loardingbar_boss.png"))
    -- hero_frame_bg:setFlippedX(true)
    progress_bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    -- progress_bar:setReverseDirection(false)
    progress_bar:setMidpoint(cc.p(1, 0))
    progress_bar:setBarChangeRate(cc.p(1, 0))
    progress_bar:setPosition(cc.p(bar_bg:getContentSize().width / 2, bar_bg:getContentSize().height / 2))
    local percent=string.format("%.4f", ((curhp/maxhp)))*100--math.floor(curhp/maxhp)*100
    progress_bar:setPercentage(percent)
    bar_bg:addChild(progress_bar)

    local percent_label=getCommonWhiteBMFontLabel(tostring(percent).."%")
    percent_label:setPosition(progress_bar:getContentSize().width/2,progress_bar:getContentSize().height/2-5)
    progress_bar:addChild(percent_label)
    local total_num=0
    local nowhp=curhp
    local hp_sp=cc.Sprite:create("res/image/worldboss/all_hp.png")
    hp_sp:setAnchorPoint(1,0.5)
    hp_sp:setPosition(-30,25+14)
    hero_frame_bg:addChild(hp_sp)
    local _labGoldCount = getCommonWhiteBMFontLabel(total_num,1000000)
    _labGoldCount:setAnchorPoint(0.5,0.5)
    _labGoldCount:setPosition(hp_sp:getContentSize().width+10,hp_sp:getContentSize().height/2-7)
    hp_sp:addChild(_labGoldCount)
    hp_sp:setVisible(false)
    _labGoldCount:setVisible(false)

    XTHD.addEventListener({name = "GOLD_COPY_GET_GOLD_NUM" ,callback = function(event)
        local data = event["data"]
            -- print("客户端世界Boss计算伤害：")
            -- print_r(data)
            local hurt_num = data["hurt_num"] or 0
            total_num=total_num+tonumber(hurt_num)
     
            _labGoldCount:runAction(cc.Sequence:create(cc.EaseSineIn:create(cc.ScaleTo:create(0.15,1.5)),cc.CallFunc:create(function()
                    _labGoldCount:setString(tostring(total_num));
                    _labGoldCount:setPosition(hp_sp:getContentSize().width+10+_labGoldCount:getContentSize().width/2,hp_sp:getContentSize().height/2-7)
                    hp_sp:setPosition(-30-_labGoldCount:getContentSize().width,25+14)
            end),cc.EaseSineOut:create(cc.ScaleTo:create(0.05,1.0))))
            --
            nowhp=curhp-tonumber(total_num)
            if nowhp<= 0 then
                nowhp=0
            end
            local percent=string.format("%.4f", ((nowhp/maxhp)))*100--math.floor((nowhp/maxhp)*100)
            progress_bar:setPercentage(percent)
            percent_label:setString(percent.."%")
        
        end})

    --结束战斗弹窗
    XTHD.addEventListener({name = CUSTOM_EVENT.WORLDBOSS_KILL ,callback = function(event)
        local data = event["data"]
        --     XTHD.dispatchEvent({
        --         name = EVENT_NAME_BATTLE_PAUSE,
        --     })
        --     local reward_pop=requires("src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXuKillPop.lua"):create(data)
        --     reward_pop:show()
        --     cc.Director:getInstance():getRunningScene():addChild(reward_pop)
        if gameUser._worldBossOver == 1 then
            XTHD.dispatchEvent({
                name = EVENT_NAME_BATTLE_PAUSE,
            })
            local reward_pop
            local function _call( ... )
                reward_pop:removeFromParent()
                musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_main,true)
                cc.Director:getInstance():popScene()
            end
            reward_pop = requires("src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiHatredPop.lua"):create({hideCallback = _call})
            reward_pop:show()
            cc.Director:getInstance():getRunningScene():addChild(reward_pop)
            gameUser._worldBossOver=0
        end
    end})

    local handle = function ( event )
        if event == "cleanup" then
            self:onCleanup()
        end
    end
    self:registerScriptHandler(handle)
end

function BattleUIWorldBoss:onCleanup()
    XTHD.removeEventListener("GOLD_COPY_GET_GOLD_NUM")
    XTHD.removeEventListener(CUSTOM_EVENT.WORLDBOSS_KILL)
end
function BattleUIWorldBoss:create(data,battle_type)
    return BattleUIWorldBoss.new(data,battle_type) 
end
return BattleUIWorldBoss