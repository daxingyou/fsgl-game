--[=[
	FileName:YingXiongStarupResultPopLayer.lua
	Autor:xingchen
	Date:2015.11.11
	Content:升星结果页
]=]
local YingXiongStarupResultPopLayer = class("YingXiongStarupResultPopLayer",function()
	return XTHDPopLayer:create({opacityValue = 204})
	end)
function YingXiongStarupResultPopLayer:ctor(_data,parent)
	self._parent = parent
	self.resultData = _data or {}
	self:setOpacity(204)
	self:initSuccesslayer()
end

function YingXiongStarupResultPopLayer:initSuccesslayer()
	-- local _popNode = 

	local _containerLayer= self:getContainerLayer()
	_containerLayer:setClickable(false)

	local _starupSpine = sp.SkeletonAnimation:create( "res/image/plugin/hero/starupFrames/shengxing_down.json", "res/image/plugin/hero/starupFrames/shengxing_down.atlas", 1.0)
    -- _diceSpine:setName("proficientySpine")
    -- _starupSpine2:setAnimation(0,"atk",false)
    _starupSpine:addAnimation(0,"shengxing_down",true)
    _starupSpine:setPosition(cc.p(_containerLayer:getContentSize().width/2,_containerLayer:getContentSize().height/2-10))
    _containerLayer:addChild(_starupSpine)

	-- local _starupSpine = sp.SkeletonAnimation:create( "res/image/plugin/hero/starupFrames/rwsx.json", "res/image/plugin/hero/starupFrames/rwsx.atlas", 1.0)
    -- -- _diceSpine:setName("proficientySpine")
    -- _starupSpine:setAnimation(0,"atk",false)
    -- _starupSpine:addAnimation(0,"idle",true)
    -- _starupSpine:setPosition(cc.p(_containerLayer:getContentSize().width/2,_containerLayer:getContentSize().height/2))
    -- _containerLayer:addChild(_starupSpine)

	local _popBg = XTHDSprite:createWithTexture(nil,cc.rect(0,0,922,400))
	self.popBg = _popBg
	_popBg:setSwallowTouches(false)
	_popBg:setOpacity(0)
	_popBg:setPosition(cc.p(_starupSpine:getContentSize().width/2,_starupSpine:getContentSize().height/2-35))
	_starupSpine:addChild(_popBg)
	
	local _propertyHeight = (28+6)*5
	self.property_scrollView = ccui.ScrollView:create()
    -- self.property_scrollView:setBounceEnabled(true)
    self.property_scrollView:setDirection(ccui.ScrollViewDir.vertical)
    self.property_scrollView:setTouchEnabled(true)
    self.property_scrollView:setScrollBarEnabled(false)
    self.property_scrollView:setContentSize(cc.size(324,_propertyHeight))
    self.property_scrollView:setInnerContainerSize(cc.size(324,_propertyHeight))
    self.property_scrollView:setPosition(_popBg:getContentSize().width/2-324/2,0)
    _popBg:addChild(self.property_scrollView)

    self:setPropertyPart()

	self:playHeroAnimation(self.resultData.heroid)
	self:playStarAnimation(self.resultData.star)

	performWithDelay(self, function()
			_containerLayer:setClickable(true)
		end,0.5)

	-- self:show()
end

function YingXiongStarupResultPopLayer:playHeroAnimation(_heroid)
	if _heroid == nil then
		return
	end
	local nId = tonumber(_heroid);
	local _spine_sp = XTHD.getHeroSpineById(nId)
	_spine_sp:setAnimation(0,action_Atk0,true)
	-- _spine_sp:setScale(0.8)
	_spine_sp:setPosition(self.popBg:getContentSize().width/2,168 + 32+20)
	_spine_sp:setName("heroSpine")
	self.popBg:addChild(_spine_sp)
end

function YingXiongStarupResultPopLayer:playStarAnimation(_star)
	if _star==nil then
		return
	end
	local _starPos = SortPos:sortFromMiddle(cc.p(self.popBg:getContentSize().width/2,168 + 12),_star,25)
	for i=1,_star do
		local _starSpSpine = sp.SkeletonAnimation:create( "res/image/plugin/hero/starupFrames/shengxing_up.json", "res/image/plugin/hero/starupFrames/shengxing_up.atlas", 1.0)
		-- local _starSpSpine = sp.SkeletonAnimation:create( "res/image/plugin/hero/starupFrames/xx.json", "res/image/plugin/hero/starupFrames/xx.atlas", 1.0)
    -- _diceSpine:setName("proficientySpine")
	    
	    _starSpSpine:setPosition(_starPos[i])
	    self.popBg:addChild(_starSpSpine)
	    if _star == i then
	    	-- _starSpSpine:setAnimation(0,"atk",false)
			-- _starSpSpine:addAnimation(0,"idle",true)
		    _starSpSpine:addAnimation(0,"shengxing_up",false)
	    else
			-- _starSpSpine:setAnimation(0,"idle",true)
			_starSpSpine:setAnimation(0,"shengxing_up",false)
	    end
	end
