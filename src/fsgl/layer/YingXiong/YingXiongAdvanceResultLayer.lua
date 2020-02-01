local YingXiongAdvanceResultLayer = class("YingXiongAdvanceResultLayer",function()
	return XTHDPopLayer:create({opacityValue = 204})
	end)
function YingXiongAdvanceResultLayer:ctor(_type,_data,parent)
	self._parent = parent
	local _resoultType = _type or "success"
	if _resoultType == "success" then
		self:initSuccesslayer(_data)
		-- self:initFailureLayer()
	else
		self:initFailureLayer()
	end

end
function YingXiongAdvanceResultLayer:initSuccesslayer(_data)
	-- local _popNode = 

	local _containerLayer= self:getContainerLayer()
	_containerLayer:setClickable(false)

	-- local _advanceSpine = sp.SkeletonAnimation:create( "res/image/plugin/hero/advanceFrames/rwjj.json", "res/image/plugin/hero/advanceFrames/rwjj.atlas", 1.0)
    -- -- _diceSpine:setName("proficientySpine")
    -- _advanceSpine:setAnimation(0,"atk",false)
	-- _advanceSpine:addAnimation(0,"idle",true)
	--new
	local _advanceSpine = sp.SkeletonAnimation:create( "res/image/plugin/hero/advanceFrames/jinjiechenggong.json", "res/image/plugin/hero/advanceFrames/jinjiechenggong.atlas", 1.0)
	_advanceSpine:addAnimation(0,"jinjiechenggong",false)
	_advanceSpine:setAnimation(0,"jinjiechenggong_loop",true)
    _advanceSpine:setPosition(cc.p(_containerLayer:getContentSize().width/2,_containerLayer:getContentSize().height/2))
	_containerLayer:addChild(_advanceSpine)
	_advanceSpine:setScale(0.8)

	local _popBg = XTHDSprite:createWithTexture(nil,cc.rect(0,0,922,332))
	_popBg:setSwallowTouches(true)
	_popBg:setOpacity(0)
	_popBg:setScale(1.2)
	_popBg:setPosition(cc.p(_advanceSpine:getContentSize().width/2,_advanceSpine:getContentSize().height/2-35))
	_advanceSpine:addChild(_popBg)

    --人物
    local _heroPosY = _popBg:getContentSize().height - 93
    --箭头
	local _arrow = cc.Sprite:create("res/image/plugin/hero/advanceAni_arrow.png")
	_arrow:setAnchorPoint(cc.p(0.5,0))
	_arrow:setPosition(cc.p(_popBg:getContentSize().width/2,_heroPosY))
	_popBg:addChild(_arrow)
	--before
	local heroRankTab_left = XTHD.resource.getRankColor_number(tonumber(_data.advance)-1 or 0,_data.heroid)
	local _heroImgpath = XTHD.resource.getHeroAvatorImgById(_data.heroid)
	local _heroBefore_sp = cc.Sprite:create(_heroImgpath)
	_heroBefore_sp:setAnchorPoint(cc.p(1,0))
	_heroBefore_sp:setScale(0.75)
	_heroBefore_sp:setPosition(cc.p(_arrow:getBoundingBox().x - 45,_heroPosY))
	_popBg:addChild(_heroBefore_sp)
	local _heroleftBg = cc.Sprite:create(XTHD.resource.getQualityHeroBgPath(tonumber(_data.rank)))
	_heroleftBg:setPosition(cc.p(_heroBefore_sp:getContentSize().width/2,_heroBefore_sp:getContentSize().height/2))
	_heroBefore_sp:addChild(_heroleftBg)
	--名称
	local _leftName = XTHDLabel:create(_data.name,18)
	_leftName:setAnchorPoint(cc.p(0.5,0))
	_leftName:setColor(heroRankTab_left["color"])
	_leftName:setPosition(cc.p(0,_heroPosY - 48))
	_popBg:addChild(_leftName)
	local _leftAddNumber = XTHDLabel:create(heroRankTab_left["addNumberStr"] or "",18)
	_leftAddNumber:setColor(heroRankTab_left["color"])
	_leftAddNumber:setAnchorPoint(cc.p(0,0))
	_leftName:setPositionX(_heroBefore_sp:getBoundingBox().x+_heroBefore_sp:getBoundingBox().width/2 - _leftAddNumber:getContentSize().width/2)
	_leftAddNumber:setPosition(cc.p(_leftName:getBoundingBox().x +  _leftName:getBoundingBox().width,_leftName:getPositionY()))
	_popBg:addChild(_leftAddNumber)
	--战斗力
	local _leftFightSp = cc.Sprite:create("res/image/common/fightValue_Image.png")
	_leftFightSp:setAnchorPoint(cc.p(1,0))
	_leftFightSp:setScale(0.7)
	local _leftFightValue_label = getCommonYellowBMFontLabel(_data.oldPower)
	_leftFightValue_label:setAnchorPoint(cc.p(0.5,0))
	_leftFightValue_label:setScale(0.9)
	_leftFightValue_label:setPosition(cc.p(_heroBefore_sp:getBoundingBox().x+_heroBefore_sp:getBoundingBox().width/2 + _leftFightSp:getBoundingBox().width/2,_heroPosY - 35))
	_leftFightSp:setPosition(cc.p(_leftFightValue_label:getBoundingBox().x, _heroPosY - 25.5))
	_popBg:addChild(_leftFightSp)
	_popBg:addChild(_leftFightValue_label)
	--after
	local heroRankTab_right = XTHD.resource.getRankColor_number(_data.advance or 0,_data.heroid)
	local _heroAfter_sp = cc.Sprite:create(_heroImgpath)
	_heroAfter_sp:setAnchorPoint(cc.p(0,0))
	_heroAfter_sp:setScale(0.75)
	_heroAfter_sp:setPosition(cc.p(_arrow:getBoundingBox().x+_arrow:getBoundingBox().width + 45,_heroPosY))
	_popBg:addChild(_heroAfter_sp)
	local _herorightBg = cc.Sprite:create(XTHD.resource.getQualityHeroBgPath(_data.rank))
	_herorightBg:setPosition(cc.p(_heroAfter_sp:getContentSize().width/2,_heroAfter_sp:getContentSize().height/2))
	_heroAfter_sp:addChild(_herorightBg)
	--名称
	local _rightName = XTHDLabel:create(_data.name,18)
	_rightName:setColor(heroRankTab_right["color"])
	_rightName:setAnchorPoint(cc.p(0.5,0))
	_rightName:setPosition(cc.p(_heroAfter_sp:getBoundingBox().x+_heroAfter_sp:getBoundingBox().width/2 - 18,_heroPosY-48))
	_popBg:addChild(_rightName)
	local _rightAddNumber = XTHDLabel:create(heroRankTab_right["addNumberStr"] or "",18)
	_rightAddNumber:setAnchorPoint(cc.p(0,0))
	_rightAddNumber:setColor(heroRankTab_right["color"])
	-- _rightAddNumber:enableShadow(cc.c4b(0,0,0,255),cc.size(0.5,-0.5),0.5)
	_rightName:setPositionX(_heroAfter_sp:getBoundingBox().x+_heroAfter_sp:getBoundingBox().width/2 - _rightAddNumber:getContentSize().width/2)
	_rightAddNumber:setPosition(cc.p(_rightName:getBoundingBox().x +  _rightName:getBoundingBox().width,_rightName:getPositionY()))
	_popBg:addChild(_rightAddNumber)
	--战斗力
	local _rightFightSp = cc.Sprite:create("res/image/common/fightValue_Image.png")
	_rightFightSp:setScale(0.7)
	_rightFightSp:setAnchorPoint(cc.p(1,0))
	local _rightFightValue_label = getCommonYellowBMFontLabel(_data.power)
	_rightFightValue_label:setScale(0.9)
	_rightFightValue_label:setAnchorPoint(cc.p(0.5,0))
	_rightFightValue_label:setPosition(cc.p(_heroAfter_sp:getBoundingBox().x+_heroAfter_sp:getBoundingBox().width/2 + _rightFightSp:getBoundingBox().width/2,_heroPosY - 35))
	_rightFightSp:setPosition(cc.p(_rightFightValue_label:getBoundingBox().x, _heroPosY - 25.5))
	_popBg:addChild(_rightFightSp)
	_popBg:addChild(_rightFightValue_label)

	--line1
	local _lineFirst = cc.Sprite:create("res/image/plugin/hero/heroAdvance_line.png")
	_lineFirst:setPosition(cc.p(_popBg:getContentSize().width/2,_popBg:getContentSize().height - 145))
	_popBg:addChild(_lineFirst)
	local _propertyHeight = _lineFirst:getBoundingBox().y - 15
	--技能
	if _data.newSkillid then
		local _skillPosX = _popBg:getContentSize().width/2 - 45
		local _skillColor = cc.c4b(255,207,139,255)
		local _skillData = gameData.getDataFromCSV("JinengInfo",{skillid = _data.newSkillid})
		local _skillTitle_sp = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.advanceResoultSkillTitleTextXc,20)
		_skillTitle_sp:setColor(_skillColor)
		_skillTitle_sp:setAnchorPoint(cc.p(1,0))
		_skillTitle_sp:setPosition(cc.p(_skillPosX-5,_lineFirst:getBoundingBox().y-45))
		_popBg:addChild(_skillTitle_sp)

		--技能图标
		_skillData.isUnLock = true
		local _skillItem_sp = JiNengItem:createWithParams(_skillData)
		_skillItem_sp:setTouchSize(cc.size(100,100))
		_skillItem_sp:setScale(60/_skillItem_sp:getContentSize().width)
		_skillItem_sp:setAnchorPoint(cc.p(0,0.5))
		_skillItem_sp:setPosition(cc.p(_skillTitle_sp:getBoundingBox().x + _skillTitle_sp:getBoundingBox().width + 10,_lineFirst:getBoundingBox().y-37))
		_popBg:addChild(_skillItem_sp)

		--技能名称
		local _skillNamePosX = _skillItem_sp:getBoundingBox().x + _skillItem_sp:getBoundingBox().width + 7
		local _skillName = XTHDLabel:create(_skillData.name,18)
		_skillName:setAnchorPoint(cc.p(0,0))
		_skillName:setColor(_skillColor)
		_skillName:setPosition(cc.p(_skillNamePosX,_skillItem_sp:getBoundingBox().y +35))
		_popBg:addChild(_skillName)
		--技能类型
		local _skillType = LANGUAGE_SKILLDESC[1]-----"主动技能"
		if _skillData.ispassive == 0 then
			_skillType = LANGUAGE_SKILLDESC[1]----"主动技能"
		elseif _skillData.ispassive == 1 then
			_skillType = LANGUAGE_SKILLDESC[2]------"被动技能"
		elseif _skillData.ispassive == 2 then
			_skillType = LANGUAGE_SKILLDESC[3] ------- "天赋技能"
		end
		local _skilltypelabel = XTHDLabel:create(_skillType,18)
		_skilltypelabel:setColor(cc.c4b(104,157,0,255))
		_skilltypelabel:setAnchorPoint(cc.p(0,0))
		_skilltypelabel:setPosition(cc.p(_skillNamePosX,_skillItem_sp:getBoundingBox().y + 5))
		_popBg:addChild(_skilltypelabel)

		local _lineSecond = cc.Sprite:create("res/image/plugin/hero/heroAdvance_line.png")
		_lineSecond:setPosition(cc.p(_popBg:getContentSize().width/2,_popBg:getContentSize().height - 145-75))
		_popBg:addChild(_lineSecond)
		_propertyHeight = _lineSecond:getBoundingBox().y - 15
	end

	self.property_scrollView = ccui.ScrollView:create()
    -- self.property_scrollView:setBounceEnabled(true)
    self.property_scrollView:setDirection(ccui.ScrollViewDir.vertical)
    self.property_scrollView:setTouchEnabled(true)
    self.property_scrollView:setScrollBarEnabled(false)
    self.property_scrollView:setContentSize(cc.size(350,_propertyHeight))
    self.property_scrollView:setPosition(_popBg:getContentSize().width/2-150,15)
    _popBg:addChild(self.property_scrollView)
    if _propertyHeight > 32*5 then
    	self.property_scrollView:setInnerContainerSize(cc.size(350,_propertyHeight))
	else
		self.property_scrollView:setInnerContainerSize(cc.size(350,32*5))
    end
    
    self:setPropertyPart(_data)

    performWithDelay(self, function()
	    	local _tips = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_CLICKSCENEIN,XTHD.SystemFont,18)
			_tips:setColor(cc.c4b(255,240,216,255))
			-- _tips:setAnchorPoint(0.5,0.5)
		    _tips:setPosition(_popBg:getBoundingBox().width / 2-100,-15)
		    _popBg:addChild(_tips)
    		_containerLayer:setClickable(true)
    	end,0.5)
	
	self:show()
