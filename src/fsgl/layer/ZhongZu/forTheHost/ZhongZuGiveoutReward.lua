--[[
	种族发放奖励
	2015/12/08
	xingchen
]]

local ZhongZuGiveoutReward = class("ZhongZuGiveoutReward",function( )
	return XTHD.createBasePageLayer()
end)

function ZhongZuGiveoutReward:ctor(cityID,prePage)
	self._cityID = cityID
	self._prePage = prePage

	self.contentBg = nil 
	self.rechooseCount = 5
	self.rewardListItemsBg = {}
	self._selectedIndex = {} ------选取的要发送的物品ID

	self.rewardListData = gameData.getDataFromCSV("RacialCityAward")
	self._rewardIDArray = string.split(ZhongZuDatas._localCity[self._cityID].pickreward,"#")

	self:initLayer()
end

function ZhongZuGiveoutReward:create(cityID,prePage)
	local layer = self.new(cityID,prePage)
	return layer
end

function ZhongZuGiveoutReward:initLayer( )
	------背景
	local bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
	self:addChild(bg)
	bg:setPosition(self:getContentSize().width / 2,(self:getContentSize().height - self.topBarHeight) / 2)

	local _titleSp = cc.Sprite:create("res/image/camp/camp_label11.png")
	_titleSp:setAnchorPoint(cc.p(0.5,1))
	_titleSp:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height - 40))
	bg:addChild(_titleSp)

	-----第二层背景
	local _secondBg = ccui.Scale9Sprite:create()
	_secondBg:setContentSize(cc.size(bg:getContentSize().width - 8,406))	
	
	bg:addChild(_secondBg)
	_secondBg:setAnchorPoint(cc.p(0.5,0))
	_secondBg:setPosition(bg:getContentSize().width / 2,20)
	self.contentBg = _secondBg

	-- local _secondBgSp = ccui.Scale9Sprite:create("res/image/camp/camp_bg5.png")
	-- _secondBgSp:setAnchorPoint(cc.p(1,0))
	-- _secondBgSp:setPosition(cc.p(_secondBg:getContentSize().width-2,2))
	-- _secondBg:addChild(_secondBgSp)

	-- _secondBgSp = cc.Sprite:createWithTexture(_secondBgSp:getTexture())
	-- _secondBgSp:setFlippedX(true)
	-- _secondBgSp:setAnchorPoint(cc.p(0,0))
	-- _secondBgSp:setPosition(cc.p(2,2))
	-- _secondBg:addChild(_secondBgSp)

	self:initContentLayer()	
end

function ZhongZuGiveoutReward:initContentLayer( )
	local _upPosY = self.contentBg:getContentSize().height - 29
	local _introduceLabel = XTHDLabel:create(LANGUAGE_CAMP_GIVEOUTREWARD.introduce,18)
	_introduceLabel:setColor(cc.c3b(54, 55, 112))
	_introduceLabel:setAnchorPoint(cc.p(0,0.5))
	_introduceLabel:setPosition(cc.p(30,_upPosY))
	self.contentBg:addChild(_introduceLabel)
	--重新选择按钮
	local _rechooseBtn = XTHD.createCommonButton({
		btnColor = "write_1",
		isScrollView = false,
		text = LANGUAGE_BTN_KEY.rechoose,
		fontSize = 24,
	})
	_rechooseBtn:setScale(0.8)
	_rechooseBtn:setPosition(cc.p(self.contentBg:getContentSize().width - 70,_upPosY))
	self.contentBg:addChild(_rechooseBtn)
	_rechooseBtn:setTouchEndedCallback(function()
		self:rechooseBtnCallback()
	end)
	-----可选择次数字
	local _chooseCountTitle = XTHDLabel:create(LANGUAGE_CAMP_GIVEOUTREWARD.chooseCount,18)
	_chooseCountTitle:setColor(cc.c3b(54, 55, 112))
	_chooseCountTitle:setAnchorPoint(cc.p(1,0.5))
	_chooseCountTitle:setPosition(cc.p(_rechooseBtn:getBoundingBox().x-25,_upPosY))
	self.contentBg:addChild(_chooseCountTitle)
	----值
	local _chooseCount = XTHDLabel:create(self.rechooseCount,20)
	self.rechooseCountLabel = _chooseCount
	_chooseCount:setColor(cc.c3b(54, 55, 112))
	_chooseCount:setAnchorPoint(cc.p(0,0.5))
	_chooseCount:setPosition(cc.p(_chooseCountTitle:getBoundingBox().x+_chooseCountTitle:getBoundingBox().width,_upPosY))
	self.contentBg:addChild(_chooseCount)
	--rewardList
	local _rewardListBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
	_rewardListBg:setContentSize(cc.size(self.contentBg:getContentSize().width - 8*2,194))
	_rewardListBg:setAnchorPoint(cc.p(0.5,1))
	_rewardListBg:setPosition(cc.p(self.contentBg:getContentSize().width/2,self.contentBg:getContentSize().height - 57))
	self.contentBg:addChild(_rewardListBg)

	local _distance = _rewardListBg:getContentSize().width/12-5
	for i=1,6 do
		local _posX = _distance  * (i*2-1)+30
		local _btnSize = cc.size(133,_rewardListBg:getContentSize().height - 3*2-10)
		local _rewardItemBg = XTHD.createButton({
			normalNode = XTHD.getScaleNode("res/image/camp/scale9_bg_19.png",_btnSize),
			selectedNode = XTHD.getScaleNode("res/image/camp/scale9_bg_19.png",_btnSize),
			touchScale = 0.95,
			touchSize = _btnSize
		})
		_rewardItemBg:setPosition(cc.p(_posX,_rewardListBg:getContentSize().height/2))
		_rewardListBg:addChild(_rewardItemBg)
		_rewardItemBg:setTag(i)
		_rewardItemBg:setTouchEndedCallback(function()
			self:doClickReward(_rewardItemBg)
		end)
		self.rewardListItemsBg[i] = _rewardItemBg
	end
	self:setRewardItems()
	--------双倍发送
	local _sendBtnPosY = _rewardListBg:getBoundingBox().y/2
	local _leftBtnPosX = 295
	local _doubleSendBtn = self:createSendBtn(2,true)
	_doubleSendBtn:setPosition(cc.p(_leftBtnPosX,_sendBtnPosY))
	self.contentBg:addChild(_doubleSendBtn)
	_doubleSendBtn:setTouchEndedCallback(function()
		self:doDispatchReward(2)
	end)
	--------正常发送
	local _rightBtnPosX = self.contentBg:getContentSize().width - 295
	local _normalSendBtn = self:createSendBtn(1)
	_normalSendBtn:setPosition(cc.p(_rightBtnPosX,_sendBtnPosY))
	self.contentBg:addChild(_normalSendBtn)
	_normalSendBtn:setTouchEndedCallback(function()
		self:doDispatchReward()
	end)
