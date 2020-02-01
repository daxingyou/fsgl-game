--以下英雄未拥有 255,210,80
local YingXiongStarUpNode = class("YingXiongStarUpNode", function()
    local select_sp = XTHD.createFunctionLayer()
    return select_sp
end)

function YingXiongStarUpNode:ctor(heroData,items_data,target_layer)
    self.property_bg = nil              --属性背景
--	print("英雄升星数据----------------")
--	print_r(heroData)
    
	self.current_star = 1
	self.exp_progress = nil
	self.maxStar = 0  --英雄的最高星级
	self.chip_number = 0 --英雄碎片数 
    self.startUp_list = 0 --升星所需要的碎片数
	self.detail_ziduan = {"hp" , "physicalattack" , "manaattack" , "physicaldefence" 
							, "manadefence" }
	self.current_number_arr = {} --当前值的数组
	self.add_number_arr = {}
	self.hero_grow = nil
    self.items_data = {}
    self.starUp_list_arr = {}       -- 升星所需道具的数组
    self.costBg = nil               --

    self.infoLayer = target_layer

    self.starup_fontSize = self.infoLayer._commonTextFontSize

    self.data = heroData
    self._oldFightValue = self.data.power or 0
    self._newFightValue = self._oldFightValue
    self.items_data = items_data

    self.current_star = heroData["star"]

    self.hero_id = heroData["heroid"]
	
	self:getHeroMaxStar()
	print("当前英雄最高星级为："..self.maxStar)

--    self.costItemStaticData = self.infoLayer.staticItemData[tostring(1000 + self.hero_id)] or {}
	self.costItemStaticData = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = self.starData["propsneed"..math.min(self.current_star + 1,self.maxStar)]}) or {}

    self._promptPosY = 100

    self:init()
    YinDaoMarg:getInstance():getACover(self.infoLayer)
end

function YingXiongStarUpNode:onCleanup()
    self:removeStarUpButtonEffect()
    YinDaoMarg:getInstance():removeCover(self.infoLayer)    
end

--获取英雄最高星数
function YingXiongStarUpNode:getHeroMaxStar()
	self.starData = gameData.getDataFromCSV("GeneralGrowthNeeds",{id = self.hero_id})
	for i = 1,11 do
	   if self.starData["starcount"..i] == 0 then
			self.maxStar = i - 1
			break
	   end
	end
end

