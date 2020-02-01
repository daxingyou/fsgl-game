XTHDArrow = class("XTHDArrow", function(params)
  return cc.Sprite:create()
end)
function XTHDArrow:ctor(params)
  local fileName = params.fileName
  local autoRotate = params.autoRotate
  if autoRotate == nil then
    autoRotate = false
  end
  self:initWithFile(fileName)
  self._posRecord = {}
  if autoRotate == true then
    self:scheduleUpdateWithPriorityLua(function(dt)
      local fNowPosX, fNowPosY = self:getPosition()
      self:_record(cc.p(fNowPosX, fNowPosY))
      if #self._posRecord < 2 then
        return
      end
      local lastPos = self._posRecord[1]
      local nowPos = self._posRecord[2]
      local deltaY = nowPos.y - lastPos.y
      local deltaX = nowPos.x - lastPos.x
      local angel = deltaX > 0 and 0 or 180
      local K = deltaY / deltaX
      if deltaX ~= 0 then
        self:setRotation(angel - CC_RADIANS_TO_DEGREES(math.atan(K)))
      end
    end, 0)
  end
end
function XTHDArrow:_record(data)
  if self.m_recordPosList == nil then
    self.m_recordPosList = {}
  end
  if #self._posRecord == 0 then
    self._posRecord[1] = data
  elseif #self._posRecord == 1 then
    self._posRecord[2] = data
  else
    self._posRecord[1] = self._posRecord[2]
    self._posRecord[2] = data
  end
end
function XTHDArrow:createWithParams(params)
  local bullet = XTHDArrow.new(params)
  return bullet
end
