--[[
pvp战斗结果 CreataBy huangjunjian 2015.08.17
]]
local ZhanDouJieGuoPVPLayer=class("ZhanDouJieGuoPVPLayer",function ( )
	return XTHDDialog:create()
end)
function ZhanDouJieGuoPVPLayer:ctor(params)
	
	self._pvp_data=params 

	self:initUI()
    
    musicManager.stopBackgroundMusic()
end

function ZhanDouJieGuoPVPLayer:initUI()
	local background=cc.Sprite:create("res/image/tmpbattle/newBg.png")
	background:setName("background")
    background:setContentSize(background:getContentSize().width,self:getContentSize().height)
    background:setAnchorPoint(1,0.5)
	background:setPosition(self:getContentSize().width,self:getContentSize().height/2)
	self:addChild(background)

    local star = cc.Sprite:create("res/image/tmpbattle/star.png")
    background:addChild(star)
    star:setPosition(background:getContentSize().width/2 + 50,background:getContentSize().height/2)
    star:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(50,360))))

    local tip = cc.Sprite:create("res/image/tmpbattle/tip.png")
    background:addChild(tip)
    tip:setPosition(background:getContentSize().width/2 + 50,235)
    self.tip = tip

    local tipText = XTHDLabel:createWithParams({
        text= "道具掉落",
        size = 16,
    })
    tip:addChild(tipText)
    tipText:setPosition(tip:getContentSize().width/2 + 15,tip:getContentSize().height/2)
    self.tip:setVisible(false)

    local avator_bg=cc.Sprite:create("res/image/tmpbattle/battle_result_cirecle.png")
    avator_bg:setScale(0.7)
    avator_bg:setAnchorPoint(0.5,0.5)
    -- avator_bg:runAction(cc.RepeatForever:create(cc.RotateBy:create(30,360)))
    avator_bg:setPosition(335+avator_bg:getContentSize().width/2,background:getContentSize().height/2)
    avator_bg:setVisible(false)
    background:addChild(avator_bg,-1)
    -- math.randomseed(os.time())
    local sp_id= math.random(2)
    local  avator=cc.Sprite:create("res/image/tmpbattle/battle_result_avator1.png")
    -- avator:setScale(0.8)
    self:addChild(avator)
    avator:setPosition(self:getContentSize().width/4 + 15,self:getContentSize().height/2 - 35)
    -- avator:setPosition(avator_bg:getPositionX(),avator_bg:getPositionY())

    --返回
    local backbtn 
    backbtn = XTHD.createCommonButton({
        btnSize = cc.size(142, 49),
        isScrollView = false,
        text = LANGUAGE_KEY_BACK,
        fontSize = 22,
        anchor = cc.p(0,0),
        musicFile = XTHD.resource.music.effect_btn_commonclose,
        endCallback = function()
            --在完全显示出来之前，不执行点击事件
            if backbtn:getOpacity() < 255 then
                return
            end
            self:backBtn()
        end
    })
    backbtn:setScale(0.8)
    backbtn:setName("backbtn")
    backbtn:setCascadeOpacityEnabled(true)
    backbtn:setPosition(self:getContentSize().width/2+350,10)
    self:addChild(backbtn)
    -------------
    self._backChapterBtn = backbtn
    -- self._battle_data_btn:setCascadeOpacityEnabled(true)

    --数据
    self._battle_data_btn = XTHDPushButton:createWithParams({
        normalNode        ="res/image/tmpbattle/battle_data_normal.png" ,
        selectedNode      ="res/image/tmpbattle/battle_data_selected.png",
        needSwallow       = false,--是否吞噬事件
        fontSize=20,
        musicFile = XTHD.resource.music.effect_btn_common,
    })
    self._battle_data_btn:setScale(0.8)
    self._battle_data_btn:setAnchorPoint(1,0)
    self._battle_data_btn:setPosition(self:getContentSize().width/2 - 30,10)
    self:addChild(self._battle_data_btn)
    if self._target_battle_type == BattleType.PVP_FRIEND then
        self._battle_data_btn:setVisible(false)
    end
    self._battle_data_btn:setTouchEndedCallback(function()
        if self._battle_data_btn:getOpacity() < 255 then
            return
        end
        -- XTHDTOAST("该功能暂未开启！")
        -- dump(self._hurt_data)
        local pop=requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoShowHurtLayer.lua"):create(self._hurt_data,self._target_battle_type)
        self:addChild(pop)
    end)
    
    --留言
    leavemsg_btn = XTHDPushButton:createWithParams({
        normalNode        ="res/image/tmpbattle/leavemsg_normal.png" ,
        selectedNode      ="res/image/tmpbattle/leavemsg_selected.png",
        needSwallow       = false,--是否吞噬事件
        fontSize=20,
    })
    leavemsg_btn:setVisible(false)
    leavemsg_btn:setAnchorPoint(0,0)
    leavemsg_btn:setPosition(self:getContentSize().width/2+100,0)
    self:addChild(leavemsg_btn)
    leavemsg_btn:setTouchEndedCallback(function()
        if leavemsg_btn:getOpacity() < 255 then
            return
        end
        self:ShowLeaveMsgPanel(self._reportId)
    end)

    --特效
    self._result_effect = sp.SkeletonAnimation:create( "res/spine/effect/battle_win/shengli.json", "res/spine/effect/battle_win/shengli.atlas",1.0)
    --玩家信息
    local playerlv=tonumber(gameUser.getLevel())
    local exp_progress_bg = cc.Sprite:create("res/image/tmpbattle/loardingbar_green_bg.png")
    exp_progress_bg:setAnchorPoint(0,0.5)
    exp_progress_bg:setPosition(background:getContentSize().width/2-120, 365)
    background:addChild(exp_progress_bg)
    local now_percent=(tonumber(gameUser.getExpNow())/tonumber(gameUser.getExpMax()))*100
    local exp_progress_timer = cc.ProgressTimer:create(cc.Sprite:create("res/image/tmpbattle/loardingbar_green.png")) 
    exp_progress_timer:setPosition(8, exp_progress_bg:getContentSize().height/2 + 2)
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
    if nex_exp >= tonumber(gameUser.getExpMax()) or self._levelup == true then
        --升级
        playerlv=tonumber(gameUser.getLevel())+1
        next_percent=(  (nex_exp-tonumber(gameUser.getExpMax())  ) /  tonumber(gameUser.getExpMax()) )*100
        exp_progress_timer:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.ProgressFromTo:create(0.5,now_percent,100),cc.CallFunc:create(function()
                                            exp_progress_timer:setPercentage(0)
                                        end),cc.ProgressFromTo:create(0.5,0,next_percent),
                                        cc.CallFunc:create(function()
                                         self:doExtraFunc()   
                                        end) )) 
    elseif nex_exp== tonumber(gameUser.getExpMax()) or self._levelup == true  then
        --升级
        playerlv=tonumber(gameUser.getLevel())+1
        next_percent=(  (nex_exp-tonumber(gameUser.getExpMax())  ) /  tonumber(gameUser.getExpMax()) )*100
        exp_progress_timer:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.ProgressFromTo:create(0.5,now_percent,100),cc.CallFunc:create(function()
                                            exp_progress_timer:setPercentage(0)
                                        end),
                                        cc.CallFunc:create(function()
                                         self:doExtraFunc()   
                                        end) ))         
    else
        --没升级
        next_percent=(nex_exp/tonumber(gameUser.getExpMax()))*100
        exp_progress_timer:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.ProgressFromTo:create(0.5,now_percent,next_percent)))

    end


    local exp="经验+"
    if self._pvp_data.addExp then
    	exp=exp..tostring(self._pvp_data.addExp)
    else
    	exp=exp.."0"
    end
    local exp_label=XTHDLabel:createWithParams({text=exp,ttf="",size=16})
    exp_label:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))
    exp_label:setPosition(exp_progress_bg:getContentSize().width/2 - 5,exp_progress_bg:getContentSize().height/2+2)
    exp_progress_bg:addChild(exp_label)                                           
    
    local exp_sp=cc.Sprite:create("res/image/tmpbattle/exp_sp.png")
    exp_sp:setAnchorPoint(0,0.5)
    exp_sp:setPosition(background:getContentSize().width/2-160, 370)
    background:addChild(exp_sp)

    local level_sp=cc.Sprite:create("res/image/tmpbattle/level_sp.png")
    level_sp:setAnchorPoint(0,0.5)
    level_sp:setPosition(background:getContentSize().width/2 - 115, 400)
    background:addChild(level_sp)

    local level_label=getCommonWhiteBMFontLabel(tostring(playerlv))
    level_label:setAnchorPoint(0,0.5)
    level_label:setPosition(background:getContentSize().width/2 - 35, 394)
    background:addChild(level_label)

    --排名
    self.rank=cc.Sprite:create()
    self.rank:setAnchorPoint(0,0.5)
    self.rank:setPosition(background:getContentSize().width/2-90, 300)
    if self._target_battle_type == BattleType.PVP_CHALLENGE  then  --类型 种族 抢夺  排位
    	self.rank:initWithFile("res/image/tmpbattle/pvp_resource.png")--抢夺
    	self.rank:setAnchorPoint(0,0.5)
        if tonumber(self._pvp_data.fightResult) == 1 then
            leavemsg_btn:setVisible(true)
        end
   	elseif self._target_battle_type == BattleType.CAMP_PVP then
   	    self.rank:initWithFile("res/image/tmpbattle/pvp_shengwang2.png")--种族
   	    self.rank:setAnchorPoint(0,0.5)
   	elseif self._target_battle_type ==  BattleType.PVP_LADDER then 
        if gameUser.getDuanId() ~= self.old_duan then   
            self.rank:initWithFile("res/image/tmpbattle/pvp_duan_up.png")--排行
            self.rank:setAnchorPoint(0,0.5) 
        else   
            self.rank:initWithFile("res/image/tmpbattle/pvp_rank.png")--排行
            self.rank:setAnchorPoint(0,0.5)	
            if tonumber(self._pvp_data.fightResult) == 1 then
                local rank_label=XTHDLabel:createWithParams({text=self._pvp_data.rankId,ttf="",size=30})
                rank_label:setAnchorPoint(0,0.5)
                rank_label:setColor(cc.c3b(26,158,207))
                rank_label:setPosition(self.rank:getPositionX()+self.rank:getContentSize().width+10,self.rank:getPositionY())
                background:addChild(rank_label)
                local num=tonumber(self.old_rank)-tonumber(self._pvp_data.rankId)
                if num>0 then
                    local left=XTHDLabel:createWithParams({text="(",ttf="",size=30})
                    left:setColor(cc.c3b(54,255,48))
                    left:setPosition(rank_label:getPositionX()+rank_label:getContentSize().width+15,self.rank:getPositionY())
                    background:addChild(left)

                    local up_sp=cc.Sprite:create("res/image/tmpbattle/rank_up.png")
                    up_sp:setAnchorPoint(0,0.5)
                    up_sp:setPosition(left:getPositionX()+left:getContentSize().width+10,self.rank:getPositionY())
                    background:addChild(up_sp)

                    
                    local rank_up=XTHDLabel:createWithParams({text=num.." )",ttf="",size=30})
                    rank_up:setColor(cc.c3b(54,255,48))
                    rank_up:setPosition(up_sp:getPositionX()+up_sp:getContentSize().width+30,self.rank:getPositionY())
                    background:addChild(rank_up)
                end
                            
            elseif tonumber(self._pvp_data.fightResult) == 0 then
                local rank_label=XTHDLabel:createWithParams({text=self._pvp_data.rankId,ttf="",size=30})
                rank_label:setAnchorPoint(0,0.5)
                rank_label:setPosition(self.rank:getPositionX()+self.rank:getContentSize().width+10,self.rank:getPositionY())
                background:addChild(rank_label)
            end
        end     	
    end
    background:addChild(self.rank)
    self.tip:setVisible(false)
    self._battle_data.items = self._battle_data.items or {}
    for k=1,#self._battle_data.items do
        local equip_data = self._battle_data.items[k]
        if equip_data then
            self.tip:setVisible(true)
            local equip_item = nil
            if equip_data["type"] then
                equip_item = self:makeDropItem(equip_data)
            end
            if not equip_item then
                break
            end
            local _item_scale = 0.8
            equip_item:setAnchorPoint(0,1)
            equip_item:setScale(_item_scale)
            equip_item:setPosition(background:getContentSize().width/2-65+102*(k-1)*_item_scale, 190)
            equip_item:setVisible(false)
            background:addChild(equip_item)
            equip_item:runAction(cc.Sequence:create(cc.DelayTime:create(0.12*(k+1)),cc.CallFunc:create(function()
                equip_item:setVisible(true) --EaseBounceOut
                if k == #self._battle_data.items then
                    -- showButtonAnimation()
                end
            end),cc.EaseExponentialOut:create(cc.Sequence:create(cc.ScaleTo:create(0.07,1.15*_item_scale),cc.ScaleTo:create(0.07,1.0*_item_scale)))))
        end
    end
    --奖励
    if tonumber(self._pvp_data.fightResult) == BATTLE_RESULT.WIN  then--成功
        musicManager.playEffect(XTHD.resource.music.effect_battle_victory,false)
    	self:initWin()
    elseif tonumber(self._pvp_data.fightResult) == BATTLE_RESULT.FAIL  then--失败
        musicManager.playEffect(XTHD.resource.music.effect_battle_lost,false)
    	self:initFail()
    elseif tonumber(self._pvp_data.fightResult) == BATTLE_RESULT.TIMEOUT  then--超时
        musicManager.playEffect(XTHD.resource.music.effect_battle_lost,false)
        self:initFail()    
    end
    self:doExtraFunc()
