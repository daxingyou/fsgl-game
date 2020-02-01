--Created By Liuluyang 2015年08月31日
--神器遗址选择挑战难度
local ShenQiYiZhiModeLayer = class("ShenQiYiZhiModeLayer",function ()
	return XTHD.createPopLayer()
end)

function ShenQiYiZhiModeLayer:ctor(data,_type,beast,callfunc)
	self.callfunc = callfunc
	self:initUI(data,_type,beast)
end

function ShenQiYiZhiModeLayer:initUI(data,_type,beast)
	self.beastData = gameData.getDataFromCSV("ServantOpenList")
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	bg:setContentSize(cc.size(744,458))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)
	--kuang 
	local kuang = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	kuang:setAnchorPoint(0,0)
	kuang:setContentSize(bg:getContentSize().width-20,bg:getContentSize().height-80)
	kuang:setPosition(10,30)
	bg:addChild(kuang)

	self.bg = bg

	--关闭按钮
	local closeBtn = XTHD.createButton({
		normalFile = "res/image/common/btn/btn_red_close_normal.png",
		selectedFile = "res/image/common/btn/btn_red_close_selected.png",
	})
	closeBtn:setPosition(bg:getContentSize().width,bg:getContentSize().height-5)
	closeBtn:setAnchorPoint(0.5,0.5)
	bg:addChild(closeBtn)
	closeBtn:setTouchEndedCallback(function ()
		self:hide()
	end)

	-- local titleSp = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277,34))
	local titleSp = ccui.Scale9Sprite:create("res/image/plugin/saint_beast/title_bg.png")
	titleSp:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-30)
	bg:addChild(titleSp)

	local titleLabel = XTHDLabel:createWithParams({
		text = LANGUAGE_TIPS_WORDS181,--------"选择想要挑战的难度",
		fontSize = 20,
		color = cc.c3b(0,0,255),
		ttf = "res/fonts/def.ttf"
	})
	titleLabel:setPosition(titleSp:getBoundingBox().width/2,titleSp:getBoundingBox().height/2)
	titleSp:addChild(titleLabel)

	for i=1,4 do
		local _isOpen = gameUser.getLevel() >= self.beastData[(beast-1)*4+i].needlevel
		local file = _isOpen and "res/image/plugin/saint_beast/mode_"..i..".png" or "res/image/plugin/saint_beast/mode_dis.png"
		local modeBg = XTHD.createButton({
			normalFile = file,
		})
		modeBg:setAnchorPoint(0.5,1)
		modeBg:setPosition(XTHD.resource.getPosInArr({
			lenth = 10,
			bgWidth = bg:getBoundingBox().width,
			num = 4,
			nodeWidth = modeBg:getBoundingBox().width,
			now = i,
		}),bg:getBoundingBox().height-70)
		bg:addChild(modeBg)

		

		if i == 1 then
			self.modeShine = cc.Sprite:create("res/image/plugin/saint_beast/select_shine.png")
			self.modeShine:setPosition(modeBg:getBoundingBox().width/2,modeBg:getBoundingBox().height/2)
			modeBg:addChild(self.modeShine)
		end

		

		if not _isOpen then
			local modeSp = cc.Sprite:create("res/image/plugin/saint_beast/mode_sp_dis"..i..".png")
			modeSp:setPosition(modeBg:getBoundingBox().width/2,modeBg:getBoundingBox().height/2)
			modeBg:addChild(modeSp)
			-- XTHD.setGray(modeBg:getStateNormal(),true)
			-- XTHD.setGray(modeSp,true)
			modeBg:setTouchEndedCallback(function ()
				local str = LANGUAGE_FORMAT_TIPS37(self.beastData[(beast-1)*4+i].needlevel)
				XTHDTOAST(str)
			end)

			local locker = cc.Sprite:create("res/image/plugin/saint_beast/locker_icon.png")
			locker:setPosition(modeBg:getBoundingBox().width/2,modeBg:getBoundingBox().height/2+20)
			modeBg:addChild(locker)

			if i ~= 1 then
				local unlockSp = cc.Sprite:create("res/image/plugin/saint_beast/unlock_sp_"..i..".png")
				unlockSp:setPosition(modeBg:getBoundingBox().width/2,modeBg:getBoundingBox().height/2)
				modeBg:addChild(unlockSp)
			end
		else
			local modeSp = cc.Sprite:create("res/image/plugin/saint_beast/mode_sp_"..i..".png")
			modeSp:setPosition(modeBg:getBoundingBox().width/2,modeBg:getBoundingBox().height/2)
			modeBg:addChild(modeSp)

			modeBg:setTouchEndedCallback(function ()
				if self.modeShine then
					self.modeShine:removeFromParent()
				end
				self.modeShine = cc.Sprite:create("res/image/plugin/saint_beast/select_shine.png")
				self.modeShine:setPosition(modeBg:getBoundingBox().width/2,modeBg:getBoundingBox().height/2)
				modeBg:addChild(self.modeShine)

				self:refreshReward((beast-1)*4+i)
				self:createChallage(_type,(beast-1)*4+i,beast)
			end)
		end
	end

	local split = ccui.Scale9Sprite:create("res/image/plugin/saint_beast/title_bg2.png")
	split:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height/2+5)
	bg:addChild(split)

	local rewardSp = cc.Sprite:create("res/image/plugin/saint_beast/reward_str.png")
	rewardSp:setAnchorPoint(0,0.5)
	rewardSp:setPosition(15,split:getBoundingBox().height/2)
	split:addChild(rewardSp)

	if _type == 2 then
		local consumeBg = ccui.Scale9Sprite:create("res/image/common/topbarItem_bg.png")
		consumeBg:setContentSize(cc.size(102,31))
		consumeBg:setAnchorPoint(0,0.5)
		consumeBg:setPosition(140,70)
		bg:addChild(consumeBg)
		self.consumeBg = consumeBg

		local ownBg = ccui.Scale9Sprite:create("res/image/common/topbarItem_bg.png")
		ownBg:setContentSize(cc.size(90,31))
		ownBg:setAnchorPoint(0,0.5)
		ownBg:setPosition(consumeBg:getPositionX()+consumeBg:getBoundingBox().width+135,70)
		bg:addChild(ownBg)
		self.ownBg = ownBg

		local consumeItem = self.beastData[1].consume
		-- local itemName = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = consumeItem}).name
		local consumeStr = XTHDLabel:createWithParams({
			text = LANGUAGE_TIP_CHALLENGE_COST..":",-------挑战消耗"..itemName..":",
			fontSize = 18,
			color = cc.c3b(55,54,112),
			ttf = "res/fonts/def.ttf"
		})
		consumeStr:setAnchorPoint(0,0.5)
		consumeStr:setPosition(ownBg:getPositionX()-ownBg:getContentSize().width/2-55,ownBg:getPositionY())
		bg:addChild(consumeStr)

		local consumeIcon = XTHD.createSprite( "res/image/plugin/saint_beast/saintbeasticon.png" )
		consumeIcon:setAnchorPoint( cc.p( 0, 0.5 ) )
		consumeIcon:setPosition( consumeStr:getPositionX() + consumeStr:getContentSize().width+2, consumeStr:getPositionY() )
		bg:addChild( consumeIcon )
		self.consumeIcon = consumeIcon

		local cosumeNum = getCommonWhiteBMFontLabel(10)
		cosumeNum:setAnchorPoint(0.5,0.5)
		cosumeNum:setPosition(self.ownBg:getContentSize().width/2,self.ownBg:getContentSize().height/2-5)
		self.cosumeNum = cosumeNum
		self.ownBg:addChild(cosumeNum,1)

		local stonePlus = XTHD.createButton({
			normalFile = "res/image/common/btn/btn_plus_normal.png",
			selectedFile = "res/image/common/btn/btn_plus_selected.png",
		})
		stonePlus:setScale(0.8)
		stonePlus:setAnchorPoint(0,0.5)
		stonePlus:setPosition(consumeBg:getBoundingBox().width,consumeBg:getBoundingBox().height/2)
		consumeBg:addChild(stonePlus)

		stonePlus:setTouchEndedCallback(function ()
			XTHD.createSaintBeastChange(self:getParent(),function ()
				self.ownNum:setString(XTHD.resource.getItemNum(consumeItem))
			end,1)
		end)

		local ownStr = XTHDLabel:createWithParams({
			text = LANGUAGE_TIP_OWNED_NUMBERS..":",------拥有数量:",
			fontSize = 18,
			color = cc.c3b(55,54,112),
			ttf = "res/fonts/def.ttf"
		})
		ownStr:setAnchorPoint(0,0.5)
		ownStr:setPosition(30,consumeBg:getPositionY())
		bg:addChild(ownStr)

		local ownIcon = XTHD.createSprite( "res/image/plugin/saint_beast/saintbeasticon.png" )
		ownIcon:setAnchorPoint( cc.p( 0, 0.5 ) )
		ownIcon:setPosition( ownStr:getPositionX() + ownStr:getContentSize().width +2, ownStr:getPositionY() )
		bg:addChild( ownIcon )

		local ownNum = getCommonWhiteBMFontLabel(XTHD.resource.getItemNum(consumeItem))
		ownNum:setAnchorPoint(0.5,0.5)
		ownNum:setPosition(consumeBg:getContentSize().width/2,consumeBg:getContentSize().height/2-5)
		consumeBg:addChild(ownNum)
		self.ownNum = ownNum

		local tipStr = XTHDLabel:createWithParams({
			text = "试练宝石可通过完成日常任务或神器商店购买获得",
			fontSize = 18,
			color = cc.c3b(55,54,112),
			ttf = "res/fonts/def.ttf"
		})
		tipStr:setAnchorPoint(0,0.5)
		tipStr:setPosition(30,consumeBg:getPositionY() - 25)
		bg:addChild(tipStr)

		-- 开始挑战
		local challageBtn = XTHD.createCommonButton({
			btnColor = "write",
			text = LANGUAGE_BTN_KEY.kaishitiaozhan,
			fontSize = 22,
			btnSize = cc.size(130, 60),
		})
		challageBtn:setAnchorPoint(1,0.5)
		challageBtn:setPosition(bg:getBoundingBox().width-20,70)
		bg:addChild(challageBtn)
		challageBtn:setScale(0.7)
		self.challageBtn = challageBtn

		-- 征战
		self.sweepBtn = XTHD.createCommonButton({
			btnColor = "write_1",
			isScrollView = false,
			text = LANGUAGE_BTN_KEY.saodang,
			fontSize = 22,
			btnSize = cc.size(130, 60),
		})
		self.sweepBtn:setScale(0.7)
		self.sweepBtn:setAnchorPoint(1,0.5)
		self.sweepBtn:setPosition(bg:getBoundingBox().width - challageBtn:getBoundingBox().width-40,70)
		bg:addChild(self.sweepBtn)
	end
	
	--初始化
	self:refreshReward((beast-1)*4+1)
	self:createChallage(_type,(beast-1)*4+1,beast)
