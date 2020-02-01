--Created By Liuluyang 2015年11月03日（第一版2015年10月10日）
--金玉其中主界面
local KaiShanCaiKuang = class("KaiShanCaiKuang",function ()
    return XTHD.createBasePageLayer({showGF = false, showPlus = false})
end)

function KaiShanCaiKuang:ctor(data, _callback)

    -- print("开衫采矿的数据为：")
    -- print_r(data)
	self._callback = _callback
	self._data = data.data
	self._timesData = {}
	self._timesData.surplusFreeBuyCount = data.surplusFreeBuyCount
	self._timesData.surplusGoldBuyCount = data.surplusGoldBuyCount
	self._cost = data.cost
	self._stoneData = gameData.getDataFromCSV("Mining")      --101是玉石 102是金矿
	table.sort(self._stoneData, function(a,b)
		return tonumber(a.id) > tonumber(b.id)
	end)
	self:initUI()
end

function KaiShanCaiKuang:onCleanup( ... )
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
    if self._callback and type(self._callback) == "function" then
    	self._callback()
    end
    local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey("res/image/daily_task/stone_gambling/di_1.png" )
	textureCache:removeTextureForKey("res/image/daily_task/stone_gambling/di_2.png" )
	textureCache:removeTextureForKey("res/image/daily_task/stone_gambling/stone_info_bg.png")
	textureCache:removeTextureForKey("res/image/daily_task/stone_gambling/mode_str_1.png" )
	textureCache:removeTextureForKey("res/image/daily_task/stone_gambling/mode_str_2.png" )
	textureCache:removeTextureForKey("res/image/daily_task/stone_gambling/lastTimes.png" )
	textureCache:removeTextureForKey("res/image/daily_task/stone_gambling/bgImg.jpg" )
end

function KaiShanCaiKuang:onEnter( )
	YinDaoMarg:getInstance():addGuide({index = 4,parent = self},3)
    YinDaoMarg:getInstance():addGuide({index = 6,parent = self},3)
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self._cutGoldBtn,-----排位赛设置防守队伍
        index = 5,
    },3)
    YinDaoMarg:getInstance():doNextGuide()	
end

