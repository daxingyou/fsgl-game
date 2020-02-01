--显示错误的信息提示框
local ShowBugLayer = class("ShowBugLayer", function()
    return XTHDDialog:create()
end)

function ShowBugLayer:onEnter()
    -- body
    -- print(">>>>>ShowBugLayer::onEnter");
end

function ShowBugLayer:onExit()
-- body
    -- print(">>>>>ShowBugLayer::onExit");
end

function ShowBugLayer:onCleanup()
-- body
    -- print(">>>>>ShowBugLayer::onCleanup");
    cc.Director:getInstance():resume()
end

function ShowBugLayer:ctor()
    cc.Director:getInstance():pause()
end

function ShowBugLayer:init(error_sting)

	error_sting = error_sting or "Error!"

	local bg = cc.Sprite:createWithTexture(nil,cc.rect(0,0,640,500))
	bg:setColor(cc.c3b(0,0,0))
	bg:setPosition(self:getContentSize().width / 2 , self:getContentSize().height / 2)
	self:addChild(bg)

    local scorllRect = ccui.ListView:create()
    scorllRect:setContentSize(cc.size(bg:getContentSize().width, bg:getContentSize().height))
    scorllRect:setDirection(ccui.ScrollViewDir.vertical)
    scorllRect:setScrollBarEnabled(false)
    scorllRect:setBounceEnabled(true)
    bg:addChild(scorllRect)
    scorllRect:setPosition(20,0)

    scorllRect:removeAllChildren()

    local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(600,500))

    local bug_label = XTHDLabel:create(error_sting,16)
	-- bug_label:setDimensions(600,500)
 --    bug_label:setPosition(cell:getContentSize().width / 2,cell:getContentSize().height / 2)
 --    bg:addChild(bug_label)

	layout:addChild(bug_label)
	bug_label:setPosition(layout:getContentSize().width / 2,layout:getContentSize().height / 2)
	bug_label:setDimensions(layout:getContentSize().width,layout:getContentSize().height)
    scorllRect:pushBackCustomItem(layout)

    local _btnBack = XTHDPushButton:createWithParams({

	    normalNode = cc.Sprite:create("res/image/common/btn/btn_red_close_normal.png"),
        selectedNode = cc.Sprite:create("res/image/common/btn/btn_red_close_selected.png"),
		isScrollView = true,
		needSwallow = true,
		enable = true,
		touchSize = cc.size(150,150),
		endCallback = function ()
			self:removeFromParent()
		end
	});
	_btnBack:setAnchorPoint(cc.p(1, 1))
	_btnBack:setPosition(cc.p(bg:getContentSize().width + 230, bg:getContentSize().height + 65))
	self:addChild(_btnBack)
end

function ShowBugLayer:onTouchBegan( touch, event )
    -- print(">>> ShowBugLayer:touchBegan");
    return true;
end

function ShowBugLayer:onTouchMoved( touch, event )
    -- body
    -- print("ShowBugLayer:move");
end

function ShowBugLayer:onTouchEnded( touch, event )
    -- print("ShowBugLayer:end")
-- body
end

function ShowBugLayer:create(error_sting)
	local layer = self.new()
	layer:init(error_sting)
	layer:setColor(cc.c3b(0,0,0))
    layer:setOpacity(200)
	return layer
end

return ShowBugLayer