end

function YingXiongAdvanceResultLayer:setPropertyPart(_data)
	if self.property_scrollView == nil then
		return
	end
	local _propertyHeight = self.property_scrollView:getInnerContainerSize().height
	local _propertyId = {200,201,202,203,204}
	local _oldPropertyData = _data.oldPropertyData
	local _newPropertyData = _data
	for i=1,#_propertyId do
		local _key = XTHD.resource.AttributesName[tonumber(_propertyId[i])]
		local _nameStr = LANGUAGE_KEY_ATTRIBUTESNAME(tostring(_propertyId[i])) .. ":"
		local _nameLabel = XTHDLabel:create(_nameStr,20)
		_nameLabel:setColor(cc.c4b(255,207,139))
		_nameLabel:enableShadow(cc.c4b(),cc.size(0.4,-0.4),0.4)
		_nameLabel:setAnchorPoint(cc.p(0,0))
		_nameLabel:setPosition(cc.p(0,_propertyHeight - 32*i))
		self.property_scrollView:addChild(_nameLabel)

		local _midPosY = _nameLabel:getBoundingBox().y+_nameLabel:getBoundingBox().height/2
		local _oldValue = getCommonWhiteBMFontLabel(_oldPropertyData[tostring(_key)] or 0)
		-- _oldValue:setScale(0.9)
		_oldValue:setAnchorPoint(cc.p(0,0.5))
		_oldValue:setPosition(cc.p(_nameLabel:getBoundingBox().x+_nameLabel:getBoundingBox().width + 10,_midPosY-7))
		self.property_scrollView:addChild(_oldValue)

		local _arrowSp = cc.Sprite:create("res/image/plugin/hero/hero_propertyadd.png")
		_arrowSp:setRotation(90)
		_arrowSp:setAnchorPoint(cc.p(0.5,0.5))
		_arrowSp:setPosition(cc.p(_nameLabel:getBoundingBox().x+_nameLabel:getBoundingBox().width+115,_midPosY))
		self.property_scrollView:addChild(_arrowSp)

		local _newValue = getCommonGreenBMFontLabel(_newPropertyData[tostring(_key)] or 0)
		_newValue:setScale(0.7)
		_newValue:setAnchorPoint(cc.p(0,0.5))
		_newValue:setPosition(cc.p(_arrowSp:getBoundingBox().x+_arrowSp:getBoundingBox().width+3,_midPosY - 2))
		self.property_scrollView:addChild(_newValue)
	end
