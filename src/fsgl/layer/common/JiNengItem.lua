--Created By Liuluyang 2015年04月17日
JiNengItem = class("JiNengItem",function (_skill)
	local _imgPath = "res/image/quality/item_6.png"
	local bg = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create(_imgPath),
		selectedNode = cc.Sprite:create(_imgPath),
		needSwallow = true,
		enable = true,
		needEnableWhenOut = true
	})
	bg:setCascadeOpacityEnabled(true)
	return bg
end)

function JiNengItem:ctor(_skillinfo) 
	self.posCallBack = nil
	
	local _imgPath = "res/image/quality/item_1.png"
	local bg = cc.Sprite:create(_imgPath)
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addChild(bg)
    self._bgColor = bg

	local SkillInfo = _skillinfo
	local _level = SkillInfo.level or 1
	local _quality = self:getSkillQuality(_level)
	local _imgpath = XTHD.resource.getQualityItemBgPath(_quality)
	self:getStateNormal():initWithFile(_imgpath)
	self:getStateSelected():initWithFile(_imgpath)


	local skill = cc.Sprite:create("res/image/skills/skill"..SkillInfo.icon..".png")
	skill:setName("skill")
	skill:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addChild(skill,-1)
	-- skill:setScale(80/skill:getContentSize().width)

--1009
	self:setTouchBeganCallback(function ()
		local tmpPos = self:convertToWorldSpace(cc.p(0,0))
		self.TipsBg = self:_getTipsLayer(SkillInfo)
		if not self.posCallBack then
			if tmpPos.x >= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y >= cc.Director:getInstance():getWinSize().height/2 then --第一象限
				self.TipsBg:setAnchorPoint(cc.p(1,1))
				self.TipsBg:setPosition(tmpPos.x,tmpPos.y)
			elseif tmpPos.x <= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y >= cc.Director:getInstance():getWinSize().height/2 then --第二象限
				self.TipsBg:setAnchorPoint(cc.p(0,1))
				self.TipsBg:setPosition(tmpPos.x+self:getBoundingBox().width,tmpPos.y)
			elseif tmpPos.x <= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y <= cc.Director:getInstance():getWinSize().height/2 then --第三象限
				self.TipsBg:setAnchorPoint(cc.p(0,0))
				self.TipsBg:setPosition(tmpPos.x+self:getBoundingBox().width,tmpPos.y+self:getBoundingBox().height)
			elseif tmpPos.x >= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y <= cc.Director:getInstance():getWinSize().height/2 then --第四象限
				self.TipsBg:setAnchorPoint(cc.p(1,0))
				self.TipsBg:setPosition(tmpPos.x,tmpPos.y+self:getBoundingBox().height)
			end

			cc.Director:getInstance():getRunningScene():addChild(self.TipsBg)
			self.TipsBg:setScale(0)
	        self.TipsBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.05),cc.ScaleTo:create(0.01,1)))
		else
			self.posCallBack()
		end
		
	end)
	self:setTouchMovedCallback( function()
        if self.TipsBg then
            self.TipsBg:removeFromParent()
            self.TipsBg = nil
        end
    end )
	self:setTouchEndedCallback(function ()
		if self.TipsBg then
			self.TipsBg:removeFromParent()
			self.TipsBg = nil
		end
	end)
end

function JiNengItem:getSkillBg()
    return self._bgColor
end

function JiNengItem:getSkillQuality(_level)
	local _quality = math.floor((tonumber(_level)-1)/20)+1
	_quality = _quality >1 and _quality or 1
	return _quality
end
function JiNengItem:setTextureGray(_skillinfo)
	local _level = _skillinfo.level or 1
	local _quality = self:getSkillQuality(_level)
	XTHD.setGray(self:getStateNormal(),true)
	XTHD.setGray(self:getStateSelected(),true)
	if self:getChildByName("skill") then
		XTHD.setGray(self:getChildByName("skill"),true)
	end
end

function JiNengItem:reFreshItemBg(_skillinfo)
	local _level = _skillinfo.level or 1
	local _quality = self:getSkillQuality(_level)
	local _imgpath_ = XTHD.resource.getQualityItemBgPath(_quality)
	self:getStateNormal():initWithFile(_imgpath_)
	self:getStateSelected():initWithFile(_imgpath_)
end

function JiNengItem:createSkillById(Sid)
	self.isSelf = false

	local SkillInfo  = gameData.getDataFromCSV("JinengInfo",{skillid = Sid})
	return self.new(SkillInfo)
end
--传入技能信息（已拥有英雄的技能显示）
function JiNengItem:createWithParams(Params)
	local _default = {
		skillid 	= 1 ,		--技能id
		name 		= "" ,		--技能名称
		icon 		= 1 ,		--技能icon
		description = "" ,		--技能描述
		isUnLock 	= false ,	--技能是否解锁
		ispassive 	= 0 		--技能类型
	}
	for k,v in pairs(_default) do
		if Params[k] == nil then
			Params[k] = v
		end
	end
	self.isSelf = true
	return self.new(Params)
