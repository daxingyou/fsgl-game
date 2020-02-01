local YingXiongLevelUp = class("YingXiongLevelUp", function()
	return XTHDPopLayer:create()
end)

function YingXiongLevelUp:onCleanup()
	-- for k,v in pair(self.btnArr) do
	-- 	v:removeAllChildren()
	-- 	v:release()
	-- end
	self.infoLayer = nil
	self:setCellArrRelease()
	YinDaoMarg:getInstance():removeCover(self.infoLayer)
end

function YingXiongLevelUp:ctor(heroData,YingXiongInfoLayer,_size)
	if _size ~=nil then
		--self:setTextureRect(cc.rect(0,0,_size.width,_size.height))
	end
	self.__addExpBtn = {}--------吃经验丹上的加号按钮们

	self.infoLayer = YingXiongInfoLayer
	self._oldFightValue = self.infoLayer.data.power or 0
    self._newFightValue = self._oldFightValue 
	--记录经验果使用次数
	self._use_count = 0
	self.levelup_fontSize = self.infoLayer._commonTextFontSize
	self.isContinus = false
	self.istopLevel = false
	self.isNoItem 	= false
	self.cellNumber = 0 		--cell的数量
	self.btnArr = {}			--存放经验按钮的数组
	self.scrolling = false 		--是否正在滚动
	self.preContentOffset = 0 	--前一次滚动偏移量
	self.level_heroData = {}	--存放升级后的经验数据等
	self.prelevel_heroData = {}	--存放初始的经验数据，以便在网络请求失败后可以恢复数值
	self.expStaticData = {} 	--经验道具数据
	self.itemNumberData = {} 	--道具数量
	local _level = gameUser.getLevel()
	
	local _levelData = gameData.getDataFromCSV("PlayerUpperLimit", {level = _level}) or {}
	self._top_level = _levelData and _levelData.maxlevel or 0

	-- self:createSpriteFrames()

	self:init(heroData)
	-- YinDaoMarg:getInstance():getACover(self.infoLayer)
end

