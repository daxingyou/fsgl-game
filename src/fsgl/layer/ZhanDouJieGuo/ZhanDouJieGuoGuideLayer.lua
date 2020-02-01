-- FileName: ZhanDouJieGuoGuideLayer.lua
-- Author: wangming
-- Date: 2015-12-16
-- Purpose: 封装引导用战斗结算界面
--[[TODO List]]

local ZhanDouJieGuoGuideLayer=class("ZhanDouJieGuoGuideLayer",function (sParams)
	return XTHDDialog:create(100)
end)

function ZhanDouJieGuoGuideLayer:ctor( sParams )
	self._dataInfo = {}
	----------------测试数据
	self._dataInfo.playerInfo = {
		addExp = 2000,
		oldlevel = 1, oldexp = 0, oldmax = 0,
		curlevel = 5, curexp = 0, curmax = 200
	}
	self._dataInfo.allPets = {
		{
			heroid = 1, star = 1, advance = 1, addExp = 680,
			oldlevel = 1, oldexp = 0, oldmax = 0,
			curlevel = 5, curexp = 0, curmax = 200
		},
		-- {
		-- 	heroid = 3, star = 1, advance = 1, addExp = 220,
		-- 	oldlevel = 1, oldexp = 0, oldmax = 100,
		-- 	curlevel = 2, curexp = 120, curmax = 200
		-- },
	}
	self._dataInfo.items = {
		-- {_type_ = XTHD.resource.type.gold, count = 100},
		-- {_type_ = XTHD.resource.type.feicui, count = 100},
		-- {_type_ = XTHD.resource.type.item, count = 100, itemId = 1001},
	}
	---------------


	sp.SkeletonAnimation:create( "res/spine/effect/level_up/xgn.json", "res/spine/effect/level_up/xgn.atlas",1.0)
    musicManager.playEffect(XTHD.resource.music.effect_battle_victory,false)

    local light_bg = cc.Sprite:create("res/image/tmpbattle/battle_result_bg.png")
    light_bg:setAnchorPoint(0.5,0.5)
    light_bg:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
    self:addChild(light_bg)
    self._light_bg = light_bg

    -- local avator_bg = cc.Sprite:create("res/image/tmpbattle/battle_result_cirecle.png")
    -- avator_bg:setAnchorPoint(0.5,0.5)
    -- avator_bg:setPosition(35+avator_bg:getContentSize().width/2,light_bg:getContentSize().height-avator_bg:getContentSize().height/2)
    -- avator_bg:runAction(cc.RepeatForever:create(cc.RotateBy:create(30,360)))
    -- light_bg:addChild(avator_bg)

    -- local avator = cc.Sprite:create("res/image/tmpbattle/battle_result_avator1.png")
    -- avator:setPosition(avator_bg:getPositionX(),avator_bg:getPositionY())
    -- light_bg:addChild(avator)

    local avator_bg=cc.Sprite:create("res/image/tmpbattle/battle_result_cirecle.png")
    avator_bg:setScale(0.7)
    avator_bg:setAnchorPoint(0.5,0.5)
    -- avator_bg:runAction(cc.RepeatForever:create(cc.RotateBy:create(30,360)))
    avator_bg:setPosition(335+avator_bg:getContentSize().width/2,light_bg:getContentSize().height/2)
    light_bg:addChild(avator_bg,-1)
    local  avator=cc.Sprite:create("res/image/tmpbattle/battle_result_avator1.png")
    avator:setScale(0.8)
    avator:setPosition(avator_bg:getContentSize().width/2-50,light_bg:getContentSize().height/2)
    -- avator:setPosition(avator_bg:getPositionX(),avator_bg:getPositionY())
    light_bg:addChild(avator)

    ---经验条
    self:makeExpBar()
   

    --播放星星动画
    local winEffect = sp.SkeletonAnimation:create( "res/spine/effect/battle_win/shengli.json", "res/spine/effect/battle_win/shengli.atlas",1.0)
    winEffect:setPosition(light_bg:getContentSize().width/2, light_bg:getContentSize().height-40)
    light_bg:addChild(winEffect)
    
    musicManager.playEffect("res/sound/sound_resultLayer_3Star_effect.mp3")

    winEffect:runAction(cc.Sequence:create(
    	cc.CallFunc:create(function()
	        winEffect:setAnimation(0, "3", false)
	    end),
	    cc.DelayTime:create(0.4),
	    cc.CallFunc:create(function()
	        self:make_hero_and_droplist()
	    end),
	    cc.DelayTime:create(1.6),
	    cc.CallFunc:create(function()
        	winEffect:setAnimation(0, "3_3", true) 
    	end)
	))

    --返回按钮
	local _btnBack = XTHD.createCommonButton({
        btnSize = cc.size(142,49),
        text = LANGUAGE_KEY_SURE,
        isScrollView = false,
        fontSize = 100,
        anchor = cc.p(0, 0),
        musicFile = XTHD.resource.music.effect_btn_commonclose,
        pos = cc.p(self:getContentSize().width/2+250,(self:getContentSize().height-light_bg:getContentSize().height)/2+18),
        endCallback = function ( ... )
            --do back
            -- self:removeFromParent()
            if sParams and sParams.callback then
                sParams.callback()
            end 
        end
    })
    _btnBack:setCascadeOpacityEnabled(true)
    self:addChild(_btnBack)
    self._btnBack = _btnBack