end
--设置tip的显示，不设置默认显示
function JiNengItem:setTipPosition(_callback)
	self.posCallBack = _callback
end

function JiNengItem:onExit()
	if self.TipsBg then
		self.TipsBg:removeFromParent()
		self.TipsBg = nil
	end
end

function JiNengItem:getTips()
	return self.TipsBg
end

-- 技能描述弹出窗口
function JiNengItem:_getTipsLayer(SkillInfo)
	local Sid = SkillInfo.skillid

	local HeroInfo = gameData.getDataFromCSV("GeneralSkillList",{heroid = math.ceil(Sid/6)})--每个英雄有6个技能按序排列的，所以/6向上取整得到英雄ID
	local SkillColumn = nil
	for k,v in pairs(HeroInfo) do
		if k ~= "heroid" and v == Sid then
			SkillColumn = k
			break
		end
	end
	local _descriptionStr = SkillInfo.description
	_descriptionStr= string.gsub(_descriptionStr,"*","\n") 
	local DescLabel = XTHDLabel:createWithParams({
        text = _descriptionStr,
        fontSize = 16,
        color = cc.c3b(77,77,125)
    })
    DescLabel:setWidth(235)
    DescLabel:setLineBreakWithoutSpace(true)
    DescLabel:setAnchorPoint(0,1)
	local _rowHeight = DescLabel:getContentSize().height+10


	local unlockStr = nil
	local unlockColor = cc.c3b(94,132,26)
	-- if self.isSelf == false then
		if SkillColumn == "talent" or SkillColumn == "skillid0" then
			unlockStr = LANGUAGE_KEY_HERO_TEXT.initSkill-------"初始技能"
			-- unlockColor = cc.c3b(255,255,255)
		elseif SkillColumn == "skillid1" then
			unlockStr = LANGUAGE_KEY_HERO_TEXT.advanceGreenIndicate --------"英雄进阶到绿色后解锁"
			-- unlockColor = cc.c3b(255,255,255)
		elseif SkillColumn == "skillid2" then
			unlockStr = LANGUAGE_KEY_HERO_TEXT.advanceBlueIndicate --------"英雄进阶到蓝色后解锁"
			-- unlockColor = cc.c3b(255,255,255)
		elseif SkillColumn == "skillid3" then
			unlockStr = LANGUAGE_KEY_HERO_TEXT.advancePupleIndicate ---------"英雄进阶到紫色后解锁"
			-- unlockColor = cc.c3b(255,255,255)
		end
	-- end

	local unlockLabel = XTHDLabel:createWithParams({
        text = unlockStr,
        fontSize = 16,
        color = unlockColor
    })
    unlockLabel:setAnchorPoint(0.5,0)
    

	local skillName = XTHDLabel:createWithParams({
        text = SkillInfo.name,
        fontSize = 18,
        color = cc.c3b(20,114,145)
    })
    skillName:setAnchorPoint(0,1)
	

	local SkillType = nil
	local TypeColor = nil
	if SkillInfo.ispassive == 0 then
		SkillType = LANGUAGE_SKILLDESC[1] ------"主动技能"
		TypeColor = cc.c3b(212,97,52)
	elseif SkillInfo.ispassive == 1 then
		SkillType = LANGUAGE_SKILLDESC[2] -------"被动技能"
		TypeColor = cc.c3b(212,97,52)
	elseif SkillInfo.ispassive == 2 then
		SkillType = LANGUAGE_SKILLDESC[3]---------"天赋技能"
		TypeColor = cc.c3b(212,97,52)
	end
	local SkillTypeLabel = XTHDLabel:createWithParams({
        text = SkillType,
        fontSize = 16,
        color = TypeColor
    })
    SkillTypeLabel:setAnchorPoint(0,1)

    local bg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
    local _bgSize = cc.size(281,15 +skillName:getContentSize().height + 4+SkillTypeLabel:getContentSize().height +10 + DescLabel:getContentSize().height+5+unlockLabel:getContentSize().height+20)
	bg:setContentSize(_bgSize)
    if SkillInfo.isUnLock and self.isSelf == true then
    	local _bgSize = cc.size(bg:getContentSize().width,bg:getContentSize().height-unlockLabel:getContentSize().height-25)
    	bg:setContentSize(_bgSize)
    else
    	unlockLabel:setPosition(bg:getBoundingBox().width/2,20)
    	bg:addChild(unlockLabel)
    end

    skillName:setPosition(10+5,bg:getContentSize().height-10-5)
	SkillTypeLabel:setPosition(20,skillName:getBoundingBox().y -4)
	DescLabel:setDimensions(235,_rowHeight)
	DescLabel:setPosition(23,SkillTypeLabel:getPositionY()-SkillTypeLabel:getBoundingBox().height-10)

	bg:addChild(skillName)
	bg:addChild(SkillTypeLabel)
	-- DescLabel:setDimensions(253,_rowHeight)
	bg:addChild(DescLabel)

	return bg
end