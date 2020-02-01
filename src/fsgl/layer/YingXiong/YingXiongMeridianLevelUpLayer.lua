local YingXiongMeridianLevelUpLayer = class("YingXiongMeridianLevelUpLayer",function()
	return XTHD.createBasePageLayer({bg = "res/image/plugin/meridian/meridian_bg2.png",isShadow = true})
end)

function YingXiongMeridianLevelUpLayer:ctor(_meridianIdx,_heroid)
	self.curMeridianData = {}
	self.meridianLevelStaticData = {}
	self.meridianRankStaticData = {}

	self.oldPropertyValue = {} 		--旧的属性值
	self.newPropertyValue = {} 		--新的属性值

	self.countLabel = {}
	self.downBg = nil 
	self.leftScrollBtn = nil
	self.rightScrollBtn = nil
	self.propertyBg = nil

	self.meridianEnergy = nil 		--当前韬略值
	self.meridianName = nil 		--当前阶段名称

	self.meridianIdx = 1
	self.heroid = _heroid

	self.costEnergyValue = 0

	self.propertyKey = {"addhp","addat","addmat","adddf","addmdf","addbj","addsb","addmz","addbjbl","addbsjm","addnq","addct","addjm"}
	self.propertyName = {200,201,203,202,204,302,301,300,303,304,314,306,305}

	-- self:getDynamicMeridianData()
	self:setStaticData()
	self:getStaticItemInfoData()
	self:getDynamicItemData()
	self:setCurStaticData(_meridianIdx)
	self:setCurMeridianData()
	self:setPropertyAddition()
	
	self:initLayer()

	local _spine = sp.SkeletonAnimation:create( "res/spine/effect/meridian_wakeupEffect/xinfajinjie_up.json", "res/spine/effect/meridian_wakeupEffect/xinfajinjie_up.atlas",1.0);
	if _spine then
		_spine:removeFromParent()
	end
end

function YingXiongMeridianLevelUpLayer:onCleanup()
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
end

function YingXiongMeridianLevelUpLayer:initLayer()
	local _topBarHeight = self.topBarHeight or 40
	
	self:setLeftLayer()

	--kuang 
	local kuang = ccui.Scale9Sprite:create("res/image/camp/kuang2.png")
	kuang:setContentSize(345,50)
	kuang:setPosition(cc.p(32, self:getContentSize().height -35 - _topBarHeight-20))
	kuang:setAnchorPoint(0,0.5)
	self:addChild(kuang)
	-------当前韬略值-------
	local _zhenqiPosY = self:getContentSize().height -35 - _topBarHeight-20
	local _hasZhenqiLabel = XTHDLabel:create(LANGUAGE_HEROMERIDIAN.zhenqiValue,22)
	_hasZhenqiLabel:setColor(cc.c3b(54,55,112))
	_hasZhenqiLabel:enableShadow(cc.c3b(54,55,112),cc.size(0.4,-0.4),0.4)
	_hasZhenqiLabel:setAnchorPoint(cc.p(0,0.5))
	_hasZhenqiLabel:setPosition(cc.p(64,_zhenqiPosY))
	self:addChild(_hasZhenqiLabel)
	local _addBtn = XTHD.createButton({
			normalFile = "res/image/common/btn/btn_plus_normal.png",
			selectedFile = "res/image/common/btn/btn_plus_selected.png",
		})
	_addBtn:setPosition(cc.p(_hasZhenqiLabel:getBoundingBox().x + 190,_zhenqiPosY))
	self:addChild(_addBtn)
	_addBtn:setTouchEndedCallback(function()
			self:addZhenqiBtnCallback()
		end)

	local _energyPosX = (_addBtn:getBoundingBox().x+_hasZhenqiLabel:getBoundingBox().x+_hasZhenqiLabel:getBoundingBox().width)/2
	--背景 
	local l_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png")
	l_bg:setContentSize(100,30)
	l_bg:setPosition(cc.p(_energyPosX,_zhenqiPosY))
	self:addChild(l_bg)

	local _energyLabel = XTHDLabel:create(0,20)
	self.meridianEnergy = _energyLabel
	_energyLabel:setColor(cc.c3b(255,255,255))
	_energyLabel:enableShadow(cc.c3b(255,255,255),cc.size(0.4,-0.4),0.4)
	_energyLabel:setPosition(cc.p(_energyPosX,_zhenqiPosY))
	self:addChild(_energyLabel)
	self:refreshMeridianEnergy()
	-------当前韬略值-end--------

	local _leftWidth = 400
	local _downSize = cc.size(self:getContentSize().width-_leftWidth,145)
	local _downBg = cc.Sprite:createWithTexture(nil, cc.rect(0,0,_downSize.width,_downSize.height))
	self.downBg = _downBg
	_downBg:setOpacity(0)
	_downBg:setAnchorPoint(cc.p(0,0))
	_downBg:setPosition(cc.p(_leftWidth,0))
	self:addChild(_downBg)

	self:setBgContent()
		--右边的大转盘
	local _bg = cc.Sprite:create("res/image/plugin/meridian/meridianLevel_bg.png")
	_bg:setPosition(cc.p(_downSize.width/2+_leftWidth,(self:getContentSize().height - _topBarHeight+145-40)/2-40 ))
	self:addChild(_bg)
	_bg:setScale(0.8)
	self.bg = _bg
	local _midPointPos = cc.p(_bg:getContentSize().width/2+1,185+2+180)
	self.midPointPos = _midPointPos 
	local _levelValue = 0
	local _circleProgress = cc.ProgressTimer:create(cc.Sprite:create("res/image/plugin/meridian/meridianLevel_progress.png"))
	_circleProgress:setRotation(214.5)
	_circleProgress:setOpacity(0)
	self.circleProgress = _circleProgress
 	-- _circleProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
 	_circleProgress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
 	_circleProgress:setMidpoint(cc.p(0.5, 0.5))
 	-- _circleProgress:setBarChangeRate(cc.p(0, 1))
 	_circleProgress:setAnchorPoint(0.5,0.5)
 	_circleProgress:setPercentage(_levelValue)
 	_circleProgress:setPosition(_midPointPos)
 	_bg:addChild(_circleProgress)

 	local _levelTitlePosTable = {
		cc.p(3,-165),cc.p(-160,0),cc.p(3,170),cc.p(170,0),cc.p(3,0)
	}
	self.levelItemSp = {}
	for i=1,5 do
		local _disableNode = cc.Sprite:create("res/image/plugin/meridian/meridianLevel_normal.png")
		XTHD.setGray(_disableNode)
		local _itemSp = XTHD.createButton({
				normalFile = "res/image/plugin/meridian/meridianLevel_normal.png",
				selectedFile = "res/image/plugin/meridian/meridianLevel_selected.png",
				disableNode = _disableNode,
			})
		_itemSp:setClickable(false)
		_itemSp:setPosition(cc.p(_midPointPos.x + _levelTitlePosTable[i].x,_midPointPos.y+_levelTitlePosTable[i].y))
		_bg:addChild(_itemSp,1)
		self.levelItemSp[i] = _itemSp

		local _textSp = cc.Sprite:create("res/image/plugin/meridian/meridianLevel_" .. i .. ".png")
		_textSp:setName("textSp")
		_textSp:setPosition(cc.p(_itemSp:getContentSize().width/2,0))
		_itemSp:addChild(_textSp)
	end
	self:refreshLevelItemState()
	self:refreshCircleProgress()

	--左边箭头
	local _arrowPosY = 190+200
    local _leftScrollBtn = XTHD.createButton({
            normalFile = "res/image/plugin/saint_beast/leftArrow_up.png",
            selectedFile = "res/image/plugin/saint_beast/leftArrow_down.png",
            touchScale = 0.95
        })
    self.leftScrollBtn = _leftScrollBtn
    _leftScrollBtn:setAnchorPoint(cc.p(0.5,0.5))
    _leftScrollBtn:setPosition(cc.p(100,_arrowPosY))
    _bg:addChild(_leftScrollBtn)
    _leftScrollBtn:setTouchEndedCallback(function()
    		self:exchangeMeridian(self.meridianIdx-1)
        end)
    --右边箭头
    local _rightScrollBtn = XTHD.createButton({
            normalFile = "res/image/plugin/saint_beast/rightArrow_up.png",
            selectedFile = "res/image/plugin/saint_beast/rightArrow_down.png",
            touchScale = 0.95
        })
    self.rightScrollBtn = _rightScrollBtn
    _rightScrollBtn:setAnchorPoint(cc.p(0.5,0.5))
    _rightScrollBtn:setPosition(cc.p(_bg:getContentSize().width - 100,_arrowPosY))
    _bg:addChild(_rightScrollBtn)

    _rightScrollBtn:setTouchEndedCallback(function()
            self:exchangeMeridian(self.meridianIdx+1)
        end)

    XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK,node=self,callback = function( event)
    	self:getDynamicItemData()
    	self:refreshMeridianEnergy()
		self:refreshDownMaterialItems()
	end})

