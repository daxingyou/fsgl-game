--以下英雄未拥有 255,210,80
local YingXiongAdvanceNode = class("YingXiongAdvanceNode", function()
	local select_sp = XTHD.createFunctionLayer()
    return select_sp
end)

function YingXiongAdvanceNode:ctor(heroData,YingXiongInfoLayer)
	
	self.infoLayer = YingXiongInfoLayer 					--主页面

	self.current_advance = 1
	self.hero_id = 0

	self.advance_fontSize = self.infoLayer._commonTextFontSize

	self._costInfo_advance = {} 			        --进阶消耗数据

	self._oldFightValue = self.infoLayer.data["power"] or 0 	--老的战斗力
	self._newFightValue = self._oldFightValue 	    --新的战斗力
	self.maxAdvanceNum = 1 					        --最大可进阶数

	self.unlockSkillLabel = nil 			        --解锁技能label

	self.current_number_arr = {} 			        --当前值的数组
	self.add_number_arr = {} 				        --进阶后的数组
	self.hero_advance_data = nil
	self.data = nil

	self.label_name_arr = {}				        --存放属性名称
	self.totalContentSize = 0 				        --scrollview的内容高度

	-- self.feicuiCost_bg = nil 				        --翡翠消耗背景
	self.costTitle_bg = nil 				        --消耗背景
	self.costItemName_label = nil 			        --翡翠名称
	self.costItemNum_label = nil 			        --翡翠数量
	self.costotherItemName_label = nil 		        --其他消耗品名称
	self.costotherItemNum_label = nil 		        --其它消耗品数量
	self.advance_up_btn = nil 				        --进阶按钮
	self._labelTexture = nil 				        --标题背景纹理
    self.costBg = nil
    self._guideADVItemNode = nil                    ------进阶绿灵

    self._advanceBtn_effect = nil                      --进阶按钮特效

	self._promptPosY = 100

	self.detail_ziduan = {
		[1]={key="hp",desc= LANGUAGE_KEY_ATTRIBUTESNAME(200)},-------"生命加成"},
        [2]={key="physicalattack",desc=LANGUAGE_KEY_ATTRIBUTESNAME(201)},----"物攻加成"},
        [3]={key="physicaldefence",desc=LANGUAGE_KEY_ATTRIBUTESNAME(202)},----"物防加成"},
        [4]={key="manaattack",desc=LANGUAGE_KEY_ATTRIBUTESNAME(203)},----"魔攻加成"},
        [5]={key="manadefence",desc=LANGUAGE_KEY_ATTRIBUTESNAME(204)},----"魔防加成"},
	 }

	self:init(heroData)
    YinDaoMarg:getInstance():getACover(self.infoLayer)
end

function YingXiongAdvanceNode:onCleanup()
    YinDaoMarg:getInstance():removeCover(self.infoLayer)    
end

