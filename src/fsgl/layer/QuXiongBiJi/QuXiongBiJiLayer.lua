-- FileName: QuXiongBiJiLayer.lua
-- Author: andong
-- Date: 2015-12-2
-- Purpose: 弄宝界面
--天命求签
--[[TODO List]]

local QuXiongBiJiLayer = class("QuXiongBiJiLayer", function()
    return XTHD.createBasePageLayer({
        bg = "res/image/daily_task/seek_treasure/seek_bg.png",
        -- difPos = cc.p(0,640/2-397/2-20),
        isOnlyBack = true,
        ZOrder = 11,
--        isScale = false,
    })
end)

function QuXiongBiJiLayer:onCleanup()
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/seekBtn_up.png")
    textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/seekBtn_down.png")
    textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/gossip.png")
    textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/arrow_gray.png")
    textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/arrow_light.png")
    textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/exchangeBtn.png")
    textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/arrow_gray.png")
    textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/arrow_light.png")
    textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/seek_bg.png")
    textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/desk.jpg")
    for i = 1,5 do
    	textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/cup_level_" ..i.. ".png")
    end
    for i =1, 14 do
    	textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/sgct/sgct"..i..".png")
    end
    for i = 1, 7 do
    	textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/sgdj/sgdj"..i..".png")
    end
    for i = 1,5 do
    	textureCache:removeTextureForKey("res/image/daily_task/seek_treasure/cup_"..i..".png")
    end
end

function QuXiongBiJiLayer:ctor(data,parent)
	-- print("趋吉避凶的数据为：")
 --    print_r(data)
	self._parent = parent
	self:initData(data)
	self:initTopBar()
	self:initUI()
end

function QuXiongBiJiLayer:initData(data)

	self._initData = data
	self._staticCost = gameData.getDataFromCSV("Qujibixiong")
end

function QuXiongBiJiLayer:initTopBar()

	local topBgSize = cc.size(self:getContentSize().width,60)
	local topBg = cc.LayerColor:create()
	topBg:setContentSize(cc.size(topBgSize.width, topBgSize.height))
	topBg:setOpacity(100)
	topBg:setPosition(0, self:getContentSize().height-topBgSize.height)
	self:addChild(topBg,10)

	local iconImg = cc.Sprite:create(IMAGE_KEY_HEADER_SOUL)
	iconImg:setPosition(30, topBgSize.height/2)
	iconImg:setAnchorPoint(0,0.5)
	topBg:addChild(iconImg,1)
	local numBg = ccui.Scale9Sprite:create("res/image/common/topbarItem_bg.png")
	numBg:setAnchorPoint(0,0.5)
	numBg:setPosition(iconImg:getPositionX()+iconImg:getContentSize().width-10, topBgSize.height/2)
	topBg:addChild(numBg,0)

	local soul = gameUser.getSoul()
    local playerNum = getCommonWhiteBMFontLabel(soul)
    topBg:addChild(playerNum,1)
    playerNum:setAnchorPoint(0,0.5)
    playerNum:setPosition(iconImg:getPositionX()+iconImg:getContentSize().width, topBgSize.height/2-7)
    self._palyerSoul = playerNum

	local addNumBtn = XTHD.createButton({
		normalFile = "res/image/common/btn/btn_plus_normal.png",
		selectedFile = "res/image/common/btn/btn_plus_selected.png",
		endCallback = function()
			self:buyHunyu()
		end,
	})
	addNumBtn:setAnchorPoint(0,0.5)
	addNumBtn:setPosition(numBg:getPositionX()+numBg:getContentSize().width-10, topBgSize.height/2)
	topBg:addChild(addNumBtn,1)

	local tipLabel = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_SEEKTREASURE_TIP1,"Helvetica", 20)
	tipLabel:enableShadow(cc.c4b(255, 255, 255, 255),cc.size(0.4,-0.4),0.4)
	tipLabel:setAnchorPoint(0,0.5)
	topBg:addChild(tipLabel)
	tipLabel:setPosition(addNumBtn:getPositionX()+addNumBtn:getContentSize().width+20,topBgSize.height/2)

	self._gotoFeiCuiBtn = XTHD.createCommonButton({
		btnSize = cc.size(180,46),
		isScrollView = false,
		endCallback = function()
			XTHD.createJaditeCopy(self,1,function()
				self._palyerSoul:setString(gameUser.getSoul())
			end)
		end,
		--ly3.26
		fontSize = 16,
		text = LANGUAGE_TIPS_SEEKTREASURE_TIP2,
	})
	self._gotoFeiCuiBtn:setScaleY(0.85)
	-- self._gotoFeiCuiBtn:getLabel():enableShadow(cc.c4b(19, 59, 6, 255),cc.size(0.4,-0.4),0.4)
	self._gotoFeiCuiBtn:setAnchorPoint(0, 0.5)
	self._gotoFeiCuiBtn:setPosition(tipLabel:getPositionX()+tipLabel:getContentSize().width+20,topBgSize.height/2)
	topBg:addChild(self._gotoFeiCuiBtn)
