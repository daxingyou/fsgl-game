CharacterData = class("CharacterData", function()
  return cc.Node:create()
end)
function CharacterData:ctor(sData)
  self._heroData = clone(sData)
  self._saveData = {}
  local mingzhong = false
  local baoji = false
  local data = {}
  math.newrandomseed()
  self._randNum = math.random(0, 100)
  self._extraData = {
    physicalattack = 0,
    physicaldefence = 0,
    manaattack = 0,
    manadefence = 0,
    hit = 0,
    dodge = 0,
    crit = 0,
    crittimes = 0,
    anticrit = 0,
    attackbreak = 0,
    antiattack = 0,
    physicalattackbreak = 0,
    antiphysicalattack = 0,
    manaattackbreak = 0,
    antimanaattack = 0,
    suckblood = 0,
    heal = 0,
    behealed = 0,
    antiangercost = 0
  }
  for k, v in pairs(self._extraData) do
    self._extraData[k] = self:d2b(v)
    self._heroData[k] = self._heroData[k] or 0
    local pStr = tostring(self._heroData[k])
    self._saveData[k] = iBaseCrypto:encodeBase64Lua(pStr, string.len(pStr))
    self._heroData[k] = self:d2b(self._heroData[k])
  end
  self._restoredHeroData = clone(self._heroData)
end
function CharacterData:create(sData)
  return CharacterData.new(sData)
end
function CharacterData:d2b(arg)
  return arg + self._randNum
end
function CharacterData:b2d(arg)
  return arg - self._randNum
end
function CharacterData:getData(...)
  return self._heroData
end
function CharacterData:getRestoredData(...)
  return self._restoredHeroData
end
function CharacterData:resetData(...)
  self._heroData = clone(self._restoredHeroData)
  for k, v in pairs(self._extraData) do
    self._extraData[k] = self:d2b(0)
  end
end
function CharacterData:compareData(_data1, _data2)
  local _num1 = tonumber(_data1) or 0
  local _num2 = tonumber(_data2) or 0
  return math.abs(_num1 - _num2)
end
function CharacterData:checkDataSafe()
  for k, v in pairs(self._extraData) do
    local _result = self:compareData(self:b2d(self._heroData[k]), iBaseCrypto:decodeBase64Lua(self._saveData[k]))
    if _result > 1 then
      local _tb = clone(self._heroData)
      local _tb2 = clone(self._saveData)
      for key, value in pairs(self._extraData) do
        _tb[key] = self:b2d(_tb[key])
        _tb2[key] = iBaseCrypto:decodeBase64Lua(_tb2[key])
      end
      local _params = {
        _type = "waveCheck",
        heroData = _tb,
        baseData = _tb2
      }
      LayerManager.sendZuobi(_params)
      return true
    end
  end
  return true
end
function CharacterData:setAttributesByBuff(params)
  local buffeffect = params.buffeffect
  local extra = params.extra
  if buffeffect == 3 then
    local _value = self:b2d(self._extraData.physicalattack)
    _value = _value + extra
    self._extraData.physicalattack = self:d2b(_value)
  elseif buffeffect == 4 then
    local _value = self:b2d(self._extraData.physicaldefence)
    _value = _value + extra
    self._extraData.physicaldefence = self:d2b(_value)
  elseif buffeffect == 5 then
    local _value = self:b2d(self._extraData.manaattack)
    _value = _value + extra
    self._extraData.manaattack = self:d2b(_value)
  elseif buffeffect == 6 then
    local _value = self:b2d(self._extraData.manadefence)
    _value = _value + extra
    self._extraData.manadefence = self:d2b(_value)
  elseif buffeffect == 7 then
    local _value = self:b2d(self._extraData.hit)
    _value = _value + extra
    self._extraData.hit = self:d2b(_value)
  elseif buffeffect == 8 then
    local _value = self:b2d(self._extraData.dodge)
    _value = _value + extra
    self._extraData.dodge = self:d2b(_value)
  elseif buffeffect == 9 then
    local _value = self:b2d(self._extraData.crit)
    _value = _value + extra
    self._extraData.crit = self:d2b(_value)
  elseif buffeffect == 10 then
    local _value = self:b2d(self._extraData.crittimes)
    _value = _value + extra
    self._extraData.crittimes = self:d2b(_value)
  elseif buffeffect == 11 then
    local _value = self:b2d(self._extraData.anticrit)
    _value = _value + extra
    self._extraData.anticrit = self:d2b(_value)
  elseif buffeffect == 12 then
    local _value = self:b2d(self._extraData.attackbreak)
    _value = _value + extra
    self._extraData.attackbreak = self:d2b(_value)
  elseif buffeffect == 13 then
    local _value = self:b2d(self._extraData.antiattack)
    _value = _value + extra
    self._extraData.antiattack = self:d2b(_value)
  elseif buffeffect == 14 then
    local _value = self:b2d(self._extraData.physicalattackbreak)
    _value = _value + extra
    self._extraData.physicalattackbreak = self:d2b(_value)
  elseif buffeffect == 15 then
    local _value = self:b2d(self._extraData.antiphysicalattack)
    _value = _value + extra
    self._extraData.antiphysicalattack = self:d2b(_value)
  elseif buffeffect == 16 then
    local _value = self:b2d(self._extraData.manaattackbreak)
    _value = _value + extra
    self._extraData.manaattackbreak = self:d2b(_value)
  elseif buffeffect == 17 then
    local _value = self:b2d(self._extraData.antimanaattack)
    _value = _value + extra
    self._extraData.antimanaattack = self:d2b(_value)
  elseif buffeffect == 18 then
    local _value = self:b2d(self._extraData.suckblood)
    _value = _value + extra
    self._extraData.suckblood = self:d2b(_value)
  elseif buffeffect == 19 then
    local _value = self:b2d(self._extraData.heal)
    _value = _value + extra
    self._extraData.heal = self:d2b(_value)
  elseif buffeffect == 20 then
    local _value = self:b2d(self._extraData.behealed)
    _value = _value + extra
    self._extraData.behealed = self:d2b(_value)
  elseif buffeffect == 21 then
    local _value = self:b2d(self._extraData.antiangercost)
    _value = _value + extra
    self._extraData.antiangercost = self:d2b(_value)
  end