function YingXiongAdvanceNode:init(heroData)
	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=41});
            cc.Director:getInstance():getRunningScene():addChild(StoredValue)
        end,
	})
	help_btn:setScale(0.5)
	self:addChild(help_btn)
	help_btn:setPosition(self:getContentSize().width - help_btn:getBoundingBox().width *0.5 - 5,self:getContentSize().height - help_btn:getBoundingBox().height*0.5 - 5)


	self.data = clone(heroData)
	self.current_advance = self.data["advance"]

	self.hero_id = self.data["heroid"]
	self.hero_advance_data = {}
    if self.infoLayer.otherStaticAdvanceData==nil or next(self.infoLayer.otherStaticAdvanceData)==nil then
        self.infoLayer:setOtherStaticDBData()
    end
	self.hero_advance_data = clone(self.infoLayer.otherStaticAdvanceData[tostring(self.hero_id)] or {})
	--进阶消耗数据
	self._costInfo_advance = {}
	self._costInfo_advance = self:getAdvanceCostInfo(self.hero_id,self.current_advance)

	self:setMaxAdvanceNumber(self.hero_advance_data)

	--UI

    local _propertyBgPosY = 225-13

    --[[属性变化]]
    local _heroPropertyTitle_bg = cc.Sprite:create("res/image/newHeroinfo/shuxingbg2.png")
    _heroPropertyTitle_bg:setPosition(cc.p(_heroPropertyTitle_bg:getContentSize().width/2 + 15,self:getContentSize().height *0.5 - 5))
    self:addChild(_heroPropertyTitle_bg)
	self.__heroPropertyTitle_bg = _heroPropertyTitle_bg
    --value
    local _propertyContentSize = cc.size(_heroPropertyTitle_bg:getContentSize().width,_heroPropertyTitle_bg:getContentSize().height - 60)
    self.propertyContentSize = _propertyContentSize

    self.property_bg = ccui.ListView:create()
    self.property_bg:setBounceEnabled(false)
	self.property_bg:setAnchorPoint(0.5,0.5)
    self.property_bg:setDirection(ccui.ScrollViewDir.vertical)
    self.property_bg:setTouchEnabled(true)
	self.property_bg:setScrollBarEnabled(false)
    self.property_bg:setContentSize(_propertyContentSize)
    self.property_bg:setPosition(_propertyContentSize.width *0.5,_propertyContentSize.height *0.5 + 10)
    _heroPropertyTitle_bg:addChild(self.property_bg)
    --技能解锁skillLabel
    self:createUnlockSkillLabel()
    --属性变化
    self:setPropertyPart(self.data)

    --进阶消耗框
    local kuang2 = ccui.Scale9Sprite:create("res/image/newHeroinfo/itemkuang.png")
    kuang2:setPosition(cc.p(self:getContentSize().width - kuang2:getContentSize().width *0.5 - 30,self:getContentSize().height - kuang2:getContentSize().height *0.5 - 20))
    kuang2:setAnchorPoint(0.5,0.5)
    self:addChild(kuang2)
	self._xiaohaoKuang = kuang2

    --[[进阶消耗]]
    local _advanceCostTitle_bg = cc.Sprite:create("res/image/plugin/hero/JJXH.png")
    _advanceCostTitle_bg:setAnchorPoint(cc.p(0.5,1))
    _advanceCostTitle_bg:setPosition(cc.p(self:getContentSize().width/2,_propertyBgPosY-6+30))
    self:addChild(_advanceCostTitle_bg)
	_advanceCostTitle_bg:setVisible(false)

    if self.current_advance < self.maxAdvanceNum then
        --开始进阶
        local start_advance_btn = XTHDPushButton:createWithParams({
								normalFile = "res/image/newHeroinfo/btn_jinjie_1.png",
								selectedFile = "res/image/newHeroinfo/btn_jinjie_2.png",
                                isScrollView = false,   
                            })
        self.advance_up_btn = start_advance_btn
        start_advance_btn:setAnchorPoint(0.5,0.5)
        start_advance_btn:setPosition(self:getContentSize().width *0.75, start_advance_btn:getContentSize().height/2 + 10)
        self:addChild(start_advance_btn)

        start_advance_btn:setTouchEndedCallback(function ()
            print("the print function has printed ")
            ----引导 
            YinDaoMarg:getInstance():guideTouchEnd() 
            YinDaoMarg:getInstance():releaseGuideLayer()
            ------------------------------------------
            if next(self._costInfo_advance)~=nil and tonumber(self._costInfo_advance.feicuiNeedNum)>tonumber(gameUser.getFeicui()) then
                self.infoLayer:showMoneyNoEnoughtPop("noFeicui")
                return
            end
            if next(self._costInfo_advance)~=nil and self._costInfo_advance._hasNum and self._costInfo_advance._needNum and tonumber(self._costInfo_advance._hasNum)<tonumber(self._costInfo_advance._needNum) then
                XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.advanceItemsNoneTextXc)
                return
            end

            self:httpToAdvance(self.hero_id)
        end)
        self.guide_advanceBtn = start_advance_btn

        self:reFreshStarupBtn()
  
        local _costBgPosY = start_advance_btn:getBoundingBox().y+start_advance_btn:getBoundingBox().height+10
        local _costBg = cc.Sprite:createWithTexture(nil,cc.rect(0,0,365,_advanceCostTitle_bg:getBoundingBox().y-_costBgPosY))
        _costBg:setOpacity(0)
        _costBg:setAnchorPoint(cc.p(0.5,0))
        _costBg:setPosition(cc.p(self:getContentSize().width/2,_costBgPosY))
        self:addChild(_costBg)
        self.costBg = _costBg
        local _costPosX = self:getContentSize().width/2-10 
        local _costPosY = 18
	
        local _feicuicostTitle = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.starupCostFeicuiTitleTextXc,self.advance_fontSize)
        _feicuicostTitle:setColor(cc.c3b(0,0,0))
        _feicuicostTitle:setAnchorPoint(cc.p(0,0.5))
        _feicuicostTitle:setPosition(cc.p(self:getContentSize().width *0.6 + 5,self:getContentSize().height *0.25 - 2))
        self:addChild(_feicuicostTitle)
		
        --消耗数量
        local _feicuiNum_label = XTHDLabel:create("",self.advance_fontSize)
		_feicuiNum_label:setColor(cc.c3b(0,0,0))
        _feicuiNum_label:setName("feicuiNum_label")
        _feicuiNum_label:setAnchorPoint(cc.p(0,0.5))
        _feicuiNum_label:setPosition(cc.p(_feicuicostTitle:getPositionX() + _feicuicostTitle:getContentSize().width,_feicuicostTitle:getPositionY()))
        self:addChild(_feicuiNum_label)
        self:reFreshCostFeicui()


        --进阶消耗
        local _costItemPosY = _costBg:getContentSize().height -40
        -- (_advanceCostTitle_bg:getBoundingBox().y - _feicuiCost_bg:getBoundingBox().y + _feicuiCost_bg:getBoundingBox().height)/2
        local _itemPath = XTHD.resource.getItemImgById(self._costInfo_advance._resourceId)
        local _bgPath = XTHD.resource.getQualityItemBgPath(self._costInfo_advance._rank)
        local _costItemNode_ = cc.Sprite:create(_itemPath)
        _costItemNode_:setAnchorPoint(cc.p(0.5,0.5))
        _costItemNode_:setName("costItemNode")
		local _scale = 62/_costItemNode_:getContentSize().width
        _costItemNode_:setScale(_scale)
        _costItemNode_:setPosition(cc.p(self._xiaohaoKuang:getContentSize().width *0.5 + 0.5,self._xiaohaoKuang:getContentSize().height *0.6 + 1))
        self._xiaohaoKuang:addChild(_costItemNode_)
		
        local _costItembg = cc.Sprite:create(_bgPath)
        _costItembg:setName("costItembg")
        _costItembg:setPosition(cc.p(_costItemNode_:getContentSize().width/2,_costItemNode_:getContentSize().height/2))
        _costItemNode_:addChild(_costItembg)
        
        --按钮
        local _btnPath = "res/image/plugin/hero/addMaterialNumber.png"
        local _normalNode = cc.Sprite:create(_btnPath)
        local _selectedNode = cc.Sprite:create(_btnPath)
        _normalNode:setScale(6/5)
        _selectedNode:setScale(6/5*0.9)
        local _costItemBtn = XTHDPushButton:createWithParams({
                normalNode = _normalNode,
                selectedNode = _selectedNode,
                touchSize = cc.size(100,100)
                ,musicFile = XTHD.resource.music.effect_btn_common
            })
        _costItemBtn:setPosition(cc.p((_costItemNode_:getContentSize().width * _scale)/2,(_costItemNode_:getContentSize().height*_scale)))
        _costItemBtn:setTouchEndedCallback(function ()
            ----------引导 ---------
            YinDaoMarg:getInstance():guideTouchEnd()
            YinDaoMarg:getInstance():releaseGuideLayer()
            ----------引导 ---------
            local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
		    popLayer= popLayer:create(self._costInfo_advance._itemId)
            popLayer:setName("ItemDropPop")
		    self.infoLayer:addChild(popLayer)
        end)
        _costItemNode_:addChild(_costItemBtn)
        self._guideADVItemNode = _costItemBtn

        local _costItemName = XTHDLabel:create(self._costInfo_advance._itemName,self.advance_fontSize - 2)
        _costItemName:setName("costItemName")
        _costItemName:setColor(cc.p(0,0,0))
        _costItemName:setAnchorPoint(cc.p(0.5,0.5))
        _costItemName:setPosition(cc.p(_costItemNode_:getPositionX(),self._xiaohaoKuang:getContentSize().height *0.3 + 3))
        self._xiaohaoKuang:addChild(_costItemName)

		local xiaohaoLableNode = cc.Node:create()
		xiaohaoLableNode:setAnchorPoint(0.5,0.5)
		self._xiaohaoLableNode = xiaohaoLableNode
	
        local _costItemNumber_label = XTHDLabel:create(0,self.advance_fontSize)
        _costItemNumber_label:setName("costItemNumber_label")
        _costItemNumber_label:setColor(cc.c3b(255,255,255))
        _costItemNumber_label:setAnchorPoint(cc.p(0,0.5))
        self._xiaohaoLableNode:addChild(_costItemNumber_label)

        local _costItemNeedNum_label = XTHDLabel:create("/0",self.advance_fontSize)
        _costItemNeedNum_label:setColor(cc.c3b(255,255,255))
        _costItemNeedNum_label:setName("costItemNeedNum_label")
        _costItemNeedNum_label:setAnchorPoint(cc.p(0,0.5))
        self._xiaohaoLableNode:addChild(_costItemNeedNum_label)

		self._xiaohaoLableNode:setContentSize(_costItemNumber_label:getContentSize().width + _costItemNeedNum_label:getContentSize().width + 5,_costItemNeedNum_label:getContentSize().height)
		self._xiaohaoKuang:addChild(self._xiaohaoLableNode)
		self._xiaohaoLableNode:setPosition(_costItemName:getPositionX(),self._xiaohaoKuang:getContentSize().height *0.2)
	
		_costItemNumber_label:setPosition(_costItemNumber_label:getContentSize().width,self._xiaohaoLableNode:getContentSize().height *0.5)
		_costItemNeedNum_label:setPosition(_costItemNumber_label:getPositionX() + _costItemNumber_label:getContentSize().width,self._xiaohaoLableNode:getContentSize().height *0.5)
		

        self:reFreshCostItemInfo(self._costInfo_advance)
    else
    	local _prompLabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.advanceTopPromptTextXc,self.advance_fontSize)
        _prompLabel:setColor(self:getAdvanceTextColor("shenhese"))
        _prompLabel:setPosition(cc.p(self:getContentSize().width * 0.75 + 2.5,self:getContentSize().height *0.15))
        self:addChild(_prompLabel)
    end
