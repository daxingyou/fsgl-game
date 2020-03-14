--xingchen
local YingXiongSkillUp = class("YingXiongSkillUp", function()
	local select_sp = XTHD.createFunctionLayer()
    return select_sp
end)

function YingXiongSkillUp:ctor(heroData,YingXiongInfoLayer,_size)
	print("哒哒哒哒哒哒多多多多多多多多多多多")
	if _size ~=nil then
		self:setTextureRect(cc.rect(0,0,_size.width,_size.height))
	end
	self._cellUpSkillBtn = {} ---存储升级按钮
	self._globalScheduler = nil

	self.infoLayer = YingXiongInfoLayer 			--主页面

	self.skill_tableView = nil
	self.label_last_skill_number = nil
	self.label_CountDown = nil

	self.cellsArr = {}

	self._oldFightValue = self.infoLayer.data.power or 0
    self._newFightValue = self._oldFightValue
	
	self.skill_foneSize = self.infoLayer._commonTextFontSize
	self.hero_id = 0
	self.last_skill_point = 0
	self.tableViewSize = cc.size(0,0) 		--tableView大小
	self.scrolling = false  				--是否在滚动
	self.selectedCellIdx = 0 				--当前选中cell的idx

	self.hero_skill_data = {}
	self.hero_skill_level = {}
	self._skillTable= {}
	self._skillAdvanceTable = {}

	self:init(heroData)
	YinDaoMarg:getInstance():getACover(self.infoLayer)
end

function YingXiongSkillUp:onCleanup()
    if self._globalScheduler ~= nil then
    	self._globalScheduler:destroy(true)
	    self._globalScheduler = nil
    end
    for k,var in pairs(self.cellsArr) do
    	var:release()
    end    
    self.cellsArr = {}
	self.infoLayer = nil
    cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(CUSTOM_EVENT.REFRESH_SKILLPOINT)
	YinDaoMarg:getInstance():removeCover(self.infoLayer)
end

function YingXiongSkillUp:onEnter(  )
	self:addGuide()
end

function YingXiongSkillUp:init(heroData)
	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=42});
            cc.Director:getInstance():getRunningScene():addChild(StoredValue)
        end,
	})
	help_btn:setScale(0.5)
	self:addChild(help_btn)
	help_btn:setPosition(self:getContentSize().width - help_btn:getBoundingBox().width *0.5 - 5,self:getContentSize().height - help_btn:getBoundingBox().height*0.5 - 5)

	--接收监听
	self:getEventCustom()

	self:setStaticData()
	
	self:setHeroId(heroData["heroid"]) 
	self:setHeroAdvance(heroData["advance"])
	self:setHeroSkillData()
	self:setHeroSkillLevel()
	
	self._globalScheduler = GlobalScheduler:create(self)

	local _bgWidth = self:getContentSize().width-8*2
	if self:getContentSize().width > 365 then
		_bgWidth = 365 - 8*2 + (self:getContentSize().width - 365)/2
	end
	local _bgSize = cc.size(_bgWidth ,self:getContentSize().height - 8 -40)

	local _itemListBg = ccui.Scale9Sprite:create(cc.rect(12,12,1,1),"res/image/common/scale9_bg_25.png")
	_itemListBg:setContentSize(_bgSize)
	_itemListBg:setAnchorPoint(cc.p(0.5,0))
	_itemListBg:setPosition(cc.p(self:getContentSize().width/2+20,8))
	_itemListBg:setOpacity(0)
	self:addChild(_itemListBg)

	--获取剩余技能点
	self:setLastskillPoint(gameUser.getSkillPointNow())
	
	--剩余技能点背景
	local skill_point_bg = cc.Sprite:create("res/image/common/skill_point_bg.png")
	skill_point_bg:setPosition(self:getContentSize().width/2,self:getContentSize().height - 22)
	self:addChild(skill_point_bg)
	--剩余技能点
	local _skillPointPositionY = self:getContentSize().height - 28
	local label_last_skill_point = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.lastSkillPointTextXc, self.skill_foneSize)
	label_last_skill_point:setName("label_last_skill_point")
	-- label_last_skill_point:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
	label_last_skill_point:setColor(cc.c3b(60,0,0))
	label_last_skill_point:setAnchorPoint(0.5,0.5)
	label_last_skill_point:setPosition(cc.p(3,_skillPointPositionY))
	self:addChild(label_last_skill_point)