end
function CharacterData:getAttackWuLiOrigin()
  local _value = self:b2d(self._restoredHeroData.physicalattack)
  return _value
end
function CharacterData:getAttackMoFaOrigin()
  local _value = self:b2d(self._restoredHeroData.manaattack)
  return _value
end
function CharacterData:getDefenseWuLiOrigin()
  local _value = self:b2d(self._restoredHeroData.physicaldefence)
  return _value
end
function CharacterData:getDefenseMoFaOrigin()
  local _value = self:b2d(self._restoredHeroData.manadefence)
  return _value
end
function CharacterData:getAttackWuLiNow()
  local _value = self:b2d(self._heroData.physicalattack)
  local _value2 = self:b2d(self._extraData.physicalattack)
  return _value + _value2
end
function CharacterData:getAttackMoFaNow()
  local _value = self:b2d(self._heroData.manaattack)
  local _value2 = self:b2d(self._extraData.manaattack)
  return _value + _value2
end
function CharacterData:getDefenseWuLiNow()
  local _value = self:b2d(self._heroData.physicaldefence)
  local _value2 = self:b2d(self._extraData.physicaldefence)
  return _value + _value2
end
function CharacterData:getDefenseMoFaNow()
  local _value = self:b2d(self._heroData.manadefence)
  local _value2 = self:b2d(self._extraData.manadefence)
  return _value + _value2
end
function CharacterData:getHitNow()
  local _value = self:b2d(self._heroData.hit)
  local _value2 = self:b2d(self._extraData.hit)
  return _value + _value2
end
function CharacterData:getDodgeNow()
  local _value = self:b2d(self._heroData.dodge)
  local _value2 = self:b2d(self._extraData.dodge)
  return _value + _value2
end
function CharacterData:getCritNow()
  local _value = self:b2d(self._heroData.crit)
  local _value2 = self:b2d(self._extraData.crit)
  return _value + _value2
end
function CharacterData:getCrittimesNow()
  local _value = self:b2d(self._heroData.crittimes)
  local _value2 = self:b2d(self._extraData.crittimes)
  return _value + _value2
end
function CharacterData:getAnticritNow()
  local _value = self:b2d(self._heroData.anticrit)
  local _value2 = self:b2d(self._extraData.anticrit)
  return _value + _value2
end
function CharacterData:getAttackbreakNow()
  local _value = self:b2d(self._heroData.attackbreak)
  local _value2 = self:b2d(self._extraData.attackbreak)
  return _value + _value2
end
function CharacterData:getAntiattackNow()
  local _value = self:b2d(self._heroData.antiattack)
  local _value2 = self:b2d(self._extraData.antiattack)
  return _value + _value2
end
function CharacterData:getPhysicalattackbreakNow()
  local _value = self:b2d(self._heroData.physicalattackbreak)
  local _value2 = self:b2d(self._extraData.physicalattackbreak)
  return _value + _value2
end
function CharacterData:getAntiphysicalattackNow()
  local _value = self:b2d(self._heroData.antiphysicalattack)
  local _value2 = self:b2d(self._extraData.antiphysicalattack)
  return _value + _value2
end
function CharacterData:getManaattackbreakNow()
  local _value = self:b2d(self._heroData.manaattackbreak)
  local _value2 = self:b2d(self._extraData.manaattackbreak)
  return _value + _value2
end
function CharacterData:getSuckbloodNow()
  local _value = self:b2d(self._heroData.suckblood)
  local _value2 = self:b2d(self._extraData.suckblood)
  return _value + _value2
end
function CharacterData:getHealNow()
  local _value = self:b2d(self._heroData.heal)
  local _value2 = self:b2d(self._extraData.heal)
  return _value + _value2
end
function CharacterData:getBehealedNow()
  local _value = self:b2d(self._heroData.behealed)
  local _value2 = self:b2d(self._extraData.behealed)
  return _value + _value2
end
function CharacterData:getAntiangercostNow()
  local _value = self:b2d(self._heroData.antiangercost)
  local _value2 = self:b2d(self._extraData.antiangercost)
  return _value + _value2
end
function CharacterData:getAntimanaattackNow()
  local _value = self:b2d(self._heroData.antimanaattack)
  local _value2 = self:b2d(self._extraData.antimanaattack)
  return _value + _value2
end
return CharacterData