function KaiShanCaiKuang:initUI()

    -- local bg = self:getChildByName("BgSprite")

    local bg = cc.Sprite:create("res/image/daily_task/stone_gambling/bgImg.png")
	local psize = bg:getContentSize()
	local csize = cc.Director:getInstance():getWinSize()
	self.scaleX = csize.width/psize.width
    bg:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
    bg:setContentSize(cc.Director:getInstance():getWinSize())
    self:addChild(bg,0)

    local pillarList = {
	    [1] = 303*self.scaleX,
	    -- [2] = 514,
	    [2] = 725*self.scaleX
	}
	self._bgList = {}
	self._stoneSpineList = {}
	for i=1,#pillarList do

		local di = cc.Sprite:create("res/image/daily_task/stone_gambling/di_" .. i .. ".png")
		di:setPosition(pillarList[i],self:getContentSize().height/2 - 5)
		bg:addChild(di,0)
		di:setScale(0.8)

		local stoneSpine = sp.SkeletonAnimation:create("res/spine/effect/stone_gambling/qs.json", "res/spine/effect/stone_gambling/qs.atlas",1.0)
		stoneSpine:setPosition(pillarList[i],385)
		bg:addChild(stoneSpine,1)
		stoneSpine:runAction(cc.RepeatForever:create(cc.Sequence:create(
	        cc.EaseInOut:create(cc.MoveBy:create(1.5,cc.p(0,20)),2),
	        cc.EaseInOut:create(cc.MoveBy:create(1.5,cc.p(0,-20)),2)
		)))
		--先注释掉，等给了动画再放开
		stoneSpine:setOpacity(0)

		self._stoneSpineList[i] = stoneSpine

		local lightSpine = sp.SkeletonAnimation:create("res/spine/effect/stone_gambling/jkysg.json","res/spine/effect/stone_gambling/jkysg.atlas",1.0)
		lightSpine:setPosition(pillarList[i],370)
		if i == 1 then
			lightSpine:setAnimation(0,"jk",true)
		else 
			lightSpine:setAnimation(0,"ys",true)
		end
		bg:addChild(lightSpine,2)

		local stoneInfoBg = cc.Sprite:create("res/image/daily_task/stone_gambling/stone_info_bg.png")
		stoneInfoBg:setAnchorPoint(0.5,0)
		stoneInfoBg:setPosition(pillarList[i],80)
		bg:addChild(stoneInfoBg,1)
		stoneInfoBg:setScale(0.8)

		--名字
		local modeStr = cc.Sprite:create("res/image/daily_task/stone_gambling/mode_str_"..i..".png")
		modeStr:setAnchorPoint(0.5,1)
		modeStr:setPosition(stoneInfoBg:getContentSize().width/2,stoneInfoBg:getBoundingBox().height + 59)
		stoneInfoBg:addChild(modeStr)

		local nowCSV = self._stoneData[i]
		local descUp = XTHDLabel:createWithSystemFont(nowCSV.tips2,"Helvetica",20)
		descUp:setColor(cc.c3b(100,100,255))
		descUp:setName("descUp")
		descUp:setAnchorPoint(0.5,1)
		descUp:setPosition(stoneInfoBg:getContentSize().width/2,stoneInfoBg:getBoundingBox().height)
		descUp:setWidth(260)
		stoneInfoBg:addChild(descUp)

		-- local descDown = XTHDLabel:createWithSystemFont(nowCSV.tips3,"Helvetica",20)
		-- descDown:setColor(cc.c3b(146,255,103))
		-- descDown:setName("descDown")
		-- descDown:setAnchorPoint(0.5,1)
		-- descDown:setPosition(stoneInfoBg:getContentSize().width/2,descUp:getPositionY()-descUp:getBoundingBox().height-20)
		-- descDown:setWidth(220)
		-- stoneInfoBg:addChild(descDown)

	    local btn = XTHD.createCommonButton({
			btnColor = "write_1",
			isScrollView = false,
	    	btnSize = cc.size(210,46),
	    	text = LANGUAGE_TIPS_STONECUT,
	    	fontSize = 28,
		})
		btn:setName("btn")
		btn:setPosition(stoneInfoBg:getContentSize().width/2,btn:getBoundingBox().height/2-90)
	    stoneInfoBg:addChild(btn)

	    --如果有免费次数
	    if tonumber(self._timesData.surplusFreeBuyCount) <= 0 then
		    local consumeStr = "<color=#FFFFFF fontSize=20 font=Helvetica>"..LANGUAGE_KEY_BUYCONSUME..":</color>".."<img="..IMAGE_KEY_HEADER_INGOT.." /><color=#FFFFFF fontSize=20 font=Helvetica>"..self._cost.."</color>"
		    local consumeLabel = RichLabel:createARichText(consumeStr,false)
		    consumeLabel:setAnchorPoint(0.5,0)
		    consumeLabel:setPosition(btn:getPositionX(),btn:getPositionY()+btn:getBoundingBox().height/2+9)
		    stoneInfoBg:addChild(consumeLabel)
		    consumeLabel:setName("consumeLabel")
		else
			local consumeStr = "<color=#FFFFFF fontSize=20 font=Helvetica>" ..LANGUAGE_TIPS_WORDS257 .. "</color>"
		    local consumeLabel = RichLabel:createARichText(consumeStr,false)
		    consumeLabel:setAnchorPoint(0.5,0)
		    consumeLabel:setPosition(btn:getPositionX(),btn:getPositionY()+btn:getBoundingBox().height/2+9)
		    stoneInfoBg:addChild(consumeLabel)
		    consumeLabel:setName("consumeLabel")
		end

	    stoneInfoBg.id = nowCSV.typeA         --石头的id(101是绿石头，102是金石头)
	    self._bgList[#self._bgList+1] = stoneInfoBg
	    if i == 1 then 
	    	self._cutGoldBtn = btn
	    end 
	end

	--剩余免费开采次数
	local ramainTimes = XTHDLabel:create("剩余免费开采次数：", 20)
	ramainTimes:setAnchorPoint(cc.p(0,0.5))
	ramainTimes:setPosition(10, self:getContentSize().height - 75)
	self:addChild(ramainTimes)

	local remainNum = XTHDLabel:createWithSystemFont(tostring(self._timesData.surplusFreeBuyCount), "Helvetica", 22)
	local remainNum = cc.Label:createWithBMFont("res/fonts/baisezi.fnt","")
	remainNum:setAnchorPoint(cc.p(0,0.5))
	remainNum:setPosition(ramainTimes:getPositionX() + ramainTimes:getContentSize().width, ramainTimes:getPositionY()-8)
	self:addChild(remainNum)
	self.remainNum = remainNum

	--剩余购买次数
	-- local lastTimesLab = cc.Sprite:create("res/image/daily_task/stone_gambling/lastTimes.png")
	local lastTimesLab = XTHDLabel:create("剩余付费开采次数：", 20)
	lastTimesLab:setAnchorPoint(cc.p(0,0.5))
	lastTimesLab:setPosition(10, self:getContentSize().height - 100)
	self:addChild(lastTimesLab)

	-- local lastTimes = XTHDLabel:createWithSystemFont("", "Helvetica", 22)
	local lastTimes = cc.Label:createWithBMFont("res/fonts/baisezi.fnt","")
	lastTimes:setAnchorPoint(cc.p(0,0.5))
	lastTimes:setPosition(lastTimesLab:getPositionX() + lastTimesLab:getContentSize().width, lastTimesLab:getPositionY()-8)
	self:addChild(lastTimes)
	self._lastTimes = lastTimes

	--
	-- local tip = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_WORDS258,"Helvetica",18)
	-- tip:setAnchorPoint(cc.p(0,0.5))
	-- tip:setColor(cc.c3b(255,245,80))
	-- tip:setPosition(30, self:getContentSize().height - 115)
	-- self:addChild(tip)

	self:refreshBtn()