--	--help
--	local help_btn = XTHDPushButton:createWithParams({
--        normalFile        = "res/image/camp/lifetree/wanfa_up.png",
--        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
--        musicFile = XTHD.resource.music.effect_btn_common,
--        endCallback       = function()
--            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=22}); --生命之树玩法说明
--			local layer = cc.Director:getInstance():getRunningScene()
--			StoredValue:setAnchorPoint(0.5,0.5)
--			StoredValue:setPosition(0,0)
--            layer:addChild(StoredValue)
--        end,
--    })
--	self:addChild(help_btn)
--	help_btn:setScale(0.9)
--	help_btn:setPosition(self:getContentSize().width - 80,_skillPointPositionY)
	
	self.label_last_skill_number = XTHDLabel:create(tostring(self:getLastskillPoint()) , self.skill_foneSize)
	-- self.label_last_skill_number:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
	self.label_last_skill_number:setAnchorPoint(0.5,0.5)
	self.label_last_skill_number:setColor(cc.c3b(60,0,0))
	self.label_last_skill_number:setVisible(false)
	label_last_skill_point:setPositionX(self:getContentSize().width/2-self.label_last_skill_number:getContentSize().width/2)
	self.label_last_skill_number:setPosition(label_last_skill_point:getBoundingBox().x + label_last_skill_point:getBoundingBox().width + self.label_last_skill_number:getBoundingBox().width/2, _skillPointPositionY)
	self:addChild(self.label_last_skill_number)

	self.label_CountDown = XTHDLabel:create("00:00",self.skill_foneSize)      ---------------------倒计时时间
	-- self.label_CountDown:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
	self.label_CountDown:setColor(self:getSkillUpTextColor("chenghongse"))
	self.label_CountDown:setAnchorPoint(cc.p(0,0.5))
	self.label_CountDown:setPosition(cc.p(26, _skillPointPositionY))
	self:addChild(self.label_CountDown)
	self.label_CountDown:setVisible(false)

	--购买技能点按钮
	local buySkillPoint = XTHD.createCommonButton({
		btnColor = "gray"
		,
		isScrollView = false,
		text = LANGUAGE_BTN_KEY.buy
		,endCallback = function()
			-- print("8431>>购买技能点按钮")
			self:toBuySkillPoint()
		end
	})
	buySkillPoint:setScale(0.4)
	buySkillPoint:getLabel():enableOutline(cc.c4b(15,0,0,255),2)
	buySkillPoint:getLabel():setScale(1.2)
	buySkillPoint:setName("buySkillPoint")
	buySkillPoint:setAnchorPoint(cc.p(1,0.5))
	buySkillPoint:setPosition(cc.p(self:getContentSize().width-35,label_last_skill_point:getPositionY()))
	buySkillPoint:setVisible(false)
	self:addChild(buySkillPoint,1)

	--设置技能点显示
	self:setSkillPointShow()

	self.tableViewSize = cc.size(_bgSize.width ,_bgSize.height - 2-2)
	self.tableViewCellSize = cc.size(self.tableViewSize.width,85)
	self.skill_tableView = cc.TableView:create(self.tableViewSize)
	TableViewPlug.init(self.skill_tableView)
	self.skill_tableView:setBounceable(true)
	self.skill_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self.skill_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self.skill_tableView:setDelegate()
	self.skill_tableView:setPosition( -15,2)
	_itemListBg:addChild(self.skill_tableView)

	--上阴影和下阴影
	-- local _downShadow_sp = ccui.Scale9Sprite:create(cc.rect(13,0,1,22),"res/image/common/common_scale9_downShader.png")
	-- _downShadow_sp:setAnchorPoint(cc.p(0.5,0))
	-- _downShadow_sp:setContentSize(cc.size(self.tableViewSize.width-10,22))
	-- _downShadow_sp:setPosition(cc.p(self.tableViewSize.width/2,4))
	-- self:addChild(_downShadow_sp)

	

	local _cellNumber = 5
	
	self.skill_tableView.getCellNumbers = function (table_view)
       return _cellNumber
    end
	self.skill_tableView:registerScriptHandler(self.skill_tableView.getCellNumbers, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	
	self.skill_tableView.getCellSize = function (table_view,idx)
       return self.tableViewCellSize.width,self.tableViewCellSize.height
    end

	self.skill_tableView:registerScriptHandler(self.skill_tableView.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
    
    self.skill_tableView:registerScriptHandler(
		function(view)
			self.scrolling = true
			-- local _contentOffsetY = self.skill_tableView:getContentOffset().y
			-- print("8431>>_posY>>" .. _contentOffsetY)
			-- if _contentOffsetY+102/3*2<0 then
			-- 	_downShadow_sp:setVisible(true)
			-- else
			-- 	_downShadow_sp:setVisible(false)
			-- end
		end,cc.SCROLLVIEW_SCRIPT_SCROLL)

    self.skill_tableView:registerScriptHandler(
    	function(table_view,cell)
   --  		local _skillbg = nil
   --  		if cell:getChildByName("cellBg"):getChildByName("skillBg") then
			-- 	_skillbg = cell:getChildByName("cellBg"):getChildByName("skillBg")
			-- else
			-- 	return
   --  		end
    	end,cc.TABLECELL_TOUCHED)

    self.skill_tableView:registerScriptHandler(
    	function (table_view,idx)
    		local cell = self.cellsArr[idx+1]
    		if not cell then
    			cell = self:createSkillCellInfo(idx+1)
    			cell:retain()
    			self.cellsArr[idx+1] = cell
    		end
    		return cell
	    end
    ,cc.TABLECELL_SIZE_AT_INDEX)
    -- print("onEnteronEnteronEnteronEnter")
    self.skill_tableView:reloadData()

end

function YingXiongSkillUp:createSkillCellInfo(_idx)
	local _idxNum = _idx

	local cell = cc.TableViewCell:create()
	local cell_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
	cell_bg:setContentSize(cc.size(self.tableViewCellSize.width - 2*2,self.tableViewCellSize.height))
	cell_bg:setName("cellBg")
	cell_bg:setAnchorPoint(0.5,0.5)
	cell_bg:setPosition(self.tableViewSize.width/2,self.tableViewCellSize.height/2)
	cell:addChild(cell_bg)

	if _idx ~=5 then
    	-- local _lineSp = ccui.Scale9Sprite:create( cc.rect( 0, 0, 3, 2 ), "res/image/ranklistreward/splitcell.png" )
		-- _lineSp:setContentSize(cc.size(self.tableViewCellSize.width - 2,2))
		-- _lineSp:setPosition(cc.p(self.tableViewCellSize.width/2,0))	
		-- cell:addChild(_lineSp)
    end

	local _advance = self:getHeroAdvance()
	local skill_level = 0
	local skill_id = 0
	local skill_cost_str = "skill0price"
	local skill_lock = {}
	skill_lock._isUnlock = false

	if _idxNum == 1 then
	    skill_id = self.hero_skill_data["talent"]
	    skill_level = self.hero_skill_level["talentlv"]
	    skill_lock._isUnlock = true
	    skill_lock._unlockDesc = LANGUAGE_KEY_HERO_TEXT.skillTalentDescTextXc
	else
	    skill_id = self.hero_skill_data["skillid" .. (_idxNum - 2)]
		skill_level = self.hero_skill_level[self:getKeyStrFromTable("heroskill",_idxNum) or "skillid0lv"]
		skill_cost_str = self:getKeyStrFromTable("skill_advance",_idxNum) or "skill0price"

		skill_lock = self:isUnLockSkill(tostring(_idxNum - 2), _advance)
	end

	local skill_info_data = self:getSkillInfoData(skill_id,skill_level,_idxNum)

	--技能头像方框
--	skill_info_data.isUnLock = skill_lock._isUnlock
--	skill_info_data.level = skill_level
	local skill_bg = JiNengItem:createWithParams(skill_info_data)
	cell.skillData = skill_info_data
	skill_bg:setSwallowTouches(false)
	skill_bg:setName("skillBg")
	skill_bg:setTouchSize(cc.size(100,100))
	skill_bg:setAnchorPoint(0,0.5)
	-- skill_bg:setScale(80/skill_bg:getContentSize().width)
	skill_bg:setPosition(15,cell_bg:getContentSize().height / 2)
	skill_bg:setScale(0.65)
	cell_bg:addChild(skill_bg)

    local _index = 1
    if skill_level >= 1 and skill_level <= 19 then
       _index = 1
    elseif skill_level > 19 and skill_level <= 39 then
        _index = 2 
    elseif skill_level > 39 and skill_level <= 59 then
        _index = 3 
    elseif skill_level > 59 and skill_level <= 79 then
        _index = 4
    elseif skill_level > 79 and skill_level <= 99 then
        _index = 5
	elseif skill_level == 0 then
		_index = 1
    else
        _index = 6
    end

    local _bgColor = skill_bg:getSkillBg()
    local name = string.format("res/image/quality/item_%d.png",_index)
    _bgColor:setTexture(name)

	-- skill_bg:setTipPosition(function()
	-- 	local _tips = skill_bg:getTips()
	-- 	_tips:setAnchorPoint(cc.p(0,1))
	-- 	_tips:setPosition(cc.p(self.skill_tableView:getContentSize().width,self.tableViewSize.height))
	-- 	self:addChild(_tips)
	-- 	end)
	
	local skill_path = "res/image/skills/skill" .. skill_info_data.icon .. ".png" 
	

	--技能名称
	local skill_name = XTHDLabel:create(skill_info_data["name"],self.skill_foneSize)
	skill_name:setColor(cc.c3b(60,0,0))
	skill_name:setAnchorPoint(0,0.5)
	skill_name:setPosition(skill_bg:getBoundingBox().x + skill_bg:getBoundingBox().width + 10,cell_bg:getContentSize().height/3*2+5)
	cell_bg:addChild(skill_name)

	--是否已经解锁
	local lock_color=self:getSkillUpTextColor("shenhese")
	if skill_lock._isUnlock == false then
		skill_bg:setTextureGray(skill_info_data)
		lock_color=self:getSkillUpTextColor("hongse")
		skill_name:setColor(self:getSkillUpTextColor("huise"))
	end
	--消耗
	if tonumber(_idxNum) > 1 and skill_lock._isUnlock then
		--翡翠图标
		local _cost_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png")
		_cost_bg:setName("cost_bg")
		_cost_bg:setAnchorPoint(cc.p(1,0))
		_cost_bg:setContentSize(cc.size(80,24))
		_cost_bg:setPosition(cc.p(cell_bg:getContentSize().width - 12,15))
		cell_bg:addChild(_cost_bg)
		local _costSprite = cc.Sprite:create("res/image/common/header_feicui.png")
		_costSprite:setName("costSprite")
		_costSprite:setAnchorPoint(cc.p(0.5,0.5))
		_costSprite:setScale(25/_costSprite:getContentSize().height)
		_costSprite:setPosition(cc.p(4,_cost_bg:getContentSize().height/2))
		_cost_bg:addChild(_costSprite)
		--翡翠数量
		local _skillCostData = skill_info_data["skill_advance"] or {}
		local _costNum = tonumber(_skillCostData[skill_cost_str]) or 0
		local _costNumLabel = XTHDLabel:create(getHugeNumberWithLongNumber(_costNum,100000),18)
		_costNumLabel.costNum = _costNum
		_costNumLabel:setName("costNumLabel")
		_costNumLabel:setAnchorPoint(cc.p(0.5,0.5))

		_costNumLabel:setPosition(cc.p(_cost_bg:getContentSize().width-34,_costSprite:getPositionY()))
		_cost_bg:addChild(_costNumLabel)
		if tonumber(_costNum)>tonumber(gameUser.getFeicui()) then
			_costNumLabel:setColor(self:getSkillUpTextColor("hongse"))
			_costNumLabel:enableShadow(self:getSkillUpTextColor("hongse"),cc.size(0.4,-0.4),0.4)
		else
			_costNumLabel:setColor(cc.c3b(247,243,233))
			_costNumLabel:enableShadow(cc.c3b(247,243,233),cc.size(0.4,-0.4),0.4)
		end
		--升级按钮
		local _skillup_btn = XTHD.createButton({
				normalFile = "res/image/common/btn/btn_add_normal.png",
				selectedFile = "res/image/common/btn/btn_add_selected.png",
				touchSize = cc.size(85,70),
				needEnableWhenMoving = true,
				beganCallback = function()
					self.scrolling = false
				end,
				endCallback = function()
					if tonumber(gameUser.getFeicui())<tonumber(_costNumLabel.costNum) then
						local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=4})
					    self.infoLayer:addChild(StoredValue)
						return
					end
					if tonumber(gameUser.getSkillPointNow())<1 then
						self:toBuySkillPoint("noEnoughSkillPoint")
						return
					else
						self:HttpSkillUpFunc(self.hero_id,skill_id,_idxNum)
					end
				end
			})
			_skillup_btn:setScale(0.8)
		_skillup_btn:setSwallowTouches(false)
		_skillup_btn:setName("skillup_btn")
		_skillup_btn:setAnchorPoint(cc.p(0.5,0.5))
		_skillup_btn:setPosition(cc.p(cell_bg:getContentSize().width-47,63))
		cell_bg:addChild(_skillup_btn)
		self._cellUpSkillBtn[#self._cellUpSkillBtn + 1] = _skillup_btn

		--等级
		local skillLevel_label = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.LevelTitleTextXc .. ": " .. skill_level , self.skill_foneSize)
		skillLevel_label:setName("skillLevel_label")
		skillLevel_label:setColor(self:getSkillUpTextColor("shenhese"))
		skillLevel_label:setAnchorPoint(0,0.5)
		skillLevel_label:setPosition(skill_name:getBoundingBox().x,cell_bg:getContentSize().height/3*1-5)
		cell_bg:addChild(skillLevel_label)
	elseif skill_lock._unlockDesc then
		local _unlockDescLabel = XTHDLabel:create(skill_lock._unlockDesc,self.skill_foneSize)
		_unlockDescLabel:setColor(cc.c3b(60,0,0))
		_unlockDescLabel:setAnchorPoint(cc.p(0,0.5))
		_unlockDescLabel:setPosition(cc.p(skill_name:getBoundingBox().x,cell_bg:getContentSize().height/3*1-5))
		_unlockDescLabel:setColor(lock_color)
		cell_bg:addChild(_unlockDescLabel)
	end

	return cell