end

function ShenQiYiZhiModeLayer:refreshReward(id)
	if self.challageBtn then
		self.challageBtn:setTouchEndedCallback(function ()
			XTHDHttp:requestAsyncInGameWithParams({
                modules="chooseServantEctype?",
                params = {ectypeType=id},
                successCallback = function(data)
                if tonumber(data.result) == 0 then
                	local _par = self:getParent()
                	local ShenQiYiZhiChapterLayer = requires("src/fsgl/layer/ShenQiYiZhi/ShenQiYiZhiChapterLayer.lua"):create(data,id,function()
                		_par:refreshData()
                	end)
                	LayerManager.addLayout(ShenQiYiZhiChapterLayer)
                	self.callfunc()
                	self:hide()
                else
                    XTHDTOAST(data.msg)
                end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败！")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
		end)
		self.sweepBtn:setTouchEndedCallback(function()
			if XTHD.resource.getItemNum(self.beastData[1].consume) >= self.beastData[id].consumenum then
				local ShenQiYiZhiSweepLayer = requires("src/fsgl/layer/ShenQiYiZhi/ServantSweepPop.lua"):create({ consume = self.beastData[id].consumenum, own = self.beastData[id].consume, id = id, callback = function ()
					self.ownNum:setString(XTHD.resource.getItemNum(self.beastData[1].consume))
					if self.callfunc then
						self.callfunc()
					end
				end })
	        	LayerManager.addLayout( ShenQiYiZhiSweepLayer, { noHide = true } )
	        	ShenQiYiZhiSweepLayer:show()
        	else
        		XTHDTOAST(LANGUAGE_KEY_SAINTBEASTSWEEP[4])
        	end
		end)
	end
	if self.rewardBg then
		self.rewardBg:removeFromParent()
		self.rewardBg = nil
	end

	self.rewardBg = cc.Sprite:create()
	self.rewardBg:setContentSize(self.bg:getContentSize())
	self.rewardBg:setPosition(self.bg:getBoundingBox().width/2,self.bg:getBoundingBox().height/2)
	self.bg:addChild(self.rewardBg,1)
	
	local nowData = self.beastData[id]
	local rewardList = string.split(nowData.reward,"#")


	for i=1,#rewardList do
		local nowReward = string.split(rewardList[i],"_")
		local itemIcon = ItemNode:createWithParams({
			_type_ = 4,
			itemId = nowReward[1],
			count = nowReward[2]
		})
		itemIcon:setPosition(XTHD.resource.getPosInArr({
			lenth = 5,
			bgWidth = self.rewardBg:getBoundingBox().width,
			num = #rewardList+3,
			nodeWidth = itemIcon:getBoundingBox().width,
			now = i+2,
		}),self.bg:getBoundingBox().height/2-70)
		self.rewardBg:addChild(itemIcon)
	end

	local normalStone = ItemNode:createWithParams({
		_type_ = XTHD.resource.type.servant,
		count = nowData.normalstone
	})
	normalStone:setPosition(XTHD.resource.getPosInArr({
		lenth = 5,
		bgWidth = self.rewardBg:getBoundingBox().width,
		num = #rewardList+3,
		nodeWidth = normalStone:getBoundingBox().width,
		now = #rewardList+3,
	}),self.bg:getBoundingBox().height/2-70)
	self.rewardBg:addChild(normalStone)

	local function addFirstSign(node)
		local firstBg = cc.Sprite:create("res/image/plugin/saint_beast/first_done.png")
		firstBg:setScale(node:getBoundingBox().width/firstBg:getBoundingBox().width)
		firstBg:setAnchorPoint(0,1)
		firstBg:setPosition(-1,node:getBoundingBox().height-3)
		node:addChild(firstBg)
	end

	local _tb = string.split(nowData.firstreward,"_")
	local firstReward = ItemNode:createWithParams({
		_type_ = 4,
		itemId = _tb[1],
		count = _tb[2],
	})
	firstReward:setPosition(XTHD.resource.getPosInArr({
		lenth = 5,
		bgWidth = self.rewardBg:getBoundingBox().width,
		num = #rewardList+3,
		nodeWidth = firstReward:getBoundingBox().width,
		now = 1,
	}),self.bg:getBoundingBox().height/2-70)
	self.rewardBg:addChild(firstReward)
	addFirstSign(firstReward)

	local firstStone = ItemNode:createWithParams({
		_type_ = XTHD.resource.type.servant,
		count = nowData.firststone
	})
	firstStone:setPosition(XTHD.resource.getPosInArr({
		lenth = 5,
		bgWidth = self.rewardBg:getBoundingBox().width,
		num = #rewardList+3,
		nodeWidth = firstStone:getBoundingBox().width,
		now = 2,
	}),self.bg:getBoundingBox().height/2-70)
	self.rewardBg:addChild(firstStone)
	addFirstSign(firstStone)
end

function ShenQiYiZhiModeLayer:createChallage(_type,id,beast)
	if _type == 1 then
		--self.rewardBg
		local lockInfo = cc.Sprite:create("res/image/plugin/saint_beast/lock_str_"..beast..".png")
		lockInfo:setPosition(self.rewardBg:getBoundingBox().width/2,50)
		self.rewardBg:addChild(lockInfo)
	elseif _type == 2 then
		local nowData = self.beastData[id]
		self.cosumeNum:setString(nowData.consumenum)
		--local cosumeNum = getCommonWhiteBMFontLabel(nowData.consumenum)
		--print("SSSSSSSS:" .. nowData.consumenum)
		--cosumeNum:setAnchorPoint(0.5,0.5)
		--cosumeNum:setPosition(self.ownBg:getContentSize().width/2,self.ownBg:getContentSize().height/2-5)
		--self.ownBg:addChild(cosumeNum,1)
	end
end

function ShenQiYiZhiModeLayer:create(data,_type,beast,callfunc)
	return ShenQiYiZhiModeLayer.new(data,_type,beast,callfunc)
end

return ShenQiYiZhiModeLayer