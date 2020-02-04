--[[
	FileName: TianCiShenFuLayer.lua
	Purpose: 天赐神符界面
]]
local TianCiShenFuLayer = class( "TianCiShenFuLayer", function ()
    return cc.Sprite:create()
end)
function TianCiShenFuLayer:ctor(parmas)
	self._parmas = parmas.httpData or {}
	self.parentLayer = parmas.parentLayer
	self:setContentSize(cc.size(640, 428))
	self:initData()
	self:initUI()
	-- 添加监听事件
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_GONGXIFACAI ,callback = function()
        self._zhongjiangInfo = gameUser.getZhongjiangInfo()
--        print_r(self._zhongjiangInfo)
        if self._myTable then
        	if not self._beginSlot then
        		self._myTable:reloadData()
        		self._myTable:scrollToCell(#self._zhongjiangInfo, false)
        	end
        end
    end})
end

--刷新小红点
function TianCiShenFuLayer:freshRedDot(data)
--	local isHave = false
--    if data.cost == 0 then
--        isHave = true
--    end
--    if isHave then
--    	if #self.parentLayer.redDotTable == 1 then
--            self.parentLayer.redDotTable[1]:setVisible(true)
--        else
--            self.parentLayer.redDotTable[2]:setVisible(true)
--    	end
--    else
--    	if #self.parentLayer.redDotTable == 1 then
--            self.parentLayer.redDotTable[1]:setVisible(false)
--        else
--            self.parentLayer.redDotTable[2]:setVisible(false)
--    	end
--	end
end

function TianCiShenFuLayer:initData()
	self._zhongjiangInfo = gameUser.getZhongjiangInfo()
    self:freshRedDot(self._parmas)
	--animation
	self.word_ani = getAnimation( "res/image/activities/newyear/luckyDraw/word/word", 1, 19, 1/38 )
	self.line_ani = getAnimation( "res/image/activities/newyear/luckyDraw/spline/spLine", 1, 10, 1/20 )

	self.word_ani:retain()
	self.line_ani:retain()
