--[[
单挑之王特别奖励界面
]]

local JingXiangZhiLuSpecifalGiftLayer = class("JingXiangZhiLuSpecifalGiftLayer",function( )
	return XTHDPopLayer:create()
end)

function JingXiangZhiLuSpecifalGiftLayer:ctor(sdata,data,id)
    self._serverData = data  --gameUser.getNickname()
    self._allReward = sdata
	self._configID = id
    self._showData = {}
	--根据服务器的状态进行判断是够可领取
    self:initShowData()
end

function JingXiangZhiLuSpecifalGiftLayer:onCleanup( )	
   
end

function JingXiangZhiLuSpecifalGiftLayer:initShowData()
	self._showData = {}
    local strArr = string.split(self._allReward,',')
	for i = 1,#strArr do
        local itemArr = string.split(strArr[i],'#')
		local temp = {}
        temp._type = tonumber(itemArr[1])
		temp.itemID = tonumber(itemArr[2])
		temp.num = tonumber(itemArr[3])
		table.insert(self._showData,temp)
	end
    -- print("封装好的福利展示数据为：")
    -- print_r(self._showData)
end

function JingXiangZhiLuSpecifalGiftLayer:create(sdata,data,id)
	local layer = JingXiangZhiLuSpecifalGiftLayer.new(sdata,data,id)
	if layer then 
		layer:init()
	end
	return layer
end

function JingXiangZhiLuSpecifalGiftLayer:init()
	self:initUI()
end

function JingXiangZhiLuSpecifalGiftLayer:initUI()

	local _popBgSprite = cc.Sprite:create("res/image/challenge/gift/tbjl_bg.png")
	self._popBgSprite = _popBgSprite
    local popNode = XTHDPushButton:createWithParams({
                        normalNode = _popBgSprite
                    })
    popNode:setTouchEndedCallback(function ()
        
    end)
	_popBgSprite:setScale(0.7)
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:addContent(popNode)
    self.popNode = popNode
    self:show()

    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    close:setPosition(_popBgSprite:getContentSize().width-15, _popBgSprite:getContentSize().height-40)
    _popBgSprite:addChild(close,2)

    local tableview_bg = cc.Sprite:create("res/image/challenge/gift/tbjl_02.png")
    tableview_bg:setAnchorPoint(0,0)
    _popBgSprite:addChild(tableview_bg)
	tableview_bg:setPosition(30,_popBgSprite:getPositionY()/2 + 15)

   	itemView = CCTableView:create( cc.size(570,125) )
    itemView:setPosition( 40, 110 )
	itemView:setBounceable( true )
    itemView:setDirection( cc.SCROLLVIEW_DIRECTION_HORIZONTAL ) --设置横向纵向
    itemView:setDelegate()
	itemView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	
	if 	#self._showData < 6 then
		itemView:setTouchEnabled(false)	
	end

    local cellSize = cc.size( 570,130)
    local function numberOfCellsInTableView( table )
		return 1
	end
	local function cellSizeForTable( table, index )
		return cellSize.width,cellSize.height
	end
		
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
		if cell then
	        cell:removeAllChildren()
	    else
	        cell = cc.TableViewCell:new()
	    end
		self:freshItemList(cell)
		return cell
	end
	
	itemView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    itemView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    itemView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
	_popBgSprite:addChild(itemView)
	itemView:reloadData()

    --领取按钮
	local recBtn = XTHDPushButton:createWithParams({
            normalFile = "res/image/challenge/gift/tbjl_up.png",
            selectedFile = "res/image/challenge/gift/tbjl_down.png",
            needEnableWhenOut = true,
        })
	recBtn:setTouchEndedCallback(function()
	    self:onRecBtnClick()
	end)
	recBtn:setPosition(_popBgSprite:getContentSize().width/2,tableview_bg:getPositionY() - 35)
	_popBgSprite:addChild(recBtn)
    self._recBtn = recBtn
	self:freshRecBtnState()
end

--刷新掉落信息
function JingXiangZhiLuSpecifalGiftLayer:freshItemList(cell)
	local itemStr = self._showData
	cell:setContentSize(cc.size(570,130))
	for i = 1,#itemStr do
        local icon = ItemNode:createWithParams({
            _type_ = itemStr[i]._type,
            itemId = itemStr[i].itemID,
			count  = itemStr[i].num,
        })
        cell:addChild(icon)
		local pos = SortPos:sortFromMiddle(cc.p(cell:getContentSize().width*0.5,cell:getContentSize().height*0.5), #itemStr, 110)
        icon:setPosition(pos[i])
        icon:setScale(0.8)
	end
    
end

function JingXiangZhiLuSpecifalGiftLayer:freshRecBtnState()
	if self._serverData.rewardState == 1 then
		XTHD.setGray(self._recBtn:getStateNormal(),false)
		XTHD.setGray(self._recBtn:getStateSelected(),false)
	elseif self._serverData.rewardState == 2 then
		self._recBtn:getStateNormal():initWithFile("res/image/challenge/gift/tbjlgot.png")
		self._recBtn:getStateSelected():initWithFile("res/image/challenge/gift/tbjlgot.png")
		XTHD.setGray(self._recBtn:getStateNormal(),true)
		XTHD.setGray(self._recBtn:getStateSelected(),true)
	else
		XTHD.setGray(self._recBtn:getStateNormal(),true)
		XTHD.setGray(self._recBtn:getStateSelected(),true)
    end
end

function JingXiangZhiLuSpecifalGiftLayer:onRecBtnClick()
	if self._serverData.fristPass ~= gameUser.getNickname() then
        XTHDTOAST("只有首位通关者才能领取该奖励！")
        return
    elseif self._serverData.rewardState == 2 then
    	XTHDTOAST("奖励已领取！")
        return
	end
	HttpRequestWithParams("singleEctypeEspecially",{configId = self._configID},function (data)
        -- print("领取特别奖励服务器返回的数据为：")
        -- print_r(data)
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
                    end
                end
                DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
            end
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})        --刷新数据信息
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
                local idx = #show + 1
                show[idx] = {}
                show[idx].rewardtype = 4 -- item_data.item_type
                show[idx].id = item_data.itemId
                show[idx].num = showCount
            end
        end
        --显示领取奖励成功界面
        ShowRewardNode:create(show)
        self._serverData.rewardState = 2
		self:freshRecBtnState()
    end)
end

return JingXiangZhiLuSpecifalGiftLayer


