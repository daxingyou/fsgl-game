--[=[
	FileName:YingXiongResetPopLayer.lua
	Date:2015.11.12
	Content:重置英雄弹出框
]=]
local YingXiongResetPopLayer = class("YingXiongResetPopLayer",function(sParams)
        return requires("src/fsgl/layer/BangPai/BangPaiXinXi.lua"):create(sParams)
	end)

function YingXiongResetPopLayer:noItemsDialog(_itemid)
	local _dialog = XTHDConfirmDialog:createWithParams({
		msg = LANGUAGE_KEY_HERO_TEXT.noItemsToGetTextXc
		,rightCallback = function()
			local popLayer = requires("src/fsgl/layer/YingXiong/BuyExpByIngotPopLayer1.lua")
			popLayer= popLayer:create(_itemid, self)
			popLayer:setName("BuyExpPop")
			self:addChild(popLayer)
		end
	})
	self:addChild(_dialog)
end

-- 购买重生令牌回调
function YingXiongResetPopLayer:refreshBuyLabel()
	-- body
end

function YingXiongResetPopLayer:init(_data,_infoLayer)
    self.infoLayer = _infoLayer
    self.resetData = {}
    self.redBtn = {}            --红色点按钮
    self.backMaterials = {}         --退还材料
    self.resetType = nil
    self:setResetData(_data)

	local popNode  = self._popNode

    local _closeBtn = XTHD.createBtnClose(function()
        self:hide()
    end)
    _closeBtn:setPosition(cc.p(popNode:getContentSize().width-10,popNode:getContentSize().height-10))
    popNode:addChild(_closeBtn)

	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=35});
            self:addChild(StoredValue)
        end,
	})
	popNode:addChild(help_btn)
	help_btn:setPosition(help_btn:getContentSize().width - 10,popNode:getContentSize().height - help_btn:getContentSize().height + 10)

    local getBtnNode = function(_path)
    	local _node = ccui.Scale9Sprite:create(cc.rect(50,0,30,49),_path)
    	_node:setContentSize(cc.size(222,49))
    	return _node 
	end
    -- local _resetBtn = XTHD.createCommonButton({
	-- 		btnColor = "blue",
	-- 		btnSize = cc.size(130, 46),
	-- 		fontSize = 20,
	-- 		text = LANGUAGE_BTN_KEY.startReset,
	-- 		anchor = cc.p(0.5, 0.5),
	-- 	})

	local _resetBtn = XTHD.createButton({
			normalFile = "res/image/common/btn/kscs_up.png",
			selectedFile = "res/image/common/btn/kscs_down.png",
		})
	_resetBtn:setTouchEndedCallback(function()
		current_num = 0
		if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2305}) then
			current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2305}).count or 0
		end
		if current_num < self.needItemCount then
			self:noItemsDialog(2305)
		else
			_resetBtn:setClickable(false)
			self:resetBtnCallback(_resetBtn)
		end
	end)
	_resetBtn:setPosition(cc.p(popNode:getContentSize().width/2,50))
	--_resetBtn:getLabel():setPositionX(_resetBtn:getLabel():getPositionX()-15)
	--_resetBtn:getLabel():setPositionY(_resetBtn:getLabel():getPositionY()-10)

    popNode:addChild(_resetBtn)

    --onehand
    local _onePosYUp = popNode:getContentSize().height - 44 - 20
    --level
    local _levelTitle = XTHDLabel:create(LANGUAGE_KEY_LEVEL .. " : ",18)
    _levelTitle:setColor(XTHD.resource.color.gray_desc)
    _levelTitle:setAnchorPoint(cc.p(0,0.5))
    _levelTitle:setPosition(cc.p(75,_onePosYUp))
    popNode:addChild(_levelTitle)
    local _oldlevel = XTHDLabel:create(self.resetData.level or 1,18)
    _oldlevel:setColor(XTHD.resource.color.gray_desc)
    _oldlevel:setAnchorPoint(cc.p(0,0.5))
    _oldlevel:setPosition(cc.p(_levelTitle:getBoundingBox().x+_levelTitle:getBoundingBox().width,_onePosYUp))
    popNode:addChild(_oldlevel)
    local _levelArrow = cc.Sprite:create("res/image/plugin/hero/hero_propertyadd.png")
	_levelArrow:setRotation(90)
	_levelArrow:setAnchorPoint(cc.p(0.5,0))
	_levelArrow:setPosition(cc.p(_oldlevel:getBoundingBox().x+_oldlevel:getBoundingBox().width + 10,_onePosYUp))
	popNode:addChild(_levelArrow)
	local _newLevel = XTHDLabel:create(1,18)
	_newLevel:setColor(XTHD.resource.color.gray_desc)
	_newLevel:setAnchorPoint(cc.p(0,0.5))
	_newLevel:setPosition(cc.p(_levelArrow:getBoundingBox().x+_levelArrow:getBoundingBox().width + 10,_onePosYUp))
	popNode:addChild(_newLevel)
	--advance
	local _advanceTitle = XTHDLabel:create(LANGUAGE_KEY_ADVANCE .. " : ",18)
    _advanceTitle:setColor(XTHD.resource.color.gray_desc)
    _advanceTitle:setAnchorPoint(cc.p(0,0.5))
    _advanceTitle:setPosition(cc.p(_levelTitle:getBoundingBox().x+200,_onePosYUp))
    popNode:addChild(_advanceTitle)
    local _oldadvance = XTHDLabel:create(self.resetData.advance - 1 or 1,18)
    _oldadvance:setColor(XTHD.resource.color.gray_desc)
    _oldadvance:setAnchorPoint(cc.p(0,0.5))
    _oldadvance:setPosition(cc.p(_advanceTitle:getBoundingBox().x+_advanceTitle:getBoundingBox().width,_onePosYUp))
    popNode:addChild(_oldadvance)
    local _advanceArrow = cc.Sprite:create("res/image/plugin/hero/hero_propertyadd.png")
	_advanceArrow:setRotation(90)
	_advanceArrow:setAnchorPoint(cc.p(0.5,0.5))
	_advanceArrow:setPosition(cc.p(_oldadvance:getBoundingBox().x+_oldadvance:getBoundingBox().width+10,_onePosYUp))
	popNode:addChild(_advanceArrow)
	local _newadvance = XTHDLabel:create(0,18)
	_newadvance:setColor(XTHD.resource.color.gray_desc)
	_advanceArrow:setAnchorPoint(cc.p(0.5,0))
	_newadvance:setPosition(cc.p(_advanceArrow:getBoundingBox().x+_advanceArrow:getBoundingBox().width + 10,_onePosYUp))
	popNode:addChild(_newadvance)
	--技能点
	local _onePosYDown = _onePosYUp - 30
	local _skillTitle = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.backSkillPointTextXcNo,18)----------------------返还技能点
    _skillTitle:setColor(XTHD.resource.color.gray_desc)
    _skillTitle:setAnchorPoint(cc.p(0.5,0.5))
    
    --local _oldskill = XTHDLabel:create(self.resetData.skillPoint or 0,18)----------------------------------------------返还技能点数量
    --_oldskill:setColor(XTHD.resource.color.gray_desc)
   -- _oldskill:setAnchorPoint(cc.p(0,0.5))
    _skillTitle:setPosition(cc.p(popNode:getContentSize().width/2  ,_onePosYDown))
   -- _oldskill:setPosition(cc.p(_skillTitle:getBoundingBox().x+_skillTitle:getBoundingBox().width,_onePosYDown))

    popNode:addChild(_skillTitle)
    --popNode:addChild(_oldskill)

    --backMaterial
    local _backItemsTitleBg = ccui.Scale9Sprite:create(cc.rect(20,0,10,32),"res/image/common/scale9_bg_27.png")
    _backItemsTitleBg:setContentSize(cc.size(450,32))
    _backItemsTitleBg:setAnchorPoint(cc.p(0.5,1))
    _backItemsTitleBg:setPosition(cc.p(popNode:getContentSize().width/2,_onePosYUp-50))
    popNode:addChild(_backItemsTitleBg)
    local _backtitleName = XTHDLabel:create("退还材料",20)
    _backtitleName:setColor(cc.c4b(180,42,0,255))
    _backtitleName:enableShadow(cc.c4b(180,42,0,255),cc.size(0.5,-0.5),0.5)
    _backtitleName:setPosition(cc.p(_backItemsTitleBg:getContentSize().width/2,_backItemsTitleBg:getContentSize().height/2))
    _backItemsTitleBg:addChild(_backtitleName)

    local _backItemUpPosY = 165
    -- local _backPartBg = self:setBackMaterilSp("part")
    -- _backPartBg:setAnchorPoint(cc.p(0.5,1))
    -- _backPartBg:setPosition(cc.p(popNode:getContentSize().width/2,_backItemUpPosY))  ------------删除60%档
    -- popNode:addChild(_backPartBg)

    local _backPerBg = self:setBackMaterilSp("perfect")
    _backPerBg:setAnchorPoint(cc.p(0.5,1))
    _backPerBg:setPosition(cc.p(popNode:getContentSize().width/2,_backItemUpPosY))--_backPartBg:getBoundingBox().y -9))
    popNode:addChild(_backPerBg)

	local _backItemNum = #self.resetData["list"] or 0
    local _backSubPos = self:getBackMaterialPos(_backItemNum,cc.size(popNode:getContentSize().width,_backItemsTitleBg:getBoundingBox().y-_backItemUpPosY))
    self.backMaterials = {}
    for i=1,_backItemNum do
    	-- local _itemData = string.split(self.resetData["list"][i],",")
    	local _backItem = ItemNode:createWithParams({
    		_type_ = self.resetData["list"][i].itemType,
			itemId = self.resetData["list"][i].itemId,
			count = self.resetData["list"][i].count or 0,
			isShowCount = true,
    	})
    	_backItem:setScale(60/_backItem:getContentSize().width)
    	self.backMaterials[i] = _backItem
    	_backItem:setPosition(cc.p(_backSubPos[i].x,_backSubPos[i].y + _backItemUpPosY))
    	popNode:addChild(_backItem)
    end

	--self:selectedCallback("part")                                                --------------------------删除60%档
	self:selectedCallback("perfect")
	self:show()
