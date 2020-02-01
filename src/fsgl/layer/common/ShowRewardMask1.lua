--[[
	FileName: ShowRewardMask1.lua
	Author: andong
	Date: 2015-12-30
	Purpose: xx界面
]]
local ShowRewardMask1 = class( "ShowRewardMask1", function ()
    return XTHDDialog:create()
end)
function ShowRewardMask1:ctor(params)
	self:initData(params)
	self:initUI()
end
function ShowRewardMask1:initData(params)
	self._callback = params.callback
end
function ShowRewardMask1:initUI()
	local popNode = XTHD.createSprite()
	popNode:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
	self:addChild(popNode)

	local CloseBtn = XTHDPushButton:createWithParams({
		touchSize = cc.size(10000,10000),
        endCallback = function ()
        	if self._callback and type(self._callback) == "function" then
        		self._callback()
        	end
            self:removeFromParent()
        end
    })
    CloseBtn:setPosition(popNode:getBoundingBox().width/2,popNode:getBoundingBox().height/2)
    popNode:addChild(CloseBtn)

end
function ShowRewardMask1:create(params)
	return self.new(params)
end

function ShowRewardMask1:onEnter()
end
function ShowRewardMask1:onCleanup()
end
function ShowRewardMask1:onExit()
end

return ShowRewardMask1