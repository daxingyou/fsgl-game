XTHDDialog = class("XTHDDialog", function()
    local obj = cc.LayerColor:create()
    return XTHDTouchExtend.extend(obj)
end)

function XTHDDialog:ctor(opacity)
    if opacity then
        self:setOpacity(opacity)
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(self._needSwallow)
    listener:registerScriptHandler(function(touch, event)
        local isVisible = self:isAllParentsVisible(self)
        local isContain = self:isContainTouch(self, touch)
        if isVisible and isContain and self:isClickable() then
            if self:getTouchBeganCallback() then
                self:getTouchBeganCallback()()
            end
            return true
        end
        return false
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function(touch, event)
        end, cc.Handler.EVENT_TOUCH_MOVED)

    listener:registerScriptHandler(function(touch, event)
        local isVisible = self:isAllParentsVisible(self)
        local isContain = self:isContainTouch(self, touch)
        if isVisible and isContain and self:isClickable() and self:getTouchEndedCallback() then
            self:getTouchEndedCallback()()
        else
            -- Warning: missing end command somewhere! Added here
        end
    end, cc.Handler.EVENT_TOUCH_ENDED)
    
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    self._listener = listener
end

function XTHDDialog:onEnter()
end

function XTHDDialog:create(opacity)
    return self.new(opacity)
end