end

function KaiShanCaiKuang:dataAnalyzer(params)

	-- dump(params, "dataAnalyzer1111111-------------------")
	if params.data then
		params.data = {params.data}
	end
	self._timesData = params.buy

	-- dump(params, "dataAnalyzer222222-------------------")

	for i=1,#params.data do
		local flag = 1
		for j=#self._data,1,-1 do
			local nowData = self._data[j]
			if params.data[i]._type == nowData._type then
				flag = 0
				if params.data[i].count == 0 then
					table.remove(self._data,j)
				else
					self._data[j] = params.data[i]
				end
				break
			end
		end
		if flag == 1 then
			self._data[#self._data+1] = params.data[i]
		end
	end
end

function KaiShanCaiKuang:refreshBtn()

	-- dump(self._data, "self.data=====")
	for i=1,#self._bgList do

		local nowBg = self._bgList[i]
		local btn = nowBg:getChildByName("btn")
		local consumeLabel = nowBg:getChildByName("consumeLabel")
		local btnStr = ""
		local _btnColor
		if  consumeLabel then
			consumeLabel:removeFromParent()
			consumeLabel = nil
		end


	    local nowCSV = self._stoneData[i]

		local flag = 0  --这里判断之前是否买过
		for j=1,#self._data do

			local nowData = self._data[j]

			if nowBg.id == nowData._type and tonumber(nowData.count) > 0 then
			    
				--买过
				flag = 1 
				break
			end
		end

		if flag == 0 then 

            self.remainNum:setString(tostring(self._timesData.surplusFreeBuyCount))
			--判断是否还有免费次数
	   	    if tonumber(self._timesData.surplusFreeBuyCount) <= 0 then
			    local consumeStr = "<color=#FFFFFF fontSize=20 font=Helvetica>"..LANGUAGE_KEY_BUYCONSUME..":</color>".."<img="..IMAGE_KEY_HEADER_INGOT.." /><color=#FFFFFF fontSize=20 font=Helvetica>"..self._cost.."</color>"
			    local consumeLabel = RichLabel:createARichText(consumeStr,false)
			    consumeLabel:setAnchorPoint(0.5,0)
			    consumeLabel:setPosition(btn:getPositionX(),btn:getPositionY()+btn:getBoundingBox().height/2+9)
			    nowBg:addChild(consumeLabel)
			    consumeLabel:setName("consumeLabel")
			else
				local consumeStr = "<color=#FFFFFF fontSize=20 font=Helvetica>" ..LANGUAGE_TIPS_WORDS257 .. "</color>"
			    local consumeLabel = RichLabel:createARichText(consumeStr,false)
			    consumeLabel:setAnchorPoint(0.5,0)
			    consumeLabel:setPosition(btn:getPositionX(),btn:getPositionY()+btn:getBoundingBox().height/2+9)
			    nowBg:addChild(consumeLabel)
			    consumeLabel:setName("consumeLabel")
			end
		end

		local stoneType = nowBg.id == 101 and 6 or 3	
		self._stoneSpineList[i]:setAnimation(0,stoneType .. "_0",true)

		--切石
		btn:setTouchEndedCallback(function ()
			
			if tonumber(self._timesData.surplusGoldBuyCount) > 0 then
				if self._isAction then
					return 
				end
				ClientHttp:requestAsyncInGameWithParams({
			        modules = "okeyCutJade?",
			        params = {_type=nowBg.id},
				    successCallback = function(data)
				        -- dump(data, "data-----")
				        if tonumber(data.result) == 0 then --请求成功
							----------------------------------------------------------------
							YinDaoMarg:getInstance():guideTouchEnd()
							----------------------------------------------------------------
				        	self._isAction = true
				        	XTHD.updateProperty(data.property)
				        	self._timesData.surplusFreeBuyCount = data.surplusFreeBuyCount and data.surplusFreeBuyCount or self._timesData.surplusFreeBuyCount 
				        	self._timesData.surplusGoldBuyCount = data.surplusGoldBuyCount and data.surplusGoldBuyCount or self._timesData.surplusGoldBuyCount
				        	self:dataAnalyzer({data=data,buy=self._timesData})
							RedPointState[16].state = data.surplusFreeBuyCount > 0 and 1 or 0
							XTHD.dispatchEvent({name = "tempfresh"})
							XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "ywc"}})
							
							self._cost = data.nextcost
						    --奖励展示
						    local show ={}
					    	show[1] = {}
					    	show[1].rewardtype = nowBg.id == 102 and XTHD.resource.type.gold or XTHD.resource.type.feicui
					    	show[1].num = data.soldPrice
					    	--更新数据
							XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
							XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
							--如果大于100000显示暴击
						   	if tonumber(data.soldPrice) >= 100000 then
						   		self:runAction(cc.Sequence:create(
						   			cc.CallFunc:create(function() 
									   	ShowRewardNode:createWithParams({
									   		showData = show,
									   		target = self,
									   		zorder = 1,
									   	})
						   			end),
						   			cc.DelayTime:create(0.5),
						   			cc.CallFunc:create(function() 
		   				                local _rateSp = cc.Sprite:create("res/image/common/exchange_burstsp.png")
						                _rateSp:setPosition(cc.p(self:getContentSize().width/2-15, self:getContentSize().height/2 + 60))
						                self:addChild(_rateSp, 25)
						                local _ratelabel = cc.Label:createWithBMFont("res/fonts/item_num.fnt","x"..data.soldPrice/100000)
						                _ratelabel:setAnchorPoint(cc.p(0,0.5))
						                _ratelabel:setPosition(cc.p(_rateSp:getContentSize().width, _rateSp:getContentSize().height/2))
						                _rateSp:addChild(_ratelabel)
						                _rateSp:runAction(cc.Sequence:create(cc.FadeOut:create(1.0), cc.RemoveSelf:create(true)))
						                _ratelabel:runAction(cc.Sequence:create(cc.FadeOut:create(1.0)))
						   			end),
						   			cc.CallFunc:create(function() 
						   				self:refreshBtn()
						   				self._isAction = false
						   			end)
					   			))
						   	else
							   	ShowRewardNode:createWithParams({
							   		showData = show,
							   		target = self,
							   		zorder = 1,
							   	})
							   	self:refreshBtn()
							   	self._isAction = false
						   	end
				        else
				           XTHDTOAST(data.msg) --出错信息(后端返回)
				        end
				    end,--成功回调
				    loadingParent = self,
				    failedCallback = function()
				        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
				    end,--失败回调
				    targetNeedsToRetain = self,--需要保存引用的目标
				    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
				})
			else
				local _node = XTHD.createSprite()
				_node:setContentSize(cc.size(375,130))

				local tip1 = XTHDLabel:createWithParams({
					text = LANGUAGE_TIPS_WORDS204,
					fontSize = 18,
					color = XTHD.resource.color.brown_desc,
					anchor = cc.p(0.5, 0.5),
					pos = cc.p(_node:getContentSize().width/2, _node:getContentSize().height/2+20),
				})
				_node:addChild(tip1)

				local tip2 = XTHDLabel:createWithParams({
					text = LANGUAGE_TIPS_TILI_NOTIMES,
					fontSize = 18,
					color = XTHD.resource.color.brown_desc,
					anchor = cc.p(0.5, 0.5),
					pos = cc.p(_node:getContentSize().width/2, _node:getContentSize().height/2-20),
				})
				_node:addChild(tip2)

				local confirm = XTHDConfirmDialog:createWithParams({
					leftVisible = false,
					rightText = LANGUAGE_BTN_KEY.sure,
					contentNode = _node
				})
				self:addChild(confirm)

			end
		end)

	end

	self._lastTimes:setString(tostring(tonumber(self._timesData.surplusGoldBuyCount)))
end

function KaiShanCaiKuang:create(data, _callback)
	return KaiShanCaiKuang.new(data, _callback)
end

return KaiShanCaiKuang