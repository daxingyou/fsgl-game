--Created By Liuluyang 2015年06月13日
local ChaozhiduihuanRankPopLayer = class("ChaozhiduihuanRankPopLayer",function ()
	return XTHD.createPopLayer()
end)

function ChaozhiduihuanRankPopLayer:ctor(data)
	self._data = data
--	dump(self._data,"排行榜")
	self:initUI()
end

function ChaozhiduihuanRankPopLayer:initUI()	
	local node = ccui.Scale9Sprite:create("res/image/challenge/rank/dtphbg_06.png")
    node:setContentSize(cc.size(748,465))
    -- node:setCascadeOpacityEnabled( false )
    self:addContent(node)
    node:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)


	 --关闭按钮
    local close = XTHD.createBtnClose(function()
         self:hide()
    end)
    node:addChild(close)
    close:setPosition(node:getContentSize().width - 5,node:getContentSize().height - 5) 

	if node:getChildByName("tishi") then
		node:getChildByName("tishi"):removeFromParent()
	end

	local tishi = XTHDLabel:create("暂无排行",30,"res/fonts/def.ttf")
	node:addChild(tishi)
	tishi:setPosition(node:getContentSize().width / 2,node:getContentSize().height/2)
	tishi:setVisible(false)
	tishi:setName("tishi")

--	if self._rankList == nil then
--		tishi:setVisible(true)
--		return
--	end

	local rankTableView = cc.TableView:create(cc.size(645,390))
	rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL );
    rankTableView:setPosition( cc.p(40, 28));
    rankTableView:setBounceable(true)
	rankTableView:setDirection(ccui.ScrollViewDir.vertical)
	rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	rankTableView:setDelegate()
	node:addChild(rankTableView)

	local function numberOfCellsInTableView( table )
        return #self._data.list
    end
	local cellSize = cc.size(630,80)
    local function cellSizeForTable( table, idx )
		return cellSize.width,cellSize.height
    end

    local function tableCellAtIndex( table, idx )
        local cell = cc.TableViewCell:new()
		local cellBg = ccui.Scale9Sprite:create("res/image/challenge/rank/dtphbg_09.png")
		cellBg:setContentSize(630,70)
		cell:addChild(cellBg)
		cellBg:setPosition(cellBg:getContentSize().width/2 +15,cellBg:getContentSize().height/2)
		local index = idx + 1 
			
		-- 排名icon
        local rankIcon = XTHD.createSprite()
        rankIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
        rankIcon:setPosition( 60, cellSize.height*0.5 - 4 )
        cellBg:addChild( rankIcon )

        local rankNum = cc.Label:createWithBMFont( "res/fonts/paihangbangword.fnt", 0 )
	    rankNum:setPosition( 60, cellSize.height*0.5 - 10)
	    cellBg:addChild( rankNum )
	    rankNum:setString( index )
		local rankIconPath = ""
        if index <= 10 then
		    if index <= 3 then
			    rankIconPath = "res/image/ranklistreward/"..( index)..".png"
			    rankNum:setVisible(false)
		    else
			    rankIconPath = "res/image/ranklist/rank_4.png"
			    rankNum:setVisible(true)
		    end
		    rankIcon:setTexture( rankIconPath )
		    rankIcon:setScale(0.8)
		    rankIcon:setVisible( true )
        else
            rankIcon:setVisible( false )
        end

		local name = XTHDLabel:create(self._data.list[index].charName,20,"res/fonts/def.ttf")
		name:setAnchorPoint(0,0.5)
		name:setColor(cc.c3b(70,40,20))
		name:setPosition(rankIcon:getPositionX() + 50,cellBg:getContentSize().height *0.5)
		cellBg:addChild(name)

		local camp = nil
		if self._data.list[index].campId == 1 then
			camp = "(仙族)"
		else
			camp = "(魔族)"
		end
		local campLable = XTHDLabel:create(camp,16,"res/fonts/def.ttf")
		campLable:setColor(cc.c3b(70,40,20))
		name:addChild(campLable)
		campLable:setAnchorPoint(0,0.5)
		campLable:setPosition(name:getContentSize().width,campLable:getContentSize().height / 2) 

		local lable = XTHDLabel:create("兑换券消耗数量：".. self._data.list[index].totalPhase,16,"res/fonts/def.ttf")
		lable:setAnchorPoint(0,0.5)
		lable:setColor(cc.c3b(70,40,20))
		lable:setPosition(cellBg:getContentSize().width *0.5 + 130,cellBg:getContentSize().height*0.5)
		cellBg:addChild(lable)

		local dengji = XTHDLabel:create("等级：".. self._data.list[index].level,16,"res/fonts/def.ttf")
		dengji:setAnchorPoint(0,0.5)
		dengji:setColor(cc.c3b(70,40,20))
		dengji:setPosition(cellBg:getContentSize().width *0.5,cellBg:getContentSize().height*0.5)
		cellBg:addChild(dengji)
		
		return cell
    end

    rankTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	rankTableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	rankTableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	rankTableView:reloadData()
	
end


function ChaozhiduihuanRankPopLayer:create(data)
	return ChaozhiduihuanRankPopLayer.new(data)
end

return ChaozhiduihuanRankPopLayer