function YingXiongLevelUp:init(heroData)
	self:setLevelData(heroData)

	for k,v in pairs(self.level_heroData) do
		self.prelevel_heroData[k] = v
	end
	local _bgWidth = self:getContentSize().width-8*2
	if self:getContentSize().width > 365 then
		_bgWidth = 365 - 8*2 + (self:getContentSize().width - 365)/3
	else
		--todo
	end
	local _bgSize = cc.size(_bgWidth ,self:getContentSize().height - 5)

	local levlebg = cc.Sprite:create("res/image/newHeroinfo/levlebg.png")
	self:addChild(levlebg)
	levlebg:setPosition(self:getContentSize().width *0.5,self:getContentSize().height *0.5)

	local _promptlabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.touchBtnNoMovePromptTextXc,self.levelup_fontSize)
	self.promptlabel = _promptlabel 
	_promptlabel:setColor(cc.c3b(200,15,15))
	_promptlabel:setAnchorPoint(cc.p(0.5,0.5))
	-- _promptlabel:setPosition(cc.p(27,self:getContentSize().height - 29))
	_promptlabel:enableShadow(self:getLevelUpTextColor("chenghongse"),cc.size(0.4,-0.4),1)
	_promptlabel:setPosition(cc.p(levlebg:getContentSize().width/2,levlebg:getContentSize().height - 15))
	levlebg:addChild(_promptlabel)

	local _leftPattern = cc.Sprite:create("res/image/common/titlepattern_left.png")
	_leftPattern:setAnchorPoint(cc.p(1,0.5))
	_leftPattern:setPosition(cc.p(_promptlabel:getBoundingBox().x-5,_promptlabel:getPositionY()))
	levlebg:addChild(_leftPattern)
	local _rightPattern = cc.Sprite:create("res/image/common/titlepattern_right.png")
	_rightPattern:setAnchorPoint(cc.p(0,0.5))
	_rightPattern:setPosition(cc.p(_promptlabel:getBoundingBox().x+_promptlabel:getBoundingBox().width + 5,_promptlabel:getPositionY()))
	levlebg:addChild(_rightPattern)


	self:setStaticItemData()
	self.cellNumber = #self.expStaticData

	self.tableViewSize = cc.size(levlebg:getContentSize().width - 60,levlebg:getContentSize().height - 55)
	self.tableViewCellSize = cc.size(self.tableViewSize.width ,self.tableViewSize.height/4)
	self.level_tableView = cc.TableView:create(self.tableViewSize)
	self.level_tableView:setBounceable(true)
	self.level_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self.level_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self.level_tableView:setDelegate()
	self.level_tableView:setPosition(30,28)
	levlebg:addChild(self.level_tableView)

	self.level_tableView:registerScriptHandler(
        function (table_view)
            return self.cellNumber
        end
    ,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	self.level_tableView:registerScriptHandler(
        function (table_view,idx)
            return self.tableViewCellSize.width, self.tableViewCellSize.height 
        end
    ,cc.TABLECELL_SIZE_FOR_INDEX)

	self.level_tableView:registerScriptHandler(
		function(view)
			self.scrolling = true
		end,cc.SCROLLVIEW_SCRIPT_SCROLL)

    self.level_tableView:registerScriptHandler(
    	function (table_view,idx)
    		local cell = table_view:dequeueCell()
    		if cell then
    			cell:removeAllChildren()
    		else
    			cell = cc.TableViewCell:create()
    		end
    		-- do return cell end
    		local _expBtn = nil
    		if not _expBtn then
    			_expBtn = self:create_exp_button(self.expStaticData[idx + 1],idx + 1)
	    		_expBtn:setAnchorPoint(cc.p(0.5,0.5))
	    		_expBtn:setPosition(cc.p(self.tableViewCellSize.width/2,self.tableViewCellSize.height/2))
	    		self.btnArr[idx+1] = _expBtn
	    		-- _expBtn:retain()
	    	else
	    		_expBtn:removeFromParent()
    		end
    		if idx ~= self.cellNumber-1 then
    			-- local _lineSp = ccui.Scale9Sprite:create( cc.rect( 0, 0, 3, 2 ), "res/image/ranklistreward/splitcell.png" )
				-- _lineSp:setContentSize(cc.size(self.tableViewCellSize.width - 2,2))
				-- _lineSp:setPosition(cc.p(self.tableViewCellSize.width/2,0))
				-- cell:addChild(_lineSp)
    		end
    		
    		
    		cell:addChild(_expBtn)

    		return cell
	    end
    ,cc.TABLECELL_SIZE_AT_INDEX)

    -- print("onEnteronEnteronEnteronEnter")
    self.level_tableView:reloadData()
end
--创建经验升级cell内容
function YingXiongLevelUp:create_exp_button(data,_btnId)
	-- local items_data = self.infoLayer.dynamicCostItemData[tostring(data["itemid"])] or {}

	local exp_btn_1 = ccui.Scale9Sprite:create("res/image/newHeroinfo/cellbg.png")
	exp_btn_1:setContentSize(cc.size(self.tableViewCellSize.width - 5*2,self.tableViewCellSize.height - 5))

	if _btnId == nil or data == nil then
		return exp_btn_1
	end
	local _itemCount = self.itemNumberData[_btnId]
	
	local equip_sp =  ItemNode:createWithParams({
        dbId =nil,
        itemId = data["itemid"],
        _type_ = 4,
        touchShowTip = false
    })
	equip_sp:setName("equipSp")
	equip_sp:setPosition((equip_sp:getBoundingBox().width *0.5)/ 2 + 15, exp_btn_1:getContentSize().height / 2 )
	equip_sp:setTouchEndedCallback(function()
--		local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
--	    popLayer= popLayer:create(data["itemid"])
--	    popLayer:setName("ItemDropPop")
--	    self.infoLayer:addChild(popLayer)
	end)
	equip_sp:setScale(0.5)
	exp_btn_1:addChild(equip_sp)
	
	--加号按钮
	--临时设成精灵，以后再改
	local addBtn = XTHDPushButton:createWithParams({
		normalFile = "res/image/common/btn/btn_add_normal.png",
		selectedFile = "res/image/common/btn/btn_add_selected.png",
		needEnableWhenOut = true,
		needSwallow = false,
		touchSize = cc.size(100,100),
		musicFile = XTHD.resource.music.effect_btn_common
	})
	addBtn:setScale(0.6)
	addBtn:setName("addBtn")
	addBtn:setAnchorPoint(cc.p(0.5,0.5))
	addBtn:setPosition(cc.p(exp_btn_1:getContentSize().width - 40,exp_btn_1:getContentSize().height/2))
	exp_btn_1:addChild(addBtn)
	self.__addExpBtn[#self.__addExpBtn + 1] = addBtn	
	--Name
	local equip_name = XTHDLabel:create(data["name"],self.levelup_fontSize - 2)
	equip_name:setColor(self:getLevelUpTextColor("shenhese"))
	equip_name:enableShadow(cc.c4b(70, 34, 34, 255),cc.size(0.4,-0.4),1)
	equip_name:setAnchorPoint(0,1)
	equip_name:setPosition(equip_sp:getBoundingBox().x + equip_sp:getBoundingBox().width + 10,
						  equip_sp:getBoundingBox().height +equip_sp:getBoundingBox().y - 5)
	exp_btn_1:addChild(equip_name)

	--道具数量
	local equip_number = getCommonWhiteBMFontLabel(_itemCount)
	equip_number:setScale(34/equip_number:getContentSize().height)
	equip_number:setName("equipNumber")

	equip_number:setAnchorPoint(1,0)
	-- equip_number:enableShadow(cc.c4b(0, 0,0, 255), cc.size(1,-1),2)
	equip_number:setPosition(equip_sp:getContentSize().width-7 ,-10)
	equip_sp:addChild(equip_number)

	--经验
	local expLabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.expTextXc,self.levelup_fontSize)
	expLabel:setColor(self:getLevelUpTextColor("shenhese"))
	expLabel:setAnchorPoint(cc.p(0,0))
	expLabel:setPosition(cc.p(equip_name:getPositionX(),equip_sp:getBoundingBox().y))
	exp_btn_1:addChild(expLabel)
	--增加经验值
	local equip_value = XTHDLabel:create("+" .. data["effectvalue"],self.levelup_fontSize)
    equip_value:enableShadow(self:getLevelUpTextColor("lvse"),cc.size(0.4,-0.4),1)
	equip_value:setColor(self:getLevelUpTextColor("lvse"))

	equip_value:setAnchorPoint(0,0)
	equip_value:setPosition(expLabel:getPositionX() + expLabel:getContentSize().width + 3 , expLabel:getPositionY())
	exp_btn_1:addChild(equip_value)

	local _expItemId = data["itemid"]

	--将经验进度条置为100
	local function setPercentageEmpty()
		local _expProcess = self.infoLayer.child_arr["exp_progress"]
		local _perValue = 100
	    _expProcess:setPercentage(_perValue)
	    self.infoLayer.child_arr["label_level"]:setString(self._top_level)
	    equip_number:setString(self.itemNumberData[_btnId])
	    if self:getScheduler() then
			self:unscheduleUpdate()
		end
		XTHDTOAST(LANGUAGE_TIPS_WORDS110)-------"英雄等级已达上限，无法继续升级")
	end
	--升级函数
	local function Add_exp(cur_data,_callback)
		for k,v in pairs(cur_data) do
			self.level_heroData[k]=v
		end
		
		local  target_percent = 100
		
		if tonumber(self.level_heroData["level"]) > tonumber(self._top_level) then
			self.level_heroData["level"] = self._top_level
			self.level_heroData["curexp"] = tonumber(self.level_heroData["maxexp"])
		end
		self:refreshLevelAndPlayAnimation(_btnId)
	end
	--判断等级和升级
	local function judgeLevelAndaddExp(_callback)
		--判断英雄等级是否达到上限
		if tonumber(self.level_heroData["level"])>tonumber( self._top_level) or (tonumber(self.level_heroData["level"])==tonumber( self._top_level) and tonumber(self.level_heroData["curexp"])>=tonumber(self.level_heroData["maxexp"])) then
			setPercentageEmpty()
			self._use_count = 0
			addBtn:setEnable(true)
			self.infoLayer:setButtonClickableState(true)
			return
		end
		local cur_data = self:getLevelInfo(tonumber(data["effectvalue"])+tonumber(self.level_heroData["curexp"]),tonumber(self.level_heroData["level"]))

		--当英雄使用持续升级，等级达到上限等级，自动停止。
		if tonumber(self.level_heroData["level"])<tonumber( self._top_level) and tonumber(cur_data["level"]) == tonumber( self._top_level) then
			self.istopLevel = true
			if self:getScheduler()  then
				self:unscheduleUpdate()
			end
			-- _callback = function()
			-- 	self:RequestNetAndRefreshData(self.level_heroData["heroid"],data["itemid"],_btnId)
			-- end
			self:RequestNetAndRefreshData(self.level_heroData["heroid"],_expItemId,_btnId)
			return

		end
		--判断经验是否会发生溢出状况
		if tonumber(cur_data["level"]) > tonumber( self._top_level) then
			self.istopLevel = true
			if self:getScheduler()  then
				self:unscheduleUpdate()
			end
			_callback = function()
				self:RequestNetAndRefreshData(self.level_heroData["heroid"],_expItemId,_btnId)
			end
			--弹出框添加close函数
			local _dialog = XTHDConfirmDialog:createWithParams({
					msg = LANGUAGE_KEY_HERO_TEXT.levelOutPopTextXc ,--提示框信息
			        closeCallback=function()
			        	self._use_count = self._use_count - 1
			        	_callback()
			        	-- if _callback then
			        	-- 	_callback()
			        	-- end
			        end
				})
			--如果是点击右边的确认按钮，调用fun函数，因为不需要调用close函数， 充值close函数为空，hide弹出框
			_dialog:setCallbackRight(function()
					_callback()
					_dialog:setCallbackClose()
					_dialog:hide()
					-- _dialog:hideCallback()
				end)
			self.infoLayer:addChild(_dialog,10)
		else
			if _callback then
				_callback()
			else
				if tonumber(self._use_count)>0 then
					Add_exp(cur_data)
				end
			end
			
		end
	end

	--使用经验果回调
	self.isContinus = false
	self.istopLevel = false
	self.isNoItem 	= false
	addBtn:setTouchBeganCallback(function()
	    ------------------------------------------------------------------
		self.scrolling = false
		self.infoLayer:setButtonClickableState(false)
		-- items_data = self.itemNumberData[_btnId]

		self._use_count = 0
		self.isContinus = false
		self.istopLevel = false
		self.isNoItem 	= false
		local t = 0
		local cd = 1
		
		self:scheduleUpdateWithPriorityLua(function(dt)
			t = t+dt 
			if t < cd then
				if self.scrolling then
					if self:getScheduler() then
						self:unscheduleUpdate()
					end
					self.infoLayer:setButtonClickableState(true)
				end
				return
			end 
			self.isContinus = true
			if tonumber(self.itemNumberData[_btnId])<=0 then
				if self:getScheduler() then
					self:unscheduleUpdate()
				end
				self.infoLayer:setButtonClickableState(true)
				self:noItemsDialog(data["itemid"])
				return
			end

			if self._use_count >= tonumber(self.itemNumberData[_btnId]) then
				self.isNoItem = true
				XTHDTOAST(LANGUAGE_TIPS_WORDS111)------"您的道具已经用完啦")
				self:RequestNetAndRefreshData(self.level_heroData["heroid"],_expItemId,_btnId)
				return
			elseif tonumber(self.infoLayer.child_arr["label_level"]:getString()) > tonumber(self._top_level) then
				self:RequestNetAndRefreshData(self.level_heroData["heroid"],_expItemId,_btnId)
				return
			end
			self._use_count = self._use_count +1
			judgeLevelAndaddExp()
			
		end, 0);
	end)
	addBtn:setTouchEndedCallback(function ()
	    ----引导
	    if YinDaoMarg:getInstance():getCurrentGuideLayer() then -----如果有引导
	    	self.scrolling = false
	    end 
	    local _group = YinDaoMarg:getInstance():getGuideSteps() 	    
	    YinDaoMarg:getInstance():guideTouchEnd()
	    if _group == 13 then -----引导大象升级
	    	YinDaoMarg:getInstance():releaseGuideLayer()
	    end 
	    ----------------------------
	    if self:getScheduler() then
			self:unscheduleUpdate()
		end
		--如果不是按住不动
		if not self.isContinus then
			self:playPromptAnimation()
			if self.scrolling then
				self.scrolling = false
				self.infoLayer:setButtonClickableState(true)
				return
			end
			if tonumber(self.itemNumberData[_btnId])<=0 then
				self:noItemsDialog(data["itemid"])
				if self:getScheduler() then
					self:unscheduleUpdate()
				end
				self.infoLayer:setButtonClickableState(true)
				return
			end
			self._use_count = 1
			addBtn:setEnable(false)
			judgeLevelAndaddExp(function()
				self:RequestNetAndRefreshData(self.level_heroData["heroid"],_expItemId,_btnId)
			end)
		--如果是按住不动，并且经验没有溢出，道具没有用完
		elseif not self.istopLevel and not self.isNoItem then
			if self._use_count<1 then
				self.infoLayer:setButtonClickableState(true)
				return
			end
			self:RequestNetAndRefreshData(self.level_heroData["heroid"],_expItemId,_btnId)
		end
	end)

	return exp_btn_1
