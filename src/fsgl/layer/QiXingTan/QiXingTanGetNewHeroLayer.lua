--Create By hezhitao 2015年05月22日



local QiXingTanGetNewHeroLayer = class("QiXingTanGetNewHeroLayer",function ()
    return  XTHDDialog:create()--XTHD.createBasePageLayer( { bg = "res/image/exchange/reward/cjbj.png" })
end)

function QiXingTanGetNewHeroLayer:onCleanup(  )
     --清理比较大的纹理
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/exchange/reward/cjbj.png") 
    textureCache:removeTextureForKey("res/spine/effect/exchange_effect/cjyx2.png") 
    textureCache:removeTextureForKey("res/spine/effect/exchange_effect/cjyx.png") 
    if self._heroSound then
        musicManager.stopEffect(self._heroSound)
        self._heroSound = nil
    end
    if self._heroinfoList.rank == 4 then
        local layer = requires("src/fsgl/layer/ConstraintPoplayer/HeroPeiYangPopLayer.lua"):create(1)
        self:addChild(layer)
    elseif self._heroinfoList.rank == 5 then
        local layer = requires("src/fsgl/layer/ConstraintPoplayer/HeroPeiYangPopLayer.lua"):create(2)
        self:addChild(layer)
    end
end

function QiXingTanGetNewHeroLayer:ctor(hero_id,star,callback)
	print("-------------------",hero_id)
    self._heroId = hero_id
    self._star = star
    self._callback = callback
	
	self._heroinfoList = gameData.getDataFromCSV( "GeneralShow",{heroid = hero_id} )
	
end

function QiXingTanGetNewHeroLayer:init()
	local bg1 = cc.Sprite:create("res/image/exchange/reward/cjbj.png")
	bg1:setContentSize(cc.Director:getInstance():getWinSize())
	bg1:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
	self:addChild(bg1)
	
    local size = self:getContentSize()
    local bg = cc.Sprite:create() 
	bg:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
	bg:setContentSize(cc.size(1024,615))
    self:addChild(bg)
    self._bg = bg
	
      --guang 
--      local light_circle = cc.Sprite:create("res/image/exchange/reward/reward_light_circle.png")
--      light_circle:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
--      bg:addChild(light_circle)
--      light_circle:setScale(0.8)
--      light_circle:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(2,360))))
--	  light_circle:setVisible(false)
       --taizi
        --台子
