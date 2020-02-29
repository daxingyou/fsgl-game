--[限时英雄界面]

local XianShiYingXiongLayer = class("XianShiYingXiongLayer",function()
	local node = cc.Node:create()
	node:setContentSize(cc.size(693,415))
	node:setAnchorPoint(0.5,0.5)
	return node
end)

function XianShiYingXiongLayer:ctor(data)
	self.redColor = cc.c4b(236,162,0,255)
	
	self:setTimeHeroData(data)
	if self.infoData == nil then
		return
	end
	self.keyStr = {"hp","at","df","mat","mdf"}
	self:setStaticData()
	self:setCurrentCostResource()
	self:initLayer()
end


function XianShiYingXiongLayer:initLayer()
	local _popNode = XTHDSprite:create("res/image/plugin/timehero_act/timeHero_bg.png")
	_popNode:setScale(0.9)
	_popNode:setOpacity(0)
	_popNode:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
	self.popNode = _popNode
	self:addChild(_popNode)
	_popNode:setSwallowTouches(true)
	--背景
	local bg = ccui.Scale9Sprite:create("res/image/plugin/timehero_act/bg.png")
	-- bg:setContentSize()
	bg:setPosition(_popNode:getContentSize().width/2-3,_popNode:getContentSize().height/2-30)
	_popNode:addChild(bg)

    local _skillBtn = XTHD.createButton({
	    	normalNode = cc.Sprite:create(),
	    	selectedNode = cc.Sprite:create(),
	    	touchSize = cc.size(290,270)
    		-- normalFile = "res/image/plugin/timehero_act/timeHero_skill_normal.png",
    		-- selectedFile = "res/image/plugin/timehero_act/timeHero_skill_selected.png",
    	})
    _skillBtn:setAnchorPoint(cc.p(0.5,0.5))
    _skillBtn:setPosition(cc.p(_popNode:getContentSize().width/2,150+270/2))
    _popNode:addChild(_skillBtn)
    _skillBtn:setTouchEndedCallback(function()
    		local _popLayer = requires("src/fsgl/layer/HuoDong/TimeHeroShowLayer1.lua"):create(self.infoData.petId)
            if _popLayer ~=nil and self:getParent() then
                cc.Director:getInstance():getRunningScene():addChild(_popLayer,self:getLocalZOrder())
            end
    	end)

    local _titlePosY = _popNode:getContentSize().height - 90
    local _titleSp = cc.Sprite:create("res/image/activities/TimelimitActivity/heroname"..self.infoData.petId..".png")
	_titleSp:setAnchorPoint(cc.p(0.5,0.5))
    _titleSp:setPosition(cc.p(_popNode:getContentSize().width/2,_titlePosY))
    _popNode:addChild(_titleSp)

    --self:refreshHeroName()

    local _leftPosX = 75
    local _actTimeTitle = XTHDLabel:create("活动时间:",20)                      -------------------活动时间
    _actTimeTitle:setAnchorPoint(cc.p(0,0.5))
    _actTimeTitle:setColor(self.redColor)
    _actTimeTitle:enableShadow(self.redColor, cc.size(0.4,-0.4), 0.4)
    _actTimeTitle:setPosition(cc.p(_actTimeTitle:getContentSize().width,_titlePosY + 30))
    _popNode:addChild(_actTimeTitle)

    local _actTimeValue = XTHDLabel:create("0",20)
    _actTimeValue:setAnchorPoint(cc.p(0,0.5))
    self.actTimeValue = _actTimeValue
    _actTimeValue:setColor(self.redColor)
    _actTimeValue:enableShadow(self.redColor, cc.size(0.4,-0.4), 0.4)
    _actTimeValue:setPosition(cc.p(_actTimeTitle:getBoundingBox().x+_actTimeTitle:getBoundingBox().width + 10,_actTimeTitle:getPositionY() ))
    _popNode:addChild(_actTimeValue)

	self:refreshActTimeValue()
	
	--框1 
	local kuang1 = ccui.Scale9Sprite:create("res/image/plugin/timehero_act/kaung1.png")
	kuang1:setContentSize(kuang1:getContentSize().width - 10,kuang1:getContentSize().height + 10)
	kuang1:setAnchorPoint(0,1)
	kuang1:setPosition(_leftPosX + 4,430)
	_popNode:addChild(kuang1)
    local _propertyPosX = _leftPosX + 3
    local _heroPropertyTitle = cc.Sprite:create("res/image/activities/TimelimitActivity/herorank.png")  --------------------------英雄评分
	_heroPropertyTitle:setScale(1.25)
    _heroPropertyTitle:setPosition(cc.p(kuang1:getContentSize().width*0.5,kuang1:getContentSize().height - _heroPropertyTitle:getContentSize().height *0.5 - 10))
	kuang1:addChild(_heroPropertyTitle)

	self.propertyTable = {}
	for i=1,5 do
		local _propertyPosY = kuang1:getContentSize().height - 38*i+165
		local _propertyTitle = XTHDLabel:create(LANGUAGE_ILLUSTRATION_HEROSCORE[i],20)
		_propertyTitle:setColor(cc.c3b(245,214,51))
		_propertyTitle:enableShadow(self.redColor,cc.size(0.4,-0.4),0.4)
		_propertyTitle:setAnchorPoint(cc.p(0,1))
		_propertyTitle:setPosition(cc.p(_propertyPosX + 20,_propertyPosY))
		_popNode:addChild(_propertyTitle)

		local _propertyValue = XTHDLabel:create("0",20)
		self.propertyTable[i] = _propertyValue
		_propertyValue:setColor(cc.c3b(245,214,51))
		_propertyValue:setAnchorPoint(cc.p(0,1))
		_propertyValue:enableShadow(self.redColor,cc.size(0.4,-0.4),0.4)
		_propertyValue:setPosition(cc.p(_propertyTitle:getBoundingBox().x+_propertyTitle:getBoundingBox().width + 10,_propertyPosY))
		_popNode:addChild(_propertyValue)
	end

	self:refreshPropertyValue()

	--框1 
	local kuang2 = ccui.Scale9Sprite:create("res/image/plugin/timehero_act/kuang2.png")
	kuang2:setAnchorPoint(0,1)
	kuang2:setContentSize(kuang1:getContentSize())
	kuang2:setPosition(635,430)
	_popNode:addChild(kuang2)
	local _skillTitle = cc.Sprite:create("res/image/activities/TimelimitActivity/heroSkill.png")
	_skillTitle:setAnchorPoint(0,0.5)
	_skillTitle:setScale(1.25)
    _skillTitle:setPosition(cc.p(0,kuang2:getContentSize().height - _skillTitle:getContentSize().height *0.5 - 3))
	kuang2:addChild(_skillTitle)

	self:setSkillItems()

	--按钮
	local _buyBtn = XTHD.createButton({
			normalFile = "res/image/plugin/timehero_act/lananniu.png",
			selectedFile = "res/image/plugin/timehero_act/lananniu.png",
			text = "十连抽",
			ttf = "res/fonts/def.ttf",
			fontSize = 30,
		})
	-- local _buyBtn = XTHD.createCommonButton({
	-- 	btnColor = "write",
	-- 	text = "购买"
	-- })
	_buyBtn:setScale(0.6)
	_buyBtn:getLabel():setPositionX(_buyBtn:getLabel():getPositionX()-55)
	_buyBtn:getLabel():setPositionY(_buyBtn:getLabel():getPositionY()-5)
	_buyBtn:getLabel():enableOutline(cc.c4b(45,13,103,255),2)
	local _btnChildPosY = _buyBtn:getContentSize().height/2
	local btnText = cc.Sprite:create("res/image/plugin/timehero_act/timeHero_buytext.png")
	btnText:setAnchorPoint(cc.p(1,0.5))
	btnText:setPosition(cc.p(_buyBtn:getContentSize().width/2+22,_btnChildPosY))
	-- _buyBtn:addChild(btnText)

	local _resourceTitle = XTHDLabel:create(LANGUAGE_COSTNUMTITLE(self.infoData.costType),20)
    _resourceTitle:setAnchorPoint(cc.p(0,0.5))
    _resourceTitle:setColor(self.redColor)
    _resourceTitle:enableShadow(self.redColor, cc.size(0.4,-0.4), 0.4)
    _resourceTitle:setPosition(cc.p(_resourceTitle:getContentSize().width *0.5 + 20,_resourceTitle:getContentSize().height + 50))
    _popNode:addChild(_resourceTitle)

    local _resourceSp = cc.Sprite:create(self.infoData.resourceImg)
	_resourceSp:setScale(0.6)
    _resourceSp:setAnchorPoint(cc.p(0,0.5))
    _resourceSp:setPosition(cc.p(_resourceTitle:getBoundingBox().x+_resourceTitle:getBoundingBox().width,_resourceTitle:getPositionY()))
    _popNode:addChild(_resourceSp)

    local _resourceValue = XTHDLabel:create("0",20)
    _resourceValue:setAnchorPoint(cc.p(0,0.5))
    self.resourceValue = _resourceValue
    _resourceValue:setColor(self.redColor)
    _resourceValue:enableShadow(self.redColor, cc.size(0.4,-0.4), 0.4)
    _resourceValue:setPosition(cc.p(_resourceSp:getBoundingBox().x+_resourceSp:getBoundingBox().width,_resourceTitle:getPositionY() ))
    _popNode:addChild(_resourceValue)

    self:refreshResourceValue()
	-- IMAGE_KEY_HEADER_INGOT
	-- if tonumber(self.infoData.costType) == 2 then
	-- 	_costImg = IMAGE_KEY_HEADER_GOLD
	-- elseif tonumber(self.infoData.costType) == 3 then
	-- 	_costImg = IMAGE_KEY_HEADER_INGOT
	-- elseif tonumber(self.infoData.costType) == 6 then
	-- 	_costImg = IMAGE_KEY_HEADER_FEICUI
	-- elseif tonumber(self.infoData.costType) == 4 then
	-- 	local _costItemId = tonumber(self.infoData.costItemId or 2302)
	-- 	if _costItemId == 2302 then
	-- 		_costImg = IMAGE_KEY_HEADER_PSYCHICSTONE
	-- 	end
	-- end
	local _costSp = cc.Sprite:create(self.infoData.resourceImg)
	_costSp:setAnchorPoint(cc.p(0,0.5))
	_costSp:setScale(1)
	_costSp:setPosition(cc.p(btnText:getBoundingBox().x+btnText:getBoundingBox().width-30,_btnChildPosY))
	_buyBtn:addChild(_costSp)
	local _costLabel = getCommonWhiteBMFontLabel(0)
	-- XTHDLabel:create(0,16)
	self.costValue = _costLabel
	_costLabel:setFontSize(36)
	-- _costLabel:setColor(XTHD.resource.textColor.gray_text)
	_costLabel:setAnchorPoint(cc.p(0,0.5))
	_costLabel:setPosition(cc.p(_costSp:getBoundingBox().x+_costSp:getBoundingBox().width,_btnChildPosY-4))
	_buyBtn:addChild(_costLabel)

	_buyBtn:setPosition(cc.p(_popNode:getContentSize().width/2,75+55))
	_popNode:addChild(_buyBtn)
	_buyBtn:setTouchEndedCallback(function()
			self:buyBtnCallback(self.infoData.configId)
	end)

	self:refreshCostValue()

	local _lastNumTitle = XTHDLabel:create("全服剩余数量:",20)                       ----------------------全服剩余数量
    _lastNumTitle:setAnchorPoint(cc.p(0.5,0.5))
    _lastNumTitle:setColor(self.redColor)
    _lastNumTitle:enableShadow(self.redColor, cc.size(0.4,-0.4), 0.4)
    _lastNumTitle:setVisible(false)

    local _lastNumValue = XTHDLabel:create("0",20)
    self.lastNumValue = _lastNumValue
    _lastNumValue:setAnchorPoint(cc.p(0,0.5))
    _lastNumValue:setColor(self.redColor)
    _lastNumValue:enableShadow(self.redColor, cc.size(0.4,-0.4), 0.4)
    _lastNumValue:setVisible(false)

    _lastNumTitle:setPosition(cc.p(_popNode:getContentSize().width/2 -_lastNumValue:getContentSize().width/2-5,80))
    _lastNumValue:setPosition(cc.p(_lastNumTitle:getBoundingBox().x+_lastNumTitle:getBoundingBox().width + 10,_lastNumTitle:getPositionY()))
    _popNode:addChild(_lastNumTitle)
    _popNode:addChild(_lastNumValue)

    self:refreshLastNumTitle()

	self:setHeroSp()