end
-- --[=[
function YingXiongLevelUp:refreshLevelAndPlayAnimation(_btnIndex,_oldLevel)
	if _btnIndex == nil or self.btnArr[_btnIndex]==nil then
		return
	end
	local _itemCell = self.btnArr[_btnIndex]
	local _itemSp = nil
	
	if _itemCell:getChildByName("equipSp") then
		_itemSp = _itemCell:getChildByName("equipSp")
	end
	if _itemSp == nil then
		return
	end
	local _expProcess = self.infoLayer.child_arr["exp_progress"]
	local level_label = self.infoLayer.child_arr["label_level"]   --改变等级
	local target_percent = self.infoLayer:getExpPerValue(tonumber(self.level_heroData["curexp"]),tonumber(self.level_heroData["maxexp"]))
	local expLabelStr = self.level_heroData["curexp"] .. "/" .. self.level_heroData["maxexp"]
	local _isLevelUp = false
	if level_label~=nil then
		local _oldLevel_ = _oldLevel
		if _oldLevel_ == nil then
			_oldLevel_= tonumber(level_label:getString())
		end
		_isLevelUp = tonumber(self.level_heroData["level"])>_oldLevel_ and true or false
		level_label:setString(self.level_heroData["level"])
	end
	
	local _itemAniFunc = nil
	if _itemSp:getChildByName("animation_costSp")==nil then
		_itemAniFunc = function()
			local _animation_costSp = cc.Sprite:create("res/image/plugin/hero/levelupFrames/cost1.png")
			-- _animation_costSp:setBlendFunc(gl.SRC_ALPHA,gl.ONE )
			_animation_costSp:setName("animation_costSp")
			_animation_costSp:setPosition(cc.p(_itemSp:getContentSize().width/2+6,_itemSp:getContentSize().height/2+3))
			_itemSp:addChild(_animation_costSp)
			_animation_costSp:setScale(1.9)
			local _cost_animation = getAnimation("res/image/plugin/hero/levelupFrames/cost",1,4,0.07)
			_animation_costSp:runAction(cc.Sequence:create(_cost_animation,cc.CallFunc:create(function()
					_animation_costSp:removeFromParent()
				end)))
		end
	end
	if _isLevelUp == true then
		local _perValue = target_percent
		_expProcess:setPercentage(0)
         --需要添加升级动画
        if self.infoLayer.cellArr["1"] and self.infoLayer.cellArr["1"]:getChildByName("animation_sp") then
        	self.infoLayer.cellArr["1"]:getChildByName("animation_sp"):stopAllActions()
        	self.infoLayer.cellArr["1"]:getChildByName("animation_sp"):removeFromParent()
		end
		
		local animation_sp = sp.SkeletonAnimation:create( "res/image/plugin/hero/levelupFrames/shengjijuese.json", "res/image/plugin/hero/levelupFrames/shengjijuese.atlas", 1.0)
        animation_sp:setName("animation_sp")
        animation_sp:setAnchorPoint(cc.p(0.5,0))
		local page=self.infoLayer.heroPager:getCurrentPage()
        animation_sp:setPosition(self.infoLayer.tableViewSize.width/2,self.infoLayer.tableViewSize.height * 0.25)
		page:addChild(animation_sp)
		animation_sp:setAnimation(0,"shengjijuese",false)
		animation_sp:runAction(cc.Sequence:create(
        	cc.Spawn:create(cc.CallFunc:create(function()
        		musicManager.playEffect("res/sound/LelveUp.mp3")
        		_expProcess:stopAllActions()
                if tonumber(self._use_count)<2 then
               		self:setExpProgressValue(_expProcess,_perValue,expLabelStr,true)
           		else
           			self:setExpProgressValue(_expProcess,_perValue,expLabelStr)
           		end
           		if _itemAniFunc~=nil then
           			_itemAniFunc()
           		end
           	end))))
		
        -- local animation_sp = cc.Sprite:create()
        -- animation_sp:setName("animation_sp")
        -- animation_sp:setAnchorPoint(cc.p(0.5,0))
        -- animation_sp:setPosition(self.infoLayer.tableViewSize.width/2,-32+4)
        -- self.infoLayer.cellArr["1"]:addChild(animation_sp)
        -- local animation = getAnimation("res/image/plugin/hero/levelupFrames/",1,13,0.06)
        -- -- animation_sp:runAction(animation)
        -- animation_sp:setScale(1.4)
        -- animation_sp:runAction(cc.Sequence:create(
        -- 	cc.Spawn:create(animation,cc.CallFunc:create(function()
        -- 		musicManager.playEffect("res/sound/LelveUp.mp3")
        -- 		_expProcess:stopAllActions()
        --         if tonumber(self._use_count)<2 then
        --        		self:setExpProgressValue(_expProcess,_perValue,expLabelStr,true)
        --    		else
        --    			self:setExpProgressValue(_expProcess,_perValue,expLabelStr)
        --    		end
        --    		if _itemAniFunc~=nil then
        --    			_itemAniFunc()
        --    		end
        --    	end))
        --    	,cc.CallFunc:create(function()
        --    		if animation_sp then
        --    			animation_sp:removeFromParent()
        --    		end
        -- 	end)))
		
	else
		local _perValue = target_percent
		if tonumber(_expProcess:getPercentage()) >_perValue then
			_expProcess:setPercentage(0) 
		end
		local _delaytime = 0
		if _itemAniFunc~=nil then
   			_delaytime = 0.28
   		end
		self:runAction(cc.Sequence:create(cc.CallFunc:create(function()
				if _itemAniFunc~=nil then
	       			_itemAniFunc()
	       		end
	       		_expProcess:stopAllActions()
			    if tonumber(self._use_count)<2 then
			    	self:setExpProgressValue(_expProcess,_perValue,expLabelStr,true)
				else
					self:setExpProgressValue(_expProcess,_perValue,expLabelStr)
				end
			end)))
	end
	local _itemNumberLabel = nil
	--更改数量
	if _itemSp:getChildByName("equipNumber") then
		_itemNumberLabel = _itemSp:getChildByName("equipNumber")
	end
	if _itemNumberLabel == nil then
		return
	end
	--数量
	if tonumber(self._use_count)>0 then
		local _itemNum_str = tonumber(self.itemNumberData[_btnIndex])-tonumber(self._use_count)

		if _itemNum_str < 0 then
			_itemNum_str = 0
		end
		_itemNumberLabel:setString(tostring(_itemNum_str))
	end
end
-- ]=]

