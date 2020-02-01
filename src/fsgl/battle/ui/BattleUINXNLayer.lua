-- FileName: BattleUINXNLayer.lua
-- Author: wangming
-- Date: 2015-10-28
-- Purpose: 封装NVN的战斗UI类
--[[TODO List]]


BattleUINXNLayer = class("BattleUINXNLayer", function()
    return XTHD.createLayer()
end)

function BattleUINXNLayer:ctor(data, battle_type)
    self._data = data
    self._battle_type = battle_type
    local width = self:getContentSize().width
    local height = self:getContentSize().height

    local selfBar = cc.Sprite:create("res/image/tmpbattle/battle_headBack1.png")
    selfBar:setOpacity(0)
    selfBar:setAnchorPoint(0, 0)
    selfBar:setScale(0.8)
    local selfNode = cc.Node:create()
    selfNode:setAnchorPoint(0, 1)
    selfNode:setPosition(3, height - 10)
    selfNode:setContentSize(selfBar:getContentSize())
    self:addChild(selfNode)
    selfNode:addChild(selfBar)
    self:initSelfInfo(selfNode)

    local enemyBar = cc.Sprite:create("res/image/tmpbattle/battle_headBack2.png")
    enemyBar:setOpacity(0)
    enemyBar:setAnchorPoint(0, 0)
    enemyBar:setScaleX(-1)
    enemyBar:setPositionX(enemyBar:getContentSize().width)
    local enemyNode = cc.Node:create()
    enemyNode:setAnchorPoint(1, 1)
    enemyNode:setPosition(width - 3, height - 10)
    enemyNode:setContentSize(enemyBar:getContentSize())
    self:addChild(enemyNode)
    enemyNode:addChild(enemyBar)
    self:initEnemyInfo(enemyNode)


    local handle = function ( event )
        if event == "cleanup" then
            self:onCleanup()
        end
    end
    self:registerScriptHandler(handle)
end