end

function YingXiongAdvanceNode:isUnLockSkill(advanceId) --进阶到改阶是否有技能解锁 --2 4 7分别解锁技能
	local _skillTable = self.infoLayer.staticHeroSkillListData[tostring(self.hero_id)] or {}
	if advanceId == 1 then
	    local skillId = _skillTable["skillid1"] and _skillTable["skillid1"] or 0
	    return skillId
	elseif advanceId == 5 then
	    local skillId = _skillTable["skillid2"] and _skillTable["skillid2"] or 0
	    return skillId
	elseif advanceId == 9 then
	    local skillId = _skillTable["skillid3"] and _skillTable["skillid3"] or 0
	    return skillId
	else
	    return nil
	end
end

function YingXiongAdvanceNode:setPropertyPart(_data)
    if self.property_bg~=nil then
        self.property_bg:removeAllChildren()
    end
    local _rowHeight = 30
    -- (self.property_bg:getContentSize().height+4)/5
    local _rowPosY = 18-(39-_rowHeight)/2
    local _currentAdvance = _data.advance
    local _nextAdvance = _currentAdvance + 1
    local _innerHeight = self.property_bg:getInnerContainerSize().height
    local _propertyPosX = 40
    for i=1,5 do
		local layout = ccui.Layout:create()
		layout:setContentSize(self.property_bg:getContentSize().width,35)
	
        local _propretyPosX = _innerHeight -_rowHeight*i + _rowHeight/2
        local info_label_name = XTHDLabel:create(self.detail_ziduan[i].desc .. ":",self.advance_fontSize - 2)
        info_label_name:setColor(cc.c3b(60,0,0))
        info_label_name:setAnchorPoint(0,0.5)
        info_label_name:setPosition(10, layout:getContentSize().height *0.5)
        layout:addChild(info_label_name)
        local _ziduanKey = self.detail_ziduan[i].key
		
        local current_info_number = XTHDLabel:create(_data[_ziduanKey], self.advance_fontSize - 2)
        current_info_number:setColor(cc.c3b(60,0,0))
        current_info_number:setAnchorPoint(0,0.5)
        current_info_number:setPosition(cc.p(info_label_name:getPositionX()+ info_label_name:getContentSize().width +5,info_label_name:getPositionY()))
        layout:addChild(current_info_number)

        if _data.advance < self.maxAdvanceNum then
        	--属性增加值
		    local _addNumber = tonumber(self.hero_advance_data[_nextAdvance][_ziduanKey])-tonumber(self.hero_advance_data[_currentAdvance][_ziduanKey])
		    if _addNumber<0 then
		    	_addNumber = 0
		    end
            local _jiantouSp = cc.Sprite:create("res/image/plugin/hero/hero_propertyadd.png")
			_jiantouSp:setRotation(90)
            _jiantouSp:setAnchorPoint(0,0.5)
			_jiantouSp:setScale(0.6)
            _jiantouSp:setPosition(cc.p(layout:getContentSize().width *0.6 + 5,current_info_number:getPositionY() + 8))
            layout:addChild(_jiantouSp)
            local after_info_number = XTHDLabel:create(tostring(tonumber(_addNumber)+tonumber(_data[_ziduanKey])) , self.advance_fontSize - 2)
            after_info_number:setAnchorPoint(0,0.5)
            after_info_number:setPosition(_jiantouSp:getContentSize().width *0.6 + _jiantouSp:getPositionX() + 4, current_info_number:getPositionY())
            after_info_number:setColor(cc.c3b(60,0,0))
            layout:addChild(after_info_number)
        end
		self.property_bg:pushBackCustomItem(layout)
    end
