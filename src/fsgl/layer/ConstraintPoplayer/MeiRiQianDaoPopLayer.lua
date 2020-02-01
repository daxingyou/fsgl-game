--[[
每日签到打脸页
]]

local MeiRiQianDaoPopLayer = class("MeiRiQianDaoPopLayer",function( )
	return XTHDPopLayer:create()
end)

function MeiRiQianDaoPopLayer:ctor()
   gameUser.setMeiRiQianDaoState(0)
end

function MeiRiQianDaoPopLayer:onCleanup( )	
   
end

function MeiRiQianDaoPopLayer:create()
	local layer = MeiRiQianDaoPopLayer.new()
	if layer then 
		layer:init()
	end
	return layer
end

function MeiRiQianDaoPopLayer:init()
	self:initUI()
end

function MeiRiQianDaoPopLayer:initUI()

	local _popBgSprite = cc.Sprite:create("res/image/dalianye/mrqd/bg.png")
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
            normalFile = "res/image/dalianye/mrqd/closeBtn1.png",
            selectedFile = "res/image/dalianye/mrqd/closeBtn2.png",
            needEnableWhenOut = true,
        })
    close:setTouchEndedCallback(function()
        self:hide()
    end)
    close:setPosition(_popBgSprite:getContentSize().width-65, _popBgSprite:getContentSize().height-85)
    _popBgSprite:addChild(close,2)

   	itemView = CCTableView:create( cc.size(250,100) )
    itemView:setPosition( 195, 145 )
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
            normalFile = "res/image/dalianye/mrqd/goBtn1.png",
            selectedFile = "res/image/dalianye/mrqd/goBtn2.png",
            needEnableWhenOut = true,
        })
	goBtn:setTouchEndedCallback(function()
	    self:onGoBtnClick()
	end)
	goBtn:setPosition(_popBgSprite:getContentSize().width/2 + 50,_popBgSprite:getContentSize().height/2 - 62)
	_popBgSprite:addChild(goBtn)
end

--刷新掉落信息
function MeiRiQianDaoPopLayer:freshItemList(cell)
	cell:setContentSize(cc.size(250,100))
    local itemStr = {
        {_type = 4,itemID = 2310},
        {_type = 3,itemID = 0},
        {_type = 4,itemID = 2418},
    }
	for i = 1,#itemStr do
        local icon = ItemNode:createWithParams({
            _type_ = itemStr[i]._type,
            itemId = itemStr[i].itemID,
        })
        cell:addChild(icon)
		local pos = SortPos:sortFromMiddle(cc.p(cell:getContentSize().width*0.5,cell:getContentSize().height*0.5), #itemStr, 70)
        icon:setPosition(pos[i])
        icon:setScale(0.5)
	end
    
end

function MeiRiQianDaoPopLayer:onGoBtnClick()
    self:hide()
	requires("src/fsgl/layer/HuoDong/HuoDongLayer.lua"):createWithTab(2)
end

return MeiRiQianDaoPopLayer


