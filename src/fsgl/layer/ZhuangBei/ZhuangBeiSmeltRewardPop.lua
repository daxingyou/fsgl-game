--Created By Liuluyang 2015年07月17日
local ZhuangBeiSmeltRewardPop = class("ZhuangBeiSmeltRewardPop",function ()
	return XTHD.createPopLayer()
end)

function ZhuangBeiSmeltRewardPop:ctor(data,callback)
	self:initUI(data,callback)
end

function ZhuangBeiSmeltRewardPop:initUI(data,callback)
	-- local bg = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_2.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
	bg:setContentSize(cc.size(495,407))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)

	-- local shadowBg = ccui.Scale9Sprite:create(cc.rect(43,18,1,1),"res/image/common/shadow_bg.png")
	local shadowBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	shadowBg:setContentSize(cc.size(462,263))
	shadowBg:setAnchorPoint(0.5,1)
	shadowBg:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-60)
	bg:addChild(shadowBg)

	local topLabel = XTHDLabel:createWithParams({
	    text = LANGUAGE_TIPS_WORDS55..":",---回收后可获得以下物品:",
	    fontSize = 20,
	    color = XTHD.resource.color.gray_desc
	})
	topLabel:setAnchorPoint(0,0.5)
	topLabel:setPosition(30,bg:getBoundingBox().height-35)
	bg:addChild(topLabel)

	local cancleBtn = XTHD.createCommonButton({
		btnColor = "write_1",
		btnSize = cc.size(130,51),
		isScrollView = false,
		text = LANGUAGE_KEY_CANCEL,
		fontSize = 26,
    })
    cancleBtn:setAnchorPoint(0.5,0)
    cancleBtn:setPosition(150,30)
	bg:addChild(cancleBtn)
	cancleBtn:setScale(0.6)
    cancleBtn:setTouchEndedCallback(function ()
    	self:hide()
    end)

    local confirmBtn = XTHD.createCommonButton({
		btnColor = "write",
		btnSize = cc.size(130,49),
		isScrollView = false,
		text = LANGUAGE_KEY_SURE,
		fontSize = 26,
    })
    confirmBtn:setAnchorPoint(0.5,0)
    confirmBtn:setPosition(bg:getBoundingBox().width-150,30)
	bg:addChild(confirmBtn)
	confirmBtn:setScale(0.6)
    confirmBtn:setTouchEndedCallback(function ()
    	if callback then
    		callback()
    		self:hide()
    	end
    end)

    for i=1,#data do
    	local nowData = data[i]
    	local itemIcon = ItemNode:createWithParams({
    		_type_ = nowData.rewardtype,
    		itemId = nowData.id,
    		count = nowData.num,
    		isShowCount = true
    	})
		itemIcon:setScale(0.8)
    	local posY = shadowBg:getBoundingBox().height/2
	    if #data > 4 then
			if i > 4 then
				posY = shadowBg:getBoundingBox().height/2 - 60 + 10
			else
				posY = shadowBg:getBoundingBox().height/2 + 60 + 10
			end
		end
    	itemIcon:setPosition(XTHD.resource.getPosInArr({
    		lenth = 30,
			bgWidth = shadowBg:getBoundingBox().width,
			num = #data > 4 and 4 or #data,
			nodeWidth = itemIcon:getBoundingBox().width,
			now = i > 4 and i-4 or i
		}),posY)
		shadowBg:addChild(itemIcon)

		local itemName = XTHDLabel:createWithParams({
		    text = itemIcon._Name,
		    fontSize = 16,
		    color = XTHD.resource.color.gray_desc
		})
		itemName:setAnchorPoint(0.5,1)
	    itemName:setPosition(itemIcon:getPositionX(),itemIcon:getPositionY()-itemIcon:getBoundingBox().height/2-4)
	    shadowBg:addChild(itemName)
    end

end

function ZhuangBeiSmeltRewardPop:create(data,callback)
	return ZhuangBeiSmeltRewardPop.new(data,callback)
end

return ZhuangBeiSmeltRewardPop