end

function YingXiongMeridianLevelUpLayer:setLeftLayer()
	local _leftShadow = ccui.Scale9Sprite:create(cc.rect(0,0,416,10),"res/image/plugin/meridian/leftshadow_level.png")
	_leftShadow:setContentSize(cc.size(416,self:getContentSize().height))
	_leftShadow:setAnchorPoint(cc.p(0,0))
	_leftShadow:setPosition(cc.p(0,0))
	self:addChild(_leftShadow)

	local _letMidPosX = 205
	--背景
	local name_bg = ccui.Scale9Sprite:create("res/image/plugin/meridian/sxk.png")
	name_bg:setContentSize(340,400)
	name_bg:setAnchorPoint(0,1)
	name_bg:setPosition(cc.p(32,self:getContentSize().height/2+150))
	self:addChild(name_bg)
	---名称
	local _nameBg = ccui.Scale9Sprite:create("res/image/plugin/meridian/jmsxjc.png")
	-- _nameBg:setContentSize(cc.size(220,41))
	_nameBg:setPosition(cc.p(_letMidPosX,self:getContentSize().height/2+150))
	self:addChild(_nameBg)
	local _nameLabel = XTHDLabel:create(self:getMeridianTitleName(),24)
	self.meridianName = _nameLabel
	_nameLabel:setOpacity(0)
	_nameLabel:setColor(XTHD.resource.textColor.blue_text_1)
	_nameLabel:enableShadow(XTHD.resource.textColor.blue_text_1,cc.size(0.4,-0.4),0.4)
	_nameLabel:setPosition(cc.p(_nameBg:getContentSize().width/2,_nameBg:getContentSize().height/2))
	_nameBg:addChild(_nameLabel)

	local _textColor = cc.c4b(255,255,255,255)
	local _desclabel =XTHDLabel:create(LANGUAGE_HEROMERIDIAN.description,18)
	_desclabel:setColor(_textColor)
	_desclabel:setAnchorPoint(cc.p(0.5,0.5))
	_desclabel:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
	_desclabel:setPosition(cc.p(_letMidPosX,_nameBg:getBoundingBox().y-18))
	self:addChild(_desclabel)
	--左右
	local _propertyBg = cc.Sprite:createWithTexture(nil,cc.rect(0,0,400,240))
	_propertyBg:setOpacity(0)
	self.propertyBg = _propertyBg
	_propertyBg:setAnchorPoint(cc.p(0,1))
	_propertyBg:setPosition(cc.p(0,_desclabel:getBoundingBox().y))
	self:addChild(_propertyBg)


	self:setPropertyContent()
end
--noPhaseBackFlag如果为true，那么只更改名称
function YingXiongMeridianLevelUpLayer:setBgContent()
	local _levelValue = tonumber(self.curMeridianData.level or 1)
	local _phaseValue = tonumber(self.curMeridianData.phase or 0)
	local _type = nil
	-- print("levelValue: ".._levelValue)
	-- print("v: "..math.floor((_levelValue - 1) / 5))
	if _levelValue%5 == 0 and math.floor((_levelValue - 1) / 5) >= _phaseValue  then
		_type = "advance"
	elseif noPhaseBackFlag ~=nil and noPhaseBackFlag == true then
		return
	end
	-- self:setUpBgContent(_type)
	self:setDownBgContent(_type)
end

