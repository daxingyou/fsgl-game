XTHDPushButton = class("XTHDPushButton", function(params)
  local obj = cc.Sprite:create()
  if type(params) == "string" then
    local _tmp = cc.Sprite:create(params)
    if _tmp then
      obj = _tmp
    end
  end
  return XTHDTouchExtend.extend(obj)
end)
function XTHDPushButton:setLabel(label)
  if self._label ~= label then
    if label ~= nil then
      self:setLabelColor(label:getColor())
      label:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
      self:addChild(label, 1)
    end
    if self:getLabel() then
      self:getLabel():removeFromParent(true)
    end
    self._label = label
  end
  self:_resetChildrenPosition()
end
function XTHDPushButton:getLabel()
  return self._label
end
function XTHDPushButton:setText(text)
  text = tostring(text)
  if not self._label then
    local label = XTHDLabel:createWithParams({
      text = text,
      fontSize = self._fontSize,
      ttf = self._ttf,
      fnt = self._fnt
    })
    label:setColor(self:getLabelColor())
    self:setLabel(label)
  else
    self._label:setString(text)
  end
  self:_resetChildrenPosition()
end
function XTHDPushButton:setLabelSize(fontSize)
  if not self._label then
  else
    self._label:setFontSize(fontSize)
  end
  self:_resetChildrenPosition()
end
function XTHDPushButton:setLabelColor(c3b)
  if not self._label then
  else
    self._label:setColor(c3b)
  end
  self._LabelColor = c3b
end
function XTHDPushButton:getLabelColor()
  return self._LabelColor
end
function XTHDPushButton:setString(text)
  self:setText(text)
end
function XTHDPushButton:setSelected(flag)
  self._selected = flag
  if flag == true then
    if self:getStateSelected() then
      self:getStateSelected():setVisible(true)
    end
    if self:getStateNormal() then
      self:getStateNormal():setVisible(false)
    end
    if self:getStateDisable() then
      self:getStateDisable():setVisible(false)
    end
  elseif flag == false then
    if self:getStateSelected() then
      self:getStateSelected():setVisible(false)
    end
    if self:getStateNormal() then
      self:getStateNormal():setVisible(true)
    end
    if self:getStateDisable() then
      self:getStateDisable():setVisible(false)
    end
  end
end
function XTHDPushButton:setEnable(flag)
  flag = flag or false
  if flag == false and self:getStateDisable() then
    self:getStateDisable():setVisible(true)
    if self:getStateNormal() then
      self:getStateNormal():setVisible(false)
    end
    if self:getStateSelected() then
      self:getStateSelected():setVisible(false)
    end
  elseif flag == true then
    if self:getStateNormal() then
      self:getStateNormal():setVisible(true)
    end
    if self:getStateSelected() then
      self:getStateSelected():setVisible(false)
    end
    if self:getStateDisable() then
      self:getStateDisable():setVisible(false)
    end
  end
  self._enable = flag
end
function XTHDPushButton:isEnable()
  return self._enable
end
function XTHDPushButton:setStateNormal(label)
  if type(label) == "string" then
    label = cc.Sprite:create(label)
  end
  if self._normalNode ~= label then
    if label ~= nil then
      label:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
      self:addChild(label)
    end
    if self:getStateNormal() then
      self:getStateNormal():removeFromParent(true)
    end
    self._normalNode = label
  end
  self:_resetChildrenPosition()
end
function XTHDPushButton:getStateNormal()
  return self._normalNode
end
function XTHDPushButton:setStateSelected(label)
  if type(label) == "string" then
    label = cc.Sprite:create(label)
  end
  if self._selectedNode ~= label then
    if label ~= nil then
      label:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
      self:addChild(label)
      label:setVisible(false)
    end
    if self:getStateSelected() then
      self:getStateSelected():removeFromParent(true)
    end
    self._selectedNode = label
  end
  self:_resetChildrenPosition()
end
function XTHDPushButton:getStateSelected()
  return self._selectedNode
end
function XTHDPushButton:setStateDisable(label)
  if type(label) == "string" then
    label = cc.Sprite:create(label)
  end
  if self._disableNode ~= label then
    if label ~= nil then
      label:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
      self:addChild(label)
      label:setVisible(false)
    end
    if self:getStateDisable() then
      self:getStateDisable():removeFromParent(true)
    end
    self._disableNode = label
  end
  self:_resetChildrenPosition()
end
function XTHDPushButton:getStateDisable()
  return self._disableNode
end
function XTHDPushButton:setMusicFile(musicFile)
  self._musicFile = musicFile
end
function XTHDPushButton:getMusicFile()
  return self._musicFile
