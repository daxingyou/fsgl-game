--[=[
    FileName:BaiWanFuWongLayer.lua
    Content:百万富翁界面
]=]
local BaiWanFuWongLayer = class("BaiWanFuWongLayer", function(params)
    return XTHDSprite:createWithTexture(nil,cc.rect(0,0,856,415))
end)

function BaiWanFuWongLayer:ctor(params)

	self._initData = params.httpData
	--self._initData.finishState = 1   -- finishState 1没有结束 0已经结束

	self:initData()
	self:initSliverUI()
    
end

function BaiWanFuWongLayer:onCleanup()
		
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/activities/slotMachine/bg.png")
    textureCache:removeTextureForKey("res/image/activities/slotMachine/slot_bg.png")
    textureCache:removeTextureForKey("res/image/activities/slotMachine/slot_wen.png")
    textureCache:removeTextureForKey("res/image/activities/slotMachine/begin_btn_up.png")
    textureCache:removeTextureForKey("res/image/activities/slotMachine/begin_btn_down.png")
    textureCache:removeTextureForKey("res/image/activities/slotMachine/get1.png")
    textureCache:removeTextureForKey("res/image/activities/slotMachine/end1.png")
    textureCache:removeTextureForKey("res/image/activities/slotMachine/time.png")
    for i = 1, 10 do
    	textureCache:removeTextureForKey("res/image/activities/slotMachine/slot_" .. i .. ".png")
    end
end

function BaiWanFuWongLayer:initData()
	self._alreadyData = {}
	if self._initData.list then
		for i = 1, table.nums(self._initData.list) do
			self._alreadyData[i] = tonumber(self._initData.list[i])

		end
	end
end

