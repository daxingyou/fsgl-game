local ZhizunkaDalianye = class("ZhizunkaDalianye",function()
	return XTHDPopLayer:create({isHide = true})
end)

function ZhizunkaDalianye:ctor()
	self._Data = gameData.getDataFromCSV("MonthCard")
	self:init()
end

function ZhizunkaDalianye:init()
	local bg = cc.Sprite:create("res/image/zhizunkadalianye/bg.png")
	self:addContent(bg)
	bg:setPosition(self:getContentSize().width*0.5,self:getContentSize().height *0.5)
	
	local btn_close = XTHDPushButton:createWithParams({
		normalFile = "res/image/zhizunkadalianye/btn_close_up.png",
		selectedFile = "res/image/zhizunkadalianye/btn_close_down.png"
	})
	bg:addChild(btn_close)
	btn_close:setPosition(bg:getContentSize().width - btn_close:getContentSize().width *0.5 - 10,bg:getContentSize().height - btn_close:getContentSize().height *0.5 - 50)
	btn_close:setTouchEndedCallback(function()
		self:hide()
	end)
	
	local btn_goBuy = XTHDPushButton:createWithParams({
		normalFile = "res/image/zhizunkadalianye/btn_buy_up.png",
		selectedFile = "res/image/zhizunkadalianye/btn_buy_down.png"
	})
	bg:addChild(btn_goBuy)
	btn_goBuy:setPosition(bg:getContentSize().width *0.5 - btn_goBuy:getContentSize().width *0.5 - 20,btn_goBuy:getContentSize().height + 38)
	btn_goBuy:setTouchEndedCallback(function()
		self:PopZhizunka()
	end)

	local yueka_award = {}
	local index = 0
	while true do
		index = index + 1
		local awardType = "rewardType" .. index
		if self._Data[1]["rewardType"..tostring(index)] then
			local itemNode = nil
			if self._Data[1]["rewardType"..tostring(index)] ~= 4 then
				itemNode = ItemNode:createWithParams({
					_type_ = self._Data[1]["rewardType"..tostring(index)],
					count = self._Data[1]["num"..tostring(index)]
				})
			else
				itemNode = ItemNode:createWithParams({
					_type_ = self._Data[1]["rewardType"..tostring(index)],
					itemId = self._Data[1]["id"..tostring(index)],
					count = self._Data[1]["num"..tostring(index)],
				})
			end
			itemNode:setScale(0.4)
			bg:addChild(itemNode)
			itemNode:setPosition(85 + itemNode:getContentSize().width *0.5 + (index - 1)*itemNode:getContentSize().width *0.5,bg:getContentSize().height *0.5 + 34)
		else
			break;
		end 
	end

	index = 0
	while true do
		index = index + 1
		local awardType = "rewardType" .. index
		if self._Data[2]["rewardType"..tostring(index)] then
			local itemNode = nil
			if self._Data[2]["rewardType"..tostring(index)] ~= 4 then
				itemNode = ItemNode:createWithParams({
					_type_ = self._Data[2]["rewardType"..tostring(index)],
					count = self._Data[2]["num"..tostring(index)]
				})
			else
				itemNode = ItemNode:createWithParams({
					_type_ = self._Data[2]["rewardType"..tostring(index)],
					itemId = self._Data[2]["id"..tostring(index)],
					count = self._Data[2]["num"..tostring(index)],
				})
			end
			itemNode:setScale(0.4)
			bg:addChild(itemNode)
			itemNode:setPosition(85 + itemNode:getContentSize().width *0.5 + (index - 1)*itemNode:getContentSize().width *0.5,bg:getContentSize().height *0.5 - 40)
		else
			break;
		end 
	end
	self:setMonthWindow()
end

function ZhizunkaDalianye:setMonthWindow()
	HttpRequestWithParams("saveMonthWindow",{state = 2},function (data)
		gameUser.setMonthState(data.state)
	end)
end

function ZhizunkaDalianye:PopZhizunka()
	HttpRequestWithOutParams("mouthCardState",function (data)
        self:hide()
        local layer = requires("src/fsgl/layer/HuoDong/YueKaAndZhiZunKa.lua"):create(data)
        self:getParent():addChild(layer)
        layer:show()
	end)
end

function ZhizunkaDalianye:create()
	return ZhizunkaDalianye.new()
end

return ZhizunkaDalianye