end


--设置HeroId
function YingXiongSkillUp:setHeroId(_heroId)
	self.hero_id = _heroId or 0
end
function YingXiongSkillUp:getHeroId()
	return self.hero_id
end

--设置当前进阶数
function YingXiongSkillUp:setHeroAdvance(_advance)
	self.hero_advance = _heroId or 0
end
function YingXiongSkillUp:getHeroAdvance()
	return self.hero_advance
end

--设置剩余点数
function YingXiongSkillUp:setLastskillPoint(_pointNum)
	self.last_skill_point = _pointNum or 0
end
function YingXiongSkillUp:getLastskillPoint()
	return self.last_skill_point
end

--设置英雄所属的技能信息
function YingXiongSkillUp:setHeroSkillData()
	self.hero_skill_data = {}
	self.hero_skill_data = clone(self.infoLayer.staticHeroSkillListData[tostring(self:getHeroId())] or {})
end
function YingXiongSkillUp:getHeroSkillData()
	return self.hero_skill_data
end
--设置英雄技能的等级
function YingXiongSkillUp:setHeroSkillLevel()
	self.hero_skill_level = DBTableHeroSkill.getData(gameUser.getUserId(),{["heroid"] = self:getHeroId()})
end
function YingXiongSkillUp:getHeroSkillLevel()
	return self.hero_skill_level