end
function XTHDPushButton:_calculateContentSize(label, normal, selected, disable)
  local sizetmp = self:getContentSize()
  local arr = {}
  if normal then
    arr[#arr + 1] = cc.size(normal:getBoundingBox().width, normal:getBoundingBox().height)
  end
  if selected then
    arr[#arr + 1] = cc.size(selected:getBoundingBox().width, selected:getBoundingBox().height)
  end
  if disable then
    arr[#arr + 1] = cc.size(disable:getBoundingBox().width, disable:getBoundingBox().height)
  end
  if label then
    arr[#arr + 1] = cc.size(label:getBoundingBox().width, label:getBoundingBox().height)
  end
  for i, v in pairs(arr) do
    if sizetmp.width * sizetmp.height < v.width * v.height then
      sizetmp = v
    end
  end
  return sizetmp
end
function XTHDPushButton:_resetChildrenPosition()
  local size = self:_calculateContentSize(self:getLabel(), self:getStateNormal(), self:getStateSelected(), self:getStateDisable())
  self:setContentSize(size)
  if self:getLabel() then
    self:getLabel():setPosition(cc.p(size.width / 2, size.height / 2))
  end
  if self:getStateNormal() then
    self:getStateNormal():setPosition(cc.p(size.width / 2, size.height / 2))
  end
  if self:getStateSelected() then
    self:getStateSelected():setPosition(cc.p(size.width / 2, size.height / 2))
  end
  if self:getStateDisable() then
    self:getStateDisable():setPosition(cc.p(size.width / 2, size.height / 2))
  end
end
function XTHDPushButton:setParams(params)
  local defaultParams = {
    normalNode = nil,
    selectedNode = nil,
    disableNode = nil,
    label = nil,
    normalFile = nil,
    selectedFile = nil,
    disableFile = nil,
    musicFile = nil,
    needSwallow = true,
    clickable = true,
    enable = true,
    beganCallback = nil,
    endCallback = nil,
    moveCallback = nil,
    ttf = nil,
    fnt = nil,
    text = nil,
    fontSize = 18,
    fontColor = cc.c3b(255, 255, 255),
    touchSize = cc.size(0, 0),
    touchScale = 1,
    anchor = cc.p(0.5, 0.5),
    pos = cc.p(0, 0),
	isTouchMoveselected = true,
    x = 0,
    y = 0,
    needEnableWhenMoving = false,
    needEnableWhenOut = false
  }
  if params == nil or type(params) == "string" then
    params = {}
  end
  for k, v in pairs(defaultParams) do
    if params[k] == nil then
      params[k] = v
    end
  end
  self._ttf = params.ttf
  self._fnt = params.fnt
  self._fontSize = params.fontSize
  self._isTouchMoveselected = params.isTouchMoveselected
  self.isScrollView = params.isScrollView or false
  self:setTouchSize(params.touchSize)
  self:setTouchScale(params.touchScale)
  self:setLabel(params.label)
  self:setStateNormal(params.normalNode)
  self:setStateSelected(params.selectedNode)
  self:setStateDisable(params.disableNode)
  self:setEnableWhenMoving(params.needEnableWhenMoving)
  self:setEnableWhenOut(params.needEnableWhenOut)
  self:setTouchBeganCallback(params.beganCallback)
  self:setTouchEndedCallback(params.endCallback)
  self:setTouchMovedCallback(params.moveCallback)
  self:setSwallowTouches(params.needSwallow)
  self:setClickable(params.clickable)
  self:setEnable(params.enable)
  self:setLabelColor(params.fontColor)
  if params.text ~= nil then
    self:setText(params.text)
  end
  if params.x ~= nil then
    self:setPositionX(params.x)
  end
  if params.y ~= nil then
    self:setPositionY(params.y)
  end
  if params.pos ~= nil then
    self:setPosition(params.pos)
  end
  if params.anchor ~= nil then
    self:setAnchorPoint(params.anchor)
  end
  if params.normalFile and self.normalNode == nil then
    local normalNode = cc.Sprite:create(params.normalFile)
    self:setStateNormal(normalNode)
  end
  if params.selectedFile and self._selectedNode == nil then
    local selectedNode = cc.Sprite:create(params.selectedFile)
    self:setStateSelected(selectedNode)
  end
  if params.disableFile and self._disableNode == nil then
    local _disableNode = cc.Sprite:create(params.disableFile)
    self:setStateDisable(_disableNode)
  end
  if params.musicFile and self._musicFile == nil then
    self:setMusicFile(params.musicFile)
  end
end
function XTHDPushButton:setTouchMovedCallback(callback)
  self._moveCallback = callback
end
function XTHDPushButton:getTouchMovedCallback()
  return self._moveCallback
end
function XTHDPushButton:doTouchBegan(touch, event)
  self._disPos.x = 0
  self._disPos.y = 0
  self._scaleX = self:getScaleX()
  self._scaleY = self:getScaleY()
  local isVisible = self:isAllParentsVisible(self,touch)
  local isContain = self:isContainTouch(self, touch)
  if isVisible and isContain and self:isClickable() and self:isEnable() then
    if self._selected == true then
      return true
    end
	if self._isTouchMoveselected then
		if self:getStateNormal() and self:getStateSelected() ~= nil then
		  self:getStateNormal():setVisible(false)
		end
		if self:getStateSelected() then
		  self:getStateSelected():setVisible(true)
		end
		if self:getStateDisable() then
		  self:getStateDisable():setVisible(false)
		end
	end
    self:setScaleX(self:getScaleX() * self:getTouchScale())
    self:setScaleY(self:getScaleY() * self:getTouchScale())
    self:playMusic()
    if self:getTouchBeganCallback() then
      self:getTouchBeganCallback()()
    end
    return true
  end
  return false
end
function XTHDPushButton:doTouchMoved(touch, event)
  local touchLocation = touch:getLocation()
  local prevLocation = touch:getPreviousLocation()
  self._disPos.x = self._disPos.x + math.abs(cc.pSub(touchLocation, prevLocation).x)
  self._disPos.y = self._disPos.y + math.abs(cc.pSub(touchLocation, prevLocation).y)
  local isVisible = self:isAllParentsVisible(self,touch)
  local isContain = self:isContainTouch(self, touch)
  if isVisible and isContain == false and self:isClickable() and self:isEnable() and self._selected ~= true then
	if self._isTouchMoveselected then
		if self:getStateNormal() then
		  self:getStateNormal():setVisible(true)
		end
		self:setScaleX(self._scaleX)
		self:setScaleY(self._scaleY)
		if self:getStateSelected() then
		  self:getStateSelected():setVisible(false)
		end
	end
  elseif isVisible and isContain == true and self:isClickable() and self:isEnable() and self._selected ~= true then
	if self._isTouchMoveselected then
		if self:getStateNormal() and self:getStateSelected() ~= nil then
		  self:getStateNormal():setVisible(false)
		end
		if self:getStateSelected() then
		  self:getStateSelected():setVisible(true)
		end
	end
    self:setScaleX(self._scaleX * self:getTouchScale())
    self:setScaleY(self._scaleY * self:getTouchScale())
  end
  if self._moveCallback then
    self._moveCallback(touch)
  end
end
function XTHDPushButton:doTouchEnd(touch, event)
  if self._selected == true then
    return
  end
  local isVisible = self:isAllParentsVisible(self,touch)
  local isContain = self:isContainTouch(self, touch)
  if self:getStateNormal() then
    self:getStateNormal():setVisible(true)
  end
  if self:getStateSelected() then
    self:getStateSelected():setVisible(false)
  end
  if self:getStateDisable() then
    self:getStateDisable():setVisible(false)
  end
  self:setScaleX(self._scaleX)
  self:setScaleY(self._scaleY)
  if self:getEnableWhenMoving() == true and (math.abs(self._disPos.x) > 15 or 15 < math.abs(self._disPos.y)) then
    return
  end
  if self:getEnableWhenOut() == true and isVisible and self:isClickable() and self:isEnable() then
    if self:getTouchEndedCallback() then
      self:getTouchEndedCallback()()
    end
    return
  end
  if isVisible and isContain and self:isClickable() and self:isEnable() and self:getTouchEndedCallback() then
    self:getTouchEndedCallback()()
  end
end
function XTHDPushButton:ctor(params)
  self:setParams(params)
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(self._needSwallow)
  self._disPos = cc.p(0, 0)
  listener:registerScriptHandler(function(touch, event)
    return self:doTouchBegan(touch, event)
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    self:doTouchMoved(touch, event)
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    self:doTouchEnd(touch, event)
  end, cc.Handler.EVENT_TOUCH_ENDED)
  listener:registerScriptHandler(function(touch, event)
    self:doTouchEnd(touch, event)
  end, cc.Handler.EVENT_TOUCHES_CANCELLED)
  local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
  self._listener = listener
end
function XTHDPushButton:setEnableWhenMoving(flag)
  self._needEnableWhenMoving = flag
end
function XTHDPushButton:getEnableWhenMoving()
  return self._needEnableWhenMoving
end
function XTHDPushButton:setEnableWhenOut(flag)
  self._needEnableWhenOut = flag
end
function XTHDPushButton:getEnableWhenOut()
  return self._needEnableWhenOut
end
function XTHDPushButton:playMusic()
  musicManager.playEffect(self:getMusicFile(), false)
end
function XTHDPushButton:createWithParams(params)
  local obj = XTHDPushButton.new(params)
  return obj
end
function XTHDPushButton:create(filePath)
  local obj = XTHDPushButton.new(filePath)
  return obj
end
function XTHDPushButton:createWithFile(filePath, params)
  local obj = XTHDPushButton:create(filePath)
  if params then
    obj:setParams(params)
  end
  return obj
end
function XTHDPushButton:createWithTexture(texture, rect)
  rect = rect or cc.rect(0, 0, texture:getContentSize().width, texture:getContentSize().height)
  local obj = XTHDPushButton.new()
  obj:setTexture(texture)
  obj:setTextureRect(rect)
  return obj
end
