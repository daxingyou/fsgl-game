--  英雄介绍界面
HeroIntroduceLayer = class("HeroIntroduceLayer", function(params)
    return XTHDPopLayer:create()
end )

local skillName = {
    "天赋技能",
    "普通攻击",
    "初始技能",
    "1阶技能",
    "4阶技能",
    "8阶技能",
}

local skillPos = {
    45,
    50,
    125,
    205,
    285,
    365,
}

function HeroIntroduceLayer:ctor(params)
    self.heroid = params

    local width = self:getContentSize().width
    local height = self:getContentSize().height

    -- local bg_sp = ccui.Scale9Sprite:create(cc.rect(0, 0, 0, 0), "res/image/tmpbattle/desBg.png")
    local bg_sp = cc.Sprite:create("res/image/tmpbattle/desBg.png")
    bg_sp:setContentSize(615, 350)
    self.containerBg = bg_sp
    bg_sp:setCascadeOpacityEnabled(true)
    bg_sp:setPosition(width / 2, height / 2)
    self:addContent(bg_sp)

    local kuang = cc.Sprite:create("res/image/tmpbattle/kuang1.png")
    kuang:setContentSize(kuang:getContentSize().width + 30,kuang:getContentSize().height + 30)
    self.containerBg:addChild(kuang)
    kuang:setPosition(self.containerBg:getContentSize().width/2,self.containerBg:getContentSize().height/2 - 15)
    self.kuang1 = kuang

    local kuang2 = cc.Sprite:create("res/image/tmpbattle/kuang1.png")
    kuang2:setContentSize(kuang2:getContentSize().width + 30,kuang2:getContentSize().height + 10)
    self.containerBg:addChild(kuang2)
    kuang2:setPosition(self.containerBg:getContentSize().width/2,self.containerBg:getContentSize().height/2 - 110)
    self.kuang2 = kuang2

    self:show(true)

    self:initUI()
end

function HeroIntroduceLayer:initUI()
    local heroData = DBTableHero.getHeroData(self.heroid)
    -- print("英雄的数据为：")
    -- print_r(heroData)
    local advance = cc.Sprite:create(XTHD.resource.getQualityHeroBgPath(gameData.getDataFromCSV("GeneralInfoList",{heroid = self.heroid}).rank or 0))
    self.containerBg:addChild(advance)
    advance:setPosition(135,self.containerBg:getContentSize().height - 100)
    advance:setScale(0.7)

    local heroNode = cc.Sprite:create(XTHD.resource.getHeroAvatorImgById(self.heroid))
    advance:addChild(heroNode)
    heroNode:setPosition(advance:getContentSize().width/2,advance:getContentSize().height/2)

    local levelText = XTHDLabel:create("等级："..tostring(heroData.level),17,"res/fonts/def.ttf")
    levelText:setAnchorPoint(cc.p(0, 0.5))
    levelText:setColor(cc.c3b(60,0,0))
    self.containerBg:addChild(levelText)
    levelText:setPosition(advance:getPositionX() + 50,advance:getPositionY() + 10)

    local powerText = XTHDLabel:create("战力："..tostring(heroData.power),17,"res/fonts/def.ttf")
    powerText:setAnchorPoint(cc.p(0, 0.5))
    powerText:setColor(cc.c3b(60,0,0))
    self.containerBg:addChild(powerText)
    powerText:setPosition(levelText:getPositionX(),levelText:getPositionY() - 30)

    local name = gameData.getDataFromCSV("GeneralInfoList",{heroid = self.heroid}).name
    local jieshuText = XTHDLabel:create(name.."+"..tostring(heroData.advance),17,"res/fonts/def.ttf")
    jieshuText:setAnchorPoint(cc.p(0, 0.5))
    jieshuText:setColor(cc.c3b(60,0,0))
    self.containerBg:addChild(jieshuText)
    jieshuText:setPosition(advance:getPositionX() + 250,levelText:getPositionY())

    local starText = XTHDLabel:create("星级："..tostring(heroData.star).."星",17,"res/fonts/def.ttf")
    starText:setAnchorPoint(cc.p(0, 0.5))
    starText:setColor(cc.c3b(60,0,0))
    self.containerBg:addChild(starText)
    starText:setPosition(advance:getPositionX() + 250,levelText:getPositionY() - 30)

    local hpadd = XTHDLabel:create("生命加成："..tostring(heroData.hp),16,"res/fonts/def.ttf")
    hpadd:setAnchorPoint(cc.p(0, 0.5))
    hpadd:setColor(cc.c3b(60,0,0))
    self.kuang1:addChild(hpadd)
    hpadd:setPosition(25,self.kuang1:getContentSize().height - 20)

    local maadd = XTHDLabel:create("魔攻加成："..tostring(heroData.manaattack),16,"res/fonts/def.ttf")
    maadd:setAnchorPoint(cc.p(0, 0.5))
    maadd:setColor(cc.c3b(60,0,0))
    self.kuang1:addChild(maadd)
    maadd:setPosition(25,hpadd:getPositionY() - 30)

    local mdadd = XTHDLabel:create("魔防加成："..tostring(heroData.manadefence),16,"res/fonts/def.ttf")
    mdadd:setAnchorPoint(cc.p(0, 0.5))
    mdadd:setColor(cc.c3b(60,0,0))
    self.kuang1:addChild(mdadd)
    mdadd:setPosition(25,maadd:getPositionY() - 30)

    local paadd = XTHDLabel:create("物攻加成："..tostring(heroData.physicalattack),16,"res/fonts/def.ttf")
    paadd:setAnchorPoint(cc.p(0, 0.5))
    paadd:setColor(cc.c3b(60,0,0))
    self.kuang1:addChild(paadd)
    paadd:setPosition(235,self.kuang1:getContentSize().height - 20)

    local pdadd = XTHDLabel:create("物防加成："..tostring(heroData.physicaldefence),16,"res/fonts/def.ttf")
    pdadd:setAnchorPoint(cc.p(0, 0.5))
    pdadd:setColor(cc.c3b(60,0,0))
    self.kuang1:addChild(pdadd)
    pdadd:setPosition(235,paadd:getPositionY() - 30)

    for i = 5,0,-1 do
        if i ~= 4 then
            local skillDes = XTHDLabel:create(skillName[6 - i],13,"res/fonts/def.ttf")
            skillDes:setColor(cc.c3b(60,0,0))
            self.kuang2:addChild(skillDes)
            skillDes:setPosition(skillPos[6 - i],self.kuang2:getContentSize().height - 12)

            local skillItem = JiNengItem:createSkillById(self.heroid*6 - i)
            skillItem:setScale(0.5)
            self.kuang2:addChild(skillItem)
            skillItem:setPosition(skillPos[6 - i],self.kuang2:getContentSize().height/2 - 9)
        end
    end

end

function HeroIntroduceLayer:onExit()
    if self.closeCallback then
        self.closeCallback()
    end
end

function HeroIntroduceLayer:createWithParams(params)
    local layer = HeroIntroduceLayer.new(params)
    return layer
end

return HeroIntroduceLayer