function BaiWanFuWongLayer:initSliverUI()

	self._bg = XTHD.createSprite("res/image/activities/slotMachine/bgImg.png")
	self._bg:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
	self:addChild(self._bg)
	local bg3 = ccui.Scale9Sprite:create("res/image/activities/slotMachine/bg2.png")
	bg3:setContentSize(840,226)
	bg3:setPosition(self._bg:getContentSize().width/2-15, self._bg:getContentSize().height/2+30)
	self:addChild(bg3)




    local slotImgPos = {
    	[1] = cc.p(83,245),
    	[2] =  cc.p(201,245),
    	[3] =  cc.p(321,245),
    	[4] =  cc.p(440,245),
    	[5] =  cc.p(560,245),
    	[6] =  cc.p(680,245),
    	[7] =  cc.p(799,245),
	}

    for i = 1, 7 do
    	local slotImgBg = XTHD.createSprite("res/image/activities/slotMachine/slot_bg.png")
    	slotImgBg:setPosition(slotImgPos[i])
    	self:addChild(slotImgBg)
    	-- local meng = XTHD.createSprite("res/image/activities/slotMachine/slot_meng1.png")
    	-- meng:setPosition(slotImgPos[i])
    	-- self:addChild(meng)

    	if self._alreadyData[i] == -1 then
	    	local slotImgWen = XTHD.createSprite("res/image/activities/slotMachine/slot_wen.png")
	    	slotImgWen:setPosition(slotImgPos[i])
			self:addChild(slotImgWen)


			--记录今天应该摇的号
			self._slotBg = slotImgBg
			self._slotImgWen = slotImgWen
			self._tadayPos = i
    	else
    		local pathId = self._alreadyData[i] + 1
	    	local slotImgWen = XTHD.createSprite("res/image/activities/slotMachine/slot_" .. pathId .. ".png")
	    	slotImgWen:setPosition(slotImgPos[i])
			self:addChild(slotImgWen)
    	end

    end

    if self._initData.yaoState == 1 then
	    -- self._slotImgWen:removeFromParent()
	    local scrollView = ccui.ScrollView:create()
	    scrollView:setContentSize(cc.size(111,208))
	    scrollView:setAnchorPoint(0.5, 0.5)
	    scrollView:setTouchEnabled(false)	
	    scrollView:setBounceEnabled(false)
	    scrollView:setPosition(cc.p(111/2, 210/2-1))
		scrollView:setScrollBarEnabled(false)
	    -- scrollView:setPosition(cc.p(self._slotImgWen:getPositionX()-4, self._slotImgWen:getPositionY()+2))

	    scrollView:setName("scrollView")
	    self._slotBg:addChild(scrollView)
	    -- self:addChild(scrollView)

	    scrollView:setInnerContainerSize(cc.size(111,210 * 31))
	    self._scroll = scrollView

	    scrollView:setVisible(false)


		local slotImgBg1 = XTHD.createSprite("res/image/activities/slotMachine/slot_wen.png")
		scrollView:addChild(slotImgBg1)
		slotImgBg1:setPosition(111/2, 210/2)

	    for i = 1, 30 do
	    	local id = i
	    	if i > 10 and i <= 20 then
	    		id = i - 10
	    	elseif i > 20 and i <= 30 then
	    		id = i - 20
	    	end
	    	local slotImgBg1 = XTHD.createSprite("res/image/activities/slotMachine/slot_" .. id .. ".png")
	    	scrollView:addChild(slotImgBg1)
	    	slotImgBg1:setPosition(111/2, 210/2 + i * 210)
		end
		performWithDelay(self, function ( )
			local inner = self._scroll:getInnerContainer()
			inner:setPositionY(0)
		end,0.005)
	end


	    --随机种子
    -- math.randomseed(os.time())


	--btn
	--活动结束需要判断是否可领取奖励
	-- self._initData.rewardState = 1
	if self._initData.rewardState == 0 then
	    -- local slotBtn = XTHDPushButton:createWithParams({
		--     normalFile = "res/image/activities/slotMachine/begin_btn_up.png",
		--     selectedFile = "res/image/activities/slotMachine/begin_btn_down.png",
		--     musicFile = XTHD.resource.music.effect_btn_common,
		-- })
		local slotBtn = XTHD.createButton({
			normalFile = "res/image/activities/slotMachine/btn1_up.png",
			selectedFile = "res/image/activities/slotMachine/btn1_down.png",
		    musicFile = XTHD.resource.music.effect_btn_common,
	    })
	    slotBtn:setPosition(self:getContentSize().width / 2 + 138, 65)
	    self:addChild(slotBtn)
	    slotBtn:setTouchEndedCallback(function (  )
	        self:callHttp()
	    end)
	    self._slotBtn = slotBtn
	else

		if  self._initData.rewardState == 1 then
		    local rewardBtn = XTHD.createButton({
				normalFile = "res/image/activities/slotMachine/btn2_up.png",
				selectedFile = "res/image/activities/slotMachine/btn2_down.png",
		    	btnSize = cc.size(165,46),
			})
			rewardBtn:setScale(0.8)
		    self:addChild(rewardBtn)
		    rewardBtn:setPosition(self:getContentSize().width / 2 + 138, 65)
		    rewardBtn:setTouchEndedCallback(function (  )
		        self:getReward()
		    end)

		    self._rewardBtn = rewardBtn
		elseif self._initData.rewardState == 2 then

			-- 已领取
			local fetchedImageView = XTHD.createSprite( "res/image/vip/yilingqu.png" )
			fetchedImageView:setScale(0.7)
		    fetchedImageView:setPosition( self:getContentSize().width / 2 + 138, 65 )
		   	self:addChild(fetchedImageView)
		end

	end

    --1 活动没有结束
    if self._initData.finishState == 1 then
		local getImg = XTHD.createSprite("res/image/activities/slotMachine/get1.png")
		self:addChild(getImg)
		getImg:setPosition(self:getContentSize().width /2, self:getContentSize().height - 30)

		self._getImg = getImg
		for i = 1, 7 do
		    local getNum = XTHDLabel:createWithSystemFont(self._alreadyData[i], "res/fonts/def.ttf", 36)
		    getNum:setColor(cc.c3b(84,12,2))
		    getNum:setAnchorPoint(cc.p(0,0.5))
		    getNum:setPosition(142 + (i-1)*29.5,getImg:getContentSize().height/2)
		    getImg:addChild(getNum)
			if self._alreadyData[i] == -1 then
				getNum:setString("?")
				self._tadayNum = getNum
			end
		end
	else
		local getImg = XTHD.createSprite("res/image/activities/slotMachine/end1.png")
		self:addChild(getImg)
		getImg:setPosition(self:getContentSize().width /2, self:getContentSize().height - 30)

		for i = 1, 7 do
		    local getNum = XTHDLabel:createWithSystemFont(self._alreadyData[i], "res/fonts/def.ttf", 36)
		    getNum:setColor(cc.c3b(84,12,2))
		    getNum:setAnchorPoint(cc.p(0,0.5))
		    getNum:setPosition(202 + (i-1)*33.5,getImg:getContentSize().height/2)
		    getImg:addChild(getNum)
			if self._alreadyData[i] == -1 then
				getNum:setString("?")
				self._tadayNum = getNum
			end
		end
	end


	local timeImg = XTHD.createSprite("res/image/activities/slotMachine/time.png")
	self:addChild(timeImg)
	timeImg:setPosition(65, 65)

	--时间
	local timeTextBegin = LANGUAGE_KEY_GETMONTH(self._initData.beginMonth, self._initData.beginDay)
	local timeTextEnd	= LANGUAGE_KEY_GETMONTH(self._initData.endMonth, self._initData.endDay)



    local timeLab = XTHDLabel:createWithSystemFont(timeTextBegin .. "-" .. timeTextEnd, "res/fonts/def.ttf", 32)
    timeLab:setColor(cc.c3b(32,72,118))
    timeLab:setAnchorPoint(cc.p(0,0.5))
    timeLab:setPosition(timeImg:getPositionX() + 70 , timeImg:getPositionY())
    self:addChild(timeLab)


    local tipLab = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_TIP_SLOT, "res/fonts/def.ttf", 25)
    tipLab:setColor(cc.c3b(60,59,95))
    tipLab:setPosition(self:getContentSize().width /2, 20)
    self:addChild(tipLab)


