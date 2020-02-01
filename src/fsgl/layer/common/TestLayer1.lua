--显示错误的信息提示框
local TestLayer1 = class("TestLayer1", function()
    return XTHDDialog:create()
end)

function TestLayer1:onEnter()
    -- body
    print(">>>>>TestLayer1::onEnter");
end

function TestLayer1:onExit()
-- body
    print(">>>>>TestLayer1::onExit");
end

function TestLayer1:onCleanup()
-- body
    print(">>>>>TestLayer1::onCleanup");
end

function TestLayer1:init(param)

	local bg = cc.Sprite:create("background/bg_0.jpg")
	bg:setPosition(self:getContentSize().width / 2 , self:getContentSize().height / 2)
	self:addChild(bg)
	
	-- bg:setOpacity(0)
	
	local avator_big_2 = cc.Sprite:create("res/image/avatar/avatar_big_2.png")
	avator_big_2:setPosition(bg:getContentSize().width / 2 , bg:getContentSize().height / 2)
	bg:addChild(avator_big_2)

	avator_big_2:setOpacity(0)

	local autocombat_off = cc.Sprite:create("res/image/tmpbattle/eff_impact_slash_2.png")
	autocombat_off:setPosition(avator_big_2:getContentSize().width / 2 , avator_big_2:getContentSize().height / 2)
	avator_big_2:addChild(autocombat_off)

	autocombat_off:setOpacity(125)

	local herobucket = cc.Sprite:create("res/image/tmpbattle/herobucket.png")
	herobucket:setPosition(avator_big_2:getContentSize().width / 2 , avator_big_2:getContentSize().height / 2)
	autocombat_off:addChild(herobucket)
	herobucket:setOpacity(50)

	local avator_6 = cc.Sprite:create("res/image/avatar/avatar_6.png")
	avator_6:setPosition(100, 100)
	bg:addChild(avator_6)

	avator_big_2:setName("avator_big_2")
	autocombat_off:setName("autocombat_off")
	avator_6:setName("avator_6")

	-- ZCFadeOut(bg,3)

	-- autocombat_off:setOpacity(0)
	-- herobucket:setOpacity(125)

	-- setAllChildrenCascadeOpacityEnabled(bg)

	-- bg:runAction(cc.FadeTo:create(5,255))

	-- bg:setCascadeOpacityEnabled(true)
	-- avator_big_2:setCascadeOpacityEnabled(true)
	-- autocombat_off:setCascadeOpacityEnabled(true)
	-- avator_6:setCascadeOpacityEnabled(true)
end

function TestLayer1:onTouchBegan( touch, event )
    print(">>> TestLayer1:touchBegan");
    return true;
end

function TestLayer1:onTouchMoved( touch, event )
    -- body
    print("TestLayer1:move");
end

function TestLayer1:onTouchEnded( touch, event )
    print("TestLayer1:end")
-- body
end

function TestLayer1:ctor()
	
end

function TestLayer1:create(param)
	local layer = self.new();
	layer:init(param)
	return layer;
end

return TestLayer1;