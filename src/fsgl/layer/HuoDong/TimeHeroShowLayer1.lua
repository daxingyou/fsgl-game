local TimeHeroShowLayer1 = class("TimeHeroShowLayer1",function()
	return XTHDPopLayer:create({opacityValue = 200})
end)

function TimeHeroShowLayer1:ctor(_heroid)
	if _heroid == nil then
		return _heroid
	end
	self:initLayer(_heroid)
end


function TimeHeroShowLayer1:initLayer(_heroid)
	local _containerLayer = self:getContainerLayer()
	_containerLayer:setClickable(false)

	local _heroHeight = _containerLayer:getContentSize().height/2-50
	local _heroSp = XTHD.getHeroSpineById(_heroid)
	_heroSp:setPosition(cc.p(_containerLayer:getContentSize().width/2,_heroHeight))
	_heroSp:setAnimation(0,action_Idle,true)
	
	_containerLayer:addChild(_heroSp)

	local _showBtn = XTHD.createCommonButton({
			btnSize = cc.size(135,46),
			isScrollView = false,
			text = "展示技能",
		})
	_showBtn:setPosition(cc.p(_containerLayer:getContentSize().width/2+150,_heroHeight-100))
	_containerLayer:addChild(_showBtn)
	_showBtn:setTouchEndedCallback(function()
			_heroSp:setAnimation(0,action_Atk0,false)
			_heroSp:addAnimation(0,action_Atk1,false)
			_heroSp:addAnimation(0,action_Atk2,false)
			_heroSp:addAnimation(0,action_Idle,true)
		end)

	local _exitBtn = XTHD.createCommonButton({
			btnSize = cc.size(135,46),
			isScrollView = false,
			text = "退出",
		})
	_exitBtn:setPosition(cc.p(_containerLayer:getContentSize().width/2-150,_heroHeight-100))
	_containerLayer:addChild(_exitBtn)
	_exitBtn:setTouchEndedCallback(function()
			_heroSp:removeFromParent()
			self:hide()
		end)
	self:show()
end

function TimeHeroShowLayer1:create(_heroid)
	local _layer = self.new(_heroid)
	if _layer~=nil then
		return _layer
	end
end
return TimeHeroShowLayer1