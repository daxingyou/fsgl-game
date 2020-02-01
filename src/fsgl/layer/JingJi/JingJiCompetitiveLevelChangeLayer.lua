--Created By Liuluyang 2015年04月14日
--段位
local TAG = "JingJiCompetitiveLevelChangeLayer"

local JingJiCompetitiveLevelChangeLayer = class("JingJiCompetitiveLevelChangeLayer",function ()
	return XTHDDialog:create(255)
end)

function JingJiCompetitiveLevelChangeLayer:ctor(duanId)
	self:initUI(duanId)
end

function JingJiCompetitiveLevelChangeLayer:initUI(duanId)
    local perId = gameUser.getDuanId()
    gameUser.setDuanId(duanId)

	local UpOrDown = perId > duanId and 2 or 1 --1升级 2降级
    local RankListData = gameData.getDataFromCSV("CompetitiveDaily")
	local RankData = RankListData[gameUser.getDuanId()]--gameData.getDataFromCSV("CompetitiveDaily", {id=gameUser.getDuanId()})

	local titlePath = nil
	local lightPath = nil
	local titleStr = nil
	local DescStr = nil
	local titleColor = nil
	if UpOrDown ==  1 then
		titlePath = "res/image/common/title_flag.png"
		lightPath = "res/image/common/level_up_light.png"
		titleStr = LANGUAGE_VERBS.promotion----"晋级"
		DescStr = LANGUAGE_TIPS_WORDS23---------"进入更高组别"
		titleColor = cc.c3b(250,253,7)
	else
		titlePath = "res/image/common/title_failed.png"
		lightPath = "res/image/common/light_failed.png"
		titleStr = LANGUAGE_VERBS.demotion---------"降级"
		DescStr = LANGUAGE_TIPS_WORDS24--------"你的组别下降了"
		titleColor = cc.c3b(255,255,255)
	end

	local close_btn = XTHDPushButton:createWithParams({
         normalNode = cc.Sprite:create("res/image/common/btn9_normal.png"),
         selectedNode = cc.Sprite:create("res/image/common/btn9_select.png"),
         needSwallow = true,
         enable = true,
         text = LANGUAGE_KEY_SURE,-----"确 定",
         endCallback = function ()
            self:removeFromParent()
         end
    })
    close_btn:getLabel():setFontSize(24)
    close_btn:getLabel():setColor(cc.c3b(241,225,115))
    close_btn:setPosition(self:getBoundingBox().width/2,60)
    self:addChild(close_btn)

    local light = cc.Sprite:create(lightPath)
    light:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height-119)
    self:addChild(light)

    local title = cc.Sprite:create(titlePath)
    title:setPosition(self:getBoundingBox().width/2,light:getPositionY()+15)
    self:addChild(title)

    local title_label = XTHDLabel:createWithParams({
        text = titleStr,
        fontSize = 48,
        color = titleColor
    })
    title_label:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-1),1)
    title_label:setPosition(title:getBoundingBox().width/2,title:getBoundingBox().height/2+20)
    title:addChild(title_label)

    local UpGradeTo = XTHDLabel:createWithParams({
        text = DescStr,
        fontSize = 18,
        color = cc.c3b(255,247,183)
    })
    UpGradeTo:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-1),1)
    UpGradeTo:setPosition(self:getBoundingBox().width/2,light:getPositionY()-30)
    self:addChild(UpGradeTo)
    UpGradeTo:setVisible(false)

    local Rank = XTHDLabel:createWithParams({
        text = RankData.rankname,
        fontSize = 30,
        color = cc.c3b(255,255,255)
    })
    Rank:setPosition(self:getBoundingBox().width/2,UpGradeTo:getPositionY()-20)
    self:addChild(Rank)

    local rankIcon = XTHD.createArenaRank(duanId)
    rankIcon:setPosition(self:getBoundingBox().width/2,Rank:getPositionY()-95)
    rankIcon:setScale(0.6)
    self:addChild(rankIcon)

    -- if gameUser.getDuanId() <= 8 then
        local ProgressPrestige = XTHDLabel:createWithParams({
            text = LANGUAGE_FORMAT_TIPS4(RankListData[gameUser.getDuanId()+1].needprestige-gameUser.getShengwang()),-------"(再有"..(RankListData[gameUser.getDuanId()+1].needprestige-gameUser.getShengwang()).."威望就可以晋级了)",
            fontSize = 18,
            color = cc.c3b(255,247,183)
        })
        ProgressPrestige:setPosition(self:getBoundingBox().width/2,close_btn:getPositionY()+60)
        self:addChild(ProgressPrestige)
    -- end

    local goldIcon = XTHD.createHeaderIcon(XTHD.resource.type.gold)
    goldIcon:setAnchorPoint(0,0.5)

    local extraGold = XTHDLabel:createWithParams({
        text = RankData.extragold,
        fontSize = 22,
        color = cc.c3b(255,255,255)
    })
    extraGold:setAnchorPoint(0,0.5)

    local emeraldIcon = XTHD.createHeaderIcon(XTHD.resource.type.feicui)
    emeraldIcon:setAnchorPoint(0,0.5)

    local extraEmerald = XTHDLabel:createWithParams({
        text = RankData.extraemerald,
        fontSize = 22,
        color = cc.c3b(255,255,255)
    })
    extraEmerald:setAnchorPoint(0,0.5)

    goldIcon:setPosition((self:getBoundingBox().width-goldIcon:getBoundingBox().width-extraGold:getBoundingBox().width-emeraldIcon:getBoundingBox().width-extraEmerald:getBoundingBox().width-50)/2,rankIcon:getPositionY()-150)
    self:addChild(goldIcon)
    extraGold:setPosition(goldIcon:getPositionX()+goldIcon:getBoundingBox().width,goldIcon:getPositionY())
    emeraldIcon:setPosition(extraGold:getPositionX()+extraGold:getBoundingBox().width+50,extraGold:getPositionY())
    extraEmerald:setPosition(emeraldIcon:getPositionX()+emeraldIcon:getBoundingBox().width,emeraldIcon:getPositionY())
    self:addChild(extraGold)
    self:addChild(emeraldIcon)
    self:addChild(extraEmerald)

    local MiddleLine = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS25,------"每次获胜后的额外奖励为：",
        fontSize = 22,
        color = cc.c3b(255,247,183)
    })
    MiddleLine:setPosition(self:getBoundingBox().width/2,goldIcon:getPositionY()+goldIcon:getBoundingBox().height/2+20)
    self:addChild(MiddleLine)

    local extraLabel = cc.Sprite:create("res/image/common/level_up_line.png")
    extraLabel:setPosition(self:getBoundingBox().width/2,MiddleLine:getPositionY()+extraLabel:getBoundingBox().height/2+30)
    self:addChild(extraLabel)


    title_label:setOpacity(0)
    title_label:setScale(5)
    UpGradeTo:setOpacity(0)
    Rank:setOpacity(0)
    rankIcon:setOpacity(0)
    Rank:setScale(5)
    rankIcon:setScale(2.5)

    MiddleLine:setOpacity(0)
    extraLabel:setOpacity(0)
    goldIcon:setOpacity(0)
    extraGold:setOpacity(0)
    emeraldIcon:setOpacity(0)
    extraEmerald:setOpacity(0)
    ProgressPrestige:setOpacity(0)

    title_label:runAction(cc.Sequence:create(cc.Spawn:create(cc.Sequence:create(cc.EaseIn:create(cc.ScaleTo:create(0.3,0.9),1.3),cc.ScaleTo:create(0.05,1.1),cc.ScaleTo:create(0.05,1)),cc.FadeIn:create(0.3)),cc.CallFunc:create(function ()
        UpGradeTo:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.FadeIn:create(0.2),cc.DelayTime:create(0.15),cc.CallFunc:create(function ()
            Rank:runAction(cc.Spawn:create(cc.Sequence:create(cc.EaseIn:create(cc.ScaleTo:create(0.3,0.9),1.3),cc.ScaleTo:create(0.05,1.1),cc.ScaleTo:create(0.05,1)),cc.FadeIn:create(0.3)))
            rankIcon:runAction(cc.Sequence:create(cc.Spawn:create(cc.Sequence:create(cc.EaseIn:create(cc.ScaleTo:create(0.3,0.54),1.3),cc.ScaleTo:create(0.05,0.66),cc.ScaleTo:create(0.05,0.6)),cc.FadeIn:create(0.3)),cc.CallFunc:create(function ()
                MiddleLine:runAction(cc.FadeIn:create(0.3))
                extraLabel:runAction(cc.FadeIn:create(0.3))
                goldIcon:runAction(cc.FadeIn:create(0.3))
                extraGold:runAction(cc.FadeIn:create(0.3))
                emeraldIcon:runAction(cc.FadeIn:create(0.3))
                extraEmerald:runAction(cc.FadeIn:create(0.3))
                ProgressPrestige:runAction(cc.FadeIn:create(0.3))
            end)))
        end)))
    end)))
end

return JingJiCompetitiveLevelChangeLayer