end

function ZhongZuGiveoutReward:createSendBtn(_ratio,hasCost)
	local btnStr = LANGUAGE_CAMP_GIVEOUTREWARD.btnText
	local btnImg = {"write","write_1"}
	local textcolor = {XTHD.resource.btntextcolor.green,XTHD.resource.btntextcolor.blue_1}
	local costNum = {30,200}  --由500改成200
	local sendDesc = LANGUAGE_CAMP_GIVEOUTREWARD.sendDesc
	-- local _sendBtn = XTHD.createButton({
	-- 	normalNode = XTHD.getScaleNode("res/image/common/btn/btn_" .. btnImg[_ratio] .. "_up.png",cc.size(163,69)),
	-- 	selectedNode = XTHD.getScaleNode("res/image/common/btn/btn_" .. btnImg[_ratio] .. "_down.png",cc.size(163,69)),
	-- 	label = XTHDLabel:create(btnStr[_ratio],20),
	-- 	fontColor = cc.c3b(255,_g,_b)
	-- })
	local _sendBtn = XTHD.createCommonButton({
		btnColor = btnImg[_ratio],
		isScrollView = true,
		text = btnStr[_ratio],
	})
	_sendBtn:setScale(0.8)
	if hasCost then 
		local _costLabel = XTHDLabel:create(LANGUAGE_VERBS.cost1 .. ":",18)
		_costLabel:setColor(XTHD.resource.textColor.gray_text)
		local _ingotSp = cc.Sprite:create("res/image/common/header_ingot.png")
		_ingotSp:setAnchorPoint(cc.p(0,0.5))
		local _costNum = XTHDLabel:create(costNum[_ratio],18)
		_costNum:setColor(XTHD.resource.textColor.gray_text)
		_costNum:setAnchorPoint(cc.p(0,0.5))
		_costLabel:setPosition(cc.p(_sendBtn:getContentSize().width/2 - _ingotSp:getContentSize().width/2-_costNum:getContentSize().width/2,_sendBtn:getContentSize().height + 15))
		_ingotSp:setPosition(cc.p(_costLabel:getBoundingBox().x+_costLabel:getBoundingBox().width,_costLabel:getPositionY()))
		_costNum:setPosition(cc.p(_ingotSp:getBoundingBox().x+_ingotSp:getBoundingBox().width,_costLabel:getPositionY()))
		_sendBtn:addChild(_costLabel)
		_sendBtn:addChild(_ingotSp)
		_sendBtn:addChild(_costNum)
	end 

	local _descLabel = XTHDLabel:create(sendDesc[_ratio],18)
	_descLabel:setColor(cc.c3b(54,55,112))
	_descLabel:setAnchorPoint(cc.p(0.5,1))
	_descLabel:setPosition(cc.p(_sendBtn:getContentSize().width/2,-5))
	_sendBtn:addChild(_descLabel)
	return _sendBtn