end

function QuXiongBiJiLayer:initUI( data )

	local winSize = self:getContentSize()

	local desk = cc.Sprite:create("res/image/daily_task/seek_treasure/desk.jpg")
	desk:setAnchorPoint(0.5,0)
	self:addChild(desk,1)
	desk:setOpacity(0)
	desk:setPosition(self:getContentSize().width/2,-15)

	-- local animalSpine = sp.SkeletonAnimation:create("res/spine/effect/seek_treasure/cqui.json", "res/spine/effect/seek_treasure/cqui.atlas",1.0)
	-- animalSpine:setPosition(winSize.width/2,winSize.height/2+70)
	-- self:addChild(animalSpine)
	-- animalSpine:setAnimation(0,"animation",true)
	--人物
	local animal = cc.Sprite:create("res/image/daily_task/seek_treasure/animal.png")
	animal:setPosition(winSize.width/2,winSize.height/2+80)
	animal:setScale(0.8)
	self:addChild(animal)

	 local seekBtn = XTHD.createButton({
	 	normalFile = "res/image/daily_task/seek_treasure/seekBtn_up.png",
	 	selectedFile = "res/image/daily_task/seek_treasure/seekBtn_down.png",
	 	musicFile = XTHD.resource.music.effect_btn_commonclose,
	 	endCallback = function()
	 		self:callHttp()
	 	end,
	 })

	 --剩余购买次数
	local lastTimesLab = cc.Sprite:create("res/image/daily_task/stone_gambling/lastTimes.png")
	lastTimesLab:setAnchorPoint(cc.p(0,0.5))
	lastTimesLab:setPosition(15, self:getContentSize().height - 90)
	self:addChild(lastTimesLab)

	-- local lastTimes = XTHDLabel:createWithSystemFont("", "Helvetica", 22)
	local lastTimes = cc.Label:createWithBMFont("res/fonts/baisezi.fnt","")
	lastTimes:setAnchorPoint(cc.p(0,0.5))
	lastTimes:setPosition(lastTimesLab:getPositionX() + lastTimesLab:getContentSize().width, lastTimesLab:getPositionY()-7)
	self:addChild(lastTimes)
	self._lastTimes = lastTimes
    self._lastTimes:setString(tostring(self._initData.surplusBuyCount))
	--ly3.26
	--local seekBtn = XTHD.createCommonButton({
	--	btnColor = "write_1",
	--	text = "求签一次",
	--	musicFile = XTHD.resource.music.effect_btn_commonclose,
	--	endCallback = function()
	--		self:callHttp()
	--	end,
	--})
	seekBtn:setAnchorPoint(0.5,0)
	seekBtn:setPosition(winSize.width/2-250, 38)
	seekBtn:setScale(0.7)
	self:addChild(seekBtn,1)
	self._seekBtn = seekBtn
	
	 local seekBtn10 = XTHD.createButton({
	 	normalFile = "res/image/daily_task/seek_treasure/seekBtn_10_up.png",
	 	selectedFile = "res/image/daily_task/seek_treasure/seekBtn_10_dowm.png",
	 	musicFile = XTHD.resource.music.effect_btn_commonclose,
	 	endCallback = function()
	 		self:getTenTimes()
	 	end,
	 })
	--ly3.26
	--local seekBtn10 = XTHD.createCommonButton({
	--	btnColor = "write_1",
	--	text = "求签十次",
	--	musicFile = XTHD.resource.music.effect_btn_commonclose,
	--	endCallback = function()
	--		self:getTenTimes()
	--	end,
	--})

	seekBtn10:setAnchorPoint(0.5,0)
	seekBtn10:setPosition(winSize.width/2+70, 38)
	seekBtn10:setScale(0.7)
	self:addChild(seekBtn10,1)
	self._seekBtn10 = seekBtn10


	self._animal1 = getAnimation("res/image/daily_task/seek_treasure/sgct/sgct",1,14,1/7) --常态
	self._animal2 = getAnimation("res/image/daily_task/seek_treasure/sgdj/sgdj",1,7,1/12) --点击
	self._animal2:retain()

	local cupHeight = desk:getPositionY()+185
	local initPosX = 100
	local cupDistance = (winSize.width-200)/4

	self._arrowList = {}
	for i = 1, 5 do
		local gossip = cc.Sprite:create("res/image/daily_task/seek_treasure/gossip.png")
		self:addChild(gossip,1)
		gossip:setName("gossip_"..i)
		gossip:setPosition(initPosX +(i-1)*cupDistance, cupHeight)

		local cup = XTHD.createButton({
			normalFile = "res/image/daily_task/seek_treasure/cup_"..i..".png",
			selectedFile = "res/image/daily_task/seek_treasure/cup_"..i..".png",
			needSwallow = true,
		})
		cup:setScale(0.8)
		self:addChild(cup,2)
		cup:setAnchorPoint(0.5,0)
		cup:setPosition(gossip:getPositionX(),gossip:getPositionY()-7)

		cup:setTouchBeganCallback(function()
			self:showTips(cup, i)
		end)
		cup:setTouchEndedCallback(function()
			if self._tipsBg then
				self._tipsBg:removeFromParent()
			end
			self._tipsBg = nil
		end)
	    cup:setTouchMovedCallback(function( touch )
	        if not cc.rectContainsPoint( cc.rect( 0, 0, cup:getBoundingBox().width, cup:getBoundingBox().height ), cup:convertToNodeSpace( touch:getLocation() ) ) then
				if self._tipsBg then
					self._tipsBg:removeFromParent()
				end
				self._tipsBg = nil
	        end
	    end)

		-- local nameImg = cc.Sprite:create("res/image/daily_task/seek_treasure/cup_level_" ..i.. ".png")
		-- self:addChild(nameImg,1)
		-- nameImg:setPosition(gossip:getPositionX(),gossip:getPositionY())		

		if i ~= 5 then
			local arrow = cc.Sprite:create("res/image/daily_task/seek_treasure/arrow_gray.png")	
			arrow:setPosition(gossip:getPositionX()+cupDistance/2,gossip:getPositionY())
			self:addChild(arrow,1)
			self._arrowList[#self._arrowList+1] = arrow 
			if i == self._initData.curIndex then
				arrow:setTexture("res/image/daily_task/seek_treasure/arrow_light.png")
				arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(
					cc.FadeIn:create(0.5),cc.FadeOut:create(0.5)
				)))
			end
		end

		if i == self._initData.curIndex then
			-- self._sp = cc.Sprite:create()
			-- self._sp:runAction(cc.RepeatForever:create(self._animal1))
			--新特效
			self._sp = sp.SkeletonAnimation:create( "res/image/daily_task/seek_treasure/sgct/chouqian_down.json", "res/image/daily_task/seek_treasure/sgct/chouqian_down.atlas", 1.0) 
			self._sp:setAnimation( 0, "chouqian_up", true )
			self._sp:setPosition(gossip:getPositionX(),gossip:getPositionY())
			self._sp:setScale(0.8)
			self:addChild(self._sp,1)
			self._sp2 = sp.SkeletonAnimation:create( "res/image/daily_task/seek_treasure/sgct/chouqian_up.json", "res/image/daily_task/seek_treasure/sgct/chouqian_up.atlas", 1.0) 
			self._sp2:setAnimation( 0, "chouqian_up", true )
			self._sp2:setPosition(gossip:getPositionX(),gossip:getPositionY())
			self:addChild(self._sp2,3)
		end
	end
	local rewardBtn = XTHD.createCommonButton({
		btnSize =  cc.size(150,46),
		isScrollView = false,
		text = LANGUAGE_TIPS_SEEKTREASURE_TIP3,
		endCallback = function()
			self:createExchangePop()
		end,
	})
	-- rewardBtn:getLabel():enableShadow(cc.c4b(19, 59, 6, 255),cc.size(0.4,-0.4),0.4)
	rewardBtn:setAnchorPoint(1,0)
	self:addChild(rewardBtn,1)
	rewardBtn:setPosition(winSize.width - 20,25)
	local rewardImg = cc.Sprite:create("res/image/daily_task/seek_treasure/exchangeBtn.png")
	rewardBtn:addChild(rewardImg)
	rewardImg:setAnchorPoint(0,0)
	rewardImg:setScale(0.8)
	rewardImg:setPosition(-35,0)

	local myPoints = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_SEEKTREASURE_TIP4..": "..self._initData.curJifen, "Helvetica",22)
	myPoints:enableShadow(cc.c4b(255, 255, 255, 255),cc.size(0.4,-0.4),0.4)
	myPoints:setAnchorPoint(1,0)
	myPoints:setPosition(winSize.width-30, 100)
	self:addChild(myPoints,1)
	self._myPoints = myPoints

	local surplusText
	if self._initData.surplusCount > 0 then
		surplusText = LANGUAGE_KEY_DESTINYDICE.lastFreeCountTextXc .." "..self._initData.surplusCount
	elseif self._initData.surplusCount == 0 then
		surplusText = LANGUAGE_TIPS_SEEKTREASURE_TIP5..": "..self._staticCost[self._initData.curIndex].cost
	end

	local surplus = XTHDLabel:createWithSystemFont(surplusText, "Helvetica",22)
	surplus:enableShadow(cc.c4b(255, 255, 255, 255),cc.size(0.4,-0.4),0.4)
	surplus:setAnchorPoint(cc.p(0.5, 0.5))
	surplus:setPosition(seekBtn:getContentSize().width/2, seekBtn:getContentSize().height+18)
	self._surplus = surplus
	seekBtn:addChild(surplus,1)

	local surplus2 = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_SEEKTREASURE_TIP5..": "..self._initData.okeyHunyu, "Helvetica",22)
	surplus2:enableShadow(cc.c4b(255, 255, 255, 255),cc.size(0.4,-0.4),0.4)
	surplus2:setAnchorPoint(cc.p(0.5,0.5))
	surplus2:setPosition(seekBtn10:getContentSize().width/2, seekBtn10:getContentSize().height+18)
	seekBtn10:addChild(surplus2,1)

	--test
	-- math.randomseed(os.time())
	-- self.data = {}	