end

function XianShiYingXiongLayer:buyBtnCallback(_configId)
	ClientHttp:httpCommon("recruitRequest?", self,{recruitType=1,sum=10,activityId=11}, function(data)   --exchangeLimitPet
		    print("限时英雄服务器返回的数据为：----------")
		    print_r(data)
			self.infoData.surplusCount = data.surplusCount or 0
			self:setCurrentCostResource()
			if data.bagItems and #data.bagItems ~= 0 then
                for i=1, #data.bagItems do
                    local item_data = data.bagItems[i]
                    DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
                end
            end
            if data.playerProperty then 
			    for i=1,#data.playerProperty do
		            local _tb = string.split(data.playerProperty[i],",")
			        gameUser.updateDataById(_tb[1], _tb[2])
			    end
		    	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
			end
            self:getHeroReward(1,data)
--            data["resultList"][1].id = data["resultList"][1].petId
--			gameData.saveDataToDB({[1] =data["resultList"][1]},1)
			self:refreshLastNumTitle()
			self:refreshResourceValue()
            self.resourceValue:setString(XTHD.resource.getItemNum(2310)) 
--			local layer = requires("src/fsgl/layer/QiXingTan/QiXingTanGetNewHeroLayer.lua"):create({
--        		par = cc.Director:getInstance():getRunningScene(),
--	            id = data["resultList"][1].petId,
--	            star = data["resultList"][1].starLevel,
--			})

			RedPointManage:getDynamicHeroData()
			RedPointManage:getDynamicItemData()
			RedPointManage:getDynamicDBHeroSkillData()
			XTHD.dispatchEvent({["name"] =CUSTOM_EVENT.REFRESH_FUNCTION_REDPOINT})

        end)
