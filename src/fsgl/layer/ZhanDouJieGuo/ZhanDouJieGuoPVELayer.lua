--战斗结果界面（历练）
local TAG = "ZhanDouJieGuoPVELayer"

local  ZhanDouJieGuoPVELayer  = class( "ZhanDouJieGuoPVELayer", function ( ... )
    return XTHDDialog:create();
end)

function ZhanDouJieGuoPVELayer:onCleanup()
    if self._target_battle_type == BattleType.PVE or 
        self._target_battle_type == BattleType.ELITE_PVE or 
        self._target_battle_type == BattleType.DIFFCULTY_COPY then
        XTHD.dispatchEvent({name = "EVENT_LEVEUP"}) 
    end
end

--[[
    /** 玩家和怪物战斗 */
        PVE(0),
        /** 竞技场挑战 */
        BattleType.PVP_CHALLENGE(1),
        /** 精英副本  */
        ELITE_PVE(2),
        /** 神兽副本  */
        GODBEASE_PVE(3),
        /** 种族pvp  */
        CAMP_PVP(4);
]]

--再战 回到副本点开小关卡那
function ZhanDouJieGuoPVELayer:BattleAgain()
    if self._backCallback then
        self._backCallback()
    else
        cc.Director:getInstance():popScene()
    end
    if self._target_battle_type == BattleType.EQUIP_PVE then--huangjunjian 装备副本修改状态
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_EQUIPCOPY})
    elseif self._target_battle_type == BattleType.GODBEASE_PVE or self._target_battle_type == BattleType.SERVANT_PVE then
        local pB = tonumber(self._battle_data.fightResult) == 1
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GODBEAST_CHAPTER, data={isWin = pB, data = self._battle_data}})
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
    elseif self._target_battle_type == BattleType.PVE or 
        self._target_battle_type == BattleType.ELITE_PVE or
        self._target_battle_type == BattleType.DIFFCULTY_COPY then
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
    elseif self._target_battle_type == BattleType.PVP_CUTGOODS then
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ESCORT_LAYER}) 
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) 
    else
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
    end
end

function ZhanDouJieGuoPVELayer:InitFailedUI()
    if self.tip then
        self.tip:setVisible(false)
    end
    local title_faild=XTHD.createSprite("res/image/tmpbattle/result_faild.png")
        
    if tonumber(self._battle_data.fightResult) == BATTLE_RESULT.TIMEOUT  then
       title_faild=XTHD.createSprite("res/image/tmpbattle/result_outtime.png")
    end
    title_faild:setPosition(self._light_bg:getContentSize().width/2 + 50, self._light_bg:getContentSize().height - 90)
    self._light_bg:addChild(title_faild)

    --小提示
    local tishi_sp=XTHD.createSprite("res/image/tmpbattle/tishi.png")
    tishi_sp:setAnchorPoint(1,1)
    tishi_sp:setPosition(self._light_bg:getContentSize().width/2 - 40,self._light_bg:getContentSize().height-200)
    self._light_bg:addChild(tishi_sp)
    local tishi_label=XTHDLabel:createWithParams({text=LANGUAGE_TIPS_WORDS90,ttf="res/fonts/def.ttf",size=18})---"怪物释放必杀时明显闪光,多多打断\n他们的必杀技吧！"
    tishi_label:setColor(cc.c3b(255,255,255))
    tishi_label:setAnchorPoint(0,0.9)
    tishi_label:setPosition(self._light_bg:getContentSize().width/2 - 40,self._light_bg:getContentSize().height-200)
    self._light_bg:addChild(tishi_label)

    --提升按钮  
    local up_label=XTHDLabel:createWithParams({text=LANGUAGE_TIPS_WORDS91,ttf="res/fonts/def.ttf",size=20})----"通过以下方式可以快速提高战力哦！",
    up_label:setColor(cc.c3b(255,255,255))
    up_label:setAnchorPoint(0,0.5)
    up_label:setPosition(tishi_sp:getPositionX()-tishi_sp:getContentSize().width,tishi_sp:getPositionY()-150)
    self._light_bg:addChild(up_label)

    local up_tab={
                    {label=LANGUAGE_FUNCTION1,path="res/image/tmpbattle/exp_up.png",id="23"},----"经验任务"
                    {label=LANGUAGE_FUNCTION2,path="res/image/tmpbattle/hero_up.png",id="38"},---"英雄升级"
                    {label=LANGUAGE_FUNCTION3,path="res/image/tmpbattle/equip_up.png",id="44"},-----"装备升级"
                    {label=LANGUAGE_FUNCTION4,path="res/image/tmpbattle/skill_up.png",id="36"} -----"技能升级"
                 }
    for i=1,4 do
        local up_item=HeroNode:createWithParams({
                        heroid = 1,
                        star   = 0,
                        level  = 0,
                        advance   = 0,
                        })
         up_item:setScale(0.7) 
         up_item:getChildByName("item_border"):getChildByName("hero_img"):initWithFile(up_tab[i]["path"])

        local up_name=XTHDLabel:createWithParams({text=up_tab[i]["label"],ttf="res/fonts/def.ttf",size=20})
        up_name:setColor(cc.c3b(255,255,255))
        up_name:setPosition(up_item:getContentSize().width/2,-20)
        up_item:addChild(up_name)
        up_item:setTouchEndedCallback(function (  )
            ----------------------------------------------------------------------
            if i == 2 then 
                YinDaoMarg:getInstance():guideTouchEnd()
                YinDaoMarg:getInstance():releaseGuideLayer()
            end 
            ----------------------------------------------------------------------
            up_item:setClickable(false)
            local nowScene = self:getScene()
            if nowScene then
                nowScene:removeAllChildren()
            end
            gotoMaincity()
            if nowScene then
                nowScene:cleanup()
            end
            replaceLayer({id = up_tab[i].id})
        end)
        
        up_item:setPosition(230+(i-1)*111,self._light_bg:getContentSize().height/2-120)
        self._light_bg:addChild(up_item)
        self._failGo2Btns[i] = up_item
    end
