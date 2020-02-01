--[[
排行榜页面
]]
local BaiPaiPaiHangBang = class("BaiPaiPaiHangBang",function( )
	return XTHDPopLayer:create()
end)

function BaiPaiPaiHangBang:ctor(data)
    self._rankList = data
end

function BaiPaiPaiHangBang:create(data,_type)
	local rank = BaiPaiPaiHangBang.new(data,_type)
	if rank then 
		rank:init()
	end 
	return rank
end

function BaiPaiPaiHangBang:init( )
    ---背景
    local back = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")  
    back:setContentSize(cc.size(524,465))   
    back:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:addContent(back)
    self:getContainerLayer():setClickable(false)
	self._backBg = back
    ---黄色标头背景
  
    ---关闭按钮
    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    back:addChild(close,2)
    close:setPosition(back:getContentSize().width - 5,back:getContentSize().height - 5)

    if #self._rankList > 0 then
		self:createListView()
	else
		local lable = XTHDLabel:create("暂无排行",30,"res/fonts/def.ttf")
		back:addChild(lable)
		lable:setPosition(back:getContentSize().width/2,back:getContentSize().height/2)
	end
	
end

function BaiPaiPaiHangBang:createListView()
	local rankTableView = cc.TableView:create(cc.size(520,450))
	rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL );
    rankTableView:setPosition( cc.p(0, 10));
    rankTableView:setBounceable(true)
	rankTableView:setDirection(ccui.ScrollViewDir.vertical)
	rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	rankTableView:setDelegate()
	self._backBg:addChild(rankTableView)

	local function numberOfCellsInTableView( table )
        return #self._rankList
    end
	local cellSize = cc.size(520,70)
    local function cellSizeForTable( table, idx )
		return cellSize.width,cellSize.height
    end

    local function tableCellAtIndex( table, idx )
        local cell = cc.TableViewCell:new()
		local cellBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
		cellBg:setContentSize(510,60)
		cell:addChild(cellBg)
		cellBg:setPosition(cellBg:getContentSize().width/2 + 3 ,cellBg:getContentSize().height/2)
		
		index = idx + 1
       
        -- 排名icon
        local rankIcon = XTHD.createSprite()
        rankIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
        rankIcon:setPosition( 50, cellSize.height*0.5 - 5 )
        cell:addChild( rankIcon )

		--昵称
		local nameLable = XTHDLabel:create(self._rankList[index].charName,20,"res/fonts/def.ttf")
		nameLable:setColor(cc.c3b(107,70,43))
		nameLable:setAnchorPoint(0,0.5)
		nameLable:setPosition(90,cellBg:getContentSize().height*0.5)
		cellBg:addChild(nameLable)
		
        --贡献点
        local GXLable = XTHDLabel:create("捐献点："..self._rankList[index].totalContribution,20,"res/fonts/def.ttf")
		GXLable:setAnchorPoint(0,0.5)
        GXLable:setColor(cc.c3b(107,70,43))
        cellBg:addChild(GXLable)
        GXLable:setPosition(cellBg:getContentSize().width * 0.7,cellBg:getContentSize().height *0.5)

    	local rankNum = cc.Label:createWithBMFont( "res/fonts/paihangbangword.fnt", 0 )
	    rankNum:setPosition( 50, cellSize.height*0.5 - 12 )
	    cell:addChild( rankNum )
	    rankNum:setString( index )
		local _isScale = 0.8
	    if index < 10 then
			local rankIconPath = ""
			if index <= 3 then
				_isScale = 0.8
				rankIconPath = "res/image/ranklistreward/"..( index)..".png"
				rankNum:setVisible(false)
			else
				_isScale = 0.6
				rankIconPath = "res/image/ranklist/rank_4.png"
				rankNum:setVisible(true)
			end
			rankIcon:setTexture( rankIconPath )
			rankIcon:setScale(_isScale)
			rankIcon:setVisible( true )
		else
			rankIcon:setVisible( false )
		end
	
		
		return cell
    end

    rankTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	rankTableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	rankTableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	rankTableView:reloadData()
end

return BaiPaiPaiHangBang