--[=[
    FileName:JieRiKuangHuangLayer.lua
    Autor:tangshicong
    Date:2016.1.18
    Content:新年活动界面
    为了控制主城新年活动按钮是否开启，在mainMenuCityLayer文件需要判断新年活动开启装状态，新年活动需要去该文件添加开启id
]=]
local JieRiKuangHuangLayer = class("JieRiKuangHuangLayer", function(tab)
    return XTHD.createBasePageLayer()
end)

function JieRiKuangHuangLayer:ctor(tab,data)
	self._openState = {}
    self._inited = false
    self._contentBg = nil
    self._tableView = nil
	self._nowOpenData = {}
    self.selectedIndex = 0
    self.selectedTab = nil
    self.redDotTable = {}
	self._btnTable = {}
	self._duihuan = data.configList
	
	self:getOpenActivity()
	self:switchTab(tab)
end

function JieRiKuangHuangLayer:onEnter()
	musicManager.playMusic(XTHD.resource.music.effect_jierikuanghuan_bgm )
end

function JieRiKuangHuangLayer:onExit()
	musicManager.playMusic(XTHD.resource.music.music_bgm_main )
end

function JieRiKuangHuangLayer:onCleanup()
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_GONGXIFACAI)
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    RedPointState[1].state = 0
    for i = 1,#self._btnTable do
        if self._btnTable[i]:getChildByName("redPoint") then
            if self._btnTable[i]:getChildByName("redPoint"):isVisible() == true then
                RedPointState[1].state = 1
                break
            end
        end
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "jrkh"}})
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/activities/newyear/bottomSnow.png")
    textureCache:removeTextureForKey("res/image/activities/newyear/background.png")
    textureCache:removeTextureForKey("res/image/activities/newyear/actAdorn_right.png")
    textureCache:removeTextureForKey("res/image/activities/newyear/actTab_normal.png")
    textureCache:removeTextureForKey("res/image/activities/newyear/actTab_selected.png")
    for i=1, 8 do
        textureCache:removeTextureForKey("res/image/activities/newyear/activitiesTab_" .. i .. ".png")
    end
    helper.collectMemory()
end

