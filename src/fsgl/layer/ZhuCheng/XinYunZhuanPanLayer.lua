-- 幸运转盘

XinYunZhuanPanLayer = class("XinYunZhuanPanLayer",function(param)
	return XTHD.createPopLayer()
end)

-- 转盘奖励位置
local TurnItemPos = {
	{x = 356, y = 435},{x = 486, y = 435},{x = 616, y = 435},{x = 743, y = 435},
	{x = 743, y = 324},
	{x = 743, y = 213},{x = 616, y = 213},{x = 486, y = 213},{x = 356, y = 213},
	{x = 356, y = 324}
}

function XinYunZhuanPanLayer:ctor()	
	self._canClick = false
	self._isReciveAll = 10	--是否全部领取完 目前0就全部领取完
	self.curPos = 1			--当前默认的位置
	self.curTurn = 1		--轮数
	self.isQuickAnimEnd = false	--快速旋转是否结束
	self.isTurnAnimEnd  = true --当前转盘动画是否播放完毕
	self.itemSprite = {}	--保存所有转盘背景
	self.targetPos = {}
	self.luckyList = {}
	
	----背景
	local bg = cc.Sprite:create("res/image/activities/luckyturntable/zpbg.png" )
	bg:setAnchorPoint(cc.p(0.5, 0.5))
	local winSize = cc.Director:getInstance():getWinSize()	
	self:setContentSize(cc.size(winSize.width, winSize.height))

    bg:setPosition(cc.p(winSize.width / 2, winSize.height / 2))
    
    -- 左边背景
--    local leftBg = cc.Sprite:create("res/image/activities/luckyturntable/zhuanpanbg1.png")
--    leftBg:setPosition(182, bg:getContentSize().height - leftBg:getContentSize().height / 2 - 80)
--	bg:addChild(leftBg)
--	self.luckyListBg = leftBg

	local scorllRect = ccui.ListView:create()
    scorllRect:setContentSize(cc.size(200, 159))
    scorllRect:setDirection(ccui.ScrollViewDir.vertical)
    scorllRect:setBounceEnabled(true)
	scorllRect:setScrollBarEnabled(false)
    -- scorllRect:setAnchorPoint(1,0)
    bg:addChild(scorllRect)
    scorllRect:setPosition(72,305)
    -- bg:addChild(scorllRect)
    self.scorllRect = scorllRect
	
	-- 我的奖品按钮
	local _normalFile = "res/image/activities/luckyturntable/wdjp_up.png"
	local _selectFile = "res/image/activities/luckyturntable/wdjp_down.png"

	local myRewardBtn = XTHDPushButton:createWithParams({
		normalFile = _normalFile,
		selectedFile = _selectFile,
		endCallback = function ()
			--展示我获得的奖品
            -- if #self.luckyList == 0 then
            --     XTHDTOAST("当前还未获得奖品")
            -- else
            -- 	ShowRewardNode:create(self.luckyList,4)
            -- end
            self:requestMyGift()
		end
	})
	myRewardBtn:setPosition(163, bg:getContentSize().height * 0.4 + 5)
	bg:addChild(myRewardBtn)

	--玩法说明
    local help_btn = XTHDPushButton:createWithParams({
    normalFile        = "res/image/common/btn/tip_up.png",
    selectedFile      = "res/image/common/btn/tip_down.png",
    musicFile = XTHD.resource.music.effect_btn_common,
    endCallback       = function()
        local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=38});
        StoredValue:setAnchorPoint(0.5,0.5)
        local layer = cc.Director:getInstance():getRunningScene()
        StoredValue:setPosition(0,0)
        layer:addChild(StoredValue,5)
    end,
    })
    help_btn:setScale(0.7)
    bg:addChild(help_btn)
    help_btn:setPosition(bg:getContentSize().width/2 - 132,bg:getContentSize().height - 55)

	--vip奖励标题