end

function YingXiongResetPopLayer:setBackMaterilSp(_typeStr)
	local _goldStr = "ptNeedGold"
	local _textId = 1 
	if _typeStr == "part" then
		_goldStr = "ptNeedGold"
		_textId = 1
	elseif _typeStr == "perfect" then
		_goldStr = "wmNeedGold"
		_textId = 2
	else
		return
	end
	local _backDescSize = cc.size(440,37)
    local _redPointPosX = 120
    local _backNormal = ccui.Scale9Sprite:create(cc.rect(15,15,1,1),"res/image/common/scale9_bg_5.png")
    _backNormal:setContentSize(_backDescSize)
    local _redPointNormal = cc.Sprite:create("res/image/common/btn/btn_redPoint_normal.png")
    _redPointNormal:setPosition(cc.p(_redPointPosX,_backNormal:getContentSize().height/2))
    _backNormal:addChild(_redPointNormal)
    local _backSelected = ccui.Scale9Sprite:create(cc.rect(15,15,1,1),"res/image/common/scale9_bg_5.png")
    _backSelected:setContentSize(_backDescSize)
    local _redPointSelected = cc.Sprite:create("res/image/common/btn/btn_redPoint_selected.png")
    _redPointSelected:setPosition(cc.p(_redPointPosX,_backSelected:getContentSize().height/2))
    _backSelected:addChild(_redPointSelected)

    local _backPartBg = XTHD.createButton({
    		normalNode = _backNormal,
    		selectedNode = _backSelected,
    		endCallback = function()
    			self:selectedCallback(_typeStr)
	    	end
    	})
    local _partPosY = _backPartBg:getContentSize().height/2
    self.redBtn[_typeStr] = _backPartBg
    local _ingoltSp = cc.Sprite:create("res/image/common/cslpicon1.png")
    _ingoltSp:setPosition(cc.p(155,_partPosY))
	_backPartBg:addChild(_ingoltSp)
	
	local resetNum = self.needItemCount --(self.resetData[tostring(_goldStr)] or 0)

    local _ingoltValue = XTHDLabel:create(resetNum.." "..LANGUAGE_HERORESET_KEY_BACKMATERIAL[tonumber(_textId)], 20)
    _ingoltValue:setColor(XTHD.resource.color.gray_desc)
    _ingoltValue:setAnchorPoint(cc.p(0,0.5))
    _ingoltValue:setPosition(cc.p(_ingoltSp:getBoundingBox().x+_ingoltSp:getBoundingBox().width,_partPosY))
    _backPartBg:addChild(_ingoltValue)

	return _backPartBg