end

function QuXiongBiJiLayer:getTenTimes()
	ClientHttp:requestAsyncInGameWithParams({
	    modules = "okeyLieming?",      --接口
	    successCallback = function(data)
	        if tonumber(data.result) == 0 then --请求成功
	        	-- ... --相应处理
	            if data.bagItems then
	                for i=1,#data.bagItems do
	                   DBTableItem.updateCount(gameUser.getUserId(),data.bagItems[i], data.bagItems[i]["dbId"])
	                end
	            end
	            --保存用户信息
                if data.property then
			        for i=1,#data.property do
			            local pro_data = string.split( data.property[i],',')
			             DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
			        end
			    end
	        	self._initData.curIndex =  data.curIndex
	        	self._addPoints = tonumber(data.curJifen) - tonumber(self._initData.curJifen)
	        	self._initData.curJifen = data.curJifen
	        	local show = {}
	        	for i = 1, #data.addItems do
	        		local ta = string.split(data.addItems[i], ",")
	        		show[i] = {} 
	        		show[i].rewardtype = 4
	        		show[i].id = ta[1]
	        		show[i].num = ta[2]
	        	end
	        	ShowRewardNode:create(show)
	        	--
	        	local item = gameData.getDataFromCSV("ArticleInfoSheet", {itemid=show[1].id} )
	        	item.count = show[1].num
				XTHDTOAST(LANGUAGE_CONGRATULATIONS_ITEM_POINTS(item.name,item.count,self._addPoints))
				self._myPoints:setString(LANGUAGE_TIPS_SEEKTREASURE_TIP4..": "..self._initData.curJifen)
    			self._palyerSoul:setString(gameUser.getSoul())

				--arrow
				for i = 1, 4 do
					self._arrowList[i]:stopAllActions()
					self._arrowList[i]:setOpacity(255)
					self._arrowList[i]:setTexture("res/image/daily_task/seek_treasure/arrow_gray.png")
					if i == data.curIndex and data.curIndex ~= 5 then
						self._arrowList[i]:setTexture("res/image/daily_task/seek_treasure/arrow_light.png")
						self._arrowList[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(
							cc.FadeOut:create(0.5),cc.FadeIn:create(0.5)
						)))
					end
				end
	        else
	           XTHDTOAST(data.msg) --出错信息(后端返回)
   	        	local cost = self._initData.okeyHunyu or 0 
	        	if tonumber(gameUser.getSoul()) < tonumber(cost) then
					local confirm = XTHDConfirmDialog:createWithParams({
				        msg = LANGUAGE_TIPS_BUY_HUNYU, ----你确定要重新选择奖励么？
				        rightCallback = function( )
							self:buyHunyu()
				        end,
				    })
				    self:addChild(confirm, 10)
				end
	        end
	    end,--成功回调
	    loadingParent = self,
	    failedCallback = function()
	        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
	    end,--失败回调
	    targetNeedsToRetain = self,--需要保存引用的目标
	    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})
