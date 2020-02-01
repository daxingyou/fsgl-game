--LayerName 限时礼包

--XianShiLiBaoLayer
local XianShiLiBaoLayer = class("XianShiLiBaoLayer",function()
	return XTHDPopLayer:create()
end)

function XianShiLiBaoLayer:ctor(data)
	self:initLayer(data)
end

function XianShiLiBaoLayer:initLayer(data)
	-- print("限时礼包数据为：")
	-- print_r(data)
	local _containerLayer = self:getContainerLayer()
	_containerLayer:setClickable(true)

	local y = os.date("%Y")
	local m = os.date("%m")
	local d = os.date("%d")
	self.daySec = os.time({year = y, month = m, day =d, hour = 24, min = 00, sec = 00})

	-- 背景
	local _popNode = XTHDSprite:create("res/image/plugin/limitTimeBuy/Activityframe.png")
	_popNode:setPosition(cc.p(_containerLayer:getContentSize().width/2,_containerLayer:getContentSize().height/2))
	self.popNode = _popNode
	_containerLayer:addChild(_popNode)
	_popNode:setSwallowTouches(true)

	-- 关闭
	local closeBtn = XTHD.createBtnClose(function()
        self:hide()
    end)
	closeBtn:setMusicFile(XTHD.resource.music.effect_btn_commonclose)
    closeBtn:setPosition(cc.p(_popNode:getContentSize().width - 30,_popNode:getContentSize().height))
    _popNode:addChild(closeBtn)

	-- 月卡购买
    local cardBtn = XTHD.createButton({
	    	normalNode = "res/image/plugin/limitTimeBuy/Card_up.png",
			selectedNode = "res/image/plugin/limitTimeBuy/Card_down.png",
			anchor = cc.p(0.5, 0.5),
			pos = cc.p(_popNode:getContentSize().width - 30, _popNode:getContentSize().height - 115),
			endCallback = function()
				XTHD.createRechargeVipLayer(self) -- 跳转充值界面
			end,
    	})
    _popNode:addChild(cardBtn)

	-- 售价
    local money = XTHDLabel:create("售价: ".. tostring(data.needMoney) .. "元", 30)
    money:setColor(XTHD.resource.color.orange_desc)
    money:enableShadow(XTHD.resource.textColor.gray_text,cc.size(0.4,-0.4),0.4)
    money:setAnchorPoint(cc.p(0,0.5))
	money:setPosition(cc.p(_popNode:getContentSize().width/2 - 40, 115))
	money:setScale(0.8)
	_popNode:addChild(money)
	
	-- 购买按钮
	local buyBtn = XTHD.createCommonButton({
		btnColor = "write",
		isScrollView = false,
        btnSize = cc.size(100,38),
        text = "购买",
        anchor = cc.p(0.5,0.5),
		pos = cc.p(_popNode:getContentSize().width - 180, 115),
	})
	buyBtn:setScale(0.8)
	buyBtn:setTouchEndedCallback(function()
		buyBtn:setClickable(false)

		local item_data = {
			configType    = data.payConfigType,  -- 计费类型
			configId      = data.payConfigId,
			needRMB       = data.needMoney,
			needGold      = 0,
		}

		XTHD.pay(item_data,2,self)  --2是限购礼包
		-- gameUser.setActivityOpenStatusById(19, 0)
		-- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
	end)

	_popNode:addChild(buyBtn)


	-- 活动倒计时
	local time = XTHDLabel:create("活动倒计时:", 18)
	time:setColor(XTHD.resource.textColor.white_text)
	time:setAnchorPoint(cc.p(0,0.5))
	time:setPosition(cc.p(_popNode:getContentSize().width/2 + 10, 53))
	time:setScale(0.8)
	_popNode:addChild(time)
	time:runAction(cc.RepeatForever:create(
		cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
			local curSec = os.time()
			local timestr = getCdStringWithNumber(os.difftime(self.daySec, curSec),{h = LANGUAGE_UNKNOWN.hour,m = LANGUAGE_UNKNOWN.minute,s = LANGUAGE_UNKNOWN.second})
            time:setString("活动倒计时:".. timestr);
        end)
    )))

	--创建item
	local function createItem(data)
		local item = ItemNode:createWithParams({
			itemId = data.id ,
			-- quality = data.rank,
			_type_ = data.type,
			count = data.num,
			-- touchShowTip = false,
		})
		item:setScale(0.85)
		return item
	end

	--创建礼包tableview
	local function create_tableview(cell_arr)
		local _extrWidth = 350
		local _extrHight = 85
		local tableview = cc.TableView:create(cc.size(_extrWidth, _extrHight))
		tableview:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
		tableview:setPosition(cc.p(_popNode:getContentSize().width/2 - 100, 145))
		tableview:setBounceable(true)
		tableview:setDelegate()
		_popNode:addChild(tableview)

		-- tableView注册事件
		local function numberOfCellsInTableView( table )
			return #cell_arr  
		end
		local function cellSizeForTable( table, idx )
			return 80, 80  
		end
		local function tableCellAtIndex( table, idx )
			local cell = table:dequeueCell()
			if cell == nil then
				cell = cc.TableViewCell:new()
				cell:setContentSize(80,80)
			else
				cell:removeAllChildren()
			end

			local item = createItem(cell_arr[idx+1])
			if (idx + 1) == 1 then
                item:setPosition(cell:getContentSize().width*0.5 + 15,cell:getContentSize().height*0.5)
            elseif (idx + 1) == 2 then
                item:setPosition(cell:getContentSize().width*0.5 + 45,cell:getContentSize().height*0.5)
            else
            	item:setPosition(cell:getContentSize().width*0.5 + 75,cell:getContentSize().height*0.5)
			end
			
			cell:addChild(item)

			return cell
		end

		tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
		tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
		tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
		tableview:reloadData()
	end

	create_tableview(data.itemList)

	self:show(true)
end

function XianShiLiBaoLayer:freshLayer()
	self:removeFromParent()
end

function XianShiLiBaoLayer:create(data)
	local _layer = self.new(data)
	if _layer~=nil then
		return _layer
	end
end
return XianShiLiBaoLayer