end

--开始摇号
function BaiWanFuWongLayer:callHttp()

    ClientHttp:requestAsyncInGameWithParams({
        modules = "yaoSilver?",
        successCallback = function(data)
            -- dump(data, "slot_data-----")
			if tonumber(data.result) == 0 then
				gameUser.setActivityOpenStatusById(self._initData.redPointid, 0)
            	self:beginSlot(data)
            else
               XTHDTOAST(data.msg)
            end
        end,--成功回调
        loadingParent = sNode,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })

end


function BaiWanFuWongLayer:beginSlot(data)

	self._slotBtn:setEnable(false)

	self._slotImgWen:setVisible(false)

	local inner = self._scroll:getInnerContainer()
	inner:setPositionY(0)
	self._scroll:setVisible(true)

	local times = 0.03
    local dis = 0
    local tar = data.list[self._tadayPos]
    local length = 210 * (21 + tar)
    local totalNum = 100
    local totalLen = dis
    local isLast = false
    local speed = 10
	local function _test( ... )
		if totalLen >= length then
			self._slotBtn:setEnable(true)
			self._tadayNum:setString(tar)
			self:endHandle(data)
			return
		end
		performWithDelay(self,function( )
			
			totalLen = totalLen+dis

			if totalLen <= 420 then
				dis = dis + speed * 2
				if dis >= 25 then
					dis = 25
				end
				times = 0.03
			elseif totalLen < (length-210*5) then
				dis = 90
				times = 0.02
			elseif totalLen < (length-210*4) then
				dis = 70
				times = 0.025
			elseif totalLen < (length-210*3) then
				dis = 50
				times = 0.035
			elseif totalLen < (length-210*2) then
				dis = 30
				times = 0.04
			elseif totalLen < (length-210) then
				dis = 10
				times = 0.045
			elseif totalLen < length then
				dis = 8
				times = 0.05
			elseif totalLen == length then
				totalLen = totalLen - 10
				isLast = true
				dis = 10
				times = 0.06
			else
				dis = length - totalLen
				times = 0.06
				isLast = false
			end
			inner:setPositionY(inner:getPositionY() - dis)
			if isLast then
				dis = 20
			end
			
	        _test()
	    end, times)
	end

	_test()


end

function BaiWanFuWongLayer:getReward()


    ClientHttp:requestAsyncInGameWithParams({
        modules = "yaoSilverReward?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
            	--删除领取按钮
            	local pos = cc.p(self._rewardBtn:getPositionX(), self._rewardBtn:getPositionY())
            	self._rewardBtn:removeFromParent()
				-- 已领取
			    local fetchedImageView = XTHD.createSprite( "res/image/vip/yilingqu.png" )
			    fetchedImageView:setPosition( pos )
			   	self:addChild(fetchedImageView)
			   	--关闭活动
			   	gameUser.setActivityOpenStatusById(2,0)

			    --奖励展示
			    local show ={}
		    	show[1] = {}
		    	show[2] = {}
		    	show[1].rewardtype = XTHD.resource.type.gold
		    	show[1].num = tonumber(data.gold) - tonumber(gameUser.getGold()) 
		    	show[2].rewardtype = XTHD.resource.type.feicui
		    	show[2].num = tonumber(data.feicui) - tonumber(gameUser.getFeicui())
		    	--更新数据
		    	gameUser.setGold(data.gold)
		    	gameUser.setFeicui(data.feicui)

				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})

			   	ShowRewardNode:create(show)

            else
               XTHDTOAST(data.msg)
            end
        end,--成功回调
        loadingParent = sNode,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })


end

function BaiWanFuWongLayer:endHandle(data)
	
	--0 这次摇了之后结束
	if tonumber(data.finishState) == 0 then
		self._getImg:runAction(cc.Sequence:create( cc.FadeOut:create(0.1), cc.DelayTime:create(0.1),
			cc.CallFunc:create(function()
				self._getImg:removeFromParent()
			end)))

		performWithDelay(self, function()
			local pathId = "res/image/activities/slotMachine/end1.png"
			print("pathId -> ", pathId)

			local getImg = XTHD.createSprite(pathId)
			self:addChild(getImg)
			getImg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))

			getImg:setPosition(self:getContentSize().width /2, self:getContentSize().height - 30)

			print("nums --> ", table.nums(data.list))
			for i = 1, table.nums(data.list) do
			    local getNum = XTHDLabel:createWithSystemFont(data.list[i], "res/fonts/def.ttf", 20)
			    getNum:setColor(cc.c3b(108,59,2))
			    getNum:setAnchorPoint(cc.p(0,0.5))
			    getNum:setPosition(202 + (i-1)*33.5,getImg:getContentSize().height/2)
			    getImg:addChild(getNum)
				if data.list[i] == -1 then
					getNum:setString("?")
				end
			end

		end,0.3)

	end

end


function BaiWanFuWongLayer:create(params)
    return self.new(params)
end

return BaiWanFuWongLayer