--      local taizi = cc.Sprite:create("res/image/exchange/reward/zhaomu_06.png")
--      taizi:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2-70)
--      bg:addChild(taizi)
      
	local taizi = sp.SkeletonAnimation:create("res/image/exchange/dipan1.json", "res/image/exchange/dipan1.atlas", 1)
	taizi:setScale(1.3)
    taizi:setName("animationSpine")
	taizi:addAnimation(0, "animation", true)
    taizi:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2-110)
	bg:addChild(taizi)
	taizi:setTimeScale(0.3)

    --静态获得新的英雄
    local gxhd = cc.Sprite:create("res/image/exchange/gxhdxyx.png")
    gxhd:setPosition(bg:getContentSize().width*0.5,bg:getContentSize().height-50)
    bg:addChild(gxhd)
	gxhd:setVisible(false)
    --动画
    local open_date_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/cjyx2.json", "res/spine/effect/exchange_effect/cjyx2.atlas",1 )
    open_date_effect:setPosition(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5 + 90)
    bg:addChild(open_date_effect)
    open_date_effect:setOpacity(0)
    self._spineAni = open_date_effect

    open_date_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/cjyx.json", "res/spine/effect/exchange_effect/cjyx.atlas",1 )
    open_date_effect:setPosition(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5)
	open_date_effect:setScaleX(self:getContentSize().width/1024)
	open_date_effect:setScaleY(self:getContentSize().height/615)
    bg:addChild(open_date_effect)
    self._spineAni2 = open_date_effect

    musicManager.playEffect("res/sound/sound_effect_newhero.mp3")
    YinDaoMarg:getInstance():getACover(self)

	--英雄简介
	local spJianJie = cc.Sprite:create("res/image/exchange/reward/zhaomu_04.png")
	bg:addChild(spJianJie)
	spJianJie:setPosition(spJianJie:getContentSize().width * 1.2, bg:getContentSize().height / 2 + 50)
	
	--英雄简介 
	local heroLable = XTHDLabel:create(self._heroinfoList.herodescription,22,"res/fonts/def.ttf")
	heroLable:setColor(cc.c3b(255,255,182))
	heroLable:setDimensions(230,0)
	heroLable:setAnchorPoint(0,1)
	bg:addChild(heroLable)
	heroLable:setPosition(spJianJie:getPositionX() + spJianJie:getContentSize().width / 2 -95,spJianJie:getPositionY() - 25)
	
	--简介背景
	local spJianJie2 = cc.Sprite:create("res/image/exchange/reward/zhaomu_02.png")
	bg:addChild(spJianJie2)
	spJianJie2:setPosition(spJianJie2:getContentSize().width - 85, spJianJie:getPositionY() -(heroLable:getContentSize().height + 45))

	--技能简介
	local spJiNeng = cc.Sprite:create("res/image/exchange/reward/zhaomu_05.png")
	bg:addChild(spJiNeng)
	spJiNeng:setPosition(bg:getContentSize().width / 2 + 220,  bg:getContentSize().height / 2 - 45)

	--英雄技能
	print("=================self._heroinfoList.icon============",self._heroinfoList.icon)
	local name = string.format("res/image/skills/skill%d.png",self._heroinfoList.icon)
	local Skill = cc.Sprite:create(name)
	bg:addChild(Skill)
	Skill:setPosition(spJiNeng:getPositionX() + Skill:getContentSize().width/2 - 45 ,spJiNeng:getPositionY() - Skill:getContentSize().height +30)
	
	--技能介绍
	local SkillLable = XTHDLabel:create(self._heroinfoList.skilldescription,22,"res/fonts/def.ttf")
	SkillLable:setColor(cc.c3b(255,255,182))
	SkillLable:setDimensions(220,0)
	SkillLable:setAnchorPoint(0,1)
	bg:addChild(SkillLable)
	SkillLable:setDimensions(200,75)
	SkillLable:setPosition(Skill:getPositionX() + Skill:getContentSize().width / 2 + 10,spJiNeng:getPositionY() - 30)
	--技能背景
	local spJiNeng2 = cc.Sprite:create("res/image/exchange/reward/zhaomu_01.png")
	spJiNeng2:setContentSize(spJiNeng2:getContentSize().width + 30,spJiNeng2:getContentSize().height)
	bg:addChild(spJiNeng2)
	spJiNeng2:setPosition(bg:getContentSize().width - spJiNeng2:getContentSize().width /2 - 30, spJiNeng:getPositionY() -(SkillLable:getContentSize().height + 65))

	--英雄定位
	local spDingWei = cc.Sprite:create("res/image/exchange/reward/zhaomu_03.png")
	bg:addChild(spDingWei)
	spDingWei:setPosition(spJiNeng:getPositionX(),  bg:getContentSize().height / 2 + 165)

	--英雄定位类型
	local name = string.format("res/image/exchange/reward/heroTaype_%d.png",tonumber(self._heroinfoList.type))
	print("====================>>>",name)
	local heroType = cc.Sprite:create(name)
	bg:addChild(heroType)
	heroType:setPosition(spDingWei:getPositionX(),  spDingWei:getPositionY() - heroType:getContentSize().height)
	
	--英雄定位简介
	local heroTypeLabel = XTHDLabel:create(self._heroinfoList.typelocation,22,"res/fonts/def.ttf")
	heroTypeLabel:setColor(cc.c3b(255,255,182))
	heroTypeLabel:setDimensions(230,0)
	heroTypeLabel:setAnchorPoint(0,1)
	bg:addChild(heroTypeLabel)
	heroTypeLabel:setPosition(heroType:getPositionX() + heroType:getContentSize().width / 2 + 10 ,heroType:getPositionY() + 10)

	--定位背景
	local spDingWeibg = cc.Sprite:create("res/image/exchange/reward/zhaomu_01.png")
	bg:addChild(spDingWeibg)
	spDingWeibg:setPosition(bg:getContentSize().width - spDingWeibg:getContentSize().width + 85, bg:getContentSize().height / 2 + 80)

	--英雄定位等级
	local rank = tonumber(self._heroinfoList.rank)
	local name = string.format("res/image/exchange/reward/pingji_%d.png",rank)
	local spDingWeibgLv = cc.Sprite:create(name)
	bg:addChild(spDingWeibgLv)
	spDingWeibgLv:setPosition(spDingWei:getPositionX(),spDingWei:getPositionY()+spDingWeibgLv:getContentSize().height * 1.2)

	--提示
	local Tishi = XTHDLabel:create("点击任意处继续", 20,"res/fonts/def.ttf")
	Tishi:setColor(cc.c3b(255,255,255))
	bg:addChild(Tishi)
	Tishi:setPosition(bg:getContentSize().width / 2, 75)	

	Tishi:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2),cc.FadeIn:create(3))))

	local op_btn = XTHDPushButton:createWithParams({
            touchSize = bg:getContentSize(),
            musicFile = XTHD.resource.music.effect_btn_common,
    })
    op_btn:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
    bg:addChild(op_btn)
	op_btn:setTouchEndedCallback(function()
		 if not self._from then 
                YinDaoMarg:getInstance():guideTouchEnd() 
                YinDaoMarg:getInstance():releaseGuideLayer()
                local _group = YinDaoMarg:getInstance():getGuideSteps()
                if _group == 1 then 
                    self:removeFromParent()
                    LayerManager.popModule()
                    return
                end 
            end 
            --------------------------------------------------------
            if self._callback ~= nil and type(self._callback) == "function" then
                self._callback()
            end
            self:removeFromParent()
	end)