function YingXiongLevelUp:playPromptAnimation()
	if self.promptlabel == nil then
		return
	end
	if tonumber(gameUser.getLevel()) > 25 then
		return
	end
	self.promptlabel:setScale(1)
	self.promptlabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,2),cc.ScaleTo:create(0.2,1)))
end

function YingXiongLevelUp:setExpProgressValue(_target,_perValue,_labelStr,isAnimation)
	if _perValue ==nil or _target == nil then
		return
	end
	_target:stopAllActions()
	local _curPercent = tonumber(_target:getPercentage())
	if _curPercent >= tonumber(_perValue) then
		isAnimation = false
	end
	if isAnimation~=nil and isAnimation == true then
		_target:runAction(cc.ProgressTo:create(0.1,_perValue))
	else
		_target:setPercentage(_perValue)
	end
	
	if _target:getChildByName("expLabel") and _labelStr~=nil then
		_target:getChildByName("expLabel"):setString(_labelStr)
	end
end

function YingXiongLevelUp:noItemsDialog(_itemid)
	local callback = function()
		self.infoLayer:setLayerState("levelup_layer")
	end
	local _dialog = XTHDConfirmDialog:createWithParams({
		msg = LANGUAGE_KEY_HERO_TEXT.noItemsToGetTextXc
		,rightCallback = function()
		    local popLayer = requires("src/fsgl/layer/YingXiong/BuyExpByIngotPopLayer1.lua")
		    popLayer= popLayer:create(_itemid,self.infoLayer,nil,callback)
		    popLayer:setName("BuyExpPop")
		    self.infoLayer:addChild(popLayer,5)
		end
	})
	self.infoLayer:addChild(_dialog,10)