function JieRiKuangHuangLayer:initWithData()
    --[[左边的tab]]
    local _topBarHeight = self.topBarHeight
	self:getChildByName("TopBarLayer1"):setBackMusic(XTHD.resource.music.effect_btn_commonclose)
    -- 15度
    local snow_small1 = cc.ParticleSnow:createWithTotalParticles(13)
    snow_small1:setPosition(self:getContentSize().width/2, self:getContentSize().height)
    snow_small1:setTexture(cc.Director:getInstance():getTextureCache():addImage("res/image/activities/newyear/snowflake_small.png"))
    self:addChild(snow_small1,1)
    snow_small1:setEmissionRate(0.25)
    snow_small1:setStartSize(3)
    snow_small1:setStartSize(5)
    snow_small1:setAngle(255)
    snow_small1:setSpeed(50)
    -- 左侧45度
    local snow_small2 = cc.ParticleSnow:createWithTotalParticles(60)
    snow_small2:setPosition(self:getContentSize().width/2, self:getContentSize().height)
    snow_small2:setTexture(cc.Director:getInstance():getTextureCache():addImage("res/image/activities/newyear/snowflake_small.png"))
    self:addChild(snow_small2,1)
    snow_small2:setStartSize(3)
    snow_small2:setStartSizeVar(5)
    snow_small2:setEmissionRate(0.8)
    snow_small2:setAngle(225)
    snow_small2:setSpeed(50)
    -- 右侧45度
    local snow_small3 = cc.ParticleSnow:createWithTotalParticles(60)
    snow_small3:setPosition(self:getContentSize().width*4/3, self:getContentSize().height)
    snow_small3:setTexture(cc.Director:getInstance():getTextureCache():addImage("res/image/activities/newyear/snowflake_small.png"))
    self:addChild(snow_small3,1)
    snow_small3:setStartSize(3)
    snow_small3:setStartSizeVar(5)
    snow_small3:setEmissionRate(0.8)
    snow_small3:setAngle(225)
    snow_small3:setSpeed(50)
    -- 中间雪花
    local snow_small4 = cc.ParticleSnow:createWithTotalParticles(10)
    snow_small4:setPosition(self:getContentSize().width/3, self:getContentSize().height*2/3)
    snow_small4:setTexture(cc.Director:getInstance():getTextureCache():addImage("res/image/activities/newyear/snowflake_small.png"))
    self:addChild(snow_small4,1)
    snow_small4:setStartSize(3)
    snow_small4:setStartSizeVar(5)
    snow_small4:setEmissionRate(10)
    snow_small4:setDuration(0.5)
    snow_small4:setAngle(225)
    snow_small4:setSpeed(50)
    local snow_small5 = cc.ParticleSnow:createWithTotalParticles(10)
    snow_small5:setPosition(self:getContentSize().width*2/3, self:getContentSize().height*2/3)
    snow_small5:setTexture(cc.Director:getInstance():getTextureCache():addImage("res/image/activities/newyear/snowflake_small.png"))
    self:addChild(snow_small5,1)
    snow_small5:setStartSize(3)
    snow_small5:setStartSizeVar(5)
    snow_small5:setEmissionRate(10)
    snow_small5:setDuration(0.5)
    snow_small5:setAngle(225)
    snow_small5:setSpeed(50)
    -- 大雪花
    local snow_big = cc.ParticleSnow:createWithTotalParticles(6)
    snow_big:setPosition(self:getContentSize().width/2, self:getContentSize().height)
    snow_big:setTexture(cc.Director:getInstance():getTextureCache():addImage("res/image/activities/newyear/snowflake_big.png"))
    self:addChild(snow_big,1)
    snow_big:setEmissionRate(0.4)
    snow_big:setStartSize(25)
    snow_big:setStartSizeVar(10)
    snow_big:setAngle(255)
    snow_big:setSpeed(50)
	
    local _contentBg = cc.Sprite:create("res/image/activities/newyear/background.png")
	--_contentBg:setScaleY(0.9)
    self._contentBg = _contentBg
    --bg2
    local bg2 = ccui.Scale9Sprite:create("res/image/activities/newyear/bg2.png")
    bg2:setPosition(_contentBg:getContentSize().width/2,_contentBg:getContentSize().height/2-35)
    _contentBg:addChild(bg2)

    local _tableViewSize = cc.size(120,420)
    --contentBg下面需要多留10pixels
    local _contentPosY = (self:getContentSize().height)/2
    _contentBg:setAnchorPoint(cc.p(0.5,0.5))
    _contentBg:setPosition(cc.p(self:getContentSize().width/2,_contentPosY - 20))
    self:addChild(_contentBg)

    local _rightSp = cc.Sprite:create("res/image/activities/newyear/actAdorn_right.png")
    _rightSp:setPosition(cc.p(_contentBg:getBoundingBox().x + _contentBg:getBoundingBox().width -58,_rightSp:getContentSize().height/2))
    self:addChild(_rightSp)
    -- 740*428
    local activityBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_37.png")
    activityBg:setContentSize(640,428)
    activityBg:setAnchorPoint(cc.p(0,0))
    activityBg:setPosition( 190, 40 )
    activityBg:setOpacity(0)
    self._contentBg:addChild( activityBg )
    self._activityBg = activityBg
	
	self._tableView = ccui.ListView:create()
    self._tableView:setContentSize(_tableViewSize)
    self._tableView:setDirection(ccui.ScrollViewDir.vertical)
    self._tableView:setScrollBarEnabled(false)
    self._tableView:setBounceEnabled(true)
	self._tableView:setPosition(97,48)
	self._contentBg:addChild(self._tableView,2)
	
	for i = 1,self._tabNumber do
		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(140,80))
		
		local btnName = string.format("res/image/activities/newyear/activitiesTab_%d.png",self._activityOpen[i].pictureid)
		local _cellBtn = XTHD.createButton({
			normalFile = btnName,
            selectedFile = btnName,
            anchor = cc.p(0.5,0.5),
            pos = cc.p(layout:getContentSize().width*0.5 - 10,layout:getContentSize().height*0.5 - 5),
			isScrollView = true,
            needEnableWhenMoving = true,
        })
		_cellBtn:setSwallowTouches(false)
		self._btnTable[#self._btnTable + 1] = _cellBtn
		layout:addChild(_cellBtn)
		self:addTabRedPoint(_cellBtn,i)
		_cellBtn:setTouchEndedCallback(function()
			for j = 1, #self._btnTable do
				if self._btnTable[j]:getChildByName("selectPic") then
					self._btnTable[j]:getChildByName("selectPic"):setVisible(false)
				end
			end
			if self._btnTable[i]:getChildByName("selectPic") then
				self._btnTable[i]:getChildByName("selectPic"):setVisible(true)
			end
            self.selectedTab = _cellBtn
            self.selectedIndex = idx
            self:switchTab(i)
        end)
		local selectPic = cc.Sprite:create("res/image/activities/newyear/actTab_selected_2.png")
		_cellBtn:addChild(selectPic)
		selectPic:setName("selectPic")
		selectPic:setPosition(_cellBtn:getContentSize().width*0.5,_cellBtn:getContentSize().height*0.5)
		if i ~= 1 then
			selectPic:setVisible(false)
		end
		self._tableView:pushBackCustomItem(layout)
	end
	self:freshRedDot()
end


function JieRiKuangHuangLayer:getOpenActivity()

    local activityStatic = {
        --累计充值
		[1] = {
            url = "holidayActivatList?",
            file = "ChongZhiFanLiLayer.lua",
            -- title = LANGUAGE_KEY_ACTIVITYTAB[13],
            priority = 750,
            isOpen = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 34,                   -- 活动开启id，后端控制
            pictureid = 1,
        },
        [2] = {
            url = "holidayActivatList?",
            file = "XiaoFeiFanLiLayer.lua",
            -- title = LANGUAGE_KEY_ACTIVITYTAB[13],
            priority = 750,
            isOpen = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid = 35,                   -- 活动开启id，后端控制
            pictureid = 2,
        },
        --天赐神符
        [3] = {
            url = "chouRewardList?",
            file = "TianCiShenFuLayer.lua",
            priority = 850,
            isOpen = 0,
            isOpenid = 8,
            pictureid = 3,
        },
		[4] = {
            url = "holidayActivatExchangeList?",
            file = "JieriduihuanLayer.lua",
            priority = 850,
            isOpen = 0,
            isOpenid = 39,
            pictureid = 4,
        },
		[5] = {
            url = "holidayActivatExchangeList?",
            file = "JieriduihuanLayer.lua",
            priority = 850,
            isOpen = 0,
            isOpenid = 37,
            pictureid = 5,
        },
		[6] = {
            url = "holidayActivatExchangeList?",
            file = "JieriduihuanLayer.lua",
            priority = 850,
            isOpen = 0,
            isOpenid = 36,
            pictureid = 6,
        },
		[7] = {
            url = "holidayActivatExchangeList?",
            file = "JieriduihuanLayer.lua",
            priority = 850,
            isOpen = 0,
            isOpenid = 38,
            pictureid = 7,
        },
		
    }
	local _openState = gameUser.getActivityOpenStatus() or {}
	self._activityOpen = {}
	for i=1,#activityStatic do
		if tonumber(activityStatic[i].isOpen) == 1  then
			self._activityOpen[#self._activityOpen + 1] = activityStatic[i]
		else
			local activityState = _openState[tostring( activityStatic[i].isOpenid or 0 )] or 0
			if tonumber( activityState ) == 1 then
				self._activityOpen[#self._activityOpen + 1] = activityStatic[i]
			end
		end
	end
	table.sort(self._activityOpen,function(data1,data2)
		return tonumber(data1.isOpenid)<tonumber(data2.isOpenid)
	end)
	
	self._tabNumber = table.nums(self._activityOpen)
    
end

function JieRiKuangHuangLayer:switchTab(tab)
    local tabIdx = tonumber(tab or 1)
	
		if self._inited == false then
            self:initWithData()
            self._inited = true
            LayerManager.addLayout(self)
            -- XTHD.runActionPop(self._contentBg)
        end
    local turnToOtherActFunc = function(data)
        if self._activityBg:getChildByName("activityTabLayer") then
            self._activityBg:removeChildByName("activityTabLayer")
        end

        local layer = requires("src/fsgl/layer/HuoDong/" .. self._activityOpen[tabIdx].file):create({httpData = data,parentLayer = self, anctivityid =  self._activityOpen[tab].isOpenid,data = data})
        layer:setName("activityTabLayer")
        layer:setAnchorPoint(cc.p(0.5,0.5))
        layer:setPosition(cc.p(self._activityBg:getContentSize().width/2,self._activityBg:getContentSize().height/2))
        self._activityBg:addChild(layer)
    end


    if  self._activityOpen[tabIdx] ==nil then
        return
    end
   
    if not self._activityOpen[tabIdx].url then
        turnToOtherActFunc()
    else
		if tab == 1 then
			ClientHttp:httpActivity(self._activityOpen[tabIdx].url,self,function(data)
				turnToOtherActFunc(data)
			end,{})
		else
			self:newHttpActivity(tab,turnToOtherActFunc)
		end
    end
  
end

function JieRiKuangHuangLayer:getDuiHuanRedPoint(_isOpenId)
	local data = gameData.getDataFromCSV("HolidayExchange" )
	local duihuanList = {}
	for k,v in pairs(data) do
		if v.type == tonumber(_isOpenId) then
			duihuanList[#duihuanList + 1] = v
		end
	end
	
	local countList = {}
	
	for k,v in pairs(duihuanList) do
		for i = 1,#self._duihuan do
			if v.id == self._duihuan[i].configId then
				countList[#countList + 1] = self._duihuan[i]
			end
		end
	end
	
	for k, v in pairs(countList) do
		if v.count <= 0 then
			return false
		end
	end

	local table = {}
	for j = 1,#duihuanList do
		local data = duihuanList[j]
		local index = #table+1 
		table[index] = true
		for i = 1,3 do
			local itemId = data["exchangeid"..tostring(i)]
			local num_1 = data["exchangenum"..tostring(i)]
			local num_2 = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = itemId}).count or 0
			if num_1 > num_2 then
				table[index] = false
				break
			end
		end
	end

 	for k,v in pairs(table) do
		if v == true then
			return true
		end
	end
	return false
end

function JieRiKuangHuangLayer:newHttpActivity(_index,callback)
	ClientHttp:requestAsyncInGameWithParams({
        modules = self._activityOpen[_index].url,
		params = { activityId  = self._activityOpen[_index].isOpenid },
        successCallback = function( data )
			callback(data)
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

function JieRiKuangHuangLayer:addTabRedPoint(_target,_idx)
    if _target==nil or _idx == nil then
        return 
    end
    if _target:getChildByName("redPoint") then
        _target:removeChildByName("redPoint")
    end
	
	local _redPointSp = cc.Sprite:create("res/image/common/heroList_redPoint.png")
	_redPointSp:setName("redPoint")
	_redPointSp:setAnchorPoint(cc.p(1,1))
	_redPointSp:setPosition(cc.p(_target:getContentSize().width,_target:getContentSize().height))
	_target:addChild(_redPointSp,1)
	_redPointSp:setVisible(false)
	self.redDotTable[_idx] = _redPointSp
end


--刷新小红点
function JieRiKuangHuangLayer:freshRedDot()	
	local isHave = true
	for i = 1, self._tabNumber do
		if self._activityOpen[i].isOpenid == 34 then		--充值有礼	
			isHave = RedPointState[23].state == 1
		elseif self._activityOpen[i].isOpenid == 8 then		--充值有礼
			isHave = false	
		elseif self._activityOpen[i].isOpenid == 35 then	--消费好礼
			isHave = RedPointState[24].state == 1
		elseif self._activityOpen[i].isOpenid == 36 then	--材料兑换
			local isEnough = self:getDuiHuanRedPoint(self._activityOpen[i].isOpenid)
			RedPointState[25].state = isEnough and 1 or 0
			isHave = RedPointState[25].state == 1
		elseif self._activityOpen[i].isOpenid == 37 then	--神装兑换
			local isEnough = self:getDuiHuanRedPoint(self._activityOpen[i].isOpenid)
			RedPointState[26].state = isEnough and 1 or 0
			isHave = RedPointState[26].state == 1
		elseif self._activityOpen[i].isOpenid == 38 then	--英雄兑换
			local isEnough = self:getDuiHuanRedPoint(self._activityOpen[i].isOpenid)
			RedPointState[27].state = isEnough and 1 or 0
			isHave = RedPointState[27].state == 1
		elseif self._activityOpen[i].isOpenid == 39 then	--稀有兑换
			local isEnough = self:getDuiHuanRedPoint(self._activityOpen[i].isOpenid)
			RedPointState[28].state = isEnough and 1 or 0
			isHave = RedPointState[28].state == 1
        end
		self.redDotTable[i]:setVisible(isHave)
	end
	RedPointState[1].state = isHave == true and 0 or 1
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "jrkh"}})

end

function JieRiKuangHuangLayer:createWithTab(tab,data)
    return JieRiKuangHuangLayer.new(tab,data)
end

return JieRiKuangHuangLayer