function YingXiongStarUpNode:init()

    self.hero_grow = {}
    if self.infoLayer.otherStaticHeroGrowData==nil or next(self.infoLayer.otherStaticHeroGrowData)==nil then
        self.infoLayer:setOtherStaticDBData()
    end
    self.hero_grow = self.infoLayer.otherStaticHeroGrowData[tostring(self.hero_id)] or {}

    self.chip_number = 0
    self:setChipNum()
    -- self.chipData = clone(self.infoLayer.staticItemData[tostring(1000 + tonumber(self.hero_id))] or {})

    local _propertyBgPosY = 225-13

    --[[属性变化]]
    local _heroPropertyTitle_bg = cc.Sprite:create("res/image/newHeroinfo/shuxingbg2.png")
    _heroPropertyTitle_bg:setPosition(cc.p(_heroPropertyTitle_bg:getContentSize().width/2 + 15,self:getContentSize().height *0.5 - 5))
    self:addChild(_heroPropertyTitle_bg)
	
    local _propertyContentSize = cc.size(_heroPropertyTitle_bg:getContentSize().width,_heroPropertyTitle_bg:getContentSize().height - 45)
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

    self:setPropertyPart(self.data)

    --[[升星消耗]]
    local _starUpCostTitle_bg = cc.Sprite:create("res/image/newHeroinfo/itemkuang.png")
    _starUpCostTitle_bg:setAnchorPoint(cc.p(0.5,0.5))
    _starUpCostTitle_bg:setPosition(cc.p(self:getContentSize().width - _starUpCostTitle_bg:getContentSize().width *0.5 - 30,self:getContentSize().height - _starUpCostTitle_bg:getContentSize().height *0.5 - 20))
    self:addChild(_starUpCostTitle_bg)
	self._xiaohaoKuang = _starUpCostTitle_bg
  
    if self.current_star < self.maxStar then
        local _startUpTable = self.infoLayer.staticHeroStarupListData
        self.starUp_list_arr = clone(_startUpTable[tostring(self.hero_id)] or {})
        self.startUp_list = self.starUp_list_arr["starcount" .. tostring(self.current_star+1)] or 0

        --开始升星
        local start_star_up_btn =XTHDPushButton:createWithParams({
								normalFile = "res/image/newHeroinfo/btn_shengxing_1.png",
								selectedFile = "res/image/newHeroinfo/btn_shengxing_2.png",
                                isScrollView = false,   
                            })
        self.start_star_up_btn = start_star_up_btn
        start_star_up_btn:setAnchorPoint(0.5,0.5)
        start_star_up_btn:setPosition(self:getContentSize().width *0.75, start_star_up_btn:getContentSize().height/2 + 10)
        self:addChild(start_star_up_btn)

        start_star_up_btn:setTouchEndedCallback(function ()
            ----引导 
            YinDaoMarg:getInstance():guideTouchEnd() 
            YinDaoMarg:getInstance():releaseGuideLayer()
            ------------------------------------------
            self:removeStarUpButtonEffect()
            if self.current_star >= self.maxStar then
                XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.starupTopPromptTextXc )
                return
            end
            local _feicuiCostNum = self.starUp_list_arr["goldcost" .. tostring(self.current_star+1) .. "star"] or 0
            if tonumber(_feicuiCostNum)>tonumber(gameUser.getFeicui()) then
                self.infoLayer:showMoneyNoEnoughtPop("noFeicui")
                return
            end
            if self.chip_number < self.startUp_list then
                XTHDTOAST(LANGUAGE_TIPS_isNoEnoughHeroChipTextXc(self.costItemStaticData["name"]))
				if self.current_star >=  5 then
					local layer = requires("src/fsgl/layer/YingXiong/YingXiongXianJi.lua"):create(self.infoLayer)
					self.infoLayer:addChild(layer,10)
					layer:show()
				end
                return
            end
            self:httpToStarUp()
        end)
        self:setStarUpButtonEffect()

        local _costBgPosY = start_star_up_btn:getBoundingBox().y+start_star_up_btn:getBoundingBox().height+10
        local _costBg = cc.Sprite:createWithTexture(nil,cc.rect(0,0,365,_starUpCostTitle_bg:getBoundingBox().y-_costBgPosY))
        _costBg:setOpacity(0)
        _costBg:setAnchorPoint(cc.p(0.5,0))
        _costBg:setPosition(cc.p(self:getContentSize().width/2,_costBgPosY))
        self:addChild(_costBg)
        self.costBg = _costBg
        local _costPosX = self:getContentSize().width/2-10 
        local _costPosY = 18

		local _feicuicostTitle = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.starupCostFeicuiTitleTextXc,16)
        _feicuicostTitle:setColor(cc.c3b(0,0,0))
        _feicuicostTitle:setAnchorPoint(cc.p(0,0.5))
        _feicuicostTitle:setPosition(cc.p(self:getContentSize().width *0.6 + 5,self:getContentSize().height *0.25 + 7))
        self:addChild(_feicuicostTitle)
        
        --消耗数量
        local _feicuiNum_label = XTHDLabel:create("",16)
		_feicuiNum_label:setColor(cc.c3b(0,0,0))
        _feicuiNum_label:setName("feicuiNum_label")
        _feicuiNum_label:setAnchorPoint(cc.p(0,0.5))
        _feicuiNum_label:setPosition(cc.p(_feicuicostTitle:getPositionX() + _feicuicostTitle:getContentSize().width,_feicuicostTitle:getPositionY()))
        self:addChild(_feicuiNum_label)
        self:reFreshCostFeicui()

		--最大升星数
		local maxStarLable = XTHDLabel:create("（"..self.data.name.."最高可升"..self.maxStar.."星）",16)
		maxStarLable:setColor(cc.c3b(0,0,0))
		maxStarLable:setAnchorPoint(cc.p(0.5,0.5))
		self:addChild(maxStarLable)
		maxStarLable:setPosition(start_star_up_btn:getPositionX() + 5,_feicuiNum_label:getPositionY() - _feicuiNum_label:getContentSize().height)