end
--使用经验果的网络请求
function YingXiongLevelUp:RequestNetAndRefreshData(_heroid,_itemId,_btnId)
	if self:getScheduler()  then
		self:unscheduleUpdate()
	end
	if tonumber(self._use_count) < 1  then
		self:setBtnEnable(_btnId)
		self.infoLayer:setButtonClickableState(true)
		return
	end
	self._oldFightValue = self.infoLayer.data.power or 0
    self._newFightValue = self._oldFightValue
    ClientHttp:httpHeroLevelUp(self,function(data)
    		self._use_count = 0
        	self:reFreshLevelUpData(data,_btnId)
        	
            XTHD._createFightLabelToast({
                oldFightValue = self._oldFightValue,
                newFightValue = self._newFightValue 
            })
            self._oldFightValue = self._newFightValue
            self.infoLayer:setButtonClickableState(true)
			self:setBtnEnable(_btnId)
			self:syncLevelData("success")
			self.infoLayer:setLayerState(self.infoLayer.state)
    	end,{itemId=_itemId , baseId=_heroid , param = tostring(self._use_count) , charType=1},function()
    		YinDaoMarg:getInstance():overCurrentGuide(true,self._guideGroup)------如果网络失败，除去引导层
	    	self.infoLayer:reFreshHeroInfo()
	    	self:resoreItemNumber(_btnId,_itemId)
	    	self:syncLevelData("failure")
			self:setBtnEnable(_btnId)
			self.infoLayer:setButtonClickableState(true)
    	end)
	-- ClientHttp:requestAsyncInGameWithParams({
	-- 	modules = "useItem?",
 --        params = {itemId=_itemId , baseId=_heroid , param = tostring(self._use_count) , charType=1},
 --        successCallback = function(data)
	--         if tonumber(data.result) == 0 then
 --            	self._use_count = 0
 --            	self:reFreshLevelUpData(data,_btnId)
            	
 --                XTHD._createFightLabelToast({
 --                    oldFightValue = self._oldFightValue,
 --                    newFightValue = self._newFightValue 
 --                })
 --                self._oldFightValue = self._newFightValue
 --                self.infoLayer:setButtonClickableState(true)
 --                -- self.infoLayer:refreshheroLayerCellHead()
 --                --如果滑动过快，这里可能出问题。
	-- 			self:setBtnEnable(_btnId)
	-- 			self:syncLevelData("success")
	--         else
	--             YinDaoMarg:getInstance():overCurrentGuide(true,5)------如果网络失败，除去引导层
	-- 	    	self.infoLayer:reFreshHeroInfo()
	-- 	    	self:resoreItemNumber(_btnId,_itemId)

	-- 			self:setBtnEnable(_btnId)
	-- 			self:syncLevelData("failure")
	--             XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
	--             self.infoLayer:setButtonClickableState(true)
	--         end        
 --        end,--成功回调
 --        failedCallback = function()
	--         YinDaoMarg:getInstance():overCurrentGuide(true,5)------如果网络失败，除去引导层
	--     	self.infoLayer:reFreshHeroInfo()
	--     	self:resoreItemNumber(_btnId,_itemId)
	--     	self:syncLevelData("failure")
	-- 		self:setBtnEnable(_btnId)
	-- 		self.infoLayer:setButtonClickableState(true)
 --            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
 --        end,--失败回调
 --        targetNeedsToRetain = nil,--需要保存引用的目标
 --        -- loadingParent = self,
 --        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
 --    })