--下
function YingXiongMeridianLevelUpLayer:setDownBgContent(_type)
	if self.downBg==nil then
		return
	end
	self.meridianRateLabel = nil
	self.energyProgress = nil
	self.energyLabel = nil
	self.cursorSp = nil
	self.costZhenqiNum = nil
	self.downBg:removeAllChildren()
	self.countLabel = {}

	local _meridianLevel = self.curMeridianData.level or 1
	local _staticData = self.meridianLevelStaticData or {}

	local _btnPosY = 40
	if _meridianLevel>=tonumber(_staticData.maxlevel) then
		local _maxLabel = XTHDLabel:create(LANGUAGE_HEROMERIDIAN.maxLevel,24)
		_maxLabel:setColor(XTHD.resource.textColor.blue_text_1)
		_maxLabel:enableShadow(XTHD.resource.textColor.blue_text_1,cc.size(0.4,0.4),0.4)
		_maxLabel:setPosition(cc.p(self.downBg:getContentSize().width/2,self.downBg:getContentSize().height/2))
		self.downBg:addChild(_maxLabel)
	elseif _type and _type == "advance" then
		--开始进阶
		local _breakPhaseBtn = XTHD.createCommonButton({
				btnColor = "write_1",
				btnSize = cc.size(102,46),
				text = LANGUAGE_BTN_KEY.startAdvance,
				isScrollView = false,
			})
			_breakPhaseBtn:setScale(0.7)
		_breakPhaseBtn:setPosition(cc.p(self.downBg:getContentSize().width/2+10,_btnPosY))
		self.downBg:addChild(_breakPhaseBtn)
		_breakPhaseBtn:setTouchEndedCallback(function()
				self:breakPhaseBtnCallback()
			end)

		local _halfWidth = 40
		local _itemPosTable = SortPos:sortFromMiddle(cc.p(self.downBg:getContentSize().width/2+20,105) ,4,_halfWidth*2)
		for i=1,4 do
			local _itemNode = self:getUpPhaseMaterialItem(i)
            _itemNode:setScale(58/80)
            _itemNode:setPosition(_itemPosTable[i])
            self.downBg:addChild(_itemNode)
		end

		local _phaseCost = XTHDLabel:create(LANGUAGE_HEROMERIDIAN.advanceCost,18)
		_phaseCost:setColor(cc.c4b(255,255,255,255))
		_phaseCost:setAnchorPoint(cc.p(1,0.5))
		_phaseCost:setPosition(cc.p(_itemPosTable[1].x-7-_halfWidth,_itemPosTable[1].y))
		self.downBg:addChild(_phaseCost)

	else
		local _textColor = cc.c4b(255,255,255,255)
		local _ratePosY = self.downBg:getContentSize().height-20
		local _rateTitleLabel = XTHDLabel:create(LANGUAGE_HEROMERIDIAN.breakSuccessRate,20)
		_rateTitleLabel:setColor(_textColor)
		_rateTitleLabel:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
		_rateTitleLabel:setPosition(cc.p(self.downBg:getContentSize().width/2-28,_ratePosY))
		self.downBg:addChild(_rateTitleLabel)
		--在刷新真气占有量的时候刷新司马法成功率
		local _rateLabel = XTHDLabel:create("0%",20)
		self.meridianRateLabel = _rateLabel
		_rateLabel:setAnchorPoint(cc.p(0,0.5))
		_rateLabel:setColor(_textColor)
		_rateLabel:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
		_rateLabel:setPosition(cc.p(_rateTitleLabel:getBoundingBox().x+_rateTitleLabel:getBoundingBox().width+10,_ratePosY))
		self.downBg:addChild(_rateLabel)

		--mid  Bg
		local _energyProgressBg = cc.Sprite:create("res/image/plugin/meridian/meridianEnergy_bg.png")
		_energyProgressBg:setPosition(cc.p(self.downBg:getContentSize().width/2+20,_ratePosY-30))
		self.downBg:addChild(_energyProgressBg)

		local _energyProgress = cc.ProgressTimer:create(cc.Sprite:create("res/image/plugin/meridian/meridianEnergy_progress.png"))
		self.energyProgress = _energyProgress
	 	_energyProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	 	-- _circleProgress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	 	_energyProgress:setMidpoint(cc.p(0, 0.5))
	 	_energyProgress:setBarChangeRate(cc.p(1, 0))
	 	_energyProgress:setAnchorPoint(0.5,0.5)
	 	_energyProgress:setPercentage(0)
	 	_energyProgress:setPosition(cc.p(_energyProgressBg:getContentSize().width/2,_energyProgressBg:getContentSize().height/2))
	 	_energyProgressBg:addChild(_energyProgress)


	 	local _energytitle = XTHDLabel:create(LANGUAGE_HEROMERIDIAN.zhenqiValue,20)
	 	_energytitle:setColor(_textColor)
	 	_energytitle:setAnchorPoint(cc.p(1,0.5))
	 	_energytitle:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
	 	_energytitle:setPosition(cc.p(_energyProgressBg:getBoundingBox().x-3 ,_energyProgressBg:getPositionY() ))
	 	self.downBg:addChild(_energytitle)

	 	local _energylabel = XTHDLabel:create(0 .. "%",20)
	 	_energylabel:setColor(_textColor)
	 	self.energyLabel = _energylabel
	 	_energylabel:setAnchorPoint(cc.p(0,0.5))
	 	_energylabel:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
	 	_energylabel:setPosition(cc.p(_energyProgressBg:getBoundingBox().x+_energyProgressBg:getBoundingBox().width + 2,_energyProgressBg:getPositionY()))
		self.downBg:addChild(_energylabel)
		local _cursorSp = cc.Sprite:create("res/image/plugin/meridian/progressSp.png")
		_cursorSp:setPosition(cc.p(5,_energyProgress:getContentSize().height/2))
		_energyProgress:addChild(_cursorSp)
		self.cursorSp = _cursorSp

		self:refreshEnergyProgress()
		--开始领悟
		local _startBreakBtn = XTHD.createCommonButton({
				btnColor = "write_1",
				btnSize = cc.size(102,46),
				isScrollView = false,
				text = LANGUAGE_BTN_KEY.startBreakMeridian,
			})
			_startBreakBtn:setScale(0.7)
		_startBreakBtn:setPosition(cc.p(self.downBg:getContentSize().width/2+10,_btnPosY))
		self.downBg:addChild(_startBreakBtn)
		_startBreakBtn:setTouchEndedCallback(function()
				self:startBreakBtnCallback()
			end)
			--注入真气
		local _injectionBtn = XTHD.createCommonButton({
				btnColor = "write_1",
				btnSize = cc.size(102,46),
				isScrollView = false,
				text = LANGUAGE_BTN_KEY.injectZhenqi,
				needEnableWhenOut = true,
			})
			_injectionBtn:setScale(0.7)
		_injectionBtn:setPosition(cc.p(self.downBg:getContentSize().width/2-135,_btnPosY))
		self.downBg:addChild(_injectionBtn)
		self.costEnergyValue = 0
		self.isHasDialog = false
		local injectionFunc = function()
			_injectionBtn:stopActionByTag(1024+8)
			_injectionBtn:stopActionByTag(1024-8)
			local _energyValue = tonumber(self.costEnergyValue)
			if _energyValue==nil or _energyValue == 0 then
				-- XTHDTOAST("注入真气不能为0")
				return
			end
			self:injectionBtnCallback(_energyValue)
		end
		_injectionBtn:setTouchEndedCallback(function()
				if self.isHasDialog == false then
					injectionFunc()
				end
			end)
		local _costPosY = _injectionBtn:getBoundingBox().y+_injectionBtn:getBoundingBox().height+60
		local zhenqiSp = cc.Sprite:create(IMAGE_KEY_HEADER_ZHENQI)
		zhenqiSp:setAnchorPoint(cc.p(0,0.5))
		zhenqiSp:setPosition(cc.p(90,_costPosY))
		self.downBg:addChild(zhenqiSp)
		local _costNum = XTHDLabel:create(0,18)
		self.costZhenqiNum = _costNum
		_costNum:setAnchorPoint(cc.p(0,0.5))
		_costNum:setPosition(cc.p(zhenqiSp:getBoundingBox().x+zhenqiSp:getBoundingBox().width+4,_costPosY))
		self.downBg:addChild(_costNum)

		self:refreshCostZhenqiNum()

		_injectionBtn:setTouchBeganCallback(function()
				self.isHasDialog = false
				self.costEnergyValue = 0
				local _lastEnergy = tonumber(self.curMeridianData.allenergy - self.curMeridianData.energy)
				if _lastEnergy<=0 then
					XTHDTOAST(LANGUAGE_HEROMERIDIAN.toastMaxZhenqi)
					return
				end
				local _changeFunc = function()
					local perCost = self:getCostZhenqiNum()
					local _curEnergyProgress = tonumber(self.energyProgress:getPercentage())
					local _lastEnergyValue = _lastEnergy - self.costEnergyValue
					if _lastEnergyValue <= 0 then
						_injectionBtn:stopActionByTag(1024-8)
						return false
					end
					if _lastEnergyValue <= perCost then
						perCost = _lastEnergyValue
					end
					if tonumber(gameUser.getZhenqi()) < self.costEnergyValue + perCost then
						self.isHasDialog = true
						XTHD.setReplaceZhenqiDialog(self.costEnergyValue + perCost - tonumber(gameUser.getZhenqi()),self,function()
								self.costEnergyValue = self.costEnergyValue + perCost
								injectionFunc()
							end)
						_injectionBtn:stopActionByTag(1024-8)
						return false
					end
					self.costEnergyValue = self.costEnergyValue + perCost
					local _newPer = math.floor(tonumber(self.curMeridianData.energy + self.costEnergyValue)/self.curMeridianData.allenergy*100)

					local _showEnergyValue = tonumber(gameUser.getZhenqi()) -  self.costEnergyValue
					self:refreshEnergyProgress(_newPer)
					self:refreshMeridianEnergy(_showEnergyValue)
					return true
				end
				
				local _action = cc.CallFunc:create(function()
						_injectionBtn:stopActionByTag(1024+8)
						local _bool = _changeFunc()
						if _bool == nil or _bool == false then
							return
						end
						schedule(_injectionBtn,function()
							_changeFunc()
						end,0.4,1024-8)
					end)
				_action:setTag(1024+8)
				_injectionBtn:runAction(_action)
			end)
			--一键领悟
		local _onekeyBreakBtn = XTHD.createCommonButton({
				btnColor = "write_1",
				btnSize = cc.size(102,46),
				text = LANGUAGE_BTN_KEY.onekeyBreak,
				isScrollView = false,
			})
			_onekeyBreakBtn:setScale(0.7)
		_onekeyBreakBtn:setPosition(cc.p(self.downBg:getContentSize().width/2+135,_btnPosY))
		self.downBg:addChild(_onekeyBreakBtn)
		_onekeyBreakBtn:setTouchEndedCallback(function()
				local _needZhenqi = tonumber(self.curMeridianData.allenergy - self.curMeridianData.energy)-tonumber(gameUser.getZhenqi())
				if tonumber(gameUser.getZhenqi()) >=_needZhenqi then
					self:onekeyBreakBtnCallback()
					return
				end
				XTHD.setReplaceZhenqiDialog(_needZhenqi,self,function()
						self:onekeyBreakBtnCallback()
					end)
			end)
	end