--		--玩法说明
--        local help_btn = XTHDPushButton:createWithParams({
--        normalFile        = "res/image/camp/lifetree/wanfa_up.png",
--        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
--        musicFile = XTHD.resource.music.effect_btn_common,
--        endCallback       = function()
--            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=24});
--			StoredValue:setAnchorPoint(0.5,0.5)
--			local layer = cc.Director:getInstance():getRunningScene()
--			StoredValue:setPosition(0,0)
--            layer:addChild(StoredValue,5)
--        end,
--        })
--		help_btn:setScale(0.9)
--        self:addChild(help_btn)
--        help_btn:setPosition(self:getContentSize().width - help_btn:getContentSize().width,self:getContentSize().height/2 - help_btn:getContentSize().height + 15)

        --升星消耗
        -- local _costItemPosX = (_starUpCostTitle_bg:getBoundingBox().y - _feicuiCost_bg:getBoundingBox().y + _feicuiCost_bg:getBoundingBox().height)/2
        local _costItemPosY = _costBg:getContentSize().height -40
        local _itemPath = XTHD.resource.getItemImgById(self.hero_id)
        local _costItemNode_ = cc.Sprite:create(_itemPath)
        _costItemNode_:setAnchorPoint(cc.p(0.5,0.5))
        _costItemNode_:setName("costItemNode")
		local _scale = 62/_costItemNode_:getContentSize().width
        _costItemNode_:setScale(_scale)
        _costItemNode_:setPosition(cc.p(self._xiaohaoKuang:getContentSize().width *0.5 + 0.5,self._xiaohaoKuang:getContentSize().height *0.6 + 1))
        self._xiaohaoKuang:addChild(_costItemNode_)
	
		local _bgPath
		if self.costItemStaticData.itemid > 1000 and self.costItemStaticData.itemid < 1111 then  --英雄碎片
			_bgPath = "res/image/quality/chip_" .. (self.costItemStaticData.rank or 1) .. ".png"
		else  --道具
			_bgPath = "res/image/item/props"..self.costItemStaticData.resourceid..".png"
		end	
        local _costItembg = cc.Sprite:create(_bgPath)
        _costItembg:setPosition(cc.p(_costItemNode_:getContentSize().width/2,_costItemNode_:getContentSize().height/2))
        _costItemNode_:addChild(_costItembg)
		self.costItembg = _costItembg
        
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
--            local _dropLayer =  self:getDropWayLayer(tonumber(self.hero_id)+1000)
			local _dropLayer =  self:getDropWayLayer(self.costItemStaticData.itemid)
            self.infoLayer:addChild(_dropLayer)
        end)
        _costItemNode_:addChild(_costItemBtn)

        local _costItemName = XTHDLabel:create(self.costItemStaticData["name"],self.starup_fontSize)
        _costItemName:setColor(cc.c3b(0,0,0))
        _costItemName:setAnchorPoint(cc.p(0.5,0.5))
        _costItemName:setPosition(cc.p(_costItemNode_:getPositionX(),self._xiaohaoKuang:getContentSize().height *0.3 + 3))
        self._xiaohaoKuang:addChild(_costItemName)
		self.costItemName = _costItemName

		local xiaohaoLableNode = cc.Node:create()
		xiaohaoLableNode:setAnchorPoint(0.5,0.5)
		self._xiaohaoLableNode = xiaohaoLableNode

        local _costItemNumber_label = XTHDLabel:create(0,self.starup_fontSize)
        _costItemNumber_label:setName("costItemNumber_label")
        _costItemNumber_label:setColor(cc.c3b(255,255,255))
        _costItemNumber_label:setAnchorPoint(cc.p(0,0.5))
        _costItemNumber_label:setPosition(cc.p(_costItemName:getPositionX(),_costItemNode_:getBoundingBox().y + _costItemNode_:getBoundingBox().height/2))
        self._xiaohaoLableNode:addChild(_costItemNumber_label)

        local _costItemNeedNum_label = XTHDLabel:create("/0",self.starup_fontSize)
        _costItemNeedNum_label:setColor(cc.c3b(255,255,255))
        _costItemNeedNum_label:setName("costItemNeedNum_label")
        _costItemNeedNum_label:setAnchorPoint(cc.p(0,0.5))
        _costItemNeedNum_label:setPosition(cc.p(_costItemNumber_label:getBoundingBox().x + _costItemNumber_label:getBoundingBox().width,_costItemNumber_label:getPositionY()))
        self._xiaohaoLableNode:addChild(_costItemNeedNum_label)

		self._xiaohaoLableNode:setContentSize(_costItemNumber_label:getContentSize().width + _costItemNeedNum_label:getContentSize().width + 5,_costItemNeedNum_label:getContentSize().height)
		self._xiaohaoKuang:addChild(self._xiaohaoLableNode)
		self._xiaohaoLableNode:setPosition(_costItemName:getPositionX(),self._xiaohaoKuang:getContentSize().height *0.2)

		_costItemNumber_label:setPosition(_costItemNumber_label:getContentSize().width,self._xiaohaoLableNode:getContentSize().height *0.5)
		_costItemNeedNum_label:setPosition(_costItemNumber_label:getPositionX() + _costItemNumber_label:getContentSize().width,self._xiaohaoLableNode:getContentSize().height *0.5)

        self:reFreshCostItemInfo(self.chip_number,self.startUp_list)

    else
        local _prompLabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.starupTopPromptTextXc,self.starup_fontSize)
        _prompLabel:setName("prompLabel")
        _prompLabel:setColor(cc.c3b(0,0,0))
        _prompLabel:setPosition(cc.p(self:getContentSize().width * 0.75 + 2.5,self:getContentSize().height *0.15))
        self:addChild(_prompLabel)
    end
