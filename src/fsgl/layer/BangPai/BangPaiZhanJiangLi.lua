-- FileName: BangPaiZhanJiangLi.lua
-- Author: wangming
-- Date: 2015-11-03
-- Purpose: 帮派战奖励显示界面
--[[TODO List]]
local SectWarReward = 
{
    { id = 3, title = "报名奖励", tips = "报名成功（帮派内所有成员均获得奖励）", typeA = 1, canshu = 1, yinliang = 200000, gongxian = 500, feicui = 0, },
    { id = 4, title = "帮派战积分奖励", tips = "第一名（帮派内所有成员均获得奖励）", typeA = 1, canshu = 1, yinliang = 0, gongxian = 3000, feicui = 200000, },
    { id = 5, title = "帮派战积分奖励", tips = "第二名（帮派内所有成员均获得奖励）", typeA = 1, yinliang = 0, gongxian = 2000, feicui = 150000, },
    { id = 6, title = "帮派战积分奖励", tips = "第三名（帮派内所有成员均获得奖励）", typeA = 1, canshu = 1, yinliang = 0, gongxian = 1500, feicui = 100000, },
    { id = 7, title = "帮派战积分奖励", tips = "第三名以后（帮派内所有成员均获得奖励）", typeA = 1, canshu = 1, yinliang = 0, gongxian = 500, feicui = 50000, },
}

local BangPaiZhanJiangLi = class("BangPaiZhanJiangLi",function(sParams)
	return requires("src/fsgl/layer/BangPai/BangPaiXinXi.lua"):create(sParams)
end)

function BangPaiZhanJiangLi:init( sParams )
	local mParams = sParams or {}
	local popNode = self._popNode
    local _worldSize = popNode:getContentSize()
    self._titleBack:setVisible(false)
    local title = cc.Sprite:create("res/image/guild/guildWar/guildWarText_rewardprompt.png")
    title:setPosition(self._titleBack:getPositionX(),self._titleBack:getPositionY()-self._titleBack:getContentSize().height+5)
    popNode:addChild(title)
	local _tableSize = cc.size(_worldSize.width - 20, _worldSize.height - 110)
	local _cellSize = cc.size(_tableSize.width, 80)
    local tableBg = BangPaiFengZhuangShuJu.createListBg(cc.size(_tableSize.width,_tableSize.height+20))
    tableBg:setAnchorPoint(0.5,0)
    tableBg:setPosition(popNode:getContentSize().width/2,30)
    popNode:addChild(tableBg)
    
     --tableview
    local tableview = CCTableView:create(_tableSize)
    tableview:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
    tableview:setPosition( cc.p(18, 40) )
    tableview:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
    tableview:setBounceable(true)
    tableview:setDelegate()
    popNode:addChild(tableview)    
   
    -- tableView注册事件
    local function numberOfCellsInTableView( table )
        return  #SectWarReward
    end

    local function cellSizeForTable( table, idx )
        return _cellSize.width-20,_cellSize.height
    end

    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
            cell:setContentSize(_cellSize)
        else
            cell:removeAllChildren()
        end

        local data = SectWarReward[idx + 1]
	    if not data then
	        return cell
	    end

        -- local cell_bg = BangPaiFengZhuangShuJu.createListCellBg(cc.size(_cellSize.width - 10, _cellSize.height - 10))
        local cell_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_26.png")
        cell_bg:setContentSize(cc.size(_cellSize.width - 20, _cellSize.height-10))
	    cell_bg:setPosition(_cellSize.width*0.5 - 8, _cellSize.height*0.5)
	    cell:addChild(cell_bg)

	    local _starX = 10
	    --描述信息
	    local name = XTHDLabel:createWithParams({
	        text = data.title,
	        fontSize = 18,
	        color = cc.c3b(178, 27, 27),
	        anchor = cc.p(0, 0.5),
	        pos = cc.p(_starX, cell_bg:getContentSize().height*0.7)
        })
	    cell_bg:addChild(name)

    	local desc = XTHDLabel:createWithParams({
	        text = data.tips,
	        fontSize = 16,
	        color = XTHD.resource.color.brown_desc,
	        anchor = cc.p(0, 0.5),
	        pos = cc.p(_starX, cell_bg:getContentSize().height*0.3)
        })
        cell_bg:addChild(desc)
        local count = data.gongxian

	    local item_reward = ItemNode:createWithParams({
	    	_type_ = XTHD.resource.type.guild_contri,
            count = count,
        }) 
        item_reward:setScale(0.7)
        item_reward:setAnchorPoint(cc.p(1, 0.5))
        item_reward:setPosition(cell_bg:getContentSize().width - _starX, cell_bg:getContentSize().height*0.5)
        cell_bg:addChild(item_reward)

        local rewardType = XTHD.resource.type.gold
        count = data.yinliang
        if data.feicui ~= 0 then
            rewardType = XTHD.resource.type.feicui
            count = data.feicui
        end

	    item_reward = ItemNode:createWithParams({
	    	_type_ = rewardType,
            count = count,
        }) 
        item_reward:setScale(0.7)
        item_reward:setAnchorPoint(cc.p(1, 0.5))
        item_reward:setPosition(cell_bg:getContentSize().width - _starX - 70, cell_bg:getContentSize().height*0.5)
        cell_bg:addChild(item_reward)

        return cell
    end

    tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableview:reloadData()
end


function BangPaiZhanJiangLi:createOne( sParams ) -- {guildData}
    local params = {
        size = cc.size(493, 430),
        titleNode = cc.Sprite:create("res/image/guild/guildWar/guildWarText_rewardprompt.png"),
    }
	local pLay = BangPaiZhanJiangLi.new( params )
	pLay:init(sParams)
	LayerManager.addLayout(pLay,{noHide = true})
	return pLay
end


return BangPaiZhanJiangLi