end

function ZhanDouJieGuoGuideLayer:makeExpBar()
	local _playerInfo = self._dataInfo.playerInfo or {}

    local exp_progress_bg = cc.Sprite:create("res/image/tmpbattle/loardingbar_green_bg.png")
    exp_progress_bg:setAnchorPoint(0,0.5)
    exp_progress_bg:setPosition(self._light_bg:getContentSize().width/2-40, 330)
    self._light_bg:addChild(exp_progress_bg)
    local exp_progress_timer = cc.ProgressTimer:create(cc.Sprite:create("res/image/tmpbattle/loardingbar_green.png"))
    exp_progress_timer:setPosition(0, exp_progress_bg:getContentSize().height/2)
    exp_progress_timer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    exp_progress_timer:setAnchorPoint(0,0.5)
    exp_progress_timer:setMidpoint(cc.p(0,0.5))
    exp_progress_timer:setBarChangeRate(cc.p(1,0))
    exp_progress_bg:addChild(exp_progress_timer)

    local now_percent = (_playerInfo.oldexp/_playerInfo.oldmax)*100
    local next_percent = (_playerInfo.curexp/_playerInfo.curmax)*100
	local addLevel = _playerInfo.curlevel - _playerInfo.oldlevel
	local addExp = _playerInfo.addExp

    if addLevel > 1 then
        exp_progress_timer:runAction(cc.Sequence:create(
        	cc.DelayTime:create(0.15),
        	cc.ProgressFromTo:create(0.5, now_percent, 100),
        	cc.Repeat:create(
        		cc.Sequence:create(
            		cc.CallFunc:create(function()
                		exp_progress_timer:setPercentage(0)
            		end),
        			cc.ProgressFromTo:create(1,0,100)
    			), addLevel - 1),
        	cc.CallFunc:create(function()
        		exp_progress_timer:setPercentage(0)
    		end),
    		cc.ProgressFromTo:create(0.5, 0, next_percent)
		))
    elseif addLevel == 1 then
    	exp_progress_timer:runAction(cc.Sequence:create(
        	cc.DelayTime:create(0.15),
        	cc.ProgressFromTo:create(0.5, now_percent, 100),
        	cc.CallFunc:create(function()
        		exp_progress_timer:setPercentage(0)
    		end),
    		cc.ProgressFromTo:create(0.5, 0, next_percent)
		))
    else
        --没升级
        exp_progress_timer:runAction(cc.Sequence:create(
        	cc.DelayTime:create(0.15),
        	cc.ProgressFromTo:create(0.5, now_percent, next_percent)
    	))
    end

    local _exp_str = "经验+" .. tostring(addExp)
    local exp_label = XTHDLabel:createWithParams({text = _exp_str, size=16})
    exp_label:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))
    exp_label:setPosition(exp_progress_bg:getContentSize().width/2,exp_progress_bg:getContentSize().height/2+1)
    exp_progress_bg:addChild(exp_label)                                           
    
    local exp_sp=cc.Sprite:create("res/image/tmpbattle/exp_sp.png")
    exp_sp:setAnchorPoint(0,0.5)
    exp_sp:setPosition(self._light_bg:getContentSize().width/2-53, 337)
    self._light_bg:addChild(exp_sp)

    local level_sp=cc.Sprite:create("res/image/tmpbattle/level_sp.png")
    level_sp:setAnchorPoint(0,0.5)
    level_sp:setPosition(self._light_bg:getContentSize().width/2, 330+20)
    self._light_bg:addChild(level_sp)

    local level_label=getCommonWhiteBMFontLabel(tostring(_playerInfo.curlevel))
    level_label:setAnchorPoint(0,0.5)
    level_label:setPosition(self._light_bg:getContentSize().width/2+85, 330+20-7)
    self._light_bg:addChild(level_label)