end

function YingXiongStarUpNode:setPropertyPart(_data)
    --5星成长属性*（当前等级-1）-4星成长属性*（当前等级-1）
    if self.property_bg~=nil then
        self.property_bg:removeAllChildren()
    end
    local label_name = LANGUAGE_TIPS_WORDS112 --------{"生命上限:","物攻伤害:","魔攻伤害:","物攻防御:","魔攻防御:"}
	local newlabel_name = LANGUAGE_TIPS_WORDS112_1  
	if _data.star <= 5 then
		label_name = LANGUAGE_TIPS_WORDS112
	else
		label_name = LANGUAGE_TIPS_WORDS112_1
	end
	if _data.star + 1 <= 5 then
		newlabel_name = LANGUAGE_TIPS_WORDS112
	else
		newlabel_name = LANGUAGE_TIPS_WORDS112_1
	end
    local _rowHeight = 30
    -- (self.property_bg:getContentSize().height+4)/5
    local _propertyPosX = 40
    local _innerHeight = self.property_bg:getInnerContainerSize().height
    for i=1,5 do
		local layout = ccui.Layout:create()
		layout:setContentSize(self.property_bg:getContentSize().width,30)

        local _propretyPosX = _innerHeight -_rowHeight*i + _rowHeight/2
        local info_label_name = XTHDLabel:create(label_name[i],self.starup_fontSize)
        info_label_name:setColor(cc.c3b(60,0,0))
        info_label_name:setAnchorPoint(0,0.5)
        info_label_name:setPosition(10, layout:getContentSize().height *0.5)
        layout:addChild(info_label_name)

        local _curNumber = self:getAddNumber(self.detail_ziduan[i] ,tonumber(_data.star))
		local current_info_number
		if _data.star <= 5 then
			current_info_number = XTHDLabel:create(_curNumber, self.starup_fontSize)
		else
			current_info_number = XTHDLabel:create(_curNumber.."%", self.starup_fontSize)
		end
        current_info_number:setColor(cc.c3b(60,0,0))
        current_info_number:setAnchorPoint(0,0.5)
        current_info_number:setPosition(cc.p(info_label_name:getPositionX()+ info_label_name:getContentSize().width +5,info_label_name:getPositionY()))
        layout:addChild(current_info_number)

        if tonumber(_data.star) < self.maxStar then
            local _addNumber = self:getAddNumber(self.detail_ziduan[i] ,tonumber(_data.star)+1)
            if tonumber(_addNumber)>=0 then
                local _jiantouSp = cc.Sprite:create("res/image/plugin/hero/hero_propertyadd.png")
				_jiantouSp:setRotation(90)
                _jiantouSp:setAnchorPoint(0,0.5)
				_jiantouSp:setScale(0.6)
				_jiantouSp:setPosition(cc.p(layout:getContentSize().width *0.6 + 5,current_info_number:getPositionY() + 8))
				layout:addChild(_jiantouSp)
				local after_info_number
				if _data.star + 1 <= 5 then
					after_info_number = XTHDLabel:create(_addNumber, self.starup_fontSize)
				else
					after_info_number = XTHDLabel:create(_addNumber.."%", self.starup_fontSize)
				end
                after_info_number:setAnchorPoint(0,0.5)
                after_info_number:setPosition(_jiantouSp:getContentSize().width *0.6 + _jiantouSp:getPositionX() + 4, current_info_number:getPositionY())
                after_info_number:setColor(cc.c3b(60,0,0))
                layout:addChild(after_info_number)
            end
        end
		self.property_bg:pushBackCustomItem(layout)
    end