end


--进阶动画
function YingXiongAdvanceResultLayer:advanceTitleAni()
end
function YingXiongAdvanceResultLayer:initFailureLayer()
	local _tureAniSpr = cc.Sprite:create("res/image/common/popBox_failureLight.png")
	_tureAniSpr:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
	self:getContainerLayer():addChild(_tureAniSpr)
	
	local _popNode  = cc.Sprite:create("res/image/common/popBox_failureAdvanceSp.png")
	_popNode:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
	self:getContainerLayer():addChild(_popNode)

	_tureAniSpr:runAction(cc.RepeatForever:create(cc.RotateBy:create(60,360)))
	self:show()
end

function YingXiongAdvanceResultLayer:create(_type,_data,parent)
	local _layer = self.new(_type,_data,parent)
	return _layer
end

function YingXiongAdvanceResultLayer:getOkayButton()
	
end

function YingXiongAdvanceResultLayer:onEnter( )
	YinDaoMarg:getInstance():removeCover(self._parent)
end

function YingXiongAdvanceResultLayer:onExit( )
	cc.Director:getInstance():getTextureCache():removeTextureForKey("res/image/plugin/hero/advanceFrames/rwjj.png")
    YinDaoMarg:getInstance():doNextGuide() 	
end

return YingXiongAdvanceResultLayer