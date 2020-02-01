local LoginTaskLayer = class("LoginTaskLayer", function(params)
    return XTHD.createFunctionLayer(cc.size(856,415))
end)

function LoginTaskLayer:ctor(params)
	local _data = params.httpData or {}
    self.totalDay = 0
    self.loginTaskData = {}
    self.currentRewardData = {}
    self.showReward = {}
    self.parentLayer = params.parentLayer or nil
    self:setLoginTaskData(_data)
    self:initLayer()
end

function LoginTaskLayer:initLayer()
	local _upHeight = 5
    local _midPosX = 305
    --advert picture
    local _advertSp = cc.Sprite:create("res/image/activities/logintask/logintask_advertsp.png")
    _advertSp:setAnchorPoint(cc.p(1,1))
    _advertSp:setPosition(cc.p(_midPosX,self:getContentSize().height - _upHeight))
    self:addChild(_advertSp)

    local _bg = cc.Sprite:create("res/image/activities/logintask/logintask_bg.png")
    _bg:setAnchorPoint(cc.p(0,0))
    _bg:setPosition(cc.p(_midPosX + 3,3))
    self:addChild(_bg)

    local _titleBg = cc.Sprite:create("res/image/activities/logintask/logintask_titlebg.png")
    _titleBg:setAnchorPoint(cc.p(0.5,0.5))
    _titleBg:setPosition(cc.p(_bg:getContentSize().width/2,_bg:getContentSize().height - 90))
    _bg:addChild(_titleBg)

    local _titleColor = cc.c4b(192,81,27,255)
    local _titleLabel = XTHDLabel:create("0",22)
    self.titleLabel = _titleLabel
    _titleLabel:setColor(_titleColor)
    _titleLabel:enableShadow(_titleColor,cc.size(0.4,-0.4),0.4)
    _titleLabel:setPosition(cc.p(_titleBg:getContentSize().width/2,_titleBg:getContentSize().height/2-4))
    _titleBg:addChild(_titleLabel)

    self:setTitleLabel()

    local _rewardBg = cc.Sprite:create("res/image/activities/logintask/logintask_rewardbg.png")
    self.rewardBg = _rewardBg
    _rewardBg:setAnchorPoint(cc.p(0.5,0))
    _rewardBg:setPosition(cc.p(_bg:getContentSize().width/2,170))
    _bg:addChild(_rewardBg)

    self:setRewardItem()

    local _lineSp = cc.Sprite:create("res/image/activities/logintask/logintask_linesp.png")
    _lineSp:setPosition(cc.p(_bg:getContentSize().width/2,130))
    _bg:addChild(_lineSp)

    local getBtnNode = function(_path)
    	local _node = ccui.Scale9Sprite:create(cc.rect(50,0,2,46),_path)
    	_node:setContentSize(cc.size(145,46))
    	return _node
	end
    local _rewardBtn = XTHD.createCommonButton({
            btnColor = "green",
            isScrollView = true,
            text = LANGUAGE_BTN_KEY.getReward,
    	})
    _rewardBtn:setPosition(cc.p(_bg:getContentSize().width/2,_lineSp:getBoundingBox().y/2))
    _bg:addChild(_rewardBtn)
    _rewardBtn:setTouchEndedCallback(function()
            self:rewardCallBack()
    	end)

    local _rewardDesc = XTHDLabel:create("0",20)
    self.rewardDesc = _rewardDesc
    _rewardDesc:setColor(_titleColor)
    _rewardDesc:setAnchorPoint(cc.p(0.5,0))
    _rewardDesc:enableShadow(_titleColor,cc.size(0.4,-0.4),0.4)
    _rewardDesc:setPosition(cc.p(_rewardBtn:getBoundingBox().x+_rewardBtn:getBoundingBox().width/2,_rewardBtn:getBoundingBox().y+_rewardBtn:getBoundingBox().height + 7))
    _bg:addChild(_rewardDesc)

    self:setRewardDescLabel()


end

function LoginTaskLayer:rewardCallBack()
    local _day = tonumber(self.currentRewardData.days or 0)
    ClientHttp:httpLoginTaskReward(self,function(data)
            self.loginTaskData[_day].state = 0
            self:getCurrentRewardData(_day + 1)
            for i=1,#data["property"] do
                local pro_data = string.split( data["property"][i],',')
                gameUser.updateDataById(pro_data[1],pro_data[2])
            end
            for i=1,#data.bagItems do
                DBTableItem.updateCount(gameUser.getUserId(),data.bagItems[i], data.bagItems[i]["dbId"])
            end
            ShowRewardNode:create(self.showReward)
            self:refreshLayer()
        end,{day = _day})
end