end

--升星网络请求
function YingXiongStarUpNode:httpToStarUp()
    self._oldFightValue = self.data.power or 0
    self._newFightValue = self._oldFightValue
    self.infoLayer:setButtonClickableState(false)
    ClientHttp:httpHeroStarUp(self,function(data)
			-- print("英雄升星服务器返回的数据为：")
			-- print_r(data)
            gameUser.setFeicui(data["feicui"])
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
            self:reFreshHeroStarupData(data)
            XTHD._createFightLabelToast({
                oldFightValue = self._oldFightValue,
                newFightValue = self._newFightValue 
            })
            self._oldFightValue = self._newFightValue
            self.infoLayer:setButtonClickableState(true)
			self.infoLayer:setLayerState(self.infoLayer.state)
        end,{petId= self.hero_id},function()
            self.infoLayer:setButtonClickableState(true)
        end)
    -- ClientHttp:requestAsyncInGameWithParams({
    --     modules = "upStar?",
    --     params = {petId= self.hero_id},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
    --     successCallback = function(data)
    --         -- ZCLOG(data)
    --         if tonumber(data.result) == 0 then
    --             -- print("返回数字为0成功")
    --             gameUser.setFeicui(data["feicui"])
    --             XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})

    --             self:reFreshHeroStarupData(data)
    --             XTHD._createFightLabelToast({
    --                 oldFightValue = self._oldFightValue,
    --                 newFightValue = self._newFightValue 
    --             })
    --             self._oldFightValue = self._newFightValue
                
    --             -- self.infoLayer:refreshheroLayerCellHead()
    --             -- XTHDTOAST("升星成功")
    --         else
    --             XTHDTOAST(data.msg)
    --         end
    --         self.infoLayer:setButtonClickableState(true)
    --     end,--成功回调
    --     failedCallback = function()
    --         self.infoLayer:setButtonClickableState(true)
    --         XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败")
    --     end,--失败回调
    --     loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    -- })
end

--弹出掉落途径的弹窗
function YingXiongStarUpNode:getDropWayLayer(_itemid)
    local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
    popLayer= popLayer:create(_itemid)
    popLayer:setName("ItemDropPop")
    return popLayer
end

--设置碎片数量
function YingXiongStarUpNode:setChipNum()
    self.chip_number = 0
	self.costItemStaticData = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = self.starData["propsneed"..math.min(self.current_star + 1,self.maxStar)]}) or {}
    for k,v in pairs(self.items_data) do 
        if tonumber(v.itemid) == self.costItemStaticData.itemid then
            self.chip_number = v.count
            break
        end
    end
end
--获取+的数值
function YingXiongStarUpNode:getAddNumber(_type,star_up_number)
    if star_up_number > self.maxStar then
        return 0
    end
	local add_number = 0
	if star_up_number <= 5 then
		add_number = tonumber(self.hero_grow[star_up_number] and self.hero_grow[star_up_number][_type .. "grow"] or 0)
	else
		add_number = tonumber(self.hero_grow[star_up_number][_type .. "grow"])
--		for i = 5,star_up_number do
--			add_number = add_number + tonumber(self.hero_grow[i][_type .. "grow"])
--		end
	end
    -- add_number = add_number * (self.data["level"]-1)
    -- local old_number = math.floor(self.hero_grow[star_up_number-1] and self.hero_grow[star_up_number-1][_type .. "grow"] or 0)
    -- old_number = old_number * (self.data["level"]-1)
    return (math.ceil(add_number*10))/10
end