end
--获取名称
function YingXiongMeridianLevelUpLayer:getMeridianTitleName()
	local _veinData = self.curMeridianData
	local _verType = tonumber(_veinData.veinsType)
	local _meridianNameStr = LANGUAGE_KEY_HEROMERIDIANVEIN[tonumber(_verType)] or ""
	local _advanceValue =_veinData.phase
	local _advanceNameStr =LANGUAGE_KEY_HEROMERIDIANRANK[_advanceValue] or ""
	local _levelValue = tonumber(_veinData.level-1)%5+1
	local _levelStr = LANGUAGE_KEY_HEROMERIDIANLEVEL[_levelValue]
	local _returnName = _meridianNameStr .. "." .. _advanceNameStr .. _levelStr
	return _returnName
end

function YingXiongMeridianLevelUpLayer:getCostZhenqiNum()
	local _num = math.ceil(self.curMeridianData.allenergy * 0.1)
	return _num
end

function YingXiongMeridianLevelUpLayer:refreshCostZhenqiNum()
	if self.costZhenqiNum ==nil then
		return
	end
	self.costZhenqiNum:setString(self:getCostZhenqiNum())
end

function YingXiongMeridianLevelUpLayer:getUpPhaseMaterialItem(_idx)
	if _idx ==nil or tonumber(_idx)==nil then
		return
	end

	local _costData = string.split(self.meridianRankStaticData[tonumber(self.curMeridianData.phase + 1)]["need" .. _idx],"#")
	local _itemType = tonumber(_costData[1] or 4)
	local _itemid = tonumber(_costData[2])
	local _itemNum = tonumber(_costData[3] or 0)
	local _itemidData_ = self.iteminfoData[tostring(_itemid)] or nil


	local _itemSpr = nil
	self.countLabel[tostring(i)] = nil
    --背包中有这个道具
	if _itemType~=XTHD.resource.type.item or (self.dynamicItemData[tostring(_itemid)]~=nil and next(self.dynamicItemData[tostring(_itemid)])~=nil) then
		_itemSpr = ItemNode:createWithParams({
	        dbId = nil,
	        itemId = _itemid,
	        _type_ = _itemType,
	        count = 0,
	        touchShowTip = false,
            endCallback = function()
                --掉落途径
                if _itemType==XTHD.resource.type.item then
                	self:gotoDropWay(_itemid)
                end
            end
	    })
	    local _count = 0
	    local _hasNumStr_ = ""
	    if _itemType~=XTHD.resource.type.item then
	    	_count = tonumber(gameUser.getFeicui())
	    	_hasNumStr_ = ""
	    else
	    	_count = self.dynamicItemData[tostring(_itemid)].count
	    	_hasNumStr_ = getHugeNumberWithLongNumber(_count,1000) .. "/"
	    end
        
        local _needNum_ = getHugeNumberWithLongNumber(_itemNum,1000)
	    self.countLabel[tostring(_idx)] = getCommonWhiteBMFontLabel(_hasNumStr_ .. _needNum_)
	    self.countLabel[tostring(_idx)]:setAnchorPoint(cc.p(1,0))
	    self.countLabel[tostring(_idx)]:setPosition(cc.p(_itemSpr:getContentSize().width-5,-7))
        self.countLabel[tostring(_idx)]:setColor(cc.c4b(255,255,255,255))
	    _itemSpr:addChild(self.countLabel[tostring(_idx)])
	    if tonumber(_itemNum) > tonumber(_count) then
	    	self.countLabel[tostring(_idx)]:setColor(cc.c4b(255,0,0,255))
	    end
	else   --背包中没有这个道具
		local _grayPath = XTHD.resource.getItemImgById(_itemidData_["resourceid"])
		_itemSpr = cc.Sprite:create(_grayPath)
        XTHD.setGray(_itemSpr,true)
        
		local _bgSpr = cc.Sprite:create(XTHD.resource.getQualityItemBgPath(1))
        _bgSpr:setAnchorPoint(cc.p(0.5,0.5))
        _bgSpr:setPosition(cc.p(_itemSpr:getContentSize().width/2,_itemSpr:getContentSize().height/2))
        _itemSpr:addChild(_bgSpr)
        local _needNum_ = getHugeNumberWithLongNumber(_itemNum,1000)
        self.countLabel[tostring(_idx)] = getCommonWhiteBMFontLabel(0 .. "/" .. _needNum_)
        self.countLabel[tostring(_idx)]:setAnchorPoint(cc.p(1,0))
        self.countLabel[tostring(_idx)]:setPosition(cc.p(_bgSpr:getContentSize().width-5,-7))
        self.countLabel[tostring(_idx)]:setColor(cc.c4b(255,0,0,255))
        _bgSpr:addChild(self.countLabel[tostring(_idx)])

        local _normalSpr = cc.Sprite:create("res/image/plugin/hero/label_add_green.png")
		local _selectSpr = cc.Sprite:create("res/image/plugin/hero/label_add_green.png")
		_selectSpr:setScale(0.95)
		local _noitemButton = XTHD.createButton({
			normalNode = _normalSpr
			,selectedNode = _selectSpr
            ,touchSize = cc.size(_itemSpr:getBoundingBox().width,_itemSpr:getBoundingBox().height)
			})
		_noitemButton:setTouchEndedCallback(function()
				--掉落途径
                self:gotoDropWay(_itemid)
			end)
		_noitemButton:setAnchorPoint(cc.p(0.5,0.5))
		_noitemButton:setPosition(cc.p(_itemSpr:getContentSize().width/2,_itemSpr:getContentSize().height/2))
		_itemSpr:addChild(_noitemButton)
	end
	return _itemSpr
end