function BattleUINXNLayer:initSelfInfo( sNode )
    local _size = sNode:getContentSize()
    local selfData = self._data.playerList
    local winInfo = self._data.winInfo
    local nowCount = self._data.nowCount


    local pName = ""
    if self._battle_type == BattleType.PVP_GUILDFIGHT then
        pName = self._data.fightData.aGuildName or ""
    elseif self._battle_type == BattleType.PVP_SHURA then
        pName = gameUser.getNickname()
    end
    local playerName = XTHDLabel:createWithSystemFont(pName, "Helvetica", 20)
    playerName:setColor(cc.c3b(206,110,240))
    playerName:setAnchorPoint(cc.p(0, 0))
    playerName:setPosition(cc.p(20 , 65))
    sNode:addChild(playerName)

    local pCampId = 1
    if self._battle_type == BattleType.PVP_GUILDFIGHT then
        pCampId = tonumber(self._data.fightData.aCampId) or 1
    elseif self._battle_type == BattleType.PVP_SHURA then
        pCampId = gameUser.getCampID()
    end
    local playerFaction = cc.Sprite:create("res/image/daily_task/arena/faction_" .. pCampId .. ".png")
	playerFaction:setScale(0.8)
    playerFaction:setAnchorPoint(0,0.5)
    playerFaction:setPosition(playerName:getPositionX()+playerName:getContentSize().width+10, playerName:getPositionY() + playerName:getContentSize().height*0.5+15)
    sNode:addChild(playerFaction)

    local pX = 35
    if self._battle_type == BattleType.PVP_GUILDFIGHT then
        local _count = #selfData
        local _nowId = self._data.fightData.aCharId
        for i = 1, _count do
            local pI = _count - i + 1
            local pData = selfData[pI]
            local hero = HaoYouPublic.getFriendIcon({templateId = pData.templateId, level = pData.level}, {notShowCamp = true})
            hero:setScale(0.65)
            hero:setPosition(pX + (i-1)*65+20, 30)
            sNode:addChild(hero)
            if _nowId ~= pData.charId then
                local m_tick = cc.Sprite:create("res/image/imgSelHero/campuse/img_markTick.png")
                m_tick:setAnchorPoint(cc.p(0.5, 0.5))
                m_tick:setPosition(cc.p(hero:getContentSize().width*0.5, hero:getContentSize().height*0.5))
                hero:addChild(m_tick)
                if pData.isLore == 1 then
                    local _tick = cc.Sprite:create("res/image/tmpbattle/wef_43.png")
                    if _tick then
                        _tick:setScale(1/0.65)
                        _tick:setAnchorPoint(1, 0)
                        _tick:setPosition(hero:getContentSize().width + 6, 1)
                        hero:addChild(_tick)
                    end
                else
                    local pNum = tonumber(pData.result) or -1
                    if pNum == 0 or pNum == 2 then
                        _tick = cc.Sprite:create("res/image/tmpbattle/battle_result"..pNum..".png")
                        if _tick then
                            _tick:setAnchorPoint(1, 0)
                            _tick:setPosition(hero:getContentSize().width + 3, 1)
                            hero:addChild(_tick)
                        end
                    end
                end
                 
            end
        end
    elseif self._battle_type == BattleType.PVP_SHURA then
        for i=1, 5 do
            local pI = 5 - i + 1
            local ppI 
            if pI == 1 then
                ppI = 1
            elseif pI == 2 or pI == 3 then
                ppI = 2
            else
                ppI = 3
            end
            local hero = HeroNode:createWithParams({
                heroid = selfData[pI]        
            })
            hero:setScale(0.65)
            hero:setPosition(pX + (i-1)*65, 30)
            sNode:addChild(hero)
            if ppI ~= nowCount then
                local m_tick = cc.Sprite:create("res/image/imgSelHero/campuse/img_markTick.png")
                m_tick:setAnchorPoint(cc.p(0.5, 0.5))
                m_tick:setPosition(cc.p(hero:getContentSize().width*0.5, hero:getContentSize().height*0.5))
                hero:addChild(m_tick)
                local pNum = tonumber(winInfo[ppI]) or -1
                if pNum >= 0 and pNum <= 2 then
                    local _tick = cc.Sprite:create("res/image/tmpbattle/battle_result"..pNum..".png")
                    if _tick then
                        _tick:setAnchorPoint(1, 0)
                        _tick:setPosition(hero:getContentSize().width, 3)
                        hero:addChild(_tick)
                    end
                end
            end
        end
    end

end