end

function YingXiongAdvanceNode:httpToAdvance(_heroid)
    self.infoLayer:setButtonClickableState(false)
    self:setAdvanceButtonClick(false)
    self._oldFightValue = self.infoLayer.data["power"] or 0     --老的战斗力
    self._newFightValue = self._oldFightValue
    ClientHttp:httpHeroAdvance(self,function(data)
            YinDaoMarg:getInstance():getACover(self.infoLayer)
            musicManager.playEffect("res/sound/sound_advanceUp_effect.mp3")
            gameUser.setFeicui(data["feicui"])
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
            self:reFreshHeroAdvanceData(data)
            XTHD._createFightLabelToast({
                oldFightValue = self._oldFightValue,
                newFightValue = self._newFightValue 
            })
            self._oldFightValue = self._newFightValue
        end,{petId=_heroid},function()
            YinDaoMarg:getInstance():tryReguide()
            self.infoLayer:setButtonClickableState(true)
            self:setAdvanceButtonClick(true)
        end)	
end

function YingXiongAdvanceNode:playAdvanceAnimation(_data)
    local _popLayer = requires("src/fsgl/layer/YingXiong/YingXiongAdvanceResultLayer.lua")
    local _resoultPopLayer = _popLayer:create("success",_data,self.infoLayer)
    self:setAdvanceButtonClick(true)
    self.infoLayer:setButtonClickableState(true)
    self.infoLayer:addChild(_resoultPopLayer)
    _resoultPopLayer:setHideCallback(function( )
        YinDaoMarg:getInstance():doNextGuide()         
    end)