end

--获取技能在skill_advance表中的键名
function YingXiongSkillUp:getKeyStrFromTable(_type,_idx)
	local _str = nil
	local _skill_advance = {"skill0price","skill1price","skill2price","skill3price"}
	local _heroskill = {"skillid0lv","skillid1lv","skillid2lv","skillid3lv"}
	if _type =="skill_advance" then
		_str = _skill_advance[tonumber(_idx-1)]
	elseif _type == "heroskill" then
		_str = _heroskill[tonumber(_idx-1)]
	end
	return _str
end
--获取静态表数据
function YingXiongSkillUp:setStaticData()
	self._skillTable= {}
	if self.infoLayer.otherStaticSkillData==nil or next(self.infoLayer.otherStaticSkillData)==nil then
		self.infoLayer:setOtherStaticDBData()
	end
	self._skillTable = clone(self.infoLayer.otherStaticSkillData or {})

	self._skillAdvanceTable = {}
	self._skillAdvanceTable = clone(self.infoLayer.staticSkillUpListData or {})
end
--获取技能信息
function YingXiongSkillUp:getSkillInfoData(_skillId,_skillLevel,_order)
	local _infoData = self._skillTable[tostring(_skillId)] or {}
	--获取技能需要进阶的信息
	_infoData["skill_advance"] = self._skillAdvanceTable[tostring(_skillLevel)]
	return _infoData
end

--判断技能是否已经解锁
function YingXiongSkillUp:isUnLockSkill(_skillOrd)
	local _skillStr = "skillid" .. _skillOrd .."lv"
	-- local _advance = LANGUAGE_KEY_HERO_TEXT.advanceColorSkillTextXc
	local skill_lock = {}
	skill_lock._isUnlock = false
	skill_lock._unlockDesc = nil
	local _skillLevel = self:getHeroSkillLevel()
	if _skillLevel[_skillStr] and tonumber(_skillLevel[_skillStr])>0 then
		skill_lock._isUnlock = true
	elseif tonumber(_skillOrd)>0 and tonumber(_skillOrd)<=3 then
		skill_lock._unlockDesc = LANGUAGE_TIPS_skillUnlockDescTextXc(tonumber(_skillOrd)) 
	end
	return skill_lock
end