end

function YingXiongResetPopLayer:getBackMaterialPos(_posNum,_backSize)
	if _posNum ==nil or _backSize == nil then
		return
	end
	local _midPosX = _backSize.width/2
	local _midPosY = _backSize.height/2+3
	local _sortNum = tonumber(_posNum)
	if tonumber(_posNum)>5 then
		_midPosY = _backSize.height - 38
		_sortNum = 5
	end
	local backPos = {}
	backPos = SortPos:sortFromMiddle(cc.p(_midPosX,_midPosY),_sortNum,15+30+30)
	if _sortNum < _posNum then
		for i=5+1,_posNum do
			backPos[i] = cc.p(backPos[tonumber(i-5)].x,_midPosY - 10-60)
		end
	end
	-- dump(backPos)
	return backPos
end

-- 开始重生
function YingXiongResetPopLayer:resetBtnCallback(_target)
    ClientHttp:httpHeroReset(self,function(data)
            gameUser.setFeicui(data.feicui)
            gameUser.setIngot(data.ingot)
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
			self:refreshHttpData(data)
			self:showRefreshBackItem()
            XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.resetSuccessToastXc)
        end,{petId=self.resetData.heroid,resetType = self.resetType},function()
            if _target ~=nil then
                _target:setClickable(true)
            end
        end)
	-- ClientHttp:requestAsyncInGameWithParams({
 --    	modules = "resetPet?",
 --        params = {petId=self.resetData.heroid,resetType = self.resetType},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
 --        successCallback = function(data)
 --            if tonumber(data.result) == 0 then
 --            	gameUser.setFeicui(data.feicui)
 --            	gameUser.setIngot(data.ingot)
 --            	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
 --            	self:refreshHttpData(data)
 --            	XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.resetSuccessToastXc)
 --            else
 --                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
 --                if _target ~=nil then
 --                    print("shatter>>>>55558855")
 --                    _target:setClickable(true)
 --                end
 --            end
            
 --        end,--成功回调
 --        failedCallback = function()
 --            if _target ~=nil then
 --                print("shatter>>>>55558855>>264")
 --                _target:setClickable(true)
 --            end
 --            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
 --        end,--失败回调
 --        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
 --    })
