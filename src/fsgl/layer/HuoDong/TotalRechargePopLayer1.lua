local TotalRechargePopLayer1 = class("TotalRechargePopLayer1",function()
	return XTHDPopLayer:create()
end)

function TotalRechargePopLayer1:ctor(_data,_finishNum,_callBack)
	self.rewardData = _data
    self:sortData()
	self.finishNum = _finishNum
	self.callBack = _callBack
	self:initLayer()
end
function TotalRechargePopLayer1:onCleanup()
	if self.callBack then
		self.callBack( self.rewardData )
	end
end
function TotalRechargePopLayer1:initLayer()
	local popNode  = ccui.Scale9Sprite:create("res/image/activities/logindaily/scale9_bg_26.png" )
 	popNode:setContentSize(cc.size(493,420))
 	popNode:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
 	self:addContent(popNode)

 	local _titleBgSp = ccui.Scale9Sprite:create("res/image/activities/dailyRecharge/common_title_barBg.png")
 	_titleBgSp:setContentSize(cc.size(popNode:getContentSize().width-7*2,44))
 	_titleBgSp:setAnchorPoint(cc.p(0.5,1))
 	_titleBgSp:setPosition(cc.p(popNode:getContentSize().width/2,popNode:getContentSize().height - 7))
 	popNode:addChild(_titleBgSp)

 	local _titleSp = cc.Sprite:create("res/image/activities/logindaily/logindaily_totalrewardTitle.png")         --------------------累计奖励
 	_titleSp:setPosition(cc.p(_titleBgSp:getContentSize().width/2,_titleBgSp:getContentSize().height/2))
 	_titleBgSp:addChild(_titleSp)

 	local _closeBtn = XTHD.createBtnClose(function()
        self:hide()
    end)
    _closeBtn:setAnchorPoint(cc.p(0.5,0.5))
    _closeBtn:setPosition(cc.p(popNode:getContentSize().width-5,popNode:getContentSize().height-5))
    popNode:addChild(_closeBtn)

    local tableView = CCTableView:create( cc.size( popNode:getContentSize().width - 15, popNode:getContentSize().height - _titleBgSp:getContentSize().height - 15 ) )
	tableView:setPosition( 8, 7 )
	tableView:setBounceable( true )
	tableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	tableView:setDelegate()
	tableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	popNode:addChild( tableView )
	self._tableView = tableView
	local function numberOfCellsInTableView( table )
		return #self.rewardData
	end
	local function cellSizeForTable( table, index )
		return 480,110
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
			cell:setContentSize(cc.size(480,110))
        end

        cell:addChild( self:initRewardItem( index + 1 ) )

    	return cell
    end
	tableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    tableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    tableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    tableView:reloadData()

    self:show()
end