end
--设置按钮可点击
function YingXiongLevelUp:setBtnEnable(_btnId)
	if self.btnArr[_btnId] and self.btnArr[_btnId]:getChildByName("addBtn") then
		self.btnArr[_btnId]:getChildByName("addBtn"):setEnable(true)
	end
end
--同步经验数据。success表示成功，failure表示失败
function YingXiongLevelUp:syncLevelData(_type)
	if _type == "success" then
		for k,v in pairs(self.level_heroData) do
			self.prelevel_heroData[k] = v
		end
	elseif _type == "failure" then
		for k,v in pairs(self.prelevel_heroData) do
			self.level_heroData[k] = v
		end
		local _expProcess = self.infoLayer.child_arr["exp_progress"]
		local _perValue = self.infoLayer:getExpPerValue(tonumber(self.level_heroData["curexp"]),tonumber(self.level_heroData["maxexp"]))
	    _expProcess:runAction(cc.ProgressTo:create(0.1,_perValue))
	    self.infoLayer.child_arr["label_level"]:setString(self.level_heroData.level)
	end
end
--恢复使用道具的数量
function YingXiongLevelUp:resoreItemNumber(_btnId,_itemId)
	if self.btnArr[_btnId] and self.btnArr[_btnId]:getChildByName("equipSp") and self.btnArr[_btnId]:getChildByName("equipSp"):getChildByName("equipNumber") then
		local _equipNumber = self.btnArr[_btnId]:getChildByName("equipSp"):getChildByName("equipNumber")
		local _itemNumber = DBTableItem.getData(gameUser.getUserId(),{["itemid"]=_itemId}) or {}
		_itemNumber = _itemNumber and _itemNumber.count or 0
		_equipNumber:setString(_itemNumber)
	end
