--Created By Liuluyang 2015年10月28日
--开始人物弹窗
local YaYunLiangCaoConfirmPop = class("YaYunLiangCaoConfirmPop",function ()
	return XTHD.createPopLayer()
end)

function YaYunLiangCaoConfirmPop:ctor(data,challengeCall)
	self:initUI(data,challengeCall)
end

function YaYunLiangCaoConfirmPop:initUI(data,challengeCall)
	local teamData = data.team
	local rewardData = data.reward
	local ETA = data.ETA

	-- local bg = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_34.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
	bg:setContentSize(cc.size(486,390))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)

	--kuang
	local kuang = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	kuang:setContentSize(cc.size(bg:getContentSize().width-30,bg:getContentSize().height-120))
	kuang:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2+10)
	kuang:setAnchorPoint(0.5,0.5)
	bg:addChild(kuang)

	-- local titleBg = cc.Sprite:create("res/image/daily_task/escort_task/escortInfoTitle_bg.png") --459,47
	-- local titleBg = XTHD.getScaleNode("res/image/common/common_title_barBg.png", cc.size(bg:getContentSize().width - 7*2,44))
	local titleBg = ccui.Scale9Sprite:create()
	titleBg:setContentSize(cc.size(bg:getContentSize().width - 7*2,44))
    titleBg:setAnchorPoint(0.5,1)
	titleBg:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-7)
	bg:addChild(titleBg)

	local titleLabel = XTHDLabel:createWithParams({
		text = LANGUAGE_KEY_ESCORTSURETEAM,
		fontSize = 24,
		color = cc.c3b(55,54,112),
		ttf = "res/fonts/def.ttf"
	})
	titleLabel:setPosition(titleBg:getBoundingBox().width/2,titleBg:getBoundingBox().height/2)
	titleBg:addChild(titleLabel)

	local closeBtn = XTHD.createBtnClose(function()
        self:hide()
    end)
    closeBtn:setPosition(cc.p(bg:getContentSize().width-7,bg:getContentSize().height-7))
    bg:addChild(closeBtn)

    local _upLinePopsY = 74+5+105
    local _downLinePosY = _upLinePopsY - 105

    for i=1,#teamData do
    	local heroIcon = HeroNode:createWithParams({
    		heroid = teamData[i]
    	})
    	heroIcon:setAnchorPoint(0.5,0.5)
    	heroIcon:setScale(0.8)
    	heroIcon:setPosition(XTHD.resource.getPosInArr({
    		lenth = 10,
			bgWidth = bg:getBoundingBox().width,
			num = #teamData,
			nodeWidth = heroIcon:getBoundingBox().width,
			now = i,
		}),(titleBg:getBoundingBox().y + _upLinePopsY)/2 )
		bg:addChild(heroIcon)
    end
    
    local splitTop = cc.Sprite:create("res/image/daily_task/escort_task/split_dark.png")
	splitTop:setAnchorPoint(cc.p(0.5,0))
	splitTop:setScaleX(0.7)
    splitTop:setPosition(bg:getBoundingBox().width/2,_upLinePopsY+20)
	bg:addChild(splitTop)
	

    local ETALabel = XTHDLabel:createWithParams({
    	text = LANGUAGE_KEY_MINUTE(ETA),
    	fontSize = 22,
		color = cc.c3b(55,54,112),
		ttf = "res/fonts/def.ttf"
    })
    ETALabel:setAnchorPoint(0,0.5)

    local _ETAPosY = splitTop:getBoundingBox().y-16
    local ETAStr = XTHDLabel:createWithParams({
    	text = LANGUAGE_KEY_REWARDSTR,
    	fontSize = 22,
		color = cc.c3b(55,54,112),
		ttf = "res/fonts/def.ttf"
    })
    ETAStr:setAnchorPoint(0,0.5)

    ETALabel:setPosition((bg:getBoundingBox().width-(ETALabel:getBoundingBox().width+ETAStr:getBoundingBox().width))/2,_ETAPosY)
    bg:addChild(ETALabel)

    ETAStr:setPosition(ETALabel:getPositionX()+ETALabel:getBoundingBox().width,_ETAPosY)
    bg:addChild(ETAStr)

    for i=1,#rewardData do
    	local itemIcon = ItemNode:createWithParams({
    		_type_ = rewardData[i].rewardtype,
			itemId = rewardData[i].id,
			count = rewardData[i].num,
    	})
        itemIcon:setAnchorPoint(cc.p(0.5,0))
    	itemIcon:setScale(0.75)
    	itemIcon:setPosition(XTHD.resource.getPosInArr({
    		lenth = 10,
			bgWidth = bg:getBoundingBox().width,
			num = #rewardData,
			nodeWidth = itemIcon:getBoundingBox().width,
			now = i,
		}),_downLinePosY + 5+3)
		bg:addChild(itemIcon)
    end

    local splitBottom = cc.Sprite:create("res/image/daily_task/escort_task/split_dark.png")
    splitBottom:setAnchorPoint(cc.p(0.5,0))
    splitBottom:setPosition(bg:getBoundingBox().width/2,_downLinePosY)
	bg:addChild(splitBottom)
	splitBottom:setOpacity(0)

    local getBtnNode = function(_path)
        local _node = ccui.Scale9Sprite:create(cc.rect(50,0,30,49),_path)
        _node:setContentSize(cc.size(182,49))
        return _node
    end

    local challengeBtn = XTHD.createCommonButton({
        btnColor = "write_1",
		btnSize = cc.size(130,49),
		isScrollView = false,
        text = LANGUAGE_TIPS_ESCORTCONFIRM,
		fontSize = 26,
		fontColor = cc.c3b(255,255,255),
    })
	challengeBtn:setPosition(bg:getBoundingBox().width/2,(splitBottom:getBoundingBox().y+5)/2)
	challengeBtn:setScale(0.7)
    bg:addChild(challengeBtn)

    challengeBtn:setTouchEndedCallback(function ()
    	challengeCall()
    	self:hide()
    end)
end

function YaYunLiangCaoConfirmPop:create(data,challengeCall)
	return YaYunLiangCaoConfirmPop.new(data,challengeCall)
end

return YaYunLiangCaoConfirmPop