--设置技能点处的显示
function YingXiongSkillUp:setSkillPointShow()
	if self:getChildByName("label_last_skill_point") then
		local _labelSkillPoint = self:getChildByName("label_last_skill_point")
		if tonumber(gameUser.getSkillPointNow())>0 then
			_labelSkillPoint:setString(LANGUAGE_KEY_HERO_TEXT.lastSkillPointTextXc)
			_labelSkillPoint:setPositionX(self:getContentSize().width/2-self.label_last_skill_number:getContentSize().width/2)
			self.label_last_skill_number:setPositionX(_labelSkillPoint:getBoundingBox().x + _labelSkillPoint:getBoundingBox().width + self.label_last_skill_number:getBoundingBox().width/2)
			self.label_last_skill_number:setVisible(true)
			self.label_CountDown:setVisible(false)
			if self:getChildByName("buySkillPoint") then
				self:getChildByName("buySkillPoint"):setVisible(false)
			end
		else
			_labelSkillPoint:setString(LANGUAGE_KEY_HERO_TEXT.CountDownTextXc)  -- xx"后得1技能点" 英文版此处需要修改 by andong
			self:setCountDownSchedule()
			self.label_CountDown:setPositionX(126)
			_labelSkillPoint:setPositionX(self.label_CountDown:getBoundingBox().width + self.label_CountDown:getBoundingBox().x + _labelSkillPoint:getBoundingBox().width/2 + 2)
			self.label_last_skill_number:setVisible(false)
			self.label_CountDown:setVisible(true)
			
			-- self:setCurrentCountDownShow(XTHD.getTimeHMS(math.ceil(UpdateTimerMgr:getSkillDot())))
			if self:getChildByName("buySkillPoint") then
				self:getChildByName("buySkillPoint"):setVisible(true)
			end
		end
	else
		return
	end
end
--设置当前剩余技能点的显示
function YingXiongSkillUp:setCurrentSkillPointShow(_str)
	if not _str then
		self.label_last_skill_number:setString(gameUser.getSkillPointNow())
	else
		self.label_last_skill_number:setString(_str)
	end
	
end
--设置当前技能倒计时显示
function YingXiongSkillUp:setCurrentCountDownShow(_str)
	if _str and tostring(_str) == tostring("10:00") then
		_str = 0
	end
 	self.label_CountDown:setString(_str)
end
--技能倒计时schedule
function YingXiongSkillUp:setCountDownSchedule()
	--获取当前的技能时间
	local _lastTimeDot = gameUser.getSkillPointDot() -(os.time() - gameUser.getLoginOstime())
	-- local _skillTime = math.ceil(UpdateTimerMgr:getSkillDot())
	-- schedule(self,function(dt)
	-- 	-- print("8431>>>schedule")
	-- 	local _skillpoint = gameUser.getSkillPointNow()
	-- 	-- print("8431>>>_skillpoint>>" .. zctech.print_table(_skillpoint))
	-- 	if tonumber(_skillpoint)>0 then
	-- 		self:setCurrentSkillPointShow(_skillpoint)
	-- 		self:setSkillPointShow()
	-- 		if self:getScheduler() then
	-- 			self:unscheduleUpdate()
	-- 		end
	-- 		return
	-- 	end
	-- 	if _skillTime >0 then
	-- 		_skillTime = math.ceil(UpdateTimerMgr:getSkillDot())
			
	-- 	end
	-- end,1)
	if _lastTimeDot < 0 then
		gameUser.setSkillPointNow(1)
		return 
	end
	self:setCurrentCountDownShow(XTHD.getTimeHMS(_lastTimeDot))
	local function _cdEnd()
		self._globalScheduler:removeCallback("skillPointDotSchedule")
	end

	local function _updateTime( sTime )
		local _skillpoint = gameUser.getSkillPointNow()
		if tonumber(_skillpoint)>0 then
			self:setCurrentSkillPointShow(_skillpoint)
			self:setSkillPointShow()
			_cdEnd()
			return
		end
        local _time = tonumber(sTime) or 0
        if _time >= 0 then
            self:setCurrentCountDownShow(XTHD.getTimeHMS(_time))
        else
        	gameUser.setSkillPointNow(1)
            _cdEnd()
        end
    end
    self._globalScheduler:removeCallback("skillPointDotSchedule")
    self._globalScheduler:addCallback("skillPointDotSchedule", {perCall = _updateTime, cdTime = _lastTimeDot})
		
end
--接收事件监听,技能点刷新。
function YingXiongSkillUp:getEventCustom()
	-- local custom_listener = cc.EventListenerCustom:create(CUSTOM_EVENT.REFRESH_SKILLPOINT,
	--  	 function (event)
	--  	 	-- print("8431>>>>>>技能点刷新啦~~~")
	--  	 	if self and self.setCurrentSkillPointShow then
	--  	 		self:setCurrentSkillPointShow()
	--  	 	else
	--  	 		cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(CUSTOM_EVENT.REFRESH_SKILLPOINT)
	--  	 	end
	--  	 end)
	-- local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
 --    eventDispatcher:addEventListenerWithFixedPriority(custom_listener, 1)
    XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_SKILLPOINT,node = self,callback = function(event)
        if self and self.setCurrentSkillPointShow then
 	 		self:setCurrentSkillPointShow()
 	 	end
    end})
    
end

