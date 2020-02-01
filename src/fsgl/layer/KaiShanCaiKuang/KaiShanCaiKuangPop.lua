--Created By Liuluyang 2015年11月03日
local KaiShanCaiKuangPop = class("KaiShanCaiKuangPop",function ()
	return XTHDDialog:create(235)
end)

function KaiShanCaiKuangPop:ctor(params,fNode)

	self._data = params.initData
	self._buyState = params.buyState
	self._fNode = fNode
	self:initUI()
	self:refreshStone()
end

function KaiShanCaiKuangPop:onCleanup()
	local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/daily_task/stone_gambling/gold_mode_1.png")
    textureCache:removeTextureForKey("res/image/daily_task/stone_gambling/gold_mode_2.png")

end

function KaiShanCaiKuangPop:initUI()
	local backBtn = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create("res/image/common/btn/btn_back_normal.png"),
		selectedNode = cc.Sprite:create("res/image/common/btn/btn_back_selected.png"),
	})
	backBtn:setAnchorPoint(1,1)
	backBtn:setPosition(self:getBoundingBox().width,self:getBoundingBox().height)
	backBtn:setTouchSize(cc.size(120,120))
	self:addChild(backBtn,2)
	backBtn:setTouchEndedCallback(function ()
		self._fNode:refreshBtn()
		self:removeFromParent()
	end)

	self._backBtn = backBtn

	local desc = XTHDLabel:createWithParams({
		text = LANGUAGE_KEY_GAMBLING,
		fontSize = 20,
		color = cc.c3b(255,229,138)
	})
	desc:setPosition(self:getBoundingBox().width/2,150)
	self:addChild(desc)
	self._desc = desc

	--切石
    local cutBtn = XTHD.createCommonButton({
		btnColor = "green",
		isScrollView = false,
    	btnSize = cc.size(265,46),
    	text = LANGUAGE_TIPS_STONECUT,
    	fontSize = 22,
	})
	cutBtn:setName("cutBtn")
	cutBtn:setAnchorPoint(0,0)
    cutBtn:setPosition(self:getBoundingBox().width/2+50,30)
    self:addChild(cutBtn)
    self._cutBtn = cutBtn

    --出售
    local sellBtn = XTHD.createCommonButton({
		btnColor = "red",
		isScrollView = false,
    	btnSize = cc.size(265,46),
    	text = LANGUAGE_TIPS_STONESELL,
    	fontSize = 22,
	})
    sellBtn:setAnchorPoint(1,0)
	sellBtn:setPosition(self:getBoundingBox().width/2-50,30)
	self:addChild(sellBtn)
	self._sellBtn = sellBtn


    --购买
    local buyBtn = XTHD.createCommonButton({
		btnColor = "green",
		isScrollView = false,
    	btnSize = cc.size(265,46),
    	text = LANGUAGE_TIPS_STONEBUY,
    	fontSize = 22,
	})
	buyBtn:setName("buyBtn")
	buyBtn:setAnchorPoint(0.5,0)
    buyBtn:setPosition(self:getBoundingBox().width/2,30)
    self:addChild(buyBtn)
    self._buyBtn = buyBtn

    self.rstSpine = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/zhsm.json", "res/spine/effect/exchange_effect/zhsm.atlas",1)
    self.rstSpine:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
    self:addChild(self.rstSpine,2)
    self.rstSpine:setTimeScale(1000)
    self.rstSpine:setAnimation(0,"a2",false)

    self._lighting = sp.SkeletonAnimation:create("res/spine/effect/stone_gambling/sd.json", "res/spine/effect/stone_gambling/sd.atlas",1.0)
    self._lighting:setAnchorPoint(0.5,0.5)
    self._lighting:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
    self:addChild(self._lighting)
    -- self._lighting:setTimeScale(0.5)
    self._lighting:setAnimation(0,"atk",false)

    self._lighting:registerSpineEventHandler( function ( event )
    	--注册闪电播放事件  入场动画为atk 然后循环播放idle
		if event.animation == "atk" then
			self._lighting:setAnimation(0.5,"idle",true)
		end
	end, sp.EventType.ANIMATION_COMPLETE)

		--切碎动画
	self._qsFaile = sp.SkeletonAnimation:create("res/spine/effect/stone_gambling/suilie.json", "res/spine/effect/stone_gambling/suilie.atlas",1.0)
	self._qsFaile:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addChild(self._qsFaile,1)
	--self._qsFaile:setAnimation(0,falseAnim,false)
	--self._qsFaile:setTimeScale(1000)	
	self._qsFaile:setScale(1.5)
	self._qsFaile:setVisible(false)
