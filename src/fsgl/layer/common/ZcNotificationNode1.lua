--[[
	这个通知条作为好多界面通用的那种存在，先写在这里，后续需要修改或者重写，酌情修改即可，不需要询问creator 
]]
local ZcNotificationNode1 = class("ZcNotificationNode1", function()
	local _Notification_Node  = ccui.Scale9Sprite:create(cc.rect(186/2,13,1,1),"res/image/common/comon_notification_bg.png")
     _Notification_Node:setContentSize(cc.size(winWidth,_Notification_Node:getContentSize().height))
     _Notification_Node:setCascadeOpacityEnabled(true)
     _Notification_Node:setCascadeColorEnabled(true)
	return _Notification_Node
end)

function ZcNotificationNode1:ctor(_msg)
	-- _msg = _msg or ""
	-- self._notification_label = XTHDLabel:createWithParams({
 --            text = _msg,
 --            fontSize = 18,--字体大小
 --            pos = cc.p(winWidth/2,self:getContentSize().height/2),
 --            color = cc.c3b(216,211,200),
 --        })
 --    -- self._notification_label:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))
 --    self:addChild(self._notification_label)
end
function ZcNotificationNode1:create(_msg)
    return self.new(_msg)
end

function ZcNotificationNode1:RefreshWithNewMsg(_newMsg)
	self._notification_label:setString(_newMsg)
end

return ZcNotificationNode1