--[[购买技能点
1.noEnoughSkillPoint=》技能点不足弹出框内容
2.其余的为正常购买
]]
function YingXiongSkillUp:toBuySkillPoint(_type)
	local _buyDialog = XTHDConfirmDialog:createWithParams({
		})
	_buyDialog:setName("buyDialog")
	_buyDialog._type = _type or nil
	_buyDialog._turnType = nil  			--跳转类型
	self.infoLayer:addChild(_buyDialog)
	local _confirmDialogBg = nil
	if _buyDialog:getContainer() then
		_confirmDialogBg = _buyDialog:getContainer()
	else
		_buyDialog:removeFromParent()
		return
	end
	--剩余购买次数
	local _label_lastBuyCount = XTHDLabel:create(0,18)
	_label_lastBuyCount:setAnchorPoint(cc.p(0.5,1))
	_label_lastBuyCount:setName("label_lastBuyCount")
	_label_lastBuyCount:setColor(XTHD.resource.color.gray_desc)
	_label_lastBuyCount:setPosition(cc.p(_confirmDialogBg:getContentSize().width/2,_confirmDialogBg:getContentSize().height/5*3 - 10))
	_confirmDialogBg:addChild(_label_lastBuyCount)
	self:reFreshBuyConfirmdialog()

	--确定回调
	_buyDialog:setCallbackRight(function()
		if _buyDialog._turnType and _buyDialog._turnType == "noEnoughIngot" then
			--元宝不足
			self:gotoRechargeIngot()
			_buyDialog:removeFromParent()
		else
			--正常购买
			self:httpToBuySkillPoint()
			-- _buyDialog:hide()
		end
		
	end)
end
function YingXiongSkillUp:reFreshBuyConfirmdialog()
	if self.infoLayer:getChildByName("buyDialog")==nil then
		return
	end
	local _buyDialog = self.infoLayer:getChildByName("buyDialog")
	local _confirmDialogBg = nil
	if _buyDialog:getContainer() then
		_confirmDialogBg = _buyDialog:getContainer()
	else
		return
	end
	if _confirmDialogBg:getChildByName("label_buySkillPoint") then
		_confirmDialogBg:removeChildByName("label_buySkillPoint")
	end
	--剩余购买次数
	local _lastBuyCount = gameUser.getLastskillPointBuyCount()
	--当前技能点购买花费
	local _cuurentSkillPointCount = tonumber(gameUser.getSkillPointBuyCount())*10+10
	--购买技能文字
	local _labelStr = ""
	--花费元宝数量
	-- local _costingotNum = 10*(tonumber(gameUser.getSkillPointBuyCount()) + 1)
	local _costingotNum = 20  
	local _str = LANGUAGE_KEY_HERO_TEXT.buySkillpointOneTextXc
	if _buyDialog._type and _buyDialog._type == "noEnoughSkillPoint" then
		_str = LANGUAGE_KEY_HERO_TEXT.noEnoughSkillPointTextXc .. _str
	end
	if tonumber(gameUser.getIngot())<_costingotNum then
		--元宝不足
		_buyDialog._turnType = "noEnoughIngot"
	end
	local _label_buySkillPoint = nil    -- "技能点不足,是否花费 xxx 购买10技能点?" (英文版需要修改 by andong)
	_labelStr = "<color=#462222 fontSize=18 >" .. _str .. "<img=res/image/common/header_ingot.png height=30 width=30 /></color><color=#cd6508 fontSize=22 >" .. _costingotNum .. "</color><color=#462222 fontSize=18 >" .. LANGUAGE_KEY_HERO_TEXT.buySkillpointTwoTextXc .. "</color>"
	_label_buySkillPoint = RichLabel:createARichText(_labelStr,false)
	_label_buySkillPoint:setName("label_buySkillPoint")
	_label_buySkillPoint:setAnchorPoint(cc.p(0.5,0))
	_label_buySkillPoint:setPosition(cc.p(_confirmDialogBg:getContentSize().width/2,_confirmDialogBg:getContentSize().height/2+50))
	_confirmDialogBg:addChild(_label_buySkillPoint)
	if _confirmDialogBg:getChildByName("label_lastBuyCount") then
		_confirmDialogBg:getChildByName("label_lastBuyCount"):setString(LANGUAGE_TIPS_lastBuyCountTextXc(_lastBuyCount))
	else
		--剩余购买次数
		local _label_lastBuyCount = XTHDLabel:create(LANGUAGE_TIPS_lastBuyCountTextXc(_lastBuyCount),18)
		_label_lastBuyCount:setAnchorPoint(cc.p(0.5,1))
		_label_lastBuyCount:setName("label_lastBuyCount")
		_label_lastBuyCount:setColor(XTHD.resource.color.gray_desc)
		_label_lastBuyCount:setPosition(cc.p(_confirmDialogBg:getContentSize().width/2,_confirmDialogBg:getContentSize().height/5*3 - 10))
		_confirmDialogBg:addChild(_label_lastBuyCount)
	end

end

--获得剩余购买次数
function YingXiongSkillUp:getLastBuyCountFunc()
	local _lastCount = gameUser.getLastskillPointBuyCount()
	return _lastcount
end

--购买技能点的网络请求
function YingXiongSkillUp:httpToBuySkillPoint()
	ClientHttp:httpHeroBuySkillPoint(self,function(data)
			--当前技能点
        	gameUser.setSkillPointNow(data.skillPoint)
        	--已经购买的次数
        	gameUser.setSkillPointBuyCount(data.buyCount)
        	--当前的元宝
        	gameUser.setIngot(data["ingot"])
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
            --技能点显示
            self:setCurrentSkillPointShow(gameUser.getSkillPointNow())
			self:setSkillPointShow()
			self.infoLayer:isCanDoPrompt()
			self:reFreshBuyConfirmdialog()

            XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.buySkillPointSuccessTextXc)
		end,{},function(data)
			if data~=nil and data.result ~=nil and tonumber(data.result)==2010 then
				self:toRechargeVIP()
			end
		end)
	-- ClientHttp:requestAsyncInGameWithParams({
 --    	modules = "buySkillPoint?",
 --        params = {""},
 --        successCallback = function(data)
 --            if tonumber(data.result) == 0 then
 --            	--当前技能点
 --            	gameUser.setSkillPointNow(data.skillPoint)
 --            	--已经购买的次数
 --            	gameUser.setSkillPointBuyCount(data.buyCount)
 --            	--当前的元宝
 --            	gameUser.setIngot(data["ingot"])
 --                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
 --                --技能点显示
 --                self:setCurrentSkillPointShow(gameUser.getSkillPointNow())
	-- 			self:setSkillPointShow()
	-- 			self.infoLayer:isCanDoPrompt()
	-- 			self:reFreshBuyConfirmdialog()

 --                XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.buySkillPointSuccessTextXc)
 --            elseif tonumber(data.result) == 2010 then
 --            	self:toRechargeVIP()
 --            else
 --              XTHDTOAST(data.msg)
 --            end
 --        end,--成功回调
 --        failedCallback = function()
 --            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败")
 --        end,--失败回调
 --        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
 --    })