end

function ZhanDouJieGuoPVELayer:InitWinUI()
	--头像
    self._result_effect:setPosition(self._light_bg:getContentSize().width/2 + 50, self._light_bg:getContentSize().height-110)
    self._light_bg:addChild(self._result_effect)

    --玩家信息
    local playerlv=tonumber(gameUser.getLevel())
    local exp_progress_bg = XTHD.createSprite("res/image/tmpbattle/loardingbar_green_bg.png")
    exp_progress_bg:setAnchorPoint(0,0.5)
    exp_progress_bg:setPosition(self._light_bg:getContentSize().width/2-120, 365)
    self._light_bg:addChild(exp_progress_bg)
    local now_percent=(tonumber(gameUser.getExpNow())/tonumber(gameUser.getExpMax()))*100
    local exp_progress_timer = cc.ProgressTimer:create(XTHD.createSprite("res/image/tmpbattle/loardingbar_green.png"))
    exp_progress_timer:setPosition(8, exp_progress_bg:getContentSize().height/2+2)
    exp_progress_timer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    exp_progress_timer:setAnchorPoint(0,0.5)
    exp_progress_timer:setMidpoint(cc.p(0,0.5))
    -- exp_progress_timer:setPercentage(now_percent)
    exp_progress_timer:setBarChangeRate(cc.p(1,0))
    exp_progress_bg:addChild(exp_progress_timer)
    --for lishuaizhe  这里的数据特殊处理了，

    local next_percent=1
    local addExp=self._battle_data.addExp or 0
    local nex_exp=tonumber(gameUser.getExpNow())+tonumber(addExp)
    if nex_exp>= tonumber(gameUser.getExpMax()) or self._levelup==true then
        --升级
        playerlv=tonumber(gameUser.getLevel())+1
        next_percent=(  (nex_exp-tonumber(gameUser.getExpMax())  ) /  tonumber(gameUser.getExpMax()) )*100
        exp_progress_timer:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.ProgressFromTo:create(0.5,now_percent,100),cc.CallFunc:create(function()
                                            exp_progress_timer:setPercentage(0)
                                        end),cc.ProgressFromTo:create(0.5,0,next_percent)

        )) 
     elseif nex_exp==tonumber(gameUser.getExpMax()) or self._levelup==true then
        --升级
        playerlv=tonumber(gameUser.getLevel())+1
        next_percent=(  (nex_exp-tonumber(gameUser.getExpMax())  ) /  tonumber(gameUser.getExpMax()) )*100
        exp_progress_timer:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.ProgressFromTo:create(0.5,now_percent,100),cc.CallFunc:create(function()
                                            exp_progress_timer:setPercentage(0)
                                        end)))
    else
        --没升级
        next_percent=(nex_exp/tonumber(gameUser.getExpMax()))*100
        exp_progress_timer:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.ProgressFromTo:create(0.5,now_percent,next_percent)))

    end
   


   
    local _exp_str = "经验+"
    if self._battle_data.addExp then
    
        _exp_str = _exp_str .. tostring(self._battle_data.addExp)
    else
        _exp_str = _exp_str .. "0"
    end
    local exp_label=XTHDLabel:createWithParams({text=_exp_str,ttf="",size=16})
    exp_label:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))
    exp_label:setPosition(exp_progress_bg:getContentSize().width/2 - 5,exp_progress_bg:getContentSize().height/2+2)
    exp_progress_bg:addChild(exp_label)                                           
    
    local exp_sp=XTHD.createSprite("res/image/tmpbattle/exp_sp.png")
    exp_sp:setAnchorPoint(0,0.5)
    exp_sp:setPosition(self._light_bg:getContentSize().width/2-160, 370)
    self._light_bg:addChild(exp_sp)

    local level_sp=XTHD.createSprite("res/image/tmpbattle/level_sp.png")
    level_sp:setAnchorPoint(0,0.5)
    level_sp:setPosition(self._light_bg:getContentSize().width/2 - 115, 400)
    self._light_bg:addChild(level_sp)

    local level_label=getCommonWhiteBMFontLabel(tostring(playerlv))
    level_label:setAnchorPoint(0,0.5)
    level_label:setPosition(self._light_bg:getContentSize().width/2 - 35, 394)
    self._light_bg:addChild(level_label)

    local function showButtonAnimation()
        local next_level_btn = self:getChildByName("next_level_btn")
        local again_btn = self:getChildByName("again_btn")    
        again_btn:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.FadeIn:create(0.3)))
    end
    local function make_hero_and_droplist()
        _heroid_list = self._battle_data.allPets
        herp_pro_list = self._battle_data.pet or {}
        --掉落信息
        local function equip_item_animation() 
			   --弹恭喜获得界面
			  local showData = {}
		      for k=1,#self._battle_data.items do
				  local tempData = {}
                  if self._battle_data.items[k]["type"] then 
					  tempData.rewardtype = self._battle_data.items[k]._type_
					  tempData.id = ""
					  tempData.num = self._battle_data.items[k].count
					  table.insert(showData,tempData)
				  else
					  local _temp_tab = string.split(self._battle_data.items[k], ',')
					  local txt  = tostring(_temp_tab[2]) or "1"
					  local item_info = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=_temp_tab[1]})
					  tempData.rewardtype = 4 
					  tempData.id = item_info.itemid
					  tempData.num = txt
					  table.insert(showData,tempData)
                  end 
			  end
			  ShowRewardNode:create(showData)