function BattleUINXNLayer:initEnemyInfo( sNode )
    local _size = sNode:getContentSize()
    local enemyData = self._data.enemyList
    local winInfo = self._data.winInfo
    local nowCount = self._data.nowCount

    -- local enemyAvatar = HaoYouPublic.getFriendIcon({templateId = enemyData.rivalData.templateId,level = enemyData.rivalData.level}, {notShowCamp = true})
    -- enemyAvatar:setAnchorPoint(1, 0.5)
    -- enemyAvatar:setPosition(_size.width - 10, _size.height*0.5)
    -- enemyAvatar:setScale(0.8)
    -- sNode:addChild(enemyAvatar)
    local pName = ""
    if self._battle_type == BattleType.PVP_GUILDFIGHT then
        pName = self._data.fightData.bGuildName or ""
    elseif self._battle_type == BattleType.PVP_SHURA then
        pName = enemyData.rivalData.name
    end
    local enemyName = XTHDLabel:createWithSystemFont(pName, "Helvetica", 20)
    enemyName:setColor(cc.c3b(206,110,240))
    enemyName:setAnchorPoint(cc.p(1, 0))
    enemyName:setPosition(cc.p(_size.width - 20 , 65))
    sNode:addChild(enemyName)

    local pCampId = 1
    if self._battle_type == BattleType.PVP_GUILDFIGHT then
        pCampId = tonumber(self._data.fightData.bCampId) or 1
    elseif self._battle_type == BattleType.PVP_SHURA then
        pCampId = enemyData.rivalData.campId
    end
    local enemyFaction = cc.Sprite:create("res/image/daily_task/arena/faction_" .. pCampId .. ".png")
	enemyFaction:setScale(0.8)
    enemyFaction:setAnchorPoint(1, 0.5)
    enemyFaction:setPosition(enemyName:getPositionX() - enemyName:getContentSize().width - 10, enemyName:getPositionY() + enemyName:getContentSize().height*0.5+15)
    sNode:addChild(enemyFaction)

    local pX = _size.width - 35
    local pData
    if self._battle_type == BattleType.PVP_GUILDFIGHT then
        local _count = #enemyData
        local _nowId = self._data.fightData.bCharId
        for i = 1, _count do
            local pI = _count - i + 1
            local pData = enemyData[pI]
            local hero = HaoYouPublic.getFriendIcon({templateId = pData.templateId,level = pData.level}, {notShowCamp = true})
            hero:setScale(0.65)
            hero:setPosition(pX - (i-1)*65-30, 30)
            sNode:addChild(hero)
            if _nowId ~= pData.charId then
                local m_tick = cc.Sprite:create("res/image/imgSelHero/campuse/img_markTick.png")
                m_tick:setAnchorPoint(cc.p(0.5, 0.5))
                m_tick:setPosition(cc.p(hero:getContentSize().width*0.5, hero:getContentSize().height*0.5))
                hero:addChild(m_tick)
                if pData.isLore == 1 then
                    local _tick = cc.Sprite:create("res/image/tmpbattle/wef_43.png")
                    if _tick then
                        _tick:setScale(1/0.65)
                        _tick:setAnchorPoint(1, 0)
                        _tick:setPosition(hero:getContentSize().width + 6, 1)
                        hero:addChild(_tick)
                    end
                else
                    local pNum = tonumber(pData.result) or -1
                    if pNum == 1 or pNum == 2 then
                        if pNum == 1 then
                            pNum = 0    
                        end
                        local _tick = cc.Sprite:create("res/image/tmpbattle/battle_result"..pNum..".png")
                        if _tick then
                            _tick:setAnchorPoint(1, 0)
                            _tick:setPosition(hero:getContentSize().width + 3, 1)
                            hero:addChild(_tick)
                        end
                    end
                end
                
            end
        end
    elseif self._battle_type == BattleType.PVP_SHURA then
        for i=1, 5 do
            local pI = 5 - i + 1
            local ppI 
            if pI == 1 then
                ppI = 1
            elseif pI == 2 or pI == 3 then
                ppI = 2
            else
                ppI = 3
            end
            pData = enemyData[pI]
            local hero = HeroNode:createWithParams({
                heroid = pData.heroID,
                advance = pData.advance,
                star = pData.star,
                level = pData.level
            })
            hero:setScale(0.65)
            hero:setPosition(pX - (i-1)*65, 30)
            sNode:addChild(hero)
            if ppI ~= nowCount then
                local m_tick = cc.Sprite:create("res/image/imgSelHero/campuse/img_markTick.png")
                m_tick:setAnchorPoint(cc.p(0.5, 0.5))
                m_tick:setPosition(cc.p(hero:getContentSize().width*0.5, hero:getContentSize().height*0.5))
                hero:addChild(m_tick)
                local pNum = tonumber(winInfo[ppI]) or -1
                if pNum >= 0 and pNum <= 2 then
                    if pNum == 0 then
                        pNum = 1
                    elseif pNum == 1 then
                        pNum = 0    
                    end
                    local _tick = cc.Sprite:create("res/image/tmpbattle/battle_result"..pNum..".png")
                    if _tick then
                        _tick:setAnchorPoint(1, 0)
                        _tick:setPosition(hero:getContentSize().width, 3)
                        hero:addChild(_tick)
                    end
                end
            end
        end
    end
end

function BattleUINXNLayer:onCleanup()
    musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_main,true)
end

function BattleUINXNLayer:create(data,battle_type)
    return BattleUINXNLayer.new(data,battle_type) 
end

return BattleUINXNLayer