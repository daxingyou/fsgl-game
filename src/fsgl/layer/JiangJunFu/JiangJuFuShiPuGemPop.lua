--Created By Liuluyang 2015年06月13日
local JiangJuFuShiPuGemPop = class("JiangJuFuShiPuGemPop",function ()
	return XTHD.createPopLayer()
end)

function JiangJuFuShiPuGemPop:ctor(index,itemid)
	self:initUI(index,itemid)
end

function JiangJuFuShiPuGemPop:initUI(index,itemid)
	-- local bg = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_2.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
	bg:setName("bg")
	bg:setContentSize(cc.size(357,443))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)
	--框
	local kuang = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	kuang:setContentSize(cc.size(327,250))
	kuang:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2-50)
	kuang:setAnchorPoint(0.5,0)
	bg:addChild(kuang)

	local itemIcon = ItemNode:createWithParams({
		_type_ = 4,
		itemId = itemid,
	})
	itemIcon:setAnchorPoint(0,1)
	itemIcon:setPosition(40,bg:getBoundingBox().height-50)
	itemIcon:setScale(0.8)
	bg:addChild(itemIcon)

	local itemData = gameData.getDataFromCSV("ServanEquip",{id = itemid})

	local itemName = XTHDLabel:createWithParams({
        text = itemData.name,
        fontSize = 20,
        color = XTHD.resource.color.brown_desc
    })
    itemName:setAnchorPoint(0,1)
    itemName:setPosition(itemIcon:getPositionX()+itemIcon:getBoundingBox().width+10,itemIcon:getPositionY())
    bg:addChild(itemName)

    local OwnNum = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_OWN_COUNT(XTHD.resource.getItemNum(itemid)),
        fontSize = 20,
        color = XTHD.resource.color.brown_desc
    })
    OwnNum:setAnchorPoint(0,0)
    OwnNum:setPosition(itemIcon:getPositionX()+itemIcon:getBoundingBox().width+10,itemIcon:getPositionY()-itemIcon:getBoundingBox().height)
    bg:addChild(OwnNum)

	local attributesBg = ccui.Scale9Sprite:create(cc.rect(10,10,10,10),"res/image/common/scale9_bg_5.png")
	attributesBg:setOpacity(0)
	attributesBg:setContentSize(cc.size(324,26+23+42))
	attributesBg:setAnchorPoint(0.5,1)
	attributesBg:setPosition(bg:getBoundingBox().width/2,itemIcon:getPositionY()-itemIcon:getBoundingBox().height-20)
	bg:addChild(attributesBg)

	attributesBg.num = 0

	for i=1,#XTHD.resource.AttributesNum do
    	if itemData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]] ~= 0 then
    		local attrName = XTHDLabel:createWithParams({
		        text = XTHD.resource.getAttributes(XTHD.resource.AttributesNum[i]),
		        fontSize = 18,
		        color = XTHD.resource.color.brown_desc
		    })
		    attrName:setAnchorPoint(0,1)
		    attrName:setPosition(30,attributesBg:getPositionY()-10-((attributesBg.num)*(attrName:getBoundingBox().height+10)))
		    bg:addChild(attrName)

		    -- local percentStr = XTHD.resource.AttributesNum[i]
		    local attrPlus = XTHDLabel:createWithParams({
		        text = " +"..itemData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]].."%",
		        fontSize = 18,
		        color = XTHD.resource.color.brown_desc
		    })
		    attrPlus:setAnchorPoint(0,0.5)
		    attrPlus:setPosition(attrName:getPositionX()+attrName:getBoundingBox().width,attrName:getPositionY()-attrName:getBoundingBox().height/2)
		    bg:addChild(attrPlus)
		    attributesBg.num = attributesBg.num + 1

		    local split = cc.Sprite:create("res/image/plugin/reforge/main_bg_split.png")
            -- split:setAnchorPoint(0.5,0)
            split:setPosition(bg:getBoundingBox().width/2,attrName:getPositionY()-attrName:getBoundingBox().height-4)
            bg:addChild(split)
            self.split = split
    	end
    end
    if self.split then
    	self.split:removeFromParent()
    end

    local changeGem = XTHDPushButton:createWithParams({
    	musicFile = XTHD.resource.music.effect_btn_common,
    	normalNode = cc.Sprite:create("res/image/plugin/saint_beast/artifact_change.png"),
    	selectedNode = cc.Sprite:create("res/image/plugin/saint_beast/artifact_change.png")
	})
	changeGem:setPosition(95,80)
	bg:addChild(changeGem)
	changeGem:setScale(0.8)

	-- local changeSp = cc.Sprite:create("res/image/plugin/saint_beast/artifact_change.png")
	-- changeSp:setPosition(changeGem:getBoundingBox().width/2,changeGem:getBoundingBox().height/2)

	-- changeGem:addChild(changeSp)

	changeGem:setTouchEndedCallback(function ()
		self._parent:showSelectGem(index)
		self:hide()
	end)


	local unloadGem = XTHDPushButton:createWithParams({
		musicFile = XTHD.resource.music.effect_btn_common,
    	normalNode = cc.Sprite:create("res/image/plugin/saint_beast/artifact_unload.png"),
    	selectedNode = cc.Sprite:create("res/image/plugin/saint_beast/artifact_unload.png")
	})
	unloadGem:setPosition(bg:getBoundingBox().width-95,80)
	bg:addChild(unloadGem)
	unloadGem:setScale(0.8)

	-- local unloadSp = cc.Sprite:create("res/image/plugin/saint_beast/artifact_unload.png")
	-- unloadSp:setPosition(unloadGem:getBoundingBox().width/2,unloadGem:getBoundingBox().height/2)
	-- unloadGem:addChild(unloadSp)

	unloadGem:setTouchEndedCallback(function ()
		self._parent:unloadGem(index)
		self:hide()
	end)
end

function JiangJuFuShiPuGemPop:create(index,itemid,parent)
	self._parent = parent
	return JiangJuFuShiPuGemPop.new(index,itemid)
end

return JiangJuFuShiPuGemPop