function TotalRechargePopLayer1:initRewardItem(_idx)
	-- 数据
	local _rewardData = self.rewardData[tonumber(_idx)]
	-- 背景
	local _rewardItemBg = ccui.Scale9Sprite:create("res/image/activities/dailyRecharge/common_title_barBg.png")
	_rewardItemBg:setContentSize(cc.size(480,105))
	_rewardItemBg:setPosition( _rewardItemBg:getContentSize().width*0.5, _rewardItemBg:getContentSize().height*0.5 )
	-- 标题
    local _descLabel = XTHDLabel:create(_rewardData.tips,20)
    _descLabel:setColor(cc.c4b(240,200,11,255))
    _descLabel:setAnchorPoint(cc.p(0,0.5))
    _descLabel:setPosition(cc.p(20,_rewardItemBg:getContentSize().height - 18))
    _rewardItemBg:addChild(_descLabel)
    -- 图标
    local expList = gameData.getDataFromCSV( "GeneralExpList", {level = gameUser.getLevel()} ) or {}
    local expNum = tonumber( expList.lordexperience or 0 )
	local iconData = {}
	local i = 1
    while _rewardData["rewardtype"..i] do
		local tmp = string.split( _rewardData["canshu"..i], "#" )
		if #tmp > 1 then
			if tonumber( _rewardData["rewardtype"..i] ) == XTHD.resource.type.exp then
				-- 经验
				local tmpData = {
					rewardtype = XTHD.resource.type.exp,
		            num = tonumber( tmp[2] )*0.01*expNum + tonumber( tmp[1] ),
				}
				local icon = ItemNode:createWithParams({
		            _type_ = tmpData.rewardtype,
		            count = tmpData.num,
		        })
		        icon:setScale( 60/icon:getContentSize().width )
		        icon:setAnchorPoint( cc.p( 0, 0.5 ) )
		        icon:setPosition( 80*( i - 1 ) + 20, 38 )
		        _rewardItemBg:addChild( icon )
		        iconData[#iconData + 1] = tmpData
			elseif tonumber( tmp[2] ) > 0 then
				-- 非经验
				local tmpData = {
					rewardtype = tonumber( _rewardData["rewardtype"..i] ),
		            id = tonumber( tmp[1] ),
		            num = tonumber( tmp[2] ),
				}
				local icon = ItemNode:createWithParams({
		            _type_ = tmpData.rewardtype,
		            itemId = tmpData.id,
		            count = tmpData.num,
		        })
		        icon:setScale( 60/icon:getContentSize().width )
		        icon:setAnchorPoint( cc.p( 0, 0.5 ) )
		        icon:setPosition( 80*( i - 1 ) + 20, 38 )
		        _rewardItemBg:addChild( icon )
		        iconData[#iconData + 1] = tmpData
			end
		end
		i = i + 1
	end
	-- 进度
	local progerssText = ""
	if self.finishNum > tonumber( _rewardData.yuanbao ) then
		progerssText = _rewardData.yuanbao.."/".._rewardData.yuanbao
	else
		progerssText = self.finishNum.."/".._rewardData.yuanbao
	end
	local progerss = XTHD.createLabel({
		text      = progerssText,
		fontSize  = 18,
		color     = cc.c3b(241,233,125),
		anchor    = cc.p( 0.5, 0.5 ),
		pos       = cc.p( _rewardItemBg:getContentSize().width - 60, _rewardItemBg:getContentSize().height - 22 ),
		clickable = false,
	})
	_rewardItemBg:addChild( progerss )   
	-- 按钮
    if _rewardData.state == 1 then
    	_rewardBtn = XTHD.createCommonButton({
			btnColor = "write",
			isScrollView = true,
	        btnSize = cc.size(100,49),
	        text = LANGUAGE_BTN_KEY.getReward,
	        anchor = cc.p( 0.5, 0.5 ),
	        pos = cc.p( _rewardItemBg:getContentSize().width - 60, 35 ),
	        endCallback = function()
	        	ClientHttp:requestAsyncInGameWithParams({
			        modules="receiveTotalPaySumReward?",
			        params = {gold = _rewardData.yuanbao},
			        successCallback = function( backData )
			            -- dump(backData,"领取次数奖励返回")
			            if tonumber( backData.result ) == 0 then
			            	ShowRewardNode:create( iconData )
			            	-- 更新属性
					    	if backData.property and #backData.property > 0 then
				                for i=1, #backData.property do
				                    local pro_data = string.split( backData.property[i], ',' )
				                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
				                end
				                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
				            end
				            -- 更新背包
				            if backData.bagItems and #backData.bagItems ~= 0 then
				                for i=1, #backData.bagItems do
				                    local item_data = backData.bagItems[i]
				                    if item_data.count and tonumber( item_data.count ) ~= 0 then
				                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
				                    else
				                        DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
				                    end
				                end
				            end
				            -- 更新界面
				            self.rewardData[tonumber(_idx)].state = 2
				            self:sortData()
				            self._tableView:reloadData()
			        	else
			                XTHDTOAST(backData.msg)
			            end
			        end,--成功回调
			        failedCallback = function()
			            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
			        end,--失败回调
			        targetNeedsToRetain = self,--需要保存引用的目标
			        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
			        loadingParent = self,
			    })
		    end
        })
        _rewardItemBg:addChild( _rewardBtn )
        local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		_rewardBtn:addChild(fetchSpine)
		fetchSpine:setPosition(_rewardBtn:getContentSize().width*0.5 + 2, _rewardBtn:getContentSize().height*0.5+2)
		fetchSpine:setAnimation(0, "querenjinjie", true )
		_rewardBtn:setScale(0.6)
	elseif _rewardData.state == 2 then
--		local lable = XTHDLabel:create("已领取",20,"res/fonts/def.ttf")
--		lable:setColor(cc.c3b(136,53,8))
    	_rewardBtn = XTHD.createSprite( "res/image/vip/yilingqu.png" )
    	_rewardBtn:setPosition( _rewardItemBg:getContentSize().width - 60, 35 )
		_rewardBtn:setScale(0.6)
        _rewardItemBg:addChild( _rewardBtn )
--		_rewardBtn:addChild(lable)
--		lable:setPosition(_rewardBtn:getContentSize().width /2,_rewardBtn:getContentSize().height/2)
	else
    	_rewardBtn = XTHD.createCommonButton({
			normalNode = "res/image/common/btn/btn_write_up.png",
            selectedNode = "res/image/common/btn/btn_write_down.png",
            btnColor = "red",
			btnSize = cc.size(100,49),
			isScrollView = true,
	        text = LANGUAGE_KEY_NOTREACHABLE,
	        anchor = cc.p( 0.5, 0.5 ),
	        pos = cc.p( _rewardItemBg:getContentSize().width - 60, 35 ),
	        endCallback = function()
		    	XTHDTOAST(LANGUAGE_TOTALRECHARGE_TEXT[3])
		    end
        })
		_rewardBtn:setScaleX(0.6)
		_rewardBtn:setScaleY(0.65)
        _rewardItemBg:addChild( _rewardBtn )
    end

	return _rewardItemBg
end
-- 更新数据
function TotalRechargePopLayer1:sortData()
	-- 分离数据
	local notFetchTable = {}
	local fetchedTable = {}
	for i, v in ipairs( self.rewardData ) do
		if v.state == 2 then
			fetchedTable[#fetchedTable + 1] = v
		else
			notFetchTable[#notFetchTable + 1] = v
		end
	end
	-- 排序
	table.sort( notFetchTable, function( a, b )
		return a.id < b.id
	end)
	table.sort( fetchedTable, function( a, b )
		return a.id < b.id
	end)
	-- 组合数据
	local sortedTable = {}
	for i, v in ipairs( notFetchTable ) do
		sortedTable[#sortedTable + 1] = v
	end
	for i, v in ipairs( fetchedTable ) do
		sortedTable[#sortedTable + 1] = v
	end
	self.rewardData = sortedTable
end

function TotalRechargePopLayer1:create(_data,_finishNum,_callBack)
	local _layer = self.new(_data,_finishNum,_callBack)
	return _layer
end

return TotalRechargePopLayer1