end

--显示物品
function ZhanDouJieGuoGuideLayer:makeDropList( ... )
	local _items = self._dataInfo.items or {}
    for k=1, #_items do
        local equip_data = _items[k]
        if equip_data then
            local equip_item = ItemNode:createWithParams(equip_data)
            if not equip_item then
                break
            end
            local _item_scale = 0.7
            equip_item:setAnchorPoint(0,1)
            equip_item:setScale(_item_scale)
            equip_item:setPosition(self._light_bg:getContentSize().width/2-40+102*(k-1)*_item_scale, 100+60)
            equip_item:setVisible(false)
            self._light_bg:addChild(equip_item)
            equip_item:runAction(cc.Sequence:create(cc.DelayTime:create(0.12*(k+1)),cc.CallFunc:create(function()
                equip_item:setVisible(true) --EaseBounceOut
                if k == #_items then
           --          local _backButton = 
        			-- again_btn:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.FadeIn:create(0.3)))
                end
            end),cc.EaseExponentialOut:create(cc.Sequence:create(cc.ScaleTo:create(0.07,1.15*_item_scale),cc.ScaleTo:create(0.07,1.0*_item_scale)))))
        end
    end
end

--显示英雄
function ZhanDouJieGuoGuideLayer:make_hero_and_droplist()

    local _heroid_list = self._dataInfo.allPets or {}

    for i=1,#_heroid_list do
        local hero_data = _heroid_list[i]
        local hero_item = self:makeHeroItem(hero_data)
        hero_item:setScale(0.8)
        hero_item:setAnchorPoint(0,0.5)
	    hero_item:setPosition(self._light_bg:getContentSize().width/2-40+90*(i-1)*1 , 330+20-90)
	    self._light_bg:addChild(hero_item)
	    hero_item:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(0.1*(i-1)),
	    	cc.CallFunc:create(function()
	          
            	local add_level = hero_data.curlevel - hero_data.oldlevel
            	local _target_per = (hero_data.curexp/hero_data.curmax)*100

                --更新最高经验值        
                local exp_progress_timer = hero_item:getChildByName("exp_progress_timer")
                if exp_progress_timer then
                    local current_percent = exp_progress_timer:getPercentage()
                    if add_level > 0 then
                        --需要添加升级动画
                        local animation_sp = cc.Sprite:create()
                        animation_sp:setPosition(hero_item:getContentSize().width/2, hero_item:getContentSize().height/2)
                        hero_item:addChild(animation_sp)
                        local animation = getAnimation("res/image/tmpbattle/level_up/level_up00",1,6,0.08)
                        animation_sp:runAction(animation)
                        animation_sp:runAction(cc.Sequence:create(animation,cc.CallFunc:create(function()
                                 animation_sp:removeFromParent()
                            end)))
                        if tonumber(add_level) == 1 then
                            exp_progress_timer:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.ProgressFromTo:create(0.5,current_percent,100),cc.CallFunc:create(function()
                                exp_progress_timer:setPercentage(0)
                            end),cc.ProgressFromTo:create(0.5,0,_target_per)))
                        else
                            exp_progress_timer:runAction(cc.Sequence:create(
                            	cc.DelayTime:create(0.15),
                            	cc.ProgressFromTo:create(0.5,current_percent,100),
                            	cc.Repeat:create(
                            		cc.Sequence:create(
	                            		cc.CallFunc:create(function()
	                                		exp_progress_timer:setPercentage(0)
	                            		end),
                            			cc.ProgressFromTo:create(1,0,100)
                        			), add_level-1),
                            	cc.CallFunc:create(function()
                            		exp_progress_timer:setPercentage(0)
                        		end),
                        		cc.ProgressFromTo:create(0.5,0,_target_per)
                    		))
                        end
                    else
                        exp_progress_timer:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.ProgressFromTo:create(1*(_target_per-current_percent)/100,current_percent,_target_per)))
                    end
            	end
        	end),
			cc.EaseExponentialOut:create(cc.Sequence:create(
				cc.ScaleTo:create(0.07,1.15*1),
				cc.ScaleTo:create(0.07,1.0*0.8)
			))
		))
    end
    self:makeDropList()
