ChainNode = class("ChainNode", function()
  return XTHD.createLayer()
end)
function ChainNode:createOne(atkeffect)
  local obj = ChainNode.new()
  obj:init(atkeffect)
  return obj
end
function ChainNode:ctor()
  self._parTime = 0.02
end
function ChainNode:init(atkeffect)
  self:scheduleUpdateWithPriorityLua(function(dt)
    self:updatePoint(dt)
  end, 0)
  self._spTb = {}
  local pLay = atkeffect or cc.Sprite:create("res/spine/effect/034/tielian.png")
  if not atkeffect then
    pLay:setAnchorPoint(0, 0.5)
  end
  self._atkEffect = atkeffect
  pLay:setVisible(false)
  self:addChild(pLay, 1)
  table.insert(self._spTb, pLay)
  for i = 2, 100 do
    pLay = cc.Sprite:create("res/spine/effect/034/tielian.png")
    pLay:setVisible(false)
    pLay:setAnchorPoint(0, 0.5)
    self:addChild(pLay)
    table.insert(self._spTb, pLay)
  end
  self._partX = self._spTb[2]:getContentSize().width * 0.8
end
function ChainNode:setBeganPoint(sPoint)
  self:setEndedPoint()
  self._beganPoint = sPoint
end
function ChainNode:setMovedPoint(sPoint)
  self._movedPoint = sPoint
end
function ChainNode:setEndedPoint(...)
  self:stopAllActions()
  self._beganPoint = nil
  self._movedPoint = nil
  self._lastMovePoint = nil
  for k, v in pairs(self._spTb) do
    v:setVisible(false)
  end
end
function ChainNode:getRotate(moveX, moveY)
  local at
  local o = moveX
  local a = moveY
  local at
  if a == 0 then
    if o < 0 then
      at = -90
    else
      at = 90
    end
  else
    at = math.atan(o / a) / math.pi * 180
  end
  if a < 0 then
    if o < 0 then
      at = 180 + math.abs(at)
    else
      at = 180 - math.abs(at)
    end
  end
  return at
end
function ChainNode:getRotateByPoint(sBegan, sEnded)
  local pos = cc.pSub(sEnded, sBegan)
  return self:getRotate(pos.x, pos.y)
end
function ChainNode:updatePoint(dt)
  if not self._beganPoint then
    return
  end
  if not self._movedPoint then
    return
  end
  if not self._lastMovePoint then
    self._lastMovePoint = self._beganPoint
  else
  end
  self._lastMovePoint = self._movedPoint
  local pStart = self._beganPoint
  local pEnd = self._movedPoint
  local distance = cc.pGetDistance(pStart, pEnd)
  local angle = self:getRotateByPoint(pStart, pEnd) - 90
  local partX = self._partX
  if distance > 1 then
    local d, f = math.modf(distance / partX)
    if d == 0 and f ~= 0 then
      d = d + 1
    end
    if d >= 1 then
      local pLay = self._spTb[1]
      local difx = pEnd.x - pStart.x
      local dify = pEnd.y - pStart.y
      local delta = d / distance * partX
      pLay:setRotation(angle)
      local pos = cc.p(pStart.x + difx * delta, pStart.y + dify * delta)
      pLay:setPosition(pos)
      pLay:setVisible(true)
      pLay:visit()
      for i = 2, #self._spTb do
        local pLay = self._spTb[i]
        if d >= i - 1 then
          local difx = pEnd.x - pStart.x
          local dify = pEnd.y - pStart.y
          local delta = (i - 2) / distance * partX
          pLay:setRotation(angle)
          local pos = cc.p(pStart.x + difx * delta, pStart.y + dify * delta)
          pLay:setPosition(pos)
          pLay:setVisible(true)
          pLay:visit()
        else
          pLay:setVisible(false)
        end
      end
    else
      for i = 1, #self._spTb do
        local pLay = self._spTb[i]
        pLay:setVisible(false)
      end
    end
  else
    local pLay = self._spTb[1]
    pLay:setRotation(angle)
    local pos = cc.p(pStart.x, pStart.y)
    pLay:setPosition(pos)
    pLay:setVisible(true)
    pLay:visit()
  end
