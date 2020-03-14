--[[
英雄培养打脸页
]]

local HeroPeiYangPopLayer = class("HeroPeiYangPopLayer",function( )
	return XTHDPopLayer:create()
end)

function HeroPeiYangPopLayer:ctor(_type)
    self._type = _type 
end

function HeroPeiYangPopLayer:onCleanup( )	
   
end

function HeroPeiYangPopLayer:create(_type)
	local layer = HeroPeiYangPopLayer.new(_type)
	if layer then 
		layer:init()
	end
	return layer
end

function HeroPeiYangPopLayer:init()
	self:initUI()
end

function HeroPeiYangPopLayer:initUI()

	local _popBgSprite = cc.Sprite:create("res/image/dalianye/peiyang/bg.png")
	self._popBgSprite = _popBgSprite
    local popNode = XTHDPushButton:createWithParams({
                        normalNode = _popBgSprite
                    })
    popNode:setTouchEndedCallback(function ()
        
    end)
	_popBgSprite:setScale(1)
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:addContent(popNode)
    self.popNode = popNode
    self:show()

    local close = XTHDPushButton:createWithParams({
            normalFile = "res/image/dalianye/peiyang/closeBtn1.png",
            selectedFile = "res/image/dalianye/peiyang/closeBtn2.png",
            needEnableWhenOut = true,
        })
    close:setTouchEndedCallback(function()
        self:hide()
    end)
    close:setPosition(_popBgSprite:getContentSize().width-60, _popBgSprite:getContentSize().height-105)
    _popBgSprite:addChild(close,2)

   	itemView = CCTableView:create( cc.size(250,100) )
    itemView:setPosition( 235, 160 )
	itemView:setBounceable( true )
    itemView:setTouchEnabled(false) 
    itemView:setDirection( cc.SCROLLVIEW_DIRECTION_HORIZONTAL ) --设置横向纵向
    itemView:setDelegate()
	itemView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )

    local cellSize = cc.size( 250,100)
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

    --前往按钮
	local goBtn = XTHDPushButton:createWithParams({
            normalFile = "res/image/dalianye/peiyang/goBtn1.png",
            selectedFile = "res/image/dalianye/peiyang/goBtn2.png",
            needEnableWhenOut = true,
        })
	goBtn:setTouchEndedCallback(function()
	    self:onGoBtnClick()
	end)
	goBtn:setPosition(_popBgSprite:getContentSize().width/2 + 80,_popBgSprite:getContentSize().height/2 - 90)
	_popBgSprite:addChild(goBtn)
end

--刷新掉落信息
function HeroPeiYangPopLayer:freshItemList(cell)
	cell:setContentSize(cc.size(250,100))
    local itemStr1 = {   --橙将
        {_type = 4,itemID = 2251,count = 300},
        {_type = 3,itemID = 0,count = 300},
        {_type = 4,itemID = 2302,count = 300},
        {_type = 4,itemID = 2002,count = 3000},
        {_type = 4,itemID = 2902,count = 3000},
    }
    local itemStr2 = {  --红将
        {_type = 4,itemID = 2251,count = 680},
        {_type = 3,itemID = 0,count = 680},
        {_type = 4,itemID = 2302,count = 680},
        {_type = 4,itemID = 2002,count = 6800},
        {_type = 4,itemID = 2902,count = 6800},
    }
    local itemStr = self._type == 1 and itemStr1 or itemStr2
	for i = 1,#itemStr do
        local icon = ItemNode:createWithParams({
            _type_ = itemStr[i]._type,
            itemId = itemStr[i].itemID,
            count = itemStr[i].count,
        })
        cell:addChild(icon)
		local pos = SortPos:sortFromMiddle(cc.p(cell:getContentSize().width*0.5,cell:getContentSize().height*0.5), #itemStr, 50)
        icon:setPosition(pos[i])
        icon:setScale(0.5)
	end
    
end

function HeroPeiYangPopLayer:onGoBtnClick()
    self:hide()
    local voucherLayer = requires("src/fsgl/layer/VoucherCenter/VoucherCenterLayer.lua"):create(5)
	LayerManager.addLayout(voucherLayer)
end

return HeroPeiYangPopLayer