function YingXiongMeridianLevelUpLayer:setPropertyContent()
	if self.propertyBg ==nil then
		return
	end
	self.propertyBg:removeAllChildren()
	local _titlePosY = self.propertyBg:getContentSize().height -27
	local _letMidPosX = 210
	local _leftPosX = _letMidPosX-118
	local _leftlabel = XTHDLabel:create(LANGUAGE_HEROMERIDIAN.currentAdd,20)
	_leftlabel:setColor(XTHD.resource.textColor.blue_text_1)
	_leftlabel:enableShadow(XTHD.resource.textColor.blue_text_1,cc.size(0.4,-0.4),0.4)
	_leftlabel:setPosition(cc.p(_leftPosX,_titlePosY))
	self.propertyBg:addChild(_leftlabel)

	local _leftBg = cc.Sprite:createWithTexture(nil, cc.rect(0,0,150,200))
	self.leftBg = _leftBg
	_leftBg:setOpacity(0)
	_leftBg:setAnchorPoint(cc.p(0.5,1))
	_leftBg:setPosition(cc.p(_leftPosX,_leftlabel:getBoundingBox().y-5))
	self.propertyBg:addChild(_leftBg)

	local _meridianLevel = self.curMeridianData.level or 1
	local _staticData = self.meridianLevelStaticData or {}
	if _meridianLevel>=tonumber(_staticData.maxlevel) then
		_leftlabel:setPositionX(_letMidPosX)
		_leftBg:setPositionX(_letMidPosX)
		self:setLeftPropertyContent()
	else
		local _arrowSp = cc.Sprite:create("res/image/plugin/meridian/property_arrow.png")
		_arrowSp:setPosition(cc.p(_letMidPosX - 15,_titlePosY-90))
		self.propertyBg:addChild(_arrowSp)

		local _rightPosX = _letMidPosX+80
		local _rightlabel = XTHDLabel:create(LANGUAGE_HEROMERIDIAN.breakMeridianAdd,20)
		_rightlabel:setColor(XTHD.resource.textColor.blue_text_1)
		_rightlabel:enableShadow(XTHD.resource.textColor.blue_text_1,cc.size(0.4,-0.4),0.4)
		_rightlabel:setPosition(cc.p(_rightPosX,_titlePosY))
		self.propertyBg:addChild(_rightlabel)
		local _rightBg = cc.Sprite:createWithTexture(nil, cc.rect(0,0,150,200))
		self.rightBg = _rightBg
		_rightBg:setOpacity(0)
		_rightBg:setAnchorPoint(cc.p(0.5,1))
		_rightBg:setPosition(cc.p(_rightPosX,_rightlabel:getBoundingBox().y-5))
		self.propertyBg:addChild(_rightBg)

		self:setLeftPropertyContent()
		self:setRightPropertyContent()
	end

end

function YingXiongMeridianLevelUpLayer:setLeftPropertyContent()
	if self.leftBg == nil then
		return
	end
	self.leftBg:removeAllChildren()
	local _propertyIdx = 1
	local _textColor = cc.c4b(255,255,255,255)
	for i=1,#self.propertyKey do
		local _key = self.propertyKey[i]
		if self.oldAdditionData[_key] ~= nil and tonumber(self.oldAdditionData[_key])>0 then
			local _keyNum = self.propertyName[i]
			local _posY = self.leftBg:getContentSize().height + 14 -_propertyIdx*33
			local _nameStr = LANGUAGE_KEY_SIMPLE_ATTRIBUTESNAME(_keyNum)
			local _valueStr = "+" .. self.oldAdditionData[_key].."%"--XTHD.resource.addPercent(_keyNum,self.oldAdditionData[_key])
			local _nameLabel = XTHDLabel:create(_nameStr .. _valueStr,20)
			_nameLabel:setColor(_textColor)
			_nameLabel:setAnchorPoint(cc.p(0,0.5))
			_nameLabel:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
			_nameLabel:setPosition(cc.p(self.leftBg:getContentSize().width/2-43,_posY))
			self.leftBg:addChild(_nameLabel)
			_propertyIdx = _propertyIdx + 1
		end
	end
end

function YingXiongMeridianLevelUpLayer:setRightPropertyContent()
	if self.rightBg == nil then
		return
	end
	self.rightBg:removeAllChildren()
	local _propertyIdx = 1
	local _textColor = XTHD.resource.textColor.green_text_1
	for i=1,#self.propertyKey do
		local _key = self.propertyKey[i]
		if self.newAdditionData[_key] ~= nil and tonumber(self.newAdditionData[_key])>0 then
			local _keyNum = self.propertyName[i]
			local _posY = self.rightBg:getContentSize().height + 14 -_propertyIdx*33
			local _nameStr = LANGUAGE_KEY_SIMPLE_ATTRIBUTESNAME(_keyNum)
			local _valueStr = "+" .. self.newAdditionData[_key].."%"--XTHD.resource.addPercent(_keyNum,self.newAdditionData[_key])
			local _nameLabel = XTHDLabel:create(_nameStr .. _valueStr,20)
			_nameLabel:setColor(_textColor)
			_nameLabel:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
			_nameLabel:setAnchorPoint(cc.p(0,0.5))
			_nameLabel:setPosition(cc.p(self.rightBg:getContentSize().width/2-50,_posY))
			self.rightBg:addChild(_nameLabel)
			_propertyIdx = _propertyIdx + 1
		end
	end
end

--跳转界面
function YingXiongMeridianLevelUpLayer:gotoDropWay(_itemid)
    local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
    local _layerid = 41
    popLayer = popLayer:create(_itemid)
    popLayer:setName("dropPop")
    self:addChild(popLayer)
end

-----------------------CallBack$Began-------------------------
function YingXiongMeridianLevelUpLayer:addZhenqiBtnCallback()
	replaceLayer({fNode = self,id = 59})
end

function YingXiongMeridianLevelUpLayer:injectionBtnCallback(_energyValue)
	self:httpToInjectionBtnBtnCallback(_energyValue)
end
--注入真气
function YingXiongMeridianLevelUpLayer:httpToInjectionBtnBtnCallback(_energyValue)
	ClientHttp:httpCommon( "veinsAddenergy?", self,{petId = self.heroid,veinsType = self.meridianIdx,energy = _energyValue}, function(data)
			if data.veinsJson~=nil and next(data.veinsJson)~=nil then
				DBTableHero.updateHeroPetVeinsData(data.veinsJson,self.heroid)
			end
			local property = data.charProperty
		    if property then
		        for i=1,#property do
		            local _tab = string.split(property[i],',')
		            gameUser.updateDataById(_tab[1],_tab[2])
		        end
		    end
		    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
		    --界面更改
		    --当前经脉数据
		    self:setCurMeridianData()
		    --刷新拥有的真气数量
		    self:refreshMeridianEnergy()
		    --中间球体
		    self:refreshEnergyProgress()
		    XTHDTOAST(LANGUAGE_HEROMERIDIAN.toastInjectZhenqi)
		end,function()
			self:refreshMeridianEnergy()
		    --中间球体
		    self:refreshEnergyProgress()
		end)
end

function YingXiongMeridianLevelUpLayer:startBreakBtnCallback()
	if self.curMeridianData.allenergy and self.curMeridianData.energy and tonumber(self.curMeridianData.allenergy)<=tonumber(self.curMeridianData.energy) then
		self:httpToStartBreakBtnCallback()
		return
	end
	local _lastEnergy = tonumber(self.curMeridianData.allenergy)-tonumber(self.curMeridianData.energy)
	if _lastEnergy>self.curMeridianData.energy then
		XTHDTOAST(LANGUAGE_HEROMERIDIAN.atleastInjectZhenqi)
		return
	end
	local confirmDialog = XTHDConfirmDialog:createWithParams({
		msg = LANGUAGE_HEROMERIDIAN.breakMeridianPossible,
		rightCallback =function()
			self:httpToStartBreakBtnCallback()
		end
		})
	self:addChild(confirmDialog)