end
function TianCiShenFuLayer:initUI()

	self._size = self:getContentSize()
    local titleAd = cc.Sprite:create("res/image/activities/newyear/titlebg.png")
    titleAd:setAnchorPoint(0.5, 1)
	titleAd:setPosition(self._size.width/2 + 27, self._size.height + 1)
	titleAd:setScaleY(1.1)
	titleAd:setScaleX(1)
    self:addChild(titleAd)

	local titleLable = cc.Sprite:create("res/image/activities/newyear/xinyueyaogan.png")
	titleAd:addChild(titleLable)
	--titleLable:setScale(0.8)
	titleLable:setPosition(titleLable:getContentSize().width - 120,titleAd:getContentSize().height *0.5 + 5)


    --data
    local time = XTHDLabel:createWithParams({
    	text = "活动剩余时间："..LANGUAGE_KEY_CARNIVALDAY(self._parmas.close),
    	fontSize = 18,
    	color = cc.c3b(255, 255, 255),
    	anchor = cc.p(0, 0),
		pos = cc.p(5, 0),
		ttf = "res/fonts/def.ttf",
    })
    titleAd:addChild(time)
    self.Time = time
    self:updateTime()
	--StoredValue
	--ly3.26
	--前往充值
    local recharteBtn = XTHD.createButton({
		normalFile = "res/image/activities/hdbtn/btn_buy_up.png",
		selectedFile = "res/image/activities/hdbtn/btn_buy_down.png",
		btnSize = cc.size(130, 46),
    	needSwallow = false,
    	endCallback = function()
    		XTHD.createRechargeVipLayer( self )
    	end,
    	anchor = cc.p(1, 0.5),
    	pos = cc.p(titleAd:getContentSize().width - 10, titleAd:getContentSize().height/2),
	})

	recharteBtn:setScale(0.7)
	-- recharteBtn:getLabel():setPositionX(recharteBtn:getLabel():getPositionX()-15)
	-- recharteBtn:getLabel():setPositionY(recharteBtn:getLabel():getPositionY()-10)
	-- recharteBtn:setScale(0.7)
    titleAd:addChild(recharteBtn)
    
    local slotImg = cc.Sprite:create("res/image/activities/newyear/luckyDraw/slot_bgimg.png")
    slotImg:setAnchorPoint(0.5, 1)
	slotImg:setPosition(self._size.width/2+27, titleAd:getPositionY()-titleAd:getContentSize().height-35)
    self:addChild(slotImg)

    local shuoming = XTHD.createButton({
    	normalFile = "res/image/activities/newyear/luckyDraw/jianglishuoming_up.png",
    	selectedFile = "res/image/activities/newyear/luckyDraw/jianglishuoming_down.png",
    	needSwallow = false,
    	endCallback = function()
			local pop = requires("src/fsgl/layer/HuoDong/luckyDrawPop.lua"):create(self._data)
			LayerManager.addLayout(pop, {noHide = true})
    	end,
    	anchor = cc.p(0.5, 0),
    	pos = cc.p(slotImg:getContentSize().width/2, 5),
    })
    slotImg:addChild(shuoming)
    self._shuoming = shuoming

    --cost
    local myLab = XTHDLabel:createWithParams({
    	text = LANGUAGE_KEY_ONLY_COST.." ",
    	fontSize = 18,
    	color = XTHD.resource.color.white_desc,
    	anchor = cc.p(1, 0),
    	pos = cc.p(slotImg:getContentSize().width-80, 10),
    })
    slotImg:addChild(myLab)
    local labstr = LANGUAGE_KEY_COIN_X(self._parmas.cost)
    local labcolor = cc.c3b(255,252,0)
    if tonumber(self._parmas.cost) == 0 then
    	labstr = LANGUAGE_ADJ.free
    	labcolor = XTHD.resource.color.green_desc
    end
    local cost = XTHDLabel:createWithParams({
    	text = labstr,
    	fontSize = 20,
    	color = labcolor,
    	anchor = cc.p(0, 0),
    	pos = cc.p(myLab:getPositionX(), myLab:getPositionY()-1),
    })
    slotImg:addChild(cost)
    self._costLab = cost

    -- local infoBg = cc.Sprite:create("res/image/activities/newyear/luckyDraw/di2.png")
    local infoBg = ccui.Scale9Sprite:create(cc.rect(400,0, 1, 30), "res/image/activities/newyear/luckyDraw/di2.png")
    infoBg:setContentSize(793, 30)
    infoBg:setAnchorPoint(0.5, 0)
    infoBg:setPosition(self._size.width/2, -10)
    self:addChild(infoBg, 10)
    self._infoBg = infoBg

    local infoBtn = XTHD.createButton({
    	touchSize = cc.size(185,80),
    	endCallback = function()
    		self:showTable(self._isUp)
    		if self._isUp == true then
    			self._normal:setVisible(false)
    			self._selected:setVisible(true)
    			self._isUp = false
    		else
    			self._isUp = true
    			self._normal:setVisible(true)
    			self._selected:setVisible(false)
    		end
    	end,
    	pos = cc.p(self:getContentSize().width-60, infoBg:getPositionY() + 15),
    })
    self._infoBtn = infoBtn
    self:addChild(infoBtn, 12)
    local normal = cc.Sprite:create("res/image/illustration/shangsheng_up.png")
    normal:setAnchorPoint(0.5, 0.5)
    normal:setPosition(0, 0)
    infoBtn:addChild(normal)
    normal:setScale(0.7)
    self._normal = normal
    local selected = cc.Sprite:create("res/image/illustration/sorttype_up.png")
    selected:setAnchorPoint(0.5, 0.5)
    selected:setPosition(0, 0)
    infoBtn:addChild(selected)
    selected:setVisible(false)
    selected:setScale(0.7)
    self._selected = selected
    self._isUp = true
    --tableview
	self:createTableView(cc.size(500, 30), self._infoBg, false)

    local slotNode = cc.Sprite:create()
    slotNode:setContentSize(cc.size(93, 176))
    slotNode:setAnchorPoint(0.5, 0)
    slotNode:setPosition(slotImg:getContentSize().width-40, 140)
    slotImg:addChild(slotNode)

    local slotBtn = XTHD.createButton({
    	normalFile = "res/image/activities/newyear/luckyDraw/slot_up.png",
    	selectedFile = "res/image/activities/newyear/luckyDraw/slot_down.png",
    	needSwallow = false,
    	anchor = cc.p(0.5, 1),
		pos = cc.p(slotNode:getContentSize().width/2, slotNode:getContentSize().height-10), 
		text = "点击\n摇奖",
		ttf = "res/fonts/def.ttf"
	})
	slotBtn:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
    slotNode:addChild(slotBtn,1)
    self._slotBtn = slotBtn

   	local eff = sp.SkeletonAnimation:create("res/image/activities/newyear/luckyDraw/circle/cjzg.json", "res/image/activities/newyear/luckyDraw/circle/cjzg.atlas", 1.0)
    eff:setPosition(slotBtn:getContentSize().width/2, slotBtn:getContentSize().height/2)
   	slotBtn:addChild(eff)
	eff:setAnimation(0, "animation", true)


    local ganzi = cc.Sprite:create("res/image/activities/newyear/luckyDraw/ganzi.png")
    ganzi:setAnchorPoint(0.5, 0)
	ganzi:setPosition(slotNode:getContentSize().width/2, 2)
    slotNode:addChild(ganzi,0)

    --
	--touzi
	-- local testbg = ccui.Scale9Sprite:create(cc.rect(5,5,1,1), "res/image/common/scale9_bg_14.png")
	-- testbg:setContentSize(cc.size(478,140))
	-- testbg:setAnchorPoint(cc.p(0, 0))
	-- testbg:setPosition(cc.p(31.5, 75))
	-- slotImg:addChild(testbg)
	do
		local wordNum = 19
	    local scrollView = ccui.ScrollView:create()
	    scrollView:setContentSize(cc.size(478,140))
		scrollView:setScrollBarEnabled(false)
	    scrollView:setAnchorPoint(0, 0)
	    scrollView:setTouchEnabled(false)
	    scrollView:setBounceEnabled(false)
	    scrollView:setPosition(cc.p(31.5, 75))
	    scrollView:setName("scrollView")
	    slotImg:addChild(scrollView)
	    scrollView:setInnerContainerSize(cc.size(478, 140 * 5 + 10))
	    self._scroll1 = scrollView
	    for i = 1, 4 do
	    	id = i
	    	local slotImgBg1 = XTHD.createSprite("res/image/activities/newyear/luckyDraw/word_" .. id .. ".png")
	    	scrollView:addChild(slotImgBg1)
	    	slotImgBg1:setTag(i)
	    	slotImgBg1:setPosition(478/2, 140/2 + (i-1) * 140)
	    	if i == 3 then
	    		slotImgBg1:setScaleY(1.3)
	    		slotImgBg1:setOpacity(230)
	    	elseif i == 4 then
	    		slotImgBg1:setScaleY(1.5)
	    		slotImgBg1:setOpacity(200)
	    	end
		end
    	local slotImgEnd = XTHD.createSprite("res/image/activities/newyear/luckyDraw/word_1.png")
    	scrollView:addChild(slotImgEnd)
    	slotImgEnd:setPosition(478/2, 140/2 + 4 * 140 + 10)
		performWithDelay(self, function ( )
			local inner = self._scroll1:getInnerContainer()
			inner:setPositionY(0)
			slotImgEnd:removeFromParent()
		end, 0.005)
	end


	slotBtn:setTouchEndedCallback(function()

			local function _doActoin(data)
				local function run2()
					--创建scrollview
					local tar = tonumber(data.configId)
				    self._scroll2 = ccui.ScrollView:create()
				    self._scroll2:setContentSize(cc.size(478,140))
				    self._scroll2:setAnchorPoint(0, 0)
				    self._scroll2:setTouchEnabled(false)
				    self._scroll2:setBounceEnabled(false)
				    self._scroll2:setPosition(cc.p(31.5, 75))
				    self._scroll2:setName("self._scroll2")
				    slotImg:addChild(self._scroll2)
				    self._scroll2:setInnerContainerSize(cc.size(478, 140 * 6))
				    self._scroll2:setVisible(false)
				    local idTa = {}
				    if tar == 1 then
				    	idTa = {[1]=0,[2]=16,[3]=17,[4]=18,[5]=19,[6]=1}
				    elseif tar == 2 then
				    	idTa = {[1]=0,[2]=17,[3]=18,[4]=19,[5]=1,[6]=2}
				    elseif tar == 3 then
				    	idTa = {[1]=0,[2]=18,[3]=19,[4]=1,[5]=2,[6]=3}
				    elseif tar == 4 then
				    	idTa = {[1]=0,[2]=19,[3]=1,[4]=2,[5]=3,[6]=4}
				    else
				    	idTa = {[1]=0,[2]=tar-4,[3]=tar-3,[4]=tar-2,[5]=tar-1,[6]=tar}
				    end
				    for i = 1, 6 do
				    	if idTa[i] ~= 0 then
					    	local slotImgBg1 = XTHD.createSprite("res/image/activities/newyear/luckyDraw/word_" .. idTa[i] .. ".png")
					    	self._scroll2:addChild(slotImgBg1)
					    	slotImgBg1:setTag(i)
					    	slotImgBg1:setPosition(478/2, 140/2 + (i-1) * 140)

					    	if i == 2 then
					    		slotImgBg1:setScaleY(1.5)
					    		slotImgBg1:setOpacity(200)
					    	elseif i == 3 then
					    		slotImgBg1:setScaleY(1.3)
					    		slotImgBg1:setOpacity(230)
					    	end
					    end
					end
					self._scroll2:getInnerContainer():setPositionY(0)
					local sp1 = XTHD.createSprite()
					local sp2 = XTHD.createSprite()
					self:runAction(cc.Sequence:create(
						cc.CallFunc:create(function() 
							sp1:setAnchorPoint(cc.p(0, 0))
							sp1:runAction(cc.RepeatForever:create(self.word_ani))
							sp1:setScale(438/219)
							sp1:setPosition(cc.p(50, 68))
							slotImg:addChild(sp1)
							sp2:setAnchorPoint(cc.p(0, 0))
							sp2:runAction(cc.RepeatForever:create(self.line_ani))
							sp2:setScale(438/219)
							sp2:setPosition(cc.p(sp1:getPositionX(), sp1:getPositionY()))
							slotImg:addChild(sp2)
						end), 
						cc.DelayTime:create(1.0), 
						cc.CallFunc:create(function()

				    		self._scroll2:setVisible(true)
				    		local inner2 = self._scroll2:getInnerContainer()
				    		local length2 = 140 * 5
				    		local totalLen2 = 0 
				    		local dis2 = 0
				    		local times2 = 0.03
	    					local isLast
	    					local already2
				    		local function run3()
				    			if totalLen2 >= length2 then --动作最终结束
				    				self:endAllAction(data)

				    				return 
				    			end
								performWithDelay(self, function()
									totalLen2 = totalLen2+dis2
									if totalLen2 <= 280 then
										dis2 = 80
										times2 = 0.02
									elseif  totalLen2 < 420 then
										dis2 = 30
										times2 = 0.02
									elseif totalLen2 < 560 then
										dis2 = 10
										times2 = 0.03
									elseif totalLen2 < 700 then
										dis2 = 5
										times2 = 0.03
									elseif totalLen2 == length2 then
										totalLen2 = totalLen2 - 10
										dis2 = 5
										times2 = 0.06
										isLast = true
									elseif totalLen2 > length2 then
										dis2 = length2 - totalLen2
										times2 = 0.06
										isLast = false
									end

									if totalLen2 > 80 and not already2 then
										already2 = true
										sp1:stopAllActions()	
										sp2:stopAllActions()	
										sp1:removeFromParent()
										sp2:removeFromParent()
									end

									-- print("dis2 --> ", dis2)
									-- print("totalLen2 ==", totalLen2)
									inner2:setPositionY(inner2:getPositionY()-dis2)
									if isLast then
										dis2 = 15
									end
									run3()
								end,times2)
				    		end

				    		run3()
						end)))
				end
				local inner1 = self._scroll1:getInnerContainer()
				inner1:setPositionY(0)
				self._scroll1:setVisible(true)
			    local length = 140 * 4
	    		local totalLen = 0
	    		local dis = 0
	    		local times = 0.03
	    		local already1
				local function run1()
					if totalLen >= length then
						self._scroll1:setVisible(false)
						return 
					end
					performWithDelay(self, function()
						totalLen = totalLen+dis
						if totalLen <= 280 then
							dis = dis + 10
							if dis >= 35 then
								dis = 35
							end
							times = 0.03
						elseif totalLen < 420 then
							dis = 50
							times = 0.02
						elseif totalLen < 560 then
							dis = 80
							times = 0.02
						end
						if totalLen > 420 and not already1 then
							already1 = true
							run2()	
						end
						inner1:setPositionY(inner1:getPositionY()-dis)
						run1()
					end, times)
				end

		    	slotBtn:runAction(cc.Sequence:create(
		    		cc.MoveBy:create(0.02, cc.p(0, -10)),
		    		cc.MoveBy:create(0.02, cc.p(0, -10)),
		    		cc.MoveBy:create(0.02, cc.p(0, -10)),
		    		cc.MoveBy:create(0.02, cc.p(0, -10)),
		    		cc.MoveBy:create(0.02, cc.p(0, -10)),
		    		cc.MoveBy:create(0.02, cc.p(0, -10)),
		    		cc.MoveBy:create(0.02, cc.p(0, -10)),
		    		cc.CallFunc:create(function() ganzi:setScaleY(0.8) end),
		    		cc.MoveBy:create(0.02, cc.p(0, -10)),
		    		cc.CallFunc:create(function() ganzi:setScaleY(0.7) end),
		    		cc.MoveBy:create(0.02, cc.p(0, -10)),
		    		cc.CallFunc:create(function() ganzi:setScaleY(0.6) end),
		    		cc.MoveBy:create(0.02, cc.p(0, -10)),
		    		cc.CallFunc:create(function() ganzi:setScaleY(0.5) end),
		    		cc.MoveBy:create(0.02, cc.p(0, -10)),
		    		cc.MoveBy:create(0.01, cc.p(0, -10)),
		    		cc.MoveBy:create(0.01, cc.p(0, -10)),
		    		cc.MoveBy:create(0.01, cc.p(0, -10)),
		    		cc.CallFunc:create(function() ganzi:setRotation(180) end),
		    		cc.MoveBy:create(0.01, cc.p(0, -10)),
		    		cc.MoveBy:create(0.01, cc.p(0, -10)),
		    		cc.MoveBy:create(0.01, cc.p(0, -10)),
		    		cc.MoveBy:create(0.01, cc.p(0, -10)),
		    		cc.CallFunc:create(function() run1() end),
		    		cc.DelayTime:create(0.2),

		    		cc.MoveBy:create(0.02, cc.p(0, 20)),
		    		cc.MoveBy:create(0.02, cc.p(0, 20)),
		    		cc.MoveBy:create(0.02, cc.p(0, 20)),
		    		cc.MoveBy:create(0.02, cc.p(0, 20)),
		    		cc.CallFunc:create(function() ganzi:setRotation(0) end),
	    			cc.MoveBy:create(0.02, cc.p(0, 20)),
	    			cc.MoveBy:create(0.02, cc.p(0, 20)),
		    		cc.CallFunc:create(function() ganzi:setScaleY(0.7) end),
		    		cc.MoveBy:create(0.02, cc.p(0, 20)),
		    		cc.CallFunc:create(function() ganzi:setScaleY(0.8) end),
		    		cc.MoveBy:create(0.04, cc.p(0, 20)),
		    		cc.CallFunc:create(function() ganzi:setScaleY(1.0) end),
		    		cc.MoveBy:create(0.05, cc.p(0, 25)),
		    		cc.MoveBy:create(0.03, cc.p(0, -5)),
		    		cc.DelayTime:create(0.05)
	    		))
			end

			self._beginSlot = true
			ClientHttp:requestAsyncInGameWithParams({
			    modules = "receiveChouReward?",      --接口
			    successCallback = function(data)
			        if tonumber(data.result) == 0 then --请求成功
						local _parent = cc.Director:getInstance():getRunningScene()
						self._mask = XTHDPushButton:createWithParams({
							touchSize = cc.size(1300, 1000),
							endCallback = function()
							end,
							pos = cc.p(_parent:getContentSize().width/2, _parent:getContentSize().height/2),
						})
						_parent:addChild(self._mask)
        		    	self._slotBtn:setEnable(false)
				    	self._infoBtn:setEnable(false)

				    	if self._scroll2 then
				    		self._scroll2:removeFromParent()
				    		self._scroll2 = nil
				    	end	
			        	_doActoin(data)
			        	self._saveData = nil
			        	self._saveData = data
			        else
			            self._beginSlot = false
			            XTHDTOAST(data.msg) --出错信息(后端返回)
			        end
			    end,--成功回调
			    loadingParent = self,
			    failedCallback = function()
			    	self._beginSlot = false
			        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
			    end,--失败回调
			    targetNeedsToRetain = self,--需要保存引用的目标
		    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
			})
	end)
  
    --随机种子
    math.randomseed(os.time())
 