end

function YingXiongAdvanceNode:setAdvanceButtonClick(flag)
    if  self.advance_up_btn~=nil then
        self.advance_up_btn:setClickable(flag)
    end
end

function YingXiongAdvanceNode:createUnlockSkillLabel(_currentadvance)
    if self.current_advance==nil then
        return
    end
	local unLockSkillId = self:isUnLockSkill(self.current_advance)
	if self.unlockSkillLabel~= nil then
		self.unlockSkillLabel:removeFromParent()
		self.unlockSkillLabel = nil
	end

	if unLockSkillId~=nil then
		--技能
        if self.infoLayer.otherStaticSkillData==nil or next(self.infoLayer.otherStaticSkillData)==nil then
            self.infoLayer:setOtherStaticDBData()
        end
		local skill_name = self.infoLayer.otherStaticSkillData[tostring(unLockSkillId)] or nil
		skill_name = skill_name and skill_name.name or nil
		if skill_name~=nil then
			self.property_bg:setContentSize(cc.size(self.propertyContentSize.width,self.propertyContentSize.height-30))
            local _nameStr = LANGUAGE_KEY_HERO_TEXT_unlockNewSkillTitleTextXc(skill_name)
			self.unlockSkillLabel = XTHDLabel:create(_nameStr,self.advance_fontSize)
			self.unlockSkillLabel:setColor(cc.c3b(200,15,15))
            self.unlockSkillLabel:setScale(0.9)
			self.unlockSkillLabel:setPosition(cc.p(self.__heroPropertyTitle_bg:getContentSize().width/2,self.property_bg:getBoundingBox().y + self.property_bg:getBoundingBox().height + 13))
			self.__heroPropertyTitle_bg:addChild(self.unlockSkillLabel)
		end
    else
        self.property_bg:setContentSize(self.propertyContentSize)
	end