end

function YingXiongResetPopLayer:refreshHttpData(_data)
	-- dump(data,"重生")
	--经验
	DBTableHero.updateHeroData(gameUser.getUserId(), _data.level, _data.petId, "level")
	DBTableHero.updateHeroData(gameUser.getUserId(), _data.curExp, _data.petId, "curexp")
	DBTableHero.updateHeroData(gameUser.getUserId(), _data.maxExp, _data.petId, "maxexp")
	DBTableHero.updateHeroData(gameUser.getUserId(), _data.phaseLevel, _data.petId, "advance")
	DBTableHero.updateHeroData(gameUser.getUserId(), _data.power, _data.petId, "power")
	DBTableHero.DBData[self.resetData.heroid].petVeins = {}

	for i=1,#_data.bagItems do
		DBTableItem.updateCount(gameUser.getUserId(),_data.bagItems[i], _data.bagItems[i]["dbId"])
		DBTableEquipment.deleteData(gameUser.getUserId(), tostring( _data.bagItems[i]["dbId"]))
	end
    for k,v in pairs(_data.property) do
    	DBTableHero.updateDataByPropId( gameUser.getUserId(), k,v,_data["petId"]);
    end

    for i=1,#_data["items"] do
        local _dbid = _data.items[i].dbId
        DBTableItem.updateCount(gameUser.getUserId(),_data.items[i],_dbid)
    end

    local HeroSkillParam = {}
	HeroSkillParam["heroid"] = tostring(_data["petId"])
	HeroSkillParam["talentlv"] = _data["skills"][1]
	HeroSkillParam["skillidlv"] = _data["skills"][2]
	HeroSkillParam["skillid0lv"] = _data["skills"][3]
	HeroSkillParam["skillid1lv"] = _data["skills"][4]
	HeroSkillParam["skillid2lv"] = _data["skills"][5]
	HeroSkillParam["skillid3lv"] = _data["skills"][6]
	DBTableHeroSkill.insertData(gameUser.getUserId(), HeroSkillParam)

	--神兽
	for i=1,#_data["godProperty"] do
        DBTableArtifact.analysDataAndUpdate(_data.godProperty[i])
    end

    RedPointManage:setDynamicData()
    RedPointManage:resetRecruitHeroPoint()
    self.infoLayer:refreshInfoLayer(_data.petId)
	self.infoLayer:reFreshLeftLayer()

	self:hide()