end

function QuXiongBiJiLayer:showTips(sender,idx)
	
	if self._tipsBg then
		self._tipsBg:removeFromParent()
		self._tipsBg = nil
	end
    local tmpPos = sender:convertToWorldSpace(cc.p(0.5,0.5))

	self._tipsBg = self:getTipNode(idx)
	self:addChild(self._tipsBg,5)

    self._tipsBg:setScale(0)
    self._tipsBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.05),cc.ScaleTo:create(0.01,1)))

    if tmpPos.x >= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y >= cc.Director:getInstance():getWinSize().height/2 then --第一象限
        self._tipsBg:setAnchorPoint(cc.p(1,1))
        self._tipsBg:setPosition(tmpPos.x,tmpPos.y)
    elseif tmpPos.x <= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y >= cc.Director:getInstance():getWinSize().height/2 then --第二象限
        self._tipsBg:setAnchorPoint(cc.p(0,1))
        self._tipsBg:setPosition(tmpPos.x+sender:getBoundingBox().width,tmpPos.y)
    elseif tmpPos.x <= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y <= cc.Director:getInstance():getWinSize().height/2 then --第三象限
        self._tipsBg:setAnchorPoint(cc.p(0,0))
        self._tipsBg:setPosition(tmpPos.x+sender:getBoundingBox().width-20,tmpPos.y+sender:getBoundingBox().height-20)
    elseif tmpPos.x >= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y <= cc.Director:getInstance():getWinSize().height/2 then --第四象限
        self._tipsBg:setAnchorPoint(cc.p(1,0))
        self._tipsBg:setPosition(tmpPos.x+20,tmpPos.y+sender:getBoundingBox().height-10)
    end