end

function QiXingTanGetNewHeroLayer:initUI()
	self:init()
    local bg = self._bg
    local hero_id = self._heroId
    local star = self._star
    local callback = self._callback
     -- musicManager.playEffect("res/sound/sound_effect_newhero.mp3")
     --标题动画
    local open_date_effect = self._spineAni
    open_date_effect:setAnimation(0,"atk",false)
    self._spineAni2:setAnimation(0,"atk",false)
	local file_path = string.format("%03d", hero_id)

    --把英雄绑定到骨骼动画中的一个点（slot）上面，这样英雄就能跟着slot做相应的动画
    local slot_hero_node = open_date_effect:getNodeForSlot("yx")
	
	local hero = nil

	if file_path ~= 322 and file_path ~= 026 and file_path ~= 042 then
		hero = sp.SkeletonAnimation:createWithBinaryFile("res/spine/"..file_path..".skel", "res/spine/"..file_path..".atlas", 1)
	else
		hero = sp.SkeletonAnimation:create("res/spine/"..file_path..".json", "res/spine/"..file_path..".atlas", 1)
	end

    hero:setPosition(slot_hero_node:getContentSize().width*0.5, slot_hero_node:getContentSize().height*0.5+40 )
    hero:setAnchorPoint(0.5,0)
    -- hero:setAnimation(0,action_Win,false)
    hero:setAnimation(0, action_Idle, true)
    slot_hero_node:addChild(hero)
    hero:setVisible(false)
    hero:registerSpineEventHandler( function ( event )
        local name  = event.animation
        if name == action_Win then
            -- hero:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
            hero:setAnimation(0, action_Idle, true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    local hero2 = nil --sp.SkeletonAnimation:create("res/spine/"..file_path..".json", "res/spine/"..file_path..".atlas", 1)
	if file_path ~= 322 and file_path ~= 026 and file_path ~= 042 then
		hero2 = sp.SkeletonAnimation:createWithBinaryFile("res/spine/"..file_path..".skel", "res/spine/"..file_path..".atlas", 1)
	else
		hero2 = sp.SkeletonAnimation:create("res/spine/"..file_path..".json", "res/spine/"..file_path..".atlas", 1)
	end
    -- hero2:setAnimation(0,action_Win,false)
    hero2:setAnimation(0, action_Idle, true)
    XTHD.setShader(hero2,"res/shader/BanishShader_yellow.vsh","res/shader/BanishShader_yellow.fsh")
    slot_hero_node:addChild(hero2)
    hero2:setVisible(false)
    hero2:registerSpineEventHandler( function ( event )
        local name  = event.animation
        if name == action_Win then
            -- hero2:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
            hero2:setAnimation(0, action_Idle, true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    performWithDelay(hero, function ( ... )
        YinDaoMarg:getInstance():removeCover(self)
        hero2:setVisible(true)
        hero2:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.EaseQuinticActionOut:create(cc.ScaleTo:create(0.5,2)),
                cc.EaseQuinticActionOut:create(cc.FadeOut:create(0.5))
            ),
            cc.CallFunc:create(function ( ... )
                hero2:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                hero2:removeFromParent()
                hero2 = nil
            end)
        ))
    end, 0.6)

   
    performWithDelay(hero, function ( ... )
        self._heroSound = XTHD.playHeroDubEffect(tonumber(hero_id), "win")
        hero:setVisible(true)
    end, 0.1)


    --确定按钮
    local be_ok = XTHD.createCommonButton({
        text = LANGUAGE_BTN_KEY.sure,
        isScrollView = false,
        fontSize = 22,
        btnSize = cc.size(200,49),
        pos = cc.p(slot_hero_node:getContentSize().width*0.5 - 20, slot_hero_node:getContentSize().height*0.5 - 110),
        endCallback = function()
            ----------引导 
            if not self._from then 
                YinDaoMarg:getInstance():guideTouchEnd() 
                YinDaoMarg:getInstance():releaseGuideLayer()
                local _group = YinDaoMarg:getInstance():getGuideSteps()
                if _group == 1 then 
                    self:removeFromParent()
                    LayerManager.popModule()
                    return
                end 
            end 
            --------------------------------------------------------
            if callback ~= nil and type(callback) == "function" then
                callback()
            end
            self:removeFromParent()
        end
    })
    be_ok:setScale(0.8)
    slot_hero_node:addChild(be_ok)
    be_ok:setVisible(false)
	
    local shareSuccCallback = function (msg)
        ClientHttp:requestAsyncInGameWithParams({
            modules = "petShare?petId="..hero_id,
            successCallback = function(data)
                -- dump(data)
                if data.result==0 then
                    if callBack then
                        callBack()
                    end
                else
                    XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
                end
            end,
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            end,--失败回调
        })
    end

    self.guide_okayBtn = be_ok
    -------------引导
    self:addGuide()
    -------------引导
    local slot_hero_name_node = open_date_effect:getNodeForSlot("yxm")
    
    --名字背景框
    local hero_name_bg = cc.Sprite:create("res/image/exchange/reward/reward_name.png")
    hero_name_bg:setPosition(slot_hero_name_node:getContentSize().width*0.5,slot_hero_name_node:getContentSize().height*0.5+80)
    slot_hero_name_node:addChild(hero_name_bg)
    hero_name_bg:setVisible(false)
    performWithDelay(hero_name_bg, function ( ... )
        hero_name_bg:setVisible(true)
    end, 0.1)
	hero_name_bg:setScale(1.2)

    --名字
    local hero_name = XTHD.createSprite("res/image/exchange/reward/hero_name/hero_name_"..hero_id..".png")
    hero_name:setPosition(hero_name_bg:getContentSize().width*0.5,hero_name_bg:getContentSize().height*0.5+25)
    -- hero_name:setScale(0.8)
    hero_name_bg:addChild(hero_name)

    function play_star(  )
        local slot_title_node = open_date_effect:getNodeForSlot("xx")
        local _x = 0
        local _y = slot_title_node:getContentSize().height*0.5 - 80
        if tonumber(star) == 1 then
            _x = slot_title_node:getContentSize().width*0.5
        elseif tonumber(star) == 2 then
            _x = slot_title_node:getContentSize().width*0.5-35
		elseif tonumber(star) == 3 then
			 _x = slot_title_node:getContentSize().width*0.5-65
		elseif tonumber(star) == 4 then
			 _x = slot_title_node:getContentSize().width*0.5-95
        else
            _x = slot_title_node:getContentSize().width*0.5-120
        end

        for i=1,tonumber(star) do
            local star_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/cjxx.json", "res/spine/effect/exchange_effect/cjxx.atlas",1 );
            star_effect:setPosition(_x+(i-1)*60,_y-10)
            slot_title_node:addChild(star_effect)
			star_effect:setScale(0.8)
            -- star_effect:setAnimation(0,"animation",false)
            performWithDelay(star_effect, function ( ... )
                star_effect:setAnimation(0,"animation",false) 
            end, (i-1)*0.2)
        end
    end

    -- self:runAction(cc.Sequence:create( cc.DelayTime:create(1.5),cc.CallFunc:create(function (  )
    --     open_date_effect:setAnimation(0,"chixu",true)     
    -- end) ))
    performWithDelay(self, function ( ... )
        be_ok:setVisible(false)
        --shareBtn:setVisible(true)
        play_star()   
    end, 0.5)
end

function QiXingTanGetNewHeroLayer:create( sParams )
    local par = sParams.par
    -- local isAddScene = sParams.isAddScene
    local hero_id = sParams.id
    local star = sParams.star
    local callback = sParams.callBack
    LayerManager.addShieldLayout()
    local layer = QiXingTanGetNewHeroLayer.new(hero_id, star, callback)
    -- layer.isAddScene = isAddScene
    layer._from = sParams.from

    par:addChild(layer,10)

--    local pLayer = cc.LayerColor:create(cc.c4b(0,0,0,255))
--    layer:addChild(pLayer,99)
--     local cgLayer = requires("src/fsgl/layer/YinDao/YinDaoCGLayer.lua"):create({
--         file = "res/spine/camp/exGetHero.mp4",
--         callBack = function ()
--            if pLayer then
--                  pLayer:removeFromParent()
--                  pLayer = nil
--             end
--             if not layer._isInit then
--                layer._isInit = true
--                layer:initUI()
--             end
--         end
--     })

--     layer:addChild(cgLayer,100)

	local spineBg = cc.Sprite:create("res/image/exchange/reward/spinebg.png") 
	layer:addChild(spineBg)
	spineBg:setPosition(layer:getContentSize().width *0.5,layer:getContentSize().height *0.5)
	spineBg:setContentSize(layer:getContentSize())

	--换成spine动画
	cgAni = sp.SkeletonAnimation:createWithBinaryFile("res/spine/cg/HeroCG.skel", "res/spine/cg/HeroCG.atlas",1 )
    cgAni:setPosition(layer:getContentSize().width*0.5,layer:getContentSize().height*0.5 - 100)
	cgAni:setScaleX(cc.Director:getInstance():getWinSize().width/1024)
	cgAni:setScaleY(cc.Director:getInstance():getWinSize().height/615)
	cgAni:setTimeScale(1)
    spineBg:addChild(cgAni)
	cgAni:setAnimation(0,"animation",false)

	local callback = function()
--        if not layer._isInit then
--            layer._isInit = true
			spineBg:removeFromParent()		
            layer:initUI()
--        end
    end

	performWithDelay(layer,callback,2.2)
    
    return layer
end

function QiXingTanGetNewHeroLayer:addGuide( )
    -- -------------引导    
    YinDaoMarg:getInstance():addGuide({ ----点击确实按钮
        parent = self,
        target = self.guide_okayBtn,
        index = 4,
        needNext = false,
        offset = cc.p(22,40),
    },1)
    performWithDelay(self,function( )
        YinDaoMarg:getInstance():doNextGuide()   
    end,0.5)
    -------------引导
end

return QiXingTanGetNewHeroLayer