--	local rewardTitle = XTHDLabel:create("vip等级越高，获得大奖概率越高!", 16)
--	rewardTitle:setColor(cc.c3b(72,14,4))
--	rewardTitle:setPosition(510, 380)
--	bg:addChild(rewardTitle)

	-- 关闭按钮
	local _normalFile = "res/image/ziyuanzhaohui/zyguan_up.png"
	local _selectFile = "res/image/ziyuanzhaohui/zyguan_down.png"

	local _back = XTHDPushButton:createWithParams({
		normalFile = _normalFile,
		selectedFile = _selectFile,
		musicFile = XTHD.resource.music.effect_btn_commonclose,
		endCallback = function ()
            if self.isTurnAnimEnd == false then
                return
            end
			self:hide()
		end
	})
	_back:setPosition(cc.p(bg:getContentSize().width - 30, bg:getContentSize().height - 80))

	bg:addChild(_back)
	self:addContent(bg)
    self.bg = bg
    self.bg:setScaleY(0.9)
	self.bg:setScaleY(0.9)
    --毕业典礼数据
	--self.arenaAwardData = gameData.getDataFromCSV("Arenaluckyturntable")
	self:initTurnUI()
end

-- 获取正确的Pos值
function XinYunZhuanPanLayer:getTargetPos(data, count)
	-- body
	for k,v in pairs(self.data.rewardList) do 
		if not data[count] then return nil end
		if v.configId == data[count].configId then
			print("getTargetPos: "..k)
			return k
		end
	end
	return count
end

function XinYunZhuanPanLayer:requestMyGift()
	XTHDHttp:requestAsyncInGameWithParams({
            modules = "luckyTurnLogList?",
            successCallback = function(data)
                if data.result == 0 then
                    -- print("服务器返回的我的奖品：")
                    -- print_r(data)
                    local showData = self:parseDataToGuideLog(data)
                    -- print("我的奖品展示数据为：")
                    -- print_r(showData)
                    local _logLayer = requires("src/fsgl/layer/BangPai/BangPaiShiJian.lua"):create(showData,2)
            		self:addChild(_logLayer, 1)
                end
            end,
            failedCallback = function()
                XTHDTOAST(LANGUAGE_KEY_WEIHUZHONG)
            end,--失败回调
            loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
        })
end

function XinYunZhuanPanLayer:parseDataToGuideLog(data)
	local show = {list = {}}
	for i=1,#data.luckLog do
		-- local diffTime = os.date("%Y-%m-%d %H:%M:%S", data.luckLog[i].time/1000)
		local diffTime = data.luckLog[i].time/1000
		local content
		if data.luckLog[i].type == 207 then
             content = "您获得了韬略x"..data.luckLog[i].count
        else
             local static = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = data.luckLog[i].id})  --通过物品id返回物品名称
             content = "您获得了"..static.name.."x"..data.luckLog[i].count
		end
		local d = {diffTime = diffTime,content = content}
		table.insert(show.list,d)
	end
	return show
end

