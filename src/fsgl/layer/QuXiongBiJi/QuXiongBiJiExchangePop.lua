-- FileName: QuXiongBiJiExchangePop.lua
-- Author: andong
-- Date: 2015-12-3
-- Purpose: 弄宝兑换奖励界面
--[[TODO List]]

local QuXiongBiJiExchangePop = class("QuXiongBiJiExchangePop", function()
    return XTHDPopLayer:create({isRemoveLayout = true})
end)

function QuXiongBiJiExchangePop:onCleanup()
end

function QuXiongBiJiExchangePop:ctor(data)

	self:initData(data)
	self:sortData()
	self:initUI()
	self:show()
end

function QuXiongBiJiExchangePop:initData(data)
	self._initData = data
	self._staticReward = gameData.getDataFromCSV("QujibixiongReward")
	for i = 1, #self._staticReward do
		self._staticReward[i].info = {}
		self._staticReward[i].info._type_ = self._staticReward[i].typeA
		self._staticReward[i].info.itemId = self._staticReward[i].typeID
		self._staticReward[i].info.count = self._staticReward[i].num

		if tonumber(self._staticReward[i].id) == tonumber(self._initData.list[i].configId) then
			self._staticReward[i].surplusCount = self._initData.list[i].surplusCount
		end
	end
end

function QuXiongBiJiExchangePop:sortData()
	table.sort(self._staticReward, function(a, b)
		if tonumber(a.surplusCount) > tonumber(b.surplusCount) then
			return true
		elseif  tonumber(a.surplusCount) == tonumber(b.surplusCount) then
			return tonumber(a.id) < tonumber(b.id)
		end
	end)
end

function QuXiongBiJiExchangePop:initUI()

	local winSize = self:getContentSize()
	local popSize = cc.size(520,440)
	local popNode = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	popNode:setContentSize(popSize)
	popNode:setPosition(winSize.width/2,winSize.height/2)
	self:addContent(popNode)

	local titleBg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277,50))
	popNode:addChild(titleBg)
	titleBg:setPosition(popSize.width/2, popSize.height-5)
	local title = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_SEEKTREASURE_TIP3, "Helvetica",26)
	title:setColor(cc.c3b(104, 33, 11))
	title:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2+5)
	titleBg:addChild(title)


	local myPoints = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_SEEKTREASURE_TIP4..": "..self._initData.points, "Helvetica",23)
	myPoints:setColor(cc.c3b(54,55,112))
	myPoints:setAnchorPoint(0,1)
	myPoints:setPosition(30,popNode:getContentSize().height - 35)
	popNode:addChild(myPoints)
	self._myPoints = myPoints

	local tip = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_SEEKTREASURE_TIP7,"Helvetica",21)
	popNode:addChild(tip)
	tip:setAnchorPoint(1,1)
	tip:setColor(cc.c3b(54,55,112))
	tip:setPosition(popSize.width-100, myPoints:getPositionY())

	self._tableSize = cc.size(500-8,340-8)

	-- tableView背景
    local exchangeBg = ccui.Scale9Sprite:create( "res/image/common/scale9_bg2_25.png" )
    exchangeBg:setContentSize( self._tableSize.width, self._tableSize.height + 8 )
    exchangeBg:setAnchorPoint( cc.p( 0.5, 0 ) )
    exchangeBg:setPosition( popNode:getContentSize().width*0.5, 30 )
    popNode:addChild( exchangeBg )

	local exChangeView = CCTableView:create(cc.size(self._tableSize.width + 8, self._tableSize.height -20))
	exChangeView:setPosition((popSize.width-self._tableSize.width)/2,45)
	exChangeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置纵向
	exChangeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) --设置单元格在表格中的填充顺序(从上到下)
	exChangeView:setDelegate()
	popNode:addChild(exChangeView)


	--方法
	local function numberOfCellsInTableView(table)
	    return #self._staticReward
	end
	local function cellSizeForTable(table, idx)
	    return self._tableSize.width,114
	end
	local function tableCellAtIndex(table, idx)
	    local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new();
            cell:setContentSize( table:getContentSize().width, 114 )
        else
            cell:removeAllChildren()
        end
        return self:initCell(cell,idx+1)
	end
	exChangeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW) --数量
	exChangeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX) --大小
	exChangeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX) --创建item
	exChangeView:reloadData()

	self._exChangeView = exChangeView

end