end

function XianShiYingXiongLayer:getHeroReward(_type, data )
    local _data = data
    if not _data then
        return
    end
    if not _data["addPets"] or not _data["resultList"] then
        return
    end
    local function _goShowReward()
		if _type == 1 then
			local showReward = requires("src/fsgl/layer/QiXingTan/QiXingTanShowHeroRewardPop.lua"):create(_data)
			LayerManager.pushModule(showReward)
		else
			local showReward = requires("src/fsgl/layer/QiXingTan/QiXingTanShowEquipRewardPop.lua"):create(data)
			LayerManager.pushModule(showReward)
		end
    end 

    if _data.serverAddress ~= "" and _data.token ~= "" then
        gameUser.setToken(_data.token)
        gameUser.setNewLoginToken(_data.token) 
        GAME_API = _data.serverAddress.."/game/"
        XTHDHttp:requestAsyncWithParams({
            url = _data.serverAddress .. "/game/newLogin?token="..gameUser.getNewLoginToken(),
            successCallback = function( sData )
                if sData.result == 0 then
                    cc.UserDefault:getInstance():setStringForKey(KEY_NAME_LAST_UUID, sData["uuid"])
                    cc.UserDefault:getInstance():flush()
                    gameUser.setSocketIP(0)
                    gameUser.setSocketPort(0)
                    gameUser.initWithData(sData)
                    MsgCenter:getInstance()
                    _goShowReward()
                    return 
                end
                gameUser.setToken(nil)
                LayerManager.backToLoginLayer()
            end,
            failedCallback = function()
                gameUser.setToken(nil)
                LayerManager.backToLoginLayer()
            end,
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    else
        if _data.serverAddress ~= "" then
            MsgCenter:getInstance()
        end
        _goShowReward()
    end
end

function XianShiYingXiongLayer:setHeroSp()
	local _heroid = self.infoData.petId or 1
	local _heroSp = XTHD.getHeroSpineById(_heroid)
	_heroSp:setPosition(cc.p(self.popNode:getContentSize().width/2,200))
	_heroSp:setAnimation(0,"idle",true)

	self.popNode:addChild(_heroSp)
end

function XianShiYingXiongLayer:setSkillItems()
	if self.skillTable == nil then
		self.skillTable = {}
	else
		for i=1,#self.skillTable do
			self.skillTable[i]:removeFromParent()
			self.skillTable[i] = nil
		end
	end
	self.skillTable = {}
	local _posY1 = 361-70
	local _posY2 = _posY1-56 - 10
	local _perWidth = (56+8)/2
	local _midPosX = 712
	local _posTable = {
		cc.p(_midPosX-_perWidth,_posY1),
		cc.p(_midPosX+_perWidth - 20,360),
		cc.p(_midPosX-_perWidth*2 + 56 + 61,_posY1),
		cc.p(_midPosX-_perWidth,_posY2),
		cc.p(_midPosX-_perWidth*2 + 56 + 61,_posY2),
	}
	for i=1,#self.skillIdData do
		local _skillData = self.staticSkillData[tostring(self.skillIdData[i])] or {}

		local _skillItem = JiNengItem:createWithParams({
				skillid 	= _skillData.skillid ,		--技能id
				name 		= _skillData.name ,			--技能名称
				icon 		= _skillData.icon ,			--技能icon
				description = _skillData.description ,	--技能描述
				ispassive 	= _skillData.ispassive 		--技能类型
			})
		_skillItem:setScale(0.7)
		_skillItem:setPosition(_posTable[i])
		self.popNode:addChild(_skillItem)
	end
end
--**
function XianShiYingXiongLayer:refreshHeroName()
	if self.heroName == nil then
		return
	end
	self.heroName:setString(self.staticGrowData.name or " ")
end
--**
function XianShiYingXiongLayer:refreshActTimeValue()
	if self.actTimeValue == nil then
		return
	end
	self.actTimeValue:setString(self.infoData.actTimeStr or "")
end
--**
function XianShiYingXiongLayer:refreshResourceValue()
	if self.resourceValue == nil then
		return
	end
	self.resourceValue:setString(getHugeNumberWithLongNumber(self.infoData.resourceNum or "",10000))
end
--**
function XianShiYingXiongLayer:refreshLastNumTitle()
	if self.lastNumValue == nil then
		return
	end
	self.lastNumValue:setString(self.infoData.surplusCount or "")
end

function XianShiYingXiongLayer:refreshCostValue()
	if self.costValue ==nil then
		return
	end
	self.costValue:setString(self.infoData.costItemSum or 0)
end

function XianShiYingXiongLayer:refreshPropertyValue()
	if self.propertyTable == nil or next(self.propertyTable)==nil then
		return
	end
	local _propertyData = self.staticGrowData
	for i=1,#self.propertyTable do
		local _str = _propertyData[tostring(self.keyStr[i] .. "point")]
		self.propertyTable[i]:setString(_str)
	end
end

function XianShiYingXiongLayer:setCurrentCostResource()
	local _resourceNum = gameUser.getIngot()
	local _costImg = IMAGE_KEY_HEADER_GOLD
	if tonumber(self.infoData.costType) == 2 then
		_resourceNum = gameUser.getGold()
		_costImg = IMAGE_KEY_HEADER_GOLD
	elseif tonumber(self.infoData.costType) == 3 then
		_resourceNum = gameUser.getIngot()
		_costImg = IMAGE_KEY_HEADER_INGOT
	elseif tonumber(self.infoData.costType) == 6 then
		_resourceNum = gameUser.getFeicui()
		_costImg = IMAGE_KEY_HEADER_FEICUI
	elseif tonumber(self.infoData.costType) == 4 then
		local _costItemId = tonumber(self.infoData.costItemId or 2302)
		-- if _costItemId == 2302 then
		-- 	_costImg = IMAGE_KEY_HEADER_PSYCHICSTONE
		-- end
		_costImg = IMAGE_KEY_HEADER_SHENJIANG
		local _table = DBTableItem.getData(gameUser.getUserId(),{itemid = tonumber(_costItemId)})
		if #_table<1 then
			_resourceNum = _table.count or 0
		else
			_resourceNum = _table[1].count or 0
		end
		-- DBTableItem:getDataByID() or 0
	end
	self.infoData.resourceNum = _resourceNum
	self.infoData.resourceImg = _costImg
end
--**
function XianShiYingXiongLayer:setStaticData()
	self.staticGrowData = {}
	local _heroGrowTable = gameData.getDataFromCSV("HeroData")
	local _heroid = tonumber(self.infoData.petId) or 1
	for k,v in pairs(_heroGrowTable) do
		if not _heroGrowTable[tostring(v.id)] and tonumber(v.id) == _heroid then
			self.staticGrowData = v
			break
		end
	end
	self:setSkillStaticData()
end
--**
function XianShiYingXiongLayer:setSkillStaticData()
	local data = gameData.getDataFromCSV("GeneralSkillList") or {}
	local _table = {}
	for k,v in pairs(data) do
		_table[v.heroid] = v
	end
	local _heroid = tonumber(self.infoData.petId or 1)
	local _skillid = _table[_heroid]
	local _skillIdKey = {"talent","skillid0","skillid1","skillid2","skillid3"}
	self.skillIdData = {}
	for i=1,#_skillIdKey do
		self.skillIdData[i] = _skillid[tostring(_skillIdKey[i])]
	end
	self.staticSkillData = gameData.getDataFromCSVWithPrimaryKey("JinengInfo")
end

function XianShiYingXiongLayer:setTimeHeroData(data)
	-- print("限时英雄的数据为：-----------")
	-- print_r(data)
	self.infoData = {}
	if data == nil or next(data) ==nil then
		return
	end
	local _table = data and data.list or {}
	self.infoData = _table[1] or {}
	local _acttimeStr = "00-00"
	_acttimeStr = data.beginMonth .. "." .. data.beginDay .. "-" .. data.endMonth .. "." .. data.endDay
	self.infoData.actTimeStr = _acttimeStr
end

function XianShiYingXiongLayer:create(data)
	local _layer = self.new(data)
	if _layer~=nil then
		return _layer
	end
end
return XianShiYingXiongLayer