end

function YingXiongStarupResultPopLayer:setPropertyPart()
	if self.property_scrollView == nil then
		return
	end
	local _propertySize = self.property_scrollView:getInnerContainerSize()
	local labelName_table = LANGUAGE_TIPS_WORDS112
	if self.resultData.star <= 5 then
		labelName_table = LANGUAGE_TIPS_WORDS112
	else
		labelName_table = LANGUAGE_TIPS_WORDS112_1
	end
	local keyTable = {"hp" , "physicalattack" , "manaattack" , "physicaldefence" , "manadefence" }
	local _oldPropertyData = self.resultData.oldProperty or {}
	local _newPropertyData = self.resultData.newProperty or {}
	for i=1,5 do
		local _distanceHeight= _propertySize.height/10*(11-i*2)
		local _propertyBg = cc.Sprite:create("res/image/plugin/hero/herostar_bg.png")
		-- _propertyBg:setAnchorPoint(cc.p(0.5,0))
		_propertyBg:setPosition(cc.p(_propertySize.width/2,_distanceHeight))
		self.property_scrollView:addChild(_propertyBg)

		local _nameStr = labelName_table[i]
		local _midPosY = _propertyBg:getContentSize().height/2
		local _nameLabel = XTHDLabel:create(_nameStr,20)
		_nameLabel:setColor(cc.c4b(255,207,139))
		_nameLabel:enableShadow(cc.c4b(),cc.size(0.4,-0.4),0.4)
		_nameLabel:setAnchorPoint(cc.p(0,0.5))
		_nameLabel:setPosition(cc.p(_propertyBg:getContentSize().width/2-120,_midPosY))
		_propertyBg:addChild(_nameLabel)

		local _oldValue
		if self.resultData.star <= 6 then
			_oldValue = getCommonWhiteBMFontLabel(_oldPropertyData[tostring(keyTable[i] .. "grow")] or 0)
		else
			_oldValue = getCommonWhiteBMFontLabel(_oldPropertyData[tostring(keyTable[i] .. "grow")].."%" or 0)
		end
		-- _oldValue:setScale(0.9)
		_oldValue:setAnchorPoint(cc.p(0,0.5))
		_oldValue:setPosition(cc.p(_nameLabel:getBoundingBox().x+_nameLabel:getBoundingBox().width + 10,_midPosY-7))
		_propertyBg:addChild(_oldValue)

		local _arrowSp = cc.Sprite:create("res/image/plugin/hero/hero_propertyadd.png")
		_arrowSp:setRotation(90)
		_arrowSp:setAnchorPoint(cc.p(0.5,0.5))
		_arrowSp:setPosition(cc.p(_nameLabel:getBoundingBox().x+_nameLabel:getBoundingBox().width+90,_midPosY))
		_propertyBg:addChild(_arrowSp)

		local _newValue
		if self.resultData.star <= 5 then
			_newValue = getCommonWhiteBMFontLabel(_newPropertyData[tostring(keyTable[i] .. "grow")] or 0)
		else
			_newValue = getCommonWhiteBMFontLabel(_newPropertyData[tostring(keyTable[i] .. "grow")].."%" or 0)
		end
		-- _newValue:setScale(0.9)
		_newValue:setAnchorPoint(cc.p(0,0.5))
		_newValue:setPosition(cc.p(_arrowSp:getBoundingBox().x+_arrowSp:getBoundingBox().width+3,_midPosY - 7))
		_propertyBg:addChild(_newValue)
	end
end

function YingXiongStarupResultPopLayer:create(_data,parent)
	local _layer = self.new(_data,parent)
	return _layer
end

function YingXiongStarupResultPopLayer:getOkayButton()
	
end

function YingXiongStarupResultPopLayer:onEnter( )
	YinDaoMarg:getInstance():removeCover(self._parent)
end

function YingXiongStarupResultPopLayer:onExit( )
    YinDaoMarg:getInstance():doNextGuide() 	
    if self.popBg~=nil and self.popBg:getChildByName("heroSpine") then
		self.popBg:removeChildByName("heroSpine")
	end
end

return YingXiongStarupResultPopLayer