end

function ZhanDouJieGuoGuideLayer:makeHeroItem( oldHero )
    local hero_data = oldHero

    local equip_box_bg = HeroNode:createWithParams({
        heroid  = hero_data.heroid,
        star    = hero_data.star,
        level   = hero_data.curlevel,
        advance = hero_data.advance
    })

    --经验进度条 
    --经验条
    local exp_progress_bg = cc.Sprite:create("res/image/tmpbattle/battle_data_pro_bg.png")
    exp_progress_bg:setAnchorPoint(0.5,0.5)
    exp_progress_bg:setPosition(equip_box_bg:getContentSize().width/2, -10)
    equip_box_bg:addChild(exp_progress_bg)
    exp_progress_bg:setScale(0.5)
    local gray_bg = cc.Sprite:create("res/image/tmpbattle/battle_data_pro_bg.png")
    gray_bg:setPosition(exp_progress_bg:getContentSize().width/2, exp_progress_bg:getContentSize().height/2)
    exp_progress_bg:addChild(gray_bg)

    local exp_progress_timer = cc.ProgressTimer:create(cc.Sprite:create("res/image/tmpbattle/battle_data_pro_green.png")) 
    exp_progress_timer:setName("exp_progress_timer")
    exp_progress_timer:setPosition(exp_progress_bg:getPositionX(), exp_progress_bg:getPositionY())
    exp_progress_timer:setType(cc.PROGRESS_TIMER_TYPE_BAR);
    exp_progress_timer:setMidpoint(cc.p(0,0.5));
    exp_progress_timer:setBarChangeRate(cc.p(1,0))
    exp_progress_timer:setScale(0.5)

    local percent_ = (hero_data.oldexp/hero_data.oldmax)*100
    exp_progress_timer:setPercentage(tonumber(percent_))
    equip_box_bg:addChild(exp_progress_timer,2)

    --经验值
    local _txt  = "EXP+"
    if hero_data.addExp then
        _txt = _txt .. tostring(hero_data.addExp)
    else
        _txt = _txt .. "0"
    end
    local equip_name_label = XTHDLabel:createWithParams({
        text = _txt ,
        size = 16,
    })
    equip_name_label:setAnchorPoint(0.5,1)
    equip_name_label:setPosition(equip_box_bg:getContentSize().width/2, -22)
    equip_box_bg:addChild(equip_name_label)
    equip_box_bg:setScale(0.8)
    return equip_box_bg
end

--升级
function ZhanDouJieGuoGuideLayer:showLevelUp( sLevelNew, sLevelCur, eEndCall )
	local _levelup = requires("src/fsgl/layer/common/ShengJiLayer.lua").new(sLevelNew, sLevelCur, eEndCall)		
    _levelup:setName("playerLevelUp")
    cc.Director:getInstance():getRunningScene():addChild(_levelup,100)   	
end

function ZhanDouJieGuoGuideLayer:onCleanup()
end

function ZhanDouJieGuoGuideLayer:create( sParams )
	return ZhanDouJieGuoGuideLayer.new(sParams)
end
return ZhanDouJieGuoGuideLayer