end

function ZhanDouJieGuoPVPLayer:initWin()
	local background=self:getChildByName("background")
	self._result_effect:setPosition(background:getContentSize().width/2 + 50, background:getContentSize().height-110)
    background:addChild(self._result_effect)
end

function ZhanDouJieGuoPVPLayer:initFail()
	local background=self:getChildByName("background")
	local _result_effect=cc.Sprite:create("res/image/tmpbattle/result_faild.png")
    if tonumber(self._pvp_data.fightResult) == BATTLE_RESULT.TIMEOUT then
       _result_effect=cc.Sprite:create("res/image/tmpbattle/result_outtime.png")
    end
	_result_effect:setPosition(background:getContentSize().width/2 + 50, background:getContentSize().height - 90)
    background:addChild(_result_effect)
end

function ZhanDouJieGuoPVPLayer:ShowLeaveMsgPanel(report_id)--战报id
    local JingJiCompetitiveMsgPop = requires("src/fsgl/layer/JingJi/JingJiCompetitiveMsgPop.lua"):create(report_id,function ()
    end)
    self:addChild(JingJiCompetitiveMsgPop,4)
    JingJiCompetitiveMsgPop:show()
end

function ZhanDouJieGuoPVPLayer:backBtn()
    if self._target_battle_type == BattleType.PVP_CHALLENGE or self._target_battle_type == BattleType.CAMP_PVP or self._target_battle_type == BattleType.PVP_LADDER then --PVP
        if self._target_battle_type == BattleType.PVP_CHALLENGE then
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PVP_TEAMINFO})
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PVP_MAIN_LAYER}) 
        elseif self._target_battle_type ==  BattleType.PVP_LADDER then
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PVP_MAIN_LAYER})
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PVP_LADDER_LAYER})
        end        
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    if self._target_battle_type == BattleType.CAMP_TEAMCOMPARE and self._fightResult == 1 then ------种族防守队伍挑战
        self:removeFromParent()
        ZhongZuDatas:enterReassignTeamLayer(cc.Director:getInstance():getRunningScene())
    elseif self._target_battle_type == BattleType.CASTELLAN_FIGHT then ------种族城主挑战 
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_CASTELLEN_AFTER_BATTLE})
        cc.Director:getInstance():popScene()
    else 
        cc.Director:getInstance():popScene()
    end 