end

--[[购买次数，充值VIP
1.noEnoughSkillPoint=》技能点不足弹出框内容
2.其余的为正常去充值
]]
function YingXiongSkillUp:toRechargeVIP(_type)
	if self.infoLayer and self.infoLayer:getChildByName("buyDialog") then
		self.infoLayer:getChildByName("buyDialog"):removeFromParent()
	end
	--购买技能文字
	local _labelStr = LANGUAGE_KEY_HERO_TEXT.noEnoughBuyCountTextXc
	local _buyDialog = XTHDConfirmDialog:createWithParams({
			msg = _labelStr,
			rightCallback = function()
				self:goToRechargeVIP()
			end
		})
	self.infoLayer:addChild(_buyDialog)
end
--跳转到充值
function YingXiongSkillUp:goToRechargeVIP()
	-- print("跳转去充值VIP")
	XTHD.createRechargeVipLayer(self.infoLayer)
end
--元宝不足，前往充值
function YingXiongSkillUp:gotoRechargeIngot()
	self.infoLayer:showMoneyNoEnoughtPop("noIngot")
end

--升级的网络请求
function YingXiongSkillUp:HttpSkillUpFunc(_heroid,_skillId,_idx)
	--------引导 
    YinDaoMarg:getInstance():guideTouchEnd() 
	--------引导 
	self.selectedCellIdx = _idx
	self.infoLayer:setButtonClickableState(false)
	self._oldFightValue = self.infoLayer.data.power or 0
    self._newFightValue = self._oldFightValue
	-----------------------------------
    ClientHttp:httpHeroSkillUp(
    	self,
    	function(data)
    		YinDaoMarg:getInstance():doNextGuide()

    		musicManager.playEffect("res/sound/sound_skillUp_effect.mp3")
        	gameUser.setFeicui(data["feicui"])
        	gameUser.setSkillPointNow(data.skillPoint)
        	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
        	self:playSkillUpAnimation(_idx)
        	self:reFreshSkillUpData(data)
            XTHD._createFightLabelToast({
                oldFightValue = self._oldFightValue,
                newFightValue = self._newFightValue 
            })
            self._oldFightValue = self._newFightValue
            self.infoLayer:setButtonClickableState(true)
    	end,
    	{petId=_heroid,skillId=_skillId},
    	function()
    		YinDaoMarg:getInstance():tryReguide()
    		if self and self.infoLayer then 
    			self.infoLayer:setButtonClickableState(true)
    		end 
    	end)
	-- ClientHttp:requestAsyncInGameWithParams({
 --    	modules = "upSkill?",
 --        params = {petId=_heroid,skillId=_skillId},
 --        successCallback = function(data)
 --            if tonumber(data.result) == 0 then
 --            	musicManager.playEffect("res/sound/sound_skillUp_effect.mp3")
 --            	gameUser.setFeicui(data["feicui"])
 --            	gameUser.setSkillPointNow(data.skillPoint)
 --            	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
 --            	self:playSkillUpAnimation(_idx)
 --            	self:reFreshSkillUpData(data)
 --                XTHD._createFightLabelToast({
 --                    oldFightValue = self._oldFightValue,
 --                    newFightValue = self._newFightValue 
 --                })
 --                self._oldFightValue = self._newFightValue
 --            else
 --              XTHDTOAST(data.msg)
 --            end
 --            self.infoLayer:setButtonClickableState(true)
 --        end,--成功回调
 --        failedCallback = function()
	--         self.infoLayer:setButtonClickableState(true)
 --            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
 --        end,--失败回调
 --        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
 --    })
end

function YingXiongSkillUp:playSkillUpAnimation(_idx)
	if self.cellsArr[_idx]==nil then
		return
	end
	local _cellBg = self.cellsArr[_idx]:getChildByName("cellBg")
	local _skillItem = _cellBg:getChildByName("skillBg")
	local _animation_Sp = cc.Sprite:create("res/image/plugin/hero/strengthFrames/1.png")
	_animation_Sp:setScale(1.3)
	_animation_Sp:setName("animation_costSp")
	_animation_Sp:setPosition(cc.p(_skillItem:getContentSize().width/2,_skillItem:getContentSize().height/2))
	_skillItem:addChild(_animation_Sp)
	-- _animation_Sp:setScale(1.9)
	local _animation = getAnimation("res/image/plugin/hero/strengthFrames/",1,13,0.065)
	_animation_Sp:runAction(cc.Sequence:create(_animation,cc.CallFunc:create(function()
			_animation_Sp:removeFromParent()
		end)))
end