end

--进阶花费。返回名称、需求数量，是否有足够数量的资源
function YingXiongAdvanceNode:getAdvanceCostInfo(_heroid,_rank)
	local _costinfo = {}
	local _cost = gameData.getDataFromCSV("GeneralAdvanceInfo",{["heroid"] = _heroid,["rank"] = _rank})
	if not _cost then
		return _costinfo
	end
	_costinfo.needLevel = _cost.needlevel or 0
	--翡翠
	_costinfo.feicuiNeedNum = _cost["feicuicost"] or 0
	--进阶材料
	local _ItemData  = self.infoLayer.staticItemData[tostring(_cost.itemid1)] or {}
	_costinfo._itemName = _ItemData and _ItemData.name or ""
	_costinfo._itemId = _cost.itemid1
	_costinfo._resourceId = _ItemData and _ItemData.resourceid or 0
	_costinfo._rank = _ItemData and _ItemData.rank or 0
	_costinfo._needNum = _cost.itemid1count or 0
	_costinfo._hasNum = 0

	local _otherItemNum = 0
	for k,v in pairs(self.infoLayer.dynamicItemData) do
		if tonumber(v.itemid) == tonumber(_cost.itemid1) then
			_otherItemNum = v.count
			break
		end
	end
	_costinfo._hasNum = tonumber(_otherItemNum)

	return _costinfo
end
--设置最大可进阶数
function YingXiongAdvanceNode:setMaxAdvanceNumber(_data)
	local _num = 1
	for k,v in pairs(_data) do
		if v.advanceid and tonumber(v.advanceid) > _num then
			_num = tonumber(v.advanceid)
		end
	end
	self.maxAdvanceNum = _num
end

function YingXiongAdvanceNode:removeAdvanceElement()
    if self.costBg~=nil then
        self.costBg:removeAllChildren()
        self._guideADVItemNode = nil
    end
end

--------------------刷新Began----------------------
--刷新翡翠消耗数量
function YingXiongAdvanceNode:reFreshCostFeicui()
    if not self._costInfo_advance or next(self._costInfo_advance)==nil then
        return
    end
        if self:getChildByName("feicuiNum_label") then
        	local _feicuiNum =tonumber(self._costInfo_advance.feicuiNeedNum) or 0
        	local _hasFeicuiNum = tonumber(gameUser.getFeicui())
            local _feicuiCostNumLabel = self:getChildByName("feicuiNum_label")
            _feicuiCostNumLabel:setString(_feicuiNum)
            if _feicuiNum>_hasFeicuiNum then
                _feicuiCostNumLabel:setColor(cc.c3b(0,0,0))
            else
                _feicuiCostNumLabel:setColor(cc.c3b(0,0,0))
            end
		end
end