end

function QuXiongBiJiLayer:getTipNode(idx)

    local id = idx
    local descLabelH = XTHDLabel:createWithParams({
        text = self._staticCost[idx].tips,
        fontSize = 18,
    })
    descLabelH:setWidth(150)
	-- local showBg = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/tips_bg.png")
	local showBg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
    showBg:setContentSize(cc.size(170, 63+descLabelH:getContentSize().height))

    local quiltyLab = XTHDLabel:createWithParams({
    	text = LANGUAGE_TIPS_QUALITY..":",
    	fontSize = 20,
    	color = cc.c3b(255,255,255),
    	anchor = cc.p(0, 1),
    	pos = cc.p(20, showBg:getContentSize().height-10),
    })
    showBg:addChild(quiltyLab)
    local quilty = XTHDLabel:createWithParams({
    	text = LANGUAGE_QUALITY(idx),
    	fontSize = 20,
    	color = cc.c3b(252,212,90),
    	anchor = cc.p(1, 1),
    	pos = cc.p(showBg:getContentSize().width-30, quiltyLab:getPositionY()),
    })
    showBg:addChild(quilty)
    
    local splitLine = cc.Sprite:create("res/image/common/common_split_line.png")
    splitLine:setPosition(showBg:getBoundingBox().width/2,quiltyLab:getPositionY()-quiltyLab:getBoundingBox().height-8)
    splitLine:setScaleX(0.4)
    showBg:addChild(splitLine)

    local descLabel = XTHDLabel:createWithParams({
        text = self._staticCost[idx].tips,
        fontSize = 18,
        color = cc.c3b(252,212,90)
    })
    descLabel:setWidth(150)
    descLabel:updateContent()
    descLabel:setAnchorPoint(0.5, 1)
    descLabel:setPosition(showBg:getContentSize().width/2+3, splitLine:getPositionY()-10)
    showBg:addChild(descLabel)

    return showBg
end