function YingXiongSkillUp:reFreshSkillUpData(data)
    --刷新数据库
    --tableview》reloadData
    for i = 1,#data["petProperty"] do
		local _petItemData = string.split( data["petProperty"][i],',')
		DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[1],_petItemData[2],data["petId"])
		if tonumber(_petItemData[1]) == 407 then
            self._newFightValue = tonumber(_petItemData[2])
        end
	end

	--设置剩余技能点和剩余时间
	if tonumber(data.skillPoint)<1 then
		gameUser.setSkillPointTimeTable(data.skillTime,tostring(os.time()))
		-- UpdateTimerMgr:setSkillDotStart(tonumber(data.skillTime))
		-- UpdateTimerMgr:setSkillDot(tonumber(data.skillTime))
	end
	local _skillinfoData = self.infoLayer.staticHeroSkillListData[tostring(data["petId"])] or {}
	local _skillKey = nil
	for k,v in pairs(_skillinfoData) do
		if tonumber(v) == tonumber(data.skillId) then
			_skillKey = k .. "lv"
			break 
		end
	end
	if _skillKey~=nil then
		DBTableHeroSkill.updateByKey(gameUser.getUserId(), _skillKey,data["skillLevel"],data["petId"])
	end
	RedPointManage:getDynamicDBHeroSkillData()
	self.infoLayer:setTheHeroData(data["petId"])
	self.infoLayer:reFreshFightLabel()
	self.infoLayer:isCanDoPrompt()
	self.infoLayer:addTabButtonRedpoint()

	if tonumber(data["petId"])==tonumber(self.infoLayer.data.heroid) then
        self:reFreshHeroFunctionInfo()
    end
end

function YingXiongSkillUp:reFreshHeroFunctionInfo()
	self:setHeroSkillLevel()
	for k,var in pairs(self.cellsArr) do
    	var:release()
    end
    self.cellsArr = {}
	self.skill_tableView:reloadDataAndScrollToCurrentCell()
	local _skilPoint = gameUser.getSkillPointNow()
	self:setLastskillPoint(_skilPoint)
    self.label_last_skill_number:setString(_skilPoint)
    self:setSkillPointShow()
    self.selectedCellIdx = 0
end

function YingXiongSkillUp:reFreshCostFeicui()
	for i=2,5 do
		if self.cellsArr[i]~=nil then
			local _cellBg = self.cellsArr[i]:getChildByName("cellBg")
			if _cellBg:getChildByName("cost_bg") then
				local _costBg = _cellBg:getChildByName("cost_bg")
				local _costNumLabel_ = _costBg:getChildByName("costNumLabel")

				local _heroskillStr = self:getKeyStrFromTable("heroskill",i)
				local _skilladvanceStr = self:getKeyStrFromTable("skill_advance",i)

				local _skillLevelStr = self.hero_skill_level[_heroskillStr] or 0

				local _costNumStr = self._skillAdvanceTable[tostring(tonumber(_skillLevelStr))][_skilladvanceStr]

				_costNumLabel_:setString(getHugeNumberWithLongNumber(_costNumStr,100000))
				_costNumLabel_.costNum = tonumber(_costNumStr)
				if tonumber(_costNumStr)>tonumber(gameUser.getFeicui()) then
					_costNumLabel_:setColor(self:getSkillUpTextColor("hongse"))
					_costNumLabel_:enableShadow(self:getSkillUpTextColor("hongse"),cc.size(0.4,-0.4),0.4)
				else
					_costNumLabel_:setColor(cc.c3b(247,243,233))
					_costNumLabel_:enableShadow(cc.c3b(247,243,233),cc.size(0.4,-0.4),0.4)
				end
			end
		end
	end
end
--刷新技能等级和银两消耗数量
function YingXiongSkillUp:refreshSkillLevelAndCost()
	local _idxNum = self.selectedCellIdx
	if self.cellsArr[_idxNum]==nil then
		return
	end
	local _cellBg = self.cellsArr[_idxNum]:getChildByName("cellBg")

	local _skillLevel_label = _cellBg:getChildByName("skillLevel_label")
	
	local _skillItem = _cellBg:getChildByName("skillBg")

	local _heroskillStr = self:getKeyStrFromTable("heroskill",_idxNum)

	local _skillLevelStr = self.hero_skill_level[tostring(_heroskillStr)] or 0
	_skillLevel_label:setString(LANGUAGE_KEY_HERO_TEXT.LevelTitleTextXc .. ": " .. _skillLevelStr)
	local _func = function(_num)
		return (tonumber(_num)+1)/10
	end
	if _func(_skillLevelStr) ~= _func(tonumber(_skillLevelStr) - 1) then
		_skillItem:reFreshItemBg({level = _skillLevelStr})
	end
end

--获取英雄技能升级界面的文字颜色
function YingXiongSkillUp:getSkillUpTextColor(_str)
	-- local _nameColor = XTHD.resource.getQualityItemColor(self.itemInfoData["rank"])
	local _textColor = {
		hongse = cc.c4b(255,48,48,255),                           --红色
        shenhese = cc.c4b(70,34,34,255),                        --深褐色，用的比较多
        lanse = cc.c4b(26,158,207,255),                         --蓝色
        chenghongse = cc.c4b(205,101,8,255),                    --橙红色
        zongse = cc.c4b(128,112,91,255),                        --棕色，有点深灰色的感觉
        baise = cc.c4b(255,255,255,255),                        --白色
        lvse = cc.c4b(104,157,0,255),                           --绿色
        huise = cc.c4b(41,41,41,255),                           --灰色
	}
	return _textColor[_str]
end

function YingXiongSkillUp:create(heroData,YingXiongInfoLayer,_size)
	local _node = self.new(heroData,YingXiongInfoLayer,_size);
	return _node;
end

function YingXiongSkillUp:addGuide( )
	if #self._cellUpSkillBtn <= 1 then 
	    YinDaoMarg:getInstance():addGuide({ ----经验丹引导
	        parent = self.infoLayer,		
	        target = self._cellUpSkillBtn[1],
	        index = 5,
	        updateServer = true,
	    },5)
	end 
	performWithDelay(self._cellUpSkillBtn[1],function( )
			YinDaoMarg:getInstance():doNextGuide()   
			YinDaoMarg:getInstance():removeCover(self.infoLayer)
		end,0.1)

end

return YingXiongSkillUp