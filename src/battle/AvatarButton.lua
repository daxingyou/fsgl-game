AvatarButton = class("AvatarButton", function(params)
  return XTHDSprite.create()
end)
function AvatarButton:ctor(params)
  local animal = params.animal
  local heroid = animal:getHeroId()
  local quality = animal:getQuality()
  local rank = tonumber(animal:getHeroData().rank) or 2
  local star = animal:getStar()
  if star == nil or tonumber(star) < 1 then
    star = 1
  end
  local avatar_bg = HeroNode:createWithParams({
    heroid = heroid,
    star = star,
    level = -1,
    advance = rank,
    clickable = false
  })
  self:setContentSize(avatar_bg:getContentSize())
  local width = self:getContentSize().width
  local height = self:getContentSize().height
  local _bg = XTHD.createSprite("res/image/tmpbattle/avatar_bg.png")
  _bg:setPosition(cc.p(width * 0.5, height * 0.5 + 9))
  _bg:setVisible(false)
  self:addChild(_bg)
  avatar_bg:setPosition(cc.p(width * 0.5, height * 0.5 + 9))
  self:addChild(avatar_bg)
  self._avatar_bg = avatar_bg
  local _data = {
    file = "res/image/tmpbattle/effect/buff/dzsf",
    name = "b",
    startIndex = 1,
    endIndex = 12,
    perUnit = 0.06666666666666667
  }
  local super_bg = XTHD.createSpriteFrameSp(_data)
  super_bg:setPosition(avatar_bg:getPositionX(), avatar_bg:getPositionY())
  super_bg:setVisible(false)
  self:addChild(super_bg)
  self._heroid = heroid
  local hp_bg = cc.Sprite:create("res/image/tmpbattle/hp_bg.png")
  hp_bg:setPosition(cc.p(width * 0.5, 0))
  self:addChild(hp_bg)
  local _sPercent = animal:getHpNow() * 100 / animal:getHpTotal()
  local hp_secondary = cc.ProgressTimer:create(cc.Sprite:create("res/image/tmpbattle/hp_yellow.png"))
  hp_secondary:setPosition(cc.p(hp_bg:getContentSize().width * 0.5, hp_bg:getContentSize().height * 0.5))
  hp_secondary:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  hp_secondary:setMidpoint(cc.p(0, 0.5))
  hp_secondary:setPercentage(_sPercent)
  hp_secondary:setBarChangeRate(cc.p(1, 0))
  hp_bg:addChild(hp_secondary)
  local hp_progress = cc.ProgressTimer:create(cc.Sprite:create("res/image/tmpbattle/hp_green.png"))
  hp_progress:setPosition(hp_secondary:getPosition())
  hp_progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  hp_progress:setMidpoint(cc.p(0, 0.5))
  hp_progress:setPercentage(_sPercent)
  hp_progress:setBarChangeRate(cc.p(1, 0))
  hp_bg:addChild(hp_progress)
  local mp_bg = cc.Sprite:create("res/image/tmpbattle/hp_bg.png")
  mp_bg:setPosition(cc.p(width * 0.5, hp_bg:getPositionY() - 12))
  self:addChild(mp_bg)
  local mp_secondary = cc.ProgressTimer:create(cc.Sprite:create("res/image/tmpbattle/hp_green.png"))
  mp_secondary:setPosition(cc.p(mp_bg:getContentSize().width * 0.5, mp_bg:getContentSize().height * 0.5))
  mp_secondary:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  mp_secondary:setMidpoint(cc.p(0, 0.5))
  mp_secondary:setPercentage(0)
  mp_secondary:setBarChangeRate(cc.p(1, 0))
  mp_bg:addChild(mp_secondary)
  local mp_progress = cc.ProgressTimer:create(cc.Sprite:create("res/image/tmpbattle/hp_yellow.png"))
  mp_progress:setPosition(mp_secondary:getPosition())
  mp_progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  mp_progress:setMidpoint(cc.p(0, 0.5))
  mp_progress:setPercentage(0)
  mp_progress:setBarChangeRate(cc.p(1, 0))
  mp_bg:addChild(mp_progress)
  mp_secondary:setVisible(false)
  self._hp_progress = hp_progress
  self._mp_progress = mp_progress
  self._hp_secondary = hp_secondary
  self._mp_secondary = mp_secondary
  self._hp_bg = hp_bg
  self._mp_bg = mp_bg
  self._super_bg = super_bg
  self._animal = animal
  self._disPos = cc.p(0, 0)
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(self._needSwallow)
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
  XTHD.addEventListenerWithNode({
    node = self,
    name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(heroid),
    callback = function(event)
      local data = event.data
      if data == nil then
        return
      end
      if data.standId and data.standId ~= self._animal:getStandId() then
        return
      end
      if data.hp then
        self:setPercentageHp(data.hp)
      end
      if data.mpadd then
        if data.mpadd > 0 and not self._animal:isAlive() then
          return
        end
        local lastPercentage = mp_secondary:getPercentage()
        local percentage = lastPercentage + 100 * data.mpadd / self._animal:getMpMax()
        mp_secondary:setPercentage(percentage)
        self:setPercentageMp(percentage)
      end
    end
  })
  XTHD.addEventListenerWithNode({
    node = self,
    name = EVENT_NAME_BATTLE_CLEAR_MP(heroid),
    callback = function(event)
      local data = event.data
      if data == nil then
        return
      end
      if data.standId and data.standId ~= self._animal:getStandId() then
        return
      end
      self:_clearMp()
    end
  })
  XTHD.addEventListenerWithNode({
    node = self,
    name = EVENT_NAME_BATTLE_AUTO_SUPER,
    callback = function(event)
      self:playSuper()
    end
  })
  XTHD.addEventListenerWithNode({
    node = self,
    name = EVENT_NAME_BATTLE_AVATAR_GRAY(heroid),
    callback = function(event)
      if data == nil then
        return
      end
      if data.standId and data.standId ~= self._animal:getStandId() then
        return
      end
      self:setColor(cc.c3b(80, 80, 80))
      doFuncForAllChild(self._avatar_bg, function(child)
        child:setColor(cc.c3b(80, 80, 80))
      end)
      self:_clearMp()
      self:stopAllActions()
    end
  })
  XTHD.addEventListener({
    name = EVENT_NAME_BATTLE_PAUSE,
    callback = function(event)
      self:pause()
    end
  })
  XTHD.addEventListener({
    name = EVENT_NAME_BATTLE_RESUME,
    callback = function(event)
      self:resume()
    end
  })
  self:setTouchEndedCallback(function()
    self:playSuper(true)
  end)
  self:setCascadeColorEnabled(true)
  self:setPercentageMp(animal:getMp() * 100 / animal:getMpMax())
  self:setPercentageHp(animal:getHpNow() * 100 / animal:getHpTotal())
  XTHD.addEventListenerWithNode({
    node = self,
    name = EVENT_NAME_BATTLE_AVATAR_BUTTON(heroid),
    callback = function(event)
      local data = event.data
      data.button = self
    end
  })