end

function ZhongZuGiveoutReward:setRewardItems()
	for i = 1,#self.rewardListItemsBg do 
		local targ = self.rewardListItemsBg[i]
		targ:removeChildByName("rewardNode")
		local _data =  self.rewardListData[tonumber(self._rewardIDArray[i])]
		if _data then 			
			local _item = ItemNode:createWithParams({
                itemId = _data.rewardID,
                _type_ = _data.pickreward,
                count = _data.rewardnum,
			})
			_item:setScale(0.8)
			_item:setName("rewardNode")
			_item:setPosition(cc.p(targ:getContentSize().width/2,targ:getContentSize().height-11-40))
			targ:addChild(_item)
			targ.configID = _data.id
			-----名字
			if targ:getChildByName("rewardName") then 
				targ:getChildByName():setString(_item._Name)
			else
				local _rewardName = XTHDLabel:create(_item._Name,16)
				_rewardName:setName("rewardName")
				_rewardName:setColor(XTHD.resource.textColor.gray_text)
				_rewardName:setPosition(cc.p(targ:getContentSize().width/2,53))
				targ:addChild(_rewardName)
			end 
			if targ:getChildByName("chooseNum") then 
				targ:getChildByName("chooseNum"):setString("x0")
			else 
				------已选择的数量 
				local _selectedTimes = XTHDLabel:create("x0",24)
				_selectedTimes:setAnchorPoint(cc.p(0.5,0))
				_selectedTimes:setName("chooseNum")
				_selectedTimes:setColor(XTHD.resource.textColor.gray_text)
				_selectedTimes:setPosition(cc.p(targ:getContentSize().width/2,10))
				targ:addChild(_selectedTimes)
				targ.selectedWord = _selectedTimes
				targ.selectedTimes = 0
			end 
		end 
	end 
end
---------选择要发放的物品
function ZhongZuGiveoutReward:doClickReward(sender)
	if sender then 
		if #self._selectedIndex < 5 then 
			sender:getStateSelected():setVisible(true)
			if sender.selectedWord then 
				sender.selectedTimes = sender.selectedTimes + 1
				sender.selectedWord:setString("x"..sender.selectedTimes)
			end 
			self._selectedIndex[#self._selectedIndex + 1] = sender.configID
			self.rechooseCount = self.rechooseCount - 1
			self.rechooseCountLabel:setString(self.rechooseCount)
		else 
			for k,v in pairs(self._selectedIndex) do 
				if v == sender.configID then 
					sender:getStateSelected():setVisible(true)
					break
				end 
			end 
			XTHDTOAST(LANGUAGE_KEY_TOLIMIT)
		end 
	end 
end
---------点击重新选择按钮
function ZhongZuGiveoutReward:rechooseBtnCallback()
	local layer = XTHDConfirmDialog:createWithParams({
        msg = LANGUAGE_CAMP_TIPSWORDS46, ----你确定要重新选择奖励么？
        rightCallback = function( )
        	self._selectedIndex = {}
        	self.rechooseCount = 5
			self.rechooseCountLabel:setString(self.rechooseCount)
			for k,v in pairs(self.rewardListItemsBg) do 
				v:getStateSelected():setVisible(false)
				v.selectedTimes = 0
				v.selectedWord:setString("x0")
			end 
        end,
    })
    self:addChild(layer,10)
end
--_type为2是双倍发送，其他的，包括nil都是正常发送
function ZhongZuGiveoutReward:doDispatchReward(_type)
	if #self._selectedIndex < 1 then 
		XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS48) ----你还没有选择要发送的奖励
	else 
		local ids = json.encode(self._selectedIndex)
		XTHDHttp:requestAsyncInGameWithParams({
	        modules = "sendCityReward?",
	        params = {
	        	rewardType = (_type == nil) and 1 or _type,
	        	rewardIds = ids
	        },        
	        successCallback = function(data)
	            if tonumber(data.result) == 0 then
	            	gameUser.setIngot(data.ingot)
	            	XTHDTOAST(LANGUAGE_TIP_SUCCESS_TO_SEND) ----发送成功
	            	LayerManager.removeLayout()
	            elseif data.result == 4822 then -----你不是城主
	            	XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS49) ----有人取代了你的位置
	            else 
	            	XTHDTOAST(data.msg)
	            end
	        end,
	        failedCallback = function()
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
	        end,--失败回调
	        loadingParent = self,
	        loadingType = HTTP_LOADING_TYPE.CIRCLE--加载图显示 circle 光圈加载 head 头像加载
	    })
	end 
end

return ZhongZuGiveoutReward