--            for k=1,#self._battle_data.items do
--                local equip_data = self._battle_data.items[k]
--                if equip_data then
--                    local equip_item = nil
--                    if equip_data["type"] then
--                        equip_item = self:makeDropItem(equip_data)
--                    else
--                        equip_item = self:makeDropEquip(equip_data)
--                    end
--                    if not equip_item then
--                        break
--                    end
--                    local _item_scale = 0.7
--                    equip_item:setAnchorPoint(0,1)
--                    equip_item:setScale(_item_scale)
--                    --试试
--                    print("个数:" .. #self._battle_data.items)
--                        if k <= 6 then
--                            print("进来了")
--                            equip_item:setPosition(self._light_bg:getContentSize().width/2-40+102*(k-1)*_item_scale, 100+60)
--                        elseif k <= 12 then 
--                            print("进来了2")
--                            equip_item:setPosition(self._light_bg:getContentSize().width/2-40+102*(k-7)*_item_scale, 100+60-equip_item:getContentSize().height*_item_scale)
--                        else
--                            print("进来了3")
--                            equip_item:setPosition(self._light_bg:getContentSize().width/2-40+102*(k-13)*_item_scale, 100+60-2*equip_item:getContentSize().height*_item_scale)
--                        end
--                        if k >= 12 then 
--                            equip_item:setScale(0.5)
--                        end
--                    -- equip_item:setPosition(self._light_bg:getContentSize().width/2-40+102*(k-1)*_item_scale, 100+60)
--                    equip_item:setVisible(false)
--                    self._light_bg:addChild(equip_item)
--                    equip_item:runAction(cc.Sequence:create(cc.DelayTime:create(0.12*(k+1)),cc.CallFunc:create(function()
--                        equip_item:setVisible(true) --EaseBounceOut
--                        if k == #self._battle_data.items then
--                            showButtonAnimation()
--                        end
--                    end),cc.EaseExponentialOut:create(cc.Sequence:create(cc.ScaleTo:create(0.07,1.15*_item_scale),cc.ScaleTo:create(0.07,1.0*_item_scale)))))
--                end
--            end
        end
        local function hero_item_animation( )
            for i=1,#_heroid_list do
                local _data_idx = i
                local hero_data = herp_pro_list[tostring(_heroid_list[i])]
                if hero_data then
                    local _hero_scale = 1
                    local hero_item = self:makeHeroItem(hero_data,_heroid_list[_data_idx],hero_data.addExp)
                    hero_item:setVisible(false)
                    hero_item:setScale(0.6)
                    hero_item:setName("hero_item"..tostring(i))
                    local db_hero_data = self._original_hero_data[tonumber(_heroid_list[_data_idx])] or {}
                    local Target_db_data = DBTableHero.getData(gameUser.getUserId(), {heroid = _heroid_list[_data_idx]}) or {}
                    hero_item.db_hero_data = db_hero_data
                    hero_item.Target_db_data = Target_db_data

                    hero_item:setAnchorPoint(0,0.5)
                    hero_item:setPosition(self._light_bg:getContentSize().width/2-165+90*(i-1)*_hero_scale , 190)
                    self._light_bg:addChild(hero_item)
                    hero_item:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*(i-1)),cc.CallFunc:create(function()
                    hero_item:setVisible(true)
                        local db_hero_data = hero_item.db_hero_data
                        local Target_db_data = hero_item.Target_db_data
                        local hero_data = hero_item.hero_data
                        local add_level = tonumber(Target_db_data["level"])-tonumber(db_hero_data["level"])
                        local _target_per = tonumber(Target_db_data["curexp"])/tonumber(Target_db_data["maxexp"])*100

                        --更新最高经验值        
                        local exp_progress_timer = hero_item:getChildByName("exp_progress_timer")
                       
                        if exp_progress_timer then
                            local current_percent = exp_progress_timer:getPercentage()
                            if add_level > 0 then
                                --需要添加升级动画
                                local animation_sp = XTHD.createSprite()
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
                                    exp_progress_timer:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.ProgressFromTo:create(0.5,current_percent,100),cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(function()
                                        exp_progress_timer:setPercentage(0)
                                    end),cc.ProgressFromTo:create(1,0,100)),add_level-1),cc.CallFunc:create(function()
                                    exp_progress_timer:setPercentage(0)
                                end),cc.ProgressFromTo:create(0.5,0,_target_per)))
                                end
                                
                            else
                                exp_progress_timer:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.ProgressFromTo:create(1*(_target_per-current_percent)/100,current_percent,_target_per)))
                            end
                    end
                    if i == #_heroid_list then
                        if #self._battle_data.items == 0 then
                            showButtonAnimation()
                        else
                           equip_item_animation()
                        end
                    end
                end),cc.EaseExponentialOut:create(cc.Sequence:create(cc.ScaleTo:create(0.07,1.15*_hero_scale),cc.ScaleTo:create(0.07,1.0*0.8)))))
                end
            end
        end     
        hero_item_animation() 
    end

    local function make_stars()
        if self._target_battle_type == BattleType.PVP_CHALLENGE 
            or (self._target_battle_type == BattleType.PVE and tonumber(self._battle_data.star) < 1 ) 
            or self._target_battle_type == BattleType.GODBEASE_PVE or self._target_battle_type == BattleType.CAMP_PVP or self._target_battle_type == BattleType.SERVANT_PVE
            or self._target_battle_type == BattleType.GOLD_COPY_PVE or self._target_battle_type == BattleType.JADITE_COPY_PVE then
            if self._fightResult == 1 then
                self._result_effect:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                        self._result_effect:setAnimation(0,"4",false)
                    end),cc.DelayTime:create(0.4),cc.CallFunc:create(function()
                        make_hero_and_droplist()
                    end),cc.DelayTime:create(1.6),cc.CallFunc:create(function()
                         self._result_effect:setAnimation(0,"4_4",true)
                    end)))
            else
                if self._target_battle_type == BattleType.PVP_CHALLENGE then
                     self._result_effect:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                        self._result_effect:setAnimation(0,"2",false)
                    end),cc.DelayTime:create(0.4),cc.CallFunc:create(function()
                        make_hero_and_droplist()
                    end),cc.DelayTime:create(0.27),cc.CallFunc:create(function()
                        self._result_effect:setAnimation(0,"1_2",true)
                    end)))
                end
            end
        else
            if tonumber(self._battle_data.star) then
                local path="res/sound/sound_resultLayer_"..self._battle_data.star.."Star_effect.mp3"
                musicManager.playEffect(path)
            end
            self._result_effect:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                self._result_effect:setAnimation(0,tostring(self._battle_data.star),false)
            end),cc.DelayTime:create(0.4),cc.CallFunc:create(function()
                make_hero_and_droplist()
            end),cc.DelayTime:create(1.6),cc.CallFunc:create(function()
                 self._result_effect:setAnimation(0,tostring(self._battle_data.star).."_"..tostring(self._battle_data.star),true)
                 
                 
            end)))
        end
    end
    bl_item_doAction = true
    make_stars()