end
function AvatarButton:_clearMp()
  self._mp_progress:stopAllActions()
  self._mp_secondary:stopAllActions()
  self:setPercentageMp(100 * self._animal:getMp() / self._animal:getMpMax())
  self._super_bg:setVisible(false)
  self._super_bg:removeAllChildren()
end
function AvatarButton:playSuper(_isManual)
  if self._super_bg:isVisible() == true and self._animal:getMp() >= self._animal:getMpMax() then
    local _data = {
      heroid = self._heroid,
      side = BATTLE_SIDE.LEFT,
      standId = self._animal:getStandId()
    }
    XTHD.dispatchEvent({name = EVENT_NAME_PLAY_SUPER_ACT, data = _data})
    if _isManual and _data.isPlaySuper then
      self:showMpFullEff(self._super_bg)
    end
  end
end
function AvatarButton:onCleanup()
  print("AvatarButton:onCleanup")
  XTHD.removeEventListener(EVENT_NAME_REFRESH_HERO_PERCENTAGE(self._heroid))
  XTHD.removeEventListener(EVENT_NAME_BATTLE_CLEAR_MP(self._heroid))
  XTHD.removeEventListener(EVENT_NAME_BATTLE_AUTO_SUPER)
  XTHD.removeEventListener(EVENT_NAME_BATTLE_AVATAR_GRAY(self._heroid))
  XTHD.removeEventListener(EVENT_NAME_BATTLE_PAUSE)
  XTHD.removeEventListener(EVENT_NAME_BATTLE_RESUME)
