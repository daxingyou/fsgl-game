--此模块仅仅是为了实现钱庄英雄升级使用，其他地方如果需要使用，预期的效果本实现本模块不提供任何保证，请谨慎使用
--yanyuling
local  TouchSprite = class("TouchSprite", function(filepath)
	return ccui.Scale9Sprite:create(filepath)
end)

function TouchSprite:ctor(filepath)
	
	 --标记一下本次的位移差
	 self.oririna_touch_pos = nil
	 local function onTouchBegan(touch, event)
		   
		    if self:isContainTouchPos(touch) then
		    	if self._begancallback then
            		self._begancallback()
            	end
		    	self.oririna_touch_pos = touch:getLocation()
		    	return true
		    else
		    	return false
		    end
        end

        local function onTouchMoved(touch, event)
            if not  self:isContainTouchPos(touch) then
            	if self._cancelcallback then
            		
            		self._cancelcallback()
            	end
            end
            local touchLocation = touch:getLocation()
            if math.abs(touchLocation.x - self.oririna_touch_pos.x) > 10 or math.abs(touchLocation.y - self.oririna_touch_pos.y) > 10 then
            	if self._movecallback then
            		self._movecallback()
            	end
            end
            local prevLocation = touch:getPreviousLocation()
            touchLocation = cc.Director:getInstance():convertToGL( touchLocation )
            prevLocation = cc.Director:getInstance():convertToGL( prevLocation )
            local diff = cc.pSub(touchLocation, prevLocation)
            end_diff= diff
            touchMovedPoint = touchLocation --记录本次滑动的总得长度
        end
        local function onTouchEnded(touch, event)
            local touch_point = self:convertToNodeSpace(touch:getLocation())
		    local _boundbox = self:getBoundingBox()
		    local rect_ =  cc.rect(0, 0, _boundbox.width, _boundbox.height)
		   
		    if cc.rectContainsPoint( rect_, touch_point ) then
		    	if self._endedCallback then
		    		self._endedCallback()
		    	end
		    end
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(isChuantou)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end
function TouchSprite:isContainTouchPos(touch)
	local touch_point = self:convertToNodeSpace(touch:getLocation())
	local _boundbox = self:getBoundingBox()
	local rect_ =  cc.rect(0, 0, _boundbox.width, _boundbox.height)

	if cc.rectContainsPoint( rect_, touch_point ) then
		return true
	else
		return false
	end
end
function TouchSprite:setTouchCanceledCallback(cancelcallback)
	self._cancelcallback = cancelcallback
end
function TouchSprite:setTouchMovedCallback(movecallback)
	self._movecallback = movecallback
end
function TouchSprite:setTouchEndedCallback(endcallback)
	self._endedCallback = endcallback
end

function TouchSprite:setTouchBeganCallback(begancallback)
	self._begancallback = begancallback
end
function TouchSprite:create(filepath)
	return self.new(filepath)
end

return TouchSprite