end
--领悟
function YingXiongMeridianLevelUpLayer:httpToStartBreakBtnCallback()
	local _oldHeroData = DBTableHero.getData(gameUser.getUserId(), {["heroid"] = self.heroid})
	local _oldPower = _oldHeroData.power or 0
	local _newPower = _oldPower
	ClientHttp:httpCommon( "veinsUpLevel?", self,{
		petId = self.heroid,veinsType = self.meridianIdx}, function(data)
			
			if data.veinsJson~=nil and next(data.veinsJson)~=nil then
				DBTableHero.updateHeroPetVeinsData(data.veinsJson,self.heroid)
			end
			if next(data.petProperty)~=nil then
				for i=1,#data.petProperty do
			        local _tab = string.split(data.petProperty[i],',')
			        DBTableHero.updateDataByPropId( gameUser.getUserId(), _tab[1],_tab[2],self.heroid);
			        if tonumber(_tab[1]) ==407 then
		            	_newPower = tonumber(_tab[2])
		            end
			    end	
			end
			XTHD._createFightLabelToast({
			        oldFightValue = _oldPower,
			        newFightValue = _newPower
			    })

			
		    --界面更改
		    --当前经脉数据
		    self:setCurMeridianData()
		    local _delayTime = 0
		    if data.upResult and tonumber(data.upResult)==1 then
		    	--成功
		    	XTHDTOAST(LANGUAGE_HEROMERIDIAN.toastBreakSuccess)
		    	self:setUpLevelAnimatoin()
		    	_delayTime = 0.4
		    else
		    	XTHDTOAST(LANGUAGE_HEROMERIDIAN.toastBreakFailure)
		    end
		    --加成数据修改
		    self:setPropertyAddition()
		    --刷新名称
		    self:refreshMeridianName()
		    self:setBgContent(true)
		    --刷新拥有的真气数量
		    self:refreshMeridianEnergy()
		    --左右
		    self:setPropertyContent()
		    --中间球体
		    self:refreshEnergyProgress()
		    self:refreshCostZhenqiNum()
		    --中间外圈
		    self:refreshCircleProgress(true)
		    performWithDelay(self,function()
		    		self:refreshLevelItemState()
		    	end,_delayTime)
		    
		    
		end)
end

function YingXiongMeridianLevelUpLayer:onekeyBreakBtnCallback()
	local _oldHeroData = DBTableHero.getData(gameUser.getUserId(), {["heroid"] = self.heroid})
	local _oldPower = _oldHeroData.power or 0
	local _newPower = _oldPower
	ClientHttp:httpCommon( "onceVeinsUpLevel?", self,{
		petId = self.heroid,veinsType = self.meridianIdx}, function(data)
			-- dump(data,"777777777777777777777777")
	    	XTHDTOAST(LANGUAGE_HEROMERIDIAN.toastOnekeybreakSuccess)
	    	
			if data.veinsJson~=nil and next(data.veinsJson)~=nil then
				DBTableHero.updateHeroPetVeinsData(data.veinsJson,self.heroid)
			end
			local property = data.charProperty
		    if property then
		        for i=1,#property do
		            local _tab = string.split(property[i],',')
		            gameUser.updateDataById(_tab[1],_tab[2])
		            
		        end
		    end
			for i=1,#data.petProperty do
		        local _tab = string.split(data.petProperty[i],',')
		        DBTableHero.updateDataByPropId( gameUser.getUserId(), _tab[1],_tab[2],self.heroid);
		        if tonumber(_tab[1]) ==407 then
	            	_newPower = tonumber(_tab[2])
	            end
		    end
		    
		    print("_newPower>>>" .. _newPower)
		    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
		    XTHD._createFightLabelToast({
			        oldFightValue = _oldPower,
			        newFightValue = _newPower
			    })
		    --界面更改
		    --当前经脉数据
		    self:setCurMeridianData()
		    self:setUpLevelAnimatoin()
		    --加成数据修改
		    self:setPropertyAddition()
		    --刷新名称
		    self:refreshMeridianName()
		    self:setBgContent(true)
		    --刷新拥有的真气数量
		    self:refreshMeridianEnergy()
		    --左右
		    self:setPropertyContent()
		    --中间球体
		    self:refreshEnergyProgress()
		    --中间外圈
		    self:refreshCircleProgress(true)
		    performWithDelay(self,function()
		    		self:refreshLevelItemState()
		    	end,0.3)
		end)
end

-- 开始进阶
function YingXiongMeridianLevelUpLayer:breakPhaseBtnCallback()
	local _oldHeroData = DBTableHero.getData(gameUser.getUserId(), {["heroid"] = self.heroid})
	local _oldPower = _oldHeroData.power or 0
	local _newPower = _oldPower
	ClientHttp:httpCommon( "veinsUpPhase?", self,{
		petId = self.heroid,veinsType = self.meridianIdx}, function(data)
			if data.veinsJson~=nil and next(data.veinsJson)~=nil then
				DBTableHero.updateHeroPetVeinsData(data.veinsJson,self.heroid)
			end
			for i=1,#data.petProperty do
		        local _tab = string.split(data.petProperty[i],',')
		        DBTableHero.updateDataByPropId( gameUser.getUserId(), _tab[1],_tab[2],self.heroid);
		        if tonumber(_tab[1]) ==407 then
	            	_newPower = tonumber(_tab[2])
	            end
		    end
		    for i=1,#data["bagItems"] do
		        local _dbid = data.bagItems[i].dbId
		        if data.bagItems[i].count and tonumber(data.bagItems[i].count)>0 then
		            DBTableItem.updateCount(gameUser.getUserId(),data.bagItems[i],_dbid)
		        else
		            DBTableItem.deleteData(gameUser.getUserId(),_dbid)
		        end
		    end
		    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
		    XTHD._createFightLabelToast({
			        oldFightValue = _oldPower,
			        newFightValue = _newPower
			    })
		    self:getDynamicItemData()
		    self:setUpPhaseAnimation()
		    --界面更改
		    --当前经脉数据
		    self:setCurMeridianData()
		    --加成数据修改
		    self:setPropertyAddition()
		    --上下
		    self:setBgContent()
		    --左右
		    self:setPropertyContent()
		    --中间球体
		    self:refreshEnergyProgress()
		    --中间外圈
		    performWithDelay(self,function()
				    self:refreshCircleProgress(true)
		    		self:refreshLevelItemState()
		    	end,1)
		end)
end

-----------------------CallBack$Ended-------------------------

function YingXiongMeridianLevelUpLayer:refreshMeridianName()
	if self.meridianName == nil then
		return
	end
	self.meridianName:setString(self:getMeridianTitleName())
end

function YingXiongMeridianLevelUpLayer:refreshMeridianEnergy(_value)
	if self.meridianEnergy == nil then
		return
	end
	local _zhengqiValue = _value or gameUser.getZhenqi()
	self.meridianEnergy:setString(getHugeNumberWithLongNumber(_zhengqiValue,1000000))
end

