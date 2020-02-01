local LoginDailyRewardPopLayer = class("LoginDailyRewardPopLayer",function()
	return XTHDPopLayer:create()
end)

function LoginDailyRewardPopLayer:ctor(_data,_parentLayer,_type)
    if _type ~= nil then
        self.rewardtype = _type
    end
    self.parentLayer = _parentLayer
	self.rewardData = _data
	self:initLayer()
end

function LoginDailyRewardPopLayer:initLayer()
	local popNode  = ccui.Scale9Sprite:create("res/image/activities/logindaily/scale9_bg_26.png")
 	popNode:setContentSize(cc.size(440,360))
 	popNode:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
 	self:addContent(popNode)

 	local _titleBgSp = ccui.Scale9Sprite:create("res/image/common/common_title_barBg.png")
 	_titleBgSp:setContentSize(cc.size(popNode:getContentSize().width-7*2,44))
 	_titleBgSp:setAnchorPoint(cc.p(0.5,1))
     _titleBgSp:setPosition(cc.p(popNode:getContentSize().width/2,popNode:getContentSize().height - 7))
     _titleBgSp:setOpacity(0)
 	popNode:addChild(_titleBgSp)

 	local _titleSp = cc.Sprite:create("res/image/activities/logindaily/logindaily_totalrewardTitle.png")
 	_titleSp:setPosition(cc.p(_titleBgSp:getContentSize().width/2,_titleBgSp:getContentSize().height/2))
 	_titleBgSp:addChild(_titleSp)

 	-- local _closeBtn = XTHD.createBtnClose(function()
    --     self:hide()
    -- end)
    local _closeBtn = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create("res/image/activities/dailyRecharge/close.png"),
		selectedNode = cc.Sprite:create("res/image/activities/dailyRecharge/close.png"),
		needSwallow = true,
		enable = true,
		endCallback = function ()
			self:hide()
		end
   })
    _closeBtn:setAnchorPoint(cc.p(0.5,0.5))
    _closeBtn:setPosition(cc.p(popNode:getContentSize().width-5,popNode:getContentSize().height-5))
    popNode:addChild(_closeBtn)

    for i=1,#self.rewardData do
        local _rewardItem = self:initRewardItem(i)
        local _rewardPosY = (_titleBgSp:getBoundingBox().y + 4)/2 -(i-2)*(_rewardItem:getContentSize().height + 3)
        _rewardItem:setPosition(cc.p(popNode:getContentSize().width/2,_rewardPosY))
        popNode:addChild(_rewardItem)
    end

    self:show()
end

function LoginDailyRewardPopLayer:initRewardItem(_idx)
	local _rewardItemBg = ccui.Scale9Sprite:create()
	_rewardItemBg:setContentSize(cc.size(418,90))

	local _rewardData = self.rewardData[tonumber(_idx)]
	local _rewardPosY = _rewardItemBg:getContentSize().height/2
	local _rewardPosX = 220

	local _rewardItem = ItemNode:createWithParams({
                dbId = nil,
                itemId = _rewardData.reward1id or 0,
                _type_ = _rewardData.reward1type or _rewardData.reward1,
                touchShowTip = true,
                count = _rewardData.reward1count or _rewardData.reward1num
            })
	_rewardItem:setScale(60/_rewardItem:getContentSize().width)
	_rewardItem:setAnchorPoint(cc.p(0,0.5))
    _rewardItem:setPosition(cc.p(_rewardPosX,_rewardPosY))
    _rewardItemBg:addChild(_rewardItem)
    local _descStr = nil
    if self.rewardtype == "onlinereward" then
        _descStr = LANGUAGE_TIPS_onlineTotalTurnRewardDescTextXc(_rewardData.needTimes or 0)
    else
        _descStr = LANGUAGE_TIPS_loginTotalRewardDescTextXc(_rewardData.rewardday or 0)
    end
    local _descLabel = XTHDLabel:create(_descStr,20)
    _descLabel:setColor(cc.c4b(240,200,11,255))
    _descLabel:setAnchorPoint(cc.p(0,0.5))
    _descLabel:setPosition(cc.p(20,_rewardPosY))
    _rewardItemBg:addChild(_descLabel)

    
    local _btnText = LANGUAGE_BTN_KEY.noAchieve
    local _btnImg = "write"
    local _isBtn = true
    if _rewardData.rewardState and _rewardData.rewardState ~= "cannotReward" then
    	if _rewardData.rewardState == "canReward" then
    		_btnText = LANGUAGE_BTN_KEY.getReward
    	else
    		_btnText = LANGUAGE_BTN_KEY.rewarded
            _isBtn = false
    	end
    	
    end
	_btnImg = "res/image/common/btn/btn_write_up.png"
	local _rewardBtn = nil
    if _isBtn ==true then
        _rewardBtn = XTHD.createCommonButton({
                normalFile = _btnImg,
                isScrollView = true,
                selectedFile = "res/image/common/btn/btn_write_down.png",
                text = _btnText,
                fontSize = 26,
            })
        -- XTHD.createButton({
        --     normalFile = "res/image/common/btn/btn_" .. _btnImg .. "_up.png",
        --     selectedFile = "res/image/common/btn/btn_" .. _btnImg .. "_down.png",
        --     label = XTHDLabel:create(_btnText,20),
        --     fontColor = _textColor,
        -- })
        if _btnText == LANGUAGE_BTN_KEY.getReward then
            --可领取按钮动画
            local rewardSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)
            rewardSpine:setName("rewardSpine")
            _rewardBtn:addChild( rewardSpine )
            rewardSpine:setPosition( _rewardBtn:getBoundingBox().width*0.5+7, _rewardBtn:getContentSize().height/2+2 )
            rewardSpine:setAnimation( 0, "querenjinjie", true)
        end
        _rewardBtn:setTouchEndedCallback(function()
            self.parentLayer:httpToGetTotalReward(_idx,function()
                    -- _rewardBtn:getLabel():setString(LANGUAGE_BTN_KEY.rewarded)
                    if _rewardBtn:getChildByName("rewardSpine") then
                        _rewardBtn:removeChildByName("rewardSpine")
                    end
                    local _posx = _rewardBtn:getPositionX()
                    _rewardBtn:removeFromParent()
                    _rewardBtn = cc.Sprite:create("res/image/vip/yilingqu.png")
                    _rewardBtn:setScale(0.7)
                    _rewardBtn:setPosition(cc.p(_posx,_rewardPosY))
                    _rewardItemBg:addChild(_rewardBtn)
                end)
        end)
        _rewardBtn:setScale(0.7)
    else
        _rewardBtn = cc.Sprite:create("res/image/vip/yilingqu.png")
        _rewardBtn:setScale(0.7)
    end
    
	-- _rewardBtn:setClickable(_clickBool)
	_rewardBtn:setAnchorPoint(cc.p(0.5,0.5))
	_rewardBtn:setPosition(cc.p(_rewardItemBg:getContentSize().width - 15 - 51,_rewardPosY))
	_rewardItemBg:addChild(_rewardBtn)
    

	return _rewardItemBg
end

function LoginDailyRewardPopLayer:create(_data,_parentLayer,_type)
	local _layer = self.new(_data,_parentLayer,_type)
	return _layer
end

return LoginDailyRewardPopLayer