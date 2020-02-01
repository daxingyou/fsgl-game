BattleBackground = class("BattleBackground", function()
  return cc.NodeGrid:create()
end)
function BattleBackground:ctor(sParams)
  self._bgWidth = cc.Director:getInstance():getWinSize().width
  self._bgHeight = cc.Director:getInstance():getWinSize().height
  self:setPosition(self._bgWidth * 0.5, self._bgHeight * 0.5)
  local _infos = sParams or {}
  self._type = _infos._type or BATTLE_GUIDEBG_TYPE.TYPE_NORMAL
  self._effPar = _infos.effPar
  self._curStep = 0
  self._isGuide = _infos.isGuide == nil and -1 or _infos.isGuide
  self._bgList = _infos.bgList
  self._worldBuff = _infos.worldBuff
  self._worldBuffDamage = _infos.worldBuffDamage
  self._worldEffLayer = _infos.worldEffLayer
  self._moveNode = cc.Node:create()
  self:addChild(self._moveNode)
end
function BattleBackground:getBgType()
  return self._type
end
function BattleBackground:isGuide()
  return self._isGuide
end
function BattleBackground:setMoveNodeState(isShow)
  self._moveNode:setVisible(isShow)
end
function BattleBackground:changeToNext(sParams)
  local _infos = sParams or {}
  self._curStep = self._curStep + 1
  self:doCurStep(_infos)
end
function BattleBackground:doCurStep(sParams)
end
function BattleBackground:_doEndCall(endCall, params)
  if endCall and type(endCall) == "function" then
    endCall(params)
  end
end
function BattleBackground:_checkBgEffect(_fileName)
  self._worldEffLayer:removeAllChildren()
  if self._bgEffNode then
    self._bgEffNode:removeFromParent()
    self._bgEffNode = nil
  end
  self._worldBuffEff = nil
  self._bgEffNode = cc.Node:create()
  self._moveNode:addChild(self._bgEffNode)
  _fileName = _fileName or ""
  if string.find(_fileName, "bg_53") then
    do
      local __sp = sp.SkeletonAnimation:create("res/spine/effect/bossBackEff/haidi.json", "res/spine/effect/bossBackEff/haidi.atlas", 1)
      self._bgEffNode:addChild(__sp)
      __sp:setAnimation(0, "animation", true)
      local function _createOne(...)
        cc.SpriteFrameCache:getInstance():addSpriteFrames("res/spine/effect/bossBackEff/paopao.plist", "res/spine/effect/bossBackEff/paopao.png")
        local sp = cc.Sprite:create()
        sp:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
        sp:setAnchorPoint(0.5, 0)
        sp:setScale(2.3)
        local perTime = 0.09
        local action = getAnimationBySpriteFrame("paopao_", 1, 21, perTime)
        sp:runAction(action)
        performWithDelay(sp, function(...)
          sp:removeFromParent()
        end, 21 * perTime)
        local pX = math.random(50, self._bgWidth - 50)
        sp:setPosition(pX - self._bgWidth * 0.5, 30)
        self._worldEffLayer:addChild(sp)
      end
      local function _runAction(...)
        local pTime = math.random(200, 500) / 100
        performWithDelay(self._worldEffLayer, _runAction, pTime)
        _createOne()
      end
      _runAction()
    end
  end
  local nowWave = self._curStep
  local _worldBuffId = tonumber(self._worldBuff[nowWave]) or 0
  if _worldBuffId ~= 0 then
    local buffEff = WorldBuff:createWithParams({
      _type = _worldBuffId,
      damage = self._worldBuffDamage
    })
    if buffEff then
      self._bgEffNode:addChild(buffEff)
      buffEff:startUse()
      self._worldBuffEff = buffEff
    end
  end
end
function BattleBackground:cleanWorldEffect()
  self._worldEffLayer:removeAllChildren()
  if self._bgEffNode then
    self._bgEffNode:removeFromParent()
    self._bgEffNode = nil
  end
end
function BattleBackground:pauseAll()
  doFuncForAllChild(self, function(_node)
    if _node.pauseSelf then
      _node:pauseSelf()
    else
      _node:pause()
    end
  end)
  if self._worldEffLayer then
    doFuncForAllChild(self._worldEffLayer, function(_node)
      _node:pause()
    end)
  end
end
function BattleBackground:resumeAll()
  doFuncForAllChild(self, function(_node)
    if _node.resumeSelf then
      _node:resumeSelf()
    else
      _node:resume()
    end
  end)
  if self._worldEffLayer then
    doFuncForAllChild(self._worldEffLayer, function(_node)
      _node:resume()
    end)
  end
end
function BattleBackground:setAllColor(_color)
  doFuncForAllChild(self, function(_node)
    _node:setColor(_color)
  end)
end
function BattleBackground:_create(params)
  return BattleBackground.new(params)
end
function BattleBackground:createWithParams(params)
  local _typeId = params._type
  local target = XTHD.battle.getBattleBgByTypeId(_typeId)
  if not target then
    return nil
  end
  return requires(target):create(params)
end
return BattleBackground