end
--当创建的是银两、翡翠等东西时，使用该方法
function ZhanDouJieGuoPVELayer:makeDropItem(data)
    return ItemNode:createWithParams(data)
end
--创建掉落的装备，名字
function ZhanDouJieGuoPVELayer:makeDropEquip(data)
    local _temp_tab = string.split(data, ',')
    print("IIIIIIID:" .. _temp_tab[1])
    local txt  = tostring(_temp_tab[2]) or "1"
    local item_info = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=_temp_tab[1]})
    local equip_box_bg = ItemNode:createWithParams({
            _type_ = 4,
            itemId = item_info["itemid"],
            count   = txt 
        })
    return equip_box_bg
end

--创建英雄,经验条
function ZhanDouJieGuoPVELayer:makeHeroItem(data,heroId,add_exp)
    local hero_data = self._original_hero_data[heroId] or {}
    local new_hero_data =  DBTableHero.getData(gameUser.getUserId(), {["heroid"] = heroId}) or {}
    local equip_box_bg = HeroNode:createWithParams({
            heroid  = heroId,
            star    = hero_data["star"],
            level   = data["level"],
            advance =new_hero_data["advance"]
        })

    --经验进度条 
    --经验条
    local exp_progress_bg = XTHD.createSprite("res/image/tmpbattle/battle_data_pro_bg.png")
    exp_progress_bg:setAnchorPoint(0.5,0.5)
    exp_progress_bg:setPosition(equip_box_bg:getContentSize().width/2, -10)
    equip_box_bg:addChild(exp_progress_bg)
    exp_progress_bg:setScale(0.5)
    local gray_bg = XTHD.createSprite("res/image/tmpbattle/battle_data_pro_bg.png")
    gray_bg:setPosition(exp_progress_bg:getContentSize().width/2, exp_progress_bg:getContentSize().height/2)
    exp_progress_bg:addChild(gray_bg)

    local exp_progress_timer = cc.ProgressTimer:create(XTHD.createSprite("res/image/tmpbattle/battle_data_pro_green.png")) 
    exp_progress_timer:setName("exp_progress_timer")
    exp_progress_timer:setPosition(exp_progress_bg:getPositionX(), exp_progress_bg:getPositionY())
    exp_progress_timer:setType(cc.PROGRESS_TIMER_TYPE_BAR);
    exp_progress_timer:setMidpoint(cc.p(0,0.5));
    exp_progress_timer:setBarChangeRate(cc.p(1,0))
    exp_progress_timer:setScale(0.5)
    --for lishuaizhe  这里的数据特殊处理了，
    local _data = hero_data 
    local percent_ = tonumber(_data["curexp"])/tonumber(_data["maxexp"])*100
    exp_progress_timer:setPercentage(tonumber(percent_))
    -- equip_box_bg.currentPer = DBTableHero.getData(gameUser.getUserId(), {["heroid"] = heroId})
    -- equip_box_bg.currentPer = equip_box_bg.currentPer and equip_box_bg.currentPer.curexp or 0
    equip_box_bg:addChild(exp_progress_timer,2)

    --经验值
    local _txt  = "经验+"
    if data.addExp then
        _txt = _txt .. tostring(data.addExp)
    else
        _txt = _txt .. "0"
    end
    local equip_name_label = XTHDLabel:createWithParams({
        text= _txt ,
        size = 16,
    })
    equip_name_label:setAnchorPoint(0.5,1)
    equip_name_label:setPosition(equip_box_bg:getContentSize().width/2, -22)
    equip_box_bg:addChild(equip_name_label)
    equip_box_bg:setScale(0.8)
    return equip_box_bg
end

