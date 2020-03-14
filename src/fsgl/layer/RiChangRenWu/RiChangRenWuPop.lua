--Create By Liuluyang 2015年11月05日
local RiChangRenWuPop = class("RiChangRenWuPop",function ()
	return XTHD.createPopLayer()
end)

function RiChangRenWuPop:ctor(data)

	self._localData = gameData.getDataFromCSV("MartialList")
	self._showData = {}
    self:initData()
	self:initUI(data)
end

function RiChangRenWuPop:initData()
    self._showData = {}
    for i = 1,#self._localData do
        self._showData[i] = {}
        for j = 1,3 do
            if self._localData[i]["rewardtype"..j] ~= nil then
                local temp = {}
                if self._localData[i]["rewardtype"..j] == 4 then
                    temp.itemtype = 4
                    temp.itemid = self._localData[i]["canshu"..j]
                else
                    temp.itemtype = self._localData[i]["rewardtype"..j]
                end
                table.insert(self._showData[i],temp)
            end
        end
    end
end

function RiChangRenWuPop:initUI(data)
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	bg:setContentSize(cc.size(465,431))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)

	local icon = cc.Sprite:create("res/image/daily_task/"..data.name..".png")
	icon:setAnchorPoint(0.5,1)
	icon:setScale(0.6)
	icon:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-10)
	bg:addChild(icon)

	local x = icon:getContentSize().width * 1/(#self._showData[data.ywcIndex] + 1) 
    if #self._showData[data.ywcIndex] == 2 then
        x = icon:getContentSize().width * 1/(#self._showData[data.ywcIndex] + 1) - 2
    else
        x = icon:getContentSize().width * 1/(#self._showData[data.ywcIndex] + 1) + 15
    end 
    for k,v in pairs(self._showData[data.ywcIndex]) do 
        local _item = ItemNode:createWithParams({
            _type_ = v.itemtype, 
            itemId = v.itemid or 0,
            isShowCount = false,
            needSwallow = true,
        })
        _item:setScale(0.6)
        icon:addChild(_item)        
        _item:setPosition(x,_item:getBoundingBox().height + 110)
        if #self._showData[data.ywcIndex] == 2 then
            x = x + _item:getBoundingBox().width*2
        else
            x = x + _item:getBoundingBox().width + 10
        end   
    end 

	 local csvData = gameData.getDataFromCSV("FunctionInfoList")[data.id]                 ----------------关卡描述
	-- local desc = XTHDLabel:createWithParams({
	-- 	text = csvData.description,
	-- 	fontSize = 18,
	-- 	color = XTHD.resource.color.gray_desc
	-- })
	-- desc:setAnchorPoint(0,1)
	-- desc:setWidth(380)
	-- desc:setPosition(40,icon:getPositionY()-icon:getBoundingBox().height-10)
	-- bg:addChild(desc)

	local turnBtn = XTHD.createCommonButton({
			btnSize = cc.size(241,46),
			isScrollView = false,
			text = csvData.unlocktype == 2 and LANGUAGE_BTN_KEY.goLilian or LANGUAGE_BTN_KEY.goRenwu,
		})
		turnBtn:setScale(0.8)
	turnBtn:setPosition(bg:getBoundingBox().width/2,turnBtn:getBoundingBox().height/2+20)
	bg:addChild(turnBtn)

	turnBtn:setTouchEndedCallback(function ()
		if csvData.unlocktype == 1 then
			replaceLayer({
				id = 23
			})
		else
			replaceLayer({
				id = 1,
				chapterId = gameUser.getInstancingId()+1
			})
		end
	end)

	local unlockLabel = XTHDLabel:createWithParams({
		text = csvData.tip,
		fontSize = 18,
		color = cc.c3b(113,0,0)
	})
	unlockLabel:setAnchorPoint(0.5,0)
	unlockLabel:setPosition(bg:getBoundingBox().width/2,turnBtn:getPositionY()+turnBtn:getBoundingBox().height/2+5)
	bg:addChild(unlockLabel)
end

function RiChangRenWuPop:create(data)
	return RiChangRenWuPop.new(data)
end

return RiChangRenWuPop