-- 刷新等级以及书上的特效
function YingXiongMeridianLevelUpLayer:refreshLevelItemState()
	local _curPhase = self.curMeridianData.phase
	-- dump(self.curMeridianData)
	local _curLevel = self.curMeridianData["level"] - _curPhase*5
	if _curLevel<1 then
		_curLevel = 0
	elseif _curLevel>5 then
		_curLevel = 5
	end
	
	for i=1,5 do
		if self.levelItemSp[i]~=nil then
			local _textSpGrayFlag = false
			local _levelItemSp = self.levelItemSp[i]
			if _curLevel<i then
				_levelItemSp:setEnable(false)
				_textSpGrayFlag = true
				if _levelItemSp:getChildByName("selectedState") then
					_levelItemSp:removeChildByName("selectedState")
				end
			else
				_levelItemSp:setEnable(true)
				if not _levelItemSp:getChildByName("selectedState") then
					local _selectedSpine = self:getUpLevelMeridianSpine()
					_selectedSpine:setAnimation(0,"idle",true)
					_selectedSpine:setName("selectedState")
					_selectedSpine:setPosition(cc.p(_levelItemSp:getContentSize().width/2,_levelItemSp:getContentSize().height/2))
					_levelItemSp:addChild(_selectedSpine)
				end
			end
			if self.levelItemSp[i]:getChildByName("textSp") then
				XTHD.setGray(self.levelItemSp[i]:getChildByName("textSp"),_textSpGrayFlag)
			end
		end
	end
end

function YingXiongMeridianLevelUpLayer:refreshRateLabel(_value)
	if self.meridianRateLabel ==nil or _value ==nil then
		return
	end
	self.meridianRateLabel:setString(_value .. "%")
end

--energyValue
function YingXiongMeridianLevelUpLayer:refreshEnergyProgress(_newPercentage)
	if self.energyProgress ==nil or self.cursorSp ==nil then
		return
	end
	--注入真气量
	--总真气量 = 基础真气*当前等级
	
	local _newper =tonumber(_newPercentage)
	if _newper==nil then
		local _allenergy = self.curMeridianData.allenergy
		_newper = math.floor(tonumber(self.curMeridianData.energy)/_allenergy*100)
	end
	local _curPer = tonumber(self.energyProgress:getPercentage())
	self.energyProgress:stopAllActions()
	if _newper==0 or _curPer == 100 then
		self.cursorSp:setVisible(false)
	else
		self.cursorSp:setVisible(true)
	end
	if self.cursorSp:getChildByName("cursorSpine") then
		self.cursorSp:removeChildByName("cursorSpine")
	end
	self.cursorSp:stopAllActions()
	if _newper>_curPer then
		local _actiontime = (_newper - _curPer)/100
		local _moveTime = 0.3
		self.cursorSp:setPositionX(self.energyProgress:getContentSize().width/100*_curPer)
		self.energyProgress:runAction(cc.ProgressTo:create(_moveTime,_newper))
		local _cursorSpine = self:getZhenqiBarSpine()
		_cursorSpine:setName("cursorSpine")
		_cursorSpine:setPosition(cc.p(self.cursorSp:getContentSize().width/2-22,self.cursorSp:getContentSize().height/2))
		self.cursorSp:addChild(_cursorSpine)
		performWithDelay(_cursorSpine, function()
			_cursorSpine:removeFromParent()
			end,_moveTime)
		self.cursorSp:runAction(cc.Sequence:create(
			cc.MoveTo:create(_moveTime,cc.p(self.energyProgress:getContentSize().width/100*_newper,self.energyProgress:getContentSize().height/2))
			,cc.CallFunc:create(function()
					if _newper == 100 then
						self.cursorSp:setVisible(false)
					end
				end)))
	else
		self.energyProgress:setPercentage(_newper)
	end

	if self.energyLabel == nil then
		return
	end
	self.energyLabel:setString(_newper .. "%")
	--司马法成功率
	local _rateValue = math.floor((_newper - tonumber(self.meridianLevelStaticData.chenggonglv or 0))*tonumber(self.meridianLevelStaticData.chenggonglv2 or 0))
	_rateValue = _rateValue >0 and _rateValue or 0
	self:refreshRateLabel(_rateValue)
end
--circleValue
function YingXiongMeridianLevelUpLayer:refreshCircleProgress(_flag)
	if self.circleProgress ==nil then
		return
	end
	local _newCircle = tonumber(self.curMeridianData.level-1)%5 * 20
	local _curPer = tonumber(self.circleProgress:getPercentage())
	self.circleProgress:stopAllActions()
	-- _newCircle = 100
	if _newCircle>_curPer and _flag==true then
		local _actiontime = (_newCircle - _curPer)/50
		local _oldCircle = _newCircle - 20
		if _oldCircle >0 then
			self.circleProgress:setPercentage(_oldCircle)
		end
		self.circleProgress:runAction(cc.ProgressTo:create(_actiontime,_newCircle))
	else
		self.circleProgress:setPercentage(_newCircle)
	end
end

function YingXiongMeridianLevelUpLayer:refreshDownMaterialItems()
	local _levelValue = tonumber(self.curMeridianData.level or 1)
	local _type = nil
	if _levelValue%5 == 0 then
		_type = "advance"
	end
	self:setDownBgContent(_type)
end
-----------------------animation---------------------------
--进阶特效
function YingXiongMeridianLevelUpLayer:setUpPhaseAnimation()
	-- for i=1,#self.levelItemSp do
	-- 	local _itemSp = self.levelItemSp[i]
		
	-- end
	if self.bg==nil then
		return
	end
	if self.bg:getChildByName("phaseSpine") then
		self.bg:removeChildByName("phaseSpine")
	end
	local _spine = self:getUpPhaseSpine()
	_spine:setName("phaseSpine")
	_spine:setPosition(self.midPointPos)
	self.bg:addChild(_spine,1)
	performWithDelay(_spine,function()
			_spine:removeFromParent()
		end,2)
end
--司马法特效
function YingXiongMeridianLevelUpLayer:setUpLevelAnimatoin()
	local _idx = tonumber(self.curMeridianData["level"]-1)%5+1
	if self.levelItemSp[_idx] == nil then
		return
	end
	local _itemSp = self.levelItemSp[_idx]
	if self.bg:getChildByName("circleSpine") then
		self.bg:removeChildByName("circleSpine")
	end
	
	local _circleSpine = self:getUpLevelCircleSpine()
	_circleSpine:setName("circleSpine")
	_circleSpine:setAnchorPoint(cc.p(0.5,1))
	_circleSpine:setPosition(self.midPointPos)
	print("_idx>>>" .. _idx)
	_circleSpine:setRotation(70*_idx-210)
	self.bg:addChild(_circleSpine,0)
	performWithDelay(_circleSpine,function()
			_circleSpine:removeFromParent()
		end,0.666)
	_itemSp:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(function()
			if _itemSp:getChildByName("selectedState") then
				_itemSp:removeChildByName("selectedState")
			end
			local _levelSpine = self:getUpLevelMeridianSpine()
			_levelSpine:setAnimation(0,"atk",false)
			_levelSpine:addAnimation(0,"idle",true)
			_levelSpine:setName("selectedState")
			_levelSpine:setPosition(cc.p(_itemSp:getContentSize().width/2,_itemSp:getContentSize().height/2))
			_itemSp:addChild(_levelSpine)
		end)))

end
-----------------------animation-end--------------------------
-----------------------Spine---------------------------
--注入真气进度条的特效
function YingXiongMeridianLevelUpLayer:getZhenqiBarSpine()
	local _spine = XTHD.createMeridianSpine()
	_spine:setAnimation(0,"lza",true)
	return _spine
end
--司马法时圆圈进度条的特效
function YingXiongMeridianLevelUpLayer:getUpLevelCircleSpine()
	local _spine = XTHD.createMeridianSpine()
	_spine:setAnimation(0,"cm",true)
	return _spine
end
--司马法时经脉的特效
function YingXiongMeridianLevelUpLayer:getUpLevelMeridianSpine()
	local _spine = sp.SkeletonAnimation:create( "res/spine/effect/meridian_wakeupEffect/xiaoqiu.json", "res/spine/effect/meridian_wakeupEffect/xiaoqiu.atlas",1.0);
	return _spine