function ZhanDouJieGuoPVELayer:ctor()
    self._failGo2Btns = {}

    local iswin = true
    if self._fightResult == 1 then
        iswin = true
        musicManager.playEffect(XTHD.resource.music.effect_battle_victory,false)
    elseif self._fightResult == 0 then
        iswin = false
         musicManager.playEffect(XTHD.resource.music.effect_battle_lost,false)
    end
    --设置成黑色具有透明度的背景
    self:setColor(cc.c3b(0, 0, 0))
    self:setOpacity(100)
    --胜利背景框
    local light_bg = XTHD.createSprite("res/image/tmpbattle/newBg.png")
    light_bg:setContentSize(light_bg:getContentSize().width,self:getContentSize().height)
    light_bg:setName("light_bg")
    self._light_bg = light_bg
    light_bg:setAnchorPoint(1,0.5)
    light_bg:setPosition(self:getContentSize().width,self:getContentSize().height/2)
    self:addChild(light_bg)
        
    local star = cc.Sprite:create("res/image/tmpbattle/star.png")
    self._light_bg:addChild(star)
    star:setPosition(self._light_bg:getContentSize().width/2 + 50,self._light_bg:getContentSize().height/2)
    star:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(50,360))))

    local tip = cc.Sprite:create("res/image/tmpbattle/tip.png")
    self._light_bg:addChild(tip)
    tip:setPosition(self._light_bg:getContentSize().width/2 + 50,290)
    self.tip = tip

    local tipText = XTHDLabel:createWithParams({
        text= "英雄经验",
        size = 16,
    })
    tip:addChild(tipText)
    tipText:setPosition(tip:getContentSize().width/2 + 15,tip:getContentSize().height/2)

    local avator_bg=XTHD.createSprite("res/image/tmpbattle/battle_result_cirecle.png")
    avator_bg:setAnchorPoint(0.5,0.5)
    avator_bg:setScale(0.7)
    avator_bg:setPosition(335+avator_bg:getContentSize().width/2,light_bg:getContentSize().height/2)
    -- avator_bg:runAction(cc.RepeatForever:create(cc.RotateBy:create(30,360)))
    light_bg:addChild(avator_bg,-1)
    -- math.randomseed(os.time())
    local sp_id= math.random(2)
    -- local  avator=XTHD.createSprite("res/image/tmpbattle/battle_result_avator"..sp_id..".png")
    local  avator=XTHD.createSprite("res/image/tmpbattle/battle_result_avator1.png")
    self:addChild(avator)
    avator:setPosition(self:getContentSize().width/4 + 15,self:getContentSize().height/2 - 10)
    -- avator:setScale(0.8)
    avator_bg:setVisible(false)

    if tonumber(self._battle_data.fightResult) == 1 then --胜利
           self._result_effect = sp.SkeletonAnimation:create( "res/spine/effect/battle_win/shengli.json", "res/spine/effect/battle_win/shengli.atlas",1.0);
    elseif tonumber(self._battle_data.fightResult) == 0 then --失败
    else--if tonumber(self._battle_data.win) == 3 then --平局

    end

    --数据
    self._battle_data_btn = XTHDPushButton:createWithParams({
        normalNode        ="res/image/tmpbattle/battle_data_normal.png" ,
        selectedNode      ="res/image/tmpbattle/battle_data_selected.png",
        needSwallow       = false,--是否吞噬事件
        fontSize=20,
        musicFile = XTHD.resource.music.effect_btn_common,
    })
    self._battle_data_btn:setScale(0.6)
    self._battle_data_btn:setAnchorPoint(0,0)
    self._battle_data_btn:setPosition(self:getContentSize().width/2 - 100,10)
    self:addChild(self._battle_data_btn)
    self._battle_data_btn:setTouchEndedCallback(function()
        if self._battle_data_btn:getOpacity() < 255 then
            return
        end
        -- XTHDTOAST("该功能暂未开启！")
        local pop=requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoShowHurtLayer.lua"):create(self._hurt_data,self._target_battle_type)
        self:addChild(pop)
    end)
    --重播
    -- self._battleReplay = XTHDPushButton:createWithParams({
    --     normalNode        ="res/image/tmpbattle/leavemsg_normal.png" ,
    --     selectedNode      ="res/image/tmpbattle/leavemsg_selected.png",
    --     needSwallow       = false,--是否吞噬事件
    --     fontSize=20,
    --     musicFile = XTHD.resource.music.effect_btn_common,
    -- })
    -- self._battleReplay:setAnchorPoint(0,0)
    -- self._battleReplay:setPosition(200,(self:getContentSize().height-light_bg:getContentSize().height)/2+15)
    -- self:addChild(self._battleReplay)
    -- self._battleReplay:setTouchEndedCallback(function()
    --     if self._battleReplay:getOpacity() < 255 then
    --         return
    --     end
    --     self:setVisible(false)
    --     XTHD.dispatchEvent({
    --         name = EVENT_NAME_BATTLE_REPLAY, 
    --         data = {
    --             replayEndCallback = function()
    --                 musicManager.stopBackgroundMusic()
    --                 self:setVisible(true)
    --             end
    --         }
    --     })
    -- end)
    local again_btn 
    again_btn = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(142,49),
        isScrollView = false,
        text = LANGUAGE_KEY_BACK,
        fontSize = 28,
        anchor = cc.p(0, 0),
        musicFile = XTHD.resource.music.effect_btn_commonclose,
        pos = cc.p(self:getContentSize().width/2+350,10),
        endCallback = function ( ... )
            ----引导
            again_btn:setClickable(false)
            local _toMian = YinDaoMarg:getInstance():isCurtGuideNeed2MainCity() 
            YinDaoMarg:getInstance():guideTouchEnd()    
            YinDaoMarg:getInstance():releaseGuideLayer()
            print("the current guide need to maincity ",_toMian)      
            -----------------  
            if not _toMian then 
                --在完全显示出来之前，不执行点击事件
                if again_btn:getOpacity() < 255 then
                    return
                end
                self:BattleAgain()
            end 
        end
    })
    again_btn:setScale(0.8)
    again_btn:setName("again_btn")
    again_btn:setCascadeOpacityEnabled(true)
    self:addChild(again_btn)
    -------------
    self._backChapterBtn = again_btn
    self._battle_data_btn:setCascadeOpacityEnabled(true)
    --上面的代码初始化一些基础元素，其他的根据战斗的结果来分别进行初始化
        --不管pvp是胜利还是失败，都走胜利结算，只是显示的特效是失败而已
    if tonumber(self._battle_data.fightResult) == BATTLE_RESULT.WIN  then
            self:InitWinUI(self._battle_data)
        
    elseif tonumber(self._battle_data.fightResult) == BATTLE_RESULT.FAIL  then  -- 在假数据中，fightResult为2，但是在后端服务器中为0
        self:InitFailedUI(self._battle_data)
        gameUser.setRefreshState(true)
    elseif tonumber(self._battle_data.fightResult) == BATTLE_RESULT.TIMEOUT then
        self:InitFailedUI(self._battle_data)
        gameUser.setRefreshState(true)
    end
    -----更新数据 
    YinDaoMarg:getInstance():getACover( self:getScene())
    self:doExtraFunc()