function LoginTaskLayer:setRewardItem()
	if self.rewardBg == nil then
		return
	end
    self.rewardBg:removeAllChildren()
    self.showReward = {}
    local _rewardNum = 0
    for i=1,4 do
        if self.currentRewardData["reword" .. i .. "num"] and tonumber(self.currentRewardData["reword" .. i .. "num"]) <1 then
            _rewardNum = i - 1
            break
        end
    end
	local _nameColor = cc.c4b(135,57,19)
	local _itemPosY = 7
	local _namePosY = 5
    local _rewardPos = SortPos:sortFromMiddle(cc.p(self.rewardBg:getContentSize().width/2,_itemPosY) ,_rewardNum,80)
    for i=1,_rewardNum do
        local _itemBg = cc.Sprite:create("res/image/activities/logintask/logintask_itembg.png")
        _itemBg:setAnchorPoint(cc.p(0.5,0))
        _itemBg:setPosition(_rewardPos[i])
        self.rewardBg:addChild(_itemBg)

        local _itemSp = ItemNode:createWithParams({
                itemId =  self.currentRewardData["reword" .. i .. "id"],
                _type_ = self.currentRewardData["reword" .. i .. "type"] or 1,
                touchShowTip = true,
                count = self.currentRewardData["reword" .. i .. "num"] or 0
            })
        _itemSp:setAnchorPoint(cc.p(0.5,0))
        _itemSp:setPosition(cc.p(_itemBg:getContentSize().width/2,15))
        _itemBg:addChild(_itemSp)

        local _itemNameLabel = XTHDLabel:create(_itemSp._Name or "",20)
        _itemNameLabel:setColor(_nameColor)
        _itemNameLabel:enableShadow(_nameColor,cc.size(0.4,-0.4),0.4)
        _itemNameLabel:setAnchorPoint(cc.p(0.5,1))
        _itemNameLabel:setPosition(cc.p(_itemBg:getPositionX(),_namePosY))
        self.rewardBg:addChild(_itemNameLabel)
        self.showReward[i] = {}
        self.showReward[i].rewardtype = self.currentRewardData["reword" .. i .. "type"]
        self.showReward[i].id = self.currentRewardData["reword" .. i .. "id"]
        self.showReward[i].num = self.currentRewardData["reword" .. i .. "num"]
    end

	
end

function LoginTaskLayer:setTitleLabel()
	if self.titleLabel == nil then
		return 
	end
    local _index = tonumber(self.currentRewardData["days"])
    local _dayStr = nil
    if tonumber(self.currentRewardData["days"]) == self.totalDay then
        _dayStr = LANGUAGE_DAYNAME[1]
    elseif tonumber(self.currentRewardData["days"])-1 == self.totalDay then
        _dayStr = LANGUAGE_DAYNAME[2]
    else
        _dayStr = LANGUAGE_TIPS_WORDS247[_index]
    end
	local _str = LANGUAGE_LOGINTASK_DESC(_dayStr,self.currentRewardData["level"])
	self.titleLabel:setString(_str)
end

function LoginTaskLayer:setRewardDescLabel()
    if self.rewardDesc ==nil then
        return
    end
    if self.currentRewardData["days"]>self.totalDay then
        --明日领取
        self.rewardDesc:setString(LANGUAGE_KEY_ACTIVITIES.loginTaskDescTextXc[3])
    else
        if tonumber(self.currentRewardData.level)<=tonumber(gameUser.getLevel()) then
            
            if tonumber(self.currentRewardData.state) == 0 and self.currentRewardData["days"] == #self.staticLoginData then
                --奖励已经全部领完
                self.rewardDesc:setString(LANGUAGE_KEY_ACTIVITIES.loginTaskDescTextXc[4])
            else
                --已满足条件
                self.rewardDesc:setString(LANGUAGE_KEY_ACTIVITIES.loginTaskDescTextXc[2])
            end
        else
            --等级不足
            self.rewardDesc:setString(LANGUAGE_KEY_ACTIVITIES.loginTaskDescTextXc[1])
        end
    end
end

function LoginTaskLayer:refreshLayer()
    self:setTitleLabel()
    self:setRewardDescLabel()
    self:setRewardItem()
end

function LoginTaskLayer:getCurrentIndex()
    local _index = nil
    local _staticData = self.staticLoginData
    for i=1,#self.loginTaskData do
        if tonumber(self.loginTaskData[i].day)<=self.totalDay and self.loginTaskData[i].state and tonumber(self.loginTaskData[i].state) == 1 then
            _index = i
            break
            -- if tonumber(_staticData[i].level)<=tonumber(gameUser.getLevel()) then
            --     print("sadfga")
                
            -- end
        end
    end
    if _index ==nil then
        if self.totalDay >=#self.staticLoginData then
            _index = #self.staticLoginData
        else
            _index = self.totalDay+1
        end
    end
    self:getCurrentRewardData(_index)
end

function LoginTaskLayer:getCurrentRewardData(_index)
    if _index == nil then
        return
    end
    if tonumber(_index)>#self.staticLoginData then
        _index = #self.staticLoginData
    end
	self.currentRewardData = {}
    
    self.currentRewardData = self.staticLoginData[tonumber(_index)] or {}
    self.currentRewardData.state = self.loginTaskData[tonumber(_index)]
end

function LoginTaskLayer:setLoginTaskData(_data)
	if _data == nil then
		return
	end
	self.loginTaskData = {}
	self.loginTaskData = _data.list or {}
	self.totalDay = tonumber(_data.totalDay or 0)
	table.sort(self.loginTaskData,function(data1,data2)
			return tonumber(data1.day)<tonumber(data2.day)
		end)
    self.staticLoginData = gameData.getDataFromCSV("LandReward")
    self:getCurrentIndex()
end

function LoginTaskLayer:create(params)
	local _layer = self.new(params)
	return _layer
end
return LoginTaskLayer