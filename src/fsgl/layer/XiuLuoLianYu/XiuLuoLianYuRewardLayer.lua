-- FileName: DuoCengScrollLayer.lua
-- Author: wangming
-- Date: 2015-08-07
-- Purpose: 修罗战场奖励类
--[[TODO List]]
local XiuLuoLianYuRewardLayer = class("XiuLuoLianYuRewardLayer",function()
    return XTHD.createPopLayer({isRemoveLayout = true})
end)
function XiuLuoLianYuRewardLayer:ctor(_nowNum)
    self._nowNum = _nowNum or 0
	self.reward_data = gameData.getDataFromCSV("SingleRaceReward", {rewardtype = 5})
    self:init()
    self:show()
end

function XiuLuoLianYuRewardLayer:init()
    local _popBgSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png" )--ccui.Scale9Sprite:create(cc.rect(69,69,1,1),"res/image/common/scale9_bg_1.png")
    _popBgSprite:setContentSize(cc.size(515,504-52))
    _popBgSprite:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
    self:addContent(_popBgSprite)

    -- local title_bg = XTHD.getScaleNode("res/image/common/common_title_barBg.png",cc.size(_popBgSprite:getContentSize().width - 7*2,44))
    local title_bg = ccui.Scale9Sprite:create()
    title_bg:setContentSize(cc.size(_popBgSprite:getContentSize().width - 7*2,44))
    -- XTHD.createSprite("res/image/daily_task/arena/rewardTitle.png")
    title_bg:setAnchorPoint(0.5,1)
    title_bg:setPosition(_popBgSprite:getContentSize().width*0.5, _popBgSprite:getContentSize().height-7)
    _popBgSprite:addChild(title_bg)
    local _titleSp = XTHDLabel:create(LANGUAGE_ARENA_TITLE,22)
    _titleSp:setColor(XTHD.resource.titleColor)
    _titleSp:setPosition(cc.p(title_bg:getContentSize().width/2,title_bg:getContentSize().height/2))
    title_bg:addChild(_titleSp)
    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    close:setPosition(_popBgSprite:getContentSize().width, _popBgSprite:getContentSize().height)
    _popBgSprite:addChild(close)

    local tableview_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
    tableview_bg:setContentSize(_popBgSprite:getContentSize().width-30,_popBgSprite:getContentSize().height-100)
    tableview_bg:setAnchorPoint(0,0)
    tableview_bg:setPosition(14.5,49)
    _popBgSprite:addChild(tableview_bg)

     --tableview
    local tableview = CCTableView:create( cc.size(tableview_bg:getContentSize().width-20, tableview_bg:getContentSize().height-25) )
    tableview:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
    tableview:setPosition( cc.p(8, 10) )
    tableview:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
    tableview:setBounceable(true)
    tableview:setDelegate()
    tableview_bg:addChild(tableview)
   
    -- tableView注册事件
    local function numberOfCellsInTableView( table )
        return  #self.reward_data
    end

    local function cellSizeForTable( table, idx )
        return  tableview:getContentSize().width,106
    end

    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell();
        if cell == nil then
            cell = cc.TableViewCell:new();
            cell:setContentSize( tableview:getContentSize().width,100 )
            -- cell:retain()
        else
            cell:removeAllChildren()
        end
        return self:initCellData(cell,idx+1)
    end

    tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)


    tableview:reloadData()

    local _tip = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS250,
        fontSize = 18,
        color = cc.c3b(55, 54, 112),
        pos = cc.p(_popBgSprite:getContentSize().width*0.5, 28),
        anchor = cc.p(0.5, 0),
        ttf = "res/fonts/def.ttf"
    })
    _popBgSprite:addChild(_tip)

end


function XiuLuoLianYuRewardLayer:initCellData( cell,idx )
    local data = self.reward_data[idx]
    if data == nil or next(data) == nil then
        return cell
    end

    -- local layer_num = {"10","二十","三十","四十","五十","六十","七十"}  
  

    local cell_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png" )--ccui.Scale9Sprite:create("res/image/plugin/mail_layer/mail_cell_bg.png")
    cell_bg:setContentSize(cell:getContentSize().width-6, 105)
    cell_bg:setPosition(cell:getContentSize().width*0.5, cell:getContentSize().height*0.5)
    cell:addChild(cell_bg)

    --描述信息
    local name = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_ARENAREWARDTIP(data.rewardcanshu),
        fontSize = 22,
        color = cc.c3b(55, 54, 112),
        anchor = cc.p(0, 0.5),
        pos = cc.p(15,cell:getContentSize().height*0.5),
        ttf = "res/fonts/def.ttf"
    })
    cell:addChild(name)


    local _tip
    if self._nowNum >= data.rewardcanshu then
        _tip = XTHD.createSprite("res/image/daily_task/arena/yidacheng.png")
    else
        _tip = XTHDLabel:createWithParams({
            text = LANGUAGE_ADJ.unreachable,
            fontSize = 22,
            color = cc.c3b(149,0,0),
            ttf = "res/fonts/def.ttf"
        })
    end
    _tip:setPosition(cell:getContentSize().width - 70,cell:getContentSize().height*0.5)
    cell:addChild(_tip)

    local items = {
        {
            _type = XTHD.resource.type.ingot, 
            num = data.rewardyuanbao,
        },
        {
            _type = XTHD.resource.type.asura_blood,
            num = data.rewardxiuluoxue,
        },
    }
   
	-- 可能掉落
	local pos_table=SortPos:sortFromMiddle(cc.p(cell:getContentSize().width*0.5,cell:getContentSize().height*0.5 + 5), #items,80)
	for i = 1, #items do
        if items[i].num > 0 then 
    		local item_bg = ItemNode:createWithParams({
        		_type_ = items[i]._type,
        		count= items[i].num
    		})
    		item_bg:setScale(0.7)
    		item_bg:setPosition(pos_table[i])
            item_bg:setPositionX(item_bg:getPositionX() + 10)
    		cell:addChild(item_bg)
    		local item_name_label = XTHDLabel:createWithParams({
                text = XTHD.resource.name[items[i]._type],
                anchor=cc.p(0.5,1),
                fontSize = 18,--字体大小
                color = cc.c3b(74,34,34),
                pos = cc.p(item_bg:getContentSize().width*0.5,0),
                ttf = "res/fonts/def.ttf"
            })
            item_bg:addChild(item_name_label)
        end 
	end


    --图片
    -- local line = cc.Sprite:create("res/image/common/line.png")
    -- line:setPosition(cell:getContentSize().width*0.5, 0)
    -- cell:addChild(line)
    -- 分隔线
    -- local splitCellLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
    -- splitCellLine:setContentSize( cell:getContentSize().width, 2 )
    -- splitCellLine:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    -- splitCellLine:setPosition( cell:getContentSize().width*0.5, -1 )
    -- cell:addChild( splitCellLine )

    return cell

end

function XiuLuoLianYuRewardLayer:create(_pNum)
    LayerManager.addShieldLayout(false, 0.1)
    local _layer = self.new(_pNum)
    return _layer
end
return XiuLuoLianYuRewardLayer