end

function ZhanDouJieGuoPVELayer:getBtnNode(imgpath,_size,_rect)

    local btn_node = ccui.Scale9Sprite:create(_rect,imgpath)
    btn_node:setContentSize(_size)
    btn_node:setCascadeOpacityEnabled(true)
    btn_node:setCascadeColorEnabled(true)

    return btn_node
end

function ZhanDouJieGuoPVELayer:UpdateHeroData(hero_data,heroid)
    --更新具体英雄的基本数据
    if hero_data then
        for i=1,#hero_data do
            local pro_data = string.split( hero_data[i],',')
            DBUpdateFunc:UpdateProperty( "userheros", pro_data[1], pro_data[2], heroid)
        end
    end
end

function ZhanDouJieGuoPVELayer:UpdateLordData(playerProperty)
    --更新玩家基本数据
    local _current = gameUser.getIngot()
    if playerProperty then
        for i=1,#playerProperty do
            local pro_data = string.split( playerProperty[i],',')
            DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2],nil)
        end
    end
    XTHD.resource.PVE11GiveIngot = gameUser.getIngot() - _current
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
end

function ZhanDouJieGuoPVELayer:onExit()
    YinDaoMarg:getInstance():removeCover( self:getScene())
    self._hurt_data = nil
end

function ZhanDouJieGuoPVELayer:onEnter()
    self.btnenable=true 
    musicManager.stopBackgroundMusic()
    local iswin = true
    if self._fightResult == 1 then
        iswin = true
    elseif self._fightResult == 0 or self._fightResult == 2 then
        iswin = false
    end
    gameUser.setFightingBlockStatu(self._fightResult)              
    --------引导 
    if self._target_battle_type == BattleType.PVE then 
        self:addGuide(iswin)
    end
    ------------------------
end

