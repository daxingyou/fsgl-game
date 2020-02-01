--[[
    FileName: luckyDrawPop.lua
    Author: andong
    Date: 2015-12-19
    Purpose: xx界面
]]
local luckyDrawPop = class( "luckyDrawPop", function ()
    return XTHDPopLayer:create({isRemoveLayout = true})
end)
function luckyDrawPop:ctor(params)
    self:initData(params)
    self:initUI()
    self:show()
end
function luckyDrawPop:initData()
    local static = gameData.getDataFromCSV("SlotMachine")
    self._static = static
end
function luckyDrawPop:initUI()
    local popSize = cc.size(500, 470)
    local popNode = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
    popNode:setContentSize(popSize)
    popNode:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
    self:addContent(popNode)
    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    close:setPosition(popSize.width-5, popSize.height-5)
    popNode:addChild(close, 10)

    local tableSize = cc.size(popSize.width-20 , popSize.height-60)
    local tableNode = popNode
    
    local myTableBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
    myTableBg:setContentSize(tableSize)
    myTableBg:setAnchorPoint(cc.p(0.5, 0.5))
    myTableBg:setPosition(cc.p(tableNode:getContentSize().width/2, tableNode:getContentSize().height/2))
    tableNode:addChild(myTableBg)
    
    local myTable = CCTableView:create(cc.size(myTableBg:getContentSize().width-4,myTableBg:getContentSize().height-14))
    myTable:setPosition(12,2)
    myTable:setBounceable(true)
    myTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    myTable:setDelegate()
    myTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    
    myTableBg:addChild(myTable)
    
    local function cellSizeForTable(table,idx)
        return  tableSize.width,100
    end
    local function numberOfCellsInTableView(table)
        return #self._static
    end
    local function tableCellAtIndex(table,idx)
        local nowIdx = idx + 1
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
            cell:setContentSize(cc.size(tableSize.width-20, 100))
        else
            cell:removeAllChildren()
        end
        self:initCell(cell, nowIdx)
        return cell
    end
    myTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    myTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    myTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    
    myTable:reloadData()
end
function luckyDrawPop:initCell(cell, idx)

    local static = self._static[idx]
    local cellimg = XTHD.getScaleNode("res/image/common/scale9_bg_32.png", cc.size(cell:getContentSize().width-10,cell:getContentSize().height-3))
    cellimg:setAnchorPoint(cc.p(0.5, 0.5))
    cellimg:setPosition(cc.p(cell:getContentSize().width/2-2, cell:getContentSize().height/2+1))
    cell:addChild(cellimg)
    local sTa = string.split(static.rewardcanshu1, "#")
    -- dump(sTa)
    local rewardList = {}
    rewardList.rewardtype = static.rewardtype1
    rewardList.num = sTa[2]
    if tonumber(static.rewardtype1) == 4 then
        rewardList.id = sTa[1]
    end
    local str = string.sub(static.miaoshu,1,12)
    local myLab = XTHDLabel:createWithParams({
        text = str.." :",
        fontSize = 20,
        color = XTHD.resource.color.brown_desc,
        anchor = cc.p(0, 0.5),
        pos = cc.p(40, cell:getContentSize().height/2),
    })
    cell:addChild(myLab)
    
    local myLab1 = XTHDLabel:createWithParams({
        text = "("..LANGUAGE_VERBS.canGet..")",
        fontSize = 18,
        color = XTHD.resource.color.brown_desc,
        anchor = cc.p(0, 0.5),
        pos = cc.p(150, cell:getContentSize().height/2),
    })
    cell:addChild(myLab1)
    
    local item = ItemNode:createWithParams({
        itemId = rewardList.id,
        _type_ = rewardList.rewardtype,
        count = rewardList.num,
    })
    item:setScale(0.8)
    item:setAnchorPoint(cc.p(0,0.5))
    item:setPosition(cc.p(280, cell:getContentSize().height/2))
    cell:addChild(item)

end
function luckyDrawPop:create(params)
    return self.new(params)
end

function luckyDrawPop:onEnter()
end
function luckyDrawPop:onCleanup()
end
function luckyDrawPop:onExit()
end

return luckyDrawPop