end

function ZhanDouJieGuoPVPLayer:UpdateLordData(playerProperty)
     --更新玩家基本数据
    if playerProperty then
        for i=1,#playerProperty do
            local pro_data = string.split( playerProperty[i],',')
            DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
        end
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
end

function ZhanDouJieGuoPVPLayer:makeDropItem(data)
    return ItemNode:createWithParams(data)
end

function ZhanDouJieGuoPVPLayer:getBtnNode(imgpath,_size,_rect)

    local btn_node = ccui.Scale9Sprite:create(_rect,imgpath)
    btn_node:setContentSize(_size)
    btn_node:setCascadeOpacityEnabled(true)
    btn_node:setCascadeColorEnabled(true)

    return btn_node
end

function ZhanDouJieGuoPVPLayer:create(params)
	self._target_battle_type = tonumber(params["battleType"]) 
    self._reportId = params["reportId"]
    self._hurt_data = {}
    self._hurt_data["afurts"] = params["afurts"]
    self._hurt_data["bfurts"] = params["bfurts"]

    self._battle_data = params
    self._levelup = false 
    if self._battle_data.playerProperty then
        for k,v in pairs(self._battle_data.playerProperty) do
            local pro_data = string.split( v,',')
             -- dump(pro_data)
            if tonumber(pro_data[1]) == 400 then 
                self._levelup = true
                break
            end 
        end
    end
    --addFeicui
    self._fightResult = tonumber(params.fightResult)
    self._timeOut = tonumber(params["timeOut"])
    --PVP模式
    if tonumber(self._target_battle_type) == BattleType.PVP_CHALLENGE then
        -- gameUser.setShengwang(params["curShengWang"])
        print("pvp 模式")
        local petIdList = params["petIdList"]
        for i=1,#petIdList do
            local _list = petIdList[i]["pets"]
            local pet_hero_data = params["pet"][i]["pets"]
            if _list and pet_hero_data then
                for j=1,#_list do
                    local _key = _list[j]
                    -- self._original_hero_data[_key] = DBTableHero.getData(gameUser.getUserId(), {["heroid"] = _key}) or {}            
                    local hero_data = pet_hero_data[_list[j]]
                    if hero_data then
                        self:UpdateHeroData(hero_data["property"],_list[j])
                    end
                end
            end
        end
        if params["addSilver"] and tonumber(params["addSilver"])>0 then
        params["items"][#params["items"] + 1]  = {
                        ["type"] = "type",
                        ["_type_"] = XTHD.resource.type.gold,
                        ["isShowCount"] = true,
                        ["count"] = params["addSilver"]
                    }
        end
        if params["addFeicui"] and tonumber(params["addFeicui"])>0 then
            params["items"][#params["items"] + 1] =  {
                ["type"] = "type",
                ["_type_"] = XTHD.resource.type.feicui,
                ["isShowCount"] = true,
                ["count"] = params["addFeicui"]
            }
        end
        --  奖牌获取数量
        params["items"][#params["items"] + 1] =  {
            ["type"] = "type",
            ["_type_"] = XTHD.resource.type.reward,
            ["isShowCount"] = true,
            ["count"] = 1
        }
    elseif  tonumber(self._target_battle_type) == BattleType.CAMP_PVP then  -- 种族战
        print("pvp 种族战")
        for i=1,#self._battle_data.allPets do
            local _key = self._battle_data.allPets[i]
            local hero_data = self._battle_data.pet[tostring(self._battle_data.allPets[i])]
            if hero_data then
                self:UpdateHeroData(hero_data["property"],self._battle_data.allPets[i])
            end
            if  tonumber(self._target_battle_type) == BattleType.CAMP_PVP then
                self._battle_data.pet[_key] = { ["property"] = {}}
            end
        end

        --去掉种族战奖励
        -- -- 如果游戏失败奖牌获取25 胜利50
        -- local honorCount = 0;
        -- if tonumber(self._fightResult) == BATTLE_RESULT.FAIL then
        --     honorCount = 25
        -- else
        --     honorCount = 50
        -- end
        
        -- params["items"][#params["items"] + 1] =  {
        --     ["type"] = "type",
        --     ["_type_"] = XTHD.resource.type.honor,
        --     ["isShowCount"] = true,
        --     ["count"] = honorCount
        -- }
    
    elseif tonumber(self._target_battle_type) == BattleType.PVP_LADDER  then  --排位赛
        print("pvp 排位赛")
        self.old_rank=gameUser.getDuanRank()
        self.old_duan=gameUser.getDuanId()
        if tonumber(self.old_duan) ~= tonumber(params["duanId"]) then
            -- local JingJiCompetitiveLevelChangeLayer = requires("src/fsgl/layer/JingJi/JingJiCompetitiveLevelChangeLayer.lua").new(params["duanId"])
            local JingJiCompetitiveLevelChangeLayer = requires("src/fsgl/layer/common/DuanAdvanceLayer.lua"):create(params["duanId"])
            cc.Director:getInstance():getRunningScene():addChild(JingJiCompetitiveLevelChangeLayer,100)
            gameUser.setDuanId(tonumber(params["duanId"]))
        end 
        gameUser.setDuanId(params["duanId"]) 
        gameUser.setDuanRank(params["rankId"])
        if params["addFeicui"] and tonumber(params["addFeicui"])>0 then
            params["items"][#params["items"] + 1] =  {
                ["type"] = "type",
                ["_type_"] = XTHD.resource.type.feicui,
                ["isShowCount"] = true,
                ["count"] = params["addFeicui"]
            }
        end
        if params["addSilver"] and tonumber(params["addSilver"])>0 then
            params["items"][#params["items"] + 1]  = {
                        ["type"] = "type",
                        ["_type_"] = XTHD.resource.type.gold,
                        ["isShowCount"] = true,
                        ["count"] = params["addSilver"]
                    }
        end
        params["items"][#params["items"] + 1] =  {
            ["type"] = "type",
            ["_type_"] = XTHD.resource.type.reward,
            ["isShowCount"] = true,
            ["count"] = 2
        }
    end
       --dbid改版over
    if params.bagItems then
        for i=1,#params.bagItems do
           DBTableItem.updateCount(gameUser.getUserId(),params.bagItems[i], params.bagItems[i]["dbId"])
        end
    end

	return ZhanDouJieGuoPVPLayer.new(params)
end
function ZhanDouJieGuoPVPLayer:doExtraFunc( )
    performWithDelay(self,function(  )
        self:UpdateLordData(self._battle_data.playerProperty)            
    end,1.0)
end
function ZhanDouJieGuoPVPLayer:onEnter( )
end

return ZhanDouJieGuoPVPLayer