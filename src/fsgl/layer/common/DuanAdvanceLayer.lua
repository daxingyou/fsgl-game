--[[
晋级pop create by.huangjunjian 2015.7.17
]]

local DuanAdvanceLayer=class("DuanAdvanceLayer",function ()
	   return XTHDPopLayer:create()
end)          
function DuanAdvanceLayer:ctor(duanid)
	self:initUI(duanid)
end
function DuanAdvanceLayer:initUI(duanid)
	local RankListData = gameData.getDataFromCSV("CompetitiveDaily")
	local RankData = RankListData[duanid]
    -- local mengban_size = cc.Sprite:create("res/image/exchange/reward/reward_background.jpg"):getContentSize()
    local mengban_bg = cc.LayerColor:create()
    mengban_bg:setColor(cc.c3b(0,0,0))
    mengban_bg:setOpacity(200)
    mengban_bg:setContentSize(cc.size(self:getContentSize().width,self:getContentSize().height))
    mengban_bg:setPosition(0,0)
    self:addChild(mengban_bg)
    local _popBgSprite=cc.Sprite:create("res/image/plugin/duanadvance/up_bg.png")
    _popBgSprite:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
    -- self:addContent(_popBgSprite)
    self:addChild(_popBgSprite)
    local title=cc.Sprite:create("res/image/plugin/duanadvance/title.png")
    _popBgSprite:addChild(title)
    title:setPosition(_popBgSprite:getContentSize().width/2,_popBgSprite:getContentSize().height)

    local space_act=cc.Sprite:create("res/image/plugin/duanadvance/space_sp.png")
    space_act:setPosition(_popBgSprite:getContentSize().width/2,-30)
    _popBgSprite:addChild(space_act)

    --left  icon and effect

    local effect_cricle=cc.Sprite:create("res/image/plugin/duanadvance/circle_effect.png")
    effect_cricle:setPosition((_popBgSprite:getContentSize().width/2-effect_cricle:getContentSize().width/2-50),_popBgSprite:getContentSize().height/2)
    _popBgSprite:addChild(effect_cricle)
    effect_cricle:runAction(cc.RepeatForever:create(cc.RotateBy:create(30,360)))

	local duanicon=cc.Sprite:create("res/image/plugin/duanadvance/"..duanid..".png")
	duanicon:setPosition(effect_cricle:getPositionX(),effect_cricle:getPositionY())
	_popBgSprite:addChild(duanicon)
   
    --right  reward
    local  pointX=_popBgSprite:getContentSize().width/2-30
    local  pointY=_popBgSprite:getContentSize().height
    
    local reward_title=cc.Sprite:create("res/image/plugin/duanadvance/up_reward.png")
    reward_title:setAnchorPoint(0,0.5)
    _popBgSprite:addChild(reward_title)
    reward_title:setPosition(pointX,pointY-70)
    --首次晋级header_ingot.png
    local  reward_frist=cc.Sprite:create("res/image/plugin/duanadvance/frist_reward.png")
    reward_frist:setAnchorPoint(0,0.5)
    _popBgSprite:addChild(reward_frist)
    reward_frist:setPosition(pointX,reward_title:getPositionY()-40)

    local gold_sp1=cc.Sprite:create("res/image/common/header_ingot.png")
    gold_sp1:setAnchorPoint(0,0.5)
    gold_sp1:setPosition(pointX+reward_frist:getContentSize().width,reward_frist:getPositionY())
    _popBgSprite:addChild(gold_sp1)

    local  reward_frist_num=XTHDLabel:createWithParams({text=tostring(RankData.rewardingot),ttf="",size=22})
    reward_frist_num:setAnchorPoint(0,0.5)
    _popBgSprite:addChild(reward_frist_num)
    reward_frist_num:setPosition(gold_sp1:getPositionX()+gold_sp1:getContentSize().width,reward_frist:getPositionY())

    --挑战银两header_gold.png
    local  reward_1=XTHDLabel:createWithParams({text=LANGUAGE_TIPS_WORDS152,ttf="",size=18}) ------"晋级后每次挑战获胜奖励:"
    reward_1:setAnchorPoint(0,0.5)
    _popBgSprite:addChild(reward_1)
    reward_1:setPosition(pointX,reward_frist:getPositionY()-40)
    local gold_sp=cc.Sprite:create("res/image/common/header_gold.png")
    gold_sp:setAnchorPoint(0,0.5)
    gold_sp:setPosition(pointX+reward_1:getContentSize().width+5,reward_1:getPositionY())
    _popBgSprite:addChild(gold_sp)
    local reward_1_num=XTHDLabel:createWithParams({text=tostring(RankData.extragold),ttf="",size=18})
    reward_1_num:setAnchorPoint(0,0.5)
    reward_1_num:setPosition(gold_sp:getPositionX()+gold_sp:getContentSize().width,reward_1:getPositionY())
    _popBgSprite:addChild(reward_1_num)
    --挑战翡翠header_feicui.png
    local  reward_2=XTHDLabel:createWithParams({text=LANGUAGE_TIPS_WORDS152,ttf="",size=18}) ----"晋级后每次挑战获胜奖励: "
    reward_2:setAnchorPoint(0,0.5)
    _popBgSprite:addChild(reward_2)
    reward_2:setPosition(pointX,reward_1:getPositionY()-40)
    local feicui_sp=cc.Sprite:create("res/image/common/header_feicui.png")
    feicui_sp:setPosition(pointX+reward_2:getContentSize().width+20,reward_2:getPositionY())
    _popBgSprite:addChild(feicui_sp)

    local reward_2_num=XTHDLabel:createWithParams({text=tostring(RankData.extraemerald),ttf="",size=18})
    reward_2_num:setAnchorPoint(0,0.5)
    reward_2_num:setPosition(feicui_sp:getPositionX()+feicui_sp:getContentSize().width-15,reward_2:getPositionY())
    _popBgSprite:addChild(reward_2_num)

    --每天元宝header_ingot.png
    local  reward_3=XTHDLabel:createWithParams({text=LANGUAGE_TIPS_WORDS153,ttf="",size=18}) -------"晋级后每天奖励（邮件发送）:  "
    reward_3:setAnchorPoint(0,0.5)
    _popBgSprite:addChild(reward_3)
    reward_3:setPosition(pointX,reward_2:getPositionY()-40)
    local yuanbao_sp=cc.Sprite:create("res/image/common/header_ingot.png")
    yuanbao_sp:setPosition(pointX+reward_3:getContentSize().width+20,reward_3:getPositionY())
    _popBgSprite:addChild(yuanbao_sp)

    local reward_3_num=XTHDLabel:createWithParams({text=tostring(RankData.yuanbao),ttf="",size=18})
    reward_3_num:setAnchorPoint(0,0.5)
    reward_3_num:setPosition(yuanbao_sp:getPositionX()+yuanbao_sp:getContentSize().width-10,reward_3:getPositionY())
    _popBgSprite:addChild(reward_3_num)

    --每天奖牌res/image/common/header_award.png
    local  reward_4=XTHDLabel:createWithParams({text=LANGUAGE_TIPS_WORDS153,ttf="",size=18})-------"晋级后每天奖励（邮件发送）:  "
    reward_4:setAnchorPoint(0,0.5)
    _popBgSprite:addChild(reward_4)
    reward_4:setPosition(pointX,reward_3:getPositionY()-40)
    local pai_sp=cc.Sprite:create("res/image/common/header_award.png")
    pai_sp:setPosition(pointX+reward_4:getContentSize().width+20,reward_4:getPositionY())
    _popBgSprite:addChild(pai_sp)

    local reward_4_num=XTHDLabel:createWithParams({text=tostring(RankData.jiangpai),ttf="",size=18})
    reward_4_num:setAnchorPoint(0,0.5)
    reward_4_num:setPosition(pai_sp:getPositionX()+pai_sp:getContentSize().width-10,reward_4:getPositionY())
    _popBgSprite:addChild(reward_4_num)


end
function DuanAdvanceLayer:create(duanid)
	local PopLayer=DuanAdvanceLayer.new(duanid)
	return PopLayer
end
return DuanAdvanceLayer