end
function AvatarButton:setPercentageHp(percent)
  local lastPercentage = self._hp_progress:getPercentage()
  local percentage = percent
  local action = cc.ProgressFromTo:create(0.1, lastPercentage, percentage)
  local action1 = cc.ProgressFromTo:create(0.5, lastPercentage, percentage)
  self._hp_progress:runAction(action)
  self._hp_secondary:runAction(action1)
  if percentage <= 0 then
    self._mp_progress:stopAllActions()
    self._mp_secondary:stopAllActions()
    self._mp_progress:setPercentage(0)
    self._mp_secondary:setPercentage(0)
    self:stopAllActions()
    self:setColor(cc.c3b(80, 80, 80))
    doFuncForAllChild(self._avatar_bg, function(child)
      child:setColor(cc.c3b(80, 80, 80))
    end)
    self:_clearMp()
    self._super_bg:removeAllChildren()
    self._super_bg:setVisible(false)
  end
end
function AvatarButton:showMpFullEff(_bg)
  local _data = {
    file = "res/image/tmpbattle/effect/buff/dzsf",
    name = "a",
    startIndex = 1,
    endIndex = 12,
    perUnit = 0.06666666666666667,
    isCircle = false
  }
  local _boomMpEffect_bottom = XTHD.createSpriteFrameSp(_data)
  _boomMpEffect_bottom:setName("_boomMpEffect_bottom")
  _boomMpEffect_bottom:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
  _boomMpEffect_bottom:setPosition(_bg:getPositionX(), _bg:getPositionY())
  self:addChild(_boomMpEffect_bottom)
end
function AvatarButton:setPercentageMp(percent)
  local lastPercentage = self._mp_progress:getPercentage()
  local percentage = percent
  local action = cc.ProgressFromTo:create(0.1, lastPercentage, percentage)
  local action1 = cc.ProgressFromTo:create(0.1, lastPercentage, percentage)
  self._mp_progress:runAction(action)
  self._mp_secondary:runAction(cc.Sequence:create(action1, cc.CallFunc:create(function()
    if percentage >= 100 and self._super_bg:isVisible() == false then
      self._super_bg:setVisible(true)
      self:showMpFullEff(self._super_bg)
      local musicFile = "res/sound/sound_effect_anger_full.mp3"
      musicManager.playEffect(musicFile, false)
      local _data = {}
      XTHD.dispatchEvent({name = EVENT_NAME_BATTLE_GETGUIDESTATE, data = _data})
      if _data.guideState == -1 and gameUser.getLevel() <= 20 then
        if self._guidHand then
          self._guidHand:setVisible(true)
        else
          self._guidHand = sp.SkeletonAnimation:create("res/spine/guide/yd.json", "res/spine/guide/yd.atlas", 1)
          self._guidHand:setAnimation(0, "animation", true)
          self._guidHand:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height * 0.5)
          self:addChild(self._guidHand, 10)
        end
      end
    elseif percentage <= 0 then
      self._mp_progress:stopAllActions()
      self._mp_secondary:stopAllActions()
      self._mp_progress:setPercentage(0)
      self._mp_secondary:setPercentage(0)
      self._super_bg:setVisible(false)
      self._super_bg:removeAllChildren()
      if self._guidHand then
        self._guidHand:setVisible(false)
      end
    elseif percentage < 100 then
      self._super_bg:setVisible(false)
      if self._guidHand then
        self._guidHand:setVisible(false)
      end
    end
  end)))
end
function AvatarButton:isAvatarButton()
end
function AvatarButton:start()
  if self._mpAction then
    self:stopAction(_mpAction)
  end
  self._mpAction = schedule(self, function()
    if self._animal and self._animal:isAlive() == true then
      self._animal:setMp(self._animal:getMp() + BATTLE_MP.AUTO)
    end
    local percentage = 100 * self._animal:getMp() / self._animal:getMpMax()
    self:setPercentageMp(percentage)
  end, 5, 1)
end
function AvatarButton:createWithParams(params)
  local label = AvatarButton.new(params)
  return label
end