end

function KaiShanCaiKuangPop:refreshStone(isTint)
	isTint = isTint or false
	local data = self._data

	local _type = data._type == 101 and 6 or 3
	local httpType ={
		buy = "buyJade?",
		cut = "cutJade?",
		sold = "soldJade?",
	}
	local index = data._type == 101 and 1 or 2
	self._stoneData = gameData.getDataFromCSV("Mining")
	local nowCSV = self._stoneData[index]

	if not self._stoneSpine then
		self._stoneSpine = sp.SkeletonAnimation:create("res/spine/effect/stone_gambling/qs.json", "res/spine/effect/stone_gambling/qs.atlas",1.0)
		self._stoneSpine:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
		self:addChild(self._stoneSpine,1)
		self.stoneType = data._type == 101 and 6 or 3     --6是玉3 是金
		self._stoneSpine:setAnimation(0.5,self.stoneType.."_"..tostring((5-self._data.cutTimes)*11),true)
		self._stoneSpine:setScale(1.5)

		self._stoneSpine:registerSpineEventHandler( function ( event )
			if event.eventData.name == "win" and self._isSuccess then
				self.rstSpine:setTimeScale(1)
	        	self.rstSpine:setAnimation(0,"a2",false)
			end
		end, sp.EventType.ANIMATION_EVENT)
	end
	if self._data.count > 0 and self._data.cutTimes > 0 then
		self._cutBtn:setVisible(true)
		self._sellBtn:setVisible(true)
		self._sellBtn:setPositionX(self:getBoundingBox().width/2-50)
		self._buyBtn:setVisible(false)
	elseif self._data.count > 0 and self._data.cutTimes == 0 then
		self._cutBtn:setVisible(false)
		self._sellBtn:setVisible(true)
		self._sellBtn:setPositionX(self:getBoundingBox().width/2+self._sellBtn:getBoundingBox().width/2)
		self._buyBtn:setVisible(false)
	else
		self._cutBtn:setVisible(false)
		self._sellBtn:setPositionX(self:getBoundingBox().width/2-50)
		self._sellBtn:setVisible(false)
		self._buyBtn:setVisible(true)
	end

	self._backBtn:setTouchEndedCallback(function ()
		self._fNode:refreshBtn()
		self:removeFromParent()
	end)

	if self._data.cutTimes and 5-self._data.cutTimes == 5 then
		self._backBtn:setTouchEndedCallback(function ()
			XTHDTOAST(LANGUAGE_KEY_NOQUIT)
		end)
	end

	if self._buyLabel then
		self._buyLabel:removeFromParent()
		self._buyLabel = nil
	end
	self._stoneSpine:stopAllActions()

	if self._worth then
		self._worth:removeFromParent()
		self._worth = nil
	end
	if self._headIcon then
		self._headIcon:removeFromParent()
		self._headIcon = nil
	end
	if self._price then
		self._price:removeFromParent()
		self._price = nil
	end
	
	self._worth = XTHDLabel:createWithParams({
		text = self._data.count > 0 and LANGUAGE_KEY_VALUE or LANGUAGE_KEY_BUYNEED, --价值， 价格
		fontSize = 20,
		color = cc.c3b(255,255,255)
	})
	self._worth:setAnchorPoint(0,0.5)
	self:addChild(self._worth)

	self._headIcon = cc.Sprite:create(self._data.count > 0 and XTHD.getHeaderIconPath(_type == 6 and XTHD.resource.type.feicui or XTHD.resource.type.gold) or IMAGE_KEY_HEADER_INGOT)
	self._headIcon:setAnchorPoint(0,0.5)
	self._price = getCommonWhiteBMFontLabel(self._data.count > 0 and self._data.soldPrice or nowCSV.need)
	self._price:setAnchorPoint(0,0.5)
	self._worth:setPosition((self:getBoundingBox().width-(self._worth:getBoundingBox().width+self._headIcon:getBoundingBox().width+self._price:getBoundingBox().width))/2,self._desc:getPositionY()-35)
	self._headIcon:setPosition(self._worth:getPositionX()+self._worth:getBoundingBox().width,self._worth:getPositionY())
	self._price:setPosition(self._headIcon:getPositionX()+self._headIcon:getBoundingBox().width,self._headIcon:getPositionY()-7)

	self:addChild(self._headIcon)
	self:addChild(self._price)


	if tonumber(self._data.count) == 0 then
		if tonumber(self._buyState.surplusFreeBuyCount) > 0 then
				if self._headIcon then
					self._headIcon:removeFromParent()
					self._headIcon = nil
				end
				if self._price then
					self._price:removeFromParent()
					self._price = nil
				end
			self._worth:setString(LANGUAGE_TIPS_WORDS257)
			self._worth:setPositionX(self:getBoundingBox().width/2 - self._worth:getBoundingBox().width/2)
		end
	end

	if isTint == true then
		letTheLableTint(self._price,true)
	end

	if self._data.count > 0 then
		self._stoneSpine:setOpacity(255)
	end

	if not self._finishSp then
		self._finishSp = cc.Sprite:create("res/image/daily_task/stone_gambling/gold_mode_"..index..".png")
		self._finishSp:setAnchorPoint(0.5,0)
		self._finishSp:setPosition(self:getBoundingBox().width/2,self._desc:getPositionY()+self._desc:getBoundingBox().height/2+10)
		self:addChild(self._finishSp)
	end
	self._finishSp:setOpacity(0)

	self._cutBtn:setTouchEndedCallback(function ()
		--切石回调
		XTHDHttp:requestAsyncInGameWithParams({
	        modules = httpType.cut,
	        params = {_type = data._type},
	        successCallback = function(data)
		        if tonumber(data.result) == 0 then
		        	-- self._buyState.surplusFreeBuyCount = data.surplusFreeBuyCount
		        	-- self._buyState.surplusGoldBuyCount = data.surplusGoldBuyCount
		        	self._buyState.surplusFreeBuyCount = data.surplusFreeBuyCount and data.surplusFreeBuyCount or self._buyState.surplusFreeBuyCount
		        	self._buyState.surplusGoldBuyCount = data.surplusGoldBuyCount and data.surplusGoldBuyCount or self._buyState.surplusGoldBuyCount
	        		self._fNode:dataAnalyzer({data=data,buy=self._buyState})
		        	self.rstSpine:setTimeScale(1000)
		        	local oldData = self._data
		        	self._data = data
		        	if data.succ == 1 then
		        		self._isSuccess = true
		        		--切成功
			        	self._stoneSpine:setAnimation(0.5,self.stoneType.."_"..tostring(5-self._data.cutTimes),false)
			        	local animName = 5-self._data.cutTimes
			        	if 5-self._data.cutTimes == 5 then
			        		--最后一刀成功
			        		-- self.rstSpine:setTimeScale(1)
			        		-- self.rstSpine:setAnimation(0,"a2",false)
			        		self._stoneSpine:registerSpineEventHandler( function ( event )
								if event.animation == self.stoneType.."_"..tostring(animName) then
									self._stoneSpine:setAnimation(0.5,self.stoneType.."_55",true)
									self._finishSp:runAction(cc.FadeIn:create(0.3))
								end
							end, sp.EventType.ANIMATION_COMPLETE)
			        		self._lighting:setOpacity(254)
							self._lighting:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.FadeOut:create(0.3)))
			        	else
			        		--不是最后一刀成功
			        		self._stoneSpine:registerSpineEventHandler( function ( event )
								if event.animation == self.stoneType.."_"..tostring(animName) then
									self._stoneSpine:setAnimation(0.5,self.stoneType.."_"..tostring(animName*11),true)
								end
							end, sp.EventType.ANIMATION_COMPLETE)
			        	end
			        	self:refreshStone(true)
			        else
			        	self._isSuccess = false
		        		self._isFaile = true
			        	--切碎了
			        	local falseAnim = _type == 3 and "jin" or "yu" --碎裂动画名称
			        	local animName = tostring(5-(oldData.cutTimes-1))
		        		self._stoneSpine:setAnimation(0,self.stoneType.."_"..animName,false)
		        		self._stoneSpine:runAction(cc.Sequence:create(cc.DelayTime:create(0.25),cc.CallFunc:create(function()
	        				self._stoneSpine:setVisible(false)
	        			end)))

			        	if self._swallowBg then
		        			self._swallowBg:removeFromParent()
		        			self._swallowBg = nil
		        		end
		        		self._swallowBg = XTHDDialog:create()
		        		self:addChild(self._swallowBg)

			        	self._qsFaile:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
			        		
			        		self._qsFaile:setVisible(true)
		        			self._qsFaile:setAnimation(0,falseAnim,false)

							self.rstSpine:setTimeScale(1)                                                                                                                                        
				        	self.rstSpine:setAnimation(0,"a3",false)
				        	
			        		self:refreshStone()
			        		self._swallowBg:removeFromParent()
			        		self._swallowBg = nil
			        		self._lighting:setVisible(false)
			        	end)))

			        	self._qsFaile:registerSpineEventHandler( function ( event )
							if event.animation == falseAnim and self._isFaile then
								--碎完了 播放切成功的字
								-- self.rstSpine:setTimeScale(1)                                                                                                                                        
					   --      	self.rstSpine:setAnimation(0,"a3",false)
			        			self._qsFaile:setVisible(false)


					        	self._lighting:runAction(cc.Sequence:create(cc.FadeOut:create(0.3),cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
					        		--继续播放闪电
					        		self._lighting:setVisible(true)
					        		self._lighting:setOpacity(255)
					        		self._lighting:setAnimation(0,"atk",false)
					        	end)))
								self._stoneSpine:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
									self._stoneSpine:setAnimation(0.5,self.stoneType.."_0",false)
			        				self._stoneSpine:setVisible(true)
			        				self._stoneSpine:setOpacity(255)

								end),cc.FadeIn:create(0.5)))
							end
						end, sp.EventType.ANIMATION_COMPLETE)
			        end
		        else
		            XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
		        end
	        end,--成功回调
	        failedCallback = function()
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
	        end,--失败回调
	        targetNeedsToRetain = self,--需要保存引用的目标
	        loadingParent = self,
	        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	    })
	end)

	self._buyBtn:setTouchEndedCallback(function ()
		--购买回调
		XTHDHttp:requestAsyncInGameWithParams({
	        modules = httpType.buy,
	        params = {_type = data._type},
	        successCallback = function(data)
		        if tonumber(data.result) == 0 then
		        	-- self._buyState.surplusFreeBuyCount = data.surplusFreeBuyCount
		        	-- self._buyState.surplusGoldBuyCount = data.surplusGoldBuyCount
		        	self._buyState.surplusFreeBuyCount = data.surplusFreeBuyCount and data.surplusFreeBuyCount or self._buyState.surplusFreeBuyCount
		        	self._buyState.surplusGoldBuyCount = data.surplusGoldBuyCount and data.surplusGoldBuyCount or self._buyState.surplusGoldBuyCount
		        	self._fNode:dataAnalyzer({data=data,buy=self._buyState})
					self._lighting:setVisible(true)
		        	if self._lighting:getOpacity() ~= 255 then
		        		self._lighting:stopAllActions()
		        		self._lighting:setAnimation(0,"atk",false)
		        		self._lighting:setOpacity(255)
		        	end
		        	self.rstSpine:setTimeScale(1000)
		        	self._qsFaile:setVisible(false)
		        	self._isFaile = false
		        	self._isSuccess = false
		        	self._stoneSpine:setVisible(true)
		        	self._stoneSpine:setAnimation(0.5,self.stoneType.."_0",true)
		        	XTHD.updateProperty(data.property)
		        	self._data = data
		        	self:refreshStone()
		        else
		            XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
		        end
	        end,--成功回调
	        failedCallback = function()
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
	        end,--失败回调
	        targetNeedsToRetain = self,--需要保存引用的目标
	        loadingParent = self,
	        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	    })
	end)

	self._sellBtn:setTouchEndedCallback(function ()
		--出售回调
		XTHDHttp:requestAsyncInGameWithParams({
	        modules = httpType.sold,
	        params = {_type = data._type},
	        successCallback = function(data)
		        if tonumber(data.result) == 0 then
		        	self._buyState.surplusFreeBuyCount = data.surplusFreeBuyCount and data.surplusFreeBuyCount or self._buyState.surplusFreeBuyCount
		        	self._buyState.surplusGoldBuyCount = data.surplusGoldBuyCount and data.surplusGoldBuyCount or self._buyState.surplusGoldBuyCount
	        		self._fNode:dataAnalyzer({data=data,buy=self._buyState})
		        	XTHD.updateProperty(data.property)
		        	ShowRewardNode:create({{rewardtype = data._type == 102 and XTHD.resource.type.gold or XTHD.resource.type.feicui,num = self._data.soldPrice}})
		        	self._data = data
		        	-- self._stoneSpine:set
		        	self._stoneSpine:setAnimation(0.5,self.stoneType.."_0",true)
		        	self:refreshStone()
		        	if self._lighting:getOpacity() ~= 255 then
		        		self._lighting:stopAllActions()
		        		self._lighting:setAnimation(0,"atk",false)
		        		self._lighting:setOpacity(255)
		        	end
		        else
		            XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
		        end
	        end,--成功回调
	        failedCallback = function()
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
	        end,--失败回调
	        targetNeedsToRetain = self,--需要保存引用的目标
	        loadingParent = self,
	        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	    })
	end)
end

function KaiShanCaiKuangPop:create(data,fNode)
	return KaiShanCaiKuangPop.new(data,fNode)
end

return KaiShanCaiKuangPop