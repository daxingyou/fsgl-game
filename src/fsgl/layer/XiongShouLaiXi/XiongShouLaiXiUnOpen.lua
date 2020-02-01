-- FileName: XiongShouLaiXiUnOpen.lua
-- Author: wangming
-- Date: 2015-11-04
-- Purpose: 世界boss未开启界面
--[[TODO List]]

local XiongShouLaiXiUnOpen = class("XiongShouLaiXiUnOpen", function(sParams)
	return XTHD.createBasePageLayer({
        bg = "res/image/worldboss/unOpenBack0.png",
        isOnlyBack = true,
    })
end)

function XiongShouLaiXiUnOpen:onCleanup( ... )
    local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey("res/image/worldboss/unOpenBack0.png")
    for i=1, 3 do
        textureCache:removeTextureForKey("res/image/worldboss/unOpenBack" .. i .. ".png")
    end
end

function XiongShouLaiXiUnOpen:initUI( sParams )
    local _size = self:getContentSize()

    local isKilledLast = tonumber(sParams.deadState) or 0
    local _hurtList = sParams.hurtList
    local _backCall = sParams.backCall
    local _backBtn = self:getChildByName("back_btn")
    if _backBtn then
        _backBtn:setTouchEndedCallback(function()
            self:removeFromParent()
            if _backCall then
                _backCall()
            end
        end)
    end
    local _fileName = isKilledLast == 0 and "unOpenBack2.png" or "unOpenBack3.png"

    local _icon = cc.Sprite:create("res/image/worldboss/world_boss.png")
    _icon:setPosition(_size.width * 0.5, _size.height * 0.5 + 50)
    self:addChild(_icon)

    -----------创建icon上边的东西
    local _tipTTF = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS246,
        size = 22,
        anchor = cc.p(0.5, 0),
        pos = cc.p(_icon:getPositionX(), _icon:getPositionY() + _icon:getContentSize().height*0.5),
    })
    self:addChild(_tipTTF)

    local _lastState = cc.Sprite:create("res/image/worldboss/".._fileName)
    _lastState:setAnchorPoint(0.5, 0)
    _lastState:setPosition(_tipTTF:getPositionX(), _tipTTF:getPositionY() + _tipTTF:getContentSize().height + 5)
    self:addChild(_lastState)

    -----------创建icon下边的东西
    local _nextTimeBg = cc.Sprite:create("res/image/worldboss/unOpenBack1.png")
    _nextTimeBg:setPosition(_icon:getPositionX(), _icon:getPositionY() - _icon:getContentSize().height*0.5 - 10)
    self:addChild(_nextTimeBg)

    local _nextTimeTip = cc.Sprite:create("res/image/worldboss/cd_sp2.png")
    _nextTimeTip:setPosition(_nextTimeBg:getContentSize().width*0.5 - 40, _nextTimeBg:getContentSize().height*0.5 + 3)
    _nextTimeBg:addChild(_nextTimeTip)

    local _timeShow = getCommonWhiteBMFontLabel("0") 
    self._timeShow = _timeShow 
    _timeShow:setAnchorPoint(0,0.5)                            
    _timeShow:setPosition(_nextTimeTip:getPositionX() + _nextTimeTip:getContentSize().width*0.5 + 2, _nextTimeTip:getPositionY() - 7)
    _nextTimeBg:addChild(_timeShow)

    local _touchSize = cc.size(170, 50)
    local _startBtn = XTHD.createCommonButton({
        text = LANGUAGE_BTN_KEY.shanghaibang,
        isScrollView = false,
        fontSize = 22,
        btnSize = _touchSize,
        endCallback = function( ... )
            local list_pop = requires("src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiHurtListPop.lua"):create(_hurtList)
            list_pop:show()
            LayerManager.addLayout(list_pop, {noHide = true})
        end,
        anchor = cc.p(1, 0.5),
        pos = cc.p(_icon:getPositionX() - 10, _icon:getPositionY() - _icon:getContentSize().height*0.5 - 80)
    })
    self:addChild(_startBtn)
    
    _startBtn = XTHD.createCommonButton({
        text = LANGUAGE_BTN_KEY.chakanjiangli,
        isScrollView = false,
        fontSize = 22,
        btnSize = _touchSize,
        endCallback = function( ... )
            local reward_pop=requires("src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiRewardPop.lua"):create()
            reward_pop:show()
            LayerManager.addLayout(reward_pop, {noHide = true})
            -- self:addChild(reward_pop, 10)
        end,
        anchor = cc.p(0, 0.5),
        pos = cc.p(_icon:getPositionX() + 10, _icon:getPositionY() - _icon:getContentSize().height*0.5 - 80)
    })
    self:addChild(_startBtn)
end

function XiongShouLaiXiUnOpen:updateTimeShow( time )
    self._timeShow:setString(time)
end

function XiongShouLaiXiUnOpen:createForLayerManager( sParams )
    LayerManager.addShieldLayout()
    local lay = XiongShouLaiXiUnOpen.new(sParams)
    lay:initUI(sParams)
    return lay
end

return XiongShouLaiXiUnOpen