end
function ChainNode:selfUpdateMovePoint(sBegan, sEnded, sTime, callFn, isNotFinal)
  local mPart = self._parTime
  local pTimes = sTime / mPart
  local dis1 = cc.pGetDistance(sBegan, sEnded)
  local partPos = cc.pMul(cc.pSub(sEnded, sBegan), 1 / pTimes)
  local pCount = 0
  local pos = cc.p(sBegan.x, sBegan.y)
  self._chainAction = schedule(self, function(...)
    pCount = pCount + 1
    if pCount > pTimes then
      self:stopAction(self._chainAction)
      if callFn then
        callFn()
      end
      return
    end
    if isNotFinal and pCount == pTimes - 1 then
    else
      pos = cc.pAdd(pos, partPos)
    end
    self:setMovedPoint(pos)
  end, mPart)
end
function ChainNode:getFlyPoint(sBegan, sEnded)
  local pY = 70
  local tarPos = cc.p(0, sBegan.y + pY)
  if sBegan.x ~= sEnded.x then
    local dis = cc.pGetDistance(sBegan, sEnded)
    local pX = dis * 0.35
    if sBegan.x > sEnded.x then
      pX = 0 - pX
    end
    tarPos.x = pX + sBegan.x
  end
  return tarPos
end
function ChainNode:runChainAction(sBegan, sEnded, sFinal, sTime1, sTime2, sTime3, endCall1, endCall2, endCall3)
  self:stopAllActions()
  self:setEndedPoint()
  self:setBeganPoint(sBegan)
  local time1 = sTime1 or 1
  local time2 = sTime2 or 1
  local time3 = sTime3 or 1
  local _wait = self._waitTime or 0.1
  self:selfUpdateMovePoint(sBegan, sEnded, time1, function(...)
    local _isBreak = false
    if endCall1 then
      _isBreak = endCall1()
    end
    if not _isBreak then
      performWithDelay(self, function(...)
        local tarPos = self:getFlyPoint(sFinal, sEnded)
        self:selfUpdateMovePoint(sEnded, tarPos, time2, function(...)
          if endCall2 then
            endCall2()
          end
          self:selfUpdateMovePoint(tarPos, sFinal, time3, function(...)
            self:stopAllActions()
            self:setEndedPoint()
            if endCall3 then
              endCall3()
            end
          end, true)
        end)
      end, _wait)
    end
  end)
end
function ChainNode:catchOneNode(sParams)
  if not sParams.target then
    return
  end
  local sNode2 = sParams.target
  local midPoint = sNode2:getSlotPositionInWorld("midPoint")
  local pDir = sNode2:getFaceDirection() == BATTLE_DIRECTION.RIGHT and 1 or -1
  local pX = 30
  local pos1 = sParams.beginPos
  local pos2 = cc.p(midPoint.x + pDir * pX, midPoint.y)
  local pos3 = sParams.endPos
  local _plus = cc.pSub(midPoint, cc.p(sNode2:getPosition()))
  self._waitTime = sParams.waitTime
  local firstCall = sParams.firstCall
  local pAction = schedule(sNode2, function(...)
    if not self.isCatched or not self._movedPoint then
      return
    end
    local pos = cc.Director:getInstance():getRunningScene():convertToNodeSpace(self._movedPoint)
    pos = cc.pSub(pos, _plus)
    pos.x = pos.x - pDir * pX
    sNode2:setPosition(pos)
  end, 0.01)
  self:runChainAction(pos1, pos2, pos3, 0.05, 0.1, 0.1, function(...)
    local pB = false
    if sParams.firstCall then
      local _posNow = sNode2:getSlotPositionInWorld("midPoint")
      local pNum = math.abs(_posNow.y - pos2.y)
      pB = sParams.firstCall(pNum)
    end
    if not pB then
      self.isCatched = true
      self.mLastPos = self._movedPoint
    end
    return pB
  end, function(...)
    if sParams.secCall then
      sParams.secCall()
    end
  end, function(...)
    self.isCatched = false
    sNode2:stopAction(pAction)
    local pos = cc.Director:getInstance():getRunningScene():convertToNodeSpace(pos3)
    sNode2:setPosition(cc.p(pos))
    if sParams.endCall then
      sParams.endCall()
    end
  end)
end
