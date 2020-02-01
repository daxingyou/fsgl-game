--Created By Liuluyang 2015年10月28日
local YaYunLiangCaoRewardPop = class("YaYunLiangCaoRewardPop",function ()
	return XTHD.createPopLayer()
end)

function YaYunLiangCaoRewardPop:ctor(reward,cost,callFunc)
	self:initUI(reward,cost,callFunc)
end

function YaYunLiangCaoRewardPop:initUI(reward,cost,callFunc)
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
	bg:setContentSize(cc.size(466,367))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)

	-- local titleBg = cc.Sprite:create("res/image/daily_task/escort_task/escortInfoTitle_bg.png")
	-- local titleBg = XTHD.getScaleNode("res/image/common/common_title_barBg.png", cc.size(bg:getContentSize().width-7*2,44))
	local titleBg = ccui.Scale9Sprite:create()
	titleBg:setContentSize(cc.size(bg:getContentSize().width-7*2,44))
	titleBg:setAnchorPoint(0.5,1)
	titleBg:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-7)
	bg:addChild(titleBg)

	local titleLabel = XTHDLabel:createWithParams({
		text = LANGUAGE_KEY_REWARDDESC,
		fontSize = 24,
		color = XTHD.resource.color.gray_desc
	})
	titleLabel:setPosition(titleBg:getBoundingBox().width/2,titleBg:getBoundingBox().height/2)
	titleBg:addChild(titleLabel)

	--kuang
	local kuang = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	kuang:setContentSize(cc.size(442,203))
	kuang:setAnchorPoint(0.5,1)
	kuang:setPosition(bg:getBoundingBox().width/2,titleBg:getPositionY()-titleBg:getBoundingBox().height-5)
	bg:addChild(kuang)

	local topShadow = ccui.Scale9Sprite:create()
	topShadow:setContentSize(cc.size(442,133))
	topShadow:setAnchorPoint(0.5,1)
	topShadow:setPosition(bg:getBoundingBox().width/2,titleBg:getPositionY()-titleBg:getBoundingBox().height-5)
	bg:addChild(topShadow)

	local rewardDesc = XTHDLabel:createWithParams({
		text = LANGUAGE_KEY_EXPDESC,
		fontSize = 22,
		color = XTHD.resource.color.gray_desc
	})
	rewardDesc:setPosition(topShadow:getBoundingBox().width/2,topShadow:getBoundingBox().height-rewardDesc:getBoundingBox().height/2-10)
	topShadow:addChild(rewardDesc)

	for i=1,#reward do
		local itemIcon = ItemNode:createWithParams({
    		_type_ = reward[i].rewardtype,
			itemId = reward[i].id,
			count = reward[i].num,
    	})
    	itemIcon:setScale(0.9)
    	itemIcon:setPosition(XTHD.resource.getPosInArr({
    		lenth = 10,
			bgWidth = topShadow:getBoundingBox().width,
			num = #reward,
			nodeWidth = itemIcon:getBoundingBox().width,
			now = i,
		}),topShadow:getBoundingBox().height/2-20)
		topShadow:addChild(itemIcon)
	end

	

	local bottomEdge = ccui.Scale9Sprite:create()
	bottomEdge:setContentSize(cc.size(442,45))
	bottomEdge:setAnchorPoint(0.5,1)
	bottomEdge:setPosition(bg:getBoundingBox().width/2,topShadow:getPositionY()-topShadow:getBoundingBox().height-8)
	bg:addChild(bottomEdge)

	local splitBottom = cc.Sprite:create("res/image/daily_task/escort_task/split_dark.png")
	splitBottom:setAnchorPoint(cc.p(0.5,0))
	splitBottom:setScale(0.7)
    splitBottom:setPosition(bottomEdge:getPositionX(),bottomEdge:getPositionY())
	bg:addChild(splitBottom)

	local tip = XTHDLabel:createWithParams({
		text = LANGUAGE_KEY_REWARDTIP,
		fontSize = 22,
		color = XTHD.resource.color.gray_desc
	})
	tip:setPosition(bottomEdge:getBoundingBox().width/2,bottomEdge:getBoundingBox().height/2)
	bottomEdge:addChild(tip)

	local cancelBtn = XTHD.createCommonButton({
		btnColor = "write_1",
		btnSize = cc.size(130,49),
		isScrollView = false,
		text = LANGUAGE_KEY_CANCEL,
		fontSize = 26,
		fontColor = cc.c3b(255,255,255),
	})
	cancelBtn:setScale(0.7)
	cancelBtn:setAnchorPoint(0,0.5)
	cancelBtn:setPosition(110-75,75)
	bg:addChild(cancelBtn)

	cancelBtn:setTouchEndedCallback(function ()
		self:hide()
	end)

	local finishBtn = XTHD.createCommonButton({
		btnColor = "write",
		btnSize = cc.size(222,49),
		isScrollView = false,
		text = LANGUAGE_TIPS_WORDS254,
		fontColor = cc.c3b(255,255,255),
		fontSize = 26,
	})
	finishBtn:setScale(0.7)
	finishBtn:setAnchorPoint(1,0.5)
	finishBtn:setPosition(bg:getBoundingBox().width-110+75,75)
	bg:addChild(finishBtn)

	-- local finishLabel = finishBtn:getLabel()
	local finishLabel = XTHDLabel:create("消耗：",24)
	finishLabel:setColor(cc.c3b(100,100,255))
	finishLabel:setAnchorPoint(1,0.5)
	local goldIcon = XTHD.createHeaderIcon(XTHD.resource.type.ingot)
	goldIcon:setAnchorPoint(1,0.5)
	local needGold = getCommonWhiteBMFontLabel(cost)
	needGold:setAnchorPoint(1,0.5)

	goldIcon:setPosition(bg:getBoundingBox().width-110+25,40)
	bg:addChild(goldIcon)
	needGold:setPosition(goldIcon:getPositionX()+goldIcon:getBoundingBox().width,goldIcon:getPositionY()-7)
	bg:addChild(needGold)

	finishLabel:setPosition(goldIcon:getPositionX()-goldIcon:getContentSize().width+3,goldIcon:getPositionY()-2)
	bg:addChild(finishLabel)

	finishBtn:setTouchEndedCallback(function ()
		callFunc()
		self:hide()
	end)
end

function YaYunLiangCaoRewardPop:create(reward,cost,callFunc)
	return YaYunLiangCaoRewardPop.new(reward,cost,callFunc)
end

return YaYunLiangCaoRewardPop