end
--根据当前经验值、 当前等级 获取目标经验、目标等级
function YingXiongLevelUp:getLevelInfo(add_exp,_level)
	if not self._Exp_info then
		 self._Exp_info = gameData.getDataFromCSV("GeneralExpList")
	end
	local _target_level = tonumber(_level)
	local _target_last_exp = tonumber(add_exp)
	local _result_tab = {}
	local function _add_exp(exp,level)
		local max_exp = tonumber(self._Exp_info[tonumber(level)]["heroexperience"])
		if tonumber(exp) >= tonumber(max_exp) then
			exp = tonumber(exp) - tonumber(max_exp)
			_target_last_exp = exp
			_target_level = _target_level +1
			_add_exp(exp,tonumber(level)+1)
		else
			_result_tab["level"] = level
			_result_tab["curexp"] = exp
			_result_tab["maxexp"] = max_exp
		end
	end
	 _add_exp(tonumber(add_exp),tonumber(_level))
	 return _result_tab
end

function YingXiongLevelUp:setCellArrRelease()
	-- for i=1,#self.btnArr do
	-- 	self.btnArr[i]:release()
	-- 	self.btnArr[i]:removeAllChildren()
	-- 	self.btnArr[i]:removeFromParent()
	-- end
end

function YingXiongLevelUp:reFreshLevelUpData(data,_btnId)
	local _dbid = data["items"][1]["dbId"] or ""
	if  data["items"][1]["count"] and data["items"][1]["count"] > 0 then
		DBTableItem.updateCount(gameUser.getUserId(),data["items"][1],_dbid)
	else
		--如果已经全部用完，则需要从数据库删除该条数据
		DBTableItem.deleteData(gameUser.getUserId(),_dbid)
	end
	local property = data.property
	if property then
		for i=1,#property do
			local _tab = string.split(property[i],',')
			DBTableHero.updateDataByPropId(gameUser.getUserId(), _tab[1],_tab[2],data["baseId"]);
			if tonumber(_tab[1]) == 407 then
                self._newFightValue = tonumber(_tab[2])
            end
		end
	end
	if self.infoLayer ==nil then
		return
	end

	local _oldLevel = nil
	if self.infoLayer.child_arr["label_level"] then
		_oldLevel = tonumber(self.infoLayer.child_arr["label_level"]:getString())
	end
	self.infoLayer:setButtonClickableState(true)
	self.infoLayer:refreshInfoLayer(data["baseId"],"noEquipInfo")
	self:setLevelData(self.infoLayer.data)
	self:setItemNumber()
	if _btnId~=nil then
		self:refreshLevelAndPlayAnimation(_btnId,_oldLevel)
	end
	if tonumber(data["baseId"])==tonumber(self.infoLayer.data.heroid) then
        
        self:reFreshHeroFunctionInfo()
    end