end

function YingXiongResetPopLayer:selectedCallback(_typeStr)
	local _selectedStr = "part"
	local _normalStr = "perfect"
	if _typeStr == "part" then
		_textId = 1
		_selectedStr = "part"
		_normalStr = "perfect"
		self.resetType = 1
	elseif _typeStr == "perfect" then
		_textId = 2
		_selectedStr = "perfect"
		_normalStr = "part"
		self.resetType = 2
	else
		return
	end
	if self.redBtn[_selectedStr] ~=nil then
		self.redBtn[_selectedStr]:setSelected(true)
	end
	if self.redBtn[_normalStr] ~=nil then
		self.redBtn[_normalStr]:setSelected(false)
	end
	self:refreshBackItemNumber(_typeStr)
end
function YingXiongResetPopLayer:refreshBackItemNumber(_typeStr)
	if self.backMaterials== nil or next(self.backMaterials)==nil or #self.backMaterials <1 then
		return
	end
	local _numberFactor = 1
	if _typeStr~=nil and _typeStr == "part" then
		_numberFactor = 0.6
	end
	for i=1,#self.backMaterials do
		if self.backMaterials[i]~=nil then
			local _itemData = string.split(self.resetData.list[i],",")
			local _newNum = math.floor(tonumber(self.resetData.list[i].count or 0)*_numberFactor+0.5)
			self.backMaterials[i]:setCountNumber(_newNum)
		end
	end
end

function YingXiongResetPopLayer:showRefreshBackItem()
	if self.backMaterials== nil or next(self.backMaterials)==nil or #self.backMaterials <1 then
		return
	end
	local show = {} -- 奖励展示
	for i=1,#self.backMaterials do
		local item = self.backMaterials[i]
		if item ~= nil then
			show[i] = {}
			show[i].rewardtype = item._type_
			show[i].id = item.itemId
			show[i].num = item.count
		end
	end

	ShowRewardNode:create(show)
end

function YingXiongResetPopLayer:setResetData(_data)
	self.resetData = {}
	if _data == nil or next(_data)==nil then
		return
	end
	self.needItemCount = _data.needItemCount
	-- dump(_data)
	local _listData = {}
	for i=1,#_data.list do
		local _elementData = string.split(_data.list[i],",")
		_listData[i] = {}
		_listData[i].itemId = _elementData[1]
		_listData[i].count = _elementData[2] or 0
        _listData[i].itemType = XTHD.resource.type.item
	end
	self.resetData = _data
	self.resetData.list = _listData
    if _data.returnFeicui~=nil and tonumber(_data.returnFeicui) >0 then
        local _index = #self.resetData.list + 1
        self.resetData.list[_index] = {}
        self.resetData.list[_index].itemId = 0
        self.resetData.list[_index].count = _data.returnFeicui
        self.resetData.list[_index].itemType = XTHD.resource.type.feicui
    end
end

function YingXiongResetPopLayer:create( _data,_infoLayer ) -- {BangPaiFengZhuangShuJu}
    local params = {
        size = cc.size(460-4,480),
        titleNode = cc.Sprite:create("res/image/plugin/hero/heroReset_title.png"),
    }
    local pLay = YingXiongResetPopLayer.new( params )
    pLay:init(_data,_infoLayer)
    LayerManager.addLayout(pLay,{noHide = true})
    return pLay
end


function YingXiongResetPopLayer:onEnter( )
	
end

return YingXiongResetPopLayer