function QuXiongBiJiLayer:callHttp()
    YinDaoMarg:getInstance():guideTouchEnd() 

    ClientHttp:requestAsyncInGameWithParams({
        modules = "lieming?",
        successCallback = function(data)
        	if data.result == 0 then
        		self._seekBtn:setEnable(false)
	            -- bagItems  背包 
	            if data.bagItems then
	                for i=1,#data.bagItems do
	                   DBTableItem.updateCount(gameUser.getUserId(),data.bagItems[i], data.bagItems[i]["dbId"])
	                end
	            end
	            --保存用户信息
                if data.property then
			        for i=1,#data.property do
			            local pro_data = string.split( data.property[i],',')
			             DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
			        end
			    end
	            local isSame = true
	            if self._initData.curIndex ~= data.curIndex then
	        		self._initData.curIndex =  data.curIndex
	        		isSame = false
	        	end
	        	self._addPoints = tonumber(data.curJifen) - tonumber(self._initData.curJifen)
	        	self._initData.curJifen = data.curJifen
	        	if self._initData.surplusCount > 0 then
	        		self._initData.surplusCount = tonumber(self._initData.surplusCount)-1
	        	end
	        	self:showReward(data,isSame)
	        	self:refreshLable()
	        else
	        	XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
	        	local cost = self._staticCost[self._initData.curIndex].cost or 0 
	        	if tonumber(gameUser.getSoul()) < tonumber(cost) then
					local confirm = XTHDConfirmDialog:createWithParams({
				        msg = LANGUAGE_TIPS_BUY_HUNYU, ----你确定要重新选择奖励么？
				        rightCallback = function( )
							self:buyHunyu()
				        end,
				    })
				    self:addChild(confirm, 10)
				end
	        end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        targetNeedsToRetain = fNode,--需要保存引用的目标
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
	
	-- local cur = math.random(1,5)
	-- local flag = false

	-- print("curIndex  -> ", self.data.curIndex)
	-- print("cur 	    -> ", cur)

	-- if self.data.curIndex == nil or self.data.curIndex ~= cur then
	-- 	self.data.curIndex = cur
	-- 	-- flag = false
	-- elseif self.data.curIndex == cur then
	-- 	if self.data.curIndex == 1 then
	-- 		self.data.curIndex = self.data.curIndex + 1
	-- 	elseif self.data.curIndex > 1 then
	-- 		self.data.curIndex  = self.data.curIndex - 1
	-- 	elseif self.data.curIndex < 5 then
	-- 		self.data.curIndex = self.data.curIndex + 1
	-- 	elseif self.data.curIndex == 5 then
	-- 		self.data.curIndex = self.data.curIndex - 1
	-- 	end
	-- end

	-- self:showReward(self.data,flag)
end

function QuXiongBiJiLayer:showReward(data,isSamePos)

	if self.sprite then
		-- self.sprite:stopAllActions()
		self.sprite:removeFromParent()
		self.sprite = nil
	end

	-- local sp = cc.Sprite:create()
	-- sp:setPosition(self._sp:getPosition())
	-- self:addChild(sp,1)

	local sp = sp.SkeletonAnimation:create( "res/image/daily_task/seek_treasure/sgdj/chouqian_baodian.json", "res/image/daily_task/seek_treasure/sgdj/chouqian_baodian.atlas", 1.0)
	sp:setPosition(self._sp:getPosition())
	self:addChild(sp,2)
	

	self.sprite = sp
	local ta = string.split(data.addItems[1],",")
	--test
	-- local ta = string.split("2250,2",",")
	-- self._addPoints = 10
	--

	local item = ItemNode:createWithParams({
		_type_ = 4,
		itemId = tonumber(ta[1]),
		needSwallow = false,
		count = ta[2],
		isShowCount = true
	})
	item:setScale(0.1)
	item:setOpacity(0)

	self:addChild(item,1)
	local itemPos = cc.p(self._sp:getPositionX(),self._sp:getPositionY()+75)
	item:setPosition(itemPos)



	sp:setAnimation( 0, "chouqian_baodian", false )
	sp:runAction(cc.Sequence:create(cc.Spawn:create(
		-- self._animal2,
		cc.CallFunc:create(function()
			item:runAction(cc.Sequence:create(cc.DelayTime:create(0.03),cc.Spawn:create( cc.MoveBy:create(0.2, cc.p(0, 125)), cc.FadeTo:create(0.2,255), cc.ScaleTo:create(0.2,1.2),
				cc.CallFunc:create(function()
					XTHDTOAST(LANGUAGE_CONGRATULATIONS_ITEM_POINTS(item._Name,item.count,self._addPoints))
				end )),cc.ScaleTo:create(0.1,1),cc.DelayTime:create(0.3), cc.FadeOut:create(0.15), cc.RemoveSelf:create(true)))
		end), 
		cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
			if not isSamePos then
				-- print("need change pos //")
				local gossip = self:getChildByName("gossip_"..data.curIndex)
				self._sp:setPosition(gossip:getPositionX(),gossip:getPositionY())
				self._sp2:setPosition(gossip:getPositionX(),gossip:getPositionY())
				--arrow
				for i = 1, 4 do
					self._arrowList[i]:stopAllActions()
					self._arrowList[i]:setOpacity(255)
					self._arrowList[i]:setTexture("res/image/daily_task/seek_treasure/arrow_gray.png")
					if i == data.curIndex and data.curIndex ~= 5 then
						self._arrowList[i]:setTexture("res/image/daily_task/seek_treasure/arrow_light.png")
						self._arrowList[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(
							cc.FadeOut:create(0.5),cc.FadeIn:create(0.5)
						)))
					end
				end
			end
			self._seekBtn:setEnable(true)
			-- sp:removeFromParent()
		end))
	)))