end

function YingXiongLevelUp:reFreshHeroFunctionInfo()
	self:setItemNumber()

	for i=1,self.cellNumber do
		if self.btnArr[i]~=nil then
			local _expBg = self.btnArr[i]
			if _expBg:getChildByName("equipSp") then
				local _expSp = _expBg:getChildByName("equipSp")
				if _expSp:getChildByName("equipNumber") then
					local _equipNum = _expSp:getChildByName("equipNumber")
					_equipNum:setString(self.itemNumberData[i])
				end
			end
		end
	end
end

function YingXiongLevelUp:setLevelData(_data)
	if _data == nil then
		return
	end
	self.level_heroData = {}
	self.level_heroData.heroid = _data.heroid
	self.level_heroData.level = _data.level
	self.level_heroData.curexp = _data.curexp
	self.level_heroData.maxexp = _data.maxexp
end

function YingXiongLevelUp:setStaticItemData()
	self.expStaticData = {}
	local _itemTable = gameData.getDataFromCSV("ArticleInfoSheet",{effecttype = 5})
	for k,v in pairs(_itemTable) do
		if v.effecttype == 5 then
			self.expStaticData[#self.expStaticData + 1] = v
		end
	end
	table.sort(self.expStaticData,function(data1,data2)
		return tonumber(data1.itemid)<tonumber(data2.itemid)
		end)
	self:setItemNumber()
end

function YingXiongLevelUp:setItemNumber()
	self.itemNumberData = {}
	local _numberData = self.infoLayer.dynamicCostItemData or {}
	for i=1,#self.expStaticData do
		local _table = _numberData[tostring(self.expStaticData[i].itemid)] or {}
		self.itemNumberData[i] = _table.count or 0
	end
end

--获取英雄升级界面的文字颜色
function YingXiongLevelUp:getLevelUpTextColor(_str)
	-- local _nameColor = XTHD.resource.getQualityItemColor(self.itemInfoData["rank"])
	local _textColor = {
		hongse = cc.c4b(204,2,2,255), 							--红色
		shenhese = cc.c4b(70,34,34,255),						--深褐色，用的比较多
		lanse = cc.c4b(26,158,207,255),							--蓝色
		chenghongse = cc.c4b(205,101,8,255),					--橙红色
		zongse = cc.c4b(128,112,91,255), 						--棕色，有点深灰色的感觉
		baise = cc.c4b(255,255,255,255),                        --白色
		lvse = cc.c4b(104,157,0,255),                           --绿色
	}
	return _textColor[_str]
end

function YingXiongLevelUp:create(heroData,YingXiongInfoLayer,_size)

	local _node = self.new(heroData,YingXiongInfoLayer,_size);
	return _node;
end

function YingXiongLevelUp:onEnter( )
	----------引导
	self:addGuide()
	----------------------------------------------------
end

function YingXiongLevelUp:addGuide( )
	-- if gameUser.getInstancingId() == 12 then ----第10组引导 
	-- 	if #self.__addExpBtn > 0 then 
	-- 	    YinDaoMarg:getInstance():addGuide({ ----经验丹引导
	-- 	        parent = self.infoLayer,
	-- 	        target = self.__addExpBtn[2],
	-- 	        index = 6,
	-- 	        updateServer = true,
	-- 	    },10)
	-- 	    self._guideGroup = 10
	-- 	end 
	-- elseif gameUser.getInstancingId() == 21 then ----第13组引导 
	-- 	if #self.__addExpBtn > 0 then 
	-- 	    YinDaoMarg:getInstance():addGuide({ ----经验丹引导
	-- 	        parent = self.infoLayer,
	-- 	        target = self.__addExpBtn[2],
	-- 	        index = 6,
	-- 	    },13)
	-- 	    self._guideGroup = 13
	-- 	end 
	-- end 
 --    performWithDelay(self.__addExpBtn[2],function( )
	-- 	YinDaoMarg:getInstance():doNextGuide()   
	-- 	YinDaoMarg:getInstance():removeCover(self.infoLayer)
 --    end,0.1)
end

return YingXiongLevelUp