--刷新消耗品
function YingXiongAdvanceNode:reFreshCostItemInfo(_data)
	if not _data or next(_data)==nil then
		return
	end
    if self.costBg~=nil then
        local _costItemValue = _data._hasNum or 0
        local _needItemValue = _data._needNum or 0

        if self._xiaohaoKuang:getChildByName("costItemNode") then
            local _itemPath = XTHD.resource.getItemImgById(_data._resourceId)
            local _bgPath = XTHD.resource.getQualityItemBgPath(_data._rank)
            local _costItemNode = self._xiaohaoKuang:getChildByName("costItemNode")
            _costItemNode:initWithFile(_itemPath)
            _costItemNode:setAnchorPoint(cc.p(0.5,0.5))
            if _costItemNode:getChildByName("costItembg") then
                _costItemNode:getChildByName("costItembg"):initWithFile(_bgPath)
            end
        end
        local _costItemName = self._xiaohaoKuang:getChildByName("costItemName")
        _costItemName:setString(_data._itemName)
        local _costItemNumber_label = self._xiaohaoLableNode:getChildByName("costItemNumber_label")
        _costItemNumber_label:setString(_costItemValue)
        local _costItemNeedNum_label = self._xiaohaoLableNode:getChildByName("costItemNeedNum_label")
        _costItemNeedNum_label:setString(" / " .. (_needItemValue or 0))

		self._xiaohaoLableNode:setContentSize(_costItemNumber_label:getContentSize().width + _costItemNeedNum_label:getContentSize().width,_costItemNeedNum_label:getContentSize().height)
		_costItemNumber_label:setPosition(0,self._xiaohaoLableNode:getContentSize().height *0.5)
		_costItemNeedNum_label:setPosition(_costItemNumber_label:getPositionX() + _costItemNumber_label:getContentSize().width,self._xiaohaoLableNode:getContentSize().height *0.5)
        if tonumber(_needItemValue)>tonumber(_costItemValue) then
            _costItemNumber_label:setColor(cc.c3b(255,255,255))
--        else
            _costItemNumber_label:setColor(cc.c3b(255,255,255))
        end
    end
end
function YingXiongAdvanceNode:reFreshStarupBtn()
    if self.advance_up_btn~=nil then
        if self._costInfo_advance.needLevel and tonumber(self._costInfo_advance.needLevel)>tonumber(self.data.level) then
            --self.advance_up_btn:getLabel():setString(LANGUAGE_TIPS_notadvanceBtnTextXc(self._costInfo_advance.needLevel))
            self.advance_up_btn:setTouchEndedCallback(function ()
                YinDaoMarg:getInstance():guideTouchEnd()

                XTHDTOAST(LANGUAGE_TIPS_notadvanceBtnTextXc(tonumber(self._costInfo_advance.needLevel)))
            end)
        end
    end
    
end
--刷新数据
function YingXiongAdvanceNode:reFreshHeroAdvanceData(data)
    local _oldHeroData = self.infoLayer.data

    self.infoLayer:setHeroAdvanced(true)

	local _dbid = data["items"][1]["dbId"]

    local property = data.petProperty
    if property then
        for i=1,#property do
            local _tab = string.split(property[i],',')
            DBTableHero.updateDataByPropId( gameUser.getUserId(), _tab[1],_tab[2],data["petId"]);
            gameUser.updateDataById(_tab[1],_tab[2])
            if tonumber(_tab[1]) == 407 then
                self._newFightValue = tonumber(_tab[2])
            end
        end
    end
    
    if  data["items"][1]["count"] and data["items"][1]["count"] > 0 then
        DBTableItem.updateCount(gameUser.getUserId(),data["items"][1],_dbid)
    else
        DBTableItem.deleteData(gameUser.getUserId(),_dbid)
    end

    self:unLockSkillToDB(data["petId"],data["skilljihuo"])

    --激活的技能id
    self.infoLayer:refreshInfoLayer(data["petId"],"noEquip")
    -- --
    local _advanceResoultData = clone(self.infoLayer.data)
    _advanceResoultData.oldPower = self._oldFightValue
    _advanceResoultData.oldPropertyData = _oldHeroData
    if data["skilljihuo"] and tonumber(data["skilljihuo"]) > 0 then
        _advanceResoultData.newSkillid = data["skilljihuo"]
    else
        _advanceResoultData.newSkillid = nil
    end
    -- self.infoLayer:playCurrentHeroWinAnimation()
    self:playAdvanceAnimation(_advanceResoultData)


    local _heroid__ = self.infoLayer.data.heroid
    if tonumber(data["petId"])==tonumber(self.infoLayer.data.heroid) then        
        self:reFreshHeroFunctionInfo()
    end
