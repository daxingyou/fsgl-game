XTHDTouchExtend = class("XTHDTouchExtend")
XTHDTouchExtend.__index = XTHDTouchExtend

function XTHDTouchExtend.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = { }
        tolua.setpeer(target, t)
    end
    setmetatable(t, XTHDTouchExtend)
    local function handler(event)
        if event == "enter" then
            target:onEnter()
        elseif event == "enterTransitionFinish" then
            target:onEnterTransitionFinish()
        elseif event == "exitTransitionStart" then
            target:onExitTransitionStart()
        elseif event == "cleanup" then
            target:onCleanup()
        elseif event == "exit" then
            target:onExit()
        end
    end
    target:registerScriptHandlerEnabled(true, handler)
    target._clickable = true
    target._needSwallow = true
    return target
end

function XTHDTouchExtend:onEnter()
end

function XTHDTouchExtend:onExit()
end

function XTHDTouchExtend:onEnterTransitionFinish()
end

function XTHDTouchExtend:onExitTransitionStart()
end

function XTHDTouchExtend:onCleanup()
end

function XTHDTouchExtend:registerScriptHandlerEnabled(enabled, handler)
    if enabled then
        handler = handler or function(event)
            if event == "enter" then
                self:onEnter()
            elseif event == "exit" then
                self:onExit()
            elseif event == "enterTransitionFinish" then
                self:onEnterTransitionFinish()
            elseif event == "exitTransitionStart" then
                self:onExitTransitionStart()
            elseif event == "cleanup" then
                self:onCleanup()
            end
        end
        self:registerScriptHandler(handler)
    else
        self:unregisterScriptHandler()
    end
    return self
end

function XTHDTouchExtend:isContainTouch(node, touch)
    local point = node:convertToNodeSpace(touch:getLocation())
    point.x = point.x * node:getScaleX()
    point.y = point.y * node:getScaleY()
    local s = node:getBoundingBox()
    local rect_ = cc.rect(0, 0, s.width, s.height)
    local touchSize = node._touchSize
    if touchSize ~= nil and 0 < touchSize.width and 0 < touchSize.height then
        rect_ = cc.rect((node:getBoundingBox().width - touchSize.width) / 2,(node:getBoundingBox().height - touchSize.height) / 2, touchSize.width, touchSize.height)
    end
    return cc.rectContainsPoint(rect_, point)
end

function XTHDTouchExtend:setTouchSize(size)
    self._touchSize = size
end

function XTHDTouchExtend:getTouchSize()
    return self._touchSize
end

function XTHDTouchExtend:setTouchScale(scale)
    self._touchScale = scale
end

function XTHDTouchExtend:getTouchScale()
    if self._touchScale == nil then
        self._touchScale = 1
    end
    return self._touchScale
end

function XTHDTouchExtend:setTouchEndedCallback(callback)
    self._endCallback = callback
end

function XTHDTouchExtend:getTouchEndedCallback()
    return self._endCallback
end

function XTHDTouchExtend:setTouchBeganCallback(callback)
    self._beganCallback = callback
end

function XTHDTouchExtend:getTouchBeganCallback(callback)
    return self._beganCallback
end

function XTHDTouchExtend:setClickable(clickable)
    self._clickable = clickable
end

function XTHDTouchExtend:isClickable()
    return self._clickable ~= nil and self._clickable == true and true or false
end

function XTHDTouchExtend:setSwallowTouches(flag)
    self._needSwallow = flag
    if self._listener then
        self._listener:setSwallowTouches(self._needSwallow)
    end
end

function XTHDTouchExtend:isSwallowTouches()
    if not self._needSwallow then
        self._needSwallow = true
    end
    return self._needSwallow
end


function XTHDTouchExtend:isAllParentsVisible(node, touch)
    local isVisible = true
    local location = nil
    if touch then
        location = touch:getLocation()
    end
    while node ~= nil do
        if node:isVisible() == false then
            isVisible = false
            break
        elseif self.isScrollView == true and location then
            local box = node:getBoundingBox()
            local posBL = node:convertToWorldSpace(cc.p(0, 0))
            local posRT = node:convertToWorldSpace(cc.p(box.width/node:getScaleX(), box.height/node:getScaleY()))
            local box1 = { x = posBL.x, y = posBL.y, width = box.width, height = box.height }
            local box2 = { x = posRT.x - box.width, y = posRT.y - box.height, width = box.width, height = box.height }
            if cc.rectContainsPoint(box1, location) == false or cc.rectContainsPoint(box2, location) == false then
                isVisible = false
                break
            end
        end
        node = node:getParent()
    end
    return isVisible
end