-- 初始化转盘UI
function XinYunZhuanPanLayer:initTurnUI( ... )
	for k,v in pairs(TurnItemPos) do
		local itemSprite = cc.Sprite:create("res/image/activities/luckyturntable/zhuanpanbg1.png")
		itemSprite:setScaleY(0.55)
		itemSprite:setScaleX(0.5)
		self.bg:addChild(itemSprite)
		itemSprite:setPosition(v.x - 5, v.y + 1)
	end

	--显示奖品
	-- print("幸运转盘的数据为：")
	-- print_r(self.data)
	for k,v in pairs(self.data.rewardList) do 
		local rewardIcon = ItemNode:createWithParams({
			_type_ = v.type,
			itemId = v.id,
			count = v.count,
		})
		rewardIcon:setScale(0.75)
		local pos = TurnItemPos[k]
		rewardIcon:setPosition(pos.x - 5, pos.y)
		self.bg:addChild(rewardIcon, 2)
	end

	-- 默认选中的背景
	local selectSprite = cc.Sprite:create("res/image/activities/luckyturntable/zhuanpanbg3.png")
	selectSprite:setPosition(TurnItemPos[1].x - 5, TurnItemPos[1].y)
	selectSprite:setScale(1.1)
	self.bg:addChild(selectSprite, 1)
	self.selectSprite = selectSprite

	-- 抽一次
	local normalFile = cc.Sprite:create("res/image/activities/luckyturntable/zhuan1_up.png")
	local selectFile = cc.Sprite:create("res/image/activities/luckyturntable/zhuan1_down.png")

	local oneGetBtn = XTHDPushButton:createWithParams({
		normalNode = normalFile,
		selectedNode = selectFile,
		endCallback = function ()
			if not self.isTurnAnimEnd then return end				
			self.isTurnAnimEnd = false
			ClientHttp:requestAsyncInGameWithParams({
				modules="luckyTurnRequest?",
				params={sum=1,type=XTHD.resource.getItemNum(2323) >= 1 and "item" or "gold"},
                successCallback = function(data)
	    --             print("抽1次服务器返回的数据为：")
					-- print_r(data)
					if tonumber(data.result) == 0 then
						self.rewardList = data
						self.isQuickAnimEnd = false
						local targetPos = self:getTargetPos(data.resultList, 1)
						table.insert( self.targetPos, targetPos)
	                    self:playOneAnim(0.15, targetPos)
	                else
	                	XTHDTOAST(data.msg)
	                	self.isTurnAnimEnd = true
	                end
                end,
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                    self.isTurnAnimEnd = true
                end,--失败回调
                targetNeedsToRetain = self,             --需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE, --加载图显示 circle 光圈加载 head 头像加载
                loadingParent = self,
            })	
		end
	})
	oneGetBtn:setPosition(415, self.bg:getContentSize().height * 0.2 + 5)
	self.bg:addChild(oneGetBtn)

	--抽奖一次花费元宝背景
	local OneBg = cc.Sprite:create("res/image/activities/luckyturntable/lunpan_10.png")
	self.bg:addChild(OneBg)
	OneBg:setPosition(cc.p(413,self.bg:getContentSize().height * 0.2 - 45))
	self._OneBg = OneBg

	-- 抽五次
	normalFile = cc.Sprite:create("res/image/activities/luckyturntable/zhuan10_up.png")
	selectFile = cc.Sprite:create("res/image/activities/luckyturntable/zhuan10_down.png")

	local tenGetBtn = XTHDPushButton:createWithParams({
		normalNode = normalFile,
		selectedNode = selectFile,
		endCallback = function ()
			if self.isTurnAnimEnd == false then return end
			self.isTurnAnimEnd = false
			ClientHttp:requestAsyncInGameWithParams({
				modules="luckyTurnRequest?",
				params={sum=5,type=XTHD.resource.getItemNum(2323) >= 4 and "item" or "gold"},
                successCallback = function(data)
	    --             print("抽5次服务器返回的数据为：")
					-- print_r(data)
					if tonumber(data.result) == 0 then
						self.rewardList = data
						self.isQuickAnimEnd = false
						local targetPos = self:getTargetPos(data.resultList, 5)
						table.insert( self.targetPos, targetPos)
                        self:playOneAnim(0.15, targetPos)
                    else
                    	XTHDTOAST(data.msg)
                    	self.isTurnAnimEnd = true
                    end
                end,
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                    self.isTurnAnimEnd = true
                end,--失败回调
                targetNeedsToRetain = self,             --需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE, --加载图显示 circle 光圈加载 head 头像加载
                loadingParent = self,
            })	
		end
	})
	tenGetBtn:setPosition(675, self.bg:getContentSize().height * 0.2 + 5)
	self.bg:addChild(tenGetBtn)
	local sell = cc.Sprite:create("res/image/store/store_discount8.png")
	sell:setRotation(90)
	sell:setScale(0.6)
	self.bg:addChild(sell)
	sell:setPosition(tenGetBtn:getPositionX() + 51,tenGetBtn:getPositionY() + 12)
	
	--抽奖五次花费元宝背景
	local Fivebg = cc.Sprite:create("res/image/activities/luckyturntable/lunpan_10.png")
	self.bg:addChild(Fivebg)
	Fivebg:setPosition(cc.p(673,self.bg:getContentSize().height * 0.2 - 45))
	self._Fivebg = Fivebg

	for i = 1, 2 do
		--local goldSprite = cc.Sprite:create("res/image/common/common_gold.png")
		local goldNum = XTHDLabel:create("100", 20)
		goldNum:setAnchorPoint(0, 0.5)
		--self.bg:addChild(goldSprite)
		--self.bg:addChild(goldNum)
		if i == 1 then
			--goldSprite:setPosition(430, self.bg:getContentSize().height * 0.41)
			if XTHD.resource.getItemNum(2323) < 1 then
				goldNum:setString(200)	
				self._OneBg:initWithFile("res/image/activities/luckyturntable/lunpan_10.png")
				goldNum:setPosition(self._OneBg:getContentSize().width / 2 - 10,self._OneBg:getContentSize().height / 2)
			else
				goldNum:setAnchorPoint(0.5, 0.5)
				goldNum:setString(1 .. "/" .. XTHD.resource.getItemNum(2323))	
				self._OneBg:initWithFile("res/image/activities/luckyturntable/lunpan_101.png")
				goldNum:setPosition(self._OneBg:getContentSize().width / 2 + 15,self._OneBg:getContentSize().height / 2)
			end
			goldNum:setName("Num")
			self._OneBg:addChild(goldNum)
		elseif i == 2 then
			--goldSprite:setPosition(530, self.bg:getContentSize().height * 0.41)
			if XTHD.resource.getItemNum(2323) < 4 then	
				goldNum:setString(800)
				self._Fivebg:initWithFile("res/image/activities/luckyturntable/lunpan_10.png")
				goldNum:setPosition(self._Fivebg:getContentSize().width / 2 - 10,self._Fivebg:getContentSize().height / 2)
			else
				goldNum:setAnchorPoint(0.5, 0.5)
				goldNum:setString(4 .. "/" .. XTHD.resource.getItemNum(2323))	
				self._Fivebg:initWithFile("res/image/activities/luckyturntable/lunpan_101.png")
				goldNum:setPosition(self._Fivebg:getContentSize().width / 2 + 15 ,self._Fivebg:getContentSize().height / 2)
			end
			goldNum:setName("Num")
			self._Fivebg:addChild(goldNum)
		end
		goldNum:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1))
	end

	-- 活动时间剩余
	local timeStr = "活动时间："..LANGUAGE_TOTALRECHARGE_DAYS( self._openTime.beginMonth, self._openTime.beginDay, self._openTime.endMonth, self._openTime.endDay )
	local activityLabelTime = XTHDLabel:create(timeStr,13,"res/fonts/def.ttf")
	activityLabelTime:setPosition(162, 294)
	activityLabelTime:setColor(cc.c3b(255,255,255))
	self.bg:addChild(activityLabelTime)
	self._activityTime = activityLabelTime
	self:ShowLuckyList()

	--刷新幸运榜
	schedule( self, function()
        self:ShowLuckyList()
    end, 10, 258 )
	--倒计时
	-- schedule( self, function()
 --        self:timer()
 --    end, 1.0, 258 )
