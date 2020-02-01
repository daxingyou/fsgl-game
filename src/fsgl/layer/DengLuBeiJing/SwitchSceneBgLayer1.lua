local SwitchSceneBgLayer1  = class( "SwitchSceneBgLayer1", function (  )
	return XTHDDialog:create()
end)

function SwitchSceneBgLayer1:ctor()
	local width = self:getContentSize().width
    local height = self:getContentSize().height

    
    --天空
--    local skin = cc.Sprite:create("res/image/login/skin.png")
--    --skin:setScale(0.68)
--    skin:setPosition(width/2, height/2)
--    self:addChild(skin)
    --云1 
    local yun_1 = cc.Sprite:create("res/image/login/yun_1.png")
    yun_1:setScale(0.68)
    yun_1:setPosition(width/2-200,height/1.1)
    self:addChild(yun_1)

    local yun_2 = cc.Sprite:create("res/image/login/yun_2.png")
    yun_2:setScale(0.68)
    yun_2:setPosition(width/2+400,height/1.1)
    self:addChild(yun_2)

    --动作 
    yun_1:runAction(cc.RepeatForever:create( cc.Sequence:create(cc.MoveTo:create(30,cc.p(0, yun_1:getPositionY())),cc.MoveTo:create(30,cc.p(width, yun_1:getPositionY())))))

    yun_2:runAction(cc.RepeatForever:create( cc.Sequence:create(cc.MoveTo:create(50,cc.p(0, yun_2:getPositionY())),cc.MoveTo:create(30,cc.p(width, yun_2:getPositionY()))))) 

    
    --山
    local login_bg = cc.Sprite:create("res/image/login/login_bg.png")
    -- login_bg:setScale(0.68)
    local bsize=login_bg:getContentSize()
    login_bg:setContentSize(width,height)
    login_bg:setPosition(width/2, height/2)
    self:addChild(login_bg)
    -- 云2
    local yun_3 = cc.Sprite:create("res/image/login/yun_3.png")
    yun_3:setScale(0.68)
    yun_3:setPosition(width/2,height/1.1)
    self:addChild(yun_3)

    local yun_4 = cc.Sprite:create("res/image/login/yun_4.png")
    yun_4:setScale(0.68)
    yun_4:setPosition(width/2,height/1.4)
    self:addChild(yun_4)

    local yun_5 = cc.Sprite:create("res/image/login/yun_5.png")
    yun_5:setScale(0.68)
    yun_5:setPosition(width/2-200,height/1.5)
    self:addChild(yun_5)

    --云的动作
    yun_3:runAction(cc.RepeatForever:create( cc.Sequence:create(cc.MoveTo:create(30,cc.p(0, yun_3:getPositionY())),cc.MoveTo:create(30,cc.p(width, yun_3:getPositionY())))))

    yun_4:runAction(cc.RepeatForever:create( cc.Sequence:create(cc.MoveTo:create(40,cc.p(0, yun_4:getPositionY())),cc.MoveTo:create(30,cc.p(width, yun_4:getPositionY())))))

    yun_5:runAction(cc.RepeatForever:create( cc.Sequence:create(cc.MoveTo:create(50,cc.p(0, yun_5:getPositionY())),cc.MoveTo:create(30,cc.p(width, yun_5:getPositionY())))))
    --树
    local tree = cc.Sprite:create("res/image/login/tree.png")
    -- tree:setScale(0.68)
    tree:setPosition(width/2, height/2)
    self:addChild(tree)

    local game_name = XTHD.createSprite("res/image/login/lddlmlogo.png")
	game_name:setScale(0.5)
    game_name:setAnchorPoint(0.5,0.5)
    game_name:setPosition(self:getContentSize().width *0.5 - 15 , self:getContentSize().height *0.5 + game_name:getContentSize().height *0.25)
    self:addChild(game_name)

    local FloatingAds = "国新出审[2019]70号 出版单位：北京伯通电子出版社 出版物号：ISBN 978-498-05666-5 著作权人：深圳市乐友网络科技有限公司"
    --健康公告
    local jiangkuang = XTHDLabel:create(FloatingAds,16)
    jiangkuang:setColor(cc.c3b(255,255,255))
    jiangkuang:setAnchorPoint(0.5,0)
    jiangkuang:enableShadow(cc.c3b(255,255,255),cc.size(0.4,-0.4),0.4)
    -- jiangkuang:setPosition(20, height-160)
    jiangkuang:setPosition(width/2, 20)
    self:addChild(jiangkuang)

    local gonggao2 = "本网络游戏仅适合于年满18周岁以上的用户。如果您未满18周岁，不建议您注册并使用本网络游戏服务。"
    --健康公告
    local jiangkuang2 = XTHDLabel:create(gonggao2,12)
    jiangkuang2:setColor(cc.c3b(255,255,255))
    jiangkuang2:setAnchorPoint(0.5,0)
    jiangkuang2:enableShadow(cc.c3b(255,255,255),cc.size(0.4,-0.4),0.4)
    -- jiangkuang:setPosition(20, height-160)
    jiangkuang2:setPosition(width/2, 30)
   -- self:addChild(jiangkuang2)
    -- --落叶
    -- local yezi = cc.ParticleSystemQuad:create("res/image/login/yinno.plist")
    -- yezi:setScale(2.5)
    -- yezi:setPosition(width/4,height/1.3)
    -- yezi:setAutoRemoveOnFinish(false)
    -- self:addChild(yezi)
    -- --飞鸟
    -- local bird = cc.Sprite:create("res/image/login/bird/feiniaoa_01.png")
    -- bird:setScale(2)
    -- bird:setPosition(width/2,height/2)
    -- self:addChild(bird)
    -- local action = getAnimation("res/image/login/bird/feiniaoa_0",1,20,0.05)
    -- bird:runAction(cc.RepeatForever:create(action))
    

    --云
    -- local yun = cc.Sprite:create("res/image/login/yun.png")
    -- yun:setAnchorPoint(cc.p(1.0,0))
    -- yun:setPosition(0, 0)
    -- yun:setScale(2.0)
    -- self:addChild(yun)

    -- yun:runAction(cc.RepeatForever:create( cc.Sequence:create(cc.MoveTo:create(30,cc.p(yun:getBoundingBox().width * 2, yun:getPositionY())) 
    --     , cc.MoveTo:create(0,cc.p(-yun:getBoundingBox().width * 2, yun:getPositionY())) )))


    -- local panda_spine = sp.SkeletonAnimation:create("res/image/login/denglu.json", "res/image/login/denglu.atlas", 1.0)
    -- panda_spine:setPosition(width / 2, height / 2)
    -- self:addChild(panda_spine)
    -- panda_spine:setAnimation( 0, "animation", true )
    -- panda_spine:setTimeScale(0.3)

end

function SwitchSceneBgLayer1:create()
	return SwitchSceneBgLayer1.new()
end

return SwitchSceneBgLayer1