function YingXiongStarUpNode:setStarUpButtonEffect()
    if self.start_star_up_btn == nil then
        return
    end
    local _isCanStarUp = self.infoLayer.isCanDo_prompt.starup or false
    if self._starupBtn_effect == nil and _isCanStarUp==true then
        -- self._starupBtn_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/mf_15.json", "res/spine/effect/exchange_effect/mf_15.atlas",1 );
        -- self._starupBtn_effect:setPosition(self.start_star_up_btn:getContentSize().width/2,self.start_star_up_btn:getContentSize().height/2)
        -- self.start_star_up_btn:addChild(self._starupBtn_effect)
        -- self._starupBtn_effect:setScaleX(144/205)
        -- self._starupBtn_effect:setScaleY(40/50)
        -- self._starupBtn_effect:setAnimation(0,"animation",true)
        -- self._starupBtn_effect:setTimeScale(0.5)    --setTimeScale参数，1表示正常
        local _btnEffect = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)
        self.start_star_up_btn:addChild( _btnEffect )
        -- _btnEffect:setScaleX(self.start_star_up_btn:getContentSize().width/102)
        _btnEffect:setPosition( self.start_star_up_btn:getContentSize().width*0.5+7, self.start_star_up_btn:getContentSize().height/2+2 )
        _btnEffect:setAnimation( 0, "querenjinjie", true)
        self._starupBtn_effect = _btnEffect
    elseif _isCanStarUp==false then
        self:removeStarUpButtonEffect()
    end
end
function YingXiongStarUpNode:removeStarUpButtonEffect()
    if self._starupBtn_effect~=nil then
        self._starupBtn_effect:removeFromParent()
        self._starupBtn_effect = nil
    end
end

function YingXiongStarUpNode:removeAdvanceElement()
    if self.costBg ~=nil then
        self.costBg:removeAllChildren()
    end
end

-----------------刷新Began--------------------
--刷新翡翠消耗数量
function YingXiongStarUpNode:reFreshCostFeicui()
    if self.starUp_list_arr==nil or next(self.starUp_list_arr)==nil or self.current_star==nil then
        return
    end
    local _needNum = self.starUp_list_arr["goldcost" .. tostring(self.current_star+1) .. "star"]
    if _needNum==nil or tonumber(_needNum)==0 then
        return
    end
        if self:getChildByName("feicuiNum_label") then
            local _feicuiCostNumLabel =self:getChildByName("feicuiNum_label")
            _feicuiCostNumLabel:setString(getHugeNumberWithLongNumber(_needNum,1000000))

            local _currentFeicui = tonumber(gameUser.getFeicui())
            if _currentFeicui> tonumber(_needNum) then
                _feicuiCostNumLabel:setColor(cc.c3b(0,0,0))
            else
                _feicuiCostNumLabel:setColor(self:getStarUpTextColor("hongse"))
            end
        end
end

--刷新消耗品
function YingXiongStarUpNode:reFreshCostItemInfo(_chipNumber,_needChipNumber)
    local _costItemValue = _chipNumber or 0
    local _needItemValue = _needChipNumber or 0
    if self.costBg ~=nil then
		self.costItembg:initWithFile("res/image/item/props"..self.costItemStaticData.resourceid..".png")		
		self.costItemName:setString(self.costItemStaticData.name)
		
        local _costItemNumber_label = self._xiaohaoLableNode:getChildByName("costItemNumber_label")
        _costItemNumber_label:setString(_costItemValue)
        local _costItemNeedNum_label = self._xiaohaoLableNode:getChildByName("costItemNeedNum_label")
        _costItemNeedNum_label:setString(" / " .. (_needItemValue or 0))
		
		self._xiaohaoLableNode:setContentSize(_costItemNumber_label:getContentSize().width + _costItemNeedNum_label:getContentSize().width,_costItemNeedNum_label:getContentSize().height)
		_costItemNumber_label:setPosition(0,self._xiaohaoLableNode:getContentSize().height *0.5)
		_costItemNeedNum_label:setPosition(_costItemNumber_label:getPositionX() + _costItemNumber_label:getContentSize().width,self._xiaohaoLableNode:getContentSize().height *0.5)

        if tonumber(_needItemValue)>tonumber(_costItemValue) then
            _costItemNumber_label:setColor(cc.c3b(255,255,255))
        else
            _costItemNumber_label:setColor(cc.c3b(255,255,255))
        end
    end
    
end

