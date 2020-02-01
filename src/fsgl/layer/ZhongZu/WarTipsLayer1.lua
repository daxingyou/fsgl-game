
local WarTipsLayer1 = class("WarTipsLayer1",function( )
	return XTHDDialog:create()
end)

function WarTipsLayer1:ctor( isMode,which )
	self._isMode = isMode
	self._which = which

	self._spine = nil
end
--[[
@which boss,camp,campstart, -----世界Boss，种族即将开启，种族现在开启
]]
function WarTipsLayer1:create(isMode,which)
	local _tips = WarTipsLayer1.new(isMode,which)
	if _tips then 
		_tips:init()
	end 
	return _tips
end

function WarTipsLayer1:onCleanUp( )
	self._spine = nil
	local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/plugin/tongzhi.png")
end

function WarTipsLayer1:init( )
	self._spine = sp.SkeletonAnimation:create( "res/image/plugin/tongzhi.json", "res/image/plugin/tongzhi.atlas", 1.0)
	if self._spine then 
		self:addChild(self._spine)
	    self._spine:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
		self._spine:registerSpineEventHandler( function ( event )
			if event.eventData.name == "atk" then 
				self:handleEvent()
			end 
		end, sp.EventType.ANIMATION_EVENT)    
	end 
	if self._which == "camp" then 
		self:initCamp()
	elseif self._which == "boss" or self._which == "campstart" then 
		self:setBattleStart()
	end 
end

function WarTipsLayer1:initCamp( )
	-----背景
	local _bgU = cc.Sprite:create("res/image/camp/camp_begin_tipbg.png")
	self:addChild(_bgU)
	_bgU:setAnchorPoint(0.5,0)
	_bgU:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	_bgU:setOpacity(0)
	local _bgD = cc.Sprite:createWithTexture(_bgU:getTexture())
	self:addChild(_bgD)
	_bgD:setFlippedY(true)
	_bgD:setAnchorPoint(0.5,1)
	_bgD:setPosition(_bgU:getPositionX(),self:getContentSize().height / 2)
	_bgD:setOpacity(0)
	----文字 
	local _leftW = cc.Sprite:create("res/image/camp/camp_tip_word1.png")
	self:addChild(_leftW)
	_leftW:setPosition(0 - _leftW:getContentSize().width / 2,self:getContentSize().height / 2 + _bgU:getContentSize().height / 2)
	local _rightW = cc.Sprite:create("res/image/camp/camp_tip_word2.png")
	self:addChild(_rightW)
	_rightW:setPosition(self:getContentSize().width + _rightW:getContentSize().width / 2,self:getContentSize().height / 2 - _bgD:getContentSize().height / 2)
	------动作 渐隐
	local time = 2	
	local _fadeIn = cc.FadeIn:create(time / 2)
	local _fadeOut = cc.FadeOut:create(time / 2)
	_bgU:runAction(cc.Sequence:create(_fadeIn,cc.DelayTime:create(time),_fadeOut))
	_bgD:runAction(cc.Sequence:create(_fadeIn:clone(),cc.DelayTime:create(time),_fadeOut:clone()))
	-----动作减速
	local rate = 3.0
	local bx = 20
	-----左边的文字
	local x,y = _leftW:getPosition()
	local _leftIn = cc.MoveTo:create(time,cc.p(self:getContentSize().width / 2,y))
	_leftIn = cc.EaseBackInOut:create(_leftIn)

	local _leftOut = cc.MoveTo:create(time,cc.p(self:getContentSize().width + _leftW:getContentSize().width / 2,y))
	_leftOut = cc.EaseBackInOut:create(_leftOut)

	_leftW:runAction(cc.Sequence:create(_leftIn,_leftOut))
	----右边的文字 
	x,y = _rightW:getPosition()
	local _rightIn = cc.MoveTo:create(time,cc.p(self:getContentSize().width / 2,y))
	_rightIn = cc.EaseBackInOut:create(_rightIn)
	
	local _rightOut = cc.MoveTo:create(time,cc.p(0 - _rightW:getContentSize().width / 2,y))
	_rightOut = cc.EaseBackInOut:create(_rightOut)

	_rightW:runAction(cc.Sequence:create(_rightIn,_rightOut,cc.DelayTime:create(0.016),cc.CallFunc:create(function( )
		self:removeFromParent()
	end)))
end

function WarTipsLayer1:setBattleStart( )
	if self._spine then 
		if self._which == "boss" then 
	    	self._spine:setAnimation(0,"boss",false)
	    elseif self._which == "campstart" then 
	    	self._spine:setAnimation(0,"zy",false)	    	
	    end 
	end 
end

function WarTipsLayer1:handleEvent( )
	if self._which == "boss" then 
		XTHD.dispatchEvent({name = CUSTOM_EVENT.DISPLAY_BATTLEBEGINS_TIP,data = {war = true,warIndex = 1 }})	
	elseif self._which == "campstart" then 
		XTHD.dispatchEvent({name = CUSTOM_EVENT.DISPLAY_BATTLEBEGINS_TIP,data = {war = true,warIndex = 4}})			
	end 
end

return WarTipsLayer1