end

function TianCiShenFuLayer:updateTime()
    self:stopActionByTag(10)
    schedule(self, function()
        self._parmas.close = self._parmas.close - 1
        local time = "活动剩余时间："..LANGUAGE_KEY_CARNIVALDAY(self._parmas.close)
        self.Time:setString(time)
    end,1,10)
end

function TianCiShenFuLayer:showTable(_type)
	if _type == true then
		self._infoBg:setContentSize(cc.size(793, 150))
		self:createTableView(cc.size(500, 150), self._infoBg, true)
		self._shuoming:setEnable(false)
	else
		self._infoBg:setContentSize(cc.size(793, 30))
		self:createTableView(cc.size(500, 30), self._infoBg, false)
		self._shuoming:setEnable(true)
	end
end
function TianCiShenFuLayer:createTableView(_size, _node, _canTouch)
	if self._tableBg then
		self._tableBg:removeFromParent()
		self._myTable = nil
	end
   	--tableview
    -- local tableSize = cc.size(500, 30)
    local tableSize = _size
    local tableNode = _node
    
    -- local myTableBg = ccui.Scale9Sprite:create(cc.rect(12,12,1,1), "res/image/common/scale9_bg_25.png")
    local myTableBg = XTHD.createSprite()
    myTableBg:setContentSize(tableSize)
    myTableBg:setAnchorPoint(cc.p(0.5, 0))
    myTableBg:setPosition(cc.p(tableNode:getContentSize().width/2, 0))
    tableNode:addChild(myTableBg, 10)
    self._tableBg = myTableBg
    
    local myTable = CCTableView:create(cc.size(myTableBg:getContentSize().width,myTableBg:getContentSize().height))
    TableViewPlug.init(myTable)
    myTable:setPosition(0, 0)
    myTable:setBounceable(false)
    myTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    myTable:setDelegate()
    myTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    myTable:setTouchEnabled(_canTouch)
    myTableBg:addChild(myTable)
    
    local function cellSizeForTable(table,idx)
    	return  tableSize.width,30
    end
    local function numberOfCellsInTableView(table)
        return #self._zhongjiangInfo
    end
    local function tableCellAtIndex(table,idx)
    	local nowIdx = idx + 1
    	local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
            cell:setContentSize(tableSize.width, 30)
        else
        	cell:removeAllChildren()
        end

        self:initCell(cell, nowIdx)
        return cell
    end
    myTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    myTable.getCellNumbers=numberOfCellsInTableView
    myTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    myTable.getCellSize=cellSizeForTable
    myTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
   
    self._myTable = myTable
	if not self._beginSlot then
		self._myTable:reloadData()
		self._myTable:scrollToCell(#self._zhongjiangInfo, false)
	end

end
function TianCiShenFuLayer:initCell(cell, nowIdx)
	local infoData = self._zhongjiangInfo[nowIdx]
	local str1 = infoData.charName..LANGUAGE_TIPS_YAO.." "
	local str2 = LANGUAGE_KEY_GONGXIFACAI(infoData.id)
	local str3 = " "..LANGUAGE_VERBS.get
	local str4 = ""

	local rewardList = {}
	local static = gameData.getDataFromCSV("SlotMachine", {["id"]=infoData.id} )
	if static then
    	local sTa = string.split(static.rewardcanshu1, "#")
		rewardList = {}
		rewardList.rewardtype = static.rewardtype1
		rewardList.num = sTa[2]
    	if tonumber(static.rewardtype1) == 4 then
			rewardList.id = sTa[1]
    	end
		if tonumber(rewardList.rewardtype) ~= 4 then
			str4 = tostring(rewardList.num)..XTHD.resource.name[rewardList.rewardtype]
		else
			str4 = tostring(rewardList.num)..LANGUAGE_UNKNOWN.a..gameData.getDataFromCSV("ArticleInfoSheet", {itemid = rewardList.id}).name
		end
	end
	local function createLab(_str, _color, _fontSize, _anchor)
		local _createLab = XTHDLabel:createWithParams({
			text = _str,
			fontSize = _fontSize,
			color = _color,
			anchor = _anchor,
		})
		return _createLab
	end
	local lab1 = createLab(str1, cc.c3b(255, 255, 255), 18, cc.p(0.5, 0.5))
	local lab2 = createLab(str2, cc.c3b(96, 255, 0), 18, cc.p(0, 0.5))
	local lab3 = createLab(str3, cc.c3b(255, 255, 255), 18, cc.p(0, 0.5))
	local lab4 = createLab(str4, cc.c3b(255, 252, 0), 20, cc.p(0, 0.5))

	cell:addChild(lab1)
	cell:addChild(lab2)
	cell:addChild(lab3)
	cell:addChild(lab4)
	lab1:setPosition(cell:getContentSize().width/2-lab2:getContentSize().width/2-lab3:getContentSize().width/2-lab4:getContentSize().width/2, cell:getContentSize().height/2)
	lab2:setPosition(lab1:getPositionX()+lab1:getContentSize().width/2, lab1:getPositionY())
	lab3:setPosition(lab2:getPositionX()+lab2:getContentSize().width, lab1:getPositionY())
	lab4:setPosition(lab3:getPositionX()+lab3:getContentSize().width, lab1:getPositionY())

end
function TianCiShenFuLayer:endAllAction(data)
	if self._myTable then
		self._myTable:reloadData()
		self._myTable:scrollToCell(#self._zhongjiangInfo, false)
	end
	local posTa = {
		[1] = {
			pos = cc.p(self:getContentSize().width/2+100, self:getContentSize().height/2+100),
			time = 0.3,
		},
		[2] = {
			pos = cc.p(self:getContentSize().width/2-200, self:getContentSize().height/2+70),
			time = 0.1,
		},
		[3] = {pos = cc.p(0, 30),time = 0.2,},
		[4] = {pos = cc.p(-20, 250), time = 0.5},
		[5] = {pos = cc.p(160, 50), time = 0.15},
		[6] = {pos=cc.p(self:getContentSize().width/2, 500),time=0},
		[7] = {pos=cc.p(self:getContentSize().width/2-300, 430),time=0.45},
		[8] = {pos=cc.p(self:getContentSize().width/2+250, 30),time=0.35},
		[9] = {pos=cc.p(self:getContentSize().width/2+300, 92),time=0.1},
	}
	--play
	schedule(self, function()
		local pId = math.random(1,9)
		performWithDelay(self, function()
		    local emitter1 = cc.ParticleSystemQuad:create("res/image/activities/newyear/luckyDraw/lihua.plist") 
		    emitter1:setAutoRemoveOnFinish(true)
		    emitter1:setStartColor(cc.c4f(1.0, 140/255, 15/255, 1.0))
		    emitter1:setStartColorVar(cc.c4f(1.0, 140/255, 15/255, 1.0))
		    emitter1:setEndColor(cc.c4f(40/255, 20/255, 1.0, 1.0))
		    emitter1:setEndColorVar(cc.c4f(40/255, 20/255, 1.0, 1.0))
		    self:addChild(emitter1,11)
		    emitter1:setPositionType(cc.POSITION_TYPE_RELATIVE)
		    emitter1:setPosition(posTa[pId].pos)
		end, posTa[pId].time)
	end, 0.05, 10000)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
    	local show = {}
    	local static = gameData.getDataFromCSV("SlotMachine", {["id"]=data.configId} )
    	local sTa = string.split(static.rewardcanshu1, "#")
		show[1] = {}
		show[1].rewardtype = static.rewardtype1
		show[1].num = sTa[2]
    	if tonumber(static.rewardtype1) == 4 then
			show[1].id = sTa[1]
    	end
    	ShowRewardNode:create(show, nil, function() self:stopActionByTag(10000) end )

    	--保存数据
		self._beginSlot = false
    	self:saveData(data)
		self._mask:removeFromParent()
		self._mask = nil 
		self._slotBtn:setEnable(true)
		self._infoBtn:setEnable(true)
    end)))
    self:freshRedDot(data)
    self._costLab:setString( LANGUAGE_KEY_COIN_X(data.cost) )
    self._costLab:setColor(cc.c3b(255, 252,0))
end

function TianCiShenFuLayer:saveData(data)
	-- 更新属性
	if data.property and #data.property > 0 then
        for i=1, #data.property do
            local pro_data = string.split( data.property[i], ',' )
            DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
        end
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
    end
    -- 更新背包
    if data.bagItems and #data.bagItems ~= 0 then
        for i=1, #data.bagItems do
            local item_data = data.bagItems[i]
            if item_data.count and tonumber( item_data.count ) ~= 0 then
                DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
            else
                DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
            end
        end
    end

end
function TianCiShenFuLayer:create(parmas)
	return self.new(parmas)
end
function TianCiShenFuLayer:onCleanup()
	--
	if self._saveData then
		self:saveData(self._saveData)
	end
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_GONGXIFACAI)
end
function TianCiShenFuLayer:onEnter( ... )
end
function TianCiShenFuLayer:onExit( ... )
end
return TianCiShenFuLayer