end

function XinYunZhuanPanLayer:timer(_time)
	-- 赋值
    self.data.endTime = _time or self.data.endTime or 0
    -- 减1
    self.data.endTime = self.data.endTime - 1
    -- 边界
    self.data.endTime = self.data.endTime > 0 and self.data.endTime or 0
    self._activityTime:setString( LANGUAGE_ACTIVITY_LEFTTIME( self.data.endTime ) )
end

function XinYunZhuanPanLayer:playOneAnim(speedTime, targetPos)
	print("speedTIme:" .. speedTime .. " targetPos: " .. targetPos)
	self.selectSprite:runAction(
		cc.RepeatForever:create(
			cc.Sequence:create(
				cc.CallFunc:create(
					function(...)
						self._isHide = true
						self.curPos = self.curPos + 1
						if self.curPos > 10 then
							self.curPos = 1
							self.curTurn = self.curTurn + 1
						end
						self.selectSprite:runAction(cc.Sequence:create(
						cc.MoveTo:create(speedTime - 0.1, cc.p(TurnItemPos[self.curPos].x - 5, TurnItemPos[self.curPos].y)),
						cc.CallFunc:create(
						function(...)
							print("self.curTurn.." .. self.curTurn .. " " .. tostring(self.isQuickAnimEnd))
							if self.curPos == 5 and self.curTurn == 1 then
								-- 说明开始已经起步并且转完了
								self.selectSprite:stopAllActions()
								self:playOneAnim(0.1, 4)
								return
							end

							if self.curTurn > 3 and self.isQuickAnimEnd == false then
								-- 表示转了3轮

								self.isQuickAnimEnd = true

								self.selectSprite:stopAllActions()
								targetPos = self.targetPos[1]
								table.remove(self.targetPos, 1)
								print("targetPos: " .. targetPos .. "num: " .. #self.targetPos)
								if self.curPos ~= targetPos then
									self:playOneAnim(0.15, targetPos)
								else
									-- 当前一圈正好转到这个位置
									self.selectSprite:stopAllActions()
									self.curTurn = 1
									self.curPos = 1
									self.isTurnAnimEnd = true
									self:showReward()
								end
							else
								if self.curTurn > 3 and self.isQuickAnimEnd == true and self.curPos == targetPos then
									self.selectSprite:stopAllActions()
									self.curTurn = 1
									self.curPos = 1
									self.selectSprite:runAction(
									cc.Sequence:create(
									cc.CallFunc:create( function()
										print("targetPosNum: " .. #self.targetPos)
										if #self.targetPos <= 0 then
											--  整体转完了显示奖励
											self:showReward()
											self.isTurnAnimEnd = true
										end
									end ),
									cc.DelayTime:create(1),
									cc.CallFunc:create(
									function()
										self.selectSprite:setPosition(cc.p(TurnItemPos[self.curPos].x - 5, TurnItemPos[self.curPos].y))
										self._isHide = false
										if #self.targetPos > 0 then
											print("targetPos: " .. targetPos .. "num: " .. #self.targetPos)
											self.isQuickAnimEnd = false
											self:playOneAnim(0.15, targetPos)
										else
											self.isTurnAnimEnd = true
										end
									end
									)
									)
									)
								end
							end
						end
						)
						)
						)
					end
				),
				cc.DelayTime:create(speedTime)
			)
		)
	)
end

function XinYunZhuanPanLayer:showReward()
	if self.rewardList then
		local data = self.rewardList
		local show = {} --奖励展示
		--货币类型
		if data.property and #data.property > 0 then
			for i=1,#data.property do
				local pro_data = string.split( data.property[i],',')
				--如果奖励类型存在，而且不是vip升级(406)则加入奖励
				print(XTHD.resource.propertyToType[tonumber(pro_data[1])])
				if tonumber(pro_data[1]) ~= 406 and XTHD.resource.propertyToType[tonumber(pro_data[1])] then
					local getNum = tonumber(pro_data[2]) - tonumber(gameUser.getDataById(pro_data[1]))
					if getNum > 0 then
						local idx = #show + 1
						show[idx] = {}
						show[idx].rewardtype = XTHD.resource.propertyToType[tonumber(pro_data[1])]
						show[idx].num = getNum
						if tonumber(pro_data[1]) == 459 then
                            show[idx].name = "韬略"
						end
					end
				end
				DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
			end
			gameUser.setIngot(self.rewardList.ingot)
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 		--刷新数据信息
		end

		--消耗类型
		if data.costItem and #data.costItem ~= 0 then
			for i=1,#data.costItem do
				local item_data = data.costItem[i]
				local showCount = item_data.count
				if item_data.count and tonumber(item_data.count) ~= 0 then
					--print("itemCount: "..DBTableItem.getCountByID(item_data.dbId))
					showCount = item_data.count - tonumber(DBTableItem.getCountByID(item_data.dbId))
					DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
				else
					DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
				end
			end
		end

		--物品类型
		if data.bagItems and #data.bagItems ~= 0 then
			for i=1,#data.bagItems do
				local item_data = data.bagItems[i]
				local showCount = item_data.count
				if item_data.count and tonumber(item_data.count) ~= 0 then
					--print("itemCount: "..DBTableItem.getCountByID(item_data.dbId))
					showCount = item_data.count - tonumber(DBTableItem.getCountByID(item_data.dbId))
					DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
				else
					DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
				end
				--如果奖励类型
				if showCount > 0 then
					local idx = #show + 1
					show[idx] = {}
					show[idx].rewardtype = 4 -- item_data.item_type
					show[idx].id = item_data.itemId
					show[idx].num = showCount
					show[idx].name = item_data.name
			    end
			end
		end
		for i = 1,#show do
            table.insert(self.luckyList,show[i])
		end
		--显示领取奖励成功界面
		ShowRewardNode:create(show)
		self:freshBtnState()
		--展示幸运榜
        -- self:ShowLuckyList()
		self.rewardList = nil
	end
end

function XinYunZhuanPanLayer:freshBtnState()
	if XTHD.resource.getItemNum(2323) < 1 then
		self._OneBg:getChildByName("Num"):setString(200)	
		self._OneBg:initWithFile("res/image/activities/luckyturntable/lunpan_10.png")
		self._OneBg:getChildByName("Num"):setPosition(self._OneBg:getContentSize().width / 2 - 10,self._OneBg:getContentSize().height / 2)
	else
		self._OneBg:getChildByName("Num"):setString(1 .. "/" ..  XTHD.resource.getItemNum(2323))	
		self._OneBg:initWithFile("res/image/activities/luckyturntable/lunpan_101.png")
		self._OneBg:getChildByName("Num"):setPosition(self._OneBg:getContentSize().width / 2 + 8 ,self._OneBg:getContentSize().height / 2)
	end
	if XTHD.resource.getItemNum(2323) < 4 then
		self._Fivebg:getChildByName("Num"):setString(800)	
		self._Fivebg:initWithFile("res/image/activities/luckyturntable/lunpan_10.png")
		self._Fivebg:getChildByName("Num"):setPosition(self._Fivebg:getContentSize().width / 2 - 10,self._Fivebg:getContentSize().height / 2)
	else
		self._Fivebg:getChildByName("Num"):setString(4 .. "/" ..  XTHD.resource.getItemNum(2323))	
		self._Fivebg:initWithFile("res/image/activities/luckyturntable/lunpan_101.png")
		self._Fivebg:getChildByName("Num"):setPosition(self._Fivebg:getContentSize().width / 2 + 8 ,self._Fivebg:getContentSize().height / 2)
	end
end

function XinYunZhuanPanLayer:ShowLuckyList()
    --self.luckyList是自己抽到的奖励数据，gameUser.getLuckyListData()是服务器返回的幸运榜
	-- print("幸运榜数据为：")
	-- print_r(gameUser.getLuckyListData())
	if #gameUser.getLuckyListData() < 1 then
        return
	end
    self.scorllRect:removeAllChildren()
    local iconWidth = 140
    for i, v in ipairs( gameUser.getLuckyListData() ) do
    	local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(iconWidth,self.scorllRect:getContentSize().height/7))
		local str = "<color fontSize=9>恭喜</color><color=#F1E900 fontSize=12>"..v.playerName.."</color><color fontSize=9>获得</color><color=#06d5f4 fontSize=12>"..v.name.."</color><color fontSize=9>x"..v.num.."</color>"
		local rewardTitle = RichLabel:createARichText(str,true)  --RichLabel:createARichText(str,false)创建富文本
		-- local rewardTitle = XTHDLabel:createWithSystemFont(str,"Helvetica",15)
		layout:addChild(rewardTitle)
		rewardTitle:setPosition(0,25)
		-- rewardTitle:setDimensions(layout:getContentSize().width - 2,layout:getContentSize().height)
		-- rewardTitle:setLineBreakWithoutSpace(true)  --设置自动换行
		self.scorllRect:pushBackCustomItem(layout)
	end
end

function XinYunZhuanPanLayer:create(data)
	-- print("幸运转盘服务器返回的数据为：")
	-- print_r(data)
	self.data = data
	self._openTime = {
		beginMonth = data.beginMonth or "",
		beginDay = data.beginDay or "",
		endMonth = data.endMonth or "",
		endDay = data.endDay or "",
	}
	--处理幸运榜数据
	local tempData = {}
	for i = 1,#data.rewardLog do
        local temp = {}
        local static = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = data.rewardLog[i].itemId})
		local playerName = data.rewardLog[i].name == gameUser.getNickname() and "您" or data.rewardLog[i].name
        temp.playerName = playerName
        temp.name = static.name
        temp.num = 1
        table.insert(tempData,temp)
	end
	gameUser.setLuckyListData(tempData)
	local XinYunZhuanPanLayer = XinYunZhuanPanLayer.new()
	if XinYunZhuanPanLayer then 
		XinYunZhuanPanLayer:init()
		XinYunZhuanPanLayer:registerScriptHandler(function(event )
			if event == "enter" then 
				XinYunZhuanPanLayer:onEnter()
			elseif event == "exit" then 
				XinYunZhuanPanLayer:onExit()
			end 
		end)	
    end
	return XinYunZhuanPanLayer
end

function XinYunZhuanPanLayer:init( )	
	self._canClick = true	
end

function XinYunZhuanPanLayer:onEnter( )
    local function TOUCH_EVENT_BEGAN( touch,event )
    	return true
    end

    local function TOUCH_EVENT_MOVED( touch,event )
    	-- body
    end

    local function TOUCH_EVENT_ENDED( touch,event )
    	if self._canClick == false then
    		return
    	end
    	local pos = touch:getLocation()
    	local rect = self.bg:getBoundingBox()
    	if cc.rectContainsPoint(rect,pos) == false then
    		self._canClick = false
            if self.isTurnAnimEnd == false then
                return
            end
    		self:removeFromParent()
    	end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(TOUCH_EVENT_BEGAN,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(TOUCH_EVENT_MOVED,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(TOUCH_EVENT_ENDED,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
end

function XinYunZhuanPanLayer:onExit( ) 
	self:stopActionByTag(258)
end

return XinYunZhuanPanLayer