end
--进阶的特效
function YingXiongMeridianLevelUpLayer:getUpPhaseSpine()
	-- local _spine = sp.SkeletonAnimation:create( "res/spine/effect/meridian_wakeupEffect/baozha.json", "res/spine/effect/meridian_wakeupEffect/baozha.atlas",1.0);
	-- _spine:setAnimation(0,"atk",false)
	--新特效
	local _spine = sp.SkeletonAnimation:create( "res/spine/effect/meridian_wakeupEffect/xinfajinjie_down.json", "res/spine/effect/meridian_wakeupEffect/xinfajinjie_down.atlas",1.0);
	_spine:setAnimation(0,"xinfajinjie_down",false)
	local _spine2 = sp.SkeletonAnimation:create( "res/spine/effect/meridian_wakeupEffect/xinfajinjie_up.json", "res/spine/effect/meridian_wakeupEffect/xinfajinjie_up.atlas",1.0);
	_spine2:setAnimation(0,"xinfajinjie_up",false)
	_spine:addChild(_spine2)


	return _spine
end

-----------------------Spine-end--------------------------

--属性计算方法。每升一级提升固定属性。每升一阶提升固定属性。20级，共升了19级，同时升了4阶。
function YingXiongMeridianLevelUpLayer:setPropertyAddition()
	self.oldAdditionData = {}
	local _meridianIdx = self.meridianIdx
	local _meridianLevel = self.curMeridianData.level or 0
	local _phaseValue = self.curMeridianData.phase
	for i=1,#self.propertyKey do
		local _key =self.propertyKey[i]
		self.oldAdditionData[_key] = tonumber(self.meridianLevelStaticData[_key] or 0)*_meridianLevel
		for j=1,_phaseValue do
			self.oldAdditionData[_key] = self.oldAdditionData[_key] + tonumber(self.meridianRankStaticData[tonumber(j)][_key] or 0)
		end
	end

	self:setNewPropertyAddition()
end

function YingXiongMeridianLevelUpLayer:setNewPropertyAddition()
	self.newAdditionData = {}
	local _meridianIdx = self.meridianIdx
	local _meridianLevel = self.curMeridianData.level or 1
	local _addData = {}
	-- if _meridianLevel%5==0 then
	-- 	_addData = self.meridianRankStaticData[math.floor(_meridianLevel/5)] or {}
	-- end
	-- _addData = self.meridianRankStaticData[self.curMeridianData.phase] or {}
	-- for i=1,#self.propertyKey do
	-- 	local _key =self.propertyKey[i]
	-- 	local addRate = (self.curMeridianData.level + 1)/self.curMeridianData.level
	-- 	self.newAdditionData[_key] = (self.oldAdditionData[_key]*addRate or 0) --+ (_addData[_key] or 0)
	-- end
	local _phaseValue
	if self.curMeridianData.level%5 == 0 and tonumber(self.curMeridianData.curPhase - 1) ~= tonumber(self.curMeridianData.phase) then
		_phaseValue = self.curMeridianData.phase + 1
		_meridianLevel = self.curMeridianData.level - 1
	else
		_phaseValue = self.curMeridianData.phase
		_meridianLevel = self.curMeridianData.level
	end

	for i=1,#self.propertyKey do
		local _key =self.propertyKey[i]
		self.newAdditionData[_key] = tonumber(self.meridianLevelStaticData[_key] or 0)*(_meridianLevel + 1)
		for j=1,_phaseValue do
			self.newAdditionData[_key] = self.newAdditionData[_key] + tonumber(self.meridianRankStaticData[tonumber(j)][_key] or 0)
		end
	end
end

function YingXiongMeridianLevelUpLayer:setCurMeridianData()
	local _idx= self.meridianIdx
	self.curMeridianData = DBTableHero.getPerVeinsDataByVeinstype(self.heroid,_idx)or{}
	self.curMeridianData.allenergy = tonumber(self.meridianLevelStaticData.cost)*tonumber(self.curMeridianData.level)
	self.curMeridianData.curPhase = XTHD.getMeridianCurPhase(self.curMeridianData.level)
end

function YingXiongMeridianLevelUpLayer:setStaticData()
	self.levelStaticData = {}
	self.rankStaticData = {}
	self.levelStaticData = gameData.getDataFromCSV("BingshuLvUp")
	local _table2 = gameData.getDataFromCSV("BingshuAdvanced")
	for i=1,#_table2 do
		if self.rankStaticData[tonumber(_table2[i].jingmai)]==nil then
			self.rankStaticData[tonumber(_table2[i].jingmai)] = {}
		end
		local n = tonumber(_table2[i].jingmai)
		self.rankStaticData[n][#self.rankStaticData[n] + 1] = _table2[i]
	end
end
--self.meridianIdx
function YingXiongMeridianLevelUpLayer:setCurStaticData(_meridianIdx)
	if _meridianIdx ==nil then
		return
	end
	self.meridianIdx = _meridianIdx

	self.meridianLevelStaticData = {}
	self.meridianRankStaticData = {}
	self.meridianLevelStaticData = self.levelStaticData[tonumber(_meridianIdx)] or {}
	self.meridianRankStaticData = self.rankStaticData[tonumber(_meridianIdx)] or {}
	
	table.sort(self.meridianRankStaticData,function(data1,data2)
			return tonumber(data1.id)<tonumber(data2.id)
		end)
end
--heroid
function YingXiongMeridianLevelUpLayer:getDynamicMeridianData()
	self.dynamicMeridianData = {}
	self.dynamicMeridianData = DBTableHero.getPerVeinsData(self.heroid)
end

function YingXiongMeridianLevelUpLayer:getDynamicItemData()
	self.dynamicItemData = {}
    local _table = DBTableItem:getDataByID()
    for k,v in pairs(_table) do
        self.dynamicItemData[tostring(v.itemid)] = v
    end
end
function YingXiongMeridianLevelUpLayer:getStaticItemInfoData()
	self.iteminfoData = {}
	self.iteminfoData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet")
end

function YingXiongMeridianLevelUpLayer:exchangeMeridian(_idx)
	if _idx == nil or tonumber(_idx) == nil then
		return
	end
	self:setScrollBtnClick(false)

	local _meridianIdx = (_idx+8-1)%8+1
	local _table = DBTableHero.getPerVeinsDataByVeinstype(self.heroid,_meridianIdx) or {}
	if next(_table) ==nil then
		XTHDTOAST(LANGUAGE_MERIDIAN_EXCHANGELIMIT(_meridianIdx))
		self:setScrollBtnClick(true)
		return
	end

	self:setCurStaticData(_meridianIdx)
	self:setCurMeridianData()
	self:setPropertyAddition()
	self:setBgContent()
	self:refreshMeridianName()
	self:refreshEnergyProgress()
	self:refreshCircleProgress()
	self:refreshLevelItemState()
	self:setPropertyContent()
	self:setScrollBtnClick(true)
end

function YingXiongMeridianLevelUpLayer:setScrollBtnClick(flag)
	local _flag = flag or true
	if self.leftScrollBtn ~= nil then
		self.leftScrollBtn:setClickable(_flag)
	end
	if self.rightScrollBtn ~= nil then
		self.rightScrollBtn:setClickable(_flag)
	end
end


function YingXiongMeridianLevelUpLayer:create(_meridianIdx,_heroid)
	local _layer = self.new(_meridianIdx,_heroid)
	return _layer
end

return YingXiongMeridianLevelUpLayer