function QuXiongBiJiExchangePop:initCell(cell,idx)

	local cellSize = cc.size(self._tableSize.width,110)
	local cellData = self._staticReward[idx]

	local di = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
	di:setContentSize(cc.size(cellSize.width-15,cellSize.height-2))
	cell:addChild(di)
	di:setPosition(cellSize.width/2, cellSize.height/2+3)

	-- 分隔线
    -- local splitCellLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
    -- splitCellLine:setContentSize( cellSize.width, 2 )
    -- splitCellLine:setAnchorPoint( cc.p( 0.5, 0 ) )
    -- splitCellLine:setPosition( cellSize.width*0.5, -4 )
    -- di:addChild( splitCellLine )

	local item = ItemNode:createWithParams({
		_type_ = self._staticReward[idx].typeA,
		count = self._staticReward[idx].num,
		itemId = self._staticReward[idx].typeID,
	})
	item:setScale(0.7)
	item:setAnchorPoint(0,0.5)
	di:addChild(item)
	item:setPosition(220, cellSize.height/2)


	local tipLab = XTHDLabel:createWithSystemFont(LANGUAGE_SEEKTREASURE_GETREWARD(cellData.cost), "Helvetica", 20)
	tipLab:setAnchorPoint(0,0.5)
	tipLab:setColor(cc.c3b(54,55,112))
	tipLab:setPosition(10,cellSize.height/2)
	di:addChild(tipLab)

	if tonumber(cellData.surplusCount) > 0 then
		local font_file
		local _btnColor
		local flag
		local isVisible = false
		if tonumber(self._initData.points) >= tonumber(self._staticReward[idx].cost) then	
	        font_file = LANGUAGE_BTN_KEY.getReward
	        _btnColor = "write_1"
	        flag = true
			isVisible = true
	    else
	        font_file = LANGUAGE_BTN_KEY.noAchieve
	        _btnColor = "write"
	        flag = false
	    end

	    local cliam_btn = XTHD.createCommonButton({
	    		btnColor = _btnColor,
				btnSize = cc.size(135,46),
				isScrollView = true,
	    		text = font_file,
	            needSwallow  = false,
	    		endCallback = function()
	            	self:callHttp(idx, flag)
	            end,
			})
			cliam_btn:setScale(0.8)
        cliam_btn:setAnchorPoint(1,0.5)
        di:addChild(cliam_btn)
	    cliam_btn:setPosition(cellSize.width-30,cellSize.height/2)

		local fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		cliam_btn:addChild( fetchSpine )
		fetchSpine:setPosition( cliam_btn:getBoundingBox().width*0.5+22, cliam_btn:getContentSize().height/2+20-17 )
		fetchSpine:setAnimation( 0, "querenjinjie", true )
		fetchSpine:setVisible(isVisible)
	else
        local already_sp = cc.Sprite:create("res/image/vip/yilingqu.png")
		already_sp:setAnchorPoint(1,0.5)
		already_sp:setScale(0.7)
        already_sp:setPosition(cellSize.width-45,cellSize.height/2)
        di:addChild(already_sp)

	end
	return cell
end

function QuXiongBiJiExchangePop:callHttp(idx,canReceive)

	if canReceive then
	    ClientHttp:requestAsyncInGameWithParams({
	        modules = "liemingExchange?",
	        params = {configId = self._staticReward[idx].id},
	        successCallback = function(data)
		        -- dump(data, "call data === ")
	            if data.result == 0 then
	               	-- bagItems  背包 
	                if data.bagItems then
	                    for i=1,#data.bagItems do
	                       DBTableItem.updateCount(gameUser.getUserId(),data.bagItems[i], data.bagItems[i]["dbId"])
	                    end
	                end
	                self._staticReward[idx].surplusCount = 0
		        	self:showReward(idx)
		        	self:sortData()
		        	self._exChangeView:reloadData()
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
	else
		XTHDTOAST(LANGUAGE_ADJ.unreachable)
	end
	-- self:showReward(id)
end

function QuXiongBiJiExchangePop:showReward(id)

	local show = {}
	show.rewardtype = self._staticReward[id].typeA
	show.num = self._staticReward[id].num
	show.id = self._staticReward[id].typeID

	ShowRewardNode:create({show})
end

function QuXiongBiJiExchangePop:onEnter( ... )
end

function QuXiongBiJiExchangePop:onExit( ... )
end

function QuXiongBiJiExchangePop:create(data)
	return QuXiongBiJiExchangePop.new(data)
end

return QuXiongBiJiExchangePop