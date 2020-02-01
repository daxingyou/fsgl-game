WorldBuff = class("WorldBuff", function(params)
  local buffSpine
  if params._type == 1 then
    buffSpine = "dw"
  elseif params._type == 2 then
    buffSpine = "sd2"
  elseif params._type == 3 then
    buffSpine = "dici"
  end
  print("resourceId=" .. tostring(params.resourceId))
  local skeletonNode = sp.SkeletonAnimation:create("res/spine/effect/dw/" .. buffSpine .. ".json", "res/spine/effect/dw/" .. buffSpine .. ".atlas", 1)
  skeletonNode:setScale(screenRadio)
  return XTHDTouchExtend.extend(skeletonNode)
end)
function WorldBuff:ctor(params)
  self._buffBack = params.backLayer or cc.Director:getInstance():getRunningScene()
  self._buffBack = params.backLayer or cc.Director:getInstance():getRunningScene()
  self._buffTargetType = params.targetType or 1
  self._buffHurt = params.damage or {30, 50}
  self._buffDuration = params.duration or 1.5
  self._buffTime = params.time or 180
  self._countDt = 0
  self._isStart = false
  self:registerSpineEventHandler(function(event)
    self:doAnimationEvent(event)
  end, sp.EventType.ANIMATION_EVENT)
  self:registerSpineEventHandler(function(event)
    self:doAnimationComplete(event)
  end, sp.EventType.ANIMATION_COMPLETE)
  self:setVisible(false)
end
function WorldBuff:startUse()
  self._isStart = true
  self:setVisible(true)
  local function _setOver(...)
    self:setOver()
  end
  performWithDelay(self, _setOver, self._buffTime)
  self:doStart()
end
function WorldBuff:_isWorldBuff(...)
end
function WorldBuff:pauseSelf()
  self._paused = true
  local function _func_(node)
    node:pause()
    for k, node in pairs(node:getChildren()) do
      _func_(node)
    end
  end
  _func_(self)
end
function WorldBuff:resumeSelf()
  self._paused = false
  local function _func_(node)
    node:resume()
    for k, node in pairs(node:getChildren()) do
      _func_(node)
    end
  end
  _func_(self)
end
function WorldBuff:setOver(...)
  if self.isOver then
    return
  end
  self.isOver = true
  local actionFadeout = cc.FadeOut:create(0.3)
  local function func_hide()
    self:setVisible(false)
    self:stopAllActions()
  end
  local actionCallfunc = cc.CallFunc:create(func_hide)
  self:runAction(cc.Sequence:create(actionFadeout, actionCallfunc))
  self:doOver()
end
function WorldBuff:doHurt(targets)
  if not targets then
    return
  end
  XTHD.dispatchEvent({name = EVENT_NAME_SHAKE_SCREEN})
  for k, target in pairs(targets) do
    local hp = math.random(self._buffHurt[1], self._buffHurt[2])
    target:runActionTip({
      blood = -hp,
      crit = false,
      attacker = target,
      _type = XTHD.action.type.fashugongji
    })
    if target:getType() == ANIMAL_TYPE.PLAYER then
      XTHD.dispatchEvent({name = EVENT_NAME_SHAKE_SCREEN})
    end
    target:runAction(cc.Sequence:create(cc.TintTo:create(0.05, 255, 0, 0), cc.TintTo:create(0, 255, 255, 255)))
    if target:getFaceDirection() == BATTLE_DIRECTION.LEFT then
      target:runAction(cc.Sequence:create(cc.MoveBy:create(0.05, cc.p(1, 0)), cc.MoveBy:create(0.05, cc.p(-2, 0)), cc.MoveBy:create(0.05, cc.p(1, 0))))
    else
      target:runAction(cc.Sequence:create(cc.MoveBy:create(0.05, cc.p(-1, 0)), cc.MoveBy:create(0.05, cc.p(2, 0)), cc.MoveBy:create(0.05, cc.p(-1, 0))))
    end
    local extraHp = target:getHpExtra()
    if 0 >= target:getHpNow() then
      target:setMp(0)
      if target:getSide() == BATTLE_SIDE.LEFT then
        XTHD.dispatchEvent({
          name = EVENT_NAME_BATTLE_CLEAR_MP(target:getHeroId()),
          data = {
            heroid = target:getHeroId(),
            standId = target:getStandId()
          }
        })
      end
    end
    local effectSprite = XTHD.createSprite("res/image/tmpbattle/effect/hiteffect004/1.png")
    target:addNodeForSlot({
      node = effectSprite,
      slotName = "midPoint",
      zorder = 10
    })
    local max_effectframe = 3
    local effectspeed = 20
    effectSprite:setScale(1 / target:getScaleY())
    if 0 > target:getScaleX() then
      effectSprite:setScaleX(-1 * effectSprite:getScaleX())
    end
    local effect_animation = getAnimation("res/image/tmpbattle/effect/hiteffect004/", 1, max_effectframe, tonumber(effectspeed) / 1000)
    effectSprite:runAction(cc.Sequence:create(effect_animation, cc.RemoveSelf:create(true)))
  end
end
function WorldBuff:isOver()
  return self.isOver
end
function WorldBuff:getBackLay()
  return self._buffBack
end
function WorldBuff:getBuffTargetType()
  return self._buffTargetType
end
function WorldBuff:getBuffHurt()
  return self._buffHurt
end
function WorldBuff:getBuffDuration()
  return self._buffDuration
end
function WorldBuff:doStart()
end
function WorldBuff:doOver()
end
function WorldBuff:doAnimationEvent(event)
end
function WorldBuff:doAnimationComplete(event)
end
function WorldBuff:getEffectSpineFromCache(prefix)
  local json_file = prefix .. ".json"
  local atlas_file = prefix .. ".atlas"
  local scale_value = 1
  return sp.SkeletonAnimation:create(json_file, atlas_file, scale_value)
end
function WorldBuff:_create(params)
  return WorldBuff.new(params)
end
function WorldBuff:createWithParams(params)
  local _typeId = params._type
  local target = XTHD.battle.getWorldBuffByTypeId(_typeId)
  if not target then
    return nil
  end
  return requires(target):create(params)
end