end

function QuXiongBiJiLayer:buyHunyu()
	self._initData.callback = function(_data)
		self._initData.buyNeedGold = _data.buyNeedGold
		self._initData.surplusBuyCount = _data.surplusBuyCount
		self._lastTimes:setString(tostring(self._initData.surplusBuyCount))
		--刷新魂玉
		self._palyerSoul:setString(gameUser.getSoul())
	end
	local poplist = requires("src/fsgl/layer/QuXiongBiJi/buyHunyu.lua"):create(self._initData)
	LayerManager.addLayout(poplist, {noHide = true})
end

function QuXiongBiJiLayer:refreshLable()

	local surplusText
	if self._initData.surplusCount > 0 then
		surplusText = LANGUAGE_KEY_DESTINYDICE.lastFreeCountTextXc .." "..self._initData.surplusCount
	elseif self._initData.surplusCount == 0 then
		surplusText = LANGUAGE_TIPS_SEEKTREASURE_TIP5..": "..self._staticCost[self._initData.curIndex].cost
	end
	self._surplus:setString(surplusText)
	self._myPoints:setString(LANGUAGE_TIPS_SEEKTREASURE_TIP4..": "..self._initData.curJifen)
    self._palyerSoul:setString(gameUser.getSoul())
end

function QuXiongBiJiLayer:createExchangePop()
    ClientHttp:requestAsyncInGameWithParams({
        modules = "liemingExchangeList?",
        params = {},
        successCallback = function(data)
            if data.result==0 then
                LayerManager.addShieldLayout()
                data.points = self._initData.curJifen
	        	local exchangePop = requires("src/fsgl/layer/QuXiongBiJi/QuXiongBiJiExchangePop.lua"):create(data)
            	LayerManager.addLayout(exchangePop, {noHide = true})
              else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        targetNeedsToRetain = fNode,--需要保存引用的目标
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function QuXiongBiJiLayer:onEnter( ... )
	print("onEnter ... ")
    --------引导 
	local _back = self:getChildByName("back_btn")	
    YinDaoMarg:getInstance():addGuide({parent = self,index = 4},15)----剧情
    YinDaoMarg:getInstance():addGuide({parent = self,index = 6},15)----剧情
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self._seekBtn,-----点击求签
        index = 5,
    },15)
    if _back then 
    	local _callback = _back:getTouchEndedCallback()
    	_back:setTouchEndedCallback(function( )
    		YinDaoMarg:getInstance():guideTouchEnd()
    		if self._parent and self._parent.addGuide then 
    			self._parent:addGuide()
    		end 
    		if _callback then 
    			_callback()
    		end 
    	end)
	    YinDaoMarg:getInstance():addGuide({
	        parent = self,
	        target = _back, -----点击返回
	        index = 7,
	        needNext = false,
	    },15)
	end 
	YinDaoMarg:getInstance():doNextGuide()
end

function QuXiongBiJiLayer:onExit( ... )
	print("onExit ... ")
end

function QuXiongBiJiLayer:create(data,parent)
	return QuXiongBiJiLayer.new(data,parent)
end


return QuXiongBiJiLayer
