XTHDSprite = class("XTHDSprite", function(params)
  local obj = cc.Sprite:create()
  if type(params) == "string" then
    local _tmp = cc.Sprite:create(params)
    if _tmp then
      obj = _tmp
    end
  end
  return XTHDTouchExtend.extend(obj)
end)
function XTHDSprite:ctor(params)
  self._disPos = cc.p(0, 0)
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    self._disPos.x = 0
    self._disPos.y = 0
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
    local touchLocation = touch:getLocation()
    local prevLocation = touch:getPreviousLocation()
    self._disPos.x = self._disPos.x + math.abs(cc.pSub(touchLocation, prevLocation).x)
    self._disPos.y = self._disPos.y + math.abs(cc.pSub(touchLocation, prevLocation).y)
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    if math.abs(self._disPos.x) > 15 or 15 < math.abs(self._disPos.y) then
      return
    end
    local isVisible = self:isAllParentsVisible(self)
    local isContain = self:isContainTouch(self, touch)
    if isVisible and isContain and self:isClickable() and self:getTouchEndedCallback() then
      self:getTouchEndedCallback()()
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
  self._listener = listener
end
function XTHDSprite:createWithFile(file)
  return XTHDSprite.new(file)
end
function XTHDSprite:create(file)
  return XTHDSprite.new(file)
end
function XTHDSprite:createWithTexture(texture, rect)
  if not rect and texture then
    rect = cc.rect(0, 0, texture:getContentSize().width, texture:getContentSize().height)
  end
  local obj = XTHDSprite.new()
  obj:setTexture(texture)
  obj:setTextureRect(rect)
  return obj
end