function ZhanDouJieGuoPVELayer:create(params,now_id)
    self._backCallback = params.backCallback
    if now_id then
        self._battle_id=now_id
    else
        self._battle_id=nil
    end
    self._target_battle_type = tonumber(params["battleType"]) 
    -- self._reportId = params["reportId"]
    self._hurt_data = {}
    self._hurt_data["afurts"] = params["afurts"]
    self._hurt_data["bfurts"] = params["bfurts"]

    self._levelup = false 
    self._battle_data = params

    if self._battle_data.playerProperty then
        for k,v in pairs(self._battle_data.playerProperty) do
            local pro_data = string.split( v,',')
            if tonumber(pro_data[1]) == 400 then 
                self._levelup = true
                self._levelupData = pro_data[2]
                self._delaytime=1.5
                break
            end 
        end
    end
    if self._levelup then
        sp.SkeletonAnimation:create( "res/spine/effect/level_up/xgn.json", "res/spine/effect/level_up/xgn.atlas",1.0) 
    end
    --addFeicui
    self._fightResult = tonumber(params.fightResult)
    self._timeOut = tonumber(params["timeOut"])
    self._original_hero_data = {} --存储英雄数据更新前的信息，做现实动画的时候，需要用到老数据
    --银两以道具的形式进行显示
    if params["addSilver"] and params["addSilver"] > 0 then
        params["items"][#params["items"] + 1]  = {
                    ["type"] = "type",
                    ["_type_"] = XTHD.resource.type.gold,
                    ["isShowCount"] = true,
                    ["count"] = params["addSilver"]
                }
    end

    if params["addHunyu"] and params["addHunyu"] > 0 then
        params["items"][#params["items"] + 1]  = {
                    ["type"] = "type",
                    ["_type_"] = XTHD.resource.type.soul,
                    ["isShowCount"] = true,
                    ["count"] = params["addHunyu"]
                }
    end
    --处理增加的真气
    if params.playerProperty then
        for k,v in pairs(params.playerProperty) do
            local pro_data = string.split( v,',')
            if tonumber(pro_data[1]) == 459 then     
                params["items"][#params["items"] + 1]  = {
                    ["type"] = "type",
                    ["_type_"] = XTHD.resource.type.zhenQi,
                    ["isShowCount"] = true,
                    ["count"] = tonumber(pro_data[2]) - tonumber(gameUser.getZhenqi())
                }
                break
            end 
        end
    end     

    --翡翠以道具的形式进行显示  hezhitao
    -- if tonumber(self._target_battle_type) == BattleType.JADITE_COPY_PVE then
        if params["addFeicui"] and params["addFeicui"] > 0 then
            params["items"][#params["items"] + 1]  = {
                        ["type"] = "type",
                        ["_type_"] = XTHD.resource.type.feicui,
                        ["isShowCount"] = true,
                        ["count"] = params["addFeicui"]
                    }
        end
    -- end

    if tonumber(self._target_battle_type) == BattleType.PVE 
        or tonumber(self._target_battle_type) == BattleType.ELITE_PVE 
        or tonumber(self._target_battle_type) == BattleType.DIFFCULTY_COPY 
        or tonumber(self._target_battle_type) == BattleType.PVP_CUTGOODS 
        or tonumber(self._target_battle_type) == BattleType.CAMP_PVP then  --PVE 模式
        self._battle_data.allPets = self._battle_data.allPets or {}
        if #self._battle_data.allPets > 0 then
            for i=1,#self._battle_data.allPets do
                local _key = self._battle_data.allPets[i]
                self._original_hero_data[_key] = DBTableHero.getData(gameUser.getUserId(), {["heroid"] = tonumber(_key)}) or {}
                local hero_data = self._battle_data.pet[tostring(self._battle_data.allPets[i])]
                if hero_data then
                    self:UpdateHeroData(hero_data["property"],self._battle_data.allPets[i])
                end
            end
        end
    elseif tonumber(self._target_battle_type) == BattleType.GODBEASE_PVE then -- 神兽副本
        local pNum = tonumber(params["addGodStone"]) or 0
        if pNum > 0 then 
            params["items"][#params["items"] + 1] =  {
                ["type"] = "type",
                ["_type_"] =  XTHD.resource.type.stone,
                ["isShowCount"] = true,
                ["count"] = params["addGodStone"]
            }
        end
        -- 组装pet结构
        self._battle_data["pet"] = {};
        local _petHps = self._battle_data["hps"]["petHps"];
        for i = 1, #_petHps do
            local _petId = _petHps[i]["petId"];
            local _hp = _petHps[i]["hp"];
            local _property = {};
            _property[#_property+1] = "200," .. tostring(_hp);
            local _data  = { ["property"] = _property}
            local _key = _petId
            self._battle_data["pet"][_key] = _data

            self._original_hero_data[_key] = DBTableHero.getData(gameUser.getUserId(), {["heroid"] = _key}) or {}
           
        end
    elseif tonumber(self._target_battle_type) == BattleType.SERVANT_PVE then -- 侍仆副本
        local pNum = tonumber(params["addWanlingpo"]) or 0
        if pNum > 0 then 
            params["items"][#params["items"] + 1] =  {
                ["type"] = "type",
                ["_type_"] =  XTHD.resource.type.servant,
                ["isShowCount"] = true,
                ["count"] = params["addWanlingpo"]
            }
        end
        -- 组装pet结构
        self._battle_data["pet"] = {};
        local _petHps = self._battle_data["hps"]["petHps"];
        for i = 1, #_petHps do
            local _petId = _petHps[i]["petId"];
            local _hp = _petHps[i]["hp"];
            local _property = {};
            _property[#_property+1] = "200," .. tostring(_hp);
            local _data  = { ["property"] = _property}
            local _key = _petId
            self._battle_data["pet"][_key] = _data

            self._original_hero_data[_key] = DBTableHero.getData(gameUser.getUserId(), {["heroid"] = _key}) or {}
           
        end

    elseif tonumber(self._target_battle_type) == BattleType.CAMP_PVP 
        or tonumber(self._target_battle_type) == BattleType.JADITE_COPY_PVE 
        or tonumber(self._target_battle_type) == BattleType.GOLD_COPY_PVE then  --翡翠副本
        self._battle_data["pet"] = {};
        self._battle_data["star"] = 3

    elseif   tonumber(self._target_battle_type) == BattleType.EQUIP_PVE then  --装备副本
        if params["addSmelt"] and tonumber(params["addSmelt"])>=1 then 
        params["items"][#params["items"] + 1] =  {
            ["type"] = "type",
            ["_type_"] = XTHD.resource.type.smeltPoint,
            ["isShowCount"] = true,
            ["count"] =params["addSmelt"]
        }
        gameUser.setSmeltPoint(params["curSmelt"])
        end
        self._battle_data["pet"] = {}
        self._battle_data["star"] = 3
    elseif tonumber(self._target_battle_type) == BattleType.OFFERREWARD_PVE then
        self._battle_data["items"] = self._battle_data["items"] or {}
        if params["addBounty"] and tonumber(params["addBounty"])>=1 then 
            self._battle_data["items"][#self._battle_data["items"] + 1] =  {
                ["type"] = "type",
                ["_type_"] = XTHD.resource.type.bounty,
                ["isShowCount"] = true,
                ["count"] =params["addBounty"]
            }
        end
        if params["addItem"] then
            for i=1, #params["addItem"] do
                local pD = params["addItem"][i]
                self._battle_data["items"][#self._battle_data["items"] + 1] = pD
            end
        end
        self._battle_data["pet"] = {}
    end

    if  tonumber(self._target_battle_type) == BattleType.PVP_CUTGOODS then
        if params["addRenown"] then
            params["items"][#params["items"] + 1]  = {
                        ["type"] = "type",
                        ["_type_"] = XTHD.resource.type.reputation,
                        ["isShowCount"] = true,
                        ["count"] = params["addRenown"]
                    }
        end
    end
    

   if tonumber(self._target_battle_type) == BattleType.CAMP_PVP 
        or tonumber(self._target_battle_type) == BattleType.EQUIP_PVE 
        or tonumber(self._target_battle_type) == BattleType.JADITE_COPY_PVE 
        or tonumber(self._target_battle_type) == BattleType.GODBEASE_PVE or tonumber(self._target_battle_type) == BattleType.SERVANT_PVE
        or tonumber(self._target_battle_type) == BattleType.GOLD_COPY_PVE  
        or tonumber(self._target_battle_type) == BattleType.OFFERREWARD_PVE then 
       local allPets = params["allPets"] or {}
        for i=1,#allPets do
            local _key = self._battle_data.allPets[i]
            self._original_hero_data[_key] = DBTableHero.getData(gameUser.getUserId(), {["heroid"] = _key}) or {}
            local idx = tostring(allPets[i])
            self._battle_data["pet"][idx] = {}
            self._battle_data["pet"][idx]["addExp"] = 0
            self._battle_data["pet"][idx]["property"] = {}
            self._battle_data["pet"][idx]["level"] = self._original_hero_data[_key]["level"]
        end
   end
       --dbid改版over
    if params.bagItems then
        for i=1,#params.bagItems do
           DBTableItem.updateCount(gameUser.getUserId(),params.bagItems[i], params.bagItems[i]["dbId"])
        end
    end
    if self._target_battle_type == BattleType.PVE or self._target_battle_type == BattleType.ELITE_PVE then
      if params["fightResult"] == 1 then
        else
            if self._target_battle_type == BattleType.ELITE_PVE then
 
            -- CopiesData.ChangeEliteTimes(GameControl:getInstancingData()["instancingid"],params["surplusCount"])
            end
        end
    end
    local layer = self.new()
    return layer
end

function ZhanDouJieGuoPVELayer:doExtraFunc(  )
    performWithDelay(self,function( )
        YinDaoMarg:getInstance():removeCover(self:getScene())
        if self._battle_data.playerProperty then
            self:UpdateLordData(self._battle_data.playerProperty)
        end
        -- DBUpdateFunc:LevelUp(self._levelupData)
        -------如果有引导更新引导的位置 
        local leveup = cc.Director:getInstance():getRunningScene():getChildByName("playerLevelUp")
        if leveup then ----如果有升级面板
            leveup:setExtraCallback(function( )
                YinDaoMarg:getInstance():setCurrentGuideVisibleStatu(true)
                if YinDaoMarg:getInstance():getCurrentGuideLayer() then 
                    local pos = self._backChapterBtn:convertToWorldSpace(cc.p(0,0))
                    YinDaoMarg:getInstance():getCurrentGuideLayer():refreshHand(pos)
                end
                YinDaoMarg:getInstance():onlyCapter1Guide({ -----执行第一章的特殊引导 (返回)
                    parent = self,
                    target = self._backChapterBtn
                })
            end)  
        else ------
            if YinDaoMarg:getInstance():getCurrentGuideLayer() then 
                local pos = self._backChapterBtn:convertToWorldSpace(cc.p(0,0))
                YinDaoMarg:getInstance():getCurrentGuideLayer():refreshHand(pos)
            end
        end
    end,self._delaytime or 0.2 )
end

function ZhanDouJieGuoPVELayer:addBattleFailGuide()
    local function addAFailGuide( )
        local target = self._failGo2Btns[2]
        if target then 
            local _layer = YinDao:create({
                target          = target,
                direction       = 2,
                action          = 2,
                isButton        = false,
                hasMask         = false,
                LinerGuide      = false,
                wordTips        = LANGUAGE_TIPS_WORDS279, -------尝试提升一下英雄等级吧
                extraCall       = function ()
                    _layer:removeFromParent()
                end,
                pos = cc.p(50,100)
            })
            self:addChild(_layer)
        end 
    end
    if YinDaoMarg:getInstance():increaseBattleTimes() == 1 then 
        local layer = StoryLayer:createWithParams({storyId = 17,callback = addAFailGuide,auto = false,opacity = 120})
        self:addChild(layer)
    else 
        addAFailGuide()
    end 
end

function ZhanDouJieGuoPVELayer:addGuide(iswin)    
    local isLevelup = false
    local hasIngot = false
    if self._battle_data.playerProperty then
        for k,v in pairs(self._battle_data.playerProperty) do
            local pro_data = string.split( v,',')
            if tonumber(pro_data[1]) == 400 then     
                isLevelup = true
                break
            end 
        end
    end     

    local block = gameUser.getInstancingId()
    print("at game result layer ,the block is,is win",block,iswin)
    if not iswin and block < 36 then -----如果前20关失败了点英雄
        self:addBattleFailGuide()     
    elseif iswin then         
        YinDaoMarg:getInstance():addGuide({ -----点击返回
            parent = self,
            target = self._backChapterBtn,
            needNext = false,
            visible = (not isLevelup),
        },{
            {2,1},
            {3,1},
        })    
        YinDaoMarg:getInstance():doNextGuide()
        if not isLevelup then  -----执行第一章的特殊引导 (返回)
            YinDaoMarg:getInstance():onlyCapter1Guide({
                parent = self,
                target = self._backChapterBtn
            })
        end 
    end 
end 

return ZhanDouJieGuoPVELayer
