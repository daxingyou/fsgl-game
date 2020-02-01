local SwitchSceneLayer1  = class( "SwitchSceneLayer1", function (params)
	return XTHDDialog:create()
end)

function SwitchSceneLayer1:ctor(params)
    local showLogo = params.showLogo

	local width = cc.Director:getInstance():getWinSize().width
    local height = cc.Director:getInstance():getWinSize().height

    local bg = XTHD.createSprite()
    bg:setContentSize(XTHD.resource.visibleSize)
    bg:setPosition(width/2, height/2)
    self:addChild(bg)

    width = XTHD.resource.visibleSize.width
    height = XTHD.resource.visibleSize.height

    

    local bar_bg = XTHD.createSprite("res/image/login/login_loading_bar_bg.png")
    bar_bg:setPosition(cc.p(width / 2, 86))
    bg:addChild(bar_bg)
    bar_bg:setScale(0.8)

    self._loadingProgress = nil

    local loadingProgress = cc.ProgressTimer:create(cc.Sprite:create("res/image/login/login_loading_bar.png"))
    loadingProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    loadingProgress:setMidpoint(cc.p(0, 0))
    loadingProgress:setBarChangeRate(cc.p(1, 0))
    loadingProgress:setPosition(cc.p(bar_bg:getContentSize().width / 2, bar_bg:getContentSize().height / 2))
    loadingProgress:setPercentage(0)
    bar_bg:addChild(loadingProgress)
    self._loadingProgress = loadingProgress

    local arr = {}
    for i=1,10 do
        math.newrandomseed()
        local random = math.random()
        if random < 0.3 then
            random = random + 0.2
        end
        arr[#arr+1] = cc.ProgressTo:create(random, 100)
        arr[#arr+1] = cc.CallFunc:create(function()
                        loadingProgress:setPercentage(0)
                    end)
    end
    
    --[[循环播放动画]]
    loadingProgress:runAction(cc.RepeatForever:create(cc.Sequence:create(arr)))
    --ios提审暂时屏蔽
    -- bar_bg:setVisible(false)
    -- loadingProgress:setVisible(false)

    local tip_bg = XTHD.createSprite("res/image/login/login_tip_bg.png")
    tip_bg:setScale(0.8)
    tip_bg:setPosition(cc.p(bg:getContentSize().width / 2,bar_bg:getBoundingBox().y + bar_bg:getBoundingBox().height + tip_bg:getContentSize().height / 2 + 20))
    bg:addChild(tip_bg)

    local txt_tip = XTHDLabel:createWithParams({
        text = getAnEsoterica(),
        fontSize = 24,
        color = cc.c3b(254, 237, 97),
    })
    txt_tip:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))
    txt_tip:setPosition(cc.p(tip_bg:getContentSize().width / 2, tip_bg:getContentSize().height - txt_tip:getContentSize().height / 2 - 10))
    tip_bg:addChild(txt_tip)
    self._esotericaLabel = txt_tip
    --更新文字
    local progressTitle = XTHDLabel:createWithParams({
        text = "正在进入游戏...",-------正在连接服务器...",LANGUAGE_KEY_CONNECTINGSERVER
        fontSize = 18,
        color = cc.c3b(255, 255, 255),
    })
    progressTitle:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))
    progressTitle:setPosition(cc.p(txt_tip:getPositionX(), 16))
    tip_bg:addChild(progressTitle)
    
    self._progressTitle = progressTitle
    
    if showLogo == true then
        local game_name = XTHD.createSprite("res/image/login/game_name.png")
        game_name:setPosition(width/2 , 460)
        bg:addChild(game_name)
        game_name:setVisible(false)
    end

end

function SwitchSceneLayer1:setText(text)
    if text == nil then
        return
    end
    self._progressTitle:setString(text)
end

function SwitchSceneLayer1:getText()
    if self._progressTitle ~= nil then
        return self._progressTitle
    end
end

function SwitchSceneLayer1:setLoadingPercent( percent )
    if percent == nil then
        return
    end
    self._loadingProgress:setPercentage(percent)
end

function SwitchSceneLayer1:getLoadingBar()
    if self._loadingProgress ~= nil then
        return self._loadingProgress
    end
end

function SwitchSceneLayer1:create(params)
	return SwitchSceneLayer1.new(params)
end

function SwitchSceneLayer1:onEnter( )
    ------显示小秘籍提示
    if self._esotericaLabel then 
        schedule(self._esotericaLabel,function(  )
            local str = getAnEsoterica()
            self._esotericaLabel:setString(str)
        end,EsotericaTime)
    end 
end

return SwitchSceneLayer1