end
function YingXiongAdvanceNode:reFreshHeroFunctionInfo()
	self.data = clone(self.infoLayer.data)
    self.current_advance = self.data["advance"] or 1
    self.hero_id = self.data.heroid
    self._costInfo_advance = {}
    self._costInfo_advance = self:getAdvanceCostInfo(self.hero_id,self.current_advance)

    self:createUnlockSkillLabel()
    self:setPropertyPart(self.data)
    --如果当前不到最顶级
    if self.current_advance < self.maxAdvanceNum then
        self:reFreshCostFeicui()
        self:reFreshCostItemInfo(self._costInfo_advance)
        self:reFreshStarupBtn()
    else
        self:removeAdvanceElement()
        -- if self.feicuiCost_bg then
        --     self.feicuiCost_bg:removeAllChildren()
        --     self.feicuiCost_bg:removeFromParent()
        --     self.feicuiCost_bg = nil
        -- end
        if self.advance_up_btn~=nil then
            self.advance_up_btn:removeFromParent()
            self.advance_up_btn = nil
        end
        local _prompLabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.advanceTopPromptTextXc,self.advance_fontSize)
        _prompLabel:setColor(self:getAdvanceTextColor("shenhese"))
        _prompLabel:setPosition(cc.p(self:getContentSize().width/2,self._promptPosY))
        self:addChild(_prompLabel)
    end
end

function YingXiongAdvanceNode:unLockSkillToDB(_heroid,_skillid)
	local _skillStaticData = self.infoLayer.staticHeroSkillListData[tostring(_heroid)] or {}
	if next(_skillStaticData)~=nil then
		for k,v in pairs(_skillStaticData) do
			if tonumber(v) == tonumber(_skillid) and k ~="heroid" then
				DBTableHeroSkill.updateByKey(gameUser.getUserId(),k .. "lv",1,_heroid)
                break
			end
		end
	end
end
--------------------刷新Ended----------------------


--获取英雄进阶界面的文字颜色
function YingXiongAdvanceNode:getAdvanceTextColor(_str)
	-- local _nameColor = XTHD.resource.getQualityItemColor(self.itemInfoData["rank"])
	local _textColor = {
		hongse = cc.c4b(204,2,2,255),                           --红色
        shenhese = cc.c4b(70,34,34,255),                        --深褐色，用的比较多
        lanse = cc.c4b(26,158,207,255),                         --蓝色
        chenghongse = cc.c4b(205,101,8,255),                    --橙红色
        zongse = cc.c4b(128,112,91,255),                        --棕色，有点深灰色的感觉
        baise = cc.c4b(255,255,255,255),                        --白色
        lvse = cc.c4b(104,157,0,255),                           --绿色
	}
	return _textColor[_str]
end
function YingXiongAdvanceNode:create(heroData,YingXiongInfoLayer)
	local _node = self.new(heroData,YingXiongInfoLayer);
	return _node;
end


function YingXiongAdvanceNode:onEnter( )
    ----------引导
    if not self.guide_advanceBtn then 
        performWithDelay(self, function( )
            YinDaoMarg:getInstance():removeCover(self.infoLayer)
        end,0.1)
        return 
    else 
        YinDaoMarg:getInstance():addGuide({parent = self.infoLayer,index = 5},7)----剧情
        YinDaoMarg:getInstance():addGuide({ ----进阶引导
            parent = self.infoLayer,
            target = self.guide_advanceBtn,
            index = 6,
        },7)
    end
    performWithDelay(self.guide_advanceBtn,function( )
        YinDaoMarg:getInstance():doNextGuide() 
        YinDaoMarg:getInstance():removeCover(self.infoLayer)
    end,0.2)
    ----------------------------------------------------
end

return YingXiongAdvanceNode