function YingXiongStarUpNode:reFreshHeroStarupData(data)
    local _oldHeroData = clone(self.infoLayer.data)
    local property = data.petProperty
    if property then
        for i=1,#property do
            local _tab = string.split(property[i],',')
            DBTableHero.updateDataByPropId(gameUser.getUserId(),_tab[1],_tab[2],data["petId"] )
            gameUser.updateDataById(_tab[1],_tab[2])
            if tonumber(_tab[1]) == 407 then
                self._newFightValue = tonumber(_tab[2])
            end
        end
    end

    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})

    local _itemData = data["items"][1] or {}
    
    local _dbid =  _itemData and _itemData["dbId"] or nil
    if _dbid==nil then
        return
    end
    if data["items"][1]["count"] and data["items"][1]["count"] > 0 then
        DBTableItem.updateCount(gameUser.getUserId(),data["items"][1],_dbid)
    else
        DBTableItem.deleteData(gameUser.getUserId(),_dbid)
    end
    self.infoLayer:refreshInfoLayer(data["petId"],"noEquip")

    -- local _starupResoultData = clone(self.infoLayer.data)
    -- _starupResoultData.oldPropertyData = _oldHeroData
    -- dump(_starupResoultData)
    local _resultData = {}
    _resultData.heroid = self.hero_id
    _resultData.star = self.infoLayer.data.star or 1
    _resultData.oldProperty = {}
    _resultData.newProperty = {}
    for i=1,#self.detail_ziduan do
        _resultData.oldProperty[self.detail_ziduan[i] .. "grow"] = self:getAddNumber(self.detail_ziduan[i] ,tonumber(_resultData.star)-1)
        _resultData.newProperty[self.detail_ziduan[i] .. "grow"] = self:getAddNumber(self.detail_ziduan[i] ,tonumber(_resultData.star))
    end
    musicManager.playEffect("res/sound/StarUP.mp3")
    local _popLayer = requires("src/fsgl/layer/YingXiong/YingXiongStarupResultPopLayer.lua")
    local _resoultPopLayer = _popLayer:create(_resultData,self.infoLayer)
    -- self.infoLayer:setButtonClickableState(true)
    self.infoLayer:addChild(_resoultPopLayer,3)      
    
    
    if tonumber(data["petId"])==tonumber(self.infoLayer.data.heroid) then
        
        self:reFreshHeroFunctionInfo()
    end
end

function YingXiongStarUpNode:reFreshHeroFunctionInfo()
    self.data = self.infoLayer.data
--	print("99999999999999999999")
--	print_r(self.data)
    self.items_data = self.infoLayer.items_data
    self.current_star = self.data["star"]
	self:setChipNum()

    self:setPropertyPart(self.data)
    --如果当前不到满星
    if self.current_star < self.maxStar then
        self.startUp_list = self.starUp_list_arr["starcount" .. tostring(self.current_star+1)]
        self.startUp_list = self.startUp_list or 0

        self:setStarUpButtonEffect()
        
        self:reFreshCostFeicui()
        self:reFreshCostItemInfo(self.chip_number,self.startUp_list)
    else
        self:removeAdvanceElement()
        if self.start_star_up_btn~=nil then
            self:removeStarUpButtonEffect()
            self.start_star_up_btn:removeFromParent()
            self.start_star_up_btn = nil
        end
        if not self:getChildByName("prompLabel") then
            local _prompLabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.starupTopPromptTextXc,self.starup_fontSize)
            _prompLabel:setColor(cc.c3b(0,0,0))
            -- local _promptPosY = (_starUpCostTitle_bg:getBoundingBox().y + start_star_up_btn:getBoundingBox().y + start_star_up_btn:getBoundingBox().height)/2
            _prompLabel:setPosition(cc.p(self:getContentSize().width/2,self._promptPosY))
            self:addChild(_prompLabel)
        end
        
    end
end
-----------------刷新Ended--------------------

--获取英雄升级界面的文字颜色
function YingXiongStarUpNode:getStarUpTextColor(_str)
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

function YingXiongStarUpNode:create(heroData,items_data,target_layer)
	local _node = self.new(heroData,items_data,target_layer);
	return _node;
end

function YingXiongStarUpNode:onEnter( )
    ----------引导
    self:addGuide()
    ----------------------------------------------------
end

function YingXiongStarUpNode:addGuide( )
    ----------引导
    if not self.start_star_up_btn then 
        performWithDelay(self, function( )
            YinDaoMarg:getInstance():removeCover(self.infoLayer)
        end,0.1)
        return 
    else
        YinDaoMarg:getInstance():addGuide({ ----进阶引导
            parent = self.infoLayer,
            target = self.start_star_up_btn,
            index = 6,
        },13)
    end 
    performWithDelay(self.start_star_up_btn,function( )
        YinDaoMarg:getInstance():doNextGuide()   
        YinDaoMarg:getInstance():removeCover(self.infoLayer)
    end,0.1)
    ----------------------------------------------------
end

return YingXiongStarUpNode